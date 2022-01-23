TopDownEffect = {}
local TopDownEffect_mt = Class(TopDownEffect, LastingEffect)

function TopDownEffect.new(name, durationMilliseconds, cameraHeight, custom_mt)
    local self = LastingEffect.new(name, durationMilliseconds, custom_mt or TopDownEffect_mt)

    self.prevCamera = nil
    self.camera = nil
    self.cameraHeight = cameraHeight or 20

    return self
end

function TopDownEffect:initialize(event)
    self:createCamera()
    return true
end

function TopDownEffect:update(dt, event)
    if getCamera() ~= self.camera then
        self.prevCamera = getCamera()
        setCamera(self.camera)
    end
    self:updateCameraPosition()
end

function TopDownEffect:finalize(event)
    setCamera(self.prevCamera)
    self:deleteCamera()
end

function TopDownEffect:createCamera()
    self.camera = createCamera("TopDownEffectCamera", math.rad(60), 1, 4000)

    setRotation(camera, math.rad(270), 0, 0)
    setTranslation(camera, 0, 0, 0)
end

function TopDownEffect:deleteCamera()
    delete(self.camera)

    self.camera = nil
end

function TopDownEffect:updateCameraPosition()
    local x, y, z = 0, 0, 0
    local dx, dy, dz = 0, 0, 0
    local yaw = 0

    if g_currentMission.controlledVehicle ~= nil then
        x, y, z = getTranslation(g_currentMission.controlledVehicle.rootNode)
        dx, dy, dz = g_currentMission.controlledVehicle:getVehicleWorldDirection()
        yaw = MathUtil.getYRotationFromDirection(-dx, -dz)
    elseif g_currentMission.player ~= nil then
        x, y, z = getTranslation(g_currentMission.player.rootNode)
        yaw = g_currentMission.player.rotY
    end

    setTranslation(self.camera, x, y + self.cameraHeight, z)
    setRotation(self.camera, math.rad(270), yaw, 0)
end


