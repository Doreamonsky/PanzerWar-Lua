---@class NetBattleController : BaseController
---@field view NetBattleView
NetBattleController = class("NetBattleController", BaseController)

Lib()

local M = NetBattleController
local POP_TEXT_MIN_SCALE = 0.5
local POP_TEXT_MAX_SCALE = 1.0
local POP_TEXT_MIN_DIS = 5
local POP_TEXT_MAX_DIS = 50

function M:ctor()
    ---@type Frontend.Runtime.Impl.GameImpl.Battle.AbstractNetBattleGameMode
    self._mode = nil
    self._chatMessageList = {}
    self._chatPopTextList = {}
end

function M:Awake()
    self._mode = ModeAPI.GetNativeMode()
    self._chatPool = UIAPI.GetUIPool(self.view.vChatMessageTemplate)
    self._chatPopPool = UIAPI.GetUIPool(self.view.vTextPopTemplate)

    GameObjectAPI.SetActive(self.view.vChatSenderBar, false)
    GameObjectAPI.SetActive(self.view.vChatMessageTemplate, false)
    self:ToggleChatSender(false)
    self:AddListeners()
end

function M:Destroy()
    self:RemoveListener()
    self._chatPool:Dispose()
    self._chatPopPool:Dispose()
end

function M:AddListeners()
    -- C#
    self.onQuarterTick = handler(self, self.OnQuarterTick)
    TimeAPI.RegisterQuarterTick(self.onQuarterTick)

    self.onLateTick = handler(self, self.OnLateTick)
    TimeAPI.RegisterLateFrameTick(self.onLateTick)

    -- Lua
    self.view.vSendChat.onClick:AddListener(handler(self, self.OnSendChatClicked))
    self.view.vOpenChatSender.onClick:AddListener(handler(self, self.OnOpenChatSenderClicked))
    self.view.vCloseChatSenderBar.onClick:AddListener(handler(self, self.OnCloseChatSenderBarClicked))
    EventSystem.AddListener(EventDefine.OnChat, self.OnChat, self)
    EventSystem.AddListener(EventDefine.OnPopText, self.OnPopText, self)
end

function M:RemoveListener()
    -- C#
    TimeAPI.UnRegisterQuarterTick(self.onQuarterTick)
    TimeAPI.UnRegisterLateFrameTick(self.onLateTick)

    -- Lua
    self.view.vSendChat.onClick:RemoveAllListeners()
    self.view.vOpenChatSender.onClick:RemoveAllListeners()
    self.view.vCloseChatSenderBar.onClick:RemoveAllListeners()
    EventSystem.RemoveListener(EventDefine.OnChat, self.OnChat, self)
    EventSystem.RemoveListener(EventDefine.OnPopText, self.OnPopText, self)
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

function M:OnLateTick(deltaTime)
    local currentTime = TimeAPI.GetTime()

    -- Refresh the pop text to screen position
    for i = #self._chatPopTextList, 1, -1 do
        local popInfo = self._chatPopTextList[i]
        if currentTime - popInfo.time > 5 then
            self._chatPopPool:Release(popInfo.go)
            table.remove(self._chatPopTextList, i)
        else
            local screenPos = CameraAPI.WorldToScreenPoint(CameraAPI.GetGameCamera(), popInfo.worldPos)
            local dis = Vector3.Distance(popInfo.worldPos, self._mode:GetPlayerPosition())

            local scaleFactor

            if dis <= POP_TEXT_MIN_DIS then
                scaleFactor = POP_TEXT_MAX_SCALE
            elseif dis >= POP_TEXT_MAX_DIS then
                scaleFactor = POP_TEXT_MIN_SCALE
            else
                scaleFactor = POP_TEXT_MIN_SCALE +
                    (POP_TEXT_MAX_SCALE - POP_TEXT_MIN_SCALE) *
                    ((POP_TEXT_MAX_DIS - dis) / (POP_TEXT_MAX_DIS - POP_TEXT_MIN_DIS))
            end

            if screenPos.z < 0 then
                popInfo.go.transform.position = Vector3(0, 9999, 0)
            else
                popInfo.go.transform.position = Vector3(screenPos.x, screenPos.y, 0)
                popInfo.go.transform.localScale = Vector3(scaleFactor, scaleFactor, scaleFactor)
            end
        end
    end
end

function M:OnOpenChatSenderClicked()
    GameObjectAPI.SetActive(self.view.vChatSenderBar, true)
end

function M:OnCloseChatSenderBarClicked()
    GameObjectAPI.SetActive(self.view.vChatSenderBar, false)
end

--- Add the top chat
function M:OnChat(message)
    local instance = self._chatPool:Get(false)
    local text = instance:GetComponent("Text")
    text.text = message

    table.insert(self._chatMessageList, {
        go = instance,
        time = TimeAPI.GetTime()
    })
end

--- Add the pop text chat
function M:OnPopText(message, position)
    local instance = self._chatPopPool:Get(false)
    local text = instance.transform:Find("Text"):GetComponent("Text")
    text.text = message

    table.insert(self._chatPopTextList, {
        go = instance,
        time = TimeAPI.GetTime(),
        worldPos = position
    })

    if Vector3.Distance(position, self._mode:GetPlayerPosition()) < 20 then
        self:OnChat(message)
    end
end

function M:ToggleChatSender(state)
    GameObjectAPI.SetActive(self.view.vChatSenderBar, state)
end

return M
