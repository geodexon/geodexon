local jobloc = {}
AddCircleZone(vector3(238.04, -412.34, 48.11), 2.3, {
    name="RPG:Jobs",
    useZ=true,
})

--[[ CreateThread(function()
    local blip = AddBlipForCoord(238.04, -412.34, 48.11)
    SetBlipSprite(blip, 375)
    SetBlipColour(blip, 8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING");
    AddTextComponentString('Careers')
    EndTextCommandSetBlipName(blip)
end) ]]

--[[ AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'RPG:Jobs' then
        jobloc.inside = inZone
        if inZone then
            while jobloc.inside do
                Wait(0)
                Shared.WorldText('[E] Jobs', vector3(238.15, -412.34, 48.11))
                if IsControlJustPressed(0, 38) then
                    Task.Run('RPG.JobLocation')
                    Wait(1000)
                end
            end
        end
    end
end) ]]

Menu.CreateMenu('Jobs', 'Jobs')
RegisterNetEvent('EnterProperty')
AddEventHandler('EnterProperty', function(property)
    if property == 'RPG Jobs' then
        while MyCharacter.interior == 'RPG Jobs' do
            Wait(0)
            if Vdist3(GetEntityCoords(Shared.Ped), vector3(-1572.01, -573.56, 108.52)) <= 3.0 then
                Shared.WorldText('E', vector3(-1572.01, -573.56, 108.52), 'Get Job')
                if IsControlJustPressed(0, 38) then
                    Menu.OpenMenu('Jobs')
                    Menu.Menus['Jobs'].SubTitle = 'Current Job: '..(MyCharacter.job or 'Unemployed')
                    while Menu.CurrentMenu == 'Jobs' do
                        Wait(0)
                        if Vdist3(GetEntityCoords(Shared.Ped), vector3(-1572.01, -573.56, 108.52)) > 3.0 then
                            break
                        end

                        for k,v in pairs(RPG.Jobs) do
                            if Menu.Button(v) then
                                if Shared.Confirm('Would you like to become a '..v..'? You can only switch jobs once per week') then
                                    TriggerServerEvent('RPG.Job', k)
                                end
                            end
                        end

                        Menu.Display()
                    end
                end
            else
                Wait(250)
            end
        end
    end
end)