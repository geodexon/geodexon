AddCircleZone(vector3(274.25, -2046.39, 18.8), 50.0, {
    name="fenciestfence",
    useZ=false,
    --debugPoly=true
})

local inside = false
AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'fenciestfence' then
        inside = inZone
        if inZone then
            local ped = exports['geo-interface']:InterfacePed({
                model = 'g_f_y_vagos_01',
                position = vector4(274.64, -2047.06, 18.89, 60.52),
                title = 'Fence',
                event = 'Fence.Menu',
                scenario = 'WORLD_HUMAN_SMOKING_POT'
            })

            while inside do
                Wait(500)
            end

            exports['geo-interface']:RemovePed(ped)
        end
    end
end)

AddEventHandler('Fence.Menu', function()
    local menu = {}

    for k,v in pairs(fenceOptions) do
        local _m = {title = v.name,  image = v.image, submenu = {}}

        for key,val in pairs(v.purchase) do
            table.insert(_m.submenu, 
                {title = val[1]..' x'..val[3], serverevent = 'Fence.Buy', params = {k, key}, disabled = not exports['geo-inventory']:HasItem(val[2], val[3])}
            )
        end

        table.insert(menu, _m)
    end

    Task.Run('FoundFence')
    RunMenu(menu)
end)