-- Source: https://github.com/ZAUB1/ESX-Binoculars author ZAUB1
-- Source script heavily based and used many elements of https://github.com/mraes/FiveM-scripts/tree/master/heli

-- This release: Removed unused code. Changed UI to use binocular scaleform.
--				 Fixed zoom in/out. Added keybind support
--				 twitch.tv/SerpicoTV
--CONFIG--
local fov_max = 70.0
local fov_min = 5.0 -- max zoom level (smaller fov is more zoom)
local zoomspeed = 10.0 -- camera zoom speed
local speed_lr = 8.0 -- speed by which the camera pans left-right
local speed_ud = 8.0 -- speed by which the camera pans up-down

local binoculars = false
local fov = (fov_max+fov_min)*0.5

AddEventHandler('Use:binoculars', function()
    binoculars = not binoculars
    if binoculars then
        binoculars = true
        if not ( IsPedSittingInAnyVehicle( Shared.Ped ) ) then
            CreateThread(function()
                TaskStartScenarioInPlace(GetPlayerPed(-1), "WORLD_HUMAN_BINOCULARS", 0, 1)
                PlayAmbientSpeech1(GetPlayerPed(-1), "GENERIC_CURSE_MED", "SPEECH_PARAMS_FORCE")
            end)
        end

        Wait(1000)

        local scaleform = RequestScaleformMovie("BINOCULARS")
        while not HasScaleformMovieLoaded(scaleform) do
            Wait(10)
        end

        local vehicle = GetVehiclePedIsIn(Shared.Ped)
        local cam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)

        AttachCamToEntity(cam, Shared.Ped, 0.0,0.0,1.0, true)
        SetCamRot(cam, 0.0,0.0,GetEntityHeading(Shared.Ped))
        SetCamFov(cam, fov)
        RenderScriptCams(true, false, 0, 1, 0)
        PushScaleformMovieFunction(scaleform, "SET_CAM_LOGO")
        PushScaleformMovieFunctionParameterInt(0) -- 0 for nothing, 1 for LSPD logo
        PopScaleformMovieFunctionVoid()

        while binoculars and not IsEntityDead(Shared.Ped) and (GetVehiclePedIsIn(Shared.Ped) == vehicle) and true do
            local zoomvalue = (1.0/(fov_max-fov_min))*(fov-fov_min)
            CheckInputRotation(cam, zoomvalue)

            HandleZoom(cam)
            HideHUDThisFrame()

            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
            Wait(10)
        end

        binoculars = false
        fov = (fov_max+fov_min)*0.5
        RenderScriptCams(false, false, 0, 1, 0)
        SetScaleformMovieAsNoLongerNeeded(scaleform)
        DestroyCam(cam, false)
        SetNightvision(false)
        SetSeethrough(false)
        ClearPedTasks(Shared.Ped)
    end
end)

--FUNCTIONS--
function HideHUDThisFrame()
	HideHelpTextThisFrame()
	HideHudAndRadarThisFrame()
	HideHudComponentThisFrame(1) -- Wanted Stars
	HideHudComponentThisFrame(2) -- Weapon icon
	HideHudComponentThisFrame(3) -- Cash
	HideHudComponentThisFrame(4) -- MP CASH
	HideHudComponentThisFrame(6)
	HideHudComponentThisFrame(7)
	HideHudComponentThisFrame(8)
	HideHudComponentThisFrame(9)
	HideHudComponentThisFrame(13) -- Cash Change
	HideHudComponentThisFrame(11) -- Floating Help Text
	HideHudComponentThisFrame(12) -- more floating help text
	HideHudComponentThisFrame(15) -- Subtitle Text
	HideHudComponentThisFrame(18) -- Game Stream
	HideHudComponentThisFrame(19) -- weapon wheel
end

function CheckInputRotation(cam, zoomvalue)
	local rightAxisX = GetDisabledControlNormal(0, 220)
	local rightAxisY = GetDisabledControlNormal(0, 221)
	local rotation = GetCamRot(cam, 2)
	if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
		new_z = rotation.z + rightAxisX*-1.0*(speed_ud)*(zoomvalue+0.1)
		new_x = math.max(math.min(20.0, rotation.x + rightAxisY*-1.0*(speed_lr)*(zoomvalue+0.1)), -89.5)
		SetCamRot(cam, new_x, 0.0, new_z, 2)
	end
end

function HandleZoom(cam)
	if not ( IsPedSittingInAnyVehicle( Shared.Ped ) ) then

		if IsControlJustPressed(0,241) then -- Scrollup
			fov = math.max(fov - zoomspeed, fov_min)
		end
		if IsControlJustPressed(0,242) then
			fov = math.min(fov + zoomspeed, fov_max) -- ScrollDown
		end
		local current_fov = GetCamFov(cam)
		if math.abs(fov-current_fov) < 0.1 then
			fov = current_fov
		end
		SetCamFov(cam, current_fov + (fov - current_fov)*0.05)
	else
		if IsControlJustPressed(0,17) then -- Scrollup
			fov = math.max(fov - zoomspeed, fov_min)
		end
		if IsControlJustPressed(0,16) then
			fov = math.min(fov + zoomspeed, fov_max) -- ScrollDown
		end
		local current_fov = GetCamFov(cam)
		if math.abs(fov-current_fov) < 0.1 then -- the difference is too small, just set the value directly to avoid unneeded updates to FOV of order 10^-5
			fov = current_fov
		end
		SetCamFov(cam, current_fov + (fov - current_fov)*0.05) -- Smoothing of camera zoom
	end
end