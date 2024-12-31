local dropOffs = {
    vector3(-65.66, 6506.08, 31.54)
}

local hashes = {
    [GetHashKey('a_c_deer')] = 'Deer',
    [GetHashKey('a_c_coyote')] = 'Coyote',
    [GetHashKey('a_c_pig')] = 'Pig',
    [GetHashKey('a_c_mtlion')] = 'Mountain Lion',
    [GetHashKey('a_c_cow')] = 'Cow',
    [GetHashKey('a_c_boar')] = 'Boar',
    [GetHashKey('a_c_hen')] = '"Turkey"',
}

AddCircleZone(vector3(-66.09, 6505.13, 31.49), 50.0, {
    name="hunting",
    useZ=false,
    --debugPoly=true
})

local inside = false
AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'hunting' then
        inside = inZone
        if inZone then
            local ped = exports['geo-interface']:InterfacePed({
                model = 'ig_hunter',
                position = vector4(-65.76, 6506.1, 31.54, 180.35),
                title = 'Sell Meat',
                event = Hunting_Menu
            })

            while inside do
                Wait(500)
            end

            exports['geo-interface']:RemovePed(ped)
        end
    end
end)

Menu.CreateMenu('Hunting', 'Hunting')
Citizen.CreateThread(function()

    for k,v in pairs(dropOffs) do
        local blip = AddBlipForCoord(v)
        SetBlipSprite(blip, 119)
		SetBlipAsShortRange(blip, true)
		SetBlipScale(blip, 0.8)
		BeginTextCommandSetBlipName("STRING");
		AddTextComponentString('Hunting Lodge')
		EndTextCommandSetBlipName(blip)
    end


    local hash = GetHashKey('WEAPON_KNIFE')
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local wep = GetSelectedPedWeapon(ped)
        if wep == hash and Shared.CurrentVehicle == 0 then
            local nPed = Shared.ClosestPed(5.0)
            if DoesEntityExist(nPed) then
                if IsEntityDead(nPed) then
                    for k,v in pairs(hashes) do
                        if GetEntityModel(nPed) == k then
                            while Vdist4(GetEntityCoords(ped), GetEntityCoords(nPed)) <= 5.0 do
                                Wait(0)

                                if GetSelectedPedWeapon(ped) ~= hash then
                                    break
                                end

                                SetTextComponentFormat("STRING")
                                AddTextComponentString("Press ~INPUT_ATTACK~ to harvest from the "..v)
                                DisplayHelpTextFromStringLabel(0, 0, 1, -1)
                                DisableControlAction(0, 24)
                                if IsDisabledControlJustPressed(0, 24) then
                                    local breakpoint = false
                                    Citizen.CreateThread(function()
                                        while DoesEntityExist(nPed) do
                                            Wait(0)
                                            SetTextComponentFormat("STRING")
                                            AddTextComponentString("Press ~INPUT_DETONATE~ to cancel the harvest")
                                            DisplayHelpTextFromStringLabel(0, 0, 1, -1)
                                            if IsControlJustPressed(0, 47) then
                                                breakpoint = true
                                                break
                                            end
                                        end
                                    end)

                                    LoadAnim('amb@medic@standing@kneel@base')
                                    LoadAnim('anim@gangops@facility@servers@bodysearch@')
                                    Wait(1000)
                                    TaskTurnPedToFaceEntity(ped, nPed, 1000)
                                    TaskPlayAnim(PlayerPedId(), 'amb@medic@standing@kneel@base', 'base' ,2.0, 1.0, -1, 1, 0, false, false, false )
                                    TaskPlayAnim(PlayerPedId(), 'anim@gangops@facility@servers@bodysearch@', 'player_search' ,1.0, -8.0, -1, 48, 0, false, false, false )

                                    while DoesEntityExist(nPed) do

                                        if breakpoint then
                                            break
                                        end

                                        TaskPlayAnim(PlayerPedId(), 'anim@gangops@facility@servers@bodysearch@', 'player_search' ,1.0, -8.0, -1, 48, 0, false, false, false )
                                        Wait(6000)

                                        if not IsEntityPlayingAnim(PlayerPedId(), 'anim@gangops@facility@servers@bodysearch@', 'player_search', 3) then
                                            break
                                        end

                                        TriggerServerEvent('Hunting:Harvest', PedToNet(nPed))
                                        Wait(500)
                                    end
                                    StopAnimTask(PlayerPedId(), 'amb@medic@standing@kneel@base', 'base', 1.0)
                                    StopAnimTask(PlayerPedId(), 'anim@gangops@facility@servers@bodysearch@', 'player_search', 1.0)
                                end
                            end
                        end
                    end
                else
                    Wait(500)
                end
            else
                Wait(500)
            end
        else
            Wait(1000)
        end
    end
end)

function Hunting_Menu()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local loc

    for k,v in pairs(dropOffs) do
        if Vdist4(pos, v) <= 100.0 then
            loc = v
        end
    end

    local list = {}

    for k,v in pairs(meatPrices) do
        local val = exports['geo-inventory']:Amount(k)
        if val > 0 then
            table.insert(list, {k, val, exports['geo-inventory']:GetItemName(k), 1})
        end
    end

    if loc then
        Menu.OpenMenu('Hunting')
        while Menu.CurrentMenu == 'Hunting' do
            Wait(0)
            if Vdist4(GetEntityCoords(ped), loc) > 100.0 then
                Menu.CloseMenu()
                break
            end

            for k,v in pairs(list) do
                if v[2] > 0 then
                    if Menu.Slider(v[3], v[2], v[4], function(current)
                        if list[k][4] ~= current then
                            list[k][4] = current
                        end
                    end) then
                        TriggerServerEvent('Hunting:Sell', v[1], v[4])
                        list[k][2] = list[k][2] - v[4]
                    end
                end
            end

            Menu.Display()
        end
    end
end

RegisterCommand('spawn', function(source, args)
    if MyCharacter.username == nil then return end
    local animal = args[1] or Shared.TextInput('animal')
    animal = GetHashKey(animal)
    local ped = Shared.SpawnPed(animal, GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 5.0, 0.0))
    SetEntityMaxHealth(ped, 100)
    SetPedMaxHealth(ped, 100)
    SetEntityHealth(ped, 100)
    Wait(100)
    SetPedSuffersCriticalHits(ped, false)
    SetPedConfigFlag(ped, 2, true)
    SetPedConfigFlag(ped, 33, false)
    SetPedConfigFlag(ped, 17, true)
    SetPedConfigFlag(ped, 188, true)
    SetPedCanPlayInjuredAnims(ped, false)
    SetPedDiesWhenInjured(ped, false)
end)