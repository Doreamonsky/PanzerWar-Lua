local Mode = require("frame.game.mode")

---@class CaptureZone : Mode
local CaptureZone = class("CaptureZone", Mode)


---@class SpawnQueue
---@field player ShanghaiWindy.Core.AbstractBattlePlayer 玩家
---@field killTime number 被击杀时间
---------------------------------

GameMode()

local STORARAGE_DEFINE = "capturezone"

local M = CaptureZone

function M:ctor()
    self.modName = "CaptureZone"
    self.author = "官方"
    self.description = "占领区域"
end

function M:GetGameModeName(lang)
    if lang == "EN" then
        return "Capture Zone"
    else
        return "占区模式"
    end
end

function M:OnStartMode()
    self._index = 0
    self._isGameLogic = true
    self._coolDownTime = 15
    ---@type ShanghaiWindy.Data.CaptureZoneModeConfig
    self._curConfig = nil
    ---@type table<number,table<Transform>> 占领点序号与出生点数组的字典
    self._captureSpawnPointMap = {}
    ---@type table<number,GameObject> 占领点序号与边缘 Mesh
    self._captureZoneMeshMap = {}
    ---@type table<ShanghaiWindy.Core.BaseInitSystem,number> 占领点载具与占领点序号
    self._vehicleCaptureZoneIndexMap = {}
    ---@type table<number,SpawnQueue> 重生列表
    self._playerSpawnQueue = {}
    ---@type table<ShanghaiWindy.Core.AbstractBattlePlayer,table<ShanghaiWindy.Core.VehicleInfo>> 人机与载具列表
    self._botPlayerVehicleListMap = {}
    ---@type table<number,table<number,number>> 占领点的连通区判断
    self._zoneConnectedMap = {}
    ---@type table<ShanghaiWindy.Core.AbstractBattlePlayer, ShanghaiWindy.Core.CaptureZoneTask>
    self._botPlayerCaptureTaskMap = {}
    self._botTaskLastUpdatedTime = 0

    self.friendTeamScore = 0
    self.enemyTeamScore = 0

    self:GetConfigStorage()
    self:RefreshOptions()
    self:AddListeners()
end

function M:OnUpdated()
end

function M:OnExitMode()
    self._isGameLogic = false

    CustomOptionUIAPI.ToggleUI(false)
    LuaUIManager.RemoveUI(self.captureZoneUIIndex)
    self:RemoveListeners()
end

function M:AddListeners()
    self.onQuarterTick = handler(self, self.OnQuarterTick)

    TimeAPI.RegisterQuarterTick(self.onQuarterTick)
    EventSystem.AddListener(EventDefine.OnZonePickBarVisibilityChanged, self.OnZonePickBarVisibilityChanged, self)
end

function M:RemoveListeners()
    TimeAPI.UnRegisterQuarterTick(self.onQuarterTick)
    EventSystem.RemoveListener(EventDefine.OnZonePickBarVisibilityChanged, self.OnZonePickBarVisibilityChanged, self)
end

function M:RefreshOptions()
    CustomOptionUIAPI.ToggleUI(true)
    local configs = ConfigAPI.GetCaptureZoneConfigs()

    CustomOptionUIAPI.AddTitle("CaptureZone")
    CustomOptionUIAPI.AddButton("Exit", ">", function()
        ModeAPI.ExitMode()
    end)

    for i = 0, configs.Length - 1 do
        local config = configs[i]
        local mapData = MapAPI.GetMapDataByGuid(config.mapGuid)

        if mapData ~= nil then
            local displayName = config.displayName:GetDisplayName()
            CustomOptionUIAPI.AddButton(displayName, "Play", function()
                self:OnConfirmInfo(config)
            end)
        end
    end


    CustomOptionUIAPI.AddTitle("Team")
    CustomOptionUIAPI.AddOption("PlayerTeam", self.team, ENUM_TEAM, function(res)
        self.team = res
    end)

    -- Number
    CustomOptionUIAPI.AddTitle("Number")
    CustomOptionUIAPI.AddSlider("FriendTankNum", self.friendTankNum, 0, 20, true, function(res)
        self.friendTankNum = res
    end)

    CustomOptionUIAPI.AddSlider("EnemyTankNum", self.enemyTankNum, 0, 20, true, function(res)
        self.enemyTankNum = res
    end)

    CustomOptionUIAPI.AddSlider("FriendFlightNum", self.friendFlightNum, 0, 20, true, function(res)
        self.friendFlightNum = res
    end)

    CustomOptionUIAPI.AddSlider("EnemyFlightNum", self.enemyFlightNum, 0, 20, true, function(res)
        self.enemyFlightNum = res
    end)

    -- Filter
    CustomOptionUIAPI.AddTitle("Filter")
    CustomOptionUIAPI.AddSlider("FriendMinRank", self.friendMinRank, 1, 20, true, function(res)
        self.friendMinRank = res
    end)

    CustomOptionUIAPI.AddSlider("FriendMaxRank", self.friendMaxRank, 1, 20, true, function(res)
        self.friendMaxRank = res
    end)

    CustomOptionUIAPI.AddSlider("EnemyMinRank", self.enemyMinRank, 1, 20, true, function(res)
        self.enemyMinRank = res
    end)

    CustomOptionUIAPI.AddSlider("EnemyMaxRank", self.enemyMaxRank, 1, 20, true, function(res)
        self.enemyMaxRank = res
    end)

    CustomOptionUIAPI.AddOption("IsArtillery", self.isArtillery, ENUM_TOGGLE, function(res)
        self.isArtillery = res
    end)

    -- Battle Type
    CustomOptionUIAPI.AddTitle("BattleType")

    CustomOptionUIAPI.AddSlider("ScoreToEnd", self.scoreToEnd, 600, 3000, true, function(res)
        self.scoreToEnd = res
    end)
end

function M:OnConfirmInfo(config)
    self._curConfig = config

    CustomOptionUIAPI.ToggleUI(false)
    self:SetConfigStorage()

    local mapData = MapAPI.GetMapDataByGuid(self._curConfig.mapGuid)
    ModeAPI.LoadBattleScene(mapData, function()
        self:OnBattleSceneLoaded()
    end)
end

function M:OnBattleSceneLoaded()
    -- Set Team
    if self.team == ENUM_TEAM[1] then
        TeamAPI.SetPlayerTeamAsRedTeam()
    else
        TeamAPI.SetPlayerTeamAsBlueTeam()
    end

    --------------------------------- Capture ---------------------------------

    -- Set capture infos
    for i = 0, self._curConfig.captureZones.Length - 1 do
        local captureZone = self._curConfig.captureZones[i]
        local meshId = MeshAPI.CreateMesh(captureZone.zonePoints, 5)
        local mesh = MeshAPI.GetMesh(meshId)

        table.insert(self._captureZoneMeshMap, mesh)

        MaterialAPI.AsyncApplyMaterial("6873b9de-42d2-45f9-8960-5738d67d0540", mesh)

        local zoneId = CaptureZoneAPI.AddCaptureZone(captureZone.zoneCapturePoint.pointName,
            captureZone.zoneCapturePoint.position, captureZone.zoneCapturePoint.radius)

        if captureZone.zoneCapturePoint.defaultOwner ~= TeamAPI.GetNoneTeam() then
            CaptureZoneAPI.CapturingZone(zoneId, captureZone.zoneCapturePoint.defaultOwner, 1)
        end

        local spawnPointTransforms = {}

        for j = 0, captureZone.spawnTransformInfos.Length - 1 do
            local transformInfo = captureZone.spawnTransformInfos[j]
            local trans = TransformAPI.CreateTransform("SpawnPoint-" .. captureZone.zoneCapturePoint.pointName)
            trans.position = transformInfo.pos
            trans.eulerAngles = transformInfo.eulerAngle

            table.insert(spawnPointTransforms, trans)
        end

        self._captureSpawnPointMap[zoneId] = spawnPointTransforms

        local capturePoints = {}

        for degree = 0, 360, 15 do
            local x = math.cos(math.rad(degree)) * captureZone.zoneCapturePoint.radius
            local z = math.sin(math.rad(degree)) * captureZone.zoneCapturePoint.radius
            table.insert(capturePoints, Vector3(x, -10, z) + captureZone.zoneCapturePoint.position)
        end

        local id = MeshAPI.CreateMesh(capturePoints, 10)
        local mesh = MeshAPI.GetMesh(id)

        MaterialAPI.AsyncApplyMaterial("6873b9de-42d2-45f9-8960-5738d67d0540", mesh)

        MeshAPI.CreateSphereTriggerBox(captureZone.zoneCapturePoint.position, captureZone.zoneCapturePoint.radius,
            function(collider)
                local ret, vehicle = VehicleAPI.TryGetBaseInitSystemFromGameObject(collider.gameObject)
                if ret then
                    self._vehicleCaptureZoneIndexMap[vehicle] = zoneId
                end
            end,
            function(collider)
                local ret, vehicle = VehicleAPI.TryGetBaseInitSystemFromGameObject(collider.gameObject)
                if ret then
                    self._vehicleCaptureZoneIndexMap[vehicle] = nil
                end
            end)
    end

    for i = 0, self._curConfig.zoneChains.Length - 1 do
        local zoneChain = self._curConfig.zoneChains[i]
        local fromId = CaptureZoneAPI.GetCaptureZoneFromName(zoneChain.fromZone):GetIndex()
        local toId = CaptureZoneAPI.GetCaptureZoneFromName(zoneChain.toZone):GetIndex()

        if self._zoneConnectedMap[toId] == nil then
            self._zoneConnectedMap[toId] = {}
        end

        table.insert(self._zoneConnectedMap[toId], fromId)
    end

    --------------------------------- Players ---------------------------------
    -- Set Players
    self.mainPlayerList = VehicleAPI.GetFilteredVehicles(self.friendMinRank, self.friendMaxRank)

    ---@type ShanghaiWindy.Core.AbstractBattlePlayer
    self.mainBattlePlayer = BattlePlayerAPI.CreateOfflineMainPlayer(-1, {})
    ModeAPI.AddBattlePlayer(self.mainBattlePlayer)

    self.mainBattlePlayer.OnVehicleLoaded:AddListener(function()
    end)

    self.mainBattlePlayer.OnVehicleDestroyed:AddListener(function()
        self:OnBattlePlayerDestroyed(self.mainBattlePlayer)
    end)

    self.mainBattlePlayer.OnGameObjectDestroyed:AddListener(function()
        self:OnMainPlayerGameObjectDestroyed(self.mainBattlePlayer)
    end)

    --- Create bot tank players
    self.friendTankBotPlayers = self:CreateBotPlayerList(self.friendTankNum, TeamAPI.GetPlayerTeam())
    self.enemyTankBotPlayers = self:CreateBotPlayerList(self.enemyTankNum, TeamAPI.GetEnemyTeam())

    self.friendFlightBotPlayers = self:CreateBotPlayerList(self.friendFlightNum, TeamAPI.GetPlayerTeam())
    self.enemyFlightBotPlayers = self:CreateBotPlayerList(self.enemyFlightNum, TeamAPI.GetEnemyTeam())

    --- Create suitable vehicle list
    self.friendTankVehicleList = self:GetBotVehicleList(self.friendMinRank, self.friendMaxRank, VehicleInfo.Type.Ground)
    self.enemyTankVehicleList = self:GetBotVehicleList(self.enemyMinRank, self.enemyMaxRank, VehicleInfo.Type.Ground)

    self.friendFlightVehicleList = self:GetBotVehicleList(self.friendMinRank, self.friendMaxRank,
        VehicleInfo.Type.Aviation)
    self.enemyFlightVehicleList = self:GetBotVehicleList(self.enemyMinRank, self.enemyMaxRank, VehicleInfo.Type.Aviation)

    self:InitBotPlayerVehicle(self.friendTankBotPlayers, self.friendTankVehicleList)
    self:InitBotPlayerVehicle(self.enemyTankBotPlayers, self.enemyTankVehicleList)

    self:InitBotPlayerVehicle(self.friendFlightBotPlayers, self.friendFlightVehicleList)
    self:InitBotPlayerVehicle(self.enemyFlightBotPlayers, self.enemyFlightVehicleList)

    ModeAPI.LoadBattleUI(function()
        self.captureZoneUIIndex = LuaUIManager.CreateUI(CaptureZoneView.new(), CaptureZoneController.new(),
            "f5ec298e-6852-487a-95a8-00191a792ad4",
            "LuaCaptureZone.prefab")
    end)
end

--- Local player pick the vehicle info and the point
function M:SpawnMainPlayer(vehicleInfo, pointIndex)
    local curPointIndex = pointIndex

    if curPointIndex ~= -1 then
        -- check if point is ours
        local zone = CaptureZoneAPI.GetCaptureZone(curPointIndex)
        if not zone:IsComplete() or zone.capturingTeam ~= TeamAPI.GetPlayerTeam() then
            curPointIndex = -1
        end
    end

    if curPointIndex == -1 then
        curPointIndex = self:GetSpawnablePointIndex(self.mainBattlePlayer:GetTeam())
    end

    if curPointIndex ~= -1 then
        EventSystem.DispatchEvent(EventDefine.OnZonePickBarVisibilityChanged, false)

        local transformList = self._captureSpawnPointMap[curPointIndex]
        SpawnAPI.AsyncSpawnGivenPoints(transformList, function(trans)
            self.mainBattlePlayer:CreateVehicle(vehicleInfo, trans.position, trans.rotation)
        end)
    else
        error("failed to find point index...")
    end
end

--- Get a capture zone that the team is the same.
function M:GetSpawnablePointIndex(team)
    local captureZones = CaptureZoneAPI.GetCaptureZoneInfos()

    for i = 0, captureZones.Length - 1 do
        local zone = captureZones[i]

        if zone:IsComplete() and zone.capturingTeam == team then
            return zone:GetIndex()
        end
    end

    return -1
end

--- Create bots
function M:CreateBotPlayerList(num, team)
    local list = {}

    for i = 1, num do
        local bot = BattlePlayerAPI.CreateOfflineBotPlayer(self._index, "黑暗降临", nil)
        bot.BotTeam = team

        ModeAPI.AddBattlePlayer(bot)

        table.insert(list, bot)
        self._index = self._index + 1
    end

    return list
end

function M:GetBotVehicleList(minRank, maxRank, vehicleType)
    return VehicleAPI.GetFilteredBotVehicles(minRank, maxRank, self.isArtillery == ENUM_TOGGLE[2], vehicleType)
end

---@param battlePlayerList table<number,ShanghaiWindy.Core.AbstractBattlePlayer>
---@param vehicleList table<number,VehicleInfo>
function M:InitBotPlayerVehicle(battlePlayerList, vehicleList)
    for k, battlePlayer in pairs(battlePlayerList) do
        self._botPlayerVehicleListMap[battlePlayer] = vehicleList
        self:RandomSpawnBotVehicle(battlePlayer, vehicleList)

        battlePlayer.OnVehicleDestroyed:AddListener(function()
            self:OnBattlePlayerDestroyed(battlePlayer)
        end)
    end
end

---@param battlePlayer ShanghaiWindy.Core.AbstractBattlePlayer
function M:RandomSpawnBotVehicle(battlePlayer, vehicleList)
    local pointIndex = self:GetSpawnablePointIndex(battlePlayer:GetTeam())

    if pointIndex ~= -1 then
        SpawnAPI.AsyncSpawnGivenPoints(self._captureSpawnPointMap[pointIndex], function(trans)
            local vehicleInfo = RandomAPI.GetRandomVehicleFromList(vehicleList)
            local spawnPos = trans.position

            if vehicleInfo.type == VehicleInfo.Type.Aviation then
                spawnPos = spawnPos + Vector3(0, 500, 0)
            end

            local vehicle = battlePlayer:CreateVehicle(vehicleInfo, spawnPos, trans.rotation)

            if vehicleInfo.type == VehicleInfo.Type.Ground then
                local logic = BotAPI.GetTankBotTaskLogic()
                vehicle.thinkLogic = logic

                vehicle.OnVehicleLoaded:AddListener(function()
                    local captureTask = BotAPI.AddCaptureTaskToBot(logic)
                    self._botPlayerCaptureTaskMap[battlePlayer] = captureTask
                    self:UpdateCaptureTask()
                end)

                vehicle.OnGameObjectDestroyed:AddListener(function()
                    self._botPlayerCaptureTaskMap[battlePlayer] = nil
                    self:UpdateCaptureTask()
                end)
            end
        end)
    end
end

function M:OnMainPlayerGameObjectDestroyed(battlePlayer)
    EventSystem.DispatchEvent(EventDefine.OnZonePickBarVisibilityChanged, true)
end

---@param battlePlayer ShanghaiWindy.Core.AbstractBattlePlayer
function M:OnBattlePlayerDestroyed(battlePlayer)
    if self._isGameLogic then
        table.insert(self._playerSpawnQueue, {
            player = battlePlayer,
            killTime = TimeAPI.GetTime()
        })
    end

    if battlePlayer:GetTeam() == TeamAPI.GetPlayerTeam() then
        self.enemyTeamScore = self.enemyTeamScore + battlePlayer.VehicleInfo:GetRank()
    else
        self.friendTeamScore = self.friendTeamScore + battlePlayer.VehicleInfo:GetRank()
    end

    self:UpdateScore()
end

function M:UpdateScore()
    if self.friendTeamScore < 0 then
        self.friendTeamScore = 0
    end

    if self.enemyTeamScore < 0 then
        self.enemyTeamScore = 0
    end

    ModeAPI.UpdateScore(math.floor(self.friendTeamScore), math.floor(self.enemyTeamScore), self.scoreToEnd,
        self.scoreToEnd)

    if self.enemyTeamScore >= self.scoreToEnd or self.friendTeamScore >= self.scoreToEnd then
        local isVictory = self.friendTeamScore >= self.scoreToEnd
        ModeAPI.ShowVictoryOrDefeat(isVictory)
        self._isGameLogic = false
        self._botPlayerCaptureTaskMap = {}
    end
end

function M:GetConfigStorage()
    self.team = StorageAPI.GetStringValue(STORARAGE_DEFINE, "Team", ENUM_TEAM[1])

    self.friendTankNum = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "FriendTankNum", 5)
    self.enemyTankNum = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "EnemyTankNum", 5)

    self.friendFlightNum = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "FriendFlightNum", 0)
    self.enemyFlightNum = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "EnemyFlightNum", 0)

    self.friendMinRank = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "FriendMinRank", 5)
    self.friendMaxRank = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "FriendMaxRank", 7)

    self.enemyMinRank = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "EnemyMinRank", 5)
    self.enemyMaxRank = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "EnemyMaxRank", 7)

    self.isArtillery = StorageAPI.GetStringValue(STORARAGE_DEFINE, "IsArtillery", ENUM_TOGGLE[1])

    self.scoreToEnd = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "ScoreToEnd", 200)
end

function M:SetConfigStorage()
    StorageAPI.SetStringValue(STORARAGE_DEFINE, "Team", self.team)

    StorageAPI.SetNumberValue(STORARAGE_DEFINE, "FriendTankNum", self.friendTankNum)
    StorageAPI.SetNumberValue(STORARAGE_DEFINE, "EnemyTankNum", self.enemyTankNum)

    StorageAPI.SetNumberValue(STORARAGE_DEFINE, "FriendFlightNum", self.friendFlightNum)
    StorageAPI.SetNumberValue(STORARAGE_DEFINE, "EnemyFlightNum", self.enemyFlightNum)

    StorageAPI.SetNumberValue(STORARAGE_DEFINE, "FriendMinRank", self.friendMinRank)
    StorageAPI.SetNumberValue(STORARAGE_DEFINE, "FriendMaxRank", self.friendMaxRank)

    StorageAPI.SetNumberValue(STORARAGE_DEFINE, "EnemyMinRank", self.enemyMinRank)
    StorageAPI.SetNumberValue(STORARAGE_DEFINE, "EnemyMaxRank", self.enemyMaxRank)

    StorageAPI.SetStringValue(STORARAGE_DEFINE, "IsArtillery", self.isArtillery)

    StorageAPI.SetNumberValue(STORARAGE_DEFINE, "ScoreToEnd", self.scoreToEnd)

    StorageAPI.SaveStorage()
end

function M:OnZonePickBarVisibilityChanged(isActive)
    for k, meshGo in pairs(self._captureZoneMeshMap) do
        GameObjectAPI.SetActive(meshGo, isActive)
    end
end

function M:IsProxyBattle()
    return false
end

function M:OnQuarterTick(deltaTime)
    for vehicle, zoneIndex in pairs(self._vehicleCaptureZoneIndexMap) do
        if vehicle:IsNull() or vehicle.IsDestroyed then
            self._vehicleCaptureZoneIndexMap[vehicle] = nil
        else
            if self:IsZoneConnected(zoneIndex, vehicle.OwnerTeam) then
                CaptureZoneAPI.CapturingZone(zoneIndex, vehicle.OwnerTeam, deltaTime * 0.1)
            end
        end
    end

    local zones = CaptureZoneAPI.GetCaptureZoneInfos()

    for i = 0, zones.Length - 1 do
        local zone = zones[i]
        if zone:IsComplete() then
            if zone.capturingTeam == TeamAPI.GetPlayerTeam() then
                self.friendTeamScore = self.friendTeamScore + deltaTime
                self.enemyTeamScore = self.enemyTeamScore - deltaTime
            else
                self.enemyTeamScore = self.enemyTeamScore + deltaTime
                self.friendTeamScore = self.friendTeamScore - deltaTime
            end

            self:UpdateScore()
        end
    end

    for i = #self._playerSpawnQueue, 1, -1 do
        ---@type SpawnQueue
        local spawnInfo = self._playerSpawnQueue[i]
        if TimeAPI.GetTime() > spawnInfo.killTime + self._coolDownTime then
            if not spawnInfo.player:IsLocalPlayer() then
                self:RandomSpawnBotVehicle(spawnInfo.player, self._botPlayerVehicleListMap[spawnInfo.player])
            end
            table.remove(self._playerSpawnQueue, i)
        end
    end

    if TimeAPI.GetTime() - self._botTaskLastUpdatedTime > 10 then
        self:UpdateCaptureTask()
    end
end

function M:IsZoneConnected(zoneIndex, team)
    local isConnected = false

    if self._zoneConnectedMap[zoneIndex] then
        for k, zoneId in pairs(self._zoneConnectedMap[zoneIndex]) do
            local zone = CaptureZoneAPI.GetCaptureZone(zoneId)

            if zone.capturingTeam == team then
                isConnected = true
            end
        end
    end

    return isConnected
end

function M:GetUnCapturedZones(team)
    local unCaptureZones = {}
    local zones = CaptureZoneAPI.GetCaptureZoneInfos()

    for i = 0, zones.Length - 1 do
        local zone = zones[i]

        if not zone:IsComplete() or zone.capturingTeam ~= team then
            if self:IsZoneConnected(zone:GetIndex(), team) then
                table.insert(unCaptureZones, zone)
            end
        end
    end

    return unCaptureZones
end

function M:UpdateCaptureTask()
    self._botTaskLastUpdatedTime = TimeAPI.GetTime()

    ---@type table<number,ShanghaiWindy.Core.CaptureZoneInfo>

    local teamAZones = self:GetUnCapturedZones(TeamAPI.GetRedTeam())
    ---@type table<number,ShanghaiWindy.Core.CaptureZoneInfo>
    local teamBZones = self:GetUnCapturedZones(TeamAPI.GetBlueTeam())

    local teamACaptureCount = 0
    local teamBCaptureCount = 0

    for battlePlayer, captureTask in pairs(self._botPlayerCaptureTaskMap) do
        if not battlePlayer.IsAlive then
            self._botPlayerCaptureTaskMap[battlePlayer] = nil
        else
            if battlePlayer.BotTeam == TeamAPI.GetRedTeam() and #teamAZones > 0 and teamACaptureCount < 2 then
                teamACaptureCount = teamACaptureCount + 1
                local zone = teamAZones[#teamAZones]
                captureTask.ZoneId = zone:GetIndex()
                captureTask.Weight = 1 / teamACaptureCount
                table.remove(teamAZones)
                -- print("Team A let" .. battlePlayer:GetVehicleName() .. " is capturing " .. zone.zoneName)
            elseif battlePlayer.BotTeam == TeamAPI.GetBlueTeam() and #teamBZones > 0 and teamBCaptureCount < 2 then
                teamBCaptureCount = teamBCaptureCount + 1
                local zone = teamBZones[#teamBZones]
                captureTask.ZoneId = zone:GetIndex()
                captureTask.Weight = 1 / teamBCaptureCount
                table.remove(teamBZones)
                -- print("Team B let" .. battlePlayer:GetVehicleName() .. " is capturing " .. zone.zoneName)
            else
                captureTask.ZoneId = 0
            end
        end
    end
end

return M
