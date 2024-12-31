Task.Register('Store.Buy', function(source, store, item, amount)
    amount = math.floor(math.abs(tonumber(amount)))
    item = tonumber(item)
    if store and item and amount then
        local thiStore = Stores[store][item]
        if exports['geo-inventory']:CanFit('Player', source, thiStore[1], amount * (thiStore[4] or 1)) then
            if exports['geo-inventory']:RemoveItem('Player', source, thiStore[2][1], thiStore[2][2] * amount) then
                exports['geo-inventory']:AddItem('Player', source, thiStore[1], amount * (thiStore[4] or 1))
            else
                TriggerClientEvent('Shared.Notif', source, "Not Enough Materials")
            end
        else
            TriggerClientEvent('Shared.Notif', source, "Not Enough Room")
        end
    end
end)