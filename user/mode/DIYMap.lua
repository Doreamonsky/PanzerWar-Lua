local GizmoConfigController = require("user.component.gizmoconfigcontroller")
local CameraController = require("user.component.cameracontroller")
local ShareCodeListController = require("user.component.sharecodelistcontroller")
local CustomClickHandler = require("user.component.customclickhandler")

local DIYMap = class("DIYMap")

GameMode()

function DIYMap:ctor()
    self.modName = "DIYMap"
    self.author = "WindyVerse Pte. Ltd."
    self.description = "创建自定义地图"
    self.isDefinitiveOnly = true
end

function DIYMap:GetGameModeName(userLang)
    if userLang == "CN" then
        return "地图工坊"
    else
        return "Map Workshop"
    end
end

function DIYMap:OnStartMode()
    self.isEditMode = true
    self.controlType = eDIYControlType.Position
    self.cameraController = EntityFactory.AddEntity(CameraController.new())

    self.shareCodeListController = ShareCodeListController.new(
        "https://game.windyverse.net/backend/mapUserDefine/Newest/",
        function(cb)
            self:ImportShareCode(cb)
        end
    )

    self.outlinableComponents = {}
    self.isLocalControlHandle = false

    --- @type DIYMapItemComponent
    self.itemComponent = nil

    CSharpAPI.RequestScene(
        "Empty-Scene",
        function()
            AssetAPI.InstantiateNonPoolObject("f5ec298e-6852-487a-95a8-00191a792ad4", "DIYCreateMapUtil.prefab",
                function(res)
                    self:onUtilCreated(res)
                end)
        end
    )

    self.onFrameTick = handler(self, self.OnFrameTick)
    TimeAPI.RegisterLateFrameTick(self.onFrameTick)
end

function DIYMap:onUtilCreated(root)
    local settingBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/SettingBtn"):GetComponent(typeof(Button))
    local configTransform = root.transform:Find("DIYCreateMapCanvas/GizmoConfig")
    local rtPluginTransform = root.transform:Find("RT-Plugin")

    self.gizmoUITransform = GizmoConfigController.new()
    self.gizmoUITransform:init(configTransform, rtPluginTransform, settingBtn)

    self.fileLoadPop = root.transform:Find("DIYCreateMapCanvas/FileLoadPop")

    --- @type DIYFileRecycleMgr
    self.fileMgr = self.fileLoadPop:GetComponent(typeof(DIYFileRecycleMgr))

    self.dragInfo = root.transform:Find("DIYCreateMapCanvas/DragInfo")
    self.configProp = root.transform:Find("DIYCreateMapCanvas/ConfigProp")
    self.configComfirmBtn = self.configProp:Find("Title/ConfirmBtn"):GetComponent(typeof(Button))
    self.configDeleteBtn = self.configProp:Find("Title/DeleteBtn"):GetComponent(typeof(Button))
    self.configMethodTemplateGo = self.configProp:Find("Methods/MethodTemplate").gameObject

    self.configContent = self.configProp:Find("Content")
    self.configPropEquipText = self.configContent:Find("BaseInfo/EquipName"):GetComponent(typeof(Text))
    self.configPropEquipDescriptionText = self.configContent:Find("BaseInfo/EquipDescription"):GetComponent(typeof(Text))
    self.configPropEquipImg = self.configContent:Find("BaseInfo/Icon"):GetComponent(typeof(Image))
    self.configDuplicateBtn = self.configContent:Find("Main/DuplicateBtn"):GetComponent(typeof(Button))
    self.configFocusBtn = self.configContent:Find("Main/FocusBtn"):GetComponent(typeof(Button))
    self.configTransformBtn = self.configContent:Find("Main/TransformBtn"):GetComponent(typeof(Button))
    self.configPropertyBtn = self.configContent:Find("Main/PropertyBtn"):GetComponent(typeof(Button))

    --- @type RuntimeInspector
    self.runtimeInspector = self.configContent:Find("Property/RuntimeInspector"):GetComponent(typeof(RuntimeInspector))
    self.runtimeInspector:Awake() -- 预热

    self.noneBtn = root.transform:Find("DIYCreateMapCanvas/ConfigProp/TransformHandle/NoneBtn"):GetComponent(typeof(
    Button))
    self.moveBtn = root.transform:Find("DIYCreateMapCanvas/ConfigProp/TransformHandle/MoveBtn"):GetComponent(typeof(
    Button))
    self.rotateBtn = root.transform:Find("DIYCreateMapCanvas/ConfigProp/TransformHandle/RotateBtn"):GetComponent(
        typeof(Button))
    self.scaleBtn = root.transform:Find("DIYCreateMapCanvas/ConfigProp/TransformHandle/ScaleBtn"):GetComponent(typeof(
    Button))
    self.worldLocalBtn = root.transform:Find("DIYCreateMapCanvas/ConfigProp/TransformHandle/WorldLocalBtn"):GetComponent(
        typeof(Button))
    self.localWorldBtn = root.transform:Find("DIYCreateMapCanvas/ConfigProp/TransformHandle/LocalWorldBtn"):GetComponent(
        typeof(Button))

    self.exitActionBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/ExitBtn"):GetComponent(typeof(Button))
    self.importActionBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/ImportBtn"):GetComponent(typeof(Button))
    self.saveActionBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/SaveBtn"):GetComponent(typeof(Button))
    self.loadActionBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/LoadBtn"):GetComponent(typeof(Button))

    self.fileSavePop = root.transform:Find("DIYCreateMapCanvas/FileSavePop")
    self.fileNameInput = self.fileSavePop.transform:Find("FileNameInput"):GetComponent(typeof(InputField))
    self.saveBtn = self.fileSavePop.transform:Find("SaveBtn"):GetComponent(typeof(Button))
    self.fileLoadCloseBtn = root.transform:Find("DIYCreateMapCanvas/FileLoadPop/Title/CloseBtn"):GetComponent(typeof(
    Button))
    self.loadShareBtn = self.fileLoadPop:Find("Title/LoadShareBtn"):GetComponent(typeof(Button))

    self.shareImportPop = root.transform:Find("DIYCreateMapCanvas/ShareImportPop")
    self.shareImportCancelBtn = self.shareImportPop:GetComponent(typeof(Button))
    self.shareCodeInput = self.shareImportPop:Find("ShareCodeInput"):GetComponent(typeof(InputField))
    self.shareImportBtn = self.shareImportPop:Find("ImportBtn"):GetComponent(typeof(Button))

    self.longPressTipGo = root.transform:Find("DIYCreateMapCanvas/LongPressTip").gameObject
    self.tipFillImg = self.longPressTipGo.transform:Find("Fill"):GetComponent(typeof(Image))

    self.eventTrigger = root.transform:Find("DIYCreateMapCanvas/TouchBar"):GetComponent(typeof(EventTrigger))
    self.seasonDropdown = root.transform:Find("DIYCreateMapCanvas/FileSavePop/SeasonDropdown"):GetComponent("Dropdown")

    self.downloadMaskGo = root.transform:Find("DIYCreateMapCanvas/DownloadMask").gameObject

    self.navBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/NavBtn"):GetComponent(typeof(Button))

    self.handlerTransform = root.transform:Find("RT-Plugin/Handle").transform

    ---------------------Bind--------------------------
    self.configDeleteBtn.onClick:AddListener(
        function()
            self:deleteConfig()
        end
    )

    self.noneBtn.onClick:AddListener(
        function()
            self:setHandle(eDIYControlType.None)
        end
    )

    self.moveBtn.onClick:AddListener(
        function()
            self:setHandle(eDIYControlType.Position)
        end
    )

    self.rotateBtn.onClick:AddListener(
        function()
            self:setHandle(eDIYControlType.EulerAngles)
        end
    )

    self.scaleBtn.onClick:AddListener(
        function()
            self:setHandle(eDIYControlType.Scale)
        end
    )

    self.localWorldBtn.onClick:AddListener(
        function()
            self.isLocalControlHandle = false
            self:setHandle(self.controlType)
        end
    )

    self.worldLocalBtn.onClick:AddListener(
        function()
            self.isLocalControlHandle = true
            self:setHandle(self.controlType)
        end
    )

    self.configComfirmBtn:GetComponent(typeof(Button)).onClick:AddListener(
        function()
            self:closeConfig()
        end
    )

    self.configDuplicateBtn.onClick:AddListener(
        function()
            local targetComponent = self.itemComponent

            if targetComponent ~= nil then
                self:duplicateItem(targetComponent, function(res)
                    self:closeConfig()
                    self:selectItemComponent(res)
                end)
            end
        end
    )

    self.configFocusBtn.onClick:AddListener(
        function()
            local targetComponent = self.itemComponent

            if targetComponent ~= nil then
                self.cameraController:focusTarget(targetComponent.transform.position)
            end
        end
    )

    self.configTransformBtn.onClick:AddListener(
        function()
            self.runtimeInspector:Inspect(self.itemComponent.transform)
        end
    )

    self.configPropertyBtn.onClick:AddListener(
        function()
            self.runtimeInspector:Inspect(self.itemComponent:GetJson())
        end
    )

    -- self.exitBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/ExitBtn"):GetComponent(typeof(Button))
    -- self.importBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/ImportBtn"):GetComponent(typeof(Button))
    -- self.saveBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/SaveBtn"):GetComponent(typeof(Button))
    -- self.loadBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/LoadBtn"):GetComponent(typeof(Button))

    self.fileSavePop:GetComponent(typeof(Button)).onClick:AddListener(
        function()
            self.fileSavePop.gameObject:SetActive(false)
        end
    )

    self.exitActionBtn.onClick:AddListener(
        function()
            PopMessageManager.Instance:PushPopup(
                UIAPI.GetLocalizedContent("ConfirmExitWorkshop"),
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

    self.importActionBtn.onClick:AddListener(
        function()
            self.shareImportPop.gameObject:SetActive(true)
        end
    )

    self.saveActionBtn.onClick:AddListener(
        function()
            self.fileSavePop.gameObject:SetActive(true)
        end
    )

    self.loadActionBtn.onClick:AddListener(
        function()
            self.fileLoadPop.gameObject:SetActive(true)
        end
    )

    self.saveBtn.onClick:AddListener(
        function()
            local definedName = self.fileNameInput.text
            self.fileSavePop.gameObject:SetActive(false)

            local userDefine = DIYMapSerializationUtil.SerializeCurrentScene(definedName)
            userDefine.season = self.seasonDropdown.value
            UserDIYMapDataManager.Instance:SetDIYUserDefined(userDefine)

            self:refeshFileList()
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

    self.navBtn.onClick:AddListener(
        function()
            self:toggleNav()
        end
    )
    ---------------------摄像机--------------------------
    --- @type Transform
    self.cameraUITransform = root.transform:Find("DIYCreateMapCanvas/CameraAction")
    self.cameraTransform = root.transform:Find("Main Camera").transform
    self.cameraTargetTrans = root.transform:Find("CameraPoint")
    self.mainCamera = self.cameraTransform:GetComponent(typeof(Camera))
    self.cameraController:Init(self.cameraUITransform, self.cameraTransform, self.cameraTargetTrans)
    ------------------------------------------------------

    ---------------------分享码--------------------------
    local findBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/FindBtn"):GetComponent(typeof(Button))
    local shareCodeListGo = root.transform:Find("DIYCreateMapCanvas/DIYShareCodeListCanvas").gameObject
    self.shareCodeListController:Init(findBtn, shareCodeListGo)
    ------------------------------------------------------

    ---------------------地图加载页面--------------------------
    self.fileLoadCloseBtn.onClick:AddListener(function()
        self.fileLoadPop.gameObject:SetActive(false)
    end)


    self:refeshFileList()

    self.fileMgr.OnPublishFile:AddListener(function(definedName)
        local userDefine = UserDIYMapDataManager.Instance:GetUserDefine(definedName)
        DIYDataPackageManager.Instance:ExportMapUserDefine(userDefine)
    end)

    self.fileMgr.OnDeleteFile:AddListener(function(definedName)
        -- 删除当前存档
        PopMessageManager.Instance:PushPopup(
            UIAPI.GetLocalizedContent("ConfirmDeleteSave"),
            function(state)
                if state then
                    UserDIYMapDataManager.Instance:DeleteDIYUserDefined(definedName)
                    self.fileMgr:RemoveFileName(definedName)
                    self.fileMgr:Refresh()
                end
            end
        )
    end)

    self.fileMgr.OnLoadFile:AddListener(function(definedName)
        self.fileLoadPop.gameObject:SetActive(false)
        self.fileNameInput.text = definedName

        -- 清当前场景
        DIYMapSerializationUtil.CleanScene()

        -- 创建新场景
        local userDefine = UserDIYMapDataManager.Instance:GetUserDefine(definedName)
        DIYMapSerializationUtil.DeserializeToCurrentScene(userDefine, false)

        self.seasonDropdown.value = CSharpAPI.EnumToNumber(userDefine.season)
    end)

    self.fileMgr.OnShareFile:AddListener(function(definedName)
        local userDefine = UserDIYMapDataManager.Instance:GetUserDefine(definedName)
        self:exportShareCode(userDefine)
    end)
    ------------------------------------------------------

    self.configMethodGoPool = GameObjectPool()
    self.configMethodGoPool:Init(self.configMethodTemplateGo, 5)
    self.configsMethodList = {}

    --- @type CustomClickHandler
    self.rayHitClick = EntityFactory.AddEntity(CustomClickHandler.new())
    self.rayHitClick:Init(self.eventTrigger, 1, 5, function(evtData)
        if not GizmoConfig.config.EnablePressSelect then return end
        local ret, viewData = DIYMapItemComponentDragPicker.Instance:GetRayItem(evtData.position)

        if ret then
            if self.itemComponent ~= nil then
                if self.itemComponent == viewData.itemComponent then
                    return
                else
                    self:closeConfig()
                end
            end

            self:selectItemComponent(viewData.itemComponent)
        end
    end, function(state, evtData)
        if not GizmoConfig.config.EnablePressSelect then return end
        if self.itemComponent ~= nil then return end
        self.longPressTipGo:SetActive(state)
    end, function(progress)
        if not GizmoConfig.config.EnablePressSelect then return end
        if self.itemComponent ~= nil then return end
        self.tipFillImg.fillAmount = progress
    end)


    CSharpAPI.SetDIYControlType(eDIYControlType.None)

    self.OnDIYPositionHandleChangedCb = function(position)
        if self.itemComponent ~= nil then
            self.itemComponent.transform.position = position
        end
    end

    self.OnDIYEulerAnglesHandleChangedCb = function(eulerAngles)
        if self.itemComponent ~= nil then
            self.itemComponent.transform.eulerAngles = eulerAngles
        end
    end

    self.OnDIYScaleHandleChangedCb = function(localScale)
        if self.itemComponent ~= nil then
            self.itemComponent.transform.localScale = localScale
        end
    end

    self.OnMapPickItemComponentCb = function(itemCompoent)
        self:selectItemComponent(itemCompoent)
    end

    self.OnMapInstallClickedCb = function(baseData)
        self:OnMapInstallClicked(baseData)
    end

    CSharpAPI.OnDIYPositionHandleChanged:AddListener(self.OnDIYPositionHandleChangedCb)
    CSharpAPI.OnDIYEulerAnglesHandleChanged:AddListener(self.OnDIYEulerAnglesHandleChangedCb)
    CSharpAPI.OnDIYScaleHandleChanged:AddListener(self.OnDIYScaleHandleChangedCb)
    CSharpAPI.OnMapPickItemComponent:AddListener(self.OnMapPickItemComponentCb)
    CSharpAPI.OnMapInstallClicked:AddListener(self.OnMapInstallClickedCb)
end

function DIYMap:OnFrameTick()
    if self.isEditMode then
        -- 意外情况下，Handler 强制更新位置
        if self.itemComponent ~= nil and not self.itemComponent:IsNull() then
            local dis = Vector3.Distance(self.handlerTransform.position, self.itemComponent.transform.position)

            if dis > 0.05 then
                self:updateHandle()
            end
        end
    end
end

function DIYMap:OnExitMode()
    self.isEditMode = false

    EntityFactory.RemoveEntity(self.cameraController)
    EntityFactory.RemoveEntity(self.rayHitClick)

    CSharpAPI.OnDIYPositionHandleChanged:RemoveListener(self.OnDIYPositionHandleChangedCb)
    CSharpAPI.OnDIYEulerAnglesHandleChanged:RemoveListener(self.OnDIYEulerAnglesHandleChangedCb)
    CSharpAPI.OnDIYScaleHandleChanged:RemoveListener(self.OnDIYScaleHandleChangedCb)
    CSharpAPI.OnMapPickItemComponent:RemoveListener(self.OnMapPickItemComponentCb)
    CSharpAPI.OnMapInstallClicked:RemoveListener(self.OnMapInstallClickedCb)
    TimeAPI.UnRegisterLateFrameTick(self.onFrameTick)
end

--- @param baseData DIYMapBaseData
function DIYMap:OnMapInstallClicked(baseData)
    --- @type Ray
    local ray = self.mainCamera:ScreenPointToRay(self.dragInfo.position)
    DIYMapCreateUtil.AutoPlaceItem(baseData.itemGUID, ray.origin, ray.direction)

    local content = UIAPI.FormatString(UIAPI.GetLocalizedContent("PlaceItem"), baseData.displayName:GetDisplayName())
    PopMessageManager.Instance:PushNotice(content, 1)
end

--- @param itemCompoent DIYMapItemComponent
function DIYMap:selectItemComponent(itemCompoent)
    self.itemComponent = itemCompoent
    self.configProp.gameObject:SetActive(true)
    self.dragInfo.gameObject:SetActive(false)

    self.runtimeInspector:Inspect(self.itemComponent:GetJson())

    if not self.itemComponent:IsNull() then
        self.itemComponent:OnSelect()
    else
        -- 各种意外，导致选择到空物体。比如单例复制。
        return
    end

    local baseData = itemCompoent:GetData()
    self.configPropEquipText.text = baseData.displayName:GetDisplayName()
    self.configPropEquipDescriptionText.text = baseData.description:GetDisplayName()
    self.configPropEquipImg.sprite = baseData.icon

    -- 移动绑定
    self:updateHandle()

    -- 描边
    local reference = self.itemComponent.gameObject:GetComponent(typeof(DIYMapBaseReference))

    for i = 0, reference.renderers.Length - 1 do
        local render = reference.renderers[i]

        if not render:IsNull() then
            local go = render.gameObject
            OutlineHelper.CreateOutlineWithDefaultParams(go, render, Color(1, 0, 0, 1))

            local outline = go:GetComponent(typeof(CS.EPOOutline.Outlinable))
            table.insert(self.outlinableComponents, outline)
        end
    end

    -- 扩展方法
    for k, v in pairs(self.configsMethodList) do
        self.configMethodGoPool:DestroyObject(v)
    end

    self.configsMethodList = {}

    local reflectMethods = self.itemComponent:ReflectMethods()
    local methodDisplayNames = self.itemComponent:ReflectMethodDisplayNames()

    for i = 0, reflectMethods.Length - 1 do
        local go = self.configMethodGoPool:InstantiateObject()
        local txt = go.transform:Find("Text"):GetComponent(typeof(Text))
        local btn = go.transform:GetComponent(typeof(Button))
        txt.text = methodDisplayNames[i]
        btn.onClick:RemoveAllListeners()
        btn.onClick:AddListener(function()
            itemCompoent:InvokeMethod(i)
        end)
        go:SetActive(true)

        table.insert(self.configsMethodList, go)
    end
end

--- 更新轴位置
function DIYMap:updateHandle()
    CSharpAPI.SetDIYPosition(self.itemComponent.transform.position)
    CSharpAPI.SetDIYEulerAngles(self.itemComponent.transform.eulerAngles)
    CSharpAPI.SetDIYScale(self.itemComponent.transform.localScale)
    self:setHandle(self.controlType)
end

--- 设置轴
function DIYMap:setHandle(controlType)
    self.controlType = controlType

    self.localWorldBtn.gameObject:SetActive(self.isLocalControlHandle)
    self.worldLocalBtn.gameObject:SetActive(not self.isLocalControlHandle)

    if controlType == eDIYControlType.Position then
        if self.isLocalControlHandle then
            CSharpAPI.SetDIYEulerAngles(Vector3.zero)
        else
            CSharpAPI.SetDIYEulerAngles(self.itemComponent.transform.eulerAngles)
        end
    else
        CSharpAPI.SetDIYEulerAngles(self.itemComponent.transform.eulerAngles)
    end

    CSharpAPI.SetDIYControlType(self.controlType)
end

--- 删除当前配置
function DIYMap:deleteConfig()
    PopMessageManager.Instance:PushPopup(
        UIAPI.GetLocalizedContent("ConfirmDeleteItem"),
        function(state)
            if state then
                GameObject.Destroy(self.itemComponent.gameObject)
                self:closeConfig()
            end
        end
    )
end

--- 关闭配置
function DIYMap:closeConfig()
    self:deleteOutlines()

    if not self.itemComponent:IsNull() then
        self.itemComponent:OnDeselect()
    end

    self.itemComponent = nil
    self.configProp.gameObject:SetActive(false)
    self.dragInfo.gameObject:SetActive(true)

    CSharpAPI.SetDIYControlType(eDIYControlType.None)
end

function DIYMap:deleteOutlines()
    for k, v in pairs(self.outlinableComponents) do
        GameObject.Destroy(v)
    end

    self.outlinableComponents = {}
end

function DIYMap:duplicateItem(itemComponent, callBack)
    PopMessageManager.Instance:PushNotice("复制成功 - Copy Successfully", 1)
    itemComponent:SerializeProperty()

    local itemGuid = itemComponent:GetData().itemGUID
    local itemJson = JsonUtility.ToJson(itemComponent:GetJson())

    local rule = DIYMapUserDefinedRule()
    rule.itemGuid = itemGuid
    rule.itemJson = itemJson

    DIYMapCreateUtil.AsyncCreateData(rule, false, function(res)
        local component = res:GetComponent(typeof(DIYMapItemComponent))
        callBack(component)
    end)
end

--- 刷新页面
function DIYMap:refeshFileList()
    self.fileMgr:Clean()

    for k, v in pairs(UserDIYMapDataManager.Instance:GetDIYUserDefines()) do
        self.fileMgr:AddFileName(v.definedName)
    end

    self.fileMgr:Refresh()
end

--- 导出分享码
function DIYMap:exportShareCode(userDefine)
    CSharpAPI.ExportMapShareCode(
        userDefine,
        function(serverCode)
            if serverCode == "" then
                PopMessageManager.Instance:PushPopup(
                    UIAPI.GetLocalizedContent("ShareFailed"),
                    function(state)
                    end,
                    false
                )
            else
                PopMessageManager.Instance:PushPopup(
                    UIAPI.FormatString(UIAPI.GetLocalizedContent("ShareCodeClipboard"), serverCode),
                    function(state)
                        if state then
                            GUIUtility.systemCopyBuffer = serverCode

                            if CS.UnityEngine.Application.isMobilePlatform then
                                PopMessageManager.Instance:PushNotice(UIAPI.GetLocalizedContent("CopyShareCodeMobile"), 4)
                            else
                                PopMessageManager.Instance:PushNotice(UIAPI.GetLocalizedContent("CopyShareCodeDesktop"),
                                    4)
                            end
                        end
                    end
                )
            end
        end
    )
end

--- 导入分享码
function DIYMap:ImportShareCode(shareCode)
    self.downloadMaskGo:SetActive(true)

    CSharpAPI.ImportMapShareCode(
        shareCode,
        function(shareUserDefine)
            if shareUserDefine ~= nil then
                UserDIYMapDataManager.Instance:SetDIYUserDefined(shareUserDefine)
                self:refeshFileList()

                PopMessageManager.Instance:PushPopup(
                    "导入成功。Import Succeed.",
                    function(state)
                    end,
                    false
                )
            end

            self.shareCodeInput.text = ""
            self.downloadMaskGo:SetActive(false)
            self.shareImportPop.gameObject:SetActive(false)
        end
    )
end

--- 切换寻路显示
function DIYMap:toggleNav()
    if self.visualizeMesh ~= nil and not self.visualizeMesh:IsNull() then
        self:removeNav()
    else
        self.visualizeMesh = DIYMapCreateUtil.BuildVisualizeMesh()
    end
end

--- 删除寻路模型
function DIYMap:removeNav()
    GameObject.Destroy(self.visualizeMesh)
end

return DIYMap
