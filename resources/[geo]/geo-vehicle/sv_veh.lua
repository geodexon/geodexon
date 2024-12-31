RegisterNetEvent('Vehicle.ToggleDoor')
AddEventHandler('Vehicle.ToggleDoor', function(ent, door)
    TriggerClientEvent('Vehicle.ToggleDoor', -1, ent, door)
end)

RegisterNetEvent('Vehicle.ToggleWindow')
AddEventHandler('Vehicle.ToggleWindow', function(ent, door)
    TriggerClientEvent('Vehicle.ToggleWindow', -1, ent, door)
end)

RegisterNetEvent('TurnSignal')
AddEventHandler('TurnSignal', function(net, direction)
    TriggerClientEvent('TurnSignal', -1, net, direction)
end)

RegisterNetEvent('Vehicle.BreakDoor')
AddEventHandler('Vehicle.BreakDoor', function(netID, door)
    SetVehicleDoorBroken(NetworkGetEntityFromNetworkId(netID), door, false)
end)

local modelBlacklist = {
    [GetHashKey('police')] = true,
    [GetHashKey('police2')] = true,
    [GetHashKey('police3')] = true,
    [GetHashKey('police4')] = true,
    [GetHashKey('police5')] = true,
    [GetHashKey('policeb')] = true,
    [GetHashKey('sheriff')] = true,
    [GetHashKey('sheriff2')] = true,
    [GetHashKey('sheriff3')] = true,
    [GetHashKey('polmav')] = true,
    [1596003233] = true,
    [-1313105063] = true,
}

local vehData = {}

RegisterNetEvent('Vehicle.UpdateHealth', function(veh, engine, body)
    veh = NetworkGetEntityFromNetworkId(veh)
    vehData[veh] = {engine = engine, body = body, vin = Entity(veh).state.vin}
end)

AddEventHandler('entityRemoved', function(veh)
    if vehData[veh] then
        if vehData[veh].vin then
            exports.ghmattimysql:execute('SELECT * from vehicles where id = @VIN', {
                VIN = vehData[veh].vin
            }, function(res)
                res = res[1]
                if res then
                    if vehData[veh].engine < 100.0 then vehData[veh].engine = 100.0 end
                    local data = json.decode(res.data)
                    data.enginehealth = vehData[veh].engine
                    data.bodyhealth = vehData[veh].body
                    data = json.encode(data)
                    exports.ghmattimysql:execute('UPDATE vehicles SET data = @Data WHERE id = @VIN', {
                        VIN = vehData[veh].vin,
                        Data = data,
                    })
        
                    vehData[veh] = nil
                end
            end)
        end
    end
end)

AddEventHandler('entityCreating', function(veh)
    local model  = GetEntityModel(veh)
    if GetEntityPopulationType(veh) ~= 7 and modelBlacklist[model] then
        CancelEvent()
        return
    end
end)

RegisterNetEvent('Park', function(veh)
    local source = source
    local char = GetCharacter(source)
    veh = NetworkGetEntityFromNetworkId(veh)
    if GetUser(source).data.parking and Entity(veh).state.vin and Entity(veh).state.owner == char.id then
        if Entity(veh).state.fake then
            TriggerClientEvent('Shared.Notif', source, 'This vehicle is already parked')
            return
        end

        SQL('UPDATE vehicles set location = ? WHERE id = ?', 
        json.encode({pos = GetEntityCoords(veh), heading = GetEntityHeading(veh)}),
        Entity(veh).state.vin)

        local val = SQL('SELECT * from vehicles where id = ?', Entity(veh).state.vin)[1]
        Entity(veh).state.fake = true
        SetVehicleDoorsLocked(veh, 3)
       --[[  TriggerEvent('DeleteEntity', NetworkGetNetworkIdFromEntity(veh))
        ParkedVehicle(val) ]]
    end
end)

RegisterNetEvent('LoJack', function(plate)
    local source = source
    for k,v in pairs(vehicles) do
        if v.Plate == plate then
            TriggerClientEvent('Tow.GPS', source, GetEntityCoords(k))
            TriggerClientEvent('PhoneNotif', source, 'vehicles', 'LoJack has found your vehicle', 2500)
            return
        end
    end
    TriggerClientEvent('PhoneNotif', source, 'vehicles', 'Your vehicle could not be located', 2500)
end)

CreateThread(function()
    Wait(1000)
    local val = SQL('SELECT * from vehicles where location is not null')
    for k,v in pairs(val) do
        CreateThread(function()
            ParkedVehicle(v)
        end)
    end
end)

function ParkedVehicle(v)
    v.location = json.decode(v.location)
    local veh = MakeVehicle(nil, v.model, vec(v.location.pos.x, v.location.pos.y, v.location.pos.z, v.location.heading))

    local owner = NetworkGetEntityOwner(veh)
    while owner == -1 do
        owner = NetworkGetEntityOwner(veh)
        Wait(0)
    end

    Console('[Parked Vehicles]', v.plate..' now spawned')
    local flags = json.decode(v.flags)
    local ent = Entity(veh)
    ent.state.plate = v.plate
    ent.state.owned = true
    ent.state.fuel = (flags.Fuel or Random(50, 100)) + 0.0
    ent.state.owner = v.owner
    ent.state.vin = v.id
    ent.state.nos = flags.NOS
    ent.state.fake = true
    vehicles[veh] = {
        Plate = v.plate,
        Data = v.data,
        Keys = {},
        Model = GetEntityModel(veh)
    }

    SetVehicleDoorsLocked(veh, 3)
    TriggerClientEvent('Parked', owner, NetworkGetNetworkIdFromEntity(veh), v.data, v.plate)
end

Task.Register('LoJack', function(source, veh)
    veh = NetworkGetEntityFromNetworkId(veh)
    local char = GetCharacter(source)
    if char.id == Entity(veh).state.owner then
        if exports['geo-inventory']:RemoveItem('Player', source, 'gps', 1) then
            SQL('UPDATE vehicles set flags = JSON_SET(flags, "$.gps", ?) where id = ?', 1, Entity(veh).state.vin)
        end
    end
end)