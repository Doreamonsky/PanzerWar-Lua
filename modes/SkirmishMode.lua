--- 离线重生模式
SkirmishMode = {}

local this = SkirmishMode

--- 初始化数据
this.initData = function()
    this.TeamAStartPoints = {}
    this.TeamBStartPoints = {}
    this.FriendBotVehicleList = {}
    this.EnemyBotVehicleList = {}
    this.TeamACount = 0
    this.TeamBCount = 0
    this.TeamAMaxNumber = 5
    this.TeamBMaxNumber = 5
    this.FriendScore = 0
    this.EnemyScore = 0
    this.isPopEnd = false -- 防止结算界面重复出现
end

--- 初始化界面
this.initUI = function(uiTransform)
    -- 开战界面绑定
    this.friendNumberInput = uiTransform:Find("Startup/Options/FriendNumber/InputField"):GetComponent("InputField")
    this.enemyNumberInput = uiTransform:Find("Startup/Options/EnemyNumber/InputField"):GetComponent("InputField")
    this.upperRankInput = uiTransform:Find("Startup/Options/UpperRank/InputField"):GetComponent("InputField")
    this.lowerRankInput = uiTransform:Find("Startup/Options/LowerRank/InputField"):GetComponent("InputField")
    this.scoreToFinishInput = uiTransform:Find("Startup/Options/ScoreToFinish/InputField"):GetComponent("InputField")
    this.startBattleBtn = uiTransform:Find("Startup/Options/StartBattle/Button"):GetComponent("Button")
    this.maxRandomPoolInputField =
        uiTransform:Find("Startup/Options/MaxRandomPool/InputField"):GetComponent("InputField")
    this.enemyRankOffsetInputField =
        uiTransform:Find("Startup/Options/EnemyRankOffSet/InputField"):GetComponent("InputField")
    this.startupGo = uiTransform:Find("Startup").gameObject

    -- 比分绑定
    this.scoreText = uiTransform:Find("ScoreBar/Score"):GetComponent("Text")

    -- 结算绑定
    this.continueBtn = uiTransform:Find("FinishBar/ContinueBtn"):GetComponent("Button")
    this.endBtn = uiTransform:Find("FinishBar/EndBtn"):GetComponent("Button")
    this.finishGo = uiTransform:Find("FinishBar").gameObject
    this.finishWinGo = uiTransform:Find("FinishBar/WinText").gameObject
    this.finishLoseGo = uiTransform:Find("FinishBar/LoseText").gameObject
end

--- 初始化模式逻辑
this.initMode = function()
    -- 寻找出生点
    this.TeamAStartPoints = GameObject.FindGameObjectsWithTag("TeamAStartPoint")
    this.TeamBStartPoints = GameObject.FindGameObjectsWithTag("TeamBStartPoint")

    URPMainUIManager.Instance.audioListener.enabled = true -- 打开界面 Audio Listener 防止警告
    URPMainUIManager.Instance.selectVehicleBar:SetActive(true) -- 打开选车界面

    -- 结束战斗比分
    this.scoreToFinish = tonumber(this.scoreToFinishInput.text)

    -- 设置敌我最大人数
    local firendNumber = tonumber(this.friendNumberInput.text)
    local enemyNumber = tonumber(this.enemyNumberInput.text)

    if GameDataManager.PlayerTeam == TeamManager.Team.red then
        this.TeamAMaxNumber = firendNumber
        this.TeamBMaxNumber = enemyNumber
    else
        this.TeamAMaxNumber = enemyNumber
        this.TeamBMaxNumber = firendNumber
    end

    -- 设置对战等级区间
    local lowerRank = tonumber(this.lowerRankInput.text)
    local upperRank = tonumber(this.upperRankInput.text)

    local playerVehicle = VehicleInfoManager.Instance:GetVehicleInfo(URPCustomModeOfflineManager.PlayerVehicleName) -- 玩家的坦克
    local maxRandomPoolCount = tonumber(this.maxRandomPoolInputField.text) -- 坦克池，资源预热防止战斗卡顿，越大越吃内存

    -- 寻找合适的载具
    --- @type VehicleInfo[]
    local availableVehicleList =
        VehicleInfoManager.Instance:GetAllDriveableVehicleList():FindAll(
        function(x)
            return playerVehicle:GetRank() - lowerRank <= x:GetRank() and
                x:GetRank() <= playerVehicle:GetRank() + upperRank
        end
    )

    local enemyRank = playerVehicle:GetRank() + tonumber(this.enemyRankOffsetInputField.text)

    local enemyAvailableVehicleList =
        VehicleInfoManager.Instance:GetAllDriveableVehicleList():FindAll(
        function(x)
            return enemyRank - lowerRank <= x:GetRank() and x:GetRank() <= enemyRank + upperRank
        end
    )

    -- 通知创建载具列表
    URPMainUIManager.Instance:CreateVehicleUIs(playerVehicle, availableVehicleList)

    -- 载具选择后的回调
    URPMainUIManager.Instance.OnVehicleSelected:AddListener(
        function(vehicleInfo)
            URPMainUIManager.Instance.selectVehicleBar:SetActive(false)
            this.CreatePlayerVehicle(vehicleInfo)
        end
    )

    -- 载具被击毁的回调
    GameEventManager.OnNewVehicleDestroyed:AddListener(
        function(destroyedVehicle)
            --- Bot 被击毁，更新逻辑
            if Core.BaseInitSystem.IsLocalPlayer(destroyedVehicle._InstanceNetType) == false then
                if destroyedVehicle.ownerTeam == TeamManager.Team.red then
                    this.TeamACount = this.TeamACount - 1
                else
                    this.TeamBCount = this.TeamBCount - 1
                end
            end

            this.UpdateScore(destroyedVehicle)
            this.UpdateModeLogic()
        end
    )

    -- 载具物体清楚的回调
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

    -- Bot 列表
    this.FriendBotVehicleList = CSharpAPI.GetBotVehicleList(availableVehicleList, maxRandomPoolCount)
    this.EnemyBotVehicleList = CSharpAPI.GetBotVehicleList(enemyAvailableVehicleList, maxRandomPoolCount)
    this.UpdateModeLogic()
end

this.onStartMode = function()
    this.initData()

    CSharpAPI.LoadAssetBundle(
        "LuaSkirmish",
        "mod",
        function(asset)
            if asset ~= nil then
                local go = GameObject.Instantiate(asset)
                this.instanceGo = go
                this.initUI(go.transform)
                this.startBattleBtn.onClick:AddListener(
                    function()
                        this.startupGo:SetActive(false)
                        this.initMode()
                    end
                )
            end
        end
    )
end

this.onExitMode = function()
end

--- Logic 战斗结束
--- @param isWin boolean 是否胜利
this.onBattleEnd = function(isWin)
    if not this.isPopEnd then
        Time.timeScale = 0

        this.finishGo:SetActive(true)

        if isWin then
            this.finishWinGo:SetActive(true)
        else
            this.finishLoseGo:SetActive(true)
        end

        this.continueBtn.onClick:AddListener(
            function()
                Time.timeScale = 1
                this.finishGo:SetActive(false)
            end
        )

        this.endBtn.onClick:AddListener(
            function()
                Time.timeScale = 1
                CSharpAPI.OnLuaExitModeReq:Invoke()
                GameObject.Destroy(this.instanceGo)
            end
        )
    end

    this.isPopEnd = true
end

--- 更新比分
this.UpdateScore = function(destroyedVehicle)
    local ownerTeam = destroyedVehicle.ownerTeam

    if ownerTeam == GameDataManager.PlayerTeam then
        this.EnemyScore = this.EnemyScore + 1
    else
        this.FriendScore = this.FriendScore + 1
    end

    this.scoreText.text = tostring(this.FriendScore) .. ":" .. tostring(this.EnemyScore)

    -- 胜负条件
    if this.FriendScore >= this.scoreToFinish then
        this.onBattleEnd(true)
    end

    if this.EnemyScore >= this.scoreToFinish then
        this.onBattleEnd(false)
    end
end

--- 模式核心逻辑，循环遍历人数，补充缺失人数
this.UpdateModeLogic = function()
    if this.FriendBotVehicleList.Count ~= 0 and this.EnemyBotVehicleList.Count ~= 0 then
        if this.TeamACount < this.TeamAMaxNumber then
            local delta = this.TeamAMaxNumber - this.TeamACount - 1
            for i = 1, 1 + delta do
                this.TeamACount = this.TeamACount + 1
                this.CreateBotVehicle(TeamManager.Team.red)
            end
        end

        if this.TeamBCount < this.TeamBMaxNumber then
            local delta = this.TeamBMaxNumber - this.TeamBCount - 1
            for i = 1, 1 + delta do
                this.TeamBCount = this.TeamBCount + 1
                this.CreateBotVehicle(TeamManager.Team.blue)
            end
        end
    end
end

--- 创建玩家载具
--- @param vehicleInfo VehicleInfo
this.CreatePlayerVehicle = function(vehicleInfo)
    local startPoints = nil

    if GameDataManager.PlayerTeam == TeamManager.Team.red then
        startPoints = this.TeamAStartPoints
    else
        startPoints = this.TeamBStartPoints
    end

    URPCustomModeOfflineManager.Instance.respawnPointModule:RequestTrans(
        startPoints,
        function(trans)
            if vehicleInfo.type == VehicleInfo.Type.Ground then
                local tankInitSystem =
                    CSharpAPI.CreateTankPlayer(vehicleInfo:GetVehicleName(), trans.position, trans.rotation)
                tankInitSystem.OnVehicleLoaded:AddListener(this.ClosePlayerUI)
            elseif vehicleInfo.type == VehicleInfo.Type.Aviation then
                local flightInitSystem =
                    CSharpAPI.CreateFlightPlayer(vehicleInfo:GetVehicleName(), trans.position, trans.rotation, false)
                flightInitSystem.OnVehicleLoaded:AddListener(this.ClosePlayerUI)
            end
        end,
        0,
        true
    )
end

this.CreateBotVehicle = function(team)
    local startPoints = nil

    if team == TeamManager.Team.red then
        startPoints = this.TeamAStartPoints
    else
        startPoints = this.TeamBStartPoints
    end

    URPCustomModeOfflineManager.Instance.respawnPointModule:RequestTrans(
        startPoints,
        function(trans)
            local vehicleInfo = nil

            if team == GameDataManager.PlayerTeam then
                vehicleInfo = CSharpAPI.RandomVehicleFromList(this.FriendBotVehicleList)
            else
                vehicleInfo = CSharpAPI.RandomVehicleFromList(this.EnemyBotVehicleList)
            end

            if vehicleInfo.type == VehicleInfo.Type.Ground then
                CSharpAPI.CreateTankBot(vehicleInfo:GetVehicleName(), trans.position, trans.rotation, team)
            end
        end,
        0,
        true
    )
end

this.ClosePlayerUI = function()
    AudioListener.volume = 1
    URPMainUIManager.Instance.audioListener.enabled = false
    URPMainUIManager.Instance.backgroundCamera.enabled = false
    MouseLockModule.Instance:OnHide()
end
