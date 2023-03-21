if not OOG_Handler then OOG_Handler = {} end

OOG_Handler.currentHandler = nil
OOG_Handler.startVehicleVector = nil
OOG_Handler.vehicleFirstPushVector = nil
OOG_Handler.vehicleSecondPushVector = nil







OOG_Handler.ManageKeys = function(key)
    print("OOG: managing keys!")

    for _,bind in ipairs(OOG_Bindings) do
        if key == getCore():getKey(bind.value) then


            if bind.value == "OOG_LeftKey" then
                OOG_Handler.currentHandler.RotateVehicle('L')
                
            elseif bind.value == "OOG_RightKey" then
                OOG_Handler.currentHandler.RotateVehicle('R')

            end
        end
             
    end

end






-----------------------------------------



local function SetDirectionY(behind)


    OOG_Handler.currentHandler.player:playEmote("WalkPushCar")


    if behind then
        OOG_Handler.currentHandler.z = -OOG_Handler.currentHandler.halfLength
        OOG_Handler.currentHandler.fz = 1
    else
        OOG_Handler.currentHandler.z = OOG_Handler.currentHandler.halfLength
        OOG_Handler.currentHandler.fz = -1
    end

end

local function SetDirectionX(behind)


    OOG_Handler.currentHandler.player:playEmote("WalkPushCar")

    OOG_Handler.currentHandler.forceCoeff = 5

    if behind then
        OOG_Handler.currentHandler.z = 0
        OOG_Handler.currentHandler.fz = 0
        OOG_Handler.currentHandler.fx = 1
    else
        OOG_Handler.currentHandler.z = 0
        OOG_Handler.currentHandler.fz = 0
        OOG_Handler.currentHandler.fx = -1
    end

  
    -- if (side == 'R') then
    --     print("Rotating R")
    --     OOG_Handler.currentHandler.x = OOG_Handler.currentHandler.halfWidth
    --     OOG_Handler.currentHandler.z = OOG_Handler.currentHandler.halfLength
    --     OOG_Handler.currentHandler.fx = 1
    -- elseif side == 'L' then
    --     print("Rotating L")
    --     OOG_Handler.currentHandler.x = -OOG_Handler.currentHandler.halfWidth
    --     OOG_Handler.currentHandler.z = -OOG_Handler.currentHandler.halfLength
    --     OOG_Handler.currentHandler.fx = 1
    -- end
end





function OOG_Handler.RotateVehicle(side)
    OOG_Handler.currentHandler.player:playEmote("WalkPushCarSide")
    OOG_Handler.currentHandler.forceCoeff = 8
    OOG_Handler.currentHandler.rotating = true
    if side == 'R' then
        print("Rotate R")
        OOG_Handler.currentHandler.x = OOG_Handler.currentHandler.halfWidth
        OOG_Handler.currentHandler.z = OOG_Handler.currentHandler.halfLength
        OOG_Handler.currentHandler.fx = -1
    else
        print("Rotate L")
        OOG_Handler.currentHandler.x = -OOG_Handler.currentHandler.halfWidth
        OOG_Handler.currentHandler.z = -OOG_Handler.currentHandler.halfLength
        OOG_Handler.currentHandler.fx = -1
    end





end




function OOG_Handler.StopAllLoops()
    Events.OnKeyKeepPressed.Remove(OOG_Handler.ManageKeys)
    Events.OnTick.Remove(OOG_Handler.UpdateVehiclePosition)


end



function OOG_Handler.StartUpdateVehiclePosition()
    Events.OnKeyKeepPressed.Add(OOG_Handler.ManageKeys)
    Events.OnTick.Add(OOG_Handler.UpdateVehiclePosition)
end




local function ExecImpulse()
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

function OOG_Handler.UpdateVehiclePosition()

    getPlayer():setAllowSprint(false)
    getPlayer():setAllowRun(false)



    -- Check distance between og point of the car and player
    local vehicleVector = OOG_Handler.currentHandler.vehicle:getWorldPos(OOG_Handler.currentHandler.startX, 0, OOG_Handler.currentHandler.startZ, OOG_Handler.startVehicleVector)
    local plX = OOG_Handler.currentHandler.player:getX()
    local plY = OOG_Handler.currentHandler.player:getY()
    local vehX = vehicleVector:get(0)
    local vehY = vehicleVector:get(1)
    
    if (math.abs(math.abs(plX) - math.abs(vehX)) > 1.5) or (math.abs(math.abs(plY) - math.abs(vehY)) > 1.5) then
        print("Stopping!")
        print("X")
        print(math.abs(math.abs(plX) - math.abs(vehX)))
        print("Y")
        print(math.abs(math.abs(plY) - math.abs(vehY)))
        print("__________________")
        Events.OnTick.Remove(OOG_Handler.currentHandler.UpdateVehiclePosition)
        OOG_Handler.currentHandler.player:setVariable("EmotePlaying", false)
        Events.OnKeyKeepPressed.Remove(OOG_Handler.ManageKeys)
        getPlayer():setAllowSprint(true)
        getPlayer():setAllowRun(true)
        return
    end

    if (math.abs(math.abs(plX) - math.abs(vehX)) > 0.5) or (math.abs(math.abs(plY) - math.abs(vehY)) > 0.5) then
        getPlayer():setAllowSprint(true)
        getPlayer():setAllowRun(true)
        OOG_Handler.currentHandler.player:setVariable("EmotePlaying", false)
        return
    end

    if not OOG_Handler.currentHandler.player:isPlayerMoving() then
        OOG_Handler.currentHandler.player:setVariable("EmotePlaying", false)
        return
    elseif OOG_Handler.currentHandler.rotating then
        ExecImpulse()
        OOG_Handler.currentHandler.rotating = false
    end

    OOG_Handler.currentHandler.player:setVariable("EmotePlaying", true)


    OOG_Handler.currentHandler.z = 0
    OOG_Handler.currentHandler.x = 0
    OOG_Handler.currentHandler.fx = 0
    OOG_Handler.currentHandler.fz = 0
    -- Not too high 

    local startDir = OOG_Handler.currentHandler.startDirection

    OOG_Handler.currentHandler.forceCoeff = 20

    if startDir == "BEHIND" then
        SetDirectionY(true)

    elseif startDir == "FRONT" then
        SetDirectionY(false)

    elseif startDir == "RIGHT" then
        SetDirectionX(true)
    elseif startDir == "LEFT" then
        SetDirectionX(false)
    end





    ExecImpulse()

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
    elseif direction == "LEFT" then
        self.startX = self.halfWidth
        self.startZ = 0
        self.startFx = -1
    elseif direction == "RIGHT" then
        self.startX = -self.halfWidth
        self.startZ = 0
        self.startFx = 1

        print(self.startX)
        print(self.startZ)
        print(self.startFx)

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



