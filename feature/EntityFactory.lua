EntityFactory = {}

--- @type table<number,Entity>
EntityFactory.entities = {}

--- @param entityType Class
EntityFactory.AddEntity = function(entityType)
    local entity = entityType.new()
    table.insert(EntityFactory.entities, entity)
    return entity
end

--- @param entity Entity
EntityFactory.RemoveEntity = function(entity)
    local index = table.indexOf(EntityFactory.entities, entity)

    if index then
        table.remove(EntityFactory.entities, index)
    end
end
