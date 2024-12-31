local jobLocation = vector3(459.31, -1275.01, 29.6)
local jobState = 'none'
local currentJob = {}
local areaBlip = 0
local model = 1224306523
local startPed
local jobStart = {}

AddZone({
    vector2(495.34603881836, -1266.3452148438),
    vector2(447.65930175781, -1268.2645263672),
    vector2(447.12475585938, -1301.2241210938),
    vector2(498.56271362305, -1299.5372314453)
  }, {
    name="HiredMuscle.Job",
    --minZ = 29.267457962036,
    --maxZ = 30.35977935791
})

local optList = {
    ['none'] = function()
        TriggerServerEvent('HiredMuscle.GetJob')        
    end,

    ['active'] = function()
        TriggerServerEvent('HiredMuscle.Quit')
    end,

    ['pay'] = function()
        TriggerServerEvent('HiredMuscle.Pay')        
    end
}

local textList = {
    ['none'] = 'Get Job',
    ['active'] = 'Quit Job',
    ['pay'] = 'Get Paid'
}

AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'HiredMuscle.Job' then
        jobStart.inside = inZone
        while jobStart.inside do
            Wait(0)
            if not startPed then
                startPed = Shared.SpawnPed(model, vector4(455.84, -1279.96, 29.54, 87.0), true)
                exports['geo-interface']:SetPed(startPed, textList[jobState], function() optList[jobState]() end)
                SetEntityCoords(startPed, GetEntityCoords(startPed) - vec(0.0, 0.0, GetEntityHeightAboveGround(startPed)))
                FreezeEntityPosition(startPed, true)
                SetEntityInvincible(startPed, true)
                SetBlockingOfNonTemporaryEvents(startPed, true)
            end

            if jobState then
                if Vdist3(GetEntityCoords(Shared.Ped), GetEntityCoords(startPed)) <= 2.0 then
                end
            end
        end

        if DoesEntityExist(startPed) then
            DeleteEntity(startPed)
            startPed = nil
        end

        exports['geo-interface']:SetPed(startPed, nil)
    end
end)

local challenge = {
    {'WEAPON_KNIFE', 'WEAPON_BAT', 'WEAPON_HAMMER', 'WEAPON_UNARMED'},
    {'WEAPON_PISTOL'},
    {'WEAPON_PISTOL50'},
    {'WEAPON_SMG', 'WEAPON_CARBINERIFLE'}
}

RegisterNetEvent('HiredMuscle.GetJob')
AddEventHandler('HiredMuscle.GetJob', function(location, ped, challengeRating)
    jobState = 'active'
    local near = false
    local nPed = 0
    CreateThread(function()
        local areaBlip = 0
        local pedBlip = 0
        areaBlip = AddBlipForRadius(location, 350.0, 175.0)
        SetBlipAlpha(areaBlip, 150)
        while true do
            Wait(0)

            if jobState == 'none' then
                break
            end


            if not near then
                if Vdist3(GetEntityCoords(Shared.Ped), location) <= 350.0 then
                    near = true
                    nPed = Task.Run('HiredMuscle.Ped', ped, location)

                    while not NetworkDoesEntityExistWithNetworkId(nPed) do
                        Wait(0)
                    end

                    nPed = NetworkGetEntityFromNetworkId(nPed)

                    local isScared = Random(100) > 50
                    local willAggro

                    if not isScared then
                        willAggro = Random(100) > 50
                    end

                    Shared.GetEntityControl(nPed)

                    ClearPedTasks(nPed)
                    if isScared then
                        TaskSmartFleePed(nPed, Shared.Ped, 50.0, -1, 1 ,1)
                    elseif willAggro then
                        Entity(nPed).state.robbed = true
                        SetPedCombatAttributes(nPed, 3, false)
                        SetPedCombatAttributes(nPed, 5, true)
                        SetPedCombatAttributes(nPed, 46, true)
                        SetPedSuffersCriticalHits(nPed, false)
                        TaskWanderStandard(nPed, 10.0, 10)
                        SetPedAsEnemy(nPed, true)
                        TaskCombatPed(nPed, Shared.Ped, 0, 16)

                        local packingHeat = Random(100) > 0
                        if packingHeat then
                            GiveWeaponToPed(nPed, GetHashKey(challenge[challengeRating][Random(#challenge[challengeRating])]), 60, 0, 1)
                        end
                    else
                        TaskWanderStandard(nPed, 10.0, 10)
                    end
                    RemoveBlip(areaBlip)
                    pedBlip = AddBlipForEntity(nPed)
                end
            else
                if not DoesEntityExist(nPed) or (Vdist3(GetEntityCoords(Shared.Ped), location) > 350.0 and not near) then
                    near = false
                    RemoveBlip(pedBlip)
                    areaBlip = AddBlipForRadius(location, 350.0, 175.0)
                    SetBlipAlpha(areaBlip, 150)
                else
                    if GetEntityHealth(nPed) <= 0 then
                        Wait(500)
                        TriggerServerEvent('HiredMuscle.KilledPed', Shared.GetLocation(GetEntityCoords(nPed)), GetEntityCoords(nPed), PedToNet(nPed))
                        RemoveBlip(pedBlip)
                        jobState = 'pay'
                        break
                    end
                end
            end
        end
        RemoveBlip(pedBlip)
        RemoveBlip(areaBlip)
    end)
end)

RegisterNetEvent('HiredMuscle.SetJobState')
AddEventHandler('HiredMuscle.SetJobState', function(state)
    jobState = state
    exports['geo-interface']:SetPed(startPed, textList[jobState], function() optList[jobState]() end)
end)