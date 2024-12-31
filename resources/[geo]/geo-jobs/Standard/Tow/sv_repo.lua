local objList = {}
local entList = {}

local vehicleList = {
    'asea',
    'asea',
    'asea',
    'asea',
    'asea',
    'washington',
    'washington',
    'washington',
    'washington',
    'washington',
    'washington',
    'glendale',
    'glendale',
    'glendale',
    'glendale',
    'granger',
    'granger',
    'granger',
    'granger',
    'granger',
    'tornado',
    'tornado',
    'tornado',
    'tornado',
    'tornado',
    'stratum',
    'stratum',
    'stratum',
    'infernus',
}

local ranks = {
    {'Trainee', 0.55, 0},
    {'Junior Repoman', 0.6, 300},
    {'Repoman', 0.7, 3000},
    {'Senior Repoman', 0.8, 9000},
    {'Assistant Manager', 0.9, 18000},
    {'Manager', 1.0, 30000}
}

Jobs:RegisterRanking('Repo', ranks)
Task.Register('Repo.Get', function(source)
    local char = GetCharacter(source)
    if not objList[char.id] then
        objList[char.id] = Jobs.Fetch('Repo', char.id)
        objList[char.id].job = 'none'
    end

    objList[char.id].rankname = objList[char.id]:GetRank()
    return {objList[char.id]}
end)

RegisterNetEvent('Repo.Promotion', function()
    local source = source
    local char = GetCharacter(source)

    if objList[char.id]:IsNextRank() then
        local mth = objList[char.id]:TimeUntilNextRank()
        if mth <= 0 then
            objList[char.id]:CheckPromotion()
            TriggerClientEvent('Chat.Message', source, '[Repo]', ('You have been promoted to a %s'):format(objList[char.id]:GetRank()), 'job')
        else
            local num = string.format('%.2f', math.abs(mth / 60))
            TriggerClientEvent('Chat.Message', source, '[Repo]', ('%s hours until your next promotion'):format(num), 'job')
        end
    end
end)

RegisterNetEvent('Repo.Start', function(model)
    local source = source
    local char = GetCharacter(source)
    if objList[char.id] and objList[char.id].job == 'none' then


        if objList[char.id]:GetHours() == 0 or GetUser(source).data.settings.jobinfo then
            TriggerClientEvent('Shared.Notif', source, [[
                Drive your flatbed over to the vehicle we marked on your map, talk to the person the being the vehicle
                back here to be impounded
            ]], 10000)
        end

        objList[char.id].OnJob = true
        JobTime[char.id] = os.time()
        objList[char.id].job = 'phase_1'    
    
        local pos = positions[Random(#positions)]

        local vehicle = exports['geo-vehicle']:CreateVehicle(source, vehicleList[Random(#vehicleList)], pos[1])
        Entity(vehicle).state.impound = true
        Entity(vehicle).state.repo = char.id


        Impound[GetVehicleNumberPlateText(vehicle)] = true
        local ped = CreatePed(1, model, pos[2], 0.0, true, true)

        objList[char.id].vehicle = vehicle
        objList[char.id].ped = ped

        table.insert(entList, ped)
        table.insert(entList, vehicle)

        TriggerClientEvent('Help', source, 13)
        TriggerClientEvent('Repo.Start', source, pos[1], NetworkGetNetworkIdFromEntity(ped), Random(#repoCommentsDriver), NetworkGetNetworkIdFromEntity(vehicle))
        
        while not DoesEntityExist(ped) == 0 do
            Wait(100)
        end
        
        while GetEntityHealth(ped) == 0 do
            Wait(100)
        end
        SetPedConfigFlag(ped, 17, true)
        Entity(ped).state.controlled = true
        Entity(ped).state.repo = char.id
        Entity(ped).state.policeoption = Random(#repoComments)
        Entity(ped).state.angry = Random(100) > 90

        while DoesEntityExist(vehicle) do
            if GetPedInVehicleSeat(vehicle, -1) ~= 0 then
                TriggerClientEvent('PhoneNotif', source, 'car', "The owner reported the car stolen, return to get a new job", 5000)
                RepoQuit(char)
            end
            Wait(500)
        end
    else
       RepoQuit(char)
    end
end)

AddEventHandler('Repo.Impounded', function(cid)
    if objList[cid].job == 'phase_1' then
        objList[cid]:AddPay(900)
        objList[cid].job = 'none'
        if DoesEntityExist(objList[char.id].ped) then
            DeleteEntity(objList[char.id].ped)
        end
    end
end)

RegisterNetEvent('Repo.PoliceAllow', function(ent)
    local source = source
    local char = GetCharacter(source)
    if char.Duty == "Police" then
        Entity(NetworkGetEntityFromNetworkId(ent)).state.angry = nil
        TriggerClientEvent('Shared.Notif', source, repoResponses[Random(#repoResponses)])
        TriggerClientEvent('Repo.PoliceDisallow', source, ent)
    end
end)

RegisterNetEvent('Repo.PoliceDisallow', function(ent)
    local source = source
    local char = GetCharacter(source)
    if char.Duty == "Police" then
        local ent = NetworkGetEntityFromNetworkId(ent)
        Entity(ent).state.angry = nil
        objList[Entity(ent).state.repo]:AddPay(900)
        objList[Entity(ent).state.repo].job = 'none'
        TriggerClientEvent('Repo.Leave', GetCharacterByID(Entity(ent).state.repo).serverid)
        TriggerClientEvent('Shared.Notif', source, "You're a life saver, thank you!")

        local veh = objList[Entity(ent).state.repo].vehicle
        local ped = objList[Entity(ent).state.repo].ped

        Wait(300000)
        if DoesEntityExist(veh) then
            DeleteEntity(veh)
        end

        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
end)

RegisterNetEvent('Repo.Pay', function()
    local source = source
    local char = GetCharacter(source)
    objList[char.id]:Pay(source, 0)
end)

function RepoQuit(char)
    objList[char.id].job = 'none'
    if DoesEntityExist(objList[char.id].ped) then
        DeleteEntity(objList[char.id].ped)
    end
    if DoesEntityExist(objList[char.id].vehicle) and GetPedInVehicleSeat(objList[char.id].vehicle, -1) == 0 then
        DeleteEntity(objList[char.id].vehicle)
    end
    TriggerClientEvent('Repo.Quit', source)
end

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        for k,v in pairs(entList) do
            DeleteEntity(v)
        end
    end
end)