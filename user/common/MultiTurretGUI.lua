---@class MultiTurretGUI
local MultiTurretGUI = class("MultiTurretGUI")
local M = MultiTurretGUI

Common()

-- 构造函数 (Constructor)
function M:ctor()
    self.tankfireList = {}
    self.tankFireDataDict = {}
end

function M:OnStarted()
    self.onVehicleLoaded = handler(self, self.OnVehicleLoaded)
    self:AddListeners()
end

function M:OnDispose()
    self:RemoveListener()
end

function M:AddListeners()
    GameAPI.RegisterVehicleLoadedEvent(self.onVehicleLoaded)
end

function M:RemoveListener()
    GameAPI.UnRegisterVehicleLoadedEvent(self.onVehicleLoaded)
end

function M:OnVehicleLoaded(vehicle)
    -- 判断是否开启多炮塔GUI (Check if MGUI is enabled)
    if not LuaModeConfig.config.MGUI then
        return
    end

    -- 判断是否是本地玩家 (Check if it's the local player)
    if CSharpAPI.isLocalPlayer(vehicle) then
        local ret = VehicleAPI.IsTankVehicle(vehicle)

        if ret then
            self.vehicle = vehicle
            self.tankFireDataDict = {}

            -- 获取炮塔列表 (Get turret list)
            self.tankfireList = TankAPI.GetTankFireList(vehicle)

            -- 如果炮塔数量大于1个，才需要创建多炮塔管理 (Create multi-turret management only if there are more than one turret)
            if self.tankfireList.Count > 1 then
                -- 请求 AssetBundle 资源 (Request AssetBundle resource)
                AssetAPI.LoadAssetBundle(
                    "multifirecanvas",
                    "mod",
                    function(asset)
                        self:OnAssetLoaded(asset)
                    end
                )
            end
        end
    end
end

-- 资源加载后的处理 (Process after resource is loaded)
function M:OnAssetLoaded(asset)
    if asset ~= nil then
        local ui_instance = GameObject.Instantiate(asset)
        local template = ui_instance.transform:Find("Panel/Template").gameObject

        -- 遍历 TankFire 绑定按钮 (Bind buttons for each TankFire)
        for index, tankFire in pairs(self.tankfireList) do
            local i = index
            local instance =
                GameObject.Instantiate(template, template.transform.parent, true)

            instance:GetComponent("Button").onClick:AddListener(
                function()
                    self.tankfireList[i]:Fire()
                end
            )

            local text = instance.transform:Find("Text"):GetComponent(typeof(Text))
            text.text = tostring(i)

            local img = instance:GetComponent(typeof(Image))
            local data = {
                imgComponent = img,
                tankFireComponet = tankFire
            }

            table.insert(self.tankFireDataDict, data)
        end

        -- 创建一个用于开火所有炮塔的按钮 (Create a button for firing all turrets)
        local instance = GameObject.Instantiate(template, template.transform.parent, true)

        instance:GetComponent("Button").onClick:AddListener(
            function()
                for k, v in pairs(self.tankfireList) do
                    self.tankfireList[k]:Fire()
                end
            end
        )
        instance.transform:Find("Text"):GetComponent(typeof(Text)).text = "All"
        instance:GetComponent(typeof(Image)).fillAmount = 0

        template:SetActive(false)

        VehicleAPI.RegisterVehicleGameObjectDestroyedEvent(self.vehicle, function()
            self.tankFireDataDict = {}
            GameObject.Destroy(ui_instance)
        end)
    end
end

-- 更新函数 (Update function)
function M:OnUpdated()
    if not LuaModeConfig.config.MGUI then
        return
    end

    -- 更新每个炮塔的 UI 填充 (Update the fill of UI for each turret)
    for key, val in pairs(self.tankFireDataDict) do
        local fillAmount = val.tankFireComponet:GetReloadPercentage()
        val.imgComponent.fillAmount = fillAmount
    end
end

return M