DIYCreateMapMode = {}

local this = DIYCreateMapMode
this.onStartMode = function()
    CSharpAPI.RequestScene(
        "Empty-Scene",
        function()
            CSharpAPI.LoadAssetBundle(
                "DIYCreateMapUtil",
                "mod",
                function(asset)
                    if asset ~= nil then
                        this.onUtilCreated(GameObject.Instantiate(asset))
                    end
                end
            )
        end
    )
end

this.onUtilCreated = function(root)

end