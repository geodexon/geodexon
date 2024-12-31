local craftingLogs = {}
local CraftingSkills = {
    {
        SkillID = 1,
        Name = 'Synthesis',
        Craftsmanship = 1.0
    },
    {
        SkillID = 2,
        Name = 'Temper',
        Control = 1.0
    },
}

Task.Register('Craft', function(source, job, item, items)
    item = item + 1
    if not RateLimit('Craft'..source, 1000) then
        TriggerClientEvent('Shared.Notif', source, 'Slow Down')
        return
    end

    local itemsToRemove = {}
    for k,v in pairs(Crafting.Lists[job][item].Requirements) do
        if items[k][1] + items[k][2] == v[2] then
            if items[k][1] > 0 then
                itemsToRemove[v[1]] = items[k][1]
            end

            if items[k][2] > 0 then
                itemsToRemove[v[1]..'_hq'] = items[k][2]
            end
        else
            return
        end
    end

    for k,v in pairs(itemsToRemove) do
        if exports['geo-inventory']:AmountKey('Player', source, k) < v then
            TriggerClientEvent('Shared.Notif', source,'no')
            return false
        end
    end

    if exports['geo-inventory']:CanFit('Player', source, Crafting.Lists[job][item].Item, Crafting.Lists[job][item].Amount) then
        for k,v in pairs(itemsToRemove) do
            exports['geo-inventory']:RemoveItem('Player', source,  k,  v)
        end
        exports['geo-inventory']:AddItem('Player', source, Crafting.Lists[job][item].Item, Crafting.Lists[job][item].Amount)
        return true
    else
        return false
    end
end)

Task.Register('Repair', function(source, item)
    local key
    for k,v in pairs(exports['geo-inventory']:GetInventory('Player', source)) do
        if v.ID == item then

            if v.Data.Equipped and v.Data.Armor then
                TriggerClientEvent('Shared.Notif', source, 'How are you going to fix something you are wearing?', 5000)
                return false
            end

            key = v.Key
            break
        end
    end

    if not key then return false end
    local _item = exports['geo-inventory']:GetItem(key).Repair
    for k,v in pairs(_item) do
        if exports['geo-inventory']:AmountKey('Player', source, v[1]) < v[2] then
            TriggerClientEvent('Shared.Notif', source,'no')
            return false
        end
    end

    for k,v in pairs(_item) do
        exports['geo-inventory']:RemoveItem('Player', source,  v[1], v[2])
    end

    exports['geo-inventory']:Repair('Player', source, item)
    return true
end)

local isCrafting = {}
Task.Register('StartCraft', function(source, job, index, items)
    local char = GetCharacter(source)
    local item = GetMainHand(char)
    if item == nil or (item ~= nil and exports['geo-inventory']:GetItem(item.Key).Skill ~= job) then
        TriggerClientEvent('Shared.Notif', source, 'This is the wrong tool')
        return false
    end

    index = tonumber(index)
    index = index + 1

    if GetLevel(char.skills[job] or 0) < Crafting.Lists[job][index].Level then
        TriggerClientEvent('Shared.Notif', source, 'You are unable to make this')
        return false
    end

    local itemsToRemove = {}
    local total = 0
    local hqToal = 0

    for k,v in pairs(Crafting.Lists[job][index].Requirements) do
        if items[k][1] + items[k][2] == v[2] then
            if items[k][1] > 0 then
                itemsToRemove[v[1]] = items[k][1]
            end

            if items[k][2] > 0 then
                itemsToRemove[v[1]..'_hq'] = items[k][2]
                hqToal = hqToal + items[k][2]
            end
            total = total + v[2]
        else
            return
        end
    end

    for k,v in pairs(itemsToRemove) do
        if exports['geo-inventory']:AmountKey('Player', source, k) < v then
            TriggerClientEvent('Shared.Notif', source,'no')
            return false
        end
    end

    if exports['geo-inventory']:CanFit('Player', source, Crafting.Lists[job][index].Item, Crafting.Lists[job][index].Amount) then
        for k,v in pairs(itemsToRemove) do
            exports['geo-inventory']:RemoveItem('Player', source,  k,  v)
        end
        --exports['geo-inventory']:AddItem('Player', source, Crafting.Lists[job][item].Item, Crafting.Lists[job][item].Amount)
        --return true
    else
        return false
    end


    isCrafting[char.id] = {
        item = New(Crafting.Lists[job][index]),
        Durability = Crafting.Lists[job][index].Durability,
        Progress = 0,
        Quality = math.floor(((hqToal / total) / 2) * Crafting.Lists[job][index].Control),
        Skill = job,
        Index = index
    }

    isCrafting[char.id].HQChance = HQChance(isCrafting[char.id].Quality, isCrafting[char.id].item.Control)

    return isCrafting[char.id]
end)

Task.Register('Crafting.Skill', function(source, skillID)
    local char = GetCharacter(source)
    local mainHand = GetMainHand(char)
    local item = exports['geo-inventory']:GetItem(mainHand.Key)
    local skill = CraftingSkills[skillID]

    if isCrafting[char.id].completed == true or isCrafting[char.id].fail == true then
        isCrafting[char.id] = nil
        return
    end

    if isCrafting[char.id] then
        isCrafting[char.id].Durability = isCrafting[char.id].Durability - 10

        if skill.Craftsmanship then
            isCrafting[char.id].Progress = isCrafting[char.id].Progress + math.floor((item.Data.Crafting / 10) * skill.Craftsmanship)
        end

        if skill.Control then
            isCrafting[char.id].Quality = isCrafting[char.id].Quality + math.floor((item.Data.Control / 10) * skill.Control)
        end
    end

    if isCrafting[char.id].Progress >= isCrafting[char.id].item.Craftsmanship then
        local str = isCrafting[char.id].item.Item
        local isHQ = false
        if Random(100) <= HQChance(isCrafting[char.id].Quality, isCrafting[char.id].item.Control) then
            str = str..'_hq'
            isHQ = true
        end

        local xp = GetCraftingXP(char, isCrafting[char.id].Skill, isCrafting[char.id].Index, isHQ)
        exports['geo-rpg']:AddSkill(source, isCrafting[char.id].Skill, xp)

        exports['geo-inventory']:ReceiveItem('Player', source, str, isCrafting[char.id].item.Amount)
        isCrafting[char.id].completed = true
    end

    if isCrafting[char.id].Durability <= 0 and not isCrafting[char.id].completed then
        isCrafting[char.id].fail = true
    end

    isCrafting[char.id].HQChance = HQChance(isCrafting[char.id].Quality, isCrafting[char.id].item.Control)

    return isCrafting[char.id]
end)

Task.Register('QuickCraft', function(source, job, index)
    index = tonumber(index)
    index = index + 1

    local char = GetCharacter(source)
    local item = GetMainHand(char)
    if item == nil or (item ~= nil and exports['geo-inventory']:GetItem(item.Key).Skill ~= job) then
        TriggerClientEvent('Shared.Notif', source, 'This is the wrong tool')
        return false
    end

    local itemsToRemove = {}
    local total = 0
    local hqToal = 0

    for k,v in pairs(Crafting.Lists[job][index].Requirements) do
        if exports['geo-inventory']:AmountKey('Player', source, v[1]) < v[2] then
            TriggerClientEvent('Shared.Notif', source, 'no')
            return false
        end
    end

    if exports['geo-inventory']:CanFit('Player', source, Crafting.Lists[job][index].Item, Crafting.Lists[job][index].Amount) then
        for k,v in pairs(Crafting.Lists[job][index].Requirements) do
            exports['geo-inventory']:RemoveItem('Player', source,  v[1],  v[2])
        end
    else
        return false
    end

    if Random(100) <= 60 then
        local xp = math.floor(GetCraftingXP(char, job, index, false) * 0.25)
        exports['geo-rpg']:AddSkill(source, job, xp)
        exports['geo-inventory']:ReceiveItem('Player', source, Crafting.Lists[job][index].Item, Crafting.Lists[job][index].Amount)
    else
        TriggerClientEvent('Shared.Notif', source, 'Synthesis Failed')
    end
end)

function GetMainHand(char)
    local inv = exports['geo-inventory']:GetInventory('Player', char.serverid)
    for k,v in pairs(inv) do
        if v.Data.Equipped and exports['geo-inventory']:GetItem(v.Key).Equippable == 'Main Hand' then
            return v
        end
    end
end

Task.Register('GetCraftingLog', function(source)
    GetCraftingLog(source)
end)

CreateThread(function()
    Wait(2000)
    for k,v in pairs(GetPlayers()) do
        GetCraftingLog(v)
    end
end)

function GetCraftingLog(source)
    local char = GetCharacter(source)
    if char then
        local data = SQL('SELECT data from crafting_log WHERE cid = ?', char.id)[1]
        if not data then
            SQL('INSERT INTO crafting_log (cid) VALUES (?)', char.id)
            data = SQL('SELECT data from crafting_log WHERE cid = ?', char.id)[1]
        end

        craftingLogs[char.id] = json.decode(data.data)
        TriggerClientEvent('CraftingLog', source, craftingLogs[char.id])
    end
end

function HQChance(current, max)
    local calc = (current / max) * 100
    if calc < 25 then
        calc = calc / 4
    elseif calc < 50 then
        calc = calc / 3
    elseif calc < 65 then
        calc = calc / 2
    elseif calc < 75 then
        calc = calc / 1.6
    elseif calc < 85 then
        calc = calc / 1.2
    elseif calc < 95 then
        calc = calc / 1.1
    end

    return math.floor(calc)
end

AddEventHandler('Logout', function(char)
    craftingLogs[char.id] = nil
end)

function GetCraftingXP(char, job, index, isHQ)
    local itemData =  Crafting.Lists[job][index]
    local xp = Crafting.XP[itemData.Level]
    if craftingLogs[char.id][itemData.Item] == nil then
        craftingLogs[char.id][itemData.Item] = true
        SQL('UPDATE crafting_log SET data = ? WHERE cid = ?', json.encode(craftingLogs[char.id]), char.id)
        TriggerClientEvent('CraftingLog', char.serverid, craftingLogs[char.id])
        TriggerClientEvent('Shared.Notif', char.serverid, Crafting.Lists[job][index].Name..' has been added to your journal', 5000, true)
    end

    if Tools[itemData.Item] then
        xp = xp + Crafting.XP[itemData.Level]
    end

    if isHQ then
        xp = xp * 2
    end

    return xp
end

Crafting.XP = {
    [1] = math.floor(Levels[2] / 10),
    [2] = math.floor(Levels[3] / 15),
    [3] = math.floor(Levels[4] / 20),
    [4] = math.floor(Levels[5] / 25),
    [5] = math.floor(Levels[6] / 30),
    [6] = math.floor(Levels[7] / 35)
}

for i=1,80 do
    if Levels[i + 1] then
        local total = Levels[i + 1] - Levels[i]
        local calc = (10 + ((5 * i) - 5))
        if i < 5 then
            calc = 20
        end

        Crafting.XP[i] = math.floor(total / calc)
    end


    if Crafting.XP[i - 1] then
       --[[  local equation = (10 + (i * 5) - 5)
        if i < 5 then equation = 10 end
        Crafting.XP[i] = math.floor((Levels[i + 1] - Levels[i]) / equation)
        ]]
        --Crafting.XP[i] = math.floor(Crafting.XP[i - 1] * 1.25)
        --Crafting.XP[i] = math.floor(Levels[i] / (10 + ((5 * i) - 5)))
        --print(i..' '..Crafting.XP[i], (Levels[i] - Levels[i - 1]) / Crafting.XP[i]) 
    end
end
