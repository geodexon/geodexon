--[[ local currentWeapon = 0
local weaponList = {
    {Name = 'WEAPON_ASSAULTRIFLE', Hash = GetHashKey('WEAPON_ASSAULTRIFLE'), obj = nil, model = 'w_ar_assaultrifle', active = false, pos = vector3(-0.1, -0.125, 0.0), rot = vector3(0.0, 90.0, 0.0)},
    {Name = 'WEAPON_CARBINERIFLE', Hash = GetHashKey('WEAPON_CARBINERIFLE'), obj = nil, model = 'w_ar_carbinerifle', active = false, pos = vector3(0.05, -0.125, 0.0), rot = vector3(0.0, 160.0, 0.0)},
    {Name = 'WEAPON_PUMPSHOTGUN', Hash = GetHashKey('WEAPON_PUMPSHOTGUN'), obj = nil, model = 'w_sg_pumpshotgun', active = false, pos = vector3(0.1, -0.125, 0.0), rot = vector3(0.0, 200.0, 0.0)},
    {Name = 'WEAPON_SMG', Hash = GetHashKey('WEAPON_SMG'), obj = nil, model = 'w_sb_smg', active = false, pos = vector3(0.0, -0.125, 0.0), rot = vector3(0.0, 120.0, 0.0)},
}

Citizen.CreateThread(function()
    while true do
        Wait(500)
        local ped = PlayerPedId()
        for k,v in pairs(weaponList) do
            if InventoryHasItemByKey(v.Name) then
                if currentWeapon == v.Hash then
                    if v.obj then
                        DeleteObject(v.obj)
                        weaponList[k].obj = nil
                    end
                else
                    if not v.obj then
                        weaponList[k].obj = Common.SpawnObject(v.model)
						AttachEntityToEntity(weaponList[k].obj, ped, GetPedBoneIndex(ped, 24818), v.pos, v.rot, 0, false, false, false, 0, true)
                        if v.tint then
                            SetWeaponObjectTintIndex(weaponList[k].obj, v.tint)
                        end
                    end
                end
            else
                if v.obj then
                    DeleteObject(v.obj)
                    weaponList[k].obj = nil
                end
            end
        end
    end
end)

AddEventHandler('onClientResourceStop', function(res)

    if res ~= GetCurrentResourceName() then
        return
    end

    for k,v in pairs(weaponList) do
        if v.obj then
            DeleteObject(v.obj)
            weaponList[k].obj = nil
        end
    end
end) ]]