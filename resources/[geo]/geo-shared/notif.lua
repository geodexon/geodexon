local gval = nil
local textbox = false
local game
GlobalState.commandinfo = '{}'


RegisterNetEvent('Shared.Notif')
AddEventHandler('Shared.Notif', function(message, time, center)
    SendNUIMessage({
        action = 'notif',
        type = 'Inform',
        text = message,
        time = time,
        center = center
    })
    SendNUIMessage({
        type = 'log',
        text = message
    })
end)

RegisterNetEvent('Log')
AddEventHandler('Log', function(message)
    SendNUIMessage({
        type = 'log',
        text = message
    })
end)

RegisterNetEvent('Shared.PlaySounds')
AddEventHandler('Shared.PlaySounds', function(file, volume)
    SendNUIMessage({
        sound = file,
        type = 'Sound',
        volume = volume
    })
end)

RegisterNetEvent('Shared.StopSounds')
AddEventHandler('Shared.StopSounds', function(file, volume)
    SendNUIMessage({
        sound = file,
        type = 'Sound.Stop',
        volume = volume
    })
end)

RegisterNetEvent('_Mayor.GetTax')
AddEventHandler('_Mayor.GetTax', function(amount)
    taxRate = amount
    TriggerEvent('Mayor.GetTax', taxRate)
end)

RegisterKeyMapping('log', '[General] Notification Log', 'keyboard', 'NULL')

local log = false
RegisterCommand('log', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    log = not log
    SendNUIMessage({
        type = 'logHUD',
        log = log
    })
    if log then
        SetNuiFocus(true, true)
    else
        SetNuiFocus(false, false)
    end
end)

RegisterCommand('bugreport', function()
    local report = Dialogue({
        {
            title = 'Bug Report',
            placeholder = 'Bug Report Title',
            image = 'unk'
        },
        {
            placeholder = 'Bug Report Description',
            image = 'unk'
        }
    })

    if report and report[1] ~= '' and report[2] ~= '' then
        TriggerServerEvent('BugReport', report)
    end
end)

RegisterCommand('+modifier', function()
    TriggerEvent('ControlMod', true)
end)

RegisterCommand('-modifier', function()
    TriggerEvent('ControlMod', false)
end)

RegisterKeyMapping('+modifier', '[General] ~y~Control Modifier~w~', 'keyboard', 'LSHIFT')
RegisterKeyMapping('interact', '[General] Interact', 'keyboard', 'E')

RegisterCommand('interact', function()
    TriggerEvent('Interact')
end)

RegisterNUICallback(
    "Focus",
    function(data)
        if textbox == false then
            SetNuiFocus(false, false)
        end
        log = false
        SendNUIMessage({
            type = 'logHUD',
            log = log
        })
    end
)

RegisterNUICallback(
    "SelectSound",
    function(data)
        TriggerEvent('Shared.PlaySounds', 'sao_menu_select.wav', 1.0)
    end
)

RegisterNUICallback(
    "OpenSound",
    function(data)
        TriggerEvent('Shared.PlaySounds', 'sao_menu_open.wav', 1.0)
    end
)

RegisterNUICallback(
    "Result",
    function(data)
        SetControlNormal(0, 176, 0.0)
        textbox = false
        gval = data.val
    end
)

RegisterNUICallback(
    "minigame",
    function(data)
        game:resolve(data.win)
        SetNuiFocus(false, false)
    end
)

function TextInput(txt, len)
    while IsControlPressed(0, 176) do
        Wait(0)
    end
    textbox = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'textinput',
        desc = txt,
        len = (len or 50)
    })
    while gval == nil do
        Wait(0)
        SetNuiFocus(true, true)
    end

    SetNuiFocus(false, false)

    local var = gval
    gval = nil
    return var
end

exports('TextInput', TextInput)

function SystemNotify(blob, txt)

    while IsControlPressed(0, 176) do
        Wait(0)
    end

    textbox = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'textinput',
        desc = txt,
        notif = true,
        blob = blob
    })
    while gval == nil do
        Wait(0)
        SetNuiFocus(true, true)
    end
    SetNuiFocus(false, false)

    local var = gval
    gval = nil
    return var
end

local ida = 1
local ids = {}
function ProgressBar(title, length, cb)
    Citizen.CreateThread(function()
        local id = ida + 1
        ida = ida + 1
        ids[ida] = true
    
        SendNUIMessage({
            type = 'progress',
            time = length,
            title = title,
            id = id
        })
    
        if cb then
            cb(false, function()
                if ids[ida] then
                    ids[ida] = nil
                    SendNUIMessage({
                        type = 'terminate',
                        id = id
                    })
                end
            end)
    
            Citizen.CreateThread(function()
                Wait(length)
                if ids[ida] then
                    ids[ida] = nil
                    SendNUIMessage({
                        type = 'terminate',
                        id = id
                    })
                end
                cb(true)
            end)
        end
    end)
end

function ProgressBarSync(title, length, cb)
    local prom = promise:new()
    Citizen.CreateThread(function()
        local id = ida + 1
        ida = ida + 1
        ids[ida] = true
        local bool = true
    
        SendNUIMessage({
            type = 'progress',
            time = length,
            title = title,
            id = id
        })

        CreateThread(function()
            local time = GetGameTimer()
            while Shared.TimeSince(time) < length - 250 do
                Wait(100)
                if IsPedClimbing(Shared.Ped) or IsPauseMenuActive() then
                    if ids[ida] then
                        ids[ida] = nil
                        SendNUIMessage({
                            type = 'terminate',
                            id = id
                        })
                        prom:resolve(false)
                    end
                end
            end
        end)
    
        Wait(length)
        if ids[ida] then
            ids[ida] = nil
            SendNUIMessage({
                type = 'terminate',
                id = id
            })
            prom:resolve(true)
        else
            prom:resolve(false)
        end
    end)
    return Citizen.Await(prom)
end

SetNuiFocus(false, false)
function _Minigame(challenge, speed)
    game = promise.new()
    Wait(100)
    UIFocus(true, false)
    SendNUIMessage({
        type = 'minigame',
        challenge = challenge or 15,
        speed = speed or 3000
    })

    local val = Citizen.Await(game)
    UIFocus(false, false, false)
    return val
end

local entity = 0
local _zone = ''
CreateThread(function()
    while true do
        Wait(250)
        local ent = Shared.EntityInFront2(5.0)
        if entity ~= ent then
            entity = ent
            TriggerEvent('Entity', entity)
        end
    end
end)

local Sounds = {}
local lastVolume = {}

RegisterNetEvent("3DSound")
AddEventHandler("3DSound", function(coords,soundName,volume,radius, interior)
    local camRot = rot_to_direction(GetGameplayCamRot(0))
    local pos = coords
    if type(coords) == 'number' then
        if NetworkDoesEntityExistWithNetworkId(coords) then
            pos = GetEntityCoords(NetworkGetEntityFromNetworkId(coords))
        else
            return
        end
    end

    local distanceVolumeMultiplier = (volume / radius)
    local distance = Vdist3(GetEntityCoords(PlayerPedId()), vec(pos.x, pos.y, pos.z))
    local distanceVolume = volume - (distance * distanceVolumeMultiplier)
    distanceVolume = distanceVolume < 0 and 0 or distanceVolume

    if (MyCharacter.interior or 'none') ~= interior then
        distanceVolume = 0
    end

    local i = 1
    while Sounds[i] ~= nil do
        i = i + 1
    end
    local camRot = rot_to_direction(GetGameplayCamRot(0))
    Sounds[i] = {pos = coords,vol = volume,dist = radius, interior = interior}
    lastVolume[i] = 26.0

    if #Sounds - 1 == 0 then
        CreateThread(function()
            while #Sounds > 0 do
                local coords = GetEntityCoords(Shared.Ped)
                for k,v in pairs(Sounds) do
                    local pos = v.pos
                    if type(v.pos) == 'number' then
                        if NetworkDoesEntityExistWithNetworkId(v.pos) then
                            pos = GetEntityCoords(NetworkGetEntityFromNetworkId(v.pos))
                        else
                            goto nd
                        end
                    end
    
                    local distanceVolumeMultiplier = (v.vol / v.dist)
                    local distance = Vdist3(coords, vec(pos.x, pos.y, pos.z))
                    local distanceVolume = v.vol - (distance * distanceVolumeMultiplier)
                    local pcoords = {x = coords.x,y = coords.y,z = coords.z}
                    local camRot = rot_to_direction(GetGameplayCamRot(0))
    
                    distanceVolume = distanceVolume < 0 and 0 or distanceVolume
    
                    if (MyCharacter.interior or 'none') ~= v.interior then
                        distanceVolume = 0
                    end
    
                    --SendNUIMessage({submissionType="updateVolume", lpos = pos, volume = distanceVolume, playerPos=GetEntityCoords(PlayerPedId()),camDir = {x = camRot.x,y = camRot.y,z = camRot.z}, soundIndex=k})
                    if distanceVolume ~= lastVolume[k] then
                        SendNUIMessage({submissionType="updateVolume", volume = distanceVolume, soundIndex=k})
                        lastVolume[k] = distanceVolume
                    end
                    ::nd::
                end
                Wait(0)
            end
        end)
    end

    SendNUIMessage({submissionType="sendSound", volume = volume, submissionFile=soundName,soundIndex=i,pos = pos, playerPos=GetEntityCoords(PlayerPedId()), camDir = {x = camRot.x,y = camRot.y,z = camRot.z}})
end)

RegisterNUICallback("discardSound", function(data)
    if Sounds[data.index] ~= nil then
        Sounds[data.index] = nil
    end
end)


function rot_to_direction(rot)

    local radiansZ = rot.z * 0.0174532924;
    local radiansX = rot.x * 0.0174532924;
    local num = math.abs(math.cos(radiansX));
    local dir = {};
    dir.x = (-math.sin(radiansZ)) * num;
    dir.y = (math.cos(radiansZ)) *  num;
    dir.z = math.sin(radiansX);
    return dir;
end


local dialogue = false

RegisterNUICallback(
    "Dialogue",
    function(data)
        if dialogue then
            UIFocus(false, false)
            dialogue:resolve(data.data)
            dialogue = false
        end
    end
)

function Dialogue(data)
    if dialogue then return end
    SendNUIMessage({
        interface = 'dialogue',
        data = data
    })

    dialogue = promise:new()
    UIFocus(true, true)
    return Citizen.Await(dialogue)
end

function Interact(text, allowed)
    _interactActive = _interactActive + 1
    SendNUIMessage({
        interface = 'interact',
        message = text,
        id = _interactActive,
        allowed = allowed == nil and true or allowed
    })
    return _interactActive
end

function CloseInteract(id)
    SendNUIMessage({
        interface = 'closeInteract',
        id = id
    })
end

function UpdateInteract(id, text)
    SendNUIMessage({
        interface = 'updateInteract',
        id = id,
        message = text
    })
end

exports('SystemNotify', SystemNotify)
exports('Progress', ProgressBar)
exports('ProgressSync', ProgressBarSync)
exports('Minigame', _Minigame)
exports('UIFocus', UIFocus)
exports('Dialogue', Dialogue)
exports('Interact', Interact)
exports('CloseInteract', CloseInteract)
exports('UpdateInteract', UpdateInteract)

local globalOpen = false
RegisterCommand('globalhide', function()
    if Shared.Confirm2('This will disable all UI elements primarily for screenshot purposes, would you like to conitune? To end this mode use your [Interact] Key (Default E)') then
        globalOpen = true
        GlobalNUI({
            type = 'hideAll',
            bool = true
        })

        local event = AddEventHandler('Interact', function()
            globalOpen = false
            GlobalNUI({
                type = 'hideAll',
                bool = false
            })
        end)

        while globalOpen do
            Wait(0)
            DisableControlAction(0, 245, true)
        end

        RemoveEventHandler(event)
    end
end)

local confirmIds = 1
local confirms = {}

function Confirmation(message)
    local id = confirmIds + 1
    confirmIds = confirmIds + 1
    confirms[id] = promise:new()
    UIFocus(true, true, '', true)
    SendNUIMessage({
        type = 'Confirm2',
        message = message,
        id = id
    })

    return Citizen.Await(confirms[id])
end

RegisterNUICallback('Confirm2', function(data, cb)
    UIFocus(false, false)
    confirms[data.id]:resolve(data.bool)
end)

exports('Confirmation', Confirmation)