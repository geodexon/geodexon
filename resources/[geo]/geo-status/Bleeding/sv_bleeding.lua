RegisterNetEvent('Status.Bleeding.Bandage')
AddEventHandler('Status.Bleeding.Bandage', function()
    local source = source
    if not Status:Has(GetCharacter(source).id, 'hospital') then
        if exports['geo-inventory']:RemoveItem('Player', source, 'bandage', 1) then
            Status:Remove(source, 'bleeding', -1)
            Status:Add(source, 'hospital', 15)
        end
    end
end)

RegisterNetEvent('Status.Bleeding.ifak', function()
    local source = source
    if exports['geo-inventory']:RemoveItem('Player', source, 'ifak', 1) then
        Status:Remove(source, 'bleeding', -1)
        Status:Add(source, 'hospital', 30)
    end
end)

RegisterNetEvent('Status.Oxy')
AddEventHandler('Status.Oxy', function()
    local source = source
    if not Status:Has(GetCharacter(source).id, 'hospital') and exports['geo-inventory']:RemoveItem('Player', source, 'oxy', 1) then
        Status:Add(source, 'hospital', 90)
    end
end)