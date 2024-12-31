local weapons = {
    "WEAPON_UNARMED",
    "WEAPON_KNIFE",
    "WEAPON_KNUCKLE",
    "WEAPON_NIGHTSTICK",
    "WEAPON_HAMMER",
    "WEAPON_BAT",
    "WEAPON_GOLFCLUB",
    "WEAPON_CROWBAR",
    "WEAPON_BOTTLE",
    "WEAPON_DAGGER",
    "WEAPON_HATCHET",
    "WEAPON_MACHETE",
    "WEAPON_FLASHLIGHT",
    "WEAPON_SWITCHBLADE",
    "WEAPON_PROXMINE",
    "WEAPON_BZGAS",
    "WEAPON_SMOKEGRENADE",
    "WEAPON_MOLOTOV",
    "WEAPON_FIREEXTINGUISHER",
    "WEAPON_PETROLCAN",
    "WEAPON_SNOWBALL",
    "WEAPON_FLARE",
    "WEAPON_BALL",
    "WEAPON_REVOLVER",
    "WEAPON_POOLCUE",
    "WEAPON_PIPEWRENCH",
    "WEAPON_PISTOL",
    "WEAPON_PISTOL_MK2",
    "WEAPON_COMBATPISTOL",
    "WEAPON_APPISTOL",
    "WEAPON_PISTOL50",
    "WEAPON_SNSPISTOL",
    "WEAPON_HEAVYPISTOL",
    "WEAPON_VINTAGEPISTOL",
    "WEAPON_STUNGUN",
    "WEAPON_FLAREGUN",
    "WEAPON_MARKSMANPISTOL",
    "WEAPON_MICROSMG",
    "WEAPON_MINISMG",
    "WEAPON_SMG",
    "WEAPON_SMG_MK2",
    "WEAPON_ASSAULTSMG",
    "WEAPON_MG",
    "WEAPON_COMBATMG",
    "WEAPON_COMBATMG_MK2",
    "WEAPON_COMBATPDW",
    "WEAPON_GUSENBERG",
    "WEAPON_MACHINEPISTOL",
    "WEAPON_ASSAULTRIFLE",
    "WEAPON_ASSAULTRIFLE_MK2",
    "WEAPON_CARBINERIFLE",
    "WEAPON_CARBINERIFLE_MK2",
    "WEAPON_ADVANCEDRIFLE",
    "WEAPON_SPECIALCARBINE",
    "WEAPON_BULLPUPRIFLE",
    "WEAPON_COMPACTRIFLE",
    "WEAPON_PUMPSHOTGUN",
    "WEAPON_SWEEPERSHOTGUN",
    "WEAPON_SAWNOFFSHOTGUN",
    "WEAPON_BULLPUPSHOTGUN",
    "WEAPON_ASSAULTSHOTGUN",
    "WEAPON_MUSKET",
    "WEAPON_HEAVYSHOTGUN",
    "WEAPON_DBSHOTGUN",
    "WEAPON_SNIPERRIFLE",
    "WEAPON_HEAVYSNIPER",
    "WEAPON_HEAVYSNIPER_MK2",
    "WEAPON_MARKSMANRIFLE",
    "WEAPON_GRENADELAUNCHER",
    "WEAPON_GRENADELAUNCHER_SMOKE",
    "WEAPON_RPG",
    "WEAPON_MINIGUN",
    "WEAPON_FIREWORK",
    "WEAPON_RAILGUN",
    "WEAPON_HOMINGLAUNCHER",
    "WEAPON_GRENADE",
    "WEAPON_STICKYBOMB",
    "WEAPON_COMPACTLAUNCHER",
    "WEAPON_SNSPISTOL_MK2",
    "WEAPON_REVOLVER_MK2",
    "WEAPON_DOUBLEACTION",
    "WEAPON_SPECIALCARBINE_MK2",
    "WEAPON_BULLPUPRIFLE_MK2",
    "WEAPON_PUMPSHOTGUN_MK2",
    "WEAPON_MARKSMANRIFLE_MK2",
    "WEAPON_RAYPISTOL",
    "WEAPON_RAYCARBINE",
    "WEAPON_RAYMINIGUN",
    "WEAPON_HIT_BY_WATER_CANNON",
    "WEAPON_RUN_OVER_BY_CAR",
    "WEAPON_COUGAR",
    'WEAPON_FALL'
}

local allwed = {'WEAPON_FALL', 'WEAPON_UNARMED', 'WEAPON_RUN_OVER_BY_CAR '}
AddEventHandler('baseevents:onPlayerDied', function()
    if MyCharacter.dead == 1 then
        return
    end

    local cause = GetPedCauseOfDeath(Shared.Ped)
    local notDead = false
    for k,v in pairs(allwed) do
        if cause == GetHashKey(v) then
            notDead = true
            break
        end
    end

    if not notDead then
        TriggerServerEvent('Status.Death', Shared.GetLocation())
    end

    local time = 300
    local str = 'Respawn: '..time..' seconds'
    if notDead then
        time = 60
        str = 'Get Up: '..time..' seconds'
    end

    while MyCharacter.dead == 0 do
        Wait(100)
    end

    CreateThread(function()
        local _int = Shared.Interact(str)
        while true do
            Wait(1000)
            _int.update(str)
            time = time - 1 >= 0 and time - 1 or 0
            str = 'Respawn: '..time..' seconds'
            if time == 0 then str = '[E] Respawn' end

            if notDead then
                str = 'Get Up: '..time..' seconds'
                if time == 0 then str = '[E] Get Up' end
            end

            if MyCharacter.dead == 0 then
                break
            end
        end
        if _int then _int.stop() end
    end)

    CreateThread(function()
        while true do
            Wait(0)
            if IsControlJustPressed(0, 38) then
                if time <= 0 then
                    if notDead then
                        exports['geo']:UpdateCharacter('dead', 0)
                    else
                        if Minigame(50, 10000) then
                            TriggerServerEvent('Respawn')
                        end
                    end
                end
            end

            if MyCharacter.dead == 0 then
                break
            end
        end
        exports['geo-menu']:ResetWalk()
    end)
end)

local anim = 'respawn@hospital@downtown'
local dict = 'downtown'
RegisterNetEvent('Respawn')
AddEventHandler('Respawn', function()
    DoScreenFadeOut(500)
    Wait(2000)
    ClearPedBloodDamage(Shared.Ped)
    Warp(vector3(301.98, -585.86, 43.28), 64.0)

    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    SetCamCoord(cam, vec(288.4496, -580.7642, 45.13387))
    SetCamRot(cam, vec(-10.62967, 2.134434e-07, -110.7972))
    RenderScriptCams(1, 0, 0, 1, 1)

    LoadAnim(anim)
    TaskPlayAnim(Shared.Ped, anim, dict, 8.0, 8.0, 5000, 1, 1.0, 0, 0, 0)
    Wait(5000)
    RenderScriptCams(0, 1, 1000, 1, 1)
    DestroyCam(cam)
end)

RegisterNetEvent('SkeletonChalice', function()
    Wait(1000)

    if not exports['geo-inventory']:HasItem('skeletonchalice', 1) then return end
    if not exports['geo-shared']:Confirmation("Would you like to use the skeleton chalice?") then
        return
    end

    if not HasNamedPtfxAssetLoaded("scr_rcbarry1") then
        RequestNamedPtfxAsset("scr_rcbarry1")
        while not HasNamedPtfxAssetLoaded("scr_rcbarry1") do
            Wait(0)
        end
    end
    UseParticleFxAssetNextCall("scr_rcbarry1")
    local ped = Shared.SpawnPed(`skeleton`, GetOffsetFromEntityInWorldCoords(Shared.Ped, 0.0, 5.0, -0.98))
    local particle = StartNetworkedParticleFxNonLoopedAtCoord("scr_alien_teleport", GetOffsetFromEntityInWorldCoords(Shared.Ped, 0.0, 5.0, 0.0), 0.0, -2.0, 0.8, 1.0, 1, 0, 1, 1)

    Shared.GetEntityControl(ped)
    TaskGoToEntity(ped, Shared.Ped, -1, 1.0, 10.0, 1073741824.0, 0)
    
    while Vdist3(GetEntityCoords(ped), GetEntityCoords(Shared.Ped)) >= 1.5 do
        TaskGoToEntity(ped, Shared.Ped, -1, 1.0, 1.0, 1073741824.0, 0)
        Wait(1000)
    end

    Shared.GetEntityControl(ped)
    TaskTurnPedToFaceEntity(ped, Shared.Ped, 2000)
    Wait(2000)

    Shared.GetEntityControl(ped)
    TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)
    Wait(15000)


    UseParticleFxAssetNextCall("scr_rcbarry1")
    local particle = StartNetworkedParticleFxNonLoopedAtCoord("scr_alien_teleport", GetEntityCoords(ped), 0.0, -2.0, 0.8, 1.0, 1, 0, 1, 1)
    TriggerServerEvent('DeleteEntity', NetworkGetNetworkIdFromEntity(ped))
    TriggerServerEvent('SkeletonChalice')
end)