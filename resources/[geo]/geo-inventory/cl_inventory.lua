itype = 'Drops'
iid = 'Drops'
Inventory = nil
local fetching = nil
breakOff = false
local Drops = {}
currentWeapon = {}
local tTime = 0
hud = false
local wepGroup
serverID = GetPlayerServerId(PlayerId())

AddEventHandler('pedChanged', function(ped)
    SetPedCanSwitchWeapon(ped, false)
end)

CreateThread(function()
    Wait(1000)
    SendNUIMessage({
        type = 'updateList',
        list = items,
        desc = desc,
        slots = Slots,
        Sizes = Sizes,
        Whitelists = Whitelists
    })
    RemoveAllPedWeapons(PlayerPedId(), true)
end)

local controls = {
    [157] = 1,
    [158] = 2,
    [160] = 3,
    [164] = 4,
    [165] = 5,
    [159] = 6,
}

local lastAlert = 0
local damageType = 2

CreateThread(function()
    local pickupList = {"PICKUP_AMMO_BULLET_MP","PICKUP_AMMO_FIREWORK","PICKUP_AMMO_FLAREGUN","PICKUP_AMMO_GRENADELAUNCHER","PICKUP_AMMO_GRENADELAUNCHER_MP","PICKUP_AMMO_HOMINGLAUNCHER","PICKUP_AMMO_MG","PICKUP_AMMO_MINIGUN","PICKUP_AMMO_MISSILE_MP","PICKUP_AMMO_PISTOL","PICKUP_AMMO_RIFLE","PICKUP_AMMO_RPG","PICKUP_AMMO_SHOTGUN","PICKUP_AMMO_SMG","PICKUP_AMMO_SNIPER","PICKUP_ARMOUR_STANDARD","PICKUP_CAMERA","PICKUP_CUSTOM_SCRIPT","PICKUP_GANG_ATTACK_MONEY","PICKUP_HEALTH_SNACK","PICKUP_HEALTH_STANDARD","PICKUP_MONEY_CASE","PICKUP_MONEY_DEP_BAG","PICKUP_MONEY_MED_BAG","PICKUP_MONEY_PAPER_BAG","PICKUP_MONEY_PURSE","PICKUP_MONEY_SECURITY_CASE","PICKUP_MONEY_VARIABLE","PICKUP_MONEY_WALLET","PICKUP_PARACHUTE","PICKUP_PORTABLE_CRATE_FIXED_INCAR","PICKUP_PORTABLE_CRATE_UNFIXED","PICKUP_PORTABLE_CRATE_UNFIXED_INCAR","PICKUP_PORTABLE_CRATE_UNFIXED_INCAR_SMALL","PICKUP_PORTABLE_CRATE_UNFIXED_LOW_GLOW","PICKUP_PORTABLE_DLC_VEHICLE_PACKAGE","PICKUP_PORTABLE_PACKAGE","PICKUP_SUBMARINE","PICKUP_VEHICLE_ARMOUR_STANDARD","PICKUP_VEHICLE_CUSTOM_SCRIPT","PICKUP_VEHICLE_CUSTOM_SCRIPT_LOW_GLOW","PICKUP_VEHICLE_HEALTH_STANDARD","PICKUP_VEHICLE_HEALTH_STANDARD_LOW_GLOW","PICKUP_VEHICLE_MONEY_VARIABLE","PICKUP_VEHICLE_WEAPON_APPISTOL","PICKUP_VEHICLE_WEAPON_ASSAULTSMG","PICKUP_VEHICLE_WEAPON_COMBATPISTOL","PICKUP_VEHICLE_WEAPON_GRENADE","PICKUP_VEHICLE_WEAPON_MICROSMG","PICKUP_VEHICLE_WEAPON_MOLOTOV","PICKUP_VEHICLE_WEAPON_PISTOL","PICKUP_VEHICLE_WEAPON_PISTOL50","PICKUP_VEHICLE_WEAPON_SAWNOFF","PICKUP_VEHICLE_WEAPON_SMG","PICKUP_VEHICLE_WEAPON_SMOKEGRENADE","PICKUP_VEHICLE_WEAPON_STICKYBOMB","PICKUP_WEAPON_ADVANCEDRIFLE","PICKUP_WEAPON_APPISTOL","PICKUP_WEAPON_ASSAULTRIFLE","PICKUP_WEAPON_ASSAULTSHOTGUN","PICKUP_WEAPON_ASSAULTSMG","PICKUP_WEAPON_AUTOSHOTGUN","PICKUP_WEAPON_BAT","PICKUP_WEAPON_BATTLEAXE","PICKUP_WEAPON_BOTTLE","PICKUP_WEAPON_BULLPUPRIFLE","PICKUP_WEAPON_BULLPUPSHOTGUN","PICKUP_WEAPON_CARBINERIFLE","PICKUP_WEAPON_COMBATMG","PICKUP_WEAPON_COMBATPDW","PICKUP_WEAPON_COMBATPISTOL","PICKUP_WEAPON_COMPACTLAUNCHER","PICKUP_WEAPON_COMPACTRIFLE","PICKUP_WEAPON_CROWBAR","PICKUP_WEAPON_DAGGER","PICKUP_WEAPON_DBSHOTGUN","PICKUP_WEAPON_FIREWORK","PICKUP_WEAPON_FLAREGUN","PICKUP_WEAPON_FLASHLIGHT","PICKUP_WEAPON_GRENADE","PICKUP_WEAPON_GRENADELAUNCHER","PICKUP_WEAPON_GUSENBERG","PICKUP_WEAPON_GOLFCLUB","PICKUP_WEAPON_HAMMER","PICKUP_WEAPON_HATCHET","PICKUP_WEAPON_HEAVYPISTOL","PICKUP_WEAPON_HEAVYSHOTGUN","PICKUP_WEAPON_HEAVYSNIPER","PICKUP_WEAPON_HOMINGLAUNCHER","PICKUP_WEAPON_KNIFE","PICKUP_WEAPON_KNUCKLE","PICKUP_WEAPON_MACHETE","PICKUP_WEAPON_MACHINEPISTOL","PICKUP_WEAPON_MARKSMANPISTOL","PICKUP_WEAPON_MARKSMANRIFLE","PICKUP_WEAPON_MG","PICKUP_WEAPON_MICROSMG","PICKUP_WEAPON_MINIGUN","PICKUP_WEAPON_MINISMG","PICKUP_WEAPON_MOLOTOV","PICKUP_WEAPON_MUSKET","PICKUP_WEAPON_NIGHTSTICK","PICKUP_WEAPON_PETROLCAN","PICKUP_WEAPON_PIPEBOMB","PICKUP_WEAPON_PISTOL","PICKUP_WEAPON_PISTOL50","PICKUP_WEAPON_POOLCUE","PICKUP_WEAPON_PROXMINE","PICKUP_WEAPON_PUMPSHOTGUN","PICKUP_WEAPON_RAILGUN","PICKUP_WEAPON_REVOLVER","PICKUP_WEAPON_RPG","PICKUP_WEAPON_SAWNOFFSHOTGUN","PICKUP_WEAPON_SMG","PICKUP_WEAPON_SMOKEGRENADE","PICKUP_WEAPON_SNIPERRIFLE","PICKUP_WEAPON_SNSPISTOL","PICKUP_WEAPON_SPECIALCARBINE","PICKUP_WEAPON_STICKYBOMB","PICKUP_WEAPON_STUNGUN","PICKUP_WEAPON_SWITCHBLADE","PICKUP_WEAPON_VINTAGEPISTOL","PICKUP_WEAPON_WRENCH"}
    local id = PlayerId()
    for k,v in pairs(pickupList) do
        N_0x616093ec6b139dd9(id, GetHashKey(pickupList[a]), false)
    end
    
    for i=1,5 do
        RegisterKeyMapping('use '..i, '[Inventory] Hotbar Slot '..i, 'keyboard', i)
    end

    local id = PlayerId()
    DisablePlayerVehicleRewards(id)
    while true do
        HideHudComponentThisFrame(19)
        HideHudComponentThisFrame(3)
        HideHudComponentThisFrame(4)

        if not currentWeapon.ID or (currentWeapon.ID and wepGroup ~= -1212426201) then
            HideHudComponentThisFrame(14)
        end

        if IsPedShooting(Shared.Ped) then
            local found, ent = GetEntityPlayerIsFreeAimingAt(PlayerId())
            local wep = GetSelectedPedWeapon(Shared.Ped)
        
            if wep ~= `WEAPON_FIREEXTINGUISHER` and wep ~= `WEAPON_STUNGUN` then
                TriggerEvent('ShotFired', found and ent or 0, currentWeapon, items[currentWeapon.Key], Shared.GetLocation().zone)

                if Shared.TimeSince(lastAlert) >= 60000 and MyCharacter.range ~= 1 and wep ~= `WEAPON_SNOWBALL` then
                    lastAlert = GetGameTimer()
                    TriggerServerEvent('Police.ShotFired', Shared.GetLocation())
                end
            end
        end
        
        if damageType ~= 2 then
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 142, true)
        else
            if GetPedStealthMovement(Shared.Ped) then
                DisableControlAction(0, 140, true)
                DisableControlAction(0, 141, true)
                DisableControlAction(0, 142, true)
                DisableControlAction(0, 263, true)
                DisableControlAction(0, 264, true)
            end
        end

        Wait(0)
    end
end)

local firing = false
AddEventHandler('ShotFired', function()
    if firing then
        return
    end

    local aWep = currentWeapon
    if aWep.ID then
        firing = true
        local c = New(aWep)
        if aWep.ID == c.ID then
            local ped = PlayerPedId()
            if HasPedGotWeapon(ped, GetHashKey(items[c.Key].Weapon)) then
                if not items[currentWeapon.Key].Stackable then
                    local wep = GetSelectedPedWeapon(ped)
                    local ammo = GetAmmoInPedWeapon(ped,  GetHashKey(items[c.Key].Weapon))
                    TriggerServerEvent('UpdateAmmo', ammo, c.ID)

                    for k,v in pairs(Inventory) do
                        if v.ID == c.ID then
                            Inventory[k].Data.CurrentAmmo = ammo
                            
                            if items[v.Key].Deteriorate then
                                Inventory[k].Data.Durability = (Inventory[k].Data.Durability or 100) -items[v.Key].Deteriorate
                            end
                            break
                        end
                    end

                    Inventories['Player'][tostring(GetPlayerServerId(PlayerId()))] = Inventory
                else
                    TriggerEvent('Holster:PauseFor', 500)
                    TriggerServerEvent('RemoveItem', currentWeapon.ID, 1)
                end
            end
        end
        firing = false
    end
end)

AddEventHandler('ShotFired', function()
    if currentWeapon.ID then
        if GetAmmoInPedWeapon(Shared.Ped,  GetHashKey(items[currentWeapon.Key].Weapon)) <= 0 then
            Wait(0)
            DisableControlAction(0, 24, true)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if MyCharacter then
            local pos = GetEntityCoords(Shared.Ped)
            local found = false

            for k,v in pairs(Drops) do
                if MyCharacter.interior == v[2] then
                    if Inventories['Drops'][k] then
                        for key,val in pairs(Inventories['Drops'][k]) do
                            if Vdist4(pos, v[1]) <= 50.0 then
                                found = true
                                DrawMarker(20, v[1].x, v[1].y, v[1].z -0.6, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.4, 0.1, 0.1, 255, 255, 255, 255, 0, true, 0, 0)
                                break
                            end
                        end
                    end
                end
            end

            if not found then
                Wait(1000)
            end
        end
    end
end)

RegisterNUICallback(
    "Transfer",
    function(data)
        data.amount = tonumber(data.amount)

        local itype = data.startType
        local iid = data.startinvID

        local pType2 = data.endType
        local pId2 = data.endinvID
        if pId2 == 'undefined' then pId2 = serverID end

        if data.amount == nil then
            SetCache()
            RefreshInv()
            return
        end

        --[[ if data.origin == data.target then
            SetCache()
            return
        end ]]

        local from = 'Player'
        local origin = tonumber(mysplit(data.origin, 'plyr')[1])
        if origin == nil then
            origin = tonumber(mysplit(data.origin, 'othr')[1])
            from = 'Other'
        end

        local to = 'Other'
        local target = tonumber(mysplit(data.target, 'plyr')[1])

        if target == nil then
            target = tonumber(mysplit(data.target, 'othr')[1])
        else
            to = 'Player'
        end

        if data.amount == 0 then
            if from == 'Player' then
                data.amount = Inventory[origin].Amount
            else
                if itype ~= 'StoreUI' then
                    data.amount = Inventories[itype][tostring(iid)][origin].Amount
                else
                    data.amount = 1
                end
            end
        end

        if itype == 'StoreUI' then

            if to == 'Other' then
                RefreshInv( )
                return
            end

            if to == 'Player' and from ~= 'Player' then
                TriggerServerEvent('Store:Purchase', iid, origin, data.amount, target)
                return
            end
        end


        local iFrom = New({type = itype, id = from == 'Player' and serverID or iid, itemID = origin, item = from == 'Player' and Inventory[origin] or Inventories[itype][iid][origin], amount = data.amount, charID = MyCharacter.id})
        local iTo = {type = pType2, id = pId2 or serverID}

        TriggerServerEvent('Inventory:TransferItem', iFrom, iTo, target)
        HandleTransfer(origin, to, data, from)
        SetCache()
    end
)

RegisterNUICallback(
    "Transfer2",
    function(data)

        local to = 'Other'
        local target = tonumber(mysplit(data.target, 'plyr')[1])

        if target == nil then
            target = tonumber(mysplit(data.target, 'othr')[1])
        else
            to = 'Player'
        end

        if to and target then
            TriggerServerEvent('Inventory:Transfer2', itype, iid, to, target, data.amount)
        else
            RefreshInv()
        end
    end
)

RegisterNUICallback(
    "Use",
    function(data)
        if true then
            local origin = tonumber(mysplit(data.origin, 'plyr')[1])
        if origin == nil then
            origin = tonumber(mysplit(data.origin, 'othr')[1])
            from = 'Other'
        end
            SetCache()
            ExecuteCommand('use '..origin)
            return
        end
    end
)


RegisterNUICallback(
    "Refresh",
    function(data)
        RefreshInv()
    end
)

RegisterNUICallback(
    "Focus",
    function(data)
        UIFocus(false, false)
        hud = false
        SendNUIMessage({
            type = 'inventoryUI',
            open = hud,
            known = exports['geo-interface']:Known(),
            user = MyUser
        })
        UIFocus(hud, hud)

        breakOff = true
    end
)

RegisterNUICallback(
    "Unload",
    function(data)
        ExecuteCommand('unload')
    end
)

RegisterNUICallback(
    "TakeEvidence",
    function(data)
        Task.Run('Police.TakeEvidence', iid, data.item, data.key, data.slot)
    end
)

RegisterNUICallback(
    "OutfitName",
    function(data)
        breakOff = true
        Wait(1000)
        local val = exports['geo-shared']:Dialogue({
            {
                placeholder = 'Name',
                title = 'New Outfit Name',
                image = 'person'
            },
        })

        Task.Run('RenameOutfit', data.id, val[1])
    end
)

RegisterNUICallback(
    "Equip",
    function(data)
        Task.Run('Inventory.Equip', data.id, data.bool)
    end
)

function SetCache()
    SendNUIMessage({
        type = 'cache',
    })
end

function RefreshInv()

    if not Inventory then
        return
    end

    local a = {}
    local b = {}
    Inventory = Inventories['Player'][tostring(serverID)]
    for k,v in pairs(Inventory) do
        a[tostring(k)] = v
    end

    local b = {}
    if Inventories[itype][tostring(iid)] then
        for k,v in pairs(Inventories[itype][tostring(iid)]) do
            b[tostring(k)] = v
        end
    end

    if itype == 'StoreUI' then
        local n = {}
        if StoreList[iid] then
            for k,v in pairs(StoreList[iid].Items) do
                local item = InstanceItem(v[1])
                item.Price = '$'..comma_value((MyCharacter.job == 'Convenience' and iid == 'Convenience') and math.floor( GetPrice(v[2]) / 2) or GetPrice(v[2]))
                n[k] = item
            end
        else
            n = GetOwnedStoreItems(iid)
        end

        for k,v in pairs(n) do
            b[tostring(k)] = v
        end
    end

    SendNUIMessage({
        type = 'inventoryUpdate',
        inventory = a,
        invType = 'Player',
        id = 'Player',
        cid = MyCharacter and MyCharacter.id or 0
    })

    if itype  ~= 'Player' then
        SendNUIMessage({
            type = 'inventoryUpdate',
            inventory = b,
            invType = 'Other',
            id = itype,
            othersize = GetMaxWeight(itype, iid),
            name = Local(itype, iid),
            realname = iid,
            cid = MyCharacter and MyCharacter.id or 0
        })
    else
        if tostring(iid) == tostring(serverID) then
            SendNUIMessage({
                type = 'inventoryUpdate',
                inventory = {},
                name = Local(itype, iid),
                invType = 'Other',
                id = itype,
                realname = iid,
                cid = MyCharacter and MyCharacter.id or 0
            })
        else
            SendNUIMessage({
                type = 'inventoryUpdate',
                inventory = b,
                invType = 'Other',
                name = Local(itype, iid),
                othersize = GetMaxWeight(itype, iid),
                id = itype,
                realname = iid,
                cid = MyCharacter and MyCharacter.id or 0
            })
        end
    end
end

AddEventHandler('Login', function(char)
    Inventoy = nil
    while Inventoy == nil do
        Wait(100)
    end
    Wait(1000)
    TriggerEvent('Inventory.Update', Inventory)
end)

local change = false
RegisterNetEvent('Inventory:Update')
AddEventHandler('Inventory:Update', function(type, id, newData)
    local var = newData
    local nvar = {}
    if newData ~= nil then
        for k,v in pairs(var) do
            nvar[tonumber(k)] = v
        end
    end

    Inventories[type][tostring(id)] = nvar

    if Inventories[type][tostring(id)] and (type ~= 'Player' and id ~= serverID) then
        local b = {}
        for k,v in pairs(Inventories[type][tostring(id)]) do
            b[tostring(k)] = v
        end
        SendNUIMessage({
            type = 'inventoryUpdate',
            inventory = b,
            invType = 'Other',
            id = type,
            othersize = GetMaxWeight(type, id),
            name = Local(type, id),
            realname = id,
            cid = MyCharacter and MyCharacter.id or 0,
            open = false
        })
    end

    if Inventories['Player'][tostring(serverID)] == nil then
        return
    end

    if type == 'Locations' then
        if itype == 'StoreUI' and iid == id then
            RefreshInv()
        end
    end

    Inventory = Inventories['Player'][tostring(serverID)]
    if type == 'Player' and tostring(id) == tostring(serverID) then
        TriggerEvent('Inventory.Update', Inventory)
    end

    if not change then
        if ((type == itype) and (id == iid)) or ((type == 'Player') and (tostring(id) == tostring(serverID))) then
            change = true
            SetTimeout(100, function()
                RefreshInv()
                change = false
            end)
        end
    end

    local foundWep = false
    if currentWeapon.ID then
        for k,v in pairs(Inventory) do
            if v.ID == currentWeapon.ID then
                currentWeapon = v
                foundWep = true
                break
            end
        end

        if not foundWep then
            ToggleWeapon(currentWeapon)
        end
    end
end)

RegisterNetEvent('Inventory:UpdateSlot')
AddEventHandler('Inventory:UpdateSlot', function(type, id, slot, newData)
    Inventories[type][id][tonumber(slot)] = newData
    if Inventories['Player'][tostring(serverID)] == nil then
        return
    end

    Inventory = Inventories['Player'][tostring(serverID)]
    if type == 'Player' and tostring(id) == tostring(serverID) then
        TriggerEvent('Inventory.Update', Inventory)
    end

    if type == 'Locations' then
        if itype == 'StoreUI' and iid == id then
            RefreshInv()
        end
    end

    if not change then
        if ((type == itype) and (id == iid)) or ((type == 'Player') and (tostring(id) == tostring(serverID))) then
            change = true
            SetTimeout(100, function()
                RefreshInv()
                change = false
            end)
        end
    end

    local foundWep = false
    if currentWeapon.ID then
        for k,v in pairs(Inventory) do
            if v.ID == currentWeapon.ID then
                currentWeapon = v
                foundWep = true
                break
            end
        end

        if not foundWep then
            ToggleWeapon(currentWeapon)
        end
    end
end)

RegisterNetEvent('Inventory:Fail')
AddEventHandler('Inventory:Fail', function()
    RefreshInv()
end)


RegisterNetEvent('Inventory:Drops')
AddEventHandler('Inventory:Drops', function(drops)
    Drops = drops
end)

RegisterNetEvent('Inventory:Notif')
AddEventHandler('Inventory:Notif', function(key, amount)
    SendNUIMessage({
        type = 'UpdateAmount',
        Key = key,
        Amount = amount
    })
end)

AddEventHandler('Inventory:Text', function(txt)
    SendNUIMessage({
        type = 'txt',
        val = txt
    })
end)

RegisterNetEvent('Inventory:Open')
AddEventHandler('Inventory:Open', function(t,i)
    InventoryMenu(t, i)
end)

local lastPress = 0
RegisterCommand('inventory', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    if Shared.UI then return end
    if lastPress < GetGameTimer() then
        lastPress = GetGameTimer() + 1000
        InventoryMenu()
    end
end)

RegisterCommand('+inventorydisplay', function(source, args, raw)
    if controlMod and RateLimit('+inventorydisplay', 1000) then
        SendNUIMessage({
            type = 'InventoryDisplay',
            open = true
        })
    end
end)

RegisterCommand('-inventorydisplay', function(source, args, raw)
    if controlMod then
        SendNUIMessage({
            type = 'InventoryDisplay',
            open = false
        })
    end
end)

function InventoryMenu(_type, _id)
    if not CanUseInventory() then
        return
    end

    if Inventory == nil then
        TriggerServerEvent('Inventory:FetchMe')
    end

    local ped = PlayerPedId()
    local char = MyCharacter
    local veh = Shared.EntityInFront(2.0)
    local pos = GetEntityCoords(ped)
    local inventoryType
    local inventoryID
    local inVeh

    if veh == 0 then
        veh = GetVehiclePedIsIn(ped, false)
        if veh ~= 0 then
            inVeh = true
        end
    end

    if veh == 0 then
        inventoryType = 'Locations'
        for k,v in pairs(inventoryLocations) do
            if Vdist4(pos, v.Pos) <= 50.0 then
                inventoryID = k
            end
        end
    else
        local plate = (Entity(veh).state.plate) or GetVehicleNumberPlateText(veh)
        if inVeh then
            local class = GetVehicleClass(veh)
            if class == 13  or class == 8 then goto skip end

            inventoryType = 'Glovebox'
            --inventoryID = 'Glovebox-'..plate
            inventoryID = NetworkGetNetworkIdFromEntity(veh)
        else
            local class = GetVehicleClass(veh)
            if class == 13 then goto skip end

            inventoryType = 'Vehicle'
            --inventoryID = plate
            inventoryID = NetworkGetNetworkIdFromEntity(veh)
            TriggerServerEvent('Inventory.SetClass', inventoryID, GetVehicleClass(veh))
        end
    end
    if inventoryType == 'Vehicle' then
        if (not IsAccessible(veh)) and (not (veh == GetVehiclePedIsIn(ped, false))) then
            inventoryType = 'Drops'
            inventoryID = 'Drops'
        end
    end

    ::skip::

    if inventoryID == nil then
        inventoryType = 'Drops'
        inventoryID = 'Drops'
    else
        if inventoryType == 'Locations' then
            local found = false
            for k,v in pairs(inventoryLocations[inventoryID].Guilds) do
                if exports['geo-guilds']:GuildAuthority(v[1], MyCharacter.id) >= v[2] and inventoryLocations[inventoryID].dist == nil then
                    found = true
                    break
                end
            end
            if not found then
                inventoryType = 'Drops'
                inventoryID = 'Drops'
            end
        end
    end
    if veh ~= 0 then
        if inVeh then
            if GetVehiclePedIsIn(ped, false) == 0 then
                return
            end
        else
            if inventoryType == 'Vehicle' then
                if not IsAccessible(veh) or Vdist4(GetEntityCoords(ped), GetEntityCoords(veh)) >= 100.0 then
                    return
                end

                if Shared.EntityInFront(5.0) ~= veh then
                    return
                end
            end
        end
    else
        if inventoryType ~= 'Drops' then
            if Vdist4(inventoryLocations[inventoryID].Pos, GetEntityCoords(ped)) >= 50.0 then
                return
            end
        end
    end

    if MyCharacter.intinv ~= nil then
        if (MyCharacter.interior):match('Apartment') then
            if Vdist4(GetEntityCoords(ped), vector3(table.unpack(MyCharacter.intinv))) <= 2.0 then
                inventoryType = 'Apartment'
                inventoryID = mysplit(MyCharacter.interior, 'Apartment:')[1]
            end
        end
    end

    itype = inventoryType
    iid = inventoryID

    local pos = GetEntityCoords(PlayerPedId())
    if inventoryType == 'Drops' then
        for k,v in pairs(Drops) do
            if MyCharacter.interior == v[2] then
                if Vdist4(pos, v[1]) <= 5.0 then
                    inventoryID = k
                end
            end
        end
    end

    if inventoryID == 'Drops' then
        inventoryID = tostring(MyCharacter.id..tostring(uuid()))
        TriggerServerEvent('CreateDrop', inventoryID, pos)
    end

    if _type and _id then
        inventoryType = _type
        inventoryID = _id
    end
    inventoryID = tostring(inventoryID)

    itype = inventoryType
    iid = inventoryID

    if itype == 'Locations' then
        if not  _id then
            TriggerServerEvent('Inventory:Location', iid)
            return
        end
    end

    if not Promise('Inventory:CanOpen', itype, iid) then
        return
    end

    RequestAnimDict('pickup_object')
    while not HasAnimDictLoaded('pickup_object') do
        Wait(0)
    end
    TaskPlayAnim(ped, "pickup_object", "putdown_low", 1.0, 1.0, 1000, 1, 3.0, 8.0, false, false, false)
    TriggerServerEvent('Inventory:Open', itype, iid)
    FetchInventory(inventoryType, inventoryID)
    Wait(0)
    while Inventories[inventoryType][inventoryID] == nil do
        Wait(0)
    end

    RefreshInv()
    hud = true
    SendNUIMessage({
        type = 'inventoryUI',
        open = hud,
        Duty = MyCharacter.Duty,
        data = GetOtherData(),
        known = exports['geo-interface']:Known(),
        user = MyUser
    })
    UIFocus(hud, hud)

    if itype ~= 'Vehicle' then
        if not IsEntityPlayingAnim(PlayerPedId(), "random@mugging3", "handsup_standing_base", 1) then
            if not IsPedInAnyVehicle(PlayerPedId(), true) then
                --[[ RequestAnimDict('pickup_object')
                while not HasAnimDictLoaded('pickup_object') do
                    Wait(0)
                end
                TaskPlayAnim(ped, "pickup_object", "putdown_low", 1.0, 1.0, 1000, 1, 3.0, 8.0, false, false, false) ]]
            end
        end
    end

    while true do
        Wait(0)
        if veh ~= 0 then
            if inVeh then
                if GetVehiclePedIsIn(ped, false) == 0 then
                    break
                end
            else
                if inventoryType == 'Vehicle' then
                    if not IsAccessible(veh) or Vdist4(GetEntityCoords(ped), GetEntityCoords(veh)) >= 100.0 then
                        break
                    end

                    if Shared.EntityInFront(5.0) ~= veh then
                        return
                    end
                end
            end
        else
            if inventoryType == 'Locations' then
                if Vdist4(inventoryLocations[inventoryID].Pos, GetEntityCoords(ped)) >= 25.0 then
                    return
                end
            end

            if inventoryType == 'Apartment' then
                if MyCharacter.intinv ~= nil then
                    if Vdist4(GetEntityCoords(ped), vector3(table.unpack(MyCharacter.intinv))) > 2.0 then
                        break
                    end
                else
                    break
                end
            end
        end

       --[[  if Inventories[itype][tostring(iid)] == nil then
            breakOff = true
        end ]]

        if breakOff then
            breakOff = false
            break
        end
    end
    hud = false
    SendNUIMessage({
        type = 'inventoryUI',
        open = hud,
        known = exports['geo-interface']:Known(),
        user = MyUser
    })
    UIFocus(hud, hud)

    TriggerServerEvent('CloseInv', iid)
    itype = 'Drops'
    iid = 'Drops'
    if not IsEntityPlayingAnim(PlayerPedId(), "random@mugging3", "handsup_standing_base", 1) then
    end
end

function CanUseInventory()
    if MyCharacter == nil or MyCharacter.jail == true or MyCharacter.range == 1 or IsPauseMenuActive() or MyCharacter.cuff == 1 or MyCharacter.dead == 1 then
        return
    end

    return true
end

function FetchInventory(inventoryType, inventoryID)
    TriggerServerEvent('Inventory:Fetch', inventoryType, inventoryID)
end

function Local(inventoryType, inventoryID)
    if inventoryType == 'Vehicle' then
        return 'Trunk - '..inventoryID
    elseif inventoryType == 'Glovebox' then
        return inventoryID
    elseif inventoryType == 'Drops' then
        return 'Drops'
    elseif inventoryType == 'Locations' then
        return inventoryLocations[inventoryID].Name
    elseif inventoryType == 'Evidence' then
        return 'Evidence-'..inventoryID
    elseif inventoryType == 'Dumpster' then
        return 'Garbage'
    elseif inventoryType == 'Register' then
        return 'Register'
    elseif inventoryType == 'Credit' then
        return 'Credit'
    elseif inventoryType == 'EvidenceBag' then
        return 'Evidence Bag'
    elseif inventoryType == 'StoreUI' then
        local str = SplitString(inventoryID, '.')
        if OwnedStores[str[1]] then
            return OwnedStores[str[1]][tonumber(str[2])][2].name or 'Store'
        end
    end
    return inventoryID
end

function mysplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function HandleTransfer(id, to, data, from, amount)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local xyz = { x = pos.x, y = pos.y, z = pos.z - GetEntityHeightAboveGround(ped) + 0.01}
    if to == 'Other' and itype == 'Drops' then
        RequestAnimDict('pickup_object')
        while not HasAnimDictLoaded('pickup_object') do
            Wait(0)
        end
        TaskPlayAnim(ped, "pickup_object", "putdown_low", 1.0, 1.0, 1000, 1, 3.0, 8.0, false, false, false)
    end
    SetCache()
    return (itype == 'Drops' and (to ~= 'Player'))
end

function HasItem(itemID)
    for k,v in pairs(Inventory or {}) do
        if v.ID == itemID then
            return true
        end
    end
end


function HasItemKey(itemID)
    for k,v in pairs(Inventory or {}) do
        if v.Key == itemID then
            return true
        end
    end
end

function IsAccessible(veh)
    if GetVehicleDoorAngleRatio(veh, 5) > 0 then
        return true
    elseif GetVehicleDoorAngleRatio(veh, 1) > 0 then
        return true
    elseif GetVehicleDoorAngleRatio(veh, 2) > 0 then
        return true
    elseif GetVehicleDoorAngleRatio(veh, 3) > 0 then
        return true
    elseif GetVehicleDoorAngleRatio(veh, 4) > 0 then
        return true
    elseif GetVehicleClass(veh) == 8 then
        return true
    elseif GetVehicleClass(veh) == 13 then
        return true
    end
    return false
end

function InventoryAmount(itemID)
    local count = 0
    for k,v in pairs(Inventory) do
        if v.ID == itemID then
            count = count + v.Amount
        end
    end

    return count
end

function InventoryAmountKey(itemID)
    local count = 0
    for k,v in pairs(Inventory) do
        if v.Key == itemID then
            count = count + v.Amount
        end
    end

    return count
end

function GetItemName(itemID)
    if items[itemID] == nil then
        return 'NULL'
    end

    return items[itemID].Name
end

function GetItemKey(id)
    for k,v in pairs(Inventory) do
        if v.Key == id then
            return v
        end
    end
end

exports('HasItem', HasItem)
exports('Amount', InventoryAmount)
exports('GetItemName', GetItemName)
exports('GetItem', function(itemID)
    return items[itemID]
end)

RegisterCommand('use', function(source, args, raw)
    local ped = PlayerPedId()
    if not ControlModCheck(raw) then return end
    if IsPedClimbing(ped) or not CanUseInventory() then
        return
    end

    if #args > 0 then
        local index
        if tonumber(args[1]) ~= nil then
            local val = tonumber(args[1])
            for k,v in pairs(Inventory) do
                if k == val then
                    index = val
                end
            end
        else
            local str = raw:sub(5):upper()
            for k,v in pairs(Inventory) do
                if items[v.Key].Name:upper() == str then
                    index = k
                    break
                end
            end

            if not index then
                for k,v in pairs(Inventory) do
                    if items[v.Key].Name:upper():match(str) then
                        index = k
                        break
                    end
                end
            end
        end

        if index then
            if (GetDurability(Inventory[index])) <= 0 then
                TriggerEvent('Shared.Notif', 'Your '..items[Inventory[index].Key].Name..' is broken')
                return
            end

            if Inventory[index].HQ then
                TriggerEvent('Use:'..items[Inventory[index].HQ].Key, index, Inventory[index])
            else
                if items[Inventory[index].Key].Food then
                    Eat(items[Inventory[index].Key].ID, Inventory[index])
                elseif items[Inventory[index].Key].Water then
                    Drink(items[Inventory[index].Key].ID, Inventory[index])
                else
                    TriggerEvent('Use:'..items[Inventory[index].Key].Key, index, Inventory[index])
                end
            end


            if items[Inventory[index].Key].Weapon then
                if currentWeapon.ID == Inventory[index].ID then
                    TriggerEvent('Inventory:Notif', Inventory[index].Key, 'Unequipped')
                else
                    TriggerEvent('Inventory:Notif', Inventory[index].Key, 'Equipped')
                end
            else 
                TriggerEvent('Inventory:Notif', Inventory[index].Key, 'Used')
            end

            if items[Inventory[index].Key].Weapon then
                ToggleWeapon(Inventory[index])
            end
        end
    end
end)

RegisterCommand('unload', function()
    if currentWeapon.ID then
        TriggerServerEvent('Unload', currentWeapon.ID)
    end
end)

local onExit = false
local switchID = 1
function ToggleWeapon(item)
    local id = switchID + 1
    switchID = switchID + 1

    if item then
        SetPlayerWeaponDamageModifier(PlayerId(), items[item.Key].Damage or 0.5)
        SetPlayerVehicleDamageModifier(PlayerId(), items[item.Key].Damage or 0.5)
        SetPlayerMeleeWeaponDamageModifier(PlayerId(), items[item.Key].Damage or 0.5)

        if item.Data.Familiarity and item.Data.Familiarity[tostring(MyCharacter.id)] == 2500 then
            SetPlayerWeaponDamageModifier(PlayerId(), (items[item.Key].Damage or 0.5) + 0.2)
            SetPlayerVehicleDamageModifier(PlayerId(), (items[item.Key].Damage or 0.5) + 0.2)
            SetPlayerMeleeWeaponDamageModifier(PlayerId(), (items[item.Key].Damage or 0.5) + 0.2)
        end
    else
        SetPlayerWeaponDamageModifier(PlayerId(), 0.5)
        SetPlayerVehicleDamageModifier(PlayerId(), 0.5)
        SetPlayerMeleeWeaponDamageModifier(PlayerId(), 0.5)
    end

    SetWeaponsNoAutoswap(true)
    SetWeaponsNoAutoreload(true)

    if MyCharacter and MyCharacter.skills.Shooting then
        if MyCharacter.skills.Shooting >= Levels[6] then
            SetWeaponAnimationOverride(Shared.Ped, 'Default')
        else
            SetWeaponAnimationOverride(Shared.Ped, 'Gang1H')
        end
    end

    local ped = PlayerPedId()
    local current = GetSelectedPedWeapon(ped)
    local inVeh = false

    if GetVehiclePedIsIn(ped, false) ~= 0 then
        inVeh = true
    end

    if inVeh then
    end

    --[[ if currentWeapon.ID then
        if current == GetHashKey('WEAPON_UNARMED') and Shared.CurrentVehicle ~= 0 then
            RemoveWeaponFromPed(ped, GetHashKey(items[currentWeapon.Key].Weapon))
            currentWeapon = {}
            SetPedAmmo(ped, current, 0)
            GiveWeaponToPed(ped, GetHashKey('WEAPON_UNARMED'), 0, true)
            return
        end
    end ]]

    if item and currentWeapon.ID ~= item.ID then
        currentWeapon = item
        RemoveWeaponFromPed(ped, current)
        if current == GetHashKey(items[item.Key].Weapon) then
            Wait(0)
        end
        SetPedAmmo(ped, current, 0)
        GiveWeaponToPed(ped, GetHashKey(items[item.Key].Weapon), 0, true)

        TriggerEvent('WeaponSwap', GetHashKey(items[item.Key].Weapon))
        if items[item.Key].Stackable then
            SetPedAmmo(ped, GetHashKey(items[item.Key].Weapon), item.Amount)
        else
            SetPedAmmo(ped, GetHashKey(items[item.Key].Weapon), item.Data.CurrentAmmo)
        end

        if items[currentWeapon.Key].DefaultTint then
            SetPedWeaponTintIndex(Shared.Ped, GetHashKey(items[item.Key].Weapon), items[currentWeapon.Key].DefaultTint)
        end

        for k,v in pairs((currentWeapon.Data.Mods or {})) do
            if type(v) == 'string' then
                SetPedWeaponTintIndex(Shared.Ped, GetHashKey(items[item.Key].Weapon), tonumber(v))
            else
                GiveWeaponComponentToPed(Shared.Ped, GetHashKey(items[item.Key].Weapon), v)
            end
        end
        
        SetCurrentPedWeapon(ped, GetHashKey(items[item.Key].Weapon), true)
        Wait(100)
        if GetSelectedPedWeapon(ped) ~= GetHashKey(items[item.Key].Weapon) then
            onExit = true
            RemoveWeaponFromPed(ped, GetHashKey(items[currentWeapon.Key].Weapon))
            RemoveAllPedWeapons(ped, true)
            SetPedAmmo(ped, current, 1)
            GiveWeaponToPed(ped, GetHashKey('WEAPON_UNARMED'), 1, true)
            SetPedCanSwitchWeapon(ped, false)
            return
        end
        TriggerEvent('WeaponSwitch', items[item.Key].Weapon, currentWeapon)
        wepGroup = GetWeapontypeGroup(items[currentWeapon.Key].Weapon)
        damageType = GetWeaponDamageType(GetSelectedPedWeapon(Shared.Ped))
    else
        if currentWeapon.ID then
            TriggerEvent('WeaponSwap', GetHashKey('WEAPON_UNARMED'))
            Wait(MyCharacter.Duty == 'Police' and 400 or 1000)
            if switchID == id then
                RemoveWeaponFromPed(ped, GetHashKey(items[currentWeapon.Key].Weapon))
                RemoveAllPedWeapons(ped, true)
                currentWeapon = {}
                SetPedAmmo(ped, current, 1)
                GiveWeaponToPed(ped, GetHashKey('WEAPON_UNARMED'), 1, true)
                SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true)
                TriggerEvent('WeaponSwitch', 'WEAPON_UNARMED', currentWeapon)
                damageType = GetWeaponDamageType(GetSelectedPedWeapon(Shared.Ped))
                wepGroup = nil
            end
        end
    end
    onExit = false
    TriggerEvent('Inventory.Update', Inventory)
    SetPedCanSwitchWeapon(ped, false)
end

AddEventHandler('leftVehicle', function()
    if onExit and currentWeapon.ID then
        exports['geo-inventory']:Pause(1000)
        local ped = PlayerPedId()
        local current = GetSelectedPedWeapon(ped)
        RemoveWeaponFromPed(ped, current)
        SetPedAmmo(ped, current, 0)
        GiveWeaponToPed(ped, GetHashKey(items[currentWeapon.Key].Weapon), 0, false)
        SetPedAmmo(ped, GetHashKey(items[currentWeapon.Key].Weapon), currentWeapon.Data.CurrentAmmo)

        for k,v in pairs((currentWeapon.Data.Mods or {})) do
            GiveWeaponComponentToPed(Shared.Ped, GetHashKey(items[currentWeapon.Key].Weapon), v)
        end

        SetCurrentPedWeapon(ped, GetHashKey(items[currentWeapon.Key].Weapon), true)
        GiveWeaponToPed(ped, GetHashKey('WEAPON_UNARMED'), 0, true)
        TriggerEvent('WeaponSwitch', items[currentWeapon.Key].Weapon)
        onExit = false
        wepGroup = GetWeapontypeGroup(items[currentWeapon.Key].Weapon)
        damageType = GetWeaponDamageType(GetSelectedPedWeapon(Shared.Ped))
    end
end)

function InstanceItem(itemID)
    local newItem = New(items[itemID])
    local cache = {}
    cache.Key = newItem.Key
    cache.Data = newItem.Data
    if items[itemID].Stackable then
        cache.ID = newItem.ID
    else
        if items[itemID].Weapon then
            cache.Data.UniqueID = uuid()
        end
        cache.ID = itemID..'.'..uuidshort()
    end
    cache.Amount = newItem.Amount
    return cache
end

Menu.CreateMenu('Mods', 'Mods')
RegisterCommand('mods', function()
    if currentWeapon.ID and weaponMods[items[currentWeapon.Key].Weapon] then
        Menu.OpenMenu('Mods')
        while Menu.CurrentMenu == 'Mods' do
            Wait(0)

            for k,v in pairs(weaponMods[items[currentWeapon.Key].Weapon]) do
                if Menu.Button(v.Name, HasMod(v.Hash, (currentWeapon.Data.Mods or {})) and 'True' or 'False') then
                    TriggerServerEvent('WeaponMods.Toggle', currentWeapon.ID, k)
                end
            end

            Menu.Display()
        end
    end
end)

function HasMod(mod, data)
    for k,v in pairs(data) do
        if v == mod then return true end
    end
end

RegisterNetEvent('Weapon.Mod')
AddEventHandler('Weapon.Mod', function(mod, toggle)
    local weapon = GetSelectedPedWeapon(Shared.Ped)
    if toggle then
        if type(mod) == 'string' then
            SetPedWeaponTintIndex(Shared.Ped, weapon, tonumber(mod))
            return
        end
        GiveWeaponComponentToPed(Shared.Ped, weapon, mod)
    else
        if type(mod) == 'string' then
            SetPedWeaponTintIndex(Shared.Ped, weapon, 0)
            return
        end
        RemoveWeaponComponentFromPed(Shared.Ped, weapon, mod)
    end
end)

exports('GetInventory', function()
    return Inventory
end)

exports('ToggleWeapon', ToggleWeapon)
exports('HasItemKey', HasItemKey)

RegisterKeyMapping('inventory', '[Inventory] Open', 'keyboard', 'TAB')
RegisterKeyMapping('+inventorydisplay', '[Inventory] Show Hotbar ~g~ +Modifier~w~', 'keyboard', 'TAB')


---------------------------

local cWep = GetSelectedPedWeapon(ped)
local canFire = true
local timer = 0

AddEventHandler('Holster:PauseFor', function(timeout)
    timer = GetGameTimer() + timeout
end)

exports('Pause', function(time)
    timer = GetGameTimer() + time
end)

function StopFire()
    CreateThread(function()
        while not canFire do
            Wait(0)
            Shared.DisableWeapons()
        end
    end)
end

local unarmed = GetHashKey("weapon_unarmed")
local inVeh = false
local holdingWeapon = false
local meleeBlacklist = {
    [GetHashKey('WEAPON_HATCHET')] = true
}

AddEventHandler('WeaponSwap', function(wep)
    RequestAnimDict("reaction@intimidation@1h")
    RequestAnimDict('anim@mp_player_intcelebrationmale@salute')
    RequestAnimDict('rcmjosh4')
    local typePistol = 416676503
    local typeThrown = 1548507267
    local ped = Shared.Ped
    local heldWeapon = wep
    if heldWeapon ~= cWep then
        if not IsPedActiveInScenario(ped) and not IsPedUsingAnyScenario(ped) and GetGameTimer() > timer then
            if IsPedSittingInAnyVehicle(ped) or IsPedGettingIntoAVehicle(ped) then
                -- Handles weapon being changed while in the vehicle So the anim doesn't play on exit
                inVeh = true
                holdingWeapon = heldWeapon ~= unarmed
            else
                if GetPedParachuteState(ped) ~= 2 and not inVeh then
                    -- Stops from plummeting to doom when changing weapons with a parachute
                    local pos = GetEntityCoords(ped, true)
                    local rot = GetEntityHeading(ped)
                    if heldWeapon ~= unarmed and holdingWeapon == false then
                        -- Pulling Out Weapon.
                        if GetWeapontypeGroup(heldWeapon) == typePistol or GetWeapontypeGroup(heldWeapon) == typeThrown or heldWeapon == GetHashKey('WEAPON_STUNGUN') then
                            -- Small Weapons
                            canFire = false
                            StopFire()
                            if MyCharacter.Duty ~= 'Police' then
                                SetPedCurrentWeaponVisible(ped, false, false, false, false)
                                TaskPlayAnimAdvanced( ped, "reaction@intimidation@1h", "intro", pos, 0, 0, rot, 8.0, 3.0, 1100, 50, 0.325, 0, 0)
                                Wait(400)
                                SetPedCurrentWeaponVisible(ped, true, false, false, false)
                                Wait(700)
                            else
                                TaskPlayAnim(ped, "rcmjosh4", "josh_leadout_cop2", 20.0, 3.0, 600, 48, 10, 0, 0, 0)
                            end
                            holdingWeapon = true
                            canFire = true
                        elseif GetWeapontypeGroup(heldWeapon) == -728555052 and not meleeBlacklist[heldWeapon] then
                            --Melee weapons
                        else
                            -- Large Weapons (SMGs, ARs, etc.)
                            HolsterDrawLarge(ped)
                        end
                    elseif heldWeapon == unarmed and holdingWeapon == true then
                        -- Putting Away Weapon.
                        canFire = false
                        StopFire()
                        local num = 1400
                        if GetHashKey(cWep) ~= 951415626 then
                            if MyCharacter and MyCharacter.Duty == 'Police' then
                                if (GetWeapontypeGroup(cWep) == typePistol or cWep == GetHashKey('WEAPON_STUNGUN')) then
                                    num = 200
                                    TaskPlayAnim(ped, "rcmjosh4", "josh_leadout_cop2", 20.0, 3.0, 200, 48, 10, 0, 0, 0)
                                else
                                    TaskPlayAnim(ped, "anim@mp_player_intcelebrationmale@salute", "salute", 8.0, 3.0, 600, 50, 0, false, false, false)
                                    num = 600
                                end
                            else
                                TaskPlayAnimAdvanced( ped, "reaction@intimidation@1h", "outro", pos, 0, 0, rot, 8.0, 3.0, num, 50, 0.125, 0, 0)
                            end
                        end
                        Wait(num)
                        holdingWeapon = false
                        canFire = true
                    elseif holdingWeapon == true then
                        -- Holding a weapon and switching weapons.
                        HolsterDrawLarge(ped)
                    end
                end
                inVeh = false
            end
        end
        cWep = heldWeapon

        --[[  CreateThread(function()
            Wait(100)
            if currentWeapon.ID == nil then
                exports['geo-inventory']:Pause(250)
                if cWep ~= GetHashKey('WEAPON_UNARMED') then
                    SetCurrentPedWeapon(Shared.Ped, GetHashKey('WEAPON_UNARMED'), true)
                end
            end
        end) ]]
    end
    Wait(0)
end)

function HolsterDrawLarge(ped)
    canFire = false
    StopFire()
    SetPedCurrentWeaponVisible(ped, false, false, false, false)
    if MyCharacter and MyCharacter.Duty ~= 'Police' then
        TaskPlayAnim(ped, "reaction@intimidation@1h", "intro", 8.0, 3.0, 2500, 50, 0, false, false, false)
        Wait(1000)
        SetPedCurrentWeaponVisible(ped, true, false, false, false)
        Wait(1500)
    else
        TaskPlayAnim(ped, "anim@mp_player_intcelebrationmale@salute", "salute", 8.0, 3.0, 600, 50, 0, false, false, false)
        Wait(600)
        SetPedCurrentWeaponVisible(ped, true, false, false, false)
    end
    holdingWeapon = true
    canFire = true
end

AddEventHandler('enteredVehicle', function(veh)
    if GetEntityModel(veh) == `FIRETRUK` then
        ToggleWeapon()
        RemoveAllPedWeapons(Shared.Ped)
    end
end)

RegisterNetEvent('Inventory.Credit', function()
    if exports['geo-shared']:Confirmation("You have unclaimed rewards, would you like to claim them?") then
        Task.Run('Inventory.Credit')
    end
end)

RegisterNetEvent('Inventory.Login', function()
    Wait(500)
    for k,v in pairs(Inventory) do
        if v.Data.Equipped then
            ExecuteCommand('use '..k)
        end
    end
end)

exports('InventoryMenu', InventoryMenu)

local waiting = {}
function GetDurability(item)
    local id = #waiting + 1
    waiting[id] = promise:new()

    SendNUIMessage({
        type = 'GetDurability',
        item = item,
        id = id
    })

    local val = Citizen.Await(waiting[id])
    waiting[id] = nil
    return val
end

RegisterNUICallback('GetDurability', function(data, cb)
    waiting[data.id]:resolve(data.val)
    cb(true)
end)

RegisterNUICallback('Repair', function(data, cb)
    Wait(500)
    TriggerEvent('Repair', data.key, data.id, items[data.key].Repair)
end)

RegisterNUICallback('RunSerial', function(data, cb)
    TriggerServerEvent('RunSerial', data.serial)
end)

RegisterNUICallback('NameBag', function(data, cb)
    local val = exports['geo-shared']:Dialogue({
        {
            placeholder = 'Name',
            title = 'Set Evidence Bag Name',
            image = 'person'
        },
    })[1]
    cb(true)

    if val then
        TriggerServerEvent('EvidenceBag.Name', data.id, val)
    end
end)

function GetMaxWeight(itype, iid)
    local max = Sizes[itype]

    if itype == 'Vehicle' then
        local class = GetVehicleClass(NetworkGetEntityFromNetworkId(tonumber(iid)))
        if Sizes[class] ~= nil then max = Sizes[class] end
    end

    return max
end

function GetOtherData()
    local data = {}
    local zone = StoreZone()
    if zone and OwnedStores[zone.entry] and OwnedStores[zone.entry][zone.storeID] then
        local val = exports['geo-instance']:GetProperty(OwnedStores[zone.entry][zone.storeID][1])
        if val and val.owner == MyCharacter.id then
            data.owner = true
        end
    end

    return data
end

if GetConvar('sv_dev', 'false') == 'true' then
    RegisterCommand('tint', function(source, args)
        SetPedWeaponTintIndex(Shared.Ped, GetSelectedPedWeapon(Shared.Ped), tonumber(args[1]))
    end)
end

local hashes = {
    [GetHashKey('a_c_deer')] = {item = 'meat_deer', amount = 6, name = 'Deer Meat'},
    [GetHashKey('a_c_coyote')] = {item = 'meat_coyote', amount = 2, name = 'Coyote Meat'},
    [GetHashKey('a_c_pig')] = {item = 'meat_pig', amount = 4, name = 'Pig Meat'},
    [GetHashKey('a_c_mtlion')] = {item = 'meat_mtlion', amount = 3, name = 'Mountain Lion Meat'},
    [GetHashKey('a_c_cow')] = {item = 'meat_cow', amount = 6, name = 'Cow Meat'},
    [GetHashKey('a_c_boar')] = {item = 'meat_pig', amount = 6, name = 'Pig Meat'},
}

local damageCounts =  {}
local inCountThread
AddEventHandler('gameEventTriggered', function(event, b)
    if event == 'CEventNetworkEntityDamage' then
        local targetPed, originPed, _, _, _, _, weaponHash, _, _, _, _, _, _ = table.unpack(b)
        if originPed == Shared.Ped and IsEntityAPed(targetPed) then
            if currentWeapon and not IsEntityDead(targetPed) then
                damageCounts[currentWeapon.ID] = (damageCounts[currentWeapon.ID] or 0) + 1

                if not inCountThread then
                    inCountThread = true
                    SetTimeout(30000, function()
                        Task.Run('Inventory.Familiarity', damageCounts)
                        damageCounts = {}
                        inCountThread = false
                    end)
                end
            else
                if currentWeapon and IsEntityDead(targetPed) and hashes[GetEntityModel(targetPed)] then
                    TriggerEvent('Help', 9)
                end
            end
        end
    end
end)

AddEventHandler('Inventory.Update', function()
    for k,v in pairs(Inventory) do
        if v.Data.Gathering then
            TriggerEvent('Help', 3)
            break
        end
    end
end)

AddEventHandler('WeaponSwitch', function(id, wep)
    if wep.Key and items[wep.Key].Hunting then
        while currentWeapon and items[currentWeapon.Key].Hunting do
            Wait(0)
            local found, ent = GetEntityPlayerIsFreeAimingAt(PlayerId())
            if ent ~= 0 and IsPedHuman(ent) then
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 257, true)
            end
        end
    end
end)