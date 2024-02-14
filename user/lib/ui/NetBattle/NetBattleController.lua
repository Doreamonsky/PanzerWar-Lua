---@class NetBattleController : BaseController
---@field view NetBattleView
NetBattleController = class("NetBattleController", BaseController)

Lib()

local M = NetBattleController

function M:ctor()
    ---@type Frontend.Runtime.Battle.AbstractNetBattleGameMode
    self._mode = nil
    self._chatMessageList = {}
end

function M:Awake()
    self._mode = ModeAPI.GetNativeMode()
    self._chatPool = UIAPI.GetUIPool(self.view.vChatTemplateMessage)

    GameObjectAPI.SetActive(self.view.vChatSenderBar, false)
    GameObjectAPI.SetActive(self.view.vChatTemplateMessage, false)
    self:ToggleChatSender(false)
    self:AddListeners()
end

function M:Destroy()
    self:RemoveListener()
    self._chatPool:Dispose()
end

function M:AddListeners()
    -- C#
    self.onQuarterTick = handler(self, self.OnQuarterTick)
    TimeAPI.RegisterQuarterTick(self.onQuarterTick)

    -- Lua
    self.view.vSendChat.onClick:AddListener(handler(self, self.OnSendChatClicked))
    self.view.vOpenChatSender.onClick:AddListener(handler(self, self.OnOpenChatSenderClicked))
    self.view.vCloseChatSenderBar.onClick:AddListener(handler(self, self.OnCloseChatSenderBarClicked))
    EventSystem.AddListener(EventDefine.OnChat, self.OnChat, self)
end

function M:RemoveListener()
    -- C#
    TimeAPI.UnRegisterQuarterTick(self.onQuarterTick)

    -- Lua
    self.view.vSendChat.onClick:RemoveAllListeners()
    self.view.vOpenChatSender.onClick:RemoveAllListeners()
    self.view.vCloseChatSenderBar.onClick:RemoveAllListeners()
    EventSystem.RemoveListener(EventDefine.OnChat, self.OnChat, self)
end

function M:OnSendChatClicked()
    if self.view.vChatTargetType.value == 0 then
        self._mode:SendTeammateTextMessage(self.view.vSenderContent.text)
    elseif self.view.vChatTargetType.value == 1 then
        self._mode:SendAllTextMessage(self.view.vSenderContent.text)
    end

    self.view.vSenderContent.text = ""
    GameObjectAPI.SetActive(self.view.vChatSenderBar, false)
end

function M:OnQuarterTick(deltaTime)
    self.view.vPing.text = self._mode:GetPing()

    local currentTime = TimeAPI.GetTime()
    for i = #self._chatMessageList, 1, -1 do
        local messageInfo = self._chatMessageList[i]
        if currentTime - messageInfo.time > 5 or i > 3 then
            self._chatPool:Release(messageInfo.go)
            table.remove(self._chatMessageList, i)
        end
    end
end

function M:OnOpenChatSenderClicked()
    GameObjectAPI.SetActive(self.view.vChatSenderBar, true)
end

function M:OnCloseChatSenderBarClicked()
    GameObjectAPI.SetActive(self.view.vChatSenderBar, false)
end

function M:OnChat(message)
    local instance = self._chatPool:Get(false)
    local text = instance:GetComponent("Text")
    text.text = message

    table.insert(self._chatMessageList, {
        go = instance,
        time = TimeAPI.GetTime()
    })
end

function M:ToggleChatSender(state)
    GameObjectAPI.SetActive(self.view.vChatSenderBar, state)
end

return M
