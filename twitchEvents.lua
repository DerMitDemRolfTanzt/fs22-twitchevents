--
-- Mod: TwitchEvents
--
-- Author: DerMitDemRolfTanzt
-- URL: https://github.com/DerMitDemRolfTanzt/fs22-twitchevents

-- #############################################################################

-- load models
source(Utils.getFilename("scripts/models/crowdcontrolevent.lua", g_currentModDirectory))
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

local fileIO = nil
local effectManager = nil

function TwitchEvents:loadMap(name)
    -- initialize support classes
    fileIO = TEFileIO.new()
    effectManager = TEEffectManager.new()

    -- register effects
    effectManager:registerEffect(DebugEffect.new("debug", 5000))
    effectManager:registerEffect(InvisibleVehicleEffect.new("invisiblevehicle", 5000))
    effectManager:registerEffect(TopDownEffect.new("topdown", 10000))
    effectManager:registerEffect(InvertControlsEfffect.new("invertcontrols", 10000))
    effectManager:registerEffect(UpsideDownEfffect.new("upsidedown", 10000))
end

function TwitchEvents:deleteMap()
end

function TwitchEvents:mouseEvent(posX, posY, isDown, isUp, button)
end

function TwitchEvents:keyEvent(unicode, sym, modifier, isDown)
end

function TwitchEvents:update(dt)
    effectManager:update(dt)

    for index, event in pairs(fileIO:pollEvents(dt)) do
        if effectManager:triggerEffect(event) then
            fileIO:answerEvent(event, true)
        end
    end
end

function TwitchEvents:draw()
    effectManager:draw()
end

addModEventListener(TwitchEvents)