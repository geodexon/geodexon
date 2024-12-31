RegisterNetEvent('Fence.Buy', function(item, key)
    local source = source
    if exports['geo-inventory']:CanFit('Player', source, fenceOptions[item].item, 1) then
        if exports['geo-inventory']:RemoveItem('Player', source, fenceOptions[item].purchase[key][2], fenceOptions[item].purchase[key][3]) then
            exports['geo-inventory']:AddItem('Player', source, fenceOptions[item].item, 1)
        end
    end
end)

Task.Register('FoundFence', function(source)
    if RateLimit('Fence.'..source, 43200) then
        Log('Fence', {cid = GetCharacter(source).id, info = 'Found Fence'})
    end
end)