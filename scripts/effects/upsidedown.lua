UpsideDownEffect = {}
local UpsideDownEffect_mt = Class(UpsideDownEffect, LastingEffect)

function UpsideDownEffect.new(name, durationMilliseconds, custom_mt)
    local self = LastingEffect.new(name, durationMilliseconds, custom_mt or UpsideDownEffect_mt)
    self:overrideFunctions()
    return self
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

    -- override VehicleCamera.updateRotateNodeRotation
    local vehicleCamera_updateRotateNodeRotation = function(vehicleCamera, originalFunction)
        originalFunction(vehicleCamera)

        if effect.active then
            local x, y, z = getRotation(vehicleCamera.rotateNode)
            setRotation(vehicleCamera.rotateNode, -x, y, math.rad(180 + math.deg(z)))
        end
    end

    Player.update = Utils.overwrittenFunction(Player.update, player_update)
    VehicleCamera.updateRotateNodeRotation = Utils.overwrittenFunction(VehicleCamera.updateRotateNodeRotation, vehicleCamera_updateRotateNodeRotation)
end