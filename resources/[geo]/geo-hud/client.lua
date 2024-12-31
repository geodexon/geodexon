local newWeight = 0
local newHunger = 100
local newThirst = 100
local radar = nil
local inVeh = false
local locked = false
local belt = false
local newFuel
local speed
local cstr = ''
local shown = true

SetScriptGfxAlign(string.byte('L'), string.byte('B'))
local minimapTopX, minimapTopY = GetScriptGfxPosition(-0.0045, 0.002 + (-0.188888))
ResetScriptGfxAlign()
local w, h = GetActiveScreenResolution()
w, h = w * minimapTopX, h * minimapTopY

local lastNotif = 0
Citizen.CreateThread(function()
    local me = PlayerId()
    local ped = PlayerPedId()
    local health =  0
    local armor = 50
    local weight = 50
    local voice = 0.0001
    local hunger = 100
    local thirst = 100
    local wasTalking = false
    local nos = 0
    local fuel = 0
    local stamina = GetPlayerStamina(me)

    Citizen.CreateThread(function()
        Wait(500)
        if MyCharacter ~= nil then
            Render(true)
        end
    end)

    SetEntityMaxHealth(ped, 200)
    --[[ local xoffset = 0.825
    local yoffset = 0.775

    SetMinimapComponentPosition('minimap', 'L', 'B', -0.0045 + xoffset, 0.002 - yoffset, 0.150, 0.188888)
    SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.020 + xoffset, 0.032 - yoffset, 0.111, 0.159)
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.03 + xoffset, 0.022 - yoffset, 0.266, 0.237) ]]
    DisplayRadar(0)
    SetRadarBigmapEnabled(false, false)
    Wait(500)
    SetRadarBigmapEnabled(false, false)
    NetworkSetVoiceActive(true)
    SetBigmapActive(false)

    SendNUIMessage({
        type = 'hud:rect',
        data = {w, h}
    })

    while true do
        Wait(200)
        local change = false
        ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        local newhealth =  GetEntityHealth(ped)
        local newarmor = GetPedArmour(ped)
        local talking = NetworkIsPlayerTalking(me)
        local newStamina = GetPlayerStamina(me)
        local newNos
        local newFuel
        if not (MyUser and MyUser.data.settings.enablestaminabar) then
            newStamina = 100
        end

        if veh ~= 0 then
            if GetIsVehicleEngineRunning(veh) then
                newNos = Entity(Shared.CurrentVehicle).state.nos or 0
                newFuel = GetVehicleFuelLevel(Shared.CurrentVehicle)
            else
                newFuel = 0
                newNos = 0
            end
        end
        
        if health ~= newhealth then
            health = newhealth
            change = true
        end

        if armor ~= newarmor then
            armor = newarmor
            change = true
        end

        if fuel ~= newFuel then
            fuel = newFuel
            change = true
        end

        if talking ~= wasTalking then
            wasTalking = talking
            voice = 0
            change = true
            if talking then
                voice = 100
            end
            exports['geo-interface']:InterfaceMessage({
                interface = 'radio.voice',
                talking = talking
            })
        end

        if weight ~= newWeight then
            weight = newWeight
            change = true
        end

        if newHunger ~= hunger then
            hunger = newHunger
            change = true
        end

        if newThirst ~= thirst then
            thirst = newThirst
            change = true
        end

        if newStamina ~= stamina then
            stamina = newStamina
            change = true
        end

        if (newNos or 0) ~= nos then
            nos = newNos
            change = true
        end

        if change then
            SendNUIMessage({
                type = 'hud:update',
                health = (((health - 100) / 100) * 100),
                armor = armor,
                voice = voice,
                weight = weight,
                hunger = hunger,
                thirst = thirst,
                nos = nos,
                fuel = fuel,
                stamina = stamina
            })
        end

        if Shared.CurrentVehicle ~= 0 then
            local isLocked = GetVehicleDoorLockStatus(Shared.CurrentVehicle) == 2
            if isLocked and not locked then
                locked = true
                SendNUIMessage({
                    type = 'hud:locked',
                    val = true
                })
            else
                if locked and not isLocked then
                    locked = false
                    SendNUIMessage({
                        type = 'hud:locked',
                        val = false
                    })
                end
            end
    
            if MyCharacter == nil then
                goto skipit  
            end

            ::skipit::
        end
    end
end)

RegisterCommand('belt', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    if Shared.CurrentVehicle == 0 then
        if belt then
            belt = false
        end
        return
    end

    belt = not belt

    if belt then
        Citizen.InvokeNative(GetHashKey('RESET_FLY_THROUGH_WINDSCREEN_PARAMS'))
        Citizen.InvokeNative(GetHashKey('SET_FLY_THROUGH_WINDSCREEN_PARAMS'), 50.0, 30.0, 1.0, 30.0)
        if not GetIsVehicleEngineRunning(Shared.CurrentVehicle) then
            TriggerEvent('Shared.Notif', 'Belt: On')
        end

        CreateThread(function()
            while belt do
                DisableControlAction(0, 75, true)
                if IsDisabledControlJustPressed(0, 75) then
                    if Shared.TimeSince(lastNotif) >= 2000 then
                        lastNotif = GetGameTimer()
                        Shared.ShowNotification('Belt is active.')
                    end
                end
                Wait(0)
            end
        end)
    else
        Citizen.InvokeNative(GetHashKey('RESET_FLY_THROUGH_WINDSCREEN_PARAMS'))
        Citizen.InvokeNative(GetHashKey('SET_FLY_THROUGH_WINDSCREEN_PARAMS'), 30.0, 10.0, 1.0, 10.0)
        if not GetIsVehicleEngineRunning(Shared.CurrentVehicle) then
            TriggerEvent('Shared.Notif', 'Belt: Off')
        end
    end

    SendNUIMessage({
        type = 'hud:belt',
        val = belt
    })
end)

AddEventHandler('Inventory:Weight', function(aweight)
    newWeight = aweight
end)

local surfaces = {
    [1] = 'Pavement',
    [4] = 'Road',
    [13] = 'Pavement',
    [32] = 'Rock',
    [35] = 'Rock',
    [36] = 'Rock',
    [46] = 'Grass',
    [47] = 'Grass',
    [48] = 'Grass',
}

local gps = false
RegisterCommand('gps', function()
    gps = not gps
    speed = 999
    cstr = ''
end)

local clock = {12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3, 4, 5, 6 ,7, 8, 9, 10, 11}
AddEventHandler('enteredVehicle', function(v)
    Citizen.InvokeNative(GetHashKey('RESET_FLY_THROUGH_WINDSCREEN_PARAMS'))
    Citizen.InvokeNative(GetHashKey('SET_FLY_THROUGH_WINDSCREEN_PARAMS'), 20.0, 10.0, 1.0, 10.0)
    local hud = false
    Wait(100)
    if GetIsVehicleEngineRunning(Shared.CurrentVehicle) then
        SendNUIMessage({
            type = 'textHUD',
            val = 1.0
        })
        hud = true
    end

    while Shared.CurrentVehicle ~= 0 do
       --[[  print(GetVehicleWheelSurfaceMaterial(v, 1)) ]]
        local newSpeed = math.floor(GetEntitySpeed(Shared.CurrentVehicle) * 2.236936)
        if speed ~= newSpeed then
            speed = newSpeed
            SendNUIMessage({
                type = 'hud:speed',
                val = speed,
                gps = gps
            })
        end

        local ped = PlayerPedId()
        local heading = GetEntityHeading(ped)
        local direction

        if heading < 45 then
            direction = 'North'
        elseif heading < 135 then
            direction = 'West'
        elseif heading < 215 then
            direction = 'South'
        elseif heading <= 315 then
            direction = 'East'
        else
            direction = 'North'
        end

        if not shown then
            DisplayRadar(false)
        else
            DisplayRadar(radar or GetIsVehicleEngineRunning(Shared.CurrentVehicle))
        end

        if (GetIsVehicleEngineRunning(Shared.CurrentVehicle) and not IsPauseMenuActive()) then
            if not hud then
                SendNUIMessage({
                    type = 'textHUD',
                    val = 1.0
                })
                hud = true
            end
        else
            if hud then
                SendNUIMessage({
                    type = 'textHUD',
                    val = 0.0
                })
                hud = false
            end
        end
    
        local speed = math.floor(GetEntitySpeed(Shared.CurrentVehicle) * 2.236936)
        local street, cross = GetStreetNameAtCoord(GetEntityCoords(Shared.Ped).x, GetEntityCoords(Shared.Ped).y, GetEntityCoords(Shared.Ped).z)
        street = GetStreetNameFromHashKey(street)
        cross = GetStreetNameFromHashKey(cross)
        local zone = GetLabelText(GetNameOfZone(GetEntityCoords(Shared.Ped).x, GetEntityCoords(Shared.Ped).y, GetEntityCoords(Shared.Ped).z))
        local lock = GetVehicleDoorLockStatus(Shared.CurrentVehicle) == 2
        local str = street
        if cross ~= '' then
            str = str..' / '..cross
        end
        str = direction..' - '..str..' / '..zone
        if str ~= cstr then
            SendNUIMessage({
                type = 'hud:location',
                val = str,
                gps = gps
            })
            cstr = str
        end
        

        local hour = GetClockHours()
        local min = GetClockMinutes()

        if tostring(min):len() == 1 then
            min = '0'..min
        end
        local nHour = hour
        local addon = 'PM'


        nHour = clock[hour + 1]

        if hour < 11 then
            addon = 'AM'
        end

        SendNUIMessage({
            type = 'hud:time',
            val = nHour..':'..min..' '..addon
        })
        Wait(500)
    end

    DisplayRadar(false)
    SendNUIMessage({
        type = 'textHUD',
        val = 0.0
    })
end)

AddEventHandler('Login', function(char)
    newHunger = char.data.hunger or 100
    newThirst = char.data.thirst or 100
end)

AddEventHandler('leftVehicle', function()
    SendNUIMessage({
        type = 'RemoveFuelBar',
    })

    if belt then
        belt = false

        SendNUIMessage({
            type = 'hud:belt',
            val = belt
        })
    end
end)

function Render(bool)
    shown = bool
    if bool then
        SendNUIMessage({
            type = 'baropac',
            amount = 0.8
        })
    else
        SendNUIMessage({
            type = 'baropac',
            amount = 0.0
        })
    end
end

exports('Render', Render)
exports('Radar', function(bool)
    radar = bool
    DisplayRadar(radar or GetIsVehicleEngineRunning(Shared.CurrentVehicle))
end)

CreateThread(function()
    Wait(1000)
    if MyCharacter then
        newHunger = MyCharacter.data.hunger or 100
        newThirst = MyCharacter.data.thirst or 100
    end

    while true do
        Wait(60000)
        if MyCharacter then
            if newHunger > 0 then
                newHunger = newHunger - 0.2
            end

            if newThirst > 0 then
                newThirst = newThirst - 0.4
            end
            TriggerServerEvent('SaveFood', newHunger, newThirst)
        end
    end
end)

AddEventHandler('Eat', function(food)
    newHunger = newHunger + food
    if newHunger > 100 then newHunger = 100 end
end)

AddEventHandler('Drink', function(food)
    newThirst = newThirst + food
    if newThirst > 100 then newThirst = 100 end
end)

RegisterNetEvent('ConsumeHunger', function(food)
    if newHunger > 0 then 
        newHunger = newHunger - food
    end
end)