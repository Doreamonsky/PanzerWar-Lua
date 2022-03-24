CustomClass = class("CustomClass")

local this = CustomClass

function this:Init()
    EventSystem.AddListener(Events.Hello, self.Bind, self)
end

function this:OnDestroy()
    EventSystem.RemoveListener(Events.Hello, self.Bind, self)
end

function this:Bind(args)
    print(args)
    print("This is a bind message")
end

return this
