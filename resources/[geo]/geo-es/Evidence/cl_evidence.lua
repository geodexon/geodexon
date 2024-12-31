local casings = {}
local closeCasings = {}
local zone = 0
local showEvidence = false
local cWep

AddEventHandler('WeaponSwitch', function(weponID, weaponData)
    cWep = weaponData
    if cWep and cWep.Key == 'flashlight' then
        local player = PlayerId()
        while cWep and cWep.Key == 'flashlight' do
            Wait(250)
            if IsPlayerFreeAiming(player) then
                ShowEvidence(true)
            else
                ShowEvidence(false)
            end
        end
    else
        if cWep.Key == nil then cWep = nil end
    end
end)

local _collecting = false
AddEventHandler('Interact', function()
    if showEvidence and MyCharacter.Duty == 'Police' then
        local closestEvidence
        local dist = 500.0
        for k,v in pairs(casings) do
            local distance = Vdist3(GetEntityCoords(Shared.Ped), v.pos)
            if distance <= 1.5 and distance < dist then
                closestEvidence = k
                dist = Vdist3(GetEntityCoords(Shared.Ped), v.pos)
            end
        end

        if not closestEvidence then return end

        if _collecting then return end
        _collecting = true
        if exports['geo-shared']:ProgressSync('Collecting Evidence', 5000) then
            local indexes = {}
            local count = 0
            for k,v in pairs(casings) do
                if v.FullSerial == casings[closestEvidence].FullSerial then
                    count = count + 1
                    table.insert(indexes, k)
                end
            end

            if Task.Run('Evidence.Collect', closestEvidence, count, indexes) then
                TriggerServerEvent('Evidence.Clear', indexes)
            end
        end
        _collecting = false
    end
end)

AddEventHandler('ShotFired', function(ent, wep, itemInfo)
    if wep.Data then
        TriggerServerEvent('Evidence.Shot', wep.Data.UniqueID, itemInfo.Weapon, Shared.GetLocation().zone)
    end
end)

RegisterNetEvent('Evidence.Shot')
AddEventHandler('Evidence.Shot', function(data, id)
    data.time = GetGameTimer()
    casings[id] = data
end)

function ShowEvidence(bool)
    if bool then
        if not showEvidence then
            showEvidence = true
            CreateThread(function()
                while showEvidence do
                    Wait(0)
                    for k,v in pairs(casings) do
                        if zone == v.zone and Vdist3(GetEntityCoords(Shared.Ped), v.pos) <= 20.0 then
                            local found, x, y = GetScreenCoordFromWorldCoord(v.pos.x, v.pos.y, v.pos.z)
                            if found then
                                if v.eType == 'Casing' then
                                    Shared.DrawText('Bullet Casing', x, y, 0, {175, 175, 175, 255}, 0.3, true, true, false)
                                    Shared.DrawText(v.Serial, x, y + 0.025, 0, {175, 175, 175, 255}, 0.3, true, true, false)
                                elseif v.eType == 'Blood' then
                                    Shared.DrawText('Blood: '..v.Serial, x, y, 0, {175, 175, 175, 255}, 0.3, true, true, false)
                                    DrawSphere(v.pos, 0.1, 255, 0, 0, 0.5)
                                end
                            end
                        end
                    end
                end
            end)
            
            CreateThread(function()
                while showEvidence do
                    zone = Shared.GetLocation().zone
                    Wait(5000)
                end
            end)
        end
    else
        showEvidence = false
    end
end

exports('ShowEvidence', ShowEvidence)

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

local weaponNames = {
    [GetHashKey("WEAPON_UNARMED")] = "Unarmed",
    [GetHashKey("WEAPON_KNIFE")] = "Knife",
    [GetHashKey("WEAPON_KNUCKLE")] = "Brass Knuckles",
    [GetHashKey("WEAPON_NIGHTSTICK")] = "Nightstick",
    [GetHashKey("WEAPON_HAMMER")] = "Hammer",
    [GetHashKey("WEAPON_BAT")] = "Bat",
    [GetHashKey("WEAPON_GOLFCLUB")] = "Golf Club",
    [GetHashKey("WEAPON_CROWBAR")] = "Crowbar",
    [GetHashKey("WEAPON_BOTTLE")] = "Bottle",
    [GetHashKey("WEAPON_DAGGER")] = "Dagger",
    [GetHashKey("WEAPON_HATCHET")] = "Hatchet",
    [GetHashKey("WEAPON_MACHETE")] = "Machete",
    [GetHashKey("WEAPON_FLASHLIGHT")] = "Flashlight",
    [GetHashKey("WEAPON_SWITCHBLADE")] = "Switchblade",
    [GetHashKey("WEAPON_PROXMINE")] = "Proximity Mine",
    [GetHashKey("WEAPON_BZGAS")] = "BZ Gas",
    [GetHashKey("WEAPON_SMOKEGRENADE")] = "Smoke Grenade",
    [GetHashKey("WEAPON_MOLOTOV")] = "Molotov Cocktail",
    [GetHashKey("WEAPON_FIREEXTINGUISHER")] = "Fire Extinguisher",
    [GetHashKey("WEAPON_PETROLCAN")] = "Gasoline Canister",
    [GetHashKey("WEAPON_SNOWBALL")] = "Snowball",
    [GetHashKey("WEAPON_FLARE")] = "Flare Gun",
    [GetHashKey("WEAPON_BALL")] = "Ball",
    [GetHashKey("WEAPON_REVOLVER")] = "Revolver",
    [GetHashKey("WEAPON_POOLCUE")] = "Pool Cue",
    [GetHashKey("WEAPON_PIPEWRENCH")] = "Pipe Wrench",
    [GetHashKey("WEAPON_PISTOL")] = "Pistol",
    [GetHashKey("WEAPON_PISTOL_MK2")] = "Pistol MK II",
    [GetHashKey("WEAPON_COMBATPISTOL")] = "Combat Pistol",
    [GetHashKey("WEAPON_APPISTOL")] = "AP Pistol",
    [GetHashKey("WEAPON_PISTOL50")] = ".50 Cal Pistol",
    [GetHashKey("WEAPON_SNSPISTOL")] = "SNS Pistol",
    [GetHashKey("WEAPON_HEAVYPISTOL")] = "Heavy Pistol",
    [GetHashKey("WEAPON_VINTAGEPISTOL")] = "Vintage Pistol",
    [GetHashKey("WEAPON_STUNGUN")] = "Stun Gun",
    [GetHashKey("WEAPON_FLAREGUN")] = "Flare Gun",
    [GetHashKey("WEAPON_MARKSMANPISTOL")] = "Marksman Pistol",
    [GetHashKey("WEAPON_MICROSMG")] = "Micro SMG",
    [GetHashKey("WEAPON_MINISMG")] = "Mini SMG",
    [GetHashKey("WEAPON_SMG")] = "SMG",
    [GetHashKey("WEAPON_SMG_MK2")] = "SMG MK II",
    [GetHashKey("WEAPON_ASSAULTSMG")] = "Assault SMG",
    [GetHashKey("WEAPON_MG")] = "MG",
    [GetHashKey("WEAPON_COMBATMG")] = "Combat MG",
    [GetHashKey("WEAPON_COMBATMG_MK2")] = "Combat MG MK II",
    [GetHashKey("WEAPON_COMBATPDW")] = "Combat PDW",
    [GetHashKey("WEAPON_GUSENBERG")] = "Gusenberg Sweeper",
    [GetHashKey("WEAPON_MACHINEPISTOL")] = "Machine Pistol",
    [GetHashKey("WEAPON_ASSAULTRIFLE")] = "Assault Rifle",
    [GetHashKey("WEAPON_ASSAULTRIFLE_MK2")] = "Assault Rifle MK II",
    [GetHashKey("WEAPON_CARBINERIFLE")] = "Carbine Rifle",
    [GetHashKey("WEAPON_CARBINERIFLE_MK2")] = "Carbine Rifle MK II",
    [GetHashKey("WEAPON_ADVANCEDRIFLE")] = "Advanced Rifle",
    [GetHashKey("WEAPON_SPECIALCARBINE")] = "Special Carbine",
    [GetHashKey("WEAPON_BULLPUPRIFLE")] = "Bullpup Rifle",
    [GetHashKey("WEAPON_COMPACTRIFLE")] = "Compact Rifle",
    [GetHashKey("WEAPON_PUMPSHOTGUN")] = "Pump-Action Shotgun",
    [GetHashKey("WEAPON_SWEEPERSHOTGUN")] = "Sweeper Shotgun",
    [GetHashKey("WEAPON_SAWNOFFSHOTGUN")] = "Sawed-Off Shotgun",
    [GetHashKey("WEAPON_BULLPUPSHOTGUN")] = "Bullpup Shotgun",
    [GetHashKey("WEAPON_ASSAULTSHOTGUN")] = "Assault Shotgun",
    [GetHashKey("WEAPON_MUSKET")] = "Musket",
    [GetHashKey("WEAPON_HEAVYSHOTGUN")] = "Heavy Shotgun",
    [GetHashKey("WEAPON_DBSHOTGUN")] = "Double Barrel Shotgun",
    [GetHashKey("WEAPON_SNIPERRIFLE")] = "Sniper Rifle",
    [GetHashKey("WEAPON_HEAVYSNIPER")] = "Heavy Sniper Rifle",
    [GetHashKey("WEAPON_HEAVYSNIPER_MK2")] = "Heavy Sniper Rifle MK II",
    [GetHashKey("WEAPON_MARKSMANRIFLE")] = "Marksman Rifle",
    [GetHashKey("WEAPON_GRENADELAUNCHER")] = "Grenade Launcher",
    [GetHashKey("WEAPON_GRENADELAUNCHER_SMOKE")] = "Grenade Launcher (Smoke)",
    [GetHashKey("WEAPON_RPG")] = "RPG",
    [GetHashKey("WEAPON_MINIGUN")] = "Minigun",
    [GetHashKey("WEAPON_FIREWORK")] = "Firework Launcher",
    [GetHashKey("WEAPON_RAILGUN")] = "Railgun",
    [GetHashKey("WEAPON_HOMINGLAUNCHER")] = "Homing Launcher",
    [GetHashKey("WEAPON_GRENADE")] = "Grenade",
    [GetHashKey("WEAPON_STICKYBOMB")] = "Sticky Bomb",
    [GetHashKey("WEAPON_COMPACTLAUNCHER")] = "Compact Grenade Launcher",
    [GetHashKey("WEAPON_SNSPISTOL_MK2")] = "SNS Pistol MK II",
    [GetHashKey("WEAPON_REVOLVER_MK2")] = "Revolver MK II",
    [GetHashKey("WEAPON_DOUBLEACTION")] = "Double-Action Revolver",
    [GetHashKey("WEAPON_SPECIALCARBINE_MK2")] = "Special Carbine MK II",
    [GetHashKey("WEAPON_BULLPUPRIFLE_MK2")] = "Bullpup Rifle MK II",
    [GetHashKey("WEAPON_PUMPSHOTGUN_MK2")] = "Pump-Action Shotgun MK II",
    [GetHashKey("WEAPON_MARKSMANRIFLE_MK2")] = "Marksman Rifle MK II",
    [GetHashKey("WEAPON_RAYPISTOL")] = "Up-n-Atomizer",
    [GetHashKey("WEAPON_RAYCARBINE")] = "Unholy Hellbringer",
    [GetHashKey("WEAPON_RAYMINIGUN")] = "Widowmaker",
    [GetHashKey("WEAPON_HIT_BY_WATER_CANNON")] = "Hit by Water Cannon",
    [GetHashKey("WEAPON_RUN_OVER_BY_CAR")] = "Run Over by Car",
    [GetHashKey("WEAPON_COUGAR")] = "Cougar",
}

AddEventHandler('gameEventTriggered', function(event, b)
    if event == 'CEventNetworkEntityDamage' then
        local targetPed, originPed, _, _, _, _, weaponHash, _, _, _, _, _, _ = table.unpack(b)
        if originPed == Shared.Ped and IsEntityAPed(targetPed) then
            if weaponHash == `WEAPON_RUN_OVER_BY_CAR` or weaponHash == `WEAPON_HIT_BY_WATER_CANNON` then
                if not RateLimit('VehicleDamage'..targetPed, 2500) then
                    return
                end
            end

            if not RateLimit(weaponHash..targetPed, 100) then
                return
            end

            local varWep = New(cWep)
            local wep = varWep and exports['geo-inventory']:GetItemName(varWep.Key)

            if varWep then
                if GetHashKey(exports['geo-inventory']:GetItem(varWep.Key).Weapon) ~= weaponHash then
                    wep = nil
                    varWep = nil
                end
            end

            if not wep and weaponHash == `WEAPON_UNARMED` then
                wep = 'Fists'
            end

            if not wep then
                wep = weaponNames[weaponHash]
                if not wep then wep = 'Unknown' end
            end

            local data = ''
            if varWep then
                data = varWep.Data.UniqueID
            else
                if wep == 'Fists' then
                    data = 'DNA: '..( Random(1, 25) == 1 and MyCharacter.data.dna or 'None Left')
                end
            end

            TriggerServerEvent('Evidence.Entity', NetworkGetNetworkIdFromEntity(targetPed), wep, data, IsPedMale(targetPed))
            
            if IsPedAPlayer(targetPed) then
                local wep
                for i,v in ipairs(weapons) do
                    if GetHashKey(v) == weaponHash then
                        wep = v
                    end
                end

                TriggerServerEvent('ShotPlayer', GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed)), wep)
            end
            return
        end

        if targetPed == Shared.Ped then
            local group = GetWeapontypeGroup(weaponHash)
            if group ~= -728555052 and group ~= -728555052 and group ~= -1609580060 then
                local wep = GetSelectedPedWeapon(Shared.Ped)
                local myGroup = GetWeapontypeGroup(wep)
                if myGroup == -728555052 or myGroup ==-1609580060 or myGroup == 970310034 then
                    if Random(100) > 75 then
                        SetPedToRagdoll(Shared.Ped, 100, 100, 0, 1, 1, 1)
                    end
                end
            end
            return
        end

        if NetworkGetEntityOwner(targetPed) == PlayerId() and IsEntityAVehicle(targetPed) then
            TriggerServerEvent('Vehicle.UpdateHealth', VehToNet(targetPed), GetVehicleEngineHealth(targetPed), GetVehicleBodyHealth(targetPed))
        end
    end
end)

CreateThread(function()
    while true do
        Wait(60000)
        for k,v in pairs(casings) do
            if Shared.TimeSince(v.time) >= 900000 then
                casings[k] = nil
            end
        end
    end
end)

AddEventHandler('RemoveEvidence', function()
    local list = {}
    for k,v in pairs(casings) do
        if Vdist3(GetEntityCoords(Shared.Ped), v.pos) <= 20.0 then
            table.insert(list, k)
        end
    end
    TriggerServerEvent('Evidence.Clear', list)
end)

RegisterNetEvent('Evidence.Clear')
AddEventHandler('Evidence.Clear', function(list)
    for k,v in pairs(list) do
        casings[v] = nil
    end
end)