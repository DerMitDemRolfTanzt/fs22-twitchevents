-- Abstract TEEffect

TEEffect = {}
local Effect_mt = Class(TEEffect)

function TEEffect.new(effectType, name, custom_mt)
    local self = setmetatable({}, custom_mt or Effect_mt)

    self.effectType = effectType
    self.name = name

    return self
end

-- DirectEffect

DirectEffect = {}
local DirectEffect_mt = Class(DirectEffect, TEEffect)

function DirectEffect.new(name, custom_mt)
    local self = TEEffect.new("DirectEffect", name, custom_mt or DirectEffect_mt)
    return self
end

function DirectEffect:run(event)
    return true
end

-- LastingEffect

LastingEffect = {}
local LastingEffect_mt = Class(LastingEffect, TEEffect)

function LastingEffect.new(name, durationMilliseconds, custom_mt)
    local self = TEEffect.new("LastingEffect", name, custom_mt or LastingEffect_mt)

    self.durationMilliseconds = durationMilliseconds
    self.active = false

    return self
end

function LastingEffect:initialize(event)
    return true
end

function LastingEffect:update(dt, event)
end

function LastingEffect:draw(event)
end

function LastingEffect:finalize(event)
end