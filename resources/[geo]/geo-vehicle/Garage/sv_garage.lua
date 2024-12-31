local keys = {}
vehicles = {}
local lst = {}

RegisterNetEvent('AddKey')
AddEventHandler('AddKey', function(net, plate, data)
    local source = source
    local char = exports['geo']:Char(source)
    Wait(100)

    local handle = NetworkGetEntityFromNetworkId(net)
    if vehicles[handle] then
        table.insert(vehicles[handle].Keys, source)
    else
        vehicles[handle] = {
            Plate = plate,
            Data = data,
            Keys = {source},
            Model = GetEntityModel(handle)
        }
    end

    if keys[char.id] == nil then
        keys[char.id] = {}
    end

    keys[char.id][plate] = plate
    TriggerClientEvent('Keys', source, keys[char.id])
end)

AddEventHandler('Login', function(char)
    if keys[char.id] then
        TriggerClientEvent('Keys', char.serverid, keys[char.id])
    end
end)

Citizen.CreateThread(function()
    Wait(1000)
    exports.ghmattimysql:execute('UPDATE vehicles SET parked = 1 WHERE location is null')
end)

RegisterNetEvent('SetVehicleLock')
AddEventHandler('SetVehicleLock', function(id, isLocked)
	TriggerClientEvent('SetVehicleLock', -1, id, isLocked)
end)

local charge = {}
RegisterNetEvent('Garage:Fetch')
AddEventHandler('Garage:Fetch', function(garage)
    local source = source
    local char = GetCharacter(source)
    local allowed = true
    local othr = false
    charge[source] = true

    if garage:match('Guild') then
        othr = 'Global'
        charge[source] = false
        local prop = SplitString(garage, 'Guild:')[1]
        if not (exports['geo-guilds']:GuildAuthority(prop, char.id) > 0) then
            allowed = false
        end
    end

    if garage:match('Property') then
        othr = 'Global'
        charge[source] = false
        local prop = garage:sub(('Property:  '):len())
        if not exports['geo-instance']:PropertyAllowed(prop, char.id) then
            allowed = false
        end
    end

    if garage:match('CrimGarage') then
        othr = 'Crim'
    end

    if allowed then
        if not othr then
            exports.ghmattimysql:execute('SELECT parked, model, plate, data from vehicles where garage = @Garage and owner = @Char', {
                Garage = garage,
                Char = char.id
            }, function(res)
    
                lst[source] = {}
                for k,v in pairs(res) do
                    lst[source][v.plate] = v.parked
                end
    
                TriggerClientEvent('Garage:Fetch', source, res)
            end)
        elseif othr == 'Global' then
            exports.ghmattimysql:execute('SELECT parked, model, plate, data from vehicles where garage = @Garage', {
                Garage = garage,
            }, function(res)
                lst[source] = {}
                for k,v in pairs(res) do
                    lst[source][v.plate] = v.parked
                end
    
                TriggerClientEvent('Garage:Fetch', source, res)
            end)
        elseif othr == 'Crim' then
            exports.ghmattimysql:execute('SELECT parked, model, plate, data from vehicles_2 where garage = @Garage and owner = @CID', {
                Garage = garage,
                CID = char.id
            }, function(res)
                lst[source] = {}
                for k,v in pairs(res) do
                    lst[source][v.plate] = v.parked
                end
    
                TriggerClientEvent('Garage:Fetch', source, res)
            end)
        end
    else
        TriggerClientEvent('Garage:Fetch', source, {})
    end
end)

RegisterNetEvent('Garage:Park')
AddEventHandler('Garage:Park', function(plate, model, netID, garage, bodyH, engineH, data)
    local source = source
    local char = GetCharacter(source)

    if garage == 'CrimGarage' then

        local veh = NetworkGetEntityFromNetworkId(netID)
        if Entity(veh).state.vin then
            TriggerClientEvent('Shared.Notif', source, 'This vehicle is too hot to store here.')
            return
        end

        if SQL('SELECT COUNT(*) as res FROM vehicles_2 WHERE owner = ?', char.id)[1].res > 0 then
            TriggerClientEvent('Shared.Notif', source, 'You already have a car parked here')
            return
        end

        SQL('INSERT INTO vehicles_2 (garage, data, model, plate, parked, owner) VALUES ("CrimGarage", ?, ?, ?, 1, ?)', data, GetEntityModel(NetworkGetEntityFromNetworkId(netID)), plate, char.id)
        vehicles[NetworkGetEntityFromNetworkId(netID)] = nil
        TriggerClientEvent('ParkVehicle', -1, netID)
        Wait(2000)
        DeleteEntity(NetworkGetEntityFromNetworkId(netID))
        return
    end
    
    exports.ghmattimysql:execute('SELECT * from vehicles where plate = @Plate', {
        Plate = plate
    }, function(res)
        res = res[1]
        if res then
            local data = json.decode(res.data)
            data.enginehealth = engineH
            data.bodyhealth = bodyH

            data = json.encode(data)

            if garage ~= res.garage then
                if res.owner ~= char.id then
                    return
                end
            end

            CreateThread(function()
                Wait(500)
                exports.ghmattimysql:execute('UPDATE vehicles SET parked = 1, data = @Data, garage = @Garage WHERE plate = @Plate', {
                    Plate = plate,
                    Data = data,
                    Garage = garage
                })
            end)

            vehicles[NetworkGetEntityFromNetworkId(netID)] = nil
            TriggerClientEvent('ParkVehicle', -1, netID)
            Wait(2000)
            DeleteEntity(NetworkGetEntityFromNetworkId(netID))
        end
    end)
end)

local times = {}
RegisterNetEvent('Garage:PullVehicle')
AddEventHandler('Garage:PullVehicle', function(plate, pos, garage, spot)
    local source = source
    local time = os.time()

    if garage ~= 'CrimGarage' then
        if charge[source] then
            if not exports['geo-eco']:DebitDefault(GetCharacter(source), 25, 'Valet Fee') then
                return
            end
        end
    end

    if type(pos) == 'vector3' then
        pos = vec(pos.x, pos.y, pos.z, GetEntityHeading(GetPlayerPed(source)))
    end

    if time - (times[source] or (time - 5)) > 1 then
        times[source] = time
        if lst[source][plate] == 1 then
            SpawnVehicle(source, plate, pos, garage, spot)
        end
    end
end)

RegisterNetEvent('RemovePlate')
AddEventHandler('RemovePlate', function(veh)
    local source = source
    local char = GetCharacter(source)
    local veh = NetworkGetEntityFromNetworkId(veh)
    local str = ''
    if DoesEntityExist(veh) then
        local plate = GetVehicleNumberPlateText(veh)
        if (plate == Entity(veh).state.plate) or (Entity(veh).state.plate == nil) then

            if not exports['geo-inventory']:HasItem('Player', source, 'plate') then
                return TriggerClientEvent('Shared.Notif', source, "You don't have any spare plates")
            end

            for i=1,5 do
                str = str..string.char(Random(65, 90))
            end
        
            str = str..Random(100,999)
            str = str:upper()

            if keys[char.id] then
                if keys[char.id][plate] then
                    keys[char.id][str] = str
                    TriggerClientEvent('Keys', char.serverid, keys[char.id])
                end
            end

            exports['geo-inventory']:RemoveItem('Player', source, 'plate', 1)
        else
            str = Entity(veh).state.plate
        end
        SetVehicleNumberPlateText(veh, str)
        Wait(100)
        TriggerClientEvent('RemovePlate', source, NetworkGetNetworkIdFromEntity(veh))
    end
end)

RegisterNetEvent('DeleteEntity')
AddEventHandler('DeleteEntity', function(vehNet)
    local ent = NetworkGetEntityFromNetworkId(vehNet)
    if ent ~= 0 then
        vehicles[ent] = nil
        DeleteEntity(ent)
    end
end)

local lastKnown = {}
AddEventHandler('entityRemoved', function(handle)
    local veh = vehicles[handle]
    if veh then
        for k,v in pairs(veh.Keys) do
            TriggerClientEvent('Shared.Notif', v, 'It went poof')
        end
        lastKnown[veh.Plate] = veh
        lastKnown[veh.Plate].Position = veh.Position
        lastKnown[veh.Plate].Heading = veh.Heading
        vehicles[handle] = nil
    end
end)

RegisterNetEvent('enteredVehicle')
AddEventHandler('enteredVehicle', function(netID)
    local handle = NetworkGetEntityFromNetworkId(netID)
    local veh = vehicles[handle]
    if veh then
        vehicles[handle].Position = GetEntityCoords(handle)
        vehicles[handle].Heading = GetEntityHeading(handle)
    end
end)

RegisterNetEvent('leftVehicle')
AddEventHandler('leftVehicle', function(netID)
    local handle = NetworkGetEntityFromNetworkId(netID)
    local veh = vehicles[handle]
    if veh then
        vehicles[handle].Position = GetEntityCoords(handle)
        vehicles[handle].Heading = GetEntityHeading(handle)
    end
end)

RegisterNetEvent('GiveKey')
AddEventHandler('GiveKey', function(player, veh)
    TriggerClientEvent('GiveKey', player, veh)
end)

local sale = {

}
RegisterNetEvent('Vehicle.Sell')
AddEventHandler('Vehicle.Sell', function(veh, player, price)
    local source = source
    if veh and price then
        price = math.floor(tonumber(price))
        veh =  NetworkGetEntityFromNetworkId(veh)
        local val = SQL('SELECT owner from vehicles WHERE plate = ?', GetVehicleNumberPlateText(veh))
        if val[1].owner == GetCharacter(source).id then
            sale[source] = {
                vehicle = veh,
                target = player,
                price = price,
                name = GetName(GetCharacter(source))
            }
            print( GetName(GetCharacter(source)))
            TriggerClientEvent('Vehicle.Buy', player, price, GetEntityModel(veh), source)
        end
    end
end)

RegisterNetEvent('Vehicle.Buy')
AddEventHandler('Vehicle.Buy', function(src, name)
    local source = source
    local char = GetCharacter(source)
    if sale[src] and sale[src].target == source then
        if exports['geo-eco']:DebitDefault(char, GetPrice(sale[src].price), 'Vehicle Purchase: '..name..' from '..sale[src].name) then
            SQL('UPDATE vehicles set owner = ? WHERE plate = ?', char.id, GetVehicleNumberPlateText(sale[src].vehicle))
            TriggerClientEvent('GiveKey', source, NetworkGetNetworkIdFromEntity(sale[src].vehicle))
            sale[src] = nil
        else
            sale[src] = nil
        end
    end
end)

RegisterCommand('recover', function(source)
    local char = GetCharacter(source)
    local pos = GetEntityCoords(GetPlayerPed(source))

    for k,v in pairs(keys[char.id] or {}) do
        if lastKnown[v] ~= nil then
            if Vdist4(pos, lastKnown[v].Position) <= 100.0 then
                TriggerClientEvent('Recover', source, lastKnown[v])
                lastKnown[v] = nil
                break
            end
        end
    end
end)

function MakeVehicle(source, model, pos)
    local _model = type(model) == 'string' and GetHashKey(model) or model
    local veh = CreateAutomobile(_model, source and GetEntityCoords(GetPlayerPed(source)) + vec(0, 0 ,-20.0) or pos.xyz + vec(0, 0, -20.0))
    while not DoesEntityExist(veh) do
        Wait(100)
        print('making vehicle')
    end

    while GetVehicleNumberPlateText(veh) == '' do
        Wait(100)
    end
    Wait(50)

    SetEntityCoords(veh, pos.x, pos.y, pos.z)
    if pos.w then
        SetEntityHeading(veh, pos.w + 0.000001)
    end

    SetVehicleDirtLevel(veh, 0.0)
    return veh
end

function SpawnVehicle(source, plate, pos, garage, spot)
    if garage == 'CrimGarage' then
        exports.ghmattimysql:execute('SELECT * from vehicles_2 WHERE plate = ?', {plate}, function(res)
            local veh = MakeVehicle(source, res[1].model, pos)
            TriggerClientEvent('Garage:Spawn', source, NetworkGetNetworkIdFromEntity(veh), res[1], pos)
            TriggerEvent('StolenPlate', plate)
        end)

        Wait(500)
        exports.ghmattimysql:execute('DELETE FROM vehicles_2 WHERE plate = @Plate', {
            Plate = plate,
        })
    else
        exports.ghmattimysql:execute('UPDATE vehicles SET parked = 0  WHERE plate = @Plate', {
            Plate = plate,
        })
    
        exports.ghmattimysql:execute('SELECT * from vehicles WHERE plate = ?', {plate}, function(res)
            local veh = MakeVehicle(source, res[1].model, pos)
            local flags = json.decode(res[1].flags)
            local ent = Entity(veh)
            ent.state.plate = res[1].plate
            ent.state.owned = true
            ent.state.fuel = (flags.Fuel or Random(50, 100)) + 0.0
            ent.state.owner = res[1].owner
            ent.state.vin = res[1].id
            ent.state.nos = flags.NOS

            TriggerClientEvent('Garage:Spawn', source, NetworkGetNetworkIdFromEntity(veh), res[1], pos, spot)
        end)
    end
end

RegisterCommand('_parkperms', function(source, args)
    if source == 0 or GetCharacter(source).username then
        for k,v in pairs(GetPlayers()) do
            if tonumber(GetUser(tonumber(v)).id) == tonumber(args[1]) then
                SetUserData(tonumber(v), 'parking', args[2] and 1 or nil)
                TriggerClientEvent('Shared.Notif', tonumber(v), 'Parking Priviliges')
                break
            end
        end
    end
    
end)

exports('SpawnVehicle', SpawnVehicle)
exports('CreateVehicle', MakeVehicle)

AddEventHandler('onResourceStop', function(res) 
    if res == GetCurrentResourceName() then
        for k,v in pairs(vehicles) do
            DeleteEntity(k)
        end
    end
end)