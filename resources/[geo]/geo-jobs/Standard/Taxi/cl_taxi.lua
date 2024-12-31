local myTaxi = 0
local activeRide = false

local dropOffs = {
    vector3(263.14, -380.15, 44.66),
    vector3(428.27, -960.23, 29.11),
    vector3(158.2, -1037.58, 29.18),
    vector3(-312.59, -1029.93, 30.39),
    vector3(-289.25, -1338.01, 31.17),
    vector3(-102.38, -1591.44, 31.45),
    vector3(32.55, -1611.66, 29.23),
    vector3(442.35, -1865.04, 27.47),
    vector3(807.96, -1390.45, 26.81),
    vector3(839.22, -1019.36, 27.44),
    vector3(324.29, -214.61, 54.09),
    vector3(399.28, 219.19, 102.9),
    vector3(36.96, 287.47, 109.7),
    vector3(-256.53, 293.67, 91.65),
    vector3(-736.24, -133.96, 37.27),
    vector3(-516.45, -605.7, 30.3),
    vector3(2553.58, 2623.35, 37.95),
    vector3(1992.33, 3057.35, 47.06),
    vector3(1179.9, 2691.0, 37.82),
    vector3(591.13, 2739.01, 41.96)
}

AddCircleZone(vector3(896.03, -179.56, 74.7), 50.0, {
    name="taxidepot",
    useZ=false,
    --debugPoly=true
})

local inside = false
AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'taxidepot' then
        inside = inZone
        if inZone then
            local ped = exports['geo-interface']:InterfacePed({
                model = 'a_m_y_clubcust_02',
                position = vector4(895.22, -179.35, 74.7, 236.67),
                title = 'Taxi',
                event = 'Taxi.Menu'
            })

            while inside do
                Wait(500)
            end

            exports['geo-interface']:RemovePed(ped)
        end
    end
end)

AddEventHandler('Taxi.Begin', function()
    TriggerServerEvent('Duty', 'Taxi')
    myTaxi = Task.Run('Taxi.Start')
    if myTaxi ~= 0 then
        TriggerEvent('AddKey', NetworkGetEntityFromNetworkId(myTaxi))
    end
end)

AddEventHandler('Taxi.Stop', function()
    TriggerServerEvent('Duty', 'Taxi')
    myTaxi = Task.Run('Taxi.End')
end)

AddEventHandler('Taxi.Menu', function()

    local menu = {
        {title = 'Clock In', hidden = MyCharacter.Duty ~= nil, event = 'Taxi.Begin'},
        {title = 'Clock Out', hidden = MyCharacter.Duty == nil, event = 'Taxi.Stop'},
    }

    RunMenu(menu)
end)

AddEventHandler('enteredVehicle', function(veh)
    if MyCharacter.Duty == 'Taxi' and GetEntityModel(veh) == GetHashKey('taxi') then
        Wait(100)
        while Shared.CurrentVehicle == veh do
            Taxi(veh)
            Wait(30000)
        end
    end
end)

local taxiLocation = AddBlipForCoord(895.54, -179.15, 73.78)
SetBlipSprite(taxiLocation, 198)
SetBlipScale(taxiLocation, 0.8)
SetBlipColour(taxiLocation, 5)
SetBlipAsShortRange(taxiLocation, true)

local thread = false
function Taxi(veh)

    if activeRide or thread or GetPedInVehicleSeat(veh, -1) ~= Shared.Ped then return end

    for _, ped in pairs(GetGamePool('CPed')) do
        if Random(100) > 90 
            and Vdist3(GetEntityCoords(ped), GetEntityCoords(Shared.Ped)) < 200.0 
            and GetVehiclePedIsIn(ped, false) == 0
            and GetPedType(ped) ~= 28
        then
            Citizen.Await(PedAction(ped, function()
                thread = true
                local collissionCount = 0
                local blip = AddBlipForEntity(ped)
                SetBlipSprite(blip, 480)
                SetBlipScale(blip, 1.25)
                SetBlipFlashes(blip, true)

                SetEntityAsMissionEntity(ped, true)
                while thread do
                    Wait(250)

                    if Vdist3(GetEntityCoords(ped), GetEntityCoords(Shared.Ped)) >= 250.0 
                        or MyCharacter.Duty ~= 'Taxi' 
                        or Shared.CurrentVehicle == 0
                        or IsEntityDead(ped)
                    then
                        RemoveBlip(blip)
                        return
                    end

                    if Vdist3(GetEntityCoords(ped), GetEntityCoords(Shared.Ped)) <= 20.0 and GetEntitySpeed(veh) <= 2.0 then
                        RemoveBlip(blip)
                        break
                    end
                end

                activeRide = true

                while GetVehiclePedIsIn(ped, false) ~= veh do
                    TaskEnterVehicle(ped, veh, -1, 1, 1.0, 1, 0)
                    Wait(2000)
                end

                local destination = dropOffs[Random(#dropOffs)]
                local atDestination = false
                local blip = AddBlipForCoord(destination)
                SetBlipSprite(blip, 198)
                SetBlipScale(blip, 1.25)
                SetBlipRoute(blip, true)
                
                while not atDestination do
                    Wait(0)

                    if Vdist3(GetEntityCoords(ped), GetEntityCoords(Shared.Ped)) >= 100.0 
                        or MyCharacter.Duty ~= 'Taxi' 
                        or IsEntityDead(ped)
                    then
                        RemoveBlip(blip)
                        return
                    end

                    if HasEntityCollidedWithAnything(veh) then
                        Wait(250)

                        collissionCount = collissionCount + 1
                        if collissionCount == 15 then
                            TriggerEvent('Shared.Notif', 'You passenger is starting to get scared')
                        end

                        if collissionCount >= 30 then
                            TriggerEvent('Shared.Notif', 'You have scared off your passenger')
                            TaskLeaveVehicle(ped, veh, 4160)
                            RemoveBlip(blip)
                            return
                        end
                    end

                    if Vdist3(destination, GetEntityCoords(Shared.Ped)) <= 5.0 and GetEntitySpeed(veh) <= 2.0 then
                        break
                    end
                end

                Wait(500)

                RemoveBlip(blip)
                SetEntityAsNoLongerNeeded(ped)
                TaskLeaveVehicle(ped, veh, 1)
                TriggerServerEvent('Taxi.Pay')
            end))
            thread = false
            activeRide = false
            break
        end
    end
end