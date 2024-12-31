local registerPrices = {}
local jobInfo = {}

Task.Register('Pearls.Storage', function(source)
    if exports['geo-guilds']:GuildAuthority('PERL', GetCharacter(source).id) < 100 then return end
    exports['geo-inventory']:OpenInventory(source, 'Locations', 'Pearls')
end)

Task.Register('Pearls.Safe', function(source)
    if exports['geo-guilds']:GuildAuthority('PERL', GetCharacter(source).id) < 100 then return end
    exports['geo-inventory']:OpenInventory(source, 'Locations', 'PearlsSafe')
end)

Task.Register('Pearls.Drinks', function(source)
    if exports['geo-guilds']:GuildAuthority('PERL', GetCharacter(source).id) < 100 then return end
    exports['geo-inventory']:OpenInventory(source, 'Locations', 'PearlsDrinks')
end)

Task.Register('Pearls.FetchList', function(source, list)
    if exports['geo-guilds']:GuildAuthority('PERL', GetCharacter(source).id) < 100 then return end
    local inv = exports['geo-inventory']:GetInventory('Locations', "Pearls")
    if inv == nil then
        exports['geo-inventory']:FetchInventory('Locations', "Pearls", true)
    end

    local menu = {}
    for k,v in pairs(Pearls[list]) do
        for key,val in pairs(v.items) do
            if exports['geo-inventory']:AmountKey('Locations', "Pearls", val[1]) < val[2] then
                menu[k] = true
                break
            end
        end
    end

    return menu
end)

Task.Register('Pearls.Craft', function(source, station, itemID)
    if exports['geo-guilds']:GuildAuthority('PERL', GetCharacter(source).id) < 100 then return end
    for k,v in pairs(Pearls[station][itemID].items) do
        if exports['geo-inventory']:AmountKey('Locations', 'Pearls', v[1]) < v[2] then
            TriggerClientEvent('Shared.Notif', source, 'Missing Items')
            return false
        end
    end

    for k,v in pairs(Pearls[station][itemID].items) do
        exports['geo-inventory']:RemoveItem('Locations', 'Pearls', v[1], v[2])
    end

    exports['geo-inventory']:ReceiveItem('Player', source, Pearls[station][itemID].product, 1)
end)

Task.Register('Pearls.Register', function(source, registerID, val)
    if exports['geo-guilds']:GuildAuthority('PERL', GetCharacter(source).id) < 100 then return end
    if not tonumber(val) then 
        TriggerClientEvent('Pearls.RegisterReset', -1, registerID)
        return false
    end

    val = math.floor(math.abs(tonumber(val)))
    TriggerClientEvent('Pearls.RegisterInit', -1, registerID, val)
    registerPrices[registerID] = {val, GetCharacter(source).id}
end)

Task.Register('Pearls.RegisterPay', function(source, registerID)
    if registerPrices[registerID] then

        if GetCharacter(source).id == registerPrices[registerID][2] then
            TriggerClientEvent('Shared.Notif', source, 'You cant charge yourself, jackass.')
            return
        end

        if exports['geo-eco']:DebitDefault(GetCharacter(source), registerPrices[registerID][1], "Pearl's Seafood") then
            local inv = exports['geo-inventory']:GetInventory('Locations', "PearlsSafe")
            if inv == nil then
                exports['geo-inventory']:FetchInventory('Locations', "PearlsSafe", true)
            end
            exports['geo-inventory']:AddItem('Locations', 'PearlsSafe', 'dollar', registerPrices[registerID][1])

            TriggerClientEvent('Pearls.RegisterReset', -1, registerID)
            local time = os.time()
            local calc = time - jobInfo[registerPrices[registerID][2]].lastTime
            if calc > 900 then calc = 900 end
            jobInfo[registerPrices[registerID][2]].pay += math.floor(calc * 0.55)
            jobInfo[registerPrices[registerID][2]].lastTime = time
            registerPrices[registerID] = nil
        end
    end
end)

Task.Register('Pearls.Cash', function(source)
    if exports['geo-guilds']:GuildAuthority('PERL', GetCharacter(source).id) < 100 then return end
    local inv = exports['geo-inventory']:GetInventory('Locations', "PearlsSafe")
    if inv == nil then
        exports['geo-inventory']:FetchInventory('Locations', "PearlsSafe", true)
    end
    return exports['geo-inventory']:AmountKey('Locations', "PearlsSafe", 'dollar')
end)

Task.Register('Pearls.OrderGoods', function(source, id, amount)
    if exports['geo-guilds']:GuildAuthority('PERL', GetCharacter(source).id) < 1000 then return end
    amount = math.floor(math.abs(tonumber(amount)))
    if not amount then return end

    local inv = exports['geo-inventory']:GetInventory('Locations', "PearlsSafe")
    if inv == nil then
        exports['geo-inventory']:FetchInventory('Locations', "PearlsSafe", true)
    end

    local inv2 = exports['geo-inventory']:GetInventory('Locations', "Pearls")
    if inv2 == nil then
        exports['geo-inventory']:FetchInventory('Locations', "Pearls", true)
    end


    if exports['geo-inventory']:CanFit('Locations', "PearlsSafe", Pearls['Supplies'][id][1], amount) then
        if exports['geo-inventory']:RemoveItem('Locations', "PearlsSafe", 'dollar', Pearls['Supplies'][id][2] * amount) then
            exports['geo-inventory']:AddItem('Locations', "Pearls", Pearls['Supplies'][id][1], amount)
            TriggerClientEvent('Shared.Notif', source, 'Supplies Ordered')
        else
            TriggerClientEvent('Shared.Notif', source, 'Not Enough Money')
        end
    else
        TriggerClientEvent('Shared.Notif', source, 'Storage is Full')
    end
end)

Task.Register('Pearls.Job', function(source)
    local char = GetCharacter(source)
    if exports['geo-guilds']:GuildAuthority('PERL', GetCharacter(source).id) < 100 then return end
    if jobInfo[char.id] == nil then
         jobInfo[char.id] = {
            clockedIn = false,
            lastTime = os.time(),
            pay = 0
         } 
    end

    return jobInfo[char.id]
end)

RegisterNetEvent('Pearls.Clock', function()
    local source = source
    local char = GetCharacter(source)
    if exports['geo-guilds']:GuildAuthority('PERL', char.id) < 100 then return end
    jobInfo[char.id].clockedIn = not jobInfo[char.id].clockedIn
end)

RegisterNetEvent('Pearls.Pay', function()
    local source = source
    local char = GetCharacter(source)
    if exports['geo-guilds']:GuildAuthority('PERL', char.id) < 100 then return end
    if exports['geo-inventory']:ReceiveItem('Player', source, 'dollar', jobInfo[char.id].pay) then
        jobInfo[char.id].pay = 0
    end
end)