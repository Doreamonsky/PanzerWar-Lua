local GizmoConfigController = require("user.component.gizmoconfigcontroller")
local CameraController = require("user.component.cameracontroller")
local ShareCodeListController = require("user.component.sharecodelistcontroller")
local CustomClickHandler = require("user.component.customclickhandler")

SymmetryAxis = enum(
    {
        "XAxis",
        "YAxis",
        "ZAxis"
    }
)

local DIY = class("DIY")

GameMode()

function DIY:ctor()
    self.modName = "DIY"
    self.author = "超级哆啦酱"
    self.description = "创建自定义坦克"
    self.isDefinitiveOnly = true
end

function DIY:GetGameModeName(userLang)
    if userLang == "EN" then
        return "Tank Workshop"
    else
        return "坦克工坊"
    end
end

function DIY:OnStartMode()
    self.userDefined = DIYUserDefined()
    self.cameraController = EntityFactory.AddEntity(CameraController.new())
    self.shareCodeListController = ShareCodeListController.new(
        "https://game.waroftanks.cn/backend/userDefine/Newest/",
        function(cb)
            self:ImportShareCode(cb)
        end
    )

    self.isDirty = false
    self.lastdirtyTime = 0
    self.dirtyCount = 0
    self.isEditMode = true
    self.controlType = eDIYControlType.Position
    --- @type Transform Binding 的 Transform，方便转 local position
    self.bindingTransform = nil

    --- @type boolean 是否在加载配件
    self.isLoadingParts = false

    CSharpAPI.RequestScene(
        "Physic-Play",
        function()
            CSharpAPI.LoadAssetBundle(
                "diycreatevehicleutil",
                "mod",
                function(asset)
                    if asset ~= nil then
                        self:OnUtilCreated(GameObject.Instantiate(asset))
                    end
                end
            )
        end
    )

    self.onFrameTick = handler(self, self.OnFrameTick)
    TimeAPI.RegisterLateFrameTick(self.onFrameTick)
    -- Application.lowMemory("+", self.onLowMemory)
end

function DIY:OnFrameTick()
    if self.isEditMode then
        if self.isDirty and Time.time - self.lastdirtyTime > 0.05 then
            if self.bindingData then
                self:onModifyUserDefined()
                self.isDirty = false
                self.lastdirtyTime = Time.time

                self.dirtyCount = self.dirtyCount + 1

                if self.dirtyCount > 50 then
                    CS.UnityEngine.Resources.UnloadUnusedAssets()
                    self.dirtyCount = 0
                end
            end
        end
    end
end

--- 设置数据为脏，Lazy 更新
function DIY:MarkDirty()
    self.isDirty = true
end

function DIY:OnUtilCreated(root)
    local settingBtn = root.transform:Find("DIYCreateVehicleCanvas/ToolAction/SettingBtn"):GetComponent("Button")
    local configTransform = root.transform:Find("DIYCreateVehicleCanvas/GizmoConfig")
    local rtPluginTransform = root.transform:Find("RT-Plugin")

    self.gizmoUITransform = GizmoConfigController.new()
    self.gizmoUITransform:init(configTransform, rtPluginTransform, settingBtn)

    self.slotModifyBtnTemplate = root.transform:Find("DIYCreateVehicleCanvas/Slots/SlotModifyBtn")
    self.slotModifyBtnTemplate.gameObject:SetActive(false)

    self.equipList = root.transform:Find("DIYCreateVehicleCanvas/EquipList")

    self.slotDisableMask = root.transform:Find("DIYCreateVehicleCanvas/SlotDisableMask")
    self.slotDisableMask.gameObject:SetActive(false)

    self.exitActionBtn = root.transform:Find("DIYCreateVehicleCanvas/FileAction/ExitBtn"):GetComponent("Button")
    self.saveActionBtn = root.transform:Find("DIYCreateVehicleCanvas/FileAction/SaveBtn"):GetComponent("Button")
    self.loadActionBtn = root.transform:Find("DIYCreateVehicleCanvas/FileAction/LoadBtn"):GetComponent("Button")

    self.fileSavePop = root.transform:Find("DIYCreateVehicleCanvas/FileSavePop")
    self.fileNameInput = self.fileSavePop.transform:Find("FileNameInput"):GetComponent("InputField")
    self.saveBtn = self.fileSavePop.transform:Find("SaveBtn"):GetComponent("Button")

    self.fileLoadPop = root.transform:Find("DIYCreateVehicleCanvas/FileLoadPop")
    --- @type DIYFileRecycleMgr
    self.fileMgr = self.fileLoadPop:GetComponent(typeof(DIYFileRecycleMgr))
    self.fileLoadCloseBtn = self.fileLoadPop:Find("Title/CloseBtn"):GetComponent("Button")
    self.loadShareBtn = self.fileLoadPop:Find("Title/LoadShareBtn"):GetComponent("Button")

    self.setMainBtn = root.transform:Find(
            "DIYCreateVehicleCanvas/ConfigProp/Scroll View/Viewport/Content/Main/SetMainBtn")
        :GetComponent(
            "Button"
        )

    self.configProp = root.transform:Find("DIYCreateVehicleCanvas/ConfigProp")
    self.configProp.gameObject:SetActive(false)

    self.configRoot = self.configProp:Find("Scroll View/Viewport/Content")
    self.configPropEquipText = self.configRoot:Find("BaseInfo/EquipName"):GetComponent("Text")
    self.configPropEquipDescriptionText = self.configRoot:Find("BaseInfo/EquipDescription"):GetComponent("Text")
    self.configPropEquipImg = self.configRoot:Find("BaseInfo/Icon"):GetComponent("Image")
    self.configPropEquipType = self.configRoot:Find("BaseInfo/EquipType"):GetComponent("Text")

    self.configPropTransformInfo = self.configRoot:Find("TransformInfo")
    self.configPropPositionRect = self.configRoot:Find("TransformInfo/Position")
    self.configPropEulerAngleRect = self.configRoot:Find("TransformInfo/EulerAngle")
    self.configScaleRect = self.configRoot:Find("TransformInfo/Scale")
    self.configComfirmBtn = self.configProp:Find("Title/ConfirmBtn"):GetComponent("Button")
    self.configCustomPropertyTemplate = root.transform:Find(
        "DIYCreateVehicleCanvas/ConfigProp/Scroll View/Viewport/Content/FloatToggleablePropertyTemplate"
    )
    self.configCustomPropertyTemplate.gameObject:SetActive(false)


    self.shareImportPop = root.transform:Find("DIYCreateVehicleCanvas/ShareImportPop")
    self.shareImportCancelBtn = self.shareImportPop:GetComponent("Button")
    self.shareCodeInput = root.transform:Find("DIYCreateVehicleCanvas/ShareImportPop/ShareCodeInput"):GetComponent(
        "InputField")
    self.shareImportBtn = root.transform:Find("DIYCreateVehicleCanvas/ShareImportPop/ImportBtn"):GetComponent("Button")

    self.slotMultiObjectsToggle = root.transform:Find("DIYCreateVehicleCanvas/EquipList/Title/SlotMultiObjectsToggle"):
    GetComponent("Toggle")

    self.ApplyParentScaleToggle = root.transform:Find("DIYCreateVehicleCanvas/EquipList/Title/ApplyParentScaleToggle"):
    GetComponent("Toggle")

    self.copyBtn = root.transform:Find("DIYCreateVehicleCanvas/ConfigProp/Scroll View/Viewport/Content/Main/CopyBtn"):
    GetComponent(
        "Button"
    )

    self.symmetryXBtn = root.transform:Find(
            "DIYCreateVehicleCanvas/ConfigProp/Scroll View/Viewport/Content/Symmetry/XAxisBtn")
        :GetComponent(
            "Button"
        )

    self.symmetryYBtn = root.transform:Find(
            "DIYCreateVehicleCanvas/ConfigProp/Scroll View/Viewport/Content/Symmetry/YAxisBtn")
        :GetComponent(
            "Button"
        )

    self.symmetryZBtn = root.transform:Find(
            "DIYCreateVehicleCanvas/ConfigProp/Scroll View/Viewport/Content/Symmetry/ZAxisBtn")
        :GetComponent(
            "Button"
        )

    self.allEquipGo = root.transform:Find("DIYCreateVehicleCanvas/EquipListAll").gameObject
    self.allFilterBtn = root.transform:Find("DIYCreateVehicleCanvas/EquipListAll/Title/Filter/AllBtn"):GetComponent(
        "Button")
    self.turretFilterBtn = root.transform:Find("DIYCreateVehicleCanvas/EquipListAll/Title/Filter/TurretBtn"):
    GetComponent("Button")
    self.gunFilterBtn = root.transform:Find("DIYCreateVehicleCanvas/EquipListAll/Title/Filter/GunBtn"):GetComponent(
        "Button")
    self.itemFilterBtn = root.transform:Find("DIYCreateVehicleCanvas/EquipListAll/Title/Filter/ItemBtn"):GetComponent(
        "Button")
    self.filterSearchField = root.transform:Find("DIYCreateVehicleCanvas/EquipListAll/Title/FilterSearchField"):
    GetComponent("InputField")

    self.noneBtn = root.transform:Find("DIYCreateVehicleCanvas/ConfigProp/TransformHandle/NoneBtn"):GetComponent(
        "Button")
    self.moveBtn = root.transform:Find("DIYCreateVehicleCanvas/ConfigProp/TransformHandle/MoveBtn"):GetComponent(
        "Button")
    self.rotateBtn = root.transform:Find("DIYCreateVehicleCanvas/ConfigProp/TransformHandle/RotateBtn"):GetComponent(
        "Button")
    self.scaleBtn = root.transform:Find("DIYCreateVehicleCanvas/ConfigProp/TransformHandle/ScaleBtn"):GetComponent(
        "Button")

    self.detailDeleteBtn = root.transform:Find("DIYCreateVehicleCanvas/ConfigProp/Title/DeleteBtn"):GetComponent(
        "Button")

    self.dragInfo = root.transform:Find("DIYCreateVehicleCanvas/DragInfo").gameObject
    self.pauseTimeBtn = root.transform:Find("DIYCreateVehicleCanvas/ToolAction/PauseTimeBtn"):GetComponent("Button")
    self.recoveryTimeBtn = root.transform:Find("DIYCreateVehicleCanvas/TimeScaleInfo/RecoverTimeBtn"):GetComponent(
        "Button")
    self.timeScaleInfoGo = root.transform:Find("DIYCreateVehicleCanvas/TimeScaleInfo").gameObject
    self.quickImportShareBtn = root.transform:Find("DIYCreateVehicleCanvas/ToolAction/ImportBtn"):GetComponent("Button")

    self.longPressTipGo = root.transform:Find("DIYCreateVehicleCanvas/LongPressTip").gameObject
    self.tipFillImg = self.longPressTipGo.transform:Find("Fill"):GetComponent("Image")

    self.eventTrigger = root.transform:Find("DIYCreateVehicleCanvas/TouchBar"):GetComponent(typeof(EventTrigger))
    ------------------------------------------------------
    -- 按钮 Binding
    self.exitActionBtn.onClick:AddListener(
        function()
            if self.isLoadingParts then
                return
            end

            PopMessageManager.Instance:PushPopup(
                "是否退出坦克工坊? Exit tank workshop?",
                function(state)
                    if state then
                        if MODE_API then
                            ModeAPI.ExitMode()
                        else
                            self:OnExitMode()
                            CSharpAPI.RequestGarageScene()
                        end
                    end
                end
            )
        end
    )

    self.saveActionBtn.onClick:AddListener(
        function()
            if self.isLoadingParts then
                return
            end

            self.fileSavePop.gameObject:SetActive(true)
        end
    )

    self.loadActionBtn.onClick:AddListener(
        function()
            if self.isLoadingParts then
                return
            end

            self.fileLoadPop.gameObject:SetActive(true)
        end
    )

    self.fileSavePop:GetComponent("Button").onClick:AddListener(
        function()
            if self.isLoadingParts then
                return
            end

            self.fileSavePop.gameObject:SetActive(false)
        end
    )

    self.saveBtn.onClick:AddListener(
        function()
            if self.isLoadingParts then
                return
            end

            local definedName = self.fileNameInput.text
            self:saveUserDefine(definedName)
        end
    )

    self.quickImportShareBtn.onClick:AddListener(
        function()
            -- 快速导入分享码
            if self.isLoadingParts then
                return
            end

            self.fileLoadPop.gameObject:SetActive(true)
            self.shareImportPop.gameObject:SetActive(true)
        end
    )

    self.loadShareBtn.onClick:AddListener(
        function()
            self.shareImportPop.gameObject:SetActive(true)
        end
    )

    self.shareImportCancelBtn.onClick:AddListener(
        function()
            self.shareImportPop.gameObject:SetActive(false)
        end
    )

    self.shareImportBtn.onClick:AddListener(
        function()
            local shareCode = self.shareCodeInput.text
            self:ImportShareCode(shareCode)
        end
    )

    self.slotDisableMask:GetComponent("Button").onClick:AddListener(
        function()
            local isEmptyRuleCount = self.userDefined.rules.Count == 0

            -- 只有有规则的时候，才显示已安装的配件
            if not isEmptyRuleCount then
                self:toggleEquipList(true)
            end
        end
    )

    -- 复制一份当前的配件
    self.copyBtn.onClick:AddListener(
        function()
            self:duplicateRule(self.curRuleId)
        end
    )

    self.symmetryXBtn.onClick:AddListener(
        function()
            self:symmetry(self.curRuleId, SymmetryAxis.XAxis)
        end
    )

    self.symmetryYBtn.onClick:AddListener(
        function()
            self:symmetry(self.curRuleId, SymmetryAxis.YAxis)
        end
    )

    self.symmetryZBtn.onClick:AddListener(
        function()
            self:symmetry(self.curRuleId, SymmetryAxis.ZAxis)
        end
    )

    self.detailDeleteBtn.onClick:AddListener(
        function()
            self:unequipSlot(self.curRuleId)
            self:closeConfig()
        end
    )

    self.noneBtn.onClick:AddListener(
        function()
            self.controlType = eDIYControlType.None
            CSharpAPI.SetDIYControlType(self.controlType)
        end
    )

    self.moveBtn.onClick:AddListener(
        function()
            self.controlType = eDIYControlType.Position
            CSharpAPI.SetDIYControlType(self.controlType)
        end
    )

    self.rotateBtn.onClick:AddListener(
        function()
            self.controlType = eDIYControlType.EulerAngles
            CSharpAPI.SetDIYControlType(self.controlType)
        end
    )

    self.scaleBtn.onClick:AddListener(
        function()
            self.controlType = eDIYControlType.Scale
            CSharpAPI.SetDIYControlType(self.controlType)
        end
    )

    -- 退出详情编辑
    self.configComfirmBtn:GetComponent("Button").onClick:AddListener(
        function()
            self:closeConfig()
        end
    )

    self.setMainBtn.onClick:AddListener(
        function()
            CSharpAPI.SetRuleAsMain(self.userDefined, self.curRuleId)
            PopMessageManager.Instance:PushNotice("当前配件已被设置为主要", 1)
        end
    )

    self.slotMultiObjectsToggle.isOn = false
    self.slotMultiObjectsToggle.onValueChanged:AddListener(
        function(isEnabled)
            self.isSlotMultiObjects = isEnabled
            self:RefreshEquipSlotInteractBtn()
        end
    )

    self.ApplyParentScaleToggle.onValueChanged:AddListener(
        function(isEnable)
            self.userDefined.isApplyParentScale = isEnable
            self:forceReloadUserDefined()
        end
    )

    self.allFilterBtn.onClick:AddListener(
        function()
            CSharpAPI.SetEquipTypeFilter(DIYDataEnum.Undefined)
        end
    )
    self.turretFilterBtn.onClick:AddListener(
        function()
            CSharpAPI.SetEquipTypeFilter(DIYDataEnum.Turret)
        end
    )

    self.gunFilterBtn.onClick:AddListener(
        function()
            CSharpAPI.SetEquipTypeFilter(DIYDataEnum.Gun)
        end
    )

    self.itemFilterBtn.onClick:AddListener(
        function()
            CSharpAPI.SetEquipTypeFilter(DIYDataEnum.Item)
        end
    )

    self.filterSearchField.onValueChanged:AddListener(
        function(text)
            CSharpAPI.SetEquipKeywordFilter(text)
        end
    )

    self.pauseTimeBtn.onClick:AddListener(
        function()
            self:updateTimeScale()
        end
    )

    self.recoveryTimeBtn.onClick:AddListener(
        function()
            self:updateTimeScale()
        end
    )


    ---------------------分享码--------------------------
    local findBtn = root.transform:Find("DIYCreateVehicleCanvas/ToolAction/FindBtn"):GetComponent("Button")
    local shareCodeListGo = root.transform:Find("DIYCreateVehicleCanvas/DIYShareCodeListCanvas").gameObject
    self.shareCodeListController:Init(findBtn, shareCodeListGo)
    ------------------------------------------------------

    ---------------------坦克加载页面--------------------------
    self.fileLoadCloseBtn.onClick:AddListener(function()
        self.fileLoadPop.gameObject:SetActive(false)
    end)

    self:refreshFileList()

    self.fileMgr.OnPublishFile:AddListener(function(definedName)
        local userDefine = UserDIYDataManager.Instance:GetUserDefine(definedName)
        DIYDataPackageManager.Instance:ExportUserDefine(userDefine)
    end)

    self.fileMgr.OnDeleteFile:AddListener(function(definedName)
        -- 删除当前的 UserDefine
        PopMessageManager.Instance:PushPopup(
            "是否确定删除当前的存档? Delete current saving?",
            function(state)
                if state then
                    self:deleteUserDefine(definedName)
                    self:refreshFileList()
                end
            end
        )
    end)

    self.fileMgr.OnLoadFile:AddListener(function(definedName)
        local userDefine = UserDIYDataManager.Instance:GetUserDefine(definedName)
        local loadedDefine = self:deepCopyUserDefine(userDefine)
        self:loadNewUserDefine(loadedDefine)
        self.fileNameInput.text = loadedDefine.definedName
        self.fileLoadPop.gameObject:SetActive(false)
    end)

    self.fileMgr.OnShareFile:AddListener(function(definedName)
        local userDefine = UserDIYDataManager.Instance:GetUserDefine(definedName)
        self:ExportShareCode(userDefine)
    end)
    ------------------------------------------------------

    -- 缓存数据
    self.slotModifyBtnPools = GameObjectPool()
    self.slotModifyBtnPools:Init(self.slotModifyBtnTemplate.gameObject, 200)

    -- 场景数据
    ---------------------摄像机--------------------------
    local cameraUITransform = root.transform:Find("DIYCreateVehicleCanvas/CameraAction")
    local cameraTransform = root.transform:Find("Main Camera").transform
    local cameraTargetTrans = root.transform:Find("CameraPoint")

    self.cameraController:Init(cameraUITransform, cameraTransform, cameraTargetTrans)
    ---------------------摄像机--------------------------

    --- @type CustomClickHandler
    self.rayHitClick = EntityFactory.AddEntity(CustomClickHandler.new())
    self.rayHitClick:Init(self.eventTrigger, 1, 5, function(evtData)
        if not GizmoConfig.config.EnablePressSelect then return end
        local ret, viewData = DIYDragPicker.Instance:GetRayItem(evtData.position)

        if ret then
            if self.curRuleId ~= nil then
                if self.curRuleId == viewData.ruleGUID then
                    return
                else
                    self:closeConfig()
                end
            end

            self:selectRule(viewData.ruleGUID)
        end
    end, function(state, evtData)
        if not GizmoConfig.config.EnablePressSelect then return end
        if self.isEditingRule then return end
        self.longPressTipGo:SetActive(state)
    end, function(progress)
        if not GizmoConfig.config.EnablePressSelect then return end
        if self.isEditingRule then return end
        self.tipFillImg.fillAmount = progress
    end)

    -- 逻辑数据

    --- Slot 增加配件交互UI按钮列表
    self.slotModifyBtnList = {}

    --- 车体 UI 列表
    self.hullUIList = {}

    --- 可装的配件UI物体列表
    self.installableEquipUIList = {}

    --- 已装配件UI物体列表
    self.installedEquipUIList = {}

    --- 配件属性UI物体列表
    self.propertyUIList = {}

    --- 创建DIY载具的中间件
    self.bindingData = nil

    --- 实例载具模型
    self.instanceMesh = nil

    --- 是否在编辑规则
    self.isEditingRule = false

    --- 当前编辑的规则 Id
    self.curRuleId = nil

    --- 插槽是否支持多物体
    self.isSlotMultiObjects = false

    --- 已安装配件滑动插槽值
    self.expandedScrollValue = -1

    --- 可安装配件滑动插槽值
    self.unexpandedScrollValue = -1

    self.outlinableComponents = {}

    self.equipList.gameObject:SetActive(true)

    self.OnEquipUninstallClickedCb = function(rule)
        self:OnEquipUninstallClicked(rule)
    end

    self.OnEquipDetailClickedCb = function(rule)
        self:OnEquipDetailClicked(rule)
    end

    self.OnEquipInstallClickedCb = function(baseData)
        self:OnEquipInstallClicked(baseData)
    end

    self.OnDIYPickItemCb = function(ruleGuid)
        self:OnDIYPickItem(ruleGuid)
    end

    CSharpAPI.OnEquipUninstallClicked:AddListener(self.OnEquipUninstallClickedCb)
    CSharpAPI.OnEquipDetailClicked:AddListener(self.OnEquipDetailClickedCb)
    CSharpAPI.OnEquipInstallClicked:AddListener(self.OnEquipInstallClickedCb)
    CSharpAPI.OnDIYPickItem:AddListener(self.OnDIYPickItemCb)

    EventSystem.AddListener(EventDefine.OnGizmoConfigChanged, self.RefreshAllSlotScale, self)
    self:toggleEquipList(false)
end

function DIY:getBaseDataTypeText(dataType)
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

--- 设置 Config 中（所有）当前插槽大小
function DIY:RefreshAllSlotScale()
    for k, v in pairs(self.slotModifyBtnList) do
        self.gizmoUITransform:applySlotScale(v.transform)
    end
end

--- 刷新 Slot 添加的 Icon
function DIY:RefreshEquipSlotInteractBtn()
    if not self.isEditingRule then
        -- 删除之前的按钮
        for k, v in pairs(self.slotModifyBtnList) do
            self.slotModifyBtnPools:DestroyObject(v)
        end

        self.slotModifyBtnList = {}

        -- 获取配件安装的状态
        --- @type table<string,boolean[]>
        local slotStatus = {}
        local slotInfoCache = {}

        -- 获取配件的插槽信息
        for index, x in pairs(self.userDefined.rules) do
            --- @type DIYRule
            local rule = x

            local slotInfos = nil
            if GET_SLOT_INFO_METHOD then
                slotInfos = DIYDataManager.Instance:GetData(rule.itemGuid):GetSlotInfos()
            else
                slotInfos = DIYDataManager.Instance:GetData(rule.itemGuid).slotInfos
            end

            local status = {}

            for i = 0, slotInfos.Length - 1 do
                table.insert(status, false)
            end

            slotStatus[rule.ruleGuid] = status
            slotInfoCache[rule.ruleGuid] = slotInfos
        end

        -- 获取配件插槽的占用信息
        for index, x in pairs(self.userDefined.rules) do
            --- @type DIYRule
            local rule = x

            if rule.parentRuleGuid and rule.parentRuleGuid ~= "" then
                slotStatus[rule.parentRuleGuid][rule.targetSlotIndex + 1] = true -- 注意 Lua index 比 c# +1
            end
        end

        for ruleGuid, statusArray in pairs(slotStatus) do
            for j, status in pairs(statusArray) do
                if not status or self.isSlotMultiObjects then -- 如果插槽支持多个物体，则无视此规则
                    local slotIndex = j - 1
                    local slotOwnerRuleId = ruleGuid

                    local iconPos = CSharpAPI.GetSlotPosFromBinding(slotOwnerRuleId, slotIndex, self.bindingData)

                    local instance = self.slotModifyBtnPools:InstantiateObject()
                    self.gizmoUITransform:applySlotScale(instance.transform) -- 设置插槽的大小

                    instance:GetComponent(typeof(CS.ShanghaiWindy.Core.IconScreenPositionCtrl)).worldPos = iconPos
                    instance:GetComponent("Button").onClick:AddListener(
                        function()
                            self:selectSlot(slotOwnerRuleId, slotIndex)
                        end
                    )
                    instance.gameObject:SetActive(true)

                    table.insert(self.slotModifyBtnList, instance)
                end
            end
        end
    end
end

--- 处理 UI 点击安装配件事件
function DIY:OnEquipInstallClicked(baseData)
    if self.isLoadingParts then
        return
    end

    local isHull = baseData:GetDataType() == DIYDataEnum.Hull

    if isHull then
        self:addRule(CSharpAPI.GetGUID(), baseData.itemGUID, true, nil, 0)
        self.isLoadingParts = true

        CSharpAPI.CreateNewDIYVehicle(
            self.userDefined,
            function(instanceMesh, textData, bindingData)
                self.bindingData = bindingData
                self:RefreshEquipSlotInteractBtn()

                self.instanceMesh = instanceMesh

                self:refreshInstalledEquipList()
                self:toggleEquipList(true)

                self.isLoadingParts = false
            end
        )
    else
        self:equipSlot(baseData.itemGUID)
    end
end

--- 处理 UI 点击卸载配件事件
function DIY:OnEquipUninstallClicked(rule)
    self:unequipSlot(rule.ruleGuid)
end

--- 处理 UI 点击详情配件事件
function DIY:OnEquipDetailClicked(rule)
    self:selectRule(rule.ruleGuid)
end

-- 处理 C# 侧拾取器选中的物体
function DIY:OnDIYPickItem(ruleGuid)
    self:selectRule(ruleGuid)
end

--- 根据 Rule 刷新已安装的配件 UI 列表
function DIY:refreshInstalledEquipList()
    CSharpAPI.SetEquipRule(self.userDefined)
end

--- 增加规则 （比较简单）
function DIY:addRule(ruleGuid, itemGuid, isMain, parentRuleGuid, targetSlotIndex)
    local rule = DIYRule()
    rule.ruleGuid = ruleGuid
    rule.itemGuid = itemGuid
    rule.isMain = isMain
    rule.parentRuleGuid = parentRuleGuid
    rule.targetSlotIndex = targetSlotIndex
    self.userDefined.rules:Add(rule)
end

-- 删除规则 （需要遍历是否有节点依赖于此节点，比较复杂，放 C# 写（虽然 lua 也可以写但逻辑很烦））
function DIY:deleteRule(ruleGuid)
    CSharpAPI.DeleteDIYRule(self.userDefined, ruleGuid)
end

function DIY:selectSlot(slotOwnerRuleId, slotIndex)
    self:toggleEquipList(false)

    self.curSlotOwnerRuleId = slotOwnerRuleId
    self.curSlotIndex = slotIndex
end

--- 安装配件
function DIY:equipSlot(itemGuid)
    self:addRule(CSharpAPI.GetGUID(), itemGuid, false, self.curSlotOwnerRuleId, self.curSlotIndex)
    self:onModifyUserDefined()
end

--- 当修改 UserDefine 或 增加新的 Rule
function DIY:onModifyUserDefined()
    self.isLoadingParts = true

    CSharpAPI.UpdateDIYVehicle(
        self.userDefined,
        self.bindingData,
        function(instanceMesh, textData, bindingData)
            self.bindingData = bindingData

            self:RefreshEquipSlotInteractBtn()
            self:refreshInstalledEquipList()

            self:toggleEquipList(true)

            self.isLoadingParts = false

            if self.bindingTransform ~= nil then
                CSharpAPI.SetDIYPosition(self.bindingTransform.position)
                CSharpAPI.SetDIYEulerAngles(CSharpAPI.RotToEuler(self.bindingTransform.rotation))
            end
        end
    )
end

-- 强制刷新当前载具
function DIY:forceReloadUserDefined()
    self.isLoadingParts = true

    -- 删除当前的预览
    if self.instanceMesh ~= nil then
        GameObject.Destroy(self.instanceMesh)
    end

    CSharpAPI.CreateNewDIYVehicle(
        self.userDefined,
        function(instanceMesh, textData, bindingData)
            self.isLoadingParts = false

            self.instanceMesh = instanceMesh
            self.bindingData = bindingData

            self:RefreshEquipSlotInteractBtn()
            self:refreshInstalledEquipList()

            self:toggleEquipList(true)
        end
    )
end

--- 删除配件
function DIY:unequipSlot(itemGuid)
    -- 进行删除操作，都要进行询问
    PopMessageManager.Instance:PushPopup(
        "是否删除当前配件? Delete Current Equipment?",
        function(state)
            if state then
                self:deleteRule(itemGuid)
                self:loadNewUserDefine(self.userDefined)
            end
        end
    )
end

--- 切换是否显示已安装的配件
--- @param showInstalled boolean true 则显示已安装的，false 则显示当前插槽可安装的配件
function DIY:toggleEquipList(showInstalled)
    self.allEquipGo:SetActive(not showInstalled)

    if not showInstalled then
        -- 没配件情况下，显示车体的选项
        local isEmptyRuleCount = self.userDefined.rules.Count == 0
        CSharpAPI.SetEquipHullToggle(isEmptyRuleCount)
    end

    self.slotDisableMask.gameObject:SetActive(not showInstalled)
end

function DIY:saveUserDefine(definedName)
    -- 保存名称检查
    if not definedName or definedName == "" then
        PopMessageManager.Instance:PushPopup(
            "请输入存档名称。Input the saving name.",
            function()
            end
        )
        return
    end

    self.userDefined.definedName = definedName

    UserDIYDataManager.Instance:SetDIYUserDefined(self:deepCopyUserDefine(self.userDefined))
    self:refreshFileList()

    self.fileSavePop.gameObject:SetActive(false)
end

--- 所有与存档相关的读写，都需要用深拷贝的规则，防止一些引用变化导致的 Bug
--- @param define DIYUserDefined
--- @return DIYUserDefined
function DIY:deepCopyUserDefine(define)
    return define:GetDeepCopied()
end

--- 删除 UserDefine
function DIY:deleteUserDefine(definedName)
    -- 通知 C# 存储侧删除该 UserDefine
    UserDIYDataManager.Instance:DeleteDIYUserDefined(definedName)
    self:refreshFileList()
end

--- 加载新的 UserDefine
--- @param userDefine DIYUserDefined
function DIY:loadNewUserDefine(userDefine)
    self.isLoadingParts = true

    -- 删除当前的预览
    if self.instanceMesh ~= nil then
        GameObject.Destroy(self.instanceMesh)
    end

    self.userDefined = userDefine

    for k, v in pairs(self.userDefined.rules) do
        --- @type DIYRule
        local rule = v

        if DIYDataManager.Instance:GetData(rule.itemGuid) == nil then
            self.isLoadingParts = false

            local itemDisplayName = rule.itemGuid

            for k, extraInfo in pairs(userDefine.extraInfos) do
                if extraInfo.itemGuid == rule.itemGuid then
                    itemDisplayName = extraInfo.itemName
                end
            end

            PopMessageManager.Instance:PushPopup("缺少部件，无法加载。Item is missing on local. Failed to load."
                .. itemDisplayName,
                nil,
                false)

            return
        end
    end

    CSharpAPI.CreateNewDIYVehicle(
        self.userDefined,
        function(instanceMesh, textData, bindingData)
            self.isLoadingParts = false

            self.bindingData = bindingData
            self.instanceMesh = instanceMesh

            self:RefreshEquipSlotInteractBtn()
            self:refreshInstalledEquipList()

            local isEmptyRuleCount = self.userDefined.rules.Count == 0
            self:toggleEquipList(not isEmptyRuleCount)

            self.ApplyParentScaleToggle.isOn = userDefine.isApplyParentScale
        end
    )
end

--- 选择当前聚焦编辑的规则
function DIY:selectRule(ruleId)
    self.curRuleId = ruleId
    self.isEditingRule = true

    -- 界面切换
    self.equipList.gameObject:SetActive(false)
    self.configProp.gameObject:SetActive(true)
    self.dragInfo.gameObject:SetActive(false)

    for k, v in pairs(self.slotModifyBtnList) do
        v.gameObject:SetActive(false)
    end

    -- 高亮选择的物体
    for i = 0, self.bindingData.Length - 1 do
        local data = self.bindingData[i]
        if data.rule.ruleGuid == ruleId then
            if data.hasInstanceObject then
                self.bindingTransform = data.instanceObject.transform

                for j = 0, data.reference.renderers.Length - 1 do
                    local render = data.reference.renderers[j]
                    if not render:IsNull() then
                        local go = render.gameObject
                        OutlineHelper.CreateOutlineWithDefaultParams(go, render, Color(1, 0, 0, 1))

                        local outline = go:GetComponent(typeof(CS.EPOOutline.Outlinable))
                        table.insert(self.outlinableComponents, outline)
                    end
                end
            end
        end
    end

    for k, v in pairs(self.userDefined.rules) do
        --- @type DIYRule
        local rule = v

        if rule.ruleGuid == ruleId then
            -- 界面基本信息
            local baseData = DIYDataManager.Instance:GetData(rule.itemGuid)
            self.configPropEquipText.text = baseData.displayName:GetDisplayName()
            self.configPropEquipDescriptionText.text = baseData.description:GetDisplayName()
            self.configPropEquipImg.sprite = baseData.icon
            self.configPropEquipType.text = self:getBaseDataTypeText(baseData:GetDataType())
            self.configPropEquipType.color = self:getBaseDataTypeText(baseData:GetDataType())

            -- 坐标变化相关逻辑
            local isHull = baseData:GetDataType() == DIYDataEnum.Hull
            self.configPropTransformInfo.gameObject:SetActive(not isHull) -- 车体不允许调整大小之类
            self.copyBtn.gameObject:SetActive(not isHull)                 -- 车体不允许复制

            self.symmetryXBtn.gameObject:SetActive(not isHull)
            self.symmetryYBtn.gameObject:SetActive(not isHull)
            self.symmetryZBtn.gameObject:SetActive(not isHull)

            if not isHull then
                ------------------------------------------------------
                -- 可视化
                CSharpAPI.SetDIYControlType(self.controlType)

                CSharpAPI.OnDIYPositionHandleChanged:RemoveAllListeners()
                CSharpAPI.SetDIYPosition(self.bindingTransform.position)
                CSharpAPI.OnDIYPositionHandleChanged:AddListener(
                    function(pos)
                        local localPos = self.bindingTransform.parent:InverseTransformPoint(pos) -- 得到插槽上的相对位置
                        local localVec = SerializeVector3(localPos.x, localPos.y, localPos.z)
                        self:Vector3ToTransformInputFields(self.configPropPositionRect, localVec)
                    end
                )

                CSharpAPI.OnDIYEulerAnglesHandleChanged:RemoveAllListeners()
                CSharpAPI.SetDIYEulerAngles(CSharpAPI.RotToEuler(self.bindingTransform.rotation))
                CSharpAPI.OnDIYEulerAnglesHandleChanged:AddListener(
                    function(eulerAngles)
                        local localRot =
                            CSharpAPI.WorldToRelateiveRotation(
                                self.bindingTransform.parent.rotation,
                                CSharpAPI.EulerToRot(eulerAngles)
                            ) -- 得到插槽上的相对旋转

                        local localEuler = CSharpAPI.RotToEuler(localRot)
                        local localVec = SerializeVector3(localEuler.x, localEuler.y, localEuler.z)

                        self:Vector3ToTransformInputFields(self.configPropEulerAngleRect, localVec)
                    end
                )

                CSharpAPI.OnDIYScaleHandleChanged:RemoveAllListeners()
                CSharpAPI.SetDIYScale(self.bindingTransform.localScale)
                CSharpAPI.OnDIYScaleHandleChanged:AddListener(
                    function(localScale)
                        local localVec = SerializeVector3(localScale.x, localScale.y, localScale.z)
                        self:Vector3ToTransformInputFields(self.configScaleRect, localVec)
                    end
                )

                ------------------------------------------------------

                -- 先解绑
                self:clearBindTransformInputField(self.configPropPositionRect)
                self:clearBindTransformInputField(self.configPropEulerAngleRect)
                self:clearBindTransformInputField(self.configScaleRect)

                -- 再对界面赋值
                self:Vector3ToTransformInputFields(self.configPropPositionRect, rule.deltaPos)
                self:Vector3ToTransformInputFields(self.configPropEulerAngleRect, rule.localEulerAngles)
                self:Vector3ToTransformInputFields(self.configScaleRect, rule.scaleSize)

                -- 再绑定
                self:bindTransformInputField(
                    self.configPropPositionRect,
                    function(val)
                        rule.deltaPos = val
                        self:MarkDirty()
                    end
                )

                self:bindTransformInputField(
                    self.configPropEulerAngleRect,
                    function(val)
                        rule.localEulerAngles = val
                        self:MarkDirty()
                    end
                )

                self:bindTransformInputField(
                    self.configScaleRect,
                    function(val)
                        rule.scaleSize = val
                        self:MarkDirty()
                    end
                )
            end

            local customProperty = baseData:CreateCustomizeProperty()

            if rule.customPropertiesJson ~= "" then
                JsonUtility.FromJsonOverwrite(rule.customPropertiesJson, customProperty)
            end

            for p, q in pairs(self.propertyUIList) do
                GameObject.Destroy(q.gameObject)
            end

            self.propertyUIList = {}

            for p, q in pairs(customProperty:GetEdittableFields()) do
                local instance =
                    GameObject.Instantiate(
                        self.configCustomPropertyTemplate,
                        self.configCustomPropertyTemplate.transform.parent,
                        true
                    )

                local toggleableProperty = customProperty:GetField(q)
                local propertyName = uGUI_Localsize.GetContent(q)
                local propertyValue = toggleableProperty:GetValue()
                local propertyIsEnable = toggleableProperty.isEnabled

                instance.transform:Find("PropertyName"):GetComponent("Text").text = propertyName

                local inputField = instance.transform:Find("PropertyField"):GetComponent("InputField")
                if toggleableProperty:IsInputFieldRequired() then
                    inputField.text = propertyValue
                    inputField.interactable = toggleableProperty.isEnabled
                    inputField.onValueChanged:AddListener(
                        function(text)
                            -- 赋值修改参数，并保存
                            toggleableProperty:SetValue(tonumber(text))
                            rule.customPropertiesJson = JsonUtility.ToJson(customProperty)

                            -- 刷新用户数据
                            self:MarkDirty()
                        end
                    )
                else
                    inputField.gameObject:SetActive(false)
                end

                instance.transform:Find("PropertyEnable"):GetComponent("Toggle").isOn = propertyIsEnable
                instance.transform:Find("PropertyEnable"):GetComponent("Toggle").onValueChanged:AddListener(
                    function(isEnabled)
                        -- 开关参数，并保存
                        toggleableProperty.isEnabled = isEnabled
                        inputField.interactable = isEnabled
                        rule.customPropertiesJson = JsonUtility.ToJson(customProperty)

                        -- 刷新用户数据
                        self:MarkDirty()
                    end
                )

                instance.gameObject:SetActive(true)
                table.insert(self.propertyUIList, instance)
            end
        end
    end
end

--- 深拷贝规则，加入规则中，并刷新载具
function DIY:duplicateRule(ruleId)
    -- 深复制此规则
    --- @type DIYRule
    local copiedRule = nil
    for k, v in pairs(self.userDefined.rules) do
        --- @type DIYRule
        local rule = v

        if rule.ruleGuid == ruleId then
            -- 界面基本信息
            copiedRule = rule:GetDeepCopied()
            copiedRule.ruleGuid = CSharpAPI.GetGUID()
            copiedRule.deltaPos = copiedRule.deltaPos + SerializeVector3(0, 1, 0)
            copiedRule.isMain = false
        end
    end

    if copiedRule then
        self.userDefined.rules:Add(copiedRule)
    end

    self:onModifyUserDefined()
    self:closeConfig()
end

--- 镜像
--- @param ruleId string
--- @param axis SymmetryAxis
function DIY:symmetry(ruleId, axis)
    local copiedRule = nil
    for k, v in pairs(self.userDefined.rules) do
        --- @type DIYRule
        local rule = v

        if rule.ruleGuid == ruleId then
            -- 界面基本信息
            --- @type DIYRule
            copiedRule = rule:GetDeepCopied()
            copiedRule.ruleGuid = CSharpAPI.GetGUID()

            -- 镜像
            if axis == SymmetryAxis.XAxis then
                copiedRule.deltaPos = SerializeVector3(-copiedRule.deltaPos.x, copiedRule.deltaPos.y,
                    copiedRule.deltaPos.z)

                local rot = TransformUtil.SerializeVectorToQuaternion(copiedRule.localEulerAngles)
                local symmetryRot = Quaternion(rot.x * -1, rot.y, rot.z, rot.w * -1)
                copiedRule.localEulerAngles = TransformUtil.QuaternionToSeralizeVector(symmetryRot)
            elseif axis == SymmetryAxis.YAxis then
                copiedRule.deltaPos = SerializeVector3(copiedRule.deltaPos.x, -copiedRule.deltaPos.y,
                    copiedRule.deltaPos.z)

                local rot = TransformUtil.SerializeVectorToQuaternion(copiedRule.localEulerAngles)
                local symmetryRot = Quaternion(rot.x, rot.y * -1, rot.z, rot.w * -1)
                copiedRule.localEulerAngles = TransformUtil.QuaternionToSeralizeVector(symmetryRot)
            elseif axis == SymmetryAxis.ZAxis then
                copiedRule.deltaPos = SerializeVector3(copiedRule.deltaPos.x, copiedRule.deltaPos.y,
                    -copiedRule.deltaPos.z)

                local rot = TransformUtil.SerializeVectorToQuaternion(copiedRule.localEulerAngles)
                local symmetryRot = Quaternion(rot.x, rot.y, rot.z * -1, rot.w * -1)
                copiedRule.localEulerAngles = TransformUtil.QuaternionToSeralizeVector(symmetryRot)
            end
            copiedRule.isMain = false
        end
    end

    if copiedRule then
        self.userDefined.rules:Add(copiedRule)
    end

    self:onModifyUserDefined()
    self:closeConfig()
end

--- 将 Vector3 赋值给 InputField
function DIY:Vector3ToTransformInputFields(rectTransform, vec)
    rectTransform:Find("XField"):GetComponent("InputField").text = string.format("%.3f", vec.x)
    rectTransform:Find("YField"):GetComponent("InputField").text = string.format("%.3f", vec.y)
    rectTransform:Find("ZField"):GetComponent("InputField").text = string.format("%.3f", vec.z)
end

--- 从 InputField 获得 Vector3
--- @return Vector3
function DIY:fromTransformInputFieldToVector3(rectTransform)
    local vec = SerializeVector3()
    vec.x = tonumber(rectTransform:Find("XField"):GetComponent("InputField").text)
    vec.y = tonumber(rectTransform:Find("YField"):GetComponent("InputField").text)
    vec.z = tonumber(rectTransform:Find("ZField"):GetComponent("InputField").text)
    return vec
end

function DIY:clearBindTransformInputField(rectTransform)
    -- 清空上次事件的绑定
    rectTransform:Find("XField"):GetComponent("InputField").onValueChanged:RemoveAllListeners()
    rectTransform:Find("YField"):GetComponent("InputField").onValueChanged:RemoveAllListeners()
    rectTransform:Find("ZField"):GetComponent("InputField").onValueChanged:RemoveAllListeners()
end

--- 绑定坐标变化事件
function DIY:bindTransformInputField(rectTransform, onValueChanged)
    -- 新的事件绑定
    rectTransform:Find("XField"):GetComponent("InputField").onValueChanged:AddListener(
        function(text)
            onValueChanged(self:fromTransformInputFieldToVector3(rectTransform))
        end
    )

    rectTransform:Find("YField"):GetComponent("InputField").onValueChanged:AddListener(
        function(text)
            onValueChanged(self:fromTransformInputFieldToVector3(rectTransform))
        end
    )

    rectTransform:Find("ZField"):GetComponent("InputField").onValueChanged:AddListener(
        function(text)
            onValueChanged(self:fromTransformInputFieldToVector3(rectTransform))
        end
    )
end

--- 导出分享码
function DIY:ExportShareCode(userDefine)
    CSharpAPI.ExportShareCode(
        userDefine,
        function(serverCode)
            if serverCode == "" then
                PopMessageManager.Instance:PushPopup(
                    "分享异常。Share failed.",
                    function(state)
                    end,
                    false
                )
            else
                PopMessageManager.Instance:PushPopup(
                    "游戏将访问剪贴版，并将分享码: " .. serverCode .. " 复制进剪贴板",
                    function(state)
                        if state then
                            GUIUtility.systemCopyBuffer = serverCode

                            if CS.UnityEngine.Application.isMobilePlatform then
                                PopMessageManager.Instance:PushNotice("复制成功。聊天软件长按输入框，点击粘贴即可分享给好友。"
                                , 4)
                            else
                                PopMessageManager.Instance:PushNotice("复制成功。点击 Ctrl + V 即可分享给好友。"
                                , 4)
                            end
                        end
                    end
                )
            end
        end
    )
end

--- 导入分享码
function DIY:ImportShareCode(shareCode)
    CSharpAPI.ImportShareCode(
        shareCode,
        function(shareUserDefine)
            if shareUserDefine ~= nil then
                UserDIYDataManager.Instance:SetDIYUserDefined(shareUserDefine)
                self:refreshFileList()
            end

            self.shareCodeInput.text = ""
            self.shareImportPop.gameObject:SetActive(false)
        end
    )
end

--- 关闭配件详情页面
function DIY:closeConfig()
    self.equipList.gameObject:SetActive(true)
    self.configProp.gameObject:SetActive(false)
    self.dragInfo.gameObject:SetActive(true)

    self.curRuleId = nil
    self.isEditingRule = false

    -- 显示被隐藏的插槽
    self:RefreshEquipSlotInteractBtn()

    for k, v in pairs(self.outlinableComponents) do
        GameObject.Destroy(v)
    end

    self.outlinableComponents = {}
    CSharpAPI.SetDIYControlType(eDIYControlType.None)
end

function DIY:updateTimeScale()
    local curTimeScale = Time.timeScale

    if curTimeScale == 0 then
        curTimeScale = 1
    else
        curTimeScale = 0
    end

    Time.timeScale = curTimeScale
    self.timeScaleInfoGo:SetActive(curTimeScale == 0)
end

function DIY:OnExitMode()
    self.isEditMode = false

    EntityFactory.RemoveEntity(self.cameraController)
    EntityFactory.RemoveEntity(self.rayHitClick)

    CSharpAPI.OnDIYPositionHandleChanged:RemoveAllListeners()
    CSharpAPI.OnDIYEulerAnglesHandleChanged:RemoveAllListeners()
    CSharpAPI.OnDIYScaleHandleChanged:RemoveAllListeners()

    CSharpAPI.OnEquipUninstallClicked:RemoveListener(self.OnEquipUninstallClickedCb)
    CSharpAPI.OnEquipDetailClicked:RemoveListener(self.OnEquipDetailClickedCb)
    CSharpAPI.OnEquipInstallClicked:RemoveListener(self.OnEquipInstallClickedCb)
    CSharpAPI.OnDIYPickItem:RemoveListener(self.OnDIYPickItemCb)

    EventSystem.RemoveListener(EventDefine.OnGizmoConfigChanged, self.RefreshAllSlotScale, self)
    TimeAPI.UnRegisterLateFrameTick(self.onFrameTick)

    self.slotModifyBtnPools:Dispose()
end

function DIY:refreshFileList()
    self.fileMgr:Clean()

    for k, v in pairs(UserDIYDataManager.Instance:GetDIYUserDefineds()) do
        if v then
            self.fileMgr:AddFileName(v.definedName)
        end
    end

    self.fileMgr:Refresh()
end

return DIY
