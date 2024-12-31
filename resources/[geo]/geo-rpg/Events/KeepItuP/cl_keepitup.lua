local _zone = ''
local active = false

AddCircleZone(vector3(166.29, -1038.94, 29.32), 100.0, {
    name="keepitup",
    useZ=false,
    --debugPoly=true
})

local inside = false
AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'keepitup' then
        inside = inZone
        if inZone then
            local ped = exports['geo-interface']:InterfacePed({
                model = 's_m_y_clown_01',
                position = vector4(165.77, -1039.64, 29.32, 338.89),
                title = 'Keep It Up!',
                scenario = 'WORLD_HUMAN_MUSICIAN',
                event = 'KeepItUp.Menu'
            })
    
            while inside do
                Wait(500)
            end
    
            exports['geo-interface']:RemovePed(ped)
        end
    end
end)

AddEventHandler('KeepItUp.Menu', function()
    local menu = {
        {title = 'Keep It Up', serverevent = 'KeepItUp'},
        {description = 'How long can you keep it up? Not checking in for more than 2 days will reset your status'}
    }

    RunMenu(menu)
end)

RegisterNetEvent('KeepItUp', function()
    local peds = {}
    local veh = Shared.SpawnVehicle('gburrito', vector3(177.51, -1011.77, 29.05))

    for i=1,3 do
        peds[i] = Shared.SpawnPed('g_m_y_lost_01', vector4(165.87, -1007.51, 29.43, 170.0) + vec(2.0 * i, 0.0, 0.0, 0.0))
        GiveWeaponToPed(peds[i], 'WEAPON_ASSAULTRIFLE', 90, false, true)
        SetCurrentPedWeapon(peds[i], 'WEAPON_ASSAULTRIFLE', true)
        SetPedKeepTask(peds[i], true)
        SetPedRelationshipGroupHash(peds[i], 10)
        SetEntityCanBeDamagedByRelationshipGroup(peds[i], false, 10)
        TaskSetBlockingOfNonTemporaryEvents(peds[i], true)
        TaskCombatPed(peds[i], Shared.Ped, 0 ,16)
        SetEntityInvincible(peds[i], true)
        Wait(100)
        TriggerServerEvent("Ped.Control", PedToNet(peds[i]), true)
    end

    while MyCharacter.dead ~= 1 do
        Wait(500)
    end

    SetPedCanBeTargetted(Shared.Ped, false)
    for i=1,3 do
        ClearPedTasksImmediately(peds[i])
        RemoveWeaponFromPed(peds[i], 'WEAPON_ASSAULTRIFLE')
        TaskSetBlockingOfNonTemporaryEvents(peds[i], true)
		SetPedCombatAttributes(peds[i], 46, false)
        SetPedKeepTask(peds[i], true)
    end

    local driver
    for i=1,3 do
        if not IsEntityDead(peds[i]) then
            driver = peds[i]
            TaskGoToEntity(peds[i], Shared.Ped, -1, 1.0, 10.0, 1073741824.0, 0)
        
            Shared.GetEntityControl(peds[i])
            while Vdist3(GetEntityCoords(peds[i]), GetEntityCoords(Shared.Ped)) >= 1.5 do
                TaskGoToEntity(peds[i], Shared.Ped, -1, 1.0, 5.0, 1073741824.0, 0)
                Wait(1000)
            end

            Shared.GetEntityControl(peds[i])
            AttachEntityToEntity(Shared.Ped, peds[i], 11816, 0.25, 0.7, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 1, 1, 1)
            ClearPedTasks(peds[i])

            Wait(1500)
            local min, max = GetModelDimensions(GetEntityModel(veh))
            local offset = GetOffsetFromEntityInWorldCoords(veh, 0.0, min.y, 0.0)
            TaskGoToCoordAnyMeans(peds[i], offset, 2.0, 0, 0, 786603, 1.0)
            Shared.GetEntityControl(peds[i])
            while Vdist3(GetEntityCoords(peds[i]), offset) >= 2.0 do
                Wait(500)
            end
    
            Shared.GetEntityControl(peds[i])
            Shared.GetEntityControl(veh)
            TaskTurnPedToFaceEntity(peds[i], veh, 2000)
            Wait(2000)
    
            Shared.GetEntityControl(peds[i])
            Shared.GetEntityControl(veh)
            DetachEntity(Shared.Ped)
            SetPedIntoVehicle(Shared.Ped, veh, 2)

            Shared.GetEntityControl(veh)
            SetVehicleDoorsLocked(veh, 0)
            TaskEnterVehicle(peds[i], veh, -1, -1, 5.0, 1, 0)
            Wait(5000)
        
            SetVehicleEngineOn(veh, true, true ,true)
            TaskVehicleDriveToCoordLongrange(peds[i], veh, vector3(979.98, -114.21, 74.22), 99999.0, 2883621 , 1.0)
            break
        end
    end

    for i=1,3 do
        if peds[i] ~= driver then
            TaskWanderStandard(peds[i], 10.0, 10)
            SetEntityInvincible(peds[i], false)
        end
    end

    Wait(50000)
    DoScreenFadeOut(3000)
    Wait(3500)
    TriggerEvent('Respawn')
    TriggerEvent('Shared.Notif', 'You seem to remember nothing abbout how this happened')

    Wait(10000)
    TriggerEvent('Shared.Notif', "You've kept it up for far too long, what did you think? clowns are this generous?")
end)

CreateThread(function()
    Wait(2000)
    local ped = exports['geo-interface']:InterfacePed({
        model = 416176080,
        position = vector4(256.01, -782.48, 30.54, 73.78),
        title = 'Event Trader',
        event = 'Event:Menu'
    })

    Wait(250)
    local loc = exports['geo-interface']:AddTargetEntity(exports['geo-interface']:GetPed(ped), 'Trade Event Items', 'StoreTrade', {'EventTrades'})
    local loc2 = exports['geo-interface']:AddTargetEntity(exports['geo-interface']:GetPed(ped), 'Buy Event Items', 'StoreTrade', {'EventBuy'})

    local pTable = Shared.SpawnObject(1207428357, vec(255.21870422363, -782.21008300781, 29.544353485107, -22.0), true)
    SetEntityHeading(pTable, -22.0)
    FreezeEntityPosition(pTable, true)
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        DeleteEntity(pTable)
    end
end)

AddEventHandler('Event:Menu', function()
    local menu = {}
    for k,v in pairs(EventTrades) do
        table.insert(menu, {
            title = v[3] or exports['geo-inventory']:GetItemName(v[1]),
            description = '',
            serverevent = 'Event.Trade',
            params = {k}
        })

        for key,val in pairs(v[2]) do
            menu[#menu].description =  menu[#menu].description..' '..exports['geo-inventory']:GetItemName(val[1])..' x'..val[2]..'<br>'
        end

        for key,val in pairs(v[2]) do
            if exports['geo-inventory']:Amount(val[1]) < val[2] then
                menu[#menu].disabled = true
                break
            end
        end
    end

    RunMenu(menu)
end)