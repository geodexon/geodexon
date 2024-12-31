Task.Register('Help.GetData', function(source)
    local char = GetCharacter(source)
    if char.data.help == nil then char.data.help = {} end

    local list = {}
    for k,v in pairs(char.data.help) do
        list[tostring(k)] = v
    end
    return char.data.help
end)

Task.Register('Help.SaveData', function(source, id)
    local char = GetCharacter(source)
    if char.data.help == nil then char.data.help = {} end
    char.data.help[id] = true
    SetData(source, 'help', char.data.help)
end)

Task.Register('Ref', function(source, code)
    if not RateLimit(source..' Ref', 1000) then return false end
    local user = GetUser(source)
    if user.data.myref then TriggerClientEvent('Shared.Notif', source, 'You have already registered a code'); return end
    local val = SQL('SELECT * from users WHERE json_value(`data`, "$.ref") = ?', code)[1]
    if not val then TriggerClientEvent('Shared.Notif', source, 'Invalid Ref Code') end
    if val and code == user.data.ref then 
        TriggerClientEvent('Shared.Notif', source, 'You can not use your own code') 
        return false
    end

    if val then
        SetUserData(source, 'myref', code)
    end

    return val or false
end)