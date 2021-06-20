---@class CSharpAPI
---@field isLocalPlayer fun():boolean 是否为本地玩家
---@field GetPlayer fun():BaseInitSystem 获得当前玩家
---@field GetMapData fun():MapData 获取当前地图
---@field isOfffline fun():boolean 是否单机
---@field LoadAssetBundle fun(abName:string,abVariant:string,callBack:function) 读取AssetBundle资源
---@field GetBotVehicleList fun(availableVehicleList:List<VehicleInfo>,maxRandomPoolCount:int) 获取 bot 可用载具列表
---@field RandomVehicleFromList fun(vehicleList:List<VehicleInfo>):VehicleInfo 从 vehicle 数组随机获取一个非火炮的载具
---@field CreateTankPlayer fun(vehicleName:string,pos:Vector3,rot:Quaternion):TankInitSystem 创建玩家坦克
---@field CreateFlightPlayer fun(vehicleName:string,pos:Vector3,rot:Quaternion,isSpawnOnAirPort:boolean):FlightInitSystem 创建玩家坦克
---@field CreateTankBot fun(vehicleName:string,pos:Vector3,rot:Quaternion,botTeam:TeamManager.Team):TankInitSystem 创建人机坦克
CSharpAPI = CS.ShanghaiWindy.Core.LuaCallCSharpHelper

--- @class VehicleInfo
--- @field GetDisplayName fun():string 载具显示名称
--- @field rank int 等级
VehicleInfo = CS.ShanghaiWindy.Core.VehicleInfo

--- @class GameDataManager
--- @field PlayerTeam TeamManager.Team 玩家队伍
GameDataManager = CS.ShanghaiWindy.Core.GameDataManager

CommonDataManager = CS.ShanghaiWindy.Core.CommonDataManager

GameEventManager = CS.ShanghaiWindy.Core.GameEventManager

--- @field Team Team
TeamManager = CS.ShanghaiWindy.Core.TeamManager

VehicleInfoManager = CS.ShanghaiWindy.Core.VehicleInfoManager

URPMainUIManager = CS.ShanghaiWindy.URPCore.URPMainUIManager
URPCustomModeOfflineManager = CS.ShanghaiWindy.URPCore.URPCustomModeOfflineManager

Core = CS.ShanghaiWindy.Core
MouseLockModule = Core.MouseLockModule

-- UnityEngine
GameObject = CS.UnityEngine.GameObject
AudioListener = CS.UnityEngine.AudioListener

-- UGUI
Text = CS.UnityEngine.UI.Text
Image = CS.UnityEngine.UI.Image
Destroy = CS.UnityEngine.GameObject.Destroy
