local currentlyPlacing = false

function PlaceObject(itemID, itemData)
    Citizen.CreateThread(function()
        if not currentlyPlacing then
            currentlyPlacing = true
            local hash = GetHashKey(items[itemData.Key].Prop)
            RequestModel(hash)
            while not HasModelLoaded(hash) do
                Wait(0)
            end
            local obj = CreateObject(hash, GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 5.0, 0.0), 0, 0, 1)
            local heading = GetEntityHeading(obj)
            SetEntityCollision(obj, false, false)
            while currentlyPlacing do
                Wait(0)
                local ray = Shared.Raycast(100)
                DisableControlAction(0, 311, true)
                DisableControlAction(0, 44, true)
                DisableControlAction(0, 51, true)
                DisableControlAction(0, 140, true)

                SetEntityCoords(obj, ray.HitPosition.x, ray.HitPosition.y, ray.HitPosition.z + (itemData.Data.Offset or 0.0))
                SetEntityHeading(obj, heading)

                if IsDisabledControlPressed(0, 44) then
                    heading = heading - 1.0
                elseif IsDisabledControlPressed(0, 51) then
                    heading = heading + 1.0
                end

                if IsControlJustPressed(0, 177) then
                    DeleteEntity(obj)
                    currentlyPlacing = false
                end

                if IsDisabledControlPressed(0, 140) then
                    DeleteEntity(obj)
                    TriggerServerEvent('PlaceProp', itemData, ray.HitPosition.x, ray.HitPosition.y, ray.HitPosition.z + (itemData.Data.Offset or 0.0), heading)
                    currentlyPlacing = false
                    return
                end
            end
            SetModelAsNoLongerNeeded(hash)
        end
    end)
end

RegisterCommand('pickup_prop', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    local obj = ClosestProp(5.0)
    if obj ~= 0 then
        if not NetworkGetEntityIsNetworked(obj) then
            return
        end

        local prop = Entity(obj)
        if prop.state.Prop ~= nil then
            TriggerServerEvent('PickupProp', ObjToNet(prop))
            LoadAnim('pickup_object')
            TaskPlayAnim(Shared.Ped, "pickup_object", "pickup_low", 1.0, 1.0, -1, 1, 3.0, 8.0, false, false, false)
            Wait(1000)
            StopAnimTask(Shared.Ped, "pickup_object", "pickup_low", 1.0)
        end
    end
end)

RegisterKeyMapping('pickup_prop', '[Inventory] Pickup Prop', 'keyboard', 'G')

function ClosestProp(maxDist)
    local vehList = GetGamePool("CObject")
    local dist = 1000
    local ped = PlayerPedId()
    local pos = GetEntityCoords(PlayerPedId())
    local closest
    for k, v in pairs(vehList) do
        local epos = GetEntityCoords(v)
        if Vdist4(pos, epos) < dist and NetworkGetEntityIsNetworked(v) and Entity(v).state.Prop then
            closest = v
            dist = Vdist4(pos, epos)
        end
    end
    if dist <= (maxDist or 5.0) then
        return closest
    else
        return 0
    end
end