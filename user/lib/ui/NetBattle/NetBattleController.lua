---@class NetBattleController : BaseController
---@field view NetBattleView
NetBattleController = class("NetBattleController", BaseController)

Lib()

local M = NetBattleController

function M:ctor()
    ---@type Frontend.Runtime.Battle.AbstractNetBattleGameMode
    self._mode = nil
end

function M:Awake()
    self._mode = ModeAPI.GetNativeMode()
    GameObjectAPI.SetActive(self.view.vChatSenderBar, false)
    GameObjectAPI.SetActive(self.view.vOpenChatSender.gameObject, false)
    GameObjectAPI.SetActive(self.view.vChatTemplateMessage, false)
    self:ToggleChatSender(false)
    self:AddListeners()
end

function M:Destroy()
    self:RemoveListener()
end

function M:AddListeners()
    -- C#
    self.onQuarterTick = handler(self, self.OnQuarterTick)
    TimeAPI.RegisterQuarterTick(self.onQuarterTick)

    -- Lua
    self.view.vOpenChatSender.onClick:AddListener(handler(self, self.OnOpenChatSenderClicked))
    self.view.vCloseChatSenderBar.onClick:AddListener(handler(self, self.OnCloseChatSenderBarClicked))
end

function M:RemoveListener()
    TimeAPI.UnRegisterQuarterTick(self.onQuarterTick)
    self.view.vOpenChatSender.onClick:RemoveAllListeners()
    self.view.vCloseChatSenderBar.onClick:RemoveAllListeners()
end

function M:OnQuarterTick()
    self.view.vPing.text = self._mode:GetPing()
end

function M:OnOpenChatSenderClicked()
    GameObjectAPI.SetActive(self.view.vChatSenderBar, true)
end

function M:OnCloseChatSenderBarClicked()
    GameObjectAPI.SetActive(self.view.vChatSenderBar, false)
end

function M:ToggleChatSender(state)
    GameObjectAPI.SetActive(self.view.vChatSenderBar, state)
end

return M
