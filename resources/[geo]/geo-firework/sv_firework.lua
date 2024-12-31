local id = 0
CreateThread(function()
    Wait(1000)
    while true do
        id = id + 1
        if id > 4 then id = 1 end
        TriggerClientEvent('Firework', -1, id)
        Wait(10000)
    end
end)