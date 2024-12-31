Task.Register('MDT.Profiles', function(source)
    local char = GetCharacter(source)
    if char.Duty ~= 'Police' and char.Duty ~= 'DOJ' and char.Duty ~= 'EMS' then return end
    local str = 'mdt_profiles'
    if char.Duty == 'EMS' then
        str = str..'_ems'
    end
    
    local list = SQL('SELECT name, cid from '..str..' LIMIT ?', 12)
    return list
end)

Task.Register('MDT.SearchProfile', function(source, name)
    local char = GetCharacter(source)
    if char.Duty ~= 'Police' and char.Duty ~= 'DOJ' and char.Duty ~= 'EMS' then return end
    local str = 'mdt_profiles'
    if char.Duty == 'EMS' then
        str = str..'_ems'
    end
    list = SQL('SELECT name, cid from '..str..' WHERE name LIKE ? or cid = ? LIMIT 50', 
    '%'..name..'%', tonumber(name) or 0)
   
    return list
end)

Task.Register('SaveProfile', function(source, data)
    local char = GetCharacter(source)
    if char.Duty ~= 'Police' and char.Duty ~= 'EMS' then return end
    local str = 'mdt_profiles'
    if char.Duty == 'EMS' then
        str = str..'_ems'
    end

    if data.name and tonumber(data.cid) then
        local found = SQL('SELECT name from '..str..' WHERE cid = ?', tonumber(data.cid))
        if not found[1] then
            SQL('INSERT INTO '..str..' (name, cid, image, notes, dob) VALUES(?, ?, ?, ?, ?)', data.name, tonumber(data.cid), data.image or '', data.notes or '', data.dob or '')
        else
            SQL('UPDATE '..str..' SET name = ?, image = ?, notes = ?, dob = ?, licenses = ? WHERE cid = ?', data.name, data.image or '', data.notes or '', data.dob or '', json.encode(data.licenses), tonumber(data.cid))
        end
    end
end)

Task.Register('LoadProfile', function(source, cid)
    local char = GetCharacter(source)
    if char.Duty ~= 'Police' and char.Duty ~= 'DOJ' and char.Duty ~= 'EMS' then return end
    local str = 'mdt_profiles'
    local str2 = 'mdt_charges'
    if char.Duty == 'EMS' then
        str = str..'_ems'
        str2 = str2..'_ems'
    end
    local profile = SQL('SELECT * FROM '..str..' WHERE cid = ?', tonumber(cid))

    profile[1].vehicles = SQL('SELECT model, plate, id from vehicles where owner = ?', tonumber(cid))
    profile[1].charges = SQL('SELECT charge FROM '..str2..' WHERE cid = ? and active = 1', tonumber(cid))
    profile[1].warrants = SQL('SELECT report_id, title FROM mdt_reports WHERE report_id IN(SELECT parent_report FROM mdt_charges WHERE cid = ? AND warrant = 1)',  tonumber(cid))
    profile[1].properties = SQL('SELECT title, doors FROM properties WHERE owner = ?',  tonumber(cid))
    return profile[1]
end)

Task.Register('NewReport', function(source, title, body)
    local char = GetCharacter(source)
    if char.Duty ~= 'Police' and char.Duty ~= 'EMS' then return end
    local str = 'mdt_reports'
    if char.Duty == 'EMS' then
        str = str..'_ems'
    end

    if title == '' or body == '' then
        return false
    end

    SQL('INSERT INTO '..str..' (author, title, body) VALUES (?, ?, ?)', char.id, title, body)
    local val = SQL('SELECT * FROM '..str..' WHERE author = ? ORDER by report_id DESC LIMIT 1', char.id)
    return val[1]
end)

Task.Register('SaveReport', function(source, title, body, id, people, person, officers, evidence)
    local char = GetCharacter(source)
    if char.Duty ~= 'Police' and char.Duty ~= 'EMS' then return end
    local str = 'mdt_reports'
    local str2 = 'mdt_profiles'
    local str3 = 'mdt_charges'
    if char.Duty == 'EMS' then
        str = str..'_ems'
        str2 = str2..'_ems'
        str3 = str3..'_ems'
    end
    SQL('UPDATE '..str..' SET title = ?, body = ?, people = ?, officers = ?, evidence = ? WHERE report_id = ? and locked = 0', title, body, json.encode(people), json.encode(officers), json.encode(evidence), id)
    local val = SQL('SELECT * FROM '..str..' WHERE report_id = ?', id)
    val[1].people = json.decode(val[1].people)
    for k,v in pairs(val[1].people) do
        val[1].people[k].name = SQL('SELECT name FROM '..str2..' WHERE cid = ?', v.cid)[1].name
    end
    val[1].people = json.encode(val[1].people)
    val[1].charges = SQL('SELECT * from '..str3..' WHERE parent_report = ?', val[1].report_id)

    if person then
        SQL('DELETE from  '..str3..' WHERE cid = ?', person)
    end

    return val[1]
end)

Task.Register('LoadReports', function(source)
    local char = GetCharacter(source)
    if char.Duty ~= 'Police' and char.Duty ~= 'EMS' and char.Duty ~= 'DOJ' then return end
    local str = 'mdt_reports'
    if char.Duty == 'EMS' then
        str = str..'_ems'
    end
    local val = SQL('SELECT title, report_id, locked from '..str..' ORDER BY report_id DESC LIMIT 12')
    return val
end)

Task.Register('OpenReport', function(source, id)
    local char = GetCharacter(source)
    if char.Duty ~= 'Police' and char.Duty ~= 'EMS' and char.Duty ~= 'DOJ' then return end
    local str = 'mdt_reports'
    local str2 = 'mdt_profiles'
    local str3 = 'mdt_charges'
    if char.Duty == 'EMS' then
        str = str..'_ems'
        str2 = str2..'_ems'
        str3 = str3..'_ems'
    end

    local val = SQL('SELECT * FROM '..str..' WHERE report_id = ?', tonumber(id))

    val[1].people = json.decode(val[1].people)
    for k,v in pairs(val[1].people) do
        val[1].people[k].name = SQL('SELECT name FROM '..str2..' WHERE cid = ?', v.cid)[1].name
    end
    val[1].people = json.encode(val[1].people)

    val[1].officers = json.decode(val[1].officers)
    for k,v in pairs(val[1].officers) do
        val[1].officers[k].name = SQL('SELECT name FROM '..str2..' WHERE cid = ?', v.cid)[1].name
    end
    val[1].officers = json.encode(val[1].officers)

    val[1].charges = SQL('SELECT * from '..str3..' WHERE parent_report = ?', val[1].report_id)

    return val[1]
end)

Task.Register('Reports.Search', function(source, name)
    local char = GetCharacter(source)
    if char.Duty ~= 'Police' and char.Duty ~= 'EMS' then return end
    local str = 'mdt_reports'
    if char.Duty == 'EMS' then
        str = str..'_ems'
    end
    local val
    if name:sub(0, 8) == 'content:' then
        val = SQL('SELECT title, report_id, locked FROM '..str..' WHERE body LIKE ? LIMIT 16', '%'..name:sub(9)..'%')
    elseif name:sub(0, 9) == 'unlocked:' then
        val = SQL('SELECT title, report_id, locked FROM '..str..' WHERE locked = 0 LIMIT 16')
    else
        val = SQL('SELECT title, report_id, locked FROM '..str..' WHERE title LIKE ? or report_id = ? or people like ? ORDER BY report_id DESC LIMIT 16', "%"..name..'%', tonumber(name) or -1, '%"cid":'..(tonumber(name) or 9999999)..'%')
    end
    return val
end)

Task.Register('Person.Search', function(source, name)
    local char = GetCharacter(source)
    if char.Duty ~= 'Police' and char.Duty ~= 'EMS' then return end
    local str = 'mdt_profiles'
    if char.Duty == 'EMS' then
        str = str..'_ems'
    end

    local val = SQL('SELECT name, image, cid from '..str..' WHERE name LIKE ? or cid = ? LIMIT 50', '%'..name..'%', tonumber(name) or '')
    return val
end)

Task.Register('AddCharge', function(source, data)
    local char = GetCharacter(source)
    if char.Duty ~= 'Police' and char.Duty ~= 'EMS' then return end
    local str = 'mdt_charges'
    if char.Duty == 'EMS' then
        str = str..'_ems'
    end

    SQL('INSERT INTO '..str..' (parent_report, cid, charge) VALUES (?, ?, ?)', data.report, data.cid, data.charge)
end)

Task.Register('RemoveCharge', function(source, data)
    local char = GetCharacter(source)
    if char.Duty ~= 'Police' and char.Duty ~= 'EMS' then return end
    local str = 'mdt_charges'
    if char.Duty == 'EMS' then
        str = str..'_ems'
    end

    SQL('DELETE FROM '..str..' WHERE parent_report = ? AND charge = ? AND cid = ? LIMIT 1', data.report, data.charge, data.cid)
end)

Task.Register('GetCharges', function(source, cid, report)
    local char = GetCharacter(source)
    if char.Duty ~= 'Police' and char.Duty ~= 'EMS' and char.Duty ~= 'DOJ' then return end
    local str = 'mdt_reports'
    local str2 = 'mdt_charges'
    if char.Duty == 'EMS' then
        str = str..'_ems'
        str2 = str2..'_ems'
    end

    return SQL('SELECT * FROM '..str..' WHERE report_id IN (SELECT parent_report FROM '..str2..' WHERE cid = ? AND charge = ?) ORDER BY report_id desc', cid, report)
end)

Task.Register('SetWarrant', function(source, data)
    if GetCharacter(source).Duty ~= 'Police' then return end
    SQL('UPDATE mdt_charges SET warrant = ?, active = ? WHERE parent_report = ? and cid = ?', data.warrant == true and 1 or 0, data.warrant == true and 0 or 1, data.report, data.cid)
end)

Task.Register('LockReport', function(source, report)
    local char = GetCharacter(source)
    if char.Duty ~= 'Police' and char.Duty ~= 'EMS' then return end
    local str = 'mdt_reports'
    local str2 = 'mdt_charges'
    if char.Duty == 'EMS' then
        str = str..'_ems'
        str2 = str2..'_ems'
    end

    if #SQL('SELECT * FROM '..str2..' WHERE parent_report = ? AND warrant = 1', report) == 0 then
        SQL('UPDATE '..str..' SET locked = 1 WHERE report_id = ? and author = ?', report, GetCharacter(source).id)
    end
end)

Task.Register('MDTImage', function(source, dep, image)
    if exports['geo-guilds']:GuildOwner(dep) == GetCharacter(source).id then
        State.Set('MDT', "Header", dep, image)
        TriggerClientEvent('MDTImageUpdate', -1, dep, image)
    end
end)

Task.Register('SearchDNA', function(source, dna)
    if GetCharacter(source).Duty ~= 'Police' then return end
    local val = SQL('SELECT cid from mdt_profiles WHERE notes like ?', '%'..dna..'%')
    return val[1]
end)

local cache = {}
Task.Register('GetWarrants', function(source)
    if RateLimit('GetWarrants', 5000) then
        local val = SQL('SELECT a.cid, a.parent_report, b.name, c.image FROM mdt_charges a JOIN mdt_profiles b ON a.cid = b.cid JOIN mdt_profiles c ON c.cid = a.cid  WHERE warrant = 1')
        local reports = {}
        local newVal = {}
        for k,v in pairs(val) do
            if reports[v.parent_report] == nil then reports[v.parent_report] = {} end
    
            if not reports[v.parent_report][v.name] then
                reports[v.parent_report][v.name] = true
                table.insert(newVal, v)
            end
        end
        
        cache = newVal
    end

    return cache
end)

Task.Register('FindReportsFprCasing', function(source, casing)
    if GetCharacter(source).Duty ~= 'Police' then return end
    local val = SQL('SELECT title, report_id, locked FROM mdt_reports WHERE evidence LIKE ?', '%'..casing..'%')
    return val
end)

Task.Register('Evidence.Search', function(source, name)
    if GetCharacter(source).Duty ~= 'Police' then return end
    local val = SQL('SELECT report_id, title from mdt_reports WHERE evidence LIKE ? ORDER BY report_id desc LIMIT 10', '%'..name..'%')
    return val
end)

local charges = {}
local injuries = {}

AddEventHandler('SendCharges', function(pCharge, pInj)
    for k,v in pairs(pCharge) do
        if k >= 10000 then
            pCharge[k] = nil
        end
    end

    if SQL('SELECT id from mdt_chargelist WHERE id = 1')[1] == nil then
        for k,v in pairs(pCharge) do
            SQL('INSERT INTO mdt_chargelist (id, data) VALUES (?, ?)', v.chargeID, json.encode(v))
        end
    end

    if SQL('SELECT id from mdt_chargelist_ems WHERE id = 1')[1] == nil then
        for k,v in pairs(pInj) do
            SQL('INSERT INTO mdt_chargelist_ems (id, data) VALUES (?, ?)', v.chargeID, json.encode(v))
        end
    end

    local list = SQL('SELECT * from mdt_chargelist')
    for k,v in pairs(list) do
        v.data = json.decode(v.data)
        charges[tonumber(v.data.chargeID)] = v.data
    end

    local list2 = SQL('SELECT * from mdt_chargelist_ems')
    for k,v in pairs(list2) do
        v.data = json.decode(v.data)
        injuries[tonumber(v.data.chargeID)] = v.data
    end

    --charges = json.encode(pCharge)
end)

local currentID = uuid()
local currentID2 = uuid()
Task.Register('GetChargeList', function(source, pid)
    local char = GetCharacter(source)
    if char.Duty == 'EMS' then
        if pid ~= currentID then return {data = injuries, id = currentID2, EMS = true} end
    else
        if pid ~= currentID then return {data = charges, id = currentID} end
    end
    return
end)

Task.Register('SaveCharge', function(source, data)
    local char = GetCharacter(source)
    if (char.Duty == 'DOJ' and exports['geo-guilds']:GuildOwner('DOJ') == char.id) or (char.Duty == 'EMS' and exports['geo-guilds']:GuildOwner('EMS') == char.id) then
        local list = charges
        if char.Duty == 'EMS' then
            list = injuries
        end

        if not tonumber(data.fine) then
            TriggerClientEvent('Shared.Notif', source, 'Invalid Fine Amount')
            return
        end

        if not tonumber(data.time) then
            TriggerClientEvent('Shared.Notif', source, 'Invalid Time Amount')
            return
        end

        if data.title == nil or data.title == '' then
            TriggerClientEvent('Shared.Notif', source, 'Invalid Title')
            return
        end

        if data.description == nil or data.description == '' then
            TriggerClientEvent('Shared.Notif', source, 'Invalid Description')
            return
        end

        list[data.chargeID].title = data.title
        list[data.chargeID].description = data.description
        list[data.chargeID].time = math.floor(math.abs(tonumber(data.time)))
        list[data.chargeID].fine = math.floor(math.abs(tonumber(data.fine)))

        local str = 'mdt_chargelist'
        if char.Duty == 'EMS' then
            str = str..'_ems'
            currentID2 = uuid()
        else
            currentID = uuid()
        end

        SQL('UPDATE '..str..' SET data = ? WHERE JSON_VALUE(`data`, "$.chargeID") = ?', json.encode(list[data.chargeID]), data.chargeID)
        return {data.chargeID, list[data.chargeID]}
    end
end)

Task.Register('NewCharge', function(source, data)
    local char = GetCharacter(source)
    if (char.Duty == 'DOJ' and exports['geo-guilds']:GuildOwner('DOJ') == char.id) or (char.Duty == 'EMS' and exports['geo-guilds']:GuildOwner('EMS') == char.id) then
        local list = charges
        if char.Duty == 'EMS' then
            list = injuries
        end

        if not tonumber(data.fine) then
            TriggerClientEvent('Shared.Notif', source, 'Invalid Fine Amount')
            return
        end

        if not tonumber(data.time) then
            TriggerClientEvent('Shared.Notif', source, 'Invalid Time Amount')
            return
        end

        if data.title == nil or data.title == '' then
            TriggerClientEvent('Shared.Notif', source, 'Invalid Title')
            return
        end

        if data.description == nil or data.description == '' then
            TriggerClientEvent('Shared.Notif', source, 'Invalid Description')
            return
        end

        local chargeID = list[#list].chargeID + 1

        list[chargeID] = {}
        list[chargeID].chargeID = chargeID
        list[chargeID].title = data.title
        list[chargeID].description = data.description
        list[chargeID].time = math.floor(math.abs(tonumber(data.time)))
        list[chargeID].fine = math.floor(math.abs(tonumber(data.fine)))
        list[chargeID].type = data.type

        local str = 'mdt_chargelist'
        if char.Duty == 'EMS' then
            str = str..'_ems'
            currentID2 = uuid()
        else
            currentID = uuid()
        end

        SQL('INSERT INTO '..str..' (data) VALUES (?)', json.encode(list[chargeID]))
        return {chargeID, list[chargeID]}
    end
end)

Task.Register('SaveChargeActive', function(source, data)
    local char = GetCharacter(source)
    if (char.Duty == 'DOJ' and exports['geo-guilds']:GuildOwner('DOJ') == char.id) or (char.Duty == 'EMS' and exports['geo-guilds']:GuildOwner('EMS') == char.id) then
        local list = charges
        if char.Duty == 'EMS' then
            list = injuries
        end
        list[data.chargeID].hidden = data.checked and true or false
        local str = 'mdt_chargelist'
        if char.Duty == 'EMS' then
            str = str..'_ems'
            currentID2 = uuid()
        else
            currentID = uuid()
        end

        SQL('UPDATE '..str..' SET data = ? WHERE JSON_VALUE(`data`, "$.chargeID") = ?', json.encode(list[data.chargeID]), data.chargeID)
        return {data.chargeID, list[data.chargeID]}
    end
end)

SetHttpHandler(function(request, response)
    if request.method == 'GET' and request.path == '/charges' then -- if a GET request was sent to the `/ping` path
        response.writeHead(200, { ['Content-Type'] = 'text/plain' }) -- set the response status code to `200 OK` and the body content type to plain text
        response.send(json.encode(charges)) -- respond to the request with `pong`
    else -- otherwise
        response.writeHead(404) -- set the response status code to `404 Not Found`
        response.send() -- respond to the request with no data
    end
end)
