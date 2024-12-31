local props = {
    ['dollar'] = {prop = 'prop_money_bag_01', Amount = 50000, id = nil, has = false, pos = vec(-0.2, -0.16, 0.1), rot = vec(0.0, 90.0, 0.0)},
    ['beanbag'] = {prop = 'w_sg_pumpshotgun', weapon = 'WEAPON_BEANBAG', tint = 1, Amount = 1, id = nil, has = false, pos = vector3(0.2, -0.14, 0.0), rot = vector3(0.0, 200.0, 0.0)},
    ['jack'] = {prop = 'reh_prop_reh_lantern_pk_01a', Amount = 1, id = nil, has = false, bone = 0xFE2C, pos = vector3(-0.1, 0.0, 0.0), rot = vector3(0.0, 90.0, 180.0)},
    ['huntingrifle'] = {prop = 'w_sr_sniperrifle', weapon = 'WEAPON_SNIPERRIFLE', tint = 4, Amount = 1, id = nil, has = false, pos = vector3(0.2, -0.14, 0.0), rot = vector3(0.0, 200.0, 0.0)},
    ['huntingrifle_gold'] = {prop = 'w_sr_sniperrifle', weapon = 'WEAPON_SNIPERRIFLE', tint = 2, Amount = 1, id = nil, has = false, pos = vector3(0.2, -0.14, 0.0), rot = vector3(0.0, 200.0, 0.0)},
    ['carbine'] = {prop = 'w_sr_sniperrifle', weapon = 'WEAPON_CARBINERIFLE', Amount = 1, id = nil, has = false, pos = vector3(0.2, -0.14, 0.0), rot = vector3(0.0, 200.0, 0.0)},
}

local slots = {
    {0.1, false},
    {0.0, false},
    {-0.1, false},
    {-0.2, false},
    {-0.3, false},
}

for k,v in pairs(props) do
    if not k:match('_hq') then
        props[k..'_hq'] = New(v)
    end
end

RegisterNetEvent('Inventory.KillProps', function()
    for k,v in pairs(props) do
        if v.has then
            v.has = false
            v.id = DeleteEntity(v.id)
            for key,val in pairs(slots) do
                if val[2] == k then
                    slots[key][2] = false
                    break
                end
            end
            TriggerServerEvent('Props', k, false)
        end
    end
end)

AddEventHandler('Logout', function()
    for k,v in pairs(props) do
        if v.has then
            v.has = false
            v.id = DeleteEntity(v.id)
            for key,val in pairs(slots) do
                if val[2] == k then
                    slots[key][2] = false
                    break
                end
            end
            TriggerServerEvent('Props', k, false)
        end
    end
end)

RegisterNetEvent('Inventory.Update', function()
    for k,v in pairs(props) do
        if HasItemKey(k) and not v.has and InventoryAmountKey(k) >= (v.Amount or 1) and (currentWeapon and currentWeapon.Key ~= k) then
            v.has = true

            if not v.weapon then
                v.id = Shared.SpawnObject(v.prop, GetEntityCoords(Shared.Ped), true)
            else
                local wep = GetHashKey(v.weapon)
                RequestWeaponAsset(wep)
                while not HasWeaponAssetLoaded(wep) do
                    Wait(0)
                end
                v.id = CreateWeaponObject(wep, 0, GetEntityCoords(Shared.Ped), true, 1.0, 0);
            end
            SetEntityCollision(v.id, false, false)
            SetEntityAsMissionEntity(v.id, true)

           --[[  for key,val in pairs(slots) do
                if not val[2] then
                    AttachEntityToEntity(v.id, Shared.Ped, GetPedBoneIndex(Shared.Ped, v.bone or 24816),v.pos, v.rot, 1, 1, 1, 0, 1, 1)
                    slots[key][2] = k
                    break
                end
            end ]]

            AttachEntityToEntity(v.id, Shared.Ped, GetPedBoneIndex(Shared.Ped, v.bone or 24816),v.pos + (v.weapon and vec(0.0, 0.0, WeaponCount(props) * 0.1 - 0.15) or vec(0.0, 0.0, 0.0)), v.rot, 1, 1, 1, 0, 1, 1)

            if v.tint then
                SetWeaponObjectTintIndex(v.id, v.tint)
            end

            local mods = GetItemKey(k)
            for _,mod in pairs(mods.Data.Mods or {}) do
                if type(mod) == 'string' then
                    SetWeaponObjectTintIndex(v.id, tonumber(mod))
                else
                    GiveWeaponComponentToWeaponObject(v.id, mod)
                end
            end

            TriggerServerEvent('Props', k, true, mods.Data.Mods)

        elseif v.has then
            if (not HasItemKey(k)) or (HasItemKey(k) and InventoryAmountKey(k) < (v.Amount or 1)) or (currentWeapon and currentWeapon.Key == k) then
               v.has = false
                 v.has = false
                v.id = DeleteEntity(v.id)
                for key,val in pairs(slots) do
                    if val[2] == k then
                        slots[key][2] = false
                        break
                    end
                end
                TriggerServerEvent('Props', k, false)
            end
        end
    end
end)

local sidProps = {}
local sidWeps = {}

RegisterNetEvent('Props', function(id, index, bool, mods)
    if id == GetPlayerServerId(PlayerId()) then return end
    if not bool then
        if sidProps[id] and sidProps[id][index] then
            DeleteEntity(sidProps[id][index])
            sidProps[id][index] = nil
            if props[index].weapon then
                sidWeps[id] = sidWeps[id] - 1
            end
        end
    else
        local ped = GetPlayerPed(GetPlayerFromServerId(id))

        if not sidProps[id] then sidProps[id] = {} end
        if not sidWeps[id] then sidWeps[id] = 0 end
        if not props[index].weapon then
            sidProps[id][index] = Shared.SpawnObject(props[index].prop, GetEntityCoords(ped), true)
        else
            local wep = GetHashKey(props[index].weapon)
            RequestWeaponAsset(wep)
            while not HasWeaponAssetLoaded(wep) do
                Wait(0)
            end
            sidProps[id][index] = CreateWeaponObject(wep, 0, GetEntityCoords(ped), true, 1.0, 0);
            sidWeps[id] = sidWeps[id] + 1
        end

        SetEntityCollision(sidProps[id][index], false, false)
        SetEntityAsMissionEntity(sidProps[id][index], true)
        AttachEntityToEntity(sidProps[id][index], ped, GetPedBoneIndex(ped, props[index].bone or 24816),props[index].pos + (props[index].weapon and vec(0.0, 0.0, sidWeps[id] * 0.1 - 0.15) or vec(0.0, 0.0, 0.0)), props[index].rot, 1, 1, 1, 0, 1, 1)

        if props[index].tint then
            SetWeaponObjectTintIndex(sidProps[id][index], props[index].tint)
        end

        if mods then
            for _,mod in pairs(mods) do
                if type(mod) == 'string' then
                    SetWeaponObjectTintIndex(sidProps[id][index], tonumber(mod))
                else
                    GiveWeaponComponentToWeaponObject(sidProps[id][index], mod)
                end
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        for k,v in pairs(props) do
            if v.id then DeleteEntity(v.id) end
        end

        for k,v in pairs(sidProps) do
            for _,val in pairs(v) do
                DeleteEntity(val)
            end
        end
    end
end)

function WeaponCount(list)
    local count = 0
    for k,v in pairs(list) do
        if v.weapon and v.has then count = count + 1 end
    end

    return count
end

function WeaponCount2(list)
    local count = 0
    for k,v in pairs(list) do
        if v.weapon and v.has then count = count + 1 end
    end

    return count
end