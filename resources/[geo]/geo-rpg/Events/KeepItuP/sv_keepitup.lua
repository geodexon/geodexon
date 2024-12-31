RegisterNetEvent('KeepItUp', function()
    local source = source
    if RateLimit('KeepItUp'..source, 5000) then
        local time = os.time()
        local char = GetCharacter(source)
        if char.data.keepitup == nil or (char.data.keepitup ~= nil and time - char.data.keepitup.lasttime > 172800) then
            local rewards = char.data.keepitup ~= nil and char.data.keepitup.rewards or {}
            char.data.keepitup = {time = time - 3601, rewards = rewards, lasttime = time}
            SetData(source, 'keepitup', char.data.keepitup)
        end

        if time - char.data.keepitup.lasttime > 3600 then
            char.data.keepitup.lasttime = time
            SetData(source, 'keepitup', char.data.keepitup)
        end

        local calc = math.ceil( (time - char.data.keepitup.time) / 86400)
        TriggerClientEvent('Shared.Notif', source, "You've kept your streak for "..calc..' day(s)', 5000)
        if calc >= 1 and char.data.keepitup.rewards[1] == nil then
            Wait(1500)
            if exports['geo-inventory']:AddItem('Player', source, 'dollar', 250) then
                TriggerClientEvent('Shared.Notif', source, "Hey, that's pretty good", 5000)
                char.data.keepitup.rewards[1] = true
                SetData(source, 'keepitup', char.data.keepitup)
            else
                TriggerClientEvent('Shared.Notif', source, "Your pockets are too full", 5000)
            end
        elseif calc >= 5 and char.data.keepitup.rewards[2] == nil then
            Wait(1500)
            if exports['geo-inventory']:AddItem('Player', source, 'lockpick', 10) then
                TriggerClientEvent('Shared.Notif', source, "Hey, you're getting better", 5000)
                char.data.keepitup.rewards[2] = true
                SetData(source, 'keepitup', char.data.keepitup)
            else
                TriggerClientEvent('Shared.Notif', source, "Your pockets are too full", 5000)
            end
        elseif calc >= 8 and char.data.keepitup.rewards[3] == nil then
            Wait(1500)
            if exports['geo-inventory']:AddItem('Player', source, 'ammo_9mm', 500) then
                TriggerClientEvent('Shared.Notif', source, "Keep on going, Keep on going", 5000)
                char.data.keepitup.rewards[3] = true
                SetData(source, 'keepitup', char.data.keepitup)
            else
                TriggerClientEvent('Shared.Notif', source, "Your pockets are too full", 5000)
            end
        elseif calc >= 10 and char.data.keepitup.rewards[4] == nil then
            Wait(1500)
            if exports['geo-inventory']:AddItem('Player', source, 'radio', 3) then
                TriggerClientEvent('Shared.Notif', source, "Keep on going, Keep on going", 5000)
                char.data.keepitup.rewards[4] = true
                SetData(source, 'keepitup', char.data.keepitup)
            else
                TriggerClientEvent('Shared.Notif', source, "Your pockets are too full", 5000)
            end
        elseif calc >= 15 and char.data.keepitup.rewards[5] == nil then
            TriggerClientEvent('KeepItUp', source)
            char.data.keepitup.rewards[5] = true
            SetData(source, 'keepitup', char.data.keepitup)
        end
    end
end)

RegisterNetEvent('Event.Trade', function(id)
    local source = source
    local char = GetCharacter(source)

    for k,v in pairs(EventTrades[id][2]) do
        if exports['geo-inventory']:AmountKey('Player', source, v[1]) < v[2] then
            TriggerClientEvent('Shared.Notif', source, "You don't have enough "..exports['geo-inventory']:GetItemName(v[1]))
            return
        end
    end

    local item = exports['geo-inventory']:InstanceItem(EventTrades[id][1])

    if id == 1 then
        item.Data.firstname = char.first
        item.Data.lastname = char.last
        item.Data.reason = 'Halloween 2023'
    elseif id == 5 then
        item.Data.firstname = char.first
        item.Data.lastname = char.last
        item.Data.reason = 'Thanksgiving 2023'
    end

    if exports['geo-inventory']:CanFit('Player', source, EventTrades[id][1], 1) then
        for k,v in pairs(EventTrades[id][2]) do
            exports['geo-inventory']:RemoveItem('Player', source, v[1], v[2])
        end
        exports['geo-inventory']:ReceiveItem('Player', source, EventTrades[id][1], 1, item)
    end
end)