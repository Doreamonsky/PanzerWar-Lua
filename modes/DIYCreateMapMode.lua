require "modes.Common.CustomClickHandler"
require "modes.Common.CameraController"

DIYCreateMapMode = {}

local this = DIYCreateMapMode
this.onStartMode = function()
    this.isEditMode = true
    this.controlType = eDIYControlType.Position
    this.cameraController = CameraController.new()
    this.outlinableComponents = {}

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
    --- @type RuntimeInspector
    this.runtimeInspector = this.configContent:Find("Property/RuntimeInspector"):GetComponent(typeof(RuntimeInspector))

    this.noneBtn = root.transform:Find("DIYCreateMapCanvas/ConfigProp/TransformHandle/NoneBtn"):GetComponent("Button")
    this.moveBtn = root.transform:Find("DIYCreateMapCanvas/ConfigProp/TransformHandle/MoveBtn"):GetComponent("Button")
    this.rotateBtn = root.transform:Find("DIYCreateMapCanvas/ConfigProp/TransformHandle/RotateBtn"):GetComponent("Button")
    this.scaleBtn = root.transform:Find("DIYCreateMapCanvas/ConfigProp/TransformHandle/ScaleBtn"):GetComponent("Button")

    this.exitActionBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/ExitBtn"):GetComponent("Button")
    this.importActionBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/ImportBtn"):GetComponent("Button")
    this.saveActionBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/SaveBtn"):GetComponent("Button")
    this.loadActionBtn = root.transform:Find("DIYCreateMapCanvas/ToolAction/LoadBtn"):GetComponent("Button")

    this.fileSavePop = root.transform:Find("DIYCreateMapCanvas/FileSavePop")
    this.fileNameInput = this.fileSavePop.transform:Find("FileNameInput"):GetComponent("InputField")
    this.saveBtn = this.fileSavePop.transform:Find("SaveBtn"):GetComponent("Button")
    this.fileLoadCloseBtn = root.transform:Find("DIYCreateMapCanvas/FileLoadPop/Title/CloseBtn"):GetComponent("Button")

    this.longPressTipGo = root.transform:Find("DIYCreateMapCanvas/LongPressTip").gameObject
    this.tipFillImg = this.longPressTipGo.transform:Find("Fill"):GetComponent("Image")

    this.eventTrigger = root.transform:Find("DIYCreateMapCanvas/TouchBar"):GetComponent(typeof(EventTrigger))

    ---------------------Bind--------------------------
    this.configDeleteBtn.onClick:AddListener(
        function()
            this.deleteConfig()
        end
    )

    this.noneBtn.onClick:AddListener(
        function()
            this.controlType = eDIYControlType.None
            CSharpAPI.SetDIYControlType(this.controlType)
        end
    )

    this.moveBtn.onClick:AddListener(
        function()
            this.controlType = eDIYControlType.Position
            CSharpAPI.SetDIYControlType(this.controlType)
        end
    )

    this.rotateBtn.onClick:AddListener(
        function()
            this.controlType = eDIYControlType.EulerAngles
            CSharpAPI.SetDIYControlType(this.controlType)
        end
    )

    this.scaleBtn.onClick:AddListener(
        function()
            this.controlType = eDIYControlType.Scale
            CSharpAPI.SetDIYControlType(this.controlType)
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
                        CSharpAPI.RequestScene(
                            "Garage",
                            function()
                            end
                        )
                    end
                end
            )
        end
    )

    this.importActionBtn.onClick:AddListener(
        function()
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
            UserDIYMapDataManager.Instance:SetDIYUserDefined(userDefine)

            this.refeshFileList()
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

    ---------------------地图加载页面--------------------------
    this.fileLoadCloseBtn.onClick:AddListener(function()
        this.fileLoadPop.gameObject:SetActive(false)
    end)

    this.refeshFileList()

    this.fileMgr.OnDeleteFile:AddListener(function(definedName)
        -- 删除当前存档
        UserDIYMapDataManager.Instance:DeleteDIYUserDefined(definedName)
        this.fileMgr:RemoveFileName(definedName)
        this.fileMgr:Refresh()
    end)

    this.fileMgr.OnLoadFile:AddListener(function(definedName)
        this.fileLoadPop.gameObject:SetActive(false)
        this.fileNameInput.text = definedName

        -- 清当前场景
        DIYMapSerializationUtil.CleanScene()

        -- 创建新场景
        local userDefine = UserDIYMapDataManager.Instance:GetUserDefine(definedName)
        DIYMapSerializationUtil.DeserializeToCurrentScene(userDefine, false)
    end)

    this.fileMgr.OnShareFile:AddListener(function(definedName)
    end)
    ------------------------------------------------------

    this.configMethodGoPool = GameObjectPool()
    this.configMethodGoPool:Init(this.configMethodTemplateGo, 5)
    this.configsMethodList = {}

    this.rayHitClick = CustomClickHandler.new()
    this.rayHitClick:Init(this.eventTrigger, 1, 5, function(evtData)
        local ret, viewData = DIYMapItemComponentDragPicker.Instance:GetRayItem(evtData.position)

        if ret then
            this.selectItemComponent(viewData.itemComponent)
        end
    end, function(state, evtData)
        this.tipFillImg.fillAmount = 0
        this.longPressTipGo:SetActive(state)
    end, function(pressTime)
        if pressTime > 0.2 then
            this.tipFillImg.fillAmount = pressTime
        end
    end)

    EntityManager.AddEntity(this.rayHitClick)

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
        this.cameraController:update()
    end
end

this.onExitMode = function()
    this.isEditMode = false

    this.cameraController:onrelease()
    EntityManager.RemoveEntity(this.rayHitClick)

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
end

--- @param itemCompoent DIYMapItemComponent
this.selectItemComponent = function(itemCompoent)
    this.itemComponent = itemCompoent
    this.configProp.gameObject:SetActive(true)
    this.dragInfo.gameObject:SetActive(false)

    this.runtimeInspector:Inspect(this.itemComponent:GetJson())

    local baseData = itemCompoent:GetData()
    this.configPropEquipText.text = baseData.displayName:GetDisplayName()
    this.configPropEquipDescriptionText.text = baseData.description:GetDisplayName()
    this.configPropEquipImg.sprite = baseData.icon

    -- 移动绑定
    CSharpAPI.SetDIYControlType(this.controlType)
    CSharpAPI.SetDIYPosition(this.itemComponent.transform.position)
    CSharpAPI.SetDIYEulerAngles(this.itemComponent.transform.eulerAngles)
    CSharpAPI.SetDIYScale(this.itemComponent.transform.localScale)

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

--- 删除当前配置
this.deleteConfig = function()
    GameObject.Destroy(this.itemComponent.gameObject)
    this.closeConfig()
end

--- 关闭配置
this.closeConfig = function()
    this.deleteOutlines()

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
    itemComponent:ApplyPosition()

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
