local objList = {}
local colors = {
    {'Bright Red', {255, 0, 0}},
    {'Bright Green', {0, 255, 0}},
    {'Bright Blue', {0, 0, 255}},
    {'Bright Yellow', {255, 255, 0}},
}

local jobs = {
    {Destination = vector3(448.31, -1501.54, 28.82), enemies = vector3(396.59, -1487.44, 29.26)},
    {Destination = vector3(982.91, -1863.01, 30.82), enemies = vector3(961.14, -1815.04, 30.66)},
    {Destination = vector3(-145.2, -1643.39, 32.05), enemies = vector3(-95.33, -1609.64, 31.84)},

}

Jobs:RegisterRanking('Escort', DefaultCriminal)
RegisterNetEvent('Escort.StartJob')
AddEventHandler('Escort.StartJob', function()
    local source = source
    local char = GetCharacter(source)

    if not objList[char.id] then
        objList[char.id] = Jobs.Fetch('Escort', char.id)
        if not objList[char.id] then return end
        objList[char.id].job = 'none'
    end

    if objList[char.id].LastTime then
        if os.time() < objList[char.id].LastTime then
            TriggerClientEvent('Shared.Notif', source, 'Come back later')
            TriggerClientEvent('Escort.SetState', source, 'none')
            return
        end
    end

    if objList[char.id]:GetHours() == 0 or GetUser(source).data.settings.jobinfo then
        TriggerClientEvent('Shared.Notif', source, [[
            Take out the target within the zone on your map. Once you've killed them, come back for your payment.
        ]], 10000)
    end

    if objList[char.id].job == 'none' then
        objList[char.id].LastTime = os.time() + 300
        objList[char.id].job = 'phase_1'
        objList[char.id].jobVehicle = CreateVehicle('granger', -52.27, -1849.71, 26.24, 316.57, true, false)
        objList[char.id].loc = jobs[Random(#jobs)]
        JobTime[char.id] = os.time()

        while not DoesEntityExist(objList[char.id].jobVehicle) do
            Wait(0)
        end
        
        Wait(500)
        SetVehicleCustomPrimaryColour(objList[char.id].jobVehicle, table.unpack(colors[Random(#colors)][2]))
        TriggerClientEvent('Escort.StartJob', source, NetworkGetNetworkIdFromEntity(objList[char.id].jobVehicle), objList[char.id].loc)
    end
end)

RegisterNetEvent('Escort.Fail')
AddEventHandler('Escort.Fail', function()
    local source = source
    local char = GetCharacter(source)

    if not objList[char.id] then
        return
    end

    if objList[char.id].job == 'phase_1' then
        objList[char.id].job = 'none'
        TriggerClientEvent('Escort.SetState', source, 'none')
    end
end)

RegisterNetEvent('Escort.QuitJob')
AddEventHandler('Escort.QuitJob', function()
    local source = source
    local char = GetCharacter(source)

    if not objList[char.id] then
        return
    end

    objList[char.id].job = 'none'
    TriggerClientEvent('Escort.SetState', source, 'none')
end)

RegisterNetEvent('Escord.Next')
AddEventHandler('Escord.Next', function()
    local source = source
    local char = GetCharacter(source)

    if not objList[char.id] then
        return
    end

    if objList[char.id].job == 'phase_1' then
        objList[char.id]:AddPay(900)
        objList[char.id].count = objList[char.id].count + 1
        objList[char.id].loc = jobs[Random(#jobs)]
        TriggerClientEvent('Escort.StartJob', source, NetworkGetNetworkIdFromEntity(objList[char.id].jobVehicle), objList[char.id].loc)
    end
end)

RegisterNetEvent('Escord.Done')
AddEventHandler('Escord.Done', function()
    local source = source
    local char = GetCharacter(source)

    if not objList[char.id] then
        return
    end

    if objList[char.id].count >= 2 then
        if objList[char.id].job == 'phase_1' then
            objList[char.id].job = 'phase_2'
            objList[char.id]:AddPay(900)
            TriggerClientEvent('Escort.Return', source, NetworkGetNetworkIdFromEntity(objList[char.id].jobVehicle), -52.27, -1849.71, 26.24)
        end
    end
end)

RegisterNetEvent('Escord.Finish')
AddEventHandler('Escord.Finish', function()
    local source = source
    local char = GetCharacter(source)

    if not objList[char.id] then
        return
    end

    if objList[char.id].job == 'phase_2' then
        objList[char.id]:AddPay(900)
        objList[char.id].job = 'done'
        TriggerClientEvent('Escort.SetState', source, 'done')
    end
end)

RegisterNetEvent('Escort.Pay')
AddEventHandler('Escort.Pay', function()
    local source = source
    local char = GetCharacter(source)

    if not objList[char.id] then
        return
    end

    if objList[char.id].job == 'done' then
        if objList[char.id]:Pay(source, 0) then
            objList[char.id].job = 'none'
            TriggerClientEvent('Escort.SetState', source, 'none')
            return
        end
        TriggerClientEvent('Escort.SetState', source, 'done')
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        for k,v in pairs(objList) do
            if v.jobVehicle then
                DeleteEntity(v.jobVehicle)
            end
        end
    end
end)