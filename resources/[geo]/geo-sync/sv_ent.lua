RegisterServerEvent('Vehicle.PopTires')
AddEventHandler('Vehicle.PopTires', function(veh)
    TriggerClientEvent('Vehicle.PopTires', -1, veh)
end)