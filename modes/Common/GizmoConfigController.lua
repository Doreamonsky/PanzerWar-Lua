--- @class GizmoConfigController
GizmoConfigController = class("GizmoConfigController")

--- 设置界面初始化
--- @param gizmoUITransform Transform GizmoConfig 的 Transform
--- @param entryButton Button 进入此界面的按钮
function GizmoConfigController:init(gizmoUITransform, rtPluginTransform, entryButton)
    -------- Bind UI Start --------
    self.slotScaleInputField = gizmoUITransform.transform:Find("Bar/Content/SlotScale/InputField"):GetComponent(
        "InputField"
    )
    self.axisScaleInputField = gizmoUITransform.transform:Find("Bar/Content/AxisScale/InputField"):GetComponent(
        "InputField"
    )
    self.cameraMoveScaleInputField = gizmoUITransform.transform:Find("Bar/Content/CameraMoveScale/InputField"):GetComponent(
        "InputField"
    )
    self.enableJoysitckToggle = gizmoUITransform.transform:Find("Bar/Content/EnableJoysitckToggle/Toggle"):GetComponent(
        "Toggle"
    )
    
    self.enableGridToggle = gizmoUITransform.transform:Find("Bar/Content/EnableGrid/Toggle"):GetComponent("Toggle")

    self.confirmBtn = gizmoUITransform.transform:Find("Bar/Title/ConfirmBtn"):GetComponent("Button")

    self.settingBtn = entryButton
    self.settingGo = gizmoUITransform.gameObject
    -------- Bind UI End --------
    -- 插槽大小
    self.slotScaleInputField.text = tostring(GizmoConfig.config.SlotScale)
    self.slotScaleInputField.onValueChanged:AddListener(
        function(text)
            local scale = tonumber(text)
            GizmoConfig.config.SlotScale = scale
            self:applyAllSlotsScale(scale)
        end
    )

    -- 坐标轴大小
    self.handleComponent = rtPluginTransform:Find("Appearance"):GetComponent(typeof(RuntimeHandlesComponent))
    self.handleComponent.HandleScale = GizmoConfig.config.AxisScale

    self.axisScaleInputField.text = tostring(GizmoConfig.config.AxisScale)
    self.axisScaleInputField.onValueChanged:AddListener(
        function(text)
            local scale = tonumber(text)
            GizmoConfig.config.AxisScale = scale
            self.handleComponent.HandleScale = scale
        end
    )

    -- 摄像机移速
    self.cameraMoveScaleInputField.text = tostring(GizmoConfig.config.CameraMoveScale)
    self.cameraMoveScaleInputField.onValueChanged:AddListener(
        function(text)
            local scale = tonumber(text)
            GizmoConfig.config.CameraMoveScale = scale
        end
    )

    -- 是否启用 虚拟摇杆
    self.enableJoysitckToggle.isOn = GizmoConfig.config.CameraControllerType == CameraControllerType.Joystick
    self.enableJoysitckToggle.onValueChanged:AddListener(
        function(isEnable)
            if isEnable then
                GizmoConfig.config.CameraControllerType = CameraControllerType.Joystick
            else
                GizmoConfig.config.CameraControllerType = CameraControllerType.Keypad
            end
        end
    )

    -- 是否启用 Grid
    self.gridComponent = rtPluginTransform:Find("SceneGrid").gameObject
    self.gridComponent:SetActive(GizmoConfig.config.EnableGrid)

    self.enableGridToggle.isOn = GizmoConfig.config.EnableGrid
    self.enableGridToggle.onValueChanged:AddListener(
        function(isEnable)
            GizmoConfig.config.EnableGrid = isEnable
            self.gridComponent.gameObject:SetActive(isEnable)
        end
    )

    -------- 进入 / 退出界面 --------
    self.settingBtn.onClick:AddListener(
        function()
            self.settingGo:SetActive(true)
        end
    )

    self.confirmBtn.onClick:AddListener(
        function()
            GizmoConfig.saveConfig()
            self.settingGo:SetActive(false)

            EventSystem.DispatchEvent(EventDefine.OnGizmoConfigChanged)
        end
    )
    ---------------------------------
end

--- 设置 Config 中（所有）当前插槽大小
function GizmoConfigController:applyAllSlotsScale()
    for k, v in pairs(DIYCreateVehicleMode.slotModifyBtnList) do
        self:applySlotScale(v.transform)
    end
end

--- 设置 Config 中插槽大小
function GizmoConfigController:applySlotScale(slotTransform)
    local scale = GizmoConfig.config.SlotScale
    slotTransform.localScale = Vector3(scale, scale, scale)
end

return GizmoConfigController
