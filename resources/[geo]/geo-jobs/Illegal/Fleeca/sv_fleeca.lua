local bankCheck = {
}

for k,v in pairs(banks) do
    bankCheck[k] = true
end

Task.Register('FleecaFlag', function(source, id)
    if bankCheck[id] == true
        and RateLimit('Fleeca'..id, 3600000, true)
        and exports['geo-es']:DutyCount('Police') > 0 
        then

        TriggerEvent('Dispatch', {
            code = '10-43',
            title = 'Flagged Keycard Used',
            location = banks[id].vaultPos,
    
            time =  os.date('%H:%M EST'),
            info = {
                {
                    icon = 'location',
                    text = banks[id].name,
                    location = true
                },
            }
        })
    end
end)

Task.Register('Fleeca.CheckBank', function(source, id)
    if bankCheck[id] == true
        and RateLimit('Fleeca'..id, 3600000, true)
        and exports['geo-es']:DutyCount('Police') > 0 
        and exports['geo-inventory']:RemoveItem('Player', source, 'keycard_red', 1) then

        bankCheck[id] = source
        RateLimit('Fleeca'..id, 3600000)

        TriggerEvent('Dispatch', {
            code = '10-90',
            title = 'Robbery',
            location = banks[id].vaultPos,
    
            time =  os.date('%H:%M EST'),
            info = {
                {
                    icon = 'location',
                    text = banks[id].name,
                    location = true
                },
            }
        })

        TriggerClientEvent('Shared.Notif', source, 'Wait for the door to open', 5000)
        Wait(30000)

        TriggerClientEvent('Fleeca.Robbery', -1, id)
        banks[id].robtime = os.time()

        return true
    else
        TriggerClientEvent('Shared.Notif', source, 'This Bank is not available')
    end
end)

Task.Register('Fleeca.Close', function(source, id)
    local char = GetCharacter(source)
    if char and exports['geo-es']:IsPolice(char.id) then
        TriggerClientEvent('Fleeca.Stop', -1,  id)
        bankCheck[id] = true
    end
end)

Task.Register('Fleeca.Done', function(source)
    for k,v in pairs(bankCheck) do
        if v == source then
            bankCheck[k] = true
            local amount = Random(5000, 7500)
            if not exports['geo-inventory']:ReceiveItem('Player', source, 'dollar', amount) then
                local id = exports['geo-inventory']:CreateDrop(banks[k].stealPos)
                exports['geo-inventory']:AddItem('Drops', id, 'dollar', amount)
            end
            break
        end
    end
end)

Task.Register('BankHasBeenRobbed', function(source, pos)
    for k,v in pairs(banks) do
        if Vdist3(pos, v.vaultPos) <= 20.0 then
            return os.time() - (v.robtime or 0) < 300
        end
    end
end)

Task.Register('Fleeca.UnlockVault', function(source)
    local pos = GetEntityCoords(GetPlayerPed(source))
    for k,v in pairs(banks) do
        if Vdist3(pos, v.vaultPos) <= 20.0 then
            TriggerEvent('UnlockFleecaVault', k)
        end
    end
end)