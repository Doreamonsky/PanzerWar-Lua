require "modes.Common.CameraController"

DIYCreateMapMode = {}

local this = DIYCreateMapMode
this.onStartMode = function()
    this.isEditMode = true
    this.controlType = eDIYControlType.None
    this.cameraController = CameraController.new()

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
    this.dragInfo = root.transform:Find("DIYCreateMapCanvas/DragInfo")

    this.configProp = root.transform:Find("DIYCreateMapCanvas/ConfigProp")
    this.configComfirmBtn = this.configProp:Find("Title/ConfirmBtn"):GetComponent("Button")
    this.configDeleteBtn = this.configProp:Find("Title/DeleteBtn"):GetComponent("Button")
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

    ---------------------Bind--------------------------
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
            local instance = GameObject.Instantiate(this.itemComponent.gameObject)
            this.selectItemComponent(instance:GetComponent(typeof(DIYMapItemComponent)))
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
        end
    )

    this.saveBtn.onClick:AddListener(
        function()
            local definedName = this.fileNameInput.text
            local userDefine = DIYMapSerializationUtil.SerializeCurrentScene(definedName)
            UserDIYMapDataManager.Instance:SetDIYUserDefined(userDefine)
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

this.onExitMode = function()
    this.isEditMode = false

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

    this.runtimeInspector:Inspect(this.itemComponent)

    local baseData = itemCompoent:GetData()
    this.configPropEquipText.text = baseData.displayName:GetDisplayName()
    this.configPropEquipDescriptionText.text = baseData.description:GetDisplayName()
    this.configPropEquipImg.sprite = baseData.icon

    CSharpAPI.SetDIYControlType(this.controlType)
    CSharpAPI.SetDIYPosition(this.itemComponent.transform.position)
    CSharpAPI.SetDIYEulerAngles(this.itemComponent.transform.eulerAngles)
    CSharpAPI.SetDIYScale(this.itemComponent.transform.localScale)
end

this.closeConfig = function()
    this.itemComponent = nil
    this.configProp.gameObject:SetActive(false)
    this.dragInfo.gameObject:SetActive(true)

    CSharpAPI.SetDIYControlType(eDIYControlType.None)
end
