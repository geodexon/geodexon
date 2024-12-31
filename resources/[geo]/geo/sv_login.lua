Users = {}
Characters = {}
local lastLogin = {}
local times = {}

AddEventHandler('playerConnecting', function(name, setReason, def)
    local source = source

    def.defer()
    local done =def.done
    local result = GetUser(GetIdent(source), function(result)
        result = result
    end, source)

    local banned = CheckBan(result)
    if banned then
        def.done('[ID: '..banned.banid..'] '..banned.reason)
    end

    if GetConvar('sv_whitelist', 'false') == 'true' then
        if result.whitelist == 0 then
            def.done('You are not whitelisted on this server')
        end
    end

    playerConnect(name, setReason, def, result, source)
end)

function GetUser(ident, cb, source)
    local prom = promise:new()
    exports.ghmattimysql:execute('SELECT * FROM users WHERE license = @ID or (discord = @Discord and discord is not null) limit 1', {ID = ident.license, Discord = ident.discord}, function(res)
        if res[1] == nil then
            exports.ghmattimysql:execute('INSERT INTO users (username, steam, license, discord) VALUES (@Name, @Steam, @License, @Discord)', {
                Name = tostring(GetPlayerName(source)),
                Steam = ident.steamid,
                License = ident.license,
                Discord = ident.discord
            }, function(res)
                exports.ghmattimysql:execute('SELECT * FROM users WHERE license = @ID or (discord = @Discord and discord is not null) limit 1', {ID = ident.license, Discord = ident.discord}, function(result)
                    cb(result[1])
                    prom:resolve(result[1])
                end)
            end)
        else
            if ident.discord then
                SQL('UPDATE users SET discord = ? WHERE license = ?', ident.discord, ident.license)
            end
            cb(res[1])
            prom:resolve(res[1])
        end
    end)

    return Citizen.Await(prom)
end

local first = false
RegisterNetEvent('Characters.Download')
AddEventHandler('Characters.Download', function()
    local source = source
    local ident = GetIdent(source)
    SetPlayerRoutingBucket(source, 1)

    if not first then
        TriggerEvent('WorldReady')
        first = true
    end
    exports.ghmattimysql:execute('SELECT * FROM users WHERE license = @ID or (discord = @Discord and discord is not null) limit 1', {ID = ident.license, Discord = ident.discord}, function(res)
        Users[source] = res[1]
        SQL('UPDATE users SET license = ? where license = ? or (discord = ? and discord is not null)', ident.license, ident.license, ident.discord)
        Users[source].data = json.decode(Users[source].data)
        if ident.fivem then
            SQL('UPDATE users SET fivem = ? WHERE id = ?', ident.fivem, Users[source].id)
        end
        if Users[source].data.settings == nil then Users[source].data.settings = {} end

        exports.ghmattimysql:execute('SELECT * FROM characters WHERE user = @ID', {ID = res[1].id}, function(result)
            TriggerClientEvent('Characters.Download', source, result,Users[source], os.time())
        end)
    end)
end)

RegisterNetEvent('Character.Finish')
AddEventHandler('Character.Finish', function(firstname, lastname, dob, clothing, sex)
    local source = source

    if not dob then
        TriggerClientEvent('Shared.Notif', source, 'Invalid DOB')
        return
    end

    if not (firstname and lastname) then
        TriggerClientEvent('Shared.Notif', source, 'Invalid Name')
        return
    end

    if firstname ~= '' and lastname ~= '' and dob ~= '' and clothing ~= nil then
        exports.ghmattimysql:execute('INSERT INTO characters (user, first, last, dob, clothing, sex) VALUES (@User, @First, @Last, @Dob, @Clothing, @Sex)', {
            User = Users[source].id,
            First = firstname,
            Last = lastname,
            Dob = dob,
            Clothing = json.encode(clothing),
            Sex = sex == 'Female' and 1 or 0
            }, function(res)
                exports.ghmattimysql:execute('SELECT * from characters where id = @ID', {
                    ID = res.insertId
                    }, function(result)
                        Login(result[1], source, 'new')
                end)
        end)
    end
end)

RegisterNetEvent('Character.Select')
AddEventHandler('Character.Select', function(id)
    local source = source
    exports.ghmattimysql:execute('SELECT * FROM characters where id = @ID AND user = @User', {
        User = Users[source].id,
        ID = id
        }, function(res)
            Login(res[1], source)
    end)
end)

local charBL = {
    ['id'] = true,
    ['user'] = true,
    ['first'] = true,
    ['last'] = true,
    ['dob'] = true,
    ['serverid'] = true,
    ['Duty'] = true,
    ['Title'] = true,
    ['skills'] = true,
    ['username'] = true,
    ['home'] = true,
    ['interior'] = true,
    ['phone_number'] = true,
    ['job'] = true,
    ['data'] = true,
}

RegisterNetEvent('UpdateCharacter')
AddEventHandler('UpdateCharacter', function(type, data)
    local source = source

    if charBL[type] ~= nil then
        DropPlayer(source, '*baps with newspaper*')
        return
    end

    UpdateCharacter(source, type, data)
end)

RegisterNetEvent('Character.Delete')
AddEventHandler('Character.Delete', function(id)
    local source = source
    GetUser(GetIdent(source), function(result)
        exports.ghmattimysql:execute('SELECT * FROM characters a JOIN (SELECT amount, `id` FROM bank) b on a.`account` = b.id WHERE a.id = ? and a.user = ?', {
            id, result.id
        }, function(res)
            if res[1] ~= nil then
                if res[1].amount < 0 then
                    TriggerClientEvent('Shared.Notif', source, 'This characters debt is too high', 5000)
                    return
                end

                if res[1].amount > 10000 then
                    TriggerClientEvent('Shared.Notif', source, 'Too Much Money', 5000)
                    return
                end

                exports.ghmattimysql:execute('UPDATE characters SET user = @NEGID WHERE id = @ID', {ID = id, NEGID = -(result.id)}, function()
                    local source = source
                    local ident = GetIdent(source)
                    exports.ghmattimysql:execute('SELECT * FROM users WHERE license = @ID or (discord = @Discord and discord is not null) limit 1', {ID = ident.license, Discord = ident.discord}, function(res)
                        Users[source] = res[1]
                        Users[source].data = json.decode(Users[source].data)
                        if Users[source].data.settings == nil then Users[source].data.settings = {} end
                        exports.ghmattimysql:execute('SELECT * FROM characters WHERE user = @ID', {ID = res[1].id}, function(result)
                            TriggerClientEvent('Characters.Download', source, result, Users[source])
                        end)
                    end)
                end)
            end
        end)
    end, source)
end)

RegisterNetEvent('SaveWalk')
AddEventHandler('SaveWalk', function(walk)
    local source = source
    local char = Characters[source]
    if char then
        exports.ghmattimysql:execute('UPDATE characters set walkstyle = ? WHERE id = ?', {
            walk, char.id
        })
        UpdateCharacter(source, 'walkstyle', walk)
    end
end)

function UpdateCharacter(serverID, type, data)
    Characters[serverID][type] = data
    TriggerClientEvent('Character.Update', serverID, type, data)

    if type == 'dead' then
        Entity(GetPlayerPed(serverID)).state.dead = data
    end
end

function UpdateUser(serverID, type, data)
    Users[serverID][type] = data
    TriggerClientEvent('User.Update', serverID, type, data)
end

function Char(id)
    return Characters[id]
end
exports('Char', Char)

function CharFromID(id)
    for k,v in pairs(Characters) do
        if v.id == id then
            return Characters[k]
        end
    end
end
exports('CharFromID', CharFromID)
exports('UpdateCharacter', UpdateCharacter)
exports('GetUser', function(src)
    return Users[src]
end)

local cPos = {}

Citizen.CreateThread(function()
    while true do
        Wait(5000)
        for k,v in pairs(GetPlayers()) do
            if (Characters[tonumber(v)]) then
                if Characters[tonumber(v)].interior == nil then
                    local pos = {table.unpack(GetEntityCoords(GetPlayerPed(tonumber(v))))}
                    cPos[Characters[tonumber(v)].id] = json.encode(pos)
                end
            end
        end
    end
end)

AddEventHandler('Logout', function(char)
    if not cPos[char.id] then return end
    exports.ghmattimysql:execute('UPDATE characters SET pos = @Pos WHERE id = @ID', {
        Pos = cPos[char.id],
        ID = char.id
    })
end)

function CheckBan(user)
    local banned = exports.ghmattimysql:executeSync('SELECT * from bans WHERE identifier = @License and active = 1', {
        License = user.license
    })[1]

    if banned then
        return banned
    end
end

AddEventHandler('playerDropped', function()
    local source = source
    if Characters[source] then
        TriggerEvent('Logout', Characters[source])
        Wait(2500)
        Characters[source] = nil
    end
end)

local logging = {}
RegisterCommand('logout', function(source)
    if not Characters[source] then
        return
    end

    if logging[source] then
        return
    end

    if Characters[source].interior == nil then
        TriggerClientEvent('Shared.Notif', source, "You can only log out from a property")
        return
    end

    logging[source] = true
    TriggerClientEvent('Shared.Notif', source, "Don't move for 30 seconds to log out")
    local start = os.time()
    local ped = GetPlayerPed(source)
    local pos = GetEntityCoords(ped)
    logging[source] = nil
    

    if Characters[source].interior == nil then
        local pos = {table.unpack(GetEntityCoords(GetPlayerPed(source)))}
        exports.ghmattimysql:execute('UPDATE characters SET pos = @Pos WHERE id = @ID', {
            Pos = json.encode(pos),
            ID = Characters[source].id
        })
    end
    
    TriggerClientEvent('Logout', source)
    lastLogin[Characters[source].id] = nil
    TriggerEvent('Logout', Characters[source])

    Characters[source] = nil
    exports['geo-inventory']:RemoveInventory(source)
end)

function CreateCharacterObject(source)
    local obj = New(Characters[source])

    function obj:AddItem(itemID, amount, itemData, slot)
        return exports['geo-inventory']:AddItem('Player', source, itemID, amount, itemData, slot)
    end

    function obj:RemoveItem(itemID, amount, slot)
        return exports['geo-inventory']:RemoveItem('Player', source, itemID, amount, slot)
    end

    Characters[source] = obj
end

function Login(result, source, flag)

    if Users[source].data.work and Users[source].data.work[1] == result.id then
        if os.time() < Users[source].data.work[3] then
            local since = _TimeSince(Users[source].data.work[3])
            TriggerClientEvent('Shared.Notif', source, ('%s hours and %s minutes and %s minutes until work is over'):format(since.hours, since.minutes, since.seconds))
            return
        end
    end

    Characters[source] = result
    Characters[source].skills = json.decode(Characters[source].skills)
    Characters[source].data = json.decode(Characters[source].data)
    Characters[source].serverid = source
    Player(source).state.cid = result.id
    SetPlayerRoutingBucket(source, 0)
    times[source] = os.time()

    if Characters[source].phone_number == nil then
        Characters[source].phone_number = GeneratePhone()
        SQL('UPDATE characters set phone_number = ? WHERE id = ?', Characters[source].phone_number, Characters[source].id)
    end

    TriggerClientEvent('Character.Select', source, result, Users[source], GetLoginMethod(Characters[source], flag))
    TriggerEvent('Login', Characters[source], Users[source])
    CreateCharacterObject(source)
    SQL('UPDATE characters set lastlogin = Now() WHERE id = ?', result.id)

    Console('[Login]', GetPlayerName(source)..' logged in as '..GetName(Characters[source])..' (ID: '..Characters[source].id..')')
    if not lastLogin[result.id] then
        lastLogin[result.id] = true
    end

    exports['geo-inventory']:FetchMe(source)
    if flag == 'new' then
        exports['geo-inventory']:AddItem('Player', source, 'phone', 1)

        local item = exports['geo-inventory']:InstanceItem('id')
        item.Data.cid = Characters[source].id
        item.Data.first = Characters[source].first
        item.Data.last = Characters[source].last
        item.Data.dob = Characters[source].dob
        item.Data.sex = Characters[source].sex == 1 and 'Female' or 'Male'
        exports['geo-inventory']:AddItem('Player', source, 'id', 1, item)
        TriggerClientEvent('Help', source, 0)
    end
end

function GetLoginMethod(char, flag)

    local found = SQL('SELECT * from jail WHERE cid = ? order by id desc limit 1', char.id)[1]

    if found and found.time > 0 then
        if found.time > 240 then
            local time = math.floor((os.time() - math.floor(found.start / 1000)) / 60 )
            found.time = found.time - time
        else
            local time = math.floor((os.time() - math.floor(found.start / 1000)) / 60 )
            time = math.floor(time / 10)
            found.time = found.time - time
        end

        if found.time > 0 then
            return 'jail'
        end
    end

    if lastLogin[char.id] ~= nil or flag == 'new' then
        return 'wakeup_last_location'
    else
        return 'wakeup_in_apartment'
    end
end

function GetCharWithPhone(number)
    for k,v in pairs(Characters) do
        if math.floor(v.phone_number) == number then
            return v
        end
    end
end

function GeneratePhone()
    local done = false
    local phone
    while not done do
        phone = Random(1000000000, 9999999999)
        done = SQL('SELECT * FROM characters WHERE phone_number = ?', phone)[1] == nil
        Wait(100)
    end

    return phone
end

CreateThread(function()
    while true do
        Wait(300000)
        exports.ghmattimysql:execute('SELECT 1')
    end
end)

exports('GetCharWithPhone', GetCharWithPhone)

Task.Register('CheckDiscord', function(source)
    local prom = promise:new()

    exports['geo-dcord']:Check(source, function(res)
        prom:resolve(res)
    end)

    return Citizen.Await(prom)
end)

function _SetData(source, key, val)
    if Characters[source] then
        Characters[source]['data'][key] = val
        SQL('UPDATE characters set data = ? WHERE id = ?', json.encode(Characters[source].data), Characters[source].id)
        UpdateCharacter(source, 'data', Characters[source]['data'])
    end
end

function _SetData2(source, key, val)
    if Users[source] then
        Users[source]['data'][key] = val
        SQL('UPDATE users set data = ? WHERE id = ?', json.encode(Users[source].data), Users[source].id)
        UpdateUser(source, 'data', Users[source]['data'])
    end
end

Task.Register('MagicSchoolBus', function(source)
    SetPlayerRoutingBucket(source, source * 1000)
    SetRoutingBucketPopulationEnabled(source * 1000, false)
end)

Task.Register('MagicSchoolBusDone', function(source)
    SetPlayerRoutingBucket(source, 0)
end)

exports('SetData', _SetData)
exports('SetUserData', _SetData2)

RegisterCommand('_buyvip', function(source, args, raw)
    if source == 0 then
        Log('Tebex', args[1]..' bought a VIP '..json.encode(args))
        local prio = 0
        if args[2] == 'bronze' then prio = 1 end
        if args[2] == 'silver' then prio = 2 end
        if args[2] == 'gold' then prio = 3 end
        if args[2] == 'diamond' then prio = 4 end
        if args[3] == 'false' then prio = 0 end
        SQL('UPDATE users SET whitelist = ? WHERE fivem = ?', prio, tonumber(args[1]))
        for k,v in pairs(GetPlayers()) do
            if tonumber(GetIdent(tonumber(v)).fivem) == tonumber(args[1]) then
                TriggerClientEvent('Shared.Notif', v, 'Your priority has been set to '..prio, 15000)
            end
        end
    end
end)

AddEventHandler('Logout', function(char)
    local mth = math.floor((os.time() - times[char.serverid]) / 60)
    SetUserData(char.serverid, 'TimePlayed', (Users[char.serverid].data.TimePlayed or 0) + mth)
    times[char.serverid] = os.time()
end)

AddEventHandler('txAdmin:events:serverShuttingDown', function()
    for k,v in pairs(Characters) do
        if times[v.serverid] then
            local mth = math.floor((os.time() - times[v.serverid]) / 60)
            SetUserData(v.serverid, 'TimePlayed', (Users[v.serverid].data.TimePlayed or 0) + mth)
        end
    end
end)

AddEventHandler('Login', function(char, user)
    if user.data.myref and user.data.myref ~= 'done' and user.data.TimePlayed >= 300 then
        Wait(1000)
        ExecuteCommand('_addcredit '..user.id..' dollar 5000')
        local data = SQL('SELECT id from users where json_value(`data`, "$.ref") = ?', user.data.myref)[1].id
        Wait(500)
        ExecuteCommand('_addcredit '..data..' dollar 5000')

        SetUserData(char.serverid, 'myref', 'done')
        Log('Ref', {NewUser = user.id, CodeFrom = data})
    end
end)