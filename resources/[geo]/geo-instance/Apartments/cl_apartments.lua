local hasLuxury = false

local pinkcage = {}

AddZone({
    vector3(292.46, -229.32, 53.83),
    vector3(344.21, -244.95, 53.9),
    vector3(355.66, -198.78, 57.46),
    vector3(309.03, -180.56, 57.26)
}, {
    name="Pinkcage",
    minZ=53.0,
    maxZ=60.0,
    debugGrid=false,
    gridDivisions=20
})

local banner = {}

AddZone({
    vector3(-308.15, -1032.21, 30.38),
    vector3(-309.96, -1037.55, 30.53),
    vector3(-320.44, -1034.1, 30.53),
    vector3(-318.78, -1028.24, 30.53)
}, {
    name="BannerExtended",
    minZ=28.0,
    maxZ=35.0,
    debugGrid=false,
    gridDivisions=20
})

PDMotels = {}
CreateThread(function()
    local id = uuid()
    AddCircleZone(vector3(470.55, -984.93, 30.69), 3.0, {
        name="PDMotel",
        useZ=true,
        id = id,
        loc = vector4(470.55, -984.93, 30.69, 91.0)
    })

    table.insert(PDMotels, {
        name="PDMotel",
        useZ=true,
        id = id,
        loc = vector4(470.55, -984.93, 30.69, 91.0)
    })

    local id = uuid()
    AddCircleZone(vector3(332.7, -569.62, 43.28), 1.65, {
        name="PDMotel",
        useZ=true,
        id = id,
        loc = vector4(332.68, -569.67, 43.28, 158.8)
    })

    table.insert(PDMotels, {
        name="PDMotel",
        useZ=true,
        id = id,
        loc = vector4(332.68, -569.67, 43.28, 158.8)
    })
end)

AddEventHandler('Poly.Zone', function(zone, inZone, data)
    if zone == 'Pinkcage' then
        pinkcage.inside = inZone
        while pinkcage.inside do
            Wait(0)
            if MyCharacter then
                if MyCharacter.motel then
                    local pox = Apartments[MyCharacter.motel].Position
                    pox = vec(pox.x, pox.y, pox.z)
                    if Vdist3(GetEntityCoords(Shared.Ped), pox) <= 2.0 then
                        Shared.WorldText('E', pox, 'Enter')
                        if IsControlJustPressed(0, 38) then
                            TriggerServerEvent('Motel.Enter')
                            Wait(1000)
                        end
                    else
                        Wait(500)
                    end
                end
            end
        end
    elseif zone == 'BannerExtended' then
        banner.inside = inZone
        local _int
        while banner.inside do
            Wait(0)
            if hasLuxury then
                _int = Shared.Interact('[E] Enter - [G] Pay', vector3(-313.72, -1034.5, 31.03)) or _int
                if IsControlJustPressed(0, 38) then
                    TriggerServerEvent('Motel.Enter')
                    Wait(1000)
                end

                if IsControlJustPressed(0, 47) then
                    local val = Shared.TextInput('Amount', 5)
                    if tonumber(val) then
                        TriggerServerEvent('Apartment.Deposit', tonumber(val))
                    end
                end
            else 
                _int = Shared.Interact('[E] High Class Apartment $5,000', vector3(-313.72, -1034.5, 31.03)) or _int
                if IsControlJustPressed(0, 38) then
                    if Shared.Confirm('Would you like to rent a room for $5,000 per week?') then
                        TriggerServerEvent('Apartment.RentLuxury')
                        if _int then _int.stop() end
                        Wait(1000)
                    end
                end
            end
        end
        if _int then _int.stop() end
    elseif zone == 'PDMotel' then
        if exports['geo-es']:IsPolice(MyCharacter.id) or exports['geo-es']:IsEMS(MyCharacter.id) then
            for k,v in pairs(PDMotels) do
                if v.id == data.id then
                    v.inside = inZone
                    pdzone = k
                    while v.inside do
                        Wait(0)
                        Shared.WorldText('Enter', data.loc, 'Enter')
                        if IsControlJustPressed(0, 38) then
                            TriggerServerEvent('PDMotel.Enter', k)
                            Wait(1000)
                        end
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('Apartment.RentLuxury')
AddEventHandler('Apartment.RentLuxury', function()
    hasLuxury = true
end)

RegisterCommand('enterroom', function(source, args)
    if pdzone then
        TriggerServerEvent('Police.EnterRoom', args[1], pdzone)
    end
end)