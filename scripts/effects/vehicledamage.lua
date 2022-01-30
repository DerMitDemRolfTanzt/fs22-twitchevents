VehicleDamageEffect = {}
local VehicleDamageEffect_mt = Class(VehicleDamageEffect, DirectServerEffect)

function VehicleDamageEffect.new(name, factor, custom_mt)
    local self = DirectServerEffect.new(name, custom_mt or VehicleDamageEffect_mt)
    self.factor = factor or 1
    return self
end

function VehicleDamageEffect:run(event)
    local vehicle = g_currentMission.controlledVehicle or self.vehicle
    if vehicle == nil then
        return false
    end

    if event.ParameterItems[1] == nil then
        return false
    end

    -- percent to repair
    local percent = tonumber(event.ParameterItems[1])

    -- repair each vehicle
    for index, v in ipairs(vehicle.childVehicles) do
        v:addDamageAmount(self.factor * percent / 100.0, true)
    end

    return true
end

function VehicleDamageEffect:writeStream(event, streamId, connection)
    NetworkUtil.writeNodeObject(streamId, g_currentMission.controlledVehicle)
end

function VehicleDamageEffect:readStream(event, streamId, connection)
    self.vehicle = NetworkUtil.readNodeObject(streamId)
end