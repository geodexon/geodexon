AddBoxZone(vector3(147.27, -1046.25, 29.37), 0.5, 0.2, {
    name="fleeca_vespucci",
    heading=341,
    --debugPoly=true,
    minZ=29.27,
    maxZ=29.87,
    id = 1
}, true)

AddBoxZone(vector3(311.56, -284.64, 54.17), 0.55, 0.2, {
    name="fleeca_vespucci",
    heading=340,
    --debugPoly=true,
    minZ=54.02,
    maxZ=54.67,
    id = 2
}, true)

AddBoxZone(vector3(148.46, -1046.6, 29.35), 0.5, 0.2, {
    name="fleeca_vaultinner",
    heading=250,
    --debugPoly=true,
    minZ=29.25,
    maxZ=29.9
}, true)

AddBoxZone(vector3(312.81, -284.99, 54.14), 0.25, 0.45, {
    name="fleeca_vaultinner",
    heading=339,
    --debugPoly=true,
    minZ=54.04,
    maxZ=54.69
}, true)

local object
local _int
local robbing

AddEventHandler('Fleeca.Swipe', function(data)
    if not exports['geo-inventory']:HasItem('keycard_red') then
        TriggerEvent('Shared.Notif', "You have no idea what to do with this")
        return
    end

    Task.Run('FleecaFlag', data.id)
    if exports['geo-shared']:ProgressSync('Waiting for Card to Scan', 15000) and Task.Run('Fleeca.CheckBank', data.id) then
        object = Shared.SpawnObject(GetHashKey('h4_prop_h4_cash_stack_01a'), banks[data.id].moneypos)
        SetEntityHeading(object, banks[data.id].moneyheading)

        CreateThread(function()
            Wait(1000)
            robbing = data.id
            while banks[data.id].beingRobbed do
                Wait(500)
                if Vdist3(GetEntityCoords(Shared.Ped), banks[data.id].stealPos) <= 1.0 then
                    _int = Shared.Interact('[Interact] Grab That Shit') or _int
                else
                    if _int then _int.stop() end
                end
            end

            if _int then _int.stop() end
            robbing = nil
        end)
    end
end)

AddEventHandler('Fleeca.Close', function(data)
    Task.Run('Fleeca.Close', data.id)
end)

RegisterNetEvent('Fleeca.Stop', function(id)
    banks[id].beingRobbed = false
end)

RegisterNetEvent('Fleeca.Robbery', function(id)
    banks[id].beingRobbed = true
    while banks[id].beingRobbed do
        local obj = GetClosestObjectOfType(banks[id].vaultPos, 50.0, 2121050683, 0, 0, 0)
        if not banks[id].open then
            if obj ~= 0 then
                while DoesEntityExist(obj) and math.abs(GetEntityHeading(obj) - banks[id].openRot) >= 2.0 do
                    Wait(10)
                    SetEntityHeading(obj, GetEntityHeading(obj) - 0.5)
                end

                banks[id].open = true
            end
        else
            if obj == 0 then banks[id].open = false end
        end
        Wait(1000)
    end

    if banks[id].open then
        banks[id].open = false
        local obj = GetClosestObjectOfType(banks[id].vaultPos, 50.0, 2121050683, 0, 0, 0)
        if obj then
            while math.abs(GetEntityHeading(obj) - banks[id].closeRot) >= 2.0 do
                Wait(10)
                SetEntityHeading(obj, GetEntityHeading(obj) + 0.5)
            end
        end
    end
end)

local open = false
AddEventHandler('Interact', function()
    if object and not open then
        if Vdist3(GetEntityCoords(Shared.Ped), banks[robbing].stealPos) > 1.0 then return end

        open = true
        local GrabCash = {
            ['animations'] = {
                {'enter', 'enter_bag'},
                {'grab', 'grab_bag', 'grab_cash'},
                {'grab_idle', 'grab_idle_bag'},
                {'exit', 'exit_bag'},
            },
            ['scenes'] = {},
        }

        local animDict = 'anim@scripted@heist@ig1_table_grab@cash@male@'
        LoadAnim('anim@scripted@heist@ig1_table_grab@cash@male@')
        local ped = Shared.Ped
        local bag = Shared.SpawnObject(GetHashKey('hei_p_m_bag_var22_arm_s'))
        for i = 1, #GrabCash['animations'] do
            GrabCash['scenes'][i] = NetworkCreateSynchronisedScene(GetEntityCoords(object), GetEntityRotation(object), 2, true, false, 1065353216, 0, 1.3)
            NetworkAddPedToSynchronisedScene(ped, GrabCash['scenes'][i], animDict, GrabCash['animations'][i][1], 4.0, -4.0, 1033, 0, 1000.0, 0)
            NetworkAddEntityToSynchronisedScene(bag, GrabCash['scenes'][i], animDict, GrabCash['animations'][i][2], 1.0, -1.0, 1148846080)
            if i == 2 then
                NetworkAddEntityToSynchronisedScene(object, GrabCash['scenes'][i], animDict, GrabCash['animations'][i][3], 1.0, -1.0, 1148846080)
            end
        end
    
        NetworkStartSynchronisedScene(GrabCash['scenes'][1])
        Wait((GetAnimDuration(animDict, 'enter') * 1000) - 500)
        NetworkStartSynchronisedScene(GrabCash['scenes'][2])
        Wait(GetAnimDuration(animDict, 'grab') * 1000 - 3000)
        TriggerServerEvent('DeleteEntity', ObjToNet(object))
        NetworkStartSynchronisedScene(GrabCash['scenes'][4])
        Wait((GetAnimDuration(animDict, 'exit') * 1000) - 700)
        ClearPedTasks(ped)
        DeleteObject(bag)
        object = nil
        open = false
        Task.Run('Fleeca.Done')
    end
end)

AddEventHandler('HackMe', function()
    TriggerEvent("mhacking:show")
    TriggerEvent('mhacking:start', 7, 60, function(bool)
        TriggerEvent('mhacking:hide')
        if bool then
            Task.Run('Fleeca.UnlockVault')
        end
    end)
end)