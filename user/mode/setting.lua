local LuaModeSetting = class("LuaModeSetting")

GameMode()

function LuaModeSetting:ctor()
    self.modName = "Lua 设置"
    self.author = "超级哆啦酱"
    self.description = "Lua 设置"
end

function LuaModeSetting:GetGameModeName(userLang)
    if userLang == "EN" then
        return "Lua Mode Setting"
    else
        return "Lua 模式设置"
    end
end

function LuaModeSetting:OnStartMode()
    CSharpAPI.LoadAssetBundle(
        "LuaModeConfigCanvas",
        "mod",
        function(asset)
            if asset ~= nil then
                self.uiObject = GameObject.Instantiate(asset)
                self:InitUI(self.uiObject.transform)
            end
        end
    )
end

function LuaModeSetting:InitUI(root)
    self.confirmBtn = root:Find("LuaModeConfig/Bar/Title/ConfirmBtn"):GetComponent("Button")
    self.multiTurretToggle = root:Find("LuaModeConfig/Bar/Content/EnableMultiTurret/Toggle"):GetComponent("Toggle")

    self.confirmBtn.onClick:AddListener(
        function()
            LuaModeConfig.saveConfig()
            CSharpAPI.OnLuaExitModeReq:Invoke()
            GameObject.Destroy(self.uiObject)
        end
    )

    self.multiTurretToggle.onValueChanged:AddListener(
        function(val)
            LuaModeConfig.config.MultiTurretGUI = val
        end
    )
end

function LuaModeSetting:OnExitMode()
end

return LuaModeSetting