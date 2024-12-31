local objList = {}
local activeWH = {}
local warehouses = {
    vec(795.8, -1725.66, 30.52, 180.0),
    vec(1019.11, -2511.68, 28.48, 88.73),
    vec(976.28, -2423.14, 30.19, 271.09),
    vec(908.34, -2220.98, 30.50, 261.71),
    vec(860.65, -2217.31, 30.52, 87.98),
    vec(871.38, -2100.30, 30.48, 91.15),
    vec(807.45, -2002.56, 29.96, 95.09),
    vec(964.19, -1786.96, 31.24, 82.71),
    vec(969.20, -1727.50, 31.06, 89.97),
    vec(977.79, -1465.96, 31.43, 81.61),
    vec(746.79, -1399.55, 26.61, 197.51),
    vec(900.52, -1153.72, 25.40, 186.51),
    vec(844.67, -1059.49, 28.32, 269.87),
    vec(721.89, -909.37, 25.43, 100.04),
    vec(724.06, -697.29, 28.54, 103.97),
    vec(102.33, 175.83, 104.72, 174.01),
    vec(-1099.18, -2137.36, 13.40, 224.46),
    vec(-1079.9, -2242.98, 13.22, 320.44),
    vec(-742.21, -2486.84, 15.74, 65.00),
    vec(-281.59, -2656.8, 6.45, 44.99)
}

local jobItems = {
    'hdd', 'briefcase', 'inventory_binder'
}


Jobs:RegisterRanking('CommercialRobbery', DefaultCriminal)
RegisterNetEvent('CommercialRobbery.StartJob')
AddEventHandler('CommercialRobbery.StartJob', function()
    local source = source
    local char = GetCharacter(source)

    if char.id then
        if not objList[char.id] then
            objList[char.id] = Jobs.Fetch('CommercialRobbery', char.id)
            if not objList[char.id] then return end
        end

        if objList[char.id].job then
            TriggerClientEvent('CommercialRobbery.StartJob', source)
            return
        end

        objList[char.id]:CheckPromotion()
        objList[char.id].job = 'phase_1'
        objList[char.id].item = exports['geo-inventory']:InstanceItem('keycard_green')
        objList[char.id].finishitem = exports['geo-inventory']:InstanceItem(jobItems[Random(#jobItems)])
        JobTime[char.id] = os.time()

        if objList[char.id]:GetHours() == 0 or GetUser(source).data.settings.jobinfo then
            TriggerClientEvent('Shared.Notif', source, [[
                Find a keycard on one of the locals and come back to me. Grab a weapon, you'll need it 
                to scare the locals into letting you search their pockets.
            ]], 10000)
        end

        TriggerClientEvent('CommercialRobbery.StartJob', source)
        TriggerClientEvent('CommercialRobbery.SetStage',source, 'phase_1')
    end
end)

RegisterNetEvent('CommercialRobbery.QuitJob')
AddEventHandler('CommercialRobbery.QuitJob', function()
    local source = source
    local char = GetCharacter(source)

    if char.id then
        if not objList[char.id] then
            objList[char.id] = Jobs.Fetch('CommercialRobbery', char.id)
            if not objList[char.id] then return end
        end

        if objList[char.id].job then
            objList[char.id].job = false
            JobTime[char.id] = os.time()
            TriggerClientEvent('CommercialRobbery.QuitJob', source)
            TriggerClientEvent('CommercialRobbery.SetStage',source, 'none')
            RemoveWarehouse(char.id)
        end
    end
end)

RegisterNetEvent('CommercialRobbery.WarehouseLocation')
AddEventHandler('CommercialRobbery.WarehouseLocation', function()
    local source = source
    local char = GetCharacter(source)

    if char.id then
        if not objList[char.id] then
            return
        end

        if objList[char.id].job == 'phase_2' then
            objList[char.id].loc = warehouses[Random(#warehouses)]
            objList[char.id].job = 'phase_3'
            TriggerClientEvent('CommercialRobbery.WarehouseLocation', source, objList[char.id].loc)
        end
    end
end)

RegisterNetEvent('CommercialRobbery.EnterWarehouse')
AddEventHandler('CommercialRobbery.EnterWarehouse', function()
    local source = source
    local char = GetCharacter(source)

    if char.id then
        if not objList[char.id] then
            return
        end

        if objList[char.id].job == 'phase_3' then
            if exports['geo-inventory']:HasItem('Player', source, objList[char.id].item.ID) then
                local pos = objList[char.id].loc
                if not activeWH['WarehouseRobbery '..char.id] then
                    activeWH['WarehouseRobbery '..char.id] = {New(comProps), char.id, char.serverid, false}
                    activeWH['WarehouseRobbery '..char.id][1][Random(#comProps)][7] = true
                end
                exports['geo-instance']:EnterProperty(source, 'WarehouseRobbery '..char.id, 'medium-warehouse', false, {pos.x, pos.y, pos.z, pos.w})
                exports['geo-es']:AddRaid('WarehouseRobbery '..char.id, 'medium-warehouse', {pos.x, pos.y, pos.z, pos.w})
            end
        end
    end
end)

RegisterNetEvent('CommercialRobbery.RobCrate')
AddEventHandler('CommercialRobbery.RobCrate', function(id)
    local source = source
    local char = GetCharacter(source)

    if char.id then
        if activeWH[char.interior] then
            if activeWH[char.interior][1][id][6] then
                local added = false
                local comp = false

                if activeWH[char.interior][1][id][7] then
                    added = exports['geo-inventory']:ReceiveItem('Player', source, objList[activeWH[char.interior][2]].finishitem.Key, 1, objList[activeWH[char.interior][2]].finishitem)
                    comp = true
                else
                    added = exports['geo-jobs']:Loot(source, 'WarehouseRobbery')
                end

                if added then
                    activeWH[char.interior][1][id][6] = false
                    local players = exports['geo-instance']:GetPlayersInInstance(char.interior)
                    for k,v in pairs(players) do
                        TriggerClientEvent('CommercialRobbery.RemoveCrate', v, id)
                    end

                    if comp then
                        if source == activeWH[char.interior][3] then
                            TriggerClientEvent('Shared.Notif', source, [[
                                You have found what we are looking for, please bring it back to me as soon as you can
                            ]], 7500)
                        else
                            TriggerClientEvent('Shared.Notif', activeWH[char.interior][3], [[
                                Someone in the room has found what we are looking for, please bring it back to me as soon as you can
                            ]], 7500)
                        end
    
                        objList[activeWH[char.interior][2]].job = 'phase_4'
                        TriggerClientEvent('CommercialRobbery.SetStage', activeWH[char.interior][3], 'phase_4')
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('CommercialRobbery.FailGame')
AddEventHandler('CommercialRobbery.FailGame', function(loc)
    local source = source
    local char = GetCharacter(source)

    if char.id then
        if activeWH[char.interior] and not activeWH[char.interior][4] then
            activeWH[char.interior][4] = true
            TriggerEvent('Dispatch', {
                code = '10-39',
                title =  'Warehouse Robbery',
                location = loc.position,

                time =  os.date('%H:%M EST'),
                info = {
                    {
                        icon = 'location',
                        text = loc.location,
                        location = false
                    },
                }
            })
            exports['geo-es']:PoliceEvent('AddTempBlip', '10-39', loc.position)
            TriggerClientEvent('3DSound',  -1, vector3(1048.05, -3098.28, -35.96), 'alarm.wav', 0.3, 30.0, char.interior)
        end
    end
end)

RegisterNetEvent('CommercialRobbery.FinishJob')
AddEventHandler('CommercialRobbery.FinishJob', function()
    local source = source
    local char = GetCharacter(source)

    if exports['geo-inventory']:GetAvailableSlots('Player', source) == 0 then
        TriggerClientEvent('Shared.Notif', source, 'You can not hold your reward')
    end

    if char.id then
        if objList[char.id].job == 'phase_4' and exports['geo-inventory']:RemoveItem('Player', source, objList[char.id].finishitem.ID, 1) then
            if objList[char.id]:Pay(source, 1800) then
                exports['geo-inventory']:RemoveItem('Player', source, objList[char.id].item.ID, 1)
                objList[char.id].item = nil
                objList[char.id].loc = nil
                objList[char.id].job = false
                TriggerClientEvent('CommercialRobbery.SetStage', source, 'none')
            end
        end
    end
end)

AddEventHandler('Mugging.Mugged', function(source)
    local char = GetCharacter(source)
    if objList[char.id] then
        if objList[char.id].job == 'phase_1' then
            if Random(100) >= 90 then
                exports['geo-inventory']:ReceiveItem('Player', source, 'keycard_green', 1, objList[char.id].item)
                objList[char.id].job = 'phase_2'
                TriggerClientEvent('CommercialRobbery.SetStage', source, 'phase_2')
                TriggerClientEvent('Shared.Notif', source, 'You got the card, come back to get the location info', 7500)
            end
        end
    end
end)

AddEventHandler('EnteredProperty', function(source, property)
    if activeWH[property] then
        local lst = {}
        for k,v in pairs(activeWH[property][1]) do
            table.insert(lst, v[6])
        end
        TriggerClientEvent('CommercialRobbery.FillProps', source, lst)
    end
end)

AddEventHandler('LeftProperty', function(source, property)
    local char = GetCharacter(source)
    if (property == 'WarehouseRobbery '..char.id) then
        if objList[char.id].job == 'phase_4' then
            RemoveWarehouse(char.id)
        end
    end
end)

AddEventHandler('Logout', function(char)
    RemoveWarehouse(char.id)
end)

function RemoveWarehouse(char)
    exports['geo-es']:RemoveRaid('WarehouseRobbery '..char)
    activeWH['WarehouseRobbery '..char] = nil
end