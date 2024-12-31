local exhausts = {
    'exhaust',
    'exhaust_2',
    'exhaust_3',
    'exhaust_4',
    'exhaust_5',
    'exhaust_6',
    'exhaust_7',
    'exhaust_8',
    'exhaust_9',
    'exhaust_10',
    'exhaust_11',
    'exhaust_12',
    'exhaust_13',
    'exhaust_14',
    'exhaust_15',
    'exhaust_16',
}

local nos = false
local nosVeh
RegisterKeyMapping('+nitrous', '[Vehicle] Nitrous', 'keyboard', 'o')
RegisterCommand('+nitrous', function()
    local veh = Shared.CurrentVehicle
    if veh ~= 0 and (Entity(veh).state.nos or 0) > 0 then
        nos = true
        Task.Run('NOS', NetworkGetNetworkIdFromEntity(veh), true)
        local nosTimer = GetGameTimer()
        local start = Entity(veh).state.nos
        AnimpostfxPlay("ExplosionJosh3", 50000, true)
        while nos and Shared.TimeSince(nosTimer) < 5000 and GetPedInVehicleSeat(veh, -1) == Shared.Ped and Entity(veh).state.nos > 0 do
            Wait(0)
            Entity(veh).state.nos = start - (Shared.TimeSince(nosTimer) / 100)
        end
        AnimpostfxPlay("ExplosionJosh3", 0, 0)
        Task.Run('NOS', NetworkGetNetworkIdFromEntity(veh), false, start - (Shared.TimeSince(nosTimer) / 100))
    end
end)

RegisterCommand('-nitrous', function()
    nos = false
end)


local nosIds = {}
RegisterNetEvent('NOS', function(veh, bool)
    if NetworkDoesEntityExistWithNetworkId(veh) then
        veh = NetworkGetEntityFromNetworkId(veh)
        if bool then
            nosIds[veh] = {}
            Nitrous(veh)
        else
            if nosIds[veh] then
                for i,v in pairs(nosIds[veh]) do
                    RemoveParticleFx(v)
                end
                nosIds[veh] = nil
            end
        end
    end
end)

function Nitrous(veh)
    local particleDict = "veh_xs_vehicle_mods"
    local driver = GetPedInVehicleSeat(veh, -1) == Shared.Ped
    RequestNamedPtfxAsset(particleDict)
    while not HasNamedPtfxAssetLoaded(particleDict) do
        Wait(0)
    end
    UseParticleFxAssetNextCall(particleDict)

    local pitch = GetEntityPitch(veh)
    local carPos = GetEntityCoords(veh, false)
    for k,v in pairs(exhausts) do
        local bone = GetEntityBoneIndexByName(veh, v)
        if bone ~= -1 then
            local offset = GetWorldPositionOfEntityBone(veh, bone)
            UseParticleFxAsset(particleDict)
            nosIds[veh][#nosIds[veh]+1] = StartNetworkedParticleFxLoopedOnEntityBone("veh_nitrous", veh, 0.0,0.0,0.0 , 0.0, pitch, 0.0, bone, 1.0, false, false, false)
        end
    end

    SetVehicleBoostActive(veh, true)
    if driver then
        while nosIds[veh] and DoesEntityExist(veh) do
            Wait(0)
            SetVehicleCheatPowerIncrease(veh, 1.75)
        end
    end

    if DoesEntityExist(veh) then
        SetVehicleBoostActive(veh, false)
    end
end