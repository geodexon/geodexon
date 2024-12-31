RegisterNetEvent('SaveFood', function(food, drink)
    local source = source
    if food > 100 then food = 100 end
    if drink > 100 then drink = 100 end

    exports['geo']:SetData(source, 'hunger', food)
    exports['geo']:SetData(source, 'thirst', drink)
end)