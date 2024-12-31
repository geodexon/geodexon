local closeQuests = {}
local questPeds = {}
local questBlips = {}
local activeBlips = {}
local activeRoute
questFlags = {}

RegisterNetEvent('Quests.Get')
AddEventHandler('Quests.Get', function(flags)

    for k,v in pairs(questBlips) do
        RemoveBlip(v)
    end

    for k,v in pairs(questPeds) do
        exports['geo-interface']:RemovePed(questPeds[k])
        questPeds[k] = nil
    end

    closeQuests = {}
    questPeds = {}
    questBlips = {}
    questFlags = flags
    
    for k,v in pairs(questFlags) do
        if v.complete == 0 and Quests[k].expired ~= true then
            TriggerEvent('Quests.Start', k, v.stage)
        end
    end

    local count = 0
    for k,v in pairs(Quests) do
        if CanAccessQuest(v.quest_id) and v.location ~= nil then
            count = count + 1
        end
    end

    LoadBlips()
    TriggerEvent('Shared.Notif', 'You have '..count..' quest(s) currently available', 5000)
end)

Menu.CreateMenu('Quests', 'Quests')
RegisterCommand('quests', function()
    if not Menu.CurrentMenu then
        Menu.OpenMenu('Quests')
        while Menu.CurrentMenu == 'Quests' do
            Wait(0)
            for k,v in pairs(questFlags) do
                if v.complete == 0 then
                    if Menu.Button(Quests[k].name) then
                        if activeRoute == k then
                            SetBlipRoute(activeBlips[k], false)
                            activeRoute = nil
                        else
                            SetBlipRoute(activeBlips[k], true)
                            SetBlipRouteColour(activeBlips[k], 8)
                            activeRoute = k
                        end
                    end
                end
            end
            Menu.Display()
        end
    end
end)

RegisterNetEvent('Quests.Add')
AddEventHandler('Quests.Add', function(questID)
    questFlags[questID] = {stage = 1, complete = 0}
    closeQuests[questID] = nil
    LoadBlips()

    if Quests[questID]['stages'][1].location then
        SetBlipRoute(activeBlips[questID], true)
        SetBlipRouteColour(activeBlips[questID], 8)
        activeRoute = questID

        CreateThread(function()
            exports['geo-hud']:Radar(true)
            SetBlipFlashes(activeBlips[questID], true)
            Wait(5000)
            exports['geo-hud']:Radar(false)
            SetBlipFlashes(activeBlips[questID], false)
        end)
    end
    TriggerEvent('Quests.Start', questID, questFlags[questID].stage)
end)

RegisterNetEvent('Quests.Set')
AddEventHandler('Quests.Set', function(questID, data)
    if questFlags[questID] == nil then
         questFlags[questID] = data 
    else
        if data then
            for k,v in pairs(data) do
                questFlags[questID][k] = v
            end
        else
            if questFlags[questID].ped  then
                if questFlags[questID].ped then
                    exports['geo-interface']:RemovePed(questFlags[questID].ped, true)
                    questFlags[questID].ped = nil
                end
            end
            questFlags[questID] = nil
        end
    end
    closeQuests[questID] = nil


    if data then
        TriggerEvent('Quests.Start', questID, questFlags[questID].stage)
    end
    LoadBlips()
end)

RegisterNetEvent('Quest.Blip')
AddEventHandler('Quest.Blip', function(questID, stage)
    SetBlipRoute(activeBlips[questID], true)
    activeRoute = questID

    CreateThread(function()
        exports['geo-hud']:Radar(true)
        SetBlipFlashes(activeBlips[questID], true)
        Wait(5000)
        exports['geo-hud']:Radar(false)
        SetBlipFlashes(activeBlips[questID], false)
    end)
end)

CreateThread(function()
    while true do
        Wait(1000)
        GetNearbyQuests()
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        local count = 0

        if questFlags['tutorial'] and questFlags['tutorial'].complete == 1 then
            return
        end

        for k,v in pairs(closeQuests) do
            if v.quest_id == 'tutorial' then
                if Vdist3(GetEntityCoords(Shared.Ped), vec(v.location.x, v.location.y, v.location.z)) <= 2.0 then
                    Shared.WorldText('[Select (Default: Left Alt)] Quest: '..v.name, vec(v.location.x, v.location.y, v.location.z))
                    count = count + 1
                end
            end
        end
        if count == 0 then
            Wait(1000)
        end
    end
end)

function GetNearbyQuests()
    local time = GetGameTimer()
    for k,v in pairs(Quests) do
        if questFlags[v.quest_id] == nil then
            if CanAccessQuest(v.quest_id) and v.location ~= nil then
                local dist = Vdist3(GetEntityCoords(Shared.Ped), vec(v.location.x, v.location.y, v.location.z))
                if dist <= 50.0 and closeQuests[k] == nil then
                    closeQuests[k] = v
                    if v.ped then
                        questPeds[k] = exports['geo-interface']:InterfacePed({
                            model = v.ped,
                            position = vec(v.location.x, v.location.y, v.location.z, v.location.w),
                            title = 'Quest: '..v.name,
                            event = 'QuestStart',
                            params = {v.quest_id}
                        })
                        
                        --exports['geo-jobs']:CreateMissionPed(v.ped, vec(v.location.x, v.location.y, v.location.z, v.location.w), true, true, true)
                    end
                else
                    if dist > 50.0 and closeQuests[k] then
                        if questPeds[k] then
                            exports['geo-interface']:RemovePed(questPeds[k], true)
                            questPeds[k] = nil
                        end
        
                        closeQuests[k] = nil
                    end
                end
            else
                if questPeds[k] then
                    exports['geo-interface']:RemovePed(questPeds[k], true)
                    questPeds[k] = nil
                end
            end
        end
    end
end

AddEventHandler('QuestStart', function(data, questID)
    for k,v in pairs(closeQuests) do
        if v.quest_id == questID then
            if questPeds[k] then
                exports['geo-interface']:RemovePed(questPeds[k], true)
                questPeds[k] = nil
                break
            end
        end
    end
    Task.Run('Quest.Start', questID)
end)

local _req = {
    ['isPolice'] = function()
        return MyCharacter and exports['geo-es']:IsPolice(MyCharacter.id)
    end,

    ['noCiv'] = function()
        return questFlags['tutorial.civ'] == nil
    end,

    ['noCrim'] = function()
        return questFlags['tutorial.crim'] == nil
    end
}

function CanAccessQuest(questID)
    if Quests[questID] and Quests[questID].requires then
        if questFlags[Quests[questID].requires] and questFlags[Quests[questID].requires].complete == 0 then return false end 
        if not questFlags[Quests[questID].requires] then return false end
    end
    if Quests[questID].item and not exports['geo-inventory']:HasItemKey(Quests[questID].item) then return false end
    if Quests[questID].needflag and not _req[Quests[questID].needflag]() then return false end
    if Quests[questID].expired == true then return false end
    if Quests[questID] and not questFlags[questID] then return true end
end

local tasks = {
    ['goto'] = function(questID, stage)
        if Vdist4(GetEntityCoords(Shared.Ped), vec(Quests[questID]['stages'][stage]['location'].x, Quests[questID]['stages'][stage]['location'].y, Quests[questID]['stages'][stage]['location'].z)) <= 20.0 then
            return true
        else
            Wait(500)
        end
    end,
    ['interact'] = function(questID, stage)
        if questFlags[questID].ped == nil then
            if Vdist3(GetEntityCoords(Shared.Ped), vec(Quests[questID]['stages'][stage]['location'].x, Quests[questID]['stages'][stage]['location'].y, Quests[questID]['stages'][stage]['location'].z)) <= 100.0 then
                questFlags[questID].ped = exports['geo-interface']:InterfacePed({
                    model = Quests[questID]['stages'][stage]['ped'],
                    position = vec(Quests[questID]['stages'][stage]['location'].x, Quests[questID]['stages'][stage]['location'].y, Quests[questID]['stages'][stage]['location'].z, Quests[questID]['stages'][stage]['location'].w),
                    title = 'Quest: '..Quests[questID]['stages'][stage].text,
                    event = 'QuestContinue',
                    params = {questID, stage}
                })
            else
                Wait(500)
            end
        else
            if Vdist3(GetEntityCoords(Shared.Ped), vec(Quests[questID]['stages'][stage]['location'].x, Quests[questID]['stages'][stage]['location'].y, Quests[questID]['stages'][stage]['location'].z)) > 100.0 then
                exports['geo-interface']:RemovePed(questFlags[questID].ped, true)
                questFlags[questID].ped = nil
            else
                Wait(500)
            end
        end
    end
}

AddEventHandler('QuestContinue', function(data, questID, stage)
    TriggerServerEvent('Quest.NextStage', questID, stage)
end)

AddEventHandler('Quests.Start', function(questID, stage)
    if questFlags[questID].complete == 1 and questFlags[questID].ped then
        local ped = questFlags[questID].ped
        SetEntityAsNoLongerNeeded(questFlags[questID].ped)
        CreateThread(function()
            while IsEntityOnScreen(ped) do
                Wait(1000)
            end
            DeleteEntity(ped)
        end)
        questFlags[questID].ped = nil
    end

    if Quests[questID] and Quests[questID]['stages'][stage] then
        while questFlags[questID] and questFlags[questID].stage == stage do
            Wait(0)

            if tasks[Quests[questID]['stages'][stage]['task']](questID, stage) then
                TriggerServerEvent('Quest.NextStage', questID, stage)
                return
            end
        end
    end
end)

function LoadBlips()

    for k,v in pairs(activeBlips) do
        RemoveBlip(v)
    end

    activeBlips = {}
    for k,v in pairs(questFlags) do
        if v.complete == 0 and Quests[k]['stages'][v.stage].location and Quests[k].expired ~= true then
            local loc = Quests[k]['stages'][v.stage].location
            activeBlips[k] = AddBlipForCoord(vec(loc.x, loc.y, loc.z))
            SetBlipSprite(activeBlips[k], 66)
            SetBlipColour(activeBlips[k], 8)
            SetBlipScale(activeBlips[k], 1.0)
            BeginTextCommandSetBlipName("STRING");
            AddTextComponentString(Quests[k].name)
            EndTextCommandSetBlipName(activeBlips[k])
        end
    end

    for k,v in pairs(questBlips) do
        RemoveBlip(v)
    end

    questBlips = {}
    for k,v in pairs(Quests) do
        if CanAccessQuest(v.quest_id) and questBlips[v.quest_id] == nil and v.location ~= nil and Quests[v.quest_id].expired ~= true then
            questBlips[v.quest_id] = AddBlipForCoord(vec(v.location.x, v.location.y, v.location.z))
            SetBlipSprite(questBlips[v.quest_id], 480)
            SetBlipScale(questBlips[v.quest_id], 0.8)
            SetBlipAsShortRange(questBlips[v.quest_id], true)
            BeginTextCommandSetBlipName("STRING");
            AddTextComponentString('Quest')
            EndTextCommandSetBlipName(questBlips[v.quest_id])
        else
            if questBlips[v.quest_id] then
                questBlips[v.quest_id] = RemoveBlip(questBlips[v.quest_id])
            end

            if closeQuests[k] then
                closeQuests[k] = nil
            end
        end
    end
end


RegisterNetEvent('Quest.PlayDialogue')
AddEventHandler('Quest.PlayDialogue', function(dialogue)
    PlayDialogue(dialogue)
end)

function PlayDialogue(dialogue)
    if dialogue then
        CreateThread(function()
            for _,dia in pairs(dialogue) do
                TriggerEvent('Shared.Notif', dia[1], dia[2], true)
                Wait(dia[2])
            end
        end)
    end
end

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        for k,v in pairs(questPeds) do
            DeleteEntity(v)
        end

        for k,v in pairs(questFlags) do
            if v.ped then
                DeleteEntity(v.ped)
            end
        end
    end
end)

function QuestStatus(questID)
    return questFlags[questID] or {}
end

exports('QuestStatus', QuestStatus)