local active = {}
local props = {}
local fx = {}
local binds = GetResourceKvpString('binds') and json.decode(GetResourceKvpString('binds')) or {}

Menu.CreateMenu('Emotes', 'Emotes')
RegisterCommand('emmote', function()
    Menu.OpenMenu('Emotes')
    while Menu.CurrentMenu == 'Emotes' do
        Wait(0)

        for k,v in Shared.SortAlphabet(Emotes) do
            if Menu.Button(v[3]..IsBind(k), k) then
                PlayEmote(v, k)
            end
        end

        Menu.Display()
    end
end)

function IsBind(emote)
    for k,v in pairs(binds) do
        if v == emote then
            return ' ~g~ [Bind '..k..']~w~'
        end
    end
    return ''
end

Menu.CreateMenu('Expressions', 'Expressions')
RegisterCommand('Expressions', function()
    Menu.OpenMenu('Expressions')
    while Menu.CurrentMenu == 'Expressions' do
        Wait(0)

        for k,v in Shared.SortAlphabet(Expressions) do
            if Menu.Button(k) then
                SetFacialIdleAnimOverride(Shared.Ped, v[1], 0)
            end
        end

        Menu.Display()
    end
end)

function PlayEmote(v, emote)
    if MyCharacter.dead == 1 then return end
    for k,val in pairs(active) do
        if val.emotename == emote then
            ExecuteCommand('ec '..emote)
            return
        end
    end

    if GetVehiclePedIsIn(Shared.Ped, false) ~= 0 then
        return
    end

    local p, p2

    if v.AnimationOptions then
        LoadAnim(v[1])
        local length = v.AnimationOptions.EmoteDuration or (math.floor(v.AnimationOptions.EmoteLoop == true and -1 or GetAnimDuration(v[1], v[2]) * 1000))
        TaskPlayAnim(Shared.Ped, v[1], v[2], 3.0, 3.0, length, v.AnimationOptions.EmoteMoving == true and 51 or 1, 1.0, false, false, false)
        table.insert(active, v)
        active[#active].emotename = emote

        if v.AnimationOptions.Prop then
            p = Shared.SpawnObject(v.AnimationOptions.Prop)
            local x, y, z, rx, ry, rz = table.unpack(v.AnimationOptions.PropPlacement)
            AttachEntityToEntity(p, Shared.Ped, GetPedBoneIndex(Shared.Ped, v.AnimationOptions.PropBone), x, y, z, rx, ry, rz, 1, 1, 0, 1, 1, 1)
            table.insert(props, {p, GetEntityModel(p)})
            active[#active].prop = p
            if length ~= -1 then
                CreateThread(function()
                    Wait(length)
                    DeleteEntity(p)
                end)
            end
        end

        if v.AnimationOptions.SecondProp then
            p2 = Shared.SpawnObject(v.AnimationOptions.SecondProp)
            local x, y, z, rx, ry, rz = table.unpack(v.AnimationOptions.SecondPropPlacement)
            AttachEntityToEntity(p2, Shared.Ped, GetPedBoneIndex(Shared.Ped, v.AnimationOptions.SecondPropBone), x, y, z, rx, ry, rz, 1, 1, 0, 1, 1, 1)
            table.insert(props, {p2, GetEntityModel(p2)})
            active[#active].prop2 = p2
            CreateThread(function()
                Wait(length)
                DeleteEntity(p2)
            end)
        end

        if v.AnimationOptions.PtfxAsset then

            while not HasNamedPtfxAssetLoaded(v.AnimationOptions.PtfxAsset) do
                RequestNamedPtfxAsset(v.AnimationOptions.PtfxAsset)
                Wait(10)
            end
    
            UseParticleFxAssetNextCall(v.AnimationOptions.PtfxAsset)
            local x, y, z, rx, ry, rz = table.unpack(v.AnimationOptions.PtfxPlacement)
            local Ptfx = StartNetworkedParticleFxLoopedOnEntityBone(v.AnimationOptions.PtfxName, v.AnimationOptions.PtfxNoProp ~= nil and PlayerPedId() or p, x, y, z, rx, ry, rz, GetEntityBoneIndexByName(v.AnimationOptions.PtfxName, "VFX"), 1065353216, 0, 0, 0, 1065353216, 1065353216, 1065353216, 0)
            SetParticleFxLoopedColour(Ptfx, 1.0, 1.0, 1.0) 
            table.insert(fx, Ptfx)
            active[#active].fx = Ptfx
        end
    else
        if v[1]:match('Scenario') then
            TaskStartScenarioInPlace(Shared.Ped, v[2], 0, true)
            table.insert(active, v)
            active[#active].emotename = emote
        else
            LoadAnim(v[1])
            TaskPlayAnim(Shared.Ped, v[1], v[2], 3.0, 3.0, math.floor(GetAnimDuration(v[1], v[2]) * 1000), 1, 1.0, false, false, false)
            table.insert(active, v)
            active[#active].emotename = emote

            if v[4] then
                Wait(v[4])
                StopAnimTask(Shared.Ped, v[1], v[2], 1.0)
            end
        end
    end
end

RegisterCommand('ec', function(source, args)
    if args[1] then
        for k,v in pairs(active) do
            if v.emotename == args[1] then
                if Emotes[args[1]].AnimationOptions then
                    StopAnimTask(Shared.Ped, v[1], v[2], 2.0)
                    if v.prop then DeleteEntity(v.prop) end
                    if v.prop2 then DeleteEntity(v.prop2) end
                    if v.fx then StopParticleFxLooped(v.fx, false) end
                    active[k] = nil
                    return
                else
                    ClearPedTasks(Shared.Ped)
                    active = {}
                    return
                end
            end
        end
        return
    else
        for k,v in pairs(active) do
            if v.AnimationOptions then
                StopAnimTask(Shared.Ped, v[1], v[2], 2.0)
            else
                ClearPedTasks(Shared.Ped)
            end
        end
    end
   

    for k,v in pairs(props) do
        if DoesEntityExist(v[1]) and GetEntityModel(v[1]) == v[2] then
            DeleteEntity(v[1])
        end
    end

    for k,v in pairs(fx) do
        StopParticleFxLooped(v, false)
    end

    props = {}
    active = {}
end)

RegisterCommand('e', function(source, args)
    if not args[1] then
        TriggerEvent('Chat.Message', '', 'Valid Emotes: '..table.concat(EmoteNames, ', '), 'me')
    else
        if Emotes[args[1]] then
            PlayEmote(Emotes[args[1]], args[1])
        else
            TriggerEvent('Shared.Notif', 'Invalid Emote: '..args[1])
        end
    end
end)

local chairs = {
    [-109356459] = {0, 0.05, 0.5},
    [-171943901] = {0, 0.05, 0.0},
    [-377849416] = {0, 0.05, 0.5},
    [1037469683] = {0, 0.1, 0.4},
    [96868307] = {0, 0.05, 0.5},
    [-992710074] = {0, 0.05, 0.7},
    [-741944541] = {0, 0.05, 0.5},
    [1037469683] = {0, 0.05, 0.5},
    [-1198343923] = {0, 0.05, 0.5},
    [-1633198649] = {0, 0.05, 0.5},
    [1262298127] = {0, 0.05, 0.0},
    [-1281587804] = {0, 0.05, 0.5},
    [-1786424499] = {0, 0.05, 0.0},
    [-1235256368] = {0, 0.05, 0.0, 270},
    [-470815620] = {0, 0.05, 0.0},
    [-1971298567] = {0, 0.05, 0.375},
    [1816935351] = {0, 0.05, 0.6},
    [1577885496] = {0, 0.05, 0.5},
    [1889748069] = {0, 0.05, 0.5},
    [-1521264200] = {0, 0.05, 0.0},
    [-1728009829] = {0, 0.05, 0.875},
    [2129125614] = {0, 0.05, 0.575},
    [-212710979] = {0, -0.1, 0.575},
    [-1173315865] = {0, 0.05, 0.5},
    [2064599526] = {0, 0.05, 0.5},
    [1872312775] = {0, 0.05, 0.1},
}

exports('ValidChair', function(model)
    return chairs[model] ~= nil
end)

local sitting = false
AddEventHandler('Sit', function(entity)
    sitting = true
    TaskStartScenarioAtPosition(Shared.Ped, 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', GetOffsetFromEntityInWorldCoords(entity, table.unpack(chairs[GetEntityModel(entity)], 1 ,3)), GetEntityHeading(entity) + (chairs[GetEntityModel(entity)][4] or 180), -1, 1, 1)

    Wait(1000)
    while sitting do
        Wait(0)

        if IsControlPressed(0, 32) then
            break
        end

        if IsControlPressed(0, 31) then
            break
        end

        if IsControlPressed(0, 30) then
            break
        end

        if IsControlPressed(0, 34) then
            break
        end
    end

    ClearPedTasks(Shared.Ped)
    sitting = false
end)


local pointing = false
RegisterCommand('+point', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    pointing = true
    LoadAnim("anim@mp_point")
    --[[ SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1) ]]
    SetPedConfigFlag(Shared.Ped, 36, 1)
    Citizen.InvokeNative(0x2D537BA194896636, Shared.Ped, "task_mp_pointing", 0.5, -1, "anim@mp_point", 24)

    while pointing do
        Wait(0)
        local ped = Shared.Ped
        local camPitch = GetGameplayCamRelativePitch()
        if camPitch < -70.0 then
            camPitch = -70.0
        elseif camPitch > 42.0 then
            camPitch = 42.0
        end
        camPitch = (camPitch + 70.0) / 112.0

        local camHeading = GetGameplayCamRelativeHeading()
        local cosCamHeading = Cos(camHeading)
        local sinCamHeading = Sin(camHeading)
        if camHeading < -180.0 then
            camHeading = -180.0
        elseif camHeading > 180.0 then
            camHeading = 180.0
        end
        camHeading = (camHeading + 180.0) / 360.0

        local blocked = 0
        local nn = 0

        local coords = GetOffsetFromEntityInWorldCoords(ped, (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
        local ray = Cast_3dRayPointToPoint(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, ped, 7);
        nn,blocked,coords,coords = GetRaycastResult(ray)

        Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Pitch", camPitch)
        Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Heading", camHeading * -1.0 + 1.0)
        Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isBlocked", blocked)
        Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isFirstPerson", Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4)
    end
end)

RegisterCommand('-point', function()
    pointing = false
    Citizen.InvokeNative(0xD01015C7316AE176, Shared.Ped, "Stop")
    ClearPedSecondaryTask(Shared.Ped)
    SetPedConfigFlag(Shared.Ped, 36, 0)
end)

RegisterKeyMapping('+point', '[Emote] Point', 'keyboard', 'B')

--[[ CreateThread(function()
    while true do
        Wait(0)
        for i=-10000,10000, 4 do
            DrawBox(i + 0.0, -10000.0, 0, i + 0.0, 10000.0, 250.0, 255, 255, 255, 20)
        end

        for i=-10000,10000, 4 do
            DrawBox(-10000.0, i + 0.0, 0, 10000.0, i + 0.0, 250.0, 255, 255, 255, 20)
        end
    end
end) ]]

local ragDolling = false
local ragTime = 0
RegisterKeyMapping('+Ragdoll', '[Emote] Ragdoll', 'keyboard', 'F11')
RegisterCommand('+Ragdoll', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    if Shared.TimeSince(ragTime) > 30000 then
        ragTime = GetGameTimer()
        ragDolling = true
        while Shared.TimeSince(ragTime) < 10000 and ragDolling do
            Wait(100)
            SetPedToRagdoll(Shared.Ped, 1000, 1000, 0, 1, 1, 1)
        end
    else
        TriggerEvent('Shared.Notif', 'Cooldown: '..((30000 - Shared.TimeSince(ragTime)) / 1000)..' seconds')
    end
end)

for i=1,6 do
    RegisterKeyMapping('emotebind'..i, '[Emote] Bind '..i, 'keyboard', 'NULL')
    RegisterCommand('emotebind'..i, function(source, args, raw)
        if not ControlModCheck(raw) then return end
        if Menu.CurrentMenu == 'Emotes' then
            local num = 1
            for k,v in Shared.SortAlphabet(Emotes) do
                if num == Menu.ActiveOption then
                    binds[tonumber(SplitString(raw, 'emotebind')[1])] = k
                    SetResourceKvp('binds', json.encode(binds))
                    break
                end
                num = num + 1
            end
        else
            ExecuteCommand('e '..binds[tonumber(SplitString(raw, 'emotebind')[1])])
        end
    end)
end

RegisterCommand('-Ragdoll', function()
    if ragDolling then
        ragDolling = false
    end
end)

CreateThread(function()
    Wait(1000)
    for k,v in pairs(booths) do
        exports['geo-interface']:AddTargetModel(k, 'Bench', 'Booth.Sita', {v}, 5.0, 'fas fa-chair')
    end
end)

local chairTest = false
SetEntityCollision(Shared.Ped, true, true)
FreezeEntityPosition(Shared.Ped, false)

AddEventHandler('Booth.Sita',function(coords, data)
    if chairTest then
        --TaskStartScenarioAtPosition(Shared.Ped, 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', GetOffsetFromEntityInWorldCoords(data.entity, table.unpack(booths[GetEntityModel(data.entity)], 1 ,3)), GetEntityHeading(data.entity) + (booths[GetEntityModel(data.entity)][4] or 180), -1, 1, 1)
        local offset = {0.0, 0.0, 0.0}
        local rot = {0.0, 0.0, 0.0}
        SetEntityNoCollisionEntity(data.entity, Shared.Ped, false)
        SetEntityCollision(Shared.Ped, false, false)
        FreezeEntityPosition(Shared.Ped, true)
        TaskPlayAnimAdvanced(Shared.Ped, "amb@prop_human_seat_chair_mp@male@generic@base", "base",
            GetOffsetFromEntityInWorldCoords(data.entity, 
            table.unpack(booths[GetEntityModel(data.entity)], 1 ,3)), 
            vec(table.unpack(rot)), 1.0, 1.0, -1, 1, 0.0, 0, 0)



        while true do
            Wait(0)
            local change = false
            if IsControlPressed(0, 32) then
                offset[2] = offset[2] + 0.01
                change = true
            end
                

            if IsControlPressed(0, 31) then
                offset[2] = offset[2] - 0.01
                change = true
            end

            if IsControlPressed(0, 30) then
                offset[1] = offset[1] + 0.01
                change = true
            end

            if IsControlPressed(0, 34) then
                offset[1] = offset[1] - 0.01
                change = true
            end

            if IsControlPressed(0, 44) then
                rot[3] = rot[3] - 1.0
                change = true
            elseif IsControlPressed(0, 51) then
                rot[3] = rot[3] + 1.0
                change = true
            end

            if IsControlPressed(0, 27) then
                change = true
                offset[3] =  offset[3] + 0.01
            elseif IsControlPressed(0, 173) then
                change = true
                offset[3] =  offset[3] - 0.01
            end


            if change then
                print(json.encode(offset))
                print(json.encode(rot))
                print(GetEntityHeading(data.entity) + rot[3])
                SetEntityCollision(Shared.Ped, false, false)
                FreezeEntityPosition(Shared.Ped, true)
                TaskPlayAnimAdvanced(Shared.Ped, "amb@prop_human_seat_chair_mp@male@generic@base", "base",
                        GetOffsetFromEntityInWorldCoords(data.entity, 
                        table.unpack(offset)), 
                        vec(table.unpack(rot)), 1.0, 1.0, -1, 1, 0.0, 0, 0)           
            end 
        end
    else
      --[[   LoadAnim("amb@prop_human_seat_chair_mp@male@generic@base")
        local pos = booths[GetEntityModel(data.entity)][5]

        for k,v in pairs(booths[GetEntityModel(data.entity)][5]) do
            local pos = v
            print(360 + pos[4])
            SetEntityCollision(Shared.Ped, false, false)
            FreezeEntityPosition(Shared.Ped, true)
            TaskPlayAnimAdvanced(Shared.Ped, "amb@prop_human_seat_chair_mp@male@generic@base", "base",
                    GetOffsetFromEntityInWorldCoords(data.entity, 
                    table.unpack(pos, 1, 3)), 
                    0.0, 0.0, (GetEntityHeading(data.entity) + pos[4]) % 360, 8.0, 1.0, -1, 1, 0.0, 0, 0)      
                    
            Wait(1000)
        end ]]
    end

    local ent = data.entity
    local pos = GetEntityCoords(ent)
    local coord = math.floor(pos.x * pos.y) << 32
    local val = Task.Run('Sit', coord, data.model)

    local menu = {}
    for k,v in pairs(val) do
        table.insert(menu, {
            title = 'Seat '..k, disabled = v ~= true, serverevent = 'Seat.Sit', params = {coord, k, data.entity}
        })
    end

    RunMenu(menu)
end)

RegisterNetEvent('Seat.Sit', function(seat, entity)
    local pos = booths[GetEntityModel(entity)][5][seat]

    SetEntityCollision(Shared.Ped, false, false)
    FreezeEntityPosition(Shared.Ped, true)
    LoadAnim("amb@prop_human_seat_chair_mp@male@generic@base")
    TaskPlayAnimAdvanced(Shared.Ped, "amb@prop_human_seat_chair_mp@male@generic@base", "base",
            GetOffsetFromEntityInWorldCoords(entity, 
            table.unpack(pos, 1, 3)), 
            0.0, 0.0, (GetEntityHeading(entity) + pos[4]) % 360, 8.0, 1.0, -1, 1, 0.0, 0, 0)    
            
    sitting = true
    Wait(1000)
    while sitting do

        if not IsEntityPlayingAnim(ped, "amb@prop_human_seat_chair_mp@male@generic@base", "base", 1) then
            LoadAnim("amb@prop_human_seat_chair_mp@male@generic@base")
            TaskPlayAnimAdvanced(Shared.Ped, "amb@prop_human_seat_chair_mp@male@generic@base", "base",
            GetOffsetFromEntityInWorldCoords(entity, 
            table.unpack(pos, 1, 3)), 
            0.0, 0.0, (GetEntityHeading(entity) + pos[4]) % 360, 8.0, 1.0, -1, 1, 0.0, 0, 0) 
            Wait(100)
        end

        if IsControlPressed(0, 32) then
            break
        end

        if IsControlPressed(0, 31) then
            break
        end

        if IsControlPressed(0, 30) then
            break
        end

        if IsControlPressed(0, 34) then
            break
        end

        Wait(100)
    end
    sitting = false
    TriggerServerEvent('Seat.Leave')

    SetEntityNoCollisionEntity(entity, Shared.Ped, true)
    SetEntityCollision(Shared.Ped, true, true)
    FreezeEntityPosition(Shared.Ped, false)

    StopAnimTask(Shared.Ped, "amb@prop_human_seat_chair_mp@male@generic@base", "base", 32.0)
    if booths[GetEntityModel(entity)][6] then
        SetEntityCoords(Shared.Ped, GetOffsetFromEntityInWorldCoords(entity, table.unpack(booths[GetEntityModel(entity)][6], 1 ,3)))
        SetEntityHeading(Shared.Ped, (GetEntityHeading(entity) + booths[GetEntityModel(entity)][6][4]) % 360)
    end
end)