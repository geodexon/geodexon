local unlocking = false
local stime
local ls = {}
local offsets = {
    [1557126584] = vector3(-1.0, 0.0, 0.0),
    [185711165] = vector3(-1.0, 0.0, 0.0),
    [-1033001619] = vector3(1.0, 0.0, 0.0),
    [631614199] = vector3(-1.0, 0.0, 0.0),
    [-2023754432] = vector3(1.0, 0.0, 0.0),
    [-1011692606] = vector3(1.25, 0.0, 0.0),
    [-519068795] = vector3(1.25, 0.0, 0.0)
}

RegisterNetEvent('Doors:Toggle')
AddEventHandler('Doors:Toggle', function(index, lock)
    Locks[index].Locked = lock
    local pos = GetEntityCoords(PlayerPedId())
    if Vdist4(pos, Locks[index].Pos) <= 250.0 then
        local obj = GetClosestObjectOfType(Locks[index].Pos, 5.0, Locks[index].Hash, 0, 0, 0)
        if obj then
            if Locks[index].Locked then
                SetEntityRotation(obj, Locks[index].Rot)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local pos = GetEntityCoords(PlayerPedId())
        if not unlocking then
            for k,v in pairs(Locks) do
                if Vdist4(pos, v.Pos) <= 100.0 then
                    local obj = GetClosestObjectOfType(v.Pos, 5.0, v.Hash, 0, 0, 0)
                    FreezeEntityPosition(obj, v.Locked)
                    if Vdist4(pos, v.Pos) <= (v.Range or 7.5) then
                        local pos2 = GetEntityCoords(obj)
                        Shared.WorldText('[E] '..IsLocked(v.Locked), GetOffsetFromEntityInWorldCoords(obj, offsets[v.Hash] or vector3(0, 0, 0))  )
                        if IsControlJustPressed(0, 38) then
                            TriggerEvent('ToggleLock')
                        end
                    end
                end
            end
        else
            local count = 0
            for k,v in pairs(ls) do
                count = count + 1
                local obj = GetClosestObjectOfType(v.Pos, 5.0, v.Hash, 0, 0, 0)
                if Shared.TimeSince(stime) <= 1000 then
                    Shared.WorldText(ToggleLock(v.Locked), GetOffsetFromEntityInWorldCoords(obj, offsets[v.Hash] or vector3(0, 0, 0))  )
                else
                    ls[k] = nil
                    TriggerServerEvent('Doors:Toggle', k)
                end
            end

            if count == 0 then
                unlocking = false
            end
        end
    end
end)

AddEventHandler('ToggleLock', function()
    local door = GetClosestDoor()
    if door then
        local allowed = false

        for key,val in pairs(Locks[door].Guilds) do
            if GuildAuthority(val, MyCharacter.id) > 100 then
                allowed = true
                break
            end
        end

        if not allowed then
            local inv = exports['geo-inventory']:GetInventory()

            for k,v in pairs(inv) do
                if v.Key == 'keycard' then
                    for key,val in pairs(Locks[door].Guilds) do
                        if v.Data.Guild == val then
                            for _, n in pairs(Guilds[val].keycard) do
                                if n == v.Data.Keycard then
                                    allowed = true
                                end
                            end
                        end
                    end
                end
            end

            if not allowed then
                return
            end
        end

        if Locks[door].Group then
            for key,val in pairs(Locks) do
                if val.Group == Locks[door].Group then
                    ls[key] = val
                end
            end
        else
            ls[door] = Locks[door]
        end

        unlocking = true
        stime = GetGameTimer()
        return
    end
end)

function IsLocked(bool)
    if bool then
        return 'Locked'
    end

    return 'Unlocked'
end

function ToggleLock(bool)
    if bool then
        return 'Unlocking'
    end

    return 'Locking'
end

function GetClosestDoor()
    local pos = GetEntityCoords(PlayerPedId())
    local closest = 500000.0
    local id
    for k,v in pairs(Locks) do
        local dist = Vdist4(pos, v.Pos)
        if dist < closest then
            if dist <= 7.5 then
                closest = dist
                id = k
            end
        end
    end

    return id
end