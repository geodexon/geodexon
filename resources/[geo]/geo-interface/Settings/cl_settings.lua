RegisterCommand('settings', function()
    SendNUIMessage({
        interface = 'Settings',
        settings = MyUser.data.settings or {},
        commands = GlobalState.commandinfo,
    })
    UIFocus(true, true)
end)

RegisterNUICallback('Settings.Close', function()
    UIFocus(false, false)
end)

RegisterNUICallback('SetHUDColor', function(data, cb)
    GlobalNUI({
        type = 'Color',
        color = data.color,
        custom = data.custom
    })
    cb(true)
end)

RegisterNUICallback('SetWindowOpac', function(data, cb)
    GlobalNUI({
        type = 'WindowOpac',
        value = data.value,
    })
    cb(true)
end)

RegisterNUICallback('UISound', function(data, cb)
    GlobalNUI({
        type = 'UISound',
        value = data.value,
    })
    cb(true)
end)

RegisterNUICallback('SaveSettings', function(data, cb)
    Task.Run('SaveSettings', data.name, data.bool)
    TriggerEvent('Inventory.Equipped')
    cb(true)
end)

RegisterNUICallback('SaveCommandSettings', function(data, cb)
    Task.Run('SaveCommandSettings', data.name, data.bool)
    cb(true)
end)

RegisterCommand('guide', function()
    local menu = {
        {title = 'Guide', event = 'Guide', params = {'https://docs.google.com/document/d/17K7okFaL85N9i0T2_D3sr3zrOIO7BV5r9zSQUZ_GwLA/edit?usp=sharing'}},
        {title = 'Commands', event = 'Guide', params = {'https://docs.google.com/spreadsheets/d/12jxFnNzHw4CfKf2r4njPD898NtDceUaUHe1YUyLC6Dk/edit#gid=0'}},
    }

    RunMenu(menu)
end)

AddEventHandler('Guide', function(link)
    UIFocus(true, true, '~INPUT_SELECT_WEAPON~ Click Out Of Window', true)
    SendNUIMessage({
        interface = 'Browser',
        link = link
    })
end)


local indicators = {}
CreateThread(function()
    Wait(5000)

    for k,v in pairs(exports['geo']:ClothingStoreLocations()) do
        table.insert(indicators, {v, 32})
    end

    for k,v in pairs(exports['geo-store']:RepairLocations()) do
        table.insert(indicators, {v, 32})
    end

    while true do
        Wait(0)
        local pos = GetEntityCoords(Shared.Ped)
        if MyUser and (MyUser.data.settings.locationindicator == nil or MyUser.data.settings.locationindicator == true) then
            local found = false
            for k,v in pairs(indicators) do
                if Vdist3(pos, v[1]) <= 5.0 then
                    while Vdist3(GetEntityCoords(Shared.Ped), v[1]) <= 5.0 do
                        Wait(0)
                        DrawMarker(v[2], v[1], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 255, 255, false, false, 1, true)
                    end
                end
            end
            Wait(2500)
        else
            Wait(5000)
        end
    end
end)