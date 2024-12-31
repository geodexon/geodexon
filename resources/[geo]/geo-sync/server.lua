local hour = 8
local minute = 0
local seconds = 0

local inc = 40

local startTime = 1609477200
print(json.encode(os.date("*t", 1609477200)))

CurrentWeather = "EXTRASUNNY"
AvailableWeatherTypes = {
    'EXTRASUNNY', 
    'CLEAR', 
    'NEUTRAL', 
    'SMOG', 
    'FOGGY', 
    'OVERCAST', 
    'CLOUDS', 
    'CLEARING', 
    'RAIN', 
    'THUNDER', 
    'SNOW', 
    'BLIZZARD', 
    'SNOWLIGHT', 
    'XMAS', 
    'HALLOWEEN',
}

Citizen.CreateThread(function()
    local count = 0
    while true do
        local calc = startTime + ((os.time() - startTime) * 12)
        local date = os.date("*t", calc)
        hour, minute = date.hour, date.min

        count = count + 1
        if count > 10 then
            TriggerClientEvent('TimeSync', -1, hour, minute)
            count = 0
        end

        Wait(5000)
    end
end)

Citizen.CreateThread(function()
    Wait(1000)
    while true do
        NextWeatherStage()
        TriggerClientEvent('WeatherSync', -1, CurrentWeather)
        Wait(300000)
    end
end)

RegisterCommand('weather', function(source, args)
    if source == 0 or GetCharacter(source).username then
        CurrentWeather = args[1]:upper()
        TriggerClientEvent('WeatherSync', source, CurrentWeather)
    end
end)

function NextWeatherStage()
    math.randomseed(os.time())
    math.random()
    math.random()
    math.random()

    if CurrentWeather == "CLEAR" or CurrentWeather == "CLOUDS" or CurrentWeather == "EXTRASUNNY"  then
        local new = math.random(1,2)
        if new == 2 then
            CurrentWeather = "CLEARING"
        else
            CurrentWeather = "OVERCAST"
        end
    elseif CurrentWeather == "CLEARING" or CurrentWeather == "OVERCAST" then
        local new = math.random(1,20)
        if new == 1 then
            if CurrentWeather == "CLEARING" then CurrentWeather = "FOGGY" else CurrentWeather = "CLEARING" end
        elseif new > 18 then
            CurrentWeather = "CLOUDS"
        elseif new == 16 then
            CurrentWeather = "FOGGY"
        elseif new == 14 then
            CurrentWeather = "EXTRASUNNY"
        elseif new == 12 then
            CurrentWeather = "SMOG"
        else
            CurrentWeather = "CLEAR"
        end
    elseif CurrentWeather == "THUNDER" or CurrentWeather == "CLEARING" then
        CurrentWeather = "CLEAR"
    elseif CurrentWeather == "SMOG" or CurrentWeather == "FOGGY" then
        CurrentWeather = "CLEAR"
    end
end

RegisterNetEvent('SyncMePls')
AddEventHandler('SyncMePls', function()
    local source = source
    TriggerClientEvent('TimeSync', source, hour, minute, seconds)
    TriggerClientEvent('WeatherSync', source, CurrentWeather)
end)

function GetTime()
    return {hour = hour, minute = minute}
end

function SetWeather(weather)
    if weather then
        CurrentWeather = weather
    else
        CurrentWeather = 'CLEAR'
    end

    NextWeatherStage()
    TriggerClientEvent('WeatherSync', -1, CurrentWeather)
end

exports('GetTime', GetTime)
exports('SetWeather', SetWeather)