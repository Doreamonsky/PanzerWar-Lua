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

this.onUtilCreated = function(canvas)
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
    local equipSlotStatus = {}

    -- 获取配件的插槽信息
    for index, x in pairs(this.userDefined.rules) do
        --- @type DIYRule
        local rule = x
        local slotInfos = DIYDataManager.Instance:GetData(rule.itemGuid).slotInfos

        local status = {}

        for i = 1, slotInfos.Length do
            table.insert(status, false)
        end

        equipSlotStatus[rule.ruleGuid] = status
    end

    -- 获取配件插槽的占用信息
    for index, x in pairs(this.userDefined.rules) do
        --- @type DIYRule
        local rule = x

        if rule.parentRuleGuid and rule.parentRuleGuid ~= "" then
            equipSlotStatus[rule.parentRuleGuid][rule.targetSlotIndex + 1] = true
        end
    end

    print(inspect(equipSlotStatus))
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
