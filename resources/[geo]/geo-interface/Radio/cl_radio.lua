local voiceRange = 1
local voiceRanges = {1.2, 3.0, 7.0}
--[[ local voiceRanges = {3.0, 9.0, 25.0} ]]
local radioOn = false
local radioActive = false
local radioChannel = 100.0
local onCall
local radios = {}
local radioVolume = (GetResourceKvpFloat('volume') == 0.0 and 1.0 or GetResourceKvpFloat('volume'))
local radioClicks = GetResourceKvpInt('clicks') == 0 and true or false
local call = false
local radioProp
local onCall
local reservedChannels = 6
local radioMix 
local normalMix

if CreateAudioSubmix then
    radioMix =  CreateAudioSubmix('radio')
    normalMix = CreateAudioSubmix('normal')
    trunkFx = CreateAudioSubmix('trunk')
    NetworkSetTalkerProximity(voiceRanges[voiceRange] + 0.0)
    CreateThread(function()
        Wait(100)
        SetAudioSubmixEffectRadioFx(radioMix, 0)
        SetAudioSubmixEffectParamInt(radioMix, 0, `default`, 1)
        SetAudioSubmixEffectParamFloat(radioMix, 0, `freq_low`, 300.0)
        SetAudioSubmixEffectParamFloat(radioMix, 0, `freq_high`, 3000.0)
        SetAudioSubmixEffectParamFloat(radioMix, 0, `rm_freq`, 2540.0)
        SetAudioSubmixEffectParamFloat(radioMix, 0, `rm_mix`, 0.8)
        SetAudioSubmixEffectParamFloat(radioMix, 0, `fudge`, 3.0)
        SetAudioSubmixEffectParamFloat(radioMix, 0, `o_freq_low`, 300.0)
        SetAudioSubmixEffectParamFloat(radioMix, 0, `o_freq_hi`, 3000.0)
        AddAudioSubmixOutput(radioMix, 0)
    end)

    CreateThread(function()
        Wait(100)
        SetAudioSubmixEffectRadioFx(0, 0)
        SetAudioSubmixEffectParamInt(0, 0, `default`, 1)
        SetAudioSubmixEffectParamFloat(0, 0, `freq_low`, 300.0)
        SetAudioSubmixEffectParamFloat(0, 0, `freq_high`, 3000.0)
        SetAudioSubmixEffectParamFloat(0, 0, `rm_freq`, 2540.0)
        SetAudioSubmixEffectParamFloat(0, 0, `rm_mix`, 0.8)
        SetAudioSubmixEffectParamFloat(0, 0, `fudge`, 3.0)
        SetAudioSubmixEffectParamFloat(0, 0, `o_freq_low`, 300.0)
        SetAudioSubmixEffectParamFloat(0, 0, `o_freq_hi`, 3000.0)
        SetAudioSubmixEffectParamInt(0, 0, `enabled`, 0)
    end)
end

AddEventHandler('enteredVehicle', function(veh)
    if GetVehicleClass(veh) == 15 or GetVehicleClass(veh) == 16 then
        HeliFx()
    end
end)

function HeliFx()
    SetAudioSubmixEffectRadioFx(0, 0)
    SetAudioSubmixEffectParamInt(0, 0, `default`, 1)
    SetAudioSubmixEffectParamFloat(0, 0, `freq_low`, 100.0)
    SetAudioSubmixEffectParamFloat(0, 0, `freq_high`, 3000.0)
    SetAudioSubmixEffectParamFloat(0, 0, `rm_freq`, 2540.0)
    SetAudioSubmixEffectParamFloat(0, 0, `rm_mix`, 0.8)
    SetAudioSubmixEffectParamFloat(0, 0, `fudge`, 3.0)
    SetAudioSubmixEffectParamFloat(0, 0, `o_freq_low`, 300.0)
    SetAudioSubmixEffectParamFloat(0, 0, `o_freq_hi`, 3000.0)
    SetAudioSubmixEffectParamInt(0, 0, `enabled`, 1)
end

function trunkFx(bool)
    SetAudioSubmixEffectRadioFx(0, 0)
    SetAudioSubmixEffectParamInt(0, 0, `default`, 1)
    SetAudioSubmixEffectParamFloat(0, 0, `freq_low`, 1200.0)
    SetAudioSubmixEffectParamFloat(0, 0, `freq_high`, 1700.0)
    SetAudioSubmixEffectParamFloat(0, 0, `rm_freq`, 100.0)
    SetAudioSubmixEffectParamFloat(0, 0, `rm_mix`, 3.8)
    SetAudioSubmixEffectParamFloat(0, 0, `fudge`, 0.0)
    SetAudioSubmixEffectParamFloat(0, 0, `o_freq_low`, 1200.0)
    SetAudioSubmixEffectParamFloat(0, 0, `o_freq_hi`, 1700.0)
    SetAudioSubmixEffectParamInt(0, 0, `enabled`, bool and 1 or 0)
end

exports('TrunkFX', trunkFx)

AddEventHandler('leftVehicle', function()
    SetAudioSubmixEffectParamInt(0, 0, `enabled`, 0)
end)

RegisterNUICallback('radio.toggle', function(data, cb)
    radioOn = not radioOn
    TriggerEvent('Shared.Notif', 'Radio: '..(radioOn and 'On' or 'Off'))

    for k,v in pairs(radios) do
        if v == radioChannel then
            if CreateAudioSubmix then
                MumbleSetSubmixForServerId(k, radioOn and radioMix or -1)
            end
        end
        SetVolume(k)
    end

    cb()
end)

RegisterNUICallback('radio.volumeup', function(data, cb)
    ExecuteCommand('rvol '..radioVolume + 0.1)
    cb()
end)

RegisterNUICallback('radio.volumedown', function(data, cb)
    ExecuteCommand('rvol '..radioVolume - 0.1)
    cb()
end)

RegisterNUICallback('radio.channel', function(data, cb)
    ExecuteCommand('rc '..data.channel)
    cb()
end)

RegisterNUICallback('radio.clicks', function(data, cb)
    radioClicks = not radioClicks
    TriggerEvent('Shared.Notif', 'Radio Clicks: '..(radioClicks and 'On' or 'Off'))
    SetResourceKvpInt('clicks', radioClicks and 0 or 1)
    cb()
end)

RegisterNUICallback('radio.close', function(data, cb)
    StopAnimTask(Shared.Ped, 'cellphone@', 'cellphone_text_in', 2.0)

    LoadAnim('cellphone@')
    TaskPlayAnim(Shared.Ped, 'cellphone@', 'cellphone_text_out', 4.0, -1, -1, 50, 0, false, false, false)
    Wait(700)
    DeleteEntity(radioProp)
    StopAnimTask(Shared.Ped, 'cellphone@', 'cellphone_text_out', 1.0)
    radioProp = nil
end)


RegisterCommand('rvol', function(source, args)
    local num = tonumber(args[1])
    if num then
        radioVolume = num > 150.0 and 150.0 or num + 0.0
        radioVolume = num < 0.0 and 0.0 or num - 0.0
        radioVolume = round(radioVolume, 1)
        SetResourceKvpFloat('volume', radioVolume)
        TriggerEvent('Shared.Notif', 'Radio Volume Set To: '..radioVolume)

        for k,v in pairs(radios) do
            SetVolume(v)
        end
    else
        TriggerEvent('Shared.Notif', 'Radio Volume Set To: '..radioVolume)
    end
end)

RegisterCommand('r', function()
    if exports['geo-inventory']:HasItem('radio') and (not IsPauseMenuActive()) and not phoneOpen then
        SendNUIMessage({
            interface = 'radio-int',
            channel = radioChannel
        })
        UIFocus(true, true)

        if not radioProp then
            radioProp = Shared.SpawnObject('prop_cs_hand_radio')
            local bone = GetPedBoneIndex(Shared.Ped, 28422)
    
            TriggerEvent('Holster:PauseFor', 1000)
            Wait(0)
            exports['geo-inventory']:ToggleWeapon()
            LoadAnim(Shared.CurrentVehicle ~= 0 and 'cellphone@in_car@ds' or 'cellphone@')
            TaskPlayAnim(Shared.Ped, Shared.CurrentVehicle ~= 0 and 'cellphone@in_car@ds' or 'cellphone@', 'cellphone_text_in', 4.0, -1, -1, 50, 0, false, false, false)
            Wait(200)
            AttachEntityToEntity(radioProp, Shared.Ped, bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, false, false, false, 2, true)
        end
    end
end)


RegisterCommand('rc', function(source, args)
    local num = tonumber(args[1])
    if num then
        for k,v in pairs(radios) do
            if v == radioChannel then
                MumbleSetSubmixForServerId(k, -1)
            end
        end

        radioChannel = round((num <= 1000.0 and CanAccess(num)) and num or radioChannel, 2)
        TriggerEvent('Shared.Notif', 'Radio Channel Set To: '..radioChannel)

        for k,v in pairs(radios) do
            if v == radioChannel then
                if CreateAudioSubmix then
                    MumbleSetSubmixForServerId(k, radioMix)
                end
            end
            SetVolume(v)
        end
    end
end)

function CanAccess(num)
    if num < reservedChannels then
        if not exports['geo-es']:IsEs(MyCharacter.id) then
            return false
        end
    end

    return true
end

RegisterKeyMapping('r', '[Interface] Radio', 'keyboard', 'INSERT')
RegisterKeyMapping('voice', '[Interface] Voice Cycle', 'keyboard', 'x')
local val = RegisterKeyMapping('+radio', '[Interface] Radio On', 'keyboard', 'NULL')

RegisterCommand('voice', function()
    if voiceRanges[voiceRange + 1] == nil then
        voiceRange = 1
    else
        voiceRange = voiceRange + 1
    end
    NetworkSetTalkerProximity(voiceRanges[voiceRange] + 0.0)
    SendNUIMessage({
        interface = 'radio',
        amount = voiceRange
    })
end)

RegisterCommand('+radio', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    if radioOn and exports['geo-inventory']:HasItem('radio') --[[ and call == false ]] then
        if radioChannel then

            SendNUIMessage({
                interface = 'radio.voice',
                talking = 'radio'
            })

            radioActive = true
            TriggerServerEvent('Radio.On', radioChannel)
            
    
            LoadAnim("random@arrests")
            TaskPlayAnim(Shared.Ped, "random@arrests", "generic_radio_chatter", 1.0, 1.0, -1, 51, 1.0, 0, 0, 0)
            while radioActive do
                if not IsEntityPlayingAnim(Shared.Ped, "random@arrests", "generic_radio_chatter", 51) then
                    TaskPlayAnim(Shared.Ped, "random@arrests", "generic_radio_chatter", 4.0, 4.0, -1, 51, 4.0, 0, 0, 0)
                end
    
                SetControlNormal(0, 249, 1.0)
                Wait(0)
            end
        end
    end
end)

RegisterCommand('-radio', function()
    if radioActive and radioChannel then
        StopAnimTask(Shared.Ped, "random@arrests", "generic_radio_chatter", 4.0)
        SendNUIMessage({
            interface = 'radio.voice',
            talking = false
        })

        radioActive = false
        TriggerServerEvent('Radio.Off', radioChannel)
    end
end)

RegisterNetEvent('Radio.On')
AddEventHandler('Radio.On', function(sid, channel)
    if radioOn and channel == radioChannel --[[ and not call ]] and exports['geo-inventory']:HasItem('radio')  then
        radios[sid] = channel
        if radioMix then
            MumbleSetSubmixForServerId(sid, radioMix)
        end
        SetVolume(sid)
        TriggerEvent('Shared.PlaySounds', 'mic_click_on.wav', radioClicks and 0.1 or 0.0)
    end
end)

RegisterNetEvent('Radio.Off')
AddEventHandler('Radio.Off', function(sid, channel)
    if --[[ onCall ~= sid and  ]]radioChannel == channel and radios[sid] == channel then
        TriggerEvent('Shared.PlaySounds', 'mic_click_off.wav', radioClicks and 0.1 or 0.0)
        radios[sid] = nil
        SetVolume(sid)
        Wait(500)
        if radioMix and radios[sid] ~= channel then
            MumbleSetSubmixForServerId(sid, -1)
        end
    end
end)

local calling = false
local called = false

RegisterNetEvent('Phone.Call')
AddEventHandler('Phone.Call', function(sid, num)
    call = true
    calling = false
    called = false

    Wait(100)
    TriggerEvent('Shared.PlaySounds', 'click.mp3', 0.5 )
    onCall = sid 
    SetVolume(sid)
    radios[sid] = -5

    LoadAnim("cellphone@")
    TaskPlayAnim(Shared.Ped, "cellphone@", "cellphone_call_listen_base", 4.0, 4.0, -1, 51, 4.0, 0, 0, 0)
    local phone = Shared.SpawnObject('prop_npc_phone_02')

    AttachEntityToEntity(phone, Shared.Ped, GetPedBoneIndex(Shared.Ped, 28422), -0.05, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 1, 1, 1)
    SendNUIMessage({
        interface = 'phone_start',
        num = num
    })
    while onCall do
        Wait(500)

        if not IsEntityPlayingAnim(Shared.Ped, "cellphone@", "cellphone_call_listen_base", 51) then
            TaskPlayAnim(Shared.Ped, "cellphone@", "cellphone_call_listen_base", 4.0, 4.0, -1, 51, 4.0, 0, 0, 0)
        end

        if not exports['geo-inventory']:HasItemKey('phone') then
            ExecuteCommand('h')
            break
        end
    end

    SendNUIMessage({
        interface = 'phone_end'
    })
    StopAnimTask(Shared.Ped, "cellphone@", "cellphone_call_listen_base", 4.0)
    DeleteEntity(phone)
end)

RegisterNetEvent('Phone.EndCall')
AddEventHandler('Phone.EndCall', function(sid)
    call = false
    calling = false
    called = false

    Wait(100)
    TriggerEvent('Shared.PlaySounds', 'callend.mp3', 0.7 * ((MyUser.data.settings.custom_phone or 100) / 100))

    SendNUIMessage({
        interface = 'call_end'
    })

    if sid then
        onCall = nil
        SetVolume(sid)
    end
end)

RegisterNetEvent('Phone.Calling')
AddEventHandler('Phone.Calling', function(num)
    calling = true
    
    LoadAnim("cellphone@")
    TaskPlayAnim(Shared.Ped, 'cellphone@', 'cellphone_call_listen_base', 1.0, 1.0, -1, 51, 1.0, 0, 0, 0)
    
    local time = GetGameTimer()
    TriggerEvent('Shared.PlaySounds', 'calling.mp3', 0.5 * ((MyUser.data.settings.custom_phone or 100) / 100))
    SendNUIMessage({
        interface = 'phone_calling',
        num = num
    })
    while calling do
        Wait(0)
        if not IsEntityPlayingAnim(Shared.Ped, "cellphone@", 'cellphone_call_listen_base', 51) then
            TaskPlayAnim(Shared.Ped, "cellphone@", 'cellphone_call_listen_base', 4.0, 4.0, -1, 51, 4.0, 0, 0, 0)
        end

        if not exports['geo-inventory']:HasItemKey('phone') then
            ExecuteCommand('h')
            break
        end

        if Shared.TimeSince(time) > 4000 then
            time = GetGameTimer()
            TriggerEvent('Shared.PlaySounds', 'calling.mp3', 0.5 * ((MyUser.data.settings.custom_phone or 100) / 100))
        end
    end
    TriggerEvent('Shared.StopSounds')
    StopAnimTask(Shared.Ped,"cellphone@", "cellphone_call_listen_base", 4.0)
end)

RegisterNetEvent('Phone.Called')
AddEventHandler('Phone.Called', function()
    called = true
    local time = GetGameTimer()
    TriggerEvent('Shared.PlaySounds', 'call.mp3', 0.5 * ((MyUser.data.settings.custom_phone or 100) / 100))
    while called do
        Wait(0)
        if Shared.TimeSince(time) > 14000 then
            time = GetGameTimer()
            TriggerEvent('Shared.PlaySounds', 'call.mp3', 0.5 * ((MyUser.data.settings.custom_phone or 100) / 100))
        end
    end
    TriggerEvent('Shared.StopSounds')
end)

function SetVolume(sid)
    CreateThread(function()
        if onCall == sid then
            MumbleSetVolumeOverrideByServerId(sid, 1.0)
            return
        end
    
        if radioOn and radios[sid] == radioChannel then
            MumbleSetVolumeOverrideByServerId(sid, radioVolume)
        else
            MumbleSetVolumeOverrideByServerId(sid, -1.0)
        end
    end)
end