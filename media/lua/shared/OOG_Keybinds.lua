


OOG_Bindings = {
    {
        name = '[OutOfGas]'
    },
    {
        value = 'OOG_LeftKey',
        key = Keyboard.KEY_NUMPAD1,

    },

    {
        value = 'OOG_RightKey',
        key = Keyboard.KEY_NUMPAD2,

    },
}


local function InitKeybinds()

    if isServer() then return end

    
    for _, bind in ipairs(OOG_Bindings) do
        if bind.name then
            table.insert(keyBinding, { value = bind.name, key = nil })
        else
            if bind.key then
                table.insert(keyBinding, { value = bind.value, key = bind.key })
            end
        end
    end

    
end


InitKeybinds()