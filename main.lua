-- Lua 的入口， xlua 初始化调用

-- Base 基础相关
require("Class")
require("LibVersion") -- Lua C# 交互版本
require("Core") -- 框架
require("GlobalDefine") -- 方便调用 C#

-- GamePlay 玩法相关
require("feature.Features")
require("modes.GameModes")

Config.loadAllConfigs()

-- 测试一下 Config 系统
GizmoConfig.config.AxisScale = 2
GizmoConfig.saveConfig()

-- print(GetLuaDataFolder())

-- local conifg = {
--     test = "this is a string",
--     p = {
--         [1] = 2,
--         [2] = 4
--     }
-- }

-- WriteConfig("test", json.encode(conifg))

-- local decoded = json.decode(ReadConfig("test"))
-- print(decoded.test)

-- print("Runing on the test lua")

-- local a = CustomClass
-- a:Init()

-- EventSystem.DispatchEvent(Events.Hello, "call from here")
-- EventSystem.DispatchEvent(Events.Hello, "another call")

-- a:OnDestroy()
