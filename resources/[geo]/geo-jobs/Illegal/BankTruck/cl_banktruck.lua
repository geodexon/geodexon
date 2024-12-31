local VehicleSpawn1 = vector3(-1327.61, -84.16, 48.87)
local VehicleHeading1 = 0.65
local BackupBackSpawn1 = vector3(-1327.37, -96.19, 49.33)
local BackupBackHeading1 = 3.57
local BackupFrontSpawn1 = vector3(-1326.22, -106.84, 49.17)
local BackupFrontHeading1 = 6.85
local VehicleSpawn2 = vector3(2051.9, 3383.22, 45.04)
local VehicleHeading2 = 199.97
local BackupBackSpawn2 = vector3(2046.86, 3397.35, 44.66)
local BackupBackHeading2 = 202.4
local BackupFrontSpawn2 = vector3(2041.73, 3410.36, 44.23)
local BackupFrontHeading2 = 203.25
local VehicleSpawn3 = vector3(-1808.98, 70.42, 71.43)
local VehicleHeading3 = 320.26
local BackupBackSpawn3 = vector3(-1820.2, 59.37, 73.68)
local BackupBackHeading3 = 307.27
local BackupFrontSpawn3 = vector3(-1836.13, 52.47, 75.54)
local BackupFrontHeading3 = 294.54
local VehicleSpawn4 = vector3(-706.39, -1248.73, 10.06) 
local VehicleHeading4 = 309.66
local BackupBackSpawn4 = vector3(-716.48, -1258.28, 8.96)
local BackupBackHeading4 = 309.66
local BackupFrontSpawn4 = vector3(-726.38, -1271.37, 7.48)
local BackupFrontHeading4 = 309.66
local VehicleSpawn5 = vector3(1299.98, -714.05, 64.37) 	
local VehicleHeading5 = 63.62
local BackupBackSpawn5 = vector3(1316.46, -721.4, 64.96)
local BackupBackHeading5 = 68.46
local BackupFrontSpawn5 = vector3(1335.53, -727.86, 66.26)
local BackupFrontHeading5 = 74.36
local TimeToBlow = Config.TimeToBlow * 1000
local PickupMoney = 0
local BlowBackdoor = 0
local GuardsDead = 0
local prop
local lootable = 0
local BlownUp = 0
local TruckBlip
local transport
local MissionStart = 0
local warning = 0
local VehicleCoords = nil
local difficulty = 0
local Complete = false

function Lang(str)
	local string = SplitString(str, '.')
	return Translations[string[1]][string[2]]
end

AddRelationshipGroup('Gruppe6')
AddRelationshipGroup('Evade')

function hintToDisplay(text)
	SetTextComponentFormat("STRING")
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, 20000)
end

CreateThread(function()
	local data = AddBoxZone(Config.StartHeistCoord, Config.StartHeistCoordWidth, Config.StartHeistCoordLength, {
        name = "BankTruck.Start",
        heading = Config.StartHeistCoordHeading,
        minZ = Config.StartHeistCoord.z - Config.StartHeistCoordheight,
        maxZ = Config.StartHeistCoord.z + Config.StartHeistCoordheight,
        debugPoly =  false
     }, true)
	exports['geo-interface']:AddTargetZone('BankTruck.Start', 'Bank Truck', 'BankTruck.Start', {'Bank Truck', Config.StartHeistCoord, 5.0}, 5.0)
end)

RegisterNetEvent("client:hackfdd:truck", function()

	result1 = exports['geo-inventory']:HasItem('rotas_mazebank')
	result2 = exports['geo-inventory']:HasItem('rotas_union')

	exports['varhack']:OpenHackingGame(function(success)
		if success then
			if not result1 and not result2 then
				TriggerEvent('menu:truckgeral')
			end
			if result1 and not result2 then
				TriggerEvent('menu:truckgeralmed')
			end
			if result2 and not result1 then
				TriggerEvent('menu:truckgeralhigh')
			end
			if result1 and result2 then
				TriggerEvent('menu:truckgeralall')
			end
		else
			TriggerEvent('Shared.Notif', Lang("error.fail"))
		end
	end, Config.Varblocks, Config.Vartime)

end)

RegisterNetEvent('BankTruck.Start', function()
	local menu = {
        {title = Lang("menu.lite"), sub = "You need $500 and C4", event = 'startjob:small', disabled = BankTruckReqs()},
		{title = Lang("menu.mod"), sub = "You need $500 and C4", event = 'startjob:medium', disabled = BankTruckReqs()},
		{title = Lang("menu.strong"), description = 'fuck', sub = "You need $500 and C4", event = 'startjob:large', disabled = BankTruckReqs()},
    }

    RunMenu(menu)
end)

function BankTruckReqs()
	if not exports['geo-inventory']:HasItem('dollar', 500) then
		return true
	end

	if not exports['geo-inventory']:HasItemKey('c4') then
		return true
	end
end

RegisterNetEvent('startjob:small')
AddEventHandler('startjob:small', function()
	local hasItem = exports['geo-inventory']:HasItemKey("c4")
	if hasItem == true then 
		TriggerServerEvent('AttackTransport:StartSmall')
	else
		TriggerEvent('Shared.Notif', Lang("error.c4"))
	end
end)

RegisterNetEvent('startjob:medium')
AddEventHandler('startjob:medium', function()
	local hasItem = exports['geo-inventory']:HasItemKey("c4")
	if hasItem == true then 
		TriggerServerEvent('AttackTransport:StartMedium')
	else
		TriggerEvent('Shared.Notif', Lang("error.c4"))
	end
end)

RegisterNetEvent('startjob:large')
AddEventHandler('startjob:large', function()
	local hasItem = exports['geo-inventory']:HasItemKey("c4")
	if hasItem == true then 
		TriggerServerEvent('AttackTransport:StartLarge')
	else
		TriggerEvent('Shared.Notif', Lang("error.c4"))
	end
end)

function CheckGuards()
	if IsPedDeadOrDying(pilot) == 1 or IsPedDeadOrDying(navigator) == 1 then
		GuardsDead = 1
	end
	Citizen.Wait(500)
end



RegisterNetEvent('AttackTransport:Small')
AddEventHandler('AttackTransport:Small', function()
	MissionStart = 1
	TriggerEvent('PhoneNotif', 'messages', "We'll let you know the trucks location soon")
	
	Wait(Config.TimeToReceiveJob)
	
	TriggerEvent('PhoneNotif', 'messages', "Truck has been located, marked on your GPS")
	local DrawCoord = math.random(1,5)
	if DrawCoord == 1 then
	VehicleCoords = VehicleSpawn1
	VehicleHeading = VehicleHeading1
	elseif DrawCoord == 2 then
	VehicleCoords = VehicleSpawn2
	VehicleHeading = VehicleHeading2
	elseif DrawCoord == 3 then
	VehicleCoords = VehicleSpawn3	
	VehicleHeading = VehicleHeading3
	elseif DrawCoord == 4 then
	VehicleCoords = VehicleSpawn4
	VehicleHeading = VehicleHeading4
	elseif DrawCoord == 5 then
	VehicleCoords = VehicleSpawn5
	VehicleHeading = VehicleHeading5
	end

	AddBoxZone(vector3(VehicleCoords.x, VehicleCoords.y, VehicleCoords.z), 210.0, 210.0, {
		name ="small-zone",
        debugPoly = false,
        heading = 138.14,
        minZ = VehicleCoords.z - 7,
        maxZ = VehicleCoords.z + 7,
    })

	SetNewWaypoint(VehicleCoords.x, VehicleCoords.y)

	

end)

RegisterNetEvent("Poly.Zone", function(ZoneName, ZoneData)
    if ZoneName == 'small-zone' then
        TriggerEvent('RemoveZone', 'small-zone')


		RequestModel(GetHashKey('stockade'))
		while not HasModelLoaded(GetHashKey('stockade')) do
		Citizen.Wait(0)
		end

		
		ClearAreaOfVehicles(VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, 15.0, false, false, false, false, false)
		transport = CreateVehicle(GetHashKey('stockade'), VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleHeading, true, true)
		SetEntityAsMissionEntity(transport)	
		TruckBlip = AddBlipForEntity(transport)
		SetBlipSprite(TruckBlip, 67)
		SetBlipColour(TruckBlip, 1)
		SetBlipFlashes(TruckBlip, true)
		SetBlipScale(TruckBlip, 0.5)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(Lang("info.van_label"))
		EndTextCommandSetBlipName(TruckBlip)
		SetVehicleDirtLevel(transport, 0.0)

		RequestModel("s_m_m_security_01")
		while not HasModelLoaded("s_m_m_security_01") do
			Wait(10)	
		end

		RequestModel("s_m_m_armoured_01")
		while not HasModelLoaded("s_m_m_armoured_01") do
			Wait(10)
		end

		pilot = CreatePed(26, "s_m_m_security_01", VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleHeading, true, true)
		navigator = CreatePed(26, "s_m_m_armoured_01", VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleHeading, true, true)
		
		TriggerServerEvent("Ped.Control", PedToNet(pilot), true)
		TriggerServerEvent("Ped.Control", PedToNet(navigator), true)
		
		SetPedIntoVehicle(pilot, transport, -1)
		SetPedIntoVehicle(navigator, transport, 0)

		SetEntityAsMissionEntity(pilot)
		SetEntityAsMissionEntity(navigator)
		--
		SetPedFleeAttributes(pilot, 0, 0)
		SetPedCombatAttributes(pilot, 46, 1)
		SetPedArmour(ped, amount)
		SetPedCombatAbility(pilot, 2)
		SetPedCombatMovement(pilot, 2)
		SetPedCombatRange(pilot, 2)
		SetPedKeepTask(pilot, true)
		GiveWeaponToPed(pilot, GetHashKey(Config.FrontSeatsGun),250,false,true)
		SetPedAsCop(pilot, true)
		SetPedRelationshipGroupHash(pilot, 'Evade')

		SetPedFleeAttributes(navigator, 0, 0)
		SetPedCombatAttributes(navigator, 46, 1)
		SetPedCombatAttributes(navigator, 2, 1)
		SetPedCombatAbility(navigator, 2)
		SetPedCombatMovement(navigator, 2)
		SetPedCombatRange(navigator, 2)
		SetPedKeepTask(navigator, true)
		TaskEnterVehicle(navigator,transport,-1,0,1.0,1)
		GiveWeaponToPed(navigator, GetHashKey(Config.FrontSeatsGun),250,false,true)
		SetPedAsCop(navigator, true)
		SetPedRelationshipGroupHash(navigator, 'Gruppe6')
		Wait(5)

		SetRelationshipBetweenGroups(4, 'Gruppe6', GetHashKey("PLAYER"))
		TaskVehicleDriveWander(pilot, transport, 40.0, 447)
		MissionStart = 1
		difficulty = 1
		packingtime = Config.PackingTimeLow * 1000
		TriggerEvent('AttackTransport:driverhealth')
		TriggerEvent('AttackTransport:truckhealth')
		TriggerEvent('AttackTransport:driverdied')
		TriggerEvent('AttackTransport:alertmode')


		exports['geo-interface']:SetPed(transport, 'Plant C4', function()
			TriggerEvent('client:rebentaraquelamerda')
		end)
	end


	if ZoneName == 'medium-zone' then

		TriggerEvent('RemoveZone', 'medium-zone')

		RequestModel(GetHashKey('stockade'))
		while not HasModelLoaded(GetHashKey('stockade')) do
		Citizen.Wait(0)
		end
	
		RequestModel(GetHashKey("speedo"))
		while not HasModelLoaded(GetHashKey("speedo")) do
		Citizen.Wait(0)
		end
	
		
		ClearAreaOfVehicles(VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, 15.0, false, false, false, false, false)
		transport = CreateVehicle(GetHashKey('stockade'), VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleHeading, true, true)
		Wait(5)
		BackupBack = CreateVehicle(GetHashKey('speedo'), BackupBackCoords.x, BackupBackCoords.y, BackupBackCoords.z, BackupBackHeading, true, true)
		Wait(5)
		SetEntityAsMissionEntity(transport)
		SetEntityAsMissionEntity(BackupBack)
		TruckBlip = AddBlipForEntity(transport)
		SetBlipSprite(TruckBlip, 67)
		SetBlipColour(TruckBlip, 1)
		SetBlipFlashes(TruckBlip, true)
		SetBlipScale(TruckBlip, 0.5)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(Lang("info.van_label"))
		EndTextCommandSetBlipName(TruckBlip)
		SetVehicleDirtLevel(transport, 0.0)
	
		SetVehicleModKit(BackupBack, 0)
		SetVehicleMod(BackupBack, 0, 1, 1)
		SetVehicleMod(BackupBack, 1, 15, 1)
		SetVehicleMod(BackupBack, 2, 0, 1)
		SetVehicleMod(BackupBack, 3, 1, 1)
		SetVehicleColours(BackupBack, 111, 0)
		SetVehicleDashboardColour(BackupBack, 111)
		SetVehicleWindowTint(BackupBack, 3)
		SetVehicleDirtLevel(BackupBack, 0.0)
		SetVehicleWindowTint(BackupBack, 2)
		SetVehicleLivery(BackupBack, 6)
	
	
		RequestModel("s_m_m_security_01")
			while not HasModelLoaded("s_m_m_security_01") do
			Wait(10)
		end
	
		RequestModel("s_m_m_armoured_01")
		while not HasModelLoaded("s_m_m_armoured_01") do
			Wait(10)
		end
	
		pilot = CreatePed(26, "s_m_m_security_01", VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleHeading, true, true)
		navigator = CreatePed(26, "s_m_m_armoured_01", VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleHeading, true, true)
		BackupBack1 = CreatePed(26, "s_m_m_security_01", VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleHeading, true, true)
		BackupBack2 = CreatePed(26, "s_m_m_armoured_01", VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleHeading, true, true)
		BackupBack3 = CreatePed(26, "s_m_m_armoured_01", VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleHeading, true, true)
		BackupBack4 = CreatePed(26, "s_m_m_armoured_01", VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleHeading, true, true)
		
		TriggerServerEvent("Ped.Control", PedToNet(pilot), true)
		TriggerServerEvent("Ped.Control", PedToNet(navigator), true)
		TriggerServerEvent("Ped.Control", PedToNet(BackupBack1), true)
		TriggerServerEvent("Ped.Control", PedToNet(BackupBack2), true)
		TriggerServerEvent("Ped.Control", PedToNet(BackupBack3), true)
		TriggerServerEvent("Ped.Control", PedToNet(BackupBack4), true)

		SetPedIntoVehicle(pilot, transport, -1)
		SetPedIntoVehicle(navigator, transport, 0)
		SetPedIntoVehicle(BackupBack1, BackupBack, -1)
		SetPedIntoVehicle(BackupBack2, BackupBack, 0)
		SetPedIntoVehicle(BackupBack3, BackupBack, 1)
		SetPedIntoVehicle(BackupBack4, BackupBack, 2)
	
		SetEntityAsMissionEntity(pilot)
		SetEntityAsMissionEntity(navigator)
		SetEntityAsMissionEntity(BackupBack1)
		SetEntityAsMissionEntity(BackupBack2)
		SetEntityAsMissionEntity(BackupBack3)
		SetEntityAsMissionEntity(BackupBack4)
	
		SetPedFleeAttributes(pilot, 0, 0)
		SetPedCombatAttributes(pilot, 46, 1)
		SetPedArmour(ped, amount)
		SetPedCombatAbility(pilot, 2)
		SetPedCombatMovement(pilot, 2)
		SetPedCombatRange(pilot, 2)
		SetPedKeepTask(pilot, true)
		GiveWeaponToPed(pilot, GetHashKey(Config.FrontSeatsGun),250,false,true)
		SetPedAsCop(pilot, true)
	
		SetPedFleeAttributes(navigator, 0, 0)
		SetPedCombatAttributes(navigator, 46, 1)
		SetPedCombatAttributes(navigator, 2, 1)
		SetPedCombatAbility(navigator, 2)
		SetPedCombatMovement(navigator, 2)
		SetPedCombatRange(navigator, 2)
		SetPedKeepTask(navigator, true)
		TaskEnterVehicle(navigator,transport,-1,0,1.0,1)
		GiveWeaponToPed(navigator, GetHashKey(Config.FrontSeatsGun),250,false,true)
		SetPedAsCop(navigator, true)
		SetPedRelationshipGroupHash(navigator, 'Gruppe6')
	
		SetPedFleeAttributes(BackupBack1, 0, 0)
		SetPedCombatAttributes(BackupBack1, 46, 1)
		SetPedCombatAbility(BackupBack1, 2)
		SetPedCombatMovement(BackupBack1, 2)
		SetPedCombatRange(BackupBack1, 2)
		SetPedKeepTask(BackupBack1, true)
		GiveWeaponToPed(BackupBack1, GetHashKey(Config.FrontSeatsGun),250,false,true)
		SetPedAsCop(BackupBack1, true)
	
		SetPedFleeAttributes(BackupBack2, 0, 0)
		SetPedCombatAttributes(BackupBack2, 46, 1)
		SetPedCombatAttributes(BackupBack2, 2, 1)
		SetPedCombatAbility(BackupBack2, 2)
		SetPedCombatMovement(BackupBack2, 2)
		SetPedCombatRange(BackupBack2, 2)
		SetPedKeepTask(BackupBack2, true)
		TaskEnterVehicle(BackupBack2,BackupBack,-1,0,1.0,1)
		GiveWeaponToPed(BackupBack2, GetHashKey(Config.FrontSeatsGun),250,false,true)
		SetPedAsCop(BackupBack2, true)
		SetPedRelationshipGroupHash(BackupBack2, 'Gruppe6')
	
		SetPedFleeAttributes(BackupBack3, 0, 0)
		SetPedCombatAttributes(BackupBack3, 46, 1)
		SetPedCombatAttributes(BackupBack3, 2, 1)
		SetPedCombatAbility(BackupBack3, 2)
		SetPedCombatMovement(BackupBack3, 2)
		SetPedCombatRange(BackupBack3, 2)
		SetPedKeepTask(BackupBack3, true)
		TaskEnterVehicle(BackupBack3,BackupBack,-1,1,1.0,1)
		GiveWeaponToPed(BackupBack3, GetHashKey(Config.BackSeatsGun),250,false,true)
		SetPedAsCop(BackupBack3, true)
		SetPedRelationshipGroupHash(BackupBack3, 'Gruppe6')
	
		SetPedFleeAttributes(BackupBack4, 0, 0)
		SetPedCombatAttributes(BackupBack4, 46, 1)
		SetPedCombatAttributes(BackupBack4, 2, 1)
		SetPedCombatAbility(BackupBack4, 2)
		SetPedCombatMovement(BackupBack4, 2)
		SetPedCombatRange(BackupBack4, 2)
		SetPedKeepTask(BackupBack4, true)
		TaskEnterVehicle(BackupBack4,BackupBack,-1,2,1.0,1)
		GiveWeaponToPed(BackupBack4, GetHashKey(Config.BackSeatsGun),250,false,true)
		SetPedAsCop(BackupBack4, true)
		SetPedRelationshipGroupHash(BackupBack4, 'Gruppe6')
	
		Wait(3000)
		SetRelationshipBetweenGroups(4, 'Gruppe6', GetHashKey("PLAYER"))
		TaskVehicleDriveWander(pilot, transport, 40.0, 447)
		TaskVehicleChase(BackupBack1, pilot)
		Wait(100)
		SetTaskVehicleChaseBehaviorFlag(BackupBack1, 32, true)
		Wait(100)
		SetTaskVehicleChaseIdealPursuitDistance(BackupBack1, 15.0)
		Wait(100)
		SetDriveTaskDrivingStyle(BackupBack1, 318)
		Wait(100)
		SetDriverAbility(pilot, 100.0)
		SetDriverAbility(BackupBack1, 100.0)
		MissionStart = 1
		difficulty = 2
		packingtime = Config.PackingTimeMedium * 1000
		TriggerEvent('AttackTransport:driverhealth')
		TriggerEvent('AttackTransport:truckhealth')
		TriggerEvent('AttackTransport:driverdied')
		TriggerEvent('AttackTransport:alertmode')

		exports['geo-interface']:SetPed(transport, 'Plant C4', function()
			TriggerEvent('client:rebentaraquelamerda')
		end)
	end

	if ZoneName == 'large-zone' then

		TriggerEvent('RemoveZone', 'large-zone')
		RequestModel(GetHashKey('stockade'))
		while not HasModelLoaded(GetHashKey('stockade')) do
		Citizen.Wait(0)
		end

		RequestModel(GetHashKey("speedo"))
		while not HasModelLoaded(GetHashKey("speedo")) do
		Citizen.Wait(0)
		end

		
		ClearAreaOfVehicles(VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, 15.0, false, false, false, false, false)
		transport = CreateVehicle(GetHashKey('stockade'), VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleHeading, true, true)
		Wait(5)
		BackupBack = CreateVehicle(GetHashKey('speedo'), BackupBackCoords.x, BackupBackCoords.y, BackupBackCoords.z, BackupBackHeading, true, true)
		Wait(5)
		BackupFront = CreateVehicle(GetHashKey('speedo'), BackupFrontCoords.x, BackupFrontCoords.y, BackupFrontCoords.z, BackupFrontHeading, true, true)
		Wait(5)
		SetEntityAsMissionEntity(transport)
		SetEntityAsMissionEntity(BackupBack)
		SetEntityAsMissionEntity(BackupFront)
		TruckBlip = AddBlipForEntity(transport)
		SetBlipSprite(TruckBlip, 67)
		SetBlipColour(TruckBlip, 1)
		SetBlipFlashes(TruckBlip, true)
		SetBlipScale(TruckBlip, 0.5)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(Lang("info.van_label"))
		EndTextCommandSetBlipName(TruckBlip)
		SetVehicleDirtLevel(transport, 0.0)

		SetVehicleModKit(BackupFront, 0)
		SetVehicleMod(BackupFront, 0, 1, 1)
		SetVehicleMod(BackupFront, 1, 15, 1)
		SetVehicleMod(BackupFront, 2, 0, 1)
		SetVehicleMod(BackupFront, 3, 1, 1)
		SetVehicleColours(BackupFront, 111, 0)
		SetVehicleDashboardColour(BackupFront, 111)
		SetVehicleWindowTint(BackupFront, 3)
		SetVehicleDirtLevel(BackupFront, 0.0)
		SetVehicleWindowTint(BackupFront, 2)
		SetVehicleLivery(BackupFront, 6)

		SetVehicleModKit(BackupBack, 0)
		SetVehicleMod(BackupBack, 0, 1, 1)
		SetVehicleMod(BackupBack, 1, 15, 1)
		SetVehicleMod(BackupBack, 2, 0, 1)
		SetVehicleMod(BackupBack, 3, 1, 1)
		SetVehicleColours(BackupBack, 111, 0)
		SetVehicleDashboardColour(BackupBack, 111)
		SetVehicleWindowTint(BackupBack, 3)
		SetVehicleDirtLevel(BackupBack, 0.0)
		SetVehicleWindowTint(BackupBack, 2)
		SetVehicleLivery(BackupBack, 6)

		RequestModel("s_m_m_security_01")
		while not HasModelLoaded("s_m_m_security_01") do
		Wait(10)
		end

		RequestModel("s_m_m_armoured_01")
		while not HasModelLoaded("s_m_m_armoured_01") do
		Wait(10)
		end

		pilot = CreatePed(26, "s_m_m_security_01", VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleHeading, true, true)
		navigator = CreatePed(26, "s_m_m_armoured_01", VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleHeading, true, true)
		BackupBack1 = CreatePed(26, "s_m_m_security_01", VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleHeading, true, true)
		BackupBack2 = CreatePed(26, "s_m_m_armoured_01", VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleHeading, true, true)
		BackupBack3 = CreatePed(26, "s_m_m_armoured_01", VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleHeading, true, true)
		BackupBack4 = CreatePed(26, "s_m_m_armoured_01", VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleHeading, true, true)
		BackupFront1 = CreatePed(26, "s_m_m_security_01", VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleHeading, true, true)
		BackupFront2 = CreatePed(26, "s_m_m_armoured_01", VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleHeading, true, true)
		BackupFront3 = CreatePed(26, "s_m_m_armoured_01", VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleHeading, true, true)
		BackupFront4 = CreatePed(26, "s_m_m_armoured_01", VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleHeading, true, true)
		
		TriggerServerEvent("Ped.Control", PedToNet(pilot), true)
		TriggerServerEvent("Ped.Control", PedToNet(navigator), true)
		TriggerServerEvent("Ped.Control", PedToNet(BackupBack1), true)
		TriggerServerEvent("Ped.Control", PedToNet(BackupBack2), true)
		TriggerServerEvent("Ped.Control", PedToNet(BackupBack3), true)
		TriggerServerEvent("Ped.Control", PedToNet(BackupBack4), true)
		TriggerServerEvent("Ped.Control", PedToNet(BackupFront1), true)
		TriggerServerEvent("Ped.Control", PedToNet(BackupFront2), true)
		TriggerServerEvent("Ped.Control", PedToNet(BackupFront3), true)
		TriggerServerEvent("Ped.Control", PedToNet(BackupFront4), true)

		SetPedIntoVehicle(pilot, transport, -1)
		SetPedIntoVehicle(navigator, transport, 0)
		SetPedIntoVehicle(BackupBack1, BackupBack, -1)
		SetPedIntoVehicle(BackupBack2, BackupBack, 0)
		SetPedIntoVehicle(BackupBack3, BackupBack, 1)
		SetPedIntoVehicle(BackupBack4, BackupBack, 2)
		SetPedIntoVehicle(BackupFront1, BackupFront, -1)
		SetPedIntoVehicle(BackupFront2, BackupFront, 0)
		SetPedIntoVehicle(BackupFront3, BackupFront, 1)
		SetPedIntoVehicle(BackupFront4, BackupFront, 2)

		SetEntityAsMissionEntity(pilot)
		SetEntityAsMissionEntity(navigator)
		SetEntityAsMissionEntity(BackupBack1)
		SetEntityAsMissionEntity(BackupBack2)
		SetEntityAsMissionEntity(BackupBack3)
		SetEntityAsMissionEntity(BackupBack4)
		SetEntityAsMissionEntity(BackupFront1)
		SetEntityAsMissionEntity(BackupFront2)
		SetEntityAsMissionEntity(BackupFront3)
		SetEntityAsMissionEntity(BackupFront4)

		SetPedFleeAttributes(pilot, 0, 0)
		SetPedCombatAttributes(pilot, 46, 0)
		SetPedCombatAbility(pilot, 2)
		SetPedCombatMovement(pilot, 2)
		SetPedCombatRange(pilot, 2)
		SetPedKeepTask(pilot, true)
		GiveWeaponToPed(pilot, GetHashKey(Config.FrontSeatsGun),250,false,true)
		SetPedAsCop(pilot, true)
		SetPedRelationshipGroupHash(pilot, 'Evade')

		SetPedFleeAttributes(navigator, 0, 0)
		SetPedCombatAttributes(navigator, 46, 1)
		SetPedCombatAttributes(navigator, 2, 1)
		SetPedCombatAbility(navigator, 2)
		SetPedCombatMovement(navigator, 2)
		SetPedCombatRange(navigator, 2)
		SetPedKeepTask(navigator, true)
		TaskEnterVehicle(navigator,transport,-1,0,1.0,1)
		GiveWeaponToPed(navigator, GetHashKey(Config.FrontSeatsGun),250,false,true)
		SetPedAsCop(navigator, true)
		SetPedRelationshipGroupHash(navigator, 'Gruppe6')

		SetPedFleeAttributes(BackupBack1, 0, 0)
		SetPedCombatAttributes(BackupBack1, 46, 0)
		SetPedCombatAbility(BackupBack1, 2)
		SetPedCombatMovement(BackupBack1, 2)
		SetPedCombatRange(BackupBack1, 2)
		SetPedKeepTask(BackupBack1, true)
		GiveWeaponToPed(BackupBack1, GetHashKey(Config.FrontSeatsGun),250,false,true)
		SetPedAsCop(BackupBack1, true)
		SetPedRelationshipGroupHash(BackupBack1, 'Evade')

		SetPedFleeAttributes(BackupBack2, 0, 0)
		SetPedCombatAttributes(BackupBack2, 46, 1)
		SetPedCombatAttributes(BackupBack2, 2, 1)
		SetPedCombatAbility(BackupBack2, 2)
		SetPedCombatMovement(BackupBack2, 2)
		SetPedCombatRange(BackupBack2, 2)
		SetPedKeepTask(BackupBack2, true)
		TaskEnterVehicle(BackupBack2,BackupBack,-1,0,1.0,1)
		GiveWeaponToPed(BackupBack2, GetHashKey(Config.FrontSeatsGun),250,false,true)
		SetPedAsCop(BackupBack2, true)
		SetPedRelationshipGroupHash(BackupBack2, 'Gruppe6')

		SetPedFleeAttributes(BackupBack3, 0, 0)
		SetPedCombatAttributes(BackupBack3, 46, 1)
		SetPedCombatAttributes(BackupBack3, 2, 1)
		SetPedCombatAbility(BackupBack3, 2)
		SetPedCombatMovement(BackupBack3, 2)
		SetPedCombatRange(BackupBack3, 2)
		SetPedKeepTask(BackupBack3, true)
		TaskEnterVehicle(BackupBack3,BackupBack,-1,1,1.0,1)
		GiveWeaponToPed(BackupBack3, GetHashKey(Config.BackSeatsGun),250,false,true)
		SetPedAsCop(BackupBack3, true)
		SetPedRelationshipGroupHash(BackupBack3, 'Gruppe6')

		SetPedFleeAttributes(BackupBack4, 0, 0)
		SetPedCombatAttributes(BackupBack4, 46, 1)
		SetPedCombatAttributes(BackupBack4, 2, 1)
		SetPedCombatAbility(BackupBack4, 2)
		SetPedCombatMovement(BackupBack4, 2)
		SetPedCombatRange(BackupBack4, 2)
		SetPedKeepTask(BackupBack4, true)
		TaskEnterVehicle(BackupBack4,BackupBack,-1,2,1.0,1)
		GiveWeaponToPed(BackupBack4, GetHashKey(Config.BackSeatsGun),250,false,true)
		SetPedAsCop(BackupBack4, true)
		SetPedRelationshipGroupHash(BackupBack4, 'Gruppe6')

		SetPedFleeAttributes(BackupFront1, 0, 0)
		SetPedCombatAttributes(BackupFront1, 46, 1)
		SetPedCombatAbility(BackupFront1, 2)
		SetPedCombatMovement(BackupFront1, 2)
		SetPedCombatRange(BackupFront1, 2)
		SetPedKeepTask(BackupFront1, true)
		GiveWeaponToPed(BackupFront1, GetHashKey(Config.FrontSeatsGun),250,false,true)
		SetPedAsCop(BackupFront1, true)
		SetPedRelationshipGroupHash(BackupFront1, 'Evade')

		SetPedFleeAttributes(BackupFront2, 0, 0)
		SetPedCombatAttributes(BackupFront2, 46, 1)
		SetPedCombatAttributes(BackupFront2, 2, 1)
		SetPedCombatAbility(BackupFront2, 2)
		SetPedCombatMovement(BackupFront2, 2)
		SetPedCombatRange(BackupFront2, 2)
		SetPedKeepTask(BackupFront2, true)
		TaskEnterVehicle(ped, vehicle, timeout, seat, speed, flag, p6)
		TaskEnterVehicle(BackupFront2,Backup,-1,0,1.0,1)
		GiveWeaponToPed(BackupFront2, GetHashKey(Config.FrontSeatsGun),250,false,true)
		SetPedAsCop(BackupFront2, true)
		SetPedRelationshipGroupHash(BackupFront2, 'Gruppe6')

		SetPedFleeAttributes(BackupFront3, 0, 0)
		SetPedCombatAttributes(BackupFront3, 46, 1)
		SetPedCombatAttributes(BackupFront3, 2, 1)
		SetPedCombatAbility(BackupFront3, 2)
		SetPedCombatMovement(BackupFront3, 2)
		SetPedCombatRange(BackupFront3, 2)
		SetPedKeepTask(BackupFront3, true)
		TaskEnterVehicle(BackupFront3,Backup,-1,1,1.0,1)
		GiveWeaponToPed(BackupFront3, GetHashKey(Config.BackSeatsGun),250,false,true)
		SetPedAsCop(BackupFront3, true)
		SetPedRelationshipGroupHash(BackupFront3, 'Gruppe6')

		SetPedFleeAttributes(BackupFront4, 0, 0)
		SetPedCombatAttributes(BackupFront4, 46, 1)
		SetPedCombatAttributes(BackupFront4, 2, 1)
		SetPedCombatAbility(BackupFront4, 2)
		SetPedCombatMovement(BackupFront4, 2)
		SetPedCombatRange(BackupFront4, 2)
		SetPedKeepTask(BackupFront4, true)
		TaskEnterVehicle(BackupFront4,Backup,-1,2,1.0,1)
		GiveWeaponToPed(BackupFront4, GetHashKey(Config.BackSeatsGun),250,false,true)
		SetPedAsCop(BackupFront4, true)
		SetPedRelationshipGroupHash(BackupFront4, 'Gruppe6')

		Wait(3000)
		SetRelationshipBetweenGroups(1, 'Evade', GetHashKey("PLAYER"))
		SetRelationshipBetweenGroups(4, 'Gruppe6', GetHashKey("PLAYER"))
		TaskVehicleDriveWander(pilot, transport, 25.0, 447)
		SetDriveTaskDrivingStyle(BackupFront1, 787263)
		SetDriveTaskDrivingStyle(BackupBack1, 787263)
		Wait(100)
		TaskVehicleChase(BackupBack1, pilot)
		TaskVehicleChase(BackupFront1, BackupBack1)
		Wait(100)
		SetTaskVehicleChaseBehaviorFlag(BackupFront1, 32, true)
		SetTaskVehicleChaseBehaviorFlag(BackupBack1, 32, true)
		Wait(100)
		SetTaskVehicleChaseIdealPursuitDistance(BackupFront1, 15.0)
		SetTaskVehicleChaseIdealPursuitDistance(BackupBack1, 15.0)
		Wait(100)
		SetDriveTaskDrivingStyle(BackupFront1, 787263)
		SetDriveTaskDrivingStyle(BackupBack1, 787263)
		Wait(100)
		SetDriverAbility(pilot, 100.0)
		SetDriverAbility(BackupFront1, 100.0)
		SetDriverAbility(BackupBack1, 100.0)
		MissionStart = 1
		difficulty = 3
		packingtime = Config.PackingTimeHigh * 1000
		TriggerEvent('AttackTransport:driverhealth')
		TriggerEvent('AttackTransport:truckhealth')
		TriggerEvent('AttackTransport:driverdied')
		TriggerEvent('AttackTransport:alertmode')

		exports['geo-interface']:SetPed(transport, 'Plant C4', function()
			TriggerEvent('client:rebentaraquelamerda')
		end)
	end
end)

RegisterNetEvent('AttackTransport:Medium')
AddEventHandler('AttackTransport:Medium', function()
	MissionStart = 1
	TriggerEvent('PhoneNotif', 'messages', "We'll let you know the trucks location soon")
	
	Wait(Config.TimeToReceiveJob)	
	
	TriggerEvent('PhoneNotif', 'messages', "Truck has been located, marked on your GPS")
	local DrawCoord = math.random(1,5)
	if DrawCoord == 1 then
	VehicleCoords = VehicleSpawn1
	VehicleHeading = VehicleHeading1
	BackupBackCoords = BackupBackSpawn1
	BackupBackHeading = BackupBackHeading1
	elseif DrawCoord == 2 then
	VehicleCoords = VehicleSpawn2
	VehicleHeading = VehicleHeading2
	BackupBackCoords = BackupBackSpawn2
	BackupBackHeading = BackupBackHeading2
	elseif DrawCoord == 3 then
	VehicleCoords = VehicleSpawn3
	VehicleHeading = VehicleHeading3
	BackupBackCoords = BackupBackSpawn3
	BackupBackHeading = BackupBackHeading3
	elseif DrawCoord == 4 then
	VehicleCoords = VehicleSpawn4
	VehicleHeading = VehicleHeading4
	BackupBackCoords = BackupBackSpawn4
	BackupBackHeading = BackupBackHeading4
	elseif DrawCoord == 5 then
	VehicleCoords = VehicleSpawn5
	VehicleHeading = VehicleHeading5
	BackupBackCoords = BackupBackSpawn5
	BackupBackHeading = BackupBackHeading5
	end

	AddBoxZone(vec(VehicleCoords.x, VehicleCoords.y, VehicleCoords.z), 210.0, 210.0, {
		name = "medium-zone",
        debugPoly = false,
        heading = 138.14,
        minZ = VehicleCoords.z - 7,
        maxZ = VehicleCoords.z + 7,
    })

	SetNewWaypoint(VehicleCoords.x, VehicleCoords.y)	
end)

RegisterNetEvent('AttackTransport:Large')
AddEventHandler('AttackTransport:Large', function()
	MissionStart = 1
	TriggerEvent('PhoneNotif', 'messages', "We'll let you know the trucks location soon")
	Wait(Config.TimeToReceiveJob)
	local DrawCoord = math.random(1,5)
	if DrawCoord == 1 then
	VehicleCoords = VehicleSpawn1
	VehicleHeading = VehicleHeading1
	BackupBackCoords = BackupBackSpawn1
	BackupBackHeading = BackupBackHeading1
	BackupFrontCoords = BackupFrontSpawn1
	BackupFrontHeading = BackupFrontHeading1
	elseif DrawCoord == 2 then
	VehicleCoords = VehicleSpawn2
	VehicleHeading = VehicleHeading2
	BackupBackCoords = BackupBackSpawn2
	BackupBackHeading = BackupBackHeading2
	BackupFrontCoords = BackupFrontSpawn2
	BackupFrontHeading = BackupFrontHeading2
	elseif DrawCoord == 3 then
	VehicleCoords = VehicleSpawn3
	VehicleHeading = VehicleHeading3
	BackupBackCoords = BackupBackSpawn3
	BackupBackHeading = BackupBackHeading3
	BackupFrontCoords = BackupFrontSpawn3
	BackupFrontHeading = BackupFrontHeading3
	elseif DrawCoord == 4 then
	VehicleCoords = VehicleSpawn4
	VehicleHeading = VehicleHeading4
	BackupBackCoords = BackupBackSpawn4
	BackupBackHeading = BackupBackHeading4
	BackupFrontCoords = BackupFrontSpawn4
	BackupFrontHeading = BackupFrontHeading4
	elseif DrawCoord == 5 then
	VehicleCoords = VehicleSpawn5
	VehicleHeading = VehicleHeading5
	BackupBackCoords = BackupBackSpawn5
	BackupBackHeading = BackupBackHeading5
	BackupFrontCoords = BackupFrontSpawn5
	BackupFrontHeading = BackupFrontHeading5
	end

	AddBoxZone(vec(VehicleCoords.x, VehicleCoords.y, VehicleCoords.z), 210.0, 210.0, {
		name = "large-zone",
        debugPoly = false,
        heading = 138.14,
        minZ = VehicleCoords.z - 7,
        maxZ = VehicleCoords.z + 7,
    })

	SetNewWaypoint(VehicleCoords.x, VehicleCoords.y)

	
end)

RegisterNetEvent('AttackTransport:driverhealth')
AddEventHandler('AttackTransport:driverhealth', function()
	while true do
       	Wait(500)			
		   if Complete == true then break else
		DriverDead = GetEntityHealth(pilot)
			if DriverDead == 0 then SetVehicleEngineOn(transport, false) break
		end
	end
end
end)

RegisterNetEvent('AttackTransport:truckhealth')
AddEventHandler('AttackTransport:truckhealth', function()
	while true do
       	Wait(500)
			local TruckCoords = GetEntityCoords(transport)
            local PlyCoords = GetEntityCoords(PlayerPedId())
            local dist = #(TruckCoords - PlyCoords)
		    TruckHealth = GetEntityHealth(transport)
			if Complete == true then break
			else
			if TruckHealth == 0 and dist <= 200 then TriggerEvent('Shared.Notif', Lang("error.brok")) TriggerEvent('AttackTransport:CleanUp') break
		end
	end
end
end)

RegisterNetEvent('AttackTransport:driverdied')
AddEventHandler('AttackTransport:driverdied', function()
	while true do
	Wait(500)	
		if Complete == true then break else
		if MissionStart == 1 and DriverDead == 0 then
			Wait(30)
			ClearPedTasks(BackupBack1)
			ClearPedTasks(BackupFront1)
			Wait(30)
			SetPedRelationshipGroupHash(pilot, 'Gruppe6')
			Wait(30)
			SetPedRelationshipGroupHash(BackupFront1, 'Gruppe6')
			Wait(30)
			SetPedRelationshipGroupHash(BackupBack1, 'Gruppe6')
			Wait(30)
			SetRelationshipBetweenGroups(5, 'Gruppe6', GetHashKey("PLAYER"))
			Wait(30)
			TaskVehicleChase(BackupBack1, transport)
			TaskVehicleChase(BackupFront1, transport)
			SetDriveTaskDrivingStyle(BackupBack1, 21758508)
			SetDriveTaskDrivingStyle(BackupFront1, 21758508)
			TaskCombatPed(BackupBack1, PlayerPedId(), 0, 16)
			TaskCombatPed(BackupBack2, PlayerPedId(), 0, 16)
			TaskCombatPed(BackupBack3, PlayerPedId(), 0, 16)
			TaskCombatPed(BackupBack4, PlayerPedId(), 0, 16)
			TaskCombatPed(BackupFront1, PlayerPedId(), 0, 16)
			TaskCombatPed(BackupFront2, PlayerPedId(), 0, 16)
			TaskCombatPed(BackupFront3, PlayerPedId(), 0, 16)
			TaskCombatPed(BackupFront4, PlayerPedId(), 0, 16)
			TaskLeaveVehicle(navigator, transport, 256)
			SetPedRagdollBlockingFlags(navigator, 1)
			SetPedRagdollBlockingFlags(BackupBack1, 1)
			SetPedRagdollBlockingFlags(BackupBack2, 1)
			SetPedRagdollBlockingFlags(BackupBack3, 1)
			SetPedRagdollBlockingFlags(BackupBack4, 1)
			SetPedRagdollBlockingFlags(BackupFront1, 1)
			SetPedRagdollBlockingFlags(BackupFront2, 1)
			SetPedRagdollBlockingFlags(BackupFront3, 1)
			SetPedRagdollBlockingFlags(BackupFront4, 1)
			SetPedCombatMovement(navigator, 1)
			SetPedCombatMovement(BackupBack1, 1)
			SetPedCombatMovement(BackupBack2, 2)
			SetPedCombatMovement(BackupBack3, 2)
			SetPedCombatMovement(BackupBack4, 3)
			SetPedCombatMovement(BackupFront1, 1)
			SetPedCombatMovement(BackupFront2, 2)
			SetPedCombatMovement(BackupFront3, 2)
			SetPedCombatMovement(BackupFront4, 3)
			Wait(5)
			SetPedRelationshipGroupHash(pilot, 'Gruppe6')
			SetPedRelationshipGroupHash(BackupFront1, 'Gruppe6')
			SetPedRelationshipGroupHash(BackupBack2, 'Gruppe6')
			TaskLeaveVehicle(BackupBack1, BackupBack, 256)
			TaskLeaveVehicle(BackupFront1, BackupFront, 256)
			break
		end
	end
end
end)

RegisterNetEvent('AttackTransport:alertmode')
AddEventHandler('AttackTransport:alertmode', function()
	while true do
       	Wait(500)	
		   if Complete == true then break else
		   local check1 = IsPlayerFreeAimingAtEntity(PlayerId(), pilot)
		   local check2 = IsPlayerFreeAimingAtEntity(PlayerId(), BackupBack1)
		   local check3 = IsPlayerFreeAimingAtEntity(PlayerId(), BackupFront1)
		if check1 or check2 or check3 == 1 then
			Wait(100)
			TaskSmartFleePed(pilot, PlayerPedId(), 100, -1)
			Wait(100)
			TaskVehicleChase(BackupBack1, transport)
			TaskVehicleChase(BackupFront1, BackupBack)
			Wait(100)
			SetDriveTaskDrivingStyle(BackupBack1, 21758508)
			SetDriveTaskDrivingStyle(BackupFront1, 21758508)
			Wait(100)
			SetTaskVehicleChaseBehaviorFlag(BackupFront1, 32, true)
			SetTaskVehicleChaseBehaviorFlag(BackupBack1, 32, true)
			SetDriverAbility(pilot, 100.0)
			SetDriverAbility(BackupFront1, 100.0)
			SetDriverAbility(BackupBack1, 100.0)
			TaskCombatPed(BackupBack2, PlayerPedId(), 0, 16)
			TaskCombatPed(BackupBack3, PlayerPedId(), 0, 16)
			TaskCombatPed(BackupBack4, PlayerPedId(), 0, 16)
			TaskCombatPed(BackupFront2, PlayerPedId(), 0, 16)
			TaskCombatPed(BackupFront3, PlayerPedId(), 0, 16)
			TaskCombatPed(BackupFront4, PlayerPedId(), 0, 16)
			TaskCombatPed(navigator, PlayerPedId(), 0, 16)
			break
		end
	end
end
end)

RegisterNetEvent("client:rebentaraquelamerda", function()
	if exports['geo-inventory']:HasItemKey('c4') then
		TriggerServerEvent('RemoveItemKey', 'c4', 1)
	else
		TriggerEvent('Shared.Notif', 'You do not have C4')
		return
	end

	if IsVehicleSeatFree(transport, -1) then
		CheckVehicleInformation()
		exports['geo-interface']:SetPed(transport, 'Grab Cash', function() TriggerEvent('client:roubarfodase') end)
	else
		TriggerEvent('Shared.Notif', 'Remove the driver')
	end
end)

RegisterNetEvent("client:roubarfodase", function()
	TakingMoney()
end)

function CheckVehicleInformation()
	
			SetVehicleDoorsLockedForAllPlayers(transport, true)
			if not IsEntityInWater(PlayerPedId()) then
				RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
				RequestModel("hei_p_m_bag_var22_arm_s")
				while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") or not HasModelLoaded("hei_p_m_bag_var22_arm_s") do Wait(50) end
				local transCoords = GetEntityCoords(transport)
				local pos = GetWorldPositionOfEntityBone(transport, GetEntityBoneIndexByName(transport, 'door_pside_r'))
				Wait(100)
				local rotx, roty, rotz = table.unpack(vec3(GetEntityRotation(PlayerPedId())))
				local netscene = NetworkCreateSynchronisedScene(pos.x, pos.y, pos.z-0.7, rotx, roty, rotz, 2, false, false, 1065353216, 0, 1.3)
				local bag = CreateObject(`hei_p_m_bag_var22_arm_s`, pos.x, pos.y, pos.z-0.7,  true,  true, false)
				SetEntityCollision(bag, false, true)
				SetEntityHeading(bag, GetEntityHeading(transport))
				SetEntityHeading(PlayerPedId(), GetEntityHeading(transport))
				local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
				local ped = PlayerPedId()
				prop = CreateObject(GetHashKey('prop_c4_final_green'), x, y, z+0.2,  true,  true, true)
				AttachEntityToEntity(prop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 60309), 0.06, 0.0, 0.03, 90.0, 0.0, 0.0, true, true, false, true, 1, true)
				SetEntityCollision(prop, false, true)
				TaskPlayAnim(PlayerPedId(), 'anim@heists@ornate_bank@thermal_charge', "thermal_charge", 3.0, -8, -1, 32, 0, 0, 0, 0)
				NetworkAddPedToSynchronisedScene(PlayerPedId(), netscene, "anim@heists@ornate_bank@thermal_charge", "thermal_charge", 1.5, -4.0, 1, 16, 1148846080, 0)
    			NetworkAddEntityToSynchronisedScene(bag, netscene, "anim@heists@ornate_bank@thermal_charge", "bag_thermal_charge", 4.0, -8.0, 1)
    			NetworkStartSynchronisedScene(netscene)
				Wait(4700)
				DetachEntity(prop)
				DeleteEntity(bag)
				AttachEntityToEntity(prop, transport, GetEntityBoneIndexByName(transport, 'door_pside_r'), -0.085, 0.0, -0.6, 0.0, 0.5, 0.0, true, true, false, true, 1, true)
				NetworkStopSynchronisedScene(netscene)
				TriggerEvent('Shared.Notif', Lang("error.c4_brror", 3000))
	
				Wait(TimeToBlow)
				SetVehicleDoorBroken(transport, 3, false)
				local proppos = GetEntityCoords(prop)
				AddExplosion(proppos.x, proppos.y, proppos.z+0.7, 'EXPLOSION_TANKER', 2.0, true, false, 2.0)
				ApplyForceToEntity(transport, 0, transCoords.x,transCoords.y,transCoords.z, 0.0, 0.0, 0.0, 1, false, true, true, true, true)
				DeleteEntity(prop)
				BlownUp = 1
				lootable = 1
				TriggerEvent('Shared.Notif', Lang("success.coey"), "success")
				RemoveBlip(TruckBlip)
			else
				TriggerEvent('Shared.Notif', Lang("error.wateor"))
			end
		
end

RegisterNetEvent('AttackTransport:CleanUp')
AddEventHandler('AttackTransport:CleanUp', function()
	Complete = true
	RemoveBlip(TruckBlip)
	PickupMoney = 0
	BlowBackdoor = 0
	LootTime = 1
	GuardsDead = 0
	lootable = 0
	BlownUp = 0
	MissionStart = 0
	warning = 0
	SetEntityAsNoLongerNeeded(transport)
	SetEntityAsNoLongerNeeded(pilot)
	SetEntityAsNoLongerNeeded(navigator)
	SetEntityAsNoLongerNeeded(BackupBack)
	SetEntityAsNoLongerNeeded(BackupBack1)
	SetEntityAsNoLongerNeeded(BackupBack2)
	SetEntityAsNoLongerNeeded(BackupBack3)
	SetEntityAsNoLongerNeeded(BackupBack4)
	SetEntityAsNoLongerNeeded(BackupFront)
	SetEntityAsNoLongerNeeded(BackupFront1)
	SetEntityAsNoLongerNeeded(BackupFront2)
	SetEntityAsNoLongerNeeded(BackupFront3)
	SetEntityAsNoLongerNeeded(BackupFront4)
	exports['geo-interface']:SetPed(transport, nil)
end)

function TakingMoney()
	RequestAnimDict('anim@heists@ornate_bank@grab_cash_heels')
	while not HasAnimDictLoaded('anim@heists@ornate_bank@grab_cash_heels') do
		Citizen.Wait(50)
	end

	RequestModel(GetHashKey('prop_cs_heist_bag_02'))
	while not HasModelLoaded(GetHashKey('prop_cs_heist_bag_02')) do
		Wait(0)
	end

	local PedCoords = GetEntityCoords(PlayerPedId())
	bag = CreateObject(GetHashKey('prop_cs_heist_bag_02'),PedCoords.x, PedCoords.y,PedCoords.z, true, true, true)
	AttachEntityToEntity(bag, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.0, 0.0, -0.16, 250.0, -30.0, 0.0, false, false, false, false, 2, true)
	TaskPlayAnim(PlayerPedId(), "anim@heists@ornate_bank@grab_cash_heels", "grab", 8.0, -8.0, -1, 1, 0, false, false, false)

	local terminate
	local finish
	exports['geo-shared']:Progress('Looting The Truck', 30000, function(res, term)
		terminate = term
		if res then
			finish = true
		end
	end)

	while finish == nil do
		Wait(250)
		if not IsEntityPlayingAnim(Shared.Ped, "anim@heists@ornate_bank@grab_cash_heels", "grab", 1) then
			finish = false
			terminate()
			break
		end
	end

	DeleteEntity(bag)
	StopAnimTask(Shared.Ped, "anim@heists@ornate_bank@grab_cash_heels", "grab", 1.0)

	if finish then
		TriggerServerEvent("AttackTransport:Reward")
		TriggerEvent('AttackTransport:CleanUp')
		Wait(10000)
		TriggerEvent('AttackTransport:CleanUp')
	end
end

