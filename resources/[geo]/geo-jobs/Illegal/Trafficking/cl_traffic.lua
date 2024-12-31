local jobState = 'none'
local waypoint
local jobPed

local blip = AddBlipForCoord(vector3(-315.41, -3.39, 48.18))
SetBlipSprite(blip, 525)
SetBlipColour(blip, 3)
SetBlipAsShortRange(blip, true)
SetBlipScale(blip, 0.8)
BeginTextCommandSetBlipName("STRING");
AddTextComponentString("Ronald's Delivery Service")
EndTextCommandSetBlipName(blip)

AddCircleZone(vector3(-315.41, -3.39, 48.18), 50.0, {
    name="Trafficking",
    useZ=false,
    --debugPoly=true
})

local inside = false
AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'Trafficking' then
        inside = inZone
        if inside then
            local ped = exports['geo-interface']:InterfacePed({
                model = 'cs_fbisuit_01',
                position = vector4(-315.41, -3.39, 48.18, 161.1),
                title = "Ronald's Delivery Service",
                event = 'Trafficking.Menu',
                scenario = 'WORLD_HUMAN_COP_IDLES'
            })

            while inside do
                Wait(500)
            end

            exports['geo-interface']:RemovePed(ped)
        end
    end
end)

AddEventHandler('Trafficking.Menu', function()
    local menu = {
        {title = 'Start: Legal', serverevent = 'Trafficking.Start', params = {'Legal'}, hidden = jobState ~= 'none'},
        {title = 'Start: Illegal', serverevent = 'Trafficking.Start',  params = {'Illegal'}, hidden = jobState ~= 'none'},
        {title = 'Quit Job', serverevent = 'Trafficking.Quit', hidden = jobState == 'none'},
        {title = 'Get Paid', serverevent = 'Trafficking.Pay', hidden = jobState ~= 'phase_2'},
    }

    RunMenu(menu)
end)

RegisterNetEvent('Trafficking.Start', function()
    if jobState == 'phase_1' then jobState = 'none'; Wait(1000); end
    jobState = 'phase_1'

    local loc = Trafficking.Locations[Random(#Trafficking.Locations)]
    if waypoint then waypoint = RemoveBlip(waypoint) end
    waypoint = AddBlipForCoord(loc[1].xyz)
    SetBlipSprite(waypoint, 162)
    SetBlipColour(waypoint, 3)
    SetBlipAsShortRange(waypoint, true)
    SetBlipScale(waypoint, 0.8)
    BeginTextCommandSetBlipName("STRING");
    AddTextComponentString('Delivery Point')
    EndTextCommandSetBlipName(waypoint)
    SetBlipRoute(waypoint, true)

    while jobState == 'phase_1' do
        Wait(500)

        if Vdist3(GetEntityCoords(Shared.Ped), loc[1].xyz) <= 100.0 then
            if not jobPed then
                jobPed = exports['geo-interface']:InterfacePed({
                    model = loc[2] or exports['geo']:GetRandomModel(),
                    position = loc[1],
                    title = "Deliver Package",
                    event = 'Trafficking.Deliver',
                    scenario = 'WORLD_HUMAN_STAND_IMPATIENT',
                    network = true
                })
            end
        else
            if jobPed then
                exports['geo-interface']:RemovePed(jobPed, true)
                jobPed = nil
            end
        end
    end

    if jobPed then
        exports['geo-interface']:RemovePed(jobPed, true)
    end
end)

AddEventHandler('Trafficking.Deliver', function()
    local options = Task.Run('Trafficking.GetOptions')
    local menu = {}
    for k,v in pairs(options) do
        table.insert(menu, {
            title = Trafficking.Options[v].name, serverevent = 'Trafficking.Interaction', params = {v, Shared.GetLocation()}, description = 'Chance: '..Trafficking.Options[v].chance..'%',
        })
    end

    table.insert(menu, {
        title = 'Leave', serverevent = 'Trafficking.Interaction'
    })

    RunMenu(menu)
end)

RegisterNetEvent('Trafficking.SetStage', function(data)
    jobState = data
    if waypoint then waypoint = RemoveBlip(waypoint) end
end)

RegisterNetEvent('Trafficking.Holdup', function()
    if jobPed then
        local ped = exports['geo-interface']:GetPed(jobPed)
        ClearPedTasksImmediately(ped)
        FreezeEntityPosition(ped, false)
        GiveWeaponToPed(ped, 'WEAPON_PISTOL', 999, false, true)
        TaskAimGunAtEntity(ped, Shared.Ped, -1, true)
        SetEntityInvincible(ped, false)

        if exports['geo-shared']:Confirmation('Would you like to submit?') then
            ClearPedTasks(ped)
            exports['geo-interface']:RemovePed(jobPed, true)
            TriggerEvent('Cuff:Target', nil, true)
            TriggerServerEvent('Trafficking.Quit')
            Wait(1000)
            Shared.GetEntityControl(ped)
            TaskStandStill(ped, 3600000)
            jobPed = nil
        else
            Wait(2000)
            Shared.GetEntityControl(ped)
            TaskCombatPed(ped, Shared.Ped)
        end

        Task.Run('Trafficking.PoliceNotif', NetworkGetNetworkIdFromEntity(ped))
    end
end)