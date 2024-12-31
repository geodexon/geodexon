local pedList = {}
_ent = nil
local options1 = {}
local options2 = {}
zoneData = {}

GatheringNodes = {}

exports('CharacterSelect', function(peds)
    pedList = peds
    SendNUIMessage({
        interface = 'CharacterSelect',
    })
    UIFocus(true, true)
end)

RegisterNUICallback('SelectChar', function(data, cb)
    local x, y = data.x, data.y
    local pos, dir = ScreenToWorld(x, y)
    local ent = RayTo(dir, 50.0)

    for k,v in pairs(pedList) do
        if v.ped == ent.HitEntity then
            SendNUIMessage({
                interface = 'Character.Found',
                data = v.data,
                name = v.data ~= 'none' and GetName(v.data) or 'none',
            })
            break
        end
    end

    cb()
end)

RegisterNUICallback('Login', function(data, cb)
    for k,v in pairs(pedList) do
        if v.data.id == data.id then
            LoadAnim('amb@world_human_cheering@male_a')
            TaskPlayAnim(v.ped, 'amb@world_human_cheering@male_a', 'base', 4.0, 4.0, 5000, 1, 1.0, 0, 0, 0)
            Wait(1000)
            break
        end
    end

    TriggerServerEvent('Character.Select', data.id)
    UIFocus(false, false)

    Wait(2000)
    if not MyCharacter then
        exports['geo-interface']:CharacterSelect(pedList)
    end
    cb()
end)

RegisterNUICallback('Create', function(data, cb)
    UIFocus(false, false)
    exports['geo']:CreateCharacter()
    cb()
end)

RegisterNUICallback('Delete', function(data, cb)
    TriggerServerEvent('Character.Delete', data.id)
    cb()
end)

RegisterNUICallback('Work', function(data, cb)
    if not Task.Run('Ped.Work', data.id) then
        cb(false)
        return
    end

    for k,v in pairs(pedList) do
        print(v.data.id == data.id)
        if v.data.id == data.id then
            LoadAnim('move_weapon@jerrycan@generic')
            local nPed = pedList[k].ped
            pedList[k].ped = 9999
            print(nPed)
            TaskPlayAnim(nPed, 'move_weapon@jerrycan@generic', 'idle', 1.0, 1.0, -1, 51, 1.0, 0, 0, 0)
            local obj = Shared.SpawnObject('prop_ld_case_01', vec(0, 0, 0), true)
            AttachEntityToEntity(obj, nPed, GetPedBoneIndex(nPed, 57005),  0.12,
            0.0,
            0.0,
            0.0,
            255.0,
            80.0, true, true, false, true, 1, true)
            cb(true)
            Wait(1000)

            FreezeEntityPosition(nPed, false)
            TaskGoToCoordAnyMeans(nPed, vector3(-226.64, -2005.93, 24.68), 1.30, 0, 0, 786603, 1.0)
            return
        end
    end
    cb(false)
end)

RegisterNUICallback('EntitySelect', function(data, cb)
    local x, y = data.x, data.y
    SelectEntity(x, y)
    cb()
end)

RegisterNUICallback('Entity.ItemClick', function(data, cb)
    _Use(data.item)
    cb()
end)

RegisterNUICallback('Entity.ItemHover', function(data, cb)
    _Hover(data.item)
    cb()
end)

RegisterNUICallback('Entity.ItemHoverEnd', function(data, cb)
    _HoverEnd(data.item)
    cb()
end)


RegisterNUICallback('Entity.SubItem', function(data, cb)
    _UseSub(data.name, data.command)
    cb()
end)

RegisterNUICallback('Entity.Finish', function(data, cb)
    _Done()
    cb()
end)

RegisterNUICallback('SelectOption.Close', function(data, cb)
    selectingOption = false
    cb()
end)

RegisterNUICallback('OptionSelected', function(data, cb)
    UseSearch(_selectOptions, data.option)
    cb()
end)

function RadialOptions(data, pEntity)
    local list = {}

    local _type = GetEntityType(pEntity or _ent)
    local pos = GetEntityCoords(Shared.Ped)
    for k,v in pairs(data) do
        if (_type == v.type or v.type == nil) and v.zone == nil then

            if _type ~= 0 then
                if v.model and _model ~= v.model then goto skipthis end
            end

            if not v.requires or (v.requires and v.requires(GetData(pEntity))) then
                if not v.distance or (v.distance and Vdist3(pos, GetEntityCoords(pEntity or _ent)) <= v.distance) then
                    table.insert(list, {
                        id = v.name,
                        title = v.displayname or v.name,
                        items = v.children and RadialOptions(v.children, pEntity) or nil,
                        icon = v.icon
                    })
                end
            end
        end

        if v.zone then
            local ray = Shared.Raycast(5.0).HitPosition
            local zoneData = exports['PolyZone']:IsInZone(ray)
            if (not v.distance or (v.distance and Vdist3(pos, ray) <= v.distance)) and zoneData and v.zoneName == zoneData.name then
                table.insert(list, {
                    id = v.name,
                    title = v.displayname or v.name,
                    items = v.children and RadialOptions(v.children, pEntity) or nil,
                    icon = v.icon
                })
            end
        end

        ::skipthis::
    end
    return list
end

function _Use(_item)
    mOPen = false
    if UseSearch(_interactOptions, _item) then return end
    if UseSearch(options1, _item) then return end
    if UseSearch(options2, _item) then return end
end

function UseSearch(data, name)
    for k,v in pairs(data) do
        if v.name == name then
            Wait(100)
            local _ = v.func and v.func(GetData(_ent))
            local params = {}
            if v.params then params = v.params end
            _ = v.event and TriggerEvent(v.event, GetData(_ent), table.unpack(params)) or nil
            return true
        end

        if v.children then
            if UseSearch(v.children, name) then
                return true
            end
        end
    end
end

function _UseSub(name, _item)
    for k,v in pairs(options1) do
        if v.name == name then
            for key,val in pairs(v.children) do
                if val.name == _item then
                    Wait(100)
                    local _ = val.func and val.func(GetData(_ent))
                    _ = v.event and TriggerEvent(v.event, GetData(_ent)) or nil
                    return
                end
            end
        end
    end

    for k,v in pairs(options2) do
        if v.name == name then
            for key,val in pairs(v.children) do
                if val.name == _item then
                    Wait(100)
                    local _ = val.func and val.func(GetData(_ent))
                    _ = v.event and TriggerEvent(v.event, GetData(_ent)) or nil
                    return
                end
            end
        end
    end
end

function _Hover(_item)
    for k,v in pairs(options1) do
        if v.name == _item then
            Wait(100)
            local _ = v.hover and v.hover()
            return
        end
    end

    for k,v in pairs(options2) do
        if v.name == _item then
            Wait(100)
            local _ = v.hover and v.hover()
            return
        end
    end
end

function _HoverEnd(_item)
    for k,v in pairs(options1) do
        if v.name == _item then
            Wait(100)
            local _ = v.hoverend and v.hoverend()
            return
        end
    end

    for k,v in pairs(options2) do
        if v.name == _item then
            Wait(100)
            local _ = v.hoverend and v.hoverend()
            return
        end
    end
end

function _Done()
    while GetUIFocus() do
        Wait(0)
    end
    Wait(250)

    for k,v in pairs(options1) do
        local _ = v.finish and v.finish()
    end

    for k,v in pairs(options2) do
        local _ = v.finish and v.finish()
    end
    _ent = nil
end

RegisterCommand("interface", function(source, args, raw)
    if not ControlModCheck(raw) then return end
    _ent = nil
    local options =  NormalOptions()
    SetCursorLocation(0.5, 0.5)
    SendNUIMessage({
        interface = 'Entity.Select',
        options = options,
        SubMenus = NormalSub(),
    })

    UIFocus(true, true)
    SelectEntity(0.5, 0.5)
end)

exports('OpenMenu', function(data)
    local options = NormalOptions(data)
    options1 = data
    SendNUIMessage({
        interface = 'Entity.Select',
        options = options,
        SubMenus = NormalSub(),
        pos = true
    })

    UIFocus(true, true)
end)

function GetOptions(ent)
    local list = {}
    local _type = GetEntityType(ent)
    options2 = {}
    if _type == 0 then
        return {}
    end

    for k,v in pairs(_interactOptions) do
        if _type == v.type then
            if not v.requires or (v.requires and v.requires(GetData(_ent))) and v.submenu == nil then
                table.insert(list, {v.name, v.displayname, v.hover ~= nil})
                options2[k] = v
            end
        end
    end

    return list
end

function NormalOptions(data)
    local list = {}
    options1 = {}
    for k,v in pairs(data or _normalOptions) do
        if not v.requires or (v.requires and v.requires(GetData(_ent))) and v.submenu == nil then
            table.insert(list, {v.name, v.displayname, v.hover ~= nil})
            options1[k] = v
        end
    end

    return list
end

function GetSubMenus(list)
    local lst = {}
    for k,v in pairs(list) do
        for _,val in pairs(_interactOptions) do
            if val.name == v[1] and #(val.children or {}) > 0 then

                if not lst[v[1]] then
                    lst[v[1]] = {}
                end

                for _index, var in pairs(val.children or {}) do
                    if not var.requires or (var.requires and var.requires(GetData(_ent))) and var.submenu == nil then
                        table.insert(lst[v[1]], {var.name, var.displayname, var.hover ~= nil})
                    end
                end
            end
        end
    end

    return lst
end

function NormalSub()
    local lst = {}
    for k,v in pairs(options1) do
        if #(v.children or {}) > 0 then

            if not lst[v.name] then
                lst[v.name] = {}
            end

            for _index, var in pairs(v.children or {}) do
                if not var.requires or (var.requires and var.requires(GetData(_ent))) and var.submenu == nil then
                    table.insert(lst[v.name], {var.name, var.displayname, var.hover ~= nil})
                end
            end
        end
    end

    return lst
end

function SelectEntity(x, y)
    local pos, dir = ScreenToWorld(x, y)
    local ent = RayTo(dir, 15.0)
    _ent = GetEntityType(ent.HitEntity) ~= 0 and ent.HitEntity or nil
    _player = GetClosestPlayer(5.0)
    local options = GetOptions(ent.HitEntity)
    SendNUIMessage({
        interface = 'Entity.Selected',
        Options = options,
        SubMenus = GetSubMenus(options),
        x = x,
        y = y,
        l = RadialOptions(_interactOptions)
    })

    if _ent then
        local entity = _ent
        local min, max = GetModelDimensions(GetEntityModel(_ent))
        TriggerEvent('EntitySelected', entity)
        while _ent == entity do
            Wait(0)
            DrawMarker(20, GetEntityCoords(_ent) + vec(0, 0, max.z + 1.0), 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.25, 0.25, 0.25, 255, 255, 255, 255, 1, 1, 2, 0)
        end
    end
end

function GetData(pEntity)
    local data = {}
    data.pos = GetEntityCoords(Shared.Ped)
    if DoesEntityExist(pEntity or _ent) and GetEntityType(pEntity or _ent) ~= 0 then
        data.dist = Vdist3(data.pos, GetEntityCoords(pEntity or _ent))
        data.model = GetEntityModel(pEntity or _ent)
        data.min, data.max = GetModelDimensions(GetEntityModel(pEntity or _ent))
    end

    data.incar = Shared.CurrentVehicle ~= 0
    data.ray = Shared.Raycast(50.0)
    data.dist = Vdist3(data.pos, data.ray.HitPosition)
    data.zone = exports['PolyZone']:IsInZone(data.ray.HitPosition)
    data.entity = pEntity

    return data
end

--[[ CreateThread(function()
    local time = GetGameTimer()
    while true do
        Wait(0)
        local pos, dir = ScreenToWorld(0.5, 0.5)
        local ent = RayTo(dir, 15.0)
        DrawLine(GetEntityCoords(Shared.Ped), Shared.Raycast(10.0).HitPosition, 255, 255, 255, 255)
        DrawLine(GetEntityCoords(Shared.Ped), ent.HitPosition, 255, 255, 255, 255)
    end
end) ]]

CreateThread(function()
    AddBoxZone(vector3(401.44, -1632.33, 29.29), 14.6, 8.8, {
        name="ImpoundDrop",
        heading=320,
        --debugPoly=true,
        minZ=27.49,
        maxZ=31.49
    })

    AddBoxZone(vector3(307.5, -595.29, 43.28), 0.55, 0.4, {
        name="evidence_patient",
        heading=340,
        --debugPoly=true,
        minZ=43.08,
        maxZ=43.18
    }, true)

    AddBoxZone(vector3(441.03, -980.11, 30.69), 0.4, 0.6, {
        name="reclaim",
        heading=340,
        --debugPoly=true,
        minZ=30.84,
        maxZ=30.99
    }, true)
end)

AddEventHandler('Poly.Zone', function(zone, inZone)
    zoneData[zone] = inZone
end)

local mOPen
selectingOption = false
RegisterCommand('+eselect', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    if _clothingOpen or MyCharacter == nil or IsPauseMenuActive() then return end
    if exports['object_gizmo']:GizmoActive() then return end
    GatheringNodes = exports['geo-disciple']:GetNodes()
    
    SendNUIMessage({
        interface = 'Selector',
        mode = 'open'
    })

    mOPen = true
    local lastLen = 0

    CreateThread(function()
        while mOPen do
            Shared.DisableWeapons()
            Wait(0)
        end
    end)

    TriggerEvent('SelectingEntity', true)
    while mOPen do
        local entity = Shared.Raycast(10.0).HitEntity
        _ent = entity
        local options = RadialOptions(_selectOptions, entity)
        if #json.encode(options) ~= lastLen then
            lastLen = #json.encode(options)
            SendNUIMessage({
                interface = 'SelectorUpdate',
                options = options
            })
        end
        Wait(100)
    end
    TriggerEvent('SelectingEntity', false)
end)

RegisterCommand('-eselect', function()
    local entity = Shared.Raycast(10.0).HitEntity
    mOPen = false
    _ent = entity
    local options = RadialOptions(_selectOptions, entity)
    if #json.encode(options) > 2 then
        SetCursorLocation(0.5, 0.5)
        UIFocus(true, true)
        SendNUIMessage({
            interface = 'SelectOption'
        })

        selectingOption = true
        while selectingOption do
            Wait(100)

            local entity = Shared.Raycast(10.0).HitEntity
            _ent = entity
            local options = RadialOptions(_selectOptions, entity)
            if #json.encode(options) ~= lastLen then
                lastLen = #json.encode(options)
                SendNUIMessage({
                    interface = 'SelectorUpdate',
                    options = options
                })
            end

            if #options == 0 then 
                selectingOption = false
                break 
            end
        end
        UIFocus(false, false)
    end

    SendNUIMessage({
        interface = 'Selector',
        mode = 'close'
    })
end)

RegisterKeyMapping('interface', '[Interface] Radial', 'keyboard', 'F1')
RegisterKeyMapping('+eselect', '[Interface] Select Entity', 'keyboard', 'LMENU')

local dc
function Discord()
    SetNuiFocus(true, true)
    SendNUIMessage({
        interface = 'Discord'
    })

    dc = promise:new()
    return Citizen.Await(dc)
end

RegisterNUICallback('Discord', function()
    dc:resolve(true)
end)

local imageProm

RegisterNUICallback('img64', function(data, cb)
    cb(true)
    imageProm:resolve(data.data)
end)

Task.Register('GetImage', function()
    imageProm = promise:new()

    local handle = RegisterPedheadshot(Shared.Ped)
    while not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle) do
        Citizen.Wait(0)
    end
    local txd = GetPedheadshotTxdString(handle)

    SendNUIMessage({
        interface = 'getimage',
        data = txd..'?'..uuid(),
        data2 = txd
    })


    Wait(500)
    UnregisterPedheadshot(handle)

    return Citizen.Await(imageProm)
end)

exports('Discord', Discord)

--[[ CreateThread(function()
    local ped = Shared.ClosestPed(15.0)
    if ped then
        local handle = RegisterPedheadshot(ped)
        while not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle) do
            Citizen.Wait(0)
        end
        local txd = GetPedheadshotTxdString(handle)
        local msg = txd..'?'..uuid()

        print(txd, msg)

        local key = GetControlInstructionalButton(2, 0x3008C430, true)
        local keyName = translateKey(key)

        SendNUIMessage({
            interface = 'SpeechBubble',
            msg = msg,
            txd = txd,
            key = keyName
        })

        Wait(500)
        UnregisterPedheadshot(handle)
       

        while true do
            Wait(0)
            local pedHeading = GetEntityHeading(ped)
            local camPitch = GetGameplayCamRot()

            local offset = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, 1.25)
            local found, _x, _y = GetScreenCoordFromWorldCoord(offset.x, offset.y, offset.z)

            local dist = Vdist(GetEntityCoords(ped), GetEntityCoords(Shared.Ped))
            if dist > 10 then
                dist = -1
            end

            SendNUIMessage({
                interface = 'SpeechBubbleLocation',
                pos = {_x, _y, pedHeading - camPitch.z - 180, dist},
            })
        end

    end
end) ]]

function translateKey(key)
    if (string.find(key, "t_")) then
        return string.gsub(key, "t_", "")
    else
        print(key)
        -- My global variable of special characters call SpecialkeyCodes
        return "SpecialCharacter."..SpecialkeyCodes[key]
    end
end

SpecialkeyCodes={
    ['b_116']='WheelMouseMove.Up',
    ['b_115']='WheelMouseMove.Up',
    ['b_100']='MouseClick.LeftClick',
    ['b_101']='MouseClick.RightClick',
    ['b_102']='MouseClick.MiddleClick',
    ['b_103']='MouseClick.ExtraBtn1',
    ['b_104']='MouseClick.ExtraBtn2',
    ['b_105']='MouseClick.ExtraBtn3',
    ['b_106']='MouseClick.ExtraBtn4',
    ['b_107']='MouseClick.ExtraBtn5',
    ['b_108']='MouseClick.ExtraBtn6',
    ['b_109']='MouseClick.ExtraBtn7',
    ['b_110']='MouseClick.ExtraBtn8',
    ['b_1015']='AltLeft',
    ['b_1000']='ShiftLeft',
    ['b_2000']='Space',
    ['b_1013']='ControlLeft',
    ['b_1002']='Tab',
    ['b_1014']='ControlRight',
    ['b_140']='Numpad4',
    ['b_142']='Numpad6',
    ['b_144']='Numpad8',
    ['b_141']='Numpad5',
    ['b_143']='Numpad7',
    ['b_145']='Numpad9',
    ['b_200']='Insert',
    ['b_1012']='CapsLock',
    ['b_170']='F1',
    ['b_171']='F2',
    ['b_172']='F3',
    ['b_173']='F4',
    ['b_174']='F5',
    ['b_175']='F6',
    ['b_176']='F7',
    ['b_177']='F8',
    ['b_178']='F9',
    ['b_179']='F10',
    ['b_180']='F11',
    ['b_181']='F12',
    ['b_194']='ArrowUp',
    ['b_195']='ArrowDown',
    ['b_196']='ArrowLeft',
    ['b_197']='ArrowRight',
    ['b_1003']='Enter',
    ['b_1004']='Backspace',
    ['b_198']='Delete',
    ['b_199']='Escape',
    ['b_1009']='PageUp',
    ['b_1010']='PageDown',
    ['b_1008']='Home',
    ['b_131']='NumpadAdd',
    ['b_130']='NumpadSubstract',
    ['b_1002']='CapsLock',
    ['b_211']='Insert',
    ['b_210']='Delete',
    ['b_212']='End',
    ['b_1055']='Home',
    ['b_1056']='PageUp',
    }