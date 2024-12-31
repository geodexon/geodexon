local Store = {}

Citizen.CreateThread(function()
   --[[  RegisterProximityMenu('Convenience Store', {Name = 'Convenience Store', pos = StoreList.Convenience.Locations, func = Store.Convenience, range = 20.0})
    RegisterProximityMenu('Ammunation', {Name = 'Ammunation', pos = StoreList.Ammunation.Locations, func = Store.Ammunation, range = 20.0}) ]]

    for k,v in pairs(StoreList.Convenience.Locations) do
        local blip = AddBlipForCoord(v)
        SetBlipSprite(blip, 52)
        SetBlipColour(blip, 14)
		SetBlipAsShortRange(blip, true)
		SetBlipScale(blip, 0.8)
		BeginTextCommandSetBlipName("STRING");
		AddTextComponentString('Convenience Store')
        EndTextCommandSetBlipName(blip)
        AddCircleZone(v, 15.0, {
            name="Store.Open",
            useZ=true,
            id = uuid(),
            func = Store.Convenience,
            pos = v,
            storeID = k,
            StoreName = 'Convenience',
            entry = 'ConvStore',
            entryRob = 'ConvStoreRob',
            model = 303280717,
        })
    end

    for k,v in pairs(StoreList.Ammunation.Locations) do
        local blip = AddBlipForCoord(v)
        SetBlipSprite(blip, 110)
        SetBlipColour(blip, 1)
		SetBlipAsShortRange(blip, true)
		SetBlipScale(blip, 0.8)
		BeginTextCommandSetBlipName("STRING");
		AddTextComponentString('Ammunation')
        EndTextCommandSetBlipName(blip)
        
        AddCircleZone(v, 15.0, {
            name="Store.Open",
            useZ=true,
            id = uuid(),
            func = Store.Ammunation,
            pos = v,
            storeID = k,
            StoreName = 'Ammunation',
            entry = 'AmmuStore',
            entryRob = 'AmmuStoreRob',
            model = 303280717,
        })
    end

    for k,v in pairs(StoreList.Hardware.Locations) do
        local blip = AddBlipForCoord(v)
        SetBlipSprite(blip, 544)
        SetBlipColour(blip, 3)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING");
		AddTextComponentString('Hardware Store')
        EndTextCommandSetBlipName(blip)
        
        AddCircleZone(v, 15.0, {
            name="Store.Open",
            useZ=true,
            id = uuid(),
            func = Store.Hardware,
            pos = v,
            entry = 'HardwareStore',
        })
    end

    for k,v in pairs(StoreList['The Donut Shop'].Locations) do
        AddCircleZone(v, 15.0, {
            name="Store.Open",
            useZ=true,
            id = uuid(),
            func = Store.Police,
            pos = v,
            entry = 'PoliceStore',
            Req = StoreList['The Donut Shop'].Req
        })
    end

    for k,v in pairs(StoreList['Tobacco Shop'].Locations) do
        AddCircleZone(v, 15.0, {
            name="Store.Open",
            useZ=true,
            id = uuid(),
            func = Store.EMS,
            pos = v,
            entry = 'EMSStore',
            Req = StoreList['Tobacco Shop'].Req
        })
    end
end)

function Store:Convenience()
    Menu.OpenMenu('null')
    InventoryMenu('StoreUI', 'Convenience')
end

function Store:Ammunation()
    Menu.OpenMenu('null')
    InventoryMenu('StoreUI', 'Ammunation')
end

function Store:Hardware()
    Menu.OpenMenu('null')
    InventoryMenu('StoreUI', 'Hardware')
end

function Store:Police()
    Menu.OpenMenu('null')
    InventoryMenu('StoreUI', 'The Donut Shop')
end

function Store:EMS()
    Menu.OpenMenu('null')
    InventoryMenu('StoreUI', 'Tobacco Shop')
end

AddTextEntry("ConvStore", "~INPUT_CONTEXT~ Open Convenience Store")
AddTextEntry("ConvStoreRob", "~INPUT_RELOAD~ Rob Convenience Store")

AddTextEntry("AmmuStore", "~INPUT_CONTEXT~ Open Gun Store")
AddTextEntry("AmmuStoreRob", "~INPUT_RELOAD~ Rob Gun Store")

AddTextEntry("HardwareStore", "~INPUT_CONTEXT~ Open Hardware Store")
AddTextEntry("PoliceStore", "~INPUT_CONTEXT~ Open The Donut Shop")
AddTextEntry("EMSStore", "~INPUT_CONTEXT~ Open The Tobacco Shop")


local atStore = false
local shopKeep = 416176080
local clerkTimes = {}
local robCount = 0
local lastRob = 0

AddEventHandler('Poly.Zone', function(zone, inZone, data)
    if zone == 'Store.Open' then
        if data.entry == 'LSC' then return end
        atStore = inZone

        if not atStore then
            return
        end

        local license = true
        if data.entry == 'AmmuStore' then
            license = Task.Run('HasGunLicense')
        end

        if data.Req then
            if data.Req == 'isPolice' then
                if not exports['geo-es']:IsPolice(MyCharacter.id) then
                    return
                end
            elseif data.Req == 'isEMS' then
                if not exports['geo-es']:IsEMS(MyCharacter.id) then
                    return
                end
            end
        end

        local robbing = false
        local isRobbing = false
        local obj = GetClosestObjectOfType(data.pos, 10.0, data.model)
        local tPos
        local clerk

        if obj ~= 0 then
            if clerkTimes[data.id] == nil then
                clerkTimes[data.id] = -999999999
            end

            tPos = GetOffsetFromEntityInWorldCoords(obj, 0.0, -0.6, 0.0)
            local found = false
            for _, ped in pairs(GetGamePool('CPed')) do
                if GetEntityModel(ped) == shopKeep and not IsEntityDead(ped) then
                    if Vdist3(tPos, GetEntityCoords(ped)) <= 3.0 then
                        found = true
                        clerk = ped
                        break
                    end
                end
            end

            if Shared.TimeSince(clerkTimes[data.id]) > 300000 then
                if not found then
                    clerk = exports['geo-jobs']:CreateMissionPed(shopKeep, vec(tPos.x, tPos.y, tPos.z, GetEntityHeading(obj)), false, false)
                    clerkTimes[data.id] = GetGameTimer()
                end
            end
        end

        if MyCharacter.Duty ~= 'Police' then
            CreateThread(function()
                if not clerk then return end
                while atStore do
                    Wait(100)
                    if currentWeapon.ID and DoesEntityExist(clerk) and (not IsEntityDead(clerk)) and GetInteriorFromEntity(Shared.Ped) ~= 0 then
                        local wep
                        if robCount == 1 then
                            wep = 'WEAPON_BAT'
                        elseif robCount == 2 then
                            wep = 'WEAPON_PISTOL'
                        elseif robCount == 3 then
                            wep = 'WEAPON_APPISTOL'
                        elseif robCount == 4 then
                            wep = 'WEAPON_SMG'
                        else
                            wep = 'WEAPON_BAT'
                        end
        
                        GiveWeaponToPed(clerk, GetHashKey(wep), 9999, false, true)
                        SetCurrentPedWeapon(clerk, wep, true)
                        SetPedCombatAttributes(clerk, 46, true)
                        SetPedCombatAbility(clerk, 2)
                        TaskCombatPed(clerk, Shared.Ped)
                        local nPos = GetEntityCoords(Shared.Ped)
                        Task.Run('Store.Pacify', NetworkGetNetworkIdFromEntity(clerk), true)
                        while Vdist3(GetEntityCoords(Shared.Ped), nPos) <= 100.0 and not IsEntityDead(clerk) do
                            Wait(100)

                            if MyCharacter.dead == 1 then
                                ClearPedTasks(clerk)
                                Wait(500)
                                LoadAnim("random@arrests")
                                Shared.GetEntityControl(clerk)
                                Task.Run('Store.Killed', Shared.GetLocation(), PedToNet(clerk))
                                TaskPlayAnim(clerk, "random@arrests", "idle_c", 8.0, 1.0, 5000, 49, 0, 0, 0, 0)
                                Wait(5000)
                                SetCurrentPedWeapon(clerk, GetHashKey('WEAPON_UNARMED'), true)
                                TaskGoToCoordAnyMeans(clerk, vec(tPos.x, tPos.y, tPos.z), 1.30, 0, 0, 786603, 1.0)
                                while Vdist3(GetEntityCoords(clerk), vec(tPos.x, tPos.y, tPos.z)) >= 0.5 do
                                    Wait(100)
                                    if IsEntityDead(clerk) then break end
                                end
                                Wait(1000)
                                TaskTurnPedToFaceEntity(clerk, obj, 2000)
                                SetPedKeepTask(clerk, true)
                                break
                            end
                        end
                        Task.Run('Store.Pacify', NetworkGetNetworkIdFromEntity(clerk))
                        return
                    end
                end
            end)
        end

        while atStore do
            Wait(0)
            local pos = obj ~= 0 and (GetEntityCoords(obj) + vec(0, 0, 0.2)) or data.pos
            local registerDist = Vdist3(pos, GetEntityCoords(Shared.Ped)) <= 2.0

            if registerDist then
                if currentWeapon.ID and clerk then
                    ShowFloatingHelp(data.entryRob, pos, 20, false)
                    if IsControlJustPressed(0, 45) then
                        if IsEntityDead(clerk) then
                            if Vdist3(GetEntityCoords(Shared.Ped), GetOffsetFromEntityInWorldCoords(obj, 0.0, -0.6, 0.0)) <= 1.0 then
                                if Task.Run('Store.CanRob', data.StoreName, data.storeID, Shared.GetLocation()) then
                                    robbing = true
                                    isRobbing = true
                                    LoadAnim('oddjobs@shop_robbery@rob_till')

                                    CreateThread(function()
                                        local _int
                                        while robbing do
                                            Wait(0)
                                            _int = Shared.Interact('[E] Quit Robbing') or _int
                                            if IsControlJustPressed(0, 38) then
                                                robbing = false
                                                break
                                            end
                                        end

                                        if _int then _int.stop() end
                                    end)

                                    robCount = robCount + 1
                                    lastRob = GetGameTimer()
                                    SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(obj, 0.0, -0.6, 0.0))
                                    SetEntityCoords(PlayerPedId(), GetEntityCoords(PlayerPedId()) - vec(0, 0, GetEntityHeightAboveGround(PlayerPedId())))
                                    SetEntityHeading(PlayerPedId(), GetEntityHeading(obj))
                                    TaskPlayAnim(PlayerPedId(), "oddjobs@shop_robbery@rob_till", "enter", 8.0, -8.0, -1, 0, 0, 0, 0, 0)
                                    Wait(GetAnimDuration("oddjobs@shop_robbery@rob_till", "enter") * 1000)
                                    for i=1,40 do
                                        if not robbing then
                                            break
                                        end

                                        TaskPlayAnim(PlayerPedId(),"oddjobs@shop_robbery@rob_till", "loop", 8.0, -8.0, 4000, 1, 0, 0, 0, 0)
                                        Wait(GetAnimDuration("oddjobs@shop_robbery@rob_till", "loop") * 1000)
                                        TriggerServerEvent('Store.Rob')
                                    end
                                    TaskPlayAnim(PlayerPedId(),"oddjobs@shop_robbery@rob_till", "exit", 8.0, -1.50, -1, 0, 0, 0, 0, 0)
                                    robbing = false
                                else
                                    TriggerEvent('Shared.Notif', 'The till is empty')
                                end
                            else
                                TriggerEvent('Shared.Notif', 'You are not close enough to the register')
                            end
                        else
                            if Random(100) <= 100 then
                                if robCount ~= 0 then
                                    if Shared.TimeSince(lastRob) >= 3600000 then
                                        robCount = robCount - 1
                                    end
                                end

                                lastRob = GetGameTimer()
                                robCount = robCount + 1

                                local wep
                                if robCount == 1 then
                                    wep = 'WEAPON_BAT'
                                elseif robCount == 2 then
                                    wep = 'WEAPON_PISTOL'
                                elseif robCount == 3 then
                                    wep = 'WEAPON_APPISTOL'
                                elseif robCount == 4 then
                                    wep = 'WEAPON_SMG'
                                end

                                GiveWeaponToPed(clerk, GetHashKey(wep), 9999, false, true)
                                SetCurrentPedWeapon(clerk, GetHashKey(wep), true)
                                SetPedCombatAttributes(clerk, 46, true)
                                SetPedCombatAbility(clerk, 2)
                                TaskCombatPed(clerk, Shared.Ped)
                                local nPos = GetEntityCoords(Shared.Ped)

                                Task.Run('Store.Pacify', NetworkGetNetworkIdFromEntity(clerk), true)
                                while Vdist3(GetEntityCoords(Shared.Ped), nPos) <= 100.0 and not IsEntityDead(clerk) do
                                    Wait(100)

                                    if Entity(clerk).state.Pacify == nil then
                                        SetCurrentPedWeapon(clerk, GetHashKey('WEAPON_UNARMED'), true)
                                        TaskGoToCoordAnyMeans(clerk, vec(tPos.x, tPos.y, tPos.z), 1.30, 0, 0, 786603, 1.0)
                                        while Vdist3(GetEntityCoords(clerk), vec(tPos.x, tPos.y, tPos.z)) >= 0.5 do
                                            Wait(100)
                                            if IsEntityDead(clerk) then break end
                                        end
                                        Wait(1000)
                                        TaskTurnPedToFaceEntity(clerk, obj, 2000)
                                        SetPedKeepTask(clerk, true)
                                        break
                                    end
            
                                    if MyCharacter.dead == 1 then
                                        ClearPedTasks(clerk)
                                        Wait(500)
                                        LoadAnim("random@arrests")
                                        Shared.GetEntityControl(clerk)
                                        Task.Run('Store.Killed', Shared.GetLocation(), PedToNet(clerk))
                                        TaskPlayAnim(clerk, "random@arrests", "idle_c", 8.0, 1.0, 5000, 49, 0, 0, 0, 0)
                                        Wait(5000)
                                        SetCurrentPedWeapon(clerk, GetHashKey('WEAPON_UNARMED'), true)
                                        TaskGoToCoordAnyMeans(clerk, vec(tPos.x, tPos.y, tPos.z), 1.30, 0, 0, 786603, 1.0)
                                        while Vdist3(GetEntityCoords(clerk), vec(tPos.x, tPos.y, tPos.z)) >= 0.5 do
                                            Wait(100)
                                            if IsEntityDead(clerk) then break end
                                        end
                                        Wait(1000)
                                        TaskTurnPedToFaceEntity(clerk, obj, 2000)
                                        SetPedKeepTask(clerk, true)
                                        break
                                    end
                                end
                                Task.Run('Store.Pacify', NetworkGetNetworkIdFromEntity(clerk))
                            end
                        end
                    end
                else
                    if license then
                        local entry = data.entry
                        if OwnedStores[data.entry] and OwnedStores[data.entry][data.storeID] and OwnedStores[data.entry][data.storeID][3] == true then
                            entry = data.entry..data.storeID
                            AddTextEntry(entry, "~INPUT_CONTEXT~ Open "..(OwnedStores[data.entry][data.storeID][2].name or 'Store'))
                        end

                        ShowFloatingHelp(entry, pos, 20)
                        if IsControlJustPressed(0, 38) then
                            local validStore = OwnedStores[data.entry] and OwnedStores[data.entry][data.storeID]

                            if not validStore or (validStore and validStore[3] == false) then
                                if data.entry == 'ConvStore' then
                                    local employee = json.decode(GlobalState.Convenience)[data.storeID]
                                    if employee == false or employee == MyCharacter.id then
                                        data.func()
                                    else
                                        TriggerEvent('Shared.Notif', 'The store is currently staffed, ring the bell maybe')
                                    end
                                else
                                    data.func()
                                end
                            else
                                if Inventories['Locations'][data.entry..'.'..data.storeID] == nil then
                                    FetchInventory('Locations', data.entry..'.'..data.storeID)
                                end
                                InventoryMenu('StoreUI', data.entry..'.'..data.storeID)
                            end
                        end
                    end
                end
            end
        end

        if isRobbing then
            TriggerServerEvent('Store.Rob.Done')
        end
    end
end)