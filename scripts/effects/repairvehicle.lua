RepairVehicleEffect = {}
local RepairVehicleEffect_mt = Class(RepairVehicleEffect, DirectServerEffect)

function RepairVehicleEffect.new(name, custom_mt)
    local self = DirectServerEffect.new(name, custom_mt or RepairVehicleEffect_mt)
    return self
end

function RepairVehicleEffect:run(event)
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
        v:addDamageAmount(-percent/100.0, true)
    end

    return true
end

function RepairVehicleEffect:writeStream(event, streamId, connection)
    NetworkUtil.writeNodeObject(streamId, g_currentMission.controlledVehicle)
end

function RepairVehicleEffect:readStream(event, streamId, connection)
    self.vehicle = NetworkUtil.readNodeObject(streamId)
end