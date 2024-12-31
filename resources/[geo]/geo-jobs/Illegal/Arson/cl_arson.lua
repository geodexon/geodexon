local arson = {}

AddCircleZone(vector3(1237.85, 1863.94, 78.96), 45.7, {
    name="Arson",
    useZ=true,
})
  

local model = 1224306523
local jobState = 'none'
local startPed
local jobBlip

local optList = {
    ['none'] = function()
        Shared.WorldText('E', GetEntityCoords(startPed), 'Get Job')
        if IsControlJustPressed(0, 38) then
            jobState = nil
            TriggerServerEvent('Arson.StartJob')
        end
    end,
    ['phase_1'] = function()
        Shared.WorldText('E', GetEntityCoords(startPed), 'Quit Job')
        if IsControlJustPressed(0, 38) then
            jobState = nil
            TriggerServerEvent('Arson.QuitJob')
        end
    end,
    ['done'] = function()
        Shared.WorldText('E', GetEntityCoords(startPed), 'Get Paid')
        if IsControlJustPressed(0, 38) then
            jobState = nil
            TriggerServerEvent('Arson.Pay')
        end
    end,
}

AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'Arson' then
        if exports['geo-inventory']:HasItemKey('propane_torch') then
            arson.inside = inZone
            while arson.inside do
                Wait(0)
                if not startPed then
                    startPed = Shared.SpawnPed(model, vector4(1238.13, 1864.12, 78.95, 203.92), true)
                    SetEntityCoords(startPed, GetEntityCoords(startPed) - vec(0.0, 0.0, GetEntityHeightAboveGround(startPed)))
                    FreezeEntityPosition(startPed, true)
                    SetEntityInvincible(startPed, true)
                    SetBlockingOfNonTemporaryEvents(startPed, true)
                end
    
                if jobState then
                    if Vdist3(GetEntityCoords(Shared.Ped), GetEntityCoords(startPed)) <= 2.0 then
                        optList[jobState]()
                    end
                end
            end
    
            if DoesEntityExist(startPed) then
                DeleteEntity(startPed)
                startPed = nil
            end
        end
    end
end)

local fireBlip
local fireFX = {}
local fireFXPos
local fireSmoke
local fireHealth
RegisterNetEvent('Arson.StartJob')
AddEventHandler('Arson.StartJob', function(pos)
    local failcount = 0
    local start = vec(pos[1].x, pos[1].y, pos[1].z)
    local _int
    jobState = 'phase_1'
    jobBlip = AddBlipForCoord(pos[1].x, pos[1].y, pos[1].z)
    SetBlipRoute(jobBlip, true)

    while jobState == 'phase_1' do
        Wait(0)

        if Vdist3(GetEntityCoords(Shared.Ped), start) <= 6.0 then
            _int = Shared.Interact('[E] Start Fire') or _int
            if IsControlJustPressed(0, 38) then
                for i=1,6 do
                    if not Minigame(10, 1000) then
                        failcount = failcount + 1
                        if failcount == 1 then
                            TriggerServerEvent('Arson.CadAlert', Shared.GetLocation())
                        elseif failcount == 5 then
                            AddExplosion(GetEntityCoords(Shared.Ped), 3, 10.0, 1, 0, 5.0)
                        elseif failcount == 10 then
                            AddExplosion(GetEntityCoords(Shared.Ped), 8, 10.0, 1, 0, 5.0)
                        end

                        goto fail
                    end
                end
                TriggerServerEvent('Arson.Fire', Shared.GetLocation())
            end
        else
            Wait(500)
        end

        ::fail::
    end
    if _int then _int.stop() end

    RemoveBlip(jobBlip)
end)

local fireactive = false
local fireHealth = 100
local _fx
RegisterNetEvent('Arson.Fire')
AddEventHandler('Arson.Fire', function(pos)
    fireactive = true
    fireHealth = 100
    for k,v in pairs(fireFX) do
        RemoveParticleFx(v, 1)
    end
    RemoveParticleFx(fireSmoke, 1)
    local x, y, z = pos[1].x, pos[1].y, pos[1].z
    _fx = vec(x, y, z)
    if not HasNamedPtfxAssetLoaded("core") then
        RequestNamedPtfxAsset("core")
        while not HasNamedPtfxAssetLoaded("core") do
            Wait(0)
        end
    end
    UseParticleFxAssetNextCall("core")
    fireFX[1] = StartParticleFxLoopedAtCoord("fire_wrecked_plane_cockpit", x, y, z, 0.0, -2.0, 0.8, 10.0, 1, 0, 1, 1)
    if not HasNamedPtfxAssetLoaded("scr_agencyheistb") then
        RequestNamedPtfxAsset("scr_agencyheistb")
        while not HasNamedPtfxAssetLoaded("scr_agencyheistb") do
            Wait(0)
        end
    end
    UseParticleFxAssetNextCall("scr_agencyheistb")
    fireSmoke = StartParticleFxLoopedAtCoord("scr_agency3b_blding_smoke", x, y, z, 0.0, -2.0, 0.8, 3.0, 1, 0, 1, 1)
    fireHealth = 100
    if #pos <= 2 then
        for i=2,#pos do
            UseParticleFxAssetNextCall("core")
            fireFX[i] = StartParticleFxLoopedAtCoord("fire_wrecked_plane_cockpit", pos[i].x, pos[i].y, pos[i].z-0.98, 0.0, -2.0, 0.8, 2.0, 1, 0, 1, 1)
        end
    else
        local amount = {}
        while #amount < 2 do
            Wait(0)
            local val = math.random(2, #pos)
            local found = false
            if #amount == 0 then
                amount[1] = val
            end
            for k,v in pairs(amount) do
                if v == val then
                    found = true
                    break
                end
            end
            if not found then 
                amount[#amount + 1] = val
            end
        end
        for k,v in pairs(amount) do
            UseParticleFxAssetNextCall("core")
            fireFX[v] = StartParticleFxLoopedAtCoord("fire_wrecked_plane_cockpit", pos[v].x, pos[v].y, pos[v].z-0.98, 0.0, -2.0, 0.8, 2.0, 1, 0, 1, 1)
        end
    end
    fireFXPos = vector3(x, y, z)

    if exports['geo-es']:IsEMS(MyCharacter.id) and MyCharacter.Duty == 'EMS' then

        CreateThread(function()
            while fireactive do
                Wait(0)
                if Vdist3(GetEntityCoords(Shared.Ped), vec(x, y, z)) <= 50.0 and Shared.CurrentVehicle ~= 0 and GetPedInVehicleSeat(Shared.CurrentVehicle, -1) == Shared.Ped and GetEntityModel(Shared.CurrentVehicle) == GetHashKey('firetruk') then
                    if IsControlPressed(0, 68) then
                        fireHealth = fireHealth - 5
                        Wait(900)
                    end
                else
                    Wait(500)
                end

                if fireHealth <= 0 then
                    TriggerServerEvent('Arson.ClearFire')
                    Wait(1000)
                end
            end
        end)

        local _int
        _int = Shared.Interact('Fire Health '..fireHealth..'%') or _int
        while fireactive do
            Wait(0)
            if Vdist3(GetEntityCoords(Shared.Ped), vec(x, y, z)) <= 50.0 and Shared.CurrentVehicle ~= 0 and GetPedInVehicleSeat(Shared.CurrentVehicle, -1) == Shared.Ped and GetEntityModel(Shared.CurrentVehicle) == GetHashKey('firetruk') then
                _int.update('Fire Health '..fireHealth..'%')
            else
                Wait(500)
            end
        end
        if _int then _int.stop() end
    end
end)

RegisterNetEvent('Arson.ClearFire')
AddEventHandler('Arson.ClearFire', function()
    fireactive = false
    for k,v in pairs(fireFX) do
        RemoveParticleFx(v, 1)
    end
    RemoveParticleFx(fireSmoke, 1)
    local _fire
    if _fx then
        for i=50,0, -1 do
            if not HasNamedPtfxAssetLoaded("core") then
                RequestNamedPtfxAsset("core")
                while not HasNamedPtfxAssetLoaded("core") do
                    Wait(0)
                end
            end
            UseParticleFxAssetNextCall("core")
            local fire = StartParticleFxLoopedAtCoord("fire_wrecked_plane_cockpit", _fx, 0.0, -2.0, 0.8, i / 2.5 + 0.0, 1, 0, 1, 1)
            Wait(500)
            RemoveParticleFx(_fire, 1)
            _fire = fire
        end
    end
    RemoveParticleFx(_fire, 1)
end)

RegisterNetEvent('Arson.SetStage')
AddEventHandler('Arson.SetStage', function(stage)
    jobState = stage
end)