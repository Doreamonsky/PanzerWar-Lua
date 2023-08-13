--- 离线重生模式

local M = class("BaseSkirmishMode")

GameMode()

local TEAM_OPTION_DEFINES = { "red", "blue" }
local TOGGLE_OPTION_DEFINES = { "closed", "opened" }
local STORARAGE_DEFINE = "skirmish"

function M:ctor()
    -- Mod Ctor
    self.modName = "经典遭遇战模式"
    self.author = "超级哆啦酱"
    self.description = "双方重生战斗"

    -- Config
    self:GetConfigStorage()

    -- Runtimes
    self.isGameLogic = false
    self.index = 0

    ---@type table<number,ShanghaiWindy.Core.AbstractBattlePlayer>
    self.friendTankBotPlayers = {}

    ---@type table<number,ShanghaiWindy.Core.AbstractBattlePlayer>
    self.enemyTankBotPlayers = {}

    ---@type ShanghaiWindy.Core.AbstractBattlePlayer
    self.mainBattlePlayer = nil
end

function M:GetConfigStorage()
    self.team = StorageAPI.GetStringValue(STORARAGE_DEFINE, "Team", TEAM_OPTION_DEFINES[1])

    self.friendTankNum = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "FriendTankNum", 5)
    self.enemyTankNum = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "EnemyTankNum", 5)

    self.friendFlightNum = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "FriendFlightNum", 0)
    self.enemyFlightNum = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "EnemyFlightNum", 0)

    self.friendMinRank = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "FriendMinRank", 5)
    self.friendMaxRank = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "FriendMaxRank", 7)

    self.enemyMinRank = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "EnemyMinRank", 5)
    self.enemyMaxRank = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "EnemyMaxRank", 7)

    self.isArtillery = StorageAPI.GetStringValue(STORARAGE_DEFINE, "IsArtillery", TOGGLE_OPTION_DEFINES[1])

    self.scoreToEnd = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "ScoreToEnd", 50)
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

function M:GetGameModeName(userLang)
    if userLang == "EN" then
        return "Base Skirmish Mode"
    else
        return "经典遭遇战模式"
    end
end

function M:OnStartMode()
    self:ShowSettingUI()
    self:AddListeners()
end

function M:OnExitMode()
    self:RemoveListeners()
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
function M:ShowSettingUI()
    CustomOptionUIAPI.ToggleUI(true)
    CustomOptionUIAPI.AddTitle("Skirmish")

    CustomOptionUIAPI.AddButton("Battle", "Start", function()
        self:OnConfirmInfo()
    end)

    -- Team
    CustomOptionUIAPI.AddTitle("Team")
    CustomOptionUIAPI.AddOption("PlayerTeam", self.team, TEAM_OPTION_DEFINES, function(res)
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
        self.friendFlightNum = res
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

    CustomOptionUIAPI.AddOption("IsArtillery", self.isArtillery, TOGGLE_OPTION_DEFINES, function(res)
        self.isArtillery = res
    end)

    -- Battle Type
    CustomOptionUIAPI.AddTitle("BattleType")

    CustomOptionUIAPI.AddSlider("ScoreToEnd", self.scoreToEnd, 1, 200, true, function(res)
        self.scoreToEnd = res
    end)
end

function M:OnConfirmInfo()
    CustomOptionUIAPI.ToggleUI(false)
    self:SetConfigStorage()

    -- Set Team
    if self.team == TEAM_OPTION_DEFINES[1] then
        TeamAPI.SetPlayerTeamAsRedTeam()
    else
        TeamAPI.SetPlayerTeamAsBlueTeam()
    end

    ModeAPI.ShowPickVehicleUI()

    self.mainBattlePlayer = self:CreateMainPlayer()
    self.mainBattlePlayer.OnVehicleDestroyed:AddListener(function()
        ModeAPI.ShowPickVehicleUI()
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

    self:CreateBotPlayerVehicle(self.friendTankBotPlayers, self.friendTankVehicleList)
    self:CreateBotPlayerVehicle(self.enemyTankBotPlayers, self.enemyTankVehicleList)

    self:CreateBotPlayerVehicle(self.friendFlightBotPlayers, self.friendFlightVehicleList)
    self:CreateBotPlayerVehicle(self.enemyFlightBotPlayers, self.enemyFlightVehicleList)

    self.isGameLogic = true
end

function M:GetBotVehicleList(minRank, maxRank, vehicleType)
    return VehicleAPI.GetFilteredBotVehicles(minRank, maxRank, self.isArtillery == TOGGLE_OPTION_DEFINES[2], vehicleType)
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
function M:CreateBotPlayerVehicle(battlePlayerList, vehicleList)
    for k, battlePlayer in pairs(battlePlayerList) do
        self:RandomSpawnBotVehicle(battlePlayer, vehicleList)

        battlePlayer.OnVehicleDestroyed:AddListener(function()
            self:RandomSpawnBotVehicle(battlePlayer, vehicleList)
        end)
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
        battlePlayer:CreateVehicle(vehicleInfo, trans.position, trans.rotation)
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

return M
