local messages
local contacts
phoneOpen = false
local inCamera
local selfieCam = false
funcRefs = {}

CreateThread(function()
    while MyCharacter == nil do
        Wait(100)
    end

    messages = Task.Run('Phone.GetMessages')
    contacts = Task.Run('Phone.Contacts')
end)

AddEventHandler('Logout2', function()
    messages = nil
    contacts = nil
end)

AddEventHandler('Login', function()
    while MyCharacter == nil do
        Wait(100)
    end

    messages = Task.Run('Phone.GetMessages')
    contacts = Task.Run('Phone.Contacts')
end)

local clock = {12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3, 4, 5, 6 ,7, 8, 9, 10, 11}
RegisterCommand('openphone', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    if phoneOpen or not exports['geo-inventory']:HasItemKey('phone') or IsPauseMenuActive() then
        return
    end

    local hour = GetClockHours()
    local min = GetClockMinutes()

    if tostring(min):len() == 1 then
        min = '0'..min
    end
    local nHour = hour
    local addon = 'PM'


    nHour = clock[hour + 1]

    if hour < 11 then
        addon = 'AM'
    end

    if not messages then
        messages = Task.Run('Phone.GetMessages')
        contacts = Task.Run('Phone.Contacts')
    end

    ExecuteCommand('e phone')
    SendNUIMessage({
        interface = 'phone.open',
        apps = GetApps(),
        messages = messages,
        contacts = contacts,
        number = MyCharacter.phone_number,
        time = nHour..':'..min..' '..addon,
        id = MyCharacter.id
    })
    local allowMovement = MyUser.data.settings.phonemovement
    if allowMovement == nil then allowMovement = true end

    UIFocus(true, true, '', allowMovement)

    phoneOpen = true

    exports['geo-hud']:Radar(true)
    while phoneOpen do
        local hour = GetClockHours()
        local min = GetClockMinutes()

        if tostring(min):len() == 1 then
            min = '0'..min
        end
        local nHour = hour
        local addon = 'PM'


        nHour = clock[hour + 1]

        if hour < 11 then
            addon = 'AM'
        end

        SendNUIMessage({
            interface = 'phone.time',
            time = nHour..':'..min..' '..addon
        })

        if not IsEntityPlayingAnim(Shared.Ped, "cellphone@", "cellphone_text_read_base", 1) and not selfieCam then
            TaskPlayAnim(Shared.Ped, "cellphone@", "cellphone_text_read_base", 1.0, 1.0, -1, 51, 0, 0, 0, 0)
        end

        if not exports['geo-inventory']:HasItemKey('phone') then
            SendNUIMessage({
                interface = 'phone.close',
            })
        end

        Wait(1000)
    end
end)

RegisterCommand('phone', function()
    local str = tostring(math.floor(MyCharacter.phone_number)) 
    local sub = ''
    for i=1,(str):len() do
        sub = sub..str:sub(i, i)

        if i == 3 or i == 6 then
            sub = sub..'-'
        end
    end
    TriggerServerEvent('Chat.LocalMessage', '', sub, 'me', GetEntityCoords(PlayerPedId()), 150.0, false)
end)

RegisterNUICallback('Focus', function(data, cb)
    UIFocus(false, false)
    ExecuteCommand('ec phone')

    if phoneOpen then
        LoadAnim('cellphone@')
        TaskPlayAnim(Shared.Ped, 'cellphone@', 'cellphone_text_out', 4.0, 1.0, 700, 50, 0, false, false, false)
    end

    phoneOpen = false
    exports['geo-hud']:Radar(false)
    cb(true)
end)

RegisterNUICallback('phone.text', function(data, cb)
    if data.text:len() > 256 then
        Wait(500)
        TriggerEvent('Phone.Error', 'Your message was too long')
    else
        Task.Run('Phone.SendText', data.number, data.text)
    end

    cb(true)
end)

RegisterNUICallback('phone.newcontact', function(data, cb)
    Task.Run('Phone.NewContact', data.number, data.name)
    cb(true)
end)

RegisterNUICallback('phone.editcontact', function(data, cb)
    Task.Run('Phone.EditContact', data.number, data.name)
    cb(true)
end)

RegisterNUICallback('phone.deletecontact', function(data, cb)
    Task.Run('Phone.DeleteContact', data.number)
    cb(true)
end)

RegisterNUICallback('phone.vehicles', function(data, cb)
    local val = Task.Run('Phone.Vehicles')

    for k,v in pairs(val) do
        v.model = GetLabelText(GetDisplayNameFromVehicleModel(v.model))
    end

    SendNUIMessage({
        interface = 'phone.vehicles',
        data = val
    })
    cb(true)
end)

RegisterNUICallback('phone.getechat', function(data, cb)
    local val = Task.Run('Phone.EChat')
    SendNUIMessage({
        interface = 'phone.echat',
        chat = val
    })
    cb(true)
end)

local takingPhoto = false
RegisterNUICallback('Phone.Camera', function(data, cb)
    cb(true)
    SetNuiFocusKeepInput(true, true)
    UIFocus(true, false, '~INPUT_CONTEXT~ Take Picture', true)
    inCamera = true

    CreateThread(function()
        local int = Shared.Interact('[E] Take Picture - [Left Click] Toggle Selfie Cam - [Right Click] Return Focus')
        while inCamera do
            Wait(0)
            Shared.DisableWeapons()

            if IsDisabledControlJustPressed(0, 24) then
                selfieCam = not selfieCam
                if selfieCam then
                    CreateMobilePhone(1)
                    CellCamActivate(true, true)
                    CellFrontCamActivate(true)
                else
                    DestroyMobilePhone()
                    CellCamActivate(false, false)
                    CellFrontCamActivate(false)
                end
            end

            if IsDisabledControlJustPressed(0, 25) then
                inCamera = false
                if selfieCam then
                    DestroyMobilePhone()
                    CellCamActivate(false, false)
                    CellFrontCamActivate(false)
                end
                selfieCam = false
            end

            if IsControlJustPressed(0, 38) then
                exports['screenshot-basic']:requestScreenshot(function(data)
                    SendNUIMessage({
                        interface= 'GetPicture',
                        data = data
                    })
                end)
            end
        end
        if phoneOpen then
            UIFocus(true, true, '', allowMovement)
        end
        int.stop()
    end)

    while inCamera do
        if not takingPhoto then
            exports['screenshot-basic']:requestScreenshot(function(data)
                SendNUIMessage({
                    interface= 'phone_image',
                    data = data
                })
            end)
        end
        Wait(150)
    end
end)

RegisterNUICallback('GetPicture', function(data, cb)
    takingPhoto = true
    exports['screenshot-basic']:requestScreenshotUploadCustom('https://discord.com/api/webhooks/1159324803723960350/DCUKTZ3zV4GlGVvqBgkkxoJIxcgrT5nwi6LuDCz2uR0qfNnKRC1XHdYoeKw1LmSIB9yS', 'files[]', {headers = {}, encoding = 'jpg', custom = data.data}, function(data)
        local resp = json.decode(data)
        Task.Run('Phone.UploadPhoto', resp.attachments[1].url)
        takingPhoto = false
    end)

    cb(true)
end)

RegisterNUICallback('Phone.Photos', function(data, cb)
    cb(Task.Run('Phone.Photos'))
end)

RegisterNUICallback('Phone.DeletePhoto', function(data, cb)
    cb(Task.Run('Phone.DeletePhoto', data.pid))
end)

RegisterNUICallback('Phone.WentHome', function(data, cb)
    cb(true)
    if phoneOpen then
        local allowMovement = MyUser.data.settings.phonemovement
        if allowMovement == nil then allowMovement = true end
        UIFocus(true, true, '', allowMovement)
    end
    DestroyMobilePhone()
    CellCamActivate(false, false)
    CellFrontCamActivate(false)
    inCamera = false
end)

RegisterNUICallback('phone.fleeca', function(data, cb)
    local val = Task.Run('Phone.Fleeca')
    SendNUIMessage({
        interface = 'phone.fleeca',
        data = val
    })
    cb(true)
end)

RegisterNUICallback('phone.echat', function(data, cb)
    Task.Run('Phone.EChatMessage', data.text)
    cb(true)
end)

RegisterNetEvent('Phone.EChat')
AddEventHandler('Phone.EChat', function(data, msg)
    if MyCharacter.Duty == 'Police' then
        SendNUIMessage({
            interface = 'phone.echat',
            chat = data,
            msg = msg,
        })
    end
end)

RegisterNUICallback('Phone.DeleteHistory', function(data, cb)
    Task.Run('Phone.DeleteHistory', data.number)
    Task.Run('Phone.GetMessages')
    cb(true)
end)

RegisterNUICallback('phone.call', function(data, cb)
    ExecuteCommand('call '..data.number)
    cb(true)
end)

RegisterNUICallback('Phone.TentacName', function(data, cb)
    local val = Task.Run('Phone.TentacName')
    cb(val)
end)

RegisterNUICallback('Phone.RegisterTentac', function(data, cb)
    local val = Task.Run('Phone.RegisterTentac', data.name)
    cb(val)
end)

RegisterNUICallback('phone.tentac', function(data, cb)
    Task.Run('Phone.Tentac', data.text, data.reply)
    cb(true)
end)

RegisterNetEvent('Phone.SendTexts')
AddEventHandler('Phone.SendTexts', function(message)
    table.insert(messages, message)
    SendNUIMessage({
        interface = 'phone.messages',
        messages = messages,
    })
end)

RegisterNetEvent('Phone.SendContacts')
AddEventHandler('Phone.SendContacts', function(contact)
    contacts = contact
    SendNUIMessage({
        interface = 'phone.contacts',
        contacts = contacts,
    })
end)

RegisterNetEvent('Phone.Error')
AddEventHandler('Phone.Error', function(txt)
    SendNUIMessage({
        interface = 'phone.error',
        error = txt,
    })
end)

RegisterNetEvent('Phone.Tentac')
AddEventHandler('Phone.Tentac', function(message)
    SendNUIMessage({
        interface = 'phone.tentac',
        message = message
    })
end)

RegisterNetEvent('Phone.Called')
AddEventHandler('Phone.Called', function(num)
    num = math.floor(num)

    local name

    for k,v in pairs(contacts or {}) do
        if v.number == num then
            name = v.name
        end
    end

    SendNUIMessage({
        interface = 'phone_call',
        num = name or num
    })
    TriggerEvent('Shared.Notif', 'Call From: '..(name or num), 10000)
end)

RegisterNetEvent('PhoneNotif', function(icon, message, time)
    SendNUIMessage({
        interface = 'phone_notif',
        icon = icon,
        message = message,
        time = time
    })
end)

RegisterNetEvent('Phone.Confirm', function(text, time, icon, id)
    TriggerServerEvent('Phone.Confirm', PhoneConfirm(text, time, icon), id)
end)

local list = {}
function PhoneConfirm(text, timer, icon, data, params)
    local id = #list + 1
    list[id] = promise:new()

    SendNUIMessage({
        interface = 'phone_confirm',
        ident = id,
        text = text,
        timer = timer,
        icon = icon
    })

    local bool = Citizen.Await(list[id])
    if data then
        local item = data[bool and 1 or 2]
        if item[1] == 'command' then
            ExecuteCommand(item[2])
        elseif item[1] == 'event' then
            TriggerEvent(item[2], table.unpack(params or {}))
        elseif item[1] == 'serverevent' then
            TriggerServerEvent(item[2], table.unpack(params or {}))
        end
    end

    return bool
end

exports('PhoneConfirm', PhoneConfirm)

RegisterNUICallback('phoneaction', function(data, cb)
    list[data.ident]:resolve(data.bool)
    cb(true)
end)

RegisterNetEvent('Phone.NewTexts')
AddEventHandler('Phone.NewTexts', function(num, text)
    SendNUIMessage({
        interface = 'phone.newmessage',
        text = text,
        num = num
    })
end)

RegisterNetEvent('Phone.NewTentac')
AddEventHandler('Phone.NewTentac', function()
    SendNUIMessage({
        interface = 'phone.newtentac'
    })
end)

function GetApps()
    local apps = {'messages','contacts', 'calls', 'fleeca', 'vehicles', 'tentac', 'guilds', 'location', 'business', 'housing', 'camera', 'photos', 'settings'}

    if exports['geo-es']:IsEs(MyCharacter.id) then
        table.insert(apps, 'echat')
    end

    return apps
end

RegisterKeyMapping('openphone', '[Interface] Phone', 'keyboard', 'DELETE')

function InterfaceMessage(data, bool)

    funcRefs = data.menu
    SendNUIMessage(data)
    if bool then
        UIFocus(true, true)
    end
end

exports('InterfaceMessage', InterfaceMessage)

RegisterCommand('email', function(source, args)
    local email = exports['geo-shared']:Dialogue({
        {
            title = 'Email',
            placeholder = 'Target CID',
            image = 'person'
        },
        {
            placeholder = 'Email',
            image = 'unk'
        }
    })

    if (tonumber(email[1]) and email[2]) then
        Task.Run('Email', email)
    end
end)

RegisterNUICallback('phonecall', function(data, cb)
    ExecuteCommand(data.action)
    cb(true)
end)

RegisterNUICallback('HasPhone', function(data, cb)
    cb(exports['geo-inventory']:HasItemKey('phone'))
end)

RegisterNUICallback('GetGuilds', function(data, cb)
    cb({guilds = exports['geo-guilds']:GetGuilds(), cid = MyCharacter.id})
end)

RegisterNUICallback('GuildAuthority', function(data, cb)
    cb(exports['geo-guilds']:GuildAuthority(data.guild, data.cid or MyCharacter.id))
end)

RegisterNUICallback('Guild.Fire', function(data, cb)
    TriggerServerEvent('Guild:Fire', data.guild, data.cid)
    cb(true)
end)

RegisterNUICallback('Guild.FireTemp', function(data, cb)
    TriggerServerEvent('Guild:FireTemp', data.guild, data.cid)
    cb(true)
end)

RegisterNUICallback('ModifyAuthority', function(data, cb)
    TriggerServerEvent('Guild:ModifyAuthority', data.guild, data.rank, data.newAUth)
    cb(true)
end)

RegisterNUICallback('SetGuildImage', function(data, cb)
    TriggerServerEvent('Guild:SetGuildImage', data.guild, data.image)
    cb(true)
end)

RegisterNUICallback('CreateRank', function(data, cb)
    TriggerServerEvent('Guild:AddRank', data.guild, data.rank, data.newAUth)
    cb(true)
end)

RegisterNUICallback('RemoveRank', function(data, cb)
    TriggerServerEvent('Guild:RemoveRank', data.guild, data.rank)
    cb(true)
end)

RegisterNUICallback('Guild.AddUser', function(data, cb)
    if data.temp then
        TriggerServerEvent('Guild:HireTemp', data.guild, data.member, data.rank)
    else
        TriggerServerEvent('Guild:Hire', data.guild, data.member, data.rank)
    end

    cb(true)
end)

RegisterNUICallback('Guild.Flag', function(data, cb)
    cb(Task.RunRemote('Guild.Flag', data.target, data.flag, data.guild))
end)

RegisterNUICallback('Guild.RankFlag', function(data, cb)
    cb(Task.RunRemote('Guild.RankFlag', data.target, data.flag, data.guild))
end)

RegisterNUICallback('Guild.RemoveRankFlag', function(data, cb)
    cb(Task.RunRemote('Guild.RemoveRankFlag', data.target, data.flag, data.guild))
end)

RegisterNUICallback('Guild.RemoveFlag', function(data, cb)
    cb(Task.RunRemote('Guild.RemoveFlag', data.target, data.flag, data.guild))
end)

RegisterNUICallback('Housing.Modify', function(data, cb)
    TriggerEvent('ModHouse', data.property)
    cb(true)
end)



RegisterNUICallback('GetNames', function(data, cb)
    local data = Task.RunRemote('Guild:CacheNames', data.guild)
    cb(data)
end)

RegisterNUICallback('SendPing', function(data, cb)
    Task.Run('Ping', data.id)
    cb(true)
end)

RegisterNUICallback('Phone.GetAds', function(data, cb)
    cb(Task.Run('Phone.GetAds'))
end)

RegisterNUICallback('Phone.SendAd', function(data, cb)
    cb(Task.Run('Phone.SendAd', data.text))
end)

RegisterNUICallback('ToggleHousing', function(data, cb)
    TriggerEvent('ToggleHousing')
    cb(true)
end)

RegisterNUICallback('LoJack', function(data, cb)
    TriggerServerEvent('LoJack', data.plate)
    cb(true)
end)

RegisterNUICallback('FindHousing', function(data, cb)
    local data = exports['geo-instance']:GetClosestPropertyData()
    if not data then 
        cb(false) 
        return 
    end
    data.cid = MyCharacter.id
    data.realtor = exports['geo-guilds']:GuildAuthority('FHA', MyCharacter.id) > 0
    if data then data.taxprice = GetPrice(data.price) end
    cb(data or false)
end)

RegisterNUICallback('BuyProperty', function(data, cb)
    TriggerServerEvent('Property:SellToPlayer', data.pid, data.cid)
    cb(true)
end)

RegisterNUICallback('Property.AddTentant', function(data, cb)
    Task.RunRemote('Property.AddTentant', data.id, data.property)
    cb(true)
end)

RegisterNUICallback('Property.GetTenants', function(data, cb)
    cb(Task.RunRemote('Property.GetTenants', data.property))
end)

RegisterNUICallback('Property.RemoveTenant', function(data, cb)
    cb(Task.RunRemote('Property.RemoveTenant', data.property, data.tenant))
end)

RegisterNUICallback('Housing.Payment', function(data, cb)
    cb(Task.RunRemote('Housing.Payment', data.property, data.tenant))
end)

RegisterNUICallback('Property.Rent', function(data, cb)
    cb(Task.RunRemote('Property.Rent', data.pid))
end)

RegisterNUICallback('Housing.Sell', function(data, cb)
    cb(Task.RunRemote('Property.Sell', data.property))
end)

RegisterNUICallback('ReleaseProprety', function(data, cb)
    TriggerServerEvent('Property:Release', data.pid)
    cb(true)
end)

RegisterNetEvent('Phone.SendAd', function(ads)
    SendNUIMessage({
        interface = 'UpdateAds',
        data = ads
    })
end)

AddEventHandler('GuildUpdate', function(id, data)
    SendNUIMessage({
        interface = 'GuildUpdate',
        guild = id,
        data = data
    })
end)

exports('IsPhoneOpen', function()
    return phoneOpen
end)

function CellFrontCamActivate(activate)
	return Citizen.InvokeNative(0x2491A93618B7D838, activate)
end

CreateThread(function()
    DestroyMobilePhone()
    
end)