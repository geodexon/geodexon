local blips = {}
local patrols = {}

RegisterNetEvent('Patrol.Start', function(pVehicle, pPed)
    while not NetworkDoesEntityExistWithNetworkId(pVehicle) do
        Wait(500)
    end

    local veh = NetworkGetEntityFromNetworkId(pVehicle)
    local ped = NetworkGetEntityFromNetworkId(pPed)
    Wait(500)

    blips[pVehicle] = AddBlipForEntity(veh)
    SetVehicleOnGroundProperly(veh)
    SetVehicleEngineOn(veh, true, false, false)
    TaskVehicleDriveWander(ped, veh, 10.0, 786468)
    SetPedKeepTask(ped, true)

    while DoesEntityExist(veh) do
        Wait(500)
    end
end)

Menu.CreateMenu('Patrol', 'Patrol')
RegisterCommand('patrol', function()
    TriggerServerEvent('Patrols.Get')
    Menu.OpenMenu('Patrol')
    local id = 1
    while Menu.CurrentMenu == 'Patrol' do
        Wait(0)
        if Menu.Button('Dispatch Patrol Unit') then
            TriggerServerEvent('Patrol.Dispatch')
        end

        for k,v in pairs(patrols) do
            if Menu.ComboBox('Patrol #'..k, {'Summon', 'Kill Me', 'Escort', 'Patrol'}, id, function(current)
                if current ~= id then id = current end
            end) then
                TriggerServerEvent('Patrol.Request', k, id)
            end
        end

        Menu.Display()
    end
end)

RegisterNetEvent('Patrols.Send', function(pPatrol)
    patrols = pPatrol
end)

RegisterNetEvent('Patrol.Request', function(pVehicle)
    local veh = NetworkGetEntityFromNetworkId(pVehicle)
    local ped = GetPedInVehicleSeat(veh, -1)
    TaskVehicleDriveToCoordLongrange(ped, veh, GetEntityCoords(PlayerPedId()), 5.0, 786603, 1.0)
end)

RegisterNetEvent('Patrol.Kill', function(pVehicle, pPed, pTarget)
    local veh = NetworkGetEntityFromNetworkId(pVehicle)
    local ped = NetworkGetEntityFromNetworkId(pPed)
    local target = NetworkGetEntityFromNetworkId(pTarget)

    GiveWeaponToPed(ped, `WEAPON_PISTOL`, 90, false, true)
    SetCurrentPedWeapon(ped, `WEAPON_PISTOL`, true)

    TaskCombatPed(ped, target, 0 ,16)
end)

RegisterNetEvent('Patrol.Escort', function(pVehicle, pPed, pTarget)
    local veh = NetworkGetEntityFromNetworkId(pVehicle)
    local ped = NetworkGetEntityFromNetworkId(pPed)
    local target = NetworkGetEntityFromNetworkId(pTarget)

    GiveWeaponToPed(ped, `WEAPON_PISTOL`, 90, false, true)
    SetCurrentPedWeapon(ped, `WEAPON_PISTOL`, true)

    TaskVehicleEscort(ped, veh, GetVehiclePedIsIn(target), -1, 10.0, 2883621, 1.0, 1, 1.0)
end)

RegisterNetEvent('Patrol.Patrol', function(pVehicle, pPed)
    local veh = NetworkGetEntityFromNetworkId(pVehicle)
    local ped = NetworkGetEntityFromNetworkId(pPed)

    SetVehicleSiren(veh, false)
    TaskVehicleDriveWander(ped, veh, 10.0, 786468)
    SetPedKeepTask(ped, true)
end)