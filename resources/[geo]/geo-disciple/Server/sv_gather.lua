local nextAccess = {}
for k,v in pairs(Gathering.Nodes) do
    nextAccess[k] = {}
end

local nodeData = {}
local activeNode = {}
local gatheringLogs = {}

Task.Register('Gathering.OpenNode', function(source, nodeID)
    local char = GetCharacter(source)
    local time = os.time()
    if nextAccess[nodeID][char.id] == nil then nextAccess[nodeID][char.id] = 0 end
    if nodeData[char.id] == nil then nodeData[char.id] = {} end

    if time < nextAccess[nodeID][char.id] then
        TriggerClientEvent('Shared.Notif', source, "This node is not ready")
        return
    end


    if not nodeData[char.id][nodeID] then
        nodeData[char.id][nodeID] = New(Gathering.Nodes[nodeID])
        nodeData[char.id][nodeID].Health = 100
    end

    nodeData[char.id][nodeID].Chances = {}
    nodeData[char.id][nodeID].HQChance = {}

    for k,v in pairs(nodeData[char.id][nodeID].Items) do
        nodeData[char.id][nodeID].Chances[k] = Gathering.Chance(v, char)
        nodeData[char.id][nodeID].HQChance[k] = Gathering.HQChance(v, char)
    end
    
    activeNode[char.id] = nodeID
    return nodeData[char.id][nodeID]
end)

Task.Register('Gathering.Harvest', function(source, item)
    local char = GetCharacter(source)
    local node = activeNode[char.id]
    local item = nodeData[char.id][node].Items[item]

    if not exports['geo-inventory']:CanFit('Player', source, item, 1) then
        TriggerClientEvent('Shared.Notif', 'You can not carry this')
        return
    end

    local tool

    local inv = exports['geo-inventory']:GetInventory('Player', char.serverid)

    local str = 'Main Hand'
    if Gathering.XP[item]["Main Hand"] then
        str = 'Main Hand'
    else
        str = 'Off Hand'
    end
    for k,v in pairs(inv) do
        if v.Data.Equipped and exports['geo-inventory']:GetItem(v.Key).Equippable == str then
            tool = v
            break
        end
    end

    if tool and exports['geo-inventory']:Deteriorate('Player', source, tool.ID) then
        if Random(100) <= Gathering.Chance(item, char) then
            local str = item
            local hq = false
            if Random(100) <= Gathering.HQChance(item, char) then
                str = item..'_hq'
                hq = true
            end

            exports['geo-inventory']:ReceiveItem('Player', source, str, 1)
            local xp = Gathering.XP[item].XP

            if gatheringLogs[char.id][item] == nil then
                gatheringLogs[char.id][item] = true
                SQL('UPDATE gathering_log SET data = ? WHERE cid = ?', json.encode(gatheringLogs[char.id]), char.id)
                TriggerClientEvent('GatheringLog', source, gatheringLogs[char.id])
                TriggerClientEvent('Shared.Notif', source, Gathering.XP[item].Name..' has been added to your journal, '..Gathering.XP[item].FirstMultiplier..'x bonus', 5000, true)
                xp = xp * Gathering.XP[item].FirstMultiplier
            end

            exports['geo-rpg']:AddSkill(source, Tools[tool.Key].Skill, xp)
            TriggerClientEvent('GatheringXP', source, xp, nodeData[char.id][node].Position, hq)
        end
    else
        TriggerClientEvent('Shared.Notif', 'This tool is broken')
        return
    end

    nodeData[char.id][node].Health = nodeData[char.id][node].Health - 20
    if nodeData[char.id][node].Health <= 0 then
        nodeData[char.id][node] = nil
        nextAccess[node][char.id] = os.time() + Gathering.Nodes[node].RespawnTime
    end

    TriggerClientEvent('ConsumeHunger', source, 1)
    return nodeData[char.id][node]
end)

Task.Register('GetGatheringLog', function(source)
    GetGatheringLog(source)
end)

CreateThread(function()
    Wait(2000)
    for k,v in pairs(GetPlayers()) do
        GetGatheringLog(v)
    end
end)

function GetGatheringLog(source)
    local char = GetCharacter(source)
    if char then
        local data = SQL('SELECT data from gathering_log WHERE cid = ?', char.id)[1]
        if not data then
            SQL('INSERT INTO gathering_log (cid) VALUES (?)', char.id)
            data = SQL('SELECT data from gathering_log WHERE cid = ?', char.id)[1]
        end

        gatheringLogs[char.id] = json.decode(data.data)
        TriggerClientEvent('GatheringLog', source, gatheringLogs[char.id])
    end
end

function Gathering.Chance(item, char)
    local startChance = Gathering.XP[item].Chance
    local inv = exports['geo-inventory']:GetInventory('Player', char.serverid)

    for k,v in pairs(inv) do
        local str = 'Main Hand'
        if Gathering.XP[item]["Main Hand"] then
            str = 'Main Hand'
        else
            str = 'Off Hand'
        end

        if v.Data.Equipped and exports['geo-inventory']:GetItem(v.Key).Equippable == str and Tools[v.Key] and Tools[v.Key].Skill == Gathering.XP[item].Skill then
            local power = Tools[v.Key].Ability
            local level = GetLevel(char.skills[Gathering.XP[item].Skill] or 0)
            local totalBonus = (level * 10) - 10 + power

            if totalBonus < Gathering.XP[item].MinGather then
                return 0
            end

            local bonus = math.floor(totalBonus / Gathering.XP[item].Divisor) - (Gathering.XP[item].MinGather / Gathering.XP[item].Divisor)
            local total = Gathering.XP[item].Chance + bonus

            if Gathering.XP[item].MinLevel > level then
                total = total - ((Gathering.XP[item].MinLevel - level) * 20)
            end

            if total > 100 then total = 100 end
            if total < 0 then total = 0 end
            return total
        end
    end

    return 0
end

function Gathering.HQChance(item, char)
    local startChance = Gathering.XP[item].HQChance
    local inv = exports['geo-inventory']:GetInventory('Player', char.serverid)

    for k,v in pairs(inv) do

        local str = 'Main Hand'
        if Gathering.XP[item]["Main Hand"] then
            str = 'Main Hand'
        else
            str = 'Off Hand'
        end

        if v.Data.Equipped and exports['geo-inventory']:GetItem(v.Key).Equippable == str and Tools[v.Key] and Tools[v.Key].Skill == Gathering.XP[item].Skill then
            local power = Tools[v.Key].Ability
            local level = GetLevel(char.skills[Gathering.XP[item].Skill] or 0)
            local totalBonus = (level * 10) - 10 + power

            if totalBonus < Gathering.XP[item].MinGather then
                return 0
            end

            local bonus = math.floor((totalBonus / Gathering.XP[item].HQDivisor) - (Gathering.XP[item].MinGather / Gathering.XP[item].HQDivisor))
            if bonus < 0 then bonus = 0 end
            
            local total = Gathering.XP[item].HQChance + bonus

            if Gathering.XP[item].MinLevel > level then
                total = total - ((Gathering.XP[item].MinLevel - level) * 20)
            end

            if total > 15 then total = 15 end
            if total < 0 then total = 0 end
            return total
        end
    end

    return 0
end

function CanEquip(source, key)
    if not Tools[key] then return true end

    if GetLevel(GetCharacter(source).skills[Tools[key].Skill] or 0) < Tools[key].Requirement then
        TriggerClientEvent('Shared.Notif', source, 'This tool is too advanced for you')
        return false
    end

    return true
end

AddEventHandler('Logout', function(char)
    gatheringLogs[char.id] = nil
end)

exports('CanEquip', CanEquip)