BotVehicleUtil = {}
Lib()

local M = BotVehicleUtil

--- Make sure the vehicle list > 0
function M.GetSafeBotVehicleList(vehicleList)
    if vehicleList.Count == 0 then
        print("fallback vehicle list")
        return VehicleAPI.GetFilteredBotVehicles(0, 20, true, VehicleInfo.Type.Ground)
    else
        return vehicleList
    end
end
