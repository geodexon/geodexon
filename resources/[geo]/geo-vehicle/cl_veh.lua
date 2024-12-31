local engine = false
local currentHeading = nil
local turnLeft = false
local turnRight = false
local stall = 0
local forceOff = false

AddEventHandler('enteringVehicle', function(veh)
    if not NetworkGetEntityIsNetworked(veh) then return end
    local _ped = GetPedInVehicleSeat(veh, -1)
    if _ped ~= 0 and not IsPedAPlayer(_ped) then _ped = true end
    if _ped == true then 
        forceOff = true 
    else
        forceOff = false
    end

    if Entity(veh).state.fake then
        return
    end

    if not DecorExistOn(veh, 'Locks') then
        local class = GetVehicleClass(veh)
        if not (class == 8 or class == 13 or class == 14 or GetVehicleNumberOfWheels(veh) == 2) then
            local nPed = GetPedInVehicleSeat(veh, -1)
            if nPed == 0 then
                local num = Random(100)
                if num <= 60 then
                    TriggerServerEvent('SetVehicleLock', VehToNet(veh), true)
                end

                DecorSetBool(veh, 'Locks', true)
            else
                local num = Random(100)
                if num <= 10 then
                    TriggerServerEvent('SetVehicleLock', VehToNet(veh), true)
                end

                DecorSetBool(veh, 'Locks', true)
            end
        end
    else
        if not DecorExistOn(veh, 'PlayerOwned') then
            if not AreAllVehicleWindowsIntact(veh) then
                TriggerServerEvent('SetVehicleLock', VehToNet(veh), false)
            end
        end
    end

    --[[ local closestDoor
    local dist = 1000.0
    for i=-1,10 do
        if IsVehicleSeatFree(veh, i) then
            local pos = GetEntryPositionOfDoor(veh, i + 1)
            local distance = Vdist3(pos, GetEntityCoords(Shared.Ped))
            if distance <= dist then
                dist = distance
                closestDoor = i + 1
            end
        end
    end

    if IsVehicleSeatFree(veh, 0) and Vdist3(GetEntryPositionOfDoor(veh, 0), GetEntityCoords(Shared.Ped)) <= 0.7 then
        closestDoor = 0
    end

    if IsVehicleSeatFree(veh, 1) and Vdist3(GetEntryPositionOfDoor(veh, 1), GetEntityCoords(Shared.Ped)) <= 0.7 then
        closestDoor = 1
    end

    if closestDoor then
        Wait(100)
        print(closestDoor)
        TaskEnterVehicle(Shared.Ped, veh, -1, closestDoor - 1, 1.0, 1, 0)
        local time = GetGameTimer()

        local done = false
        while Shared.TimeSince(time) <= 5000 and Shared.CurrentVehicle == 0 do
            Wait(0)
            for i=32,35 do
                if IsControlJustPressed(0, i) then
                    ClearPedTasks(Shared.Ped)
                    done = true
                    break
                end
            end

            if done then
                break
            end
        end
    end ]]
end)


AddEventHandler('enteringVehicle', function(veh)
    local closest = -3
	local dist = 1000.0
	local pos = GetEntityCoords(PlayerPedId())
	for i= 0, 4 do
		if DoesVehicleHaveDoor(veh, i) then
			local door = GetEntryPositionOfDoor(veh, i)
			if IsVehicleSeatFree(veh, i - 1) then
                if Vdist2(pos, door) < dist then
                    closest = i - 1
                    dist = Vdist2(pos, door)
                end
            else
                if not IsPedAPlayer(GetPedInVehicleSeat(veh, i)) then
                    if Vdist2(pos, door) < dist then
                        closest = i - 1
                        dist = Vdist2(pos, door)
                    end
                end
			end
		end
	end

	if closest == -3 then
		return
	end

	if MyCharacter.cuff == 1 then
		if GetVehicleDoorAngleRatio(veh, closest + 1) <= 0 then
			ClearPedTasksImmediately(PlayerPedId())
			entering = false
			Citizen.CreateThread(function()
				local time = GetGameTimer()
				while Shared.TimeSince(time) < 1000 do
					Wait(0)
					DisableControlAction(0, 23, true)
				end
			end)
			return
		end
    end
    
    print(closest)
    if closest == 3 then
        if GetPedInVehicleSeat(veh, -1) == 0 then
            closest = -1
        end
    elseif closest == 4 then
        if GetPedInVehicleSeat(veh, 0) == 0 then
            closest = 0
        end
    end

    TaskEnterVehicle(PlayerPedId(), veh, 10000, closest, 1.0, 1, 0)
    Wait(500)

    while Shared.CurrentVehicle == 0 do
        Wait(0)
        for i=30,35 do
            if IsControlPressed(0, i) then
                ClearPedTasks(Shared.Ped)
                return
            end
        end
    end
end)

local classList = {
    5, 6, 7, 15, 16, 18, 21
}
local inVeh = false
AddEventHandler('enteredVehicle', function(veh, seat)
    local ped = PlayerPedId()
    local class = GetVehicleClass(veh)
    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fCollisionDamageMult', 2.0)
    inVeh = true
    engine = GetIsVehicleEngineRunning(veh)

    SetPedIntoVehicle(ped, veh, seat)
	SetPedConfigFlag(ped, 184, true)
    SetPedConfigFlag(ped, 35, true)
    SetPedConfigFlag(ped, 32, true)
    SetPedConfigFlag(ped, 429, true)
    local angle = GetVehicleSteeringAngle(veh)
    if (not engine or forceOff) and (seat == -1 or (seat ~= -1 and not IsPedAPlayer(GetPedInVehicleSeat(veh, -1)))) then
        engine = false
        SetVehicleEngineOn(veh, false, true, true)
    end

    CreateThread(function()
        if HasKey(veh) then
            return
        end

        local _int
        while Shared.CurrentVehicle ~= 0 do
            Wait(0)
			if not engine then
                if GetPedInVehicleSeat(veh, -1) == Shared.Ped and MyCharacter.dead ~= 1 then
                    local pos = GetOffsetFromEntityInWorldCoords(Shared.CurrentVehicle, 0.0, 2.0, 0.25)
                    _int = Shared.Interact('[G] Hotwire') or _int
                    if IsControlJustPressed(0, 47) then
                        if _int then _int.stop() end

                        local class = GetVehicleClass(veh)
                        for k,v in pairs(classList) do
                            if v == class then
                                _int = Shared.Interact('This Vehicle Can not be hotwired', 5000) or _int
                                return
                            end
                        end

                        RequestAnimDict('veh@handler@base')
                        while not HasAnimDictLoaded('veh@handler@base') do
                            Wait(0)
                        end
                        TaskPlayAnim(PlayerPedId(), 'veh@handler@base', 'hotwire', 1.0, 1.0, -1, 49, 1.0, 0, 0, 0)
                        hotwiring = true
                        local comp = false
                        local terminate = nil

                        exports['geo-shared']:Progress('Hotwiring', 10000, function(val, term)
                            terminate = term
                            if val == true then
                                comp = true
                            end
                        end)
                        local time = GetGameTimer()
                        while hotwiring do
                            Wait(0)

                            if IsControlJustPressed(0, 75) then
                                TaskLeaveVehicle(ped, veh, 0)
                            end

                            if not IsEntityPlayingAnim(PlayerPedId(), 'veh@handler@base', 'hotwire', 1) then
                                terminate()
                                hotwiring = true
                                break
                            end

                            if Shared.CurrentVehicle == 0 then
                                terminate()
                                hotwiring = true
                                break
                            end

                            if comp then
                                hotwiring = false
                                break
                            end
                        end
                        StopAnimTask(PlayerPedId(), 'veh@handler@base', 'hotwire', 1.0)
                        if hotwiring then
                            StopAnimTask(PlayerPedId(), 'veh@handler@base', 'hotwire', 1.0)
                            hotwiring = false
                            if _int then _int.stop() end
                            return
                        end
                        engine = true
                        SetVehicleEngineOn(veh, true, false, true)
                        Wait(500)
                        if GetVehicleEngineHealth(veh) < 150 then
                            SetVehicleEngineOn(veh, false, true, true)
                        end
                        StopAnimTask(PlayerPedId(), 'veh@handler@base', 'hotwire', 1.0)
                        if _int then _int.stop() end
                        return
                    end
                else
                    if _int then _int.stop() end
                    Wait(500)
                end
            else
                Wait(500)
                if _int then _int.stop() end
                if GetVehicleEngineHealth(veh) < 150 then
                    SetVehicleEngineOn(veh, false, true, true)
                    engine = false
                end
            end
        end
        if _int then _int.stop() end
    end)


    CreateThread(function()
        SetVehicleLightMultiplier(veh, 1.0)
        local lights, on, highbeam = GetVehicleLightsState(veh)
        while Shared.CurrentVehicle ~= 0 do
            lights, on, highbeam = GetVehicleLightsState(veh)
            angle = GetVehicleSteeringAngle(veh)
            Wait(500)
        end
        SetVehicleSteeringAngle(veh, angle)
        if highbeam == 1 then
            SetVehicleFullbeam(veh, true)
            SetVehicleLightMultiplier(veh, 5.0)
        end
    end)

    Citizen.CreateThread(function()
        while Shared.CurrentVehicle ~= 0 do
            if IsControlJustPressed(0, 75) then
                TriggerEvent('leftVehicle', veh, GetPedInVehicleSeat(veh, -1) == Shared.Ped)
                break
            end

            if class ~= 8 and class ~= 16 and class ~= 15 and class ~= 13 then
                if not IsVehicleOnAllWheels(veh) then
                    DisableControlAction(0, 59, true)
                    DisableControlAction(0, 60, true)
                end
            end
            Wait(0)
        end
    end)

    Citizen.CreateThread(function()
        while Shared.CurrentVehicle ~= 0 do
            Wait(0)
            if GetPedInVehicleSeat(veh, -1) == Shared.Ped then
                if HasEntityCollidedWithAnything(veh) then
                    local speed = GetEntitySpeed(veh)
                    Wait(250)
                    local newSpeed = GetEntitySpeed(veh)
                    if newSpeed < speed and speed - newSpeed > (10 * 2.236936) then
                        local calc = GetVehicleEngineHealth(veh) - ((speed - newSpeed) * 5)
                        SetVehicleEngineHealth(veh, calc > 10 and calc or 10)
                        Wait(1000)

                        if GetVehicleEngineHealth(veh) <= 150 then
                            for i=0,7 do
                                SetVehicleTyreBurst(veh, i, true, 1.0)
                            end
                        end

                        if Random(1, 10) > 7 then
                            engine = false
                            SetVehicleEngineOn(veh, false, true, true)
                            TriggerEvent('Your engine has stalled')
                            stall = GetGameTimer() + 3000
                        end
                    else
                        Wait(1000)
                    end
                end
            else
                Wait(1000)
            end
        end
    end)

    CreateThread(function()
        while Shared.CurrentVehicle ~= 0 do
            if IsEntityInAir(Shared.CurrentVehicle) then
                local pTime = GetGameTimer()
                while IsEntityInAir(Shared.CurrentVehicle) do
                    Wait(0)
                end
                
                local pCalc = (GetGameTimer() - pTime) / 1000
                local pClass = GetVehicleClass(Shared.CurrentVehicle)

                if pClass == 14 or pClass == 15 or pClass == 16 then break end

               --[[  if class == 8 or class == 13 then
                    if pCalc > 1.0 then
                        if GetPedInVehicleSeat(Shared.CurrentVehicle, -1) == Shared.Ped and pCalc > 0.5 then
                            SetVehicleEngineHealth(Shared.CurrentVehicle, GetVehicleEngineHealth(Shared.CurrentVehicle) - pCalc * 100)
                        end

                        ApplyDamageToPed(Shared.Ped, math.floor(pCalc * 3), false)
                        ShakeGameplayCam("JOLT_SHAKE", pCalc)
                    end
                else ]]
                    if pCalc > 1.0 then
                        if GetPedInVehicleSeat(Shared.CurrentVehicle, -1) == Shared.Ped and pCalc > 0.5 then
                            SetVehicleEngineHealth(Shared.CurrentVehicle, GetVehicleEngineHealth(Shared.CurrentVehicle) - pCalc * 50)
                        end

                        ApplyDamageToPed(Shared.Ped, math.floor(pCalc), false)
                        ShakeGameplayCam("JOLT_SHAKE", pCalc)
                    end
                --end
            end
            Wait(100)
        end
    end)

    Citizen.CreateThread(function()
        while Shared.CurrentVehicle ~= 0 do
            Wait(0)
            if MyCharacter.cuff == 1 then
                DisableControlAction(0, 59, true)
            else
                Wait(1000)
            end
        end
    end)

    while inVeh do
        Wait(0)
        if GetPedInVehicleSeat(veh, -1) == Shared.Ped then
            if not engine then
                SetVehicleEngineOn(veh, false, true, true)
            else
                Wait(500)
            end
        end
    end
end)

RegisterNetEvent('TurnSignal')
AddEventHandler('TurnSignal', function(net, dir)
    if NetworkDoesEntityExistWithNetworkId(net) then
        local veh = NetworkGetEntityFromNetworkId(net)
        if dir == 'right' then
            SetVehicleIndicatorLights(veh, 1, false)
            SetVehicleIndicatorLights(veh, 0, true)
        elseif dir == 'left' then
            SetVehicleIndicatorLights(veh, 0, false)
            SetVehicleIndicatorLights(veh, 1, true)
        elseif dir == 'off' then
            SetVehicleIndicatorLights(veh, 1, false)
            SetVehicleIndicatorLights(veh, 0, false)
        elseif dir == 'both' then
            SetVehicleIndicatorLights(veh, 1, true)
            SetVehicleIndicatorLights(veh, 0, true)
        end

        if dir ~= 'off' and dir ~= 'both' then
            if veh == Shared.CurrentVehicle then
                currentHeading = GetEntityHeading(veh)

                while math.abs(currentHeading - GetEntityHeading(veh)) <= 70.0 do
                    Wait(250)
                end
                TriggerServerEvent('TurnSignal', VehToNet(Shared.CurrentVehicle), 'off')
            end
        end
    end
end)

AddEventHandler('leftVehicle', function(veh, driver)
    if driver then
        Shared.GetEntityControl(veh)
        inVeh = false
        if engine then
            Wait(100)
            SetVehicleEngineOn(veh, true, true, true)
        end
    end
end)

function ToggleEngine(source, args, raw)
    if not ControlModCheck(raw) then return end
	if hotwiring then
		return
	end

	local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
	if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then

		if GetIsVehicleEngineRunning(veh) then
            SetVehicleEngineOn(veh, false, true, true)
            engine = false
		else

            if not HasKey(veh) then
                
                if GetEntityModel(veh) == GetHashKey('forklift') and exports['geo-inventory']:HasItem('forklift_keys') then
                    TriggerServerEvent('RemoveItem', 'forklift_keys', 1)
                    TriggerEvent('AddKey', veh)
                    goto skipX
                end

				TriggerEvent('Shared.Notif', 'You do not have a key to this vehicle')
				return
            end

            ::skipX::

            if GetVehicleEngineHealth(veh) > 150 then

                if stall > GetGameTimer() then
                    TriggerEvent('Shared.Notif', 'The engine is flooded')
                    return
                end

				engine = true
                SetVehicleEngineOn(veh, true, false, true)
                Wait(500)
			end
        end
    end
end

RegisterCommand('engine', ToggleEngine)

local data = {}
RegisterCommand('get', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    data = GetVehicleData(veh)
    TriggerServerEvent('print', json.encode(data))
end)

RegisterCommand('set', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    SetVehicleData(veh, json.encode(data), data.plate)
end)

AddEventHandler('Vehicle:ToggleDoor', function(door)
	ToggleVehicleDoor(door)
end)

RegisterCommand("door", function(source, args, rawCommand)
    if MyCharacter.cuff ~= 1 then
        ToggleVehicleDoor(args[1])
    end
end)


RegisterCommand("window", function(source, args, rawCommand)
	ToggleVehicleWindow(args[1])
end)

RegisterCommand("trunk", function(source)
	local ped = PlayerPedId()
	if IsPedSittingInAnyVehicle(ped) then
		local vehicle = GetVehiclePedIsIn(ped, false)
		if GetPedInVehicleSeat(vehicle, -1) == ped then
			doorAngle = GetVehicleDoorAngleRatio(vehicle, 5)
			DoorToggle(vehicle, 5)
		end
	else
		local vehicle = Shared.EntityInFront(5.0)
		if DoesEntityExist(vehicle) then
			DoorToggle(vehicle, 5)
		else
		end
	end
end)

RegisterCommand("hood", function(source)
	local ped = PlayerPedId()
	if IsPedSittingInAnyVehicle(ped) then
		local vehicle = GetVehiclePedIsIn(ped, false)
		if GetPedInVehicleSeat(vehicle, -1) == ped then 
			doorAngle = GetVehicleDoorAngleRatio(vehicle, 5)
			DoorToggle(vehicle, 4)
		end
	else
		local vehicle = Shared.EntityInFront(5.0)
		if DoesEntityExist(vehicle) then
			DoorToggle(vehicle, 4)
		else
		end
	end
end)

RegisterCommand('seat', function(source, args)
    seat = tonumber(args[1])
    if Shared.CurrentVehicle ~= 0 and seat then

        if MyCharacter.cuff == 1 then
            if seat < 1 then return end
        end

        if IsVehicleSeatFree(Shared.CurrentVehicle, seat) then
            SetPedIntoVehicle(Shared.Ped, Shared.CurrentVehicle, seat)
        end
    end
end)

function DoorToggle(entity, door)
	local doorAngle = GetVehicleDoorAngleRatio(entity, door)
    if doorAngle == 0 then
        if GetVehicleDoorLockStatus(entity) ~= 2 then
            if door == 5 then
                TriggerEvent('Trunk.Open', entity)
            end
			TriggerServerEvent('Vehicle.ToggleDoor', VehToNet(entity), door)
		else
			TriggerEvent('sendChatMessage', 'locks', 'The vehicle is Locked')
		end
	else
		TriggerServerEvent('Vehicle.ToggleDoor', VehToNet(entity), door)
	end
end

function WindowToggle(entity, door)
    TriggerServerEvent('Vehicle.ToggleWindow', VehToNet(entity), door)
end

function ToggleVehicleDoor(doorIndex)

	if MyCharacter.cuff == 1 then
		return
	end

	if doorIndex ~= nil then
		if doorIndex == 'frontleft' or doorIndex == 'fl' then
			sDoor = 0
		elseif doorIndex == 'frontright' or doorIndex == 'fr' then
			sDoor = 1
		elseif doorIndex == 'backleft' or doorIndex == 'bl' then
			sDoor = 2
		elseif doorIndex == 'backright' or doorIndex == 'br' then
			sDoor = 3
		elseif doorIndex == 'trunk2' then
            sDoor = 6
        elseif doorIndex == 'hood' or doorIndex == 'h' then
            sDoor = 4
        elseif doorIndex == 'trunk' or doorIndex == 't' then
            sDoor = 5
		else
			sDoor = 20
		end
		local ped = PlayerPedId()
		if IsPedSittingInAnyVehicle(ped) then
			local vehicle = GetVehiclePedIsIn(ped, false)
			if GetPedInVehicleSeat(vehicle, -1) == ped then 
				DoorToggle(vehicle, sDoor)
			end
		else
			local vehicle = Shared.EntityInFront(5.0)
			if DoesEntityExist(vehicle) then
				DoorToggle(vehicle, sDoor)
			end
		end
	end
end

function ToggleVehicleWindow(doorIndex)
    local sDoor
	if MyCharacter.cuff == 1 then
		return
	end

    if doorIndex ~= nil then
        doorIndex = type(doorIndex) == 'string' and doorIndex:lower() or doorIndex
		if doorIndex == 'frontleft' or doorIndex == 'fl' then
			sDoor = 0
		elseif doorIndex == 'frontright' or doorIndex == 'fr' then
			sDoor = 1
		elseif doorIndex == 'backleft' or doorIndex == 'bl' then
			sDoor = 2
		elseif doorIndex == 'backright' or doorIndex == 'br' then
			sDoor = 3
		elseif doorIndex == 'trunk2' then
            sDoor = 6
        elseif doorIndex == 'hood' or doorIndex == 'h' then
            sDoor = 4
        elseif doorIndex == 'trunk' or doorIndex == 't' then
            sDoor = 5
		else
			sDoor = 20
        end
        
        if not sDoor then
            return
        end

		local ped = PlayerPedId()
		if IsPedSittingInAnyVehicle(ped) then
			local vehicle = GetVehiclePedIsIn(ped, false)
			if GetPedInVehicleSeat(vehicle, -1) == ped then 
				WindowToggle(vehicle, sDoor)
			end
		else
			local vehicle = Shared.EntityInFront(5.0)
			if DoesEntityExist(vehicle) then
				WindowToggle(vehicle, sDoor)
			end
		end
	end
end

RegisterNetEvent('Vehicle.ToggleDoor')
AddEventHandler('Vehicle.ToggleDoor', function(net, door)
    if NetworkDoesEntityExistWithNetworkId(net) then
        local veh = NetworkGetEntityFromNetworkId(net)
        if NetworkHasControlOfEntity(veh) then
            local doorAngle = GetVehicleDoorAngleRatio(veh, door)
	        if doorAngle == 0 then
	        	SetVehicleDoorOpen(veh, door, false, false)
	        else
	        	SetVehicleDoorShut(veh, door, false, false)
            end
        end
    end
end)

RegisterNetEvent('Vehicle.ToggleWindow')
AddEventHandler('Vehicle.ToggleWindow', function(net, door)
    if NetworkDoesEntityExistWithNetworkId(net) then
        local veh = NetworkGetEntityFromNetworkId(net)
        if NetworkHasControlOfEntity(veh) then
            if IsVehicleWindowIntact(veh, door) then
                RollDownWindow(veh, door)
            else
                RollUpWindow(veh, door)
            end
        end
    end
end)

RegisterCommand('inspect', function()
    local time = GetGameTimer()
    local veh = Shared.EntityInFront(5.0)
    local vehBack, vehFront = GetModelDimensions(GetEntityModel(veh))
    if veh ~= 0 then
        if IsEntityAVehicle(veh) then
            while Shared.TimeSince(time) < 5000 do
                Wait(0)
                local pos = GetOffsetFromEntityInWorldCoords(veh, 0.0, vehFront.y - 0.5, 0.5)
                local found, x, y = GetScreenCoordFromWorldCoord(pos.x, pos.y, pos.z)
				if found then
					DebugText('Engine: '..(GetVehicleEngineHealth(veh)/10)..'%', x, y)
					DebugText('Body: '..(GetVehicleBodyHealth(veh)/10)..'%', x, y + 0.03)
				end
            end
        end
    end
end)

function DebugText(str, x, y, width, height)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(str)
	DrawText(x,y)
	local factor = (string.len(str)) / 370
    DrawRect(x,y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 150)
end

RegisterCommand('indicateleft', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~- 0 then
        if GetPedInVehicleSeat(veh, -1) == ped then
            if GetVehicleIndicatorLights(Shared.CurrentVehicle) ~= 1 then
                TriggerServerEvent('TurnSignal', VehToNet(Shared.CurrentVehicle), 'left')
            else
                TriggerServerEvent('TurnSignal', VehToNet(Shared.CurrentVehicle), 'off')
            end
        end
    end
end)

RegisterCommand('indicateright', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~- 0 then
        if GetPedInVehicleSeat(veh, -1) == ped then
            if GetVehicleIndicatorLights(Shared.CurrentVehicle) ~= 2 then
                TriggerServerEvent('TurnSignal', VehToNet(Shared.CurrentVehicle), 'right')
            else
                TriggerServerEvent('TurnSignal', VehToNet(Shared.CurrentVehicle), 'off')
            end
        end
    end
end)

RegisterCommand('indicatehaz', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~- 0 then
        if GetPedInVehicleSeat(veh, -1) == ped then
            if GetVehicleIndicatorLights(Shared.CurrentVehicle) ~= 3 then
                TriggerServerEvent('TurnSignal', VehToNet(Shared.CurrentVehicle), 'both')
            else
                TriggerServerEvent('TurnSignal', VehToNet(Shared.CurrentVehicle), 'off')
            end
        end
    end
end)

local inTrunk = false
local _tcam
RegisterCommand('getintrunk', function()
    if not inTrunk then
        local veh = Shared.EntityInFront(5.0)
        if veh ~= 0 then
            local min, max = GetModelDimensions(GetEntityModel(veh))

            if Vdist3(GetEntityCoords(Shared.Ped), GetOffsetFromEntityInWorldCoords(veh, 0.0, min.y, 0.0)) >= 3.0 then
                return
            end

            AttachEntityToEntity(Shared.Ped, veh, GetEntityBoneIndexByName(veh, 'bodyshell'), 0.0, min.y + 1.0, min.z + 0.4, 180.0, 0.0, 0.0, 1, 1, 0, 1, 1, 1)
            LoadAnim('timetable@floyd@cryingonbed@base')
            TaskPlayAnim(Shared.Ped, 'timetable@floyd@cryingonbed@base', 'base', 4.0, 4.0, -1, 1, 1.0, 0, 0, 0)
            inTrunk = veh
            _tcam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
            AttachCamToEntity(_tcam, inTrunk, 0.0, min.y - 3.0, max.z + 0.5, 1)
            RenderScriptCams(1, 1, 500, 1, 1)
            CreateThread(function()
                while inTrunk do
                    if GetVehicleDoorAngleRatio(inTrunk, 5) > 0  then
                        exports['geo-interface']:TrunkFX(false)
                    else
                        exports['geo-interface']:TrunkFX(true)
                    end
                    Wait(500)
                end
            end)

            while inTrunk do
                SetCamRot(_tcam, GetEntityRotation(inTrunk))
                if not IsEntityPlayingAnim(Shared.Ped, 'timetable@floyd@cryingonbed@base', 'base', 1) then
                    TaskPlayAnim(Shared.Ped, 'timetable@floyd@cryingonbed@base', 'base', 4.0, 4.0, -1, 1, 1.0, 0, 0, 0)
                end

                if not DoesEntityExist(inTrunk) then
                    inTrunk = false
                end

                Wait(0)
            end
            Wait(100)
            exports['geo-interface']:TrunkFX(false)
            local min, max = GetModelDimensions(GetEntityModel(veh))
            DetachEntity(Shared.Ped)
            SetEntityCoords(Shared.Ped, GetOffsetFromEntityInWorldCoords(veh, 0.0, min.y - 1.0, 0.0))
            Wait(100)
            SetEntityCoords(Shared.Ped, GetOffsetFromEntityInWorldCoords(veh, 0.0, min.y - 1.0, 0.0))
            StopAnimTask(Shared.Ped, 'timetable@floyd@cryingonbed@base', 'base', 1.0)
            RenderScriptCams(0, 1, 1000, 1, 1)
        end
    else
        if GetVehicleDoorAngleRatio(inTrunk, 5) > 0 then
            inTrunk = false
        end
    end
end)


local cruise = false
RegisterCommand('_cruise', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    if Shared.CurrentVehicle ~= 0 and GetPedInVehicleSeat(Shared.CurrentVehicle, -1) == Shared.Ped then
        cruise = not cruise

        if not cruise then return end

        local veh = Shared.CurrentVehicle
        local speed = GetEntitySpeed(veh)
        local rpm = GetVehicleCurrentRpm(veh)
        TriggerEvent('Shared.Notif', 'Cruise: '..math.floor(speed * 2.236936).. ' MPH')
        while cruise do
            if Shared.CurrentVehicle ~= veh or GetPedInVehicleSeat(veh, -1) ~= Shared.Ped or IsEntityInWater(water) or IsVehicleInBurnout(veh) or (not GetIsVehicleEngineRunning(veh)) or IsEntityInAir(veh) or HasEntityCollidedWithAnything(veh) or IsControlPressed(0, 72) then
                break
            end

            if not (GetEntitySpeed(veh) >= speed or IsControlPressed(0, 71) or IsControlPressed(0, 63) or IsControlPressed(0, 64) or IsControlPressed(0, 106)) then
                if GetEntitySpeed(veh) + 1.0 >= speed then
                    SetVehicleForwardSpeed(veh, speed)
                    SetVehicleCurrentRpm(veh, rpm)
                else
                    ApplyForceToEntityCenterOfMass(veh, 1, 0.0, 1.0, 0.0, 1, 1, 1, 1)
                    Wait(50)
                end
            end
            Wait(0)
        end
        TriggerEvent('Shared.Notif', 'Cruise: Off')
        cruise = false
    end
end)

exports('InTrunk', function()
    return inTrunk
end)

DecorRegister('Locks', 2)
DecorRegister('PlayerOwned', 2)
RegisterKeyMapping('indicateleft', '[Vehicle] Turn Signal: Left', 'keyboard', 'minus')
RegisterKeyMapping('indicateright', '[Vehicle] Turn Signal: Right', 'keyboard', 'equals')
RegisterKeyMapping('indicatehaz', '[Vehicle] Turn Signal: Hazards', 'keyboard', 'backslash')
RegisterKeyMapping('belt', '[Vehicle] Toggle Seatbelt', 'keyboard', 'B')
RegisterKeyMapping('engine', '[Vehicle] Toggle Engine', 'keyboard', 'RSHIFT')
RegisterKeyMapping('_cruise', '[Vehicle] Cruise Control', 'keyboard', 'Y')

exports('Engine', function(bool)
    engine = bool
    if engine then
        SetVehicleEngineOn(Shared.CurrentVehicle, true, false, true)
    end
end)

RegisterCommand('park', function()
    local veh = Shared.EntityInFront(5.0)
    if veh ~= 0 and Entity(veh).state.vin then
        TriggerServerEvent('Park', NetworkGetNetworkIdFromEntity(veh))
    end
end)

RegisterNetEvent('Parked', function(veh, data, plate)
    veh = NetworkGetEntityFromNetworkId(veh)
    SetVehicleData(veh, data, plate)
    SetOwned(veh)
end)


AddEventHandler('LoJack', function(ent)

    if Entity(ent).state.owner ~= MyCharacter.id then
        TriggerEvent('Shared.Notif', "I don't really wanna put it on this car")
        return
    end

    local min, max = GetModelDimensions(GetEntityModel(ent))
    SetEntityCoords(Shared.Ped, GetOffsetFromEntityInWorldCoords(ent, 0.0, max.y + 0.5, -0.5))
    SetEntityHeading(Shared.Ped, GetEntityHeading(ent))
    ExecuteCommand('e mechanic3')

    if exports['geo-shared']:ProgressSync('Installing LoJack', 10000) then
        Task.Run('LoJack', NetworkGetNetworkIdFromEntity(ent))
    end

    ExecuteCommand('ec')
end)