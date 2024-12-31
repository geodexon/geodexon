local vehList = {}
firstNames = json.decode(LoadResourceFile(GetCurrentResourceName(), 'Files/first-names.json'))
lastNames = json.decode(LoadResourceFile(GetCurrentResourceName(), 'Files/surnames.json'))
local prom = {}
local raidables = {}

RegisterNetEvent('Crime:StealVehicle')
AddEventHandler('Crime:StealVehicle', function(ent, loc, title, color)
    local entity = NetworkGetEntityFromNetworkId(ent)
    if DoesEntityExist(entity) then
        if Entity(entity).state.vin then return end
        local plate = (Entity(entity).state.plate) or GetVehicleNumberPlateText(entity)

        if vehList[plate] == nil then
            vehList[plate] = {}
        end
        if vehList[plate].stolen == nil then
            vehList[plate].stolen = true
            if exports.ghmattimysql:scalarSync('SELECT plate from vehicles where plate = @Plate', {Plate = plate}) ~= nil then
                return
            end
            local partial = SplitString(plate, plate:sub(0, 2))[1]
            TriggerEvent('Dispatch', {
                code = '10-35',
                title = 'Stolen Vehicle',
                location = loc.position,

                time =  os.date('%H:%M EST'),
                info = {
                    {
                        icon = 'location',
                        text = loc.location,
                        location = false
                    },
                    {
                        icon = 'car',
                        text = title
                    },
                    {
                        icon = 'car',
                        text = color
                    },
                    {
                        icon = 'car',
                        text = partial
                    },
                }
            })
        end
    end
end)

AddEventHandler('StolenPlate', function(plate)
    if vehList[plate] == nil then
        vehList[plate] = {}
    end
    vehList[plate].stolen = true
end)

RegisterNetEvent('Police.ShotFired')
AddEventHandler('Police.ShotFired', function(loc)
    local source = source
    TriggerEvent('Dispatch', {
        code = '10-32',
        title = 'Shots Fired',
        location = loc.position,

        time =  os.date('%H:%M EST'),
        info = {
            {
                icon = 'location',
                text = loc.location,
                location = false
            },
        }
    })
    PoliceEvent('AddTempBlip', '10-32', loc.position)
end)

RegisterNetEvent('Crime:AttemptStealVehicle')
AddEventHandler('Crime:AttemptStealVehicle', function(ent, loc, title)
    local entity = NetworkGetEntityFromNetworkId(ent)
    if DoesEntityExist(entity) then

        if Entity(entity).state.vin then return end
        local plate = (Entity(entity).state.plate) or GetVehicleNumberPlateText(entity)

        if vehList[plate] == nil then
            vehList[plate] = {}
        end
        if vehList[plate].stolen == nil then
            if exports.ghmattimysql:scalarSync('SELECT plate from vehicles where plate = @Plate', {Plate = plate}) ~= nil then
                return
            end
            local partial = SplitString(plate, plate:sub(0, 2))[1]
            TriggerEvent('Dispatch', {
                code = '10-35A',
                title = 'Attempted Vehicle Theft',
                location = loc.position,

                time =  os.date('%H:%M EST'),
                info = {
                    {
                        icon = 'location',
                        text = loc.location,
                        location = true
                    },
                    {
                        icon = 'car',
                        text = title
                    },
                }
            })
            vehList[plate].stolen = true
        end
    end
end)


RegisterCommand('reportveh', function(source, args, raw)
    if not args[1] or not args[2] then
        return
    end

    local char = GetCharacter(source)
    if char and char.Duty == 'Police' then
        local plate = raw:sub(('/reportveh '..args[1]..' '):len()):upper()
        if not vehList[plate] then
            vehList[plate] = {}
        end

        if args[1]:lower() == 'stolen' then
            vehList[plate].stolen = true
            TriggerClientEvent('Shared.Notif', source, 'Plate: "'..plate..'" marked as stolen', 5000)
        elseif args[1]:lower() == 'recovered' then
            vehList[plate].stolen = false
            TriggerClientEvent('Shared.Notif', source, 'Plate: "'..plate..'" marked as recovered', 5000)
        end
    end
end)

RegisterNetEvent('GetPlate')
AddEventHandler('GetPlate', function(plate)
    local source = source
    if prom[source] then
        prom[source]:resolve(plate)
    end
end)

RegisterNetEvent('Cuff')
AddEventHandler('Cuff', function(plyr)
    local source = source
    local char = GetCharacter(source)
    local player = GetCharacter(plyr)

    if player.cuff == 0 or player.cuff == nil then
        if char.Duty == 'Police' then
            TriggerClientEvent('Shared.Notif', source, 'Attempting Cuff')
            Wait(500)
            if Vdist4(GetEntityCoords(GetPlayerPed(source)), GetEntityCoords(GetPlayerPed(plyr))) <= 5.0 then
                UpdateChar(plyr, 'cuff', 1)
                TriggerClientEvent('Cuff:Origin', source)
                TriggerClientEvent('Cuff:Target', plyr, source)
            end
        end
    else
        if char.Duty == 'Police' then
            if Vdist4(GetEntityCoords(GetPlayerPed(source)), GetEntityCoords(GetPlayerPed(plyr))) <= 5.0 then
                UpdateChar(plyr, 'cuff', 0)
                TriggerClientEvent('Cuff:UncuffOrigin', source)
            end
        end
    end
end)

Task.Register('Cuff', function(source, num)
    UpdateChar(source, 'cuff', num)
    return true
end)

local gsr = {}
RegisterNetEvent('GSR:Init')
AddEventHandler('GSR:Init', function()
    local source = source
    local char = GetCharacter(source)
    gsr[char.id] = os.time()
end)

RegisterNetEvent('GSR:Check')
AddEventHandler('GSR:Check', function(target)
    local source = source
    if exports['geo-inventory']:HasItem('Player', source, 'gsr') then
        local othr = GetCharacter(target)
        if othr then
            local time = os.time()
            local positive = gsr[othr.id] and (time - gsr[othr.id] <= 900)
            TriggerClientEvent('Shared.Notif', source, 'GSR: '..(positive and 'Positive' or 'Negative'))
        end
    end
end)

RegisterNetEvent('Breath:Check')
AddEventHandler('Breath:Check', function(target)
    local source = source
    if exports['geo-inventory']:HasItem('Player', source, 'breathalyzer') then
        local othr = GetCharacter(target)
        if othr then
            TriggerClientEvent('Shared.Notif', source, (source == target and 'Your ' or '')..'BAC: '..(othr.BAC or 0.0))
        end
    end
end)

RegisterNetEvent('Frisk')
AddEventHandler('Frisk', function(target)
    local source = source
    local char = GetCharacter(source)
    if char.Duty == 'Police' then
        TriggerEvent('_Frisk', source, target)
    end
end)

RegisterNetEvent('Police.RaidLocation')
AddEventHandler('Police.RaidLocation', function(id)
    local source = source
    local char = GetCharacter(source)
    if char.Duty == 'Police' then
        if raidables[id] then
            exports['geo-instance']:EnterProperty(source, raidables[id][1], raidables[id][2], false, raidables[id][3])
            if raidables[id][4] then
                TriggerEvent(raidables[id][4], source)
            end
        end
    end
end)

RegisterNetEvent('Jail.Ping')
AddEventHandler('Jail.Ping', function()
    local source = source

    local found = SQL('SELECT * from jail WHERE cid = ? order by id desc limit 1', GetCharacter(source).id)[1]
    if found.time > 240 then
        local time = math.floor((os.time() - math.floor(found.start / 1000)) / 60 )
        found.time = found.time - time
    end

    SQL('UPDATE jail set time = ? WHERE time > 0 and cid = ?', found.time - 1, GetCharacter(source).id)
end)

RegisterNetEvent('Jail.Login')
AddEventHandler('Jail.Login', function()
    local source = source

    local found = SQL('SELECT * from jail WHERE cid = ? order by id desc limit 1', GetCharacter(source).id)[1]

    if found.time > 240 then
        local time = math.floor((os.time() - math.floor(found.start / 1000)) / 60 )
        found.time = found.time - time
    else
        local time = math.floor((os.time() - math.floor(found.start / 1000)) / 60 )
        time = math.floor(time / 10)
        found.time = found.time - time
    end

    TriggerClientEvent('Police.Arrest', source, found.time)
end)

RegisterNetEvent('Police.Runplate')
AddEventHandler('Police.Runplate', function(plate)
    local source = source
    plate = plate:upper()
    local char = GetCharacter(source)
    if char.Duty == 'Police' then
        local data = exports.ghmattimysql:executeSync('SELECT * from vehicles where plate = @Plate', {Plate = plate})[1]

        if data then
            exports.ghmattimysql:execute('SELECT first, last, id, phone_number from characters where id = @ID', {ID = data.owner}, function(res)
                local hasWarrant = SQL('SELECT report_id, title FROM mdt_reports WHERE report_id IN(SELECT parent_report FROM mdt_charges WHERE cid = ? AND warrant = 1)',  tonumber(res[1].id))[1]
                TriggerClientEvent('SendPlate', source, data, res[1], (vehList[plate] or {}).stolen == true, hasWarrant ~= nil)
            end)
        else
            if vehList[plate] == nil then
                vehList[plate] = {}
            end

            if vehList[plate].first == nil then
                vehList[plate].first = firstNames[math.random(#firstNames)]
                vehList[plate].last = lastNames[math.random(#lastNames)]
            end

            if vehList[plate].rented then
                TriggerClientEvent('Chat.Message', source, '[Police]', ('Vehicle with plate "%s" is rented by %s %s %s'):format(plate, vehList[plate].first, vehList[plate].last, vehList[plate].stolen == true and ' | Marked as ^1Stolen' or ''), 'job')
            else
                TriggerClientEvent('Chat.Message', source, '[Police]', ('Vehicle with plate "%s" is registered to %s %s %s'):format(plate, vehList[plate].first, vehList[plate].last, vehList[plate].stolen == true and ' | Marked as ^1Stolen' or ''), 'job')
            end
        end
    end
end)

RegisterNetEvent('SetRented')
AddEventHandler('SetRented', function(plate)
    local source = source
    local char = GetCharacter(source)
    RentVehicle(plate, char)
end)

function RentVehicle(plate, char)
    vehList[plate] = {}
    vehList[plate].first = char.first
    vehList[plate].last = char.last
    vehList[plate].id = char.id
    vehList[plate].rented = true
    vehList[plate].stolen = false
end

exports('SetRented', RentVehicle)
Task.Register('Jailbreak', function(source)
    local source = source
    local char = GetCharacter(source)
    local found = SQL('SELECT * from jail WHERE cid = ? order by id desc limit 1', char.id)[1]

    if found.time > 240 then
        local time = math.floor((os.time() - math.floor(found.start / 1000)) / 60 )
        found.time = found.time - time
    end

    if #Duty['Police'] >= 2 and found.time <= 1000 then
        PoliceEvent('Chat.Message', '[Jail]', GetName(char)..' ['..char.id..'] has escaped from prison with '..found.time.. ' remaining months in jail', 'job')
        SQL('DELETE FROM jail where cid = ?', char.id)
        return true
    end
end)

local impoundData = {}
Task.Register('GetImpound', function(source)
    local char = GetCharacter(source)
    local data = SQL('SELECT * from vehicles WHERE owner = ? and garage = "Impound"', char.id)
    impoundData[source] = data
    return data
end)

Task.Register('PullImpound', function(source, plate)
    local char = GetCharacter(source)

    for k,v in pairs(impoundData[source]) do
        if v.plate == plate and exports['geo-eco']:DebitDefault(char, 750, 'Impound Fees') then
            exports['geo-vehicle']:SpawnVehicle(source, plate, vector4(389.39, -1621.91, 28.9, 321.26))
            SQL('UPDATE vehicles set garage = "Legion" WHERE plate = ?', plate)
            break
        end
    end
end)

RegisterNetEvent('RunSerial', function(serial)
    local source = source
    local char = GetCharacter(source)
    if char.Duty == 'Police' then
        exports.ghmattimysql:execute('SELECT a.*, b.first, b.last, b.id FROM weapons a JOIN (SELECT `first`, `last`, id FROM characters) b ON a.cid = b.id WHERE serial_number = ?', {serial or ''}, function(res)
            if res[1] then
                local found = SQL('SELECT a.FIRST, a.LAST, b.name FROM characters a JOIN (SELECT name, cid FROM mdt_profiles) b ON a.id = b.cid WHERE a.id = ?', res[1].id)[1]
                if found then
                    TriggerClientEvent('Chat.Message', source, '[Serial]', 'This weapon is registered to: '..found.name, 'job')
                else
                    TriggerClientEvent('Shared.Notif', source, 'We have no record of this weapons owner', 5000)
                end
            else
                TriggerClientEvent('Shared.Notif', source, 'This weapon is not registered', 5000)
            end
        end)
    end
end)

RegisterCommand('bill', function(source, args, raw)
    local char = GetCharacter(source)
    if char.id == nil then
        return
    end

    if char.Duty == 'Police' or char.Duty == 'DOJ' then
        local target = tonumber(args[1])
        local targetChar = GetCharacterByID(target)

        if targetChar == nil then
            TriggerClientEvent('Chat.Message', source, '[Error]', 'Unable to find target', 'sys')
            return
        end

        local amount = tonumber(args[2])
        if amount == nil then
            TriggerClientEvent('Chat.Message', source, '[Error]', 'Invalid amount given', 'sys')
            return
        end

        amount = math.abs(math.floor(amount))
        local message = table.concat(args, " ", 3)
        Log('Bill', {cid = char.id, target = targetChar.id, amount = amount, reason = message:len() > 0 and message or nil})
        exports.ghmattimysql:execute('INSERT INTO police_actions (officer, subject, action, data, amount) VALUES (@Char, @Subject, "Bill", @Message, @Amount)', {
            Char = char.id,
            Subject = targetChar.id,
            Message = message,
            Amount = amount
        }, function(res)
            for k,v in pairs(dutyState) do
                if v == 'Police' then
                    TriggerClientEvent('Chat.Message', k, '[Bill]', ('%s gave %s a bill for the amount of $%s %s'):format(GetName(char), GetName(targetChar), comma_value(amount), message:len() > 0 and ('for '..message) or ''), 'job')
                end
            end
            TriggerClientEvent('Chat.Message', targetChar.serverid, '[Bill]', ('You have recieved a bill from %s for the amount of $%s %s'):format(GetName(char), comma_value(amount), message:len() > 0 and ('for '..message) or ''), 'job')
            if exports['geo-eco']:DebitDefault(targetChar, amount, 'Bill '..(message:len() > 0 and (': '..message) or ''), true) then
            end

            exports.ghmattimysql:execute('UPDATE characters SET debt = @Debt WHERE id = @ID', {
                Debt = targetChar.debt + amount,
                ID = targetChar.id
            })
        end)
    end
end)

RegisterCommand('arrest', function(source, args, raw)
    local char = GetCharacter(source)
    if char.id == nil then
        return
    end

    if char.Duty == 'Police' then
        local target = tonumber(args[1])
        local targetChar = GetCharacterByID(target)

        if targetChar == nil then
            TriggerClientEvent('Chat.Message', source, '[Error]', 'Unable to find target', 'sys')
            return
        end

        local amount = tonumber(args[2])
        if amount == nil then
            TriggerClientEvent('Chat.Message', source, '[Error]', 'Invalid time given', 'sys')
            return
        end

        amount = math.abs(math.floor(amount))
        local message = table.concat(args, " ", 3)

        exports.ghmattimysql:execute('INSERT INTO police_actions (officer, subject, action, data, amount) VALUES (@Char, @Subject, "Arrest", @Message, @Amount)', {
            Char = char.id,
            Subject = targetChar.id,
            Message = message,
            Amount = amount
        }, function(res)
            PoliceEvent('Chat.Message', '[Arrest]', ('%s Arrested %s for %s month(s) %s'):format(GetName(char), GetName(targetChar), comma_value(amount), message:len() > 0 and 'for '..message or ''), 'job')
            SQL('INSERT INTO jail (cid, time) VALUES (?, ?)', targetChar.id, amount)
            TriggerEvent('Inventory.Jail', targetChar)
            TriggerClientEvent('Police.Arrest', targetChar.serverid, amount)
            TriggerEvent('AddQuestTask', source, 'police_arrest_5', 1)
            Log('Arrest', {cid = char.id, target = targetChar.id, time = amount, reason = message:len() > 0 and message or nil})
        end)
    end
end)

AddEventHandler('Chat.Message.Police.Internal', function(m1, m2)
    for k,v in pairs(dutyState) do
        if v == 'Police' then
            TriggerClientEvent('Chat.Message', k, m1, m2, 'job')
        end
    end
end)

AddEventHandler('OnDuty', function(source, dType)
    if dType == 'Police' then
        TriggerClientEvent('Police.RaidList', source, raidables)
    end
end)

--[[ RegisterCommand('paystate', function(source, args)
    local char = GetCharacter(source)
    if char.id then

        local amount = tonumber(args[1])
        if amount == nil then
            TriggerClientEvent('Chat.Message', source, '[Debt]', ('You currently owe $%s to the state'):format(comma_value(char.debt)), 'job')
            return
        end

        amount = math.abs(math.floor(amount))
        local ped = GetPlayerPed(source)
        local pos = GetEntityCoords(ped)
        if Vdist4(pos, vector3(224.96, -441.16, 45.25)) <= 50.0 then
            if amount <= char.debt then
                if exports['geo-eco']:DebitDefault(char, amount, 'Debt Payment') then
                    TriggerClientEvent('Chat.Message', source, '[Debt]', ('$%s has been put towards your debt, $%s remains'):format(comma_value(amount), comma_value(char.debt - amount)), 'job')
                    UpdateChar(char.serverid, , char.debt - amount)

                    exports.ghmattimysql:execute('UPDATE characters SET debt = @Debt WHERE id = @ID', {
                        Debt = char.debt - amount,
                        ID = char.id
                    })
                end
            end
        else
            TriggerClientEvent('Chat.Message', source, '[Error]', 'Not close enough to the courthouse', 'sys')
        end
    end
end) ]]

RegisterCommand('breach', function(source)
    local char = GetCharacter(source)
    if char.Duty == 'Police' then
        TriggerEvent('Breach', source)
    end
end)

function PoliceEvent(eventName, ...)
    for k,v in pairs(dutyState) do
        if v == 'Police' then
            TriggerClientEvent(eventName, k, ...)
        end
    end
end

function AddRaid(property, interior, location)
    if raidables[property] then
        return
    end

    raidables[property] = {property, interior, location}
    PoliceEvent('Police.AddRaid', property, raidables[property])
end

function RemoveRaid(property)
    if raidables[property] then
        raidables[property] = nil
        PoliceEvent('Police.AddRaid', property, nil)
    end
end

exports('PoliceEvent', PoliceEvent)
exports('AddRaid', AddRaid)
exports('RemoveRaid', RemoveRaid)

local ped
local obj
local scold = 0
local tomb

AddEventHandler('WorldReady', function() 
    Wait(100)
    ped = CreatePed(4, 'u_m_y_party_01', vector3(441.24, -978.52, 30.69), 184.49, true, true)
    Wait(1000)

    while true do
        Wait(1000)
        if DoesEntityExist(ped) then
            if GetEntityHealth(ped) == 0 then
                DeleteEntity(ped)
                ped = CreatePed(4, 'u_m_y_party_01', vector3(441.24, -978.52, 30.69), 184.49, true, true)
                Wait(1500)
            else
                break
            end
        end
    end

    Wait(500)
    while true do
        Wait(1000)
        if DoesEntityExist(ped) then
            if GetEntityHealth(ped) <= 0 then
                --TriggerEvent('Chat.Message.Police.Internal', '[MAJOR CRIME]', 'Receptionist Larry has been murdered', 'job')
                TriggerEvent('Dispatch', {
                    code = '!!!!!!',
                    title = 'Larry Has Been Murdered',
                    time =  os.date('%H:%M EST'),
                    info = {
                    }
                })
                Wait(5000)
                if DoesEntityExist(ped) then
                    DeleteEntity(ped)
                end
                break
            end
        end
    end

    local tomb = CreateObjectNoOffset(1397319391, vector3(444.79, -976.16, 30.69 - 1.0), true, true, false)
    while not DoesEntityExist(tomb) do
        Wait(0)
    end
    SetEntityHeading(tomb, 90.0)
    print('Larry has died')
end)

RegisterCommand('whereslarry', function(source)
    local char = GetCharacter(source)
    if DoesEntityExist(ped) then
        TriggerClientEvent('Larry', source, GetEntityCoords(ped))
    end
end)

RegisterCommand('scoldlarry', function(source)
    if DoesEntityExist(ped) then
        local posToLarry = Vdist3(GetEntityCoords(GetPlayerPed(source)), GetEntityCoords(ped))
        if posToLarry <= 5.0 then
            if Vdist3(vector3(441.24, -978.52, 30.69), GetEntityCoords(ped)) >= 50.0 then
                SetEntityCoords(ped, vector3(441.24, -978.52, 30.69))
                SetEntityHeading(ped, 184.9)
                TriggerClientEvent('Shared.Notif', source, 'Larry has been scoled '..(scold + 1)..' times today')
                scold = scold + 1
            else
                TriggerClientEvent('Shared.Notif', source, 'Larry does not deserve a scolding right now')
            end
        end
    end
end)

AddEventHandler('onResourceStop', function()
    if DoesEntityExist(ped) then
        DeleteEntity(ped)
    end

    if DoesEntityExist(obj) then
        DeleteEntity(obj)
    end
end)

RegisterCommand('announce', function(source, args)
    local char = GetCharacter(source)
    if char.Duty == 'DOJ' then
        TriggerClientEvent('Chat.Message', -1, '[State Announcement]', table.concat(args, ' '))
    end
end)

local dispatch = {}
AddEventHandler('Dispatch', function(data)
    local call = #dispatch + 1
    dispatch[call] = data
    dispatch[call].id = call
    dispatch[call].people = {}
    PoliceEvent('Dispatch', dispatch[call])
    if data.EMS then
        EMSEvent('Dispatch', dispatch[call])
    end
end)

Task.Register('MarkGPS', function(source, id)
    return dispatch[id].location
end)

Task.Register('ToggleCall', function(source, call)
    local char = GetCharacter(source)
    if char.Duty == 'Police' or char.Duty == 'EMS' then
        local found = false
        for k,v in pairs(dispatch[call].people) do
            if v == char.callsign then
                found = true
                table.remove(dispatch[call].people, k)
                break
            end
        end

        if not found then
            table.insert(dispatch[call].people, char.callsign)
        end

        ESEvent('UpdateCall', call, dispatch[call].people)
    end
end)

Task.Register('DispatchLatestCall', function(source, call)
    local char = GetCharacter(source)
    call = #dispatch
    if char.Duty == 'Police' then
        local found = false
        for k,v in pairs(dispatch[call].people) do
            if v == char.callsign then
                found = true
                table.remove(dispatch[call].people, k)
                break
            end
        end

        if not found then
            table.insert(dispatch[call].people, char.callsign)
        end

        ESEvent('UpdateCall', call, dispatch[call].people)
    end
end)

Task.Register('Weapon.Register', function(source, serial, id)
    id = tonumber(id)
    if serial and id and GetCharacter(source).Duty == 'Police' then
        if SQL('SELECT * from weapons where serial_number = ?', serial)[1] ~= nil then
            TriggerClientEvent('Shared.Notif', source, 'This weapon is already registered')
            return
        end

        SQL('INSERT INTO weapons (cid, serial_number) VALUES (?, ?)', id, serial)
        TriggerClientEvent('Shared.Notif', source, 'Weapon Registered')
    end
end)