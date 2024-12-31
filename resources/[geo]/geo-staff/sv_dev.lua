if GetConvar('sv_dev', 'false') == 'true' then
    RegisterNetEvent('Dev.UpdatePropList')
    AddEventHandler('Dev.UpdatePropList', function(lst)
    
        local str = ''
        for k,v in pairs(lst) do
            str = str.. Format([[{%s, %s, %s, %s, %s}
    ]], table.unpack(v))
        end
    
        SaveResourceFile(GetCurrentResourceName(), 'props.txt', str, -1)
        print('done')
    end)

    RegisterCommand('coords', function(source, args)
        local file = LoadResourceFile(GetCurrentResourceName(), 'coords.txt')
        local pos = GetEntityCoords(GetPlayerPed(source))
        file = file..Format('{"x": %s, "y": %s, "z": %s}', pos.x, pos.y, pos.z)..'\n'
        SaveResourceFile(GetCurrentResourceName(), 'coords.txt', file, -1)
    end)
end

local version = io.popen('git describe --tags --long'):read('*all')
print('Version is: '..version)
AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining == 60 then
        print('Updating Code')
        CreateThread(function()
            os.execute('git fetch && git pull')
            os.execute('cd resources/[geo]/[assets]/ && git fetch && git pull')
        end)

        Wait(10000)
        if io.popen('git describe --tags --long'):read('*all') ~= version then
            PerformHttpRequest('127.0.0.1:8080/isUpdate', function(err, text, header) end, 'POST',
            json.encode({
                version = io.popen('git describe --tags --long'):read('*all'),
            }), { ['Content-Type'] = 'application/json'})
        end
    elseif eventData.secondsRemaining == 900 then
        TriggerClientEvent('Shared.Notif', -1, '15 Minutes until server reboot', 10000)
    end
    --[[ 
    eventData.secondsRemaining == 60 then
    print('Updating Code')
    CreateThread(function()
        os.execute('cd /home/geodexon/geodexon; git fetch; git pull;')
        os.execute('cd /home/geodexon/geodexon/resources/[geo]/[assets]/; git fetch; git pull;')
    end)

    Wait(10000)
    if io.popen('git describe --tags --long'):read('*all') ~= version then
        PerformHttpRequest('127.0.0.1:8080/isUpdate', function(err, text, header) end, 'POST',
        json.encode({
            version = io.popen('git describe --tags --long'):read('*all'),
        }), { ['Content-Type'] = 'application/json'})
    end ]]
end)

RegisterCommand('_fupdate', function(source)
    if source == 0 then
        print('Updating Code')
        CreateThread(function()
            os.execute('git fetch && git pull')
            os.execute('cd resources/[geo]/[assets]/ && git fetch && git pull')
        end)

        Wait(10000)
        if io.popen('git describe --tags --long'):read('*all') ~= version then
            PerformHttpRequest('127.0.0.1:8080/isUpdate', function(err, text, header) end, 'POST',
            json.encode({
                version = io.popen('git describe --tags --long'):read('*all'),
            }), { ['Content-Type'] = 'application/json'})
        end
    end
end)