local keys = {}
local garages = {
    ['Legion'] = {
        Name = 'Legion',
        Position = vector3(214.59, -806.19, 30.81),
        SpawnPosition = {
            vector4(216.74, -799.37, 30.77, 70.0),
            vector4(218.49, -794.48, 30.77, 70.0),
            vector4(220.57, -789.42, 30.77, 70.0),
            vector4(222.55, -784.37, 30.77, 70.0),
            vector4(223.94, -779.32, 30.77, 70.0),
            vector4(226.47, -774.39, 30.77, 70.0),
            vector4(228.0, -769.13, 30.77, 70.0),
            vector4(221.93, -804.16, 30.77, 251.0),
            vector4(223.64, -799.26, 30.77, 251.0),
            vector4(225.71, -794.27, 30.77, 251.0),
        }
    },
    ['Alta'] = {
        Name = 'Alta',
        Position = vector3(273.86, -344.65, 44.92),
        SpawnPosition = {
            vector4(278.54, -336.87, 44.92, 70.0),
        }
    },
    ['Little Seoul'] = {
        Name = 'Little Seoul',
        Position = vector3(-693.58, -731.23, 29.35),
        SpawnPosition = {
            vector4(-693.66, -739.06, 29.37, 270.0),
        }
    },
    ['Rockford Hills'] = {
        Name = 'Rockford Hills',
        Position = vector3(-892.95, -150.13, 37.0),
        SpawnPosition = {
            vector4(-892.95, -150.13, 37.0, 300.0),
        }
    },
    ['Cypress Flats'] = {
        Name = 'Cypress Flats',
        Position = vector3(1009.72, -2289.47, 30.51),
        SpawnPosition = {
            vector4(1007.13, -2302.84, 30.51, 270.0),
        }
    },
    ['LSIA'] = {
        Name = 'LSIA',
        Position = vector3(-998.76, -2608.58, 14.13),
        SpawnPosition = {
            vector4(-998.76, -2608.58, 14.13, 60.0),
        }
    },
    ['Sandy'] = {
        Name = 'Sandy',
        Position = vector3(1737.41, 3710.25, 34.14),
        SpawnPosition = {
            vector4(1722.30, 3713.05, 33.7, 18.55),
        }
    },
    ['Paleto'] = {
        Name = 'Paleto',
        Position = vector3(-358.6, 6062.89, 31.5),
        SpawnPosition = {
            vector4(-356.45, 6069.04, 30.98, 46.24),
        }
    },
}

local state = {
    [0] = 'Checked Out',
    [1] = 'Parked'
}

CreateThread(function()
    for k,v in pairs(garages) do
        if k:match('Guild') == nil then
            local blip = AddBlipForCoord(v.Position)
            SetBlipSprite(blip, 50)
            SetBlipAsShortRange(blip, true)
            SetBlipScale(blip, 0.8)
            BeginTextCommandSetBlipName("STRING");
            AddTextComponentString('Garage')
            EndTextCommandSetBlipName(blip)
        end
    end
end)


local lastPress = 0
local dList = {}
local gatherGarage = {}
for k,v in pairs(garages) do
    table.insert(gatherGarage, v.Position)
end

exports('NearGarage', function()
    local pos = GetEntityCoords(Shared.Ped)
    for k,v in pairs(garages) do
        for key,val in pairs(v.SpawnPosition) do
            if Vdist3(pos, val.xyz) <= 5.0 then
                return true
            end
        end
    end
end)

Citizen.CreateThread(function()
    --RegisterProximityMenu('Garage', {Name = 'Garage', pos = gatherGarage, Event = 'Garage:Valet', range = 30.0})
end)

AddEventHandler('AddKey', function(veh)
    if Entity(veh).state.vin == nil then
        SetEntityAsMissionEntity(veh, true)
    end
    TriggerServerEvent('AddKey', VehToNet(veh), GetVehicleNumberPlateText(veh), GetVehicleData(veh))
end)

RegisterNetEvent('ParkVehicle')
AddEventHandler('ParkVehicle', function(netID)
    if NetworkDoesEntityExistWithNetworkId(netID) then
        local veh = NetToVeh(netID)
        if Shared.CurrentVehicle == veh then
            TaskLeaveVehicle(PlayerPedId(), veh, 0)
        end
    end
end)

RegisterNetEvent('Recover')
AddEventHandler('Recover', function(data)
    local veh = Shared.SpawnVehicle(data.Model, vector4(data.Position, data.Heading))

    SetVehicleData(veh, json.encode(data.Data), data.Plate)
    SetOwned(veh)
    if GetVehicleClass(veh) ~= 8 and GetVehicleClass(veh) ~= 13 then SetVehicleDoorsLocked(veh, 2) end
    TriggerEvent('AddKey', veh)
end)

RegisterNetEvent('Keys')
AddEventHandler('Keys', function(nK)
    keys = nK
end)

RegisterKeyMapping('+Lock', '[Vehicle] Lock', 'keyboard', 'L')
RegisterCommand('-Lock', function() end)
RegisterCommand('+Lock', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh ~= 0 then
        if GetPedInVehicleSeat(veh, -1) == Shared.Ped then
            LockVehicle(veh)
        end
    else
        local closest = 0
        local dist = 100
        local pos = GetEntityCoords(PlayerPedId())
        for k, v in pairs(GetGamePool('CVehicle')) do
            if Vdist4(pos, GetEntityCoords(v)) < dist then
                if keys[GetVehicleNumberPlateText(v)] ~= nil then
                    dist =  Vdist4(pos, GetEntityCoords(v))
                    closest = v
                end
            end
        end

        if closest ~= 0 then
            if Entity(closest).state.fake then return end
            LockVehicle(closest)
        end
    end
end)

local blacklist = {
    [8] = 'Motorcycle',
    [13] = 'Cycle',
    [14] = 'Boat'
}
function LockVehicle(vCar)

    if not NetworkGetEntityIsNetworked(vCar) then
        TriggerEvent('Common.Notif', 'Sadly only you can see this vehicle')
        return
    end

    local class = GetVehicleClass(vCar)
    if blacklist[class] == nil and GetVehicleNumberOfWheels(vCar) > 2 then
        local lockstatus = GetVehicleDoorLockStatus(vCar)

        if lockstatus ~= 2 and DoesEntityExist(vCar) then
            TriggerServerEvent('SetVehicleLock', VehToNet(vCar), true)
            if Shared.CurrentVehicle == 0 then
                TriggerServerEvent('3DSound', VehToNet(vCar), 'lock.wav', 0.2, 10.0)
            end
            if not GetIsVehicleEngineRunning(Shared.CurrentVehicle) or Shared.CurrentVehicle == 0 then
                TriggerEvent('Shared.Notif', 'Vehicle Locked')
            end
	    elseif lockstatus == 2 and DoesEntityExist(vCar) then
            TriggerServerEvent('SetVehicleLock', VehToNet(vCar), false)
            if Shared.CurrentVehicle == 0 then
                TriggerServerEvent('3DSound', VehToNet(vCar), 'unlock.wav', 0.2, 10.0)
            end
            if not GetIsVehicleEngineRunning(Shared.CurrentVehicle) or Shared.CurrentVehicle == 0 then
                TriggerEvent('Shared.Notif', 'Vehicle Unlocked')
            end
        end
        local ped = PlayerPedId()
        if not IsPedSittingInAnyVehicle(ped) then
            RequestAnimDict('anim@mp_player_intmenu@key_fob@')
            while not HasAnimDictLoaded('anim@mp_player_intmenu@key_fob@') do
                Wait(0)
            end
            local ped = PlayerPedId()
            TaskPlayAnim(ped, "anim@mp_player_intmenu@key_fob@", "fob_click", 4.0, 4.0, 1000, 49, 1.0, 0, 0, 0)
            SetVehicleLights(vCar, 2)
            Wait(500)
            SetVehicleLights(vCar, 0)
        end
    end
end

RegisterNetEvent('SetVehicleLock')
AddEventHandler('SetVehicleLock', function(vehId, doLock)
    if NetworkDoesNetworkIdExist(vehId) then
        local vCar = NetToVeh(vehId)
        if NetworkHasControlOfEntity(vCar) then
            if doLock and DoesEntityExist(vCar) then
                SetVehicleDoorsLocked(vCar, 2)
                SetVehicleAlarm(vCar, true)
            elseif (not doLock) and DoesEntityExist(vCar) then
                SetVehicleDoorsLocked(vCar, 0)
                SetVehicleAlarm(vCar, false)
            end
        end
    end
end)

function HasKey(veh)
    return keys[GetVehicleNumberPlateText(veh)] ~= nil
end

exports('HasKey', HasKey)

RegisterNetEvent('Garage:Fetch')
AddEventHandler('Garage:Fetch', function(vehs)
    vehList = vehs
end)

local _a
Menu.CreateMenu('Garage', 'Garage')
AddEventHandler('Garage:Valet', function(garageID, gInfo)
    if not Menu.CurrentMenu then
        vehList = nil
        local ped = PlayerPedId()
        for k,v in pairs(garages) do
            local v = v
            local k = k
            if gInfo then
                v = gInfo
                k = garageID
                _a = gInfo
            end

            local spot
            local cDist = 999
            for key,val in pairs(v.SpawnPosition) do
                local dist = Vdist3(GetEntityCoords(Shared.Ped), val.xyz)
                if dist <= 5.0 and dist < cDist then
                    spot = key
                    cDist = dist
                end
            end

            if not spot then goto continue end
            if Vdist3(GetEntityCoords(ped), v.SpawnPosition[spot].xyz) <= 5.0 then
                if not IsPedSittingInAnyVehicle(ped) then
                    Menu.OpenMenu('Garage')
                    Menu.Menus['Garage'].SubTitle = v.Name
                    Menu.OpenMenu('Garage')
                    TriggerServerEvent('Garage:Fetch', k)
                    Citizen.CreateThread(function()
                        local option = 0
                        local vehs = {}
                        while Menu.CurrentMenu == 'Garage' do
                            Wait(0)
                            while vehList == nil do
                                Wait(0)
                            end

                            if Vdist3(GetEntityCoords(ped), v.SpawnPosition[spot].xyz) > 7.0 then
                                Menu.CloseMenu()
                                break
                            end

                            if #vehList == 0 then
                                TriggerEvent('Shared.Notif', 'You have no vehicles parked here', 5000)
                                Menu.CloseMenu()
                                return
                            end

                            for key,value in pairs(vehList) do
                                local name = GetLabelText(GetDisplayNameFromVehicleModel(value.model))
                                if value.showasmodel ~= nil then
                                    name = value.showasmodel
                                end
                                if Menu.Button(name, state[value.parked]) then
                                    if value.parked == 1 then
                                        for _, pos in pairs(v.SpawnPosition) do
                                            local _n =  CheckPosition(pos)
                                            if _n == 0 or (_n ~= 0 and not IsEntityAMissionEntity(_n)) then
                                                if type(pos) == 'vector3' then pos = {x = pos.x, y = pos.y, z = pos.z, w = GetEntityHeading(Shared.Ped)} end
                                                TriggerServerEvent('Garage:PullVehicle', value.plate, v.SpawnPosition[spot], k)
                                                Menu.CloseMenu()
                                                break
                                            end
                                        end
                                    end
                                end
                            end

                            if vehList[Menu.ActiveOption] then
                                Menu.Extra({
                                    {'Plate:', vehList[Menu.ActiveOption].plate},
                                })
                            end
                            Menu.Display()

                            if option ~= Menu.ActiveOption then
                                Citizen.CreateThreadNow(function()
                                    option = Menu.ActiveOption
                                    local pOption = Menu.ActiveOption
                                    vehs[pOption] = Shared.SpawnVehicle(vehList[pOption].model, v.SpawnPosition[spot], true)
                                    local nVeh = vehs[pOption]
                                    while not DoesEntityExist(vehs[pOption]) do
                                        Wait(0)
                                    end
                                    SetVehicleColours(vehs[pOption], 0, 0)
                                    SetVehicleExtraColours(vehs[pOption], 0, 0)
                                    FreezeEntityPosition(vehs[pOption], true)
                                    SetEntityCollision(vehs[pOption], false, false)
                                    SetVehicleOnGroundProperly(vehs[pOption])
                                    SetEntityAlpha(vehs[pOption], 150, 1)
                                    SetVehicleData(vehs[pOption], vehList[pOption].data, vehList[pOption].plate)
                                
                                    while Menu.ActiveOption == pOption do
                                        Wait(0)
                                    end

                                    while not DoesEntityExist(nVeh) do
                                        Wait(100)
                                    end
            
                                    SetEntityAsNoLongerNeeded(nVeh)
                                    SetEntityCoords(nVeh, 0.0, 0.0, 0.0)
                                    DeleteEntity(nVeh)
                                    while DoesEntityExist(nVeh) do
                                        DeleteEntity(nVeh)
                                        Wait(0)
                                    end
                                    nVeh = nil
                                    vehs[pOption] = nil
                                end)
                            end
                        end

                        for k,v in pairs(vehs) do
                            DeleteEntity(v)
                        end
                    end)
                else
                    local veh = GetVehiclePedIsIn(ped, false)
                    if GetPedInVehicleSeat(veh, -1) == ped then
                        local plate = GetVehicleNumberPlateText(veh)
                        local model = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
                        local bodyH = GetVehicleBodyHealth(veh)
                        local engineH = GetVehicleEngineHealth(veh)
                        if GetGameTimer() > lastPress then
                            TriggerServerEvent('Garage:Park', plate, model, VehToNet(veh), k, bodyH, engineH, k == 'CrimGarage' and json.encode(GetVehicleData(veh)) or '')
                        end
                    end
                end
                break
            end

            ::continue::
        end
    end
end)

RegisterNetEvent('Garage:Spawn')
AddEventHandler('Garage:Spawn', function(handle, data, v)

    while not NetworkDoesEntityExistWithNetworkId(handle) do
        Wait(100)
    end

    while not DoesEntityExist(NetworkGetEntityFromNetworkId(handle)) do
        Wait(100)
    end

    local veh = NetworkGetEntityFromNetworkId(handle)
    Shared.GetEntityControl(veh)
    SetEntityCoords(veh, v.x, v.y, v.z)
    SetEntityHeading(veh, (v.w or GetEntityHeading(PlayerPedId())) + 0.001)
    if _a ~= nil then
        SetPedIntoVehicle(Shared.Ped, veh, -1)
        _a = nil
    end

    SetVehicleFuelLevel(veh, json.decode(data.flags).Fuel)
    Shared.GetEntityControl(veh)

    while GetVehicleNumberPlateText(veh) ~= data.plate do
        Shared.GetEntityControl(veh)
        SetVehicleData(veh, data.data, data.plate)
        Wait(100)
    end

    SetVehicleData(veh, data.data, data.plate)
    SetOwned(veh)
    if GetVehicleClass(veh) ~= 8 and GetVehicleClass(veh) ~= 13 then SetVehicleDoorsLocked(veh, 2) end
    TriggerEvent('AddKey', veh)
    Menu.CloseMenu()
    showMe = true
end)

RegisterNetEvent('GiveKey')
AddEventHandler('GiveKey', function(veh)
    local veh = NetworkGetEntityFromNetworkId(veh)
    TriggerEvent('AddKey', veh)
    TriggerEvent('Shared.Notif', 'You have received keys to a vehicle')
end)

RegisterNetEvent('Vehicle.Buy')
AddEventHandler('Vehicle.Buy', function(price, model, src)
    if exports['geo-interface']:PhoneConfirm('Would you like to buy this '..GetLabelText(GetDisplayNameFromVehicleModel(model))..' for $'..comma_value(GetPrice(price)), 30) then
        TriggerServerEvent('Vehicle.Buy', src, GetLabelText(GetDisplayNameFromVehicleModel(model)))
    end
end)

function IsParked(bool, garage)
    if bool == 1 then
        return 'parked at '..garage
    else
        return 'out somewhere'
    end
end

function CheckPosition(epos)
    local rayHandle = StartShapeTestCapsule(epos.x, epos.y, epos.z+5.0, epos.x, epos.y, epos.z-5.0, 3.5, 10, PlayerPedId(), 2)
    local _, _, _, _, vehicle = GetRaycastResult( rayHandle )
    return vehicle
end

RegisterCommand('removeplate', function(source, args)
    TriggerServerEvent('RemovePlate', VehToNet(Shared.EntityInFront(5.0)))
end)

RegisterCommand('givekey', function()
    local player = GetClosestPlayer(2.0)
    local veh = GetVehiclePedIsIn(Shared.Ped, true)
    if player and DoesEntityExist(veh) and HasKey(veh) and Vdist3(GetEntityCoords(veh), GetEntityCoords(Shared.Ped)) <= 10.0 then
        TriggerServerEvent('GiveKey', GetPlayerServerId(player), VehToNet(veh))
        TriggerEvent('Shared.Notif', 'You have given keys to a vehicle')
    end
end)