local Mode = require("frame.game.mode")

---@class PlayField : Mode
local PlayField = class("PlayField", Mode)

GameMode()

local M = PlayField

function M:ctor()
    self.modName = "PlayField"
    self.author = "官方"
    self.description = "生成坦克，并单挑"
end

function M:GetGameModeName(lang)
    if lang == "CN" then
        return "试车场"
    else
        return "Play Field"
    end
end

function M:OnStartMode()
    self:AddListeners()

    -- Add main player
    ---@type ShanghaiWindy.Core.AbstractBattlePlayer
    self.mainBattlePlayer = BattlePlayerAPI.CreateOfflineMainPlayer(-1, nil)
    ModeAPI.AddBattlePlayer(self.mainBattlePlayer)

    self.mainBattlePlayer.OnVehicleLoaded:AddListener(function()
        ModeAPI.EnableCheat()
    end)

    self.mainBattlePlayer.OnGameObjectDestroyed:AddListener(function()
        ModeAPI.DisableCheat()
    end)

    ModeAPI.ShowPickVehicleUI(true)
    self.mainBattlePlayer.OnGameObjectDestroyed:AddListener(function()
        ModeAPI.ShowPickVehicleUI(true)
    end)

    ModeAPI.ToggleScore(false)
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

function M:OnPickMainPlayerVehicle(evtData)
    local vehicleInfo = evtData.VehicleInfo

    SpawnAPI.AsyncSpawn(self.mainBattlePlayer:GetTeam(), function(trans)
        self.mainBattlePlayer:CreateVehicle(vehicleInfo, trans.position, trans.rotation)
    end)
end

function M:IsProxyBattle()
    return true
end


function M:GetMapMode()
    return MODE_PLAY_FIELD
end

return M
