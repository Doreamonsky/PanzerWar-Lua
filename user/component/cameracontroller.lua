--- @class CameraController
--- Lua 侧的方向键形式的按键控制器 (Direction key style camera controller in Lua)
local CameraController = class("CameraController", Entity)

--- @param uiTransform Transfom 按钮 (Button)
--- @param cameraTargetTransform Transform 摄像机目标 (Camera target)
--- @param cameraTargetTransform Transform 摄像机 Transform (Camera Transform)
--- @param originPos Vector3 初始坐标 (Initial coordinates)
function CameraController:Init(uiTransform, cameraTransform, cameraTargetTransform)
    -- 监听 GizmoConfig 变更事件 (Listen for GizmoConfig change events)
    EventSystem.AddListener(EventDefine.OnGizmoConfigChanged, self.RefreshCameraController, self)

    self.joystickMove = Vector2.zero
    self.cameraDelta = Vector3.zero
    self.cameraTransform = cameraTransform
    self.cameraTargetTrans = cameraTargetTransform
    self.cameraOriginPos = cameraTargetTransform.position

    self.keyboardCameraMoveSpeed = 5 -- 摄像机移动速度，按 Shift 会加快 (Camera move speed, holding Shift will speed it up)

    self.keypadGo = uiTransform:Find("Keypad").gameObject
    self.joystickGo = uiTransform:Find("Joystick").gameObject

    self.upBtn = uiTransform:Find("UpBtn"):GetComponent(typeof(PressButton))
    self.downBtn = uiTransform:Find("DownBtn"):GetComponent(typeof(PressButton))
    self.forwardBtn = uiTransform:Find("Keypad/ForwardBtn"):GetComponent(typeof(PressButton))
    self.backwardBtn = uiTransform:Find("Keypad/BackwardBtn"):GetComponent(typeof(PressButton))
    self.leftBtn = uiTransform:Find("Keypad/LeftBtn"):GetComponent(typeof(PressButton))
    self.rightBtn = uiTransform:Find("Keypad/RightBtn"):GetComponent(typeof(PressButton))
    self.moveJoystick = uiTransform:Find("Joystick"):GetComponent(typeof(Joystick))

    -- 添加摄像机控制按钮的监听器 (Add listeners for camera control buttons)
    ---------------------摄像机操控 (Camera control) --------------------------
    self.upBtn.onPressed:AddListener(
        function()
            self:makeCameraTargetDelta(Vector3.up, false)
        end
    )

    self.downBtn.onPressed:AddListener(
        function()
            self:makeCameraTargetDelta(Vector3.down, false)
        end
    )

    self.forwardBtn.onPressed:AddListener(
        function()
            self:makeCameraTargetDelta(Vector3.forward, true)
        end
    )

    self.backwardBtn.onPressed:AddListener(
        function()
            self:makeCameraTargetDelta(Vector3.back, true)
        end
    )

    self.leftBtn.onPressed:AddListener(
        function()
            self:makeCameraTargetDelta(Vector3.left, true)
        end
    )

    self.rightBtn.onPressed:AddListener(
        function()
            self:makeCameraTargetDelta(Vector3.right, true)
        end
    )
    -- 注册摇杆移动事件 (Register joystick movement events)
    self.moveJoystick:OnStartJoystickMovement("+", function(p, val)
        self.joystickMove = val
    end)

    self.moveJoystick:OnJoystickMovement("+", function(p, val)
        self.joystickMove = val
    end)

    self.moveJoystick:OnEndJoystickMovement("+",
        function(p)
            self.joystickMove = Vector2.zero
        end)
    ------------------------------------------------------

    self:RefreshCameraController()
end

function CameraController:update()
    -- 检查摇杆移动 (Check for joystick movement)
    if self.joystickMove ~= nil then
        if self.joystickMove.sqrMagnitude ~= 0 then
            self:makeCameraTargetDelta(Vector3.forward * self.joystickMove.y + Vector3.right * self.joystickMove.x, true)
        end
    end

    -- PC 输入 (PC input)
    if not Application.isMobile then
        -- 检查键盘输入 (Check for keyboard input)
        if Input.GetKey(KeyCode.W) then
            self:makeCameraTargetDelta(Vector3.forward, true)
        end

        if Input.GetKey(KeyCode.A) then
            self:makeCameraTargetDelta(Vector3.left, true)
        end

        if Input.GetKey(KeyCode.S) then
            self:makeCameraTargetDelta(Vector3.back, true)
        end

        if Input.GetKey(KeyCode.D) then
            self:makeCameraTargetDelta(Vector3.right, true)
        end

        if Input.GetKey(KeyCode.E) then
            self:makeCameraTargetDelta(Vector3.up, false)
        end

        if Input.GetKey(KeyCode.Q) then
            self:makeCameraTargetDelta(Vector3.down, false)
        end

        -- 检查 Shift 键 (Check for Shift key)
        if Input.GetKeyDown(KeyCode.LeftShift) then
            self.keyboardCameraMoveSpeed = 10
        end

        if Input.GetKeyUp(KeyCode.LeftShift) then
            self.keyboardCameraMoveSpeed = 5
        end
    end
end

function CameraController:dispose()
    -- 移除 GizmoConfig 变更事件监听器 (Remove listener for GizmoConfig change events)
    EventSystem.RemoveListener(EventDefine.OnGizmoConfigChanged, self.RefreshCameraController, self)
end

function CameraController:RefreshCameraController()
    -- 根据 GizmoConfig 配置更新摄像机控制器类型 (Update camera controller type based on GizmoConfig configuration)
    if GizmoConfig.config.CameraControllerType == CameraControllerType.Keypad then
        self.keypadGo:SetActive(true)
        self.joystickGo:SetActive(false)
    elseif GizmoConfig.config.CameraControllerType == CameraControllerType.Joystick then
        self.keypadGo:SetActive(false)
        self.joystickGo:SetActive(true)
    end
end

--- 调整摄像机聚焦位置 (Adjust camera focus position)
--- @param delta Vector3 位置增量 (Position delta)
--- @param isProjectPlane boolean 是否投影到 XZ 平面 (Whether to project onto the XZ plane)
function CameraController:makeCameraTargetDelta(delta, isProjectPlane)
    if delta.sqrMagnitude ~= 0 then
        -- 移动坐标时候，禁止输入 (Disable input when moving coordinates)
        if DIYHandleManager.Instance.isDragging then
            return
        end

        -- 计算摄像机位置增量 (Calculate camera position delta)
        delta = delta * Time.deltaTime * self.keyboardCameraMoveSpeed * GizmoConfig.config.CameraMoveScale

        if isProjectPlane then
            delta = Vector3.ProjectOnPlane(self.cameraTransform:TransformVector(delta), Vector3.up)
        end

        self.cameraDelta = self.cameraDelta + delta

        if self.cameraDelta.y < 0 then
            self.cameraDelta = Vector3(self.cameraDelta.x, 0, self.cameraDelta.z)
        end

        self.cameraTargetTrans.position = self.cameraDelta + self.cameraOriginPos
    end
end

--- 聚焦目标 (Focus target)
--- @param targetPosition Vector3 目标位置 (Target position)
function CameraController:focusTarget(targetPosition)
    self.cameraDelta = targetPosition - self.cameraOriginPos
    self.cameraTargetTrans.position = self.cameraDelta + self.cameraOriginPos
end

return CameraController
