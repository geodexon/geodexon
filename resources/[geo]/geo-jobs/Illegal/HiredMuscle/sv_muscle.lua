local pedList = {
    390939205,
    1224306523,
    -1211756494,
    -1736970383,
    -1589423867,
}
local locationList = {
    vector3(-356.65, -949.42, 31.08),
    vector3(1191.47, -559.16, 64.13),
    vector3(896.97, -143.72, 76.35),
    vector3(421.05, 95.52, 99.9),
    vector3(-4.41, 249.08, 108.51),
    vector3(-574.65, 244.27, 82.36),
    vector3(-1092.55, 207.79, 61.25),
    vector3(-968.36, -186.1, 37.33),
    vector3(-1352.92, -614.97, 27.87),
    vector3(-1041.23, -1072.8, 3.44),
    vector3(-1077.47, -1549.39, 4.17),
    vector3(-642.86, -1308.44, 10.31),
    vector3(-964.23, -2442.29, 13.28),
    vector3(370.3, -593.03, 28.39)
}

local Bonuses = {
    {Name = 'Pistol', Hash = `WEAPON_PISTOL`},
    {Name = 'Fists', Hash = `WEAPON_UNARMED`},
    {Name = 'Bottle', Hash = `weapon_bottle`},
    {Name = 'Knife', Hash = `weapon_knife`},
    {Name = 'Crowbar', Hash = `weapon_crowbar`},
    {Name = 'Switchblade', Hash = `weapon_switchblade`}
}

local objList = {}

Jobs:RegisterRanking('HiredMuscle', DefaultCriminal)
RegisterNetEvent('HiredMuscle.GetJob')
AddEventHandler('HiredMuscle.GetJob', function()
    local source = source
    local char = GetCharacter(source)

    if char.id then
        if not objList[char.id] then
            objList[char.id] = Jobs.Fetch('HiredMuscle', char.id)
            if not objList[char.id] then return end
            objList[char.id].job = 'none'
        end

        objList[char.id]:CheckPromotion()
        if objList[char.id]:GetHours() == 0 or GetUser(source).data.settings.jobinfo then
            TriggerClientEvent('Shared.Notif', source, [[
                Head to the area marked on your map and look for your mark, after you've take care of them
                come back here to collect your payment
            ]], 10000)
        end

        JobTime[char.id] = os.time()
        local chosenPed = pedList[Random(#pedList)]
        local chosenLocation = locationList[Random(#locationList)]
        local challengeRating = 1

        local hours = objList[char.id]:GetHours()
        if hours < 10 then
            challengeRating = 1
        elseif hours < 20 then
            challengeRating = 2
        elseif hours < 50 then
            challengeRating = 3
        elseif hours < 100 then
            challengeRating = 4
        end

        objList[char.id].job = 'p1'

        objList[char.id].bonus = Random(#Bonuses)
        TriggerClientEvent('Shared.Notif', source, Format('Bonus Objective: %s', Bonuses[objList[char.id].bonus].Name), 2000)
        TriggerClientEvent('HiredMuscle.GetJob', source, chosenLocation, chosenPed, challengeRating)
        TriggerClientEvent('HiredMuscle.SetJobState', source, 'active')
    end
end)

RegisterNetEvent('HiredMuscle.KilledPed')
AddEventHandler('HiredMuscle.KilledPed', function(location, coords, ped)
    local source = source
    local char = GetCharacter(source)

    if char.id then
        if objList[char.id].job == 'p1' then
            objList[char.id].job = 'p2'
            TriggerEvent('Dispatch', {
                code = '10-18',
                title =  'Homicide',
                location = location.position,

                time =  os.date('%H:%M EST'),
                info = {
                    {
                        icon = 'location',
                        text = location.location,
                        location = true
                    },
                }
            })

            if GetPedCauseOfDeath(NetworkGetEntityFromNetworkId(ped)) == Bonuses[objList[char.id].bonus].Hash then
                objList[char.id].bonus = true
            end

            exports['geo-es']:PoliceEvent('AddTempBlip', '10-31', location.position)
        end
    end
end)

RegisterNetEvent('HiredMuscle.Pay')
AddEventHandler('HiredMuscle.Pay', function()
    local source = source
    local char = GetCharacter(source)
    if char.id then
        if objList[char.id].job == 'p2' then
            if objList[char.id]:Pay(source, 1800) then
                TriggerClientEvent('HiredMuscle.SetJobState', source, 'none')
                objList[char.id].job = 'none'
                if objList[char.id].bonus == true then
                    exports['geo-inventory']:ReceiveItem('Player', source, 'dollar', 100)
                end

                objList[char.id].bonus = nil
            end
        else
            TriggerClientEvent('HiredMuscle.SetJobState', source, 'pay')
        end
    end
end)

RegisterNetEvent('HiredMuscle.Quit')
AddEventHandler('HiredMuscle.Quit', function()
    local source = source
    local char = GetCharacter(source)

    if char.id then
        if objList[char.id] then
            objList[char.id].job = 'none'
            JobTime[char.id] = os.time()
            TriggerClientEvent('HiredMuscle.SetJobState', source, 'none')
        end
    end
end)

Task.Register('HiredMuscle.Ped', function(source, ped, location)
    local ped = CreatePed(1, ped, location, 0.0)
    Wait(1000)
    while GetEntityHealth(ped) == 0 do
        Wait(100)
    end

    Entity(ped).state.controlled = true
    return NetworkGetNetworkIdFromEntity(ped)
end)