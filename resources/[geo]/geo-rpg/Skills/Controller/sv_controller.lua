local dev = GetConvar('sv_dev', 'false') == 'true'

function AddSkill(source, skillID, amount)
    amount = math.floor(amount)
    local char = GetCharacter(source)
    char.skills[skillID] = math.floor(char.skills[skillID] ~= nil and char.skills[skillID] + amount or amount)
    if char.skills[skillID] > (RPG.Levels[RPG.MaxLevels[skillID] or 30]) then
        char.skills[skillID] =  RPG.Levels[(RPG.MaxLevels[skillID] or 30)]
    end

    if dev then
        local level = GetLevel(char.skills[skillID])
        print(Format('[Debug] [%s] Added %s XP, To Next Level: %s, Current Level: %s, Same %s Times', skillID, amount, RPG.Levels[level + 1] - char.skills[skillID], level, (RPG.Levels[level + 1] - char.skills[skillID]) / amount))
    end

    UpdateChar(source, 'skills', char.skills)
    TriggerClientEvent('Skill.Update', source, skillID, char.skills[skillID])
    --TriggerClientEvent('GatheringXP', source, amount..' '..skillID, GetEntityCoords(GetPlayerPed(source)), false)
    SQL('UPDATE characters SET skills = json_set(skills, ?, ?) WHERE id = ?', '$.'..skillID, char.skills[skillID], char.id)
end

function RemoveSkill(source, skillID, amount)
    local char = GetCharacter(source)
    char.skills[skillID] = (char.skills[skillID] ~= nil and (char.skills[skillID] - amount > 0 and char.skills[skillID] - amount or 0) or 0)
    UpdateChar(source, 'skills', char.skills)
    TriggerClientEvent('Skill.Update', source, skillID, char.skills[skillID])
    SQL('UPDATE characters SET skills = json_set(skills, ?, ?) WHERE id = ?', '$.'..skillID, char.skills[skillID], char.id)
end

RegisterCommand('_setskill', function(source, args)
    local char = GetCharacter(source)
    if char.username == nil then return end
    local skillID = args[1]


    char.skills[skillID] = RPG.Levels[tonumber(args[2])]
    UpdateChar(source, 'skills', char.skills)
    TriggerClientEvent('Skill.Update', source, skillID, char.skills[skillID])
    --TriggerClientEvent('GatheringXP', source, amount..' '..skillID, GetEntityCoords(GetPlayerPed(source)), false)
    SQL('UPDATE characters SET skills = json_set(skills, ?, ?) WHERE id = ?', '$.'..skillID, char.skills[skillID], char.id)
end)

exports('AddSkill', AddSkill)
exports('RemoveSkill', RemoveSkill)