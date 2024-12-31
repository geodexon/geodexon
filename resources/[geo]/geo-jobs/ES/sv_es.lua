local interval = 900000
local objList = {}

Jobs:RegisterRanking('Police', DefaultCiv)
Jobs:RegisterRanking('EMS', DefaultCiv)
Jobs:RegisterRanking('DOJ', DefaultCiv)

CreateThread(function()
    while true do
        Wait(interval)
        local time = os.time()
        local count = 0
        local total = 0

        for k,v in pairs(GetPlayers()) do
            v = tonumber(v)
            local char = GetCharacter(v)
            if char then
                local job = char.Duty
                if job == 'Police' or job == 'EMS' or job == 'DOJ' then
                    if not objList[char.id] then
                        objList[char.id] = Jobs.Fetch(job, char.id)
                        if not objList[char.id] then return end
                        objList[char.id]:CheckPromotion()
                    end

                    if JobTime[char.id] == nil then JobTime[char.id] = time - interval end
                    local amount = objList[char.id]:AddPay(900)
                    total = total + amount
                    count = count + 1
                end
            end
        end

        if count > 0 then
            Console('[Emergency Service Pay]', Format('Processed %s requests', count))
            exports['geo-guilds']:RemoveGuildFunds('CITY', total)
        end
    end
end)

RegisterNetEvent('ES.PayMe')
AddEventHandler('ES.PayMe', function()
    local source = source
    local char = GetCharacter(source)
    if objList[char.id] then
        objList[char.id]:Pay(source, 0)
    end
end)

AddEventHandler('Logout', function(char)
    if objList[char.id] and (char.Duty == 'Police' or char.Duty == 'EMS' or job == 'DOJ') then
        objList[char.id]:AddPay(interval / 1000)
        objList[char.id] = nil
    end
end)

Task.Register('ES.Pay', function(source)
    local char = GetCharacter(source)

    if not objList[char.id] then
        local job = char.Duty
        if job == 'Police' or job == 'EMS' or job == 'DOJ' then
            objList[char.id] = Jobs.Fetch(job, char.id)
            if not objList[char.id] then return end
            if JobTime[char.id] == nil then JobTime[char.id] = os.time() - interval end
        end
    end

    if objList[char.id] then
       return objList[char.id].pay
    end

    return 0
end)