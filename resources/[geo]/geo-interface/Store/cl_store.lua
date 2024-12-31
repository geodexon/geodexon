AddEventHandler('StoreTrade', function(storeName)
    SendNUIMessage({
        interface = 'Store',
        data = Stores[storeName],
        Store = storeName,
        inv = exports['geo-inventory']:Module().Items
    })
    UIFocus(true, true)
end)

RegisterNUICallback('Store.Buy', function(data, cb)
    Task.Run('Store.Buy', data.Store, data.Item, data.Amount)
    cb(true)
end)