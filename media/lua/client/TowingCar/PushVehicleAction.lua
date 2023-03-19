require('TimedActions/ISBaseTimedAction')

TAPushVehicle = ISBaseTimedAction:derive("TAPushVehicle")


-- The condition which tells the timed action if it is still valid
function TAPushVehicle:isValid()   
   return true;
end

-- Starts the Timed Action
function TAPushVehicle:start()
   self.character:facePosition(self.vehicle:getX(), self.vehicle:getY())
   self:setActionAnim("Loot")
end

-- Is called when the time has passed
function TAPushVehicle:perform()
    local lenHalf = self.vehicle:getScript():getPhysicsChassisShape():z()/2
    local heightHalf = self.vehicle:getScript():getPhysicsChassisShape():y()/2
    local x = 0
    local z = 0
    
    local fx = 0
    local fz = 0

    local forceCoeff = 40

    if self.dir == "FRONT" then
        fz = -1
        forceCoeff = 150
    elseif self.dir == "BEHIND" then
        fz = 1
        forceCoeff = 150
    elseif self.dir == "LEFT_FRONT" then
        z = lenHalf
        fx = -1
        forceCoeff = 100
    elseif self.dir == "LEFT_BEHIND" then
        z = -lenHalf
        fx = -1
        forceCoeff = 100
    elseif self.dir == "RIGHT_FRONT" then
        z = lenHalf
        fx = 1
        forceCoeff = 100
    elseif self.dir == "RIGHT_BEHIND" then
        z = -lenHalf
        fx = 1
        forceCoeff = 100
    end

    local forceVector = self.vehicle:getWorldPos(fx, 0, fz, TowCarMod.Utils.tempVector1):add(-self.vehicle:getX(), -self.vehicle:getY(), -self.vehicle:getZ())
    local pushPoint = self.vehicle:getWorldPos(x, 0, z, TowCarMod.Utils.tempVector2):add(-self.vehicle:getX(), -self.vehicle:getY(), -self.vehicle:getZ())
    pushPoint:set(pushPoint:x(), 0, pushPoint:y())
    
    local force = 0.5 + 0.1 * self.character:getPerkLevel(Perks.Strength)
    forceVector:mul(forceCoeff * force * self.vehicle:getMass())
    forceVector:set(forceVector:x(), 0, forceVector:y())

    self.vehicle:setPhysicsActive(true)
    self.vehicle:addImpulse(forceVector, pushPoint)


    local enduranceCoeff = self.character:getPerkLevel(Perks.Fitness)
    if enduranceCoeff == 0 then enduranceCoeff = 1 end
    local endurance = self.character:getStats():getEndurance() - (1 / enduranceCoeff)
    self.character:getStats():setEndurance(endurance)


    ISBaseTimedAction.perform(self);
end


function TAPushVehicle:stop()
    ISBaseTimedAction.stop(self)
end

function TAPushVehicle:new(character, vehicle, direction)
    local o = {};
    setmetatable(o, self)
    self.__index = self
    o.stopOnWalk = true
    o.stopOnRun = true
    o.maxTime = 400

    o.character = character;
    o.vehicle = vehicle
    o.dir = direction
   
    return o;
end