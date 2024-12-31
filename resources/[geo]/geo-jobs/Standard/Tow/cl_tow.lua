local flatbed
local canSpawn = true
local tow = {}
local data = '{"1":-1,"2":-1,"3":-1,"4":-1,"5":-1,"6":-1,"7":-1,"8":-1,"9":-1,"10":-1,"11":-1,"12":-1,"13":-1,"14":-1,"15":-1,"16":-1,"17":-1,"18":-1,"19":-1,"20":-1,"21":-1,"22":-1,"23":-1,"24":-1,"25":-1,"26":-1,"27":-1,"28":-1,"29":-1,"30":-1,"31":-1,"32":-1,"33":-1,"34":-1,"35":-1,"36":-1,"37":-1,"38":-1,"39":-1,"40":-1,"41":-1,"42":-1,"43":-1,"44":-1,"45":-1,"46":-1,"47":-1,"48":-1,"49":-1,"0":-1,"tint":-1,"pearl":0,"xenon":false,"livery":-1,"paint":0,"plate":"84TQK080","extras":[],"bodyhealth":1000.0,"turbo":false,"wheelColor":156,"plateType":3,"enginehealth":1000.0,"paint2":0,"wheeltype":0}'
local towList = {
    [GetHashKey('flatbed')] = {
        ['default'] = vector3(0.0, -2.0, 1.0),
        ['maxLength'] = 6.5,
        ['class'] = {
        },
        ['vehicle'] = {
            
        },
    },
    [GetHashKey('flatbed2')] = {
        ['default'] = vector3(0.0, -2.0, 1.0),
        ['maxLength'] = 6.5,
        ['class'] = {
        },
        ['vehicle'] = {
            
        },
    },
    [GetHashKey('trflat')] = {
        ['default'] = vector3(0.0, -1.0, 1.5),
        ['maxLength'] = 15.0,
        ['class'] = {

        },
        ['vehicle'] = {
            
        }
    },
    [GetHashKey('tr2')] = {
        ['default'] = vector3(0.0, -1.0, 1.5),
        ['maxLength'] = 6.5,
        ['class'] = {

        },
        ['vehicle'] = {
            
        },
        [1] = {pos = vector3(0.0, 5.0, 0.8), rot = -1.0},
        [2] = {pos = vector3(0.0, 0.0, 0.9), rot = -2.0},
        [3] = {pos = vector3(0.0, -5.0, 0.9), rot = 4.0},
        [4] = {pos = vector3(0.0, 5.0, 2.8), rot = 4.0},
        [5] = {pos = vector3(0.0, 0.0, 2.9), rot = -4.0},
        [6] = {pos = vector3(0.0, -5.0, 3.0), rot = 2.0}
    },
    [GetHashKey('safreng2')] = {
        ['default'] = vector3(0.0, -0.75, 2.25),
        ['maxLength'] = 20.0,
        ['class'] = {

        },
        ['vehicle'] = {
            
        },
        ['whitelist'] = {
            [14] = true
        }
    },
    [GetHashKey('safrrescue')] = {
        ['default'] = vector3(0.0, -0.75, 2.25),
        ['maxLength'] = 20.0,
        ['offset'] = -12.5,
        ['class'] = {

        },
        ['vehicle'] = {
            
        },
        ['whitelist'] = {
            [14] = true
        }
    },
    [GetHashKey('boattrailer')] = {
        ['default'] = vector3(0.0, -1.0, 0.0),
        ['maxLength'] = 10.0,
        ['offset'] = -8.5,
        ['class'] = {

        },
        ['vehicle'] = {
            
        },
        ['bone'] = 0
    }
}

AddCircleZone(vector3(409.94, -1624.17, 29.29), 50.0, {
    name="towingdepot",
    useZ=false,
    location = vector4(409.24, -1622.97, 29.29, 227.72)
    --debugPoly=true
})

AddCircleZone(vector3(387.96, 3585.95, 33.29), 50.0, {
    name="towingdepot",
    useZ=false,
    location = vector4(387.65, 3584.89, 33.29, 348.92),
    --debugPoly=true
})


local blip = AddBlipForCoord(vec(409.24, -1622.97, 29.29))
SetBlipSprite(blip, 68)
SetBlipAsShortRange(blip, true)
SetBlipScale(blip, 0.8)
BeginTextCommandSetBlipName("STRING");
AddTextComponentString('Tow')
EndTextCommandSetBlipName(blip)

local blip = AddBlipForCoord(vector3(387.96, 3585.95, 33.29))
SetBlipSprite(blip, 68)
SetBlipAsShortRange(blip, true)
SetBlipScale(blip, 0.8)
BeginTextCommandSetBlipName("STRING");
AddTextComponentString('Tow')
EndTextCommandSetBlipName(blip)

local inside = false
AddEventHandler('Poly.Zone', function(zone, inZone, zoneData)
    if zone == 'towingdepot' then
        inside = inZone
        if inZone then
            local ped = exports['geo-interface']:InterfacePed({
                model = 'ig_floyd',
                position = zoneData.location,
                title = 'Tow',
                event = Tow_OpenMenu
            })

            local _ped = exports['geo-interface']:GetPed(ped)
            local loc = exports['geo-interface']:AddTargetEntity(_ped, 'Repo', 'Tow.Repo', {}, 
                {
                    req = function(data) return data.dist < 3.0 and MyCharacter.Duty == 'Tow' end
                }
            )

            while inside do
                Wait(500)
            end

            exports['geo-interface']:RemovePed(ped)
            loc.remove()
        end
    end
end)

exports('CanTow', function(veh)
    local hasTrailer, trailer = GetVehicleTrailerVehicle(veh)
    if hasTrailer then
        veh = trailer
    end

    local hash = GetEntityModel(veh)
    for k,v in pairs(towList) do
        if k == hash then
            return true
        end
    end
end)

local towSpawn = {
    ['Davis'] = {
        Position = vector3(410.02, -1623.81, 29.29),
        spawnPos = vector4(410.34, -1638.05, 29.29, 190.17)
    },

    ['Harmony'] = {
        Position = vector3(387.96, 3585.95, 33.29),
        spawnPos = vector4(388.18, 3597.74, 33.41, 258.69)
    },
}

local posList = {}
for k,v in pairs(towSpawn) do
    table.insert(posList, v.Position)
end

Citizen.CreateThread(function()
    TriggerServerEvent('Tow:RequestList')
    Menu.CreateMenu('Tow', 'Tow')
    Menu.Menus['Tow'].TitleColor = {50, 117, 168, 255}
end)


RegisterCommand('wash', function()
    if (MyCharacter.lastvehicle == 'FLATBED') and MyCharacter.Duty == 'Tow' then
        local veh = Shared.EntityInFront(5.0)
        if veh ~= 0 then
            Shared.GetEntityControl(veh)
            if NetworkHasControlOfEntity(veh) then
                SetVehicleDirtLevel(veh, 0.0)
            end
        end
    end
end)

AddEventHandler('Tow', function(ent)
    local ped = PlayerPedId()
    if ent ~= 0 then
        local aNum = 1
        local towVeh = GetVehiclePedIsIn(ped, true)
	
        local veh = ent
        local aVeh = towVeh
        local towVehBack, towVehFront = GetModelDimensions(GetEntityModel(towVeh))
        local vehBack, vehFront = GetModelDimensions(GetEntityModel(veh))
        local hasTrailer, trailer = GetVehicleTrailerVehicle(towVeh)
        if hasTrailer then
            towVeh = trailer
            offset = -20.0
            if not towList[GetEntityModel(towVeh)] then
                return
            end
        end
        local offset = (towList[GetEntityModel(towVeh)].offset or -16.5)
        local attached = tow[VehToNet(towVeh)]

        if GetEntityModel(towVeh) == GetHashKey('tr2') then
            local prom = promise:new()
            local options = {}
            for i=1,6 do
                table.insert(options, {
                    name = 'Slot: '..i,

                    func = function()
                        prom:resolve(i)
                    end,

                    done = function()
                        prom:resolve(false)
                    end
                })
            end
            exports['geo-interface']:OpenMenu(options)

            aNum = Citizen.Await(prom)

            if not aNum then
                return
            end

            if not tow[VehToNet(towVeh)] then
                tow[VehToNet(towVeh)] = {}
            end
            attached = tow[VehToNet(towVeh)][aNum]
        end

        local bone = (towList[GetEntityModel(towVeh)].bone or GetEntityBoneIndexByName(towVeh, 'bodyshell'))
        if attached == nil then
            if veh ~= towVeh then

                if veh == aVeh then
                    return
                end

                if veh ~= 0 then
                    if not Shared.GetEntityControl(veh) then return end 
                    if not Shared.GetEntityControl(towVeh) then return end 
                    local model = GetEntityModel(towVeh)
                    if towList[model] ~= nil then
                        local class = GetVehicleClass(veh)

                        if towList[model]['whitelist'] then
                            if towList[model]['whitelist'][class] == nil then
                                return
                            end
                        end

                        if model ~= GetHashKey('tr2') then
                            if (vehFront.y - vehBack.y) <= towList[model].maxLength then
                                if towList[model].class[class] == nil then
                                    offset = towList[model].default
                                end
                                local nOffset = offset.z
                                AttachEntityToEntity(veh, towVeh, bone, offset.x, offset.y, nOffset, 0.0, 0.0, 0.0, 1, 1, 1, 0, 1, 1)
                                local added = 0.0
                                
                                while true do
                                    Wait(0)


                                    form = setupScaleform("instructional_buttons")
                                    DrawScaleformMovieFullscreen(form, 255, 255, 255, 255, 0)
                                    DisableControlAction(0 , 44)
                                    DisableControlAction(0 , 51)
                                    DisableControlAction(0 , 140)
                                    if IsDisabledControlPressed(0, 44) then
                                        added = added - 0.01
                                        if added < -0.4 then
                                            added = -0.4
                                        end
                                    elseif IsDisabledControlPressed(0, 51) then
                                        added = added + 0.01
                                        if added > 0.4 then
                                            added = 0.4
                                        end
                                    elseif IsDisabledControlPressed(0, 140) then
                                        break
                                    end
                                    AttachEntityToEntity(veh, towVeh, bone, offset.x, offset.y, nOffset + added, 0.0, 0.0, 0.0, 1, 1, 1, 0, 1, 1)
                                end
                                
                                Wait(100)
                                Shared.GetEntityControl(veh)
                                Shared.GetEntityControl(towVeh)
                                AttachEntityToEntity(veh, towVeh, bone, offset.x, offset.y, nOffset + added, 0.0, 0.0, 0.0, 1, 1, 1, 0, 1, 1)

                                TriggerServerEvent('Tow:UpdateData', VehToNet(towVeh), VehToNet(veh))
                                TriggerEvent('Tow.Vehicle', veh)
                            end
                        else
                            if not towList[model][aNum] then
                                return
                            end
                            AttachEntityToEntity(veh, towVeh, bone, towList[model][aNum].pos, towList[model][aNum].rot, 0.0, 0.0, 1, 1, 1, 0, 1, 1)
                            local nOffset = towList[model][aNum].pos.z
                            local added = 0.0
                            while true do
                                Wait(0)

                                form = setupScaleform("instructional_buttons")
                                DrawScaleformMovieFullscreen(form, 255, 255, 255, 255, 0)
                                DisableControlAction(0 , 44)
                                DisableControlAction(0 , 51)
                                DisableControlAction(0 , 140)
                                if IsDisabledControlPressed(0, 44) then
                                    added = added - 0.01
                                    if added < -0.4 then
                                        added = -0.4
                                    end
                                elseif IsDisabledControlPressed(0, 51) then
                                    added = added + 0.01
                                    if added > 0.4 then
                                        added = 0.4
                                    end
                                elseif IsDisabledControlPressed(0, 140) then
                                    break
                                end
                                AttachEntityToEntity(veh, towVeh, bone, towList[model][aNum].pos.x, towList[model][aNum].pos.y, nOffset + added, towList[model][aNum].rot, 0.0, 0.0, 1, 1, 1, 0, 1, 1)
                            end

                            Wait(100)
                            Shared.GetEntityControl(veh)
                            Shared.GetEntityControl(towVeh)
                            AttachEntityToEntity(veh, towVeh, bone, towList[model][aNum].pos.x, towList[model][aNum].pos.y, nOffset + added, towList[model][aNum].rot, 0.0, 0.0, 1, 1, 1, 0, 1, 1)
                            TriggerServerEvent('Tow:UpdateData', VehToNet(towVeh), VehToNet(veh), true, aNum)
                            TriggerEvent('Tow.Vehicle', veh)
                        end
                    end
                end
            end
        else
            attached = NetToVeh(attached)
            if not Shared.GetEntityControl(towVeh) then return end
            DetachEntity(attached, 1, 0)
            local towVehBack, towVehFront = GetModelDimensions(GetEntityModel(towVeh))
            local nVehBack, nVehFront = GetModelDimensions(GetEntityModel(attached))

            SetEntityCoords(attached, GetOffsetFromEntityInWorldCoords(towVeh, 0.0, towVehBack.y + nVehBack.y + -3.0, 0.0), 1, 0, 0, 1) --reduced offset as requested
            SetVehicleOnGroundProperly(attached)
            local bool = GetEntityModel(towVeh) == GetHashKey('tr2') or GetEntityModel(towVeh) == GetHashKey('gneck')
            TriggerServerEvent('Tow:UpdateData', VehToNet(towVeh), nil, bool, aNum)
        end
    end
end)

RegisterNetEvent('Tow:UpdateData')
AddEventHandler('Tow:UpdateData', function(vehs)
    tow = vehs
end)

RegisterNetEvent('DeregisterFlatbed')
AddEventHandler('DeregisterFlatbed', function()
    flatbed = false
end)

function Tow_OpenMenu()
    if not Menu.CurrentMenu then
        local ped = PlayerPedId()
        for k,v in pairs(towSpawn) do
            if Vdist4(GetEntityCoords(ped), v.Position) <= 50.0 then
                Menu.OpenMenu('Tow')
                while Menu.IsMenuOpened('Tow') do
                    Wait(0)
                    if Vdist4(GetEntityCoords(ped), v.Position) > 50.0 then
                        Menu.CloseMenu()
                    end

                    if Menu.CheckBox('Duty', MyCharacter.Duty == 'Tow') then
                        TriggerServerEvent('Duty', 'Tow')
                    end

                    if MyCharacter.Duty == 'Tow' then
                        if not flatbed then
                            if Menu.Button('Spawn Vehicle') then
                                flatbed = VehToNet(Shared.SpawnVehicle('flatbed', v.spawnPos))
                                TriggerServerEvent('SetRented', GetVehicleNumberPlateText(NetToVeh(flatbed)))
                                SetVehicleData(NetToVeh(flatbed), data)
                                flatbedPlate = GetVehicleNumberPlateText(NetToVeh(flatbed))
                                TriggerEvent('AddKey', NetToVeh(flatbed))
                                TriggerServerEvent('RegisterFlatbed', flatbed)
                            end
                        else
                            if Menu.Button('Return Vehicle') then
                                if NetworkDoesEntityExistWithNetworkId(flatbed) then
                                    local ent = NetToEnt(flatbed)
                                    if GetVehicleNumberPlateText(ent) == flatbedPlate then
                                        TriggerServerEvent('DeleteEntity', flatbed)
                                        flatbed = nil
                                        flatbedPlate = nil
                                    end
                                end
                            end
                        end
                    end
                    Menu.Display()
                end
            end
        end
    end
end

local impounds = {
    ['Davis'] = vector3(401.95, -1631.22, 29.29),
    ['Paleto'] = vector3(-473.5, 6018.04, 31.34)
}

function initiateMenuDesign(name, title)
    Menu.SetSubtitle(name, title)
end

function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function Button(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

function setupScaleform(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    Button(GetControlInstructionalButton(2, 51, true))
    ButtonMessage("Increase Height")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    Button(GetControlInstructionalButton(2, 44, true))
    ButtonMessage("Lower Height")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    Button(GetControlInstructionalButton(2, 140, true))
    ButtonMessage("Lock")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

RegisterNetEvent('Tow.GPS', function(pos)
    SetNewWaypoint(pos.x, pos.y)
end)