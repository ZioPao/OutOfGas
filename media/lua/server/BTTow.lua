BTtow = {}
BTtow.Create = {}
BTtow.Init = {}

function BTtow.Create.towbar(vehicle, part)  
    for j=0, 23 do
        part:setModelVisible("towbar" .. j, false)        
    end
end

function BTtow.Init.towbar(vehicle, part)
    for j=0, 23 do
        part:setModelVisible("towbar" .. j, false)        
    end
    if vehicle:getScript():getModelScale() > 2 or vehicle:getScript():getModelScale() < 1.5 then return end
    if vehicle:getModData()["isTowingByTowBar"] and vehicle:getModData()["towed"] then 
        local z = vehicle:getScript():getPhysicsChassisShape():z()/2 - 0.1
        part:setModelVisible("towbar" .. math.floor((z*2/3-1)*10), true)
    end
end

function BTtow.Create.rope(vehicle, part)  
    for j=0, 23 do
        part:setModelVisible("rope" .. j, false)    
    end
end

function BTtow.Init.rope(vehicle, part) 
    for j=0, 23 do
        part:setModelVisible("rope" .. j, false)    
    end
    if vehicle:getScript():getModelScale() > 2 or vehicle:getScript():getModelScale() < 1.5 then return end
    if vehicle:getModData()["isTowingByRope"] and vehicle:getModData()["towing"] then 
        local z = vehicle:getScript():getPhysicsChassisShape():z()/2 - 0.1
        part:setModelVisible("rope" .. math.floor((z*2/3-1)*10), true)
    end
end
