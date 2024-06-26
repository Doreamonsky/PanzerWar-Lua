local Mode = require("frame.game.mode")

---@class Wave : Mode
local Wave = class("Wave", Mode)

GameMode()

local M = Wave

function M:ctor()
    self.modName = "Wave"
    self.author = "WindyVerse Pte. Ltd."
    self.description = "防守战"
    self.isDefinitiveOnly = true
end

function M:GetGameModeName(lang)
    if lang == "CN" then
        return "防守战"
    else
        return "Defence"
    end
end

function M:OnStartMode()
    ---@type ShanghaiWindy.Data.WaveMissionConfig
    self.curConfig = nil
    self.curWave = 0
    self.uid = 0
    self.escapeEnemyCount = 0
    self.dstPoints = {}

    self:AddListeners()

    CustomOptionUIAPI.ToggleUI(true)
    local configs = ConfigAPI.GetWaveMissionConfigs()

    for i = 0, configs.Length - 1 do
        local config = configs[i]
        local displayName = config.displayName:GetDisplayName()

        CustomOptionUIAPI.AddTitle("Defence")
        CustomOptionUIAPI.AddButton("Exit", ">", function()
            ModeAPI.ExitMode()
        end)

        CustomOptionUIAPI.AddButton(displayName, "Play", function()
            CustomOptionUIAPI.ToggleUI(false)

            self.curConfig = config
            local mapData = MapAPI.GetMapDataByGuid(self.curConfig.mapGuid)
            ModeAPI.LoadBattleScene(mapData, function()
                self:OnBattleSceneLoaded()
            end)
        end)
    end
end

function M:OnExitMode()
    self:RemoveListeners()
    CustomOptionUIAPI.ToggleUI(false)
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

function M:OnBattleSceneLoaded()
    TeamAPI.SetPlayerTeam(self.curConfig.playerTeam)

    -- Pick player vehicle
    local minRank = self.curConfig.playerPickMinRank
    local maxRank = self.curConfig.playerPickMaxRank
    local vehicleList = VehicleAPI.GetFilteredVehicles(minRank, maxRank)
    ModeAPI.ShowPickVehicleUIWithList(true, vehicleList)
end

function M:OnPickMainPlayerVehicle(evtData)
    ---@type ShanghaiWindy.Core.AbstractBattlePlayer
    self.mainBattlePlayer = BattlePlayerAPI.CreateOfflineMainPlayer(-1, nil)
    ModeAPI.AddBattlePlayer(self.mainBattlePlayer)

    self.mainBattlePlayer:CreateVehicle(evtData.VehicleInfo, self.curConfig.playerTransformInfo.pos,
        TransformAPI.EulerToRot(self.curConfig.playerTransformInfo.eulerAngle))

    self:StartBattle()
end

function M:StartBattle()
    ModeAPI.LoadBattleUI(function()
        self:GenWaveInfo(self.curWave)
    end)
end

function M:GenWaveInfo(waveIndex)
    local waveInfo = self.curConfig.waveInfos[waveIndex]

    local points = {}
    local rot = TransformAPI.EulerToRot(waveInfo.destTransformInfo.eulerAngle)
    local p1 = rot * Vector3.forward * waveInfo.destSize.z * 0.5    -- forward
    local p2 = rot * Vector3.right * waveInfo.destSize.x * 0.5      -- right
    local p3 = -(rot * Vector3.forward * waveInfo.destSize.z * 0.5) -- backward
    local p4 = -(rot * Vector3.right * waveInfo.destSize.x * 0.5)   -- left
    table.insert(points, waveInfo.destTransformInfo.pos + p1 + p2)  -- forward right
    table.insert(points, waveInfo.destTransformInfo.pos + p1 + p4)  -- forward left
    table.insert(points, waveInfo.destTransformInfo.pos + p3 + p4)  -- backward left
    table.insert(points, waveInfo.destTransformInfo.pos + p3 + p2)  -- backward right

    local meshId = MeshAPI.CreateMesh(points, waveInfo.destSize.y)
    local meshInstance = MeshAPI.GetMesh(meshId)
    MaterialAPI.AsyncApplyMaterial("6873b9de-42d2-45f9-8960-5738d67d0540", meshInstance)

    self.dstPoints = points

    self.friendPlayerList = self:GenerateAttackInfo(waveInfo.friendWaveList, TeamAPI.GetPlayerTeam())
    self.enemyPlayerList = self:GenerateAttackInfo(waveInfo.enemyWaveList, TeamAPI.GetEnemyTeam())

    for k, v in pairs(self.enemyPlayerList) do
        ---@type ShanghaiWindy.Core.AbstractBattlePlayer
        local botPlayer = v
        botPlayer.OnVehicleDestroyed:AddListener(function()
            self:CheckWaveLogic()
        end)
    end
end

---@param attackInfos ShanghaiWindy.Data.WaveAttackInfo[]
function M:GenerateAttackInfo(attackInfos, botTeam)
    local playerList = {}

    for i = 0, attackInfos.Length - 1 do
        local attackInfo = attackInfos[i]
        ---@type VehicleInfo
        local vehicleInfo = VehicleAPI.GetVehicleInfoByGuid(attackInfo.vehicleGuid)

        for j = 0, attackInfo.waveTransformInfos.Length - 1 do
            local waveTransformInfo = attackInfo.waveTransformInfos[j]

            self.uid = self.uid + 1

            ---@type ShanghaiWindy.Core.AbstractBattlePlayer
            local botPlayer = BattlePlayerAPI.CreateOfflineBotPlayer(self.uid, BattlePlayerAPI.GetRandomBotName(), {})
            botPlayer.BotTeam = botTeam

            ModeAPI.AddBattlePlayer(botPlayer)

            local vehicle = botPlayer:CreateVehicle(vehicleInfo, waveTransformInfo.pos,
                TransformAPI.EulerToRot(waveTransformInfo.eulerAngle))

            table.insert(playerList, botPlayer)

            if botTeam == TeamAPI.GetEnemyTeam() then
                -- TODO: add a more generic bot fsm
                local defenceLogic = BotAPI.GetTankDefenceBotLogic()
                vehicle.thinkLogic = defenceLogic

                botPlayer.OnVehicleLoaded:AddListener(function()
                    defenceLogic:SetWayPoints(attackInfo.waveWayPoints)
                end)
            end
        end
    end

    return playerList
end

function M:CheckWaveLogic()
    for k = #self.enemyPlayerList, 1, -1 do
        ---@type ShanghaiWindy.Core.AbstractBattlePlayer
        local botPlayer = self.enemyPlayerList[k]
        if not botPlayer.IsAlive then
            table.remove(self.enemyPlayerList, k)
            ModeAPI.RemoveBattlePlayer(botPlayer.Uid)
        end
    end

    local totalEnemyVehicleCount = #self.enemyPlayerList

    if self.escapeEnemyCount >= self.curConfig.maxEscapeEnemyCount then
        self:JumpNextStage(true)
    end

    if totalEnemyVehicleCount == 0 then
        self:JumpNextStage(false)
        return
    end

    if totalEnemyVehicleCount - self.escapeEnemyCount <= 0 then
        self:JumpNextStage(false)
        return
    end
end

function M:JumpNextStage(isDefeat)
    if isDefeat then
        ModeAPI.ShowVictoryOrDefeat(false)
        return
    end

    self.curWave = self.curWave + 1

    if self.curWave >= self.curConfig.waveInfos.Length then
        -- Battle end
        ModeAPI.ShowVictoryOrDefeat(true)
    else
        self:GenWaveInfo(self.curWave)
    end
end

function M:OnUpdated()
    if #self.dstPoints > 0 then
        for k = #self.enemyPlayerList, 1, -1 do
            ---@type ShanghaiWindy.Core.AbstractBattlePlayer
            local botPlayer = self.enemyPlayerList[k]
            local isPointInPolygon = MeshAPI.IsPointInPolygon(botPlayer.Vehicle:GetPosition(), self.dstPoints)

            if isPointInPolygon then
                self.escapeEnemyCount = self.escapeEnemyCount + 1
                table.remove(self.enemyPlayerList, k)
                ModeAPI.RemoveBattlePlayer(botPlayer.Uid)

                self:CheckWaveLogic()
            end
        end
    end
end

function M:IsProxyBattle()
    return false
end

return M
