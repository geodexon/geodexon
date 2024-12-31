local blip
local model = 1224306523
local jobState = 'none'
local startPed
local targetClass

local textList = {
    ['none'] = 'Get Job',
    ['phase_1'] = 'Quit Job'
}

CreateThread(function()
    Wait(1000)
    AddCircleZone(vector3(-109.91, -2705.62, 5.81), 39.650000000001, {
        name="chop.start",
        useZ=false,
    })

    while true do
        local time = GetClockHours()
        if MyCharacter then
            if (time > 19 or time < 7) and exports['geo-rpg']:QuestStatus('chop.begin').complete == 1 then
                if not blip then
                    blip = AddBlipForCoord(-109.58, -2705.77, 6.01) 
                    SetBlipSprite(blip, 663)
                    SetBlipColour(blip, 14)
                    SetBlipAsShortRange(blip, true)
                    SetBlipScale(blip, 0.8)
                    BeginTextCommandSetBlipName("STRING");
                    AddTextComponentString('Chop it Up')
                    EndTextCommandSetBlipName(blip)
                end
            else
                if blip then
                    blip = RemoveBlip(blip)
                end
            end
        end
        Wait(60000)
    end
end)

AddEventHandler('Chop.none', function()
    jobState = Task.Run('Chop.GetJob') or 'none'
    exports['geo-interface']:SetPed(startPed, textList[jobState], 'Chop.'..jobState)
end)

AddEventHandler('Chop.phase_1', function()
    jobState = Task.Run('Chop.Quit') or 'none'
    exports['geo-interface']:SetPed(startPed, textList[jobState], 'Chop.'..jobState)
end)

RegisterNetEvent('Chop.Start')
AddEventHandler('Chop.Start', function(class)
    TriggerEvent('Shared.Notif', 'Bring us a vehicle of the type: '..GetLabelText('VEH_CLASS_'..class), 5000)
    targetClass = class
end)

local atTheft = false
AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'chop.start' then
        atTheft = inZone
        if atTheft and exports['geo-rpg']:QuestStatus('chop.begin').complete == 1 then
            startPed = Shared.SpawnPed(model, vector4(-109.7, -2705.27, 6.01, 128.72), true)
            exports['geo-interface']:SetPed(startPed, textList[jobState], 'Chop.'..jobState)
            SetEntityCoords(startPed, GetEntityCoords(startPed) - vec(0.0, 0.0, GetEntityHeightAboveGround(startPed)))
            FreezeEntityPosition(startPed, true)
            SetEntityInvincible(startPed, true)
            SetBlockingOfNonTemporaryEvents(startPed, true)

            while atTheft do
                Wait(500)
            end

            exports['geo-interface']:SetPed(startPed, nil)
            startPed = DeleteEntity(startPed)
        end
    end
end)

RegisterNetEvent('Quest.Done', function(questID)
    if questID == 'chop.begin' then
        TriggerEvent('Poly.Zone', 'chop.start', true)
    end
end)

AddEventHandler('enteredVehicle', function(veh)
    if jobState == 'phase_1' and GetVehicleClass(veh) == targetClass then
        TriggerEvent('Shared.Notif', 'This is what we want, bring it back to the start point', 5000)

        Wait(100)
        local _int
        local min, max = GetModelDimensions(GetEntityModel(veh))
        while Shared.CurrentVehicle == veh do
            if atTheft then
                _int = Shared.Interact('[E] Process Vehicle') or _int
                if IsControlJustPressed(0, 38) then
                    local vehPos = GetEntityCoords(veh)
                    local done = false
                    FreezeEntityPosition(veh, true)
                    for i=1,4 do
                        local pos
                        if i == 1 then
                            pos = GetOffsetFromEntityInWorldCoords(veh, 0.0, max.y, 0.0)
                        elseif i == 2 then
                            pos = GetOffsetFromEntityInWorldCoords(veh, max.x, 0.0, 0.0)
                        elseif i == 3 then
                            pos = GetOffsetFromEntityInWorldCoords(veh, 0.0, min.y, 0.0)
                        elseif i == 4 then
                            pos = GetOffsetFromEntityInWorldCoords(veh, min.x, 0.0, 0.0)
                        end


                        local ped = Shared.SpawnPed(model, vector3(-102.24, -2707.85, 5.98))
                        SetBlockingOfNonTemporaryEvents(ped, true)
                        ClearPedTasks(ped)
                        TaskGoToCoordAnyMeans(ped, pos, 1.30, 0, 0, 786603, 1.0)
                        CreateThread(function()
                            while true do
                                Wait(250)
                                if Vdist3(GetEntityCoords(ped), pos) <= 1.0 then
                                    break
                                end
                            end

                            if i == 1 then
                                for n = 0, 5 do
                                    CreateThread(function()
                                        Wait(Random(5000, 10000))
                                        Shared.GetEntityControl(veh)
                                        SetVehicleDoorBroken(veh, n)
                                    end)
                                end

                                for n = 0, 3 do
                                    CreateThread(function()
                                        Wait(Random(5000, 10000))
                                        Shared.GetEntityControl(veh)
                                        BreakOffVehicleWheel(veh, n, true, false, true, false)
                                    end)
                                end
                            end

                            Shared.GetEntityControl(ped)
                            TaskTurnPedToFaceEntity(ped, veh, 1000)
                            Wait(1000)
                            TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_WELDING', 1, 1)

                            while not done or Vdist3(GetEntityCoords(Shared.Ped), vehPos) >= 100.0 do
                                Wait(1000)
                            end

                            Wait(500)
                            Shared.GetEntityControl(ped)
                            ClearPedTasks(ped)
                            SetEntityAsNoLongerNeeded(ped)
                            TaskWanderInArea(ped, vector3(-102.24, -2707.85, 5.98), 500.0, 100.0, 1.0)
                        end)
                    end
                   
                    if exports['geo-shared']:ProgressSync('Processing Vehicle', 30000) then
                        if GetPedInVehicleSeat(veh, -1) == Shared.Ped or (GetPedInVehicleSeat(veh, -1) == 0 and Vdist3(GetEntityCoords(veh), vehPos) <= 5.0) then
                            DoScreenFadeOut(500)
                            Wait(500)
                            jobState = Task.Run('Chop.Deliver', VehToNet(veh), GetVehicleClass(veh))
                            DoScreenFadeIn(500)
                            exports['geo-interface']:SetPed(startPed, textList[jobState], 'Chop.'..jobState)
                        end
                    end
                    done = true
                end
            else
                Wait(500)
            end
            Wait(0)
        end
        if _int then _int.stop() end
    end
end)