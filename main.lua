-- Lua 的入口， xlua 初始化调用

-- Base 基础相关
require("frame.core") -- 框架
require("game.all")   -- 游戏侧脚本

Config.loadAllConfigs()

-- 禁止屏熄
Screen.sleepTimeout = CS.SleepTimeout.NeverSleep
