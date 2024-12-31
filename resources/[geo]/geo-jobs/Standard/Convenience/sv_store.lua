local stores = {}
for i=1,21 do
    stores[i] = false
end

GlobalState.Convenience = json.encode(stores)

Task.Register('Convenience.SetJob', function(source, bool, storeID)
    local char = GetCharacter(source)
    if bool then
        if char and stores[storeID] == false then

            for k,v in pairs(stores) do
                if v == char.id then
                    TriggerClientEvent('Shared.Notif', source, 'You already have a job at one of our locations', 5000)
                    return
                end
            end

            stores[storeID] = char.id
            GlobalState.Convenience = json.encode(stores)
            UpdateChar(source, 'job', 'Convenience')
            TriggerEvent('JobCache', char.id)
            TriggerClientEvent('Shared.Notif', source, 'Clocked in at 24/7', 5000)
            return true
        end
    else
        if stores[storeID] == char.id then
            TriggerClientEvent('Shared.Notif', source, 'Clocked out at 24/7', 5000)
            stores[storeID] = false
            GlobalState.Convenience = json.encode(stores)
            UpdateChar(source, 'job', nil)
            TriggerEvent('JobCache', char.id)
        end
    end
end)

RegisterNetEvent('Convenience.Ping')
AddEventHandler('Convenience.Ping', function(storeID)
    local source = source
    if stores[storeID] ~= false then
        if RateLimit('Convenience.Ping'..storeID, 60000) then
            TriggerClientEvent('Shared.Notif', source, 'The cashier has been notified and shoould be there soon', 5000)
            TriggerClientEvent('Shared.Notif', GetCharacterByID(stores[storeID]).serverid, 'Someone is requesting you at the register', 5000)
        else
            TriggerClientEvent('Shared.Notif', source, 'The bell has went off too recently', 5000)
        end
    else
        TriggerClientEvent('Shared.Notif', source, "There's not attendent working, shop on your own", 5000)
    end
end)

RegisterNetEvent('Convenience.OpenRegister')
AddEventHandler('Convenience.OpenRegister', function(storeID)
    local source = source
    local char = GetCharacter(source)
    if char and stores[storeID] == char.id then
        exports['geo-inventory']:OpenInventory(source, 'Register', tostring(storeID))
    end
end)

AddEventHandler('Logout', function(char)
    for k,v in pairs(stores) do
        if v == char.id then
            stores[k] = false
            GlobalState.Convenience = json.encode(stores)
            break
        end
    end
end)