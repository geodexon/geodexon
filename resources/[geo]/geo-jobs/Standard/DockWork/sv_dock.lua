local pool = {}

local Job = {
    OnJob = false,
    CurrentID = 0
}

local ranks = {
    {'Trainee', 0.55, 0},
    {'Junior Driver', 0.6, 300},
    {'Driver', 0.7, 3600},
    {'Senior Driver', 0.8, 10080},
    {'Assistant Manager', 0.9, 21000},
    {'Manager', 1.0, 36000}
}

Jobs:RegisterRanking('DockWork', ranks)

local count = 0
local objList = {}

local jobList = {
    {vector3(1100.22, -2995.16, 8.69), vector3(876.2, -2942.84, 5.9)},
    {vector3(1142.26, -3020.84, 8.69), vector3(876.2, -2942.84, 5.9)},
    {vector3(945.23, -3074.93, 8.69), vector3(876.2, -2942.84, 5.9)},
    {vector3(1274.46, -3107.19, 7.49), vector3(876.2, -2942.84, 5.9)},
    {vector3(1274.11, -3165.04, 7.53), vector3(876.2, -2942.84, 5.9)},
    {vector3(848.84, -2970.76, 7.48), vector3(876.2, -2942.84, 5.9)},
    {vector3(1213.56, -2969.33, 5.87), vector3(876.2, -2942.84, 5.9)},
    {vector3(1170.28, -2978.95, 5.90), vector3(876.2, -2942.84, 5.9)},
    {vector3(866.08, -2970.54, 7.48), vector3(876.2, -2942.84, 5.9)},
    {vector3(1134.15, -3252.93, 5.90), vector3(876.2, -2942.84, 5.9)},
    {vector3(1279.25, -3311.28, 5.90), vector3(876.2, -2942.84, 5.9)},
    {vector3(1035.21, -3248.98, 9.09), vector3(876.2, -2942.84, 5.9)}
}

RegisterNetEvent('Dock Work:StartJob')
AddEventHandler('Dock Work:StartJob', function()
    local source = source
    local char = GetCharacter(source)

    if count >= 2 then
        return
    end

    if pool[char.id] == nil then
        pool[char.id] = New(Job)
        objList[char.id].pay = 0
        objList[char.id] = Jobs.Fetch('DockWork', char.id)
        if not objList[char.id] then return end
    end

    if objList[char.id]:GetHours() == 0 or GetUser(source).data.settings.jobinfo then
        TriggerClientEvent('Shared.Notif', source, [[
            Your handler is parked near the water, use it to pick up your cargo container and transport it to the
            designated area on your map
        ]], 10000)
    end

    local time = os.time()
    if pool[char.id].LastJob == nil then
        pool[char.id].LastJob = time
    end

    if pool[char.id].LastJob <= time then
        pool[char.id].OnJob = true
        count = count + 1
    else
        local since = _TimeSince(pool[char.id].LastJob)
        TriggerClientEvent('Chat.Message', source, '[Dock Work]', ('%s minutes and %s seconds until next available job'):format(since.minutes, since.seconds), 'job')
        return
    end

    pool[char.id].CurrentID = Random(#jobList)
    JobTime[char.id] = os.time()

    TriggerClientEvent('Help', source, 6)
    TriggerClientEvent('Dock Work:StartJob', source, pool[char.id].OnJob, jobList[pool[char.id].CurrentID])
end)

RegisterNetEvent('Dock Work:QuitJob')
AddEventHandler('Dock Work:QuitJob', function() 
    local source = source
    local char = GetCharacter(source)
    if objList[char.id] then
        if pool[char.id].OnJob then
            pool[char.id].OnJob = false
            count = count - 1
            pool[char.id].LastJob = os.time() + 900
            TriggerClientEvent('Dock Work:QuitJob', source, pool[char.id].OnJob)
        end
    end
end)

RegisterNetEvent('Dock Work:Next')
AddEventHandler('Dock Work:Next', function(pos)
    local source = source
    local char = GetCharacter(source)
    if pool[char.id].OnJob then
        if Vdist4(pos, jobList[pool[char.id].CurrentID][1]) <= 500.0 then
            objList[char.id]:AddPay(900)
            pool[char.id].CurrentID = Random(#jobList)
            TriggerClientEvent('Dock Work:NextJob', source, jobList[pool[char.id].CurrentID])
        end
    end
end)

RegisterNetEvent('Dock Work:PayMe')
AddEventHandler('Dock Work:PayMe', function()
    local source = source
    local char = GetCharacter(source)

    if pool[char.id] then
        if objList[char.id]:Pay(source, 0) then
            TriggerClientEvent('Dock Work:GetPay', source, objList[char.id].pay)
        end
    end
end)

RegisterNetEvent('Dock Work:GetPay')
AddEventHandler('Dock Work:GetPay', function()
    local source = source
    local char = GetCharacter(source)

    if pool[char.id] then
        TriggerClientEvent('Dock Work:GetPay', source, objList[char.id].pay)
    end

    if objList[char.id] == nil then
        objList[char.id] = Jobs.Fetch('DockWork', char.id)
        if not objList[char.id] then return end
    end

    TriggerClientEvent('Dock Work:InformRank', source, objList[char.id]:GetRank())
end)

RegisterNetEvent('Dock Work:Promotion')
AddEventHandler('Dock Work:Promotion', function()
    local source = source
    local char = GetCharacter(source)

    if objList[char.id]:IsNextRank() then
        local mth = objList[char.id]:TimeUntilNextRank()
        if mth <= 0 then
            objList[char.id]:CheckPromotion()
            TriggerClientEvent('Chat.Message', source, '[Dock Work]', ('You have been promoted to a %s'):format(objList[char.id]:GetRank()), 'job')
            TriggerClientEvent('Dock Work:InformRank', source, objList[char.id]:GetRank())
        else
            local num = string.format('%.2f', math.abs(mth / 60))
            TriggerClientEvent('Chat.Message', source, '[Dock Work]', ('%s hours until your next promotion'):format(num), 'job')
        end
    end
end)

AddEventHandler('playerDropped', function()
    local source = source
    local char = GetCharacter(source)
    if char then
        if pool[char.id] then
            if pool[char.id].OnJob then
                count = count - 1
                pool[char.id].OnJob = false
            end
        end
    end
end)