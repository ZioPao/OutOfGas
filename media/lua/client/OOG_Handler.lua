if not OOG_Handler then OOG_Handler = {} end

OOG_Handler.currentHandler = nil
OOG_Handler.vehicleFirstPushVector = nil
OOG_Handler.vehicleSecondPushVector = nil



function OOG_Handler.StartUpdateVehiclePosition()
    

    Events.OnTick.Add(OOG_Handler.UpdateVehiclePosition)
end

function OOG_Handler.UpdateVehiclePosition()
    if not OOG_Handler.currentHandler.player:isPlayerMoving() then
        OOG_Handler.currentHandler.player:setVariable("EmotePlaying", false)
        return
    end
    OOG_Handler.currentHandler.player:setVariable("EmotePlaying", true)
    OOG_Handler.currentHandler.player:playEmote("WalkPushCar")

    -- Check distance between og point of the car and player
    local vehicleVector = OOG_Handler.currentHandler.vehicle:getWorldPos(OOG_Handler.currentHandler.x, 0, OOG_Handler.currentHandler.z, OOG_Handler.vehicleFirstPushVector)
    local plX = OOG_Handler.currentHandler.player:getX()
    local plY = OOG_Handler.currentHandler.player:getY()
    local vehX = vehicleVector:get(0)
    local vehY = vehicleVector:get(1)

    -- print("X")
    -- print(math.abs(math.abs(plX) - math.abs(vehX)))
    -- print("Y")
    -- print(math.abs(math.abs(plY) - math.abs(vehY)))
    -- print("__________________")
    if (math.abs(math.abs(plX) - math.abs(vehX)) > 0.7) or (math.abs(math.abs(plY) - math.abs(vehY)) > 0.5) then


        Events.OnTick.Remove(OOG_Handler.currentHandler.UpdateVehiclePosition)

        OOG_Handler.currentHandler.player:setVariable("EmotePlaying", false)
        OOG_Handler.currentHandler = nil
        return
    end


    -- Not too high 
    local forceCoeff = 20
    local forceVector = OOG_Handler.currentHandler.vehicle:getWorldPos(OOG_Handler.currentHandler.fx, 0, OOG_Handler.currentHandler.fz, OOG_Handler.vehicleFirstPushVector):add(-OOG_Handler.currentHandler.vehicle:getX(), -OOG_Handler.currentHandler.vehicle:getY(), -OOG_Handler.currentHandler.vehicle:getZ())

    local pushPoint = OOG_Handler.currentHandler.vehicle:getWorldPos(OOG_Handler.currentHandler.x, 0, OOG_Handler.currentHandler.z, OOG_Handler.vehicleSecondPushVector):add(-OOG_Handler.currentHandler.vehicle:getX(), -OOG_Handler.currentHandler.vehicle:getY(), -OOG_Handler.currentHandler.vehicle:getZ())
    pushPoint:set(pushPoint:x(), 0, pushPoint:y())

    local force = 0.5 + 0.1 * OOG_Handler.currentHandler.player:getPerkLevel(Perks.Strength)
    forceVector:mul(forceCoeff * force * OOG_Handler.currentHandler.vehicle:getMass())
    forceVector:set(forceVector:x(), 0, forceVector:y())

    OOG_Handler.currentHandler.vehicle:setPhysicsActive(true)

    if OOG_Handler.currentHandler.vehicle:getSpeed2D() < 1 then
        OOG_Handler.currentHandler.vehicle:addImpulse(forceVector, pushPoint)
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


    OOG_Handler.vehicleFirstPushVector = Vector3f.new()
    OOG_Handler.vehicleSecondPushVector = Vector3f.new()

    local pushPoint = self.vehicle:getWorldPos(self.x, 0, self.z, OOG_Handler.vehicleFirstPushVector)
    ISTimedActionQueue.add(ISPathFindAction:customPathToVehicle(self.player, pushPoint:x(), pushPoint:y(), pushPoint:z(), OOG_Handler.StartUpdateVehiclePosition))

end

function OOG_Handler.GetInstance()
    return OOG_Handler.currentHandler

end

function OOG_Handler:new(player, vehicle)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.player = player
    o.vehicle = vehicle

    OOG_Handler.currentHandler = o

    return o
end