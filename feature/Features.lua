require("feature.MultiTurretGUI")
require("feature.BlueprintVehicles")
require("feature.EntityFactory")
require("modes.DIYCreateVehicleMode")

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
    },
    {
        modName = "Custom Loops",
        author = "超级哆啦酱",
        description = "模式相关的 update 都可以放在这里",
        luaLibVersion = LibVersion,
        onStarted = function()
        end,
        onUpdated = function()
            DIYCreateVehicleMode.onUpdate()
            DIYCreateMapMode.onUpdate()

            for k,v in pairs(EntityFactory.entities) do
                --- @type Entity
                local x = v
                x:update()
            end
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
