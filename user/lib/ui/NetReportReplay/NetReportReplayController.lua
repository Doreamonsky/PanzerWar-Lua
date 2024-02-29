---@class NetReportReplayController : BaseController
---@field view NetReportReplayView
NetReportReplayController = class("NetReportReplayController", BaseController)

Lib()

local M = NetReportReplayController

function M:ctor()

end

function M:Awake()
    ---@type Frontend.Runtime.Impl.GameImpl.Battle.Mode.ReplayNetGameMode
    self._mode = ModeAPI.GetNativeMode()
    self.view.vNickName.text = self._mode:GetReportedPlayerNickName()
    GameObjectAPI.SetActive(self.view.vBan.gameObject, self._mode:IsShowBan())
    
    self:AddListeners()
end

function M:Destroy()
    self:RemoveListener()
end

function M:AddListeners()
    -- Lua
    self.view.vAgreeBan.onClick:AddListener(handler(self, self.OnAgreeBanClicked))
    self.view.vDisagreeBan.onClick:AddListener(handler(self, self.OnDisagreeBanClicked))
    self.view.vBan.onClick:AddListener(handler(self, self.OnBanClicked))
end

function M:RemoveListener()
    -- Lua
    self.view.vAgreeBan.onClick:RemoveAllListeners()
    self.view.vDisagreeBan.onClick:RemoveAllListeners()
    self.view.vBan.onClick:RemoveAllListeners()
end

function M:OnAgreeBanClicked()
    UIAPI.ShowPopup(UIAPI.GetLocalizedContent("AgreeBan"), true, function(res)
        if res then
            self._mode:AgreeBan()
        end
    end)
end

function M:OnDisagreeBanClicked()
    UIAPI.ShowPopup(UIAPI.GetLocalizedContent("DisagreeBan"), true, function(res)
        if res then
            self._mode:DisagreeBan()
        end
    end)
end

function M:OnBanClicked()
    UIAPI.ShowPopup(UIAPI.GetLocalizedContent("BanPlayer"), true, function(res)
        if res then
            self._mode:Ban()
        end
    end)
end
