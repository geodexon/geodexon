AddCircleZone(vector3(-38.38, -1098.16, 26.42), 50.0, {
    name="PDM",
    useZ=false,
    --debugPoly=true
})

local inside = false
AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'PDM' then
        inside = inZone
        if inside then
            local ped = exports['geo-interface']:InterfacePed({
                model = 'a_m_y_business_01',
                position = vector4(-32.89, -1103.79, 26.42, 54.59),
                title = 'Car Directory',
                event = 'CarDirectory',
                scenario = 'WORLD_HUMAN_CLIPBOARD'
            })
            while inside do
                Wait(500)
            end
            exports['geo-interface']:RemovePed(ped)
        end
    end
end)

AddEventHandler('CarDirectory', function()
    local info = exports['geo-store']:GetCarInfo()
    UIFocus(true, true)
    SendNUIMessage({
        interface = 'cars',
        data = info
    })
end)

RegisterNUICallback('FindCar', function(data, cb)
    TriggerEvent('LocateCar', data.name)
    cb(true)
end)