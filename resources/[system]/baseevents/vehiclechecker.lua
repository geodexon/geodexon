local isInVehicle = false
local isEnteringVehicle = false
local currentVehicle = 0
local currentSeat = 0
local ped = PlayerPedId()

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if not isInVehicle and not isDead then
			if DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not isEnteringVehicle then
				-- trying to enter a vehicle!
				local vehicle = GetVehiclePedIsTryingToEnter(ped)
				local seat = GetSeatPedIsTryingToEnter(ped)
				local netId = VehToNet(vehicle)
				isEnteringVehicle = true
				TriggerServerEvent('enteringVehicle', vehicle, seat, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)), netId)
				TriggerEvent('enteringVehicle', vehicle, seat, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)), netId)
			elseif not DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not IsPedInAnyVehicle(ped, true) and isEnteringVehicle then
				-- vehicle entering aborted
				TriggerServerEvent('enteringAborted')
				isEnteringVehicle = false
			elseif IsPedInAnyVehicle(ped, false) then
				-- suddenly appeared in a vehicle, possible teleport
				isEnteringVehicle = false
				isInVehicle = true
				currentVehicle = GetVehiclePedIsUsing(ped)
				currentSeat = GetPedVehicleSeat(ped)
				local model = GetEntityModel(currentVehicle)
				local name = GetDisplayNameFromVehicleModel()
				local netId = VehToNet(currentVehicle)
				TriggerServerEvent('enteredVehicle', netId)
				TriggerEvent('enteredVehicle', currentVehicle, currentSeat, GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)), netId)
			end
		elseif isInVehicle then
			if not IsPedInAnyVehicle(ped, false) or isDead then
				-- bye, vehicle
				local model = GetEntityModel(currentVehicle)
				local name = GetDisplayNameFromVehicleModel()
				local netId = VehToNet(currentVehicle)
				TriggerServerEvent('leftVehicle', netId)
				TriggerEvent('leftVehicle', currentVehicle, GetPedInVehicleSeat(currentVehicle, -1) == ped)
				isInVehicle = false
				currentVehicle = 0
				currentSeat = 0
			end
		end
		Citizen.Wait(100)
	end
end)

function GetPedVehicleSeat(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    for i=-2,GetVehicleMaxNumberOfPassengers(vehicle) do
        if(GetPedInVehicleSeat(vehicle, i) == ped) then return i end
    end
    return -2
end

CreateThread(function()
	while true do
		Wait(500)
		if ped ~= PlayerPedId() then
			ped = PlayerPedId()
			TriggerEvent('pedChanged', ped)
		end
	end
end)