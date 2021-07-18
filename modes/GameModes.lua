require("modes.SkirmishMode")
require("modes.FreeCameraMode")
require("modes.MaskTextureMgrMode")
require("LibVersion")

-- 装甲纷争 自定义模式
luaGameModes = {
    {
        modName = "自由摄像机",
        author = "超级哆啦酱",
        description = "场景自由摄像机",
        luaLibVersion = LibVersion,
        getModeName = function(userLang)
            if userLang == "CN" then
                return "场景自由摄像机"
            else
                return "Free Camera"
            end
        end,
        onStartMode = FreeCameraMode.onStartMode,
        onExitMode = FreeCameraMode.onExitMode,
        isProxyBattle = function()
            return true
        end
    },
    {
        modName = "遭遇战（重生战）",
        author = "超级哆啦酱",
        description = "遭遇战",
        luaLibVersion = LibVersion,
        getModeName = function(userLang)
            if userLang == "CN" then
                return "遭遇战"
            else
                return "Conquer Mode"
            end
        end,
        onStartMode = SkirmishMode.onStartMode,
        onExitMode = SkirmishMode.onExitMode,
        isProxyBattle = function()
            return true
        end
    },
    {
        modName = "反光贴图全局管理",
        author = "超级哆啦酱",
        description = "可视化的全局管理反光贴图。",
        luaLibVersion = LibVersion,
        getModeName = function(userLang)
            if userLang == "CN" then
                return "反光贴图全局管理"
            else
                return "Mask Texture Global Manager"
            end
        end,
        onStartMode = MaskTextureMgrMode.onStartMode,
        onExitMode = MaskTextureMgrMode.onExitMode,
        isProxyBattle = function()
            return false
        end
    }
}
