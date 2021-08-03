--- 蓝图测试载具加载
BlueprintVehicles = {}
BlueprintVehicles.onStarted = function()
    local blueprints = {
        [0] = "nameless-t-30",
        [1] = "nameless-stb-1",
        [2] = "nameless-char-future-4"
    }

    -- 暂时只有 Android 支持蓝图载具测试
    -- 请求 AssetBundle 资源
    for index, uid in pairs(blueprints) do
        CSharpAPI.LoadAssetBundle(
            uid,
            "vehicleinfo",
            function(asset)
                print("request loading:" .. uid)
                if asset ~= nil then
                    local vehicleInfo = GameObject.Instantiate(asset)
                    vehicleInfo.isExtraFile = true

                    -- 卸载已加载的载具描述文件
                    for k, v in pairs(AssetBundleManager.LoadedAssets) do
                        if k == uid .. ".vehicleinfo" then
                            v.loadedAB:Unload(false)
                        end
                    end

                    VehicleInfoManager.Instance:AddVehicle(vehicleInfo)
                end
            end
        )
    end
end
