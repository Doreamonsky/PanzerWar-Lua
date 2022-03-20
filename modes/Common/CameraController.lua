--- @class CameraController
--- Lua 侧的方向键形式的按键控制器
CameraController = class("CameraController", nil)

--- @param uiTransform Transfom 按钮
--- @param cameraTargetTransform Transform 摄像机目标
--- @param cameraTargetTransform Transform 摄像机 Transform
--- @param originPos Vector3 初始坐标
function CameraController:Init(uiTransform, cameraTransform, cameraTargetTransform)
    self.cameraDelta = Vector3.zero
    self.cameraTransform = cameraTransform
    self.cameraTargetTrans = cameraTargetTransform
    self.cameraOriginPos = cameraTargetTransform.position

    self.keyboardCameraMoveSpeed = 5 -- 摄像机移动速度，按 Shift 会加快

    self.upBtn = uiTransform:Find("UpBtn"):GetComponent("Button")
    self.downBtn = uiTransform:Find("DownBtn"):GetComponent("Button")
    self.forwardBtn = uiTransform:Find("ForwardBtn"):GetComponent("Button")
    self.backwardBtn = uiTransform:Find("BackwardBtn"):GetComponent("Button")
    self.leftBtn = uiTransform:Find("LeftBtn"):GetComponent("Button")
    self.rightBtn = uiTransform:Find("RightBtn"):GetComponent("Button")

    ---------------------摄像机操控--------------------------
    self.upBtn.onClick:AddListener(
        function()
            self:makeCameraTargetDelta(Vector3.up, false)
        end
    )

    self.downBtn.onClick:AddListener(
        function()
            self:makeCameraTargetDelta(Vector3.down, false)
        end
    )

    self.forwardBtn.onClick:AddListener(
        function()
            self:makeCameraTargetDelta(Vector3.forward, true)
        end
    )

    self.backwardBtn.onClick:AddListener(
        function()
            self:makeCameraTargetDelta(Vector3.back, true)
        end
    )

    self.leftBtn.onClick:AddListener(
        function()
            self:makeCameraTargetDelta(Vector3.left, true)
        end
    )

    self.rightBtn.onClick:AddListener(
        function()
            self:makeCameraTargetDelta(Vector3.right, true)
        end
    )
    ------------------------------------------------------
end

function CameraController:update()
    -- PC 输入
    if not Application.isMobile then
        if Input.GetKey(KeyCode.W) then
            self:makeCameraTargetDelta(Vector3.forward * Time.deltaTime * self.keyboardCameraMoveSpeed, true)
        end

        if Input.GetKey(KeyCode.A) then
            self:makeCameraTargetDelta(Vector3.left * Time.deltaTime * self.keyboardCameraMoveSpeed, true)
        end

        if Input.GetKey(KeyCode.S) then
            self:makeCameraTargetDelta(Vector3.back * Time.deltaTime * self.keyboardCameraMoveSpeed, true)
        end

        if Input.GetKey(KeyCode.D) then
            self:makeCameraTargetDelta(Vector3.right * Time.deltaTime * self.keyboardCameraMoveSpeed, true)
        end

        if Input.GetKey(KeyCode.E) then
            self:makeCameraTargetDelta(Vector3.up * Time.deltaTime * self.keyboardCameraMoveSpeed, false)
        end

        if Input.GetKey(KeyCode.Q) then
            self:makeCameraTargetDelta(Vector3.down * Time.deltaTime * self.keyboardCameraMoveSpeed, false)
        end

        if Input.GetKeyDown(KeyCode.LeftShift) then
            self.keyboardCameraMoveSpeed = 10
        end

        if Input.GetKeyUp(KeyCode.LeftShift) then
            self.keyboardCameraMoveSpeed = 5
        end
    end
end

--- 调整摄像机聚焦位置
--- @param delta Vector3 位置增量
--- @param isProjectPlane boolean 是否投影到 XZ 平面
function CameraController:makeCameraTargetDelta(delta, isProjectPlane)
    if isProjectPlane then
        delta = Vector3.ProjectOnPlane(self.cameraTransform:TransformVector(delta), Vector3.up)
    end

    self.cameraDelta = self.cameraDelta + delta

    if self.cameraDelta.y < 0 then
        self.cameraDelta = Vector3(self.cameraDelta.x, 0, self.cameraDelta.z)
    end

    self.cameraTargetTrans.position = self.cameraDelta + self.cameraOriginPos
end

return CameraController
