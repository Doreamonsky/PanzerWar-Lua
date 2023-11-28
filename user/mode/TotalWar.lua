--- 离线重生模式

---@class TotalWar
local M = class("TotalWar")

GameMode()

local STORARAGE_DEFINE = "skirmish"

function M:ctor()
    self:InitModeMeta()
end

function M:InitModeMeta()
    -- Mod Ctor
    self.modName = "TotalWar"
    self.author = "官方"
    self.description = "双方空陆不间断冲突。"
end

function M:GetGameModeName(userLang)
    if userLang == "EN" then
        return "Total War Mode"
    else
        return "全面冲突模式"
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

    self.friendScoreToEnd = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "FriendScoreToEnd", 50)
    self.enemyScoreToEnd = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "EnemyScoreToEnd", 50)

    self.friendMinRank = math.min(self.friendMinRank, self.friendMaxRank)
    self.friendMaxRank = math.max(self.friendMinRank, self.friendMaxRank)
   
    self.enemyMinRank = math.min(self.enemyMinRank, self.enemyMaxRank)
    self.enemyMaxRank = math.max(self.enemyMinRank, self.enemyMaxRank)
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

    StorageAPI.SetNumberValue(STORARAGE_DEFINE, "FriendScoreToEnd", self.friendScoreToEnd)
    StorageAPI.SetNumberValue(STORARAGE_DEFINE, "EnemyScoreToEnd", self.enemyScoreToEnd)

    StorageAPI.SaveStorage()
end

function M:OnStartMode()
    -- Config
    self:GetConfigStorage()

    -- Runtimes
    self.isGameLogic = false
    self.index = 0

    self.enemyTeamScore = 0
    self.friendTeamScore = 0

    ---@type table<number,ShanghaiWindy.Core.AbstractBattlePlayer>
    self.friendTankBotPlayers = {}

    ---@type table<number,ShanghaiWindy.Core.AbstractBattlePlayer>
    self.enemyTankBotPlayers = {}

    ---@type ShanghaiWindy.Core.AbstractBattlePlayer
    self.mainBattlePlayer = nil

    self:RefreshOptions()
    self:AddListeners()
end

function M:OnExitMode()
    self:RemoveListeners()
    self.isGameLogic = false
end

function M:AddListeners()
    self.onPickPlayerVehicle = function(evtData)
        self:OnPickMainPlayerVehicle(evtData)
    end

    ModeAPI.RegisterPickVehicleCallBack(self.onPickPlayerVehicle)
end

function M:RemoveListeners()
    ModeAPI.UnRegisterPickVehicleCallBack(self.onPickPlayerVehicle)
end

function M:OnPickMainPlayerVehicle(evtData)
    local vehicleInfo = evtData.VehicleInfo
    self:CreateMainPlayerVehicle(vehicleInfo)
end

--- Create ui of game mode settting
function M:RefreshOptions()
    CustomOptionUIAPI.ClearOptions()
    CustomOptionUIAPI.ToggleUI(true)
    CustomOptionUIAPI.AddTitle("Skirmish")

    CustomOptionUIAPI.AddButton("Battle", "Start", function()
        self:OnConfirmInfo()
    end)

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

    CustomOptionUIAPI.AddSlider("FriendScoreToEnd", self.friendScoreToEnd, 1, 200, true, function(res)
        self.friendScoreToEnd = res
    end)

    CustomOptionUIAPI.AddSlider("EnemyScoreToEnd", self.enemyScoreToEnd, 1, 200, true, function(res)
        self.friendScoreToEnd = res
    end)

    CustomOptionUIAPI.AddButton("HostBP", ">", function()
        BanPick.ShowBanPick()
    end)
end

function M:OnConfirmInfo()
    CustomOptionUIAPI.ToggleUI(false)
    self:SetConfigStorage()

    -- Set Team
    if self.team == ENUM_TEAM[1] then
        TeamAPI.SetPlayerTeamAsRedTeam()
    else
        TeamAPI.SetPlayerTeamAsBlueTeam()
    end

    self.mainPlayerList = VehicleAPI.GetFilteredVehicles(self.friendMinRank, self.friendMaxRank)
    ModeAPI.ShowPickVehicleUIWithList(true, self.mainPlayerList)

    self.mainBattlePlayer = self:CreateMainPlayer()
    self.mainBattlePlayer.OnVehicleDestroyed:AddListener(function()
        self:OnBattlePlayerDestroyed(self.mainBattlePlayer)
    end)
    self.mainBattlePlayer.OnGameObjectDestroyed:AddListener(function()
        if self.isGameLogic then
            ModeAPI.ShowPickVehicleUIWithList(true, self.mainPlayerList)
        end
    end)

    --- Create bot tank players
    self.friendTankBotPlayers = self:CreateBotPlayerList(self.friendTankNum, self:GetFriendTeam())
    self.enemyTankBotPlayers = self:CreateBotPlayerList(self.enemyTankNum, self:GetEnemyTeam())

    self.friendFlightBotPlayers = self:CreateBotPlayerList(self.friendFlightNum, self:GetFriendTeam())
    self.enemyFlightBotPlayers = self:CreateBotPlayerList(self.enemyFlightNum, self:GetEnemyTeam())

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

    self.isGameLogic = true
end

function M:GetBotVehicleList(minRank, maxRank, vehicleType)
    local vehicleList = VehicleAPI.GetFilteredBotVehicles(minRank, maxRank, self.isArtillery == ENUM_TOGGLE[2], vehicleType)
    return vehicleList
end

function M:CreateMainPlayer()
    local player = BattlePlayerAPI.CreateOfflineMainPlayer(-1, nil)
    ModeAPI.AddBattlePlayer(player)
    return player
end

--- Create bots
function M:CreateBotPlayerList(num, team)
    local list = {}

    for i = 1, num do
        local bot = BattlePlayerAPI.CreateOfflineBotPlayer(self.index, "黑暗降临", nil)
        bot.BotTeam = team

        ModeAPI.AddBattlePlayer(bot)

        table.insert(list, bot)
        self.index = self.index + 1
    end

    return list
end

function M:CreateMainPlayerVehicle(vehicleInfo)
    self:RandomSpawnMainPlayerVehicle(vehicleInfo)
end

---@param battlePlayerList table<number,ShanghaiWindy.Core.AbstractBattlePlayer>
---@param vehicleList table<number,VehicleInfo>
function M:InitBotPlayerVehicle(battlePlayerList, vehicleList)
    if vehicleList.Count > 0 then
        for k, battlePlayer in pairs(battlePlayerList) do
            self:RandomSpawnBotVehicle(battlePlayer, vehicleList)

            battlePlayer.OnVehicleDestroyed:AddListener(function()
                self:OnBattlePlayerDestroyed(battlePlayer)
            end)

            battlePlayer.OnGameObjectDestroyed:AddListener(function()
                if self.isGameLogic then
                    self:RandomSpawnBotVehicle(battlePlayer, vehicleList)
                end
            end)
        end
    end
end

function M:RandomSpawnMainPlayerVehicle(vehicleInfo)
    -- todo: 选点
    SpawnAPI.AsyncSpawn(self.mainBattlePlayer:GetTeam(), function(trans)
        self.mainBattlePlayer:CreateVehicle(vehicleInfo, trans.position, trans.rotation)
    end)
end

---@param battlePlayer ShanghaiWindy.Core.AbstractBattlePlayer
function M:RandomSpawnBotVehicle(battlePlayer, vehicleList)
    SpawnAPI.AsyncSpawn(battlePlayer:GetTeam(), function(trans)
        local vehicleInfo = RandomAPI.GetRandomVehicleFromList(vehicleList)
        local spawnPos = trans.position

        if vehicleInfo.type == VehicleInfo.Type.Aviation then
            spawnPos = spawnPos + Vector3(0, 500, 0)
        end

        battlePlayer:CreateVehicle(vehicleInfo, spawnPos, trans.rotation)
    end)
end

function M:GetFriendTeam()
    return TeamAPI.GetPlayerTeam()
end

function M:GetEnemyTeam()
    return TeamAPI.GetEnemyTeam()
end

function M:OnUpdated()

end

function M:IsProxyBattle()
    return true
end

---@param battlePlayer ShanghaiWindy.Core.AbstractBattlePlayer
function M:OnBattlePlayerDestroyed(battlePlayer)
    if battlePlayer:GetTeam() == TeamAPI.GetPlayerTeam() then
        self.enemyTeamScore = self.enemyTeamScore + 1
    else
        self.friendTeamScore = self.friendTeamScore + 1
    end

    self:UpdateScore()
end

function M:UpdateScore()
    ModeAPI.UpdateScore(self.friendTeamScore, self.enemyTeamScore, self.friendScoreToEnd, self.enemyScoreToEnd)

    if self.enemyTeamScore >= self.enemyScoreToEnd or self.friendTeamScore >= self.friendScoreToEnd then
        local isVictory = self.friendTeamScore >= self.friendScoreToEnd
        ModeAPI.ShowVictoryOrDefeat(isVictory)
        self.isGameLogic = false
    end
end

return M
