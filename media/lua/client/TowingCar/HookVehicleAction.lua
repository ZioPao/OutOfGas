require('TimedActions/ISBaseTimedAction')

TAHookVehicle = ISBaseTimedAction:derive("TAHookVehicle")


-- The condition which tells the timed action if it is still valid
function TAHookVehicle:isValid()   
   return true;
end

-- Starts the Timed Action
function TAHookVehicle:start()
   self:setActionAnim(self.animation)
   self.sound = getSoundManager():PlayWorldSound("towingCar_hookingSound", false, self.character:getSquare(), 0, 5, 1, true)
end

-- Is called when the time has passed
function TAHookVehicle:perform()
    self.sound:stop();

    if self.performFunc ~= nil then
        self.performFunc(self.character, self.arg1, self.arg2, self.arg3, self.arg4)
    end

    ISBaseTimedAction.perform(self);
end


function TAHookVehicle:stop()
    if self.sound then
        self.sound:stop()
    end

    ISBaseTimedAction.stop(self)
end

function TAHookVehicle:new(character, time, animation, performFunc, arg1, arg2, arg3, arg4)
    local o = {};
    setmetatable(o, self)
    self.__index = self
    o.stopOnWalk = true
    o.stopOnRun = true
    o.maxTime = time
   
   o.character = character;
   o.animation = animation

   o.performFunc = performFunc
   o.arg1 = arg1
   o.arg2 = arg2
   o.arg3 = arg3
   o.arg4 = arg4
   
    return o;
end