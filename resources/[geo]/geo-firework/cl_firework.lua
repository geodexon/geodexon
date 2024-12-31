RegisterNetEvent('Firework')
AddEventHandler('Firework', function(id)
    RequestWeaponAsset(0x7F7497E5, 31, 26)
    -- Legion
    if id == 1 then
        ShootSingleBulletBetweenCoords(264.02, -870.34, 30.2, 264.02, -870.34, 50.2, true, true, 0x7F7497E5, 0, true, false, 40.0)
    elseif id == 2 then
        ShootSingleBulletBetweenCoords(vector3(187.5, -842.44, 31.01), vector3(187.5, -842.44, 50.01), true, true, 0x7F7497E5, 0, true, false, 40.0)
    elseif id == 3 then
        ShootSingleBulletBetweenCoords(vector3(128.75, -989.0, 29.3),vector3(128.75, -989.0, 50.3), true, true, 0x7F7497E5, 0, true, false, 40.0)
    elseif id == 4 then
        ShootSingleBulletBetweenCoords(vector3(211.3, -1020.36, 29.31),vector3(211.3, -1020.36, 50.31), true, true, 0x7F7497E5, 0, true, false, 40.0)
    end

    --MRPD
    if id == 1 then
        ShootSingleBulletBetweenCoords(vector3(389.36, -992.49, 43.06), vector3(428.63, -984.35, 41.63), true, true, 0x7F7497E5, 0, true, false, 100.0)
    end

    -- Pillbox
    if id == 1 then
        ShootSingleBulletBetweenCoords(vector3(249.48, -554.05, 56.46), vector3(292.43, -574.01, 43.2), true, true, 0x7F7497E5, 0, true, false, 150.0)
    end

    -- Court
    if id == 1 then
        ShootSingleBulletBetweenCoords(vector3(255.59, -343.52, 66.71), vector3(241.92, -399.13, 47.92), true, true, 0x7F7497E5, 0, true, false, 150.0)
    elseif id == 3 then
        ShootSingleBulletBetweenCoords(vector3(233.22, -397.38, 60.27), vector3(233.22, -397.38, 100.27), true, true, 0x7F7497E5, 0, true, false, 150.0)
        ShootSingleBulletBetweenCoords(vector3(243.66, -400.83, 60.21), vector3(243.66, -400.83, 100.21), true, true, 0x7F7497E5, 0, true, false, 150.0)
    end
end)