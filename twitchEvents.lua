--
-- Mod: TwitchEvents
--
-- Author: DerMitDemRolfTanzt
-- URL: https://github.com/DerMitDemRolfTanzt/fs22-twitchevents

-- #############################################################################

-- load models
source(Utils.getFilename("scripts/models/crowdcontrolevent.lua", g_currentModDirectory))
source(Utils.getFilename("scripts/models/networkevent.lua", g_currentModDirectory))
source(Utils.getFilename("scripts/models/effect.lua", g_currentModDirectory))

-- load support classes
source(Utils.getFilename("scripts/support/effectmanager.lua", g_currentModDirectory))
source(Utils.getFilename("scripts/support/fileio.lua", g_currentModDirectory))

-- load effects
source(Utils.getFilename("scripts/effects/debug.lua", g_currentModDirectory))
source(Utils.getFilename("scripts/effects/invisiblevehicle.lua", g_currentModDirectory))
source(Utils.getFilename("scripts/effects/topdown.lua", g_currentModDirectory))
source(Utils.getFilename("scripts/effects/invertcontrols.lua", g_currentModDirectory))
source(Utils.getFilename("scripts/effects/upsidedown.lua", g_currentModDirectory))

-- mod definition
TwitchEvents = {}

TwitchEvents.fileIO = nil
TwitchEvents.effectManager = nil

function TwitchEvents:loadMap(name)
    -- initialize support classes
    TwitchEvents.fileIO = TEFileIO.new()
    TwitchEvents.effectManager = TEEffectManager.new()

    -- register effects
    TwitchEvents.effectManager:registerEffect(DebugEffect.new("debug", 5000))
    TwitchEvents.effectManager:registerEffect(InvisibleVehicleEffect.new("invisiblevehicle", 5000))
    TwitchEvents.effectManager:registerEffect(TopDownEffect.new("topdown", 10000))
    TwitchEvents.effectManager:registerEffect(InvertControlsEffect.new("invertcontrols", 10000))
    TwitchEvents.effectManager:registerEffect(UpsideDownEffect.new("upsidedown", 10000))
end

function TwitchEvents:deleteMap()
end

function TwitchEvents:mouseEvent(posX, posY, isDown, isUp, button)
end

function TwitchEvents:keyEvent(unicode, sym, modifier, isDown)
end

function TwitchEvents:update(dt)
    TwitchEvents.effectManager:update(dt)

    for index, event in pairs(TwitchEvents.fileIO:pollEvents(dt)) do
        if TwitchEvents.effectManager:triggerEffect(event) then
            TwitchEvents.fileIO:answerEvent(event, true)
        end
    end
end

function TwitchEvents:draw()
    TwitchEvents.effectManager:draw()
end

addModEventListener(TwitchEvents)