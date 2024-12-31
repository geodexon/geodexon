local objList = {}

local ranks = {
    {'Trainee', 0.55, 0},
    {'Junior Picker', 0.6, 300},
    {'Picker', 0.7, 3600},
    {'Senior Picker', 0.8, 10080},
    {'Assistant Manager', 0.9, 21000},
    {'Manager', 1.0, 36000}
}

Jobs:RegisterRanking('Winery', ranks)

RegisterNetEvent('Winery.Job')
AddEventHandler('Winery.Job', function(onJob)
    local source = source
    local char = GetCharacter(source)
    local time = exports['geo-sync']:GetTime()

    if onJob then
        if char.id then
            if not objList[char.id] then
                objList[char.id] = Jobs.Fetch('Winery', char.id)
                if not objList[char.id] then return end
            end
    
            if not (time.hour >= 5 and time.hour < 19) then
                TriggerClientEvent('Shared.Notif', source, 'Not during the night, jackass', 5000)
                return 
            end
    
            objList[char.id].job = 'phase_1'
            objList[char.id].grapes = 0
            objList[char.id].grapeAmount = 25

            if objList[char.id]:GetHours() <= 0 or GetUser(source).data.settings.jobinfo then
                TriggerClientEvent('Shared.Notif', source, "Go out to the back and pick some grapes for us.")
            end
    
            JobTime[char.id] = os.time()
            TriggerClientEvent('Help', source, 8)
            TriggerClientEvent('Winery.State', source, objList[char.id].job)
        end
    else
        if char.id and objList[char.id] then
            objList[char.id].job = 'none'
            TriggerClientEvent('Winery.State', source, objList[char.id].job)
        end
    end
end)

Task.Register('Winery.CollectGrape', function(source)
    local char = GetCharacter(source)
    if char.id and objList[char.id] and objList[char.id].job == 'phase_1' then
        if RateLimit('Grapes.'..char.id, 9000) then
            objList[char.id].grapes = objList[char.id].grapes + 1
            TriggerClientEvent('Shared.Notif', source, 'Collected '..objList[char.id].grapes..'/'..objList[char.id].grapeAmount..' grapes')

            if objList[char.id].grapes == objList[char.id].grapeAmount then
                objList[char.id].job = 'phase_2'
                TriggerClientEvent('Winery.State', source, objList[char.id].job)
                TriggerClientEvent('Shared.Notif', source, "Bring the grapes back to the front.")
            end

            exports['geo-rpg']:AddSkill(source, 'Botany', 0.1)
        end
    end
end)

RegisterNetEvent('Winery.Deliver')
AddEventHandler('Winery.Deliver', function()
    local char = GetCharacter(source)
    if char.id and objList[char.id] and objList[char.id].job == 'phase_2' then
        if Random(1, 5) == 1 then
            TriggerClientEvent('Shared.Notif', source, "Actually, I think we could use some more grapes")
            objList[char.id].job = 'phase_1'
            objList[char.id].grapes = 0
            objList[char.id].grapeAmount = Random(20, 50)
            TriggerClientEvent('Winery.State', source, objList[char.id].job)
        else
            TriggerClientEvent('Shared.Notif', source, "Okay, bring the grapes to the vat up the road")
            objList[char.id].job = 'phase_3'
            TriggerClientEvent('Winery.State', source, objList[char.id].job)
        end
    end
end)

RegisterNetEvent('Winery.Vat')
AddEventHandler('Winery.Vat', function()
    local source = source
    local char = GetCharacter(source)
    if char.id and objList[char.id] and objList[char.id].job == 'phase_3' then
        objList[char.id]:Pay(source, 3600)
        objList[char.id].job = 'none'
    end
end)