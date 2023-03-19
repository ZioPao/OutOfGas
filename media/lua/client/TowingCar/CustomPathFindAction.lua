require "TimedActions/ISBaseTimedAction"

TACustomPathFind = ISBaseTimedAction:derive("TACustomPathFind")

function TACustomPathFind:isValid()
	return true
end

function TACustomPathFind:update()
    if instanceof(self.character, "IsoPlayer") and
			(self.character:pressedMovement(false) or self.character:pressedCancelAction()) then
		self:forceStop()
		return
    end

    local result = self.character:getPathFindBehavior2():update()
    if result == BehaviorResult.Succeeded then
		self:forceComplete()
	end

    local x = self.character:getX()
    local y = self.character:getY()

    if x == self.lastX and y == self.lastY then
        self.currentTimeInOnePosition = self.currentTimeInOnePosition + 1
    else
        self.currentTimeInOnePosition = 0
        self.lastX = x
        self.lastY = y
    end

    if self.currentTimeInOnePosition > self.maxTimeInOnePosition then
        self:forceComplete()
    end
end

function TACustomPathFind:start()
    self.character:facePosition(self.goal[2], self.goal[3])
	self.character:getPathFindBehavior2():pathToLocationF(self.goal[2], self.goal[3], self.goal[4])
end

function TACustomPathFind:stop()
	ISBaseTimedAction.stop(self)
	self.character:getPathFindBehavior2():cancel()
	self.character:setPath2(nil)
end

function TACustomPathFind:perform()
	self.character:getPathFindBehavior2():cancel()
	self.character:setPath2(nil)
	ISBaseTimedAction.perform(self)
end

function TACustomPathFind:pathToLocationF(character, targetX, targetY, targetZ)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.stopOnWalk = false
	o.stopOnRun = false
    o.maxTime = -1
    
    o.maxTimeInOnePosition = 15
    o.currentTimeInOnePosition = 0
    o.lastX = -1
    o.lastY = -1

	o.goal = { 'LocationF', targetX, targetY, targetZ }
	return o
end

