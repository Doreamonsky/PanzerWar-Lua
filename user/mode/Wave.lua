local Mode = require("frame.game.mode")

---@class Wave : Mode
local Wave = class("Wave", Mode)

GameMode()

local M = Wave

function M:ctor()
    self.modName = "Wave"
    self.author = "官方"
    self.description = "防守战"
end

function M:GetGameModeName(lang)
    if lang == "EN" then
        return "Defence"
    else
        return "防守战"
    end
end

function M:OnStartMode()
    ---@type ShanghaiWindy.Data.WaveMissionConfig
    self.curConfig = nil
    self.curWave = 0
    self.uid = 0

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
        self:GenerateWaveInfo(self.curWave)
    end)
end

function M:GenerateWaveInfo(waveIndex)
    local waveInfo = self.curConfig.waveInfos[waveIndex]
    self:GenerateAttackInfo(waveInfo.friendWaveList, TeamAPI.GetPlayerTeam())
    self:GenerateAttackInfo(waveInfo.enemyWaveList, TeamAPI.GetEnemyTeam())
end

---@param attackInfos ShanghaiWindy.Data.WaveAttackInfo[]
function M:GenerateAttackInfo(attackInfos, botTeam)
    for i = 0, attackInfos.Length - 1 do
        local attackInfo = attackInfos[i]
        ---@type VehicleInfo
        local vehicleInfo = VehicleAPI.GetVehicleInfoByGuid(attackInfo.vehicleGuid)

        for j = 0, attackInfo.waveTransformInfos.Length - 1 do
            local waveTransformInfo = attackInfo.waveTransformInfos[j]

            self.uid = self.uid + 1

            ---@type ShanghaiWindy.Core.AbstractBattlePlayer
            local botPlayer = BattlePlayerAPI.CreateOfflineBotPlayer(self.uid, "装纷派蒙", {})
            botPlayer.BotTeam = botTeam

            print("Bot Player" .. vehicleInfo:GetDisplayName())

            ModeAPI.AddBattlePlayer(botPlayer)
            botPlayer:CreateVehicle(vehicleInfo, waveTransformInfo.pos,
                TransformAPI.EulerToRot(waveTransformInfo.eulerAngle))
        end
    end
end

function M:OnUpdated()
end

function M:IsProxyBattle()
    return false
end

function M:IsEnableCapturePoint()
    return false
end

return M
