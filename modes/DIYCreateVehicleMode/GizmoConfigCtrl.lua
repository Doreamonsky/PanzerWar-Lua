GizmoConfigCtrl = {}

local this = GizmoConfigCtrl

--- @type boolean
--- 是否在编辑 Conifg
this.isEditConfig = false

--- 设置界面初始化
--- @param root Transform
this.onInit = function(root)
    -------- Bind UI Start --------
    this.slotScaleInputField =
        root.transform:Find("DIYCreateVehicleCanvas/GizmoConfig/Bar/Content/SlotScale/InputField"):GetComponent(
        "InputField"
    )
    this.axisScaleInputField =
        root.transform:Find("DIYCreateVehicleCanvas/GizmoConfig/Bar/Content/AxisScale/InputField"):GetComponent(
        "InputField"
    )
    this.enableGridToggle =
        root.transform:Find("DIYCreateVehicleCanvas/GizmoConfig/Bar/Content/EnableGrid/Toggle"):GetComponent("Toggle")

    this.confirmBtn =
        root.transform:Find("DIYCreateVehicleCanvas/GizmoConfig/Bar/Title/ConfirmBtn"):GetComponent("Button")

    this.settingBtn = root.transform:Find("DIYCreateVehicleCanvas/ToolAction/SettingBtn"):GetComponent("Button")
    this.settingGo = root.transform:Find("DIYCreateVehicleCanvas/GizmoConfig").gameObject
    -------- Bind UI End --------
    -- 插槽大小
    this.slotScaleInputField.text = tostring(GizmoConfig.config.SlotScale)
    this.slotScaleInputField.onValueChanged:AddListener(
        function(text)
            local scale = tonumber(text)
            GizmoConfig.config.SlotScale = scale
            this.applyAllSlotsScale(scale)
        end
    )

    -- 坐标轴大小
    this.handleComponent = root.transform:Find("RT-Plugin/Appearance"):GetComponent(typeof(RuntimeHandlesComponent))
    this.handleComponent.HandleScale = GizmoConfig.config.AxisScale

    this.axisScaleInputField.text = tostring(GizmoConfig.config.AxisScale)
    this.axisScaleInputField.onValueChanged:AddListener(
        function(text)
            local scale = tonumber(text)
            GizmoConfig.config.AxisScale = scale
            this.handleComponent.HandleScale = scale
        end
    )

    -- 是否启用 Grid
    this.gridComponent = root.transform:Find("RT-Plugin/SceneGrid").gameObject
    this.gridComponent:SetActive(GizmoConfig.config.EnableGrid)

    this.enableGridToggle.isOn = GizmoConfig.config.EnableGrid
    this.enableGridToggle.onValueChanged:AddListener(
        function(isEnable)
            GizmoConfig.config.EnableGrid = isEnable
            this.gridComponent.gameObject:SetActive(isEnable)
        end
    )

    -------- 进入 / 退出界面 --------
    this.settingBtn.onClick:AddListener(
        function()
            this.settingGo:SetActive(true)
            this.isEditConfig = true
        end
    )

    this.confirmBtn.onClick:AddListener(
        function()
            GizmoConfig.saveConfig()
            this.settingGo:SetActive(false)
            this.isEditConfig = false
        end
    )
    ---------------------------------
end

--- 设置 Config 中（所有）当前插槽大小
this.applyAllSlotsScale = function()
    for k, v in pairs(DIYCreateVehicleMode.slotModifyBtnList) do
        this.applySlotScale(v.transform)
    end
end

--- 设置 Config 中插槽大小
this.applySlotScale = function(slotTransform)
    local scale = GizmoConfig.config.SlotScale
    slotTransform.localScale = Vector3(scale, scale, scale)
end
