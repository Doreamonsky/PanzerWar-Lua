---@class StandardWarController : BaseController
---@field view StandardWarView
StandardWarController = class("StandardWarController", BaseController)

Lib()

local M = StandardWarController

function M:ctor()
    self._mainPlayerVehicle = nil
end

function M:AddListeners()
    -- C#
    self.onPickMainPlayerVehicle = handler(self, self.OnPickMainPlayerVehicle)
    ModeAPI.RegisterPickVehicleCallBack(self.onPickMainPlayerVehicle)
    -- Lua
    self.view.vPickVehicle.onClick:AddListener(handler(self, self.OnPickVehicleClicked))
    self.view.vBattle.onClick:AddListener(handler(self, self.OnBattleClicked))
    EventSystem.AddListener(EventDefine.OnPickBarVisibilityChanged, self.OnPickBarChanged, self)
    EventSystem.AddListener(EventDefine.OnVehicleUseQueueNumberChanged, self.OnVehicleUseQueueNumberChanged, self)
end

function M:RemoveListener()
    -- C#
    ModeAPI.UnRegisterPickVehicleCallBack(self.onPickMainPlayerVehicle)
    -- Lua
    self.view.vPickVehicle.onClick:RemoveAllListeners()
    self.view.vBattle.onClick:RemoveAllListeners()
    EventSystem.RemoveListener(EventDefine.OnPickBarVisibilityChanged, self.OnPickBarChanged, self)
    EventSystem.RemoveListener(EventDefine.OnVehicleUseQueueNumberChanged, self.OnVehicleUseQueueNumberChanged, self)
end

function M:Awake()
    ---@type Frontend.Runtime.Battle.Mode.StandardWarNetGameMode
    self._mode = ModeAPI.GetNativeMode()
    self:OnPickBarChanged(not self._mode:IsMainPlayerLoaded())
    self:PickMainPlayerVehicle(self._mode:GetPlayerVehicleQueue()[0])
    self:AddListeners()
end

function M:Destroy()
    self:RemoveListener()
end

function M:OnPickVehicleClicked()
    ModeAPI.ShowPickVehicleUIWithList(true, self._mode:GetPlayerVehicleQueue())
end

function M:OnBattleClicked()
    if self._mainPlayerVehicle ~= nil then
        self._mode:PickVehicle(self._mainPlayerVehicle:GetLoadGUID())
    end
end

function M:OnPickBarChanged(isActive)
    GameObjectAPI.SetActive(self.view.vVehiclePickBar, isActive)
end

function M:OnVehicleUseQueueNumberChanged()
    self:PickMainPlayerVehicle(self._mainPlayerVehicle)
end

function M:OnPickMainPlayerVehicle(evtData)
    self:PickMainPlayerVehicle(evtData.VehicleInfo)
end

---@param vehicleInfo ShanghaiWindy.Core.VehicleInfo
function M:PickMainPlayerVehicle(vehicleInfo)
    self._mainPlayerVehicle = vehicleInfo

    self.view.vVehicleName.text = vehicleInfo:GetDisplayName()
    self.view.vVehicleRank.text = vehicleInfo:GetRank()
    VehicleAPI.LoadVehicleThumbnail(vehicleInfo, function(thumbnail)
        self.view.vVehicleThumbnail.sprite = thumbnail
    end)

    local isLock = self._mode:GetVehicleUsedNumber(self._mainPlayerVehicle:GetLoadGUID()) <= 0
    GameObjectAPI.SetActive(self.view.vUnuseMask, isLock)
end

return M
