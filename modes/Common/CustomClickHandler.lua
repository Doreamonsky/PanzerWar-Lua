-- 自定义点击，长按处理
CustomClickHandler = class("CustomClickHandler", Entity)

function CustomClickHandler:awake()
    self.lastPointerDownTime = 0
    self.pressTime = 0
    self.isPointerIn = false

    --- @type fun()
    --- Pointer 持续触发时每帧回调
    self.updateCallBack = nil
end

function CustomClickHandler:update()
    if self.updateCallBack ~= nil then
        self.pressTime = self.pressTime + Time.deltaTime
        self.updateCallBack(self.pressTime)
    end
end

function CustomClickHandler:dispose()
    self.lastPointerDownTime = nil
    self.pressTime = nil
    self.isPointerIn = nil
    self.updateCallBack = nil
end

--- @param eventTrigger EventTrigger
--- @param minTime number 最少触发时间
--- @param maxTime number 最长触发时间
--- @param clickCallBack fun(evt:BaseEventData) 点击回调
--- @param pointerCallBack fun(state:boolean,evt:BaseEventData) 按下，抬起回调
--- @param updateCallBack fun(pressTime:number) 持续触发时每帧回调
function CustomClickHandler:Init(eventTrigger, minTime, maxTime, clickCallBack, pointerCallBack, updateCallBack)
    self.updateCallBack = updateCallBack

    self.onPointerDown = function(evtData)
        self.lastPointerDownTime = Time.time
        self.pressTime = 0
        self.isPointerIn = true
        pointerCallBack(true, evtData)
    end

    self.onPointerUp = function(evtData)
        if not self.isPointerIn then
            return
        end
        
        self.isPointerIn = false
        pointerCallBack(false, evtData)

        local clickTime = Time.time - self.lastPointerDownTime
        if clickTime < maxTime and clickTime > minTime then
            clickCallBack(evtData)
        end
    end

    self.onBeginDragEntry = function(evtData)
        self:onPointerUp(evtData)
    end

    local pointerDownEntry = UIEventUtil.CreateEntryDelegate(self.onPointerDown, EventTriggerType.PointerDown)
    local pointerUpEntry = UIEventUtil.CreateEntryDelegate(self.onPointerUp, EventTriggerType.PointerUp)
    local beginDragEntry = UIEventUtil.CreateEntryDelegate(self.onBeginDragEntry, EventTriggerType.BeginDrag)


    eventTrigger.triggers:Add(pointerDownEntry)
    eventTrigger.triggers:Add(pointerUpEntry)
    eventTrigger.triggers:Add(beginDragEntry)
end

return CustomClickHandler
