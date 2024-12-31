AddEventHandler('ShotFired', function(ent, wep)

    if wep.Key == 'snowball' or wep.Key == 'gascan' then return end

    if MyCharacter then
        local max = RPG.Levels[15]
        if wep.Key == 'carbine' then
            max = RPG.Levels[30]
        end
        
        local r1 = Random(math.floor((-2.0 + (((MyCharacter.skills.Shooting or 0) / max) * 2)) * 100), math.floor((2.0 - (((MyCharacter.skills.Shooting or 0) / max) * 2)) * 100))
        local r2 = Random(math.floor((-4.0 + (((MyCharacter.skills.Shooting or 0) / max) * 2)) * 100), math.floor((4.0 - (((MyCharacter.skills.Shooting or 0) / max) * 2)) * 100))
        SetGameplayCamRelativeRotation(GetGameplayCamRelativeHeading() + (r1 / 75), GetGameplayCamRelativePitch() + (r2 / 75), 0.0)
        ShakeGameplayCam('JOLT_SHAKE', 1.0 - (((MyCharacter.skills.Shooting or 0) / max)))
    
        if IsEntityAPed(ent) and not IsEntityDead(ent) then
            TriggerServerEvent('Ped.Shot', PedToNet(ent))
        end
    end
end)

local ammu = {} 

AddZone({
    vector2(6.4844875335693, -1098.4885253906),
    vector2(18.374326705933, -1101.7583007813),
    vector2(19.592279434204, -1097.9156494141),
    vector2(7.1237573623657, -1093.7523193359)
  }, {
    name="Shooting.Ammunation",
})


local usingRange = false
local ranges = {
    vector3(14.01247,-1079.892, 31.8),
    vector3(14.92893, -1080.152, 31.8),
    vector3(15.85143, -1080.531, 31.8),
    vector3(16.79301, -1080.851, 31.8),
    vector3(21.51006, -1082.579, 31.8),
    vector3(22.44058, -1083.017, 31.8),
    vector3(23.438848, -1083.271, 31.8),
    vector3(24.30321, -1083.613, 31.8),
}

AddTextEntry("Ammunation:Shootiung", "~INPUT_CONTEXT~ Use Range")
AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'Shooting.Ammunation' then
        ammu.inside = inZone
        if ammu.inside then

            CreateThread(function()
                Wait(1000)
                TriggerEvent('Help', 2)
            end)

            local v1, v2, v3, h, ref
            local points = 0
            Update('range', 1)
            exports['geo-inventory']:ToggleWeapon()

            while ammu.inside do
                Wait(0)

                SuppressShockingEventsNextFrame()
                if not usingRange then
                    if Vdist3(GetEntityCoords(Shared.Ped), vector3(13.56, -1097.22, 29.83)) <= 3.0 then 
                        ShowFloatingHelp('Ammunation:Shootiung', vector3(13.56, -1097.22, 29.83), 6)
                        if IsControlJustPressed(0, 38) then
                            ref = Task.Run('Ammunation.Range')
                            if ref then
                                usingRange = true

                                v1 = Shared.SpawnObject('prop_target_backboard')
                                v2 = Shared.SpawnObject('prop_target_arm')
                                v3 = Shared.SpawnObject('prop_target_comp_wood')
                                SetNetworkIdCanMigrate(ObjToNet(v1), false)
                                SetNetworkIdCanMigrate(ObjToNet(v2), false)
                                SetNetworkIdCanMigrate(ObjToNet(v3), false)
        
                                FreezeEntityPosition(v2, true)
                                Wait(100)
                                AttachEntityToEntity(v1, v2, 0, 0.0, 0.0, -0.76, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, 1);
                                AttachEntityToEntity(v3, v2, 0, 0.0, 0.125, -1.175, 0.0, 0.0, 180.0, 0, 0, 1, 0, 2, 1);
                            
                                SetEntityRotation(v2, 0.0, 0.0, 160.0)
                                SetEntityCoords(v2, ranges[ref[2]])
                                SetEntityInvincible(v3, false)
                                SetEntityOnlyDamagedByPlayer(v3, true)
                                h = GetEntityHealth(v3)
        
                                TriggerEvent('Holster:PauseFor', 100)
                                GiveWeaponToPed(Shared.Ped, 'WEAPON_PISTOL', 0, false, true)
                                SetPedAmmo(Shared.Ped, 'WEAPON_PISTOL', 30)
                                TriggerEvent('Shared.Notif', "You're up on range "..ref[2], 7500)
                            end
                        end
                    end
                else
                    if GetEntityHealth(v3) ~= h then
                        h = GetEntityHealth(v3)
                        local pos = GetEntityCoords(v3)
                        if HasBulletImpactedInArea(pos, 0.06, true, true) then
                            points = points + 5
                        elseif HasBulletImpactedInArea(pos, 0.11, true, true) then
                            points = points + 4
                        elseif HasBulletImpactedInArea(pos, 0.16, true, true) then
                            points = points + 3
                        elseif HasBulletImpactedInArea(pos, 0.21, true, true) then
                            points = points + 2
                        else
                            points = points + 1
                        end
                        RemoveDecalsInRange(GetEntityCoords(v3), 10.0)
                    end
                end
            end

            Update('range', 0)
            if usingRange then
                usingRange = false
                DeleteEntity(v1)
                DeleteEntity(v2)
                DeleteEntity(v3)
                TriggerEvent('Holster:PauseFor', 100)
                RemoveWeaponFromPed(Shared.Ped, 'WEAPON_PISTOL')
                TriggerServerEvent('Shooting.Leave', points, ref[1])
            end
        end
    end
end)

--[[ local n = false
local v2
local v1
local v3
RegisterCommand('plce', function()
    if not n then
        n = true
        v1 = Shared.SpawnObject('prop_target_backboard')
        v2 = Shared.SpawnObject('prop_target_arm', vector3(21.06, -1082.55, 31.9))
        v3 = Shared.SpawnObject('prop_target_comp_wood')

        FreezeEntityPosition(v2, true)
        Wait(100)
        AttachEntityToEntity(v1, v2, 0, 0.0, 0.0, -0.76, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, 1);
        AttachEntityToEntity(v3, v2, 0, 0.0, 0.025, -1.175, 0.0, 0.0, 180.0, 0, 0, 0, 0, 2, 1);

        SetEntityRotation(v2, 0.0, 0.0, 160.0)

        while n do
            Wait(0)
            local ray = Shared.Raycast(50.0)
            if ray.HitEntity ~= v2 then
                SetEntityCoords(v2, Shared.Raycast(50.0).HitPosition)
            end
        end
    else
        n = false
        print(GetEntityCoords(v2))
        DeleteEntity(v1)
        DeleteEntity(v2)
        DeleteEntity(v3)
    end
end) ]]

RegisterKeyMapping('skills', '[General] View Skills ~g~ +Modifier~w~', 'keyboard', 'U')
RegisterCommand('skills', function()
    if controlMod then
        local skills = {}
        for k,v in Shared.SortAlphabet(MyCharacter.skills) do
            table.insert(skills, {k, v})
        end

        exports['geo-interface']:InterfaceMessage({
            interface = 'Skills',
            data = skills,
            info = RPG
        })
    end
end)

RegisterNetEvent('Inventory.Equipped', function(skill)
    Wait(100)
    SkillUpdate()
end)

CreateThread(function()
    Wait(100)
    SkillUpdate()
end)

function SkillUpdate()
    if not MyCharacter then return end
    local inv = exports['geo-inventory']:GetInventory()
    for k,v in pairs(inv) do
        if v.Data.Equipped and (exports['geo-inventory']:GetItem(v.Key).Equippable == 'Main Hand' or exports['geo-inventory']:GetItem(v.Key).Equippable == 'Off Hand') then
            local skill = exports['geo-inventory']:GetItem(v.Key).Skill

            if MyUser and MyUser.data.settings.rpgmode then
                exports['geo-interface']:InterfaceMessage({
                    interface = 'SkillBar',
                    data = {skill, MyCharacter.skills[skill]},
                    info = RPG
                })
                return
            end
        end
    end

    exports['geo-interface']:InterfaceMessage({
        interface = 'SkillBar',
        data = nil,
        info = RPG
    })
end

RegisterNetEvent('Skill.Update', function()
    SkillUpdate()
end)

AddEventHandler('Login', function()
    Wait(100)
    SkillUpdate()
end)

AddEventHandler('Logout', function()
    exports['geo-interface']:InterfaceMessage({
        interface = 'SkillBar',
        data = nil,
        info = RPG
    })
end)