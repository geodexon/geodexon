local consumption = {
    [VehicleClass.Compact] = 240,
    [VehicleClass.Sedan] = 240,
    [VehicleClass.SUV] = 180,
    [VehicleClass.Coupe] = 200,
    [VehicleClass.Muscle] = 160,
    [VehicleClass.SportsClassic] = 140,
    [VehicleClass.Sports] = 150,
    [VehicleClass.Super] = 100,
    [VehicleClass.Motorcycle] = 200,
    [VehicleClass.OffRoad] = 140,
    [VehicleClass.Industrial] = 300,
    [VehicleClass.Utility] = 150,
    [VehicleClass.Van] = 150,
    [VehicleClass.Cycle] = 999999999999999999999999999999,
    [VehicleClass.Boat] = 120,
    [VehicleClass.Helicopter] = 36,
    [VehicleClass.Plane] = 60,
    [VehicleClass.Service] = 160,
    [VehicleClass.Emergency] = 240,
    [VehicleClass.Military] = 60,
    [VehicleClass.Commcerical] = 200,
    [VehicleClass.Trains] = 99999999999999999999
}
local gasStations = json.decode(LoadResourceFile(GetCurrentResourceName(), 'Fuel/GasStations.json')).GasStations
local pumps = {}

CreateThread(function()
    for k,v in pairs(gasStations) do
        for key,val in pairs(v.pumps) do
            table.insert(pumps, vec(val.X, val.Y, val.Z))
        end
    end

    --RegisterProximityMenu('RefuelVehicle', {Name = 'Refuel Vehicle', pos = pumps, Event = 'Fuel:Refill', range = 20.0})
end)

local refuelling = false
AddEventHandler('Fuel:Refill', function()
    if refuelling then
        return
    end

    local veh = Shared.EntityInFront(2.0)
    if veh ~= 0 then

        if GetIsVehicleEngineRunning(veh) then
            Wait(500)
            AddExplosion(GetEntityCoords(veh), 9, 10.0, 1, 0, 10.0)
            return
        end

        refuelling = true
        CreateThread(function()
            while refuelling do
                if not IsEntityPlayingAnim(Shared.Ped, 'weapon@w_sp_jerrycan', 'fire', 1) then
                    TaskPlayAnim(Shared.Ped, 'weapon@w_sp_jerrycan', 'fire', 1.0, 1.0, -1, 1, 1.0, 0, 0 ,0)
                end
                Wait(100)
            end
        end)

        local fuel = GetVehicleFuelLevel(veh)
        LoadAnim('weapon@w_sp_jerrycan')
        TaskPlayAnim(Shared.Ped, 'weapon@w_sp_jerrycan', 'fire', 1.0, 1.0, -1, 1, 1.0, 0, 0 ,0)
        if exports['geo-shared']:ProgressSync('Refuelling', 5000 + (10000 * (math.abs(fuel - 100) / 100))) then
            TriggerServerEvent('SetFuel', VehToNet(veh), 100)
        end
        StopAnimTask(Shared.Ped, 'weapon@w_sp_jerrycan', 'fire', 1.0)
        refuelling = false
    end
end)

AddEventHandler('enteredVehicle', function(veh)
    if Entity(veh).state.fuel == nil then
        local num = math.random(60, 100) + 0.0
        SetVehicleFuelLevel(veh, num)
        TriggerServerEvent('SetFuel', VehToNet(veh), num)
    end

    Wait(1000)
    while Shared.CurrentVehicle == veh do
        TickFuel()
        Wait(1000)
    end
end)

local cw
AddEventHandler('WeaponSwitch', function(wep, currWep)
    cw = wep
    if wep == 'WEAPON_PETROLCAN' then
        AddTextEntry('vehRefuel', '~INPUT_AIM~ To Refuel Vehicle')
        while cw == 'WEAPON_PETROLCAN' do
            Wait(0)
            local veh = Shared.EntityInFront(2.0)
            if veh ~= 0 then
                ShowFloatingHelp('vehRefuel', GetEntityCoords(veh) + vec(0, 0 , 0.5), 2)
                DisableControlAction(0, 25, true)
                if IsDisabledControlJustPressed(0, 25) and (Entity(veh).state.fuel or GetVehicleFuelLevel(veh)) < 100  then
                    local time = GetGameTimer()
                    local fuel = Entity(veh).state.fuel or GetVehicleFuelLevel(veh)
                    LoadAnim('weapon@w_sp_jerrycan')
                    TaskPlayAnim(Shared.Ped, 'weapon@w_sp_jerrycan', 'fire', 99.0, 99.0, -1, 1, 1.0, 0, 0 ,0)
                    while IsDisabledControlPressed(0, 25) do
                        if fuel >= 100 or cw ~= wep or Shared.EntityInFront(2.0) == 0 then
                            break
                        end

                        if Shared.TimeSince(time) >= 1000 then
                            TriggerServerEvent('SetFuel', VehToNet(veh), (Entity(veh).state.fuel or GetVehicleFuelLevel(veh)) + 2)
                            time = GetGameTimer()
                            fuel = (Entity(veh).state.fuel or GetVehicleFuelLevel(veh)) + 2
                            if not IsEntityPlayingAnim(Shared.Ped, 'weapon@w_sp_jerrycan', 'fire', 1) then
                                TaskPlayAnim(Shared.Ped, 'weapon@w_sp_jerrycan', 'fire', 99.0, 99.0, -1, 1, 1.0, 0, 0 ,0)
                            end

                            SetPedAmmo(Shared.Ped, GetHashKey(wep), GetAmmoInPedWeapon(Shared.Ped, GetHashKey(wep)) - math.floor(45 * (consumption[GetVehicleClass(veh)] / 100)))
                            TriggerServerEvent('UpdateAmmo', GetAmmoInPedWeapon(Shared.Ped, GetHashKey(wep)), currWep.ID)
                        end

                        Shared.WorldText('Fuel Level: '..round(fuel, 2), GetEntityCoords(veh) + vec(0, 0 , 0.5), 2)
                        Wait(0)
                    end
                    Wait(100)
                    StopAnimTask(Shared.Ped, 'weapon@w_sp_jerrycan', 'fire', 1.0)
                end
            else
                Wait(500)
            end
        end
    end
end)

driving = true
function TickFuel()
    local veh = Shared.CurrentVehicle

    if GetPedInVehicleSeat(veh, -1) ~= PlayerPedId() then
        return
    end

    if GetIsVehicleEngineRunning(veh) then
        local class = GetVehicleClass(veh)
        local currentFuel = Entity(veh).state.fuel or 100
        local rpm = GetVehicleCurrentRpm(veh)
        if rpm < 0.21 then
            rpm = 0.01
        end

        local mult = 1 / (consumption[class] * 60)
        local rpmMult = mult * rpm
        currentFuel = currentFuel - ((mult + rpmMult) * 100)
        Entity(veh).state.fuel = currentFuel
        SetVehicleFuelLevel(veh, currentFuel)
    end

    if GetPedInVehicleSeat(veh, -1) == PlayerPedId() then
        driving = true
    else
        if driving then
            TriggerServerEvent('SetFuel', VehToNet(veh), GetVehicleFuelLevel(veh))
            driving = false
        end
    end
end

AddEventHandler('leftVehicle', function(veh)
    TriggerServerEvent('SetFuel', VehToNet(veh), GetVehicleFuelLevel(veh))
end)

CreateThread(function()
    while true do
        Wait(500)
        for i=1,150 do
            RemoveAllPickupsOfType(i)
        end
    end
end)

exports('AtPump', function()
    local pos = GetEntityCoords(Shared.Ped)
    for k,v in pairs(pumps) do
        if Vdist4(pos, v) <= 20.0 then
            return true
        end
    end
end)