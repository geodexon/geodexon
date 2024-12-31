local jobState = 'none'
local winery = {}

AddCircleZone(vector3(-1890.52, 2043.45, 140.86), 20.6, {
    name="Winery",
    useZ=false,
    --debugPoly=true
})

local atWinery = false
local inYard = false
local _int

CreateThread(function()
    local blip = AddBlipForCoord(vec(-1888.33, 2049.68, 140.98))
    SetBlipSprite(blip, 616)
    SetBlipColour(blip, 5)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, 0.8)
    BeginTextCommandSetBlipName("STRING");
    AddTextComponentString('Winery')
    EndTextCommandSetBlipName(blip)
end)

AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'Winery' then
        atWinery = inZone

        local ped = exports['geo-interface']:InterfacePed({
            model = 'a_m_y_clubcust_02',
            position = vector4(-1888.33, 2049.68, 140.98, 154.67),
            title = 'Winery',
            event = 'Winery.Menu'
        })

        while atWinery do
            Wait(500)
        end

        exports['geo-interface']:RemovePed(ped)
    elseif zone == 'WineryYard' then
        inYard = inZone

        _int = Shared.Interact('[E] Pick Grapes') or _int
        while inYard do
            Wait(500)
        end
        if _int then _int.stop() end
    end
end)

local picking = false
AddEventHandler('Interact', function()
    if inYard and not picking and MyCharacter.dead ~= 1 then
        picking = true
        LoadAnim('amb@world_human_gardener_plant@female@base')
        TaskPlayAnim(Shared.Ped, 'amb@world_human_gardener_plant@female@base', 'base_female', 1.0, 1.0, 10000, 1, 0, 0, 0, 0 )
        if exports['geo-shared']:ProgressSync('Picking Grapes', 10000) then
            Task.Run('Winery.CollectGrape')
        end

        LoadAnim('amb@world_human_gardener_plant@female@exit')
        TaskPlayAnim(Shared.Ped, 'amb@world_human_gardener_plant@female@exit', 'exit_female', 1.0, 1.0, 4000, 1, 0, 0, 0, 0 )

        picking = false
    end
end)

AddEventHandler('Winery.Menu', function()
    local menu = {
        {title = 'Clock In', hidden = jobState ~= 'none', serverevent = 'Winery.Job', params = {true}},
        {title = 'Clock Out', hidden = jobState == 'none', serverevent = 'Winery.Job', params = {false}},
        {title = 'Deliver Grapes', hidden = jobState ~= 'phase_2', serverevent = 'Winery.Deliver'}
    }

    RunMenu(menu)
end)

AddEventHandler('Winery.Vat', function()
    local menu = {
        {title = 'Deliver Grapes', hidden = jobState ~= 'phase_3', serverevent = 'Winery.Vat'}
    }

    RunMenu(menu)
end)

RegisterNetEvent('Winery.State')
AddEventHandler('Winery.State', function(state)
    jobState = state
    if state == 'phase_1' then
        AddZone({
            vector2(-1849.4860839844, 2059.5712890625),
            vector2(-1816.2122802734, 2057.4064941406),
            vector2(-1793.8763427734, 2064.7651367188),
            vector2(-1685.1674804688, 2154.87109375),
            vector2(-1663.7204589844, 2190.9868164062),
            vector2(-1742.4548339844, 2220.0024414062),
            vector2(-1737.9063720703, 2266.7553710938),
            vector2(-1775.8156738281, 2282.82421875),
            vector2(-1827.1455078125, 2269.5700683594),
            vector2(-1853.0830078125, 2286.2297363281),
            vector2(-1901.7152099609, 2280.5756835938),
            vector2(-1907.3999023438, 2171.7885742188),
            vector2(-1919.6986083984, 2096.1540527344),
            vector2(-1864.5048828125, 2088.2504882812),
            vector2(-1850.8854980469, 2069.5112304688)
          }, {
            name="WineryYard",
            --minZ = 65.218368530273,
            --maxZ = 140.81367492676
        })

        while jobState == 'phase_1' do
            Wait(500)
        end

        inYard = false
        TriggerEvent('RemoveZone', 'WineryYard')
    elseif state == 'phase_3' then
        local jobPed
        local pos = vector4(-1928.38, 1779.55, 173.09, 108.93)
        while jobState == 'phase_3' do
            Wait(500)

            if Vdist3(GetEntityCoords(Shared.Ped), vec(pos.x, pos.y, pos.z)) <= 50.0 then
                if not jobPed then
                    jobPed = exports['geo-interface']:InterfacePed({
                        model = 'a_m_y_clubcust_02',
                        position = pos,
                        title = 'Winery Vat',
                        event = 'Winery.Vat'
                    })
                end
            else
                if jobPed then
                    jobPed = exports['geo-interface']:RemovePed(jobPed)
                end
            end
        end

        exports['geo-interface']:RemovePed(jobPed)
    end
end)
