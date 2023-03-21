if not OOG_Handler then OOG_Handler = {} end

OOG_Handler.currentHandler = nil
OOG_Handler.startVehicleVector = nil
OOG_Handler.vehicleFirstPushVector = nil
OOG_Handler.vehicleSecondPushVector = nil







OOG_Handler.ManageKeys = function(key)

    for _,bind in ipairs(OOG_Bindings) do
        if key == getCore():getKey(bind.value) then


            if bind.value == "OOG_LeftKey" then
                
            elseif bind.value == "OOG_RightKey" then

            end
        end
             
    end

end






-----------------------------------------



local function SetDirectionY(behind, side)


    if side then
        OOG_Handler.currentHandler.player:playEmote("WalkPushCarSide")
        OOG_Handler.currentHandler.forceCoeff = 5
    else
        OOG_Handler.currentHandler.player:playEmote("WalkPushCar")
    end


    if behind and not side then
        OOG_Handler.currentHandler.z = -OOG_Handler.currentHandler.halfLength
        OOG_Handler.currentHandler.fz = 1
    elseif not behind and not side then
        OOG_Handler.currentHandler.z = OOG_Handler.currentHandler.halfLength
        OOG_Handler.currentHandler.fz = -1
    
    elseif (behind and side == 'R') or (not behind and side =='L') then
        print("Rotating 1")
        OOG_Handler.currentHandler.x = OOG_Handler.currentHandler.halfWidth
        OOG_Handler.currentHandler.z = OOG_Handler.currentHandler.halfLength
        OOG_Handler.currentHandler.fx = -1
    elseif (behind and side == 'L') or (not behind and side == 'R') then
        print("Rotating 2")
        OOG_Handler.currentHandler.x = -OOG_Handler.currentHandler.halfWidth
        OOG_Handler.currentHandler.z = -OOG_Handler.currentHandler.halfLength
        OOG_Handler.currentHandler.fx = -1
    end
end
local function SetDirectionX(side)


    OOG_Handler.currentHandler.player:playEmote("WalkPushCarSide")




    OOG_Handler.currentHandler.z = 0
    OOG_Handler.currentHandler.fz = 0
    OOG_Handler.currentHandler.fx = 1
    
    if side then
        OOG_Handler.currentHandler.forceCoeff = 5
    else
        return
    end
    if (side == 'R') then
        print("Rotating R")
        OOG_Handler.currentHandler.x = OOG_Handler.currentHandler.halfWidth
        OOG_Handler.currentHandler.z = OOG_Handler.currentHandler.halfLength
        OOG_Handler.currentHandler.fx = 1
    elseif side == 'L' then
        print("Rotating L")
        OOG_Handler.currentHandler.x = -OOG_Handler.currentHandler.halfWidth
        OOG_Handler.currentHandler.z = -OOG_Handler.currentHandler.halfLength
        OOG_Handler.currentHandler.fx = 1
    end
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
            SetDirectionY(true, nil)
        elseif flooredDir == -46 then
            print("NE")
            SetDirectionY(true, 'R')
        elseif flooredDir == 0 then
            print("E")
            SetDirectionY(true, nil)
        elseif flooredDir == 45 then
            print("SE")
            SetDirectionY(true, nil)
        elseif flooredDir == 89 then
            print("S")
            SetDirectionY(true, nil)
        elseif flooredDir == 135 then
            print("SW")
            SetDirectionY(true, 'L')
        elseif flooredDir == -180 then
            print("W")
            SetDirectionY(true, nil)

        elseif flooredDir == -135 then
            print("NW")
            SetDirectionY(true, nil)

        end
    elseif inputDirection == "FRONT" then
        if flooredDir == -90 then
            print("N")
            SetDirectionY(false, nil)
        elseif flooredDir == -46 then
            print("NE")
            SetDirectionY(false, 'L')
        elseif flooredDir == 0 then
            print("E")
            SetDirectionY(false, nil)
        elseif flooredDir == 45 then
            print("SE")
            SetDirectionY(false, nil)
        elseif flooredDir == 89 then
            print("S")
            SetDirectionY(false, nil)
        elseif flooredDir == 135 then
            print("SW")
            SetDirectionY(false, 'R')
        elseif flooredDir == -180 then
            print("W")
            SetDirectionY(false, nil)
        elseif flooredDir == -135 then
            print("NW")
            SetDirectionY(false, nil)
        end
    elseif inputDirection == "RIGHT" then


        if flooredDir == -90 then
            print("N")
            SetDirectionX(nil)
        elseif flooredDir == -46 then
            print("NE")
            SetDirectionX('L')
        elseif flooredDir == 0 then
            print("E")
            SetDirectionX(nil)
        elseif flooredDir == 45 then
            print("SE")
            SetDirectionX(nil)
        elseif flooredDir == 89 then
            print("S")
            SetDirectionX(nil)
        elseif flooredDir == 135 then
            print("SW")
            SetDirectionX('R')
        elseif flooredDir == -180 then
            print("W")
            SetDirectionX(nil)
        elseif flooredDir == -135 then
            print("NW")
            SetDirectionX(nil)
        end
    elseif inputDirection == "LEFT" then
        
    end

    

end




function OOG_Handler.RotateVehicle(side)

    if side == 'R' then
        print("Rotate R")
    else
        print("Rotate L")
    end

end



function OOG_Handler.StartUpdateVehiclePosition()
    
    Events.OnKeyPressed.Add(OOG_Bindings.ManageKeys)
    Events.OnTick.Add(OOG_Handler.UpdateVehiclePosition)
end

function OOG_Handler.UpdateVehiclePosition()

    if OOG_Handler == nil then
        Events.OnTick.Remove(OOG_Handler.currentHandler.UpdateVehiclePosition)
        Events.OnKeyPressed.Remove(OOG_Bindings.ManageKeys)

    end

    if not OOG_Handler.currentHandler.player:isPlayerMoving() then
        OOG_Handler.currentHandler.player:setVariable("EmotePlaying", false)
        return
    end

    OOG_Handler.currentHandler.player:setVariable("EmotePlaying", true)

    
    local dir = getPlayer():getDirectionAngle()
    MapDirectionToValue(OOG_Handler.currentHandler.startDirection, dir)


    -- Check distance between og point of the car and player
    local vehicleVector = OOG_Handler.currentHandler.vehicle:getWorldPos(OOG_Handler.currentHandler.startX, 0, OOG_Handler.currentHandler.startZ, OOG_Handler.startVehicleVector)
    local plX = OOG_Handler.currentHandler.player:getX()
    local plY = OOG_Handler.currentHandler.player:getY()
    local vehX = vehicleVector:get(0)
    local vehY = vehicleVector:get(1)





    if (math.abs(math.abs(plX) - math.abs(vehX)) > 3) or (math.abs(math.abs(plY) - math.abs(vehY)) > 3) then
        print("Stopping!")
        print("X")
        print(math.abs(math.abs(plX) - math.abs(vehX)))
        print("Y")
        print(math.abs(math.abs(plY) - math.abs(vehY)))
        print("__________________")
        Events.OnTick.Remove(OOG_Handler.currentHandler.UpdateVehiclePosition)
        OOG_Handler.currentHandler.player:setVariable("EmotePlaying", false)
        Events.OnKeyPressed.Remove(OOG_Bindings.ManageKeys)
        return
    end

    if (math.abs(math.abs(plX) - math.abs(vehX)) > 0.5) or (math.abs(math.abs(plY) - math.abs(vehY)) > 0.5) then
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
    elseif direction == "LEFT" then
        self.startX = -self.halfWidth
        self.startZ = self.halfLength
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



