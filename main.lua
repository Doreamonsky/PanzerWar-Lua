-- Lua 的入口， xlua 初始化调用

-- Base 基础相关
require("frame.core") -- 框架
require("game.all")   -- 游戏侧脚本

Config.loadAllConfigs()

-- 禁止屏熄
Screen.sleepTimeout = CS.SleepTimeout.NeverSleep

LuaUIManager.createResourceDelegate = function(cb, ...)
    local id = select(1, ...)
    local fileName = select(2, ...)

    AssetAPI.LoadPoolAsset(id, fileName, function(assetPoolRef)
        if assetPoolRef:IsValid() then
            cb(assetPoolRef.go, assetPoolRef)
        else
            error(string.format("can not load ui for %s", id))
        end
    end)
end

LuaUIManager.removeResourceDelegate = function(resourceRef)
    AssetAPI.ReleasePoolAsset(resourceRef)
end
