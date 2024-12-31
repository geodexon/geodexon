local postalLocations = {
    vector3(1197.05, -3253.69, 7.1)
}

local vehSpawn = {
    vector4(1144.9, -3261.08, 5.9, 1.64)
}

local vehSpawn2 = {
    vector4(1145.65, -3275.08, 5.9, 348.43)
}

local vehData = '{"1":-1,"2":-1,"3":-1,"4":-1,"5":-1,"6":-1,"7":-1,"8":-1,"9":-1,"10":-1,"11":-1,"12":-1,"13":-1,"14":-1,"15":-1,"16":-1,"17":-1,"18":-1,"19":-1,"20":-1,"21":-1,"22":-1,"23":-1,"24":-1,"25":-1,"26":-1,"27":-1,"28":-1,"29":-1,"30":-1,"31":-1,"32":-1,"33":-1,"34":-1,"35":-1,"36":-1,"37":-1,"38":-1,"39":-1,"40":-1,"41":-1,"42":-1,"43":-1,"44":-1,"45":-1,"46":-1,"47":-1,"48":-1,"49":-1,"0":-1,"plateType":3,"livery":1,"wheelColor":156,"plate":"64KHT806","wheeltype":1,"paint2":121,"xenon":false,"tint":-1,"paint":121,"extras":[1,1],"turbo":false,"bodyhealth":1000.0,"pearl":121,"enginehealth":1000.0}'

local pay = 0
local job = false
local currentJob = {}
local jobVehicle = 0
local jobVehiclePlate = ''
local jobTrailer = 0
local jobTrailerPlate = ''
local holdingBox = false
local blip = nil

AddCircleZone(vector3(1195.92, -3253.35, 7.1), 50.0, {
    name="truckingdepot",
    useZ=false,
    --debugPoly=true
})

local inside = false
AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'truckingdepot' then
        inside = inZone
        if inZone then
            local ped = exports['geo-interface']:InterfacePed({
                model = 's_m_m_trucker_01',
                position = vector4(1196.9, -3253.56, 7.1, 86.0),
                title = 'Trucking',
                event = Trucking_Menu
            })

            while inside do
                Wait(500)
            end

            exports['geo-interface']:RemovePed(ped)
        end
    end
end)

Citizen.CreateThread(function()
    Menu.CreateMenu('Trucking', 'Trucking')
    Menu.Menus['Trucking'].TitleColor = {0, 0, 255, 255}

    for k,v in pairs(postalLocations) do
        local blip = AddBlipForCoord(v)
        SetBlipSprite(blip, 67)
        SetBlipColour(blip, 31)
		SetBlipAsShortRange(blip, true)
		SetBlipScale(blip, 0.8)
		BeginTextCommandSetBlipName("STRING");
		AddTextComponentString('Truck Depot')
		EndTextCommandSetBlipName(blip)
    end
end)

RegisterNetEvent('Trucking:InformRank')
AddEventHandler('Trucking:InformRank', function(rnk)
    myRank = rnk
end)

AddEventHandler('Use:dolly', function(key, val)

    if Shared.CurrentVehicle ~= 0 then
        return
    end

    holdingBox = not holdingBox

    if holdingBox then
        local ped = PlayerPedId()
        RequestAnimDict("anim@heists@box_carry@")
        while not HasAnimDictLoaded("anim@heists@box_carry@") do
            Wait(0)
        end
        local currentBox = Shared.SpawnObject('prop_sacktruck_02b', vector3(0.0, 0.0, 0.0))
        local netID = ObjToNet(currentBox)
        
        SetNetworkIdCanMigrate(netID, false)
        TaskPlayAnim(ped, "anim@heists@box_carry@", 'idle', 99999.0, 99999.0, -1, 50, 1.0, 1, 0, 0, 0)
        AttachEntityToEntity(currentBox, ped, GetEntityBoneIndexByName(ped, "SKEL_Pelvis"), -0.075, 0.90, -0.9, -20.0, 0.5, 181.0, true, false, false, true, 1, true)
        while holdingBox do
            Wait(100)
            if not IsEntityPlayingAnim(ped, "anim@heists@box_carry@", 'idle', 1) then
                holdingBox = false
            end

            if not exports['geo-inventory']:HasItem('dolly') then
                holdingBox = false
            end
        end
        DeleteEntity(currentBox)
        StopAnimTask(ped, "anim@heists@box_carry@", 'idle', 1.0)
    end
end)

function Trucking_Menu()
    local position = GetEntityCoords(Shared.Ped)
    Menu.OpenMenu('Trucking')
    TriggerServerEvent('Trucking:GetPay')
    while Menu.CurrentMenu == 'Trucking' do
        Wait(0)

        if Vdist3(GetEntityCoords(PlayerPedId()), position) >= 5.0 then
            Menu.CloseMenu()
            return
        end

        if myRank then
            Menu.EmptyButton('Rank:', myRank)
        end

        if Menu.CheckBox('Job', job) then
            if not job then
                TriggerServerEvent('Trucking:StartJob')
            else
                TriggerServerEvent('Trucking:QuitJob')
            end
        end

        if pay > 0 then
            if Menu.Button('Pay', '$'..pay) then
                TriggerServerEvent('Trucking:PayMe')
            end
        end

        if Menu.Button('Ask For Promotion') then
            TriggerServerEvent('Trucking:Promotion')
        end
        Menu.Display()
    end
end

RegisterNetEvent('Trucking:StartJob')
AddEventHandler('Trucking:StartJob', function(bool, location)
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

    jobVehicle = Shared.SpawnVehicle('hauler', vehSpawn[closest])
    jobTrailer = Shared.SpawnVehicle('trailers2', vehSpawn2[closest])
    TriggerServerEvent('SetRented', GetVehicleNumberPlateText(jobVehicle))

    TriggerEvent('AddKey', jobVehicle)
    TriggerServerEvent('FillTrucking', VehToNet(jobTrailer), GetEntityModel(jobTrailer), GetVehicleClass(jobTrailer))
    
    SetVehicleData(jobVehicle, vehData)
    jobVehiclePlate = GetVehicleNumberPlateText(jobVehicle)
    jobVehicle = VehToNet(jobVehicle)

    jobTrailerPlate = GetVehicleNumberPlateText(jobTrailer)
    jobTrailer = VehToNet(jobTrailer)

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
                        TriggerServerEvent('Trucking:Next', GetEntityCoords(PlayerPedId()))
                        Wait(100)
                    end
                end
            end
        end
    end)
end)

RegisterNetEvent('Trucking:QuitJob')
AddEventHandler('Trucking:QuitJob', function(onJob)
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

    if NetworkDoesEntityExistWithNetworkId(jobTrailer) then
        local ent = NetToEnt(jobTrailer)
        if IsEntityAVehicle(ent) then
            if GetVehicleNumberPlateText(ent) == jobTrailerPlate then
                TriggerServerEvent('DeleteEntity', jobTrailer)
            end
        end
    end
end)

RegisterNetEvent('Trucking:NextJob')
AddEventHandler('Trucking:NextJob', function(location)
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

RegisterNetEvent('Trucking:GetPay')
AddEventHandler('Trucking:GetPay', function(am)
    pay = am
end)