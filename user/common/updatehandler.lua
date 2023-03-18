local UpdateHandler = class("UpdateHandler")

Common()

function UpdateHandler:OnUpdated()
    EntityFactory.UpdateEntity()
end

return UpdateHandler
