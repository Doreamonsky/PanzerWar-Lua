TransformUtil = {}

local this = TransformUtil

--- 序列化欧拉角 -> 四元数
--- @param vec SerializeVector3
this.SerializeVectorToQuaternion = function(vec)
    return Quaternion.Euler(vec.x, vec.y, vec.z)
end

--- 四元数 -> 序列化欧拉角
this.QuaternionToSeralizeVector = function(rot)
    local vec = rot.eulerAngles
    return SerializeVector3(vec.x, vec.y, vec.z)
end

return this
