AddCircleZone(vector3(-349.71, -1569.94, 25.22), 50.0, {
    name="GarbageJob",
    useZ=false,
    --debugPoly=true
})

local inside = false
AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'GarbageJob' then
        inside = inZone
        if inZone then
            local ped = exports['geo-interface']:InterfacePed({
                model = 's_m_m_dockwork_01',
                position = vector4(-349.72, -1569.97, 25.22, 287.0),
                title = 'Garbage',
                scenario = 'WORLD_HUMAN_CLIPBOARD',
                event = GarbageMenu
            })

            while inside do
                Wait(500)
            end

            exports['geo-interface']:RemovePed(ped)
        end
    end
end)

function GarbageMenu()
    local garbageData, groups = table.unpack(Task.Run('Garbage.Get'))

    local menu = {
        {title = garbageData.OnJob and 'Clock Out' or 'Clock In', hidden = garbageData.FormingGroup,  serverevent = 'Garbage.Start'},
        {title = 'Clock In (Group)', hidden = garbageData.OnJob or garbageData.FormingGroup, sub = 'This will start a group another person can join. the person starting the group must be the driver', serverevent = 'Garbage.Group'},
        {title = 'Cancel Group', hidden = not garbageData.FormingGroup, serverevent = 'Garbage.CancelGroup'},
        {title = 'Pay: $'..comma_value(garbageData.pay), hidden = garbageData.pay == 0, serverevent = 'Garbahe.Pay'}
    }

    if not garbageData.OnJob then
        for k,v in pairs(groups) do
            table.insert(menu, {
                title = 'Available Group: '..v, hidden = MyCharacter.id == k,serverevent = 'Garbage.JoinGroup', params = {k}
            })
        end
    end

    table.insert(menu, 
        {title = 'Ask for Promotion', serverevent = 'Garbage.Promotion'}
    )

    table.insert(menu, 
        {description = 'Current Rank: '..garbageData.rankname}
    )

    RunMenu(menu)
end

local truck
local modelOptions = {}
local trashModels = {
    218085040,
    666561306,
    -1096777189,
    -58485588
}

CreateThread(function()
    Wait(1000)
    for k,v in pairs(trashModels) do
        exports['geo-interface']:AddTargetModel(v, 'Loot Garbage', 'Garbage.Loot', nil, 2.0, 'fas fa-trash')
    end
end)

RegisterNetEvent('Garbage.Loot', function(null, pData)
    TaskTurnPedToFaceEntity(Shared.Ped, pData.entity, 1000)
    Wait(1000)
    LoadAnim("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
    TaskPlayAnim(Shared.Ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0, 1.0, -1, 31, 1.0, 0, 0, 0)
    if exports['geo-shared']:ProgressSync('Searching the Trash', 10000) then
        Task.Run('Garbage.Loot')
    end
    StopAnimTask(Shared.Ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
end)

RegisterNetEvent('Garbage.AllowPickup', function(pTruck)
    for k,v in pairs(trashModels) do
        table.insert(modelOptions, exports['geo-interface']:AddTargetModel(v, 'Grab Garbage', 'Garbage.Pickup', nil, 2.0, 'fas fa-trash'))
    end

    truck = NetworkGetEntityFromNetworkId(pTruck)
end)

local carryingTrash
AddEventHandler('Garbage.Pickup', function()
    local min, max = GetModelDimensions(GetEntityModel(truck))
    RequestAnimDict('missfbi4prepp1')
    while not HasAnimDictLoaded('missfbi4prepp1') do
        Wait(0)
    end
    TaskPlayAnim(Shared.Ped, "missfbi4prepp1", '_idle_garbage_man', 1.0, 1.0, -1, 49, 1.0, 0, 0, 0)
    local trashBag = Shared.SpawnObject('prop_cs_rub_binbag_01')
    SetEntityCollision(trashBag, false, false)
    AttachEntityToEntity(trashBag, Shared.Ped, GetPedBoneIndex(Shared.Ped, 0xE5F2), 0.0, 0.05, 0.0, 0.0, 0.0, 0.0, 1, 0, 1, 1, 1, 0)
    Wait(250)
    carryingTrash = true
    Update('range', 1)
    while carryingTrash do
        Wait(0)

        if not IsEntityPlayingAnim(Shared.Ped, "missfbi4prepp1", '_idle_garbage_man', 3) then
            TaskPlayAnim(Shared.Ped, "missfbi4prepp1", '_idle_garbage_man', 1.0, 1.0, -1, 49, 1.0, 0, 0, 0)
        end

        Shared.DisableWeapons()
        local veh = Shared.EntityInFront(5.0)
        if veh == truck then
            local pos = GetOffsetFromEntityInWorldCoords(truck, 0.0, min.y, 0.0)
            if Vdist3(GetEntityCoords(Shared.Ped), pos) <= 1.0 then
                if GetVehicleDoorAngleRatio(veh, 5) > 0 then
                    HelpText('Press ~INPUT_DETONATE~ to put the trash in')
                    if IsControlJustPressed(0, 47) then
                        StopAnimTask(Shared.Ped, "missfbi4prepp1", '_idle_garbage_man', 1.0)
                        Task.Run('Garbage.Collect')
                        carryingTrash = false
                    end
                else
                    HelpText('Open the trunk')
                end
            end
        else
            HelpText('Press ~INPUT_DETONATE~ to drop trash')
            if IsControlJustPressed(0, 47) then
                StopAnimTask(Shared.Ped, "missfbi4prepp1", '_idle_garbage_man', 1.0)
                carryingTrash = false
            end
        end
    end
    LoadAnim('anim@heists@narcotics@trash')
    TaskPlayAnim(Shared.Ped, 'anim@heists@narcotics@trash', 'throw_b', 1.0, -1.0, 1000, 1, 0, 0, 0, 0)
    Update('range', 0)
    Wait(1000)
    TriggerServerEvent('DeleteEntity', ObjToNet(trashBag))
end)

RegisterNetEvent('Garbage.RemovePickup', function()
    for k,v in pairs(modelOptions) do
        v.remove()
    end
end)

RegisterNetEvent('Garbage.PingPong', function()
    TriggerServerEvent('Garbage.Start')
end)

local blip = AddBlipForCoord(vector3(-349.71, -1569.94, 25.22))
SetBlipSprite(blip, 318)
SetBlipColour(blip, 52)
SetBlipAsShortRange(blip, true)
SetBlipScale(blip, 0.8)
BeginTextCommandSetBlipName("STRING");
AddTextComponentString('Garbage')
EndTextCommandSetBlipName(blip)