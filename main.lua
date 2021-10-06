-- Base 基础相关
require("LibVersion") -- Lua C# 交互版本
require("Core") -- 框架
require("GlobalDefine") -- 方便调用 C#

-- GamePlay 玩法相关
require("feature.Features")
require("modes.GameModes")

-- print("Runing on the test lua")

-- local a = CustomClass
-- a:Init()

-- EventSystem.DispatchEvent(Events.Hello, "call from here")
-- EventSystem.DispatchEvent(Events.Hello, "another call")

-- a:OnDestroy()
