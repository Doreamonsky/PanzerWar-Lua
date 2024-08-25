---@class ScreenShotController : BaseController
---@field view ScreenShotView
ScreenShotController = class("ScreenShotController", BaseController)

Lib()

local M = ScreenShotController

function M:ctor()
    self._isScreenShot = false
    self._canvasList = {}
end

function M:AddListeners()
    self.onScreenShotClicked = handler(self, self.OnScreenShotClicked)
    self.view.vScreenShot.onClick:AddListener(self.onScreenShotClicked)
end

function M:RemoveListener()
    self.view.vScreenShot.onClick:RemoveListener(self.onScreenShotClicked)
end

function M:Awake()
    self:AddListeners()
end

function M:Destroy()
    self:RemoveListener()
end

function M:OnScreenShotClicked()
    self._isScreenShot = not self._isScreenShot

    if self._isScreenShot then
        PopMessageManager.Instance:PushPopup(UIAPI.GetLocalizedContent("ScreenshotModePrompt"), function(res)
            if res then
                local canvasGroup = ComponentAPI.GetObjectsInWorld("CanvasGroup")

                for i = 0, canvasGroup.Length - 1 do
                    canvasGroup[i].alpha = 0
                    table.insert(self._canvasList, canvasGroup[i])
                end
            end
        end)
    else
        for k, v in pairs(self._canvasList) do
            v.alpha = 1
        end

        self._canvasList = {}
    end
end
