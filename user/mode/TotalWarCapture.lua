--- 离线重生模式
local TotalWar = require("user.mode.TotalWar")

---@class TotalWarCapture : TotalWar
local M = class("TotalWarCapture", TotalWar)

GameMode()

function M:InitModeMeta()
    -- Mod Ctor
    self.modName = "全面冲突模式 （占点模式）"
    self.author = "官方"
    self.description = "双方空陆不间断冲突。（占点得分制）"
    self.isPreview = true
end

function M:GetGameModeName(userLang)
    if userLang == "EN" then
        return "Total War Mode (Capture)"
    else
        return "全面冲突模式 （占点）"
    end
end

function M:IsEnableCapturePoint()
    return true
end

return M
