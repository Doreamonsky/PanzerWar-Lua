--- 第三方插件 以及框架向的引用
inspect = require("inspect")
require("events.EventDefine")
require("events.EventSystem")
require("base64")

table.indexOf = function(tab, value)
    for index, val in pairs(tab) do
        if value == val then
            return index
        else
            return -1
        end
    end
end
