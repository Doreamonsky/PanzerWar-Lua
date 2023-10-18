---@class CaptureZoneController : BaseController
---@field view CaptureZoneView
CaptureZoneController = class("CaptureZoneController", BaseController)

Lib()

local M = CaptureZoneController

function M:ctor()
    self.uiMap = {}
end

function M:AddListeners()
    self.onTick = handler(self, self.OnTick)
    TimeAPI.RegisterQuarterTick(self.onTick)
end

function M:RemoveListener()
    TimeAPI.UnRegisterQuarterTick(self.onTick)
end

function M:Awake()
    local captureZones = CaptureZoneAPI.GetCaptureZoneInfos()
    local bgCam = CameraAPI.GetBackGroundCamera()

    for i = 0, captureZones.Length - 1 do
        local captureZone = captureZones[i]
        local instance = GameObjectAPI.Clone(self.view.vPointTemplate)
        local screenPoint = CameraAPI.WorldToScreenPoint(bgCam, captureZone.point)

        instance.transform.position = screenPoint

        local text = ComponentAPI.GetNativeComponent(GameObjectAPI.Find(instance, "Text"), "Text")
        text.text = captureZone.zoneName

        local img = ComponentAPI.GetNativeComponent(GameObjectAPI.Find(instance, "Fill"), "Image")

        self.uiMap[captureZone:GetIndex()] = {
            img = img,
            text = text
        }
    end

    self:RefreshCaptureStatus()
    self:AddListeners()
end

function M:Destroy()
    self:RemoveListener()
end

function M:OnTick()
    self:RefreshCaptureStatus()
end

function M:RefreshCaptureStatus()
    for index, res in pairs(self.uiMap) do
        local captureZone = CaptureZoneAPI.GetCaptureZone(index)

        if captureZone.capturingTeam:Get() == TeamAPI.GetRedTeam() then
            res.img.color = ColorAPI.GetColor(1, 0, 0, 1)
        elseif captureZone.capturingTeam:Get() == TeamAPI.GetBlueTeam() then
            res.img.color = Color.GetColor(0, 0, 0, 1, 1)
        end

        res.img.fillAmount = captureZone.currentCaptureProgress
        print(res.img.fillAmount)
    end
end
