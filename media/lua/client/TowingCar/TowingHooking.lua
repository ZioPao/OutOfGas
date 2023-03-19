if not TowCarMod then TowCarMod = {} end
if not TowCarMod.Hook then TowCarMod.Hook = {} end

---------------------------------------------------------------------------
--- Trailer functions
---------------------------------------------------------------------------

function TowCarMod.Hook.performAttachTrailer(playerObj, towingVehicle, towedVehicle, attachmentA, attachmentB)
    if #(TowCarMod.Utils.getHookTypeVariants(towingVehicle, towedVehicle, false)) == 0 then return end
    
    local args = { vehicleA = towingVehicle:getId(), vehicleB = towedVehicle:getId(), attachmentA = attachmentA, attachmentB = attachmentB }
    sendClientCommand(playerObj, 'vehicle', 'attachTrailer', args)
end

function TowCarMod.Hook.attachTrailerAction(playerObj, towingVehicle, towedVehicle, towingPoint, towedPoint)
    if playerObj == nil or towingVehicle == nil or towedVehicle == nil then return end

    -- check vehicle available
    if #(TowCarMod.Utils.getHookTypeVariants(towingVehicle, towedVehicle, false)) == 0 then return end

    --- Go to rear of towing vehicle
    local hookPoint = towingVehicle:getAttachmentWorldPos(towingPoint, TowCarMod.Utils.tempVector1)
    if hookPoint == nil then return end
    ISTimedActionQueue.add(TACustomPathFind:pathToLocationF(playerObj, hookPoint:x(), hookPoint:y(), hookPoint:z()))
  
    -- Unequip item
    local storePrim = playerObj:getPrimaryHandItem()
    if storePrim ~= nil then
        ISTimedActionQueue.add(ISUnequipAction:new(playerObj, storePrim, 12));
    end

    -- Attach
    ISTimedActionQueue.add(TAHookVehicle:new(playerObj, 100, TowCarMod.Config.lowLevelAnimation, 
            TowCarMod.Hook.performAttachTrailer, towingVehicle, towedVehicle, towingPoint, towedPoint))
end

function TowCarMod.Hook.performDeattachTrailer(playerObj, towingVehicle, towedVehicle)
    local args = { vehicle = towingVehicle:getId() }
	sendClientCommand(playerObj, 'vehicle', 'detachTrailer', args)
end

function TowCarMod.Hook.deattachTrailerAction(playerObj, vehicle)
    local towingVehicle = vehicle
    if vehicle:getVehicleTowedBy() then
        towingVehicle = vehicle:getVehicleTowedBy()
    end
    
    --- Go to rear of towing vehicle
    local hookPoint = towingVehicle:getAttachmentWorldPos("trailer", TowCarMod.Utils.tempVector1)
    if hookPoint == nil then return end
    ISTimedActionQueue.add(TACustomPathFind:pathToLocationF(playerObj, hookPoint:x(), hookPoint:y(), hookPoint:z()))
  
    -- Unequip item
    local storePrim = playerObj:getPrimaryHandItem()
    if storePrim ~= nil then
       ISTimedActionQueue.add(ISUnequipAction:new(playerObj, storePrim, 12));
    end
   
    -- Deattach
    ISTimedActionQueue.add(TAHookVehicle:new(playerObj, 100, TowCarMod.Config.lowLevelAnimation, TowCarMod.Hook.performDeattachTrailer, towingVehicle, towingVehicle:getVehicleTowing()))
end

---------------------------------------------------------------------------
--- Tow truck functions
---------------------------------------------------------------------------

function TowCarMod.Hook.performAttachTowTruck(playerObj, towingVehicle, towedVehicle, attachmentA, attachmentB)
    if #(TowCarMod.Utils.getHookTypeVariants(towingVehicle, towedVehicle, false)) == 0 then return end
    
    TowCarMod.Utils.updateAttachmentsForRigidTow(towingVehicle, towedVehicle, attachmentA, attachmentB, true)
    
    local args = { vehicleA = towingVehicle:getId(), vehicleB = towedVehicle:getId(), attachmentA = attachmentA, attachmentB = attachmentB }
    sendClientCommand(playerObj, 'vehicle', 'attachTrailer', args)

    towingVehicle:getModData()["isTowingByTowTruck"] = true
    towingVehicle:transmitModData()
    towedVehicle:getModData()["isTowingByTowTruck"] = true
    towedVehicle:transmitModData()

    towedVehicle:updateTotalMass()
end

function TowCarMod.Hook.attachTowTruckAction(playerObj, towingVehicle, towedVehicle)
    if playerObj == nil or towingVehicle == nil or towedVehicle == nil then return end

    local attachment
    if towingVehicle:canAttachTrailer(towedVehicle, "trailer", "trailerfront") then    
        attachment = "trailerfront"
    elseif towingVehicle:canAttachTrailer(towedVehicle, "trailer", "trailer") then
        attachment = "trailer"
    else
        return
    end

    --- Go to rear of tow truck
    local hookPoint = towingVehicle:getAttachmentWorldPos("trailer", TowCarMod.Utils.tempVector1)
    if hookPoint == nil then return end
    ISTimedActionQueue.add(TACustomPathFind:pathToLocationF(playerObj, hookPoint:x(), hookPoint:y(), hookPoint:z()))
    
    --- Unequip item
    local storePrim = playerObj:getPrimaryHandItem()
    if storePrim ~= nil then
       ISTimedActionQueue.add(ISUnequipAction:new(playerObj, storePrim, 12));
    end

    --- First attach animation
    ISTimedActionQueue.add(TAHookVehicle:new(playerObj, 100, TowCarMod.Config.highLevelAnimation))

    --- Go to attachment point of towed vehicle
    local hookPoint = towedVehicle:getAttachmentWorldPos(attachment, TowCarMod.Utils.tempVector1)
    if hookPoint == nil then return end
    ISTimedActionQueue.add(TACustomPathFind:pathToLocationF(playerObj, hookPoint:x(), hookPoint:y(), hookPoint:z()))

    -- Attach vehicle
    ISTimedActionQueue.add(TAHookVehicle:new(playerObj, 100, TowCarMod.Config.lowLevelAnimation, 
            TowCarMod.Hook.performAttachTowTruck, towingVehicle, towedVehicle, "trailer", attachment))
end

function TowCarMod.Hook.performDeattachTowTruck(playerObj, towingVehicle, towedVehicle)
    TowCarMod.Utils.updateAttachmentsOnDefaultValues(towingVehicle, towedVehicle, true)

    local args = { vehicle = towingVehicle:getId() }
	sendClientCommand(playerObj, 'vehicle', 'detachTrailer', args)
    

    towingVehicle:getModData()["isTowingByTowTruck"] = false
    towingVehicle:transmitModData()
    towedVehicle:getModData()["isTowingByTowTruck"] = false
    towedVehicle:transmitModData()
end

function TowCarMod.Hook.deattachTowTruckAction(playerObj, vehicle)
    local towingVehicle = vehicle:getVehicleTowedBy()
    local towedVehicle = vehicle
    if vehicle:getVehicleTowing() then
        towingVehicle = vehicle
        towedVehicle = vehicle:getVehicleTowing()
    end

    --- Go to attachment point of towed vehicle
    local localPoint = towedVehicle:getAttachmentLocalPos(towedVehicle:getTowAttachmentSelf(), TowCarMod.Utils.tempVector1)
    local shift = 0
    if towedVehicle:getModData()["isChangedTowedAttachment"] then
        shift = localPoint:z() > 0 and -1 or 1
    end
    shift = shift * 0.2
    local hookPoint = towedVehicle:getWorldPos(localPoint:x(), localPoint:y(), localPoint:z() + shift, TowCarMod.Utils.tempVector2)
    if hookPoint == nil then return end
    ISTimedActionQueue.add(TACustomPathFind:pathToLocationF(playerObj, hookPoint:x(), hookPoint:y(), hookPoint:z()))

    -- Unequip item
    local storePrim = playerObj:getPrimaryHandItem()
    if storePrim ~= nil then
       ISTimedActionQueue.add(ISUnequipAction:new(playerObj, storePrim, 12));
    end
    
    --- First animation of deattach
    ISTimedActionQueue.add(TAHookVehicle:new(playerObj, 100, TowCarMod.Config.highLevelAnimation))

    --- Go to rear of tow truck
    local localPoint = towingVehicle:getAttachmentLocalPos(towingVehicle:getTowAttachmentSelf(), TowCarMod.Utils.tempVector1)
    local shift = 0
    if towingVehicle:getModData()["isChangedTowedAttachment"] then
        shift = localPoint:z() > 0 and -1 or 1
    end
    shift = shift * 0.2
    local hookPoint = towingVehicle:getWorldPos(localPoint:x(), localPoint:y(), localPoint:z() + shift, TowCarMod.Utils.tempVector2)
    if hookPoint == nil then return end
    ISTimedActionQueue.add(TACustomPathFind:pathToLocationF(playerObj, hookPoint:x(), hookPoint:y(), hookPoint:z()))
    
    --- Deattach vehicle
    ISTimedActionQueue.add(TAHookVehicle:new(playerObj, 100, TowCarMod.Config.highLevelAnimation, TowCarMod.Hook.performDeattachTowTruck, towingVehicle, towedVehicle))
end

---------------------------------------------------------------------------
--- Tow rope functions
---------------------------------------------------------------------------

function TowCarMod.Hook.performAttachTowRope(playerObj, towingVehicle, towedVehicle, attachmentA, attachmentB)
    if #(TowCarMod.Utils.getHookTypeVariants(towingVehicle, towedVehicle, false)) == 0 then return end
    
    local args = { vehicleA = towingVehicle:getId(), vehicleB = towedVehicle:getId(), attachmentA = attachmentA, attachmentB = attachmentB }
    sendClientCommand(playerObj, 'vehicle', 'attachTrailer', args)

    towingVehicle:getModData()["isTowingByRope"] = true
    towedVehicle:getModData()["isTowingByRope"] = true
    towingVehicle:getModData()["towing"] = true
    towingVehicle:transmitModData()
    towedVehicle:transmitModData()

    local part = towingVehicle:getPartById("rope")
    for j=0, 23 do
        part:setModelVisible("rope" .. j, false)    
    end
    if towingVehicle:getScript():getModelScale() > 2 or towingVehicle:getScript():getModelScale() < 1.5 then return end
    local z = towingVehicle:getScript():getPhysicsChassisShape():z()/2 - 0.1
    part:setModelVisible("rope" .. math.floor((z*2/3-1)*10), true)

    towingVehicle:doDamageOverlay()
end

function TowCarMod.Hook.attachByTowRopeAction(playerObj, towingVehicle, towedVehicle)
    if playerObj == nil or towingVehicle == nil or towedVehicle == nil then return end
        
    -- check vehicle available
    if #(TowCarMod.Utils.getHookTypeVariants(towingVehicle, towedVehicle, false)) == 0 then return end

    local attachmentA, attachmentB = TowCarMod.Utils.getRopeTowPossibleAttachPoints(towingVehicle, towedVehicle)
    if attachmentA == nil or attachmentB == nil then return end

    --- Go to attachment point
    local hookPoint = towedVehicle:getAttachmentWorldPos(attachmentB, TowCarMod.Utils.tempVector1)
    if hookPoint == nil then return end
    ISTimedActionQueue.add(TACustomPathFind:pathToLocationF(playerObj, hookPoint:x(), hookPoint:y(), hookPoint:z()))
    
    -- Unequip item
    local storePrim = playerObj:getPrimaryHandItem()
    if storePrim ~= nil then
       ISTimedActionQueue.add(ISUnequipAction:new(playerObj, storePrim, 12));
    end

    --- First attach animation
    ISTimedActionQueue.add(TAHookVehicle:new(playerObj, 100, TowCarMod.Config.lowLevelAnimation))

    --- Go to second attachment point
    local hookPoint = towingVehicle:getAttachmentWorldPos(attachmentA, TowCarMod.Utils.tempVector1)
    if hookPoint == nil then return end
    ISTimedActionQueue.add(TACustomPathFind:pathToLocationF(playerObj, hookPoint:x(), hookPoint:y(), hookPoint:z()))

    --- Attach vehicle
    ISTimedActionQueue.add(TAHookVehicle:new(playerObj, 100, TowCarMod.Config.lowLevelAnimation, 
    TowCarMod.Hook.performAttachTowRope, towingVehicle, towedVehicle, attachmentA, attachmentB))
end

function TowCarMod.Hook.performDeattachTowRope(playerObj, towingVehicle, towedVehicle)
    towingVehicle:getModData()["isTowingByRope"] = false
    towedVehicle:getModData()["isTowingByRope"] = false
    towingVehicle:getModData()["towing"] = false
    towingVehicle:transmitModData()
    towedVehicle:transmitModData()

    local args = { vehicle = towingVehicle:getId() }
	sendClientCommand(playerObj, 'vehicle', 'detachTrailer', args)

    local part = towingVehicle:getPartById("rope")
    for j=0, 23 do
        part:setModelVisible("rope" .. j, false)    
    end

    towingVehicle:doDamageOverlay()
end

function TowCarMod.Hook.deattachRopeTowAction(playerObj, vehicle)       
    local towingVehicle = vehicle
    local towedVehicle = vehicle:getVehicleTowing()
    if vehicle:getVehicleTowedBy() then
        towingVehicle = vehicle:getVehicleTowedBy()
        towedVehicle = vehicle
    end
    
    -- Go to attachment point
    local hookPoint = towedVehicle:getAttachmentWorldPos(towedVehicle:getTowAttachmentSelf(), TowCarMod.Utils.tempVector1)
    if hookPoint == nil then return end
    ISTimedActionQueue.add(TACustomPathFind:pathToLocationF(playerObj, hookPoint:x(), hookPoint:y(), hookPoint:z()))
 
    -- Unequip item
    local storePrim = playerObj:getPrimaryHandItem()
    if storePrim ~= nil then
       ISTimedActionQueue.add(ISUnequipAction:new(playerObj, storePrim, 12));
    end

    --- First deattach animation
    ISTimedActionQueue.add(TAHookVehicle:new(playerObj, 100, TowCarMod.Config.lowLevelAnimation))

    -- Go to second attachment point
    local hookPoint = towingVehicle:getAttachmentWorldPos(towingVehicle:getTowAttachmentSelf(), TowCarMod.Utils.tempVector1)
    if hookPoint == nil then return end
    ISTimedActionQueue.add(TACustomPathFind:pathToLocationF(playerObj, hookPoint:x(), hookPoint:y(), hookPoint:z()))
    
    --- Deattach
    ISTimedActionQueue.add(TAHookVehicle:new(playerObj, 100, TowCarMod.Config.lowLevelAnimation, TowCarMod.Hook.performDeattachTowRope, towingVehicle, towedVehicle))
end

---------------------------------------------------------------------------
--- Tow bar functions
---------------------------------------------------------------------------

function TowCarMod.Hook.performAttachTowBar(playerObj, towingVehicle, towedVehicle, attachmentA, attachmentB)
    if #(TowCarMod.Utils.getHookTypeVariants(towingVehicle, towedVehicle, true)) == 0 then return end
    
    playerObj:getInventory():Remove(playerObj:getInventory():getItemFromType("TowingCar.TowBar"))
    playerObj:setPrimaryHandItem(nil)      -- for update prim item icon

    TowCarMod.Utils.updateAttachmentsForRigidTow(towingVehicle, towedVehicle, attachmentA, attachmentB, false)
    
    local args = { vehicleA = towingVehicle:getId(), vehicleB = towedVehicle:getId(), attachmentA = attachmentA, attachmentB = attachmentB }
    sendClientCommand(playerObj, 'vehicle', 'attachTrailer', args)

    towingVehicle:getModData()["isTowingByTowBar"] = true
    towedVehicle:getModData()["isTowingByTowBar"] = true
    towedVehicle:getModData()["towed"] = true
    towingVehicle:transmitModData()
    towedVehicle:transmitModData()

    towedVehicle:updateTotalMass()

    local part = towedVehicle:getPartById("towbar")
    if towedVehicle:getScript():getModelScale() > 2 or towedVehicle:getScript():getModelScale() < 1.5 then return end
    local z = towedVehicle:getScript():getPhysicsChassisShape():z()/2 - 0.1
    part:setModelVisible("towbar" .. math.floor((z*2/3-1)*10), true)
    towedVehicle:doDamageOverlay()
end

function TowCarMod.Hook.attachByTowBarAction(playerObj, towingVehicle, towedVehicle)
    if playerObj == nil or towingVehicle == nil or towedVehicle == nil then return end

    local item = playerObj:getInventory():getItemFromTypeRecurse("TowingCar.TowBar")
    if item == nil then return end

    -- check vehicle available
    if #(TowCarMod.Utils.getHookTypeVariants(towingVehicle, towedVehicle, true)) == 0 then return end
    
    --- Go to attachment point
    local hookPoint = towedVehicle:getAttachmentWorldPos("trailerfront", TowCarMod.Utils.tempVector1)
    if hookPoint == nil then return end
    ISTimedActionQueue.add(TACustomPathFind:pathToLocationF(playerObj, hookPoint:x(), hookPoint:y(), hookPoint:z()))
    
    --- If need - transfer item to main inventory
    if not playerObj:getInventory():contains("TowingCar.TowBar") then 
        ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, item:getContainer(), playerObj:getInventory(), nil))
    end

    -- Equip item
    local storePrim = playerObj:getPrimaryHandItem()
    if not storePrim or storePrim ~= item then
        ISTimedActionQueue.add(ISEquipWeaponAction:new(playerObj, item, 12, true));
    end

    --- First attach animation
    ISTimedActionQueue.add(TAHookVehicle:new(playerObj, 300, TowCarMod.Config.lowLevelAnimation))

    ---Go to second attachment point
    local hookPoint = towingVehicle:getAttachmentWorldPos("trailer", TowCarMod.Utils.tempVector1)
    if hookPoint == nil then return end
    ISTimedActionQueue.add(TACustomPathFind:pathToLocationF(playerObj, hookPoint:x(), hookPoint:y(), hookPoint:z()))

    -- Attach
    ISTimedActionQueue.add(TAHookVehicle:new(playerObj, 100, TowCarMod.Config.lowLevelAnimation, 
            TowCarMod.Hook.performAttachTowBar, towingVehicle, towedVehicle, "trailer", "trailerfront"))
end

function TowCarMod.Hook.performDeattachTowBar(playerObj, towingVehicle, towedVehicle)
    TowCarMod.Utils.updateAttachmentsOnDefaultValues(towingVehicle, towedVehicle, false)
    
    local args = { vehicle = towingVehicle:getId() }
	sendClientCommand(playerObj, 'vehicle', 'detachTrailer', args)
    
    playerObj:getInventory():AddItem("TowingCar.TowBar")
    playerObj:setPrimaryHandItem(playerObj:getInventory():getItemFromType("TowingCar.TowBar"))

    towingVehicle:getModData()["isTowingByTowBar"] = false
    towedVehicle:getModData()["isTowingByTowBar"] = false
    towedVehicle:getModData()["towed"] = false
    towingVehicle:transmitModData()
    towedVehicle:transmitModData()

    local part = towedVehicle:getPartById("towbar")
    for j=0, 23 do
        part:setModelVisible("towbar" .. j, false)        
    end
    towedVehicle:doDamageOverlay()
end

function TowCarMod.Hook.deattachTowBarAction(playerObj, vehicle)
    local towingVehicle = vehicle
    local towedVehicle = vehicle:getVehicleTowing()
    if vehicle:getVehicleTowedBy() then
        towingVehicle = vehicle:getVehicleTowedBy()
        towedVehicle = vehicle
    end
    
    --- Go to attachment point   
    local localPoint = towingVehicle:getAttachmentLocalPos(towingVehicle:getTowAttachmentSelf(), TowCarMod.Utils.tempVector1)
    local shift = 0
    if towingVehicle:getModData()["isChangedTowedAttachment"] then
        shift = localPoint:z() > 0 and -1 or 1
    end
    local hookPoint = towingVehicle:getWorldPos(localPoint:x(), localPoint:y(), localPoint:z() + shift, TowCarMod.Utils.tempVector2)
    if hookPoint == nil then return end
    ISTimedActionQueue.add(TACustomPathFind:pathToLocationF(playerObj, hookPoint:x(), hookPoint:y(), hookPoint:z()))
   
    -- Unequip item
    local storePrim = playerObj:getPrimaryHandItem()
    if storePrim ~= nil then
       ISTimedActionQueue.add(ISUnequipAction:new(playerObj, storePrim, 12));
    end
    
    --- Fist attach animation
    ISTimedActionQueue.add(TAHookVehicle:new(playerObj, 100, TowCarMod.Config.lowLevelAnimation))

    --- Go to second attachment point
    local localPoint = towedVehicle:getAttachmentLocalPos(towedVehicle:getTowAttachmentSelf(), TowCarMod.Utils.tempVector1)
    local shift = 0
    if towedVehicle:getModData()["isChangedTowedAttachment"] then
        shift = localPoint:z() > 0 and -1 or 1
    end
    local hookPoint = towedVehicle:getWorldPos(localPoint:x(), localPoint:y(), localPoint:z() + shift, TowCarMod.Utils.tempVector2)
    if hookPoint == nil then return end
    ISTimedActionQueue.add(TACustomPathFind:pathToLocationF(playerObj, hookPoint:x(), hookPoint:y(), hookPoint:z()))
    
    --- Attach
    ISTimedActionQueue.add(TAHookVehicle:new(playerObj, 300, TowCarMod.Config.lowLevelAnimation, TowCarMod.Hook.performDeattachTowBar, towingVehicle, towedVehicle))
end

