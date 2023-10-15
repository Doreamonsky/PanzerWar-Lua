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

    self:AddListeners()


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
            CustomOptionUIAPI.ToggleUI(false)

            self.curConfig = config
            local mapData = MapAPI.GetMapDataByGuid(self.curConfig.mapGuid)
            ModeAPI.LoadBattleScene(mapData, function()
                self:OnBattleSceneLoaded()
            end)
        end)
    end
end

function M:OnBattleSceneLoaded()
    for k, captureZone in pairs(self.curConfig.captureZones) do
        local meshId = MeshAPI.CreateMesh(captureZone.zonePoints, 5)
        local mesh = MeshAPI.GetMesh(meshId)

        MaterialAPI.AsyncApplyMaterial("6873b9de-42d2-45f9-8960-5738d67d0540", mesh)

        CaptureZoneAPI.AddCaptureZone(captureZone.zoneName, captureZone.captureFlagPoint)
    end

    ModeAPI.LoadBattleUI()
end

function M:OnExitMode()
    self:RemoveListeners()
end

function M:AddListeners()

end

function M:RemoveListeners()
end

function M:IsProxyBattle()
    return false
end

return M
