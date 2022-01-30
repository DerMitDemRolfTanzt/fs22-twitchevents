InvertControlsEffect = {}
local InvertControlsEffect_mt = Class(InvertControlsEffect, LastingEffect)

function InvertControlsEffect.new(name, durationMilliseconds, custom_mt)
    local self = LastingEffect.new(name, durationMilliseconds, custom_mt or InvertControlsEffect_mt)
    self:overrideFunctions()
    return self
end

function InvertControlsEffect:initialize(event)
    -- This effect currently only works inside vehicles
    return g_currentMission.controlledVehicle ~= nil
end

function InvertControlsEffect:overrideFunctions()
    local effect = self

    -- override Drivable.actionEventSteer
    local drivable_actionEventSteer = function(drivable, originalFunction, actionName, inputValue, callbackState, isAnalog, isMouse, deviceCategory, binding)
        if effect.active then
            inputValue = -inputValue
        end
        originalFunction(drivable, actionName, inputValue, callbackState, isAnalog, isMouse, deviceCategory, binding)
    end

    -- override Rideable.actionEventSteer
    local rideable_actionEventSteer = function(rideable, originalFunction, actionName, inputValue, callbackState, isAnalog)
        if effect.active then
            inputValue = -inputValue
        end
        originalFunction(rideable, actionName, inputValue, callbackState, isAnalog)
    end

    Drivable.actionEventSteer = Utils.overwrittenFunction(Drivable.actionEventSteer, drivable_actionEventSteer)
    Rideable.actionEventSteer = Utils.overwrittenFunction(Rideable.actionEventSteer, rideable_actionEventSteer)
end


