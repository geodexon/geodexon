local auth = {}

function Authenticate(id, type)
    if not auth[id] then
        auth[id] = {}
    end

    local val = Random(999999999999999999)
    auth[id][type] = val
    return val
end

function Verify(id, type, val)
    local math = auth[id][type] == val

    auth[id][type] = nil
    return math
end

exports('Authenticate', Authenticate)
exports('Verify', Verify)

RegisterCommand('kick', function(source, args, raw)
    if GetCharacter(source).username then
        if tonumber(args[1]) then
            local reason = raw:sub(('kick '..args[1]..' '):len())
            DropPlayer(tonumber(args[1]), reason..' ['..GetPlayerName(source)..']')
        end
    end
end)

RegisterCommand('ban', function(source, args, raw)
    if GetCharacter(source).username then
        if tonumber(args[1]) then

            if GetPlayerEndpoint(tonumber(args[1])) == nil then
                return
            end

            local reason = raw:sub(('ban '..args[1]..' '):len())
            exports.ghmattimysql:executeSync('INSERT INTO bans (identifier, reason, author) VALUES (@Ident, @Reason, @Auth)', {
                Ident = GetIdent(tonumber(args[1])).license,
                Reason = reason,
                Auth = GetUser(source).id
            })
            DropPlayer(tonumber(args[1]), 'Ban: '..reason..' ['..GetPlayerName(source)..']')
        end
    end
end)

RegisterCommand('setattr', function(source, args, raw)
    if GetCharacter(source).username then
        if tonumber(args[2]) then
            UpdateChar(source, args[1], tonumber(args[2]))
        else
            UpdateChar(source, args[1], args[2])
        end

        Console('[Staff]', GetCharacter(source).username..' set '..args[1]..' : '..args[2])
        LogStaff(source, 'Character Attribute', {field = args[1], value = args[2]})
    end
end)

RegisterNetEvent('Staff:TP')
AddEventHandler('Staff:TP', function(user, pos)
    local source = source
    if GetCharacter(source).username then
        local ped = GetPlayerPed(user)
        if DoesEntityExist(ped) then
            SetEntityCoords(ped, pos)
        end
    end
end)

RegisterNetEvent('StaffTPMe', function(id)
    local source = source
    SetEntityCoords(GetPlayerPed(source), GetEntityCoords(GetPlayerPed(id)))
end)

RegisterNetEvent('GetPlayerList')
AddEventHandler('GetPlayerList', function()
    local source = source
    local list = {}
    for k,v in pairs(GetPlayers()) do
        table.insert(list, {
            serverID = tonumber(v),
            name = GetPlayerName(v)
        })
    end
    TriggerClientEvent('GetPlayerList', source, list)
end)

local frozen = {}
RegisterNetEvent('Staff:Freeze')
AddEventHandler('Staff:Freeze', function(user)
    local source = source
    if GetCharacter(source).username then
        if frozen[user] then
            SetPlayerControl(user, true)
            frozen[user] = false
        else
            SetPlayerControl(user, false)
            frozen[user] = true
        end
    end
end)

RegisterCommand('heal2', function(source, args)
    if GetCharacter(source).username then
        local id = tonumber(args[1]) or source
        if DoesEntityExist(GetPlayerPed(id)) then
            LogStaff(source, 'heal', {target = GetCharacter(id).id})
            TriggerClientEvent('Heal', id)
        end
    end
end)

RegisterCommand('armor', function(source, args)
    if GetCharacter(source).username then
        local id = tonumber(args[1]) or source
        local ped = GetPlayerPed(id)
        if DoesEntityExist(ped) then
            SetPedArmour(ped, tonumber(args[2]) or 200)
            LogStaff(source, 'Armor', {target = GetCharacter(id).id})
        end
    end
end)


RegisterNetEvent('give')
AddEventHandler('give', function(item, amount)
    local source = source
    if GetCharacter(source).username ~= nil then
        exports['geo-inventory']:ReceiveItem('Player', source, item or 'dollar', tonumber(amount) or 1)
        LogStaff(source, 'Item', {item = item, amount = amount})
    end
end)

function LogStaff(source, action, extra)
    local query = ''
    if extra then
        query = 'INSERT INTO staff_actions (user, action, extra) VALUES (?, ?, ?)'
    else
        query = 'INSERT INTO staff_actions (user, action) VALUES (?, ?)'
    end

    extra = extra or {}
    exports.ghmattimysql:execute(query, {GetCharacter(source).user, action, json.encode(extra)})
end

local conceal = {}
RegisterCommand('conceal', function(source, args)
    local char = GetCharacter(source)
    if char.username then
        conceal[source] = conceal[source] == nil and true or nil
        TriggerClientEvent('Conceal', -1, source, conceal[source], tonumber(args[1] or 0))
    end
end)