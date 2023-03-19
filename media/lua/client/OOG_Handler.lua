OOG_Handler = {}



function OOG_Handler:updateVehiclePosition()

    if self.character:isAiming() then Events.OnTick.Remove(self.updateVehiclePosition) end
    if not self.character:isPlayerMoving() then return end

    local forceCoeff = 10
    local forceVector = self.vehicle:getWorldPos(self.fx, 0, self.fz, TowCarMod.Utils.tempVector1):add(-self.vehicle:getX(), -self.vehicle:getY(), -self.vehicle:getZ())
    local pushPoint = self.vehicle:getWorldPos(self.x, 0, self.z, TowCarMod.Utils.tempVector2):add(-self.vehicle:getX(), -self.vehicle:getY(), -self.vehicle:getZ())
    pushPoint:set(pushPoint:x(), 0, pushPoint:y())

    local force = 0.5 + 0.1 * self.vehicle:getPerkLevel(Perks.Strength)
    forceVector:mul(forceCoeff * force * self.vehicle:getMass())
    forceVector:set(forceVector:x(), 0, forceVector:y())

    self.vehicle:setPhysicsActive(true)

    if self.vehicle:getSpeed2D() < 1 then
        self.vehicle:addImpulse(forceVector, pushPoint)
    end

end

function OOG_Handler:startPushingVehicle(direction)

    local halfLength = self.vehicle:getScript():getPhysicsChassisShape():z()/2
    local halfWidth = self.vehicle:getScript():getPhysicsChassisShape():x()/2

    self.z = 0
    self.x = 0
    self.fx = 0
    self.fz = 0

    if direction == "FRONT" then
        self.z = halfLength
        self.fz = -1
    elseif direction == "BEHIND" then
        self.z = -halfLength
        self.fz = 1
    elseif direction == "LEFT_FRONT" then
        self.x = halfWidth
        self.z = halfLength
        self.fx = -1
    elseif direction == "LEFT_BEHIND" then
        self.x = halfWidth
        self.z = -halfLength
        self.fx = -1
    elseif direction == "RIGHT_FRONT" then
        self.x = -halfWidth
        self.z = halfLength
        self.fx = 1
    elseif direction == "RIGHT_BEHIND" then
        self.x = -halfWidth
        self.z = -halfLength
        self.fx = 1
    end



    Events.OnTick.Add(self.updateVehiclePosition)
end



function OOG_Handler:new(player, vehicle)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.player = player
    o.vehicle = vehicle


    return o
end