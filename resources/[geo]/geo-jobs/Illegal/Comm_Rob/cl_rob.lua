local model = 1224306523
local jobState = 'none'
local startPed
local jobBlip

local optList = {
    ['none'] = function()
        TriggerServerEvent('CommercialRobbery.StartJob')
    end,
    ['phase_1'] = function()
        TriggerServerEvent('CommercialRobbery.QuitJob')
    end,
    ['phase_2'] = function()
        TriggerServerEvent('CommercialRobbery.WarehouseLocation')
    end,
    ['phase_3'] = function()
        TriggerServerEvent('CommercialRobbery.QuitJob')
    end,
    ['phase_4'] = function()
        TriggerServerEvent('CommercialRobbery.FinishJob')
    end,
}

local textList = {
    ['none'] = 'Get Job',
    ['phase_1'] = 'Quit Job',
    ['phase_2'] = 'Get Location',
    ['phase_3'] = 'Quit Job',
    ['phase_4'] = 'Get Paid'
}

local jobStart = {}

AddZone({
    vector2(746.26239013672, -1689.7404785156),
    vector2(742.85980224609, -1722.279296875),
    vector2(750.77349853516, -1723.2419433594),
    vector2(752.31652832031, -1690.2738037109)
  }, {
    name="com_rob",
})

AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'com_rob' then
        jobStart.inside = inZone
        while jobStart.inside do
            Wait(0)
            if not startPed then
                startPed = Shared.SpawnPed(model, vector4(748.18, -1694.76, 29.29, 180.0), true)
                exports['geo-interface']:SetPed(startPed, textList[jobState], function() optList[jobState]() end)
                SetEntityCoords(startPed, GetEntityCoords(startPed) - vec(0.0, 0.0, GetEntityHeightAboveGround(startPed)))
                FreezeEntityPosition(startPed, true)
                SetEntityInvincible(startPed, true)
                SetBlockingOfNonTemporaryEvents(startPed, true)
            end
        end

        exports['geo-interface']:SetPed(startPed, nil)
        if DoesEntityExist(startPed) then
            DeleteEntity(startPed)
            startPed = nil
        end
    end
end)
  
RegisterNetEvent('CommercialRobbery.StartJob')
AddEventHandler('CommercialRobbery.StartJob', function()
    jobState = 'phase_1'
    local handsUp = false

    while jobState == 'phase_1' do
        Wait(0)
    end
end)

RegisterNetEvent('CommercialRobbery.QuitJob')
AddEventHandler('CommercialRobbery.QuitJob', function()
    RemoveBlip(jobBlip)
    jobState = 'none'
end)

RegisterNetEvent('CommercialRobbery.SetStage')
AddEventHandler('CommercialRobbery.SetStage', function(st)
    jobState = st
    exports['geo-interface']:SetPed(startPed, textList[jobState], function() optList[jobState]() end)

    if st == 'none' then
        RemoveBlip(jobBlip)
    end
end)
  
RegisterNetEvent('CommercialRobbery.WarehouseLocation')
AddEventHandler('CommercialRobbery.WarehouseLocation', function(loc)
    jobState = 'phase_3'

    jobBlip = AddBlipForCoord(loc)
    SetBlipRoute(jobBlip, true)

    while jobState == 'phase_3' do
        Wait(0)
        if Vdist3(GetEntityCoords(Shared.Ped), vec(loc.x, loc.y, loc.z)) <= 3.0 then
            Shared.WorldText('E', loc, 'Enter')
            if IsControlJustPressed(0, 38) then
                TriggerServerEvent('CommercialRobbery.EnterWarehouse')
                Wait(1000)
            end
        else
            Wait(500)
        end
    end
end)

local aProps = {}
RegisterNetEvent('CommercialRobbery.FillProps')
AddEventHandler('CommercialRobbery.FillProps', function(lst)
    for k,v in pairs(lst) do
        if v then
            local off = comProps[k]
            local obj = Shared.SpawnObject(off[1], vec(off[2], off[3], off[4]), true)
            SetEntityHeading(obj, off[5])
            aProps[k] = obj
        end
    end

    while (MyCharacter.interior ~= 'None' and MyCharacter.interior ~= nil) do
        Wait(0)
        local index, entity, position = GetClosestCrate()
        if index then
            Shared.WorldText('E', position, 'Rob')
            if IsControlJustPressed(0, 38) then
                local fail = false
                LoadAnim('amb@medic@standing@kneel@base')
                LoadAnim('anim@gangops@facility@servers@bodysearch@')
                TaskTurnPedToFaceEntity(Shared.Ped, entity, 1000)
                TaskPlayAnim(Shared.Ped, 'amb@medic@standing@kneel@base', 'base' ,2.0, 1.0, -1, 1, 0, false, false, false )
                TaskPlayAnim(Shared.Ped, 'anim@gangops@facility@servers@bodysearch@', 'player_search' ,1.0, -8.0, -1, 48, 0, false, false, false )
                for i=1,5 do
                    if not Minigame(10) then
                        fail = true
                        TriggerServerEvent('CommercialRobbery.FailGame', Shared.GetLocation())
                        break
                    end
                end
                StopAnimTask(Shared.Ped, 'amb@medic@standing@kneel@base', 'base', 1.0)
                StopAnimTask(Shared.Ped, 'anim@gangops@facility@servers@bodysearch@', 'player_search', 1.0)

                if not fail then
                    TriggerServerEvent('CommercialRobbery.RobCrate', index)
                end
            end
        end
    end

    for k,v in pairs(aProps) do
        DeleteEntity(v)
    end
    aProps = {}
end)

RegisterNetEvent('CommercialRobbery.RemoveCrate')
AddEventHandler('CommercialRobbery.RemoveCrate', function(id)
    if aProps[id] then
        if DoesEntityExist(aProps[id]) then
            DeleteEntity(aProps[id])
        end
    end
end)

function GetClosestCrate()
    local cl = 5.0
    local index
    local entity
    local position
    for k,v in pairs(aProps) do
        if DoesEntityExist(v) then
            local bPos = GetEntityCoords(v)
            local dist = Vdist3(GetEntityCoords(Shared.Ped), bPos)

            if dist <= 2.0 and dist < cl then
                cl = dist
                index = k
                entity = v
                position = bPos
            end
        end
    end

    if cl <= 2.0 then
        return index, entity, position
    end
end

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        for k,v in pairs(aProps) do
            DeleteEntity(v)
        end
    end
    DeleteEntity(startPed)
end)