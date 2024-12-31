local postalLocations = {
    vector3(-258.96, -841.86, 31.42),
    vector3(132.96, 95.9, 83.51)
}

local vehSpawn = {
    vector4(-269.13, -844.49, 31.46, 71.67),
    vector4(114.86, 99.72, 80.84, 97.14)
}

local vehData = '{"1":-1,"2":-1,"3":-1,"4":-1,"5":-1,"6":-1,"7":-1,"8":-1,"9":-1,"10":-1,"11":-1,"12":-1,"13":-1,"14":-1,"15":-1,"16":-1,"17":-1,"18":-1,"19":-1,"20":-1,"21":-1,"22":-1,"23":-1,"24":-1,"25":-1,"26":-1,"27":-1,"28":-1,"29":-1,"30":-1,"31":-1,"32":-1,"33":-1,"34":-1,"35":-1,"36":-1,"37":-1,"38":-1,"39":-1,"40":-1,"41":-1,"42":-1,"43":-1,"44":-1,"45":-1,"46":-1,"47":-1,"48":-1,"49":-1,"0":-1,"plateType":3,"livery":1,"wheelColor":156,"plate":"64KHT806","wheeltype":1,"paint2":121,"xenon":false,"tint":-1,"paint":121,"extras":[1,1],"turbo":false,"bodyhealth":1000.0,"pearl":121,"enginehealth":1000.0}'

local pay = 0
local job = false
local currentJob = {}
local jobVehicle = 0
local jobVehiclePlate = ''
local holdingBox = false
local blip = nil
local myRank

local inside = false
AddCircleZone(vector3(-259.45, -844.37, 31.41), 50.0, {
    name="gopostaldepot",
    useZ=false,
    position = vector4(-257.9, -843.79, 31.43, 121.02)
    --debugPoly=true
})

AddCircleZone(vector3(135.16, 93.88, 83.51), 50.0, {
    name="gopostaldepot",
    useZ=false,
    position = vector4(132.96, 96.3, 83.51, 163.91)
    --debugPoly=true
})

local inside = false
AddEventHandler('Poly.Zone', function(zone, inZone, data)
    if zone == 'gopostaldepot' then
        inside = inZone
        if inside then
            local ped = exports['geo-interface']:InterfacePed({
                model = 's_m_m_postal_01',
                position = data.position,
                title = 'GoPostal',
                event = GoPostalMenu
            })

            while inside do
                Wait(500)
            end

            exports['geo-interface']:RemovePed(ped)
        end
    end
end)

Citizen.CreateThread(function()
    Menu.CreateMenu('GoPostal', 'GoPostal')
    Menu.Menus['GoPostal'].TitleColor = {0, 0, 255, 255}

    for k,v in pairs(postalLocations) do
        local blip = AddBlipForCoord(v)
        SetBlipSprite(blip, 440)
        SetBlipColour(blip, 67)
		SetBlipAsShortRange(blip, true)
		SetBlipScale(blip, 0.8)
		BeginTextCommandSetBlipName("STRING");
		AddTextComponentString('GoPostal')
		EndTextCommandSetBlipName(blip)
    end
end)

AddEventHandler('Use:box', function(key, val)
    holdingBox = not holdingBox

    if holdingBox then
        local ped = PlayerPedId()
        RequestAnimDict("anim@heists@box_carry@")
        while not HasAnimDictLoaded("anim@heists@box_carry@") do
            Wait(0)
        end
        local currentBox = Shared.SpawnObject('hei_prop_heist_box', vector3(0.0, 0.0, 0.0))
        local netID = ObjToNet(currentBox)
        SetNetworkIdCanMigrate(netID, false)
        TaskPlayAnim(ped, "anim@heists@box_carry@", 'idle', 99999.0, 99999.0, -1, 50, 1.0, 1, 0, 0, 0)
        AttachEntityToEntity(currentBox, ped, GetPedBoneIndex(ped, 60309), 0.025, 0.0, 0.255, -145.0, 290.0, 0.0, false, false, false, false, 2, true)
        while holdingBox do
            Wait(100)
            if not IsEntityPlayingAnim(ped, "anim@heists@box_carry@", 'idle', 1) then
                holdingBox = false
            end

            if not exports['geo-inventory']:HasItem('box') then
                holdingBox = false
            end
        end
        DeleteEntity(currentBox)
        StopAnimTask(ped, "anim@heists@box_carry@", 'idle', 1.0)
    end
end)

RegisterNetEvent('GoPostal:InformRank')
AddEventHandler('GoPostal:InformRank', function(rnk)
    myRank = rnk
end)

function GoPostalMenu()
    position = position or GetEntityCoords(Shared.Ped)
    rge = rge or 5.0
    Menu.OpenMenu('GoPostal')
    TriggerServerEvent('GoPostal:GetPay')
    while Menu.CurrentMenu == 'GoPostal' do
        Wait(0)

        if Vdist3(GetEntityCoords(Shared.Ped), position) >= rge then
            Menu.CloseMenu()
            return
        end

        if myRank then
            Menu.EmptyButton('Rank:', myRank)
        end

        if Menu.CheckBox('Job', job) then
            if not job then
                TriggerServerEvent('GoPostal:StartJob')
            else
                TriggerServerEvent('GoPostal:QuitJob')
            end
        end

        if pay > 0 then
            if Menu.Button('Pay', '$'..pay) then
                TriggerServerEvent('GoPostal:PayMe')
            end
        end

        if Menu.Button('Ask For Promotion') then
            TriggerServerEvent('GoPostal:Promotion')
        end
        Menu.Display()
    end
end

RegisterNetEvent('GoPostal:StartJob')
AddEventHandler('GoPostal:StartJob', function(bool, location)
    job = bool
    currentJob = location

    local npos = GetEntityCoords(PlayerPedId())
    local dist = 99999999.0
    local closest
    for k,v in pairs(postalLocations) do
        if Vdist4(npos, v) <= dist then
            dist = Vdist4(npos, v)
            closest = k
        end
    end

    jobVehicle = Shared.SpawnVehicle('pony', vehSpawn[closest])
    TriggerServerEvent('SetRented', GetVehicleNumberPlateText(jobVehicle))
    TriggerEvent('AddKey', jobVehicle)
    TriggerServerEvent('FillGoPostal', VehToNet(jobVehicle), GetEntityModel(jobVehicle), GetVehicleClass(jobVehicle))
    SetVehicleData(jobVehicle, vehData)
    jobVehiclePlate = GetVehicleNumberPlateText(jobVehicle)
    jobVehicle = VehToNet(jobVehicle)

    Citizen.CreateThread(function()
        blip = AddBlipForCoord(currentJob[1])
        SetBlipSprite(blip, 459)
        SetBlipColour(blip, 47)
        SetBlipRoute(blip, true)
        BeginTextCommandSetBlipName("STRING");
		AddTextComponentString('Drop Off')
		EndTextCommandSetBlipName(blip)
        while job do
            Wait(0)
            local pos = GetEntityCoords(PlayerPedId())
            if Vdist4(pos, currentJob[1]) <= 100.0 then
                DrawMarker(20, currentJob[1], 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 255, 0, 0, 2, 0, nil, nil, 0)
                if holdingBox then
                    if Vdist4(pos, currentJob[1]) <= 5.0 then
                        TriggerServerEvent('GoPotal:Next', GetEntityCoords(PlayerPedId()))
                        Wait(100)
                    end
                end
            end
        end
    end)
end)

RegisterNetEvent('GoPostal:QuitJob')
AddEventHandler('GoPostal:QuitJob', function(onJob)
    job = onJob
    RemoveBlip(blip)
    blip = nil

    if NetworkDoesEntityExistWithNetworkId(jobVehicle) then
        local ent = NetToEnt(jobVehicle)
        if IsEntityAVehicle(ent) then
            if GetVehicleNumberPlateText(ent) == jobVehiclePlate then
                TriggerServerEvent('DeleteEntity', jobVehicle)
            end
        end
    end
end)

RegisterNetEvent('GoPostal:NextJob')
AddEventHandler('GoPostal:NextJob', function(location)
    holdingBox = false
    currentJob = location
    RemoveBlip(blip)
    blip = AddBlipForCoord(currentJob[1])
    SetBlipSprite(blip, 459)
    SetBlipColour(blip, 47)
    SetBlipRoute(blip, true)
    BeginTextCommandSetBlipName("STRING");
	AddTextComponentString('Drop Off')
	EndTextCommandSetBlipName(blip)
end)

RegisterNetEvent('GoPostal:GetPay')
AddEventHandler('GoPostal:GetPay', function(am)
    pay = am
end)