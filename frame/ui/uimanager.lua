---@class LuaUIManager
---@field createResourceDelegate function
---@field removeResourceDelegate function
local LuaUIManager = {}
local M = LuaUIManager

M.createResourceDelegate = nil
M.removeResourceDelegate = nil

M.Index = 0
M.RefMap = {}

---@param controller BaseController
---@param view BaseView
function M.CreateUI(view, controller, ...)
    local index = M.Index
    M.Index = M.Index + 1

    M.RefMap[index] = {
        view = nil,
        controller = nil,
        resourceRef = nil
    }

    M.createResourceDelegate(function(instance, resourceRef)
        if M.RefMap[index] ~= nil then
            local root = instance.transform
            view:InitUI(root)
            controller.view = view

            M.RefMap[index].view = view
            M.RefMap[index].controller = controller
            M.RefMap[index].resourceRef = resourceRef

            controller:Awake()
        else
            M.removeResourceDelegate(resourceRef)
        end
    end, ...)

    return index
end

function M.RemoveUI(index)
    local ref = M.RefMap[index]

    if ref ~= nil then
        ---@type BaseController
        local controller = ref.controller
        controller:Destroy()

        M.removeResourceDelegate(ref.resourceRef)
        M.RefMap[index] = nil
    end
end

return M
