local jobState = 'none'
local jobBlip

AddBoxZone(vector3(-1406.37, -641.69, 28.67), 62.2, 41.8, {
    name="BurnerPhone",
    heading=130,
    minZ=27.67,
    maxZ=31.67
})

local _inZone = false
local _ped

AddEventHandler('Poly.Zone', function(zone, inZone, data)
    if zone == 'BurnerPhone' then
        _inZone = inZone
        if inZone and exports['geo-inventory']:HasItem('burner_phone') then
            local ped = exports['geo-interface']:InterfacePed({
                model = 1224306523,
                position = vec(-1413.57, -635.39, 28.67, 214.46),
                title = 'Burner',
                event = BurnerMenu
            })
            
            while _inZone do
                Wait(500)
            end

            exports['geo-interface']:RemovePed(ped)
        end
    end
end)

function BurnerMenu()
    local menu = {
        {title = 'Start Job', event = 'Burner.Start', hidden = jobState ~= 'none'},
        {title = 'Get Paid', event = 'Burner.Pay', hidden = jobState ~= 'done'},
        {title = 'Quit Job', event = 'Burner.Quit', hidden = jobState ~= 'phase_1'},
    }

    RunMenu(menu)
end

AddEventHandler('Burner.Start', function()
    jobState = Task.Run('Burner.StartJob')
end)

AddEventHandler('Burner.Pay', function()
    jobState = Task.Run('Burner.Pay')
end)

AddEventHandler('Burner.Quit', function()
    jobState = Task.Run('Burner.QuitJob')
end)

RegisterNetEvent('Burner.StartJob')
AddEventHandler('Burner.StartJob', function(loc)
    jobBlip = AddBlipForCoord(loc)
    SetBlipRoute(jobBlip, true)

    Wait(500)
    local _int
    while jobState == 'phase_1' do
        Wait(0)

        if Vdist3(GetEntityCoords(Shared.Ped), loc) <= 10.0 then
            _int = Shared.Interact('[E] Call It In') or _int
            if IsControlJustPressed(0, 38) then
                jobState = Task.Run('Burner.Call', Shared.GetLocation())
                Wait(100)
            end
        else
            Wait(500)
        end
    end
    if _int then _int.stop() end


    local _time = 300

    CreateThread(function()
        while jobState == 'phase_2' do
            Wait(1000)
            _time = _time - 1

            if _time <= 0 then
                jobState = Task.Run('Burner.Finish')
            end
        end
    end)

    CreateThread(function()
        local _int
        _int = Shared.Interact(_time.. ' seconds remain') or _int
        while jobState == 'phase_2' do
            Wait(500)
            _int.update(_time.. ' seconds remain')
        end
        if _int then _int.stop() end
    end)

    while jobState == 'phase_2' do
        if Vdist3(GetEntityCoords(Shared.Ped), loc) > 100.0 then
           jobState = Task.Run('Burner.Fail')
        end

        Wait(100)
    end

    RemoveBlip(jobBlip)
end)