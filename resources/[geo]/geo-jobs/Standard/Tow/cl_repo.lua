local interaction
local scenarios = {
    'WORLD_HUMAN_AA_COFFEE',
    'WORLD_HUMAN_AA_SMOKE',
    'WORLD_HUMAN_DRINKING',
    'WORLD_HUMAN_HANG_OUT_STREET',
    'WORLD_HUMAN_MUSICIAN',
    'WORLD_HUMAN_TOURIST_MAP',
}

AddEventHandler('Tow.Repo', function() 
    local repoData = table.unpack(Task.Run('Repo.Get'))

    local menu = {
        {title = repoData.job ~= 'none' and 'Clock Out' or 'Clock In',  serverevent = 'Repo.Start', params = {exports['geo']:GetRandomModel()}},
        {title = 'Pay: $'..comma_value(repoData.pay), hidden = repoData.pay == 0, serverevent = 'Repo.Pay'}
    }

    table.insert(menu, 
        {title = 'Ask for Promotion', serverevent = 'Repo.Promotion'}
    )

    table.insert(menu, 
        {description = 'Current Rank: '..repoData.rankname}
    )

    RunMenu(menu)
end)

local repoCar, repoPed
local blip
RegisterNetEvent('Repo.Start', function(pos, ent, option, veh)
    if interaction then interaction.remove() end
    interaction = nil
    blip = AddBlipForCoord(pos.xyz)
    SetBlipSprite(blip, 659)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, 0.8)
    BeginTextCommandSetBlipName("STRING")
    SetBlipColour(blip, 44)
    AddTextComponentString('Repo')
    EndTextCommandSetBlipName(blip)
    SetBlipRoute(blip, true)

    while not NetworkDoesEntityExistWithNetworkId(ent) do
        Wait(100)
    end
    ent = NetworkGetEntityFromNetworkId(ent)
    veh = NetworkGetEntityFromNetworkId(veh)

    TaskStartScenarioInPlace(ent, scenarios[Random(#scenarios)], 0, true)
    repoCar, repoPed = veh, ent
    interaction = exports['geo-interface']:AddTargetEntity(ent, 'Repossess Vehicle', 'Tow.RepoTarget', {ent, option}, 
        {
            req = function(data) return data.dist < 3.0 and Entity(ent).state.repo end
        }
    )
end)

AddEventHandler('enteredVehicle', function(veh)
    if veh == repoCar then
        TriggerEvent('Shared.Notif', "Bring the vehicle back to the impound lot")
        AngryRepo(repoPed, 45)
    end
end)

RegisterNetEvent('Repo.Quit', function()
    RemoveBlip(blip)
    if interaction then interaction.remove() end
    repoCar, repoPed, interaction = nil, nil, nil
end)

AddEventHandler('Tow.RepoTarget', function(ent, option, c)
    local menu = {
        {title = repoCommentsDriver[option]},
    }

    if option >= 50 and Entity(ent).state.angry then
        table.insert(menu, {
            description = 'This person seems angry, might be best to call the police, who knows what they might do if you try to take this vehicle now'
        })
    end

    RunMenu(menu)
end)

AddEventHandler('Repo.Angy', function(ent)
    local menu = {
        {title = repoComments[Entity(ent).state.policeoption]},
        {title = 'Allow Repo', serverevent = 'Repo.PoliceAllow', params = {NetworkGetNetworkIdFromEntity(ent)}},
        {title = 'Cancel Repo', serverevent = 'Repo.PoliceDisallow', params = {NetworkGetNetworkIdFromEntity(ent)}},
    }

    RunMenu(menu)
end)

RegisterNetEvent('Repo.PoliceDisallow', function(ent)
    ent = NetworkGetEntityFromNetworkId(ent)
    if Random(100) > 80 then
        AngryRepo(ent)
    else
        Shared.GetEntityControl(ent)
        TaskWanderStandard(ent, 10.0, 10)
    end
end)

AddEventHandler('Tow.Vehicle', function(veh)
    if veh == repoCar then
        RemoveBlip(blip)
        if DoesEntityExist(repoPed) and Entity(repoPed).state.angry then
            AngryRepo(repoPed)
        end
        Shared.GetEntityControl(repoPed)
        SetEntityAsNoLongerNeeded(repoPed)
    end
end)

RegisterNetEvent('Repo.Leave', function()
    Shared.GetEntityControl(repoPed)
    ClearPedTasksImmediately(repoPed)
    TaskVehicleDriveWander(repoPed, repoCar, 15.0, 427)
    SetEntityAsNoLongerNeeded(repoPed)
    SetEntityAsNoLongerNeeded(repoCar)
    RemoveBlip(blip)
end)

function AngryRepo(ent, rng)
    local wep
    local rng = rng or Random(50)
    if rng <= 30 then
        wep = 'WEAPON_BAT'
    elseif rng <= 40 then
        wep = 'WEAPON_KNIFE'
    elseif rng <= 45 then
        wep = 'WEAPON_PISTOL'
    elseif rng <= 48 then
        wep = 'WEAPON_APPISTOL'
    else
        wep = 'WEAPON_SMG'
    end

    Shared.GetEntityControl(ent)
    GiveWeaponToPed(ent, GetHashKey(wep), 9999, false, true)
    SetCurrentPedWeapon(ent, GetHashKey(wep), true)
    SetPedCombatAttributes(ent, 46, true)
    SetPedCombatAbility(ent, 2)
    TaskCombatPed(ent, Shared.Ped)
    SetEntityAsNoLongerNeeded(ent)
end