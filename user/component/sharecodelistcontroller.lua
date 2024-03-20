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
    self.closeBtn = self.root:Find("Title/CloseBtn"):GetComponent(typeof(Button))
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

                    local instance = GameObject.Instantiate(self.templateGo, self.templateGo.transform.parent, true)
                        .transform
                    instance:Find("DefineName"):GetComponent(typeof(Text)).text = defineName
                    instance:Find("DownloadCount"):GetComponent(typeof(Text)).text = downloadCount
                    instance:Find("ShareCode"):GetComponent(typeof(Text)).text = shareCode
                    instance:Find("ImportBtn"):GetComponent(typeof(Button)).onClick:AddListener(
                        function()
                            self.importCB(shareCode)
                        end
                    )
                    instance:Find("CopyBtn"):GetComponent(typeof(Button)).onClick:AddListener(
                        function()
                            GUIUtility.systemCopyBuffer = v.ShareCode

                            PopMessageManager.Instance:PushPopup(
                                UIAPI.FormatString(UIAPI.GetLocalizedContent("ShareCodeClipboard"), v.ShareCode),
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
