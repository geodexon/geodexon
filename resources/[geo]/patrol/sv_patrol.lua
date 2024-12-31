local entityList = {}
local patrolCount = 0
local patrols = {}

function CreateAutomobile(...)
    return Citizen.InvokeNative(GetHashKey('CREATE_AUTOMOBILE'), ...)
end

function CreatePatrol(pos)
    local ped = CreatePed(0, `s_m_y_cop_01`, pos.x, pos.y, pos.z - 50.0, pos.w, true, true)
    local vehicle = CreateAutomobile(`police5`, pos.x, pos.y, pos.z, pos.w)
    SetPedIntoVehicle(ped, vehicle, -1)

    entityList[ped] = 1
    entityList[vehicle] = 1

    while not DoesEntityExist(vehicle) and not DoesEntityExist(ped) do
        Wait(250)
    end

    local owner = FindOwner(vehicle)
    Entity(vehicle).state.owner = owner
    Entity(ped).state.owner = owner
    patrolCount = patrolCount + 1
    local patrolID = patrolCount
    patrols[patrolID] = {vehicle, ped}
    TriggerClientEvent('Patrols.Send', -1, patrols)

    TriggerClientEvent('Patrol.Start', owner, NetworkGetNetworkIdFromEntity(vehicle), NetworkGetNetworkIdFromEntity(ped))
    while DoesEntityExist(vehicle) do
        if NetworkGetEntityOwner(vehicle) ~= owner then
            if Entity(vehicle).state.owner ~= 0 then
                print("[Patrol]", string.format("Unit %s lost its owner, looking for a new one", vehicle))
                Entity(vehicle).state.owner = 0
                Entity(ped).state.owner = 0
                CreateThread(function()
                    owner = FindOwner(vehicle)
                    print("[Patrol]", string.format("Unit %s found a new owner (%s)", vehicle, owner))
                    Entity(vehicle).state.owner = owner
                    Entity(ped).state.owner = owner
                    TriggerClientEvent('Patrol.Start', owner, NetworkGetNetworkIdFromEntity(vehicle), NetworkGetNetworkIdFromEntity(ped))
                end)
            end
        end

        Wait(1000)
    end

    patrols[patrolID] = nil
    patrolCount = patrolCount - 1
    TriggerClientEvent('Patrols.Send', -1, patrols)
    if DoesEntityExist(ped) then
        DeleteEntity(ped)
    end
end

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        for k,v in pairs(entityList) do
            DeleteEntity(k)
        end
    end
end)

AddEventHandler('entityRemoved', function(ent)
    if entityList[ent] then entityList[ent] = nil end
end)

AddStateBagChangeHandler(false, false, function(bagName, key, value, source, replicated)
    local entityNet = tonumber(bagName:gsub('entity:', ''), 10)
    local entity = NetworkGetEntityFromNetworkId(entityNet)
    if entityList[entity] then
        local ent = Entity(entity)
        local curState = ent.state[key]

        if source ~= 0 then
            SetTimeout(0, function()
                print('removed fake bag: '..bagName, key, value)
                Entity(entity).state[key] = curState
            end)
        end
    end
end)

function FindOwner(veh)
    while NetworkGetEntityOwner(veh) == 0 or NetworkGetEntityOwner(veh) == -1 do
        Wait(250)
    end

    return NetworkGetEntityOwner(veh)
end

RegisterNetEvent('Patrol.Dispatch', function()
    CreatePatrol(vector4(425.64, -1022.41, 28.89, 90.81))
end)

RegisterNetEvent('Patrols.Get', function()
    local source = source
    TriggerClientEvent('Patrols.Send', source, patrols)
end)

RegisterNetEvent('Patrol.Request', function(id, index)
    local source = source
    local owner = NetworkGetEntityOwner(patrols[id][1])
    local vehicle = NetworkGetNetworkIdFromEntity(patrols[id][1])
    local ped = NetworkGetNetworkIdFromEntity(patrols[id][2])
    local playerPed = NetworkGetNetworkIdFromEntity(GetPlayerPed(source))

    if index == 1 then
        TriggerClientEvent('Patrol.Request', owner, vehicle, ped)
    elseif index == 2 then
        TriggerClientEvent('Patrol.Kill', owner, vehicle, ped, playerPed)
    elseif index == 3 then
        if GetVehiclePedIsIn(GetPlayerPed(source)) == 0 then
            TriggerClientEvent('Shared.Notif', source, 'You are not in a vehicle')
            return
        end
        TriggerClientEvent('Patrol.Escort', owner, vehicle, ped, playerPed)
    elseif index == 4 then
        TriggerClientEvent('Patrol.Patrol', owner, vehicle, ped)
    end
end)