DIYCreateVehicleMode = {}

--- TODO:
--- DIY Finalize Created
--- 检查哪个是 Main Hull Main Turret Main Gun

local this = DIYCreateVehicleMode
this.onStartMode = function()
    this.userDefined = DIYUserDefined()

    CSharpAPI.RequestScene(
        "Physic-Play",
        function()
            CSharpAPI.LoadAssetBundle(
                "DIYCreateVehicleUtil",
                "mod",
                function(asset)
                    if asset ~= nil then
                        this.onUtilCreated(GameObject.Instantiate(asset))
                    end
                end
            )
        end
    )
end

this.onUtilCreated = function(root)
    this.slotModifyBtnTemplate = root.transform:Find("DIYCreateVehicleCanvas/Slots/SlotModifyBtn")
    this.slotModifyBtnTemplate.gameObject:SetActive(false)

    this.equipTemplate = root.transform:Find("DIYCreateVehicleCanvas/EquipList/Scroll View/Viewport/Content/Template")
    this.equipTemplate.gameObject:SetActive(false)

    this.slotDisableMask = root.transform:Find("DIYCreateVehicleCanvas/SlotDisableMask")
    this.slotDisableMask.gameObject:SetActive(false)

    this.slotDisableMask:GetComponent("Button").onClick:AddListener(
        function()
            this.toggleEquipList(true)
        end
    )

    --- Slot 增加配件交互UI按钮列表
    this.slotModifyBtnList = {}

    --- 可装的配件UI物体列表
    this.installableEquipUIList = {}

    --- 已装配件UI物体列表
    this.installedEquipUIList = {}

    --- 创建DIY载具的中间件
    this.bindingData = nil

    --- 实例载具模型
    this.instanceMesh = nil

    this.refreshInstallableEquipList()

    this.addRule(CSharpAPI.GetGUID(), "d526381d-f6e4-42fc-9f6b-548866c23241", true, nil, 0)
    -- this.addRule(2, "ee45c582-3a2f-4f50-b674-46bc62edf381", true, 1, 0)
    -- this.addRule(3, "5c02c009-51bc-4260-b00e-4dbf26d9325e", true, 2, 0)
    -- this.addRule(4, "ee45c582-3a2f-4f50-b674-46bc62edf381", false, 1, 1)

    CSharpAPI.CreateNewDIYVehicle(
        this.userDefined,
        function(instanceMesh, textData, bindingData)
            this.bindingData = bindingData
            this.refreshEquipSlotInteractBtn()

            this.instanceMesh = instanceMesh
        end
    )
end

--- 创建右侧的配件显示
this.createEquipUIObject = function(baseData)
    local instance = GameObject.Instantiate(this.equipTemplate, this.equipTemplate.transform.parent, true)
    instance.transform:Find("Title"):GetComponent("Text").text = baseData.displayName:GetDisplayName()
    instance.transform:Find("Description"):GetComponent("Text").text = baseData.description:GetDisplayName()
    instance.transform:Find("Type"):GetComponent("Text").text = this.getBaseDataTypeText(baseData:GetDataType())
    instance.gameObject:SetActive(true)
    return instance
end

this.getBaseDataTypeText = function(dataType)
    local text = "未知"

    if dataType == DIYDataEnum.Hull then
        text = "车体"
    elseif dataType == DIYDataEnum.Turret then
        text = "炮塔"
    elseif dataType == DIYDataEnum.Gun then
        text = "炮管"
    elseif dataType == DIYDataEnum.Item then
        text = "物品"
    end

    return text
end

--- 刷新 Slot 添加的 Icon
this.refreshEquipSlotInteractBtn = function()
    -- 删除之前的按钮
    for k, v in pairs(this.slotModifyBtnList) do
        GameObject.Destroy(v.gameObject)
    end

    this.slotModifyBtnList = {}

    -- 获取配件安装的状态
    --- @type table<string,boolean[]>
    local slotStatus = {}
    local slotInfoCache = {}

    -- 获取配件的插槽信息
    for index, x in pairs(this.userDefined.rules) do
        --- @type DIYRule
        local rule = x
        local slotInfos = DIYDataManager.Instance:GetData(rule.itemGuid).slotInfos

        local status = {}

        for i = 0, slotInfos.Length - 1 do
            table.insert(status, false)
        end

        slotStatus[rule.ruleGuid] = status
        slotInfoCache[rule.ruleGuid] = slotInfos
    end

    -- 获取配件插槽的占用信息
    for index, x in pairs(this.userDefined.rules) do
        --- @type DIYRule
        local rule = x

        if rule.parentRuleGuid and rule.parentRuleGuid ~= "" then
            slotStatus[rule.parentRuleGuid][rule.targetSlotIndex + 1] = true -- 注意 Lua index 比 c# +1
        end
    end

    for ruleGuid, statusArray in pairs(slotStatus) do
        for j, status in pairs(statusArray) do
            if not status then
                local slotIndex = j - 1
                local slotOwnerRuleId = ruleGuid

                local iconPos = CSharpAPI.GetSlotPosFromBinding(slotOwnerRuleId, slotIndex, this.bindingData)

                local instance =
                    GameObject.Instantiate(
                    this.slotModifyBtnTemplate,
                    this.slotModifyBtnTemplate.transform.parent,
                    true
                )

                instance:GetComponent(typeof(CS.ShanghaiWindy.Core.IconScreenPositionCtrl)).worldPos = iconPos
                instance:GetComponent("Button").onClick:AddListener(
                    function()
                        this.selectSlot(slotOwnerRuleId, slotIndex)
                    end
                )
                instance.gameObject:SetActive(true)

                table.insert(this.slotModifyBtnList, instance)
            end
        end
    end
end

this.refreshInstallableEquipList = function()
    for index, baseData in pairs(DIYDataManager.Instance:GetEquipableData()) do
        local instance = this.createEquipUIObject(baseData)

        instance.transform:Find("InstallBtn").gameObject:SetActive(true)
        instance.transform:Find("InstallBtn"):GetComponent("Button").onClick:AddListener(
            function()
                this.equipSlot(baseData.itemGUID)
            end
        )

        table.insert(this.installableEquipUIList, instance)
    end
end

--- 根据 Rule 刷新已安装的配件 UI 列表
this.refreshInstalledEquipList = function()
    for k, v in pairs(this.installedEquipUIList) do
        GameObject.Destroy(v.gameObject)
    end

    this.installedEquipUIList = {}

    for index, x in pairs(this.userDefined.rules) do
        --- @type DIYRule
        local rule = x
        local instance = this.createEquipUIObject(DIYDataManager.Instance:GetData(rule.itemGuid))
        instance.transform:Find("UninstallBtn").gameObject:SetActive(true)
        instance.transform:Find("UninstallBtn"):GetComponent("Button").onClick:AddListener(
            function()
                this.unequipSlot(rule.ruleGuid)
            end
        )

        table.insert(this.installedEquipUIList, instance)
    end
end

--- 增加规则 （比较简单）
--- TODO: isMain 放入这里计算
this.addRule = function(ruleGuid, itemGuid, isMain, parentRuleGuid, targetSlotIndex)
    local rule = DIYRule()
    rule.ruleGuid = ruleGuid
    rule.itemGuid = itemGuid
    rule.isMain = isMain
    rule.parentRuleGuid = parentRuleGuid
    rule.targetSlotIndex = targetSlotIndex
    this.userDefined.rules:Add(rule)
end

-- 删除规则 （需要遍历是否有节点依赖于此节点，比较复杂，放 C# 写（虽然 lua 也可以写但逻辑很烦））
this.deleteRule = function(ruleGuid)
    CSharpAPI.DeleteDIYRule(this.userDefined, ruleGuid)
end

this.selectSlot = function(slotOwnerRuleId, slotIndex)
    this.toggleEquipList(false)

    this.curSlotOwnerRuleId = slotOwnerRuleId
    this.curSlotIndex = slotIndex
end

--- 安装配件
this.equipSlot = function(itemGuid)
    -- TODO: isMain 逻辑
    this.addRule(CSharpAPI.GetGUID(), itemGuid, false, this.curSlotOwnerRuleId, this.curSlotIndex)

    CSharpAPI.UpdateDIYVehicle(
        this.userDefined,
        this.bindingData,
        function(instanceMesh, textData, bindingData)
            this.bindingData = bindingData

            this.refreshEquipSlotInteractBtn()
            this.refreshInstalledEquipList()

            this.toggleEquipList(true)
        end
    )
end

--- 删除配件
this.unequipSlot = function(itemGuid)
    this.deleteRule(itemGuid)
    GameObject.Destroy(this.instanceMesh)

    CSharpAPI.CreateNewDIYVehicle(
        this.userDefined,
        function(instanceMesh, textData, bindingData)
            this.bindingData = bindingData

            this.refreshEquipSlotInteractBtn()
            this.refreshInstalledEquipList()

            this.instanceMesh = instanceMesh
        end
    )
end

--- 切换是否显示已安装的配件
--- @param showInstalled boolean true 则显示已安装的，false 则显示当前插槽可安装的配件
this.toggleEquipList = function(showInstalled)
    for k, v in pairs(this.installedEquipUIList) do
        v.gameObject:SetActive(showInstalled)
    end

    for k, v in pairs(this.installableEquipUIList) do
        v.gameObject:SetActive(not showInstalled)
    end

    this.slotDisableMask.gameObject:SetActive(not showInstalled)
end

this.onExitMode = function()
end
