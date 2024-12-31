local questFlags = {}
local DefaultData = {count = 0}

local itemSpawn = {
    ['police.range'] = function(char, item)
        item.Data.firstname = char.first
        item.Data.lastname = char.last
        item.Data.reason = 'Range Satisfactory'
        return item
    end,

    ['police.arrests1'] = function(char, item)
        item.Data.firstname = char.first
        item.Data.lastname = char.last
        item.Data.reason = 'Got 5 Arrests'
        return item
    end,

    ['police.ticket1'] = function(char, item)
        item.Data.firstname = char.first
        item.Data.lastname = char.last
        item.Data.reason = 'Got 5 Tickets'
        return item
    end
}

RegisterNetEvent('Quests.Get')
AddEventHandler('Quests.Get', function()
    local source = source
    local char = GetCharacter(source)
    if char then
        GetQuests(char)
    end
end)

RegisterNetEvent('Quest.NextStage')
AddEventHandler('Quest.NextStage', function(questID, stage)
    local source = source
    local allow = false

    if questFlags[source][questID]['stage'] ~= stage then
        TriggerClientEvent('Quests.Set', source, questID, {stage = stage, complete = 0})
        return
    end

    local data = Quests[questID]['stages'][stage]
    local rewards = Quests[questID]['rewards']

    local task = data['task']
    if task == 'goto' or task == 'interact' then
        allow = true
    end

    if Quests[questID].expired then
        return
    end

    if data.itemcount then
        if questFlags[source][questID].data.count < data.itemcount then
            allow = false
            TriggerClientEvent('Shared.Notif', source, 'Current Quest Status: '..questFlags[source][questID].data.count..' / '..data.itemcount..' '..exports['geo-inventory']:GetItemName(data.item)..'(s)', 5000)
            goto fail
        end
    end

    if data.taskcount then
        if questFlags[source][questID].data.count < data.taskcount then
            allow = false
            TriggerClientEvent('Shared.Notif', source, 'Current Quest Status: '..questFlags[source][questID].data.count..' / '..data.taskcount..' '..data.taskdisplay, 5000)
            goto fail
        end
    end

    if rewards and Quests[questID]['stages'][stage + 1] == nil then
        if not exports['geo-inventory']:CanFit('Player', source, rewards[1], rewards[2]) then
            TriggerClientEvent('Shared.Notif', source, Format('You don\'t have room for %sx %s', rewards[2], exports['geo-inventory']:GetItemName(rewards[1])), 10000)
            goto fail
        end
    end

    if data['items'] then
        if not exports['geo-inventory']:RemoveItem('Player', source, data['items'][1], data['items'][2]) then
            TriggerClientEvent('Shared.Notif', source, Format('You need %sx %s', data['items'][2], exports['geo-inventory']:GetItemName(data['items'][1])), 10000)
            goto fail
        end
    end

    if allow then
        local char = GetCharacter(source)

        if Quests[questID]['stages'][stage].dialogue then
            TriggerClientEvent('Quest.PlayDialogue', source, Quests[questID]['stages'][stage].dialogue)
        end

        if Quests[questID]['stages'][stage + 1] == nil then

            if rewards then
                local item = exports['geo-inventory']:InstanceItem(rewards[1])
                item.Amount = rewards[2]

                if itemSpawn[questID] then
                    item = itemSpawn[questID](char, item)
                end

                if not exports['geo-inventory']:AddItem('Player', source, rewards[1], rewards[2], item) then
                    TriggerClientEvent('Shared.Notif', char.serverid, 'You are not capable of holding the quest rewards')
                    TriggerClientEvent('Quests.Set', source, questID, questFlags[source][questID])
                    return
                end
            end

            if Quests[questID].repeatable then
                SQL('DELETE FROM quests WHERE qid = ? and cid = ?', questID, char.id)
                TriggerClientEvent('Quests.Set', char.serverid, questID, nil)
                questFlags[source][questID] = nil
            else
                SQL('UPDATE quests SET complete = 1 WHERE qid = ? and cid = ?', questID, char.id)
                TriggerClientEvent('Quests.Set', char.serverid, questID, {stage = stage + 1, complete = 1})
                questFlags[source][questID] = {stage = stage + 1, complete = 1, data = New(DefaultData)}
                Log('Quest', {type = 'complete', cid = char.id, user = char.user, questID = questID})
            end
            TriggerClientEvent('Shared.Notif', char.serverid, 'Quest: '..Quests[questID].name..' has been completed', 5000, true)
            TriggerClientEvent('Quest.Done', char.serverid, questID)
            TriggerClientEvent('Shared.PlaySounds', source, 'quest_end.wav', 0.2)
        else
            if data['notif'] then
                TriggerClientEvent('Shared.Notif', char.serverid, data['notif'], 10000)
            end
            SQL('UPDATE quests SET stage = ?, data = ? WHERE qid = ? and cid = ?', stage + 1, json.encode(New(DefaultData)), questID, char.id)
            questFlags[source][questID] = {stage = stage + 1, complete = 0, data = New(DefaultData)}
            TriggerClientEvent('Quests.Set', char.serverid, questID, {stage = stage + 1, complete = 0, data = New(DefaultData)})
            TriggerClientEvent('Quest.Blip', char.serverid, questID, stage + 1)
        end

        return
    end

    ::fail::
    TriggerClientEvent('Quests.Set', source, questID, {stage = stage, complete = 0, data = questFlags[source][questID].data})
end)

AddEventHandler('StartQuest', function(source, questID)
    if Quests[questID] and CanAccessQuest(source, questID) then
        StartQuest(source, questID)
    end
end)

AddEventHandler('Login', function(char)
   GetQuests(char)
end)

Task.Register('Quest.Start', function(source, questID)
    if Quests[questID] and CanAccessQuest(source, questID) then
        StartQuest(source, questID)
    end
end)

function CanAccessQuest(source, questID)
    if Quests[questID] and Quests[questID].requires then
        if questFlags[source][Quests[questID].requires] and questFlags[source][Quests[questID].requires].complete == 1 then return true end 
        if not questFlags[source][Quests[questID].requires] then return false end
    end

    if Quests[questID].item and not exports['geo-inventory']:HasItemKey('Player', source, Quests[questID].item) then return false end
    if Quests[questID].expired then return false end
    if Quests[questID] and not questFlags[source][questID] then return true end
end

function StartQuest(source, questID)
    local char = GetCharacter(source)

    Console('[Quests]', GetName(char)..' ['..char.id..'] Started Quest: '..questID)
    questFlags[source][questID] = {stage = 1, complete = 0, data = New(DefaultData)}
    SQL('INSERT INTO quests (cid, qid, data) VALUES (?, ?, ?)', char.id, questID, json.encode(New(DefaultData)))
    TriggerClientEvent('Quests.Add', source, questID)
    TriggerClientEvent('Shared.PlaySounds', source, 'quest_start.wav', 0.2)
    if Quests[questID].dialogue then
        TriggerClientEvent('Quest.PlayDialogue', source, Quests[questID].dialogue)
    end
end

AddEventHandler('ReceiveItem', function(source, item, amount)
    for k,v in pairs(questFlags[source]) do
        if Quests[k]['stages'][v.stage] and Quests[k]['stages'][v.stage].itemcount and item == Quests[k]['stages'][v.stage].item and questFlags[source][k].data.count < Quests[k]['stages'][v.stage].itemcount then
            questFlags[source][k].data.count = questFlags[source][k].data.count + amount
            TriggerClientEvent('Shared.Notif', source, 'Current Quest Status: '..questFlags[source][k].data.count..' / '..Quests[k]['stages'][v.stage].itemcount..' '..exports['geo-inventory']:GetItemName(Quests[k]['stages'][v.stage].item)..'(s)', 5000)
            SQL('UPDATE quests SET data = ? WHERE qid = ? and cid = ?', json.encode(questFlags[source][k].data), k, GetCharacter(source).id)
        end
    end

    if item == 'propane_torch' and CanAccessQuest(source, 'comrob_propanetorch') then
        StartQuest(source, 'comrob_propanetorch')
    elseif item == 'burner_phone' and CanAccessQuest(source, 'burner_onstart') then
        StartQuest(source, 'burner_onstart')
    end
end)

AddEventHandler('AddQuestTask', function(source, item, amount)
    for k,v in pairs(questFlags[source]) do
        if questFlags[source][k].complete == 0 and Quests[k]['stages'][v.stage].taskcount and item == Quests[k]['stages'][v.stage].taskname and questFlags[source][k].data.count < Quests[k]['stages'][v.stage].taskcount then
            questFlags[source][k].data.count = questFlags[source][k].data.count + amount
            TriggerClientEvent('Shared.Notif', source, 'Current Quest Status: '..questFlags[source][k].data.count..' / '..Quests[k]['stages'][v.stage].taskcount, 5000)
            SQL('UPDATE quests SET data = ? WHERE qid = ? and cid = ?', json.encode(questFlags[source][k].data), k, GetCharacter(source).id)
        end
    end
end)

AddEventHandler('SetQuestTask', function(source, item, amount)
    for k,v in pairs(questFlags[source]) do
        if questFlags[source][k].complete == 0 and Quests[k]['stages'][v.stage].taskcount and item == Quests[k]['stages'][v.stage].taskname and questFlags[source][k].data.count < Quests[k]['stages'][v.stage].taskcount then
            questFlags[source][k].data.count = amount
            TriggerClientEvent('Shared.Notif', source, 'Current Quest Status: '..questFlags[source][k].data.count..' / '..Quests[k]['stages'][v.stage].taskcount, 5000)
            SQL('UPDATE quests SET data = ? WHERE qid = ? and cid = ?', json.encode(questFlags[source].data), k, GetCharacter(source).id)
        end
    end
end)

function GetQuests(char)
    Wait(2000)
    local flags = SQL('SELECT * from quests WHERE cid = ?', char.id)
    questFlags[char.serverid] = {}
    for k,v in pairs(flags) do
        questFlags[char.serverid][v.qid] = {
            stage = v.stage,
            complete = v.complete,
            data = json.decode(v.data)
        }
    end
    TriggerClientEvent('Quests.Get', char.serverid, questFlags[char.serverid])
end

AddEventHandler('onResourceStart', function(res)
    if res == GetCurrentResourceName() then
        for k,v in pairs(GetPlayers()) do
            GetQuests(GetCharacter(tonumber(v)))
        end
    end
end)

exports('CanAccessQuest', CanAccessQuest)
exports('StartQuest', StartQuest)
exports('GetQuest', function(source, quest)
    return questFlags[source][quest] and questFlags[source][quest].complete == 1
end)