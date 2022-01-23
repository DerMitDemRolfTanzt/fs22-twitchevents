InvertControlsEfffect = {}
local InvertControlsEfffect_mt = Class(InvertControlsEfffect, LastingEffect)

function InvertControlsEfffect.new(name, durationMilliseconds, custom_mt)
    local self = LastingEffect.new(name, durationMilliseconds, custom_mt or InvertControlsEfffect_mt)
    self.active = false
    self:overrideFunctions()
    return self
end

function InvertControlsEfffect:initialize(event)
    self.active = true
    return true
end

function InvertControlsEfffect:update(dt, event)
end

function InvertControlsEfffect:draw(event)
end

function InvertControlsEfffect:finalize(event)
    self.active = false
end

function InvertControlsEfffect:overrideFunctions()
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


