-- OUT OF GAS?
-- Some code referenced from the Better Towing mod from Aiteron

local function HandlePushOption(_, handler, direction)
    handler:startPushingVehicle(direction)
end


local function AddOptionPushVehicle(oogHandler, playerObj, context)

    local pushOption = context:addOption(getText("UI_Text_PushByHands"))
    local subMenuMain = context:getNew(context)
    context:addSubMenu(pushOption, subMenuMain)
    subMenuMain:addOption(getText("UI_Text_PushByHands_Front"), playerObj, HandlePushOption, oogHandler, "FRONT")
    subMenuMain:addOption(getText("UI_Text_PushByHands_Behind"), playerObj, HandlePushOption, oogHandler, "BEHIND")
    subMenuMain:addOption(getText("UI_Text_PushByHands_Right"), playerObj, HandlePushOption, oogHandler, "RIGHT")
    subMenuMain:addOption(getText("UI_Text_PushByHands_Left"), playerObj, HandlePushOption, oogHandler, "LEFT")



end



local defaultMenuOutsideVehicle = ISVehicleMenu.FillMenuOutsideVehicle
function ISVehicleMenu.FillMenuOutsideVehicle(player, context, vehicle, test)
    defaultMenuOutsideVehicle(player, context, vehicle, test)

    local playerObj = getSpecificPlayer(player)

    local oogHandler = OOG_Handler.GetInstance()

    if oogHandler ~= nil then
        OOG_Handler.currentHandler = nil
    end

    oogHandler = OOG_Handler:new(playerObj, vehicle)
    AddOptionPushVehicle(oogHandler, playerObj, context)

end
