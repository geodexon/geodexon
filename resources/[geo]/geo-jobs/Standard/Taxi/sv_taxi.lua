local taxis = {}
local lastTaxi = {}
local objList = {}

Jobs:RegisterRanking('Taxi', DefaultCiv)
Task.Register('Taxi.Start', function(source)
    local char = GetCharacter(source)
    local time = os.time()
    if char and taxis[char.id] == nil and (lastTaxi[char.id] == nil or (lastTaxi[char.id] and  time - lastTaxi[char.id] > 300)) then
        
        if not objList[char.id] then
            objList[char.id] = Jobs.Fetch('Taxi', char.id)
            if not objList[char.id] then return end
            objList[char.id]:CheckPromotion()
            JobTime[char.id] = time
        end
        
        local veh = exports['geo-vehicle']:CreateVehicle(source, 'taxi',vec(904.74, -188.58, 73.8, 54.72))
        exports['geo-es']:SetRented(GetVehicleNumberPlateText(veh), char)
        lastTaxi[char.id] = time
        taxis[char.id] = veh
        TriggerClientEvent('Help', source, 11)
        return NetworkGetNetworkIdFromEntity(veh)
    else
        TriggerClientEvent('Shared.Notif', source, 'You can only pull out a taxi every 5 minutes', 5000)
    end

    return 0
end)

Task.Register('Taxi.End', function(source)
    local char = GetCharacter(source)
    if char and taxis[char.id] ~= nil then
        if DoesEntityExist(taxis[char.id]) then
            if #(GetEntityCoords(taxis[char.id]) - GetEntityCoords(GetPlayerPed(source))) <= 50.0 then
                TriggerEvent('DeleteEntity', NetworkGetNetworkIdFromEntity(taxis[char.id]))
            end
            taxis[char.id] = nil
        end
    end
    
    return 0
end)

RegisterNetEvent('Taxi.Pay')
AddEventHandler('Taxi.Pay', function()
    local source = source
    local char = GetCharacter(source)
    if char and objList[char.id] then
        objList[char.id]:Pay(source, 900)
    end
end)