FreeCameraMode = {}

FreeCameraMode.onStartMode = function()
    local mapData = MapDataManager.Instance.currentMap
    -- 放置自由摄像机
    CSharpAPI.CreateFreeCamera(mapData.sceneCameraPos, mapData.sceneCameraRot)
end

FreeCameraMode.onExitMode = function()
    print("结束游戏模式")
end
