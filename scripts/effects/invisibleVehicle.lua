InvisibleVehicleEffect = {}
local InvisibleVehicleEffect_mt = Class(InvisibleVehicleEffect, LastingEffect)

function InvisibleVehicleEffect.new(name, durationMilliseconds, custom_mt)
    local self = LastingEffect.new(name, durationMilliseconds, custom_mt or InvisibleVehicleEffect_mt)
    self:overrideFunctions()
    return self
end

function InvisibleVehicleEffect:initialize(event)
    local vehicle = g_currentMission.controlledVehicle
    if vehicle == nil then
        return false
    end

    self.vehicles = {}

    -- create shallow copy of vehicle.childVehicles
    for index, value in ipairs(vehicle.childVehicles) do
        self.vehicles[index] = value
    end

    self:setVisibility(false)

    return true
end

function InvisibleVehicleEffect:update(dt, event)
end

function InvisibleVehicleEffect:draw(event)
end

function InvisibleVehicleEffect:finalize(event)

    self:setVisibility(true)
end

function InvisibleVehicleEffect:setVisibility(isVisible)
    for index, vehicle in ipairs(self.vehicles) do
        vehicle:setVisibility(isVisible)
        if vehicle.getVehicleCharacter ~= nil and vehicle:getVehicleCharacter() ~= nil then
            vehicle:getVehicleCharacter():setCharacterVisibility(isVisible)
        end
    end
end

function InvisibleVehicleEffect:overrideFunctions()
    local effect = self

    -- override VehicleCharacter.updateVisibility
    local updateVisibility = function(vehicleCharacter, originalFunction, isVisible)
        if not effect.active then
            originalFunction(vehicleCharacter, isVisible)
        end
    end

    VehicleCharacter.updateVisibility = Utils.overwrittenFunction(VehicleCharacter.updateVisibility, updateVisibility)
end


