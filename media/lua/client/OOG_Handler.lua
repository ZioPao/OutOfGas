if not OOG_Handler then OOG_Handler = {} end


-----------------------------------------

local function SetValuesFrontBehind(behind)


    OOG_Handler.player:playEmote("WalkPushCar")


    if behind then
        OOG_Handler.z = -OOG_Handler.halfLength
        OOG_Handler.fz = 1
    else
        OOG_Handler.z = OOG_Handler.halfLength
        OOG_Handler.fz = -1
    end

end

local function SetValuesLeftRight(behind)


    OOG_Handler.player:playEmote("WalkPushCar")
    OOG_Handler.forceCoeff = 5

    if behind then
        OOG_Handler.z = 0
        OOG_Handler.fz = 0
        OOG_Handler.fx = 1
    else
        OOG_Handler.z = 0
        OOG_Handler.fz = 0
        OOG_Handler.fx = -1
    end

end

local function RotateVehicle(side)
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


local function ExecImpulse()
    local forceVector = OOG_Handler.vehicle:getWorldPos(OOG_Handler.fx, 0, OOG_Handler.fz, OOG_Handler.vehicleFirstPushVector):add(-OOG_Handler.vehicle:getX(), -OOG_Handler.vehicle:getY(), -OOG_Handler.vehicle:getZ())

    local pushPoint = OOG_Handler.vehicle:getWorldPos(OOG_Handler.x, 0, OOG_Handler.z, OOG_Handler.vehicleSecondPushVector):add(-OOG_Handler.vehicle:getX(), -OOG_Handler.vehicle:getY(), -OOG_Handler.vehicle:getZ())
    pushPoint:set(pushPoint:x(), 0, pushPoint:y())

    local force = 0.5 + 0.1 * OOG_Handler.player:getPerkLevel(Perks.Strength)
    forceVector:mul(OOG_Handler.forceCoeff * force * OOG_Handler.vehicle:getMass())
    forceVector:set(forceVector:x(), 0, forceVector:y())

    OOG_Handler.vehicle:setPhysicsActive(true)

    if OOG_Handler.vehicle:getSpeed2D() < 1 then
        OOG_Handler.vehicle:addImpulse(forceVector, pushPoint)
    end

end



-------------------------------------------
-- Key management


OOG_Handler.ManageKeys = function(key)
    print("OOG: managing keys!")

    for _,bind in ipairs(OOG_Bindings) do
        if key == getCore():getKey(bind.value) then
            if bind.value == "OOG_LeftKey" then
                RotateVehicle('L')
                
            elseif bind.value == "OOG_RightKey" then
                RotateVehicle('R')
            end
        end
             
    end

end



------------------------------------------------


OOG_Handler.UpdateVehiclePosition = function()
    getPlayer():setAllowSprint(false)
    getPlayer():setAllowRun(false)


    -- Check distance between og point of the car and player
    local vehicleVector = OOG_Handler.vehicle:getWorldPos(OOG_Handler.startX, 0, OOG_Handler.startZ, OOG_Handler.startVehicleVector)
    local plX = OOG_Handler.player:getX()
    local plY = OOG_Handler.player:getY()
    local vehX = vehicleVector:get(0)
    local vehY = vehicleVector:get(1)
    
    if (math.abs(math.abs(plX) - math.abs(vehX)) > 1.5) or (math.abs(math.abs(plY) - math.abs(vehY)) > 1.5) then
        print("Stopping!")
        print("X")
        print(math.abs(math.abs(plX) - math.abs(vehX)))
        print("Y")
        print(math.abs(math.abs(plY) - math.abs(vehY)))
        print("__________________")
        Events.OnTick.Remove(OOG_Handler.UpdateVehiclePosition)
        OOG_Handler.player:setVariable("EmotePlaying", false)
        Events.OnKeyKeepPressed.Remove(OOG_Handler.ManageKeys)
        getPlayer():setAllowSprint(true)
        getPlayer():setAllowRun(true)
        return
    end

    if (math.abs(math.abs(plX) - math.abs(vehX)) > 0.5) or (math.abs(math.abs(plY) - math.abs(vehY)) > 0.5) then
        getPlayer():setAllowSprint(true)
        getPlayer():setAllowRun(true)
        OOG_Handler.player:setVariable("EmotePlaying", false)
        return
    end

    if not OOG_Handler.player:isPlayerMoving() then
        OOG_Handler.player:setVariable("EmotePlaying", false)
        return
    elseif OOG_Handler.rotating then
        ExecImpulse()
        OOG_Handler.rotating = false
    end

    OOG_Handler.player:setVariable("EmotePlaying", true)


    OOG_Handler.z = 0
    OOG_Handler.x = 0
    OOG_Handler.fx = 0
    OOG_Handler.fz = 0
    -- Not too high 

    local startDir = OOG_Handler.startDirection

    OOG_Handler.forceCoeff = 20

    if startDir == "BEHIND" then
        SetValuesFrontBehind(true)

    elseif startDir == "FRONT" then
        SetValuesFrontBehind(false)

    elseif startDir == "RIGHT" then
        SetValuesLeftRight(true)
    elseif startDir == "LEFT" then
        SetValuesLeftRight(false)
    end





    ExecImpulse()

end

OOG_Handler.StopAllLoops = function()
    Events.OnKeyKeepPressed.Remove(OOG_Handler.ManageKeys)
    Events.OnTick.Remove(OOG_Handler.UpdateVehiclePosition)

end

OOG_Handler.StartUpdateVehiclePosition = function()
    Events.OnKeyKeepPressed.Add(OOG_Handler.ManageKeys)
    Events.OnTick.Add(OOG_Handler.UpdateVehiclePosition)
end

OOG_Handler.StartPushingVehicle = function(direction)

    OOG_Handler.halfLength = OOG_Handler.vehicle:getScript():getPhysicsChassisShape():z()/2
    OOG_Handler.halfWidth = OOG_Handler.vehicle:getScript():getPhysicsChassisShape():x()/2

     -- We need to account for the starting point!
     OOG_Handler.startZ = 0
     OOG_Handler.startX = 0
     OOG_Handler.startFx = 0
     OOG_Handler.startFz = 0
 
     if direction == "FRONT" then
        OOG_Handler.startZ = OOG_Handler.halfLength
        OOG_Handler.startFz = -1
     elseif direction == "BEHIND" then
        OOG_Handler.startZ = -OOG_Handler.halfLength
        OOG_Handler.startFz = 1
     elseif direction == "LEFT" then
        OOG_Handler.startX = OOG_Handler.halfWidth
        OOG_Handler.startZ = 0
        OOG_Handler.startFx = -1
     elseif direction == "RIGHT" then
        OOG_Handler.startX = -OOG_Handler.halfWidth
        OOG_Handler.startZ = 0
        OOG_Handler.startFx = 1
     end
 
 
     OOG_Handler.vehicleFirstPushVector = Vector3f.new()
     OOG_Handler.vehicleSecondPushVector = Vector3f.new()
     OOG_Handler.startVehicleVector = Vector3f.new()
 
     local pushPoint = OOG_Handler.vehicle:getWorldPos(OOG_Handler.startX, 0, OOG_Handler.startZ, OOG_Handler.vehicleFirstPushVector)
     ISTimedActionQueue.add(ISPathFindAction:customPathToVehicle(OOG_Handler.player, pushPoint:x(), pushPoint:y(), pushPoint:z(), OOG_Handler.StartUpdateVehiclePosition))
 
end

OOG_Handler.Setup = function(player, vehicle)

    OOG_Handler.player = player
    OOG_Handler.vehicle = vehicle


end