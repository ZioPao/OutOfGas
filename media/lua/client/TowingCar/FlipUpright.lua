if not TowCarMod then TowCarMod = {} end
if not TowCarMod.Flip then TowCarMod.Flip = {} end



local function getCorrectAngle(vehicle)
   local frontPos = vehicle:getWorldPos(0, 0, 1, TowCarMod.Utils.tempVector1)
   local centerPos = vehicle:getWorldPos(0, 0, 0, TowCarMod.Utils.tempVector2)

   local dx = frontPos:x() - centerPos:x()
   local dy = frontPos:y() - centerPos:y()

   local dirVector = TowCarMod.Utils.tempVector1:set(dx, dy, 0):normalize()
   local baseVector = TowCarMod.Utils.tempVector2:set(1, 0, 0):normalize()

   local angle = (baseVector:angle(dirVector) * 180 / math.pi + 270) % 360

   return angle + 180
end




function TowCarMod.Flip.isUpsideDownVehicle(vehicle)
   local topPos = vehicle:getWorldPos(0, 1, 0, TowCarMod.Utils.tempVector1)
   local centerPos = vehicle:getWorldPos(0, 0, 0, TowCarMod.Utils.tempVector2)

   return topPos:z() < (centerPos:z() + 0.3)
end

function TowCarMod.Flip.getUpsideDownVehicle(square)
	for y=square:getY() - 2, square:getY() + 2 do
		for x=square:getX() - 2, square:getX() + 2 do
			local square2 = getCell():getGridSquare(x, y, square:getZ())
			if square2 then
				for i=1, square2:getMovingObjects():size() do
					local obj = square2:getMovingObjects():get(i-1)
					if obj~= nil 
							and instanceof(obj, "BaseVehicle") 
							and TowCarMod.Flip.isUpsideDownVehicle(obj) then
						return obj
					end
				end
			end
		end
	end
	return nil
end


function TowCarMod.Flip.flipAction(playerObj, towTruck)
   local rearPos = towTruck:getAttachmentWorldPos("trailer", TowCarMod.Utils.tempVector1)
   local square = getCell():getGridSquare(rearPos:x(), rearPos:y(), towTruck:getZ())
   if square == nil then return end

   local vehicle = TowCarMod.Flip.getUpsideDownVehicle(square)
   if vehicle == nil then return end


   --- Go to rear of tow truck
   local hookPoint = towTruck:getAttachmentWorldPos("trailer", TowCarMod.Utils.tempVector1)
   if hookPoint == nil then return end
   ISTimedActionQueue.add(TACustomPathFind:pathToLocationF(playerObj, hookPoint:x(), hookPoint:y(), hookPoint:z()))
   
   --- Unequip item
   local storePrim = playerObj:getPrimaryHandItem()
   if storePrim ~= nil then
      ISTimedActionQueue.add(ISUnequipAction:new(playerObj, storePrim, 12));
   end

   local performFunc = function()
      local angle = getCorrectAngle(vehicle)
      vehicle:flipUpright();
      vehicle:setAngles(0, angle, 0)
      vehicle:setPhysicsActive(true)
   end

   --- First attach animation
   ISTimedActionQueue.add(TAHookVehicle:new(playerObj, 100, TowCarMod.Config.highLevelAnimation, performFunc))
end

function TowCarMod.Flip.isUpsideDownVehicleNear(towTruck)
   local rearPos = towTruck:getAttachmentWorldPos("trailer", TowCarMod.Utils.tempVector1)
   local square = getCell():getGridSquare(rearPos:x(), rearPos:y(), towTruck:getZ())
   if square == nil then return end

   return TowCarMod.Flip.getUpsideDownVehicle(square) ~= nil
end