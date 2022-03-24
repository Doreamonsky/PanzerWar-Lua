EntityManager = {}

--- @type table<number,Entity>
EntityManager.entities = {}

--- @param entity Entity
EntityManager.AddEntity = function(entity)
    table.insert(EntityManager.entities, entity)
end

--- @param entity Entity
EntityManager.RemoveEntity = function(entity)
    local index = table.indexOf(EntityManager.entities, entity)

    if index then
        table.remove(EntityManager.entities, index)
    end
end
