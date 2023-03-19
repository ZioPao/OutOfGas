local currentVehicle
local currentCharacter
local currentDir


local function PushVehicleHelper(ticks)

    if currentCharacter:isAiming() then Events.OnTick.Remove(PushVehicleHelper) end

    if not currentCharacter:isPlayerMoving() then return end

    --print("Pushing!")
    local lenHalf = currentVehicle:getScript():getPhysicsChassisShape():z()/2
    local heightHalf = currentVehicle:getScript():getPhysicsChassisShape():y()/2
    local x = 0
    local z = 0
    
    local fx = 0
    local fz = 0

    local forceCoeff = 10

    if currentDir == "FRONT" then
        fz = -1
    elseif currentDir == "BEHIND" then
        fz = 1
    elseif currentDir == "LEFT_FRONT" then
        z = lenHalf
        fx = -1
    elseif currentDir == "LEFT_BEHIND" then
        z = -lenHalf
        fx = -1
    elseif currentDir == "RIGHT_FRONT" then
        z = lenHalf
        fx = 1
    elseif currentDir == "RIGHT_BEHIND" then
        z = -lenHalf
        fx = 1
    end

    local forceVector = currentVehicle:getWorldPos(fx, 0, fz, TowCarMod.Utils.tempVector1):add(-currentVehicle:getX(), -currentVehicle:getY(), -currentVehicle:getZ())
    local pushPoint = currentVehicle:getWorldPos(x, 0, z, TowCarMod.Utils.tempVector2):add(-currentVehicle:getX(), -currentVehicle:getY(), -currentVehicle:getZ())
    pushPoint:set(pushPoint:x(), 0, pushPoint:y())
    
    local force = 0.5 + 0.1 * currentCharacter:getPerkLevel(Perks.Strength)
    forceVector:mul(forceCoeff * force * currentVehicle:getMass())
    forceVector:set(forceVector:x(), 0, forceVector:y())

    currentVehicle:setPhysicsActive(true)

    if currentVehicle:getSpeed2D() < 1 then
        currentVehicle:addImpulse(forceVector, pushPoint)
    end
end


local function pushVehicle(playerObj, vehicle, direction)
    local lenHalf = vehicle:getScript():getPhysicsChassisShape():z()/2
    local widthHalf = vehicle:getScript():getPhysicsChassisShape():x()/2
    local x = 0
    local z = 0
    
    if direction == "FRONT" then
        z = lenHalf
    elseif direction == "BEHIND" then
        z = -lenHalf
    elseif direction == "LEFT_FRONT" then
        z = lenHalf*0.8
        x = widthHalf
    elseif direction == "LEFT_BEHIND" then
        z = -lenHalf*0.8
        x = widthHalf
    elseif direction == "RIGHT_FRONT" then
        z = lenHalf*0.8
        x = -widthHalf
    elseif direction == "RIGHT_BEHIND" then
        z = -lenHalf*0.8
        x = -widthHalf
    end

    currentCharacter = playerObj
    currentVehicle = vehicle
    currentDir = direction

    Events.OnTick.Add(PushVehicleHelper)
end


local function addOptionPushVehicle(playerObj, context, vehicle)
    local pushOption = context:addOption(getText("UI_Text_PushByHands"))
    local subMenuMain = context:getNew(context)
    context:addSubMenu(pushOption, subMenuMain)

    local leftOption = subMenuMain:addOption(getText("UI_Text_PushByHands_Left"))
    local subMenuLeft = context:getNew(context)
    context:addSubMenu(leftOption, subMenuLeft)
    subMenuLeft:addOption(getText("UI_Text_PushByHands_Front"), playerObj, pushVehicle, vehicle, "LEFT_FRONT")
    subMenuLeft:addOption(getText("UI_Text_PushByHands_Behind"), playerObj, pushVehicle, vehicle, "LEFT_BEHIND")

    local rightOption = subMenuMain:addOption(getText("UI_Text_PushByHands_Right"))
    local subMenuRight = context:getNew(context)
    context:addSubMenu(rightOption, subMenuRight)
    subMenuRight:addOption(getText("UI_Text_PushByHands_Front"), playerObj, pushVehicle, vehicle, "RIGHT_FRONT")
    subMenuRight:addOption(getText("UI_Text_PushByHands_Behind"), playerObj, pushVehicle, vehicle, "RIGHT_BEHIND")

    subMenuMain:addOption(getText("UI_Text_PushByHands_Front"), playerObj, pushVehicle, vehicle, "FRONT")
    subMenuMain:addOption(getText("UI_Text_PushByHands_Behind"), playerObj, pushVehicle, vehicle, "BEHIND")
end


-- Wrap the original function
local defaultMenuOutsideVehicle
if not defaultMenuOutsideVehicle then
    defaultMenuOutsideVehicle = ISVehicleMenu.FillMenuOutsideVehicle
end

-- Override the original function
function ISVehicleMenu.FillMenuOutsideVehicle(player, context, vehicle, test)
    defaultMenuOutsideVehicle(player, context, vehicle, test)

    addOptionPushVehicle(getSpecificPlayer(player), context, vehicle)
end
