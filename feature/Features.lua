require("feature.MultiTurretGUI")
require("feature.BlueprintVehicles")

luaCommonMods = {
    {
        modName = "多炮塔管理-通用",
        author = "超级哆啦酱",
        description = "界面实时更新",
        luaLibVersion = LibVersion,
        onStarted = function()
            MultiTurretGUI.onStarted()
        end,
        onUpdated = function()
            MultiTurretGUI.onUpdated()
        end,
        onFixedUpdated = function()
        end,
        onGUI = function()
        end,
        onLateUpdated = function()
        end,
        onDestroyed = function()
        end,
        onSceneLoaded = function(levelName)
        end
    },
    {
        modName = "蓝图载具测试-通用",
        author = "超级哆啦酱",
        description = "待平衡载具观察",
        luaLibVersion = LibVersion,
        onStarted = function()
            BlueprintVehicles.onStarted()
        end,
        onUpdated = function()
        end,
        onFixedUpdated = function()
        end,
        onGUI = function()
        end,
        onLateUpdated = function()
        end,
        onDestroyed = function()
        end,
        onSceneLoaded = function(levelName)
        end
    }
}
