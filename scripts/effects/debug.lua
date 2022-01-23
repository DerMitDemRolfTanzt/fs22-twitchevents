DebugEffect = {}
local DebugEffect_mt = Class(DebugEffect, LastingEffect)

function DebugEffect.new(name, durationMilliseconds, custom_mt)
    local self = LastingEffect.new(name, durationMilliseconds, custom_mt or DebugEffect_mt)
    return self
end

function DebugEffect:colorOverTime(event)
    local result = {}
    table.insert(result, math.max(0, math.min(1, (3 * event.effectDurationMilliseconds / self.durationMilliseconds) - 0)))
    table.insert(result, math.max(0, math.min(1, (3 * event.effectDurationMilliseconds / self.durationMilliseconds) - 1)))
    table.insert(result, math.max(0, math.min(1, (3 * event.effectDurationMilliseconds / self.durationMilliseconds) - 2)))

    -- GIANTS engine uses LUA pre 5.4
    ---@diagnostic disable-next-line: deprecated
    return unpack(result)
end

function DebugEffect:draw(event)
    setTextAlignment(RenderText.ALIGN_CENTER)
    setTextBold(false)
    local r, g, b = self:colorOverTime(event)
    setTextColor(r, g, b, 0.75)
    renderText(0.5, 0.08, getCorrectTextSize(0.025), string.format("User \"%s\" invoked effect \"%s\".", event.DisplayViewer, event.InventoryItem))
end