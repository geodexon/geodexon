local raids = {}
SetMaxWantedLevel(0)
DisableIdleCamera(true)

VehicleColors = {
    ["0"] = "Metallic Black",
    ["1"] = "Metallic Graphite Black",
    ["2"] = "Metallic Black Steal",
    ["3"] = "Metallic Dark Silver",
    ["4"] = "Metallic Silver",
    ["5"] = "Metallic Blue Silver",
    ["6"] = "Metallic Steel Gray",
    ["7"] = "Metallic Shadow Silver",
    ["8"] = "Metallic Stone Silver",
    ["9"] = "Metallic Midnight Silver",
    ["10"] = "Metallic Gun Metal",
    ["11"] = "Metallic Anthracite Grey",
    ["12"] = "Matte Black",
    ["13"] = "Matte Gray",
    ["14"] = "Matte Light Grey",
    ["15"] = "Util Black",
    ["16"] = "Util Black Poly",
    ["17"] = "Util Dark silver",
    ["18"] = "Util Silver",
    ["19"] = "Util Gun Metal",
    ["20"] = "Util Shadow Silver",
    ["21"] = "Worn Black",
    ["22"] = "Worn Graphite",
    ["23"] = "Worn Silver Grey",
    ["24"] = "Worn Silver",
    ["25"] = "Worn Blue Silver",
    ["26"] = "Worn Shadow Silver",
    ["27"] = "Metallic Red",
    ["28"] = "Metallic Torino Red",
    ["29"] = "Metallic Formula Red",
    ["30"] = "Metallic Blaze Red",
    ["31"] = "Metallic Graceful Red",
    ["32"] = "Metallic Garnet Red",
    ["33"] = "Metallic Desert Red",
    ["34"] = "Metallic Cabernet Red",
    ["35"] = "Metallic Candy Red",
    ["36"] = "Metallic Sunrise Orange",
    ["37"] = "Metallic Classic Gold",
    ["38"] = "Metallic Orange",
    ["39"] = "Matte Red",
    ["40"] = "Matte Dark Red",
    ["41"] = "Matte Orange",
    ["42"] = "Matte Yellow",
    ["43"] = "Util Red",
    ["44"] = "Util Bright Red",
    ["45"] = "Util Garnet Red",
    ["46"] = "Worn Red",
    ["47"] = "Worn Golden Red",
    ["48"] = "Worn Dark Red",
    ["49"] = "Metallic Dark Green",
    ["50"] = "Metallic Racing Green",
    ["51"] = "Metallic Sea Green",
    ["52"] = "Metallic Olive Green",
    ["53"] = "Metallic Green",
    ["54"] = "Metallic Gasoline Blue Green",
    ["55"] = "Matte Lime Green",
    ["56"] = "Util Dark Green",
    ["57"] = "Util Green",
    ["58"] = "Worn Dark Green",
    ["59"] = "Worn Green",
    ["60"] = "Worn Sea Wash",
    ["61"] = "Metallic Midnight Blue",
    ["62"] = "Metallic Dark Blue",
    ["63"] = "Metallic Saxony Blue",
    ["64"] = "Metallic Blue",
    ["65"] = "Metallic Mariner Blue",
    ["66"] = "Metallic Harbor Blue",
    ["67"] = "Metallic Diamond Blue",
    ["68"] = "Metallic Surf Blue",
    ["69"] = "Metallic Nautical Blue",
    ["70"] = "Metallic Bright Blue",
    ["71"] = "Metallic Purple Blue",
    ["72"] = "Metallic Spinnaker Blue",
    ["73"] = "Metallic Ultra Blue",
    ["74"] = "Metallic Bright Blue",
    ["75"] = "Util Dark Blue",
    ["76"] = "Util Midnight Blue",
    ["77"] = "Util Blue",
    ["78"] = "Util Sea Foam Blue",
    ["79"] = "Uil Lightning blue",
    ["80"] = "Util Maui Blue Poly",
    ["81"] = "Util Bright Blue",
    ["82"] = "Matte Dark Blue",
    ["83"] = "Matte Blue",
    ["84"] = "Matte Midnight Blue",
    ["85"] = "Worn Dark blue",
    ["86"] = "Worn Blue",
    ["87"] = "Worn Light blue",
    ["88"] = "Metallic Taxi Yellow",
    ["89"] = "Metallic Race Yellow",
    ["90"] = "Metallic Bronze",
    ["91"] = "Metallic Yellow Bird",
    ["92"] = "Metallic Lime",
    ["93"] = "Metallic Champagne",
    ["94"] = "Metallic Pueblo Beige",
    ["95"] = "Metallic Dark Ivory",
    ["96"] = "Metallic Choco Brown",
    ["97"] = "Metallic Golden Brown",
    ["98"] = "Metallic Light Brown",
    ["99"] = "Metallic Straw Beige",
    ["100"] = "Metallic Moss Brown",
    ["101"] = "Metallic Biston Brown",
    ["102"] = "Metallic Beechwood",
    ["103"] = "Metallic Dark Beechwood",
    ["104"] = "Metallic Choco Orange",
    ["105"] = "Metallic Beach Sand",
    ["106"] = "Metallic Sun Bleeched Sand",
    ["107"] = "Metallic Cream",
    ["108"] = "Util Brown",
    ["109"] = "Util Medium Brown",
    ["110"] = "Util Light Brown",
    ["111"] = "Metallic White",
    ["112"] = "Metallic Frost White",
    ["113"] = "Worn Honey Beige",
    ["114"] = "Worn Brown",
    ["115"] = "Worn Dark Brown",
    ["116"] = "Worn straw beige",
    ["117"] = "Brushed Steel",
    ["118"] = "Brushed Black steel",
    ["119"] = "Brushed Aluminium",
    ["120"] = "Chrome",
    ["121"] = "Worn Off White",
    ["122"] = "Util Off White",
    ["123"] = "Worn Orange",
    ["124"] = "Worn Light Orange",
    ["125"] = "Metallic Securicor Green",
    ["126"] = "Worn Taxi Yellow",
    ["127"] = "police car blue",
    ["128"] = "Matte Green",
    ["129"] = "Matte Brown",
    ["130"] = "Worn Orange",
    ["131"] = "Matte White",
    ["132"] = "Worn White",
    ["133"] = "Worn Olive Army Green",
    ["134"] = "Pure White",
    ["135"] = "Hot Pink",
    ["136"] = "Salmon pink",
    ["137"] = "Metallic Vermillion Pink",
    ["138"] = "Orange",
    ["139"] = "Green",
    ["140"] = "Blue",
    ["141"] = "Mettalic Black Blue",
    ["142"] = "Metallic Black Purple",
    ["143"] = "Metallic Black Red",
    ["144"] = "hunter green",
    ["145"] = "Metallic Purple",
    ["146"] = "Metaillic V Dark Blue",
    ["147"] = "MODSHOP BLACK1",
    ["148"] = "Matte Purple",
    ["149"] = "Matte Dark Purple",
    ["150"] = "Metallic Lava Red",
    ["151"] = "Matte Forest Green",
    ["152"] = "Matte Olive Drab",
    ["153"] = "Matte Desert Brown",
    ["154"] = "Matte Desert Tan",
    ["155"] = "Matte Foilage Green",
    ["156"] = "DEFAULT ALLOY COLOR",
    ["157"] = "Epsilon Blue",
    ["158"] = "Shit Brown",
    ["159"] = "Shiny Shit Brown",
    ["160"] = "Puke Yellow",
    ["161"] = ""
}

--[[ local jail = AddZone({
    vector2(1852.2663574219, 2538.1638183594),
    vector2(1854.2080078125, 2712.4479980469),
    vector2(1770.1401367188, 2779.4138183594),
    vector2(1642.8624267578, 2767.5673828125),
    vector2(1559.4901123047, 2682.1215820313),
    vector2(1523.2789306641, 2584.3122558594),
    vector2(1531.7000732422, 2458.7214355469),
    vector2(1654.2928466797, 2384.9704589844),
    vector2(1768.5012207031, 2401.9147949219),
    vector2(1833.9830322266, 2469.1635742188)
  }, {
    name="jail",
    --minZ = 45.672134399414,
    --maxZ = 54.001998901367
}) ]]
  
local jail = {}
local impound = {}

AddBoxZone(vector3(1695.04, 2599.39, 45.56), 313.59999999999, 408.39999999998, {
    name="jail",
    heading=270,
    --debugPoly=true,
    minZ=43.36,
    maxZ=68.36
})

AddBoxZone(vector3(378.75, -1629.46, 28.5), 9.0, 9.4, {
    name="Impound",
    heading=320,
    --debugPoly=true,
    minZ=27.2,
    maxZ=31.2
})

AddEventHandler('enteringVehicle', function(veh)
    if not NetworkGetEntityIsNetworked(veh) then return end
    Wait(5000)

    if Entity(veh).ignoreCrime or Entity(veh).fake then
        return
    end

    if Shared.CurrentVehicle == veh then
        local prim, sec = GetVehicleColours(veh)
        TriggerServerEvent('Crime:StealVehicle', VehToNet(veh), Shared.GetLocation(), GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(veh))), VehicleColors[tostring(prim)])
    else
        TriggerServerEvent('Crime:AttemptStealVehicle', VehToNet(veh), Shared.GetLocation(), GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(veh))))
    end
end)

RegisterNetEvent('GetPlate')
AddEventHandler('GetPlate', function(def)
    local plate = PlateForString(def)
    TriggerServerEvent('GetPlate', plate)
end)

RegisterNetEvent('SendPlate')
AddEventHandler('SendPlate', function(veh, char, stolen, hasWarrant)
    TriggerEvent('Chat.Message', '[Police]', 'Plate: "'..veh.plate..'" is registered to a '..GetLabelText(GetDisplayNameFromVehicleModel(GetHashKey(veh.model)))..' owned by '..GetName(char)..' - P#: '..math.floor(char.phone_number).. (stolen == true and ' | Marked as ^1Stolen' or ''.. (hasWarrant and ' ^1 Warrant Flagged' or '')), 'job')
    if hasWarrant then
        TriggerEvent('Shared.PlaySounds','warrantalarm.mp3', 0.4)
    end
end)

RegisterNetEvent('Cuff:Origin')
AddEventHandler('Cuff:Origin', function()
    Wait(100)
    LoadAnim('mp_arrest_paired')
    TaskPlayAnim(PlayerPedId(), 'mp_arrest_paired', 'cop_p2_back_right', 8.0, -8, 4000, 16, 0, 0, 0, 0)
end)

RegisterNetEvent('Cuff:UncuffOrigin')
AddEventHandler('Cuff:UncuffOrigin', function()
    LoadAnim('mp_arrest_paired')
    TaskPlayAnim(PlayerPedId(), 'mp_arresting', 'a_uncuff', 8.0, -8, 2500, 16, 0, 0, 0, 0)
end)

local escaped = 0
local escapeTime = 0
RegisterNetEvent('Cuff:Target')
AddEventHandler('Cuff:Target', function(src, bool)
    local ped = PlayerPedId()
    local _mingame = false

    if src then
        CreateThread(function()
            if Shared.TimeSince(escapeTime) > 120000 then
                escapeTime = GetGameTimer()
                escaped = 0
            end

            if escaped < 4 then
                _mingame = Minigame(10, 1000)
                escaped = escaped + 1
            end
        end)
    end
    Wait(100)
    LoadAnim('mp_arrest_paired')
    if src then
        AttachEntityToEntity(ped, GetPlayerPed(GetPlayerFromServerId(src)), 11816, 0.0, 0.65, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    end
    TaskPlayAnim(ped, 'mp_arrest_paired', 'crook_p2_back_right', 8.0, -8, 4000, 16, 0, 0, 0, 0)
    if not _minigame then
        TriggerServerEvent('3DSound', PedToNet(PlayerPedId()), 'cuff.wav', 0.3, 10.0)
    end
    Wait(4000)
    DetachEntity(ped)
    if _mingame then 
        goto skipcuff 
    end
    Task.Run('Cuff', 1)
    SetEnableHandcuffs(ped, true)
    TriggerEvent('Holster:PauseFor', 1000)
    Wait(0)
    SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true)
    if MyCharacter.dead ~= 1 then
        TaskPlayAnim(ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
    end

    CreateThread(function()
        while MyCharacter.cuff == 1 do
            Wait(0)
            Shared.DisableWeapons()
        end
    end)

    while MyCharacter.cuff == 1 do
        Wait(0)
        if GetVehicleClass(Shared.CurrentVehicle) == 18 then
            DisableControlAction(0, 75, true)
        end

        if not IsEntityPlayingAnim(ped, 'mp_arresting', 'idle', 49) and MyCharacter.dead == 0 and RateLimit('AnimFix', 100) then
            Wait(100)
            LoadAnim('mp_arresting')
            TaskPlayAnim(ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
        end

        if bool then
            for i=30,35 do
                DisableControlAction(0, i, true)
            end
        end
    end
    Wait(2500)
    ::skipcuff::
    SetEnableHandcuffs(ped, false)
    StopAnimTask(ped, 'mp_arresting', 'idle', 1.0)
    Task.Run('Cuff', 0)
end)

Menu.CreateMenu('BreachList', 'Breach')
RegisterNetEvent('BreachList')
AddEventHandler('BreachList', function(list)
    Menu.OpenMenu('BreachList')
    while Menu.CurrentMenu do
        Wait(0)
        for k,v in pairs(list) do
            if Menu.Button(v.title) then
                TriggerServerEvent('BreachProperty', k)
                Menu.CloseMenu()
            end
        end
        Menu.Display()
    end
end)

RegisterNetEvent('Larry')
AddEventHandler('Larry', function(pos)
    local blip = AddBlipForCoord(pos)
    while DoesBlipExist(blip) do
        Wait(500)
        if Vdist3(pos, GetEntityCoords(Shared.Ped)) <= 20.0 then
            RemoveBlip(blip)
        end
    end
end)

RegisterNetEvent('Police.AddRaid')
AddEventHandler('Police.AddRaid', function(prop, val)
    raids[prop] = val
end)

RegisterNetEvent('Police.RaidList')
AddEventHandler('Police.RaidList', function(lst)
    raids = lst

    while MyCharacter and MyCharacter.Duty == 'Police' do
        Wait(0)

        local found = false
        for k,v in pairs(raids) do
            local vec = vec(table.unpack(v[3], 1, 3))
            if Vdist3(GetEntityCoords(Shared.Ped), vec) <= 3.0 then
                Shared.WorldText('[E] Raid', vec)
                if IsControlJustPressed(0, 38) then
                    TriggerServerEvent('Police.RaidLocation', k)
                    Wait(1000)
                    break
                end
            end
        end
    end
end)

local tempBlips = {}
local sprites = {
    ['10-13'] = {84},
    ['10-31'] = {84},
    ['10-39'] = {569},
    ['10-32'] = {442},
    ['10-70'] = {436, 49},
    ['10-71'] = {648, 49},
}

local blipData = {}
RegisterNetEvent('AddTempBlip')
AddEventHandler('AddTempBlip', function(blipType, position, data)
    local blip

    if not data then
        blip = AddBlipForCoord(position)
        SetBlipSprite(blip, sprites[blipType] and sprites[blipType][1] or 0)
        SetBlipFlashes(blip, true)
        SetBlipScale(blip, 1.5)

        if sprites[blipType][2] then
            SetBlipColour(blip, sprites[blipType][2])
        end
    else
        blip = AddBlipForRadius(position, data.range or 200.0)
        SetBlipAlpha(blip, 150)

        if data.color then
            SetBlipColour(blip, data.color)
        end
    end

   
    BeginTextCommandSetBlipName("STRING");
    AddTextComponentString(blipType)
    EndTextCommandSetBlipName(blip)
    local id = uuid()
    tempBlips[id] = blip
    blipData[id] = data
end)

CreateThread(function()
    while true do
        Wait(1000)
        for k,v in pairs(tempBlips) do
            if blipData[k] == nil or (blipData[k] and not blipData[k].noclear) then
                if Vdist3(GetEntityCoords(Shared.Ped), GetBlipCoords(v)) <= 50.0 then
                    RemoveBlip(v)
                    tempBlips[k] = nil
                end
            end
        end
    end
end)

RegisterCommand('clear', function()
    for k,v in pairs(tempBlips) do
        RemoveBlip(v)
        tempBlips[k] = nil
    end
end)

RegisterCommand('regser', function()
    if MyCharacter.Duty ~= 'Police' then return end
    local val = exports['geo-shared']:Dialogue({
        {placeholder = 'Serial Number', image = 'person', title = 'Register Weapon'},
        {placeholder = 'Citizen ID', image = 'person'}
    })

    if val[1] and val[2] then
        Task.Run('Weapon.Register', val[1], val[2])
    end
end)

local jailTime = 0
RegisterNetEvent('Police.Arrest')
AddEventHandler('Police.Arrest', function(time)
    jailTime = time
    Update('jail', 1)
    Warp(vector3(1789.93, 2585.9, 45.8), 90.0)
    while jailTime > 0 do
        TriggerEvent('Shared.Notif', jailTime..' month(s) remain', 5000)
        Wait(60000)
        jailTime = jailTime - 1
        TriggerServerEvent('Jail.Ping')
    end
    Update('jail', 0)
    TriggerEvent('Shared.Notif', "You're free to leave at any time, hope you enjoyed your stay, come again", 10000)
end)

AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'jail' then
        jail.inside = inZone
        if jailTime > 0 and not inZone then
            if Task.Run('Jailbreak') then
                jailTime = 0
            else
                Warp(vector3(1789.93, 2585.9, 45.8), 90.0)
            end
        end

        if inZone then
            while jail.inside do
                Wait(0)

                if Vdist3(GetEntityCoords(Shared.Ped), vector3(1837.81, 2590.5, 46.13)) <= 2.0 then
                    Shared.WorldText('[E] Reclaim Goods', vector3(1837.81, 2590.5, 46.13))
                    if IsControlJustPressed(0, 38) and MyCharacter.jail ~= 1 then
                        TriggerServerEvent('Jail.ReclaimGoods')
                        Wait(100)
                    end
                elseif Vdist3(GetEntityCoords(Shared.Ped), vector3(1835.29, 2583.67, 46.16)) <= 2.0 then
                    Shared.WorldText('[E] Leave Jail', vector3(1835.29, 2583.67, 46.16))
                    if IsControlJustPressed(0, 38) and MyCharacter.jail ~= 1 then
                        Warp(vector3(1847.25, 2585.65, 45.67), 270.0)
                    end
                else
                    Wait(100)
                end
            end
        end
    elseif zone == 'Impound' then
        impound.inside = inZone
        local obj = Shared.Interact('[E] Fetch From Impound', impound.inside)
        while impound.inside do
            Wait(0)
            if IsControlJustPressed(0, 38) then
                local vehicles = Task.Run('GetImpound')
                local impoundMenu = {}
                for k,v in pairs(vehicles) do
                    table.insert(impoundMenu, {
                        name = GetLabelText(GetDisplayNameFromVehicleModel(v.model)),

                        children = {
                            {name = v.plate},
                            {name = '$750'}
                        },

                        func = function()
                            Task.Run('PullImpound', v.plate)
                        end
                    })
                end

                if #impoundMenu > 0 then
                    exports['geo-interface']:OpenMenu(impoundMenu)
                else
                    TriggerEvent('Shared.Notif', 'No vehicles')
                end
            end
        end
        obj.stop()
    end
end)

local lastShot = 0
AddEventHandler('ShotFired', function()
    if Shared.TimeSince(lastShot) > 20000 then
        lastShot = GetGameTimer()
        TriggerServerEvent('GSR:Init')
    end
end)

RegisterCommand('gsr', function()
    if exports['geo-inventory']:HasItem('gsr') then
        local plyr = GetClosestPlayer(5.0)
        if not plyr then
            return
        end

        local finish = nil
        exports['geo-shared']:Progress('Administering GSR Test', 2500, function(res, term)
            terminate = term
            if res then
                finish = true
            end
        end)

        local ped = GetPlayerPed(plyr)
        while finish == nil do
            Wait(0)
            local pos = GetEntityCoords(ped)
            DrawMarker(27, pos.x, pos.y, pos.z - 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 200, 0, 0, 2, 0, nil, nil, 0, 500.0)
        end

        if finish then
            TriggerServerEvent('GSR:Check', GetPlayerServerId(plyr))
        end
    end
end)

RegisterCommand('breath', function()
    if exports['geo-inventory']:HasItem('breathalyzer') then
        local plyr = GetClosestPlayer(5.0)
        if not plyr then
            TriggerServerEvent('Breath:Check', GetPlayerServerId(PlayerId()))
            return
        end

        local finish = nil
        exports['geo-shared']:Progress('Administering Breath Test', 2500, function(res, term)
            terminate = term
            if res then
                finish = true
            end
        end)

        local ped = GetPlayerPed(plyr)
        while finish == nil do
            Wait(0)
            local pos = GetEntityCoords(ped)
            DrawMarker(27, pos.x, pos.y, pos.z - 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 200, 0, 0, 2, 0, nil, nil, 0, 500.0)
        end

        if finish then
            TriggerServerEvent('Breath:Check', GetPlayerServerId(plyr))
        end
    end
end)

RegisterCommand('runplate', function(source, args, raw)
    if #args == 0 then
        return
    end

    if args[1] then
        TriggerServerEvent('Police.Runplate', raw:sub(('/runplate '):len()))
    end
end)

RegisterCommand('+runplate', function(source, args, raw)
    if controlMod then
        local ent = Shared.EntityInFront(5.0)
        if ent then
            ExecuteCommand('runplate '..GetVehicleNumberPlateText(ent))
        end
    end
end)

RegisterCommand('-runplate', function() end)
RegisterKeyMapping('+runplate', '[Police] Run Plate ~g~+Modifier~w~', 'keyboard', 'NULL')

RegisterCommand('cuff', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    local plyr = GetClosestPlayer(5.0)
    if plyr then
        TriggerServerEvent('Cuff', GetPlayerServerId(plyr), GetEntityHeading(PlayerPedId()))
    end
end)

local frisking = false
RegisterCommand('frisk', function()
    local plyr = GetClosestPlayer(5.0)
    if plyr then
        TriggerServerEvent('Frisk', GetPlayerServerId(plyr))
    end
end)

local spikeModel = GetHashKey("p_stinger_04")
local spikeStrip1
local spikeStrip2
RegisterCommand('spikes', function()
    if MyCharacter.Duty == 'Police' then
        if spikeStrip1 == nil then

            if Shared.CurrentVehicle ~= 0 then
                return
            end

            local fail = false
            CreateThread(function()
                LoadAnim('anim@heists@money_grab@briefcase')
                TaskPlayAnim(Shared.Ped, 'anim@heists@money_grab@briefcase', 'put_down_case', 4.0, 4.0, 1400, 1, 1.0, 0, 0, 0)
                Wait(1200)
                if not fail then
                    TaskPlayAnim(Shared.Ped, 'anim@heists@money_grab@briefcase', 'loop', 4.0, 4.0, 2000, 1, 1.0, 0, 0, 0)
                end
            end)
           
            if not exports['geo-shared']:ProgressSync('Placing Spikes', 3200) then
                fail = true
                StopAnimTask(Shared.Ped, 'anim@heists@money_grab@briefcase', 'put_down_case', 1.0)
                StopAnimTask(Shared.Ped, 'anim@heists@money_grab@briefcase', 'loop', 1.0)
                return
            end

            StopAnimTask(Shared.Ped, 'anim@heists@money_grab@briefcase', 'loop', 1.0)
            local ped = PlayerPedId()
            RequestModel(spikeModel)
            while not HasModelLoaded(spikeModel) do
                Wait(0)
            end
            local spikeStripHeading = GetEntityHeading(ped)
            local spikeCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 4.0, -0.7)
            local spikeCoords2 = GetOffsetFromEntityInWorldCoords(ped, 0.0, 7.0, -0.7)
            spikeStrip1 = CreateObject( spikeModel, spikeCoords, true, true, true)
            spikeStrip2 = CreateObject( spikeModel, spikeCoords2, true, true, true)
            SetModelAsNoLongerNeeded(spikeModel)
            SetEntityHeading(spikeStrip1, spikeStripHeading)
            SetEntityHeading(spikeStrip2, spikeStripHeading)
            PlaceObjectOnGroundProperly(spikeStrip1)
            PlaceObjectOnGroundProperly(spikeStrip2)
            FreezeEntityPosition(spikeStrip1)
            Citizen.CreateThread(function()
                while spikeStrip1 ~= nil do
                    Wait(100)
                    for k,v in pairs( GetGamePool('CVehicle')) do
                        if not IsVehicleTyreBurst(v, 0) then
                            if IsEntityTouchingEntity(v, spikeStrip1) or IsEntityTouchingEntity(v, spikeStrip2) then
                                TriggerServerEvent('Vehicle.PopTires', VehToNet(v))
                                Wait(1000)
                            end
                        end 
                    end
                end
            end)

            Citizen.CreateThread(function()
                while spikeStrip1 ~= nil do
                    Wait(1000)
                    if not DoesEntityExist(spikeStrip1) or Vdist3(GetEntityCoords(Shared.Ped), GetEntityCoords(spikeStrip1)) >= 250.0 then
                        if DoesEntityExist(spikeStrip1) then
                            TriggerServerEvent('DeleteEntity', ObjToNet(spikeStrip1))
                            TriggerServerEvent('DeleteEntity', ObjToNet(spikeStrip2))
                        end
                        spikeStrip1 = nil
                        spikeStrip2 = nil
                    end
                end
            end)
        else
            if Vdist4(GetEntityCoords(Shared.Ped), GetEntityCoords(spikeStrip1)) <= 50.0 then
                LoadAnim('anim@heists@money_grab@briefcase')
                TaskPlayAnim(Shared.Ped, 'anim@heists@money_grab@briefcase', 'put_down_case', 4.0, 4.0, 1500, 1, 1.0, 0, 0, 0)
                if not exports['geo-shared']:ProgressSync('Grabbing Spikes', 1500) then
                    StopAnimTask(Shared.Ped, 'anim@heists@money_grab@briefcase', 'put_down_case', 1.0)
                    StopAnimTask(Shared.Ped, 'anim@heists@money_grab@briefcase', 'loop', 1.0)
                    return
                end

                TriggerServerEvent('DeleteEntity', ObjToNet(spikeStrip1))
                TriggerServerEvent('DeleteEntity', ObjToNet(spikeStrip2))
                spikeStrip1 = nil
                spikeStrip2 = nil
            end
        end
    end
end)

function ReportCrime(perc)
    local peds = GetGamePool('CPed')
    local ped = PlayerPedId()
    local pos = GetEntityCoords(PlayerPedId())
    for k,v in pairs(peds) do
        if not IsPedAPlayer(v) then
            if Vdist4(pos, GetEntityCoords(v)) <= 1000.0 then
                if HasEntityClearLosToEntityInFront(v, ped) then
                    local num = math.random(100)
                    if num < (perc or 25) then
                        return true
                    end
                end
            end
        end
    end
end

AddEventHandler('Police.ShowBadge', function()
    LoadAnim('paper_1_rcm_alt1-9')
    TaskPlayAnim(Shared.Ped, 'paper_1_rcm_alt1-9', 'player_one_dual-9', 2.0, 1.0, 3000, 51, 1.0, 0, 0, 0)
    local obj = Shared.SpawnObject('prop_fib_badge', GetOffsetFromEntityInWorldCoords(Shared.Ped,  0.0, 5.0, 0.0))
    AttachEntityToEntity(obj, Shared.Ped, GetPedBoneIndex(Shared.Ped, 0xDEAD), 0.06, -0.0, -0.03, 90.0, 0.0, 90.0, 1, 1, 1, 0, 1, 1)
    Wait(3000)
    TriggerServerEvent('DeleteEntity', ObjToNet(obj))
end)

RegisterNetEvent('Dispatch')
AddEventHandler('Dispatch', function(data)
    SendNUIMessage({
        type = 'dispatchcall',
        data = data,
        callsign = MyCharacter.callsign
    })
end)

RegisterKeyMapping('dispatchopen', '[Police] Open Dispatch', 'keyboard', 'NULL')
RegisterCommand('dispatchopen', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    if not IsPauseMenuActive() then
        UIFocus(true, true)
        SendNUIMessage({
            type = 'dispatchopen',
        })
    end
end)

RegisterKeyMapping('dispatlatestcall', '[Police] Toggle Latest Call  ~g~+Modifier~w~', 'keyboard', 'NULL')
RegisterCommand('dispatlatestcall', function()
    if controlMod then
        Task.Run('DispatchLatestCall')
    end
end)

RegisterNUICallback('MarkGPS', function(data, cb)
    local val = Task.Run('MarkGPS', data.call)
    SetNewWaypoint(val.x, val.y)
    cb(true)
end)

RegisterNUICallback('ToggleCall', function(data, cb)
    local val = Task.Run('ToggleCall', data.call)
    cb(true)
end)

RegisterNetEvent('UpdateCall')
AddEventHandler('UpdateCall', function(call, people)
    SendNUIMessage({
        type = 'updateDispatchCall',
        call = call,
        people = people
    })
end)

CreateThread(function()
    while true do
        Wait(500)
        DistantCopCarSirens(false)
    end
end)

AddBoxZone(vector3(445.46, -980.45, 30.69), 0.2, 1.2, {
    name="warrant_board",
    heading=271,
    --debugPoly=true,
    minZ=30.64,
    maxZ=32.44
},true)

AddEventHandler('PD.WarrantBoard', function()
    local warrants = Task.Run('GetWarrants')
    local reports = {}

    local menu = {}
    for k,v in pairs(warrants) do
        table.insert(menu, {
            title = v.name,
            description = 'Reference Report: '..v.parent_report,
            image = v.image
        })
    end

    if #warrants == 0 then
        if MyCharacter.id == 7 then
            table.insert(menu, {
                description =  "You keep checking this like there are any other cops who log in, please stop.",
            })
        else
            table.insert(menu, {
                description =  "There's currently no warrants, please write some more.",
            })
        end
    end

    RunMenu(menu)
end)

AddEventHandler('Coroner', function(entity)
    local myPos = GetEntityCoords(Shared.Ped)
    local offset = GetOffsetFromEntityInWorldCoords(Shared.Ped, 100.0, 100.0, 0.0)
    local found, pos, heading = GetNthClosestVehicleNodeFavourDirection(offset.x, offset.y, offset.z, myPos.x, myPos.y, myPos.z, 0, 1, 0x40400000, 0)

    if found then
        local working = true

        TriggerEvent('PhoneNotif', 'echat', 'Ambulance Dispatched')
        LoadAnim('random@arrests')
        TaskPlayAnim(Shared.Ped, "random@arrests", "idle_c", 8.0, 1.0, 3000, 49, 0, 0, 0, 0)

        local veh = Shared.SpawnVehicle('ambulance', vec(pos.x, pos.y, pos.z, heading))
        local ped = Shared.SpawnPed('s_m_m_paramedic_01', vec(pos.x, pos.y, pos.z, heading))

        CreateThread(function()
            while working do
                if IsEntityDead(ped) and DoesEntityExist(ped) then
                    TriggerServerEvent('EMSDown', Shared.GetLocation(GetEntityCoords(ped)))
                    break
                end

                Wait(1000)
            end
        end)

        SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(veh), false)
        SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(ped), false)

        SetPedIntoVehicle(ped, veh, -1)
        TaskSetBlockingOfNonTemporaryEvents(ped, true)
		SetPedCombatAttributes(ped, 46, false)
        SetPedKeepTask(ped, true)
        Wait(1000)
        TriggerServerEvent('Ped.Control', PedToNet(ped), true)
        TaskVehicleDriveToCoordLongrange(ped, veh, myPos.x, myPos.y, myPos.z, 15.0, 1074528293, 2.0)

        Wait(1000)
        while Vdist3(GetEntityCoords(veh), myPos) >= 50.0 do
            Wait(500)
        end

        Shared.GetEntityControl(ped)
        Shared.GetEntityControl(veh)
        TaskLeaveVehicle(ped, veh)
        Wait(1500)
        TaskGoToEntity(ped, entity, -1, 1.0, 10.0, 1073741824.0, 0)
        
        while Vdist3(GetEntityCoords(ped), GetEntityCoords(entity)) >= 1.5 do
            TaskGoToEntity(ped, entity, -1, 1.0, 1.0, 1073741824.0, 0)
            Wait(1000)
        end

        Shared.GetEntityControl(ped)
        Shared.GetEntityControl(veh)
        TaskTurnPedToFaceEntity(ped, entity, 2000)
        Wait(2000)

        Shared.GetEntityControl(ped)
        Shared.GetEntityControl(veh)
        TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)
        Wait(5000)

        Shared.GetEntityControl(ped)
        Shared.GetEntityControl(veh)
        AttachEntityToEntity(entity, ped, 11816, 0.25, 0.7, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 1, 1, 1)

        Wait(500)
        LoadAnim('dead')
        TaskPlayAnim(entity, 'dead', 'dead_a', 8.0, -8, -1, 1, 0, 0, 0, 0)
        SetPedKeepTask(entity, true)

        local min, max = GetModelDimensions(GetEntityModel(veh))
        local offset = GetOffsetFromEntityInWorldCoords(veh, 0.0, min.y, 0.0)
        TaskGoToCoordAnyMeans(ped, offset, 1.30, 0, 0, 786603, 1.0)
        while Vdist3(GetEntityCoords(ped), offset) >= 2.0 do
            Wait(500)
        end

        Shared.GetEntityControl(ped)
        Shared.GetEntityControl(veh)
        TaskTurnPedToFaceEntity(ped, veh, 2000)
        Wait(2000)

        Shared.GetEntityControl(ped)
        Shared.GetEntityControl(veh)
        DetachEntity(entity)
        SetPedIntoVehicle(entity, veh, 1)

        TaskEnterVehicle(ped, veh, -1, -1, 1.0, 1, 0)
        while GetVehiclePedIsIn(ped) ~= veh do
            Wait(500)
        end

        Shared.GetEntityControl(ped)
        Shared.GetEntityControl(veh)
        TaskVehicleDriveWander(ped, veh, 15.0, 427)
        SetEntityAsNoLongerNeeded(ped)
        SetEntityAsNoLongerNeeded(veh)
        TriggerServerEvent('Evidence.Analyze', NetworkGetNetworkIdFromEntity(entity))
        working = false
    end
end)

AddEventHandler('PeopleEvidence', function()
    local data = Task.Run('PeopleEvidence')
    local menu = {}

    if data then
       for k,v in pairs(data) do
           table.insert(menu, {title = v.first..' '..v.last, event = 'PeopleEvidence.Show', params = {v.evidence}})
       end
    else
        menu = {
            {description = "You have no patient data available"},
        } 
    end

    RunMenu(menu)
end)

AddEventHandler('PeopleEvidence.Show', function(evidence)
    for k,v in pairs(evidence) do
        TriggerEvent('Shared.Notif', v.hash..' ' ..v.Serial, 5000)
    end
end)