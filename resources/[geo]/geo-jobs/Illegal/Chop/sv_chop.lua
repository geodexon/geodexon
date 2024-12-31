local objList = {}
local classes = {0, 1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 17, 20}

classes = {
    {0, 1, 2, 3, 4, 8, 9, 10, 11, 12, 17, 20},
    {0, 1, 2, 3, 4, 8, 9, 10, 11, 12, 17, 20},
    {0, 1, 2, 3, 4, 8, 9, 10, 11, 12, 17, 20},
    {0, 1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 17, 20},
    {0, 1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 17, 20}
}

Jobs:RegisterRanking('Chop', {
    {'r3', 0.95, 0},
    {'r4', 1.0, 300},
    {'r5', 1.05, 3000},
    {'r6', 1.1, 9000}
})

Task.Register('Chop.GetJob', function(source)
    local char = GetCharacter(source)
    local time = exports['geo-sync']:GetTime()

    if char.id then
        if not objList[char.id] then
            objList[char.id] = Jobs.Fetch('Chop', char.id)
            if not objList[char.id] then return end
        end

        if not (time.hour > 19 or time.hour < 7) then
            TriggerClientEvent('Shared.Notif', source, 'Not during the day, jackass', 5000)
            return 
        end

        objList[char.id].job = 'phase_1'
        objList[char.id].class = classes[objList[char.id].rank][Random(#classes[objList[char.id].rank])]

        if objList[char.id].timeout and objList[char.id].timeout > os.time() then
            TriggerClientEvent('Shared.Notif', source, 'Come back later', 5000)
            return 
        end

        if objList[char.id]:GetHours() <= 0 or GetUser(source).data.settings.jobinfo then
            TriggerClientEvent('Shared.Notif', source, "Bring me a vehicle, tear it down and i'll give you some parts and maybe some other things, we'll talk")
        end

        JobTime[char.id] = os.time()
        TriggerClientEvent('Chop.Start', source, objList[char.id].class)
        return 'phase_1'
    end
end)

Task.Register('Chop.Quit', function(source)
    local char = GetCharacter(source)

    if char.id and objList[char.id] then
        objList[char.id].job = 'none'
        objList[char.id].class = nil
        objList[char.id].timeout = os.time() + 300
    end
end)

Task.Register('Chop.Deliver', function(source, veh, class)
    local char = GetCharacter(source)

    if char.id and objList[char.id] and objList[char.id].job == 'phase_1' then
        veh = NetworkGetEntityFromNetworkId(veh)
        if DoesEntityExist(veh) and class == objList[char.id].class then
            TriggerEvent('DeleteEntity', NetworkGetNetworkIdFromEntity(veh))
            objList[char.id]:Pay(source, 1800)

            if Random(1, 15) == 1 then
                exports['geo-inventory']:ReceiveItem('Player', source, 'plate', 1)
            end
            
            exports['geo-inventory']:ReceiveItem('Player', source, 'auto_parts', Random(1, 50))
            return 'none'
        end

        return 'phase_1'
    end
end)