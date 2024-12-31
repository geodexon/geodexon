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
    [-519068795] = vector3(1.25, 0.0, 0.0),
    [-1603817716] = vector3(-3.0, 0.0, 2.0),
    [741314661] = vector3(3.7, 0.0, 3.0),
    [-1156020871] = vector3(0.8, 0.0, -0.25),
    [-553305514] = vector3(1.0, 0.0, 0.0),
    [-1591004109] = vector3(1.4, 0.0, 0.0),
    [1425919976] = vector3(1.0, 0.0, 0.0),
    [9467943] = vector3(-1.0, 0.0, 0.0),
    [-1262354275] = vector3(1.2, 0.0, 0.0),
    [-147325430] = vector3(1.2, 0.0, 0.0),
    [-1264811159] = vector3(1.2, 0.0, 0.0),
    [1364638935] = vector3(1.2, 0.0, 0.0),
    [-1501157055] = vector3(-1.2, 0.0, 0.0),
    [2010487154] = vector3(-1.1, 0.0, 0.0),
}

RegisterNetEvent('Doors:Toggle')
AddEventHandler('Doors:Toggle', function(index, lock)
    Locks[index].Locked = lock
    DoorSystemSetDoorState(index, lock == true and 1 or 0, false, false)
    DoorSystemSetAutomaticRate(index, 30.0, true, true)
end)

RegisterNetEvent('Doors.Get')
AddEventHandler('Doors.Get', function(lst)
    for k,v in pairs(lst) do
        Locks[k].Locked = v
        DoorSystemSetDoorState(k, v == true and 4 or 0, false, false)
        DoorSystemSetAutomaticRate(k, 30.0, true, true)
    end
end)

CreateThread(function()
    while true do
        Wait(10000)
        for k,v in pairs(Locks) do
            DoorSystemSetDoorState(k, v.Locked == true and 4 or 0, false, false)
            DoorSystemSetAutomaticRate(k, 30.0, true, true)
        end
    end
end)

CreateThread(function()
    Wait(500)
    for k,v in pairs(Locks) do
        AddDoorToSystem(k, v.Hash, v.Pos, false, false, false)
        DoorSystemSetDoorState(k, v.Locked == true and 4 or 0, false, false)
        DoorSystemSetAutomaticRate(k, 30.0, true, true)
    end

    Wait(100)
    TriggerServerEvent('Doors.Get')
end)

local closestDoor = 0
local door
CreateThread(function()
    while true do
        Wait(0)
        if MyUser and MyUser.data and (MyUser.data.settings.doorlockui == nil or MyUser.data.settings.doorlockui) then
            if door and #closestDoor ~= 0 then
                if not unlocking then
                    for k,v in pairs(closestDoor) do
                        Shared.WorldText('E', GetOffsetFromEntityInWorldCoords(v[1], offsets[Locks[v[2]].Hash] or vector3(0, 0, 0)) , IsLocked(Locks[door].Locked))
                    end
                else
                    if Shared.TimeSince(stime) <= 1000 then
                        for k,v in pairs(closestDoor) do
                            Shared.WorldText(ToggleLock(Locks[door].Locked), GetOffsetFromEntityInWorldCoords(v[1], offsets[Locks[v[2]].Hash] or vector3(0, 0, 0))  )
                        end
                    end
                end
            end
        else
            Wait(1000)
        end
    end
end)

AddEventHandler('Interact', function()
    TriggerEvent('ToggleLock')
end)

CreateThread(function()
    while true do
        Wait(500)
        if MyUser and MyUser.data and (MyUser.data.settings.doorlockui == nil or MyUser.data.settings.doorlockui) then
            door = GetClosestDoor()
            if door then
                closestDoor = {}
                if Locks[door].Group then
                    for k,v in pairs(Locks) do
                        if v.Group == Locks[door].Group then
                            table.insert(closestDoor, {GetClosestObjectOfType(v.Pos, 5.0, v.Hash, 0, 0, 0), k})
                        end
                    end
                else
                    closestDoor = {{GetClosestObjectOfType(Locks[door].Pos, 5.0, Locks[door].Hash, 0, 0, 0), door}}
                end
            end
        else
            Wait(1000)
        end
    end
end)

function IsLocked(bool)
    return bool and 'Locked' or 'Unlocked'
end

function ToggleLock(bool)
    return bool and 'Unlocking' or 'Locking'
end

AddEventHandler('ToggleLock', function()
    if unlocking then return end
    local door = GetClosestDoor()
    if door then
        local allowed = false

        for key,val in pairs(Locks[door].Guilds) do
            if GuildAuthority(val, MyCharacter.id) >= 100 then
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

        LoadAnim('anim@mp_player_intmenu@key_fob@')
        TaskPlayAnim(Shared.Ped, "anim@mp_player_intmenu@key_fob@", 'fob_click', 16.0, 1.0, 500, 49, 1.0, 0, 0, 0)
        TriggerServerEvent('3DSound', Locks[door].Pos, 'door.wav', 0.15, 5.0)

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

            while Shared.TimeSince(stime) <= 1000 do
                Wait(100)
            end
            for k,v in pairs(ls) do
                TriggerServerEvent('Doors:Toggle', k)
            end
            ls = {}
            unlocking = false
        return
    end
end)

function GetClosestDoor()
    local pos = GetEntityCoords(PlayerPedId())
    local closest = 500000.0
    local id
    for k,v in pairs(Locks) do
        local dist = Vdist4(pos, v.Pos)
        if dist < closest then
            if dist <= (v.Range or 7.5) then
                closest = dist
                id = k
            end
        end
    end

    return id
end

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        for k,v in pairs(Locks) do
            RemoveDoorFromSystem(k)
        end
    end
end)