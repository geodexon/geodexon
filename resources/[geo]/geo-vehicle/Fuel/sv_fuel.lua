RegisterNetEvent('SetFuel')
AddEventHandler('SetFuel', function(veh, fuel)
    veh = NetworkGetEntityFromNetworkId(veh)
    Entity(veh).state.fuel = fuel

    if Entity(veh).state.plate then
        SQL('UPDATE vehicles set flags = JSON_SET(flags, "$.Fuel", ?) where plate = ?', fuel, GetVehicleNumberPlateText(veh))
    end
end)