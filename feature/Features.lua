require("feature.MultiTurretGUI")

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
    }
}
