local startPed
local job = 'none'
local model = 1224306523
local startZone = {}

AddZone({
    vector2(-52.190505981445, -1862.3167724609),
    vector2(-32.686485290527, -1839.6859130859),
    vector2(-65.416404724121, -1810.9058837891),
    vector2(-86.886917114258, -1834.6447753906)
  }, {
    name="Escort",
})

local jobPed
local jobBlip

AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'Escort' then
        startZone.inside = inZone
        if inZone then
            startPed = Shared.SpawnPed(model, vector4(-73.73, -1833.53, 26.94, 262.49), true)
            SetEntityCoords(startPed, GetEntityCoords(startPed) - vec(0.0, 0.0, GetEntityHeightAboveGround(startPed)))
            FreezeEntityPosition(startPed, true)
            SetEntityInvincible(startPed, true)
            SetBlockingOfNonTemporaryEvents(startPed, true)
        end

        while startZone.inside do
            Wait(0)

            if job == 'none' then
                if Vdist3(GetEntityCoords(Shared.Ped), GetEntityCoords(startPed)) <= 2.0 then
                    Shared.WorldText('E', GetEntityCoords(startPed), 'Escort Job')
                    if IsControlJustPressed(0, 38) then
                        TriggerServerEvent('Escort.StartJob')
                        job = nil
                    end
                end
            elseif job == 'phase_1' then
                if Vdist3(GetEntityCoords(Shared.Ped), GetEntityCoords(startPed)) <= 2.0 then
                    Shared.WorldText('E', GetEntityCoords(startPed), 'Quit Job')
                    if IsControlJustPressed(0, 38) then
                        TriggerServerEvent('Escort.QuitJob')
                        job = nil
                        RemoveBlip(jobBlip)
                        jobPed = nil
                    end
                end
            elseif job == 'done' then
                if Vdist3(GetEntityCoords(Shared.Ped), GetEntityCoords(startPed)) <= 2.0 then
                    Shared.WorldText('[E] Get Paid', GetEntityCoords(startPed))
                    if IsControlJustPressed(0, 38) then
                        TriggerServerEvent('Escort.Pay')
                        job = nil
                        RemoveBlip(jobBlip)
                        jobPed = nil
                    end
                end
            end
        end

        DeleteEntity(startPed)
        startPed = nil
    end
end)

RegisterNetEvent('Escort.SetState')
AddEventHandler('Escort.SetState', function(state)
    job = state
end)

local hash, name = AddRelationshipGroup('hitsquad')
local count = 0
RegisterNetEvent('Escort.StartJob')
AddEventHandler('Escort.StartJob', function(vehicle, jobInfo)
    job = 'phase_1'
    Shared.GetEntityControl(NetworkGetEntityFromNetworkId(vehicle))
    SetNetworkIdCanMigrate(vehicle, false)
    if not jobPed then
        jobPed = Shared.SpawnPed(-449965460, GetOffsetFromEntityInWorldCoords(Shared.Ped, 0.0, 0.0, -10.0), false)
    end
    ped = jobPed
    Shared.GetEntityControl(ped)
    SetNetworkIdCanMigrate(PedToNet(ped), false)
    vehicle = NetworkGetEntityFromNetworkId(vehicle)
    SetPedIntoVehicle(ped, vehicle, -1)
    TriggerServerEvent('Ped.Control', PedToNet(ped), true)
    jobBlip = AddBlipForEntity(ped)
    SetBlipAsFriendly(jobBlip, true)
    SetVehicleDoorsLocked(vehicle, 0)
    local aggro = {}
    local dead = false
    local done = false

    CreateThread(function()
        while job == 'phase_1' do
            Wait(500)

            if done then
                break
            end

            if not DoesEntityExist(ped) or not DoesEntityExist(vehicle) or IsEntityDead(ped) then
                job = nil
                TriggerServerEvent('Escort.Fail')
                SetEntityAsNoLongerNeeded(ped)
                SetEntityAsNoLongerNeeded(vehicle)
                dead = true
                TriggerEvent('Shared.Notif', 'Mission failed, we\'ll get em next time', 5000)

                for k,v in pairs(aggro) do
                    TaskWanderStandard(v, 10.0, 10)
                    SetEntityAsNoLongerNeeded(v)
                end
                RemoveBlip(blip)
                break
            end
        end
    end)

    while job == 'phase_1' do
        Wait(5000)

        if done then
            break
        end

        if dead then
            RemoveBlip(jobBlip)
            jobPed = nil
            return
        end

        TaskVehicleDriveToCoordLongrange(ped, vehicle, jobInfo.Destination, 20.0, 786603, 1.0)
        SetPedKeepTask(ped, true)

        if Vdist4(GetEntityCoords(vehicle), jobInfo.Destination) <= 50.0 then
            break
        end
    end

    CreateThread(function()
        local min, max = GetModelDimensions(GetEntityModel(vehicle))
        TaskGoToCoordAnyMeans(ped, GetOffsetFromEntityInWorldCoords(vehicle, 0.0, min.y - 1.5, 0.0), 1.30, 0, 0, 786603, 1.0)
        Wait(3000)
        while GetEntitySpeed(ped) > 0 do
            Wait(100)
        end
        TaskTurnPedToFaceEntity(ped, vehicle, 1000)
        Wait(1000)
        if GetVehicleDoorAngleRatio(vehicle, 5) <= 0.0 then
            TriggerServerEvent('Vehicle.ToggleDoor', VehToNet(vehicle), 5)
        end
    
        Wait(15000)
        if GetVehicleDoorAngleRatio(vehicle, 5) > 0.0 then
            TriggerServerEvent('Vehicle.ToggleDoor', VehToNet(vehicle), 5)
        end
    end)

    Wait(Random(5000, 15000))
    if jobInfo.enemies and Random(100) > 50 then
        for i=1,Random(1, 3) do
            local asshole = Shared.SpawnPed('u_m_y_party_01', jobInfo.enemies)
            SetPedRelationshipGroupHash(asshole, name)
            GiveWeaponToPed(asshole, GetHashKey('WEAPON_PISTOL'), 60, false, true)
            TaskCombatPed(asshole, ped)
            table.insert(aggro, asshole)
        end

        while #aggro > 0 do
            Wait(500)
            if dead then
                RemoveBlip(jobBlip)
                jobPed = nil
                return  
            end
            for k,v in pairs(aggro) do
                if IsEntityDead(v) then
                    table.remove(aggro, k)
                end
            end

            TaskCower(ped, 1000)
        end
    end
    
    count = count + 1
    RemoveBlip(blip)
    if count >= 3 then
        count = 0
        TriggerServerEvent('Escord.Done')
    else
        TriggerServerEvent('Escord.Next')
    end

    done = true
end)

RegisterNetEvent('Escort.Return')
AddEventHandler('Escort.Return', function(vehicle, x, y, z)
    job = 'phase_2'
    SetNetworkIdCanMigrate(vehicle, false)
    SetNetworkIdCanMigrate(ped, false)
    vehicle = NetworkGetEntityFromNetworkId(vehicle)
    ped = jobPed
    local blip = AddBlipForEntity(ped)
    SetBlipAsFriendly(blip, true)
    SetVehicleDoorsLocked(vehicle, 0)
    local dead = false

    CreateThread(function()
        while job == 'phase_2' do
            Wait(500)
            if not DoesEntityExist(ped) or not DoesEntityExist(vehicle) or IsEntityDead(ped) then
                job = nil
                TriggerServerEvent('Escort.Fail')
                SetEntityAsNoLongerNeeded(ped)
                SetEntityAsNoLongerNeeded(vehicle)
                dead = true
                RemoveBlip(blip)
                break
            end
        end
    end)

    while job == 'phase_2' do
        Wait(5000)

        if dead then
            RemoveBlip(jobBlip)
            jobPed = nil
            return
        end

        TaskVehicleDriveToCoordLongrange(ped, vehicle, vec(x, y, z), 30.0, 786603, 1.0)
        SetPedKeepTask(ped, true)

        if Vdist4(GetEntityCoords(vehicle), vec(x, y, z)) <= 50.0 then
            break
        end
    end

    SetEntityAsNoLongerNeeded(ped)
    SetEntityAsNoLongerNeeded(vehicle)
    RemoveBlip(jobBlip)
    jobPed = nil
    TriggerServerEvent('Escord.Finish')
end)