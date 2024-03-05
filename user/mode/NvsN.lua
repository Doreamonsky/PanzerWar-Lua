local Mode = require("frame.game.mode")

---@class NvsN : Mode
local NvsN = class("NvsN", Mode)

GameMode()

local STORARAGE_DEFINE = "nvn"

local M = NvsN

function M:ctor()
    self.modName = "NvsN"
    self.author = "官方"
    self.description = "N 人对 N 人"
end

function M:GetGameModeName(lang)
    if lang == "CN" then
        return "N 对 N 闪电战"
    else
        return "N vs N Blitzkrieg"
    end
end

function M:OnStartMode()
    self:GetConfigStorage()
    self.index = 0

    self.friendTeamScore = 0
    self.enemyTeamScore = 0

    self.friendTeamMaxScore = 0
    self.enemyTeamMaxScore = 0

    self.isCountDown = false
    self.isGameLogic = true

    ---@type table<number,ShanghaiWindy.Core.AbstractBattlePlayer>
    self.countDownPlayerList = {}

    self:AddListeners()
    self:RefreshOptions()
end

function M:OnUpdated()
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

function M:GetConfigStorage()
    self.team = StorageAPI.GetStringValue(STORARAGE_DEFINE, "Team", ENUM_TEAM[1])

    self.friendTankNum = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "FriendTankNum", 5)
    self.enemyTankNum = StorageAPI.GetNumberValue(STORARAGE_DEFINE, "EnemyTankNum", 5)
end

function M:SetConfigStorage()
    StorageAPI.SetStringValue(STORARAGE_DEFINE, "Team", self.team)

    StorageAPI.SetNumberValue(STORARAGE_DEFINE, "FriendTankNum", self.friendTankNum)
    StorageAPI.SetNumberValue(STORARAGE_DEFINE, "EnemyTankNum", self.enemyTankNum)


    StorageAPI.SaveStorage()
end

--- Create ui of game mode settting
function M:RefreshOptions()
    CustomOptionUIAPI.ClearOptions()
    CustomOptionUIAPI.ToggleUI(true)
    CustomOptionUIAPI.AddTitle("N vs N")

    CustomOptionUIAPI.AddButton("Battle", "Start", function()
        self:OnConfirmInfo()
    end)

    -- Team
    CustomOptionUIAPI.AddTitle("Team")
    CustomOptionUIAPI.AddOption("PlayerTeam", self.team, ENUM_TEAM, function(res)
        self.team = res
    end)

    CustomOptionUIAPI.AddTitle("Number")
    CustomOptionUIAPI.AddSlider("FriendTankNum", self.friendTankNum, 1, 20, true, function(res)
        self.friendTankNum = res
    end)

    CustomOptionUIAPI.AddSlider("EnemyTankNum", self.enemyTankNum, 1, 20, true, function(res)
        self.enemyTankNum = res
    end)

    CustomOptionUIAPI.AddButton("HostBP", ">", function()
        BanPick.ShowBanPick()
    end)
end

function M:OnConfirmInfo()
    CustomOptionUIAPI.ToggleUI(false)
    self:SetConfigStorage()

    if self.team == ENUM_TEAM[1] then
        TeamAPI.SetPlayerTeamAsRedTeam()
    else
        TeamAPI.SetPlayerTeamAsBlueTeam()
    end

    self.friendTeamMaxScore = self.enemyTankNum
    self.enemyTeamMaxScore = self.friendTankNum

    ModeAPI.ShowPickVehicleUI(true)
end

function M:OnPickMainPlayerVehicle(evtData)
    local vehicleInfo = evtData.VehicleInfo

    local playerRank = vehicleInfo:GetRank()

    self.mainBattlePlayer = BattlePlayerAPI.CreateOfflineMainPlayer(-1, {})
    ModeAPI.AddBattlePlayer(self.mainBattlePlayer)

    self.mainBattlePlayer.OnVehicleLoaded:AddListener(function()
        if self.isCountDown then
            ModeAPI.ToggleVehicleLockState(true, self.mainBattlePlayer.Vehicle)
            table.insert(self.countDownPlayerList, self.mainBattlePlayer)
        end
    end)

    self.mainBattlePlayer.OnVehicleDestroyed:AddListener(function()
        self:OnBattlePlayerDestroyed(self.mainBattlePlayer)

        local cameraTrans = CameraAPI.GetCameraTransform()
        SpawnVehicleAPI.CreateFreeCamera(cameraTrans.position, cameraTrans.rotation)
    end)

    SpawnAPI.AsyncSpawn(self.mainBattlePlayer:GetTeam(), function(trans)
        self.mainBattlePlayer:CreateVehicle(vehicleInfo, trans.position, trans.rotation)
    end)

    local minRankPattern = { playerRank - 2, playerRank - 1, playerRank }
    local maxRankPattern = { playerRank, playerRank + 1, playerRank + 2 }

    local minRank = self:GetRandomPattern(minRankPattern)
    local maxRank = self:GetRandomPattern(maxRankPattern)

    local friendRanks = self:GetRandomRanks(minRank, maxRank, self.friendTankNum - 1)
    local enemyRanks = self:GetRandomRanks(minRank, maxRank, self.enemyTankNum - 1)

    if enemyRanks[playerRank] then
        enemyRanks[playerRank] = enemyRanks[playerRank] + 1
    else
        enemyRanks[playerRank] = 1
    end


    self:CreateVehiclesFromRanks(TeamAPI.GetPlayerTeam(), playerRank, friendRanks)
    self:CreateVehiclesFromRanks(TeamAPI.GetEnemyTeam(), playerRank, enemyRanks)

    self.isCountDown = true

    ModeAPI.EnableCountDown(10, "Blitzkrieg", "DestroyAllEnemyVehicles", function()
        self.isCountDown = false
        for k, player in pairs(self.countDownPlayerList) do
            ModeAPI.ToggleVehicleLockState(false, player.Vehicle)
        end
    end)
end

function M:GetRandomPattern(randomPattern)
    return randomPattern[math.random(1, #randomPattern)]
end

---@type table<number,number> rank -> numbers
function M:GetRandomRanks(minRank, maxRank, number)
    local ranks = {}

    for i = 1, number do
        local rank = math.random(minRank, maxRank)

        if ranks[rank] then
            ranks[rank] = ranks[rank] + 1
        else
            ranks[rank] = 1
        end
    end

    return ranks
end

---@type table<number,ShanghaiWindy.Core.AbstractBattlePlayer>
function M:CreateVehiclesFromRanks(team, playerRank, ranks)
    local battlePlayerList = {}
    local rankVehicleMap = {}

    for rank, _ in pairs(ranks) do
        local botVehicles = VehicleAPI.GetFilteredBotVehicles(rank, rank, false, VehicleInfo.Type.Ground)

        if botVehicles.Count == 0 then
            botVehicles = VehicleAPI.GetFilteredBotVehicles(playerRank, playerRank, false, VehicleInfo.Type.Ground)
        end

        rankVehicleMap[rank] = botVehicles
    end

    for rank, number in pairs(ranks) do
        for i = 1, number do
            if rankVehicleMap[rank].Count ~= 0 then
                ---@type ShanghaiWindy.Core.AbstractBattlePlayer
                local botPlayer = BattlePlayerAPI.CreateOfflineBotPlayer(self.index, "DarkPaiMen", {})
                botPlayer.BotTeam = team
                botPlayer.IsKeepWreckage = true

                ModeAPI.AddBattlePlayer(botPlayer)

                SpawnAPI.AsyncSpawn(team, function(trans)
                    botPlayer:CreateVehicle(RandomAPI.GetRandomVehicleFromList(rankVehicleMap[rank]), trans.position,
                        trans.rotation)
                end)

                botPlayer.OnVehicleLoaded:AddListener(function()
                    if self.isCountDown then
                        ModeAPI.ToggleVehicleLockState(true, botPlayer.Vehicle)
                        table.insert(self.countDownPlayerList, botPlayer)
                    end
                end)

                botPlayer.OnVehicleDestroyed:AddListener(function()
                    self:OnBattlePlayerDestroyed(botPlayer)
                end)

                table.insert(battlePlayerList, botPlayer)
                self.index = self.index + 1
            else
                print(string.format("Current rank do not have bot vehicles %s", rank))
            end
        end
    end

    return battlePlayerList
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
    ModeAPI.UpdateScore(self.friendTeamScore, self.enemyTeamScore, self.friendTeamMaxScore, self.enemyTeamMaxScore)

    if self.friendTeamScore >= self.friendTeamMaxScore then
        ModeAPI.ShowVictoryOrDefeat(true)
        self.isGameLogic = false
    end

    if self.enemyTeamScore >= self.enemyTeamMaxScore then
        ModeAPI.ShowVictoryOrDefeat(false)
        self.isGameLogic = false
    end
end

function M:IsProxyBattle()
    return true
end

function M:GetMapMode()
    return MODE_HOST_RANDOM
end

return M
