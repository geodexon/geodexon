local atStore
local zoneData
local storeMenus = {}
local currentStore
AddEventHandler('Poly.Zone', function(zone, inZone, data)
    if zone == 'Store.Open' then
        if data.storeID == nil then return end
        
        atStore = inZone
        if not atStore then
            PurgeZoneData(data.entry..data.storeID)
            return
        end

        if inZone then
            PurgeZoneData(currentStore)
        end

        zoneData = data
        local cStore = data.entry..data.storeID
        currentStore = cStore
        if OwnedStores[zoneData.entry] and OwnedStores[zoneData.entry][zoneData.storeID] then
            local val = exports['geo-instance']:GetProperty(OwnedStores[zoneData.entry][zoneData.storeID][1])
            if val and val.owner == MyCharacter.id then
                storeMenus[#storeMenus + 1] = exports['geo-interface']:AddTargetModel(303280717, 'Store Managment', 'OwnedStore.Manage', nil, 2.0, 'fas fa-solid fa-briefcase')
                storeMenus[#storeMenus + 1] = exports['geo-interface']:AddTargetModel(-1251197000, 'Store Stock', 'OwnedStore.Stock', nil, 2.0, 'fas fa-solid fa-briefcase')
                storeMenus[#storeMenus + 1] = exports['geo-interface']:AddTargetModel(-1787068858, 'Store Cash', 'OwnedStore.Bank', nil, 2.0, 'fas fa-solid fa-briefcase')
                zoneData.owner = true
            end

            if OwnedStores[zoneData.entry][zoneData.storeID][2].safe then
                local pos = OwnedStores[zoneData.entry][zoneData.storeID][2].safe.position
                local rot = OwnedStores[zoneData.entry][zoneData.storeID][2].safe.rotation
                zoneData.safe = Shared.SpawnObject(-1251197000, vec(pos.x, pos.y, pos.z), true)
                FreezeEntityPosition(zoneData.safe, true)
                SetEntityCoords(zoneData.safe, vec(pos.x, pos.y, pos.z))
                SetEntityRotation(zoneData.safe, rot.x, rot.y, rot.z)
            end

            if OwnedStores[zoneData.entry][zoneData.storeID][2].cash then
                local pos = OwnedStores[zoneData.entry][zoneData.storeID][2].cash.position
                local rot = OwnedStores[zoneData.entry][zoneData.storeID][2].cash.rotation
                zoneData.cash = Shared.SpawnObject(-1787068858, vec(pos.x, pos.y, pos.z), true)
                FreezeEntityPosition(zoneData.cash, true)
                SetEntityCoords(zoneData.cash, vec(pos.x, pos.y, pos.z))
                SetEntityRotation(zoneData.cash, rot.x, rot.y, rot.z)
            end
        end
    end
end)

RegisterNetEvent('OwnedStore.UpdateProperty', function(storeType, storeID, newData)
    OwnedStores[storeType][storeID] = newData
    if newData[2].safe then
        local pos = newData[2].safe.position
        exports['geo-inventory']:AddLocation(storeType..'.'..storeID, (newData[2].name or 'Store')..' Stock', vector3(pos.x, pos.y, pos.z), {})
    end

    if itype == 'StoreUI' and iid == storeType..'.'..storeID then
        RefreshInv()
    end

    if newData[2].cash then
        local pos = newData[2].cash.position
        exports['geo-inventory']:AddLocation(storeType..'.'..storeID..'Bank', (newData[2].name or 'Store')..' Bank', vector3(pos.x, pos.y, pos.z), {})
    end

    if zoneData then
        UpdateZoneInfo()
    end
end)

RegisterNetEvent('OwnedStore.Init', function(data)
    OwnedStores = data
    for k,v in pairs(OwnedStores) do
        for key,val in pairs(v) do
            if val[2].safe then
                local pos = val[2].safe.position
                exports['geo-inventory']:AddLocation(k..'.'..key, (val[2].name or 'Store')..' Stock', vector3(pos.x, pos.y, pos.z), {})
            end

            if val[2].cash then
                local pos = val[2].cash.position
                exports['geo-inventory']:AddLocation(k..'.'..key..'Bank', (val[2].name or 'Store')..' Bank', vector3(pos.x, pos.y, pos.z), {})
            end
        end
    end
end)

RegisterCommand('_setstoreproperty', function(source, args)

    local repairShop = exports['geo-store']:AtRepair()
    if repairShop then
        Task.Run('SetStoreProperty', repairShop, tonumber(args[1]), 'LSC')
        return
    end

    if zoneData then
        Task.Run('SetStoreProperty', zoneData.storeID, tonumber(args[1]), zoneData.entry)
        return
    end
end)

AddEventHandler('OwnedStore.Safe', function()
    if not OwnedStores[zoneData.entry][zoneData.storeID][2].safe then
        zoneData.safe = Shared.SpawnObject(-1251197000, GetEntityCoords(Shared.Ped), true)
        FreezeEntityPosition(zoneData.safe, true)
    end

    local data = exports['object_gizmo']:useGizmo(zoneData.safe)
    Task.Run('OwnedStore.Safe', data, zoneData.entry, zoneData.storeID)
end)

AddEventHandler('OwnedStore.Cash', function()
    local cash
    if OwnedStores[zoneData.entry][zoneData.storeID][2].cash then
        cash = zoneData.cash
    else
        zoneData.cash = Shared.SpawnObject(-1787068858, GetEntityCoords(Shared.Ped), true)
        FreezeEntityPosition(zoneData.cash, true)
    end

    local data = exports['object_gizmo']:useGizmo(zoneData.cash)
    Task.Run('OwnedStore.Cash', data, zoneData.entry, zoneData.storeID)
end)

AddEventHandler('OwnedStore.Stock', function()
    Task.Run('OwnedStore.Stock', zoneData.entry, zoneData.storeID)
end)

AddEventHandler('OwnedStore.Bank', function()
    Task.Run('OwnedStore.Bank', zoneData.entry, zoneData.storeID)
end)

AddEventHandler('OwnedStore.Name', function()
    local val = exports['geo-shared']:Dialogue({
        {
            placeholder = 'Name',
            title = 'Store Name',
            image = 'person'
        },
    })

    if val[1] then
        Task.Run('OwnedStore.Name', zoneData.entry, zoneData.storeID, val[1])  
    end
end)

function GetOwnedStoreItems(iid)
    if Inventories['Locations'][iid] == nil then
        Inventories['Locations'][iid] = Task.Run('FetchStoreInv', iid)
    end

    while Inventories['Locations'][iid] == nil do
        Wait(0)
    end
    Wait(100)

    local data = {}
    for k,v in pairs(Inventories['Locations'][iid]) do
        local item = New(v)

        local prices = OwnedStores[zoneData.entry][zoneData.storeID][2].prices

        item.Price = '$'..comma_value(GetPrice(prices and prices[v.ID] and prices[v.ID][1] or 9999999999))
        item.Amount = v.Amount
        item.Stock = v.Amount
        data[k] = item
    end

    return data
end

RegisterNUICallback('SetPrice', function(data, cb)
    SetPrice(data)
    cb(true)
end)

RegisterNetEvent('SetProperty')
AddEventHandler('SetProperty', function(id, prop)
    if zoneData and OwnedStores[zoneData.entry] and OwnedStores[zoneData.entry][zoneData.storeID] then
        Wait(500)
        UpdateZoneInfo()
    end
end)

function SetPrice(data, managment)
    local val = exports['geo-shared']:Dialogue({
        {
            placeholder = 'Price',
            title = 'Set Price For '..items[data.key].Name,
            image = 'person'
        },
    })[1]
    if tonumber(val) then
        Task.Run('OwnedStore.SetPrice', zoneData.entry, zoneData.storeID, data.id, tonumber(val), data.key)
        if managment then
            OwnedStorePrices()
        end
    end
end

function OwnedStorePrices()
    local menu = {}

    for k,v in pairs(OwnedStores[zoneData.entry][zoneData.storeID][2].prices) do
        table.insert(menu, {
            title = items[v[2]].Name or k,
            close = false,
            right = '$'..comma_value(v[1]),
            submenu = {
                {title = 'Remove Price', func = OwnedStoreRemovePrice,  params = {k}},
                {title = 'Change Price', close = false, func = SetPrice, params = {{id = k, key = v[2]}, true}}
            }
        })
    end

    table.insert(menu, {
        description = 'Open to change or remove prices'
    })

    RunMenu(menu)
end

function OwnedStoreRemovePrice(index)
    Task.Run('OwnedStore.RemovePrice', zoneData.entry, zoneData.storeID, index)
    Wait(100)
    OwnedStorePrices()
end

function ToggleOwnedStore()
    Task.Run('OwnedStore.Toggle', zoneData.entry, zoneData.storeID)
end

function PurgeZoneData(store)
    if store ~= currentStore then return end

    if zoneData then
        if zoneData.safe then
            DeleteEntity(zoneData.safe)
        end

        if zoneData.cash then
            DeleteEntity(zoneData.cash)
        end

        for k,v in pairs(storeMenus) do
            v.remove()
        end
        zoneData = nil
        storeMenus = {}
    end
end

AddEventHandler('OwnedStore.Manage', function()
    local menu = {
        {title = 'Place Safe', event = 'OwnedStore.Safe'},
        {title = 'Place Cash Storage', event = 'OwnedStore.Cash'},
        {title = 'Set Store Name', event = 'OwnedStore.Name'},
        {title = 'View Store Prices', func = OwnedStorePrices},
        {title = OwnedStores[zoneData.entry][zoneData.storeID][3] == false and 'Open Store' or 'Close Store', func = ToggleOwnedStore},
    }

    RunMenu(menu)
end)

AddEventHandler('LSC.Customize', function(repairShop)
    local menu = {
        {title = 'Place Safe', event = 'OwnedStore.Safe'},
        {title = 'Set Store Name', event = 'OwnedStore.Name'},
    }

    RunMenu(menu)
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() == res then
        if zoneData and zoneData.safe then
            DeleteEntity(zoneData.safe)
        end

        if zoneData and zoneData.cash then
            DeleteEntity(zoneData.cash)
        end
    end
end)

function IsStoreAvailable()
    if zoneData then 
        if OwnedStores[zoneData.entry] and OwnedStores[zoneData.entry][zoneData.storeID] then
            return not OwnedStores[zoneData.entry][zoneData.storeID][3]
        end
    end

    return true
end

function StoreZone()
    return zoneData
end

function UpdateZoneInfo()
    if zoneData.safe == nil and OwnedStores[zoneData.entry][zoneData.storeID][2].safe then
        local pos = OwnedStores[zoneData.entry][zoneData.storeID][2].safe.position
        local rot = OwnedStores[zoneData.entry][zoneData.storeID][2].safe.rotation
        zoneData.safe = Shared.SpawnObject(-1251197000, vec(pos.x, pos.y, pos.z), true)
        FreezeEntityPosition(zoneData.safe, true)
        SetEntityRotation(zoneData.safe, rot.x, rot.y, rot.z)
    elseif zoneData.safe then
        local pos = OwnedStores[zoneData.entry][zoneData.storeID][2].safe.position
        local rot = OwnedStores[zoneData.entry][zoneData.storeID][2].safe.rotation
        FreezeEntityPosition(zoneData.safe, true)
        SetEntityCoords(zoneData.safe, pos.x, pos.y, pos.z)
        SetEntityRotation(zoneData.safe, rot.x, rot.y, rot.z)
    end

    if zoneData.cash == nil and OwnedStores[zoneData.entry][zoneData.storeID][2].cash then
        local pos = OwnedStores[zoneData.entry][zoneData.storeID][2].cash.position
        local rot = OwnedStores[zoneData.entry][zoneData.storeID][2].cash.rotation
        zoneData.cash = Shared.SpawnObject(-1787068858, vec(pos.x, pos.y, pos.z), true)
        FreezeEntityPosition(zoneData.cash, true)
        SetEntityRotation(zoneData.cash, rot.x, rot.y, rot.z)
    elseif zoneData.cash then
        local pos = OwnedStores[zoneData.entry][zoneData.storeID][2].cash.position
        local rot = OwnedStores[zoneData.entry][zoneData.storeID][2].cash.rotation
        FreezeEntityPosition(zoneData.cash, true)
        SetEntityCoords(zoneData.cash, pos.x, pos.y, pos.z)
        SetEntityRotation(zoneData.cash, rot.x, rot.y, rot.z)
    end

    local val = exports['geo-instance']:GetProperty(OwnedStores[zoneData.entry][zoneData.storeID][1])
    if val and val.owner == MyCharacter.id then
        if zoneData.owner ~= true then
            storeMenus[#storeMenus + 1] = exports['geo-interface']:AddTargetModel(303280717, 'Store Managment', 'OwnedStore.Manage', nil, 2.0, 'fas fa-solid fa-briefcase')
            storeMenus[#storeMenus + 1] = exports['geo-interface']:AddTargetModel(-1251197000, 'Store Stock', 'OwnedStore.Stock', nil, 2.0, 'fas fa-solid fa-briefcase')
            storeMenus[#storeMenus + 1] = exports['geo-interface']:AddTargetModel(-1787068858, 'Store Cash', 'OwnedStore.Bank', nil, 2.0, 'fas fa-solid fa-briefcase')
            zoneData.owner = true
        end
    else
        if zoneData.owner == true then
            zoneData.owner = false
            for k,v in pairs(storeMenus) do
                v.remove()
            end
            storeMenus = {}
        end
    end
end

exports('IsStoreAvailable', IsStoreAvailable)