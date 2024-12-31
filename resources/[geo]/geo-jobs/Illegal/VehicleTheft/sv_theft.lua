local objList = {}
classes = {
    {0, 1, 2, 3, 4, 8, 9, 10, 11, 12, 17, 20},
    {0, 1, 2, 3, 4, 8, 9, 10, 11, 12, 17, 20},
    {0, 1, 2, 3, 4, 8, 9, 10, 11, 12, 17, 20},
    {0, 1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 17, 20},
    {0, 1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 17, 20}
}

Jobs:RegisterRanking('VehicleTheft', DefaultCriminal)
Task.Register('VehicleTheft.GetJob', function(source)
    local char = GetCharacter(source)

    if char.id then
        if not objList[char.id] then
            objList[char.id] = Jobs.Fetch('VehicleTheft', char.id)
            if not objList[char.id] then return end
        end

        if objList[char.id].rank >= 2 and exports['geo-rpg']:CanAccessQuest(source, 'chop.begin') then
            exports['geo-rpg']:StartQuest(source, 'chop.begin')
            return
        end

        objList[char.id].job = 'phase_1'
        objList[char.id].class = classes[objList[char.id].rank][Random(#classes[objList[char.id].rank])]


        if objList[char.id].timeout and objList[char.id].timeout > os.time() then
            TriggerClientEvent('Shared.Notif', source, 'Come back later', 5000)
            return 
        end

        JobTime[char.id] = os.time()
        TriggerClientEvent('VehicleTheft.Start', source, objList[char.id].class)
        return 'phase_1'
    end
end)

Task.Register('VehicleTheft.Quit', function(source)
    local char = GetCharacter(source)

    if char.id and objList[char.id] then
        objList[char.id].job = 'none'
        objList[char.id].class = nil
        objList[char.id].timeout = os.time() + 300
    end
end)

Task.Register('VehicleTheft.Deliver', function(source, veh, class)
    local char = GetCharacter(source)

    if char.id and objList[char.id] and objList[char.id].job == 'phase_1' then
        veh = NetworkGetEntityFromNetworkId(veh)
        if Entity(veh).state.towed then
            TriggerClientEvent('Shared.Notif', source, "We don't want this vehicle", 5000)
            return objList[char.id].job
        end

        if DoesEntityExist(veh) and class == objList[char.id].class then
            TriggerEvent('DeleteEntity', NetworkGetNetworkIdFromEntity(veh))
            objList[char.id]:Pay(source, 1800)

            local promoted, rank = objList[char.id]:CheckPromotion()
            if promoted and rank == 3 then
                TriggerClientEvent('VehicleTheft.UnlockGarage', source)
            end

            if Random(1, 15) == 1 then
                exports['geo-inventory']:ReceiveItem('Player', source, 'plate', 1)
            end
            
            return 'none'
        end

        return 'phase_1'
    end
end)

Task.Register('VehicleTheft.Garaage', function(source)
    local char = GetCharacter(source)

    if char.id then
        if not objList[char.id] then
            objList[char.id] = Jobs.Fetch('VehicleTheft', char.id)
            if not objList[char.id] then return end
        end

        return objList[char.id].rank >= 3
    end
end)