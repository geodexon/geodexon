local weed = {}

RegisterNetEvent('Store:Purchase')
AddEventHandler('Store:Purchase', function(store, slot, amount, target)
    local source = source
    if StoreList[store] then
        local char = GetCharacter(source)
        if store == 'Ammunation' then
            if not HasWeaponsLicense(char.id) then
                return
            end
        end

        if StoreList[store].Items[slot] then

            amount = tonumber(amount)
            if amount == nil then
                return
            end
            amount = math.floor(math.abs(amount))

            if store == 'Smoke On The Water' then
                if weed[char.id] == nil then weed[char.id] = 10 end
                if weed[char.id] - amount < 0 then
                    TriggerClientEvent('Shared.Notif', source, 'You can only buy '..weed[char.id]..' more joints', 5000)
                    Update('Player', tostring(source))
                    return
                end
            end


            if items[StoreList[store].Items[slot][1]] == nil then
                return
            end

            if items[StoreList[store].Items[slot][1]].Stackable == false then
                amount = 1
            end

            if Inventory.CanFit('Player', source, StoreList[store].Items[slot][1], amount, target) then
                local item = InstanceItem(StoreList[store].Items[slot][1])
                item.Amount = amount

                local emptySlot
                local found = false
                if target == 0 then
                    for i = 1, Slots['Player'] do
                        i = tostring(i)
                        if Inventories['Player'][tostring(source)][i] and Inventories['Player'][tostring(source)][i].ID == item.ID then
                            target = i
                            break
                        else
                            if not Inventories['Player'][tostring(source)][i] and not found then
                                found = true
                                emptySlot = i
                            end
                        end
                    end
                end

                if target == 0 then target = emptySlot end
                local multiplier = 1
                if char.job == 'Convenience' then multiplier = 0.5 end

                if Inventories['Player'][tostring(source)][tostring(target)] == nil or (Inventories['Player'][tostring(source)][tostring(target)] and Inventories['Player'][tostring(source)][tostring(target)].ID == StoreList[store].Items[slot][1])  then
                    if exports['geo-eco']:DebitDefault(GetCharacter(source), math.floor((StoreList[store].Items[slot][2] * amount) * multiplier), amount..' '..GetItemName(StoreList[store].Items[slot][1])..'(s)') then
                        
                        if items[StoreList[store].Items[slot][1]].Decay then
                            item.Data.Life = {}
                            for i = 1, amount do
                                table.insert(item.Data.Life, os.time())
                            end
                        end
                        
                        Inventory.AddItem('Player', source, StoreList[store].Items[slot][1], amount, item, target)
                        if items[item.Key].Weapon and (store == 'Ammunation' or store == 'The Donut Shop') then
                            SQL('INSERT INTO weapons (cid, serial_number) VALUES (?, ?)', GetCharacter(source).id, item.Data.UniqueID)
                        end

                        if store == 'Smoke On The Water' then
                            weed[char.id] = weed[char.id] - amount
                        end

                        Log('Store', {cid = char.id, item = StoreList[store].Items[slot][1], amount = amount, store = store, cost = math.floor((StoreList[store].Items[slot][2] * amount) * multiplier)})
                    end
                end
            else
                TriggerClientEvent('Shared.Notif', source, 'You are carrying too much')
            end

            Update('Player', tostring(source))
        end
    else
        TriggerEvent('OwnedStore.Purchase', source, store, slot, amount, target)
    end
end)

local robbed = {}
local robbing = {}
local lastRobbery = {}
local robbingType = {}

for k,v in pairs(StoreList) do
    robbed[k] = {}
    for index, store in pairs(v.Locations or {}) do
        robbed[k][index] = 0
    end
end

Task.Register('Store.CanRob', function(source, storeName, storeID, loc)
    if StoreList[storeName] and StoreList[storeName].Locations[storeID] and exports['geo-es']:DutyCount('Police') > 0 then
        local time = os.time()

        if robbing[source] then
            return true
        end

        if time - (lastRobbery[source] or 0) < 600 then
            return false
        end

        if time > robbed[storeName][storeID] then
            robbed[storeName][storeID] = time + 900
            robbing[source] = 0
            robbingType[GetCharacter(source).id] = {storeName, storeID}
            lastRobbery[source] = time
            TriggerEvent('Dispatch', {
                code = '10-39',
                title =  storeName..' Robbery',
                location = loc.position,

                time =  os.date('%H:%M EST'),
                info = {
                    {
                        icon = 'location',
                        text = loc.location,
                        location = true
                    },
                }
            })
            return true
        end
    end
end)

Task.Register('Store.Killed', function(source, loc, ent)
    TriggerEvent('Dispatch', {
        code = '10-43',
        title =  "Store Clerk Killed a Bitch",
        location = loc.position,

        time =  os.date('%H:%M EST'),
        info = {
            {
                icon = 'location',
                text = loc.location,
                location = true
            },
        }
    })

    local msg = "Yeah I killed this bitch, tried to attack me"
    if GetEntityHealth(NetworkGetEntityFromNetworkId(ent)) == 200 then
        msg = 'This dickhead had a weapon in my shop'
    end

    Entity(NetworkGetEntityFromNetworkId(ent)).state.policenotif = msg
end)

Task.Register('Store.Pacify', function(source, clerk, bool)
    if Entity(NetworkGetEntityFromNetworkId(clerk)).state.Pacify and not bool then
        Entity(NetworkGetEntityFromNetworkId(clerk)).state.Pacify = nil 
        return
    end
    Entity(NetworkGetEntityFromNetworkId(clerk)).state.Pacify = source
end)

Task.Register('Store.PacifyClerk', function(source, clerk)
    if Entity(NetworkGetEntityFromNetworkId(clerk)).state.Pacify ~= source then
        Entity(NetworkGetEntityFromNetworkId(clerk)).state.Pacify = nil
    else
        TriggerClientEvent('Shared.Notif', source, ([[
            Bitch I won't calm down, you tried to rob me!
        ]]), 10000, true)
    end
end)

RegisterNetEvent('Store.Rob')
AddEventHandler('Store.Rob', function()
    local source = source
    if robbing[source] then
        if robbing[source] < 40 then
            robbing[source] = robbing[source] + 1
            exports['geo-jobs']:Loot(source, 'StoreRobbery')

            if robbing[source] == 40 then
                local char = GetCharacter(source)
                if robbingType[char.id][1] == 'Convenience' then
                    exports['geo-inventory']:OpenInventory(source, 'Register', tostring(robbingType[char.id][2]))
                end
            end
        else
            TriggerClientEvent('Shared.Notif', source, 'the till is empty')
        end
    end
end)

RegisterNetEvent('Store.Rob.Done')
AddEventHandler('Store.Rob.Done', function()
    local source = source
    if robbing[source] then
        robbing[source] = nil
    end
end)

Task.Register('HasGunLicense', function(source)
    local char = GetCharacter(source)
    return HasWeaponsLicense(char.id)
end)

function HasWeaponsLicense(id)
    local hasLicense = (SQL('SELECT licenses from mdt_profiles WHERE cid = ?', id)[1] or {}).licenses
    if type(hasLicense) == 'string' then
        hasLicense = json.decode(hasLicense)
    else
        return true
    end

    if hasLicense['Weapons License'] == nil then
        hasLicense['Weapons License'] = true 
    end

    return hasLicense['Weapons License']
end