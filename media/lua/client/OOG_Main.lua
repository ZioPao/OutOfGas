-- OUT OF GAS?
-- Some code referenced from the Better Towing mod from Aiteron

local function HandlePushOption(_, direction)
    OOG_Handler.StartPushingVehicle(direction)
end


local function AddOptionPushVehicle(oogHandler, playerObj, context)

    local pushOption = context:addOption(getText("UI_Text_PushByHands"))
    local subMenuMain = context:getNew(context)
    context:addSubMenu(pushOption, subMenuMain)
    subMenuMain:addOption(getText("UI_Text_PushByHands_Front"), playerObj, HandlePushOption, "FRONT")
    subMenuMain:addOption(getText("UI_Text_PushByHands_Behind"), playerObj, HandlePushOption, "BEHIND")
    subMenuMain:addOption(getText("UI_Text_PushByHands_Right"), playerObj, HandlePushOption, "RIGHT")
    subMenuMain:addOption(getText("UI_Text_PushByHands_Left"), playerObj, HandlePushOption, "LEFT")



end



local defaultMenuOutsideVehicle = ISVehicleMenu.FillMenuOutsideVehicle
function ISVehicleMenu.FillMenuOutsideVehicle(player, context, vehicle, test)
    defaultMenuOutsideVehicle(player, context, vehicle, test)

    local playerObj = getSpecificPlayer(player)

    if OOG_Handler.player ~= nil then
        OOG_Handler.StopAllLoops()
    end

    OOG_Handler.Setup(playerObj, vehicle)
    AddOptionPushVehicle(playerObj, context)

end
