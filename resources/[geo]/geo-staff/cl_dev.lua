if GetConvar('sv_dev', 'false') == 'true' then
    local _sp = false
    local pList = {}
    local props = {}
    
    RegisterCommand('sp', function()
        TriggerServerEvent('Dev.UpdatePropList', props)
        for k,v in pairs(pList) do
            DeleteEntity(v)
        end
    
        pList = {}
        props = {}
    end)

    RegisterCommand('devcloth', function()
       exports['geo']:ClothingMenu()
    end)
    
    RegisterCommand('sprop', function(source, args)
        local obj = Shared.SpawnObject(GetHashKey(args[1]) or 1885839156, GetEntityCoords(Shared.Ped), true)
        table.insert(pList, obj)
    
        SetEntityCollision(obj, false, false)
        local currentlyPlacing = true
        local heading = GetEntityHeading(obj)
        SetEntityCollision(obj, false, false)
    
        while currentlyPlacing do
            Wait(0)
            local ray = Shared.Raycast(100)
            DisableControlAction(0, 311, true)
            DisableControlAction(0, 44, true)
            DisableControlAction(0, 51, true)
            DisableControlAction(0, 140, true)
    
            SetEntityCoords(obj, ray.HitPosition.x, ray.HitPosition.y, ray.HitPosition.z)
            SetEntityHeading(obj, heading)
    
            if IsDisabledControlPressed(0, 44) then
                heading = heading - 1.0
            elseif IsDisabledControlPressed(0, 51) then
                heading = heading + 1.0
            end
    
            if IsControlJustPressed(0, 177) then
                DeleteEntity(obj)
                currentlyPlacing = false
            end
    
            if IsDisabledControlPressed(0, 140) then
                currentlyPlacing = false
                table.insert(props, {GetHashKey(args[1]), ray.HitPosition.x, ray.HitPosition.y, ray.HitPosition.z, heading})
                return
            end
        end
    end)
    
    RegisterCommand('setmodel', function(source, args)
        local model = args[1] and GetHashKey(args[1]) or ''
        if IsModelValid(model) then
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(0)
            end

            SetPlayerModel(PlayerId(), model)
            SetModelAsNoLongerNeeded(model)
            SetPedDefaultComponentVariation(PlayerPedId())
        end
    end)

    AddEventHandler('onResourceStop', function(res)
        if res == GetCurrentResourceName() then
            for k,v in pairs(pList) do
                DeleteEntity(v)
            end
        end
    end)

    local carrying = false
    local carryPlayer = 0
    RegisterCommand('carry', function()
        if not carrying then
            local target = Shared.ClosestPed(5.0)
            if target ~= 0 then
                if not IsPedAPlayer(target) and not IsEntityDead(target) and GetPedType(target) ~= 28 then
                    if IsPedInAnyVehicle(target, true) then
                        return
                    end
                
                    Citizen.Await(PedAction(target, function()
                        SetNetworkIdCanMigrate(PedToNet(target), false)
                        carrying = true
                        carryPlayer = target
                        LoadAnim('missfinale_c2mcs_1')
                        LoadAnim('nm')
                        TaskPlayAnim(PlayerPedId(), 'missfinale_c2mcs_1', 'fin_c2_mcs_1_camman', 1.0, 1.0, -1, 49, 1.0, 0, 0, 0)
                        SetBlockingOfNonTemporaryEvents(target, true)
                        ClearPedTasksImmediately(target)
                        SetEntityCollision(target, false, false)
                        AttachEntityToEntity(target, Shared.Ped, GetPedBoneIndex(src, 0), 0.3, 0.1, 0.5, 0.0, 0.0, 0.0, 1, 1, 0, 1, 1, 1)
                        TaskPlayAnim(target, 'nm', 'firemans_carry', 1.0, 1.0, -1, 1, 1.0, 0, 0, 0)
                        Citizen.CreateThread(function()
                            while carrying do
                                Wait(500)
                                if not IsEntityPlayingAnim(PlayerPedId(), 'missfinale_c2mcs_1', 'fin_c2_mcs_1_camman', 49) or Shared.InVehicle then
                                    carrying = false
                                end

                                if not IsEntityPlayingAnim(target, 'nm', 'firemans_carry', 1) then
                                    TaskPlayAnim(target, 'nm', 'firemans_carry', 1.0, 1.0, -1, 1, 1.0, 0, 0, 0)
                                end

                                if IsEntityDead(target) then
                                    carrying = false
                                    break
                                end
                            end
                            carryPlayer = 0
                            StopAnimTask(Shared.Ped, 'missfinale_c2mcs_1', 'fin_c2_mcs_1_camman', 1.0)

                            DetachEntity(target)
                            SetEntityCollision(target, true, true)
                            SetPedToRagdoll(target, 1000, 1000, 0, 1, 1, 1)
                            SetNetworkIdCanMigrate(PedToNet(target), true)
                            SetBlockingOfNonTemporaryEvents(target, false)

                            if IsEntityDead(target) then
                                SetEntityCoords(target, 0, 0, 0)
                            end
                        end)

                        while carrying do
                            Wait(0)
                            Shared.DisableWeapons()
                        end
                    end))
                end
            end
        else
            carrying = false
        end
    end)

    local hostage = 0
    RegisterCommand('hostage', function()
        if hostage == 0 then
            local target = Shared.ClosestPed(5.0)
            if target ~= 0 and not IsPedAPlayer(target) and not IsEntityDead(target) and GetPedType(target) ~= 28 then
                if IsPedInAnyVehicle(target, true) then
                    return
                end

                
                Citizen.Await(PedAction(target, function()
                    SetNetworkIdCanMigrate(PedToNet(target), false)
                    local netID = PedToNet(target)
                    hostage = target

                    Entity(target).state.hostage = 1
                    SetBlockingOfNonTemporaryEvents(target, true)
                    ClearPedTasksImmediately(target)

                    while hostage ~= 0 and DoesEntityExist(hostage) do
                        Wait(1000)
                        if Shared.CurrentVehicle == 0 then
                            TaskFollowToOffsetOfEntity(target, Shared.Ped, 0.0, -0.25, 0.0, 1.0, -1, 2.0, 1)
                        else
                            if GetVehiclePedIsIn(target, false) ~= Shared.CurrentVehicle then
                                for i=0,5 do
                                    if IsVehicleSeatFree(Shared.CurrentVehicle, i) then
                                        ClearPedTasks(target)
                                        Wait(0)
                                        TaskEnterVehicle(target, Shared.CurrentVehicle, 5000, i, 1.0, 1, 0)
                                        Wait(500)
                                        break
                                    end
                                end
                            end
                        end

                        if IsEntityDead(target) then
                            TriggerEvent('Shared.Notif', 'Your hostage has died')
                            break
                        end
                    end

                    if DoesEntityExist(target) then
                        TaskFollowToOffsetOfEntity(target, Shared.Ped, 0.0, -0.25, 0.0, 1.0, 1, 2.0, 1)
                        SetNetworkIdCanMigrate(netID, true)
                        SetBlockingOfNonTemporaryEvents(target, false)
                        Entity(target).state.hostage = nil
                        ClearPedTasks(target)
                    end
                    hostage = 0
                end))
            end
        else
            hostage = 0
        end
    end)

    RegisterCommand('benchmark', function(source, args)
        local veh = args[1]
        local veh = Shared.SpawnVehicle(veh, vector4(2445.49, 2868.85, 49.09, 316.05))
        SetPedIntoVehicle(Shared.Ped, veh, -1)
        Wait(500)
        local target = vector3(2808.47, 4412.95, 48.97)
        TriggerEvent('AddKey', veh)

        while not GetIsVehicleEngineRunning(veh) do
            Wait(100)
        end


        TaskVehicleDriveToCoordLongrange(Shared.Ped, veh, target, 99999.0, 786603, 1.0)

        local time = GetGameTimer()
        local topSpeed = 0

        while Vdist3(GetEntityCoords(veh), target) >= 5.0 do
            Wait(0)
            local speed = GetEntitySpeed(veh)
            if speed > topSpeed then
                topSpeed = speed
            end

            Shared.DrawText((Shared.TimeSince(time) / 1000)..' seconds', 0.94, 0.1, 0, {255, 255, 255, 255}, 0.35, false, false, false)
        end

        ClearPedTasks(Shared.Ped)
    end)

    local lastVeh
    RegisterCommand('mspeed', function(source, args)
        if lastVeh then lastVeh = DeleteEntity(lastVeh) end
        Wait(500)
        lastVeh = Shared.SpawnVehicle(args[1], GetEntityCoords(Shared.Ped))
        SetPedIntoVehicle(Shared.Ped, lastVeh, -1)
        print(GetVehicleModelEstimatedMaxSpeed(GetHashKey(args[1]))  * 2.236936)
    end)
end