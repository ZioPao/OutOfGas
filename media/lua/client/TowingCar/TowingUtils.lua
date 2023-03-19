if not TowCarMod then TowCarMod = {} end
if not TowCarMod.Utils then TowCarMod.Utils = {} end

TowCarMod.Utils.tempVector1 = Vector3f.new()
TowCarMod.Utils.tempVector2 = Vector3f.new()
TowCarMod.Utils.tempVector3 = Vector3f.new()
TowCarMod.Utils.tempVector4 = Vector3f.new()

---------------------------------------------------------------------------
--- Util functions
---------------------------------------------------------------------------

function TowCarMod.Utils.isTrailer(vehicle)
	return string.match(string.lower(vehicle:getScript():getName()), "trailer")
end

function TowCarMod.Utils.isTowTruck(vehicle)
	return string.match(string.lower(vehicle:getScript():getName()), "towtruck")
end

--- Return vehicles from sector that player can hook.
function TowCarMod.Utils.getAviableVehicles(mainVehicle, hasTowBar)
	local vehicles = {}
	local square = mainVehicle:getSquare()
	if square == nil then return vehicles end

	for y=square:getY() - 10, square:getY() + 10 do
		for x=square:getX() - 10, square:getX() + 10 do
			local square2 = getCell():getGridSquare(x, y, square:getZ())
			if square2 then
				for i=1, square2:getMovingObjects():size() do
					local obj = square2:getMovingObjects():get(i-1)
					if obj~= nil 
							and instanceof(obj, "BaseVehicle") 
							and obj ~= mainVehicle
							and #(TowCarMod.Utils.getHookTypeVariants(mainVehicle, obj, hasTowBar)) ~= 0 then
						table.insert(vehicles, obj)
					end
				end
			end
		end
	end
	return vehicles
end

--- Return a table with hookType options for vehicles.
function TowCarMod.Utils.getHookTypeVariants(vehicleA, vehicleB, hasTowBar)
	local hookTypeVariants = {}

	if vehicleA:getVehicleTowing() or vehicleA:getVehicleTowedBy()
			or vehicleB:getVehicleTowing() or vehicleB:getVehicleTowedBy() then 
		return hookTypeVariants 
	end

	local p1, p2 = TowCarMod.Utils.getTrailerPossibleAttachPoints(vehicleA, vehicleB)

	if TowCarMod.Utils.isTrailer(vehicleA) then	
		if not TowCarMod.Utils.isTrailer(vehicleB) and p1 ~= nil and p2 ~= nil then
			local hookType = {}
			hookType.name = getText("UI_Text_Towing_attach").."\n"..ISVehicleMenu.getVehicleDisplayName(vehicleA)
			hookType.func = TowCarMod.Hook.attachTrailerAction
			hookType.towingVehicle = vehicleB
			hookType.towedVehicle = vehicleA
			hookType.towingPoint = p2
			hookType.towedPoint = p1
			hookType.textureName = "trailer_sclice_icon"
			table.insert(hookTypeVariants, hookType)
		end
	else
		if TowCarMod.Utils.isTrailer(vehicleB) then
			if p1 ~= nil and p2 ~= nil then
				local hookType = {}
				hookType.name = getText("UI_Text_Towing_attach") .. "\n" ..ISVehicleMenu.getVehicleDisplayName(vehicleB)
				hookType.func = TowCarMod.Hook.attachTrailerAction
				hookType.towingVehicle = vehicleA
				hookType.towedVehicle = vehicleB	
				hookType.towingPoint = p1
				hookType.towedPoint = p2
				hookType.textureName = "trailer_sclice_icon"
				table.insert(hookTypeVariants, hookType)
			end
		else
			if TowCarMod.Utils.isTowTruck(vehicleA) 
					and (vehicleA:canAttachTrailer(vehicleB, "trailer", "trailerfront") or vehicleA:canAttachTrailer(vehicleB, "trailer", "trailer")) then
				local hookType = {}
				hookType.name = getText("UI_Text_Towing_attach") .. "\n".. ISVehicleMenu.getVehicleDisplayName(vehicleB) .. "\n" .. getText("UI_Text_Towing_byHook")
				hookType.func = TowCarMod.Hook.attachTowTruckAction
				hookType.towingVehicle = vehicleA
				hookType.towedVehicle = vehicleB
				hookType.textureName = "tow_car_icon"
				table.insert(hookTypeVariants, hookType)
			end
			if TowCarMod.Utils.isTowTruck(vehicleB) 
					and (vehicleA:canAttachTrailer(vehicleB, "trailerfront", "trailer") or vehicleA:canAttachTrailer(vehicleB, "trailer", "trailer")) then
				local hookType = {}
				hookType.name = getText("UI_Text_Towing_attach") .. "\n".. ISVehicleMenu.getVehicleDisplayName(vehicleB) .. "\n" .. getText("UI_Text_Towing_byHook")
				hookType.func = TowCarMod.Hook.attachTowTruckAction
				hookType.towingVehicle = vehicleB
				hookType.towedVehicle = vehicleA
				hookType.textureName = "tow_car_icon"
				table.insert(hookTypeVariants, hookType)
			end

			if hasTowBar then
				if vehicleA:canAttachTrailer(vehicleB, "trailerfront", "trailer") then
					local hookType = {}
					hookType.name = getText("UI_Text_Towing_attach") .. "\n".. ISVehicleMenu.getVehicleDisplayName(vehicleB) .. "\n" .. getText("UI_Text_Towing_byTowBar")
					hookType.func = TowCarMod.Hook.attachByTowBarAction
					hookType.towingVehicle = vehicleB
					hookType.towedVehicle = vehicleA
					hookType.textureName = "tow_bar_icon"
					table.insert(hookTypeVariants, hookType)
				elseif vehicleA:canAttachTrailer(vehicleB, "trailer", "trailerfront") then
					local hookType = {}
					hookType.name = getText("UI_Text_Towing_attach") .. "\n".. ISVehicleMenu.getVehicleDisplayName(vehicleB) .. "\n" .. getText("UI_Text_Towing_byTowBar")
					hookType.func = TowCarMod.Hook.attachByTowBarAction
					hookType.towingVehicle = vehicleA
					hookType.towedVehicle = vehicleB
					hookType.textureName = "tow_bar_icon"
					table.insert(hookTypeVariants, hookType)
				end
			end

			local ropeAttachA, ropeAttachB = TowCarMod.Utils.getRopeTowPossibleAttachPoints(vehicleA, vehicleB)
			if ropeAttachA ~= nil and ropeAttachB ~= nil then
				local hookType = {}
				hookType.name = getText("UI_Text_Towing_attach") .. "\n".. ISVehicleMenu.getVehicleDisplayName(vehicleB) .. "\n" .. getText("UI_Text_Towing_byRope")
				hookType.func = TowCarMod.Hook.attachByTowRopeAction
				
				hookType.towingVehicle = vehicleA
				hookType.towedVehicle = vehicleB
				if ropeAttachA == "trailerfront" then 
					hookType.towingVehicle = vehicleB
					hookType.towedVehicle = vehicleA
				end

				hookType.textureName = "tow_rope_icon"
				table.insert(hookTypeVariants, hookType)
			end
		end
	end
	return hookTypeVariants
end

function TowCarMod.Utils.getTrailerPossibleAttachPoints(vehicleA, vehicleB)
	if vehicleA:canAttachTrailer(vehicleB, "trailer", "trailer") then
		return "trailer", "trailer"
	end
	if vehicleA:canAttachTrailer(vehicleB, "trailer", "trailerfront") then
		return "trailer", "trailerfront"
	end
	if vehicleA:canAttachTrailer(vehicleB, "trailerfront", "trailer") then
		return "trailerfront", "trailer"
	end
end


--- Return name of attachments for rope hook if it possible.
function TowCarMod.Utils.getRopeTowPossibleAttachPoints(vehicleA, vehicleB)
	if vehicleA:canAttachTrailer(vehicleB, "trailer", "trailerfront") then
		return "trailer", "trailerfront"
	end
	if vehicleA:canAttachTrailer(vehicleB, "trailerfront", "trailer") then
		return "trailerfront", "trailer"
	end
end


function TowCarMod.Utils.updateAttachmentsForRigidTow(towingVehicle, towedVehicle, attachmentA, attachmentB, isTowTruck)
	towingVehicle:getScript():getAttachmentById(attachmentA):setUpdateConstraint(false)
	towingVehicle:getScript():getAttachmentById(attachmentA):setZOffset(0)

	towedVehicle:getScript():getAttachmentById(attachmentB):setUpdateConstraint(false)
	towedVehicle:getScript():getAttachmentById(attachmentB):setZOffset(0)

	local offset = towedVehicle:getScript():getAttachmentById(attachmentB):getOffset()
	local zShift = offset:z() > 0 and 1 or -1
	if isTowTruck then
		zShift = 0.2 * zShift
	end
	local yShift = isTowTruck and -0.5 or 0
	towedVehicle:getScript():getAttachmentById(attachmentB):getOffset():set(offset:x(), offset:y() + yShift, offset:z() + zShift)
	towedVehicle:getModData()["isChangedTowedAttachment"] = true
	towedVehicle:transmitModData()
end

function TowCarMod.Utils.updateAttachmentsOnDefaultValues(towingVehicle, towedVehicle, isWasTowTruck)
	if not towedVehicle:getModData()["isChangedTowedAttachment"] then
		local temp = towedVehicle
		towedVehicle = towingVehicle
		towingVehicle = temp
	end
	
	local attachment = towingVehicle:getScript():getAttachmentById(towingVehicle:getTowAttachmentSelf())
	attachment:setUpdateConstraint(true)
	local zOffset = (towingVehicle:getTowAttachmentSelf() == "trailer") and -1 or 1
    attachment:setZOffset(zOffset)

	attachment = towedVehicle:getScript():getAttachmentById(towedVehicle:getTowAttachmentSelf())
	attachment:setUpdateConstraint(true)
	zOffset = (towedVehicle:getTowAttachmentSelf() == "trailer") and -1 or 1
	attachment:setZOffset(zOffset)

	local offset = attachment:getOffset()
	local zShift = offset:z() > 0 and -1 or 1
	if isWasTowTruck then
		zShift = zShift * 0.2
	end
	local yShift = isWasTowTruck and 0.5 or 0
	attachment:getOffset():set(offset:x(), offset:y() + yShift, offset:z() + zShift)
	towedVehicle:getModData()["isChangedTowedAttachment"] = false
	towedVehicle:transmitModData()
end

function TowCarMod.Utils.isZombieNear(square)
   if square == nil then return false end
   
   for y=square:getY() - 1, square:getY() + 1 do
		for x=square:getX() - 1, square:getX() + 1 do
			local square2 = getCell():getGridSquare(x, y, square:getZ())
			if square2 then
				for i=1, square2:getMovingObjects():size() do
					local obj = square2:getMovingObjects():get(i-1)
					if obj~= nil and instanceof(obj, "IsoZombie") then
                  return true                        
					end
				end
			end
		end
	end
   return false
end


-----------------------------------------------------------

--- Fix mods that add vehicles without tow attachments
local function fixTowAttachmentsForOtherVehicleMods()
	local scriptManager = getScriptManager()
	local vehicleScripts = scriptManager:getAllVehicleScripts()

	print("fixTowAttachmentsForOtherVehicleMods")
	for i = 0, vehicleScripts:size()-1 do
		local script = vehicleScripts:get(i)
		local wheelCount = script:getWheelCount()

		local attachHeigtOffset = -0.5
		if wheelCount > 0 then 
			attachHeigtOffset = script:getWheel(0):getOffset():y() + 0.1
		end

		if string.match(string.lower(script:getName()), "trailer") then

		else
			local trailerAttachment = script:getAttachmentById("trailer")
			if trailerAttachment == nil then
				print(script:getName())
				local attach = ModelAttachment.new("trailer")
				attach:getOffset():set(0, attachHeigtOffset, -script:getPhysicsChassisShape():z()/2 - 0.1)
				attach:setZOffset(-1)

				script:addAttachment(attach)
			end

			local trailerAttachment = script:getAttachmentById("trailerfront")
			if trailerAttachment == nil then
				print(script:getName())
				local attach = ModelAttachment.new("trailerfront")
				attach:getOffset():set(0, attachHeigtOffset, script:getPhysicsChassisShape():z()/2 + 0.1)
				attach:setZOffset(1)

				script:addAttachment(attach)
			end
		end
	end
end

Events.OnGameBoot.Add(fixTowAttachmentsForOtherVehicleMods)