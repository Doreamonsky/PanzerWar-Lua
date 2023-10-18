---@class CaptureZoneController : BaseController
---@field view CaptureZoneView
CaptureZoneController = class("CaptureZoneController", BaseController)

Lib()

local M = CaptureZoneController

function M:Awake()
    print(self.view.vPointTemplate)
    print("xxxx")
end

function M:Dispose()
end
