RegisterNetEvent('PurchaseVehicle')
AddEventHandler('PurchaseVehicle', function(dealer, veh, data, handle, name)
    local source = source
    local char = GetCharacter(source)

    if not VehicleShops[dealer].Vehicles[veh] then
        return
    end

    if VehicleShops[dealer].requires then
        if not VehicleShops[dealer].requires(char) then
            TriggerClientEvent('PurchaseVehicle', source, false)
            return
        end
    end

    local var = VehicleShops[dealer].Vehicles[veh][3]
    if var then
        local found = false
        for k,v in pairs(var) do
            local hasFlag = exports['geo-guilds']:GuildHasFlag(v[1], char.id,  v[2])
            if (v[3] and not hasFlag) or (not v[3] and hasFlag) then
                found = true 
                break
            end
        end

        if not found then
            for k,v in pairs(var) do
                if not v[3] then
                    TriggerClientEvent('Shared.Notif', source, Format('You need to be in %s: %s to purchase this vehicle', v[1], v[2]))
                else
                    TriggerClientEvent('Shared.Notif', source, Format('You can\'t be in %s: %s to purchase this vehicle', v[1], v[2]))
                end
            end
            return
        end
    end

    local str = ''
    for i=1,5 do
        str = str..string.char(Random(65, 90))
    end

    str = str..Random(100,999)
    str = str:upper()
    
    if VehicleShops[dealer].Vehicles[veh][2] > 0 then
        VehicleShops[dealer].Vehicles[veh][2] = VehicleShops[dealer].Vehicles[veh][2] - 1
        DeleteEntity(NetworkGetEntityFromNetworkId(handle))

        local price = VehiclePrices[VehicleShops[dealer].Vehicles[veh][1]]
        if char.job == 'Car Salesman' then
            price = math.floor(price * 0.8)
        end

        if exports['geo-eco']:DebitDefault(char, price, 'Vehicle Purchase: '..name) then
            TriggerClientEvent('VehicleListings', -1, dealer, VehicleShops[dealer].Vehicles[veh])
            while exports.ghmattimysql:scalarSync('SELECT plate from vehicles where plate = @plate', {
                plate = str
            }) do
                str = ''
                for i=1,5 do
                    str = str..string.char(Random(65, 90))
                end
            
                str = str..Random(100,999)
                str = str:upper()
            end
    
            data.plate = str
            exports.ghmattimysql:execute('INSERT INTO vehicles (plate, model, data, owner) VALUES (@Plate, @Model, @Data, @Owner)', {
                Plate = str,
                Model = VehicleShops[dealer].Vehicles[veh][1]:upper(),
                Data = json.encode(data),
                Owner = char.id
            }, function()
                TriggerClientEvent('PurchaseVehicle', source, true, json.encode(data), str, veh)

                exports['geo-vehicle']:SpawnVehicle(source, data.plate, VehicleShops[dealer].VehSpawn)
            end)
            
            return
        else
            VehicleShops[dealer].Vehicles[veh][2] = VehicleShops[dealer].Vehicles[veh][2] + 1
        end
    else
        TriggerClientEvent('Shared.Notif', source, 'This vehicle is out of stock')
    end
    
    TriggerClientEvent('PurchaseVehicle', source, false)
end)

Task.Register('VehicleShop.GetCars', function(source, closest)
    return VehicleShops[closest].Vehicles
end)

CreateThread(function()
    while true do

        for k,v in pairs(VehicleShops) do
            v.Vehicles = {}
            if v.VehicleDefaults ~= 'all' then
                while #v.Vehicles ~= (#v.VehicleDefaults >= (v.max or 4) and (v.max or 4) or #v.VehicleDefaults) do
                    local choice = v.VehicleDefaults[Random(#v.VehicleDefaults)]

                    local found = false
                    for k,v in pairs(v.Vehicles) do
                        if v[1] == choice[1] then
                            found = true
                            break
                        end
                    end

                    if not found then
                        table.insert(v.Vehicles, New(choice))
                    end
                end
            else
                for key,val in pairs(VehiclePrices) do
                    if not exclude[key] then
                        table.insert(v.Vehicles, {key, 2})
                    end
                end
            end

            table.sort(v.Vehicles, function(a, b)
                return (VehiclePrices[a[1]] or 0) < (VehiclePrices[b[1]] or 0)
            end)

            TriggerClientEvent('VehicleListings', -1, k, v.Vehicles)
        end

        Console('[Vehicle Shops]', 'Refreshed Listing')
        Wait(1000 * 3600)
    end
end)

Task.Register('FindCar', function(source, pCar)
    for key,val in pairs(VehicleShops) do
        for _, car in pairs(val.Vehicles or {}) do
            if car[1] == pCar then
                return val.Location
            end
        end
    end
end)