local objList ={}
local vehicles = {}

local jobLocations = {
    vector3(1187.55, 2727.57, 38.0),
    vector3(1828.13, 2542.34, 45.88),
    vector3(2323.56, 2563.85, 46.67),
    vector3(2545.97, 2581.39, 37.94),
    vector3(2659.45, 2881.95, 35.96),
    vector3(2238.92, 3196.05, 48.49),
    vector3(2046.51, 3446.06, 43.77),
    vector3(1980.27, 3785.3, 32.18),
    vector3(1825.05, 3689.81, 34.22),
    vector3(1569.43, 3605.48, 35.36),
    vector3(1351.36, 3613.36, 34.84),
    vector3(921.26, 3654.31, 32.51),
    vector3(444.3, 3558.2, 33.24),
    vector3(250.33, 3120.48, 42.51),
    vector3(206.21, 2604.78, 46.17)
}

Jobs:RegisterRanking('Organ', DefaultCriminal)
Task.Register('Organ.StartJob', function(source)
    local char = GetCharacter(source)
    if char then
        if objList[char.id] == nil then
            objList[char.id] = Jobs.Fetch('Organ', char.id)
            if not objList[char.id] then return end
            objList[char.id].sid = source
        end

        JobTime[char.id] = os.time()
        objList[char.id].count = 0
        objList[char.id].job = 'phase_1'
        if objList[char.id]:GetHours() == 0 or GetUser(source).data.settings.jobinfo then
            TriggerClientEvent('Shared.Notif', source, [[
                Your task is to deliver body parts to your coolers marked on your GPS, the ice won't last too long so don't
                waste any time
            ]], 10000)
        end

        local veh = CreateVehicle('sentinel', vector3(1039.48, 2650.54, 39.55), 90.0, true, false)
        while not DoesEntityExist(veh) do
            Wait(100)
        end
        Wait(100)
    
        Entity(veh).state.ignoreCrime = true
        Entity(veh).state.organ = true
        objList[char.id].vehicle = veh
        vehicles[veh] = char.id
        TriggerClientEvent('Organ.SetStage', source, objList[char.id].job)
        return NetworkGetNetworkIdFromEntity(veh)
    end
end)

Task.Register('Organ.QuitJob', function(source)
    local char = GetCharacter(source)
    TriggerClientEvent('Organ.SetStage', source, 'none')
    if char and objList[char.id] and objList[char.id].vehicle then
        DeleteEntity(objList[char.id].vehicle)
        return
    end
end)

Task.Register('Organ.GetLocation', function(source)
    local char = GetCharacter(source)
    if char and objList[char.id] and objList[char.id].vehicle then
        if objList[char.id].count < 5 then
            if objList[char.id].loc == nil then
                objList[char.id].loc = jobLocations[Random(#jobLocations)]
            end
    
            return objList[char.id].loc
        else
            return 'return'
        end
    end
end)

Task.Register('Organ.FinishJob', function(source)
    local char = GetCharacter(source)
    if char and objList[char.id] and objList[char.id].vehicle then
        if objList[char.id].count == 5 then
            if objList[char.id]:Pay(source, 900) then
                DeleteEntity(objList[char.id].vehicle)
                return
            end
        end

        return objList[char.id].vehicle
    end
end)

RegisterNetEvent('Organ.Next')
AddEventHandler('Organ.Next', function(loc)
    local source = source
    local char = GetCharacter(source)
    if char and objList[char.id] and objList[char.id].vehicle then
        local time = os.time()
        if time - JobTime[char.id] <= 300 then
            objList[char.id]:AddPay(300)
            objList[char.id].loc = nil
            objList[char.id].count = objList[char.id].count + 1
            if Random(10) > 7 then
                TriggerEvent('Dispatch', {
                    code = '10-43',
                    title =  'Strange Handoff',
                    location = loc.position,
    
                    time =  os.date('%H:%M EST'),
                    info = {
                        {
                            icon = 'location',
                            text = loc.location,
                            location = true
                        },
                    }
                })
            end
        else
            TriggerClientEvent('Shared.Notif', source, 'This organ is no good, no money for you')
            objList[char.id].loc = nil
            JobTime[char.id] = time
        end
    end
end)

AddEventHandler('entityRemoved', function(veh)
    if vehicles[veh] then
        objList[vehicles[veh]].vehicle = nil
        objList[vehicles[veh]].job = 'none'
        TriggerClientEvent('Organ.QuitJob', objList[vehicles[veh]].sid)
    end
end)