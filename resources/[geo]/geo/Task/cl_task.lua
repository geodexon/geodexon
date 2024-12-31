Task = {}
local idList = {}
local ids = 1
local RegisteredEvents = {}

function Task.Run(ident, ...)

    if ids > 60000 then
        ids = 1
    end

    local id = ids + 1
    ids = ids + 1
    idList[id] = promise.new()
    TriggerServerEvent(GetCurrentResourceName()..':Task.run', ident, id, ...)
    return Citizen.Await(idList[id])
end

function Task.RunRemote(ident, ...)

    if ids > 60000 then
        ids = 1
    end

    local id = ids + 1
    ids = ids + 1
    idList[id] = promise.new()
    TriggerServerEvent('Task.run', ident, id, GetCurrentResourceName(), ...)
    return Citizen.Await(idList[id])
end

RegisterNetEvent(GetCurrentResourceName()..':Task.return')
AddEventHandler(GetCurrentResourceName()..':Task.return', function(value, id)
    idList[id]:resolve(value or false)
    idList[id] = nil
end)

RegisterNetEvent(GetCurrentResourceName()..':Task.run')
AddEventHandler(GetCurrentResourceName()..':Task.run', function(ident, id, ...)
    local retVal = false
    if RegisteredEvents[ident] ~= nil then
        retVal = RegisteredEvents[ident](...)
    end

    TriggerLatentServerEvent(GetCurrentResourceName()..':Task.return', 150000, retVal or false, id)
end)

function Task.Register(ident, func)
    RegisteredEvents[ident] = func
end