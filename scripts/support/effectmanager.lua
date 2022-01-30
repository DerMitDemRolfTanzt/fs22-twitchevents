TEEffectManager = {}
local TEEffectManager_mt = Class(TEEffectManager)

function TEEffectManager.new(custom_mt)
    local self = setmetatable({}, custom_mt or TEEffectManager_mt)

    self.effects = {}
    self.runningEffects = {}

    return self
end

function TEEffectManager:registerEffect(effect)
    self.effects[effect.name] = effect
end

function TEEffectManager:getEffect(event)
    return self.effects[event.BaseCode]
end

function TEEffectManager:triggerEffect(event)
    local effect = self:getEffect(event)

    if effect == nil then
        Logging.warning(string.format("[TwitchEvents] Effect \"%s\" triggered by event \"%s\" has not been registered.", event.BaseCode, event.ID))
        return false
    end
    if self.runningEffects[effect.name] ~= nil then
        Logging.info(string.format("[TwitchEvents] Effect \"%s\" triggered by event \"%s\" has been postponed since it is already running.", event.FinalCode, event.ID))
        return false
    end

    if effect.effectType == "DirectEffect" then
        Logging.info(string.format("[TwitchEvents] Trying to run DirectEffect \"%s\".", effect.name))
        local result = effect:run(event)
        if not result then
            Logging.info(string.format("[TwitchEvents] Running DirectEffect \"%s\" was not successful.", effect.name))
        end
        return result
    elseif effect.effectType == "DirectServerEffect" then
        if g_server ~= nil then
            effect:run(event)
        else
            TwitchServerEvent.sendEvent(event)
        end
    elseif effect.effectType == "LastingEffect" then
        Logging.info(string.format("[TwitchEvents] Trying to initialize LastingEffect \"%s\" with %d milliseconds duration.", effect.name, effect.durationMilliseconds))
        local result = effect:initialize(event)
        if not result then
            Logging.info(string.format("[TwitchEvents] Initializing LastingEffect \"%s\" was not successful.", effect.name))
        else
            self.runningEffects[effect.name] = event
            effect.active = true
        end
        return result
    else
        Logging.error(string.format("[TwitchEvents] Effect \"%s\" has unsupported effectType \"%s\".", effect.name, effect.effectType))
        return false
    end
end

function TEEffectManager:update(dt)
    for effectName, event in pairs(self.runningEffects) do
        local effect = self.effects[effectName]

        event.effectDurationMilliseconds = event.effectDurationMilliseconds + dt

        if event.effectDurationMilliseconds <= effect.durationMilliseconds then
            effect:update(dt, event)
        else
            Logging.info(string.format("[TwitchEvents] Finalizing LastingEffect \"%s\" after %d milliseconds.", effect.name, event.effectDurationMilliseconds))
            self.runningEffects[effect.name] = nil
            effect.active = false
            effect:finalize(event)
        end
    end
end

function TEEffectManager:draw()
    for effectName, event in pairs(self.runningEffects) do
        local effect = self.effects[effectName]

        effect:draw(event)
    end
end