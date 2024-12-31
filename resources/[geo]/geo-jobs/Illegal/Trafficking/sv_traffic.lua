local objList = {}

Jobs:RegisterRanking('Trafficking.Legal', DefaultCiv)
Jobs:RegisterRanking('Trafficking.Illegal', DefaultCriminal)

RegisterNetEvent('Trafficking.Start', function(job)
    local source = source
    local char = GetCharacter(source)
    if char then
        if not objList[char.id] and RateLimit('Trafficking.'..job, 900000, true) then
            objList[char.id] = Jobs.Fetch('Trafficking.'..job, char.id)
            if not objList[char.id] then return end


            if objList[char.id]:GetHours() == 0 or GetUser(source).data.settings.jobinfo then
                local str = [[
                    Go to the destination marked and try to convince the person to take what you're offering
                ]]

                if job == 'Illegal' then str = str..'. You will need to take some risk' end
                TriggerClientEvent('Shared.Notif', source, str, 10000)
            end

            RateLimit('Trafficking.'..job, 900000)
            objList[char.id]:CheckPromotion()
            local time = os.time()
            JobTime[char.id] = time
            objList[char.id].type = job
            objList[char.id].job = 'phase_1'
            objList[char.id].delivered = 0

            objList[char.id].options = TraffickingOptions(objList[char.id].type)
            TriggerClientEvent('Help', source, 10)
            TriggerClientEvent('Trafficking.Start', source)
        else
            TriggerClientEvent('Shared.Notif', source, 'Come back later')
        end
    end
end)

RegisterNetEvent('Trafficking.Quit', function()
    local source = source
    local char = GetCharacter(source)
    if char then
        if objList[char.id] then
            objList[char.id] = nil
        end

        TriggerClientEvent('Trafficking.SetStage', source, 'none')
    end
end)

local lastMsg = {}
RegisterNetEvent('Trafficking.Interaction', function(id, pos)
    local source = source
    local val = (Random(100) <= Trafficking.Options[id].chance)
    local char = GetCharacter(source)
    if char and objList[char.id] then
        if objList[char.id].job ~= 'phase_1' then return end
        local found = false
        for k,v in pairs(objList[char.id].options) do
            if v == id then
                found = true
                break
            end
        end

        lastMsg[source] = Trafficking.Options[id].name

        if not found then return end
        if val then
            objList[char.id].delivered = objList[char.id].delivered + 1

            local chance = Trafficking.Options[id].chance
            local skillGain = 0
            if chance > 90 then
                skillGain = 1
            elseif chance > 90 then
                skillGain = 2
            elseif chance > 80 then
                skillGain = 3
            elseif chance > 70 then
                skillGain = 4
            elseif chance > 60 then
                skillGain = 5
            elseif chance > 50 then
                skillGain = 6
            elseif chance > 40 then
                skillGain = 10
            elseif chance > 30 then
                skillGain = 40
            elseif chance > 20 then
                objList[char.id].risk = true
                skillGain = 60
            elseif chance > 10 then
                objList[char.id].risk = true
                skillGain = 80
            elseif chance > 0 then
                objList[char.id].risk = true
                skillGain = 100
            end

            exports['geo-rpg']:AddSkill(source, 'Persuasion', skillGain)
        else
            if Trafficking.Options[id].criminal then
                if Random(5) == 1 then
                    if objList[char.id].callpolice then
                        TriggerClientEvent('Trafficking.Holdup', source)
                        TriggerEvent('Dispatch', {
                            code = '10-17',
                            title = 'Threats',
                            location = pos.position,
                    
                            time =  os.date('%H:%M EST'),
                            info = {
                                {
                                    icon = 'location',
                                    text = pos.location,
                                    location = false
                                },
                            }
                        })
                        objList[char.id].callpolice = false
                    else
                        TriggerClientEvent('Shared.Notif', source, "Act like that and we'll call the cops")
                        objList[char.id].callpolice = true
                    end
                    goto skip
                end
            end

            TriggerClientEvent('Shared.Notif', source, 'Delivery Rejected')
        end
    
        ::skip::

        if objList[char.id].delivered < 5 then
            objList[char.id].options = TraffickingOptions(objList[char.id].type)
            TriggerClientEvent('Shared.Notif', source, 'Deliver here next')
            TriggerClientEvent('Trafficking.Start', source)
        else
            if Random(20) >= 15 then
                exports['geo-inventory']:ReceiveItem('Player', source, 'oxy', 5)
            end
            TriggerClientEvent('Shared.Notif', source, "you done")
            objList[char.id].job = 'phase_2'
            TriggerClientEvent('Trafficking.SetStage', source, 'phase_2')
        end
    end
end)

RegisterNetEvent('Trafficking.Pay', function()
    local source = source
    local char = GetCharacter(source)
    if char then
        if objList[char.id] then
            local pay = 1800
            if objList[char.id].type == 'Illegal' and objList[char.id].risk ~= true then
                pay = 300
            end

            if objList[char.id]:Pay(source, 1800) then
                TriggerClientEvent('Trafficking.SetStage', source, 'none')
                if objList[char.id].type == 'Illegal' and objList[char.id].risk ~= true then
                    TriggerClientEvent('Shared.Notif', source, 'Not enough risk taken, pay reduced', 5000)
                end
                objList[char.id] = nil
            end
        end
    end
end)

Task.Register('Trafficking.GetOptions', function(source)
    local char = GetCharacter(source)
    if char then
        if objList[char.id] then
            return objList[char.id].options
        end
    end
end)

Task.Register('Trafficking.PoliceNotif', function(source, pNetID)
    if lastMsg[source] then
        local ped = NetworkGetEntityFromNetworkId(pNetID)
        Entity(ped).state.policenotif = lastMsg[source]
    end
end)

function TraffickingOptions(pJob)
    local options = {}
    while #options < 3 do
        local id = Random(#Trafficking.Options)
        local found = false
        for k,v in pairs(options) do
            if v == id then
                found = true
            end
        end

        if not found and CanDeliverHere(pJob, id) then
            table.insert(options, id)
        end

        Wait(0)
    end

    return options
end

function CanDeliverHere(pJob, id)
    if pJob == 'Legal' then
        if Trafficking.Options[id].criminal == true then
            return false
        end
    end

    return true
end