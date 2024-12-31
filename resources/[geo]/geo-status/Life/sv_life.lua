CreateThread(function()
    Wait(1000)
    SQL('DELETE a FROM characters a INNER join (SELECT cid FROM death_queue) AS b ON a.id = b.cid WHERE a.id = b.cid')
    SQL('DELETE FROM death_queue WHERE 1 = 1')
end)

AddEventHandler('Login', function(char)
    exports.ghmattimysql:execute('INSERT INTO status_life (cid) SELECT id FROM characters WHERE id = ? AND (SELECT COUNT(cid) FROM status_life WHERE cid = ?) = 0', {
        char.id, char.id
    })
end)

local diedAt = {}
RegisterNetEvent('Status.Death')
AddEventHandler('Status.Death', function(loc)
    local source = source
    local char = GetCharacter(source)
    diedAt[source] = os.time() + 300
    RemoveLife(100, char)
    Wait(500)
    Status:Remove(source, 'bleeding', -1)
    TriggerClientEvent('SkeletonChalice', source)

    --exports['geo-es']:EMSEvent('AddTempBlip', 'null', GetEntityCoords(GetPlayerPed(source)) + vec(Random(100), Random(100), 0), {color = 1, range = 100.0, noclear = true})
    --exports['geo-es']:EMSEvent('Chat.Message', '[Alert]', 'Reports of a downed individual at '..loc.location, '911')
    TriggerEvent('Dispatch', {
        code = '10-52',
        title = 'Injured Individual',
        location = loc.position,

        time =  os.date('%H:%M EST'),
        info = {
            {
                icon = 'location',
                text = loc.location,
                location = true
            },
        },
        EMS = true
    })
end)

RegisterNetEvent('Respawn')
AddEventHandler('Respawn', function()
    local source = source
    if diedAt[source] - os.time() <= 0 then
        UpdateChar(source, 'dead', 0)
        TriggerClientEvent('Respawn', source)
        if exports['geo-es']:DutyCount('EMS') > 0 then
            TriggerClientEvent('Shared.Notif', source, 'The weight of this situation is especially taxing')
            RemoveLife(2000, GetCharacter(source))
        end
    else
        TriggerClientEvent('Shared.Notif', source, 'Too Soon...')
    end
end)

RegisterNetEvent('SkeletonChalice', function()
    local source = source
    if exports['geo-inventory']:HasItem('Player', source, 'skeletonchalice', 1) then
        exports['geo-inventory']:RemoveItem('Player', source, 'skeletonchalice', 1)
        UpdateChar(source, 'dead', 0)
    end
end)

function RemoveLife(amount, char)
    SQL('UPDATE status_life SET remaining = remaining - ? WHERE cid = ?', amount, char.id)
    local val = SQL('SELECT remaining FROM status_life WHERE cid = ?', char.id)[1].remaining

    if val == 99900 then
        TriggerClientEvent('Shared.Notif', char.serverid, [[
            The cold feeling of death washes over you, taking time to think over it you realize that you should
            be careful. Your actions will have consequences.
        ]], 15000)
    elseif val == 95000 then
        TriggerClientEvent('Shared.Notif', char.serverid, [[
            Your heart feels strong, but not as strong as it once did.
        ]], 15000)
    elseif val == 90000 then
        TriggerClientEvent('Shared.Notif', char.serverid, [[
            The damage to your body is starting to feel significant, be careful.
        ]], 15000)
    end
end