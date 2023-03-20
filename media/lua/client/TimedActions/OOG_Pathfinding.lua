function ISPathFindAction:customPathToVehicle(character, targetX, targetY, targetZ, method)
	local o = ISBaseTimedAction.new(self, character)
	o.stopOnAim = false
	o.stopOnWalk = false
	o.stopOnRun = false
	o.maxTime = -1
    o.onCompleteFunc = method
    o.onCompleteArgs = {}
	o.goal = { 'LocationF', targetX, targetY, targetZ }
	return o
end