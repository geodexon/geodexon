local objList = {}
local vehicle = {}
local groups = {}

local ranks = {
    {'Trainee', 0.55, 0},
    {'Junior Garbageman', 0.6, 300},
    {'Garbageman', 0.7, 3000},
    {'Senior Garbageman', 0.8, 9000},
    {'Assistant Manager', 0.9, 18000},
    {'Manager', 1.0, 30000}
}

Jobs:RegisterRanking('Garbage', ranks)
Task.Register('Garbage.Get', function(source)
    local char = GetCharacter(source)
    if not objList[char.id] then
        objList[char.id] = Jobs.Fetch('Garbage', char.id)
        JobTime[char.id] = os.time()
    end

    objList[char.id].rankname = objList[char.id]:GetRank()
    return {objList[char.id], groups}
end)

RegisterNetEvent('Garbage.Start', function()
    local source = source
    local char = GetCharacter(source)
    groups[char.id] = nil

    if objList[char.id].OnJob then
        objList[char.id].FormingGroup = nil
        if objList[char.id].Vehicle then
            DeleteEntity(objList[char.id].Vehicle)
        end

        if objList[char.id].Partner then
            TriggerClientEvent('Garbage.RemovePickup', GetCharacterByID(objList[char.id].Partner).serverid)
            objList[objList[char.id].Partner].OnJob = false
            objList[objList[char.id].Partner].Vehicle = nil
            objList[objList[char.id].Partner].Partner = nil
            objList[objList[char.id].Partner].InGroup = nil
        end

        objList[char.id].OnJob = false
        objList[char.id].Vehicle = nil
        objList[char.id].Partner = nil
        objList[char.id].InGroup = nil
        TriggerClientEvent('Garbage.RemovePickup', source)
        return
    end

    if objList[char.id]:GetHours() == 0 or GetUser(source).data.settings.jobinfo then
        TriggerClientEvent('Shared.Notif', source, [[
            Bring your garbage truck to the destinations and pick up the garbahe, come back when you're
            finished
        ]], 10000)
    end

    local time = os.time()
    objList[char.id].OnJob = true
    JobTime[char.id] = os.time()
    objList[char.id].Pos = vec(0, 0 ,0)
    if objList[char.id].InGroup then return end

    local garbage = exports['geo-vehicle']:CreateVehicle(source, 'trash', vector4(-338.76, -1561.1, 25.23, 91.46))
    objList[char.id].Vehicle = garbage
    vehicle[garbage] = char
    
    TriggerEvent('GiveKey', source, NetworkGetNetworkIdFromEntity(garbage))
    exports['geo-es']:SetRented(GetVehicleNumberPlateText(garbage), char)

    if objList[char.id].Partner then
        TriggerClientEvent('Garbage.AllowPickup', GetCharacterByID(objList[char.id].Partner).serverid, NetworkGetNetworkIdFromEntity(objList[char.id].Vehicle))
        TriggerClientEvent('Help', GetCharacterByID(objList[char.id].Partner).serverid, 5)
    else
        TriggerClientEvent('Garbage.AllowPickup', source, NetworkGetNetworkIdFromEntity(objList[char.id].Vehicle))
    end
    TriggerClientEvent('Help', source, 5)
end)

RegisterNetEvent('Garbage.Group', function()
    local source = source
    local char = GetCharacter(source)
    groups[char.id] = GetName(char)
    objList[char.id].FormingGroup = true
    TriggerClientEvent('Shared.Notif', source, 'Group started, waiting for people to join...')
end)

RegisterNetEvent('Garbage.CancelGroup', function()
    local source = source
    local char = GetCharacter(source)
    if groups[char.id] then
        groups[char.id] = nil
        objList[char.id].FormingGroup = false
        TriggerClientEvent('Shared.Notif', source, 'Group cancelled')
    end
end)

RegisterNetEvent('Garbage.JoinGroup', function(groupID)
    local source = source
    local char = GetCharacter(source)
    if groups[groupID] then
        if exports['geo-interface']:PhoneConfirm(GetCharacterByID(groupID).serverid, GetName(char)..' would like to join your garbage group', 30, 'housing') then
            objList[groupID].Partner = char.id
            objList[char.id].InGroup = groupID
            TriggerClientEvent('Garbage.PingPong', GetCharacterByID(groupID).serverid)
            Wait(1000)
            TriggerClientEvent('Garbage.PingPong', source)
            groups[groupID] = nil
        end
    else
        TriggerClientEvent('Shared.Notif', source, 'This group is no longer available')
    end
end)

Task.Register('Garbage.Collect', function(source)
    local char = GetCharacter(source)
    local pos = GetEntityCoords(GetPlayerPed(source))
    if Vdist3(pos, objList[char.id].Pos) < 50.0 then
        TriggerClientEvent('Shared.Notif', source, "You've colleced trash from this area already")
        return
    end

    objList[char.id].Pos = pos
    if objList[char.id].InGroup then
        objList[char.id]:AddPay(420)
        objList[objList[char.id].InGroup]:AddPay(420)
    else
        objList[char.id]:AddPay(600)
    end
end)

RegisterNetEvent('Garbahe.Pay', function()
    local source = source
    local char = GetCharacter(source)
    objList[char.id]:Pay(source, 0)
end)

AddEventHandler('entityRemoved', function(ent)
    if vehicle[ent] then
        local char = vehicle[ent]

        if objList[char.id].Partner then
            TriggerClientEvent('Garbage.RemovePickup', GetCharacterByID(objList[char.id].Partner).serverid)
            objList[objList[char.id].Partner].InGroup = nil
        else
            TriggerClientEvent('Garbage.RemovePickup', char.serverid)
        end
        vehicle[ent] = nil
    end
end)

local garbageLooted = {}
Task.Register('Garbage.Loot', function(source)
    local char = GetCharacter(source)
    if garbageLooted[char.id] == nil then
        garbageLooted[char.id] = {}
    end

    if not objList[char.id] then
        objList[char.id] = Jobs.Fetch('Garbage', char.id)
    end


    local pos = GetEntityCoords(GetPlayerPed(source))
    for k,v in pairs(garbageLooted[char.id]) do
        if Vdist3(pos, v) <= 10.0 then
            TriggerClientEvent('Shared.Notif', source, "You've already looted the garbage around here")
            return
        end
    end

    table.insert(garbageLooted[char.id], pos)
    GetLoot(source, 'Garbage.'..objList[char.id].rank)
end)

RegisterNetEvent('Garbage.Promotion', function()
    local source = source
    local char = GetCharacter(source)

    if objList[char.id]:IsNextRank() then
        local mth = objList[char.id]:TimeUntilNextRank()
        if mth <= 0 then
            objList[char.id]:CheckPromotion()
            TriggerClientEvent('Chat.Message', source, '[Garbage]', ('You have been promoted to a %s'):format(objList[char.id]:GetRank()), 'job')
        else
            local num = string.format('%.2f', math.abs(mth / 60))
            TriggerClientEvent('Chat.Message', source, '[Garbage]', ('%s hours until your next promotion'):format(num), 'job')
        end
    end
end)