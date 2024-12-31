local RegisteredEvents = {}
local idList = {}
local ids = 1
Task = {}

RegisterNetEvent(GetCurrentResourceName()..':Task.run')
AddEventHandler(GetCurrentResourceName()..':Task.run', function(ident, id, ...)
    local source = source
    local retVal = false
    if RegisteredEvents[ident] ~= nil then
        retVal = RegisteredEvents[ident](source, ...)
    end

    TriggerLatentClientEvent(GetCurrentResourceName()..':Task.return', source, 150000, retVal or false, id)
    --TriggerClientEvent(GetCurrentResourceName()..':Task.return', source, retVal or false, id)
end)

RegisterNetEvent(GetCurrentResourceName()..':Task.return')
AddEventHandler(GetCurrentResourceName()..':Task.return', function(value, id)
    idList[id]:resolve(value or false)
    idList[id] = nil
end)

RegisterNetEvent('Task.run', function(ident, id, res, ...)
    local source = source
    local retVal = false
    if RegisteredEvents[ident] ~= nil then
        retVal = RegisteredEvents[ident](source, ...)
        TriggerLatentClientEvent(res..':Task.return', source, 150000, retVal or false, id)
        --TriggerClientEvent(res..':Task.return', source, retVal or false, id)
    end
end)

function Task.Register(ident, func)
    RegisteredEvents[ident] = func
end

function Task.Run(ident, source, ...)

    if ids > 60000 then
        ids = 1
    end

    local id = ids + 1
    ids = ids + 1
    idList[id] = promise.new()
    TriggerClientEvent(GetCurrentResourceName()..':Task.run', source, ident, id, ...)
    return Citizen.Await(idList[id])
end