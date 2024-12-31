charIDs = {}
Inventory = {}
Drops = {}
Cache = {}
openInv = {}

local classes = {}

Citizen.CreateThread(function()
    Wait(1000)
    exports.ghmattimysql:execute('DELETE FROM inventories WHERE TYPE = "Vehicle" and inventoryid NOT IN (SELECT plate FROM vehicles)')
    exports.ghmattimysql:execute('DELETE FROM inventories WHERE TYPE = "Glovebox" and inventoryid not IN (SELECT  CONCAT("Glovebox-" , vehicles.plate) FROM vehicles)')
    exports.ghmattimysql:execute('DELETE FROM inventories WHERE TYPE = "Drops" or TYPE = "Dumpster"')
end)

RegisterNetEvent('Inventory:FetchMe')
AddEventHandler('Inventory:FetchMe', function()
    local source = source
    local char = GetCharacter(source)
    if char then
        charIDs[tostring(source)] = char.id 
        FetchInventory('Player', source)
    end
end)

function FetchMe(source)
    local char = GetCharacter(source)
    if char then
        charIDs[tostring(source)] = char.id 
        FetchInventory('Player', source)
    end
end

exports('FetchMe', FetchMe)

RegisterNetEvent('Inventory:Fetch')
AddEventHandler('Inventory:Fetch', function(inventoryType, inventoryID)
    FetchInventory(inventoryType, inventoryID)
end)

RegisterNetEvent('CreateDrop')
AddEventHandler('CreateDrop', function(inventoryID, pos)
    local source = source
    local char = GetCharacter(source)
    Drops[inventoryID] = {pos, char.interior}
    TriggerClientEvent('Inventory:Drops', -1, Drops)
end)

exports('CreateDrop', function(pos)
    local id = uuid()

    for k,v in pairs(Drops) do
        if Vdist3(pos, v[1]) <= 5.0 then
            return k
        end
    end

    Drops[id] = {pos}
    FetchInventory('Drops', id)
    TriggerClientEvent('Inventory:Drops', -1, Drops)
    return id
end)

RegisterNetEvent('Inventory:TransferItem')
AddEventHandler('Inventory:TransferItem', function(invFrom, invTo, slot)
    local source = source
    if not openInv[source] then
        Fail(invFrom.type, tostring(invFrom.id))
        Fail(invTo.type, tostring(invTo.id))
        return
    end

    local allowed = false
    for k,v in pairs(openInv[source]) do
        if (v[1] == invFrom.type and v[2] == invFrom.id) or (v[1] == invTo.type and v[2] == invTo.id) then
            allowed = true
            break
        end
    end

    if invTo.type == 'Credit' then
        Fail(invFrom.type, tostring(invFrom.id))
        Fail(invTo.type, tostring(invTo.id))
        return
    end

    if invFrom.type == 'Player' and tostring(invFrom.id) == tostring(source) then
        if not (invTo.type == 'Player' and tostring(invTo.id) == tostring(source)) then
            if not allowed then
                Fail(invFrom.type, tostring(invFrom.id))
                Fail(invTo.type, tostring(invTo.id))
                return
            end
        end
    else
        if not allowed then
            Fail(invFrom.type, tostring(invFrom.id))
            Fail(invTo.type, tostring(invTo.id))
            return
        end

        if not (invTo.type == 'Player' and tostring(invTo.id) == tostring(source)) then
            if not allowed then
                Fail(invFrom.type, tostring(invFrom.id))
                Fail(invTo.type, tostring(invTo.id))
                return
            end
        end
    end

    if invFrom.type == 'Player' and tostring(invTo.id) == tostring(source) then
        if tostring(source) ~= tostring(invFrom.id) and items[Inventories[invFrom.type][tostring(invFrom.id)][tostring(invFrom.itemID)].Key].Soulbound then
            Fail(invFrom.type, tostring(invFrom.id))
            Fail(invTo.type, tostring(invTo.id))
            return
        end
    end


    Inventory.TransferItem(invFrom, invTo, source, slot)
end)

local times = {}
RegisterNetEvent('Inventory:Transfer2')
AddEventHandler('Inventory:Transfer2', function(inventoryType, inventoryID, to, target, amount)
    local source = source
    local char = GetCharacter(source)
    amount = math.abs(math.floor(tonumber(amount)))

    local time = GetGameTimer()
    if times[source] == nil then
        times[source] = time - 1000
    end

    if inventoryType == 'Credit' then
        Fail(inventoryType, inventoryID)
        Fail('Player', tostring(source))
        return
    end

    if time - times[source] < 0 then
        print('stop spamming')
        Fail(inventoryType, inventoryID)
        Fail('Player', tostring(source))
        return
    end

    times[source] = time + 100
    if not openInv[source] then
        Fail(inventoryType, inventoryID)
        Fail('Player', tostring(source))
        return
    end


    if openInv[source][1] ~= inventoryType or openInv[source][2] ~= inventoryID then
        Fail(inventoryType, inventoryID)
        Fail('Player', tostring(source))
        return
    end

   --[[  FetchInventory('Player', source)
    FetchInventory(inventoryType, inventoryID) ]]

    if to == 'Other' then
        if Inventories[inventoryType][inventoryID][tostring(target)] ~= nil then
            local item = New(Inventories[inventoryType][inventoryID][tostring(target)])
            if Inventory.CanFit('Player', source, item.Key, amount) then

                if inventoryType == 'Player' and items[Inventories[inventoryType][inventoryID][tostring(target)].Key].Soulbound then
                    Fail(inventoryType, inventoryID)
                    Fail('Player', tostring(source))
                    return
                end

                if Inventory.RemoveItem(inventoryType, inventoryID, item.ID, amount, target) then
                    Inventory.AddItem('Player', source, item.Key, amount, item)
                    Log('[Inventory]', {cid = char.id, user = char.user, Item = {item.ID, amount}, TargetInventory = {'Player', source}, StartInventory = {inventoryType, inventoryID}})
                end
            else
                Fail(inventoryType, inventoryID)
                Fail('Player', tostring(source))
                return
            end
        end
    elseif to == 'Player' then
        if Inventories['Player'][tostring(source)][tostring(target)] ~= nil then
            local item = New(Inventories['Player'][tostring(source)][tostring(target)])
            if Inventory.CanFit(inventoryType, inventoryID, item.Key, amount) then
                if Inventory.RemoveItem('Player', source, item.ID, amount, target) then
                    Inventory.AddItem(inventoryType, inventoryID, item.Key, amount, item)
                    Log('[Inventory]', {cid = char.id, user = char.user, Item = {item.ID, amount}, StartInventory = {'Player', source}, TargetInventory = {inventoryType, inventoryID}})
                end
            else
                Fail(inventoryType, inventoryID)
                Fail('Player', tostring(source))
                return
            end
        end
    end
end)

RegisterNetEvent('LoadAmmo')
AddEventHandler('LoadAmmo', function(itemID, ammo, max, toRemove, currWep)
    local source = source
    if Inventory.RemoveItem('Player', source, itemID, toRemove) then
        for k,v in pairs(Inventories['Player'][tostring(source)]) do
            if currWep == v.ID then
                v.Data.CurrentAmmo = ammo + toRemove
                Inventory.SQL('Update', 'Player', source, k)
                TriggerClientEvent('Reload', source, v.Data.CurrentAmmo)
                Refresh('Player', tostring(source))
                Update('Player', tostring(source), nil, nil, nil, k)
                break
            end
        end
    end
end)

RegisterNetEvent('Unload')
AddEventHandler('Unload', function(wep)
    local source = source
    for k,v in pairs(Inventories['Player'][tostring(source)]) do
        if v.ID == wep then
            local ammo = v.Data.CurrentAmmo

            if ammo == 0 then
                return
            end

            if Inventory.AddItem('Player', source, v.Data.Ammo, ammo) then
                Inventories['Player'][tostring(source)][k].Data.CurrentAmmo = 0
                Inventory.SQL('Update', 'Player', source, k)
                TriggerClientEvent('Reload', source, 0)
                Refresh('Player', tostring(source))
                Update('Player', tostring(source), nil, nil, nil, k)
                break
            end
        end
    end
end)

RegisterNetEvent('UpdateAmmo')
AddEventHandler('UpdateAmmo', function(ammo, id)
    local source = source
    for k,v in pairs(Inventories['Player'][tostring(source)]) do
        if id == v.ID then
            Inventories['Player'][tostring(source)][k].Data.CurrentAmmo = ammo

            if items[v.Key].Deteriorate then
                Inventories['Player'][tostring(source)][k].Data.Durability = (Inventories['Player'][tostring(source)][k].Data.Durability or 100) -items[v.Key].Deteriorate
            end

            Inventory.SQL('Update', 'Player', source, k)
            break
        end
    end
end)

local bypass = {['Drops'] = true, ['Vehicle'] = true, ['Glovebox'] = true, ['StoreUI'] = true,}
RegisterNetEvent('Inventory:Open')
AddEventHandler('Inventory:Open', function(inventoryType, inventoryID)
    local source = source
    if bypass[inventoryType] then
        if not openInv[source] then openInv[source] = {} end
        table.insert(openInv[source], {inventoryType, inventoryID})
    end
end)

RegisterNetEvent('Inventory:CanOpen')
AddEventHandler('Inventory:CanOpen', function(_res, promID, inventoryType, inventoryID)
    local source = source
    if bypass[inventoryType] then
        TriggerClientEvent('ReturnPromise', source, _res, promID, true)
        return
    else
        local allowed = false
        for k,v in pairs(openInv[source]) do
            if v[1] == inventoryType and v[2] == inventoryID then
                allowed = true
                break
            end
        end

        if openInv[source] then
            if allowed then
                TriggerClientEvent('ReturnPromise', source, _res, promID, true)
                return
            end
        end
    end
    TriggerClientEvent('ReturnPromise', source, _res, promID, false)
end)

AddEventHandler('Login', function(char)
    Inventories['Player'][tostring(char.serverid)] = nil
    charIDs[tostring(char.serverid)] = char.id
    FetchInventory('Player', char.serverid)
    TriggerClientEvent('Inventory.Login', char.serverid)
end)

CreateThread(function()
    Wait(1000)
    for k,v in pairs(GetPlayers()) do
        v = tonumber(v)
        local char = GetCharacter(v)
        if char then
            Inventories['Player'][tostring(char.serverid)] = nil
            charIDs[tostring(char.serverid)] = char.id
            FetchInventory('Player', char.serverid)
            TriggerClientEvent('Inventory.Login', char.serverid)
        end
    end
end)

function FetchInventory(inventoryType, inventoryID, ignore)
    inventoryID = tostring(inventoryID)
    --if Inventories[inventoryType][inventoryID] == nil then
        local val = Inventory.SQL('Fetch', inventoryType, inventoryID)
        if val then
            Inventories[inventoryType][inventoryID] = val

            local time = os.time()
            for k,v in pairs(Inventories[inventoryType][inventoryID]) do
                if items[v.Key].Decay and Inventories[inventoryType][inventoryID][k].Data.Life == nil then
                    Inventories[inventoryType][inventoryID][k].Data.Life = {}
                    for i=1,v.Amount do
                        table.insert(Inventories[inventoryType][inventoryID][k].Data.Life, time)
                    end
                    Inventory.SQL('Update', inventoryType, inventoryID, tostring(k))
                end

                if items[v.Key].Decay and items[v.Key].DecayRemove then
                    for i=v.Amount,1 do
                        if math.abs(Inventories[inventoryType][inventoryID][k].Data.Life[i] - time) > items[v.Key].Decay then
                            table.remove(Inventories[inventoryType][inventoryID][k].Data.Life, i)
                            Inventories[inventoryType][inventoryID][k].Amount = Inventories[inventoryType][inventoryID][k].Amount - 1
                            if Inventories[inventoryType][inventoryID][k].Amount == 0 then Inventories[inventoryType][inventoryID][k] = nil end
                            Inventory.SQL('Update', inventoryType, inventoryID, tostring(k))
                        end
                    end
                end
            end

            for k,v in pairs(Inventories[inventoryType][inventoryID]) do
                if items[v.Key] == nil then
                    Inventories[inventoryType][inventoryID][k] = nil
                    Console('[Inventory]', ('Invalid Item %s removed from %s %s'):format(v.Key, inventoryType, inventoryID))
                end
            end
        else
            Inventories[inventoryType][inventoryID] = {}
        end
        --Console('[Inventory]', ('Loaded %s: %s'):format(inventoryType, inventoryID))
    --end

    if not ignore then
        Update(inventoryType, inventoryID)
    end
end

function Update(inventoryType, inventoryID, key, amount, bool, slot)
    local p = 0
    if inventoryType == 'Player' then
        p = tonumber(inventoryID)
        if not slot then
            TriggerClientEvent('Inventory:Update', p, inventoryType, inventoryID, Inventories[inventoryType][inventoryID])
        else
            TriggerClientEvent('Inventory:UpdateSlot', p, inventoryType, inventoryID, slot, Inventories[inventoryType][inventoryID][tostring(slot)])
        end
        --TriggerClientEvent('Inventory:Drops', p, Drops)
    end


    if inventoryType == 'Drops' or inventoryType == 'Locations' then
        if not slot then
            TriggerClientEvent('Inventory:Update', -1, inventoryType, inventoryID, Inventories[inventoryType][inventoryID])
        else
            TriggerClientEvent('Inventory:UpdateSlot', -1, inventoryType, inventoryID, slot, Inventories[inventoryType][inventoryID][tostring(slot)])
        end
        --return
    end

    for k,v in pairs(openInv) do
        for key, val in pairs(v) do
            if inventoryType ~= 'Drops' and val[1] == inventoryType and val[2] == inventoryID then
                if k ~= p then
                    if not slot then
                        TriggerClientEvent('Inventory:Update', k, inventoryType, inventoryID, Inventories[inventoryType][inventoryID])
                    else
                        TriggerClientEvent('Inventory:UpdateSlot', k, inventoryType, inventoryID, slot, Inventories[inventoryType][inventoryID][tostring(slot)])
                    end
                end
            end
        end
    end

    if not hidden[inventoryType][inventoryID] then
        if inventoryType == 'Player' then
            if key then
                if not bool then
                    TriggerClientEvent('Inventory:Notif', tonumber(inventoryID), key, amount)
                end
            end
        end
    end
end

function Fail(inventoryType, inventoryID)

    local p = 0
    if inventoryType == 'Player' then
        p = tonumber(inventoryID)
        TriggerClientEvent('Inventory:Fail', p)
    end

    for k,v in pairs(openInv) do
        for key,val in pairs(v) do
            if val[1] == inventoryType and val[2] == inventoryID then
                if k ~= p then
                    TriggerClientEvent('Inventory:Fail', k)
                end
            end
        end
    end
end

function Refresh(inventoryType, inventoryID)
    Inventories[inventoryType][tostring(inventoryID)] = New(Inventories[inventoryType][tostring(inventoryID)])
end

function Inventory.AddItem(inventoryType, inventoryID, itemID, amount, itemData, slot, noUpdate)
    inventoryID = tostring(inventoryID)
    if Inventories[inventoryType][inventoryID] == nil then
        Fail(inventoryType, inventoryID)
        return false
    end

    if items[itemID] == nil then
        Fail(inventoryType, inventoryID)
        Console('[Inventory]', 'Invalid Item: '..itemID)
        return false
    end

    amount = math.floor(amount)
    amount = math.abs(amount)
    local toAdd = amount

    Refresh(inventoryType, inventoryID)

    if not Inventory.CanFit(inventoryType, inventoryID, itemID, amount, slot) then
        Fail(inventoryType, inventoryID)
        return
    end

    local lifeVal
    if itemData == nil then
        itemData = InstanceItem(itemID)
        itemData.Amount = amount

        if items[itemID].Decay then
            lifeVal = {}
            local time = os.time()
            itemData.Data.Life = {}
            for i=1,amount do
                table.insert(lifeVal, time)
            end
        end
    else
        itemData = New(itemData)
        if itemData.Data.Equipped ~= inventoryID then
            itemData.Data.Equipped = nil
        end
        itemData.Amount = amount
        if itemData.Data.Life then
            lifeVal = New(itemData.Data.Life)
            itemData.Data.Life = {}
        end
    end

    if items[itemData.Key].Stackable == false then
        itemData.Amount = 1
        amount = 1
    end

    fakeSlots = GetFakeSlots(Inventories[inventoryType][inventoryID])
    
    if not slot then
        for i=1,Slots[inventoryType] do
            i = tostring(i)
            if Inventories[inventoryType][inventoryID][i] and (Inventories[inventoryType][inventoryID][i].ID == itemData.ID) and Inventories[inventoryType][inventoryID][i].Amount < GetMax(itemID) then
                local i = tostring(i)
                if toAdd == 0 then
                    break
                end

                itemData = New(itemData)
                local math = GetMax(itemID) - Inventories[inventoryType][inventoryID][i].Amount
                local add = math > toAdd and toAdd or math
                if math >= toAdd then
                    Inventories[inventoryType][inventoryID][i].Amount = Inventories[inventoryType][inventoryID][i].Amount + add 
                    toAdd = toAdd - add

                    if lifeVal then
                        lifeVal = AddLife(inventoryType, inventoryID, add, i, lifeVal)
                    end

                    Inventory.SQL('Update', inventoryType, inventoryID, i)
                    if not noUpdate then
                        Update(inventoryType, inventoryID, items[itemID].Key, add, nil, i)
                    end
                else
                    Inventories[inventoryType][inventoryID][i].Amount = Inventories[inventoryType][inventoryID][i].Amount + add
                    toAdd = toAdd - add

                    if lifeVal then
                        lifeVal = AddLife(inventoryType, inventoryID, add, i, lifeVal)
                    end

                    Inventory.SQL('Update', inventoryType, inventoryID, i)
                    if not noUpdate then
                        Update(inventoryType, inventoryID, items[itemID].Key, add, nil, i)
                    end
                end
            end
        end

        for i=1,Slots[inventoryType] do
            if toAdd == 0 then
                break
            end

            i = tostring(i)
            itemData = New(itemData)

            local breakout = false
            if items[itemID].size then
                for heightIndex = 1, items[itemID].size[2] do
                    for pIndex = 1, items[itemID].size[1] do
                        if not (pIndex == 1 and heightIndex == 1) then
                            local num = (heightIndex * 8) + pIndex - 8 - 1
                            if tonumber(i) + num > Slots[inventoryType] then return end
                            if Inventories[inventoryType][inventoryID][tostring(tonumber(i) + num)] ~= nil then
                                breakout = true
                                break
                            end

                            if 9 - (tonumber(i) % 8) < items[itemID].size[1] or (tonumber(i) % 8) == 0 then
                                breakout = true
                                break
                            end

                            if fakeSlots[tostring(tonumber(i) + num)] then 
                                breakout = true
                                break
                            end
                        end
                    end

                    if breakout then break end
                end
            end

            if breakout then goto fin end
            if Inventories[inventoryType][inventoryID][i] == nil then
                if not fakeSlots[i] then
                    local val = toAdd > GetMax(itemID) and GetMax(itemID) or toAdd
                    itemData.Amount = val
                    Inventories[inventoryType][inventoryID][i] = itemData
                    toAdd = toAdd - val

                    if lifeVal then
                        lifeVal = AddLife(inventoryType, inventoryID, val, i, lifeVal)
                    end

                    Inventory.SQL('Update', inventoryType, inventoryID, i)
                    if not noUpdate then
                        Update(inventoryType, inventoryID, items[itemID].Key, val, nil, i)
                    end
                end
            else
                if Inventories[inventoryType][inventoryID][i].ID == itemData.ID and Inventories[inventoryType][inventoryID][i].Amount < GetMax(itemID) then
                    local math = GetMax(itemID) - Inventories[inventoryType][inventoryID][i].Amount
                    if math >= toAdd then
                        Inventories[inventoryType][inventoryID][i].Amount = Inventories[inventoryType][inventoryID][i].Amount + toAdd
                        
                        if lifeVal then
                            lifeVal = AddLife(inventoryType, inventoryID, toAdd, i, lifeVal)
                        end
                        
                        if not noUpdate then
                            Update(inventoryType, inventoryID, items[itemID].Key, toAdd, nil, i)
                        end
                        toAdd = 0
                    else
                        Inventories[inventoryType][inventoryID][i].Amount = Inventories[inventoryType][inventoryID][i].Amount + math
                        
                        if lifeVal then
                            lifeVal = AddLife(inventoryType, inventoryID, math, i, lifeVal)
                        end

                        if not noUpdate then
                            Update(inventoryType, inventoryID, items[itemID].Key, math, nil, i)
                        end
                        toAdd = toAdd - math
                    end
                    Inventory.SQL('Update', inventoryType, inventoryID, i)
                end
            end

            ::fin::
        end
    else
        slot = tostring(slot)
        local i = slot
        itemData = New(itemData)
        if Inventories[inventoryType][inventoryID][slot] == nil and not fakeSlots[slot] then
            local val = toAdd > GetMax(itemID) and GetMax(itemID) or toAdd
            itemData.Amount = val
            Inventories[inventoryType][inventoryID][slot] = itemData
            toAdd = toAdd - val

            if lifeVal then
                lifeVal = AddLife(inventoryType, inventoryID, val, i, lifeVal)
            end

            Inventory.SQL('Update', inventoryType, inventoryID, slot)
            if not noUpdate then
                Update(inventoryType, inventoryID, items[itemID].Key, amount, nil, slot)
            end
        else
            if Inventories[inventoryType][inventoryID][slot].ID == itemData.ID then
                local math = GetMax(itemID) - Inventories[inventoryType][inventoryID][i].Amount
                if math >= toAdd then
                    Inventories[inventoryType][inventoryID][i].Amount = Inventories[inventoryType][inventoryID][i].Amount + toAdd
                    
                    if lifeVal then
                        lifeVal = AddLife(inventoryType, inventoryID, toAdd, i, lifeVal)
                    end

                    toAdd = 0
                else
                    Inventories[inventoryType][inventoryID][i].Amount = Inventories[inventoryType][inventoryID][i].Amount + math
                    
                    if lifeVal then
                        lifeVal = AddLife(inventoryType, inventoryID, math, i, lifeVal)
                    end
                    
                    toAdd = toAdd - math
                end
                Inventory.SQL('Update', inventoryType, inventoryID, slot)
                if not noUpdate then
                    Update(inventoryType, inventoryID, items[itemID].Key, amount, nil, slot)
                end
            end
        end
    end

    if toAdd <= 0 then
        completed = true
    end

    if completed then

        if inventoryType == 'Player' then
            TriggerClientEvent('Log', tonumber(inventoryID), 'Item Added '..amount..'x '..items[itemID].Name)
        end

        Log('[Inventory]', {Item = {itemID, amount}, type = 'Add', Inventory = {inventoryType, inventoryID}})
        return true
    end

    Fail(inventoryType, inventoryID)
    return false
end

function Inventory.RemoveItem(inventoryType, inventoryID, itemID, amount, slot, noUpdate)
    inventoryID = tostring(inventoryID)
    if Inventories[inventoryType][inventoryID] == nil then
        Fail(inventoryType, inventoryID)
        return false
    end
    local key
    local slotID
    local durab = false

    Refresh(inventoryType, inventoryID)

    local found = false
    local completed = false
    local startAmount = amount

    if slot == nil then

        local cAmmount = Inventory.Amount(inventoryType, inventoryID, itemID)
        if cAmmount < amount then
            Fail(inventoryType, inventoryID)
            return false
        end

        for i = 1, Slots[inventoryType] do
            Refresh(inventoryType, inventoryID)
            local k = tostring(i)
            local v = Inventories[inventoryType][inventoryID][k]
            if v then
                if v.ID == itemID then
                    key = v.Key
                    local removed = 0
                    if Inventories[inventoryType][inventoryID][k].Amount - amount < 0 then
                        removed = Inventories[inventoryType][inventoryID][k].Amount
                        Inventories[inventoryType][inventoryID][k] = nil
                        Inventory.SQL('Update', inventoryType, inventoryID, k)
                        if not noUpdate then
                            Update(inventoryType, inventoryID, key, -removed, false, k)
                        end
                    else 
                        if (Inventories[inventoryType][inventoryID][k].Data.Durability or 100) <= 0 then
                            Inventories[inventoryType][inventoryID][k] = nil
                            if not noUpdate then
                                Update(inventoryType, inventoryID, key, -amount, false, k)
                            end
                            Inventory.SQL('Update', inventoryType, inventoryID, k)
                        else
                            if amount > Inventories[inventoryType][inventoryID][k].Amount then
                                removed = Inventories[inventoryType][inventoryID][k].Amount
                            else
                                removed = amount
                            end

                            Inventories[inventoryType][inventoryID][k].Amount = Inventories[inventoryType][inventoryID][k].Amount - removed
                            
                            if Inventories[inventoryType][inventoryID][k].Data.Life then
                                local count = 0
                                local total = #Inventories[inventoryType][inventoryID][k].Data.Life
                                for index = 1, removed do
                                    if Inventories[inventoryType][inventoryID][k].Data.Life[total - count] then
                                        table.remove(Inventories[inventoryType][inventoryID][k].Data.Life, total - count)
                                    end
                                    count = count + 1
                                end
                            end

                            if Inventories[inventoryType][inventoryID][k].Amount == 0 then
                                Inventories[inventoryType][inventoryID][k] = nil
                                Inventory.SQL('Update', inventoryType, inventoryID, k)
                            end
                            if not noUpdate then
                                Update(inventoryType, inventoryID, key, -amount, false, k)
                            end
                            Refresh(inventoryType, inventoryID)
                        end
                    end

                    amount = tonumber(amount - removed)
                end
            end

            if amount == 0 then
                completed = true
                slotID = k
                break
            end

            completed = true
        end
    else
        Refresh(inventoryType, inventoryID)
        if Inventories[inventoryType][inventoryID][tostring(slot)] then
            local k = tostring(slot)
            key = Inventories[inventoryType][inventoryID][k].Key
            if Inventories[inventoryType][inventoryID][k].ID == itemID then
                if not (Inventories[inventoryType][inventoryID][k].Amount - amount < 0) then
                    if (Inventories[inventoryType][inventoryID][k].Data.Durability or 100) <= 0 then
                        durab = true
                    end
                    Inventories[inventoryType][inventoryID][k].Amount = Inventories[inventoryType][inventoryID][k].Amount - amount
                    
                    if Inventories[inventoryType][inventoryID][k].Data.Life then
                        local count = 0
                        local total = #Inventories[inventoryType][inventoryID][k].Data.Life
                        for index = 1, amount do
                            if Inventories[inventoryType][inventoryID][k].Data.Life[total - count] then
                                table.remove(Inventories[inventoryType][inventoryID][k].Data.Life, total - count)
                            end
                            count = count + 1
                        end
                    end

                    if Inventories[inventoryType][inventoryID][k].Amount == 0 then
                        Inventories[inventoryType][inventoryID][k] = nil
                    end
                    completed = true
                    slotID = k
                    if not noUpdate then
                        Update(inventoryType, inventoryID, key, -startAmount, durab, slot)
                    end
                end
            end
        end
        Refresh(inventoryType, inventoryID)
    end

    if completed then
        Inventory.SQL('Update', inventoryType, inventoryID, slotID)
        Log('[Inventory]', {Item = {itemID, amount}, type = 'Remove', Inventory = {inventoryType, inventoryID}})
        return true
    end

    Fail(inventoryType, inventoryID)
    return false
end

function Inventory.RemoveItemKey(inventoryType, inventoryID, itemID, amount, slot)
    inventoryID = tostring(inventoryID)
    if Inventories[inventoryType][inventoryID] == nil then
        Fail(inventoryType, inventoryID)
        return false
    end
    local key
    local slotID
    local durab = false

    Refresh(inventoryType, inventoryID)

    local found = false
    local completed = false
    local startAmount = amount

    if slot == nil then

        local cAmmount = Inventory.AmountKey(inventoryType, inventoryID, itemID)
        if cAmmount < amount then
            Fail(inventoryType, inventoryID)
            return false
        end

        for i = 1, Slots[inventoryType] do
            Refresh(inventoryType, inventoryID)
            local k = tostring(i)
            local v = Inventories[inventoryType][inventoryID][k]
            if v then
                if v.Key == itemID then
                    key = v.Key
                    local removed = 0
                    if Inventories[inventoryType][inventoryID][k].Amount - amount < 0 then
                        removed = Inventories[inventoryType][inventoryID][k].Amount
                        Inventories[inventoryType][inventoryID][k] = nil
                        Inventory.SQL('Update', inventoryType, inventoryID, k)
                        Update(inventoryType, inventoryID, key, -amount, false, k)
                    else 
                        if (Inventories[inventoryType][inventoryID][k].Data.Durability or 100) <= 0 then
                            Inventories[inventoryType][inventoryID][k] = nil
                            Update(inventoryType, inventoryID, key, -amount, false, k)
                            Inventory.SQL('Update', inventoryType, inventoryID, k)
                        else
                            if amount > Inventories[inventoryType][inventoryID][k].Amount then
                                removed = Inventories[inventoryType][inventoryID][k].Amount
                            else
                                removed = amount
                            end

                            Inventories[inventoryType][inventoryID][k].Amount = Inventories[inventoryType][inventoryID][k].Amount - removed
                            if Inventories[inventoryType][inventoryID][k].Amount == 0 then
                                Inventories[inventoryType][inventoryID][k] = nil
                                Inventory.SQL('Update', inventoryType, inventoryID, k)
                            end
                            Update(inventoryType, inventoryID, key, -amount, false, k)
                            Refresh(inventoryType, inventoryID)
                        end
                    end

                    amount = tonumber(amount - removed)
                end
            end

            if amount == 0 then
                completed = true
                slotID = k
                break
            end

            completed = true
        end
    else
        Refresh(inventoryType, inventoryID)
        if Inventories[inventoryType][inventoryID][tostring(slot)] then
            local k = tostring(slot)
            key = Inventories[inventoryType][inventoryID][k].Key
            if Inventories[inventoryType][inventoryID][k].Key == itemID then
                if not (Inventories[inventoryType][inventoryID][k].Amount - amount < 0) then
                    if (Inventories[inventoryType][inventoryID][k].Data.Durability or 100) <= 0 then
                        durab = true
                    end
                    Inventories[inventoryType][inventoryID][k].Amount = Inventories[inventoryType][inventoryID][k].Amount - amount
                    if Inventories[inventoryType][inventoryID][k].Amount == 0 then
                        Inventories[inventoryType][inventoryID][k] = nil
                    end
                    completed = true
                    slotID = k
                    Update(inventoryType, inventoryID, key, -startAmount, durab, slot)
                end
            end
        end
        Refresh(inventoryType, inventoryID)
    end

    if completed then
        Inventory.SQL('Update', inventoryType, inventoryID, slotID)
        Log('[Inventory]', {Item = {itemID, amount}, type = 'Remove', Inventory = {inventoryType, inventoryID}})
        return true
    end

    Fail(inventoryType, inventoryID)
    return false
end

function Inventory.Amount(inventoryType, inventoryID, itemID)
    inventoryID = tostring(inventoryID)
    if Inventories[inventoryType][inventoryID] == nil then
        return 0
    end

    local amount = 0
    for k,v in pairs(Inventories[inventoryType][inventoryID]) do
        if v.ID == itemID then
            amount = amount + v.Amount
        end
    end

    return amount
end

function Inventory.AmountKey(inventoryType, inventoryID, itemID)
    inventoryID = tostring(inventoryID)
    if Inventories[inventoryType][inventoryID] == nil then
        return 0
    end

    local amount = 0
    for k,v in pairs(Inventories[inventoryType][inventoryID]) do
        if v.Key == itemID then
            amount = amount + v.Amount
        end
    end

    return amount
end

function Inventory.SQL(type, inventoryType, inventoryID, slot)
    local returner
    inventoryID = tostring(inventoryID)
    local updateID = inventoryID

    if inventoryType == 'Vehicle' then
        local veh = NetworkGetEntityFromNetworkId(tonumber(inventoryID))
        local ent = Entity(veh)

        local str = ent.state.plate
        if str == nil then
            str = 'throwaway-'..veh
        end

        updateID = str
    elseif inventoryType == 'Glovebox' then
        local veh = NetworkGetEntityFromNetworkId(tonumber(inventoryID))
        local ent = Entity(veh)
        
        local str = ent.state.plate
        if str == nil then
            str = 'throwaway-'..veh
        end

        updateID = str
    end

    if type == 'Fetch' then
        if inventoryType == 'Player' then
            returner = exports.ghmattimysql:executeSync('SELECT content, slot FROM inventories where type = @Type and charid = @ID', {Type = inventoryType, ID = charIDs[inventoryID]})
        else
            returner = exports.ghmattimysql:executeSync('SELECT content, slot FROM inventories where type = @Type and stringid = @ID', {Type = inventoryType, ID = updateID})
        end

        local val = {}
        for k,v in pairs(returner) do
            val[tostring(v.slot)] = json.decode(v.content)
        end

        if returner then
            return val
        end

    elseif type == 'Update' then
        local value = Inventories[inventoryType][inventoryID][tostring(slot)]
        if value then
            if inventoryType == 'Player' then
                exports.ghmattimysql:execute('DELETE FROM inventories WHERE type = @Type and charid = @ID and slot = @Slot', {Type = inventoryType, ID = charIDs[inventoryID], Slot = tonumber(slot)}, function()
                    exports.ghmattimysql:execute('INSERT INTO inventories (inventoryid, type, content, charid, slot) VALUES (@ID, @Type, @Content, @ID, @Slot)', {Content = json.encode(Inventories[inventoryType][inventoryID][tostring(slot)]), Type = inventoryType, ID = charIDs[inventoryID], Slot = tonumber(slot)})
                end)
            else
                exports.ghmattimysql:execute('DELETE FROM inventories WHERE type = @Type and stringid = @ID and slot = @Slot', {Type = inventoryType, ID = updateID, Slot = tonumber(slot)}, function()
                    exports.ghmattimysql:execute('INSERT INTO inventories (inventoryid, type, content, stringid, slot) VALUES (@ID, @Type, @Content, @ID, @Slot)', {Content = json.encode(Inventories[inventoryType][inventoryID][tostring(slot)]), Type = inventoryType, ID = updateID, Slot = tonumber(slot)})
                end)
            end
        else
            if inventoryType == 'Player' then
                exports.ghmattimysql:execute('DELETE FROM inventories WHERE type = @Type and charid = @ID and slot = @Slot', {Type = inventoryType, ID = charIDs[inventoryID], Slot = tonumber(slot)})
            else
                exports.ghmattimysql:execute('DELETE FROM inventories WHERE type = @Type and stringid = @ID and slot = @Slot', {Type = inventoryType, ID = updateID, Slot = tonumber(slot)})
            end
        end
    end
end

function mysplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function GetItemName(itemID)
    if items[itemID] == nil then
        return 'NULL'
    end

    return items[itemID].Name
end


function InstanceItem(itemID)
    local newItem = New(items[itemID])
    local cache = {}
    cache.Key = newItem.Key
    cache.Data = newItem.Data
    if items[itemID].Stackable and items[itemID].ID ~= nil then
        cache.ID = newItem.ID
    else
        if items[itemID].Weapon then
            cache.Data.UniqueID = uuid()
        end
        cache.ID = itemID..'.'..uuidshort()
    end

    cache.Amount = newItem.Amount
    return cache
end

function Inventory.TransferItem(invFrom, invTo, source, slot)
    invFrom.id = tostring(invFrom.id)
    invTo.id = tostring(invTo.id)
    slot = tostring(slot)
    invFrom.type = tostring(invFrom.type)
    invTo.type = tostring(invTo.type)
    invFrom.amount = math.floor(invFrom.amount)
    invFrom.amount = math.abs(invFrom.amount)
    local found = false

    if invFrom.amount <= 0 then
        Fail( invTo.type, invTo.id)
        return
    end

    if invFrom.item == nil then
        Fail( invTo.type, invTo.id)
        return
    end

    if Inventories[invFrom.type][invFrom.id] == nil then
        return
    end

    if Inventories[invTo.type][invTo.id] == nil then
        return
    end

    for k,v in pairs(Inventories[invFrom.type][invFrom.id]) do
        if k == invFrom.itemID then
            invFrom.item = New(v)
            break
        end
    end

    Refresh(invFrom.type, invFrom.id)
    Refresh(invTo.type, invTo.id)

    if Inventories[invFrom.type][invFrom.id][tostring(invFrom.itemID)] == nil then
        Fail( invFrom.type, invFrom.id)
        return
    end

    local startItem
    if Inventories[invFrom.type][invFrom.id][tostring(invFrom.itemID)].ID == invFrom.item.ID then
        startItem = New(Inventories[invFrom.type][invFrom.id][tostring(invFrom.itemID)])
    else
        Fail( invFrom.type, invFrom.id)
        return
    end
    local char = GetCharacter(source)

    if (invFrom.id == invTo.id) and (invFrom.type == invTo.type) then
        hidden[invFrom.type][invFrom.id] = true
        if Inventories[invFrom.type][invFrom.id][slot] == nil then
            for k,v in pairs(Inventories[invFrom.type][invFrom.id]) do
                if k == tostring(invFrom.itemID) then
                    local this = New(v)

                    if invFrom.amount > Inventories[invFrom.type][invFrom.id][k].Amount then
                        Fail( invFrom.type, invFrom.id)
                        hidden[invFrom.type][invFrom.id] = nil
                        return
                    end

                    if invFrom.amount == Inventories[invFrom.type][invFrom.id][k].Amount then
                        if Inventory.RemoveItem(invFrom.type, invFrom.id, this.ID, this.Amount, k, true) then
                            Inventory.AddItem(invFrom.type, invFrom.id, this.Key, this.Amount, this, slot, true)
                        end
                    else
                        if Inventory.RemoveItem(invFrom.type, invFrom.id, this.ID, invFrom.amount, k, true) then
                            this.Amount = invFrom.amount
                            Inventory.AddItem(invFrom.type, invFrom.id, this.Key, this.Amount, this, slot, true)
                        end
                    end
                    Log('[Inventory]', {cid = char.id, user = char.user, Item = {this.ID, this.Amount}, StartInventory = {invFrom.type, invFrom.id}, TargetInventory = {invTo.type, invTo.id}})
                end
            end
        else
            local start
            local target = New(Inventories[invFrom.type][invFrom.id][slot])
            local index = invFrom.itemID
            local index = invFrom.itemID
            local start = startItem

            if start and target then
                index = tostring(invFrom.itemID)
                _n = index

                if start.ID == target.ID and target.Amount + invFrom.amount > GetMax(start.Key) and target.Amount ~= GetMax(target.Key) then
                    local calc = GetMax(start.Key) - target.Amount
                    if Inventory.RemoveItem(invFrom.type, invFrom.id, start.ID, calc, invFrom.itemID, true) then
                        Inventory.AddItem(invTo.type, invTo.id, start.Key, calc, start, slot, true)
                        hidden[invFrom.type][invFrom.id] = nil
                        Update(invFrom.type, invFrom.id)
                        Update(invTo.type, invTo.id)
                        return
                    end
                end

                if target.ID ~= start.ID or (target.ID == start.ID and target.Amount + invFrom.amount > GetMax(start.Key)) then

                    if Inventory.RemoveItem(invFrom.type, invFrom.id, start.ID, start.Amount, index, true) then
                        if Inventory.RemoveItem(invFrom.type, invFrom.id, target.ID, target.Amount, slot, true) then
                            Inventory.AddItem(invFrom.type, invFrom.id, start.Key, start.Amount, start, slot, true)
                            Inventory.AddItem(invFrom.type, invFrom.id, target.Key, target.Amount, target, index, true)
                        end
                    end

                    Log('[Inventory]', {cid = char.id, user = char.user, Item = {start.ID, start.Amount}, StartInventory = {invFrom.type, invFrom.id}, TargetInventory = {invTo.type, invTo.id}})
                    Log('[Inventory]', {cid = char.id, user = char.user, Item = {target.ID, target.Amount}, StartInventory = {invFrom.type, invFrom.id}, TargetInventory = {invTo.type, invTo.id}})
                else
                    if Inventory.RemoveItem(invFrom.type, invFrom.id, invFrom.item.ID, invFrom.amount, invFrom.itemID, true) then
                        Inventory.AddItem(invTo.type, invTo.id, invFrom.item.Key, invFrom.amount, invFrom.item, slot, true)
                        Log('[Inventory]', {cid = char.id, user = char.user, Item = {invFrom.item.ID, invFrom.item.Amount}, StartInventory = {invFrom.type, invFrom.id}, TargetInventory = {invTo.type, invTo.id}})
                    end
                end
            end
        end
        hidden[invFrom.type][invFrom.id] = nil
    else
        if Inventories[invTo.type][invTo.id][slot] == nil then
            if Inventory.CanFit(invTo.type, invTo.id, invFrom.item.Key, invFrom.amount, slot) then
                if Inventory.RemoveItem(invFrom.type, invFrom.id, invFrom.item.ID, invFrom.amount, invFrom.itemID, true) then
                    Inventory.AddItem(invTo.type, invTo.id, invFrom.item.Key, invFrom.amount, invFrom.item, slot, true)
                    Log('[Inventory]', {cid = char.id, user = char.user, Item = {invFrom.item.ID, invFrom.amount}, StartInventory = {invFrom.type, invFrom.id}, TargetInventory = {invTo.type, invTo.id}})
                end
            else
                Fail(invFrom.type, invFrom.id)
                return
            end
        else
            local start = startItem
            local index = tostring(invFrom.itemID)

            local target = New(Inventories[invTo.type][invTo.id][slot])

            if start.ID == target.ID and target.Amount + invFrom.amount > GetMax(start.Key) and target.Amount ~= GetMax(target.Key) then
                local calc = GetMax(start.Key) - target.Amount
                if Inventory.RemoveItem(invFrom.type, invFrom.id, start.ID, calc, invFrom.itemID, true) then
                    Inventory.AddItem(invTo.type, invTo.id, start.Key, calc, start, slot, true)
                    Update(invFrom.type, invFrom.id)
                    Update(invTo.type, invTo.id)
                    return
                end
            end

            local weight = GetWeight(invTo.type, invTo.id)
            weight = weight - ((items[target.Key].Weight or 0) * target.Amount)

            local weight2 = GetWeight(invFrom.type, invFrom.id)
            weight2 = weight2 - ((items[start.Key].Weight or 0) * start.Amount)

            local maxWeight = GetMaxWeight(invTo.type, invTo.id)
            local maxWeight2 = GetMaxWeight(invFrom.type, invFrom.id)
            if (weight + ((items[start.Key].Weight or 0) * start.Amount) <= maxWeight) and (weight2 + ((items[target.Key].Weight or 0) * target.Amount) <= maxWeight2) then
                if start.ID ~= target.ID or (target.ID == start.ID and target.Amount + invFrom.amount > GetMax(start.Key)) then
                    if Inventory.RemoveItem(invFrom.type, invFrom.id, start.ID, start.Amount, invFrom.itemID, true) then
                        Inventory.RemoveItem(invTo.type, invTo.id, target.ID, target.Amount, slot, true)
                        Inventory.AddItem(invFrom.type, invFrom.id, target.Key, target.Amount, target, tostring(index), true)
                        Inventory.AddItem(invTo.type, invTo.id, start.Key, start.Amount, start, slot, true)
                        Log('[Inventory]', {cid = char.id, user = char.user, Item = {start.ID, invFrom.amount}, StartInventory = {invFrom.type, invFrom.id}, TargetInventory = {invTo.type, invTo.id}})
                        Log('[Inventory]', {cid = char.id, user = char.user, Item = {target.ID, invFrom.amount}, StartInventory = {invFrom.type, invFrom.id}, TargetInventory = {invTo.type, invTo.id}})
                    end
                else
                    for k,v in pairs(Inventories[invFrom.type][invFrom.id]) do
                        if v.ID == invFrom.item.ID then
                            invFrom.item = New(v)
                        end
                    end

                    if Inventory.CanFit(invTo.type, invTo.id, invFrom.item.Key, invFrom.amount, slot) then
                        if Inventory.RemoveItem(invFrom.type, invFrom.id, invFrom.item.ID, invFrom.amount, invFrom.itemID, true) then
                            Inventory.AddItem(invTo.type, invTo.id, invFrom.item.Key, invFrom.amount, invFrom.item, slot, true)
                            Log('[Inventory]', {cid = char.id, user = char.user, Item = {invFrom.item.ID, invFrom.amount}, StartInventory = {invFrom.type, invFrom.id}, TargetInventory = {invTo.type, invTo.id}})
                        end
                    else
                        Fail(invFrom.type, invFrom.id)
                        return
                    end
                end
            else
                Fail(invFrom.type, invFrom.id)
                return
            end
        end
    end

    Update(invFrom.type, invFrom.id, nil, nil, nil, invFrom.itemID)
    Update(invTo.type, invTo.id, nil, nil, nil, slot)
end

function Inventory.Contains(inventoryType, inventoryID, itemID)
    inventoryID = tostring(inventoryID)
    if Inventories[inventoryType][inventoryID] == nil then
        return 0
    end

    for k,v in pairs(Inventories[inventoryType][inventoryID]) do
        if v.ID == itemID then
            return v.Amount
        end
    end

    return 0
end

function Inventory.CanFit(inventoryType, inventoryID, itemID, amount, slot)
    inventoryID = tostring(inventoryID)
    if Inventories[inventoryType][inventoryID] == nil then
        return false
    end

    amount = math.floor(amount)
    amount = math.abs(amount)
    slot = slot and tostring(slot)
    local toAdd = amount

    if items[itemID] == nil then
        return false
    end

    local weight = GetWeight(inventoryType, inventoryID)
    local maxWeight = GetMaxWeight(inventoryType, inventoryID)
    if weight + ((items[itemID].Weight or 0) * amount) > maxWeight then
        if inventoryType == "Player" then TriggerClientEvent('Shared.Notif', tonumber(inventoryID), 'You are carrying too much', 5000) end
        return false
    end

    local fakeSlots = GetFakeSlots(Inventories[inventoryType][inventoryID])

    if not slot then
        for i=1,Slots[inventoryType] do
            i = tostring((i))
            local breakout = false
            if items[itemID].size then
                for heightIndex = 1, items[itemID].size[2] do
                    for pIndex = 1, items[itemID].size[1] do
                        if not (pIndex == 1 and heightIndex == 1) then
                            local num = (heightIndex * 8) + pIndex - 8 - 1
                            if tonumber(i) + num > Slots[inventoryType] then return end

                            if Inventories[inventoryType][inventoryID][tostring(tonumber(i) + num)] ~= nil then
                                breakout = true
                                break
                            end

                            if 9 - (tonumber(i) % 8) < items[itemID].size[1] or (tonumber(i) % 8) == 0 then
                                breakout = true
                                break
                            end

                            if fakeSlots[tostring(tonumber(i) + num)] then 
                                breakout = true
                                break
                            end
                        end
                    end

                    if breakout then break end
                end
            end

            if breakout then goto fin end

            if Inventories[inventoryType][inventoryID][i] == nil then
                if not fakeSlots[i] then
                    if toAdd <= GetMax(itemID) then
                        return true
                    else
                        toAdd = toAdd - GetMax(itemID)
                    end
                end
            else
                if Inventories[inventoryType][inventoryID][i].ID == itemID then
                    local math = GetMax(itemID) - Inventories[inventoryType][inventoryID][i].Amount
                    if math >= toAdd then
                        toAdd = 0
                    else
                        toAdd = toAdd - math
                    end
                end
            end

            ::fin::
        end
    else
        if Inventories[inventoryType][inventoryID][slot] == nil then
            if not fakeSlots[slot] then
                if toAdd <= GetMax(itemID) then
                    return true
                end
            end
        else
            if Inventories[inventoryType][inventoryID][slot].ID == itemID then
                local math = GetMax(itemID) - Inventories[inventoryType][inventoryID][slot].Amount
                if math >= toAdd then
                    toAdd = 0
                else
                    toAdd = toAdd - math
                end
            end
        end
    end

    return toAdd == 0
end

RegisterNetEvent('Inventory:Location')
AddEventHandler('Inventory:Location', function(loc)
    local source = source
    local pos = GetEntityCoords(GetPlayerPed(source))
    local char = GetCharacter(source)
    for k,v in pairs(inventoryLocations) do
        if Vdist4(pos, v.Pos) <= 50.0 then
            for key,val in pairs(v.Guilds) do
                if exports['geo-guilds']:GuildAuthority(val[1], char.id) > val[2] then
                    OpenInventory(source, 'Locations', k)
                end
            end
        end
    end
end)

RegisterNetEvent('RemoveItem')
AddEventHandler('RemoveItem', function(id, amount)
    local source = source
    Inventory.RemoveItem('Player', source, id, amount or 1)
end)

RegisterNetEvent('RemoveItemKey')
AddEventHandler('RemoveItemKey', function(id, amount)
    local source = source
    Inventory.RemoveItemKey('Player', source, id, amount or 1)
end)

function IsHQ(item)
    return item.ID:match('_hq')
end

exports('IsHQ', IsHQ)

function OpenInventory(source, inventoryType, inventoryID)
    inventoryID = tostring(inventoryID)
    if not openInv[source] then openInv[source] = {} end
    table.insert(openInv[source], {inventoryType, inventoryID})
    TriggerClientEvent('Inventory:Open', source, inventoryType, inventoryID)
end

function HasItem(inventoryType, inventoryID, id)
    inventoryID = tostring(inventoryID)
    for k,v in pairs(Inventories[inventoryType][inventoryID]) do
        if v.ID == id then
            return true
        end
    end
end

function HasItemKey(inventoryType, inventoryID, id)
    inventoryID = tostring(inventoryID)
    for k,v in pairs(Inventories[inventoryType][inventoryID]) do
        if v.Key == id then
            return true
        end
    end
end

function GetItemKey(inventoryType, inventoryID, id)
    inventoryID = tostring(inventoryID)
    for k,v in pairs(Inventories[inventoryType][inventoryID]) do
        if v.Key == id then
            return v
        end
    end
end


function RemoveDurability(inventoryType, inventoryID, itemID, amount)
    inventoryID = tostring(inventoryID)
    if Inventories[inventoryType][inventoryID] then
        for k,v in pairs(Inventories[inventoryType][inventoryID]) do
            if v.ID == itemID then
                v.Data.Durability = (v.Data.Durability or 100) - amount
                Inventory.SQL('Update', inventoryType, inventoryID, k)
                Update(inventoryType, inventoryID, nil, nil, nil, k)
                return v.Data.Durability >= 0
            end
        end
    end
end

function Repair(inventoryType, inventoryID, itemID, amount)
    inventoryID = tostring(inventoryID)
    if Inventories[inventoryType][inventoryID] then
        for k,v in pairs(Inventories[inventoryType][inventoryID]) do
            if v.ID == itemID then
                if v.Data.Durability then
                    v.Data.Durability = 100
                end
                if v.Data.Life then
                    v.Data.Life[v.Amount] = os.time()
                end
                if v.Data.Armor then
                    v.Data.Armor = New(items[v.Key]).Data.Armor
                end
                Inventory.SQL('Update', inventoryType, inventoryID, k)
                Update(inventoryType, inventoryID, nil, nil, nil, k)
            end
        end
    end
end

function Deteriorate(inventoryType, inventoryID, itemID)
    inventoryID = tostring(inventoryID)
    if Inventories[inventoryType][inventoryID] then
        for k,v in pairs(Inventories[inventoryType][inventoryID]) do
            if v.ID == itemID then
                v.Data.Durability = (v.Data.Durability or 100) - (items[v.Key].Deteriorate or 0)
                Inventory.SQL('Update', inventoryType, inventoryID, k)
                Update(inventoryType, inventoryID, nil, nil, nil, k)
                return v.Data.Durability >= 0
            end
        end
    end

    return 0
end

function GetMax(itemID)
    return items[itemID].max or 1000
end

function ReceiveItem(inventoryType, inventoryID,  itemID, amount, ...)
    amount = math.floor(math.abs(amount))
    if Inventory.AddItem(inventoryType, inventoryID, itemID, amount, ...) then
        Log('Reward', {cid = GetCharacter(inventoryID).id, item = itemID, amount = amount})
        TriggerEvent('ReceiveItem', tonumber(inventoryID), itemID, amount)
        return true
    end
end

function GetAvailableSlots(inventoryType, inventoryID)
    inventoryID = tostring(inventoryID)
    if not Inventories[inventoryType][inventoryID] then
        return
    end

    local count = 0
    for i=1,Slots[inventoryType] do
        if Inventories[inventoryType][inventoryID][tostring(i)] == nil then
            count = count + 1
        end
    end

   return count
end

function GetInventory(inventoryType, inventoryID)
    return Inventories[inventoryType][tostring(inventoryID)]
end

AddEventHandler('_Frisk', function(source, target)
    local lst = {}
    for k,v in pairs(Inventories['Player'][tostring(target)]) do
        if items[v.Key].Weapon then
            TriggerClientEvent('Shared.Notif', source, 'You feel a large bulge', 5000)
            break
        end
    end
end)

local pList = {}
RegisterNetEvent('PlaceProp')
AddEventHandler('PlaceProp', function(prop, x, y, z, heading)
    local source = source
    local char = GetCharacter(source)
    if char.interior then
        TriggerClientEvent('Shared.Notif', source, 'Props can not be placed in interiors')
        return
    end

    if items[prop.Key].Prop then
        if Inventory.RemoveItem('Player', source, items[prop.Key].Key, 1) then
            local obj = AddProp(items[prop.Key].Prop, vector3(x, y, z), heading)
            Entity(obj).state.Prop = prop.Key
        end
    end
end)

RegisterNetEvent('PickupProp')
AddEventHandler('PickupProp', function(prop)
    local source = source
    local obj = NetworkGetEntityFromNetworkId(prop)
    local ent = Entity(obj)
    if ent.state.Prop ~= nil then
        if DoesEntityExist(obj) then
            if Inventory.AddItem('Player', source, ent.state.Prop, 1) then
                DeleteEntity(obj)
            end
        end
    end
end)

AddEventHandler('Inventory.Jail', function(char)
    FetchInventory('Jail', tostring(char.id))
    for k,v in pairs(Inventories['Player'][tostring(char.serverid)]) do
        Inventory.RemoveItem('Player', tostring(char.serverid), v.ID, v.Amount, k, true)
        Inventory.AddItem('Jail', char.id, v.Key, v.Amount, v)
    end
    
    Update('Player', tostring(char.serverid))
end)

RegisterCommand('_seizeinternal', function(souce, args)
    TriggerClientEvent('Shared.Notif', GetCharacter(tonumber(args[1])).serverid, 'Your items have been seized')
    TriggerEvent('Inventory.Jail', GetCharacter(tonumber(args[1])))
end)

local reclaiming = {}
RegisterNetEvent('Jail.ReclaimGoods')
AddEventHandler('Jail.ReclaimGoods', function()
    local source = source
    local char = GetCharacter(source)
    FetchInventory('Jail', tostring(char.id))

    if reclaiming[source] then
        return
    end

    if char.jail == 1 then
        TriggerClientEvent('Shared.Notif', source, 'Come back when you are not in jail', 5000)
        return
    end

    reclaiming[source] = true
    local needed = 0
    for k,v in pairs(Inventories['Jail'][tostring(char.id)]) do
        needed = needed + 1
    end

    if GetAvailableSlots('Player', tostring(source)) >= needed then
        for k,v in pairs(Inventories['Jail'][tostring(char.id)]) do
            local item = New(v)

            if exports['geo-inventory']:CanFit('Player', source, item.Key, item.Amount) then
                if exports['geo-inventory']:RemoveItem('Jail', char.id, item.ID, item.Amount) then
                    exports['geo-inventory']:AddItem('Player', source, item.Key, item.Amount, item, nil, true)
                end
            end
        end
        Update('Player', tostring(char.serverid))
    else
        TriggerClientEvent('Shared.Notif', source, 'Your Inventory is too full', 5000)
    end
    reclaiming[source] = nil
end)

local usedMod = {}
RegisterNetEvent('WeaponMods.Toggle')
AddEventHandler('WeaponMods.Toggle', function(wep, mod)
    local source = source
    for k,v in pairs(Inventories['Player'][tostring(source)]) do
        if v.ID == wep and weaponMods[items[v.Key].Weapon] and weaponMods[items[v.Key].Weapon][mod] and (v.Data.Durability or 100) > 0 then
            local modList = weaponMods[items[v.Key].Weapon]
            if HasMod(modList[mod].Hash, (v.Data.Mods or {})) then

                if not modList[mod].NoConsume then
                    if Inventory.CanFit('Player', source, modList[mod].Item, 1) then
                        Inventory.AddItem('Player', source, modList[mod].Item, 1)
                        Refresh('Player', tostring(source))
                       
                        for key,val in pairs(v.Data.Mods) do
                            if val == modList[mod].Hash then
                                table.remove(v.Data.Mods, key)
                                break
                            end
                        end
    
                        Inventories['Player'][tostring(source)][k].Data.Mods = v.Data.Mods
                        Inventory.SQL('Update', 'Player', source, k)
                        Update('Player', tostring(source), nil, nil, nil, k)
                        TriggerClientEvent('Weapon.Mod', source, modList[mod].Hash, false)
                        return
                    end
                end
                for key,val in pairs(v.Data.Mods) do
                    if val == modList[mod].Hash then
                        table.remove(v.Data.Mods, key)
                        break
                    end
                end

                Inventories['Player'][tostring(source)][k].Data.Mods = v.Data.Mods
                Inventory.SQL('Update', 'Player', source, k)
                Update('Player', tostring(source), nil, nil, nil, k)
                TriggerClientEvent('Weapon.Mod', source, modList[mod].Hash, false)
            else
                v.Data.Mods = v.Data.Mods or {}
                if not modList[mod].NoConsume then
                    if not Inventory.RemoveItemKey('Player', source, modList[mod].Item, 1) then
                        return
                    end
                else
                    if not exports['geo-inventory']:HasItemKey('Player', source, modList[mod].Item, 1) then return end
                    
                    if items[modList[mod].Item].Deteriorate then
                        local item = GetItemKey('Player', source, modList[mod].Item)
                        if (item.Data.Durability or 100) <= 0 then return end
                        Deteriorate('Player', source, item.ID)
                    else
                        local char = GetCharacter(source)
                        if usedMod[char.id] == nil then
                            usedMod[char.id] = {}
                        end
    
                        if usedMod[char.id][mod] then
                            TriggerClientEvent('Shared.Notif', source, 'You can only use this once per day')
                            return
                        else
                            usedMod[char.id][mod] = true
                        end
                    end
                end

                Refresh('Player', tostring(source))
                table.insert(v.Data.Mods, modList[mod].Hash)
                Inventories['Player'][tostring(source)][k].Data.Mods = v.Data.Mods
                Inventory.SQL('Update', 'Player', source, k)
                Update('Player', tostring(source), nil, nil, nil, k)
                TriggerClientEvent('Weapon.Mod', source, modList[mod].Hash, true)
            end
        end
    end
end)

RegisterNetEvent('Dumpster')
AddEventHandler('Dumpster', function(dumpsterID)
    local source = source
    OpenInventory(source, 'Dumpster', dumpsterID)
end)

RegisterNetEvent('EvidenceBag.Name', function(id, name)
    local source = source
    for k,v in pairs(Inventories['Player'][tostring(source)]) do
        if v.ID == id then
            v.Data.DisplayName = name
            Update('Player', tostring(source), nil, nil, nil, k)
            Inventory.SQL('Update', 'Player', source, k)
        end
    end
end)

AddEventHandler('playerDropped', function()
    local source = source
    Inventories['Player'][tostring(source)] = nil
end)

function HasMod(mod, data)
    for k,v in pairs(data) do
        if v == mod then return true end
    end
end

exports('RemoveInventory', function(source)
    Inventories['Player'][tostring(source)] = nil
    charIDs[tostring(source)] = nil
end)

exports('GetItem', function(itemID)
    return items[itemID]
end)

function GetWeight(inventoryType, inventoryID)
    local inv = Inventories[inventoryType][tostring(inventoryID)]
    if inv == nil then return 0 end
    local weight = 0

    for k,v in pairs(inv) do
        weight = weight + ((items[v.Key].Weight or 0) * v.Amount)
    end

    return weight
end

Task.Register('NewOutfit', function(source, data)
    local item = InstanceItem('outfit')
    item.Data = data
    exports['geo-inventory']:AddItem('Player', source, 'outfit', 1, item)
end)

Task.Register('BuyOutfit', function(source, data)
    if Inventory.CanFit('Player', source, 'outfit', 1) and exports['geo-inventory']:RemoveItem('Player', source, 'dollar', 1000) then
        local item = InstanceItem('outfit')
        item.Data = data
        exports['geo-inventory']:AddItem('Player', source, 'outfit', 1, item)
    end
end)

Task.Register('RenameOutfit', function(source, id, name)
    for k,v in pairs(Inventories['Player'][tostring(source)]) do
        if v.ID == id and v.Key == 'outfit' then
            v.Data.Name = name or "Unk"
            Inventory.SQL('Update', 'Player', source, k)
            Update('Player', tostring(source))
            break
        end
    end
end)

Task.Register('Inventory.Familiarity', function(source, counts)
    for k,v in pairs(Inventories['Player'][tostring(source)]) do
        if counts[v.ID] then
            local char = GetCharacter(source)
            local inv = Inventories['Player'][tostring(source)]
            local cid = tostring(char.id)

            if not inv[k].Data.Familiarity then inv[k].Data.Familiarity = {} end
            if not inv[k].Data.Familiarity[cid] then inv[k].Data.Familiarity[cid] = 0 end


            inv[k].Data.Familiarity[cid] = inv[k].Data.Familiarity[cid] + (counts[v.ID] > 5 and 5 or counts[v.ID])
            if inv[k].Data.Familiarity[cid] > 2500 then inv[k].Data.Familiarity[cid] = 2500 end
            Inventory.SQL('Update', 'Player', source, k)
        end
    end
    Console('Inventory', 'Update Fami')
    Update('Player', tostring(source))
end)

local allowed = {}
RegisterCommand('_checkcredit', function(source, args)
    local char = GetCharacter(source)
    if char.username then
        OpenInventory(source, 'Credit', args[1])
    end
end)

RegisterCommand('_addcredit', function(source, args)
    local char = GetCharacter(source)
    if source == 0 or char.username then
        FetchInventory('Credit', args[1])
        Inventory.AddItem('Credit', args[1], args[2], tonumber(args[3]))

        for k,v in pairs(GetPlayers()) do
            if GetUser(tonumber(v)).id == tonumber(args[1]) then
                for key,val in pairs(Inventories['Credit'][args[1]]) do
                    if val then
                        allowed[tonumber(v)] = true
                        TriggerClientEvent('Inventory.Credit', v)
                        break
                    end
                end
            end
        end
    end
end)

RegisterCommand('_addcreditchar', function(source, args)
    local char = GetCharacter(source)
    if source == 0 or char.username then
        local id = SQL('SELECT user from characters where id = ?', tonumber(args[1]))[1].user
        FetchInventory('Credit', id)
        Inventory.AddItem('Credit', id, args[2], tonumber(args[3]))

        for k,v in pairs(GetPlayers()) do
            if GetUser(tonumber(v)).id == tonumber(id) then
                for key,val in pairs(Inventories['Credit'][tostring(id)]) do
                    if val then
                        allowed[tonumber(v)] = true
                        TriggerClientEvent('Inventory.Credit', v)
                        break
                    end
                end
            end
        end
    end
end)

AddEventHandler('Login', function(char, user)
    FetchInventory('Credit', user.id)
    for k,v in pairs(Inventories['Credit'][tostring(user.id)]) do
        if v then
            allowed[char.serverid] = true
            TriggerClientEvent('Inventory.Credit', char.serverid)
            break
        end
    end
end)

RegisterNetEvent('CloseInv', function()
    local source = source
    openInv[source] = {}
end)

Task.Register('Inventory.Credit', function(source)
    if allowed[source] then
        OpenInventory(source, 'Credit', GetUser(source).id)
    end

    allowed[source] = false
end)

Task.Register('Inventory.Equip', function(source, id, bool)
    local inventoryID = tostring(source)
    for k,v in pairs(Inventories['Player'][inventoryID]) do
        if v.ID == id and items[v.Key].Equippable then
            local str = items[v.Key].Equippable
            if bool then
                local skill = items[v.Key].Skill

                if not exports['geo-disciple']:CanEquip(source, v.Key) then return end
                for key,val in pairs(Inventories['Player'][inventoryID]) do
                    if (items[val.Key].Equippable == str and val.Data.Equipped) or items[val.Key].Skill ~= skill then
                        val.Data.Equipped = nil
                        Inventory.SQL('Update', 'Player', inventoryID, key)
                        Update('Player', inventoryID, nil, nil, nil, key)
                    end
                end
            end

            v.Data.Equipped = bool == true and inventoryID or nil
            TriggerClientEvent('Inventory.Equipped', source, items[v.Key].Skill)

            Inventory.SQL('Update', 'Player', inventoryID, k)
            Update('Player', inventoryID, nil, nil, nil, k)
            return
        end
    end
end)

Task.Register('Police.TakeEvidence', function(source, player, item, key, slot)
    local char = GetCharacter(source)
    if char.Duty == 'Police' then
        local item = New(Inventories['Player'][tostring(player)][tostring(slot)])
        if Inventory.CanFit('Player', source, item.Key, 1) then
            if Inventory.RemoveItem('Player', player, item.ID, item.Amount, slot) then
                Inventory.AddItem('Player', source, item.Key, item.Amount, item)
            end
        end
    end
end)

RegisterNetEvent('Inventory.SetClass', function(veh, class)
    local ent = NetworkGetEntityFromNetworkId(veh)
    if classes[ent] == nil then classes[ent] = class end
end)

AddEventHandler('entityRemoved', function(ent)
    if classes[ent] then
        Inventories['Vehicle'][tostring(NetworkGetNetworkIdFromEntity(ent))] = nil
        Inventories['Glovebox']['Glovebox-'..tostring(NetworkGetNetworkIdFromEntity(ent))] = nil
    end
end)

function AddLife(inventoryType, inventoryID, add, i, lifeVal)
    local lastIndex
    for index = #lifeVal - (add - 1), #lifeVal do
        table.insert(Inventories[inventoryType][inventoryID][i].Data.Life, lifeVal[index] or lastIndex)
        lastIndex = lifeVal[index] or lastIndex
        lifeVal[index] = nil
    end
    return lifeVal
end

function GetMaxWeight(inventoryType, inventoryID)
    local max = Sizes[inventoryType]

    if inventoryType == 'Vehicle' then
        local class = classes[NetworkGetEntityFromNetworkId(tonumber(inventoryID))]
        if Sizes[class] then return Sizes[class] end
    end

    return max
end

exports('OpenInventory', OpenInventory)
exports('AddItem', Inventory.AddItem)
exports('RemoveItem', Inventory.RemoveItem)
exports('CanFit', Inventory.CanFit)
exports('InstanceItem', InstanceItem)
exports('RemoveDurability', RemoveDurability)
exports('Repair', Repair)
exports('HasItem', HasItem)
exports('HasItemKey', HasItemKey)
exports('GetItemName', GetItemName)
exports('GetAvailableSlots', GetAvailableSlots)
exports('GetItemKey', GetItemKey)
exports('ReceiveItem', ReceiveItem)
exports('GetInventory', GetInventory)
exports('Deteriorate', Deteriorate)
exports('AmountKey', Inventory.AmountKey)
exports('FetchInventory', FetchInventory)



local scopes = {}
local props = {}

AddEventHandler("playerEnteredScope", function(data)
    local playerEntering, player = data["player"], data["for"]

    if not scopes[player] then
        scopes[player] = {}
    end

    scopes[player][playerEntering] = true

    for k,v in pairs(props[tonumber(playerEntering)] or {}) do
        TriggerClientEvent('Props', tonumber(player), tonumber(playerEntering), k, v)
    end
end)

AddEventHandler("playerLeftScope", function(data)
    local playerLeaving, player = data["player"], data["for"]

    if not scopes[player] then return end
    scopes[player][playerLeaving] = nil

    for k,v in pairs(props[tonumber(playerLeaving)] or {}) do
        TriggerClientEvent('Props', tonumber(player), tonumber(playerLeaving), k, false)
    end
end)

AddEventHandler('Logout', function(char)
    for k,v in pairs(props[tonumber(char.serverid)] or {}) do
        TriggerClientEvent('Props', -1, char.serverid, k, false)
    end
end)

AddEventHandler("playerDropped", function()
    local intSource = source
        
    if not intSource then return end

    scopes[intSource] = nil

    for owner, tbl in pairs(scopes) do
        if tbl[intSource] then
            tbl[intSource] = nil
        end
    end
end)

function GetPlayerScope(intSource)
    return scopes[tostring(intSource)]
end

function TriggerScopeEvent(eventName, scopeOwner, ...)
    local targets = scopes[tostring(scopeOwner)]
    if targets then
        for target, _ in pairs(targets) do
            TriggerClientEvent(eventName, target, ...)
        end
    end
end

RegisterNetEvent('Props', function(index, bool, mods)
    local source = source
    if not props[source] then props[source] = {} end
    props[source][index] = bool and true or nil
    TriggerScopeEvent('Props', source, source, index, bool, mods)
end)

function GetFakeSlots(inv)
    local fakeSlots = {}
    for k,v in pairs(inv) do
        if items[v.Key].size then
            for heightIndex = 1, items[v.Key].size[2] do
                for pIndex = 1, items[v.Key].size[1] do
                    if not (pIndex == 1 and heightIndex == 1) then
                        local num = (heightIndex * 8) + pIndex - 8 - 1
                        fakeSlots[tostring(tonumber(k) + num)] = true
                    end
                end
            end
        end
    end
    return fakeSlots
end