local hour = 8
local minute = 0

CurrentWeather = 'EXTRASUNNY'
local lastWeather = CurrentWeather

Citizen.CreateThread(function()
    TriggerServerEvent('SyncMePls')
end)

SetMillisecondsPerGameMinute(5000)

Citizen.CreateThread(function()
    while true do
        if lastWeather ~= CurrentWeather then
            lastWeather = CurrentWeather
            SetWeatherTypeOverTime(CurrentWeather, 40.0)
            Wait(15000)
        end
        Wait(100) -- Wait 0 seconds to prevent crashing.
        SetArtificialLightsState(blackout)
        SetArtificialLightsStateAffectsVehicles(false)
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist(lastWeather)
        SetWeatherTypeNow(lastWeather)
        SetWeatherTypeNowPersist(lastWeather)
        if lastWeather == 'XMAS' then
            SetForceVehicleTrails(true)
            SetForcePedFootstepsTracks(true)
        else
            SetForceVehicleTrails(false)
            SetForcePedFootstepsTracks(false)
        end
    end
end)

RegisterNetEvent('TimeSync')
AddEventHandler('TimeSync', function(hr, min)
    hour = hr
    minute = min
    NetworkOverrideClockTime(hour, minute, 0)
    SetMillisecondsPerGameMinute(5000)
end)

RegisterNetEvent('WeatherSync')
AddEventHandler('WeatherSync', function(WeatherSync)
    CurrentWeather = WeatherSync
end)