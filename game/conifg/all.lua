--- 新增的 Config 统一在这里添加
GizmoConfig = require("game.conifg.gizmo")
LuaModeConfig = require("game.conifg.mode")


local Config = {}

--- 加载所有的配置文件
--- lua 环境创建时候调用
Config.loadAllConfigs = function()
    GizmoConfig.loadConfig()
    LuaModeConfig.loadConfig()
end

return Config
