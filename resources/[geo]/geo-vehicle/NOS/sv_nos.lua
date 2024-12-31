Task.Register('NOS', function(source, veh, bool, nos)
    TriggerClientEvent('NOS', -1, veh, bool)
    if nos then
        local veh = NetworkGetEntityFromNetworkId(veh)
        Entity(veh).state.nos = nos < 0 and 0 or nos
        if Entity(veh).state.vin then
            if nos < 0 then nos = 0 end
            if nos > 100 then nos = 100 end
            SQL('UPDATE vehicles set flags = JSON_SET(flags, "$.NOS", ?) where id = ?', nos, Entity(veh).state.vin)
        end
    end
end)