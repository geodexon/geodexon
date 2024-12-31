local pos = {}
local mySeat = {}

Task.Register('Sit', function(source, coord, model) 
    if booths[model] then
        if pos[coord] == nil then 
            pos[coord] = {} 
            for k,v in pairs(booths[model][5]) do
                pos[coord][k] = true
            end
        end
        

        return pos[coord]
    end
end)

RegisterNetEvent('Seat.Sit', function(coord, seat, ent)
    local source = source
    if pos[coord] then
        if pos[coord][seat] == true then
            pos[coord][seat] = source
            if mySeat[source] then
                pos[mySeat[source][1]][mySeat[source][2]] = true
            end
            mySeat[source] = {coord, seat}
            TriggerClientEvent('Seat.Sit', source, seat, ent)
        end
    end
end)

RegisterNetEvent('Seat.Leave', function()
    local source = source
    if mySeat[source] then
        pos[mySeat[source][1]][mySeat[source][2]] = true
        mySeat[source] = nil
    end
end)

AddEventHandler('playerDropped', function()
    local source = source
    if mySeat[source] then
        pos[mySeat[source][1]][mySeat[source][2]] = true
        mySeat[source] = nil
    end
end)