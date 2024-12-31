AddCircleZone(vector3(-1170.94, -1571.1, 4.66), 20.0, {
    name="smokeonthewater",
    useZ=false,
    --debugPoly=true
})

local inside = false
AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'smokeonthewater' then
        inside = inZone
        if inside then
            local ped = exports['geo-interface']:InterfacePed({
                model = 'a_m_y_hippy_01',
                position = vector4(-1168.74, -1572.88, 4.66, 117.83),
                title = 'Buy Weed',
                event = 'Weed.Buy',
            })

            while inside do
                Wait(500)
            end

            exports['geo-interface']:RemovePed(ped)
        end
    end
end)

AddEventHandler('Weed.Buy', function()
    exports['geo-inventory']:InventoryMenu('StoreUI', 'Smoke On The Water')
end)

local blip = AddBlipForCoord(vector3(-1173.77, -1572.28, 4.53))
SetBlipSprite(blip, 140)
SetBlipColour(blip, 2)
SetBlipAsShortRange(blip, true)
SetBlipScale(blip, 0.8)
BeginTextCommandSetBlipName("STRING");
AddTextComponentString('Smoke On The Water')
EndTextCommandSetBlipName(blip)