local pool = {}

local Job = {
    OnJob = false,
    CurrentID = 0
}

local objList = {}

local ranks = {
    {'Trainee', 0.55, 0},
    {'Junior Trucker', 0.6, 300},
    {'Trucker', 0.7, 3000},
    {'Senior Trucker', 0.8, 9000},
    {'Assistant Manager', 0.9, 18000},
    {'Manager', 1.0, 30000}
}

Jobs:RegisterRanking('Trucking', ranks)

local jobList = {
    {vector3(303.43, -170.98, 58.12), ''},
    {vector3(-1179.19, -368.34, 36.64), ''},
    {vector3(-979.39, -1449.44, 4.69), ''},
    {vector3(-741.95, -1507.95, 5.0), ''},
    {vector3(-1064.39, -2082.77, 13.29), ''},
    {vector3(989.08, -1381.57, 31.55), ''},
    {vector3(1213.62, -1256.15, 35.23), ''},
    {vector3(718.13, -975.7, 24.91), ''},
    {vector3(1845.71, 2585.89, 45.67), ''},
    {vector3(568.97, 2796.38, 42.02), ''},
    {vector3(182.85, 2790.07, 45.6), ''},
    {vector3(-2544.15, 2316.03, 33.22), ''},
    {vector3(-246.68, 6068.53, 32.34), ''},
    {vector3(1730.89, 6410.71, 35.0), ''},
    {vector3(1707.85, 4791.89, 41.98), ''},
    {vector3(2899.32, 4399.38, 50.23), ''},
}

RegisterNetEvent('Trucking:StartJob')
AddEventHandler('Trucking:StartJob', function()
    local source = source
    local char = GetCharacter(source)

    if pool[char.id] == nil then
        pool[char.id] = New(Job)
        objList[char.id].pay = 0

        objList[char.id] = Jobs.Fetch('Trucking', char.id)
        if not objList[char.id] then return end
    end

    if objList[char.id]:GetHours() == 0 or GetUser(source).data.settings.jobinfo then
        TriggerClientEvent('Shared.Notif', source, [[
            The dollys are in your trailer, take them to your destination then use them and bring them
                up to the delivery point to deliver the package and continue 
        ]], 10000)
    end

    local time = os.time()
    if pool[char.id].LastJob == nil then
        pool[char.id].LastJob = time
    end

    if pool[char.id].LastJob <= time then
        pool[char.id].OnJob = true
    else
        local since = _TimeSince(pool[char.id].LastJob)
        TriggerClientEvent('Chat.Message', source, '[Trucking]', ('%s minutes and %s seconds until next available job'):format(since.minutes, since.seconds), 'job')
        return
    end

    if exports['geo-eco']:DebitDefault(char, 100, 'Truck Rental') then
    end

    pool[char.id].CurrentID = Random(#jobList)
    JobTime[char.id] = os.time()

    TriggerClientEvent('Help', source, 7)
    TriggerClientEvent('Trucking:StartJob', source, pool[char.id].OnJob, jobList[pool[char.id].CurrentID])
end)

RegisterNetEvent('Trucking:QuitJob')
AddEventHandler('Trucking:QuitJob', function() 
    local source = source
    local char = GetCharacter(source)

    if objList[char.id] then
        pool[char.id].OnJob = false
        pool[char.id].LastJob = os.time() + 900
        TriggerClientEvent('Trucking:QuitJob', source, pool[char.id].OnJob)
    end
end)

RegisterNetEvent('FillTrucking')
AddEventHandler('FillTrucking', function(plate, model, class)
    TriggerEvent('Inventory:Fetch', 'Vehicle', plate)
    Wait(100)
    exports['geo-inventory']:AddItem('Vehicle', plate, 'dolly', 100)
end)

RegisterNetEvent('Trucking:Next')
AddEventHandler('Trucking:Next', function(pos)
    local source = source
    local char = GetCharacter(source)
    if pool[char.id].OnJob then
        if Vdist4(pos, jobList[pool[char.id].CurrentID][1]) <= 20.0 then
            if exports['geo-inventory']:RemoveItem('Player', source, 'dolly', 1) then
                objList[char.id]:AddPay(900)
                pool[char.id].CurrentID = Random(#jobList)
                TriggerClientEvent('Trucking:NextJob', source, jobList[pool[char.id].CurrentID])
            end
        end
    end
end)

RegisterNetEvent('Trucking:PayMe')
AddEventHandler('Trucking:PayMe', function()
    local source = source
    local char = GetCharacter(source)

    if pool[char.id] then
        if objList[char.id]:Pay(source, 0) then
            TriggerClientEvent('Trucking:GetPay', source, objList[char.id].pay)
        end
    end
end)

RegisterNetEvent('Trucking:GetPay')
AddEventHandler('Trucking:GetPay', function()
    local source = source
    local char = GetCharacter(source)

    if pool[char.id] then
        TriggerClientEvent('Trucking:GetPay', source, objList[char.id].pay)
    end

    if objList[char.id] == nil then
        objList[char.id] = Jobs.Fetch('Trucking', char.id)
        if not objList[char.id] then return end
    end

    TriggerClientEvent('Trucking:InformRank', source, objList[char.id]:GetRank())
end)

RegisterNetEvent('Trucking:Promotion')
AddEventHandler('Trucking:Promotion', function()
    local source = source
    local char = GetCharacter(source)

    if objList[char.id]:IsNextRank() then
        local mth =objList[char.id]:TimeUntilNextRank()
        if mth <= 0 then
            objList[char.id]:CheckPromotion()
            TriggerClientEvent('Chat.Message', source, '[Trucking]', ('You have been promoted to a %s'):format(objList[char.id]:GetRank()), 'job')
            TriggerClientEvent('Trucking:InformRank', source, objList[char.id]:GetRank())
        else
            local num = string.format('%.2f', math.abs(mth / 60))
            TriggerClientEvent('Chat.Message', source, '[Trucking]', ('%s hours until your next promotion'):format(num), 'job')
        end
    end
end)