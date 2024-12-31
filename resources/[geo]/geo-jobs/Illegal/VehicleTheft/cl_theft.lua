AddBoxZone(vector3(-5.71, -627.41, 35.72), 50.4, 33.8, {
    name="VehicleTheft",
    heading=340,
    --debugPoly=true,
    minZ=34.72,
    maxZ=38.72
})

AddBoxZone(vector3(-37.77, -616.89, 35.09), 9.2, 13.2, {
    name="VehicleTheft.Garaage",
    heading=70,
    --debugPoly=true,
    minZ=34.09,
    maxZ=38.09
})

local model = 1224306523
local jobState = 'none'
local startPed
local targetClass
local atGarage = false

local textList = {
    ['none'] = 'Get Job',
    ['phase_1'] = 'Quit Job'
}

AddEventHandler('VehicleTheft.none', function()
    jobState = Task.Run('VehicleTheft.GetJob') or 'none'
    exports['geo-interface']:SetPed(startPed, textList[jobState], 'VehicleTheft.'..jobState)
end)

AddEventHandler('VehicleTheft.phase_1', function()
    jobState = Task.Run('VehicleTheft.Quit') or 'none'
    exports['geo-interface']:SetPed(startPed, textList[jobState], 'VehicleTheft.'..jobState)
end)

local atTheft = false
AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'VehicleTheft' then
        atTheft = inZone

        if atTheft then
            startPed = Shared.SpawnPed(model, vector4(-27.98, -642.44, 35.86, 290.0), true)
            exports['geo-interface']:SetPed(startPed, textList[jobState], 'VehicleTheft.'..jobState)
            SetEntityCoords(startPed, GetEntityCoords(startPed) - vec(0.0, 0.0, GetEntityHeightAboveGround(startPed)))
            FreezeEntityPosition(startPed, true)
            SetEntityInvincible(startPed, true)
            SetBlockingOfNonTemporaryEvents(startPed, true)

            while atTheft do
                Wait(100)
            end

            exports['geo-interface']:SetPed(startPed, nil)
            startPed = DeleteEntity(startPed)
        end
    elseif zone == 'VehicleTheft.Garaage' then
        if not Task.Run('VehicleTheft.Garaage') then return end
        atGarage = inZone

        if atGarage then
            local _int
            while atGarage do
                Wait(0)
                _int = Shared.Interact('[E] Hidden Garage') or _int
                if IsControlJustPressed(0, 38) then
                    TriggerEvent('Garage:Valet', 'CrimGarage', { 
                        Name = 'Hidden Garage',
                        Position = vector3(-38.01, -620.35, 35.08),
                        SpawnPosition = {
                            vector4(-38.01, -620.35, 35.08, 250.0),
                    }})
                    Wait(1000)
                end
            end
            if _int then _int.stop() end
        end
    end
end)

RegisterNetEvent('VehicleTheft.Start')
AddEventHandler('VehicleTheft.Start', function(class)
    TriggerEvent('Shared.Notif', 'Bring us a vehicle of the type: '..GetLabelText('VEH_CLASS_'..class), 5000)
    targetClass = class
end)

RegisterNetEvent('VehicleTheft.UnlockGarage')
AddEventHandler('VehicleTheft.UnlockGarage', function()
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    SetCamCoord(cam, vec(-9.954383, -630.2536, 37.88612))
    SetCamRot(cam, -5.866098, 1.494104e-06, 69.63897)
    DoScreenFadeOut(500)
    Wait(1000)
    RenderScriptCams(1, 1, 0, 1, 1)
    DoScreenFadeIn(500)
    Wait(500)
    TriggerEvent('Shared.Notif', "Due to your continued patronage, we'll let you store any vehicle you want here free of charge", 5000, true)
    Wait(5000)
    DoScreenFadeOut(500)
    Wait(750)
    DestroyCam(cam)
    RenderScriptCams(0, 0, 0, 1, 1)
    DoScreenFadeIn(500)
end)

AddEventHandler('enteredVehicle', function(veh)
    if jobState == 'phase_1' and GetVehicleClass(veh) == targetClass then
        TriggerEvent('Shared.Notif', 'This is what we want, bring it back to the start point', 5000)

        Wait(100)
        local _int
        while Shared.CurrentVehicle == veh do
            if atTheft then
                _int = Shared.Interact('[E] Process Vehicle') or _int
                if IsControlJustPressed(0, 38) then
                    TriggerEvent('Shared.Notif', 'Stay in the car', 5000)
                    if exports['geo-shared']:ProgressSync('Processing Vehicle', 30000) then
                        if Shared.CurrentVehicle == veh then
                            jobState = Task.Run('VehicleTheft.Deliver', VehToNet(veh), GetVehicleClass(veh))
                            exports['geo-interface']:SetPed(startPed, textList[jobState], 'VehicleTheft.'..jobState)
                        end
                    end
                end
            else
                Wait(500)
            end
            Wait(0)
        end
        if _int then _int.stop() end
    end
end)