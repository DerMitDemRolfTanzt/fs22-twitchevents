UpsideDownEfffect = {}
local UpsideDownEfffect_mt = Class(UpsideDownEfffect, LastingEffect)

function UpsideDownEfffect.new(name, durationMilliseconds, custom_mt)
    local self = LastingEffect.new(name, durationMilliseconds, custom_mt or UpsideDownEfffect_mt)
    self:overrideFunctions()
    return self
end

function InvisibleVehicleEffect:initialize(event)
    -- This effect currently only works outside of vehicles
    return g_currentMission.controlledVehicle == nil
end

function UpsideDownEfffect:overrideFunctions()
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