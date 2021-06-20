MultiTurretGUI = {}

MultiTurretGUI.tankFireDict = {}

MultiTurretGUI.onStarted = function()
    MultiTurretGUI.bindEvent()
    GameEventManager.OnResetAction:AddListener(
        function()
            MultiTurretGUI.bindEvent()
        end
    )
end

MultiTurretGUI.bindEvent = function()
    GameEventManager.OnNewVehicleSpawned:AddListener(
        function(vehicle)
            if CSharpAPI.isLocalPlayer(vehicle) then
                MultiTurretGUI.tankFireDict = {}

                local vehicleComponet = vehicle.vehicleComponents
                local tankfireList = vehicleComponet.tankfireList
                -- 若发射器大于1个，才需要创建多发射器管理
                if tankfireList.Count > 1 then
                    -- 请求 AssetBundle 资源
                    CSharpAPI.LoadAssetBundle(
                        "multifirecanvas",
                        "mod",
                        function(asset)
                            local ui_instance = CS.UnityEngine.GameObject.Instantiate(asset)
                            local template = ui_instance.transform:Find("Panel/Template").gameObject

                            -- 遍历 TankFire 绑定按钮
                            for index, tankFire in pairs(tankfireList) do
                                local i = index
                                local instance =
                                    CS.UnityEngine.GameObject.Instantiate(template, template.transform.parent, true)

                                instance:GetComponent("Button").onClick:AddListener(
                                    function(...)
                                        tankfireList[i]:Fire()
                                    end
                                )

                                local text = instance.transform:Find("Text"):GetComponent(typeof(Text))
                                text.text = tostring(i)

                                local img = instance:GetComponent(typeof(Image))
                                local data = {
                                    imgComponent = img,
                                    tankFireComponet = tankFire
                                }

                                table.insert(MultiTurretGUI.tankFireDict, data)
                            end

                            template:SetActive(false)

                            vehicle.OnGameObjectDestroyed:AddListener(
                                function(...)
                                    MultiTurretGUI.tankFireDict = {}
                                    Destroy(ui_instance)
                                end
                            )
                        end
                    )
                end
            end
        end
    )
end

MultiTurretGUI.onUpdated = function()
    for key, val in pairs(MultiTurretGUI.tankFireDict) do
        local fillAmount = val.tankFireComponet:GetReloadPercentage()
        val.imgComponent.fillAmount = fillAmount
    end
end
