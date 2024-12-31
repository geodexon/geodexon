local hostile = {}
local name, group = AddRelationshipGroup('mugged')

CreateThread(function()
    while true do
        Wait(0)
        AttemptRobbery()
    end
end)

function ReportCrime(perc)
    local peds = GetGamePool('CPed')
    local ped = PlayerPedId()
    local pos = GetEntityCoords(PlayerPedId())
    for k,v in pairs(peds) do
        if not IsPedAPlayer(v) then
            if Vdist4(pos, GetEntityCoords(v)) <= 1000.0 then
                if HasEntityClearLosToEntityInFront(v, ped) then
                    local num = math.random(100)
                    if num < (perc or 25) then
                        return true
                    end
                end
            end
        end
    end
end

function AttemptRobbery()
    if IsPedArmed(Shared.Ped, 4) then
        local aiming, ent = GetEntityPlayerIsFreeAimingAt(PlayerId())
        if aiming and not IsPedAPlayer(ent) and GetVehiclePedIsIn(ent, false) == 0 then

            if GetEntityType(ent) ~= 1 then
                Wait(500)
                return
            end

            if not IsPedHuman(ent) then return end

            if MissionPeds[ent] then
                Wait(500)
                return
            end 

            if NetworkGetEntityIsNetworked(ent) then
                local p = Entity(ent)

                if p.state.robbed or p.state.hostage then
                    Wait(500)
                    return
                end

                Citizen.Await(PedAction(ent, function()
                    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(ent), false)
                    local startEnt = ent
                    local willBeHostile = Random(100) > 80
                    --[[ if willBeHostile then
                        p.state.mad = true
                        mad = true
                        ClearPedTasks(ent)
                        SetPedCombatAttributes(ent, 3, false)
                        SetPedCombatAttributes(ent, 5, true)
                        SetPedCombatAttributes(ent, 46, true)
                        SetPedSuffersCriticalHits(ent, false)
                        SetPedAsEnemy(ent, true)
                        TaskCombatPed(ent, Shared.Ped, 0, 16)
                    end ]]

                    local mad = p.state.mad or false
                    local attack = false
                    local aimTime = GetGameTimer()
                    local _int
                    while GetGameTimer() - aimTime < 2000 do
                        Wait(0)
                        aiming, ent = GetEntityPlayerIsFreeAimingAt(PlayerId())

                        if ent == startEnt then
                            aimTime = GetGameTimer()
                        end

                        if not mad then
                            local dist = Vdist3(GetEntityCoords(Shared.Ped), GetEntityCoords(startEnt))
                            if dist <= 20.0 then
                                if not handsUp then
                                    SetBlockingOfNonTemporaryEvents(startEnt, true)
                                    SetPedFleeAttributes(startEnt, 0, 0)
                                    TaskHandsUp(startEnt, 50000, Shared.Ped, -1, true)
                                    handsUp = true
                                else
                                    if dist <= 3.0 then
                                        _int = Shared.Interact('[E] Rob') or _int
                                        if IsControlJustPressed(0, 38) then
                                            if not IsEntityDead(startEnt) then
                                                LoadAnim('random@mugging2')
                                                TaskPlayAnim(Shared.Ped, 'random@mugging2', 'ig_1_guy_stickup_loop', 8.0, -8, -1, 1, 0, 0, 0, 0)
                                                if ReportCrime(50) and RateLimit('Rob', 60000) then
                                                    TriggerServerEvent('NPC.Rob', Shared.GetLocation())
                                                end
                                                if Minigame(10) then
                                                    TriggerServerEvent('Mugging.Mug', NetworkGetNetworkIdFromEntity(startEnt))
                                                end
                                                StopAnimTask(Shared.Ped, 'random@mugging2', 'ig_1_guy_stickup_loop', 1.0)
                                            else
                                                LoadAnim('amb@medic@standing@kneel@base')
                                                LoadAnim('anim@gangops@facility@servers@bodysearch@')
                                                TaskTurnPedToFaceEntity(Shared.Ped, startEnt, 1000)
                                                TaskPlayAnim(Shared.Ped, 'amb@medic@standing@kneel@base', 'base' ,2.0, 1.0, -1, 1, 0, false, false, false )
                                                TaskPlayAnim(Shared.Ped, 'anim@gangops@facility@servers@bodysearch@', 'player_search' ,1.0, -8.0, -1, 48, 0, false, false, false )
                                                local lost = false

                                                for i=1,3 do
                                                    if not Minigame(15, 2000) then
                                                        lost = true
                                                        break
                                                    end
                                                end
                                                StopAnimTask(Shared.Ped, 'amb@medic@standing@kneel@base', 'base', 1.0)
                                                StopAnimTask(Shared.Ped, 'anim@gangops@facility@servers@bodysearch@', 'player_search', 1.0)
                                            
                                                if not lost then
                                                    TriggerServerEvent('Mugging.Mug', NetworkGetNetworkIdFromEntity(ent))
                                                end
                                            end
                                        end
                                    else
                                        if _int then 
                                            _int.stop() 
                                            int = nil
                                        end
                                    end
                                end
                            else
                                if _int then 
                                    _int.stop()
                                    int = nil
                                end
                                if IsEntityDead(ent) then
                                    mad = false
                                end
                            end
                        end
                    end
                    if _int then _int.stop() end
                    handsUp = false
                    TaskHandsUp(startEnt, 1, Shared.Ped, 1, true)
                    SetBlockingOfNonTemporaryEvents(startEnt, false)
                    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(startEnt), true)
                end))
            end
        else
            Wait(500)
        end
    else
        Wait(500)
    end
end