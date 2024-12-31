dutyState = {}
Duty = {Police = {}, EMS = {}, Tow = {}, DOJ = {}, Taxi = {}}
Blips = {}

CreateThread(function()
    while true do
        Wait(2500)
        SendBlips()
    end
end)

function SendBlips()
    for k,v in pairs(Blips) do
        Blips[k].pos = GetEntityCoords(GetPlayerPed(v.sid))
    end

    ESEvent('Duty.Blips', Blips)
end

local dutyTimes = {}
RegisterNetEvent('Duty')
AddEventHandler('Duty', function(dutyType)
    local source = source
    local char = GetCharacter(source)
    local nTitle

    if char.id == nil then
        return
    end

    if dutyState[source] == nil then
        if dutyType == 'Police' then
            if not IsPolice(char.id) and char.username == nil then
                return
            end

            for k,v in pairs(Departments.Police) do
                if exports['geo-guilds']:GuildAuthority(k, char.id) > 100 then
                    nTitle = exports['geo-guilds']:GuildTitle(k, char.id)
                end
            end
        elseif dutyType == 'EMS' then
            if not IsEMS(char.id) and char.username == nil then
                return
            end
        elseif dutyType == 'DOJ' then
            if not IsDOJ(char.id) and char.username == nil then
                return
            end
        else
            if Duty[dutyType] == nil then
                return
            end
        end

        table.insert(Duty[dutyType], char.id)
        dutyState[source] = dutyType
        UpdateChar(source, 'Duty', dutyType)
        UpdateChar(source, 'Title', nTitle)
        dutyTimes[source] = os.time()
        TriggerClientEvent('Shared.Notif', source, 'Duty: '..dutyType)
        TriggerClientEvent('DutyState', source, dutyType, true)
        TriggerEvent('GetDutyList')
        TriggerEvent('OnDuty', source, dutyType)

        if dutyType == 'Police' or dutyType == 'EMS' then
            Blips[source] = {callsign = char.callsign, duty = dutyType, sid =  source}
            SendBlips()
        end
    else
        for k,v in pairs(Duty[dutyState[source]]) do
            if v == char.id then
                table.remove(Duty[dutyState[source]], k)
                break
            end
        end
        UpdateChar(source, 'Duty', nil)
        UpdateChar(source, 'Title', nil)
        TriggerClientEvent('Shared.Notif', source, 'Duty: Off Duty')
        TriggerClientEvent('DutyState', source, dutyType, false)
        TriggerEvent('GetDutyList')
        Blips[source] = nil
        TriggerClientEvent('Police.ClearBlips', source)
        SendBlips()

        local mth = os.time() - dutyTimes[source]
        if math.floor(mth / 60) > 0 then
            Log('Duty', {cid = char.id, time = math.floor(mth / 60), job = dutyState[source], department = IsPolice(char.id)})
            dutyTimes[source] = nil
        end

        dutyState[source] = nil
    end
end)

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining == 60 then
        for k,v in pairs(dutyTimes) do
            local char = GetCharacter(k)
            local mth = os.time() - dutyTimes[k]
            if math.floor(mth / 60) > 0 then
                Log('Duty', {cid = char.id, time = math.floor(mth / 60), job = dutyState[k], department = IsPolice(char.id)})
                dutyTimes[k] = os.time()
            end
        end
    end
end)

AddEventHandler('Logout', function(char)
    Blips[char.serverid] = nil
    TriggerClientEvent('Police.ClearBlips', char.serverid)
    SendBlips()

    if not dutyTimes[char.serverid] then return end
    local mth = os.time() - dutyTimes[char.serverid]
    if math.floor(mth / 60) > 0 then
        Log('Duty', {cid = char.id, time = math.floor(mth / 60), job = dutyState[char.serverid], department = IsPolice(char.id)})
    end
    dutyTimes[char.serverid] = nil
end)

RegisterNetEvent('GetDutyList')
AddEventHandler('GetDutyList', function()
    local source = source
    local lst = {}
    lst['Police'] = {}
    lst['EMS'] = {}
    lst['DOJ'] = {}
    for k,v in pairs(dutyState) do
        if v == 'Police' then
            table.insert(lst['Police'], GetName(GetCharacter(k)))
        elseif v == 'EMS' then
            table.insert(lst['EMS'], GetName(GetCharacter(k)))
        end
    end
    TriggerClientEvent('GetDutyList', (source ~= '' and source or -1), lst)
end)

local handsup = {}
RegisterNetEvent('Handsup')
AddEventHandler('Handsup', function(bool)
    local source = source
    handsup[source] = bool
end)

RegisterCommand('locker', function(source, args)
    local char = GetCharacter(source)
    if char.id then
        local isEs = IsES(char.id)
        if isEs then
            local num = tonumber(args[1])
            if num then
                local myAuth = exports['geo-guilds']:GuildAuthority(isEs, char.id)
                local targetAuth = exports['geo-guilds']:GuildAuthority(IsES(num), num)

                if myAuth > 1500 and myAuth > targetAuth then
                    exports['geo-inventory']:OpenInventory(source, 'Locker', 'Locker-'..num)
                else
                    TriggerClientEvent('Shared.Notif', source, 'You can not access this')
                end
            end
        end
    end
end)

RegisterCommand('evidence', function(source, args)
    local char = GetCharacter(source)
    if char.id then
        if char.Duty == 'Police' and args[1] then
            exports['geo-inventory']:OpenInventory(source, 'Evidence', args[1])
        end
    end
end)

RegisterCommand('callsign', function(source, args)
    local char = GetCharacter(source)
    if char.id then

        if not IsES(char.id) then
            return
        end

        local callsign = args[1]
        if not args[1] then
            TriggerClientEvent('Chat.Message', source, '[Badge]', 'Callsign is currently '..(char.callsign or ''), 'job')
            return
        end

        callsign = callsign:upper()

        exports.ghmattimysql:execute('SELECT id, first, last from characters WHERE callsign = @Callsign', {
            Callsign = callsign
        }, function(res)
            if not res[1] then
                exports.ghmattimysql:execute('UPDATE characters SET callsign = @Callsign WHERE id = @ID', {
                    Callsign = callsign,
                    ID = char.id
                })
                UpdateChar(source, 'callsign', callsign)
                TriggerClientEvent('Chat.Message', source, '[Badge]', 'Callsign set to '..callsign, 'job')
            else
                TriggerClientEvent('Chat.Message', source, '[Badge]', ('Callsign "%s" is taken by %s %s'):format(callsign, res[1].first, res[1].last), 'job')
            end
        end)
    end
end)

local callIndex = 0
local calls = {}
local callTime = {}

RegisterCommand('911', function(source, args)
    local char = GetCharacter(source)
    if char then
        local name = char.first..' '..char.last
        local message = table.concat(args, ' ')

        if message ~= '' then
            if not callTime[source] then
                callTime[source] = 0
            end

            local _time = os.time()
            if _time - callTime[source] > 300 then
                callTime[source] = _time
                local _index = callIndex + 1
                callIndex = callIndex + 1
                calls[source] = _index
            end
            TriggerEvent('Dispatch', {
                code = '911',
                title = 'Call #'..callIndex,
                location = nil,
        
                time =  os.date('%H:%M EST'),
                info = {
                    {
                        icon = 'person',
                        text = name,
                    },
                    {
                        icon = 'person',
                        text = message,
                    },
                },
                EMS = true,
                hidden = true
            })


            --ESEvent('Chat.Message', '[911]', '[Call #'..calls[source]..'] '..name..' : '..message, '911')
            TriggerClientEvent('Chat.Message', source, '[911]', '[Call #'..calls[source]..'] '..name..' : '..message, '911')
            exports['geo-es']:PoliceEvent('AddTempBlip', 'null', GetEntityCoords(GetPlayerPed(source)) + vec(Random(100), Random(100), 0), {color = 1})
        end
    end
end)


RegisterCommand('311', function(source, args)
    local char = GetCharacter(source)
    if char then
        local name = GetName(char)
        local message = table.concat(args, ' ')

        if message ~= '' then
            if not callTime[source] then
                callTime[source] = 0
            end

            local _time = os.time()
            if _time - callTime[source] > 300 then
                callTime[source] = _time
                local _index = callIndex + 1
                callIndex = callIndex + 1
                calls[source] = _index
            end

            ESEvent('Chat.Message', '[311]', '[Call #'..calls[source]..'] '..name..' : '..message, '311')
            TriggerClientEvent('Chat.Message', source, '[311]', '[Call #'..calls[source]..'] '..name..' : '..message, '311')
        end
    end
end)

RegisterCommand('311r', function(source, args)
    local char = GetCharacter(source)
    local num = tonumber(args[1])
    local message = table.concat(args, ' ', 2)
    if num and char and IsES(char.id) and message ~= '' then
        for k,v in pairs(calls) do
            if v == num then
                local msg = 'Reponse to Call #'..v..': '..message

                ESEvent('Chat.Message', '[311]', msg, '311')
                if k ~= char.serverid then
                    TriggerClientEvent('Chat.Message', k, '[311]', msg, '311')
                end
            end
        end
    end
end)

RegisterCommand('911r', function(source, args)
    local char = GetCharacter(source)
    local num = tonumber(args[1])
    local message = table.concat(args, ' ', 2)
    if num and char and IsES(char.id) and message ~= '' then
        for k,v in pairs(calls) do
            if v == num then
                local msg = 'Reponse to Call #'..v..': '..message
                
                ESEvent('Chat.Message', '[911]', msg, '911')
                if k ~= char.serverid then
                    TriggerClientEvent('Chat.Message', k, '[911]', msg, '911')
                end
            end
        end
    end
end)

RegisterNetEvent('ES:Fix')
AddEventHandler('ES:Fix', function(vehNet, bool)
    TriggerClientEvent('ES:Fix', -1, vehNet, bool)
end)

local dragging = {}
RegisterNetEvent('Drag')
AddEventHandler('Drag', function(plyr)
    local source = source
    local char = GetCharacter(source)
    local othr = GetCharacter(plyr)

    if not dragging[source] then
        if plyr == 0 then
            return
        end

        for k,v in pairs(dragging) do
            if v == plyr then
                return
            end
        end

        if handsup[plyr] or (othr and othr.dead == 1) then
            Drag(source, plyr)
            return
        end

        if IsES(char.id) then
            Drag(source, plyr)
            return
        end
    else
        StopDrag(source)
    end
end)

RegisterNetEvent('PutInCar')
AddEventHandler('PutInCar', function(veh, seat)
    local source = source
    if dragging[source] then

        if Entity(NetworkGetEntityFromNetworkId(veh)).state.fake then
            TriggerClientEvent('Shared.Notif', source, 'This vehicle is locked tight')
            return
        end

        TriggerClientEvent('PutInCar', dragging[source], veh, seat)
        StopDrag(source)
    end
end)

RegisterNetEvent('Pullout')
AddEventHandler('Pullout', function(veh, player, class)
    local source = source
    local char = GetCharacter(source)
    local veh = NetworkGetEntityFromNetworkId(veh)
    if class == 18 then
        if not IsES(char.id) then
            return
        end
    end

    local othr = GetCharacter(player)

    if not dragging[source] then
        if player == 0 then
            return
        end

        for k,v in pairs(dragging) do
            if v == player then
                return
            end
        end

        if handsup[player] or (othr and othr.dead == 1) then
            Drag(source, player)
            return
        end

        if IsES(char.id) then
            Drag(source, player)
            return
        end
    else
        StopDrag(source)
    end

    --[[ TriggerClientEvent('Pullout', -1, veh) ]]
end)

RegisterNetEvent('Locker')
AddEventHandler('Locker', function(veh)
    local source = source
    local char = GetCharacter(source)
    if IsES(char.id) then
        exports['geo-inventory']:OpenInventory(source, 'Locker', 'Locker-'..char.id)
    end
end)

RegisterNetEvent('Fix')
AddEventHandler('Fix', function(veh)
    TriggerClientEvent('Fix', -1, veh)
end)

AddEventHandler('Logout', function(char)
    local source = char.serverid
    if char then
        if dutyState[source] then
            for k,v in pairs(Duty[dutyState[source]]) do
                if v == char.id then
                    table.remove(Duty[dutyState[source]], k)
                    break
                end
            end
            dutyState[source] = nil
        end
    end
end)

AddEventHandler('playerDropped', function() 
    local source = source
    for k,v in pairs(dragging) do
        if v == source then
            dragging[k] = nil
            break
        end
    end

    Blips[source] = nil
    calls[source] = nil
end)

RegisterNetEvent('Search')
AddEventHandler('Search', function(plyr)
    local source = source
    local char = GetCharacter(source)

    if plyr == 0 then
        return
    end

    if IsPolice(char.id) then
        exports['geo-inventory']:OpenInventory(source, 'Player', tostring(plyr))
        return
    end

    --[[ if handsup[plyr] then
        exports['geo-inventory']:OpenInventory(source, 'Player', tostring(plyr))
        return
    end ]]
end)

RegisterNetEvent('ES.Panic')
AddEventHandler('ES.Panic', function(loc)
    local source = source
    local char = GetCharacter(source)
    if IsES(char.id) and (char.Duty == 'Police' or char.Duty == 'EMS') then
        ESEvent('AddTempBlip', '10-13', GetEntityCoords(GetPlayerPed(source)))
        ESEvent('Panic')
        TriggerEvent('Dispatch', {
            code = '10-13',
            title = 'Officer/Medic in Trouble',
            location = loc.position,
    
            time =  os.date('%H:%M EST'),
            info = {
                {
                    icon = 'location',
                    text = loc.location,
                    location = true
                },
                {
                    icon = 'person',
                    text = char.callsign,
                },
            }
        })
    end
end)

local dutyOutfits = {}
Task.Register('Duty.Outfits', function(source, job)
    if not dutyOutfits[job] then
        dutyOutfits[job] = SQL('SELECT * from outfits WHERE guild = ?', job)
    end

    return dutyOutfits[job]
end)

RegisterNetEvent('Duty.DeleteOutfit', function(outfit)
    local source = source
    local job
    local char = GetCharacter(source)
    if char.Duty == 'Police' then
        job = IsPolice(char.id)
    elseif char.Duty == 'EMS' then
        job = IsEMS(char.id)
    end

    SQL('DELETE from outfits WHERE outfit = ? and guild = ?', outfit, job)

    for k,v in pairs(dutyOutfits[job]) do
        if v.outfit == outfit then
            table.remove(dutyOutfits[job], k)
            break
        end
    end
end)

Task.Register('Duty.ClothingSave', function(source, clothingData)
    local job
    local char = GetCharacter(source)
    if char.Duty == 'Police' then
        job = IsPolice(char.id)
    elseif char.Duty == 'EMS' then
        job = IsEMS(char.id)
    end

    SQL('INSERT INTO outfits (cid, clothing, guild) VALUES (?, ?, ?)', 0, json.encode(clothingData), job)
    dutyOutfits[job] = SQL('SELECT * from outfits WHERE guild = ?', job)
end)

Task.Register('Duty.History', function(source, job, pVal)
    if not job or not pVal then return end
    local char = GetCharacter(source)
    local val = SQL('SELECT data FROM log WHERE `type` = "Duty" AND JSON_VALUE(`data`, "$.department") = ? AND `date` > NOW() - INTERVAL ? day', job, pVal)

    local count = {}
    for k,v in pairs(val) do
        v = json.decode(v.data)
        if count[v.cid] == nil then 
            count[v.cid] = v.time 
        else
            count[v.cid] = count[v.cid] + v.time 
        end
    end

    local timeDate = SQL([[select DATE_FORMAT(NOW() - INTERVAL ? DAY, '%M %D %Y') as res]], pVal)[1].res

    for k,v in pairs(count) do
        local time = _TimeSince(os.time() + (v * 60))
        local name = SQL('SELECT first, last from characters WHERE id = ?', k)[1]
        local total = math.floor(SQL('SELECT time from jobs where cid = ? and business = ?', k, char.Duty)[1].time)
        total = _TimeSince(os.time() + (total * 60))
        total = Format('Total: %s hours and %s minutes', total.hours, total.minutes)

        count[k] = {Format('%s hours and %s minutes', time.hours, time.minutes), Format('%s %s', name.first, name.last), timeDate, total}
    end

    return count
end)

function Drag(source, plyr)
    dragging[source] = plyr
    TriggerClientEvent('Drag', plyr, source)
    UpdateChar(source, 'Dragging', true)
    UpdateChar(plyr, 'dragged', true)
end

function StopDrag(source)
    local p = dragging[source]
    TriggerClientEvent('StopDrag', p)
    UpdateChar(source, 'Dragging', false)
    UpdateChar(p, 'dragged', false)
    dragging[source] = nil
end

function ESEvent(eventName, ...)
    for k,v in pairs(dutyState) do
        if v == 'Police' or v == 'DOJ' or v == 'EMS' then
            TriggerClientEvent(eventName, k, ...)
        end
    end
end

function EMSEvent(eventName, ...)
    for k,v in pairs(dutyState) do
        if v == 'EMS' then
            TriggerClientEvent(eventName, k, ...)
        end
    end
end

exports('Handsup', function(id)
    return handsup[id]
end)

exports('Dragging', function(id)
    return dragging[id]
end)

exports('StopDrag', StopDrag)
exports('ESEvent', ESEvent)
exports('EMSEvent', EMSEvent)

exports('DutyCount', function(id)
    return #Duty[id]
end)