local FreeCameraMode = class("FreeCameraMode")

GameMode()

function FreeCameraMode:ctor()
    self.modName = "自由摄像机"
    self.author = "WindyVerse Pte. Ltd."
    self.description = "自由摄像机"
end

function FreeCameraMode:GetGameModeName(userLang)
    if userLang == "CN" then
        return "自由摄像机"
    else
        return "Free camera"
    end
end

function FreeCameraMode:OnStartMode()
    local mapData = MapDataManager.Instance.currentMap
    -- 放置自由摄像机
    CSharpAPI.CreateFreeCamera(mapData.sceneCameraPos, mapData.sceneCameraRot)
end

function FreeCameraMode:OnExitMode()
end

return FreeCameraMode
