AddEventHandler('Use:ammo_556', function(key, val)
    Reload(key, val)
end)

AddEventHandler('Use:ammo_9mm', function(key, val)
    Reload(key, val)
end)

AddEventHandler('Use:ammo_12g', function(key, val)
    Reload(key, val)
end)

AddEventHandler('Use:ammo_flare', function(key, val)
    Reload(key, val)
end)

AddEventHandler('Use:ammo_taser', function(key, val)
    Reload(key, val)
end)

AddEventHandler('Use:cone', function(key, val)
    PlaceObject(key, val)
end)

AddEventHandler('Use:barrier', function(key, val)
    PlaceObject(key, val)
end)

AddEventHandler('Use:medbag', function(key, val)
    PlaceObject(key, val)
end)

AddEventHandler('Use:work_light', function(key, val)
    PlaceObject(key, val)
end)

AddEventHandler('Use:donut', function(key, val)
    Eat(val.ID, val)
end)

AddEventHandler('Use:sandwich', function(key, val)
    Eat(val.ID, val)
end)

AddEventHandler('Use:water', function(key, val)
    Drink(val.ID, val)
end)

AddEventHandler('Use:horn_christmas', function()
    if Shared.CurrentVehicle ~= 0 then
        SetVehicleModKit(GetVehiclePedIsIn(Shared.Ped, false), 1)
        SetVehicleMod(GetVehiclePedIsIn(Shared.Ped, false), 14, 48)
        TriggerServerEvent('Use:horn_christmas')
    end
end)

AddEventHandler('Use:horn_halloween', function()
    if Shared.CurrentVehicle ~= 0 then
        SetVehicleModKit(GetVehiclePedIsIn(Shared.Ped, false), 1)
        SetVehicleMod(GetVehiclePedIsIn(Shared.Ped, false), 14, 38)
        TriggerServerEvent('Use:horn_halloween')
    end
end)

AddEventHandler('Use:evidencebag', function(key, val)
    TriggerServerEvent('Use:evidencebag', val.ID)
end)

AddEventHandler('Use:cigar', function()
    ExecuteCommand('e cigar')
    TriggerServerEvent('RemoveItem', 'cigar', 1)
end)

AddEventHandler('Use:redwood', function()
    ExecuteCommand('e smoke')
    TriggerServerEvent('RemoveItem', 'redwood', 1)
end)

AddEventHandler('Use:egochaser', function()
    ExecuteCommand('e eat')
    TriggerServerEvent('RemoveItem', 'egochaser', 1)
end)

AddEventHandler('Use:meteorite', function()
    ExecuteCommand('e eat')
    TriggerServerEvent('RemoveItem', 'meteorite', 1)
end)

AddEventHandler('Use:pisswasser', function()
    ExecuteCommand('e beer')
    AddBAC(items['wine'].BAC)
    TriggerServerEvent('RemoveItem', 'pisswasser', 1)
end)

AddEventHandler('Use:wine', function()
    ExecuteCommand('e wine')
    AddBAC(items['wine'].BAC)
    TriggerServerEvent('RemoveItem', 'wine', 1)
end)

AddEventHandler('Use:mask', function(key, val)
   --[[  LoadAnim("mp_masks@standard_car@ds@")
    TaskPlayAnim(Shared.Ped, "mp_masks@standard_car@ds@", "put_on_mask", 8.0, 8.0, math.floor(GetAnimDuration("mp_masks@standard_car@ds@", "put_on_mask") * 1000) - 600, 51, 0, 0, 0, 0)
    Wait(math.floor(GetAnimDuration("mp_masks@standard_car@ds@", "put_on_mask") * 1000) - 1000)
    SetPedComponentVariation(Shared.Ped, 1, val.Data.Drawable, val.Data.Texture, 0) ]]
    ExecuteCommand('mask '..val.ID)
end)

AddEventHandler('Use:pain_killer', function()
    AddBAC(0.08)
    TriggerServerEvent('RemoveItem', 'pain_killer', 1)
end)

AddEventHandler('Use:phone', function()
    Wait(500)
    if hud then
        breakOff = true
        Wait(250)
    end
    ExecuteCommand('openphone')
end)

AddEventHandler('Use:burner_phone', function()
    if RateLimit('burner_phone', 5000) then
        ExecuteCommand('e phonecall')
        local id = Shared.Interact('You made a call, but no one answered.....')
        Wait(2500)
        ExecuteCommand('ec phonecall')
        id.stop()
    end
end)

local bandaging = false
AddEventHandler('Use:bandage', function(key, val)
    if bandaging then
        return
    end

    local obj = Shared.SpawnObject('prop_ld_health_pack')
    LoadAnim('missheistdockssetup1clipboard@idle_a')
    AttachEntityToEntity(obj, Shared.Ped, GetPedBoneIndex(Shared.Ped, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 1, 1 ,1)
    TaskPlayAnim(Shared.Ped, "missheistdockssetup1clipboard@idle_a", 'idle_a', 1.0, 1.0, 7500, 49, 1.0, 0, 0, 0)
    bandaging = true
    if exports['geo-shared']:ProgressSync('Healing', 7500) then
        TriggerServerEvent('Status.Bleeding.Bandage')
    end
    bandaging = false
    StopAnimTask(Shared.Ped, "missheistdockssetup1clipboard@idle_a", 'idle_a', 1.0)
    TriggerServerEvent('DeleteEntity', ObjToNet(obj))
end)

local bandaging = false
AddEventHandler('Use:ifak', function(key, val)
    if bandaging then
        return
    end

    local obj = Shared.SpawnObject('prop_ld_health_pack')
    LoadAnim('missheistdockssetup1clipboard@idle_a')
    AttachEntityToEntity(obj, Shared.Ped, GetPedBoneIndex(Shared.Ped, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 1, 1 ,1)
    TaskPlayAnim(Shared.Ped, "missheistdockssetup1clipboard@idle_a", 'idle_a', 1.0, 1.0, 7500, 49, 1.0, 0, 0, 0)
    bandaging = true
    if exports['geo-shared']:ProgressSync('Healing', 7500) then
        TriggerServerEvent('Status.Bleeding.ifak')
    end
    bandaging = false
    StopAnimTask(Shared.Ped, "missheistdockssetup1clipboard@idle_a", 'idle_a', 1.0)
    TriggerServerEvent('DeleteEntity', ObjToNet(obj))
end)

local oxying = false
AddEventHandler('Use:oxy', function(key, val)
    if oxying then
        return
    end

    local obj = Shared.SpawnObject('prop_ld_health_pack')
    oxying = true
    ExecuteCommand('e drug')
    if exports['geo-shared']:ProgressSync('Pill Junky', 2800) then
        TriggerServerEvent('Status.Oxy')
    end
    ExecuteCommand('ec drug')
    oxying = false
end)

local wire = false
AddEventHandler('Use:wire_copper', function(key, val)
    if wire then return end
    if Shared.CurrentVehicle ~= 0 then return end
    local ped = Shared.Ped

    local veh = Shared.EntityInFront(5.0)
    if veh == 0 then
        return
    end

    if (GetVehicleDoorLockStatus(veh) ~= 2 and GetVehicleDoorLockStatus(veh) ~= 7) or GetPedInVehicleSeat(veh, -1) ~= 0 then
        TriggerEvent('Shared.Notif', 'Vehicle is already unlocked')
        return
    end

    local terminate = false
    local finish = nil
    wire = true
    LoadAnim('mini@repair')
    TaskPlayAnim(Shared.Ped, 'mini@repair', 'fixing_a_ped', 1.0, 1.0, 60000, 1, 1.0, 0, 0, 0)
    exports['geo-shared']:Progress('Attempting to Unlock', 15000, function(res, term)
        terminate = term
        if res then
            finish = true
        end
    end)

    Wait(100)
    while finish == nil do
        Wait(0)

        if IsControlJustPressed(0, 47) then
            StopAnimTask(ped, 'mini@repair', 'fixing_a_ped', 1.0)
        end

        if Shared.EntityInFront(5.0) ~= veh then
            terminate()
            break
        end

        if not IsEntityPlayingAnim(ped, 'mini@repair', 'fixing_a_ped', 1) then
            terminate()
            break
        end
    end

    StopAnimTask(ped, 'mini@repair', 'fixing_a_ped', 1.0)
    if finish then
        TriggerServerEvent('SetVehicleLock', VehToNet(veh), false)
        TriggerServerEvent('RemoveItem', val.ID, 1)
    end

    wire = false
end)

local applyingArmor = false
local armor = false
AddEventHandler('Use:armor', function(key, val)
    Armor(key, val)
end)

AddEventHandler('Use:lightarmor', function(key, val)
    Armor(key, val)
end)


local nos = false
AddEventHandler('Use:nos', function(key, val)
    if nos then return end
    local veh = Shared.CurrentVehicle
    if veh ~= 0 and Entity(veh).state.vin == nil then
        if Entity(veh).state.nos == nil then
            if not exports['geo-shared']:Confirmation('Are you sure you want to install NOS in this vehicle?') then return end
        end
    end

    if Entity(veh).state.nos ~= nil then
        nos = true
        if exports['geo-shared']:ProgressSync('Refilling Bottle', 5000) then
            Task.Run('NOS.Consume', NetworkGetNetworkIdFromEntity(veh), val.ID)
        end
        nos = false
        return
    end

    nos = true
    if exports['geo-shared']:ProgressSync('Installing NOS', 30000) then
        TriggerServerEvent('InstallNOS', NetworkGetNetworkIdFromEntity(veh))
    end
    nos = false
end)

function Armor(key, val)
    if armor then
        if exports['geo-shared']:ProgressSync('Removing Armor', 2000) then
            armor = false
        end
        return
    else
        if val.Data.Equipped == nil then
            TriggerEvent('Shared.Notif', 'You must equip this first')
            return
        end
    end

    if applyingArmor then
        return
    end

    applyingArmor = true
    if exports['geo-shared']:ProgressSync('Applying Armor', 5000) then
        armor = true
        SetPedArmour(Shared.Ped, val.Data.Armor)
        applyingArmor = false
        local currArmor = GetPedArmour(Shared.Ped)
        while armor do
            if not HasItem(val.ID) or MyCharacter.dead == 1 then
                armor = false
                break
            end

            for k,v in pairs(Inventory) do
                if v.ID == val.ID then
                    if not v.Data.Equipped then
                        armor = false
                        break
                    end
                end
            end

            local arm = GetPedArmour(Shared.Ped)
            if arm ~= currArmor then
                currArmor = arm
                TriggerServerEvent('Armor.Set', arm, val.ID)
            end

            Wait(500)
        end

        SetPedArmour(Shared.Ped, 0)
    else
        applyingArmor = false
    end
end

function Reload(key, val)
    if currentWeapon.ID then
        if val.Key == currentWeapon.Data.Ammo then
            local ped = Shared.Ped
            local wep = GetSelectedPedWeapon(ped)
            local ammo = GetAmmoInPedWeapon(ped, wep)

            local max = GetMaxAmmoInClip(ped, wep, 1)

            if ammo < max * 3 then
                local needed = (max * 3) - ammo

                toRemove = 0
                if InventoryAmount(val.ID) >= needed then
                    toRemove = needed
                else
                    toRemove = InventoryAmount(val.ID)
                end

                if toRemove > 0 then
                    TriggerServerEvent('LoadAmmo', val.ID, ammo, max, toRemove, currentWeapon.ID)
                end
            end
        end
    end
end

local lockpick = false
local difficulty = {
    [VehicleClass.Emergency] = 2,
    [VehicleClass.Super] = 2,
    [VehicleClass.Sports] = 1.5
}

AddEventHandler('Use:lockpick', function(key, val)
    Lockpick(key ,val)
end)

AddEventHandler('Use:lockpick_flimsy', function(key, val)
    Lockpick(key ,val)
end)

AddEventHandler('Use:lockpick_adv', function(key, val)
    Lockpick(key ,val)
end)

local fixing = false
AddEventHandler('Use:repair_kit', function(key, val)
    if fixing then
        return
    end

    if HasItem('repair_kit') then
        local veh = Shared.EntityInFront(5.0)
        if veh == 0 then
            return
        end

        local min, max = GetModelDimensions(GetEntityModel(veh))
        local ped = Shared.Ped
        local pos = GetEntityCoords(ped)

        if Vdist4(pos, GetOffsetFromEntityInWorldCoords(veh, 0.0, max.y, 0.0)) <= 5.0 then

            if DoesVehicleHaveDoor(veh, 4) then
                if GetVehicleDoorAngleRatio(veh, 4) <= 0.0 then
                    ExecuteCommand('hood')
                end
            end

            RequestAnimDict('mini@repair')
            while not HasAnimDictLoaded('mini@repair') do
                Wait(0)
            end
            TaskPlayAnim(Shared.Ped, 'mini@repair', 'fixing_a_ped', 1.0, 1.0, 60000, 1, 1.0, 0, 0, 0)
            Wait(100)
            local terminate = false
            local finish = nil
            fixing = true
            exports['geo-shared']:Progress('Repairing', 15000, function(res, term)
                terminate = term
                if res then
                    finish = true
                end
            end)

            while finish == nil do
                Wait(0)

                if IsControlJustPressed(0, 47) then
                    StopAnimTask(ped, 'mini@repair', 'fixing_a_ped', 1.0)
                end

                if not IsEntityPlayingAnim(ped, 'mini@repair', 'fixing_a_ped', 1) then
                    terminate()
                    fixing = false
                    return
                end
            end

            if finish then
                StopAnimTask(ped, 'mini@repair', 'fixing_a_ped', 1.0)
                TriggerServerEvent('ES:Fix', VehToNet(veh))
                TriggerServerEvent('RemoveItem', val.ID, 1)
                fixing = false
            end

            fixing = false
            Wait(750)
            ExecuteCommand('hood')
        end
    end
end)

AddEventHandler('Use:repair_kit_adv', function(key, val)
    if fixing then
        return
    end

    if HasItem('repair_kit_adv') then
        local veh = Shared.EntityInFront(5.0)
        if veh == 0 then
            return
        end

        local min, max = GetModelDimensions(GetEntityModel(veh))
        local ped = Shared.Ped
        local pos = GetEntityCoords(ped)

        if Vdist4(pos, GetOffsetFromEntityInWorldCoords(veh, 0.0, max.y, 0.0)) <= 5.0 then

            if DoesVehicleHaveDoor(veh, 4) then
                if GetVehicleDoorAngleRatio(veh, 4) <= 0.0 then
                    ExecuteCommand('hood')
                end
            end

            RequestAnimDict('mini@repair')
            while not HasAnimDictLoaded('mini@repair') do
                Wait(0)
            end
            TaskPlayAnim(Shared.Ped, 'mini@repair', 'fixing_a_ped', 1.0, 1.0, 60000, 1, 1.0, 0, 0, 0)
            Wait(100)
            local terminate = false
            local finish = nil
            fixing = true
            exports['geo-shared']:Progress('Repairing', 15000, function(res, term)
                terminate = term
                if res then
                    finish = true
                end
            end)

            while finish == nil do
                Wait(0)

                if IsControlJustPressed(0, 47) then
                    StopAnimTask(ped, 'mini@repair', 'fixing_a_ped', 1.0)
                end

                if not IsEntityPlayingAnim(ped, 'mini@repair', 'fixing_a_ped', 1) then
                    terminate()
                    fixing = false
                    return
                end
            end

            if finish then
                StopAnimTask(ped, 'mini@repair', 'fixing_a_ped', 1.0)
                TriggerServerEvent('ES:Fix', VehToNet(veh), true)
                TriggerServerEvent('RemoveItem', val.ID, 1)
                fixing = false
            end

            fixing = false
            Wait(750)
            ExecuteCommand('hood')
        end
    end
end)

local cutting = false
AddEventHandler('Use:plasma_cutter', function(key, val)
    if (val.Data.Durability or 100) <= 0 then
        return
    end

    cutting = not cutting
    local doorList = {
        [0] = 'Front Left Door',
        [1] = 'Front Right Door',
        [2] = 'Back Left Door',
        [3] = 'Back Right Door',
        [4] = 'Hood',
        [5] = 'Trunk'
    }

    local veh = 0
    local vehBack, vehFront = nil, nil
    Citizen.CreateThread(function()
        while cutting do
            Wait(0)
            if DoesEntityExist(veh) and vehFront then
                local doors = {}
                for i=0,5 do
                    if DoesVehicleHaveDoor(veh, i) then
                        if i == 4 then
                            doors[i] = GetOffsetFromEntityInWorldCoords(veh, 0.0, vehFront.y, 0.0)
                        elseif i == 5 then
                            doors[i] = GetOffsetFromEntityInWorldCoords(veh, 0.0, vehBack.y, 0.0)
                        else
                            doors[i] = GetEntryPositionOfDoor(veh, i)
                        end
                    end
                end
                local closestDoor = {dist = 99, id = 99}
                local pos = GetEntityCoords(Shared.Ped)
                for k,v in pairs(doors) do
                    if Vdist4(pos, v) <= closestDoor.dist and not IsVehicleDoorDamaged(veh, k) then
                        closestDoor = {dist = Vdist4(pos, v), id = k, loc = v}
                    end
                end
                if Vdist4(pos, closestDoor.loc) <= 3.0 then
                    if not IsPedSittingInAnyVehicle(Shared.Ped) then
                        SetTextComponentFormat("STRING")
                        AddTextComponentString("Press ~INPUT_CONTEXT~ to remove the "..doorList[closestDoor.id])
                        DisplayHelpTextFromStringLabel(0, 0, 1, -1)
                        if IsControlJustPressed(0, 38) then
                            ClearPedTasks(Shared.Ped)
                            TaskTurnPedToFaceEntity(Shared.Ped, veh, -1)
                            Wait(2000)
                            TaskStartScenarioInPlace(Shared.Ped, 'WORLD_HUMAN_WELDING', 1, 1)
                            Wait(1000)
                            ClearPedTasks(Shared.Ped)
                            closestDoor.broken = true
                            TriggerServerEvent('Vehicle.BreakDoor', VehToNet(veh), closestDoor.id)
                            TriggerServerEvent('Use:plasma_cutter', val.ID)
                        end
                    end
                end
            else
                Wait(500)
            end
        end
    end)

    while cutting do
        Wait(500)
        veh = Shared.EntityInFront(5.0)
        vehBack, vehFront = GetModelDimensions(GetEntityModel(veh))

        if Inventory[key].ID ~= val.ID or Inventory[key].Data.Durability == 0 then
            cutting = false
            break
        end
    end
end)

AddEventHandler('Use:weed_1g', function()
    if RateLimit('SmokeWeed', 10000) then
        ExecuteCommand('e smokeweed')
        if not exports['geo-shared']:ProgressSync('Smoking', 10000) then
            ExecuteCommand('ec smokeweed')
            return
        end
        ExecuteCommand('ec smokeweed')
        TriggerServerEvent('SmokeWeed')
        for i=1,20 do
            Wait(1000)
            SetPedArmour(Shared.Ped, GetPedArmour(Shared.Ped) + 1)
        end
    end
end)

AddEventHandler('Use:weed_seed', function()
    if RateLimit('weed_seed', 5000) then
        TriggerEvent('Shared.Notif', "You're not sure what to do with this, but you have hope", 5000)
    end
end)

AddEventHandler('Use:outfit', function(key, data)

    if data.Data.Model ~= GetEntityModel(Shared.Ped) then
        TriggerEvent('Shared.Notif', 'These clothes do not fit you')
        return
    end

    if RateLimit('outfitswap', 15000) then
        LoadAnim('clothingtie')
        TaskPlayAnim(Shared.Ped, "clothingtie", "try_tie_negative_a", 8.0, 8.0, 15000, 51, 0, 0, 0, 0)
        isChanging = true

        CreateThread(function()
            while isChanging do
                DisableControlAction(0, 21, true)
                if not IsEntityPlayingAnim(Shared.Ped, "clothingtie", "try_tie_negative_a", 1) then
                    TaskPlayAnim(Shared.Ped, "clothingtie", "try_tie_negative_a", 8.0, 8.0, 15000, 51, 0, 0, 0, 0)
                end
                Wait(0)
            end
        end)

        if exports['geo-shared']:ProgressSync('Changing Clothes', 15000) then
            local newClothes = {}
            for i=1,11 do
                if i ~= 2 then
                    newClothes[i] = {Drawable = GetPedDrawableVariation(Shared.Ped, i), Texture = GetPedTextureVariation(Shared.Ped, i)}
                end
            end
            
            for k,v in pairs(data.Data) do
                if tonumber(k) then
                    SetPedComponentVariation(Shared.Ped, tonumber(k), v.Drawable, v.Texture, 0)
                end
            end

            local cl = json.decode(MyCharacter.clothing)
            if cl.Name == 'Unset' then
                local val = exports['geo-shared']:Dialogue({
                    {
                        placeholder = 'Name',
                        title = 'Give your old clothes a name',
                        image = 'person'
                    },
                })
                newClothes.Name = val[1]
            else
                newClothes.Name = cl.Name
            end
            TriggerServerEvent('RemoveItem', data.ID, 1)
            Wait(500)
            newClothes.Model = GetEntityModel(Shared.Ped)
            Task.Run('NewOutfit', newClothes)
            cl.Name = data.Data.Name
            TriggerServerEvent('Clothing:SaveData', json.encode(GetClothing(cl.Name, oID)))
        end
        isChanging = false
        StopAnimTask(Shared.Ped, "clothingtie", "try_tie_negative_a", 1.0)
    end
end)

AddEventHandler('Use:id', function(key, val)
    TriggerServerEvent('Chat.LocalMessage', '[ID]', {val.Data.first, val.Data.last, val.Data.dob, val.Data.cid, val.Data.sex}, 'id', GetEntityCoords(PlayerPedId()), 150.0, false)
end)

function Eat(id, data)
    ExecuteCommand('e donut')

    if items[data.Key].Food then
        if exports['geo-shared']:ProgressSync('Eating', 5000) then
            TriggerEvent('Eat', items[data.Key].Food)
        else
            return
        end
    else
        Wait(1000)
    end

    ExecuteCommand('ec donut')
    TriggerServerEvent('RemoveItem', id, 1)
end

function Drink(id, data)
    ExecuteCommand('e soda')

    if items[data.Key].Water then
        if exports['geo-shared']:ProgressSync('Drinking', 5000) then
            TriggerEvent('Drink', items[data.Key].Water)
        else
            return
        end
    else
        Wait(1000)
    end

    ExecuteCommand('ec soda')
    TriggerServerEvent('RemoveItem', id, 1)
end

RegisterNetEvent('Reload')
AddEventHandler('Reload', function(ammo)
    local ped = Shared.Ped
    local wep = GetSelectedPedWeapon(ped)
    SetPedAmmo(ped, wep, ammo)
    TaskReloadWeapon(ped, 1)
end)

local drunk = false
function AddBAC(amount)
    Update('BAC', ((MyCharacter.BAC or 0) + amount))
    Wait(500)
    Citizen.SetTimeout(900000, function()
        Update('BAC', ((MyCharacter.BAC or 0) - amount))
    end)

    if MyCharacter.BAC >= 0.08 and not drunk then
        drunk = true
        CreateThread(function()
            RequestAnimSet("move_m@drunk@verydrunk")
            while not HasAnimSetLoaded("move_m@drunk@verydrunk") do
                Wait(0)
            end 
    
            ShakeGameplayCam('DRUNK_SHAKE', 1.0)
            while MyCharacter and MyCharacter.BAC >= 0.08 do
                Wait(250)
                SetPedIsDrunk(Shared.Ped, true)
                SetPedMovementClipset(Shared.Ped, "move_m@drunk@verydrunk", 0.2)
    
                if Shared.CurrentVehicle ~= 0 and GetEntitySpeed(Shared.CurrentVehicle) > 0 then
                    local val = (Random(-100, 100) / 100) + 0.0
                    SetVehicleSteerBias(Shared.CurrentVehicle, (Random(-100, 100) / 100) + 0.0)
                end
    
            end

            drunk = false
            RemoveAnimSet("move_m@drunk@verydrunk")
            ShakeGameplayCam('DRUNK_SHAKE', 0.0)
            exports['geo-menu']:ResetWalk()
    
            if Shared.CurrentVehicle ~= 0 then
                SetVehicleSteerBias(Shared.CurrentVehicle, 0.0)
            end
        end)
    end
end

local fov_max = 70.0
local fov_min = 5.0
local zoomspeed = 10.0
local speed_lr = 8.0
local speed_ud = 8.0

local camera = false
local fov = (fov_max+fov_min)*0.5

local camera = false
AddEventHandler('Use:camera', function()
    camera = not camera

    if camera then
        ExecuteCommand('e film')
        Wait(1000)
        local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
        SetCamCoord(cam, GetOffsetFromEntityInWorldCoords(Shared.Ped, 0.0, 0.7, 0.4))

        SetGameplayCamRelativeHeading(0.0)
        Wait(0)
        SetCamRot(cam, GetGameplayCamRot())
        RenderScriptCams(1, 0, 0, 1, 1)
        exports['geo-hud']:Render(false)
        exports['geo-es']:ShowEvidence(true)
        while camera do
            Wait(0)
            HandleZoom(cam)
            DisableControlAction(0, 220, true)
            DisableControlAction(0, 221, true)

            CheckInputRotation(cam, 1.0)

            local loc = Shared.GetLocation()
            local str = loc.street..' / '..(loc.cross == '' and '' or loc.cross..' / ')..loc.zone
            DrawRect(0.5, 0.95, str:len() / 110, 0.05, 0, 0, 0, 255)
            Shared.DrawText(str, 0.5, 0.93, 0, {255, 255, 255, 255}, 0.55, true, true, false)
            
            local hour = GetClockHours()
            local min = GetClockMinutes()
    
            if tostring(min):len() == 1 then
                min = '0'..min
            end

            DrawRect(0.9, 0.95, 0.08, 0.05, 0, 0, 0, 255)
			Shared.DrawText(hour..':'..min, 0.9, 0.93, 0, {255, 255, 255, 255}, 0.55, true, true, false)
        end
        exports['geo-hud']:Render(true)
        exports['geo-es']:ShowEvidence(false)
        ExecuteCommand('ec film')
        DestroyCam(cam)
        RenderScriptCams(0, 0, 0, 1, 1)
    end
end)

function HandleZoom(cam)
	local lPed = Shared.Ped
	if not ( IsPedSittingInAnyVehicle( lPed ) ) then

		if IsControlJustPressed(0,241) then
			fov = math.max(fov - zoomspeed, fov_min)
		end
		if IsControlJustPressed(0,242) then
			fov = math.min(fov + zoomspeed, fov_max)
		end
		local current_fov = GetCamFov(cam)
		if math.abs(fov-current_fov) < 0.1 then
			fov = current_fov
		end
		SetCamFov(cam, current_fov + (fov - current_fov)*0.05)
	else
		if IsControlJustPressed(0,17) then
			fov = math.max(fov - zoomspeed, fov_min)
		end
		if IsControlJustPressed(0,16) then
			fov = math.min(fov + zoomspeed, fov_max)
		end
		local current_fov = GetCamFov(cam)
		if math.abs(fov-current_fov) < 0.1 then
			fov = current_fov
		end
		SetCamFov(cam, current_fov + (fov - current_fov)*0.05)
	end
end

exports('AddBAC', AddBAC)

RegisterCommand('outfit', function()
    local newClothes = {}
    for i=1,11 do
        if i ~= 2 then
            newClothes[i] = {Drawable = GetPedDrawableVariation(Shared.Ped, i), Texture = GetPedTextureVariation(Shared.Ped, i)}
        end
    end
    
    local val = exports['geo-shared']:Dialogue({
        {
            placeholder = 'Name',
            title = 'Give your old clothes a name',
            image = 'person'
        },
    })
    newClothes.Name = val[1]
    Task.Run('NewOutfit', newClothes)
end)

function Lockpick(key, val)

    if GetClosestPlayer(3.0) then
        local player = GetClosestPlayer(3.0)
        local cuffed = Task.Run('IsCuffed', GetPlayerServerId(player))
        if cuffed == 1 and GetVehiclePedIsIn(GetPlayerPed(player)) == 0 then
            RequestAnimDict('anim@gangops@facility@servers@')
            while not HasAnimDictLoaded('anim@gangops@facility@servers@') do
                Wait(0)
            end
            TaskPlayAnim(Shared.Ped, 'anim@gangops@facility@servers@', 'hotwire', 1.0, 1.0, -1, 63, 1.0, 0, 0, 0)

            for i=1,3 do
                if not Minigame(15, 10000) then
                    StopAnimTask(Shared.Ped, 'anim@gangops@facility@servers@', 'hotwire', 1.0)
                    lockpick = false

                    if Random(100) >= (items[val.Key].BreakChance or 90) then
                        TriggerServerEvent('RemoveItem', val.ID, 1)
                    end
                    return
                end
            end

            StopAnimTask(Shared.Ped, 'anim@gangops@facility@servers@', 'hotwire', 1.0)
            Task.Run('RemoveCuff', GetPlayerServerId(player))
            return
        end
    end

    if Shared.CurrentVehicle == 0 then
        local veh = Shared.EntityInFront(5.0)
        if veh ~= 0 then

            if lockpick then
                return
            end

            if Entity(veh).state.fake then
                TriggerEvent('Shared.Notif', 'This vehicle is locked tight')
                return
            end

            if not DecorExistOn(veh, 'Locks') then
                local num = Random(100)
                if num <= 10 then
                    TriggerServerEvent('SetVehicleLock', VehToNet(veh), true)
                end
        
                DecorSetBool(veh, 'Locks', true)
                Wait(100)
            end
            
            if (GetVehicleDoorLockStatus(veh) ~= 2 and GetVehicleDoorLockStatus(veh) ~= 7) or GetPedInVehicleSeat(veh, -1) ~= 0 then
                TriggerEvent('Shared.Notif', 'Vehicle is already unlocked')
                return
            end

            if not DecorGetBool(veh, 'Locks') then
                DecorSetBool(veh, 'Locks', true)
            end

            RequestAnimDict('anim@gangops@facility@servers@')
            while not HasAnimDictLoaded('anim@gangops@facility@servers@') do
                Wait(0)
            end
            TaskPlayAnim(Shared.Ped, 'anim@gangops@facility@servers@', 'hotwire', 1.0, 1.0, -1, 63, 1.0, 0, 0, 0)
            if hud then
                breakOff = true
                Wait(250)
            end
            
            for i=1,3 do
                if not Minigame(15, 10000) then
                    StopAnimTask(Shared.Ped, 'anim@gangops@facility@servers@', 'hotwire', 1.0)
                    lockpick = false

                    if Random(100) >= (items[val.Key].BreakChance or 90) then
                        TriggerServerEvent('RemoveItem', val.ID, 1)
                    end
                    return
                end
            end

            StopAnimTask(Shared.Ped, 'anim@gangops@facility@servers@', 'hotwire', 1.0)
            lockpick = false
            TriggerServerEvent('SetVehicleLock', VehToNet(veh), false)
            TriggerServerEvent('Lockpick', VehToNet(veh))
        end
    else
        if not GetIsVehicleEngineRunning(Shared.CurrentVehicle) then
            RequestAnimDict('veh@handler@base')
            while not HasAnimDictLoaded('veh@handler@base') do
                Wait(0)
            end
            TaskPlayAnim(Shared.Ped, 'veh@handler@base', 'hotwire', 1.0, 1.0, -1, 49, 1.0, 0, 0, 0)

            local class = GetVehicleClass(Shared.CurrentVehicle)
            for i=1,7 do
                if not Minigame(15, 1000 / (val.ID == 'lockpick_adv' and 1 or (difficulty[class] or 1))) then
                    if Random(100) > (items[val.Key].BreakChance or 80) then
                        TriggerServerEvent('RemoveItem', val.ID, 1)
                    end

                    StopAnimTask(Shared.Ped, 'veh@handler@base', 'hotwire', 1.0)
                    return
                end
            end

            StopAnimTask(Shared.Ped, 'veh@handler@base', 'hotwire', 1.0)
            SetVehicleEngineOn(Shared.CurrentVehicle, true, false, true)
            Wait(500)
            if GetVehicleEngineHealth(Shared.CurrentVehicle) < 150 then
                SetVehicleEngineOn(Shared.CurrentVehicle, false, true, true)
            end
            exports['geo-vehicle']:Engine(true)
            TriggerEvent('AddKey', Shared.CurrentVehicle)
        end
    end
end