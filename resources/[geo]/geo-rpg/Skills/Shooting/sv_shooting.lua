local ranges = {false, false, false, false, false, false, false, false}
local refs = {}

Task.Register('Ammunation.Range', function(source)
    local found = false
    for k,v in pairs(ranges) do
        if v == false then
            ranges[k] = source
            found = k
            break
        end
    end

    if not found then
        return
    end
    
    if exports['geo-eco']:DebitDefault(GetCharacter(source), 50, 'Range Rental') then
        refs[source] = uuid()
        return {refs[source], found}
    end

    RemoveRange(source)
end)

function RemoveRange(src)
    for k,v in pairs(ranges) do
        if v == src then
            ranges[k] = false
            break
        end
    end
end

AddEventHandler('playerDropped', function()
    local source = source
    RemoveRange(source)
end)

RegisterNetEvent('Shooting.Leave')
AddEventHandler('Shooting.Leave', function(points, ref)
    local source = source
    RemoveRange(source)

    if refs[source] == ref and points <= 150 then
        if (GetCharacter(source).skills.Shooting or 0) >= RPG.Levels[12] then
            TriggerClientEvent('Shared.Notif', source, "We can't teach you anything else here", 5000)
            return
        end
        
        AddSkill(source, 'Shooting', points)
        if points > 0 then
            if GetCharacter(source).Duty == 'Police' then
                TriggerEvent('SetQuestTask', source, 'police_range_target', points)
            end
            TriggerClientEvent('Shared.Notif', source, 'Gained '..points..' Shooting XP', 5000)
        end
    end
end)

local shots = {}
RegisterNetEvent('Ped.Shot')
AddEventHandler('Ped.Shot', function()
    local source = source
    shots[source] = shots[source] or 0
    shots[source] = shots[source] + 1
end)

CreateThread(function()
    while true do
        Wait(60000)
        local count = 0
        for k,v in pairs(shots) do
            AddSkill(k, 'Shooting', v > 100 and 100 or v)
            count = count + 1
        end

        if count > 0 then
            shots = {}
            Console('[RPG: Skill - Shooting]', 'Processed '..count.. ' requests')
        end
    end
end)