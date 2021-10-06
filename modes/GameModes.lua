require("modes.SkirmishMode")
require("modes.FreeCameraMode")
require("modes.MaskTextureMgrMode")
require("modes.DIYCreateVehicleMode")

-- 装甲纷争 自定义模式
luaGameModes = {
    {
        modName = "自由摄像机",
        author = "超级哆啦酱",
        description = "场景自由摄像机",
        luaLibVersion = LibVersion,
        getModeName = function(userLang)
            return "场景自由摄像机"
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
            return "遭遇战"
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
            return "反光贴图全局管理"
        end,
        onStartMode = MaskTextureMgrMode.onStartMode,
        onExitMode = MaskTextureMgrMode.onExitMode,
        isProxyBattle = function()
            return false
        end
    },
    {
        modName = "DIY 创建载具",
        author = "超级哆啦酱",
        description = "创建载具",
        luaLibVersion = LibVersion,
        getModeName = function(userLang)
            return "DIY 创建载具"
        end,
        onStartMode = DIYCreateVehicleMode.onStartMode,
        onExitMode = DIYCreateVehicleMode.onExitMode,
        isProxyBattle = function()
            return false
        end
    }
}
