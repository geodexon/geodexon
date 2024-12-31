Task.Register('GetPawnItems', function(source)
    local inv = exports['geo-inventory']:GetInventory('Player', source)
    local priceList = {}

    for k,v in pairs(inv) do
        local data = exports['geo-inventory']:GetItem(v.Key)
        if data.Value then
            table.insert(priceList, {data.Name, data.Value, v.Amount, v.Key})
        end
    end

    return priceList
end)

RegisterNetEvent('PawnShop:Sell', function(key, amount)
    local source = source
    amount = math.floor(math.abs(amount))
    local itemData = exports['geo-inventory']:GetItem(key)
    if itemData.Value then
        if exports['geo-inventory']:CanFit('Player', source, 'dollar', itemData.Value * amount) then
            if exports['geo-inventory']:RemoveItem('Player', source, key, amount) then
                exports['geo-inventory']:ReceiveItem('Player', source, 'dollar', amount * itemData.Value) 
            end
        end
    end
end)