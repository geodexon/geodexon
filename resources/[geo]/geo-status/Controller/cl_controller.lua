function Status:Register(statusID, timeInc)
    SendNUIMessage({
        ui = 'status',
        job = 'Register',
        status = statusID,
        time = timeInc
    })
end


function Status:Add(statusID, time)
   SendNUIMessage({
       ui = 'status',
       job = 'AddStatus',
       status = statusID,
       time = time
   })
end

function Status:Set(statusID, time)
    SendNUIMessage({
        ui = 'status',
        job = 'SetStatus',
        status = statusID,
        time = time
    })
end

RegisterNetEvent('Status.Add')
AddEventHandler('Status.Add', function(statusID, time)
    Status:Add(statusID, time)
end)

RegisterNetEvent('Status.Set')
AddEventHandler('Status.Set', function(statusID, time)
    Status:Set(statusID, time)
end)

RegisterNetEvent('Status.Clear')
AddEventHandler('Status.Clear', function()
    SendNUIMessage({
        ui = 'status',
        job = 'Clear',
    })
end)

RegisterNUICallback('status', function(data, cb)
    if Status.Statuses[data.status] then
        Status.Statuses[data.status]()
    end
    cb()
end)

RegisterNUICallback('status.done', function(data, cb)

    cb()
end)