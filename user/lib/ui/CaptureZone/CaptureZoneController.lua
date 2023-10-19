---@class CaptureZoneController : BaseController
---@field view CaptureZoneView
CaptureZoneController = class("CaptureZoneController", BaseController)

Lib()

local M = CaptureZoneController

function M:ctor()
    self._uiMap = {}
    self._selectPointId = -1
    self._mainPlayerVehicle = nil
end

function M:AddListeners()
    -- C#
    self.onTick = handler(self, self.OnTick)
    self.onPickMainPlayerVehicle = handler(self, self.OnPickMainPlayerVehicle)
    TimeAPI.RegisterQuarterTick(self.onTick)
    ModeAPI.RegisterPickVehicleCallBack(self.onPickMainPlayerVehicle)

    -- Lua
    self.onPickVehicleClicked = handler(self, self.OnPickVehicleClicked)
    self.onBattleClicked = handler(self, self.OnBattleClicked)

    self.view.vPickVehicle.onClick:AddListener(self.onPickVehicleClicked)
    self.view.vBattle.onClick:AddListener(self.onBattleClicked)
    EventSystem.AddListener(EventDefine.OnZonePickBarVisibilityChanged, self.OnPickBarChanged, self)
end

function M:RemoveListener()
    -- C#
    TimeAPI.UnRegisterQuarterTick(self.onTick)
    ModeAPI.UnRegisterPickVehicleCallBack(self.OnPickMainPlayerVehicle)

    -- Lua
    self.view.vPickVehicle.onClick:RemoveListener(self.onPickVehicleClicked)
    self.view.vBattle.onClick:RemoveListener(self.onBattleClicked)
    EventSystem.RemoveListener(EventDefine.OnZonePickBarVisibilityChanged, self.OnPickBarChanged, self)
end

function M:Awake()
    ---@type CaptureZone
    self.mode = ModeAPI.GetModeInstance()

    local captureZones = CaptureZoneAPI.GetCaptureZoneInfos()

    for i = 0, captureZones.Length - 1 do
        local captureZone = captureZones[i]
        local instance = GameObjectAPI.Clone(self.view.vPointTemplate)

        local btn = ComponentAPI.GetNativeComponent(instance, "Button")
        btn.onClick:AddListener(function()
            self._selectPointId = captureZone:GetIndex()
        end)

        local text = ComponentAPI.GetNativeComponent(GameObjectAPI.Find(instance, "Text"), "Text")
        text.text = captureZone.zoneName

        local img = ComponentAPI.GetNativeComponent(GameObjectAPI.Find(instance, "Fill"), "Image")

        self._uiMap[captureZone:GetIndex()] = {
            root = instance,
            img = img,
            text = text
        }
    end

    self:PickMainPlayerVehicle(self.mode.mainPlayerList[0])
    self:RefreshCaptureStatus()
    self:RefreshCaptureScreen()
    self:AddListeners()
end

function M:Destroy()
    self:RemoveListener()

    for k, v in pairs(self._uiMap) do
        GameObjectAPI.DestroyObject(v.root)
    end

    self._uiMap = {}
end

function M:OnTick()
    self:RefreshCaptureStatus()
end

function M:OnPickVehicleClicked()
    ModeAPI.ShowPickVehicleUIWithList(false, self.mode.mainPlayerList)
end

function M:OnPickMainPlayerVehicle(evtData)
    self:PickMainPlayerVehicle(evtData.VehicleInfo)
end

---@param vehicleInfo ShanghaiWindy.Core.VehicleInfo
function M:PickMainPlayerVehicle(vehicleInfo)
    self._mainPlayerVehicle = vehicleInfo

    VehicleAPI.LoadVehicleThumbnail(vehicleInfo, function(thumbnail)
        self.view.vVehicleThumbnail.sprite = thumbnail
        self.view.vVehicleName.text = vehicleInfo:GetDisplayName()
        self.view.vVehicleRank.text = vehicleInfo:GetRank()
    end)
end

function M:OnPickBarChanged(isActive)
    GameObjectAPI.SetActive(self.view.vCapturePickBar, isActive)
    self:RefreshCaptureScreen()
end

function M:OnBattleClicked()
    self.mode:SpawnMainPlayer(self._mainPlayerVehicle, self._selectPointId)
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


function M:RefreshCaptureScreen()
    local bgCam = CameraAPI.GetBackGroundCamera()
    local captureZones = CaptureZoneAPI.GetCaptureZoneInfos()

    for i = 0, captureZones.Length - 1 do
        local captureZone = captureZones[i]
        local instance = self._uiMap[captureZone:GetIndex()].root
        local screenPoint = CameraAPI.WorldToScreenPoint(bgCam, captureZone.point)
        instance.transform.position = screenPoint
    end
    
end

function M:RefreshCaptureStatus()
    for index, res in pairs(self._uiMap) do
        local captureZone = CaptureZoneAPI.GetCaptureZone(index)

        if captureZone.capturingTeam == TeamAPI.GetRedTeam() then
            res.img.color = ColorAPI.GetColor(1, 0, 0, 1)
        elseif captureZone.capturingTeam == TeamAPI.GetBlueTeam() then
            res.img.color = ColorAPI.GetColor(0, 0, 1, 1)
        else
            res.img.color = ColorAPI.GetColor(1, 1, 1, 1)
        end

        res.img.fillAmount = captureZone.currentCaptureProgress
    end
end
