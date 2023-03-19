

local function HandlePushOption(handler, direction)
    handler:startPushingVehicle(direction)
end


local function AddOptionPushVehicle(oogHandler, playerObj, context)

    local pushOption = context:addOption(getText("UI_Text_PushByHands"))
    local subMenuMain = context:getNew(context)
    context:addSubMenu(pushOption, subMenuMain)

    local leftOption = subMenuMain:addOption(getText("UI_Text_PushByHands_Left"))
    local subMenuLeft = context:getNew(context)
    context:addSubMenu(leftOption, subMenuLeft)
    subMenuLeft:addOption(getText("UI_Text_PushByHands_Front"), playerObj, HandlePushOption, oogHandler, "LEFT_FRONT")
    subMenuLeft:addOption(getText("UI_Text_PushByHands_Behind"), playerObj, HandlePushOption, oogHandler, "LEFT_BEHIND")

    local rightOption = subMenuMain:addOption(getText("UI_Text_PushByHands_Right"))
    local subMenuRight = context:getNew(context)
    context:addSubMenu(rightOption, subMenuRight)
    subMenuRight:addOption(getText("UI_Text_PushByHands_Front"), playerObj, HandlePushOption, oogHandler, "RIGHT_FRONT")
    subMenuRight:addOption(getText("UI_Text_PushByHands_Behind"), playerObj, HandlePushOption, oogHandler, "RIGHT_BEHIND")

    subMenuMain:addOption(getText("UI_Text_PushByHands_Front"), playerObj, HandlePushOption, oogHandler, "FRONT")
    subMenuMain:addOption(getText("UI_Text_PushByHands_Behind"), playerObj, HandlePushOption, oogHandler, "BEHIND")
end


-- Wrap the original function
local defaultMenuOutsideVehicle
if not defaultMenuOutsideVehicle then
    defaultMenuOutsideVehicle = ISVehicleMenu.FillMenuOutsideVehicle
end

-- Override the original function
function ISVehicleMenu.FillMenuOutsideVehicle(player, context, vehicle, test)
    defaultMenuOutsideVehicle(player, context, vehicle, test)

    local playerObj = getSpecificPlayer(player)
    local oogHandler = OOG_Handler:new(playerObj, vehicle)

    AddOptionPushVehicle(oogHandler, playerObj, context)

end
