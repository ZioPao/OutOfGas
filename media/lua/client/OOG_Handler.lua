if not OOG_Handler then OOG_Handler = {} end

OOG_Handler.currentHandler = nil
OOG_Handler.startVehicleVector = nil
OOG_Handler.vehicleFirstPushVector = nil
OOG_Handler.vehicleSecondPushVector = nil

function TestDirection()

    Events.OnTick.Add(function()
        --print(getPlayer():getDirectionAngle())
    
        local dir = getPlayer():getDirectionAngle()

        local flooredDir = math.floor(dir)
        if flooredDir == -135 then
            print("NW")
        elseif flooredDir == -90 then
            print("N")
        elseif flooredDir == -46 then
            print("NE")
        elseif flooredDir == 0 then
            print("E")
        elseif flooredDir == 45 then
            print("SE")
        elseif flooredDir == 89 then
            print("S")
        elseif flooredDir == 135 then
            print("SW")
        elseif flooredDir == - 180 then
            print("W")
        end
    
    
    
    end)

end



local function MapDirectionToValue(inputDirection, playerDir)

    -- N = 0
    -- NE = 1
    -- E = 2
    -- SE = 3
    -- S = 4
    -- SW = 5
    -- W = 6
    -- NW = 7
    local flooredDir = math.floor(playerDir)

    OOG_Handler.currentHandler.z = 0
    OOG_Handler.currentHandler.x = 0
    OOG_Handler.currentHandler.fx = 0
    OOG_Handler.currentHandler.fz = 0
    -- Not too high 
    OOG_Handler.currentHandler.forceCoeff = 20

    if inputDirection == "BEHIND" then
        if flooredDir == -90 then
            print("N")
            OOG_Handler.currentHandler.z = -OOG_Handler.currentHandler.halfLength
            OOG_Handler.currentHandler.fz = 1
        elseif flooredDir == -46 then
            print("NE")
            OOG_Handler.currentHandler.x = OOG_Handler.currentHandler.halfWidth
            OOG_Handler.currentHandler.z = OOG_Handler.currentHandler.halfLength
            OOG_Handler.currentHandler.fx = -1
            OOG_Handler.currentHandler.forceCoeff = 5
        elseif flooredDir == 0 then
            print("E")
            OOG_Handler.currentHandler.z = -OOG_Handler.currentHandler.halfLength
            OOG_Handler.currentHandler.fz = 1
        elseif flooredDir == 45 then
            print("SE")
            OOG_Handler.currentHandler.z = -OOG_Handler.currentHandler.halfLength
            OOG_Handler.currentHandler.fz = 1
        elseif flooredDir == 89 then
            print("S")
            OOG_Handler.currentHandler.z = OOG_Handler.currentHandler.halfLength
            OOG_Handler.currentHandler.fz = 1
        elseif flooredDir == 135 then
            print("SW")
            OOG_Handler.currentHandler.x = -OOG_Handler.currentHandler.halfWidth
            OOG_Handler.currentHandler.z =  OOG_Handler.currentHandler.halfLength
            OOG_Handler.currentHandler.fx = 1
            OOG_Handler.currentHandler.forceCoeff = 5
        elseif flooredDir == -180 then
            print("W")
        elseif flooredDir == -135 then
            print("NW")
        end
    elseif inputDirection == "FRONT" then
        if flooredDir == -90 then
            print("N")
            OOG_Handler.currentHandler.z = OOG_Handler.currentHandler.halfLength
            OOG_Handler.currentHandler.fz = -1
        elseif flooredDir == -46 then
            print("NE")
            OOG_Handler.currentHandler.x = -OOG_Handler.currentHandler.halfWidth
            OOG_Handler.currentHandler.z = -OOG_Handler.currentHandler.halfLength
            OOG_Handler.currentHandler.fx = 1
            OOG_Handler.currentHandler.forceCoeff = 5
        elseif flooredDir == 0 then
            print("E")
            OOG_Handler.currentHandler.z = OOG_Handler.currentHandler.halfLength
            OOG_Handler.currentHandler.fz = -1
        elseif flooredDir == 45 then
            print("SE")
            OOG_Handler.currentHandler.z = OOG_Handler.currentHandler.halfLength
            OOG_Handler.currentHandler.fz = -1
        elseif flooredDir == 89 then
            print("S")
            OOG_Handler.currentHandler.z = OOG_Handler.currentHandler.halfLength
            OOG_Handler.currentHandler.fz = -1
        elseif flooredDir == 135 then
            print("SW")
            OOG_Handler.currentHandler.x = OOG_Handler.currentHandler.halfWidth
            OOG_Handler.currentHandler.z = OOG_Handler.currentHandler.halfLength
            OOG_Handler.currentHandler.fx = -1
            OOG_Handler.currentHandler.forceCoeff = 5
        elseif flooredDir == -180 then
            print("W")
            OOG_Handler.currentHandler.z = OOG_Handler.currentHandler.halfLength
            OOG_Handler.currentHandler.fz = -1
        elseif flooredDir == -135 then
            print("NW")
            OOG_Handler.currentHandler.z = OOG_Handler.currentHandler.halfLength
            OOG_Handler.currentHandler.fz = -1
        end
    end

    

end



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



    local dir = getPlayer():getDirectionAngle()
    MapDirectionToValue(OOG_Handler.currentHandler.startDirection, dir)






    -- Check distance between og point of the car and player
    local vehicleVector = OOG_Handler.currentHandler.vehicle:getWorldPos(OOG_Handler.currentHandler.startX, 0, OOG_Handler.currentHandler.startZ, OOG_Handler.startVehicleVector)
    local plX = OOG_Handler.currentHandler.player:getX()
    local plY = OOG_Handler.currentHandler.player:getY()
    local vehX = vehicleVector:get(0)
    local vehY = vehicleVector:get(1)

    -- FIXME this check is fucked
    if (math.abs(math.abs(plX) - math.abs(vehX)) > 1) or (math.abs(math.abs(plY) - math.abs(vehY)) > 1) then
        print("Stopping!")
        print("X")
        print(math.abs(math.abs(plX) - math.abs(vehX)))
        print("Y")
        print(math.abs(math.abs(plY) - math.abs(vehY)))
        print("__________________")
        Events.OnTick.Remove(OOG_Handler.currentHandler.UpdateVehiclePosition)
        OOG_Handler.currentHandler.player:setVariable("EmotePlaying", false)
        --OOG_Handler.currentHandler = nil
        return
    end



    local forceVector = OOG_Handler.currentHandler.vehicle:getWorldPos(OOG_Handler.currentHandler.fx, 0, OOG_Handler.currentHandler.fz, OOG_Handler.vehicleFirstPushVector):add(-OOG_Handler.currentHandler.vehicle:getX(), -OOG_Handler.currentHandler.vehicle:getY(), -OOG_Handler.currentHandler.vehicle:getZ())

    local pushPoint = OOG_Handler.currentHandler.vehicle:getWorldPos(OOG_Handler.currentHandler.x, 0, OOG_Handler.currentHandler.z, OOG_Handler.vehicleSecondPushVector):add(-OOG_Handler.currentHandler.vehicle:getX(), -OOG_Handler.currentHandler.vehicle:getY(), -OOG_Handler.currentHandler.vehicle:getZ())
    pushPoint:set(pushPoint:x(), 0, pushPoint:y())

    local force = 0.5 + 0.1 * OOG_Handler.currentHandler.player:getPerkLevel(Perks.Strength)
    forceVector:mul(OOG_Handler.currentHandler.forceCoeff * force * OOG_Handler.currentHandler.vehicle:getMass())
    forceVector:set(forceVector:x(), 0, forceVector:y())

    OOG_Handler.currentHandler.vehicle:setPhysicsActive(true)

    if OOG_Handler.currentHandler.vehicle:getSpeed2D() < 1 then
        OOG_Handler.currentHandler.vehicle:addImpulse(forceVector, pushPoint)
    end

end

function OOG_Handler:startPushingVehicle(direction)


    self.startDirection = direction

    self.halfLength = self.vehicle:getScript():getPhysicsChassisShape():z()/2
    self.halfWidth = self.vehicle:getScript():getPhysicsChassisShape():x()/2

    -- We need to account for the starting point!



    self.startZ = 0
    self.startX = 0
    self.startFx = 0
    self.startFz = 0

    if direction == "FRONT" then
        self.startZ = self.halfLength
        self.startFz = -1
    elseif direction == "BEHIND" then
        self.startZ = -self.halfLength
        self.startFz = 1
    elseif direction == "LEFT_FRONT" then
        self.startX = self.halfWidth
        self.startZ = self.halfLength
        self.startFx = -1
    elseif direction == "LEFT_BEHIND" then
        self.startX = self.halfWidth
        self.startZ = -self.halfLength
        self.startFx = -1
    elseif direction == "RIGHT_FRONT" then
        self.startX = -self.halfWidth
        self.startZ = self.halfLength
        self.startFx = 1
    elseif direction == "RIGHT_BEHIND" then
        self.startX = -self.halfWidth
        self.startZ = -self.halfLength
        self.startFx = 1
    end


    OOG_Handler.vehicleFirstPushVector = Vector3f.new()
    OOG_Handler.vehicleSecondPushVector = Vector3f.new()
    OOG_Handler.startVehicleVector = Vector3f.new()

    local pushPoint = self.vehicle:getWorldPos(self.startX, 0, self.startZ, OOG_Handler.vehicleFirstPushVector)
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