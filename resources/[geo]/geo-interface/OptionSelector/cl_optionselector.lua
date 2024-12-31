RegisterNUICallback('OptionSelector.Trigger', function(data, cb)
    if data.event then TriggerEvent(data.event, table.unpack(data.params or {})) end
    if data.serverevent then TriggerServerEvent(data.serverevent, table.unpack(data.params or {})) end
    if data.func then 
        local func = json.encode(data.func)
        local val = FindRef(func, funcRefs)
        val(table.unpack(data.params or {}))
        if data.close then funcRefs = {} end
    end
    cb(true)
end)

RegisterNUICallback('OptionSelector.Hover', function(data, cb)
    if data.hover then TriggerEvent(data.hover, table.unpack(data.params or {})) end
    cb(true)
end)

function FindRef(data, pTable)
    for k,v in pairs(pTable) do
        if v.func then
            if json.encode(v.func) == data then
                return v.func
            end
        end

        if v.submenu then
            return FindRef(data, v.submenu)
        end
    end
end