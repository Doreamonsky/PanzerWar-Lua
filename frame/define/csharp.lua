---@class ShanghaiWindy.Core.BaseFireSystem
local BaseFireSystem = {}

return BaseFireSystem

---@class ShanghaiWindy.Core.BaseInitSystem
local BaseInitSystem = {}

return BaseInitSystem

---@class ShanghaiWindy.Core.TeamManager
local TeamManager = {}

return TeamManager

---@class ShanghaiWindy.Core.Lua.ILuaCommonMod
local ILuaCommonMod = {}

return ILuaCommonMod

---@class ShanghaiWindy.Core.Lua.ILuaGameModeMod
local ILuaGameModeMod = {}

return ILuaGameModeMod

---@class ShanghaiWindy.Core.Lua.ILuaMod
local ILuaMod = {}

return ILuaMod

---@class ShanghaiWindy.Core.Data.BulletFiredInfo
local BulletFiredInfo = {}

return BulletFiredInfo

---@class ShanghaiWindy.Core.API.OnGameVehicleLoadedDelegate
local OnGameVehicleLoadedDelegate = {}

return OnGameVehicleLoadedDelegate

---@class ShanghaiWindy.Core.API.OnGameVehicleDestroyedDelegate
local OnGameVehicleDestroyedDelegate = {}

return OnGameVehicleDestroyedDelegate

---@class ShanghaiWindy.Core.API.GameAPI
local GameAPI = {}

---@static
---@function [GameAPI.RegisterVehicleLoadedEvent]
function GameAPI.RegisterVehicleLoadedEvent(gameVehicleLoadedDelegate) end
---@static
---@function [GameAPI.UnRegisterVehicleLoadedEvent]
function GameAPI.UnRegisterVehicleLoadedEvent(gameVehicleLoadedDelegate) end
---@static
---@function [GameAPI.RegisterVehicleDestroyedEvent]
function GameAPI.RegisterVehicleDestroyedEvent(gameVehicleDestroyedDelegate) end
---@static
---@function [GameAPI.UnRegisterVehicleDestroyedEvent]
function GameAPI.UnRegisterVehicleDestroyedEvent(gameVehicleDestroyedDelegate) end
return GameAPI

---@class ShanghaiWindy.Core.API.SpawnVehicleAPI
local SpawnVehicleAPI = {}

---@static
---@function [SpawnVehicleAPI.CreateLocalBot]
function SpawnVehicleAPI.CreateLocalBot(vehicleInfo, pos, rot, botTeam, isKeepWreckage, isIdle) end
---@static
---@function [SpawnVehicleAPI.CreatePlayer]
function SpawnVehicleAPI.CreatePlayer(vehicleInfo, pos, rot, onPreBind) end
---@static
---@function [SpawnVehicleAPI.CreateFreeCamera]
function SpawnVehicleAPI.CreateFreeCamera(pos, rot) end
return SpawnVehicleAPI

---@class ShanghaiWindy.Core.API.OnVehicleLoadedDelegate
local OnVehicleLoadedDelegate = {}

return OnVehicleLoadedDelegate

---@class ShanghaiWindy.Core.API.OnVehicleDestroyedDelegate
local OnVehicleDestroyedDelegate = {}

return OnVehicleDestroyedDelegate

---@class ShanghaiWindy.Core.API.OnVehicleRemovedDelegate
local OnVehicleRemovedDelegate = {}

return OnVehicleRemovedDelegate

---@class ShanghaiWindy.Core.API.OnFiredDelegate
local OnFiredDelegate = {}

return OnFiredDelegate

---@class ShanghaiWindy.Core.API.VehicleAPI
local VehicleAPI = {}

---@static
---@function [VehicleAPI.RegisterVehicleLoadedEvent]
function VehicleAPI.RegisterVehicleLoadedEvent(vehicle, vehicleLoadedDelegate) end
---@static
---@function [VehicleAPI.UnRegisterVehicleLoaedEvent]
function VehicleAPI.UnRegisterVehicleLoaedEvent(vehicle, vehicleLoadedDelegate) end
---@static
---@function [VehicleAPI.RegisterVehicleDestroyedEvent]
function VehicleAPI.RegisterVehicleDestroyedEvent(vehicle, vehicleDestroyedDelegate) end
---@static
---@function [VehicleAPI.UnRegisterVehicleDestroyedEvent]
function VehicleAPI.UnRegisterVehicleDestroyedEvent(vehicle, vehicleDestroyedDelegate) end
---@static
---@function [VehicleAPI.RegisterVehicleGameObjectDestroyedEvent]
function VehicleAPI.RegisterVehicleGameObjectDestroyedEvent(vehicle, vehicleGameObjectDestroyed) end
---@static
---@function [VehicleAPI.UnRegisterVehicleGameObjectDestroyedEvent]
function VehicleAPI.UnRegisterVehicleGameObjectDestroyedEvent(vehicle, vehicleGameObjectDestroyed) end
---@static
---@function [VehicleAPI.RegisterBulletFiredEvent]
function VehicleAPI.RegisterBulletFiredEvent(vehicle, index, tankFiredDelegate) end
---@static
---@function [VehicleAPI.UnRegisterBulletFiredEvent]
function VehicleAPI.UnRegisterBulletFiredEvent(vehicle, index, tankFiredDelegate) end
---@static
---@function [VehicleAPI.GetPlayerVehicle]
function VehicleAPI.GetPlayerVehicle() end
---@static
---@function [VehicleAPI.TryGetTankInitSystem]
function VehicleAPI.TryGetTankInitSystem(gameObject, tankInitSystem) end
---@static
---@function [VehicleAPI.TryGetFlightInitSystem]
function VehicleAPI.TryGetFlightInitSystem(gameObject, flightInitSystem) end
---@static
---@function [VehicleAPI.TryGetArmyInitSystem]
function VehicleAPI.TryGetArmyInitSystem(gameObject, armyInitSystem) end
---@static
---@function [VehicleAPI.GetFireList]
function VehicleAPI.GetFireList(vehicle) end
return VehicleAPI

