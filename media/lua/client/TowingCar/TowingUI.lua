if not TowCarMod then TowCarMod = {} end
if not TowCarMod.UI then TowCarMod.UI = {} end

---------------------------------------------------------------------------
--- UI functions
---------------------------------------------------------------------------

function TowCarMod.UI.removeDefaultTrailerOptions(playerObj)
   local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
   if menu == nil then return end

   local tmpSlices = menu.slices
   menu:clear()
   for _, slice in ipairs(tmpSlices) do
      if slice.command[1] ~= ISVehicleMenu.onAttachTrailer and slice.command[1] ~= ISVehicleMenu.onDetachTrailer then
         menu:addSlice(slice.text, slice.texture, slice.command[1], 
                        slice.command[2], slice.command[3], slice.command[4], slice.command[5], slice.command[6], slice.command[7])
      end
   end
end

--- Show menu with hook type options.
function TowCarMod.UI.showChooseTowTypeMenu(playerObj, vehicleA, vehicleB, hookTypeVariants)
   local playerIndex = playerObj:getPlayerNum()
   local menu = getPlayerRadialMenu(playerIndex)
   menu:clear()

   for _, hookType in ipairs(hookTypeVariants) do
      menu:addSlice(hookType.name, getTexture("media/textures/"..hookType.textureName..".png"), 
            hookType.func, playerObj, hookType.towingVehicle, hookType.towedVehicle, hookType.towingPoint, hookType.towedPoint)
   end
   
   menu:setX(getPlayerScreenLeft(playerIndex) + getPlayerScreenWidth(playerIndex) / 2 - menu:getWidth() / 2)
   menu:setY(getPlayerScreenTop(playerIndex) + getPlayerScreenHeight(playerIndex) / 2 - menu:getHeight() / 2)
   menu:addToUIManager()
   if JoypadState.players[playerObj:getPlayerNum()+1] then
      menu:setHideWhenButtonReleased(Joypad.DPadUp)
      setJoypadFocus(playerObj:getPlayerNum(), menu)
      playerObj:setJoypadIgnoreAimUntilCentered(true)
   end
end

--- Show menu with aviable vehicles for hook.
function TowCarMod.UI.showChooseVehicleMenu(playerObj, vehicle, vehicles, hasTowBar)
   local playerIndex = playerObj:getPlayerNum()
   local menu = getPlayerRadialMenu(playerIndex)
   menu:clear()

   for _, veh in ipairs(vehicles) do
      local mechType = TowCarMod.Utils.isTrailer(veh) and 4 or veh:getScript():getMechanicType()
      local textureNameByMechType = {
         [0] = "burnt_car_slice_icon",
         [1] = "standard_car_slice_icon",
         [2] = "heavy-duty_car_slice_icon",
         [3] = "sport_car_slice_icon",
         [4] = "trailer_sclice_icon"
      }

      local hookTypeVariants = TowCarMod.Utils.getHookTypeVariants(vehicle, veh, hasTowBar)
      if #hookTypeVariants == 1 then
         menu:addSlice(hookTypeVariants[1].name, getTexture("media/textures/"..textureNameByMechType[mechType]..".png"), 
               hookTypeVariants[1].func, playerObj, hookTypeVariants[1].towingVehicle, hookTypeVariants[1].towedVehicle, hookTypeVariants[1].towingPoint, hookTypeVariants[1].towedPoint)
      else
         local sliceName = getText("UI_Text_Towing_attach").."\n".. ISVehicleMenu.getVehicleDisplayName(veh).."\n..."
         menu:addSlice(sliceName, getTexture("media/textures/"..textureNameByMechType[mechType]..".png"), 
               TowCarMod.UI.showChooseTowTypeMenu, playerObj, vehicle, veh, hookTypeVariants)
      end
   end

   menu:setX(getPlayerScreenLeft(playerIndex) + getPlayerScreenWidth(playerIndex) / 2 - menu:getWidth() / 2)
   menu:setY(getPlayerScreenTop(playerIndex) + getPlayerScreenHeight(playerIndex) / 2 - menu:getHeight() / 2)
   menu:addToUIManager()
   if JoypadState.players[playerObj:getPlayerNum()+1] then
      menu:setHideWhenButtonReleased(Joypad.DPadUp)
      setJoypadFocus(playerObj:getPlayerNum(), menu)
      playerObj:setJoypadIgnoreAimUntilCentered(true)
   end
end

function TowCarMod.UI.addHookOptionToMenu(playerObj, vehicle)
   local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
   if menu == nil then return end

   local hasTowBar = playerObj:getInventory():getItemFromTypeRecurse("TowingCar.TowBar") ~= nil
   local vehicles = TowCarMod.Utils.getAviableVehicles(vehicle, hasTowBar)
   
   if #vehicles == 0 then
      menu:addSlice(getText("UI_Text_Towing_noAviableVehicles"), getTexture("media/textures/no_cars_for_tow.png"))

   elseif #vehicles == 1 then
      local hookTypeVariants = TowCarMod.Utils.getHookTypeVariants(vehicle, vehicles[1], hasTowBar)
      if #hookTypeVariants == 1 then
         menu:addSlice(hookTypeVariants[1].name, getTexture("media/textures/tow_car_icon.png"), 
               hookTypeVariants[1].func, playerObj, hookTypeVariants[1].towingVehicle, hookTypeVariants[1].towedVehicle, hookTypeVariants[1].towingPoint, hookTypeVariants[1].towedPoint)
      else
         local sliceName = getText("UI_Text_Towing_attach").."\n"..ISVehicleMenu.getVehicleDisplayName(vehicles[1]).."\n..."
         menu:addSlice(sliceName, getTexture("media/textures/tow_car_icon.png"), TowCarMod.UI.showChooseTowTypeMenu, playerObj, vehicle, vehicles[1], hookTypeVariants)
      end

   else
      menu:addSlice(getText("UI_Text_Towing_attach").. "...", getTexture("media/textures/tow_car_icon.png"), 
            TowCarMod.UI.showChooseVehicleMenu, playerObj, vehicle, vehicles, hasTowBar)
   end
end

function TowCarMod.UI.addUnhookOptionToMenu(playerObj, vehicle)
   local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
   if menu == nil then return end
   
   local towedVehicle = vehicle
   if vehicle:getVehicleTowing() then
      towedVehicle = vehicle:getVehicleTowing()
   end

   local deattachFunc
   if vehicle:getModData()["isTowingByTowTruck"] then
      deattachFunc = TowCarMod.Hook.deattachTowTruckAction
   elseif vehicle:getModData()["isTowingByTowBar"] then
      deattachFunc = TowCarMod.Hook.deattachTowBarAction
   elseif vehicle:getModData()["isTowingByRope"] then   
      deattachFunc = TowCarMod.Hook.deattachRopeTowAction
   else
      deattachFunc = TowCarMod.Hook.deattachTrailerAction
   end

   menu:addSlice(getText("ContextMenu_Vehicle_DetachTrailer", ISVehicleMenu.getVehicleDisplayName(towedVehicle)), 
         getTexture("media/textures/untow_car_icon.png"), deattachFunc, playerObj, towedVehicle)
end

---------------------------------------------------------------------------
--- Mod compability
---------------------------------------------------------------------------

if getActivatedMods():contains("vehicle_additions") then
   require('Vehicles/ISUI/Oven_Mattress_RadialMenu')
   require('Vehicles/ISUI/FuelTruckTank_ISVehicleMenu_FillPartMenu')
end

---------------------------------------------------------------------------
--- Attach to default menu method
---------------------------------------------------------------------------

--- Save default function for wrap it.
if TowCarMod.UI.defaultShowRadialMenu == nil then
   TowCarMod.UI.defaultShowRadialMenu = ISVehicleMenu.showRadialMenu
end
 
 --- Wrap default fuction.
function ISVehicleMenu.showRadialMenu(playerObj)
   TowCarMod.UI.defaultShowRadialMenu(playerObj)
   
   if playerObj:getVehicle() then  
   else
      TowCarMod.UI.removeDefaultTrailerOptions(playerObj)

      local vehicle = ISVehicleMenu.getVehicleToInteractWith(playerObj)
      if vehicle ~= nil then
         if vehicle:getVehicleTowing() or vehicle:getVehicleTowedBy() then
            TowCarMod.UI.addUnhookOptionToMenu(playerObj, vehicle)
         else
            TowCarMod.UI.addHookOptionToMenu(playerObj, vehicle)
         end
         
         -- Flip upsideDown vehicle by towTruck
         if TowCarMod.Utils.isTowTruck(vehicle) and TowCarMod.Flip.isUpsideDownVehicleNear(vehicle) then
            local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
            if menu == nil then return end
            menu:addSlice(getText("UI_Text_Towing_flipUpright"), getTexture("media/textures/upside_down_icon.png"), TowCarMod.Flip.flipAction, playerObj, vehicle)
         end
      end
   end
end