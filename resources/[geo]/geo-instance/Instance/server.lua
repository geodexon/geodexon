Instance = {}
VehicleInstance = {}
Keys = {}

RegisterCommand('view', function(source, args)
    local char = GetCharacter(source)
    if char.id then
        if exports['geo-guilds']:GuildAuthority('FHA', char.id) > 0 then
            if interiors[args[1]] then
                EnterProperty(source, 'view-'..args[1], args[1], false, {table.unpack(GetEntityCoords(GetPlayerPed(source)))})
            end
        end
    end
end)

RegisterNetEvent('InstanceInit')
AddEventHandler('InstanceInit', function()
    Instance[source] = 'None'
end)

RegisterNetEvent('Instance:Exit')
AddEventHandler('Instance:Exit', function(veh)
    local source = source
    local char = GetCharacter(source)
    InstancePlayer(source, 'None')
    Keys[source] = nil

    if veh then
        InstanceVehicle(veh, 'None')
    end

    TriggerEvent('LeftProperty', source, char.interior)
    UpdateChar(source, 'interior', nil)
    UpdateChar(source, 'interiorpos', nil)

    local dragging = exports['geo-es']:Dragging(source)
    if dragging then
        local char = GetCharacter(dragging)
        InstancePlayer(dragging, 'None')
        Keys[dragging] = nil

        if veh then
            InstanceVehicle(veh, 'None')
        end

        TriggerEvent('LeftProperty', dragging, char.interior)
        UpdateChar(dragging, 'interior', nil)
        UpdateChar(dragging, 'interiorpos', nil)
        exports['geo-es']:StopDrag(source)
    end
end)

AddEventHandler('Logout', function(char)
    InstancePlayer(char.serverid, 'None')
    TriggerClientEvent('Interior:Break', char.serverid)
    Keys[source] = nil
end)

local breachList = {}
AddEventHandler('Breach', function(source)
    local pos = GetEntityCoords(GetPlayerPed(source))
    local char = GetCharacter(source)
    local closest = 0
    local dist = 5.0
    breachList[char.id] = {}
    for k,v in pairs(properties) do
        for _, door in pairs(v.doors) do
            local distance = Vdist3(pos, vec(table.unpack(door, 1 ,3)))
            if distance <= 5.0 then
                table.insert(breachList[char.id], v)
                break
            end
        end
    end

    for k,v in pairs(Apartments) do
        if v.Resident then
            local distance = Vdist3(pos, vec(v.Position.x, v.Position.y, v.Position.z))
            if distance <= 2.0 then
                local val = New(v)
                val.title = 'Motel: '..v.Resident
                table.insert(breachList[char.id], val)
                break
            end
        end
    end

    for k,v in pairs(luxuary) do
        local distance = Vdist3(pos, vec(table.unpack(v.Position, 1, 3)))
        if distance <= 2.0 then
            table.insert(breachList[char.id], v)
            break
        end
    end

    if #breachList[char.id] > 0 then
        TriggerClientEvent('BreachList', source, breachList[char.id])
    end
end)

RegisterNetEvent('BreachProperty')
AddEventHandler('BreachProperty', function(id)
    local source = source
    local char = GetCharacter(source)
    if char.Duty == 'Police' then
        local pos = GetEntityCoords(GetPlayerPed(source))
        if breachList[char.id] then
            EnterProperty(source, breachList[char.id][id].title, breachList[char.id][id].interior or 'motel', true, {pos.x, pos.y, pos.z})
            breachList[char.id] = nil
        else
            EnterProperty(source, properties[id].title, properties[id].interior or 'motel', true, {pos.x, pos.y, pos.z})
        end
    end
end)

function EnterProperty(source, property, int, hasKey, pos, veh, players)
    local dragging = exports['geo-es']:Dragging(source)
    Console('[Instance]', Format('%s entered %s', GetName(GetCharacter(source)), property))
    InstancePlayer(source, property)
    if veh then
        InstanceVehicle(veh, property)
    end

    if dragging then
        EnterProperty(dragging, property, int, hasKey, pos)
        exports['geo-es']:StopDrag(source)
    end
    UpdateChar(source, 'interior', property)
    UpdateChar(source, 'interiorpos', vec(pos[1], pos[2], pos[3]))
    TriggerClientEvent('EnterProperty', source, property, int, hasKey, pos)
    TriggerEvent('EnteredProperty', source, property)
    Keys[source] = hasKey

    local char = GetCharacter(source)
    if PropertyAllowed(property, char.id) then
        if property == char.home or char.home == nil then
            SQL('UPDATE characters SET lastproperty = ? WHERE id = ?', json.encode({property, int, pos}), char.id)
        end
    end

    if players then
        local ent = NetworkGetEntityFromNetworkId(veh)
        for k,v in pairs(players) do
            if ent == GetVehiclePedIsIn(GetPlayerPed(v[1])) then
                InstancePlayer(v[1], property)
                UpdateChar(v[1], 'interior', property)
                UpdateChar(v[1], 'interiorpos', vec(pos[1], pos[2], pos[3]))
                TriggerClientEvent('EnterProperty', v[1], property, int, PropertyAllowed(property, GetCharacter(v[1]).id), pos, veh, v[2])
                TriggerEvent('EnteredProperty', v[1], property)
            end
        end
    end
end

function InstancePlayer(source, property)
    Instance[source] = property
    TriggerClientEvent('Inventory.KillProps', source)
    SetPlayerRoutingBucket(source, property == 'None' and 0 or math.abs(GetHashKey(property)))
    if property ~= 'None' then
        SetRoutingBucketPopulationEnabled(math.abs(GetHashKey(property)), false)
    end
end

function InstanceVehicle(source, property)
    for k,v in pairs(VehicleInstance) do
        local ent = NetworkGetEntityFromNetworkId(source)
        if DoesEntityExist(ent) then
            if GetEntityModel(ent) ~= v[2] then
                VehicleInstance[k] = nil
            end
        else
            VehicleInstance[k] = nil
        end
    end

    local ent = NetworkGetEntityFromNetworkId(source)
    if DoesEntityExist(ent) then
        local bucket = property == 'None' and 0 or math.abs(GetHashKey(property))
        VehicleInstance[ent] = {property, GetEntityModel(ent), source}
        SetEntityRoutingBucket(ent, bucket)
    end
end

AddEventHandler('entityRemoved', function(ent)
    if VehicleInstance[ent] then
        VehicleInstance[ent] = nil
    end
end)

RegisterCommand('sethome', function(source)
    local char = GetCharacter(source)
    if char.interior then
        if PropertyAllowed(char.interior, char.id) then
            SQL('UPDATE characters SET home = ? WHERE id = ?', char.interior, char.id)
            TriggerClientEvent('Shared.Notif', source, "Welcome to your new home!")
            UpdateChar(source, 'home', char.interior)
        else
            TriggerClientEvent('Shared.Notif', source, "You aren't allowed to live here :(")
        end
    else
        TriggerClientEvent('Shared.Notif', source, "You aren't inside a home")
    end
end)

function GetPlayersInInstance(property)
    local lst = {}
    for k,v in pairs(Instance) do
        if v == property then
            table.insert(lst, k)
        end
    end

    return lst
end

Task.Register('GetOutfits', function(source)
    local char = GetCharacter(source)
    return SQL('SELECT * from outfits WHERE cid = ?', char.id)
end)

Task.Register('PDChar', function(source, id)
    return SQL('SELECT clothing from characters where id = ?', tonumber(id))[1].clothing
end)

exports('EnterProperty', EnterProperty)
exports('GetPlayersInInstance', GetPlayersInInstance)