---@class CaptureZoneController : BaseController
---@field view CaptureZoneView
CaptureZoneController = class("CaptureZoneController", BaseController)

Lib()

---@class ZoneUI
---@field index number
---@field root GameObject
---@field capturedGo GameObject
---@field unCapturedGo GameObject
---@field capturedFillImg Image
---@field unCapturedFillImg Image
---@field text Text
---@field isSceneUI boolean
---------------------------------


local M = CaptureZoneController

function M:ctor()
    ---@type CaptureZone
    self._mode = nil

    ---@type table<number,ZoneUI>
    self._uis = {}
    self._selectPointId = -1
    self._mainPlayerVehicle = nil
    self._isPickBar = false
end

function M:AddListeners()
    -- C#
    self.onQuarterTick = handler(self, self.OnQuarterTick)
    self.onLateTick = handler(self, self.OnLateTick)
    self.onPickMainPlayerVehicle = handler(self, self.OnPickMainPlayerVehicle)
    TimeAPI.RegisterQuarterTick(self.onQuarterTick)
    TimeAPI.RegisterLateFrameTick(self.onLateTick)
    ModeAPI.RegisterPickVehicleCallBack(self.onPickMainPlayerVehicle)

    -- Lua
    self.view.vPickVehicle.onClick:AddListener(handler(self, self.OnPickVehicleClicked))
    self.view.vBattle.onClick:AddListener(handler(self, self.OnBattleClicked))
    EventSystem.AddListener(EventDefine.OnPickBarVisibilityChanged, self.OnPickBarChanged, self)
end

function M:RemoveListener()
    -- C#
    TimeAPI.UnRegisterQuarterTick(self.onQuarterTick)
    TimeAPI.UnRegisterLateFrameTick(self.onLateTick)
    ModeAPI.UnRegisterPickVehicleCallBack(self.onPickMainPlayerVehicle)

    -- Lua
    self.view.vPickVehicle.onClick:RemoveAllListeners()
    self.view.vBattle.onClick:RemoveAllListeners()
    EventSystem.RemoveListener(EventDefine.OnPickBarVisibilityChanged, self.OnPickBarChanged, self)
end

function M:Awake()
    ---@type Frontend.Runtime.Battle.Mode.CaptureZoneNetGameMode
    self._mode = ModeAPI.GetModeInstance()

    self:CreateZoneUI(true)
    self:CreateZoneUI(false)

    GameObjectAPI.SetActive(self.view.vPointTemplate, false)
    self:OnPickBarChanged(true)
    self:PickMainPlayerVehicle(self._mode.mainPlayerList[0])
    self:RefreshCaptureStatus()
    self:RefreshCaptureScreenUI()
    self:RefreshBackgroundCamera()
    self:AddListeners()
end

function M:Destroy()
    self:RemoveListener()

    for k, v in pairs(self._uis) do
        GameObjectAPI.DestroyObject(v.root)
    end

    self._uis = nil
end

function M:OnQuarterTick()
    self:RefreshCaptureStatus()

    if self._isPickBar then
        self:RefreshPickedCapturePointStatus()
        self:RefreshCaptureScreenUI()
        self:RefreshBackgroundCamera()
    end
end

function M:OnLateTick()
    self:RefreshCaptureScreenUI()
    self:RefreshCoolDownMask()
end

function M:CreateZoneUI(isSceneUI)
    local captureZones = CaptureZoneAPI.GetCaptureZoneInfos()

    for i = 0, captureZones.Length - 1 do
        local captureZone = captureZones[i]
        local instance = GameObjectAPI.Clone(self.view.vPointTemplate)
        GameObjectAPI.SetActive(instance, true)

        local btn = ComponentAPI.GetNativeComponent(instance, "Button")
        btn.onClick:AddListener(function()
            self._selectPointId = captureZone:GetIndex()
        end)

        local text = ComponentAPI.GetNativeComponent(GameObjectAPI.Find(instance, "Text"), "Text")
        text.text = captureZone.zoneName

        local capturedFill = ComponentAPI.GetNativeComponent(GameObjectAPI.Find(instance, "Captured/Fill"), "Image")
        local unCapturedFill = ComponentAPI.GetNativeComponent(GameObjectAPI.Find(instance, "UnCaptured/Fill"), "Image")

        table.insert(self._uis,
            {
                index = captureZone:GetIndex(),
                root = instance,
                capturedGo = GameObjectAPI.Find(instance, "Captured"),
                unCapturedGo = GameObjectAPI.Find(instance, "UnCaptured"),
                capturedFillImg = capturedFill,
                unCapturedFillImg = unCapturedFill,
                text = text,
                isSceneUI = isSceneUI
            })
        if not isSceneUI then
            instance.transform:SetParent(self.view.vZoneList.transform)
        end
    end
end

function M:OnPickVehicleClicked()
    ModeAPI.ShowPickVehicleUIWithList(false, self._mode.mainPlayerList)
end

function M:OnPickMainPlayerVehicle(evtData)
    self:PickMainPlayerVehicle(evtData.VehicleInfo)
end

---@param vehicleInfo ShanghaiWindy.Core.VehicleInfo
function M:PickMainPlayerVehicle(vehicleInfo)
    self._mainPlayerVehicle = vehicleInfo

    self.view.vVehicleName.text = vehicleInfo:GetDisplayName()
    self.view.vVehicleRank.text = vehicleInfo:GetRank()
    VehicleAPI.LoadVehicleThumbnail(vehicleInfo, function(thumbnail)
        self.view.vVehicleThumbnail.sprite = thumbnail
    end)
end

function M:OnPickBarChanged(isActive)
    self._isPickBar = isActive

    GameObjectAPI.SetActive(self.view.vCapturePickBar, isActive)
    self:RefreshCaptureScreenUI()
    self:RefreshBackgroundCamera()


    for k, v in pairs(self._uis) do
        local img = ComponentAPI.GetNativeComponent(v.root, "Image")
        img.raycastTarget = isActive
    end
end

function M:OnBattleClicked()
    self._mode:SpawnMainPlayer(self._mainPlayerVehicle, self._selectPointId)
end

function M:CreateBotPlayerList(num, team)
    local list = {}

    for i = 1, num do
        local bot = BattlePlayerAPI.CreateOfflineBotPlayer(self.index, "黑暗降临", nil)
        bot.BotTeam = team

        ModeAPI.AddBattlePlayer(bot)

        table.insert(list, bot)
        self.index = self.index + 1
    end

    return list
end

function M:RefreshBackgroundCamera()
    local config = self._mode._curConfig

    CameraAPI.SetBackgroundCameraPosition(config.backgroundCameraTransformInfo.pos)
    CameraAPI.SetBackgroundCameraEulerAngles(config.backgroundCameraTransformInfo.eulerAngle)
end

--- Update the screen position of capture point
function M:RefreshCaptureScreenUI()
    for k, ui in pairs(self._uis) do
        local captureZone = CaptureZoneAPI.GetCaptureZone(ui.index)
        local instance = ui.root

        if ui.isSceneUI then
            local screenPos, eIconPosition = CameraAPI.GetScreenPosition(captureZone.point + Vector3(0, 15, 0))
            instance.transform.position = screenPos

            GameObjectAPI.SetVisible(instance, eIconPosition ~= EIconPosition.Top)
        end
    end
end

--- Update the capture progress and owner of the points
function M:RefreshCaptureStatus()
    for k, ui in pairs(self._uis) do
        local captureZone = CaptureZoneAPI.GetCaptureZone(ui.index)

        if captureZone.captureStage == ECaptureStage.Own then
            GameObjectAPI.SetVisible(ui.capturedGo, true)
            GameObjectAPI.SetVisible(ui.unCapturedGo, false)
        else
            GameObjectAPI.SetVisible(ui.capturedGo, false)
            GameObjectAPI.SetVisible(ui.unCapturedGo, true)
        end

        ui.capturedFillImg.color = self:GetTeamColor(captureZone.capturingTeam)
        ui.capturedFillImg.fillAmount = captureZone.currentCaptureProgress

        ui.unCapturedFillImg.color = self:GetTeamColor(captureZone.capturingTeam)
        ui.unCapturedFillImg.fillAmount = captureZone.currentCaptureProgress
    end
end

--- Update the picked point status
function M:RefreshPickedCapturePointStatus()
    local isPicked = self._selectPointId ~= -1
    GameObjectAPI.SetActive(self.view.vPickPoint, isPicked)

    if isPicked then
        local captureZone = CaptureZoneAPI.GetCaptureZone(self._selectPointId)
        self.view.vPickPointName.text = captureZone.zoneName

        self.view.vPickPointFill.color = self:GetTeamColor(captureZone.capturingTeam)
        self.view.vPickPointFill.fillAmount = captureZone.currentCaptureProgress

        local canSpawn = captureZone.capturingTeam ~= TeamAPI.GetPlayerTeam()
        GameObjectAPI.SetActive(self.view.vSpawnWarning, canSpawn)
    else
        GameObjectAPI.SetActive(self.view.vSpawnWarning, false)
    end
end

--- Add mask to vehicle when time is cooling
function M:RefreshCoolDownMask()
    local isCoolDown = false

    for index, spawnInfo in pairs(self._mode._playerSpawnQueue) do
        if spawnInfo.player:IsLocalPlayer() then
            isCoolDown = true
            local leftTime = math.ceil(self._mode._coolDownTime - (TimeAPI.GetTime() - spawnInfo.killTime))

            if leftTime < 0 then
                leftTime = 0
            end

            self.view.vCoolDownTime.text = leftTime
        end
    end

    self.view.vBattle.interactable = not isCoolDown
    GameObjectAPI.SetActive(self.view.vCoolDownMask, isCoolDown)
end

function M:GetTeamColor(team)
    if team == TeamAPI.GetPlayerTeam() then
        return FRIEND_TEAM_COLOR
    else
        return ENEMY_TEAM_COLOR
    end
end
