local registers = {}
local safe = Shared.SpawnObject(-1251197000, vec(-1843.8018798828, -1183.705078125, 13.910640716553, 58.0), true)
SetEntityHeading(safe, 58.0)
FreezeEntityPosition(safe, true)

local inPearls = false
AddBoxZone(vector3(-1832.47, -1191.66, 29.52), 33.0, 30.8, {
    name="Pearls",
    heading=321,
    --debugPoly=true,
    minZ=11.92,
    maxZ=24.32
})
  
local pearlZones = {
    {vector3(-1844.03, -1198.89, 14.31), 3.6, 0.4, {
        name="PearlsStorage",
        heading=330,
        --debugPoly=true
    }, true},
    {vector3(-1847.21, -1199.63, 14.31), 0.4, 0.6, {
        name="Pearls.CuttingBoard",
        heading=330,
        --debugPoly=true,
        minZ=14.21,
        maxZ=14.41
    }, true},
    {vector3(-1848.12, -1195.51, 14.31), 1.4, 0.8, {
        name="Pearls.Fryer",
        heading=330,
        --debugPoly=true,
        minZ=14.11,
        maxZ=14.51
    }, true},
    {vector3(-1847.23, -1194.0, 14.31), 2.0, 0.8, {
        name="Pearls.Stove",
        heading=330,
        --debugPoly=true,
        minZ=14.11,
        maxZ=14.31
    }, true},
    {vector3(-1845.23, -1196.19, 14.31), 1, 1.55, {
        name="Pearls.Range",
        heading=330,
        --debugPoly=true,
        minZ=14.11,
        maxZ=14.51
    }, true},
    {vector3(-1849.16, -1197.38, 14.31), 1.4, 0.8, {
        name="Pearls.Frozen",
        heading=330,
        --debugPoly=true,
        minZ=14.21,
        maxZ=14.41
    }, true},
    {vector3(-1843.63, -1183.78, 14.31), 0.8, 0.4, {
        name="Pearls.Safe",
        heading=330,
        --debugPoly=true,
        minZ=13.31,
        maxZ=14.31
    }, true},
    {vector3(-1839.83, -1183.67, 14.31), 0.4, 1, {
        name="Pearls.Order",
        heading=330,
        --debugPoly=true,
        minZ=14.16,
        maxZ=14.36
    }, true},
    {vector3(-1837.82, -1190.43, 14.31), 1.2, 0.4, {
        name="Pearls.Drinks",
        heading=330,
        --debugPoly=true,
        minZ=13.31,
        maxZ=14.31
    }, true},
    {vector3(-1843.06, -1193.2, 14.31), 0.35, 0.5, {
        name="Pearls.Job",
        heading=331,
        --debugPoly=true,
        minZ=14.16,
        maxZ=14.36
    }, true}
}
  
local targetZones = {}
AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'Pearls' then
        inPearls = inZone
        if inPearls then
            Wait(500)
            if exports['geo-guilds']:GuildAuthority('PERL', MyCharacter.id) < 100 then return end
            for k,v in pairs(pearlZones) do
                AddBoxZone(table.unpack(v))
            end

            table.insert(targetZones, exports['geo-interface']:AddTargetZone("PearlsStorage", 'Storage', 'Pearls.Storage', nil, 2.0, 'fas fa-solid fa-ring'))
            table.insert(targetZones, exports['geo-interface']:AddTargetZone("Pearls.CuttingBoard", 'Cutting Board', 'Pearls.FetchList', {'CuttingBoard'}, 2.0, 'fas fa-solid fa-ring'))
            table.insert(targetZones, exports['geo-interface']:AddTargetZone("Pearls.Fryer", 'Fryer', 'Pearls.FetchList', {'Fryer'}, 2.0, 'fas fa-solid fa-ring'))
            table.insert(targetZones, exports['geo-interface']:AddTargetZone("Pearls.Stove", 'Stove', 'Pearls.FetchList', {'Stove'}, 2.0, 'fas fa-solid fa-ring'))
            table.insert(targetZones, exports['geo-interface']:AddTargetZone("Pearls.Range", 'Range', 'Pearls.FetchList', {'Range'}, 2.0, 'fas fa-solid fa-ring'))
            table.insert(targetZones, exports['geo-interface']:AddTargetZone("Pearls.Frozen", 'Frozen Goods', 'Pearls.FetchList', {'Frozen'}, 2.0, 'fas fa-solid fa-ring'))
            table.insert(targetZones, exports['geo-interface']:AddTargetZone("Pearls.Register1", 'Set Price', 'Pearls.RegisterPrice', {1}, 2.0, 'fas fa-solid fa-ring'))
            table.insert(targetZones, exports['geo-interface']:AddTargetZone("Pearls.Safe", 'Safe', 'Pearls.Safe', {1}, 2.0, 'fas fa-solid fa-ring'))
            table.insert(targetZones, exports['geo-interface']:AddTargetZone("Pearls.Order", 'Order Supplies', 'Pearls.Order', {1}, 2.0, 'fas fa-solid fa-ring'))
            table.insert(targetZones, exports['geo-interface']:AddTargetZone("Pearls.Drinks", 'Drink Bar', 'Pearls.Drinks', {}, 2.0, 'fas fa-solid fa-ring'))
            table.insert(targetZones, exports['geo-interface']:AddTargetZone("Pearls.Job", 'Work', 'Pearls.Job', {}, 2.0, 'fas fa-solid fa-ring'))

            
            AddBoxZone(vector3(-1834.12, -1190.0, 14.31), 0.6, 0.4, {
                name="Pearls.Register2",
                heading=330,
                --debugPoly=true,
                minZ=14.31,
                maxZ=14.51
            }, true)
            
            table.insert(targetZones, exports['geo-interface']:AddTargetZone("Pearls.Register2", 'Set Price', 'Pearls.RegisterPrice', {2}, 2.0, 'fas fa-solid fa-ring'))
        
            while inPearls do
                Wait(500)
            end


            for k,v in pairs(pearlZones) do
                TriggerEvent("RemoveZone", v[4].name)
            end

            for k,v in pairs(targetZones) do
                v.remove(true)
            end
            targetZones = {}
        end
    end
end)

CreateThread(function()
    AddBoxZone(vector3(-1835.15, -1191.74, 14.31), 0.6, 0.3, {
        name="Pearls.Register1",
        heading=330,
        --debugPoly=true,
        minZ=14.31,
        maxZ=14.51
    }, true)

    AddBoxZone(vector3(-1834.12, -1190.0, 14.31), 0.6, 0.4, {
        name="Pearls.Register2",
        heading=330,
        --debugPoly=true,
        minZ=14.31,
        maxZ=14.51
    }, true)
end)


AddEventHandler('Pearls.RegisterPrice', function(register)
    local val = Shared.TextInput('Price', 4)
    Task.Run('Pearls.Register', register, val)
end)

RegisterNetEvent('Pearls.RegisterInit', function(registerID, val)
    if registers[registerID] then
        registers[registerID].remove(true)
        registers[registerID] = nil
    end

    registers[registerID] = exports['geo-interface']:AddTargetZone("Pearls.Register"..registerID, 'Pay $'..GetPrice(val), 'Pearls.RegisterPay', {registerID}, 2.0, 'fas fa-solid fa-ring')
end)

RegisterNetEvent('Pearls.RegisterReset', function(registerID)
    if registers[registerID] then
        registers[registerID].remove(true)
        registers[registerID] = nil
    end
end)

AddEventHandler('Pearls.RegisterPay', function(registerID)
    Task.Run('Pearls.RegisterPay', registerID)
end)

AddEventHandler('Pearls.Storage', function()
    Task.Run('Pearls.Storage')
end)

AddEventHandler('Pearls.Drinks', function()
    Task.Run('Pearls.Drinks')
end)

AddEventHandler('Pearls.Order', function()
    local cash = Task.Run('Pearls.Cash')
    local menu = {}
    for k,v in pairs(Pearls['Supplies']) do
        local sub = '$'..GetPrice(v[2])..' per unit <br> Can Afford '..math.floor(cash / v[2])
        table.insert(menu, {
            title = exports['geo-inventory']:GetItemName(v[1]), disabled = false, sub = sub, event = 'Pearls.OrderGoods', params = {k}
        })
    end

    RunMenu(menu)
end)

AddEventHandler('Pearls.OrderGoods', function(id)
    local value = Shared.TextInput('Order Quantity')
    Task.Run('Pearls.OrderGoods', id, value)
end)

AddEventHandler('Pearls.Safe', function()
    Task.Run('Pearls.Safe')
end)

AddEventHandler('Pearls.FetchList', function(listId)
    local data = Task.Run('Pearls.FetchList', listId)

    local menu = {}
    for k,v in pairs(Pearls[listId]) do
        local sub = ''
        for key,val in pairs(v.items) do
            sub = sub..' '..string.format('%sx %s <br>', val[2], exports['geo-inventory']:GetItemName(val[1]))
        end

        table.insert(menu, {
            title = exports['geo-inventory']:GetItemName(v.product), disabled = data[k], sub = sub, event = 'Pearls.Craft', params = {listId, k}
        })
    end

    RunMenu(menu)
end)

AddEventHandler('Pearls.Craft', function(listId, itemID)
    if listId == 'CuttingBoard' then
        LoadAnim('weapons@first_person@aim_idle@generic@melee@knife@shared@core')
        TaskPlayAnim(Shared.Ped, 'weapons@first_person@aim_idle@generic@melee@knife@shared@core', "settle_low", 8.0, 8.0, 5000, 1, 0, 0, 0, 0)
        Wait(5000)
    else
        TaskStartScenarioInPlace(Shared.Ped, 'PROP_HUMAN_BBQ', 0, false)
        Wait(5000)
        ClearPedTasks(Shared.Ped)
    end
    Task.Run('Pearls.Craft', listId, itemID)
end)

AddEventHandler('Pearls.Job', function()
    local data = Task.Run('Pearls.Job')
    local menu = {}

    if data.clockedIn then
        table.insert(menu, {
            title = 'Clock Out',
            serverevent = 'Pearls.Clock'
        })
    else
        table.insert(menu, {
            title = 'Clock In',
            serverevent = 'Pearls.Clock'
        })
    end

    if data.pay > 0 then
        table.insert(menu, {
            title = 'Pay: $'..data.pay,
            serverevent = 'Pearls.Pay'
        })
    end

    RunMenu(menu)
end)