local anims = {
    'dead_a',
    'dead_b',
    'dead_c',
    'dead_d',
    'dead_e',
    'dead_f',
    'dead_g',
}

AddEventHandler('baseevents:onPlayerDied', function()
    if MyCharacter.dead == 1 then
        return
    end

    local anim = anims[Random(#anims)]
    UpdateCharacter('dead', 1)

    local ped = PlayerPedId()
    local myDeadPed = PlayerPedId()


    Wait(2000)
    local pos = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local seat 
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 then
        for i=-1,10 do
            if GetPedInVehicleSeat(veh, i) == ped then
                seat = i
                break
            end
        end
    end

    while GetEntitySpeed(ped) > 1.0 do
        Wait(500)
    end

    NetworkResurrectLocalPlayer(pos, heading, true, true, false)
    exports['geo-inventory']:ToggleWeapon()
    SetEntityMaxHealth(PlayerPedId(), 200)
    SetEntityHealth(PlayerPedId(), 200)
    Wait(100)
    ped = PlayerPedId()

    if myDeadPed ~= ped then
        DeleteEntity(myDeadPed)
    end

    LoadAnim('dead')
    TaskPlayAnim(Shared.Ped, 'dead', anim, 8.0, -8, -1, 1, 0, 0, 0, 0)

    SetEntityInvincible(PlayerPedId(), true)
    SetPedIntoVehicle(PlayerPedId(), veh, seat)

    Citizen.CreateThread(function()
        local time = GetGameTimer()
        while Character.dead == 1 do
            Wait(0)
            DisableControlAction(2, 34, true)
            DisableControlAction(2, 35, true)
            for i=59,90 do
                DisableControlAction(2, i, true)
            end
            Shared.DisableWeapons()
        end
    end)

    while Character.dead == 1 do
        if Character.dead == 0 then
            break
        end
        if GetEntityHealth(PlayerPedId()) <= 0 then
            SetEntityHealth(PlayerPedId(), 200)
        end

        if Shared.CurrentVehicle == 0 then
            if not IsEntityPlayingAnim(Shared.Ped, 'dead', anim, 8.0) then
                LoadAnim('dead')
                TaskPlayAnim(Shared.Ped, 'dead', anim, 8.0, -8, -1, 1, 0, 0, 0, 0)
            end
            Wait(250)
        else
            if not IsEntityPlayingAnim(Shared.Ped, 'veh@std@ds@base', 'die', 1.0) then
                LoadAnim('veh@std@ds@base')
                TaskPlayAnim(Shared.Ped, 'veh@std@ds@base', 'die', 1.0, -8, -1, 1, 0, 0, 0, 0)
            end
            Wait(1000)
        end
      
    end

    Wait(500)
    StopAnimTask(Shared.Ped, 'dead', anim, 1.0)
    SetPedToRagdoll(PlayerPedId(), 100, 100, 0, 1, 1, 0)
    SetEntityInvincible(PlayerPedId(), false)
    SetPedSuffersCriticalHits(PlayerPedId(), false)
end)
