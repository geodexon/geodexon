RegisterNetEvent('Doors:Toggle')
AddEventHandler('Doors:Toggle', function(index, bool)
    if Locks[index] then
        Locks[index].Locked = (bool or not Locks[index].Locked)
        TriggerClientEvent('Doors:Toggle', -1, index, Locks[index].Locked)
    end
end)

RegisterNetEvent('Doors.Get')
AddEventHandler('Doors.Get', function()
    local source = source
    local tbl = {}
    for k,v in pairs(Locks) do
        table.insert(tbl, v.Locked)
    end

    TriggerClientEvent('Doors.Get', source, tbl)
end)

AddEventHandler('UnlockFleecaVault', function(id)
    for k,v in pairs(Locks) do
        if v.BankID == id then
            Locks[k].Locked = false
            TriggerClientEvent('Doors:Toggle', -1, k, Locks[k].Locked)
            Citizen.SetTimeout(360000, function()
                Locks[k].Locked = true
                TriggerClientEvent('Doors:Toggle', -1, k, Locks[k].Locked)
            end)
            break
        end
    end
end)

AddEventHandler('UnlockVangelico', function()
    for k,v in pairs(Locks) do
        if v.Group == 5 then
            Locks[k].Locked = false
            TriggerClientEvent('Doors:Toggle', -1, k, Locks[k].Locked)
        end
    end
end)