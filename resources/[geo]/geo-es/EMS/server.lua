RegisterNetEvent('EMS.Revive')
AddEventHandler('EMS.Revive', function(id, staff)
    local source = source
    local char = GetCharacter(source)
    if IsEMS(char.id) or (staff and char.username) or exports['geo-rpg']:GetQuest(source, 'police.medical') then
        UpdateChar(id, 'dead', 0)
    end
end)

RegisterNetEvent('EMS.Heal')
AddEventHandler('EMS.Heal', function(id)
    local source = source
    local char = GetCharacter(source)
    if IsEMS(char.id) then
        exports['geo-status']:Add(id, 'hospital', 200)
    end
end)

RegisterNetEvent('EMS.Painkiller')
AddEventHandler('EMS.Painkiller', function(id)
    local source = source
    local char = GetCharacter(source)
    if IsEMS(char.id) and exports['geo-inventory']:RemoveItem('Player', source, 'pain_killer', 1) then
        TriggerClientEvent('EMS.Painkiller', id)
    end
end)

RegisterCommand('kittylitter', function(source)
    local char = GetCharacter(source)
    if IsEMS(char.id) then
        TriggerClientEvent('EMS.KittyLitter', -1, GetEntityCoords(GetPlayerPed(source)))
    end
end)