local zones = {}
local targetZones = {}

function CreateZone(coords, data, ignore)
    local val = {}
    val.zone = PolyZone:Create(coords, data)
    val.inside = false
    val.data = data
    if ignore then
        table.insert(targetZones, val)
    else
        table.insert(zones, val)
    end
    return val
end

function CreateCircleZone(coords, h, data, ignore)
    local val = {}
    val.zone = CircleZone:Create(coords, h, data)
    val.inside = false
    val.data = data
    if ignore then
        table.insert(targetZones, val)
    else
        table.insert(zones, val)
    end
    return val
end

function CreateBoxZone(loc, x, y, data, ignore)
    local val = {}
    val.zone = BoxZone:Create(loc, x, y, data)
    val.inside = false
    val.data = data
    if ignore then
        table.insert(targetZones, val)
    else
        table.insert(zones, val)
    end
    return val
end


CreateThread(function()
    while true do
        Wait(500)
        local pos = GetEntityCoords(PlayerPedId())
        for k,v in pairs(zones) do
            if v.zone:isPointInside(pos) then
                if not v.inside then
                    v.inside = true
                    TriggerEvent('Poly.Zone', v.data.name, true, v.data)
                end
            else
                if v.inside then
                    v.inside = false
                    TriggerEvent('Poly.Zone', v.data.name, false, v.data)
                end
            end
        end
    end
end)

function IsInZone(pos)
    for k,v in pairs(targetZones) do
        if v.zone:isPointInside(pos) then
            return v.data
        end
    end
end

exports('CreateZone', CreateZone)
exports('CreateCircleZone', CreateCircleZone)
exports('CreateBoxZone', CreateBoxZone)
exports('IsInZone', IsInZone)

AddEventHandler('onResourceStop', function(res)
    for k,v in pairs(zones) do
        if v.data.res == res then
            print('removed zone '..v.data.name)
            zones[k] = nil
        end
    end

    for k,v in pairs(targetZones) do
        if v.data.res == res then
            print('removed zone '..v.data.name)
            targetZones[k] = nil
        end
    end
end)

AddEventHandler('RemoveZone', function(zone)
    for k,v in pairs(zones) do
        if v.data.name == zone then
            print('removed zone '..v.data.name)
            zones[k] = nil
            break
        end
    end

    for k,v in pairs(targetZones) do
        if v.data.name == zone then
            print('removed zone '..v.data.name)
            targetZones[k] = nil
            break
        end
    end
end)