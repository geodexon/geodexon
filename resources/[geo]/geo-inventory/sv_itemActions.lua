RegisterNetEvent('Use:plasma_cutter')
AddEventHandler('Use:plasma_cutter', function(id)
    local source = source
    RemoveDurability('Player', source, id, 10)
end)

RegisterNetEvent('Armor.Set')
AddEventHandler('Armor.Set', function(arm, id)
    local source = source
    for k,v in pairs(Inventories['Player'][tostring(source)]) do
        if v.ID == id then
            if arm > items[v.Key].MaxArmor then arm = items[v.Key].MaxArmor end
            v.Data.Armor = arm
            Inventory.SQL('Update', 'Player', tostring(source), k)
            Update('Player', tostring(source), nil, nil, nil, k)
            break
        end
    end
end)

RegisterNetEvent('Use:horn_christmas')
AddEventHandler('Use:horn_christmas', function()
    local source = source
    if exports['geo-inventory']:RemoveItem('Player', source, 'horn_christmas', 1) then
        local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(source)))
        SQL('UPDATE vehicles SET data = json_set(data, "$.14", 48) WHERE plate = ?', plate)
    end
end)

RegisterNetEvent('Use:horn_halloween')
AddEventHandler('Use:horn_halloween', function()
    local source = source
    if exports['geo-inventory']:RemoveItem('Player', source, 'horn_halloween', 1) then
        local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(source)))
        SQL('UPDATE vehicles SET data = json_set(data, "$.14", 38) WHERE plate = ?', plate)
    end
end)

RegisterNetEvent('SmokeWeed', function()
    local source = source
    if RateLimit('SmokeWeed'..source, 9000) and exports['geo-inventory']:RemoveItem('Player', source, 'weed_1g', 1) and Random(1, 50) == 1 then
        exports['geo-inventory']:AddItem('Player', source, 'weed_seed', 1)
    end
end)

RegisterNetEvent('InstallNOS', function(veh)
    local source = source
    veh = NetworkGetEntityFromNetworkId(veh)
    if exports['geo-inventory']:RemoveItem('Player', source, GetItemKey('Player', source, 'nos').ID, 1) then
        if Entity(veh).state.vin then
            SQL('UPDATE vehicles set flags = JSON_SET(flags, "$.NOS", ?) where id = ?', 100, Entity(veh).state.vin)
        end

        Entity(veh).state.nos = 100
    end
end)

RegisterNetEvent('Use:evidencebag', function(id)
    local source = source
    for k,v in pairs(Inventories['Player'][tostring(source)]) do
        if id == v.ID then
            OpenInventory(source, 'EvidenceBag', id)
            break;
        end
    end
end)

RegisterNetEvent('Lockpick', function(veh)
    Entity(NetworkGetEntityFromNetworkId(veh)).state.Lockpicked = true
end)

Task.Register('NOS.Consume', function(source, veh, id)
    veh = NetworkGetEntityFromNetworkId(veh)
    for k,v in pairs(Inventories['Player'][tostring(source)]) do
        if v.ID == id and v.Key == 'nos' then
            if RemoveDurability('Player', source, v.ID, 20) then
                Entity(veh).state.nos = 100
                if Entity(veh).state.vin then
                    SQL('UPDATE vehicles set flags = JSON_SET(flags, "$.NOS", ?) where id = ?', 100, Entity(veh).state.vin)
                end
            end
        end
    end
end)

Task.Register('IsCuffed', function(source, player)
    return GetCharacter(player).cuff
end)

Task.Register('RemoveCuff', function(source, player)
    UpdateChar(player, 'cuff', 0)
end)