local breakPoint = false
local Instance = {}
local VehicleInstance = {}
TriggerServerEvent('InstanceInit')

AddEventHandler('Instance', function(inst)
    Instance = inst
end)

local hasKey = false
exports('HasKey', function()
    return hasKey
end)

Menu.CreateMenu('Outfits', 'Outfits')
RegisterNetEvent('EnterProperty')
AddEventHandler('EnterProperty', function(property, int, key, npos, veh, seat)
    hasKey = key
    if interiors[int].IPL then
        RequestIpl(interiors[int].IPL)
    end

    local serverID = GetPlayerServerId(PlayerId())
    local propertySpawn = vec(interiors[int].Spawn.x, interiors[int].Spawn.y, interiors[int].Spawn.z)
    local ped = PlayerPedId()
    local startPos = GetEntityCoords(ped)
    local heading
    if npos then
        startPos = vec(table.unpack(npos, 1 ,3))
        heading = npos[4]
    end
    local prop
    if interiors[int].Prop then
        local model = GetHashKey(interiors[int].Prop)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(0)
        end
        prop = CreateObject(model, GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, -100.0), 0, 0, 0)
        SetEntityCollision(prop, false, false)
        SetEntityHeading(prop, 0.0)
        FreezeEntityPosition(prop, true)
        SetModelAsNoLongerNeeded(model)
        local val = interiors[int].Spawn.w
        local veh = GetVehiclePedIsIn(ped, false)
        Warp(GetOffsetFromEntityInWorldCoords(prop, vec(interiors[int].Spawn.x, interiors[int].Spawn.y, interiors[int].Spawn.z)), val, veh)
        propertySpawn = GetEntityCoords(PlayerPedId())
    else
        local veh = GetVehiclePedIsIn(ped, false)
        Warp(interiors[int].Spawn, interiors[int].Spawn.w, interiors[int].Vehicles == true and veh or nil)
    end

    if interiors[int].Doors then
        for k,v in pairs(interiors[int].Doors) do
            AddDoorToSystem(k + 1000, v.Hash, v.Pos, false, false, false)
            DoorSystemSetDoorState(k + 1000, 4, false, false)
        end
    end

    if veh then
        SetPedIntoVehicle(Shared.Ped, NetworkGetEntityFromNetworkId(veh), seat)
    end


    local ped
    if property:match('PD Motel') then
        local str = SplitString(property, 'PD Motel:')[1]
        local char = json.decode(Task.Run('PDChar', str))
        LoadAnim('anim@mp_bedmid@left_var_01')
        ped = Shared.SpawnPed(char.Model, vector4(349.57, -996.19, -98.54, 272.81), true)
        exports['geo-interface']:SetPed(ped, 'Rob', function() 
            exports['geo-interface']:SetPed(ped, nil)
            SetEntityCoords(ped, 349.57, -996.19, -98.54)
            GiveWeaponToPed(ped, GetHashKey('WEAPON_PUMPSHOTGUN'), 9999, false, true)
            SetCurrentPedWeapon(ped, GetHashKey('WEAPON_PUMPSHOTGUN'), true)
            SetPedCombatAttributes(ped, 46, true)
            SetPedCombatAbility(ped, 2)
            TaskCombatPed(ped, Shared.Ped)
            FreezeEntityPosition(ped, false)
            CreateThread(function()
                while MyCharacter.dead == 0 and DoesEntityExist(ped) do
                    Wait(250)
                end

                if DoesEntityExist(ped) then
                    FreezeEntityPosition(ped, true)
                    SetEntityHeading(ped, 272.81)
                    SetEntityInvincible(ped, true)
                    SetBlockingOfNonTemporaryEvents(ped, true)
                    SetPedCanBeTargetted(ped, false)
                    SetPedKeepTask(ped, true)
                    local rot = GetEntityRotation(ped)
                    SetFacialIdleAnimOverride(ped, 'mood_sleeping_1', 0)
                    TaskPlayAnimAdvanced(ped, 'anim@mp_bedmid@left_var_01', 'f_sleep_l_loop_bighouse', 349.57, -996.19, -99.15, rot.x, rot.y, rot.z, 8.0, 8.0, -1, 1, 0, 0, 0, 0)
                end
            end)
        end)
        exports['geo']:LoadClothing(char, ped)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedCanBeTargetted(ped, false)
        SetPedKeepTask(ped, true)
        local rot = GetEntityRotation(ped)
        SetFacialIdleAnimOverride(ped, 'mood_sleeping_1', 0)
        TaskPlayAnimAdvanced(ped, 'anim@mp_bedmid@left_var_01', 'f_sleep_l_loop_bighouse', 349.57, -996.19, -99.15, rot.x, rot.y, rot.z, 8.0, 8.0, -1, 1, 0, 0, 0, 0)
    end

    TriggerEvent('Inventory.Update')
    while MyCharacter.interior == property do
        Wait(0)

        --[[ for k,v in pairs(GetActivePlayers()) do
            if v ~= PlayerId() then
                if (Instance[GetPlayerServerId(v)] or 'None') ~= (Instance[serverID] or 'None') then
                    NetworkConcealPlayer(v, true)
                else
                    NetworkConcealPlayer(v, false)
                end
            end
        end ]]

        if breakPoint then
            breakPoint = false
            return
        end

        if MyCharacter == nil then
            return
        end

        if Vdist4(GetEntityCoords(Shared.Ped), propertySpawn) < 5.0 then
            if IsControlJustPressed(0, 38) then
                if interiors[int].IPL then
                    SetTimeout(500, function()
                        RemoveIpl(interiors[int].IPL)
                    end)
                end

                if prop then
                    DeleteObject(prop)
                end
                break
            end  
        end

        if key then
            if Vdist4(GetEntityCoords(Shared.Ped), interiors[int].Inventory) < 1.0 then
                Shared.WorldText('E', interiors[int].Inventory, 'Inventory')
                if IsControlJustPressed(0, 38) then
                    TriggerServerEvent('Property:OpenInventory')
                end  
            end
    
            if Vdist4(GetEntityCoords(Shared.Ped), interiors[int].Closet) < 1.0 then
                Shared.WorldText('Outfits', interiors[int].Closet, 'Outfits')
                if IsControlJustPressed(0, 38) then
                    if not Menu.CurrentMenu then
                        local outfits = Task.Run('GetOutfits') or {}
                        Menu.OpenMenu('Outfits')
                        while Menu.CurrentMenu == 'Outfits' do
                            Wait(0)

                            for k,v in pairs(outfits) do
                                if Menu.Button(json.decode(v.clothing).Name) then
                                    local clothing = json.decode(v.clothing)
                                    exports['geo']:LoadClothing(clothing)
                                end
                            end

                            Menu.Display()
                        end
                    end
                end  
            end
        end
        
        if not interiors[int].Prop then
            if Vdist4(GetEntityCoords(Shared.Ped), propertySpawn) >= 10000.0 then
                Warp(interiors[int].Spawn, interiors[int].Spawn.w)
                Wait(500)
            end
        end
    end

    if ped then
        exports['geo-interface']:SetPed(ped, nil)
        DeleteEntity(ped)
    end

    if interiors[int].Doors then
        for k,v in pairs(interiors[int].Doors) do
            RemoveDoorFromSystem(k + 1000)
        end
    end

    local veh = GetVehiclePedIsIn(Shared.Ped, false)
    if veh ~= 0 then
        if GetPedInVehicleSeat(veh, -1) == Shared.Ped then
            TriggerServerEvent('Instance:Exit', VehToNet(veh))
            Warp(startPos, heading, veh)
            return
        end
    end
    Warp(startPos, heading)
    hasKey = false
    TriggerServerEvent('Instance:Exit')

   while MyCharacter.interior ~= nil do
        Wait(100)
   end
   TriggerEvent('Inventory.Update')
end)

RegisterNetEvent('Instance:Exit')
AddEventHandler('Instance:Exit', function(veh, pos, heading, seat)
    Warp(pos, heading)
    Wait(500)
    SetPedIntoVehicle(Shared.Ped, NetworkGetEntityFromNetworkId(veh), seat)
end)

RegisterNetEvent('Interior:Break')
AddEventHandler('Interior:Break', function()
    breakPoint = true
end)