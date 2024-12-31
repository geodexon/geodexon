local jobVehicle
local job = 'none'
local jobStart = {
    model = 'a_m_y_business_02',
    pedSpawn = vector4(1045.7, 2653.17, 39.55, 236.0)
}

AddCircleZone(vector3(1045.7, 2653.17, 39.55), 30.0, {
    name="OrganTransport",
    useZ=true,
    id = uuid(),
    model = 'a_m_y_business_02',
    pedSpawn = vector4(1045.7, 2653.17, 39.55, 236.0)
})

local destination
local prop
local jobBlip

local textList = {
    ['none'] = 'Start Job',
    ['done'] = 'Get Paid',
    ['phase_1'] = 'Quit Job',
}

AddEventHandler('Organ.none', function()
    jobVehicle = Task.Run('Organ.StartJob')
    TriggerEvent('AddKey', NetworkGetEntityFromNetworkId(jobVehicle))
end)

AddEventHandler('Organ.done', function()
    jobVehicle = Task.Run('Organ.FinishJob')
    if jobVehicle == nil then
        job = 'none'
        exports['geo-interface']:SetPed(jobStart.ped, textList[job], 'Organ.'..job)
    end
end)

AddEventHandler('Organ.phase_1', function()
    Task.Run('Organ.QuitJob')
end)

AddEventHandler('Poly.Zone', function(zone, inZone, data)
    if zone == 'OrganTransport' then
        if not jobStart.inside then
            jobStart.inside = inZone
            jobStart.ped = CreateMissionPed(data.model, data.pedSpawn, true, true, true)
            exports['geo-interface']:SetPed(jobStart.ped, textList[job], 'Organ.'..job)
            while jobStart.inside do
                Wait(500)
            end
            exports['geo-interface']:SetPed(jobStart.ped, nil)
            DeleteEntity(jobStart.ped)
        end
    end
end)

RegisterNetEvent('Organ.QuitJob')
AddEventHandler('Organ.QuitJob', function()
    jobVehicle = nil
    destination = nil
    job = 'none'
end)

RegisterNetEvent('Organ.SetStage')
AddEventHandler('Organ.SetStage', function(stage)
    job = stage
    exports['geo-interface']:SetPed(jobStart.ped, textList[job], 'Organ.'..job)
end)

AddEventHandler('enteredVehicle', function(veh)
    if jobVehicle and job == 'phase_1' and veh == NetworkGetEntityFromNetworkId(jobVehicle) then
        if not destination then
            destination = Task.Run('Organ.GetLocation')

            if destination ~= 'return' then
                jobBlip = AddBlipForCoord(destination)
                SetBlipSprite(jobBlip, 480)
                SetBlipRoute(jobBlip, true)
                BeginTextCommandSetBlipName("STRING");
                AddTextComponentString('Organ Delivery')
                EndTextCommandSetBlipName(jobBlip)

                CreateThread(function()
                    local close = false
                    local obj
                    while destination do
                        Wait(0)
                        if Vdist3(GetEntityCoords(Shared.Ped), destination) <= 100.0 then
                            if not close then
                                close = true
                                obj = Shared.SpawnObject(1925308724, destination)
                                PlaceObjectOnGroundProperly(obj)
                            end

                            if Vdist3(GetEntityCoords(Shared.Ped), destination) <= 3.0 and prop then
                                Shared.WorldText('E', GetEntityCoords(obj), 'Deliver Organ')
                                if IsControlJustPressed(0, 38) then
                                    TaskTurnPedToFaceEntity(Shared.Ped, obj, 2000)
                                    Wait(2000)
                                    LoadAnim('anim@amb@business@weed@weed_inspecting_lo_med_hi@')
                                    TaskPlayAnim(Shared.Ped, "anim@amb@business@weed@weed_inspecting_lo_med_hi@", "weed_crouch_checkingleaves_idle_01_inspector", 1.0, 1.0, 3000, 1, 3.0, 8.0, false, false, false)
                                    Wait(3000)
                                    TriggerServerEvent('DeleteEntity', ObjToNet(prop))
                                    TriggerServerEvent('Organ.Next', Shared.GetLocation())
                                    jobBlip = RemoveBlip(jobBlip)
                                    prop = nil
                                    local nObj = obj
                                    destination = nil
                                    Citizen.SetTimeout(5000, function()
                                        TriggerServerEvent('DeleteEntity', ObjToNet(obj))
                                    end)
                                end
                            end
                        else
                            if close then
                                close = false
                                if DoesEntityExist(obj) then
                                    TriggerServerEvent('DeleteEntity', ObjToNet(obj))
                                    obj = nil
                                end
                            end
                            Wait(1000)
                        end
                    end
                end)
            else
                TriggerEvent('Shared.Notif', 'Return to your hookup', 5000)
                job = 'done'
                exports['geo-interface']:SetPed(jobStart.ped, textList[job], 'Organ.'..job)
            end
        end
    end
end)

local trunkOpen = false
AddEventHandler('Trunk.Open', function(veh)
    if jobVehicle and job == 'phase_1' and veh == NetworkGetEntityFromNetworkId(jobVehicle) and not trunkOpen then
        trunkOpen = true
        local start = GetGameTimer()
        local min, max = GetModelDimensions(GetEntityModel(veh))

        if Entity(veh).state.organ == true then
            local np = GetOffsetFromEntityInWorldCoords(veh, 0.0, min.y + 0.25, max.z / 2)
            if Vdist3(GetEntityCoords(Shared.Ped), np) <= 2.0 and Shared.CurrentVehicle == 0 then
                TriggerEvent('Shared.Notif', 'The trunk of the vehicle is full of organs', 5000)
            end
        end

        while Shared.TimeSince(start) < 15000 do
            Wait(0)
            local np = GetOffsetFromEntityInWorldCoords(veh, 0.0, min.y + 0.25, max.z / 2)
            if Vdist3(GetEntityCoords(Shared.Ped), np) <= 2.0 and Shared.CurrentVehicle == 0 then
                Shared.WorldText('E', np, 'Get Organ')
                if IsControlJustPressed(0, 38) then
                    prop = Shared.SpawnObject('prop_security_case_01')
                    AttachEntityToEntity(prop, Shared.Ped, GetPedBoneIndex(Shared.Ped, 57005), 0.10, 0.0, 0.0, 0.0, 280.0, 53.0, 1, 1, 0, 1, 1, 1)
                    break
                end
            end
        end
        trunkOpen = false
    end
end)

local lastNotif = GetGameTimer()
AddEventHandler('Entity', function(ent)
    if ent == 0 then return end

    if IsEntityAVehicle(ent) and Entity(ent).state.organ == true and GetVehicleDoorAngleRatio(ent, 5) > 0  and Shared.TimeSince(lastNotif) > 5000 then
        lastNotif = GetGameTimer()
        local min, max = GetModelDimensions(GetEntityModel(ent))
        local np = GetOffsetFromEntityInWorldCoords(ent, 0.0, min.y + 0.25, max.z / 2)
        if Vdist3(GetEntityCoords(Shared.Ped), np) <= 2.0 and Shared.CurrentVehicle == 0 then
            TriggerEvent('Shared.Notif', 'The trunk of the vehicle is full of organs', 5000)
        end
    end
end)