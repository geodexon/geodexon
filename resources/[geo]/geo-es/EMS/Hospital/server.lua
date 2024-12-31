beds = {
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
}

local bedCount = {
    {1, 9},
    {10, 14}
}

local takenBy = {}
local times = {}
local bedOff = {}
local inBed = {}

RegisterNetEvent('Hospital.Checkin')
AddEventHandler('Hospital.Checkin', function(bed, hospitalID)
    local source = source
    local char = GetCharacter(source)
    if char.dead == 1 then
        UpdateChar(source, 'dead', 0)
    end

    if inBed[source] then
        return
    end

    exports['geo-status']:Remove(source, 'bleeding', -1)
    exports['geo-status']:Add(source, 'hospital', -1, true)

    if bed and bed ~= 'null' then
        if beds[bed] then
            beds[bed] = false
            takenBy[source] = bed
            TriggerClientEvent('Hospital.Checkin', source, bed)
            inBed[source] = true
            times[source] = os.time()
            return
        end
    end

    for k,v in pairs(beds) do
        if v and (k >= bedCount[hospitalID][1]) then
            beds[k] = false
            takenBy[source] = k
            TriggerClientEvent('Hospital.Checkin', source, k)
            inBed[source] = true
            times[source] = os.time()
            break
        end
    end
end)

RegisterNetEvent('Hospital.CheckinOffset')
AddEventHandler('Hospital.CheckinOffset', function(pos, id)
    local source = source
    local char = GetCharacter(source)
    if char.dead == 1 then
        UpdateChar(source, 'dead', 0)
    end

    if inBed[source] then
        return
    end

    if bedOff[id] then
        TriggerClientEvent('Shared.Notif', source, 'This bed is occupied')
        return
    end

    exports['geo-status']:Remove(source, 'bleeding', -1)
    exports['geo-status']:Add(source, 'hospital', -1, true)

    bedOff[id] = source
    inBed[source] = true
    times[source] = os.time()
    TriggerClientEvent('Hospital.Checkin', source, pos, true)
end)

RegisterNetEvent('Hospital.Checkout')
AddEventHandler('Hospital.Checkout', function()
    local source = source
    if takenBy[source] then
        beds[takenBy[source]] = true
        takenBy[source] = nil
        local calc = os.time() - times[source]
        times[source] = nil
    end

    for k,v in pairs(bedOff) do
        if v == source then
            bedOff[k] = nil
            local calc = os.time() - times[source]
            times[source] = nil
            break
        end
    end

    exports['geo-status']:Remove(source, 'hospital', -1, true)
    inBed[source] = nil
end)

AddEventHandler('playerDropped', function()
    local source = source
    if takenBy[source] then
        beds[takenBy[source]] = true
        takenBy[source] = nil
    end

    for k,v in pairs(bedOff) do
        if v == source then
            bedOff[k] = nil
            break
        end
    end
end)