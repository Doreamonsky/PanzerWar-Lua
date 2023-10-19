local Mode = require("frame.game.mode")

---@class CaptureZone : Mode
local CaptureZone = class("CaptureZone", Mode)

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
    ---@type ShanghaiWindy.Data.CaptureZoneModeConfig
    self.curConfig = nil
    self:GetConfigStorage()
    self:RefreshOptions()
    self:AddListeners()
end

function M:OnUpdated()
end

function M:OnExitMode()
    CustomOptionUIAPI.ToggleUI(false)
    LuaUIManager.RemoveUI(self.captureZoneUIIndex)
    self:RemoveListeners()
end

function M:RefreshOptions()
    CustomOptionUIAPI.ToggleUI(true)
    local configs = ConfigAPI.GetCaptureZoneConfigs()

    for i = 0, configs.Length - 1 do
        local config = configs[i]
        local displayName = config.displayName:GetDisplayName()

        CustomOptionUIAPI.AddTitle("CaptureZone")
        CustomOptionUIAPI.AddButton("Exit", ">", function()
            ModeAPI.ExitMode()
        end)

        CustomOptionUIAPI.AddButton(displayName, "Play", function()
            self:OnConfirmInfo(config)
        end)
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

    CustomOptionUIAPI.AddSlider("ScoreToEnd", self.scoreToEnd, 1, 200, true, function(res)
        self.scoreToEnd = res
    end)
end

function M:OnConfirmInfo(config)
    self.curConfig = config

    CustomOptionUIAPI.ToggleUI(false)

    local mapData = MapAPI.GetMapDataByGuid(self.curConfig.mapGuid)
    ModeAPI.LoadBattleScene(mapData, function()
        self:OnBattleSceneLoaded()
    end)
end

function M:OnBattleSceneLoaded()
    self.mainPlayerList = VehicleAPI.GetFilteredVehicles(self.friendMinRank, self.friendMaxRank)

    for i = 0, self.curConfig.captureZones.Length - 1 do
        local captureZone = self.curConfig.captureZones[i]
        local meshId = MeshAPI.CreateMesh(captureZone.zonePoints, 5)
        local mesh = MeshAPI.GetMesh(meshId)

        MaterialAPI.AsyncApplyMaterial("6873b9de-42d2-45f9-8960-5738d67d0540", mesh)

        local id = CaptureZoneAPI.AddCaptureZone(captureZone.zoneCapturePoint.pointName,
            captureZone.zoneCapturePoint.position)

        if captureZone.zoneCapturePoint.defaultOwner ~= TeamAPI.GetNoneTeam() then
            CaptureZoneAPI.CapturingZone(id, captureZone.zoneCapturePoint.defaultOwner, 1)
        end
    end

    CameraAPI.SetBackgroundCameraPosition(self.curConfig.backgroundCameraTransformInfo.pos)
    CameraAPI.SetBackgroundCameraEulerAngles(self.curConfig.backgroundCameraTransformInfo.eulerAngle)

    ModeAPI.LoadBattleUI(function()
        self.captureZoneUIIndex = LuaUIManager.CreateUI(CaptureZoneView.new(), CaptureZoneController.new(),
            "f5ec298e-6852-487a-95a8-00191a792ad4",
            "LuaCaptureZone.prefab")
    end)
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

function M:AddListeners()

end

function M:RemoveListeners()
end

function M:IsProxyBattle()
    return false
end

return M
