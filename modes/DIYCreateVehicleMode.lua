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

    this.equipList = root.transform:Find("DIYCreateVehicleCanvas/EquipList")
    this.equipTemplate = root.transform:Find("DIYCreateVehicleCanvas/EquipList/Scroll View/Viewport/Content/Template")
    this.equipTemplate.gameObject:SetActive(false)

    this.slotDisableMask = root.transform:Find("DIYCreateVehicleCanvas/SlotDisableMask")
    this.slotDisableMask.gameObject:SetActive(false)

    this.exitActionBtn = root.transform:Find("DIYCreateVehicleCanvas/FileAction/ExitBtn"):GetComponent("Button")
    this.saveActionBtn = root.transform:Find("DIYCreateVehicleCanvas/FileAction/SaveBtn"):GetComponent("Button")
    this.loadActionBtn = root.transform:Find("DIYCreateVehicleCanvas/FileAction/LoadBtn"):GetComponent("Button")

    this.fileSavePop = root.transform:Find("DIYCreateVehicleCanvas/FileSavePop")
    this.fileNameInput = this.fileSavePop.transform:Find("FileNameInput"):GetComponent("InputField")
    this.saveBtn = this.fileSavePop.transform:Find("SaveBtn"):GetComponent("Button")

    this.fileLoadPop = root.transform:Find("DIYCreateVehicleCanvas/FileLoadPop")
    this.fileLoadCloseBtn = this.fileLoadPop:Find("Scroll View/Viewport/Content/Title/CloseBtn"):GetComponent("Button")
    this.fileLoadTemplate = this.fileLoadPop:Find("Scroll View/Viewport/Content/Template")
    this.fileLoadTemplate.gameObject:SetActive(false)

    this.configProp = root.transform:Find("DIYCreateVehicleCanvas/ConfigProp")
    this.configProp.gameObject:SetActive(false)

    this.upBtn = root.transform:Find("DIYCreateVehicleCanvas/CameraAction/UpBtn")
    this.downBtn = root.transform:Find("DIYCreateVehicleCanvas/CameraAction/DownBtn")

    this.configPropEquipText =
        root.transform:Find("DIYCreateVehicleCanvas/ConfigProp/BaseInfo/EquipName"):GetComponent("Text")
    this.configPropEquipDescriptionText =
        root.transform:Find("DIYCreateVehicleCanvas/ConfigProp/BaseInfo/EquipDescription"):GetComponent("Text")
    this.configPropEquipImg =
        root.transform:Find("DIYCreateVehicleCanvas/ConfigProp/BaseInfo/Icon"):GetComponent("Image")
    this.configPropEquipType =
        root.transform:Find("DIYCreateVehicleCanvas/ConfigProp/BaseInfo/EquipType"):GetComponent("Text")

    this.configPropPositionRect = root.transform:Find("DIYCreateVehicleCanvas/ConfigProp/TransformInfo/Position")
    this.configPropEulerAngleRect = root.transform:Find("DIYCreateVehicleCanvas/ConfigProp/TransformInfo/EulerAngle")
    this.configScaleRect = root.transform:Find("DIYCreateVehicleCanvas/ConfigProp/TransformInfo/Scale")
    this.configComfirmBtn = root.transform:Find("DIYCreateVehicleCanvas/ConfigProp/ConfirmBtn"):GetComponent("Button")

    -- 按钮 Binding
    this.exitActionBtn.onClick:AddListener(
        function()
            CSharpAPI.RequestScene(
                "Garage",
                function()
                end
            )
        end
    )

    this.saveActionBtn.onClick:AddListener(
        function()
            this.fileSavePop.gameObject:SetActive(true)
        end
    )

    this.loadActionBtn.onClick:AddListener(
        function()
            this.refreshFileLoadList()
            this.fileLoadPop.gameObject:SetActive(true)
        end
    )

    this.fileSavePop:GetComponent("Button").onClick:AddListener(
        function()
            this.fileSavePop.gameObject:SetActive(false)
        end
    )

    this.saveBtn.onClick:AddListener(
        function()
            local definedName = this.fileNameInput.text
            this.saveUserDefine(definedName)
        end
    )

    this.fileLoadCloseBtn.onClick:AddListener(
        function()
            this.fileLoadPop.gameObject:SetActive(false)
        end
    )

    this.slotDisableMask:GetComponent("Button").onClick:AddListener(
        function()
            this.toggleEquipList(true)
        end
    )

    this.upBtn:GetComponent("Button").onClick:AddListener(
        function()
            this.makeCameraTargetDelta(Vector3.up)
        end
    )

    this.downBtn:GetComponent("Button").onClick:AddListener(
        function()
            this.makeCameraTargetDelta(-Vector3.up)
        end
    )

    this.configComfirmBtn:GetComponent("Button").onClick:AddListener(
        function()
            this.equipList.gameObject:SetActive(true)
            this.configProp.gameObject:SetActive(false)

            for k, v in pairs(this.slotModifyBtnList) do
                v.gameObject:SetActive(true)
            end
        end
    )

    -- 场景数据
    --- @type Transform 摄像机焦点 Transform
    this.cameraTargetTrans = root.transform:Find("CameraPoint")
    --- @type Vector3 摄像机焦点初始位置
    this.cameraDelta = Vector3.zero
    this.cameraTargetOriginalPos = root.transform:Find("CameraPoint").position

    -- 逻辑数据

    --- Slot 增加配件交互UI按钮列表
    this.slotModifyBtnList = {}

    --- 车体 UI 列表
    this.hullUIList = {}

    --- 可装的配件UI物体列表
    this.installableEquipUIList = {}

    --- 已装配件UI物体列表
    this.installedEquipUIList = {}

    --- 加载UI物件列表
    this.fileLoadUIList = {}

    --- 创建DIY载具的中间件
    this.bindingData = nil

    --- 实例载具模型
    this.instanceMesh = nil

    --- 当前编辑的规则 Id
    this.curRuleId = nil

    this.toggleEquipListSize(true)
    this.createHullList()
end

--- 切换装备列表大小
--- @param isExpand boolean 是否放大
this.toggleEquipListSize = function(isExpand)
    if isExpand then
        this.equipList.transform.anchoredPosition = Vector2(0, 0)
        this.equipList.transform.sizeDelta = Vector2(0, 0)
    else
        this.equipList.transform.anchoredPosition = Vector2(400, 0)
        this.equipList.transform.sizeDelta = Vector2(-400, 0)
    end
end

--- 调整摄像机聚焦位置
--- @param delta Vector3 位置增量
this.makeCameraTargetDelta = function(delta)
    this.cameraDelta = this.cameraDelta + delta

    if this.cameraDelta.y < 0 then
        this.cameraDelta = Vector3(this.cameraDelta.x, 0, this.cameraDelta.z)
    end

    this.cameraTargetTrans.position = this.cameraDelta + this.cameraTargetOriginalPos
end

--- 创建右侧的配件显示
this.createEquipUIObject = function(baseData)
    local instance = GameObject.Instantiate(this.equipTemplate, this.equipTemplate.transform.parent, true)
    instance.transform:Find("Title"):GetComponent("Text").text = baseData.displayName:GetDisplayName()
    instance.transform:Find("Description"):GetComponent("Text").text = baseData.description:GetDisplayName()
    instance.transform:Find("Type"):GetComponent("Text").text = this.getBaseDataTypeText(baseData:GetDataType())
    instance.transform:Find("Type"):GetComponent("Text").color = this.getBaseDataTypeColor(baseData:GetDataType())

    if baseData.icon ~= nil then
        instance.transform:Find("Icon"):GetComponent("Image").sprite = baseData.icon
    end
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

this.getBaseDataTypeColor = function(dataType)
    local color = Color(0.6213613, 1, 0)

    if dataType == DIYDataEnum.Hull then
        color = color
    elseif dataType == DIYDataEnum.Turret then
        color = Color(0, 0.451296, 0.9803922)
    elseif dataType == DIYDataEnum.Gun then
        color = Color(0.9811321, 0.1496851, 0)
    elseif dataType == DIYDataEnum.Item then
        color = Color(0, 0.9803922, 0.9395363)
    end

    return color
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

this.createHullList = function()
    for index, baseData in pairs(DIYDataManager.Instance:GetHullDataList()) do
        local instance = this.createEquipUIObject(baseData)

        instance.transform:Find("InstallBtn").gameObject:SetActive(true)
        instance.transform:Find("InstallBtn"):GetComponent("Button").onClick:AddListener(
            function()
                this.addRule(CSharpAPI.GetGUID(), baseData.itemGUID, true, nil, 0)

                CSharpAPI.CreateNewDIYVehicle(
                    this.userDefined,
                    function(instanceMesh, textData, bindingData)
                        this.bindingData = bindingData
                        this.refreshEquipSlotInteractBtn()

                        this.instanceMesh = instanceMesh

                        for k, v in pairs(this.hullUIList) do
                            v.gameObject:SetActive(false)
                        end

                        this.refreshInstallableEquipList()
                        this.refreshInstalledEquipList()
                        this.toggleEquipList(true)
                    end
                )
            end
        )

        table.insert(this.hullUIList, instance)
    end
end

this.refreshInstallableEquipList = function()
    for k, v in pairs(this.installableEquipUIList) do
        GameObject.Destroy(v.gameObject)
    end

    this.installableEquipUIList = {}
    local installableEquips = DIYDataManager.Instance:GetEquipableDataList()

    for index, baseData in pairs(installableEquips) do
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

        instance.transform:Find("DetailBtn").gameObject:SetActive(true)
        instance.transform:Find("DetailBtn"):GetComponent("Button").onClick:AddListener(
            function()
                this.selectRule(rule.ruleGuid)
            end
        )

        table.insert(this.installedEquipUIList, instance)
    end
end

--- 增加规则 （比较简单）
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
    this.addRule(CSharpAPI.GetGUID(), itemGuid, false, this.curSlotOwnerRuleId, this.curSlotIndex)
    this.onModifyUserDefined()
end

--- 当修改 UserDefine 或 增加新的 Rule
this.onModifyUserDefined = function()
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
    this.loadNewUserDefine(this.userDefined)
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
    this.toggleEquipListSize(not showInstalled)
end

this.saveUserDefine = function(defineName)
    -- 保存名称检查
    if not defineName or defineName == "" then
        PopMessageManager.Instance:PushPopup(
            "请输入存档名称.",
            function()
            end
        )
        return
    end

    this.userDefined.definedName = defineName

    -- C# 侧会检查载具是否拥有并设置 MainTurret 与 MainGun.
    -- 若载具想可以正常运行，则必须拥有规范父子结构的 Hull,Turret,Gun.

    -- 实现存档的深复制，防止干扰以前的数据

    UserDIYDataManager.Instance:SetDIYUserDefined(this.deepCopyUserDefine(this.userDefined))

    -- CS.UnityEngine.GUIUtility.systemCopyBuffer = JsonUtility.ToJson(this.userDefined) TODO: 载具分享功能
    this.fileSavePop.gameObject:SetActive(false)
end

--- 所有与存档相关的读写，都需要用深拷贝的规则，防止一些引用变化导致的 Bug
--- @param define DIYUserDefined
--- @return DIYUserDefined
this.deepCopyUserDefine = function(define)
    return define:GetDeepCopied()
end

--- 删除 UserDefine
this.deleteUserDefine = function(definedName)
    -- 通知 C# 存储侧删除该 UserDefine
    UserDIYDataManager.Instance:DeleteDIYUserDefined(definedName)
end

--- 加载新的 UserDefine
--- @param userDefine DIYUserDefined
this.loadNewUserDefine = function(userDefine)
    -- 删除当前的预览
    if this.instanceMesh ~= nil then
        GameObject.Destroy(this.instanceMesh)
    end

    this.userDefined = userDefine

    CSharpAPI.CreateNewDIYVehicle(
        this.userDefined,
        function(instanceMesh, textData, bindingData)
            this.bindingData = bindingData
            this.refreshEquipSlotInteractBtn()

            this.instanceMesh = instanceMesh

            for k, v in pairs(this.hullUIList) do
                v.gameObject:SetActive(this.userDefined.rules.Count == 0)
            end

            this.refreshInstallableEquipList()
            this.refreshInstalledEquipList()
            this.toggleEquipList(true)
        end
    )
end

--- 更新存档页面列表
this.refreshFileLoadList = function()
    for k, v in pairs(this.fileLoadUIList) do
        GameObject.Destroy(v.gameObject)
    end
    this.fileLoadUIList = {}

    -- 遍历 UserDefine
    local userDefines = UserDIYDataManager.Instance:GetDIYUserDefineds()

    for k, v in pairs(userDefines) do
        --- @type DIYUserDefined
        local userDefine = v
        local instance = GameObject.Instantiate(this.fileLoadTemplate, this.fileLoadTemplate.transform.parent, true)
        instance.transform:Find("Title"):GetComponent("Text").text = userDefine.definedName
        instance.transform:Find("LoadBtn"):GetComponent("Button").onClick:AddListener(
            function()
                -- 覆盖当前的 UserDefine
                local loadedDefine = this.deepCopyUserDefine(userDefine)
                this.loadNewUserDefine(loadedDefine)
                this.fileNameInput.text = loadedDefine.definedName
                this.fileLoadPop.gameObject:SetActive(false)
            end
        )
        instance.transform:Find("DeleteBtn"):GetComponent("Button").onClick:AddListener(
            function()
                -- 删除当前的 UserDefine
                PopMessageManager.Instance:PushPopup(
                    "是否确定删除当前的存档?",
                    function(state)
                        if state then
                            this.deleteUserDefine(userDefine.definedName)
                            this.refreshFileLoadList()
                        end
                    end
                )
            end
        )
        instance.gameObject:SetActive(true)

        table.insert(this.fileLoadUIList, instance)
    end
end

this.selectRule = function(ruleId)
    this.curRuleId = ruleId

    -- 界面切换
    this.equipList.gameObject:SetActive(false)
    this.configProp.gameObject:SetActive(true)

    for k, v in pairs(this.slotModifyBtnList) do
        v.gameObject:SetActive(false)
    end

    for k, v in pairs(this.userDefined.rules) do
        --- @type DIYRule
        local rule = v

        if rule.ruleGuid == ruleId then
            -- 界面基本信息
            local baseData = DIYDataManager.Instance:GetData(rule.itemGuid)
            this.configPropEquipText.text = baseData.displayName:GetDisplayName()
            this.configPropEquipDescriptionText.text = baseData.description:GetDisplayName()
            this.configPropEquipImg.sprite = baseData.icon
            this.configPropEquipType.text = this.getBaseDataTypeText(baseData:GetDataType())
            this.configPropEquipType.color = this.getBaseDataTypeText(baseData:GetDataType())

            -- 坐标变化相关逻辑
            local isHull = baseData:GetDataType() == DIYDataEnum.Hull -- 车体不允许调整大小之类的
            this.configPropPositionRect.gameObject:SetActive(not isHull)
            this.configPropEulerAngleRect.gameObject:SetActive(not isHull)
            this.configScaleRect.gameObject:SetActive(not isHull)

            if not isHull then
                -- 先解绑
                this.clearBindTransformInputField(this.configPropPositionRect)
                this.clearBindTransformInputField(this.configPropEulerAngleRect)
                this.clearBindTransformInputField(this.configScaleRect)

                -- 再对界面赋值
                this.Vector3ToTransformInputFields(this.configPropPositionRect, rule.deltaPos)
                this.Vector3ToTransformInputFields(this.configPropEulerAngleRect, rule.localEulerAngles)
                this.Vector3ToTransformInputFields(this.configScaleRect, rule.scaleSize)

                -- 再绑定
                this.bindTransformInputField(
                    this.configPropPositionRect,
                    function(val)
                        rule.deltaPos = val
                        this.onModifyUserDefined()
                    end
                )

                this.bindTransformInputField(
                    this.configPropEulerAngleRect,
                    function(val)
                        rule.localEulerAngles = val
                        this.onModifyUserDefined()
                    end
                )

                this.bindTransformInputField(
                    this.configScaleRect,
                    function(val)
                        rule.scaleSize = val
                        this.onModifyUserDefined()
                    end
                )
            end
        end
    end
end

--- 将 Vector3 赋值给 InputField
this.Vector3ToTransformInputFields = function(rectTransform, vec)
    rectTransform:Find("XField"):GetComponent("InputField").text = string.format("%.3f", vec.x)
    rectTransform:Find("YField"):GetComponent("InputField").text = string.format("%.3f", vec.y)
    rectTransform:Find("ZField"):GetComponent("InputField").text = string.format("%.3f", vec.z)
end

--- 从 InputField 获得 Vector3
--- @return Vector3
this.fromTransformInputFieldToVector3 = function(rectTransform)
    local vec = SerializeVector3()
    vec.x = tonumber(rectTransform:Find("XField"):GetComponent("InputField").text)
    vec.y = tonumber(rectTransform:Find("YField"):GetComponent("InputField").text)
    vec.z = tonumber(rectTransform:Find("ZField"):GetComponent("InputField").text)
    return vec
end

this.clearBindTransformInputField = function(rectTransform)
    -- 清空上次事件的绑定
    rectTransform:Find("XField"):GetComponent("InputField").onValueChanged:RemoveAllListeners()
    rectTransform:Find("YField"):GetComponent("InputField").onValueChanged:RemoveAllListeners()
    rectTransform:Find("ZField"):GetComponent("InputField").onValueChanged:RemoveAllListeners()
end

--- 绑定坐标变化事件
this.bindTransformInputField = function(rectTransform, onValueChanged)
    -- 新的事件绑定
    rectTransform:Find("XField"):GetComponent("InputField").onValueChanged:AddListener(
        function(text)
            onValueChanged(this.fromTransformInputFieldToVector3(rectTransform))
        end
    )

    rectTransform:Find("YField"):GetComponent("InputField").onValueChanged:AddListener(
        function(text)
            onValueChanged(this.fromTransformInputFieldToVector3(rectTransform))
        end
    )

    rectTransform:Find("ZField"):GetComponent("InputField").onValueChanged:AddListener(
        function(text)
            onValueChanged(this.fromTransformInputFieldToVector3(rectTransform))
        end
    )
end

this.onExitMode = function()
end
