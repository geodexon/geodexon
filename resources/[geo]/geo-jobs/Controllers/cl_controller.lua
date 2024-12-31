--[[ function QuitJobs()
    TriggerServerEvent('CommercialRobbery.QuitJob')
    TriggerServerEvent('HiredMuscle.Quit')
    TriggerServerEvent('Dock Work:QuitJob')
    TriggerServerEvent('GoPostal:QuitJob')
    TriggerServerEvent('Trucking:QuitJob')
end

RegisterCommand('quitjobs', QuitJobs) ]]

MissionPeds = {}

function CreateMissionPed(model, location, invincible, frozen, noNetwork)
    local ped = Shared.SpawnPed(model, location, noNetwork or false)
    SetEntityCoords(ped, GetEntityCoords(ped) - vec(0.0, 0.0, GetEntityHeightAboveGround(ped)))
    FreezeEntityPosition(ped, frozen or false)
    SetEntityInvincible(ped, invincible or false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedKeepTask(ped, true)
    MissionPeds[ped] = {model, ped}

    if not noNetwork then
        TriggerServerEvent('Ped.Control', PedToNet(ped), true)
    end

    return ped
end

exports('CreateMissionPed', CreateMissionPed)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        for k,v in pairs(MissionPeds) do
            if v[1] == GetEntityModel(v[2]) then
                DeleteEntity(k)
            end
        end
    end
end)

RegisterNetEvent('Job.CheckIn', function(id)
    local bool, found = StatGetFloat('MPPLY_CHAR_DIST_TRAVELLED', -1)
    TriggerServerEvent('Job.CheckIn', id, found)
end)