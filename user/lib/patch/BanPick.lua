BanPick = {}
Lib()

local M = BanPick

function M.ShowBanPick()
    UIManager.Instance:ShowUI(UIEnum.BANPICK_UI, function(ctrl)
        local canvas = ComponentAPI.GetNativeComponent(ctrl.go, "Canvas")
        canvas.sortingOrder = 100

        ctrl:InitBanPickInfo(CommonDataManager.Instance:GetBPVehicleList());
        ctrl:onSaveCallBack():AddListener(function()
            CommonDataManager.Instance:SaveBPVehicle()
        end)
    end)
end
