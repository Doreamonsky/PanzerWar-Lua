--- 第三方插件 以及框架向的引用
require("events.EventDefine") -- 事件定义
require("events.EventSystem") -- 事件系统
require("lib.base64") -- base64
require("lib.configIO") -- IO 相关

inspect = require("lib.inspect")
json = require("lib.dkjson")

--- 寻找 Index 位置，若找到则返回位置，否则返回 false
table.indexOf = function(tab, value)
    for index, val in pairs(tab) do
        if value == val then
            return index
        else
            return false
        end
    end
end
