CreateThread(function()
    Wait(100)
    local stores = SQL('SELECT * FROM stores')
    for k,v in pairs(stores) do
        if OwnedStores[v.storeType] == nil then
            OwnedStores[v.storeType] = {}
        end
        OwnedStores[v.storeType][v.storeIndex] = {v.propertyId, json.decode(v.data)}
        OwnedStores[v.storeType][v.storeIndex][3] = false
        if OwnedStores[v.storeType][v.storeIndex][2].safe then
            local pos = OwnedStores[v.storeType][v.storeIndex][2].safe.position
            exports['geo-inventory']:AddLocation(v.storeType..'.'..v.storeIndex, (OwnedStores[v.storeType][v.storeIndex][2].name or 'Store')..' Stock', vector3(pos.x, pos.y, pos.z), {})
        end

        if OwnedStores[v.storeType][v.storeIndex][2].cash then
            local pos = OwnedStores[v.storeType][v.storeIndex][2].cash.position
            exports['geo-inventory']:AddLocation(v.storeType..'.'..v.storeIndex..'Bank', (OwnedStores[v.storeType][v.storeIndex][2].name or 'Store')..' Bank', vector3(pos.x, pos.y, pos.z), {})
        end
    end
    TriggerClientEvent('OwnedStore.Init', -1, OwnedStores)
end)

AddEventHandler('Login', function(char)
    TriggerClientEvent('OwnedStore.Init', char.serverid, OwnedStores)
end)

Task.Register('SetStoreProperty', function(source, storeID, propertyID, storeType)
    local char = GetCharacter(source)
    if not char.username then return end
    if storeID and propertyID and storeType then
        if OwnedStores[storeType][storeID] == nil then
            OwnedStores[storeType][storeID] = {propertyID, {}}
            OwnedStores[storeType][storeID][3] = false
            SQL('INSERT INTO stores (propertyId, storeType, storeIndex) VALUES (?, ?, ?)', propertyID, storeType, storeID)
        else
            OwnedStores[storeType][storeID][1] = propertyID
            SQL('UPDATE stores SET propertyId = ? WHERE storeType = ? and storeIndex = ?', propertyID, storeType, storeID)
        end

        TriggerClientEvent('OwnedStore.UpdateProperty', -1, storeType, storeID, OwnedStores[storeType][storeID])
    end
end)

Task.Register('OwnedStore.Safe', function(source, data, storeType, storeID)

    local propertyOwner = exports['geo-instance']:GetProperty(OwnedStores[storeType][storeID][1]).owner
    if propertyOwner ~= GetCharacter(source).id then
        return
    end

    OwnedStores[storeType][storeID][2].safe = {position = data.position, rotation = data.rotation}
    SQL('UPDATE stores SET data = ? WHERE storeType = ? and storeIndex = ?', json.encode(OwnedStores[storeType][storeID][2]), storeType, storeID)
    TriggerClientEvent('OwnedStore.UpdateProperty', -1, storeType, storeID, OwnedStores[storeType][storeID])
end)

Task.Register('OwnedStore.Cash', function(source, data, storeType, storeID)
    local propertyOwner = exports['geo-instance']:GetProperty(OwnedStores[storeType][storeID][1]).owner
    if propertyOwner ~= GetCharacter(source).id then
        return
    end

    OwnedStores[storeType][storeID][2].cash = {position = data.position, rotation = data.rotation}

    local pos = OwnedStores[storeType][storeID][2].cash.position
    exports['geo-inventory']:AddLocation(storeType..'.'..storeID..'Bank', (OwnedStores[storeType][storeID][2].name or 'Store')..' Bank', vector3(pos.x, pos.y, pos.z), {})

    SQL('UPDATE stores SET data = ? WHERE storeType = ? and storeIndex = ?', json.encode(OwnedStores[storeType][storeID][2]), storeType, storeID)
    TriggerClientEvent('OwnedStore.UpdateProperty', -1, storeType, storeID, OwnedStores[storeType][storeID])
end)

Task.Register('OwnedStore.Name', function(source, storeType, storeID, name)

    local propertyOwner = exports['geo-instance']:GetProperty(OwnedStores[storeType][storeID][1]).owner
    if propertyOwner ~= GetCharacter(source).id then
        return
    end

    OwnedStores[storeType][storeID][2].name = name
    SQL('UPDATE stores SET data = ? WHERE storeType = ? and storeIndex = ?', json.encode(OwnedStores[storeType][storeID][2]), storeType, storeID)
    
    if OwnedStores[storeType][storeID][2].safe then
        local pos = OwnedStores[storeType][storeID][2].safe.position
        exports['geo-inventory']:AddLocation(storeType..'.'..storeID, (OwnedStores[storeType][storeID][2].name or 'Store')..' Stock', vector3(pos.x, pos.y, pos.z), {})
    end

    if OwnedStores[storeType][storeID][2].cash then
        local pos = OwnedStores[storeType][storeID][2].cash.position
        exports['geo-inventory']:AddLocation(storeType..'.'..storeID..'Bank', (OwnedStores[storeType][storeID][2].name or 'Store')..' Bank', vector3(pos.x, pos.y, pos.z), {})
    end
    
    TriggerClientEvent('OwnedStore.UpdateProperty', -1, storeType, storeID, OwnedStores[storeType][storeID])
end)

Task.Register('OwnedStore.Stock', function(source, storeType, storeID)

    local propertyOwner = exports['geo-instance']:GetProperty(OwnedStores[storeType][storeID][1])
    if propertyOwner.owner ~= GetCharacter(source).id then
        return
    end

    exports['geo-inventory']:OpenInventory(source, 'Locations', storeType..'.'..storeID)
end)

Task.Register('OwnedStore.Bank', function(source, storeType, storeID)
    exports['geo-inventory']:OpenInventory(source, 'Locations', storeType..'.'..storeID..'Bank')
end)

Task.Register('FetchStoreInv', function(source, iid)
    if not Inventories['Locations'][iid] then
        FetchInventory('Locations', iid)
    end
    return Inventories['Locations'][iid]
end)

AddEventHandler('OwnedStore.Purchase', function(source, store, slot, amount, target)
    local item = New(Inventories['Locations'][store][tostring(slot)])
    if Inventory.CanFit('Player', source, item.Key, amount, target) then
        local str = SplitString(store, '.')
        amount = math.abs(amount)
        local prices = OwnedStores[str[1]][tonumber(str[2])][2].prices
        local price = 999999
        if prices[item.ID] then
            price = prices[item.ID][1]
        end

        local totalPrice = math.floor(price * amount)

        if Inventory.Amount('Locations', store, item.ID) < amount then
            Update('Player', tostring(source))
            return 
        end

        FetchInventory('Locations', store..'Bank')
        if exports['geo-eco']:DebitDefault(GetCharacter(source), totalPrice, amount..' '..GetItemName(item.Key)..'(s)') then
            if Inventory.RemoveItem('Locations', store, item.ID, amount) then
                Inventory.AddItem('Player', source, item.Key, amount, item, target)
                Inventory.AddItem('Locations', store..'Bank', 'dollar', totalPrice)
            end
        end
    else
        TriggerClientEvent('Shared.Notif', source, 'You are carrying too much')
    end

    Update('Player', tostring(source))
end)

Task.Register('OwnedStore.SetPrice', function(source, storeType, storeID, item, val, key)
    local propertyOwner = exports['geo-instance']:GetProperty(OwnedStores[storeType][storeID][1]).owner
    if propertyOwner ~= GetCharacter(source).id then
        return
    end

    local store = OwnedStores[storeType][storeID][2]
    if store.prices == nil then store.prices = {} end

    store.prices[item] = {math.abs(math.floor(val)), key}
    OwnedStores[storeType][storeID][2].prices = store.prices
    SQL('UPDATE stores SET data = ? WHERE storeType = ? and storeIndex = ?', json.encode(OwnedStores[storeType][storeID][2]), storeType, storeID)
    if OwnedStores[storeType][storeID][2].safe then
        local pos = OwnedStores[storeType][storeID][2].safe.position
        exports['geo-inventory']:AddLocation(storeType..'.'..storeID, (OwnedStores[storeType][storeID][2].name or 'Store')..' Stock', vector3(pos.x, pos.y, pos.z), {})
    end

    if OwnedStores[storeType][storeID][2].cash then
        local pos = OwnedStores[storeType][storeID][2].cash.position
        exports['geo-inventory']:AddLocation(storeType..'.'..storeID..'Bank', (OwnedStores[storeType][storeID][2].name or 'Store')..' Bank', vector3(pos.x, pos.y, pos.z), {})
    end
    
    TriggerClientEvent('OwnedStore.UpdateProperty', -1, storeType, storeID, OwnedStores[storeType][storeID])
end)

Task.Register('OwnedStore.RemovePrice', function(source, storeType, storeID, item)
    
    local propertyOwner = exports['geo-instance']:GetProperty(OwnedStores[storeType][storeID][1]).owner
    if propertyOwner ~= GetCharacter(source).id then
        return
    end

    local store = OwnedStores[storeType][storeID][2]
    if store.prices == nil then store.prices = {} end

    store.prices[item] = nil
    OwnedStores[storeType][storeID][2].prices = store.prices
    SQL('UPDATE stores SET data = ? WHERE storeType = ? and storeIndex = ?', json.encode(OwnedStores[storeType][storeID][2]), storeType, storeID)
    if OwnedStores[storeType][storeID][2].safe then
        local pos = OwnedStores[storeType][storeID][2].safe.position
        exports['geo-inventory']:AddLocation(storeType..'.'..storeID, (OwnedStores[storeType][storeID][2].name or 'Store')..' Stock', vector3(pos.x, pos.y, pos.z), {})
    end

    if OwnedStores[storeType][storeID][2].cash then
        local pos = OwnedStores[storeType][storeID][2].cash.position
        exports['geo-inventory']:AddLocation(storeType..'.'..storeID..'Bank', (OwnedStores[storeType][storeID][2].name or 'Store')..' Bank', vector3(pos.x, pos.y, pos.z), {})
    end
    
    TriggerClientEvent('OwnedStore.UpdateProperty', -1, storeType, storeID, OwnedStores[storeType][storeID])
end)

Task.Register('OwnedStore.Toggle', function(source, storeType, storeID)
    local propertyOwner = exports['geo-instance']:GetProperty(OwnedStores[storeType][storeID][1]).owner
    if propertyOwner ~= GetCharacter(source).id then
        return
    end

    OwnedStores[storeType][storeID][3] = not OwnedStores[storeType][storeID][3]
    TriggerClientEvent('OwnedStore.UpdateProperty', -1, storeType, storeID, OwnedStores[storeType][storeID])
end)
