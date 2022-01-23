UpsideDownEffect = {}
local UpsideDownEffect_mt = Class(UpsideDownEffect, LastingEffect)

function UpsideDownEffect.new(name, durationMilliseconds, custom_mt)
    local self = LastingEffect.new(name, durationMilliseconds, custom_mt or UpsideDownEffect_mt)
    self:overrideFunctions()
    return self
end

function UpsideDownEffect:initialize(event)
    -- This effect currently only works outside of vehicles
    return g_currentMission.controlledVehicle == nil
end

function UpsideDownEffect:overrideFunctions()
    local effect = self

    -- override Player.update
    local player_update = function(player, originalFunction, dt)
        originalFunction(player, dt)
        if player.isEntered and player.isClient and not g_gui:getIsGuiVisible() and not player.thirdPersonViewActive then
            if effect.active then
                setRotation(player.cameraNode, player.rotX, player.rotY, math.rad(180))
            end
        end
    end

    Player.update = Utils.overwrittenFunction(Player.update, player_update)
end