
local currentNcic = 0
local pid

RegisterCommand('mdt', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    if (MyCharacter.Duty == 'Police' or MyCharacter.Duty == 'DOJ' or MyCharacter.Duty == 'EMS') and not IsPauseMenuActive() then
        ExecuteCommand('e tablet2')
        SendNUIMessage({
            type = 'mdt.open',
            duty = MyCharacter.Duty
        })
        UIFocus(true, true)
        local chargeList = Task.Run('GetChargeList', pid)
        if chargeList then
            pid = chargeList.id
            SendNUIMessage({
                type = 'mdt.gotcharges',
                data = chargeList.data,
                EMS = chargeList.EMS
            })
        end
    end
end)

RegisterNUICallback('MDTImage', function(data, cb)
    Task.Run('MDTImage', data.department, data.image)
    cb(false)
end)

RegisterNUICallback('close', function(data)
    ExecuteCommand('ec tablet2')
    UIFocus(false, false)
end)

AddEventHandler('Login', function()
    Wait(500)
    if MyCharacter and IsPolice(MyCharacter.id) then
        CreateThread(function()
            SendNUIMessage({
                type = 'mdt.register'
            })
            SendNUIMessage({
                type = 'mdt.image',
                data = State.Get("MDT", 'Header', IsPolice(MyCharacter.id)),
                department = IsPolice(MyCharacter.id)
            })
        end)
    end
end)

CreateThread(function()
    if MyCharacter and IsPolice(MyCharacter.id) then
        CreateThread(function()
            SendNUIMessage({
                type = 'mdt.image',
                data = State.Get("MDT", 'Header', IsPolice(MyCharacter.id)),
                department = IsPolice(MyCharacter.id)
            })
        end)
    end
end)

RegisterNetEvent('MDTImageUpdate')
AddEventHandler('MDTImageUpdate', function()
    if MyCharacter.id and IsPolice(MyCharacter.id) then
        CreateThread(function()
            SendNUIMessage({
                type = 'mdt.image',
                data = State.Get("MDT", 'Header', IsPolice(MyCharacter.id)),
                department = IsPolice(MyCharacter.id)
            })
        end)
    end
end)

RegisterKeyMapping('mdt', '[Police] MDT', 'keyboard', 'NULL')

RegisterNUICallback('OpenProfile', function(data, cb)
    if not MyCharacter then cb() return end
    local profiles = Task.Run('MDT.Profiles')
    cb(profiles)
end)

RegisterNUICallback('Profiles.Search', function(data, cb)
    local profiles = Task.Run('MDT.SearchProfile', data.name)
    cb(profiles)
end)

RegisterNUICallback('SaveProfile', function(data, cb)
    local completed = Task.Run('SaveProfile', data)
    cb(completed)
end)

RegisterNUICallback('LoadProfile', function(data, cb)
    local profile = Task.Run('LoadProfile', data.cid)
    cb(profile)
end)

RegisterNUICallback('NewReport', function(data, cb)
    local data = Task.Run('NewReport', data.title, data.body)
    cb(data)
end)

RegisterNUICallback('SaveReport', function(data, cb)
    local data = Task.Run('SaveReport', data.title, data.body, data.id, data.people, data.person, data.officers, data.evidence)
    cb(data)
end)

RegisterNUICallback('LoadReports', function(data, cb)
    local reports = Task.Run('LoadReports')
    cb(reports)
end)

RegisterNUICallback('OpenReport', function(data, cb)
    local reports = Task.Run('OpenReport', data.id)
    cb(reports)
end)

RegisterNUICallback('Reports.Search', function(data, cb)
    local reports = Task.Run('Reports.Search', data.name)
    cb(reports)
end)

RegisterNUICallback('Person.Search', function(data, cb)
    local profiles = Task.Run('Person.Search', data.name)
    cb(profiles)
end)

RegisterNUICallback('AddCharge', function(data, cb)
    local ret = Task.Run('AddCharge', data)
    cb(ret)
end)

RegisterNUICallback('RemoveCharge', function(data, cb)
    local ret = Task.Run('RemoveCharge', data)
    cb(ret)
end)

RegisterNUICallback('GetCharges', function(data, cb)
    local ret = Task.Run('GetCharges', data.cid, data.charge)
    cb(ret)
end)

RegisterNUICallback('SaveCharge', function(data, cb)
    local ret = Task.Run('SaveCharge', data.data)
    cb(ret)
end)

RegisterNUICallback('SaveChargeActive', function(data, cb)
    local ret = Task.Run('SaveChargeActive', data.data)
    cb(ret)
end)

RegisterNUICallback('NewCharge', function(data, cb)
    local ret = Task.Run('NewCharge', data.data)
    cb(ret)
end)

RegisterNUICallback('SetWarrant', function(data, cb)
    local ret = Task.Run('SetWarrant', data)
    cb(ret)
end)

RegisterNUICallback('OpenEvidence', function(data, cb)
    ExecuteCommand('evidence '..data.evidence)
    cb(true)
end)

RegisterNUICallback('LockReport', function(data, cb)
    local ret = Task.Run('LockReport', data.report)
    cb(ret)
end)

RegisterNUICallback('SearchDNA', function(data, cb)
    local found = Task.Run('SearchDNA', data.DNA)
    cb(found)
end)

RegisterNUICallback('FindReportsFprCasing', function(data, cb)
    local found = Task.Run('FindReportsFprCasing', data.casing)
    cb(found)
end)

RegisterNUICallback('Evidence.Search', function(data, cb)
    local found = Task.Run('Evidence.Search', data.name)
    cb(found)
end)

AddBoxZone(vector3(229.1, -429.41, 48.08), 3.6, 0.6, {
    name="MDTCharges",
    heading=248,
    --debugPoly=true,
    minZ=47.13,
    maxZ=49.63
}, true)

AddEventHandler('MDT.Charges', function()
    ExecuteCommand('e tablet2')
    SendNUIMessage({
        type = 'mdt.open',
        pd = false
    })
    UIFocus(true, true, '', true)
end)