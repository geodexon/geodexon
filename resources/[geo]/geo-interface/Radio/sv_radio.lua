local reservedChannels = 6

RegisterNetEvent('Radio.On')
AddEventHandler('Radio.On', function(channel)
    local source = source

    if channel < reservedChannels then
        if not exports['geo-es']:IsEs(GetCharacter(source).id) or channel < 0 or channel > 1000 then
            TriggerClientEvent('Shared.Notif', source, "You can't access this channel")
            return
        end
    end

    TriggerClientEvent('Radio.On', -1, source, channel)
end)

RegisterNetEvent('Radio.Off')
AddEventHandler('Radio.Off', function(channel)
    local source = source
    TriggerClientEvent('Radio.Off', -1, source, channel)
end)
--[[ 
CreateThread(function()
    while true do
        for k,v in pairs(GetPlayers()) do
            local ped = GetPlayerPed(v)
            if DoesEntityExist(ped) then
                SetEntityDistanceCullingRadius(ped, 1000000.0)
            end
        end
        Wait(10000)
    end
end) ]]