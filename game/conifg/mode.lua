--- 坦克工坊的 Gzimo 自定义
--- 比如插槽大小，坐标轴大小

local LuaModeConfig = {}

LuaModeConfig.configName = "LuaMode"

LuaModeConfig.config = {
    ["MultiTurretGUI"] = true
}

LuaModeConfig.loadConfig = function()
    local config = ReadConfig(LuaModeConfig.configName)

    if config ~= nil then
        local dict = json.decode(config)

        if dict ~= nil then
            for k, v in pairs(dict) do
                LuaModeConfig.config[k] = v
            end
        end
    end
end

LuaModeConfig.saveConfig = function()
    WriteConfig(LuaModeConfig.configName, json.encode(LuaModeConfig.config))
end

return LuaModeConfig
