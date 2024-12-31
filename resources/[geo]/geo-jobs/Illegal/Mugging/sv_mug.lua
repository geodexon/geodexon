local robbed = {}
local times = {}

RegisterNetEvent('Mugging.Mug')
AddEventHandler('Mugging.Mug', function(id)
    local source = source
    local ent = NetworkGetEntityFromNetworkId(id)
    local p = Entity(ent)

    if GetEntityType(ent) ~= 1 then
        return
    end

    if Vdist3(GetEntityCoords(ent), GetEntityCoords(GetPlayerPed(source))) <= 10.0 then
        if not p.state.robbed then
            p.state.robbed = true
            exports['geo-inventory']:AddItem('Player', source, 'dollar', Random(1, 10))
            TriggerEvent('Mugging.Mugged', source)
        end
    end
end)

RegisterNetEvent('NPC.Rob', function(loc)
    TriggerEvent('Dispatch', {
        code = '10-39',
        title = 'Mugging',
        location = loc.position,

        time =  os.date('%H:%M EST'),
        info = {
            {
                icon = 'location',
                text = loc.location,
                location = true
            },
        }
    })
end)