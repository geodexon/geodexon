local reservePlates = {}

RegisterNetEvent('LSC:Fix')
AddEventHandler('LSC:Fix', function(veh, engineHealth, bodyHealth, class, shopID)
    local source = source
    local cost = GetRepairCost(engineHealth, bodyHealth, class)

    local store = exports['geo-inventory']:GetStore('LSC', shopID)
    local worksHere
    if store then
        local storeGuild = exports['geo-instance']:GetProperty(store[1]).guild
        if storeGuild then
            worksHere = exports['geo-guilds']:GuildHasFlag(storeGuild, GetCharacter(source).id, 'Repair') or exports['geo-guilds']:GuildHasFlag(storeGuild, GetCharacter(source).id, 'Customize')
            if worksHere then cost = math.floor(cost * 0.6) end
        end
    end

    if exports['geo-eco']:DebitDefault(GetCharacter(source), cost, 'Vehicle Repairs') then
        TriggerClientEvent('LSC:Fix', source)
    end
end)

RegisterNetEvent('LSC:CheckPlate')
AddEventHandler('LSC:CheckPlate', function(_res, promID, plate)
    local source = source
    exports.ghmattimysql:scalar('SELECT plate from vehicles WHERE plate = @Plate', {Plate = plate}, function(res)
        if res == nil and reservePlates[plate] == nil then
            reservePlates[plate] = source
            TriggerClientEvent('ReturnPromise', source, _res, promID, true)
        else
            TriggerClientEvent('ReturnPromise', source, _res, promID, false)
        end
    end)
end)

RegisterNetEvent('LSC:Clear')
AddEventHandler('LSC:Clear', function()
    local source = source
    for k,v in pairs(reservePlates) do
        if v == source then
            reservePlates[k] = nil
        end
    end
end)

RegisterNetEvent('LSC:ModVehicle')
AddEventHandler('LSC:ModVehicle', function(_res, promID, start, ender, plate, class, shop, veh)
    local source = source
    local char = GetCharacter(source)
    local owned = Entity(NetworkGetEntityFromNetworkId(veh)).state.owned
    local total = 0
    for k,v in pairs(ender) do
        if v ~= start[k] and json.encode(v) ~= json.encode(start[k]) then
            total = total + CalculatePrice(class, k, v)
        end
    end

    local store = exports['geo-inventory']:GetStore('LSC', shop)
    local worksHere
    if store then
        local storeGuild = exports['geo-instance']:GetProperty(store[1]).guild
        if storeGuild then
            worksHere = exports['geo-guilds']:GuildHasFlag(storeGuild, GetCharacter(source).id, 'Customize')
            if worksHere then total = math.floor(total * 0.6) end
        end
    end

    if not owned then
        if exports['geo-eco']:DebitDefault(GetCharacter(source), total, 'Vehicle Modification') then
            TriggerClientEvent('ReturnPromise', source, _res, promID, true)
            return
        else
            TriggerClientEvent('ReturnPromise', source, _res, promID, false)
            return
        end
    end

    exports.ghmattimysql:execute('SELECT * from vehicles WHERE plate = @Plate', {Plate = plate}, function(res)
        res = res[1]
        if res == nil then
            if exports['geo-eco']:DebitDefault(GetCharacter(source), total, 'Vehicle Modification') then
                TriggerClientEvent('ReturnPromise', source, _res, promID, true)
            else
                TriggerClientEvent('ReturnPromise', source, _res, promID, false)
            end
        else
            if char.id == res.owner or CanMod(id, shop) then
                if ender['plate'] ~= start['plate'] then
                    for k,v in pairs(reservePlates) do
                        if v == source then
                            if k ~= ender['plate'] then
                                return
                            else
                                if exports.ghmattimysql:scalarSync('SELECT plate from vehicles WHERE plate = @Plate', {Plate = ender['plate']}) ~= nil then
                                    return
                                end
                            end
                        end
                    end
                end

                if exports['geo-eco']:DebitDefault(GetCharacter(source), total, 'Vehicle Modification') then
                    exports.ghmattimysql:execute('UPDATE vehicles set data = @Data WHERE Plate = @Plate', {Data = json.encode(ender), Plate = plate}, function()
                        TriggerClientEvent('ReturnPromise', source, _res, promID, true)

                        if ender['plate'] ~= start['plate'] then
                            exports.ghmattimysql:execute('UPDATE vehicles set plate = @Plate2 WHERE plate = @Plate', {Plate2 = ender['plate'] , Plate = plate}, function()
                                exports.ghmattimysql:execute('UPDATE inventories set stringid = @Plate2, inventoryid = @Plate2 WHERE stringid = @Plate', {Plate2 = ender['plate'] , Plate = plate}, function()
                                    exports.ghmattimysql:execute('UPDATE inventories set stringid = @Plate2, inventoryid = @Plate2 WHERE stringid = @Plate', {Plate2 = 'Glovebox-'..ender['plate'] , Plate = 'Glovebox-'..plate}, function()
                                    end)
                                end)
                            end)
                        end
                    end)
                else
                    TriggerClientEvent('ReturnPromise', source, _res, promID, false)
                end
            end
        end
    end)
end)

RegisterNetEvent('GetVehicleOwner')
AddEventHandler('GetVehicleOwner', function(plate, id)
    local source = source
    local char = GetCharacter(source)
    exports.ghmattimysql:execute('SELECT owner FROM vehicles WHERE plate = @Plate', {
        Plate = plate
    }, function(res)
        res = res[1]
        if res == nil then
            res = {}
        end
        res = res.owner or 0
        TriggerClientEvent('GetVehicleOwner', source, res, id)
    end)
end)

RegisterCommand('_buyplate', function(source, args, raw)
    if source == 0 then
        Log('Tebex', args[1]..' bought a license plate')
        for k,v in pairs(GetPlayers()) do
            if tonumber(GetIdent(tonumber(v)).fivem) == tonumber(args[1]) then
                if exports['geo-inventory']:AddItem('Player', v, 'free_plate', 1) then return end
            end
        end

        local id = SQL('SELECT * from users WHERE fivem = ?', tonumber(args[1]))[1].id
        ExecuteCommand('_addcredit '..id..' free_plate 1')
    end
end)

Task.Register('ChangePlate', function(source, veh, plate)
    if reservePlates[plate] == source then
        veh = NetworkGetEntityFromNetworkId(veh)
        if Entity(veh).state.vin and exports['geo-inventory']:RemoveItem('Player', source, 'free_plate', 1) then
            local data = SQL('SELECT * from vehicles where id = ?', Entity(veh).state.vin)[1]
            local oldplate = json.decode(data.data).plate
            exports.ghmattimysql:execute('UPDATE vehicles set plate = @Plate2 WHERE id = @Plate', {Plate2 = plate , Plate = Entity(veh).state.vin}, function()
                exports.ghmattimysql:execute('UPDATE inventories set stringid = @Plate2, inventoryid = @Plate2 WHERE stringid = @Plate', {Plate2 = plate , Plate = GetVehicleNumberPlateText(veh)}, function()
                    exports.ghmattimysql:execute('UPDATE inventories set stringid = @Plate2, inventoryid = @Plate2 WHERE stringid = @Plate', {Plate2 = 'Glovebox-'..plate , Plate = 'Glovebox-'..GetVehicleNumberPlateText(veh)}, function()
                        Entity(veh).state.plate = plate
                        SetVehicleNumberPlateText(veh, plate)
                    end)
                end)
            end)
        end
    end
end)