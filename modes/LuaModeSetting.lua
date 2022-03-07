LuaModeSetting = {}

local this = LuaModeSetting

this.onStartMode = function()
    CSharpAPI.LoadAssetBundle(
        "LuaModeConfigCanvas",
        "mod",
        function(asset)
            if asset ~= nil then
                this.uiObject = GameObject.Instantiate(asset)
                this.bindUI(this.uiObject.transform)
            end
        end
    )
end

this.bindUI = function(root)
    this.confirmBtn = root:Find("LuaModeConfig/Bar/Title/ConfirmBtn"):GetComponent("Button")
    this.multiTurretToggle = root:Find("LuaModeConfig/Bar/Content/EnableMultiTurret/Toggle"):GetComponent("Toggle")

    this.confirmBtn.onClick:AddListener(
        function()
            LuaModeConfig.saveConfig()
            CSharpAPI.OnLuaExitModeReq:Invoke()
            GameObject.Destroy(this.uiObject)
        end
    )

    this.multiTurretToggle.onValueChanged:AddListener(
        function(val)
            LuaModeConfig.config.MultiTurretGUI = val
        end
    )
end

this.onExitMode = function()
end

return this
