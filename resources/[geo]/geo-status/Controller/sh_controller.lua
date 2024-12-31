Status = {
    Players = {},
    Statuses = {}
}

if IsDuplicityVersion() then
    function Status:Register(statusID, time, data)
        self.Statuses[statusID] = data
    end
else
    function Status:Register(statusID, timeInc)
        SendNUIMessage({
            ui = 'status',
            job = 'Register',
            status = statusID,
            time = timeInc
        })
    end
end

CreateThread(function()
    Wait(1000)
    for k,v in pairs(json.decode(LoadResourceFile(GetCurrentResourceName(), 'Controller/statuses.json'))) do
        Status:Register(v.statusName, v.timeInterval, v)
        if v.allowClient then
            if IsDuplicityVersion() then
                RegisterNetEvent(v.statusEvent)
                AddEventHandler(v.statusEvent, function()
                    local source = source
                    Status:Add(source, v.statusName, v.defaultTime, v.isTemp)
                end)
            else
                RegisterNetEvent(v.statusEvent)
                AddEventHandler(v.statusEvent, function()
                    Status:Add(v.statusName, v.defaultTime)
                end)
            end
        end
    end
end)
