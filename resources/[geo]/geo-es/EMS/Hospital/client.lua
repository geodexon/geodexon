local hospitalBeds = {
    vector3(309.22, -578.1, 44.2),
    vector3(313.47, -579.47, 44.2),
    vector3(319.61, -581.02, 44.21),
    vector3(324.0, -582.71, 44.2),
    vector3(308.04, -581.67, 44.2),
    vector3(308.04, -581.67, 44.2),
    vector3(314.36, -583.96, 44.2),
    vector3(317.62, -585.0, 44.2),
    vector3(322.9, -587.05, 44.2),
    vector3(-257.73, 6321.82, 31.99),
    vector3(-260.11, 6324.2, 31.99),
    vector3(-262.46, 6326.5, 31.99),
    vector3(-258.73, 6330.06, 31.99),
    vector3(-256.42, 6327.83, 31.99),
}

local pboxcheckin = {}

AddZone({
    vector3(310.3, -591.52, 43.28),
    vector3(307.05, -590.05, 43.28),
    vector3(305.51, -595.11, 43.28),
    vector3(309.92, -594.71, 43.28)
}, {
    name="Pillbox-Checkin",
    minZ=42.0,
    maxZ=45.0,
    debugGrid=false,
    gridDivisions=12,
    entry = 'PboxCheckin',
    model = -1883980157,
    id = 1
})
AddCircleZone(vector3(-252.26, 6334.28, 32.43), 1.68, {
    name="Pillbox-Checkin",
    useZ=true,
    id = 2,
    entry = 'PboxCheckin',
    pos = vector3(-251.9, 6334.83, 32.8)
    --debugPoly=true
  })
--[[ 
AddEventHandler('Poly.EnterZone', function(zone)
    if zone == 'Pillbox-Checkin' then
        pboxcheckin.inside = true
        while pboxcheckin.inside do
            Wait(0)
            Shared.WorldText('[E] Check In', vector3(308.75, -592.54, 43.28))
            if IsControlJustPressed(0, 38) then
                TriggerServerEvent('Hospital.Checkin')
            end
        end
    end
end) ]]
AddTextEntry("PboxCheckin", "~INPUT_DETONATE~ Check In")
AddEventHandler('Poly.Zone', function(zone, inZone, data)
    if zone == 'Pillbox-Checkin' then
        pboxcheckin.inside = inZone
        local obj = GetClosestObjectOfType(GetEntityCoords(Shared.Ped), 10.0, data.model)
        while pboxcheckin.inside do
            Wait(0)

            local pos = obj ~= 0 and (GetEntityCoords(obj) + vec(0, 0, 0.5)) or data.pos
            ShowFloatingHelp(data.entry, pos, 6)
            if IsControlJustPressed(0, 47) then
                if MyCharacter.dragged then 
                    TriggerEvent('Shared.Notif', "You're being held") 
                    Wait(100)
                else
                    TriggerServerEvent('Hospital.Checkin', 'null', data.id)
                    Wait(100)
                end
            end
        end
    end
end)


local inBed = false
local myHospitalID
RegisterNetEvent('Hospital.Checkin')
AddEventHandler('Hospital.Checkin', function(bed, bool, hospitalID)
    local obj
    if bool then
        obj = GetClosestObjectOfType(bed, 2.0, 2117668672, false, false, false)
        SetEntityCoords(Shared.Ped, bed)
    else
        obj = GetClosestObjectOfType(hospitalBeds[bed], 2.0, 2117668672, false, false, false)
        SetEntityCoords(Shared.Ped, hospitalBeds[bed])
    end
    
    inBed = true
    AttachEntityToEntity(Shared.Ped, obj, 0, 0.0, 0.0, 1.4, 0.0, 0.0, GetEntityHeading(obj) - 180.0, 0, 0, 1, 1, 1, 0)
    LoadAnim('dead')
    TaskPlayAnim(Shared.Ped, 'dead', 'dead_a', 8.0, -8, -1, 1, 0, 0, 0, 0)

    CreateThread(function()
        while inBed do
            if not IsEntityPlayingAnim(Shared.Ped, 'dead', 'dead_a', 1) then
                TaskPlayAnim(Shared.Ped, 'dead', 'dead_a', 8.0, -8, -1, 1, 0, 0, 0, 0)
            end
            Wait(250)
        end
        DetachEntity(Shared.Ped)
        LoadAnim('mp_bedmid')
        TaskPlayAnimAdvanced(Shared.Ped, "mp_bedmid", 'f_getout_l_bighouse', GetEntityCoords(Shared.Ped), GetEntityRotation(Shared.Ped), 1.0, 1.0, 3500, 1, 1.0, 1, 1)
        TriggerServerEvent('Hospital.Checkout')
        ClearPedBloodDamage(Shared.Ped)
    end)
end)

local taken = {}
RegisterCommand('bed', function()
    if inBed then
        inBed = false
    else
        if MyCharacter.dragged then return end
        for k,v in pairs(hospitalBeds) do
            if Vdist3(GetEntityCoords(Shared.Ped), v) <= 2.5 then
                TriggerServerEvent('Hospital.Checkin', k)
                return
            end
        end

        local obj = GetClosestObjectOfType(GetEntityCoords(Shared.Ped), 1.0, 2117668672, 0, 0, 0)
        if obj ~= 0 then
            local pos = GetEntityCoords(obj)
            local mth = (math.floor(pos.x * pos.y) << 16)
            TriggerServerEvent('Hospital.CheckinOffset', GetEntityCoords(obj), mth)
        end
    end
end)