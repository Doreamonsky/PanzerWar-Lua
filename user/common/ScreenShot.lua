local ScreenShot = class("ScreenShot")

Common()

local M = ScreenShot

function M:OnStarted()
    if OBJECT_API then
        LuaUIManager.CreateUI(ScreenShotView.new(), ScreenShotController.new(),
            "a93b1cf1-71c6-4a11-8354-6c13e3bd232e",
            "LuaScreenShot.prefab")
    end
end

return M
