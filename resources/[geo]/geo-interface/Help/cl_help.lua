local known = nil
RegisterNetEvent('Help', function(id)
    id = tostring(id)

    while known == nil do
        Wait(100)
    end

    if known[id] then return end
    known[id] = true
    Task.Run('Help.SaveData', id)
    if (MyUser == nil) or (MyUser and (MyUser.data.settings.serverhelp == nil or MyUser.data.settings.serverhelp == true)) then
        SendNUIMessage({
            interface = 'Help',
            id = id
        })
    end
end)

AddEventHandler('Login', function()
    known = Task.Run('Help.GetData')
end)

CreateThread(function()
    Wait(100)
    if MyCharacter then
        known = Task.Run('Help.GetData')
    end
end)

RegisterNetEvent('Logout', function()
    known = nil
end)

RegisterKeyMapping('__uicursor', '[Interface] UI Cursor ~g~ +Modifier~w~', 'keyboard', 'LMENU')
RegisterCommand('__uicursor', function()
    if not controlMod then return end
    SendNUIMessage({
        interface = 'uicursor',
        known = known,
        user = MyUser
    })

    SetCursorLocation(0.975, 0.95)
    UIFocus(true, true)
end)

RegisterNUICallback('Help.Command', function(data,cb)
    ExecuteCommand(data.command)
end)

RegisterNUICallback('Ref', function(data,cb)
    cb(Task.Run('Ref', data.code))
end)

exports('Known', function()
    return known
end)