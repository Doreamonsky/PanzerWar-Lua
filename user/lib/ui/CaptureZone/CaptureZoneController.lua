---@class CaptureZoneController : BaseController
---@field view CaptureZoneView
CaptureZoneController = class("CaptureZoneController", BaseController)

Lib()

local M = CaptureZoneController

function M:ctor()
    self._uiMap = {}
    self._selectPointId = -1
end

function M:AddListeners()
    self.onTick = handler(self, self.OnTick)
    self.onPickVehicleClicked = handler(self, self.OnPickVehicleClicked)

    TimeAPI.RegisterQuarterTick(self.onTick)
    self.view.vPickVehicle.onClick:AddListener(self.onPickVehicleClicked)
end

function M:RemoveListener()
    TimeAPI.UnRegisterQuarterTick(self.onTick)
    self.view.vPickVehicle.onClick:RemoveListener(self.onPickVehicleClicked)
end

function M:Awake()
    local captureZones = CaptureZoneAPI.GetCaptureZoneInfos()
    local bgCam = CameraAPI.GetBackGroundCamera()

    for i = 0, captureZones.Length - 1 do
        local captureZone = captureZones[i]
        local instance = GameObjectAPI.Clone(self.view.vPointTemplate)
        local screenPoint = CameraAPI.WorldToScreenPoint(bgCam, captureZone.point)

        instance.transform.position = screenPoint

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

    self:RefreshCaptureStatus()
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
    ---@type CaptureZone
    local mode = ModeAPI.GetModeInstance()
    ModeAPI.ShowPickVehicleUIWithList(false, mode.mainPlayerList)
end

function M:RefreshCaptureStatus()
    for index, res in pairs(self._uiMap) do
        local captureZone = CaptureZoneAPI.GetCaptureZone(index)

        if captureZone.capturingTeam:Get() == TeamAPI.GetRedTeam() then
            res.img.color = ColorAPI.GetColor(1, 0, 0, 1)
        elseif captureZone.capturingTeam:Get() == TeamAPI.GetBlueTeam() then
            res.img.color = ColorAPI.GetColor(0, 0, 1, 1)
        else
            res.img.color = ColorAPI.GetColor(1, 1, 1, 1)
        end

        res.img.fillAmount = captureZone.currentCaptureProgress
    end
end
