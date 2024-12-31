local dutyLocations = {
    vector3(454.4, -990.68, 30.69),
    vector3(-1113.33, -849.21, 13.45),
    vector3(371.06, -1608.94, 29.29),
    vector3(847.02, -1316.05, 26.45),
    vector3(535.02, -22.46, 70.63),
    vector3(1842.83, 3679.2, 34.19),
    vector3(-446.6, 6010.26, 31.72),
    vector3(-379.65, 6118.52, 31.85),
    vector3(1695.56, 3594.53, 35.62),
    vector3(-633.1, -122.04, 39.01),
    vector3(198.71, -1647.07, 29.8),
    vector3(208.43, -427.74, 48.08),
    vector3(300.72, -597.67, 43.28)
}

local policeStations = {
    vector3(454.4, -990.68, 30.69),
    vector3(-1113.33, -849.21, 13.45),
    vector3(371.06, -1608.94, 29.29),
    vector3(847.02, -1316.05, 26.45),
    vector3(535.02, -22.46, 70.63),
    vector3(1856.08, 3687.1, 34.27),
    vector3(-446.6, 6010.26, 31.72)
}

RequestIpl("gabz_pillbox_milo_")
interiorID = GetInteriorAtCoords(311.2546, -592.4204, 42.32737)
	if IsValidInterior(interiorID) then
		RemoveIpl("rc12b_fixed")
		RemoveIpl("rc12b_destroyed")
		RemoveIpl("rc12b_default")
		RemoveIpl("rc12b_hospitalinterior_lod")
		RemoveIpl("rc12b_hospitalinterior")
		RefreshInterior(interiorID)
	end

local garages = {
    {
        vec(446.421, -1025.874, 27.639, 0.0),
        vec(442.736, -1026.28, 27.701, 0.0),
        vec(439.051, -1026.685, 27.764, 0.0),
        vec(435.366, -1027.09, 27.826, 0.0),
        vec(431.681, -1027.496, 27.889, 0.0),
        vec(427.996, -1027.901, 27.951, 0.0),
    },
    vector3(1871.71, 3688.25, 33.66 -0.95),
    vector3(-469.21, 6039.14, 31.34-0.95),
    vector3(-359.67, 6099.41, 31.4 - 0.95),
    vector3(1694.49, 3604.59, 35.46-0.95),
    vector3(-640.37, -105.43, 38.01-0.95),
    vector3(217.39, -1639.58, 29.54-0.95),
    vector3(1185.8, -1503.6, 34.69 - 0.95),
    vector3(850.96, -1356.66, 26.09 - 0.95),
    vector3(365.92, -594.96, 28.69 - 0.95)
}

local _inDuty = false
Citizen.CreateThread(function()
    local dep = {}
    for k,v in pairs(Departments) do
        for key,va in pairs(v) do
            table.insert(dep, key)
        end
    end

    for k,v in pairs(policeStations) do
        local blip = AddBlipForCoord(v)
        SetBlipSprite(blip, 60)
        SetBlipColour(blip, 3)
		SetBlipAsShortRange(blip, true)
		SetBlipScale(blip, 0.8)
		BeginTextCommandSetBlipName("STRING");
		AddTextComponentString('Police Department')
		EndTextCommandSetBlipName(blip)
    end

    for k,v in pairs(dutyLocations) do
        AddCircleZone(v, 3.5, {
            name="DutyLocation",
            useZ = true
        })
    end

--[[     RegisterProximityMenu('DutyMenu', {Name = 'Duty', pos = dutyLocations, func = DutyMenu, range = 50.0, Groups = dep})
 ]]    NetworkSetFriendlyFireOption(true)

    SetScenarioTypeEnabled('WORLD_VEHICLE_POLICECAR', false)
    SetScenarioTypeEnabled('WORLD_VEHICLE_POLICECAR', false)
end)

RegisterCommand('rv', function()
    if IsES(MyCharacter.id) or MyCharacter.username then
        local veh = Shared.EntityInFront(5.0)
        if veh == 0 then
            return
        end

        if not MyCharacter.username then
            if not exports['geo-shared']:ProgressSync('Removing Vehicle', 10000) then
                return
            end
        end

        if Shared.EntityInFront(5.0) == veh then
            if NetworkGetEntityIsNetworked(veh) then
                TriggerServerEvent('DeleteEntity', VehToNet(veh))
            else
                DeleteEntity(veh)
            end
        end
    end
end)

RegisterNetEvent('ES:Fix')
AddEventHandler('ES:Fix', function(netID, bool)
    if NetworkDoesNetworkIdExist(netID) then
        local veh = NetToVeh(netID)
        if NetworkHasControlOfEntity(veh) then
            local val = 300.0

            if bool then val = 600 end
            if MyCharacter.job == 'Mechanic' then
                val = val + 150.0
            end

            if GetVehicleEngineHealth(veh) < val then
                SetVehicleEngineHealth(veh, val)
            end
            for i=0,47 do
                SetVehicleTyreFixed(veh, i)
            end
        end
    end
end)

RegisterNetEvent('DeleteEntity')
AddEventHandler('DeleteEntity', function(netID)
    if NetworkDoesNetworkIdExist(netID) then
        local veh = NetToEnt(netID)
        if NetworkHasControlOfEntity(veh) then
            SetEntityAsMissionEntity(veh, true)
            DeleteEntity(veh)
        end
    end
end)

local DutyList = {['Police'] = {}, ['EMS'] = {}, ['DOJ'] = {}}
RegisterNetEvent('GetDutyList')
AddEventHandler('GetDutyList', function(lst)
    DutyList = lst
end)


local zoneNotif = 0
AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'DutyLocation' then

        if not IsES(MyCharacter.id) then
            return
        end

        _inDuty = inZone
        if inZone then
            zoneNotif = exports['geo-shared']:Interact('[E] Duty')
        else
            exports['geo-shared']:CloseInteract(zoneNotif)
        end
    end
end)

AddEventHandler('Interact', function()
    if _inDuty then
        DutyMenu()
    end
end)

AddEventHandler('Police.Clothing', function()
    exports['geo']:ClothingMenu()
end)

function DutyMenu()

    local job
    if MyCharacter.Duty == "Police" then
        job = IsPolice(MyCharacter.id)
    elseif MyCharacter.Duty == 'EMS'then
        job = IsEMS(MyCharacter.id)
    end

    local isOwner = nil
    local dutyOutfits = nil
    if job then 
        isOwner = exports['geo-guilds']:GuildOwner(job) == MyCharacter.id
        dutyOutfits = Task.Run('Duty.Outfits', job)
    end

    local _dutyMenu = {
        {title = 'Duty Types', submenu = {
            {title = 'Police', hidden = not (MyCharacter.Duty == nil and exports['geo-es']:IsPolice(MyCharacter.id)), serverevent = 'Duty', params = {'Police'}, image = 'https://cdn.discordapp.com/attachments/870797116883234857/895841462019842118/unknown.png'},
            {title = 'EMS', hidden = not (MyCharacter.Duty == nil and exports['geo-es']:IsEMS(MyCharacter.id)), serverevent = 'Duty', params = {'EMS'}},
            {title = 'DOJ', hidden = not (MyCharacter.Duty == nil and exports['geo-es']:IsDOJ(MyCharacter.id)), serverevent = 'Duty', params = {'DOJ'}},
            {title = 'Off Duty', hidden = not (MyCharacter.Duty ~= nil), serverevent = 'Duty', params = {'Police'}},
        }},
        {title = 'Clothing', hidden = not IsNearLocation(dutyLocations, GetEntityCoords(Shared.Ped), 25.0), event = 'Police.Clothing', params = {}},
        {title = 'Clothing Presets', hidden = not (IsNearLocation(dutyLocations, GetEntityCoords(Shared.Ped), 25.0) and MyCharacter.Duty ~= nil), event = 'Police.Clothing', params = {}, submenu = {
            {title = 'Create Outfit', description = 'Creates an Outfit of what you are currently wearing', hidden = not isOwner, event = 'Duty.NewOutfit', params = {job}},
        }},
        {title = 'Locker', hidden = not IsNearLocation(dutyLocations, GetEntityCoords(Shared.Ped), 25.0), serverevent = 'Locker', params = {}},
        {title = 'Duty History', hidden = not isOwner, event = 'Duty.History', params = {job}},
    }

    if dutyOutfits then
        for k,v in pairs(dutyOutfits) do

            table.insert(_dutyMenu[3].submenu, {
                title = json.decode(v.clothing).Name, params = {v.clothing}, event = not isOwner and 'Duty.Clothes' or nil, submenu = isOwner and {
                    {title = 'Change Clothes', params = {v.clothing}, event = 'Duty.Clothes' },
                    {title = 'Delete Outfit', serverevent = 'Duty.DeleteOutfit', params = {v.outfit}},
                } or nil
            })
        end
    end

    local currentDuty = 1
    local dutyTypes = {}
    if IsPolice(MyCharacter.id) then
        table.insert(dutyTypes, 'Police')
    end

    if IsEMS(MyCharacter.id) then
        table.insert(dutyTypes, 'EMS')
    end

    if IsDOJ(MyCharacter.id) then
        table.insert(dutyTypes, 'DOJ')
    end

    if #dutyTypes == 0 then
        return
    end

    RunMenu(_dutyMenu)
end


AddEventHandler('Duty.NewOutfit', function(job)
    local val = exports['geo-shared']:Dialogue({
        {
            placeholder = 'Name',
            title = 'Duty Outfit Name',
            image = 'person'
        },
    })

    if val[1] then
        Task.Run('Duty.ClothingSave', GetClothing(val[1]))
    end
end)

AddEventHandler('Duty.History', function(job)
    local val = exports['geo-shared']:Dialogue({
        {
            placeholder = 'Time in days',
            title = 'Duty Hour History',
            image = 'person',
        },
    })

    if val[1] then
        local val = Task.Run('Duty.History', job, tonumber(val[1]))
        if val then
            local menu = {}
            local date

            for k,v in pairs(val) do
                date = v[3]
                table.insert(menu, {
                    title = v[2],
                    description = v[4],
                    sub = v[1]
                })
            end

            table.insert(menu, {
                description = 'Duty Times Since: '..date
            })

            RunMenu(menu)
        end
    end
end)

AddEventHandler('Duty.Clothes', function(clothing)
    clothing = json.decode(clothing)

    for i=0,11 do
        if i ~= 2 then
            SetPedComponentVariation(Shared.Ped, i, clothing.Clothing.Drawable[tostring(i)], clothing.Clothing.Texture[tostring(i)], 1)
        end
    end

    for i=0,3 do
        SetPedPropIndex(Shared.Ped, i, clothing.Props.Drawable[tostring(i)], clothing.Props.Texture[tostring(i)], 1)
    end

    if MyCharacter then
        local cl = json.decode(MyCharacter.clothing)
        TriggerServerEvent('Clothing:SaveData', json.encode(GetClothing(cl.Name)))
    end
end)

RegisterCommand('duty', function()
    DutyMenu()
end)

RegisterCommand('drag', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    TriggerServerEvent('Drag', GetPlayerServerId(GetClosestPlayer(5.0)))
end)

RegisterKeyMapping('drag', '[General] Drag', 'keyboard', 'NULL')

RegisterCommand('search', function()
    TriggerServerEvent('Search', GetPlayerServerId(GetClosestPlayer(5.0)))
end)

RegisterCommand('putincar', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    if MyCharacter.Dragging then
        local veh = Shared.EntityInFront(5.0)
        if veh ~= 0 then
            for i =GetVehicleMaxNumberOfPassengers(veh), 0, -1 do
                if IsVehicleSeatFree(veh, i) then
                    TriggerServerEvent('PutInCar', VehToNet(veh), i)
                    break
                end
            end
        end
    end
end)

RegisterCommand('pullout', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    local veh = Shared.EntityInFront(5.0)
    local player = GetClosestPlayer(5.0)
    if veh ~= 0 and player then
        TriggerServerEvent('Pullout', VehToNet(veh), GetPlayerServerId(player), GetVehicleClass(veh))
    end
end)

RegisterKeyMapping('putincar', '[General] Place In Vehicle', 'keyboard', 'NULL')
RegisterKeyMapping('pullout', '[General] Pull From Vehicle', 'keyboard', 'NULL')


RegisterNetEvent('Pullout')
AddEventHandler('Pullout', function(veh)
    if NetworkDoesNetworkIdExist(veh) then
        veh = NetToVeh(veh)
        local ped = PlayerPedId()
        if GetVehiclePedIsIn(ped, false) == veh then
            TaskLeaveVehicle(ped, veh, 0)
        end
    end
end)

local beingDragged = false
RegisterNetEvent('Drag')
AddEventHandler('Drag', function(dragger)
    dragger = GetPlayerFromServerId(dragger)
    local this = GetPlayerPed(dragger)
    if GetVehiclePedIsIn(PlayerPedId(), false) ~= 0 then
        SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(this, 0.25, 0.5, 0.0))
    end
    AttachEntityToEntity(PlayerPedId(), this, 11816, 0.25, 0.7, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 1, 1, 1)
    beingDragged = true
    Citizen.CreateThread(function()
        while beingDragged do
            Wait(0)
            DisableControlAction(0, 23)
            DisableControlAction(0, 24)
            DisableControlAction(0, 25)
            DisableControlAction(0, 37)
            DisableControlAction(0, 311)

            --[[ if MyCharacter.dead == 1 then
                Wait(100)
                if Shared.CurrentVehicle == 0 then
                    if not IsEntityPlayingAnim(PlayerPedId(), 'dead', 'dead_a', 1) then
                        LoadAnim('dead')
                        TaskPlayAnim(PlayerPedId(), "dead", 'dead_a', 9999.0, 9999.0, -1, 1, 1.0, 1, 0, 0, 0)
                    end
                end
            end ]]
        end
    end)
end)

RegisterNetEvent('PutInCar')
AddEventHandler('PutInCar', function(veh, seat)
    veh = NetToVeh(veh)
    SetPedIntoVehicle(PlayerPedId(), veh, seat)
end)

RegisterNetEvent('StopDrag')
AddEventHandler('StopDrag', function(dragger)
    SetEntityCollision(PlayerPedId(), true, true)
    DetachEntity(PlayerPedId())
    beingDragged = false
end)

RegisterNetEvent('Chat.Message.ES')
AddEventHandler('Chat.Message.ES', function(...)
    if IsOnDuty(MyCharacter) then
        TriggerEvent('Chat.Message', ...)
    end
end)

RegisterNetEvent('Chat.Message.Police')
AddEventHandler('Chat.Message.Police', function(...)
    if IsOnDuty(MyCharacter) and MyCharacter.Duty == 'Police' then
        TriggerEvent('Chat.Message', ...)
    end
end)

exports('NearGarage', function()
    local pos = GetEntityCoords(Shared.Ped)
    for k,v in pairs(garages) do
        if type(v) == 'table' then
            for key,val in pairs(v) do
                if Vdist3(pos, val.xyz) <= 5.0 then
                    return true
                end
            end
        else
            if Vdist3(pos, v.xyz) <= 5.0 then
                return true
            end
        end
    end
end)

RegisterNetEvent('DutyState')
AddEventHandler('DutyState', function(t, bool)
    if bool then
        if t == 'Police' then
            local str = IsPolice(MyCharacter.id)
            if str then
                --RegisterProximityMenu('DutyGarage', {Name = 'Retrieve Vehicle', pos = garages, Event = 'Duty:Garage', range = 50.0})
                --RegisterProximityMenu('DutyFix', {Name = '[Duty] Fix Vehicle', pos = garages, Event = 'Duty:Fix', range = 50.0})
            end
        elseif t == 'EMS' then
            local str = IsEMS(MyCharacter.id)
            if str then
                --RegisterProximityMenu('DutyGarage', {Name = 'Retrieve Vehicle', pos = garages, Event = 'Duty:Garage', range = 50.0})
                --RegisterProximityMenu('DutyFix', {Name = '[Duty] Fix Vehicle', pos = garages, Event = 'Duty:Fix', range = 50.0})
            end
        end

        SendNUIMessage({
            type = 'mdt.register'
        })
    else
        RegisterProximityMenu('DutyGarage', nil)
        RegisterProximityMenu('DutyFix', nil)
    end

    Citizen.CreateThread(function()
        Wait(100)
        while MyCharacter and MyCharacter.Duty ~= nil do
            Wait(0)
            local found = false
            local pos = GetEntityCoords(PlayerPedId())
            for k,v in pairs(garages) do
                if type(v) ~= 'table' then
                    if Vdist3(pos, v.xyz) <= 100 then
                        found = true
                        DrawMarker(27, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 5.0, 0, 0, 255, 50, 0, 0, 2, 0, nil, nil, 0, 500.0)
                    end
                end
            end

            if not found then
                Wait(1000)
            end
        end
    end)
end)

local Blips = {}
local _blips = {}
RegisterNetEvent('Duty.Blips')
AddEventHandler('Duty.Blips', function(blips)
    Blips = blips

    for k,v in pairs(Blips) do
        if not DoesBlipExist(_blips[v.sid]) then
            ESBlip(v)
        else
            local player = GetPlayerFromServerId(v.sid)
            if player ~= -1 then
                if GetBlipFromEntity(GetPlayerPed(player)) ~= _blips[v.sid] then
                    RemoveBlip(_blips[v.sid])
                    ESBlip(v)
                end
            else
                SetBlipCoords(_blips[v.sid], v.pos)
            end
        end
    end

    for k,v in pairs(_blips) do
        if Blips[k] == nil then
            if DoesBlipExist(v) then
                RemoveBlip(v)
            end
            _blips[k] = nil
        end
    end
end)

function ESBlip(v)
    local player = GetPlayerFromServerId(v.sid)
    if player == -1 then
        _blips[v.sid] = AddBlipForCoord(v.pos)
    else
        _blips[v.sid] = AddBlipForEntity(GetPlayerPed(player))
        SetBlipShowCone(_blips[v.sid], true)
    end

    if v.duty == 'Police' then
        SetBlipColour(_blips[v.sid], 3)
        BeginTextCommandSetBlipName("STRING");
        AddTextComponentString(v.callsign)
        EndTextCommandSetBlipName(_blips[v.sid])
    else
        SetBlipColour(_blips[v.sid], 1)
        BeginTextCommandSetBlipName("STRING");
        AddTextComponentString(v.callsign)
        EndTextCommandSetBlipName(_blips[v.sid])
    end

    SetBlipAsShortRange(_blips[v.sid], true)
    SetBlipScale(_blips[v.sid], 1.25)
    SetBlipCategory(_blips[v.sid], 7)
    ShowFriendIndicatorOnBlip(_blips[v.sid], true)
    ShowHeadingIndicatorOnBlip(_blips[v.sid], true)
    ShowHeightOnBlip(_blips[v.sid], true)
end

RegisterNetEvent('Police.ClearBlips')
AddEventHandler('Police.ClearBlips', function()
    for k,v in pairs(_blips) do
        if DoesBlipExist(v) then
            RemoveBlip(v)
        end
        _blips[k] = nil
    end
end)

AddEventHandler('Duty:Garage', function()
    local closestGarage
    local closest = 10000
    local pos = GetEntityCoords(PlayerPedId())
    for k,v in pairs(garages) do

        if type(v) == 'table' then
            for key,val in pairs(v) do
                if Vdist3(pos, val.xyz) <= closest then
                    closestGarage = val
                    closest = Vdist3(pos, val.xyz)
                end
            end
        else
            if Vdist3(pos, v.xyz) <= closest then
                closestGarage = v
                closest = Vdist3(pos, v.xyz)
            end
        end
    end


    if MyCharacter.Duty == 'Police' then
        local str = IsPolice(MyCharacter.id)
        if str then
            TriggerEvent('Garage:Valet', 'Guild:'..str, { 
                Name = str,
                Position = closestGarage,
                SpawnPosition = {
                closestGarage,
            }})
        end
    elseif MyCharacter.Duty == 'EMS' then
        local str = IsEMS(MyCharacter.id)
        if str then
            TriggerEvent('Garage:Valet', 'Guild:'..str, { 
                Name = str,
                Position = closestGarage,
                SpawnPosition = {
                closestGarage,
            }})        
        end
    end
end)

AddEventHandler('Duty:Fix', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh ~= 0 then
        TriggerServerEvent('Fix', VehToNet(veh))
    end
end)

RegisterNetEvent('Fix')
AddEventHandler('Fix', function(netID)
    if NetworkDoesNetworkIdExist(netID) then
        local veh = NetToVeh(netID)
        if NetworkHasControlOfEntity(veh) then
            SetVehicleEngineHealth(veh, 1000.0)
            SetVehicleBodyHealth(veh, 1000.0)
            SetVehicleFixed(veh)
            SetVehicleDirtLevel(veh, 0.0)
        end
    end
end)

RegisterCommand('+handsup', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    handsUp = true
    TriggerServerEvent('Handsup', true)
    CreateThread(function()
        local ped = PlayerPedId()
        LoadAnim('missfra1mcs_2_crew_react')
        TaskPlayAnim(PlayerPedId(), 'missfra1mcs_2_crew_react', 'handsup_standing_base', 1.0, 1.0, -1, 50, 1.0, 0, 0, 0)
    
        while handsUp do
            if not IsEntityPlayingAnim(ped, 'missfra1mcs_2_crew_react', 'handsup_standing_base', 1) then
                TaskPlayAnim(PlayerPedId(), 'missfra1mcs_2_crew_react', 'handsup_standing_base', 1.0, 1.0, -1, 50, 1.0, 0, 0, 0)
            end
            Wait(100)
        end
    end)
end)
RegisterCommand('-handsup', function()
    handsUp = false
    TriggerServerEvent('Handsup', false)
    StopAnimTask(PlayerPedId(), 'missfra1mcs_2_crew_react', 'handsup_standing_base', 2.0)
end)

RegisterKeyMapping('+handsup', '[Emote] Hands Up', 'keyboard', 'Z')

RegisterNetEvent('Panic')
AddEventHandler('Panic', function()
    TriggerServerEvent('3DSound', PedToNet(PlayerPedId()), 'alert.wav', 0.3, 10.0)
    Wait(1000)
    TriggerServerEvent('3DSound', PedToNet(PlayerPedId()), 'alert.wav', 0.3, 10.0)
    Wait(1000)
    TriggerServerEvent('3DSound', PedToNet(PlayerPedId()), 'alert.wav', 0.3, 10.0)
end)

AddBoxZone(vector3(331.93, -597.18, 43.28), 0.15, 0.1, {
    name="elevator_pillbox",
    heading=338,
    --debugPoly=true,
    minZ=43.48,
    maxZ=43.78,
    elevator = true
}, true)

AddBoxZone(vector3(355.14, -596.07, 28.78), 2.2, 1.0, {
    name="elevator_lowerpillbox",
    heading=340,
    --debugPoly=true,
    minZ=27.58,
    maxZ=29.98,
    elevator = true
}, true)

AddEventHandler('Elevator', function(data)
    if data.name == 'elevator_pillbox' then
        local menu = {
            {title = 'First Floor', event = 'Elevator.Use', params = {vector4(356.26, -598.01, 28.78, 259.15)}},
            {title = 'Second Floor', event = 'Elevator.Use',  disabled  = true, params = {vector4(331.75, -595.54, 43.28, 70.03)}},
        }
    
        RunMenu(menu)
    elseif data.name == 'elevator_lowerpillbox' then
        local menu = {
            {title = 'First Floor', disabled = true, event = 'Elevator.Use', params = {vector4(356.26, -598.01, 28.78, 259.15)}},
            {title = 'Second Floor', event = 'Elevator.Use', params = {vector4(331.75, -595.54, 43.28, 70.03)}},
        }
    
        RunMenu(menu)
    end
end)

AddEventHandler('Elevator.Use', function(loc)
    if exports['geo-shared']:ProgressSync('*Elevator Music*', 7500) then
        Warp(vec(loc.x, loc.y, loc.z), loc.w)
    end
end)