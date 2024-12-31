propertyTypes = {'House', 'Apartment', 'Warehouse', 'Business'}

exports('GetProperty', function(id)
    return properties[id]
end)