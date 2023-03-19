--- @class ShareCodeListController
--- Share code list manager
--- Make players easier to download share codes.
local ShareCodeListController = class("ShareCodeListController", nil)

function ShareCodeListController:ctor(remoteUrl, importCB)
    --- @type boolean 是否已初始化
    self.isInit = false

    --- @type string 请求地址
    self.url = remoteUrl

    --- @type function 导入方法
    self.importCB = importCB
end

function ShareCodeListController:Init(entryBtn, rootGo)
    --- @type Button 界面入口按钮
    self.entryBtn = entryBtn

    --- @type Transform 界面
    self.root = rootGo.transform
    ---------------------Transform--------------------------
    self.templateGo = self.root:Find("Scroll View/Viewport/Content/Template").gameObject
    self.closeBtn = self.root:Find("Title/CloseBtn"):GetComponent("Button")
    ---------------------Transform--------------------------

    self.templateGo:SetActive(false)

    ---------------------Bind--------------------------
    self.closeBtn.onClick:AddListener(function()
        self:toggleUIGo(false)
    end)

    self.entryBtn.onClick:AddListener(function()
        if not self.isInit then
            self.isInit = true
            self:getList(self.url)
        end

        self:toggleUIGo(true)
    end)
    ---------------------Bind--------------------------
end

function ShareCodeListController:toggleUIGo(status)
    self.root.gameObject:SetActive(status)
end

function ShareCodeListController:getList(url)
    local webRequest = UnityWebRequest.Get(url)
    local asyncWebRequest = webRequest:SendWebRequest()

    asyncWebRequest:completed(
        "+",
        function(res)
            local text = webRequest.downloadHandler.text

            local decodeText = function()
                local data = json.decode(text)
                for k, v in pairs(data.content.userDefines) do
                    local defineName = v.DefineName
                    local downloadCount = v.DownloadCount
                    local shareCode = v.ShareCode

                    local instance = GameObject.Instantiate(self.templateGo, self.templateGo.transform.parent, true).transform
                    instance:Find("DefineName"):GetComponent("Text").text = defineName
                    instance:Find("DownloadCount"):GetComponent("Text").text = downloadCount
                    instance:Find("ShareCode"):GetComponent("Text").text = shareCode
                    instance:Find("ImportBtn"):GetComponent("Button").onClick:AddListener(
                        function()
                            self.importCB(shareCode)
                        end
                    )
                    instance:Find("CopyBtn"):GetComponent("Button").onClick:AddListener(
                        function()
                            GUIUtility.systemCopyBuffer = v.ShareCode

                            PopMessageManager.Instance:PushPopup(
                                "游戏将访问剪贴版，并将分享码: " .. v.ShareCode .. " 复制进剪贴板",
                                function(state)
                                end
                            )
                        end
                    )
                    instance.gameObject:SetActive(true)
                end
            end

            local ret = xpcall(decodeText, traceback)

            if not ret then
                print("Failed to decode share code list.")
            end
        end
    )
end

return ShareCodeListController
