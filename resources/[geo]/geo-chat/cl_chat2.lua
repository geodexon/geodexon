local foreverOn = GetResourceKvpInt('fadeout') == 0 and false or true
local fontSize = GetResourceKvpFloat('fontsize')
Citizen.CreateThread(function()
    Wait(2500)

    SendNUIMessage({
        type = 'hudtoggle',
        bool = foreverOn
    })

    if fontSize ~= 0.0 then
        SendNUIMessage({
            type = 'fontsize',
            size = fontSize
        })
    end

    TriggerEvent('chat:addTemplate', 'guild', "<font color='#95569c'><b>{0}</b>:</font> {1}")
    TriggerEvent('chat:addTemplate', 'me', "<font color='#a793ba'><b>{0}</b> {1}")
    TriggerEvent('chat:addTemplate', 'bank', "<font color='#3bb02e'><b>{0}</b>:</font> {1}")
    TriggerEvent('chat:addTemplate', 'job', "<font color='#4287f5'><b>{0}</b>:</font> {1}")
    TriggerEvent('chat:addTemplate', 'sys', "<font color='red'><b>{0}</b>:</font> {1}")
    TriggerEvent('chat:addTemplate', 'ooc', "<font color='pink'><b>{0}</b>:</font> {1}")
    TriggerEvent('chat:addTemplate', '911', "<font color='red'><b>{0}</b>:</font> {1}")
    TriggerEvent('chat:addTemplate', '311', "<font color='yellow'><b>{0}</b>:</font> {1}")
    TriggerEvent('chat:addTemplate', 'center', "<center>{1}</center>")
    TriggerEvent('chat:addTemplate', 'br', "<hr>")
    TriggerEvent('chat:addTemplate', 'id', [[
        <div class = "idcard">
            <p style = "top:0.0em;color:black;font-weight:normal;line-height:1em;text-align:center;">State of San Andreas</p>
            <hr style = "background-color:black;"><hr>

            <h class = "id" style = "position: relative;color:black;font-weight:bold;top:0.0em;left:1em;">FIRST:</h>
            <h class = "id" style = "position: relative;color:black;font-weight:bold;top:1.0em;left:1em;">LAST:</h>
            <h class = "id" style = "position: relative;color:black;font-weight:bold;top:2.0em;left:1em;">DOB:</h>
            <h class = "id" style = "position: relative;color:black;font-weight:bold;top:3.0em;left:1em;">CID:</h>
            <h class = "id" style = "position: relative;color:black;font-weight:bold;top:4.0em;left:1em;">SEX:</h>

            <p class = "id" style = "position: relative;color:black;font-weight:normal;top:-3em;left:6em;"></b>{0} </p>
            <p class = "id" style = "position: relative;color:black;font-weight:normal;top: -2.5em;left:6em;">{1}</p>
            <p class = "id" style = "position: relative;color:black;font-weight:normal;top: -2em;left:6em;">{2}</p>
            <p class = "id" style = "position: relative;color:black;font-weight:normal;top: -1.5em;left:6em;">{3}</p>
            <p class = "id" style = "position: relative;color:black;font-weight:normal;top: -1em;left:6em;">{4}</p>
            <img src="https://nui-img/{5}/{6}" style = "position:relative;width:6em;bottom:8em;left:17.5em; border-radius:5em;">
        </div>
    ]])
end)

RegisterCommand('_hide', function()
    foreverOn = not foreverOn
    SendNUIMessage({
        type = 'hudtoggle',
        bool = foreverOn
    })
    SetResourceKvpInt('fadeout', foreverOn == true and 1 or 0)
end)

RegisterCommand('_fontsize', function()
    local size = Shared.TextInput('Font Size', 5)
    if tonumber(size) then
        SetResourceKvpFloat('fontsize', tonumber(size) + 0.0)
        SendNUIMessage({
            type = 'fontsize',
            size = size
        })
    end
end)

RegisterNetEvent("Chat.Message")
AddEventHandler('Chat.Message', function(prefix, message, template)
    TriggerEvent('chat:addMessage', { templateId = template, multiline = true, args = { prefix , message } })
end)

RegisterNetEvent('Chat.ID', function(message)
    local clothing = json.decode(message[6])
    local ped = Shared.SpawnPed(clothing.Model, nil, true)
    exports['geo']:LoadClothing(clothing, ped)
    Wait(250)
    local handle = RegisterPedheadshot(ped)
    while not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle) do
        Citizen.Wait(0)
    end
    local txd = GetPedheadshotTxdString(handle)
    message[6] = txd
    message[7] = txd..'?'..uuid()

    TriggerEvent('chat:addMessage', { templateId = 'id', multiline = true, args = { table.unpack(message) } })
    Wait(500)
    UnregisterPedheadshot(handle)
    DeleteEntity(ped)
end)

RegisterCommand('me', function(source, args)
    local me = table.concat(args, ' ')
    if MyCharacter.id ~= nil then
       --[[  TriggerServerEvent('Chat.LocalMessage', '', GetName(MyCharacter)..' '..me, 'me', GetEntityCoords(PlayerPedId()), 150.0, false) ]]
        TriggerServerEvent('me', me)
    end
end)

local me = {}
local open = {}
RegisterNetEvent("me")
AddEventHandler('me', function(id, message)
    if me[id] == nil then
        me[id] = {}
    end

    table.insert(me[id], message)
    SetTimeout(5000, function()
        for k,v in pairs(me[id]) do
            if v == message then
                table.remove(me[id], k)
                break
            end
        end
    end)

    if open[id] then
        return
    end

    CreateThread(function()
        if GetPlayerFromServerId(id) ~= -1 then
            open[id] = true
            local ped = GetPlayerPed(GetPlayerFromServerId(id))
            while #me[id] > 0 do
                Wait(0)
                local pos = GetEntityCoords(ped) + vec(0, 0, 0.3)
                if HasEntityClearLosToEntityInFront(Shared.Ped, ped) or Vdist3(GetEntityCoords(Shared.Ped), GetEntityCoords(ped)) <= 5.0 then
                    for k,v in pairs(me[id]) do
                        Shared.WorldText(v, pos - vec(0.0, 0.0, 0.13 * k))
                    end
                end
            end
            open[id] = nil
        end
    end)
end)

RegisterNetEvent("Chat.LocalMessage")
AddEventHandler('Chat.LocalMessage', function(prefix, message, template, pos, distance, bypass, instance, player)
    if MyCharacter.id ~= nil then
        local userPed = GetEntityCoords(PlayerPedId())
        local ped

        if NetworkDoesEntityExistWithNetworkId(player) then
            ped = NetworkGetEntityFromNetworkId(player)
        end

        if bypass then
            if Shared.Ped == ped then
                return
            end
        end

        if MyCharacter.interior ~= instance then
            return
        end

        if Vdist4(userPed, pos) < distance then

            if template == 'id' then
                TriggerEvent('Chat.ID', message)
                return
            end

            TriggerEvent('chat:addMessage', { templateId = template, multiline = true, args = { prefix , message } })
        end
    end
end)

AddEventHandler("localOOC", function(raw)
    if MyCharacter then
        TriggerServerEvent('Chat.LocalMessage', "[Local OOC] "..GetName(MyCharacter), raw, 'ooc', GetEntityCoords(PlayerPedId()), 150.0, false)
    end
end)

RegisterNetEvent("LocalChatMessage")
AddEventHandler("LocalChatMessage", function(type, message, sender, atEnd, id, distance,instance)
    if MyCharacter.id ~= nil then

        if MyCharacter.interior ~= instance then
            return
        end

        local userPed = GetEntityCoords(PlayerPedId())
        local ped = GetEntityCoords(GetPlayerPed(id))
        if Vdist4(userPed, ped) < distance then
            TriggerEvent('Chat.Message', type, message)
        end
    end
end)

exports('Name', GetName)