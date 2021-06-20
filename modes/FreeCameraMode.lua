FreeCameraMode = {}

FreeCameraMode.onStartMode = function()
    CS.ShanghaiWindy.Core.FreeCamera.CreateFreeCamera(
        CS.UnityEngine.Vector3.zero,
        function(...)
            local state = CS.ShanghaiWindy.Core.BaseInitSystem:GetMobileState()
            CS.ShanghaiWindy.URPCore.URPMainUIManager.Instance.backgroundCamera.gameObject:SetActive(false)
            CS.ShanghaiWindy.URPCore.URPMainUIManager.Instance.observeJoystick.gameObject:SetActive(state)
        end
    )
end

FreeCameraMode.onExitMode = function()
    print("结束游戏模式")
end
