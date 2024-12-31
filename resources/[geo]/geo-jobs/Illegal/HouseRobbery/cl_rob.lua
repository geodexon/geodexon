local jobState = 'none'
local jobBlip
local near = false
local looting = false
local _int
local ped
local zoneList = {}
local pedDead = false
local pedMode

AddCircleZone(vector3(-1316.76, -940.42, 9.73), 50.0, {
    name="houserobbery",
    useZ=false,
    --debugPoly=true
})

local inside = false
AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'houserobbery' then
        inside = inZone
        if inside then
            local ped = exports['geo-interface']:InterfacePed({
                model = 'g_f_y_vagos_01',
                position = vector4(-1317.06, -940.69, 9.73, 335.17),
                title = 'House Robberies',
                event = 'HouseRob.Menu',
            })

            while inside do
                Wait(500)
            end

            exports['geo-interface']:RemovePed(ped)
        end
    end
end)

AddEventHandler('HouseRob.Menu', function()
    local menu = {
        {title = 'Start Job', serverevent = 'HouseRob.Start', hidden = jobState ~= 'none'},
        {title = 'Quit Job', serverevent = 'HouseRob.Quit', hidden = jobState == 'none'},
        {title = 'Get Paid', serverevent = 'HouseRob.Pay', hidden = jobState ~= 'done'},
    }

    RunMenu(menu)
end)

RegisterNetEvent('HouseRob.SetState', function(state, location)
    jobState = state

    if state == 'phase_1' then
        for k,v in pairs(zoneList) do
            v.remove()
        end
    end

    if jobBlip then RemoveBlip(jobBlip) end
    if state == 'phase_2' then
        jobBlip = AddBlipForCoord(location)
        SetBlipRoute(jobBlip, true)
        near = false

        while jobState == 'phase_2' or jobState == 'done' do
            Wait(500)

            if Vdist3(GetEntityCoords(Shared.Ped), location) <= 3.0 then
                if not near then
                    near = true
                    _int = Shared.Interact('[Interact] Enter') or _int
                end
            else
                if near then
                    near = false
                    if _int then _int = _int.stop() end
                end
            end
        end
    end
end)

RegisterNetEvent('HouseRob.Enter', function(firstEnter)
    if _int then _int = _int.stop() end
    while MyCharacter.interior == nil do
        Wait(100)
    end

    if firstEnter then
        pedDead = false
        pedModel = exports['geo']:GetRandomModel()
        zoneList = {}
        for k,v in pairs(HouseRob.Zones) do
            if v.zonetype == 'Box' then
                local data = exports['PolyZone']:CreateBoxZone(table.unpack(v.zonedata))
                zoneList[k] = exports['geo-interface']:AddTargetZone(v.zonename, k, 'HouseRob.Loot', {k, v.zonedata[1]}, 2.0)
            end
        end
    end

    if ped == nil or ((not pedDead) and (not DoesEntityExist(ped))) then
        ped = Shared.SpawnPed(pedModel, vector4(349.57, -996.19, -98.54, 272.81))
        Wait(500)
        TriggerServerEvent('Ped.Control', PedToNet(ped), true)
        FreezeEntityPosition(ped, true)
        LoadAnim('anim@mp_bedmid@left_var_01')
        local rot = GetEntityRotation(ped)
        TaskPlayAnimAdvanced(ped, 'anim@mp_bedmid@left_var_01', 'f_sleep_l_loop_bighouse', 349.57, -996.19, -99.15, rot.x, rot.y, rot.z, 8.0, 8.0, -1, 1, 0, 0, 0, 0)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedKeepTask(ped, true)
        SetFacialIdleAnimOverride(ped, 'mood_sleeping_1', 0)
    end

    local noise = 0
    if not pedDead then
        SendNUIMessage({
            interface = 'houserob',
            active = true
        })

        SendNUIMessage({
            interface = 'houserob-progress',
            percent = 0
        })

        while MyCharacter.interior do
            Wait(0)
            local lastNoise = noise

            if GetEntitySpeed(Shared.Ped)  < 1 then
                noise = noise - ((GetFrameTime() / 5) * 100)
                if noise < 0 then noise = 0 end
            else
                if IsPedJumping(Shared.Ped) then
                    noise = noise + ((GetFrameTime()) * 100)
                elseif IsPedSprinting(Shared.Ped) then
                    noise = noise + ((GetFrameTime()) * 100)
                elseif IsPedRunning(Shared.Ped) then
                    noise = noise + ((GetFrameTime() / 2) * 100)
                elseif GetPedStealthMovement(Shared.Ped) then
                    noise = noise + ((GetFrameTime() / 20) * 100)
                else
                    noise = noise + ((GetFrameTime() / 5) * 100)
                end
                if noise > 100 then noise = 100 end
            end

            if noise == 100 then
                SendNUIMessage({
                    interface = 'houserob',
                    active = false
                })
                break
            end

            if lastNoise ~= noise then
                SendNUIMessage({
                    interface = 'houserob-progress',
                    percent = noise
                })
            end

            if IsEntityDead(ped) then
                pedDead = true
            end
        end

        SendNUIMessage({
            interface = 'houserob',
            active = false
        })
    end

    if noise == 100 then
        LoadAnim('anim@mp_bedmid@left_var_01')
        local rot = GetEntityRotation(ped)
        SetEntityCompletelyDisableCollision(ped, true, false)
        FreezeEntityPosition(ped, false)
        TaskPlayAnimAdvanced(ped, 'anim@mp_bedmid@left_var_01', 'f_getout_l_bighouse', 349.57, -996.19, -99.15, rot.x, rot.y, rot.z, 8.0, 8.0, 4000, 1, 0, 0, 0, 0)
        Wait(4000)
        GiveWeaponToPed(ped, GetHashKey('WEAPON_KNIFE'), 60, false, true)
        TaskCombatPed(ped, Shared.Ped, 0 ,16)
        Task.Run('HouseRob.HomeInvasion', Shared.GetLocation())
    end
end)

AddEventHandler('Interact', function()
    if near then
        Task.Run('HouseRob.Enter')
    end
end)

AddEventHandler('HouseRob.Loot', function(id, pos)
    if looting then return end
    looting = true
    TaskTurnPedToFaceCoord(Shared.Ped, pos, 1000)
    Wait(1000)
    LoadAnim('anim@gangops@morgue@table@')
    TaskPlayAnim(Shared.Ped, "anim@gangops@morgue@table@", "player_search", 8.0, 1.0, 10500, 1, 0, 0, 0, 0)
    Wait(10000)
    looting = false
    if IsEntityPlayingAnim(Shared.Ped, "anim@gangops@morgue@table@", "player_search", 1) then
        if Task.Run('HouseRob.Loot', id) then
            zoneList[id].remove()
        end
    end
end)

AddEventHandler('onResourceStop', function()
    DeleteEntity(ped)
end)