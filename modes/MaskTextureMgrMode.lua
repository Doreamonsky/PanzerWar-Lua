--- 反光贴图全局管理模式

MaskTextureMgrMode = {}

MaskTextureMgrMode.init = function()
end

MaskTextureMgrMode.onStartMode = function()
    MaskTextureMgrMode.init()

    CSharpAPI.LoadAssetBundle(
        "MaskTexMgrCanvas",
        "mod",
        function(asset)
            if asset ~= nil then
                local uiObject = GameObject.Instantiate(asset)
                local template = uiObject.transform:Find("Panel/Scroll View/Viewport/Content/Template")
                local maskTexs = MaskTextureManager.Instance:GetMaskTextureList()

                template.gameObject:SetActive(false)

                for i = 0, maskTexs.Count - 1 do
                    local maskTex = maskTexs[i]
                    local instance = GameObject.Instantiate(template, template.transform.parent, true)
                    instance.transform:Find("Text"):GetComponent("Text").text = maskTex.maskDisplayName:GetDisplayName()
                    instance.transform:Find("Thumbnail"):GetComponent("RawImage").texture = maskTex.maskTexture
                    instance:GetComponent("Button").onClick:AddListener(
                        function()
                            local vehicleInfos = VehicleInfoManager.Instance:GetAllDriveableVehicleList(true)

                            for i = 0, vehicleInfos.Count - 1 do
                                local vehicleCamoData =
                                AchievementManager.Instance:GetVehicleCamoData(vehicleInfos[i]:GetVehicleName())
                                vehicleCamoData.maskTexGuid = maskTex.guid
                            end

                            AchievementManager.Instance:SaveVehicleData()
                            PopMessageManager.Instance:PushNotice(
                                "更新反光贴图至:" .. maskTex.maskDisplayName:GetDisplayName() .. "，重新选择战车生效。"
                                ,
                                2
                            )
                        end
                    )
                    instance.gameObject:SetActive(true)
                end

                uiObject.transform:Find("Panel/Close"):GetComponent("Button").onClick:AddListener(
                    function()
                        CSharpAPI.OnLuaExitModeReq:Invoke()
                        GameObject.Destroy(uiObject)

                        PopMessageManager.Instance:PushNotice("重新选择战车生效反光贴图。", 5)
                    end
                )
            end
        end
    )
end

MaskTextureMgrMode.onExitMode = function()
end
