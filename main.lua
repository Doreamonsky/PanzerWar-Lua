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
            FontAPI.ReplaceAsMainFont(assetPoolRef.go)
            cb(assetPoolRef.go, assetPoolRef)
        else
            error(string.format("can not load ui for %s", id))
        end
    end)
end

LuaUIManager.removeResourceDelegate = function(resourceRef)
    AssetAPI.ReleasePoolAsset(resourceRef)
end

function print_func_ref_by_csharp()
    local registry = debug.getregistry()
    for k, v in pairs(registry) do
        if type(k) == 'number' and type(v) == 'function' and registry[v] == k then
            local info = debug.getinfo(v)
            print(string.format('func ref by c# %s:%d', info.short_src, info.linedefined))
        end
    end
end

FRIEND_TEAM_COLOR = ColorAPI.GetColor(0.01176471, 0.6627451, 0.9568627, 1)
ENEMY_TEAM_COLOR = ColorAPI.GetColor(0.8941177, 0.2235294, 0.2078431, 1)
