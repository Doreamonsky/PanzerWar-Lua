--- 坦克工坊的 Gzimo 自定义
--- 比如插槽大小，坐标轴大小


local GizmoConfig = {}
GizmoConfig.configName = "Gizmo"

CameraControllerType = enum({
    "Keypad",
    "Joystick"
})

GizmoConfig.config = {
    ["SlotScale"] = 1,
    ["AxisScale"] = 1,
    ["CameraMoveScale"] = 1,
    ["EnableGrid"] = true,
    ["CameraControllerType"] = CameraControllerType.Keypad,
    ["EnablePressSelect"] = true,
}

GizmoConfig.loadConfig = function()
    local config = ReadConfig(GizmoConfig.configName)

    if config ~= nil then
        local dict = json.decode(config)

        if dict ~= nil then
            for k, v in pairs(dict) do
                GizmoConfig.config[k] = v
            end
        end
    end

    print("成功: 初始化 Gizmo 配置文件")
end

GizmoConfig.saveConfig = function()
    WriteConfig(GizmoConfig.configName, json.encode(GizmoConfig.config))
end

return GizmoConfig
