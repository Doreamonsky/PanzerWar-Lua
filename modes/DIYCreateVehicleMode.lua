DIYCreateVehicleMode = {}

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
    this.slotModifyBtnTemplate = root.transform:Find("DIYCreateVehicleCanvas/SlotModifyBtn")
    this.slotModifyBtnTemplate.gameObject:SetActive(false)

    this.addRule(1, "d526381d-f6e4-42fc-9f6b-548866c23241", true, nil, 0)
    this.addRule(2, "ee45c582-3a2f-4f50-b674-46bc62edf381", true, 1, 0)
    this.addRule(3, "5c02c009-51bc-4260-b00e-4dbf26d9325e", true, 2, 0)
    -- this.addRule(4, "ee45c582-3a2f-4f50-b674-46bc62edf381", false, 1, 1)

    this.refreshInteractBtn()
    CSharpAPI.CreateDIYVehicle(
        this.userDefined,
        function(instanceMesh, textData)
            instanceMesh.transform:GetComponent(typeof(CS.UnityEngine.Rigidbody)).useGravity = false
        end
    )
end

this.refreshInteractBtn = function()
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

                local iconPos = CSharpAPI.GetSlotPosFromRule(slotOwnerRuleId, slotIndex, this.userDefined)

                local instance =
                    GameObject.Instantiate(
                    this.slotModifyBtnTemplate,
                    this.slotModifyBtnTemplate.transform.parent,
                    true
                )

                instance:GetComponent(typeof(CS.ShanghaiWindy.Core.IconScreenPositionCtrl)).worldPos = iconPos
                instance:GetComponent("Button").onClick:AddListener(
                    function()
                        print(
                            inspect(
                                {
                                    slotIndex = slotIndex,
                                    iconPos = iconPos,
                                    slotOwnerRuleId = slotOwnerRuleId
                                }
                            )
                        )
                    end
                )
                instance.gameObject:SetActive(true)
            end
        end
    end

    print(inspect(slotStatus))
end

this.addRule = function(ruleGuid, itemGuid, isMain, parentRuleGuid, targetSlotIndex)
    local rule = DIYRule()
    rule.ruleGuid = ruleGuid
    rule.itemGuid = itemGuid
    rule.isMain = isMain
    rule.parentRuleGuid = parentRuleGuid
    rule.targetSlotIndex = targetSlotIndex
    this.userDefined.rules:Add(rule)
end

this.onExitMode = function()
end
