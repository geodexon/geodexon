--[[ local surveying = false
AddEventHandler('Use:pickaxe', function(key, val)
    if not val.Data.Equipped then return end
    surveying = not surveying
    if surveying then
        while surveying do
            Wait(0)
            for k,v in pairs(Gathering.Nodes) do
                if Gathering.NearNode(GetEntityCoords(Shared.Ped), k) then
                    Shared.WorldText('[E] Gather', v.Position)
                    if IsControlJustPressed(0, 38) then
                        Gather(k)
                    end
                end
            end
        end
    end
end) ]]

AddEventHandler('Login', function()
    Task.Run('GetGatheringLog')
end)

CreateThread(function()
    Wait(1000)
    Task.Run('GetGatheringLog')
end)

AddEventHandler('Gathering.Harvest', function()
    local node = Gathering.NearAnyNode(GetEntityCoords(Shared.Ped))
    if node then
        Gather(node)
    end
end)

local compass = false
AddEventHandler('Use:compass', function()
    compass = not compass

    if compass then
        exports['geo-hud']:Radar(true)

        local blips = {}
        for k,v in pairs(Gathering.Nodes) do
            local blip = AddBlipForCoord(v.Position)
            SetBlipSprite(blip, 304)
            SetBlipScale(blip, 0.7)
            SetBlipFlashes(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('Gather')
            EndTextCommandSetBlipName(blip)
            table.insert(blips, blip)
        end

        local time = GetGameTimer()
        
        while compass and Shared.TimeSince(time) <= 15000 do
            Wait(0)
        end

        for k,v in pairs(blips) do
            RemoveBlip(v)
        end

        exports['geo-hud']:Radar(false)
        compass = false
    end
end)

local pNode
function Gather(nodeID)
    local data = Task.Run('Gathering.OpenNode', nodeID)
    pNode = nodeID
    if not data then return end
    UIFocus(true, true)
    SendNUIMessage({
        type = 'Gathering',
        interface = 'Gather',
        data = data,
        items = Gathering.XP,
        gatheringLog = gatheringLog
    })
end

function GetNodes()
    local list = {}
    for k,v in pairs(Gathering.Nodes) do
        table.insert(list, {v.Position, v.Name})
    end

    return list
end

exports('GetNodes', GetNodes)

RegisterNUICallback('CloseMenu', function(data, cb)
    UIFocus(false, false)
    craftMenu = false
    quickGather = false
    cb(true)
end)

local gathering = false
RegisterNUICallback('Gathering.Harvest', function(data, cb)
    quickGather = data.quick
    if gathering then return end
    gathering = true
    local prop
    local animDict, anim = 'melee@large_wpn@streamed_core', 'ground_attack_on_spot'
    local animDict2, anim2

    if data.skill == 'Mining' then
        prop = Shared.SpawnObject("prop_tool_pickaxe")
    end

    exports['geo-inventory']:ToggleWeapon()
    local divisor = 3
    if data.skill == 'Botany' then
        animDict, anim = "melee@hatchet@streamed_core", 'plyr_rear_takedown'

        if data.mainHand == 'false' then
            animDict, anim = "anim@gangops@morgue@table@", "player_search"
            divisor = 1
        end

        if data.mainHand == 'true' then
            GiveWeaponToPed(Shared.Ped, GetHashKey('WEAPON_HATCHET'), 1, 0, true)
            SetCurrentPedWeapon(Shared.Ped, GetHashKey('WEAPON_HATCHET'), true)
        end
    end

    TaskTurnPedToFaceCoord(Shared.Ped, Gathering.Nodes[pNode].Position, 1000)
    Wait(1000)

    LoadAnim(animDict)
    local pos, rot = GetEntityCoords(Shared.Ped), GetEntityRotation(Shared.Ped)
    if not quickGather then
        if prop then
            AttachEntityToEntity(prop, Shared.Ped, GetPedBoneIndex(Shared.Ped, 57005),  0.08,
            -0.4,
            -0.10,
            80.0,
            -20.0,
            175.0, false, true, true, true, 0, true)
        end

        for i=1,divisor do
            TaskPlayAnimAdvanced(Shared.Ped, animDict, anim, pos, rot, 1.0, 1.0, math.floor(5000 / divisor), 16, 0.0, 0, 0)
            if data.skill == 'Mining' then
                Wait(500)
                TriggerServerEvent('3DSound', PedToNet(PlayerPedId()), 'pickaxe.mp3', 0.5, 10.0)
                Wait(math.floor(4500/divisor))
            else
                Wait(math.floor(5000/divisor))
            end
        end

        cb({data = Task.Run('Gathering.Harvest', math.floor(data.item + 1)), log = gatheringLog})
    else
        if prop then
            AttachEntityToEntity(prop, Shared.Ped, GetPedBoneIndex(Shared.Ped, 57005),  0.08,
            -0.4,
            -0.10,
            80.0,
            -20.0,
            175.0, false, true, true, true, 0, true)        
        end        
        while quickGather do
            for i=1,divisor do
                TaskPlayAnimAdvanced(Shared.Ped, animDict, anim, pos, rot, 1.0, 1.0, math.floor(5000 / divisor),16, 0.0, 0, 0)
                if data.skill == 'Mining' then
                    Wait(500)
                    TriggerServerEvent('3DSound', PedToNet(PlayerPedId()), 'pickaxe.mp3', 0.5, 10.0)
                    Wait(math.floor(4500/divisor))
                else
                    Wait(math.floor(5000/divisor))
                end
            end
            local data = Task.Run('Gathering.Harvest', math.floor(data.item + 1))
            SendNUIMessage({
                type = 'Gathering',
                interface = 'UpdateNode',
                data = data,
                items = Gathering.XP,
                gatheringLog = gatheringLog
            })

            if not data then quickGather = false end
        end
       
    end
    if prop then
        TriggerServerEvent('DeleteEntity', ObjToNet(prop))
    end
    RemoveAllPedWeapons(Shared.Ped)
    StopAnimTask(Shared.Ped, animDict, anim, 1.0)
    StopAnimTask(Shared.Ped, animDict2 or '', anim2 or '', 1.0)
    gathering = false
end)

RegisterNetEvent('GatheringLog', function(data)
    gatheringLog = data
end)

function XP(str, pos, r, g, b, alpha)
    SetDrawOrigin(pos.x, pos.y, pos.z)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    if alpha < 0 then alpha = 0 end
    SetTextColour(r, g, b, math.floor(alpha))
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(str)
    DrawText(0, 0)
    ClearDrawOrigin()
end

RegisterNetEvent('GatheringXP', function(xp, pos, hq)
    local time = GetGameTimer()
    local colors = hq and {212, 212, 49} or {43, 189, 65}
    while Shared.TimeSince(time) <= 3500 do
        Wait(0)
        XP('+'..xp..' XP', pos, colors[1], colors[2], colors[3], 150 - ((Shared.TimeSince(time) / 3500) * 150))
        pos = pos + vec(0, 0, 0.01)
    end
end)

local selecting = false
AddEventHandler('SelectingEntity', function(bool)
    selecting = bool
    while selecting do
        Wait(0)

        for k,v in pairs(Gathering.Nodes) do
            DrawMarker(6, v.Position.x, v.Position.y, v.Position.z + 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0.4, 0.4, 0.4, 146, 122, 146, 255, 0, 1, 1, 0)
        end
    end
end)