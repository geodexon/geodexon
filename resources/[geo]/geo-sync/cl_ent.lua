RegisterNetEvent('Vehicle.PopTires')
AddEventHandler('Vehicle.PopTires', function(veh)
    if NetworkDoesNetworkIdExist(veh) then
        veh = NetToVeh(veh)
        for i=0,7 do
            SetVehicleTyreBurst(veh, i, true, 1000.0)
        end
    end
end)