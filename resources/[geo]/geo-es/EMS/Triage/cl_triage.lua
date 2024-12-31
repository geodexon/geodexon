local weapons = {
    "WEAPON_UNARMED",
    "WEAPON_KNIFE",
    "WEAPON_KNUCKLE",
    "WEAPON_NIGHTSTICK",
    "WEAPON_HAMMER",
    "WEAPON_BAT",
    "WEAPON_GOLFCLUB",
    "WEAPON_CROWBAR",
    "WEAPON_BOTTLE",
    "WEAPON_DAGGER",
    "WEAPON_HATCHET",
    "WEAPON_MACHETE",
    "WEAPON_FLASHLIGHT",
    "WEAPON_SWITCHBLADE",
    "WEAPON_PROXMINE",
    "WEAPON_BZGAS",
    "WEAPON_SMOKEGRENADE",
    "WEAPON_MOLOTOV",
    "WEAPON_FIREEXTINGUISHER",
    "WEAPON_PETROLCAN",
    "WEAPON_SNOWBALL",
    "WEAPON_FLARE",
    "WEAPON_BALL",
    "WEAPON_REVOLVER",
    "WEAPON_POOLCUE",
    "WEAPON_PIPEWRENCH",
    "WEAPON_PISTOL",
    "WEAPON_PISTOL_MK2",
    "WEAPON_COMBATPISTOL",
    "WEAPON_APPISTOL",
    "WEAPON_PISTOL50",
    "WEAPON_SNSPISTOL",
    "WEAPON_HEAVYPISTOL",
    "WEAPON_VINTAGEPISTOL",
    "WEAPON_STUNGUN",
    "WEAPON_FLAREGUN",
    "WEAPON_MARKSMANPISTOL",
    "WEAPON_MICROSMG",
    "WEAPON_MINISMG",
    "WEAPON_SMG",
    "WEAPON_SMG_MK2",
    "WEAPON_ASSAULTSMG",
    "WEAPON_MG",
    "WEAPON_COMBATMG",
    "WEAPON_COMBATMG_MK2",
    "WEAPON_COMBATPDW",
    "WEAPON_GUSENBERG",
    "WEAPON_MACHINEPISTOL",
    "WEAPON_ASSAULTRIFLE",
    "WEAPON_ASSAULTRIFLE_MK2",
    "WEAPON_CARBINERIFLE",
    "WEAPON_CARBINERIFLE_MK2",
    "WEAPON_ADVANCEDRIFLE",
    "WEAPON_SPECIALCARBINE",
    "WEAPON_BULLPUPRIFLE",
    "WEAPON_COMPACTRIFLE",
    "WEAPON_PUMPSHOTGUN",
    "WEAPON_SWEEPERSHOTGUN",
    "WEAPON_SAWNOFFSHOTGUN",
    "WEAPON_BULLPUPSHOTGUN",
    "WEAPON_ASSAULTSHOTGUN",
    "WEAPON_MUSKET",
    "WEAPON_HEAVYSHOTGUN",
    "WEAPON_DBSHOTGUN",
    "WEAPON_SNIPERRIFLE",
    "WEAPON_HEAVYSNIPER",
    "WEAPON_HEAVYSNIPER_MK2",
    "WEAPON_MARKSMANRIFLE",
    "WEAPON_GRENADELAUNCHER",
    "WEAPON_GRENADELAUNCHER_SMOKE",
    "WEAPON_RPG",
    "WEAPON_MINIGUN",
    "WEAPON_FIREWORK",
    "WEAPON_RAILGUN",
    "WEAPON_HOMINGLAUNCHER",
    "WEAPON_GRENADE",
    "WEAPON_STICKYBOMB",
    "WEAPON_COMPACTLAUNCHER",
    "WEAPON_SNSPISTOL_MK2",
    "WEAPON_REVOLVER_MK2",
    "WEAPON_DOUBLEACTION",
    "WEAPON_SPECIALCARBINE_MK2",
    "WEAPON_BULLPUPRIFLE_MK2",
    "WEAPON_PUMPSHOTGUN_MK2",
    "WEAPON_MARKSMANRIFLE_MK2",
    "WEAPON_RAYPISTOL",
    "WEAPON_RAYCARBINE",
    "WEAPON_RAYMINIGUN",
    "WEAPON_HIT_BY_WATER_CANNON",
    "WEAPON_RUN_OVER_BY_CAR",
    "WEAPON_COUGAR"
}

local weaponGroups = {
    [416676503] = 'Pistol',
    [-957766203] = 'SMG',
    [970310034] = 'Assault Rifle',
    [-1212426201] = 'Sniper Rifle',
    [860033945] = 'Shotgun',
    [-1569042529] = 'Heavy Weapon',
    [1548507267] = 'Projectile',
    [-728555052] = 'Blunt',
    [-1609580060] = 'Blunt'
}

local bones = {
    [0] = "mid-section",
    [839] = 'tail',
    [840] = 'tail',
    [841] = 'tail',
    [842] = 'tail',
    [1356] = "eyebrows",
    [2108] = "left foot toes",
    [2992] = "elbow",
    [4089] = "left ring finger",
    [4090] = "left pinky",
    [4137] = "left index finger",
    [4138] = "left middle finger",
    [4153] = "left thumb",
    [4154] = "left ring finger",
    [4169] = "left pinky",
    [4170] = "left index finger",
    [4185] = "left middle finger",
    [4186] = "left thumb",
    [5232] = "left arm",
    [6286] = "right hand",
    [6442] = "right thigh",
    [10706] = "right clavicle",
    [11174] = "lips",
    [11816] = "pelvis",
    [12844] = "head",
    [14201] = "left foot",
    [16335] = "right knee",
    [17188] = "lips",
    [17719] = "lips",
    [18905] = "left hand",
    [19336] = "right cheek",
    [20178] = "lips",
    [20279] = "lips",
    [20623] = "lips",
    [20781] = "right foot toes",
    [21550] = "left cheek",
    [22711] = "elbow",
    [23553] = "mid-section",
    [23639] = "left thigh",
    [24806] = "right foot",
    [24816] = "abdomen",
    [24817] = "lower chest",
    [24818] = "upper chest",
    [25260] = "left eye",
    [26610] = "left pinky",
    [26611] = "left ring finger",
    [26612] = "left middle finger",
    [26613] = "left index finger",
    [26614] = "left thumb",
    [27474] = "right eye",
    [28252] = "right forearm",
    [28422] = "right hand",
    [29868] = "lips",
    [31086] = "head",
    [35502] = "right foot",
    [35731] = "neck",
    [36029] = "left hand",
    [36864] = "right calf",
    [37119] = "right arm",
    [37193] = "eyebrows",
    [39317] = "neck",
    [40269] = "upper arm",
    [43536] = "lips",
    [43810] = "forearm",
    [45509] = "upper arm",
    [45750] = "lips",
    [46078] = "left knee",
    [46240] = "jaw",
    [47419] = "lips",
    [47495] = "tongue",
    [49979] = "lips",
    [51826] = "right thigh",
    [52301] = "right foot",
    [56604] = "mid-region",
    [57005] = "right hand",
    [57597] = "mid-region",
    [57717] = "left foot",
    [58271] = "left thigh",
    [58331] = "eyebrows",
    [58866] = "right pinky",
    [58867] = "right ring finger",
    [58868] = "right middle finger",
    [58869] = "right index finger",
    [58870] = "right thumb",
    [60309] = "left hand",
    [61007] = "left forearm",
    [61163] = "left forearm",
    [61839] = "lips",
    [63931] = "left calf",
    [64016] = "right pinky",
    [64017] = "right ring finger",
    [64064] = "right middle finger",
    [64065] = "right index finger",
    [64080] = "right thumb",
    [64081] = "right pinky",
    [64096] = "right ring finger",
    [64097] = "right middle finger",
    [64112] = "right index finger",
    [64113] = "right thumb",
    [64729] = "left clavicle",
    [65068] = "face",
    [65245] = "foot"
}

local n = {}
for k,v in pairs(bones) do
    n[k] = v:gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end)
end
bones = n

local knife = {
    ["WEAPON_KNIFE"] = 0,
    ['WEAPON_BOTTLE'] = 0,
    ['WEAPON_DAGGER'] = 0,
    ['WEAPON_HATCHET'] = 0,
    ['WEAPON_MACHETE'] = 0,
    ['WEAPON_SWITCHBLADE'] = 0,
    ['WEAPON_BATTLEAXE'] = 0,
}

local ImpactTimeout = 2000
local fireTimeout = 15000
local projectileTimeout = 15000
local projectileDamage = false
local impactDamage = false
local fireDamage = false
local bleedTimeout = 500

Citizen.CreateThread(function()
    local lastHealth = GetEntityHealth(ped)
    while true do
        Wait(100)
        local ped = PlayerPedId()
        local health = GetEntityHealth(ped)
        if health ~= lastHealth then
            SetPedMinGroundTimeForStungun(Shared.Ped, 3000)
            local damage = {}
            local causeBleed = false
            for k,v in pairs(weapons) do
                local hash = weaponGroups[GetWeapontypeGroup(GetHashKey(v))]
                if HasEntityBeenDamagedByWeapon(ped, GetHashKey(v), 0) then
                    if v == "WEAPON_UNARMED" then
                        hash = 'Unarmed'
                    elseif v == "WEAPON_HIT_BY_WATER_CANNON" then
                        hash = "Abusive EMS Member"
                    elseif v == "WEAPON_SNOWBALL" then
                        hash = "Snowball"
                    elseif v == "WEAPON_RUN_OVER_BY_CAR" then
                        hash = "Vehicle"
                    elseif v == "WEAPON_COUGAR" then
                        hash = 'Kitty Food'
                    elseif v == 'WEAPON_STUNGUN' or v == 'WEAPON_PDSTUN' then
                        hash = 'Taser Prong'
                    else
                        if hash ~= nil and hash ~= 'Blunt' then
                            causeBleed = true
                        end
                    end
                    if knife[v] ~= nil then
                        hash = 'Sharp'
                        causeBleed = true
                    end
                    if hash == 'Projectile' then
                        if projectileDamage then
                            break
                        else
                            projectileDamage = true
                            Citizen.SetTimeout(projectileTimeout, function()
                                projectileDamage = false
                            end)
                        end
                    end
                    local unused, bone = GetPedLastDamageBone(ped)
                    if hash == nil then
                        hash = 'Unknown'
                    end
                    damage[#damage + 1] = {type = hash, bone = bone}
                    break
                end
            end
            if IsEntityOnFire(ped) then
                if not fireDamage then
                    local unused, bone = GetPedLastDamageBone(ped)
                    fireDamage = true
                    damage[#damage + 1] = {type = 'Fire', bone = bone}
                    Citizen.SetTimeout(fireTimeout, function()
                        fireDamage = false
                    end)
                end
            end
            if HasEntityCollidedWithAnything(ped) then
                if not impactDamage then
                    local unused, bone = GetPedLastDamageBone(ped)
                    impactDamage = true
                    damage[#damage + 1] = {type = 'Impact', bone = bone}
                    Citizen.SetTimeout(ImpactTimeout, function()
                        ImpactTimeout = false
                    end)
                end
            end
            if #damage > 0 then
                TriggerServerEvent('EMS:PedDamage', damage)
                ClearPedLastDamageBone(ped)
                ClearEntityLastDamageEntity(ped)
                ClearEntityLastWeaponDamage(ped)
            end

            if causeBleed then
                if Random(100) > 75 and MyCharacter.dead ~= 1 then
                    if Shared.TimeSince(bleedTimeout) > 2000 then
                        bleedTimeout = GetGameTimer()
                        TriggerServerEvent('Status.Bleed')
                    end
                end
            end
        end
        SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
        if (health / GetEntityMaxHealth(ped)) < 0.75  then
            SetPlayerSprint(PlayerId(), false)
        else
            SetPlayerSprint(PlayerId(), true)
        end
        lastHealth = GetEntityHealth(ped)
    end
end)

RegisterCommand('triage', function(source, args, raw)
    if IsES(MyCharacter.id) then
        local player = GetClosestPlayer()
        if player ~= nil then
            TriggerServerEvent('EMS:Triage', GetPlayerServerId(player))
        end
    end
end)

RegisterCommand('triageself', function(source, args, raw)
    if IsES(MyCharacter.id) then
        TriggerServerEvent('EMS:Triage', GetPlayerServerId(PlayerId()))
    end
end)

RegisterNetEvent('EMS:Triage')
AddEventHandler('EMS:Triage', function(damage)
    TriggerEvent('Chat.Message', '', 'Triage', 'center')
    TriggerEvent('Chat.Message', '', '', 'br')
    local boneDamage = {}
    for k,v in pairs(damage) do
        for key, value in pairs(v) do
            if boneDamage[value.bone] == nil then
                boneDamage[value.bone] = {}
            end
            if boneDamage[value.bone][k] == nil then
                boneDamage[value.bone][k] = {}
            end
            boneDamage[value.bone][k][#boneDamage[value.bone][k] + 1] = value
        end
    end
    local shown = {}
    for k,v in pairs(boneDamage) do
        if IsEMS(MyCharacter.id) then
            for key,value in pairs(v) do
                TriggerEvent('Chat.Message', '', '^0['..bones[k]..'] ['..key..'] '.. #value..' wounds', 'me')
            end
        else
            local num = 0
            for key,value in pairs(v) do
                num = num + #value
            end
            TriggerEvent('Chat.Message',  '', '^0['..bones[k]..'] '..num..' wounds', 'me')
        end
    end
    TriggerEvent('Chat.Message', '', '', 'br')
end)

AddEventHandler('Death.Cause', function(ent)
    local dead = GetPedCauseOfDeath(ent)
    TriggerEvent('Shared.Notif', 'This person seems to have died from '..(weaponGroups[GetWeapontypeGroup(dead)] or 'Unknown')..' damage')
end)