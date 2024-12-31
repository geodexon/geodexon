local dockLocations = {
    vector3(813.88, -2981.99, 6.02)
}

local vehSpawn = {
    vector4(855.41, -2942.27, 5.9, 270.0)
}

local vehData = '{"1":-1,"2":-1,"3":-1,"4":-1,"5":-1,"6":-1,"7":-1,"8":-1,"9":-1,"10":-1,"11":-1,"12":-1,"13":-1,"14":-1,"15":-1,"16":-1,"17":-1,"18":-1,"19":-1,"20":-1,"21":-1,"22":-1,"23":-1,"24":-1,"25":-1,"26":-1,"27":-1,"28":-1,"29":-1,"30":-1,"31":-1,"32":-1,"33":-1,"34":-1,"35":-1,"36":-1,"37":-1,"38":-1,"39":-1,"40":-1,"41":-1,"42":-1,"43":-1,"44":-1,"45":-1,"46":-1,"47":-1,"48":-1,"49":-1,"0":-1,"plateType":3,"livery":1,"wheelColor":156,"plate":"64KHT806","wheeltype":1,"paint2":121,"xenon":false,"tint":-1,"paint":121,"extras":[1,1],"turbo":false,"bodyhealth":1000.0,"pearl":121,"enginehealth":1000.0}'

local pay = 0
local job = false
local currentJob = {}
local jobVehicle = 0
local jobVehiclePlate = ''
local myBox = 0
local blip = nil
local myRank
local boxBlip
local boxAttached = false
local tempBlip

AddCircleZone(vector3(815.45, -2983.24, 6.02), 50.0, {
    name="dockdepot",
    useZ=false,
    --debugPoly=true
})

local inside = false
AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'dockdepot' then
        inside = inZone
        if inZone then
            local ped = exports['geo-interface']:InterfacePed({
                model = 's_m_m_dockwork_01',
                position = vector4(813.83, -2982.53, 6.02, 266.92),
                title = 'Dock Work',
                event = DockWorkMenu
            })

            while inside do
                Wait(500)
            end

            exports['geo-interface']:RemovePed(ped)
        end
    end
end)

Citizen.CreateThread(function()
    Menu.CreateMenu('Dock Work', 'Dock Work')
    Menu.Menus['Dock Work'].TitleColor = {100, 100, 255, 255}

    for k,v in pairs(dockLocations) do
        local blip = AddBlipForCoord(v)
        SetBlipSprite(blip, 478)
        SetBlipColour(blip, 10)
		SetBlipAsShortRange(blip, true)
		SetBlipScale(blip, 0.8)
		BeginTextCommandSetBlipName("STRING");
		AddTextComponentString('Dock Work')
		EndTextCommandSetBlipName(blip)
    end
end)

RegisterNetEvent('Dock Work:InformRank')
AddEventHandler('Dock Work:InformRank', function(rnk)
    myRank = rnk
end)

function DockWorkMenu()
    Menu.OpenMenu('Dock Work')
    TriggerServerEvent('Dock Work:GetPay')
    local position = GetEntityCoords(Shared.Ped)
    while Menu.CurrentMenu == 'Dock Work' do
        Wait(0)

        if Vdist3(GetEntityCoords(Shared.Ped), position) >= 5.0 then
            Menu.CloseMenu()
            return
        end

        if myRank then
            Menu.EmptyButton('Rank:', myRank)
        end

        if Menu.CheckBox('Job', job) then
            if not job then
                TriggerServerEvent('Dock Work:StartJob')
            else
                TriggerServerEvent('Dock Work:QuitJob')
            end
        end

        if pay > 0 then
            if Menu.Button('Pay', '$'..pay) then
                TriggerServerEvent('Dock Work:PayMe')
            end
        end

        if Menu.Button('Ask For Promotion') then
            TriggerServerEvent('Dock Work:Promotion')
        end
        Menu.Display()
    end
end

RegisterNetEvent('Dock Work:StartJob')
AddEventHandler('Dock Work:StartJob', function(bool, location)
    job = bool
    currentJob = location

    local npos = GetEntityCoords(Shared.Ped)
    local dist = 99999999.0
    local closest
    for k,v in pairs(dockLocations) do
        if Vdist4(npos, v) <= dist then
            dist = Vdist4(npos, v)
            closest = k
        end
    end

    jobVehicle = Shared.SpawnVehicle('handler', vehSpawn[closest])
    TriggerServerEvent('SetRented', GetVehicleNumberPlateText(jobVehicle))
    TriggerEvent('AddKey', jobVehicle)
    SetVehicleData(jobVehicle, vehData)
    jobVehiclePlate = GetVehicleNumberPlateText(jobVehicle)
    jobVehicle = VehToNet(jobVehicle)
    myBox = Shared.SpawnObject('prop_container_ld2', currentJob[2])
    SetNetworkIdCanMigrate(ObjToNet(myBox), false)
    boxBlip = AddBlipForEntity(myBox)
    boxAttached = false

    Citizen.CreateThread(function()
        blip = AddBlipForCoord(currentJob[1])
        SetBlipSprite(blip, 459)
        SetBlipColour(blip, 47)
        SetBlipRoute(blip, true)
        BeginTextCommandSetBlipName("STRING");
		AddTextComponentString('Drop Off')
		EndTextCommandSetBlipName(blip)
        while job do
            if not DoesEntityExist(myBox) and Vdist3(GetEntityCoords(Shared.Ped), currentJob[2]) <= 200.0 then
                myBox = Shared.SpawnObject('prop_container_ld2', currentJob[2])
                boxBlip = AddBlipForEntity(myBox)
                RemoveBlip(tempBlip)
            else
                if DoesEntityExist(myBox) and Vdist3(GetEntityCoords(Shared.Ped), GetEntityCoords(myBox)) >= 200.0 then
                    myBox = DeleteEntity(myBox)
                end
            end

            local pos = GetEntityCoords(Shared.Ped)
            if boxAttached then
                if Vdist4(pos, currentJob[1]) <= 500.0 then
                    DrawMarker(1, currentJob[1], 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 3.0, 3.0, 3.0, 255, 255, 255, 255, 0, 0, 2, 0, nil, nil, 0)
                    if boxAttached then
                        if Vdist4(GetEntityCoords(myBox), currentJob[1]) <= 5.0 then
                            TriggerServerEvent('Dock Work:Next', GetEntityCoords(Shared.Ped))
                            Wait(1000)
                        end
                    end
                end
            else
                if Vdist4(pos, GetEntityCoords(myBox)) <= 100.0 then
                    local veh = NetToVeh(jobVehicle)
                    local bone = GetEntityBoneIndexByName(veh, 'frame_2')
                    local nPos = GetWorldPositionOfEntityBone(veh, bone)
                    if Vdist4(nPos, GetEntityCoords(myBox)) <= 12.0 then
                        AttachEntityToEntity(myBox, veh, bone, 0.0, 1.8, -2.5, 0.0 ,0.0, 90.0, 1, 1, 1, 0, 1, 1)
                        boxAttached = true
                    end
                end
            end
            Wait(0)
        end
    end)
end)

RegisterNetEvent('Dock Work:QuitJob')
AddEventHandler('Dock Work:QuitJob', function(onJob)
    job = onJob
    RemoveBlip(blip)
    RemoveBlip(boxBlip)
    RemoveBlip(tempBlip)
    blip = nil

    if NetworkDoesEntityExistWithNetworkId(jobVehicle) then
        local ent = NetToEnt(jobVehicle)
        if IsEntityAVehicle(ent) then
            if GetVehicleNumberPlateText(ent) == jobVehiclePlate then
                TriggerServerEvent('DeleteEntity', jobVehicle)
                TriggerServerEvent('DeleteEntity', ObjToNet(myBox))
            end
        end
    end
end)

RegisterNetEvent('Dock Work:NextJob')
AddEventHandler('Dock Work:NextJob', function(location)
    currentJob = location
    TriggerServerEvent('DeleteEntity', ObjToNet(myBox))
    tempBlip = AddBlipForCoord(currentJob[2])
    RemoveBlip(blip)
    RemoveBlip(boxBlip)
    SetNetworkIdCanMigrate(ObjToNet(myBox), false)
    boxAttached = false
    boxBlip = AddBlipForEntity(myBox)
    blip = AddBlipForCoord(currentJob[1])
    SetBlipSprite(blip, 459)
    SetBlipColour(blip, 47)
    SetBlipRoute(blip, true)
    BeginTextCommandSetBlipName("STRING");
	AddTextComponentString('Drop Off')
	EndTextCommandSetBlipName(blip)
end)

RegisterNetEvent('Dock Work:GetPay')
AddEventHandler('Dock Work:GetPay', function(am)
    pay = am
end)