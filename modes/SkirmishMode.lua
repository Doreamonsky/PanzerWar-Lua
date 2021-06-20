--- 离线征服模式 （占点）

SkirmishMode = {}

SkirmishMode.init = function()
    SkirmishMode.TeamAStartPoints = {}
    SkirmishMode.TeamBStartPoints = {}
    SkirmishMode.BotVehicleList = {}
    SkirmishMode.MaxTeamPlayers = 5
    SkirmishMode.TeamACount = 0
    SkirmishMode.TeamBCount = 0
end

SkirmishMode.onStartMode = function()
    SkirmishMode.init()

    SkirmishMode.TeamAStartPoints = GameObject.FindGameObjectsWithTag("TeamAStartPoint")
    SkirmishMode.TeamBStartPoints = GameObject.FindGameObjectsWithTag("TeamBStartPoint")

    URPMainUIManager.Instance.audioListener.enabled = true
    URPMainUIManager.Instance.selectVehicleBar:SetActive(true)

    local lowerRank = 2
    local upperRank = 1
    local playerVehicle = VehicleInfoManager.Instance:GetVehicleInfo(URPCustomModeOfflineManager.PlayerVehicleName)
    local maxRandomPoolCount = 25

    --- @type VehicleInfo[]
    local availableVehicleList =
        VehicleInfoManager.Instance:GetAllVehicleList():FindAll(
        function(x)
            return playerVehicle.rank - lowerRank <= x.rank and x.rank <= playerVehicle.rank + upperRank
        end
    )

    URPMainUIManager.Instance:UpdateVehicleList(playerVehicle, availableVehicleList)

    URPMainUIManager.Instance.OnVehicleSelected:AddListener(
        function(vehicleInfo)
            URPMainUIManager.Instance.selectVehicleBar:SetActive(false)
            SkirmishMode.CreatePlayerVehicle(vehicleInfo)
        end
    )

    GameEventManager.OnNewVehicleDestroyed:AddListener(
        function(destroyedVehicle)
            --- Bot 被击毁，更新逻辑
            if Core.BaseInitSystem.IsLocalPlayer(destroyedVehicle._InstanceNetType) == false then
                if destroyedVehicle.ownerTeam == TeamManager.Team.red then
                    SkirmishMode.TeamACount = SkirmishMode.TeamACount - 1
                else
                    SkirmishMode.TeamBCount = SkirmishMode.TeamBCount - 1
                end
            end

            SkirmishMode.ModeLogic()
        end
    )

    GameEventManager.OnNewVehicleRemoved:AddListener(
        function(initSystem)
            --- 玩家死亡，显示选车界面
            if Core.BaseInitSystem.IsLocalPlayer(initSystem._InstanceNetType) then
                AudioListener.volume = 0

                URPMainUIManager.Instance.audioListener.enabled = true
                URPMainUIManager.Instance.backgroundCamera.enabled = true

                URPMainUIManager.Instance.selectVehicleBar:SetActive(true)
                MouseLockModule.Instance:OnVisible()
            end
        end
    )

    SkirmishMode.BotVehicleList = CSharpAPI.GetBotVehicleList(availableVehicleList, maxRandomPoolCount)
    SkirmishMode.ModeLogic()
end

SkirmishMode.onExitMode = function()
end

--- 模式核心逻辑
SkirmishMode.ModeLogic = function()
    if SkirmishMode.BotVehicleList.Count ~= 0 then
        if SkirmishMode.TeamACount < SkirmishMode.MaxTeamPlayers then
            local delta = SkirmishMode.MaxTeamPlayers - SkirmishMode.TeamACount
            for i = 1, 1 + delta do
                SkirmishMode.TeamACount = SkirmishMode.TeamACount + 1
                SkirmishMode.CreateBotVehicle(TeamManager.Team.red)
            end
        end

        if SkirmishMode.TeamBCount < SkirmishMode.MaxTeamPlayers then
            local delta = SkirmishMode.MaxTeamPlayers - SkirmishMode.TeamBCount
            for i = 1, 1 + delta do
                SkirmishMode.TeamBCount = SkirmishMode.TeamBCount + 1
                SkirmishMode.CreateBotVehicle(TeamManager.Team.blue)
            end
        end
    end
end

--- 创建玩家载具
--- @param vehicleInfo VehicleInfo
SkirmishMode.CreatePlayerVehicle = function(vehicleInfo)
    local startPoints = nil

    if GameDataManager.PlayerTeam == TeamManager.Team.red then
        startPoints = SkirmishMode.TeamAStartPoints
    else
        startPoints = SkirmishMode.TeamBStartPoints
    end

    URPCustomModeOfflineManager.Instance.respawnPointModule:RequestTrans(
        startPoints,
        function(trans)
            if vehicleInfo.type == VehicleInfo.Type.Ground then
                local tankInitSystem =
                    CSharpAPI.CreateTankPlayer(vehicleInfo.vehicleName, trans.position, trans.rotation)
                tankInitSystem.OnVehicleLoaded:AddListener(SkirmishMode.ClosePlayerUI)
            elseif vehicleInfo.type == VehicleInfo.Type.Aviation then
                local flightInitSystem =
                    CSharpAPI.CreateFlightPlayer(vehicleInfo.vehicleName, trans.position, trans.rotation, false)
                flightInitSystem.OnVehicleLoaded:AddListener(SkirmishMode.ClosePlayerUI)
            end
        end,
        0,
        true
    )
end

SkirmishMode.CreateBotVehicle = function(team)
    local startPoints = nil

    if team == TeamManager.Team.red then
        startPoints = SkirmishMode.TeamAStartPoints
    else
        startPoints = SkirmishMode.TeamBStartPoints
    end

    URPCustomModeOfflineManager.Instance.respawnPointModule:RequestTrans(
        startPoints,
        function(trans)
            local vehicleInfo = CSharpAPI.RandomVehicleFromList(SkirmishMode.BotVehicleList)
            if vehicleInfo.type == VehicleInfo.Type.Ground then
                CSharpAPI.CreateTankBot(vehicleInfo.vehicleName, trans.position, trans.rotation, team)
            end
        end,
        0,
        true
    )
end

SkirmishMode.ClosePlayerUI = function()
    AudioListener.volume = 1
    URPMainUIManager.Instance.audioListener.enabled = false
    URPMainUIManager.Instance.backgroundCamera.enabled = false
end
