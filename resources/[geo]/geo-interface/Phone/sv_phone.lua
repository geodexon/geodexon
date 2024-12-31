local echat = {}
local tentac = {}
local ads = {}

function getNumber(num)
    num = tostring(num)
    return "("..num:sub(1, 3)..") "..num:sub(4, 6).."-"..num:sub(7, 10)
end

Task.Register('Phone.SendText', function(source, number, text)
    local char = GetCharacter(source)
    if char and char.phone_number then
        number = tonumber(number)
        if number and text ~= nil and text ~= '' then
            if number < 10000 then
                local fnum = SQL('SELECT phone_number from characters WHERE callsign = ?', tostring(number))[1]
                if fnum then
                    number = fnum.phone_number
                else
                    TriggerClientEvent('Phone.Error', source, 'Invalid Number')
                    return
                end
            end

            exports.ghmattimysql:execute('INSERT INTO phone_text (from_number, to_number, message) VALUES (?, ?, ?)', {
                char.phone_number, number, text
            }, function(res)
                local target = exports['geo']:GetCharWithPhone(number)
                local messages = SQL('SELECT * from phone_text WHERE message_id = ?', res.insertId)[1]
                if target then
                    TriggerClientEvent('Shared.PlaySounds', target.serverid, 'phone_text.wav', 0.4 * ((GetUser(source).data.settings.custom_phone or 100) / 100))
                    TriggerClientEvent('Shared.Notif', target.serverid, 'You have received a text message')
                    TriggerClientEvent('Phone.NewTexts', target.serverid, char.phone_number, text)
                    TriggerClientEvent('Phone.SendTexts', target.serverid, messages)
                end

                if not target or target.serverid ~= char.serverid then
                    TriggerClientEvent('Phone.SendTexts', char.serverid, messages)
                end
            end)
        end
    end
end)

Task.Register('Phone.DeleteHistory', function(source, number)
    local char = GetCharacter(source)
    if char and char.phone_number then
        SQL('UPDATE phone_text SET hiddenfor = json_set(hiddenfor, ?, ?) WHERE from_number = ? or to_number = ?', '$.'..char.id, true, number, number)
    end
end)

Task.Register('Phone.GetMessages', function(source)
    local char = GetCharacter(source)
    if char and char.phone_number then
        return SQL('SELECT * from phone_text WHERE (from_number = ? or to_number = ?) and JSON_VALUE(hiddenfor, "$.?") is null ORDER BY TIME asc', char.phone_number, char.phone_number,  char.id)
    end
end)

Task.Register('Phone.Contacts', function(source)
    local char = GetCharacter(source)
    if char and char.phone_number then
        return SQL('SELECT * from phone_contacts WHERE cid = ?', char.id)
    end
end)

Task.Register('Phone.NewContact', function(source, number, name)
    local char = GetCharacter(source)
    if char and char.phone_number then
        number = tonumber(number)
        if number and name ~= nil and name ~= '' then
            exports.ghmattimysql:execute('INSERT INTO phone_contacts (cid, number, name) VALUES (?, ?, ?)', {
                char.id, number, name
            }, function()
                local contacts = SQL('SELECT * from phone_contacts WHERE cid = ?', char.id)
                TriggerClientEvent('Phone.SendContacts', char.serverid, contacts)
            end)
        end
    end
end)

Task.Register('Phone.EditContact', function(source, number, name)
    local char = GetCharacter(source)
    if char and char.phone_number then
        number = tonumber(number)
        if number and name ~= nil and name ~= '' then
            exports.ghmattimysql:execute('UPDATE phone_contacts SET number = ?, name = ? WHERE cid = ? and number = ?', {
                number, name, char.id, number
            }, function()
                local contacts = SQL('SELECT * from phone_contacts WHERE cid = ?', char.id)
                TriggerClientEvent('Phone.SendContacts', char.serverid, contacts)
            end)
        end
    end
end)

Task.Register('Phone.DeleteContact', function(source, number)
    local char = GetCharacter(source)
    if char and char.phone_number then
        number = tonumber(number)
        if number then
            exports.ghmattimysql:execute('DELETE from phone_contacts WHERE number = ? and cid = ?', {
                number, char.id
            }, function()
                local contacts = SQL('SELECT * from phone_contacts WHERE cid = ?', char.id)
                TriggerClientEvent('Phone.SendContacts', char.serverid, contacts)
            end)
        end
    end
end)

Task.Register('Phone.EChat', function()
    return echat
end)

Task.Register('Phone.EChatMessage', function(source, msg)
    local char = GetCharacter(source)
    table.insert(echat, {GetName(GetCharacter(source)), msg})
    TriggerClientEvent('Phone.EChat', -1, echat, GetName(GetCharacter(source))..': '..msg)
end)

Task.Register('Phone.Fleeca', function(source)
    return exports['geo-eco']:GetMyAccounts(GetCharacter(source))
end)

Task.Register('Phone.Vehicles', function(source)
    local char = GetCharacter(source)
    return SQL('SELECT garage, model, plate, parked, flags from vehicles where owner = ?', char.id)
end)

Task.Register('Phone.TentacName', function(source)
    local char = GetCharacter(source)
    if tentac[char.id] == nil then
        local found = SQL('SELECT name from phone_tentac WHERE cid = ?', char.id)
        if found[1] and found[1].name then
            tentac[char.id] = found[1].name
        end
    end

    return tentac[char.id]
end)

Task.Register('Phone.RegisterTentac', function(source, name)
    local char = GetCharacter(source)
    name = string.gsub(name, "%s+", "")
    if name and name ~= '' then
        local found = SQL('SELECT name from phone_tentac WHERE name = ?', char.id, name)
        if not found[1] then
            SQL('INSERT into phone_tentac (cid, name) VALUES (?, ?)', char.id, name)
            tentac[char.id] = name
            return true
        end
    end
end)

Task.Register('Phone.Tentac', function(source, text, reply)
    local char = GetCharacter(source)
    if tentac[char.id] and text ~= '' then
        TriggerClientEvent('Phone.Tentac', -1, {
            message = text,
            author = tentac[char.id]
        })

        if reply then
            for k,v in pairs(tentac) do
                if v == reply then
                    TriggerClientEvent('Shared.Notif', GetCharacterByID(k).serverid, 'You were mentioned on Tentac', 5000)
                    TriggerClientEvent('Phone.NewTentac', GetCharacterByID(k).serverid)
                end
            end
        end
    end
end)

local calls = {}
local _911 = {}
local _911caller

RegisterCommand('call', function(source, args)
    local char = GetCharacter(source)
    if char and exports['geo-inventory']:HasItemKey('Player', source, 'phone') then

        if char.call then
            TriggerClientEvent('Shared.Notif', source, 'You are already on a call')
            return
        end

        local num = tonumber(args[1])
        if num then
            local target = exports['geo']:GetCharWithPhone(num)
            if num == 911 then
                _911Event('Shared.Notif', '911 Call From '..math.floor(char.phone_number), 10000)
                _911Event('Shared.PlaySounds', '911call.wav', 0.4 * ((GetUser(source).data.settings.custom_phone or 100) / 100))
                TriggerClientEvent('Phone.Calling', source,  args[1])
                _911caller = source
            end
            if target --[[ and target.serverid ~= char.serverid ]] and exports['geo-inventory']:HasItemKey('Player', target.serverid, 'phone') then
                calls[target.serverid] = source
                TriggerClientEvent('Phone.Called', target.serverid, char.phone_number, num)
                UpdateChar(source, 'call', target.serverid)
                TriggerClientEvent('Phone.Calling', source)
            else
                TriggerClientEvent('Phone.Calling', source, args[1])
                UpdateChar(source, 'call', 'fake')
            end
        end
    end
end)

RegisterCommand('911t', function(source, args)
    local char = GetCharacter(source)
    if char and exports['geo-es']:IsEs(char.id) then
        for k,v in pairs(_911) do
            if v == source then
                table.remove(_911, k)
                TriggerClientEvent('Shared.Notif', source, '911 Released')
                return
            end
        end

        table.insert(_911, source)
        TriggerClientEvent('Shared.Notif', source, '911 Is Taken')
    end
end)

RegisterCommand('911a', function(source, args)
    local char = GetCharacter(source)
    if char and exports['geo-es']:IsEs(char.id) then
        if _911caller then
            _911Event('Shared.Notif', '911 has been answered', 5000)
            UpdateChar(source, 'call', _911caller)
            UpdateChar(_911caller, 'call', source)
            TriggerClientEvent('Phone.Call',source, _911caller, GetCharacter(_911caller).phone_number)
            TriggerClientEvent('Phone.Call', _911caller, source, char.phone_number)
            _911caller = nil
        end
    end
end)

AddEventHandler('playerDropped', function()
    local source = source
    if _911caller == source then
        _911caller = nil
    end
end)

RegisterCommand('a', function(source)
    if calls[source] then
        TriggerClientEvent('Phone.Call', calls[source], source, GetCharacter(source).phone_number)
        TriggerClientEvent('Phone.Call', source, calls[source], GetCharacter(calls[source]).phone_number)
        UpdateChar(source, 'call', calls[source])

        calls[source] = nil
        if _911caller == source then
            _911caller = nil
        end
    end
end)

RegisterCommand('h', function(source)
    local char = GetCharacter(source)
    if char then
        if char.call then
            TriggerClientEvent('Phone.EndCall', source, char.call)
            UpdateChar(source, 'call', nil)

            if char.call ~= 'fake' then
                TriggerClientEvent('Phone.EndCall', char.call, source)
                UpdateChar(char.call, 'call', nil)
            end
        end

        if calls[source] then
            UpdateChar(calls[source], 'call', nil)
            UpdateChar(source, 'call', nil)

            TriggerClientEvent('Phone.EndCall', source)
            TriggerClientEvent('Phone.EndCall', calls[source])

            calls[source] = nil
        end

        if _911caller == source then
            _911caller = nil
        end
    end
end)

function _911Event(ev, ...)
    for k,v in pairs(_911) do
        TriggerClientEvent(ev, v, ...)
    end
end

Task.Register('Email', function(source, email)
    local char = GetCharacter(source)
    local user = SQL('SELECT user from characters where id = ?', tonumber(email[1]))[1].user
    local d = SQL('SELECT discord from users where id = ?', user)[1].discord

    PerformHttpRequest('127.0.0.1:8080/now', function(err, text, header) end, 'POST',
    json.encode({
        username = d,
        name = GetName(char),
        message = email[2]
    }), { ['Content-Type'] = 'application/json'})
end)

local ids = {}
function PhoneConfirm(source, text, time, icon)
    local id = #ids + 1
    ids[id] = {promise:new(), source}
    time = time or 60
    CreateThread(function()
        Wait((time * 1000) + 1000)
        if ids[id] then
            ids[id][1]:resolve(false)
        end
    end)

    TriggerClientEvent('Phone.Confirm', source, text, time, icon, id)
    local val = Citizen.Await(ids[id][1])
    ids[id] = nil
    return val
end

RegisterNetEvent('Phone.Confirm', function(bool, id)
    local source = source
    if ids[id][2] == source then
        ids[id][1]:resolve(bool)
    end
end)

Task.Register('Ping', function(source, id)
    if tonumber(id) then
        local target = GetCharacterByID(tonumber(id))
        if exports['geo-interface']:PhoneConfirm(tonumber(target.serverid), "You've recieved location data", 30, 'location') then
            TriggerClientEvent('Tow.GPS', target.serverid, GetEntityCoords(GetPlayerPed(source)))
            TriggerClientEvent('PhoneNotif', source, 'location', 'Ping accepted', 5000)
        else
            TriggerClientEvent('PhoneNotif', source, 'location', 'Ping denied', 5000)
        end
    end
end)

Task.Register('Phone.GetAds', function(source)
    return ads
end)

Task.Register('Phone.SendAd', function(source, text)
    local char = GetCharacter(source)
    for k,v in pairs(ads) do
        if v.cid == char.id then
            table.remove(ads, k)
            break
        end
    end

    if text ~= '' then
        table.insert(ads, {message = text, name = char.first..' '..char.last, num = char.phone_number, cid = char.id})
    end
    TriggerClientEvent('Phone.SendAd', -1, ads)
    return ads
end)

Task.Register('Phone.Photos', function(source)
    local char = GetCharacter(source)
    local photos = SQL('SELECT photo, pid from phone_photos where cid = ?', char.id)
    return photos
end)

Task.Register('Phone.UploadPhoto', function(source, photo)
    local char = GetCharacter(source)
    SQL('INSERT INTO phone_photos (cid, photo) VALUES (?, ?)', char.id, photo)
    TriggerClientEvent('PhoneNotif', source, 'photos', 'Picture Taken', 5000)
end)

Task.Register('Phone.DeletePhoto', function(source, photo)
    local char = GetCharacter(source)
    SQL('DELETE FROM phone_photos WHERE cid = ? and pid = ?', char.id, photo)
end)

AddEventHandler('Logout', function(char)
    for k,v in pairs(ads) do
        if v.cid == char.id then
            table.remove(ads, k)
            TriggerClientEvent('Phone.SendAd', -1, ads)
            break
        end
    end
end)

exports('PhoneConfirm', PhoneConfirm)
