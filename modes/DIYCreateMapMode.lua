require "modes.Common.CustomClickHandler"
require "modes.Common.CameraController"
require "modes.Common.ShareCodeListController"

DIYCreateMapMode = {}

local this = DIYCreateMapMode
this.onStartMode = function()
    this.isEditMode = true
    this.controlType = eDIYControlType.Position
    this.cameraController = CameraController.new()
    this.shareCodeListController = ShareCodeListController.new(
        "https://game.waroftanks.cn/backend/mapUserDefine/Newest/",
        this.importShareCode
    )

    this.outlinableComponents = {}
    this.isLocalControlHandle = false

    --- @type DIYMapItemComponent
    this.itemComponent = nil

    CSharpAPI.RequestScene(
        "Empty-Scene",
        function()
            CSharpAPI.LoadAssetBundle(
                "DIYCreateMapUtil",
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
    local settingBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/SettingBtn"):GetComponent("Button")
    local configTransform = root.transform:Find("DIYCreateMapCanvas/GizmoConfig")
    local rtPluginTransform = root.transform:Find("RT-Plugin")

    this.gizmoUITransform = GizmoConfigController.new()
    this.gizmoUITransform:init(configTransform, rtPluginTransform, settingBtn)

    this.fileLoadPop = root.transform:Find("DIYCreateMapCanvas/FileLoadPop")

    --- @type DIYFileRecycleMgr
    this.fileMgr = this.fileLoadPop:GetComponent(typeof(DIYFileRecycleMgr))

    this.dragInfo = root.transform:Find("DIYCreateMapCanvas/DragInfo")
    this.configProp = root.transform:Find("DIYCreateMapCanvas/ConfigProp")
    this.configComfirmBtn = this.configProp:Find("Title/ConfirmBtn"):GetComponent("Button")
    this.configDeleteBtn = this.configProp:Find("Title/DeleteBtn"):GetComponent("Button")
    this.configMethodTemplateGo = this.configProp:Find("Methods/MethodTemplate").gameObject

    this.configContent = this.configProp:Find("Content")
    this.configPropEquipText = this.configContent:Find("BaseInfo/EquipName"):GetComponent("Text")
    this.configPropEquipDescriptionText = this.configContent:Find("BaseInfo/EquipDescription"):GetComponent("Text")
    this.configPropEquipImg = this.configContent:Find("BaseInfo/Icon"):GetComponent("Image")
    this.configDuplicateBtn = this.configContent:Find("Main/DuplicateBtn"):GetComponent("Button")
    this.configFocusBtn = this.configContent:Find("Main/FocusBtn"):GetComponent("Button")
    this.configTransformBtn = this.configContent:Find("Main/TransformBtn"):GetComponent("Button")
    this.configPropertyBtn = this.configContent:Find("Main/PropertyBtn"):GetComponent("Button")

    --- @type RuntimeInspector
    this.runtimeInspector = this.configContent:Find("Property/RuntimeInspector"):GetComponent(typeof(RuntimeInspector))
    this.runtimeInspector:Awake() -- 预热

    this.noneBtn = root.transform:Find("DIYCreateMapCanvas/ConfigProp/TransformHandle/NoneBtn"):GetComponent("Button")
    this.moveBtn = root.transform:Find("DIYCreateMapCanvas/ConfigProp/TransformHandle/MoveBtn"):GetComponent("Button")
    this.rotateBtn = root.transform:Find("DIYCreateMapCanvas/ConfigProp/TransformHandle/RotateBtn"):GetComponent("Button")
    this.scaleBtn = root.transform:Find("DIYCreateMapCanvas/ConfigProp/TransformHandle/ScaleBtn"):GetComponent("Button")
    this.worldLocalBtn = root.transform:Find("DIYCreateMapCanvas/ConfigProp/TransformHandle/WorldLocalBtn"):GetComponent("Button")
    this.localWorldBtn = root.transform:Find("DIYCreateMapCanvas/ConfigProp/TransformHandle/LocalWorldBtn"):GetComponent("Button")

    this.exitActionBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/ExitBtn"):GetComponent("Button")
    this.importActionBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/ImportBtn"):GetComponent("Button")
    this.saveActionBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/SaveBtn"):GetComponent("Button")
    this.loadActionBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/LoadBtn"):GetComponent("Button")

    this.fileSavePop = root.transform:Find("DIYCreateMapCanvas/FileSavePop")
    this.fileNameInput = this.fileSavePop.transform:Find("FileNameInput"):GetComponent("InputField")
    this.saveBtn = this.fileSavePop.transform:Find("SaveBtn"):GetComponent("Button")
    this.fileLoadCloseBtn = root.transform:Find("DIYCreateMapCanvas/FileLoadPop/Title/CloseBtn"):GetComponent("Button")
    this.loadShareBtn = this.fileLoadPop:Find("Title/LoadShareBtn"):GetComponent("Button")

    this.shareImportPop = root.transform:Find("DIYCreateMapCanvas/ShareImportPop")
    this.shareImportCancelBtn = this.shareImportPop:GetComponent("Button")
    this.shareCodeInput = this.shareImportPop:Find("ShareCodeInput"):GetComponent("InputField")
    this.shareImportBtn = this.shareImportPop:Find("ImportBtn"):GetComponent("Button")

    this.longPressTipGo = root.transform:Find("DIYCreateMapCanvas/LongPressTip").gameObject
    this.tipFillImg = this.longPressTipGo.transform:Find("Fill"):GetComponent("Image")

    this.eventTrigger = root.transform:Find("DIYCreateMapCanvas/TouchBar"):GetComponent(typeof(EventTrigger))
    this.seasonDropdown = root.transform:Find("DIYCreateMapCanvas/FileSavePop/SeasonDropdown"):GetComponent("Dropdown")

    this.downloadMaskGo = root.transform:Find("DIYCreateMapCanvas/DownloadMask").gameObject

    this.navBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/NavBtn"):GetComponent("Button")

    this.handlerTransform = root.transform:Find("RT-Plugin/Handle").transform

    ---------------------Bind--------------------------
    this.configDeleteBtn.onClick:AddListener(
        function()
            this.deleteConfig()
        end
    )

    this.noneBtn.onClick:AddListener(
        function()
            this.setHandle(eDIYControlType.None)
        end
    )

    this.moveBtn.onClick:AddListener(
        function()
            this.setHandle(eDIYControlType.Position)
        end
    )

    this.rotateBtn.onClick:AddListener(
        function()
            this.setHandle(eDIYControlType.EulerAngles)
        end
    )

    this.scaleBtn.onClick:AddListener(
        function()
            this.setHandle(eDIYControlType.Scale)
        end
    )

    this.localWorldBtn.onClick:AddListener(
        function()
            this.isLocalControlHandle = false
            this.setHandle(this.controlType)
        end
    )

    this.worldLocalBtn.onClick:AddListener(
        function()
            this.isLocalControlHandle = true
            this.setHandle(this.controlType)
        end
    )

    this.configComfirmBtn:GetComponent("Button").onClick:AddListener(
        function()
            this.closeConfig()
        end
    )

    this.configDuplicateBtn.onClick:AddListener(
        function()
            local targetComponent = this.itemComponent

            if targetComponent ~= nil then
                this.duplicateItem(targetComponent, function(res)
                    this.closeConfig()
                    this.selectItemComponent(res)
                end)
            end
        end
    )

    this.configFocusBtn.onClick:AddListener(
        function()
            local targetComponent = this.itemComponent

            if targetComponent ~= nil then
                this.cameraController:focusTarget(targetComponent.transform.position)
            end
        end
    )

    this.configTransformBtn.onClick:AddListener(
        function()
            this.runtimeInspector:Inspect(this.itemComponent.transform)
        end
    )

    this.configPropertyBtn.onClick:AddListener(
        function()
            this.runtimeInspector:Inspect(this.itemComponent:GetJson())
        end
    )

    -- this.exitBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/ExitBtn"):GetComponent("Button")
    -- this.importBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/ImportBtn"):GetComponent("Button")
    -- this.saveBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/SaveBtn"):GetComponent("Button")
    -- this.loadBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/LoadBtn"):GetComponent("Button")

    this.fileSavePop:GetComponent("Button").onClick:AddListener(
        function()
            this.fileSavePop.gameObject:SetActive(false)
        end
    )

    this.exitActionBtn.onClick:AddListener(
        function()
            PopMessageManager.Instance:PushPopup(
                "是否退出地图工坊? Exit map workshop?",
                function(state)
                    if state then
                        this.onExitMode()
                        CSharpAPI.RequestGarageScene()
                    end
                end
            )
        end
    )

    this.importActionBtn.onClick:AddListener(
        function()
            this.shareImportPop.gameObject:SetActive(true)
        end
    )

    this.saveActionBtn.onClick:AddListener(
        function()
            this.fileSavePop.gameObject:SetActive(true)
        end
    )

    this.loadActionBtn.onClick:AddListener(
        function()
            this.fileLoadPop.gameObject:SetActive(true)
        end
    )

    this.saveBtn.onClick:AddListener(
        function()
            local definedName = this.fileNameInput.text
            this.fileSavePop.gameObject:SetActive(false)

            local userDefine = DIYMapSerializationUtil.SerializeCurrentScene(definedName)
            userDefine.season = this.seasonDropdown.value
            UserDIYMapDataManager.Instance:SetDIYUserDefined(userDefine)

            this.refeshFileList()
        end
    )

    this.loadShareBtn.onClick:AddListener(
        function()
            this.shareImportPop.gameObject:SetActive(true)
        end
    )

    this.shareImportCancelBtn.onClick:AddListener(
        function()
            this.shareImportPop.gameObject:SetActive(false)
        end
    )

    this.shareImportBtn.onClick:AddListener(
        function()
            local shareCode = this.shareCodeInput.text
            this.importShareCode(shareCode)
        end
    )

    this.navBtn.onClick:AddListener(
        function()
            this.toggleNav()
        end
    )
    ---------------------摄像机--------------------------
    --- @type Transform
    this.cameraUITransform = root.transform:Find("DIYCreateMapCanvas/CameraAction")
    this.cameraTransform = root.transform:Find("Main Camera").transform
    this.cameraTargetTrans = root.transform:Find("CameraPoint")
    this.mainCamera = this.cameraTransform:GetComponent(typeof(Camera))
    this.cameraController:Init(this.cameraUITransform, this.cameraTransform, this.cameraTargetTrans)
    ------------------------------------------------------

    ---------------------分享码--------------------------
    local findBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/FindBtn"):GetComponent("Button")
    local shareCodeListGo = root.transform:Find("DIYCreateMapCanvas/DIYShareCodeListCanvas").gameObject
    this.shareCodeListController:Init(findBtn, shareCodeListGo)
    ------------------------------------------------------

    ---------------------地图加载页面--------------------------
    this.fileLoadCloseBtn.onClick:AddListener(function()
        this.fileLoadPop.gameObject:SetActive(false)
    end)


    this.refeshFileList()

    this.fileMgr.OnPublishFile:AddListener(function(definedName)
        local userDefine = UserDIYMapDataManager.Instance:GetUserDefine(definedName)
        DIYDataPackageManager.Instance:ExportMapUserDefine(userDefine)
    end)

    this.fileMgr.OnDeleteFile:AddListener(function(definedName)
        -- 删除当前存档
        PopMessageManager.Instance:PushPopup(
            "是否确定删除当前的存档? Delete current saving?",
            function(state)
                if state then
                    UserDIYMapDataManager.Instance:DeleteDIYUserDefined(definedName)
                    this.fileMgr:RemoveFileName(definedName)
                    this.fileMgr:Refresh()
                end
            end
        )
    end)

    this.fileMgr.OnLoadFile:AddListener(function(definedName)
        this.fileLoadPop.gameObject:SetActive(false)
        this.fileNameInput.text = definedName

        -- 清当前场景
        DIYMapSerializationUtil.CleanScene()

        -- 创建新场景
        local userDefine = UserDIYMapDataManager.Instance:GetUserDefine(definedName)
        DIYMapSerializationUtil.DeserializeToCurrentScene(userDefine, false)

        this.seasonDropdown.value = CSharpAPI.EnumToNumber(userDefine.season)
    end)

    this.fileMgr.OnShareFile:AddListener(function(definedName)
        local userDefine = UserDIYMapDataManager.Instance:GetUserDefine(definedName)
        this.exportShareCode(userDefine)
    end)
    ------------------------------------------------------

    this.configMethodGoPool = GameObjectPool()
    this.configMethodGoPool:Init(this.configMethodTemplateGo, 5)
    this.configsMethodList = {}

    --- @type CustomClickHandler
    this.rayHitClick = EntityFactory.AddEntity(CustomClickHandler)
    this.rayHitClick:Init(this.eventTrigger, 1, 5, function(evtData)
        if not GizmoConfig.config.EnablePressSelect then return end
        local ret, viewData = DIYMapItemComponentDragPicker.Instance:GetRayItem(evtData.position)

        if ret then
            if this.itemComponent ~= nil then
                if this.itemComponent == viewData.itemComponent then
                    return
                else
                    this.closeConfig()
                end
            end

            this.selectItemComponent(viewData.itemComponent)
        end
    end, function(state, evtData)
        if not GizmoConfig.config.EnablePressSelect then return end
        if this.itemComponent ~= nil then return end
        this.longPressTipGo:SetActive(state)
    end, function(progress)
        if not GizmoConfig.config.EnablePressSelect then return end
        if this.itemComponent ~= nil then return end
        this.tipFillImg.fillAmount = progress
    end)


    CSharpAPI.SetDIYControlType(eDIYControlType.None)
    CSharpAPI.OnDIYPositionHandleChanged:AddListener(
        function(position)
            if this.itemComponent ~= nil then
                this.itemComponent.transform.position = position
            end
        end
    )

    CSharpAPI.OnDIYEulerAnglesHandleChanged:AddListener(
        function(eulerAngles)
            if this.itemComponent ~= nil then
                this.itemComponent.transform.eulerAngles = eulerAngles
            end
        end
    )

    CSharpAPI.OnDIYScaleHandleChanged:AddListener(
        function(localScale)
            if this.itemComponent ~= nil then
                this.itemComponent.transform.localScale = localScale
            end
        end
    )

    CSharpAPI.OnMapPickItemComponent:AddListener(this.selectItemComponent)
    CSharpAPI.OnMapInstallClicked:AddListener(this.OnMapInstallClicked)
end

this.onUpdate = function()
    if this.isEditMode then
        -- 摄像机更新
        this.cameraController:update()


        -- 意外情况下，Handler 强制更新位置
        if this.itemComponent ~= nil and not this.itemComponent:IsNull() then
            local dis = Vector3.Distance(this.handlerTransform.position, this.itemComponent.transform.position)

            if dis > 0.05 then
                this.updateHandle()
            end
        end
    end
end

this.onExitMode = function()
    this.isEditMode = false

    this.cameraController:onrelease()
    EntityFactory.RemoveEntity(this.rayHitClick)

    CSharpAPI.OnDIYPositionHandleChanged:RemoveAllListeners()
    CSharpAPI.OnDIYEulerAnglesHandleChanged:RemoveAllListeners()
    CSharpAPI.OnDIYScaleHandleChanged:RemoveAllListeners()

    CSharpAPI.OnMapPickItemComponent:RemoveListener(this.selectItemComponent)
    CSharpAPI.OnMapInstallClicked:RemoveListener(this.OnMapInstallClicked)
end

--- @param baseData DIYMapBaseData
this.OnMapInstallClicked = function(baseData)
    --- @type Ray
    local ray = this.mainCamera:ScreenPointToRay(this.dragInfo.position)
    DIYMapCreateUtil.AutoPlaceItem(baseData.itemGUID, ray.origin, ray.direction)
    PopMessageManager.Instance:PushNotice(string.format("放置 %s 成功", baseData.displayName:GetDisplayName()), 1)
end

--- @param itemCompoent DIYMapItemComponent
this.selectItemComponent = function(itemCompoent)
    this.itemComponent = itemCompoent
    this.configProp.gameObject:SetActive(true)
    this.dragInfo.gameObject:SetActive(false)

    this.runtimeInspector:Inspect(this.itemComponent:GetJson())

    if not this.itemComponent:IsNull() then
        this.itemComponent:OnSelect()
    else
        -- 各种意外，导致选择到空物体。比如单例复制。
        return
    end

    local baseData = itemCompoent:GetData()
    this.configPropEquipText.text = baseData.displayName:GetDisplayName()
    this.configPropEquipDescriptionText.text = baseData.description:GetDisplayName()
    this.configPropEquipImg.sprite = baseData.icon

    -- 移动绑定
    this.updateHandle()

    -- 描边
    local reference = this.itemComponent.gameObject:GetComponent(typeof(DIYMapBaseReference))

    for i = 0, reference.renderers.Length - 1 do
        local render = reference.renderers[i]

        if not render:IsNull() then
            local go = render.gameObject
            OutlineHelper.CreateOutlineWithDefaultParams(go, render, Color(1, 0, 0, 1))

            local outline = go:GetComponent(typeof(CS.EPOOutline.Outlinable))
            table.insert(this.outlinableComponents, outline)
        end
    end

    -- 扩展方法
    for k, v in pairs(this.configsMethodList) do
        this.configMethodGoPool:DestroyObject(v)
    end

    this.configsMethodList = {}

    local reflectMethods = this.itemComponent:ReflectMethods()
    local methodDisplayNames = this.itemComponent:ReflectMethodDisplayNames()

    for i = 0, reflectMethods.Length - 1 do
        local go = this.configMethodGoPool:InstantiateObject()
        local txt = go.transform:Find("Text"):GetComponent("Text")
        local btn = go.transform:GetComponent("Button")
        txt.text = methodDisplayNames[i]
        btn.onClick:RemoveAllListeners()
        btn.onClick:AddListener(function()
            itemCompoent:InvokeMethod(i)
        end)
        go:SetActive(true)

        table.insert(this.configsMethodList, go)
    end
end

--- 更新轴位置
this.updateHandle = function()
    CSharpAPI.SetDIYPosition(this.itemComponent.transform.position)
    CSharpAPI.SetDIYEulerAngles(this.itemComponent.transform.eulerAngles)
    CSharpAPI.SetDIYScale(this.itemComponent.transform.localScale)
    this.setHandle(this.controlType)
end

--- 设置轴
this.setHandle = function(controlType)
    this.controlType = controlType

    this.localWorldBtn.gameObject:SetActive(this.isLocalControlHandle)
    this.worldLocalBtn.gameObject:SetActive(not this.isLocalControlHandle)

    if controlType == eDIYControlType.Position then
        if this.isLocalControlHandle then
            CSharpAPI.SetDIYEulerAngles(Vector3.zero)
        else
            CSharpAPI.SetDIYEulerAngles(this.itemComponent.transform.eulerAngles)
        end
    else
        CSharpAPI.SetDIYEulerAngles(this.itemComponent.transform.eulerAngles)
    end

    CSharpAPI.SetDIYControlType(this.controlType)
end

--- 删除当前配置
this.deleteConfig = function()
    PopMessageManager.Instance:PushPopup(
        "是否删除当前物品? Delete Current Item?",
        function(state)
            if state then
                GameObject.Destroy(this.itemComponent.gameObject)
                this.closeConfig()
            end
        end
    )
end

--- 关闭配置
this.closeConfig = function()
    this.deleteOutlines()

    if not this.itemComponent:IsNull() then
        this.itemComponent:OnDeselect()
    end

    this.itemComponent = nil
    this.configProp.gameObject:SetActive(false)
    this.dragInfo.gameObject:SetActive(true)

    CSharpAPI.SetDIYControlType(eDIYControlType.None)
end

this.deleteOutlines = function()
    for k, v in pairs(this.outlinableComponents) do
        GameObject.Destroy(v)
    end

    this.outlinableComponents = {}
end

this.duplicateItem = function(itemComponent, callBack)
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
this.refeshFileList = function()
    this.fileMgr:Clean()

    for k, v in pairs(UserDIYMapDataManager.Instance:GetDIYUserDefines()) do
        this.fileMgr:AddFileName(v.definedName)
    end

    this.fileMgr:Refresh()
end

--- 导出分享码
this.exportShareCode = function(userDefine)
    CSharpAPI.ExportMapShareCode(
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
this.importShareCode = function(shareCode)
    this.downloadMaskGo:SetActive(true)

    CSharpAPI.ImportMapShareCode(
        shareCode,
        function(shareUserDefine)
            if shareUserDefine ~= nil then
                UserDIYMapDataManager.Instance:SetDIYUserDefined(shareUserDefine)
                this.refeshFileList()

                PopMessageManager.Instance:PushPopup(
                    "导入成功。Import Succeed.",
                    function(state)
                    end,
                    false
                )

            end

            this.shareCodeInput.text = ""
            this.downloadMaskGo:SetActive(false)
            this.shareImportPop.gameObject:SetActive(false)
        end
    )
end

--- 切换寻路显示
this.toggleNav = function()
    if this.visualizeMesh ~= nil and not this.visualizeMesh:IsNull() then
        this.removeNav()
    else
        this.visualizeMesh = DIYMapCreateUtil.BuildVisualizeMesh()
    end
end

--- 删除寻路模型
this.removeNav = function()
    GameObject.Destroy(this.visualizeMesh)
end
