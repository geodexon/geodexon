Shared = {}
MyCharacter = nil
MyUser = nil
Shared.Ped = PlayerPedId()
Shared.CurrentVehicle = GetVehiclePedIsIn(Shared.Ped, false)
Shared.Position = GetEntityCoords(Shared.Ped)
_interactActive = 0
State = {}
local funcID = {}
local count = 0
local taxRate = 0.0
controlMod = false
TriggerServerEvent("Mayor.GetTax")

AddEventHandler(
    "Mayor.GetTax",
    function(amount)
        taxRate = amount

        if RefreshInv then
            RefreshInv()
        end
    end
)

AddEventHandler(
    "ControlMod",
    function(bool)
        controlMod = bool
    end
)

AddEventHandler(
    "Login:Ret",
    function(char, user, t, data)
        if MyCharacter and t and data then
            MyCharacter[t] = data
            MyUser = user
        else
            MyCharacter = char
            MyUser = user
        end
    end
)

TriggerEvent(
    "Login:Info",
    function(char, user)
        MyCharacter = char
        MyUser = user
    end
)

RegisterNetEvent("Logout")
AddEventHandler(
    "Logout",
    function()
        MyCharacter = nil
        MyUser = nil
    end
)

AddEventHandler(
    "Login",
    function(char)
        MyCharacter = char
    end
)

AddEventHandler(
    "pedChanged",
    function(ped)
        Shared.Ped = ped
        SetPedMinGroundTimeForStungun(Shared.Ped, 2000)
    end
)

-- Raycasting

function CameraForwardVec(cam)
    local rot = (math.pi / 180.0) * (cam and GetCamRot(cam) or GetGameplayCamRot(2))
    return vector3(-math.sin(rot.z) * math.abs(math.cos(rot.x)), math.cos(rot.z) * math.abs(math.cos(rot.x)), math.sin(rot.x))
end

function Shared.Raycast(dist)
    local start = GetGameplayCamCoord()
    local target = start + (CameraForwardVec() * dist)

    local ray = StartShapeTestRay(start, target, -1, PlayerPedId(), 1)
    local a, b, c, d, ent = GetShapeTestResult(ray)
    return {
        a = a,
        b = b,
        HitPosition = c,
        HitCoords = d,
        HitEntity = ent
    }
end

function Shared.EntityInFront(distance, rear)
    if rear then
        distance = -distance
    end
    local targetVehicle = 0
    local currentEntityCoords = GetEntityCoords(PlayerPedId(), 1)
    for i = -4.0, 2.0, 0.1 do
        local currentWorldOffset = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, distance, i)
        local currentRayCastHandle = CastRayPointToPoint(currentEntityCoords.x, currentEntityCoords.y, currentEntityCoords.z + i, currentWorldOffset.x, currentWorldOffset.y, currentWorldOffset.z, 10, PlayerPedId(), 0)
        local A, B, C, D, targetVehicle = GetRaycastResult(currentRayCastHandle)
        if targetVehicle ~= nil and targetVehicle ~= 0 and IsEntityAVehicle(targetVehicle) then
            return targetVehicle
        end
    end
    return 0
end

function RayTo(dir, dist, ent, pos)
    local start = GetGameplayCamCoord()
    local _cam = GetRenderingCam()
    if _cam ~= -1 then
        start = GetCamCoord(_cam)
    end

    start = pos or start

    local target = start + (dir * dist)

    local ray = StartShapeTestRay(start, target, -1, ent or PlayerPedId(), 1)
    local a, b, c, d, ent = GetShapeTestResult(ray)
    return {
        a = a,
        b = b,
        HitPosition = c,
        HitCoords = d,
        HitEntity = ent
    }
end

function Shared.EntityInFront2(distance, rear)
    if rear then
        distance = -distance
    end
    local targetVehicle = 0
    local currentEntityCoords = GetEntityCoords(PlayerPedId(), 1)
    local currentWorldOffset = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, distance, -2.0)
    local currentRayCastHandle = StartShapeTestRay(currentEntityCoords, currentWorldOffset, -1, PlayerPedId(), 1)
    local A, B, C, D, targetVehicle = GetRaycastResult(currentRayCastHandle)
    if targetVehicle ~= nil and targetVehicle ~= 0 and GetEntityType(targetVehicle) ~= 0 then
        return targetVehicle
    end
    return 0
end

-- Entities

function Shared.ClosestPed(maxDist)
    local pedList = GetGamePool("CPed")
    local dist = 1000
    local ped = PlayerPedId()
    local pos = GetEntityCoords(PlayerPedId())
    local closest
    for k, v in pairs(pedList) do
        if v ~= ped then
            local epos = GetEntityCoords(v)
            if Vdist4(pos, epos) < dist then
                closest = v
                dist = Vdist4(pos, epos)
            end
        end
    end
    if dist <= (maxDist or 5.0) then
        return closest
    else
        return 0
    end
end

function Shared.ClosestVehicle(maxDist)
    local vehList = GetGamePool("CVehicle")
    local dist = 1000
    local ped = PlayerPedId()
    local pos = GetEntityCoords(PlayerPedId())
    local closest
    for k, v in pairs(vehList) do
        local epos = GetEntityCoords(v)
        if Vdist4(pos, epos) < dist then
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

function Shared.IsVehicleInArea(pos, range)
    if type(model) == "string" then
        model = GetHashKey(model)
    end
    local vehList = GetGamePool("CPed")
    local found = false
    for k, v in pairs(vehList) do
        local epos = GetEntityCoords(v)
        if Vdist4(vector3(pos.x, pos.y, pos.z), epos) < range then
            return v
        end
    end
    return false
end

function Shared.ClosestObject(maxDist)
    local vehList = GetGamePool("CObject")
    local dist = 1000
    local ped = PlayerPedId()
    local pos = GetEntityCoords(PlayerPedId())
    local closest
    for k, v in pairs(vehList) do
        local epos = GetEntityCoords(v)
        if Vdist4(pos, epos) < dist then
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

function Shared.IsAnyDoorOpen(veh)
    for i = 0, 5 do
        if DoesVehicleHaveDoor(veh, i) then
            if GetVehicleDoorAngleRatio(veh, i) > 0 then
                return true
            end
        end
    end

    return false
end

function Shared.SpawnObject(model, pos, noNetwork)
    if type(model) == "string" then
        model = GetHashKey(model)
    end

    if not IsModelValid(model) then
        return
    end

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end

    local obj = CreateObject(model, GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, -20.0), false, false, true)

    if not noNetwork then
        while not NetworkGetEntityIsNetworked(obj) do
            Wait(50)
            NetworkRegisterEntityAsNetworked(obj)
        end
        local netID = NetworkGetNetworkIdFromEntity(obj)
        NetworkSetNetworkIdDynamic(netID, false)
        SetNetworkIdCanMigrate(netID, true)
        SetNetworkIdExistsOnAllMachines(netID, true)
        SetEntityAsMissionEntity(obj, true)
    end
    if pos then
        SetEntityCoords(obj, pos)
    end
    PlaceObjectOnGroundProperly(obj)

    SetModelAsNoLongerNeeded(model)
    return obj
end

function Shared.SpawnVehicle(model, position, noNetwork)
    local x, y, z, w = table.unpack(position)
    position = vector4(x, y, z, (w or GetEntityHeading(PlayerPedId())))

    local strModel = model
    if type(model) == "string" then
        model = GetHashKey(model)
    end

    if not IsModelValid(model) then
        return
    end

    local time = GetGameTimer()
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end

    local networked = true
    if noNetwork then networked = false end
    local veh = CreateVehicle(model, position, networked, false)
    SetEntityHeading(veh, position.w or 0.0)

    SetVehicleDirtLevel(veh, 0.0)
    SetVehicleOnGroundProperly(veh)
    SetVehicleHasBeenOwnedByPlayer(veh, true)

    if not noNetwork then
        while not NetworkGetEntityIsNetworked(veh) do
            Wait(0)
            NetworkRegisterEntityAsNetworked(veh)
        end
        local netID = NetworkGetNetworkIdFromEntity(veh)
        SetNetworkIdExistsOnAllMachines(netID, true)
        SetNetworkIdCanMigrate(netID, true)
    end

    SetEntityAsMissionEntity(veh, true)
    SetEntityCoords(veh, position)
    SetEntityHeading(veh, position.w or 0.0)

    SetVehicleOnGroundProperly(veh)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetModelAsNoLongerNeeded(model)
    return veh
end

function Shared.SpawnPed(model, position, noNetwork)
    local strModel = model
    if type(model) == "string" then
        model = GetHashKey(model)
    end
    local time = GetGameTimer()

    if not IsModelValid(model) then
        return
    end

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end

    local veh = CreatePed(0, model, 0.0, 0.0, 1000.0, noNetwork == nil and true or false, false)

    if not noNetwork then
        while not NetworkGetEntityIsNetworked(veh) do
            Wait(50)
            NetworkRegisterEntityAsNetworked(veh)
        end
        local netID = NetworkGetNetworkIdFromEntity(veh)
        SetNetworkIdCanMigrate(netID, true)
        SetNetworkIdExistsOnAllMachines(netID, true)
        SetEntityAsMissionEntity(veh, true)
    end

    if position then
        local x, y, z, w = table.unpack(position)
        position = vector4(x, y, z, (w or GetEntityHeading(PlayerPedId())))
        SetEntityCoords(veh, position)
        SetEntityHeading(veh, position.w or 0.0)
    end

    SetModelAsNoLongerNeeded(model)
    return veh
end

function Shared.GetEntityControl(ent)
    local wait = 0
    NetworkRequestControlOfEntity(ent)
    while not NetworkHasControlOfEntity(ent) do
        Wait(0)
        wait = wait + 1
        if wait > 15 then
            break
        end
    end

    return NetworkHasControlOfEntity(ent)
end

function GetGuild(guildID)
    return exports["geo-guilds"]:GetGuildData(guildID)
end

-- Misc

function Shared.DisableWeapons()
    DisableControlAction(0, 37, true)
    DisableControlAction(0, 24, true)
    DisableControlAction(0, 25, true)
    DisableControlAction(0, 140, true)
    DisableControlAction(0, 257, true)
    DisableControlAction(0, 263, true)
    DisableControlAction(0, 264, true)
end

local notif = 0
function Shared.ShowNotification(text)
    TriggerEvent("Shared.Notif", text)
end

function Shared.WorldText(str, pos, str2)

    local factor1, factor
    local offset = 0
    factor1 = (string.len(str)) / 370
    if str2 then
        factor = (string.len(str2)) / 370
    end

    if factor then
        offset =  (factor + factor1) / 2 + 0.01
    end

    SetDrawOrigin(pos.x, pos.y, pos.z)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(str)
    DrawText(0 - offset, 0)
    DrawSprite('rect', 'rect', 0.0 - offset, 0.012, 0.019 + factor1, 0.034, 0.0, 53, 44, 53, 255)
    DrawSprite('rect', 'rect', 0.0 - offset, 0.012, 0.015 + factor1, 0.03, 0.0, 77, 64, 77, 255)
    --DrawRect(0, 0 + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 150)

    if str2 then
        SetDrawOrigin(pos.x, pos.y, pos.z)
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(str2)
        local calc = factor + factor1
        if calc < 0.03 then calc = 0.03 end
        calc = calc / 20
        DrawText(factor1 + 0.019 + (factor / 2) - offset, 0)
        DrawSprite('rect', 'rect', factor1 + 0.019 + (factor / 2) - offset, 0.012, 0.019 + factor, 0.034, 0.0, 53, 44, 53, 255)
        DrawSprite('rect', 'rect', factor1 + 0.019 + (factor / 2) - offset, 0.012, 0.015 + factor, 0.03, 0.0, 77, 64, 77, 255)
        ClearDrawOrigin()
    end
end

CreateThread(function()
    RequestStreamedTextureDict('rect')
end)

function Shared.InteractText(str)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(str)
    DrawText(0.5, 0.055)
    local factor = (string.len(str)) / 370
    DrawRect(0.5, 0.055 + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 75)
end

function Shared.DrawText(text, x, y, font, color, scale, center, shadow, alignRight, num1, num2)
    SetTextColour(color[1], color[2], color[3], color[4])
    SetTextFont(font)
    SetTextScale(scale, scale)

    if shadow then
        SetTextOutline()
    end

    if center then
        SetTextCentre(center)
    elseif alignRight then
        SetTextRightJustify(true)
        SetTextWrap(num1, num2)
    end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function Shared.SortAlphabet(input, output)
    local a = {}
    for n in pairs(input) do
        table.insert(a, n)
    end
    table.sort(a, output)
    local i = 0 -- iterator variable
    local iter = function()
        -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], input[a[i]]
        end
    end
    return iter
end

function Shared.Clamp(val, min, max)
    if val < min then
        return min
    elseif val > max then
        return max
    else
        return val
    end
end

function Shared.TimeSince(start)
    local time = GetGameTimer()
    return (time - start)
end

local _rates = {}

function RateLimit(id, time)
    if _rates[id] == nil then
        _rates[id] = 0
    end
    if Shared.TimeSince(_rates[id]) >= time then
        _rates[id] = GetGameTimer()
        return true
    end
    return false
end

function Shared.TrackBlip(pos, routeColor, sprite, blipColor)
    local blip = AddBlipForCoord(pos)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, routeColor)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, blipColor)
    return blip
end

local hashKey = _G.GetHashKey
function GetHashKey(hash)
    if hash == nil or type(hash) == "number" then
        return 0
    else
        return hashKey(hash)
    end
end

function Vdist3(vec1, vec2)
    return #(vec1 - vec2)
end

function Vdist4(vec1, vec2)
    local var = #(vec1 - vec2)
    return (var * var)
end

function TextDraw(str, x, y)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, 0.40)
    SetTextDropshadow(1, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(str)
    DrawText(x, y)
end

local bl = {
    ["playerConnecting"] = true
}

function Hash(str)
    if bl[str] then
        return str
    end

    if str:match("cfx") then
        return str
    end

    return tostring(GetHashKey(str .. "-geo"))
end

--[[ _G.Handler = AddEventHandler
AddEventHandler = function(str, ...)
    _G.Handler(Hash(str), ...)
end

_G.NetHandler = RegisterNetEvent
RegisterNetEvent = function(str)
    _G.NetHandler(Hash(str))
end

_G.ServerHandler = TriggerServerEvent
TriggerServerEvent = function(str, ...)
    _G.ServerHandler(Hash(str), ...)
end

_G.EventHandler = TriggerEvent
TriggerEvent = function(str, ...)
    _G.EventHandler(Hash(str), ...)
end ]]
RegisterCommand(
    "loc",
    function(source, args)
        local pos = GetEntityCoords(PlayerPedId())
        local head = GetEntityHeading(PlayerPedId())

        if args[1] == "1" then
            local ray = Shared.Raycast(100)
            local ent = ray.HitEntity
            pos = GetEntityRotation(ent)
            TriggerServerEvent("loc", json.encode({x = pos.x, y = pos.y, z = pos.z, w = string.format("%.2f", head)}))
        elseif args[1] == "2" then
            local ray = Shared.Raycast(100)
            local ent = ray.HitEntity
            pos = GetEntityCoords(ray.HitEntity)
            TriggerServerEvent("loc", json.encode({x = string.format("%.2f", pos.x), y = string.format("%.2f", pos.y), z = string.format("%.2f", pos.z), w = string.format("%.2f", head)}))
        elseif args[1] == "3" then
            local ray = Shared.Raycast(100)
            pos = ray.HitPosition
            TriggerServerEvent("loc", json.encode({x = string.format("%.2f", pos.x), y = string.format("%.2f", pos.y), z = string.format("%.2f", pos.z), w = string.format("%.2f", head)}))
        elseif args[1] == "5" then
            local ray = Shared.Raycast(100)
            local ent = ray.HitEntity
            pos = GetEntityCoords(ray.HitEntity)
            TriggerServerEvent("loc", json.encode({x = string.format("%.2f", pos.x), y = string.format("%.2f", pos.y), z = string.format("%.2f", pos.z), w =GetEntityModel(ent)}), args[1])
        elseif args[1] == nil then
            TriggerServerEvent("loc", json.encode({x = string.format("%.2f", pos.x), y = string.format("%.2f", pos.y), z = string.format("%.2f", pos.z), w = string.format("%.2f", head)}))
        else
            TriggerServerEvent("loc", json.encode({x = string.format("%.2f", pos.x), y = string.format("%.2f", pos.y), z = string.format("%.2f", pos.z), w = string.format("%.2f", head)}), args[1])
        end
    end
)

function Shared.TextInput(example, len)
    return exports["geo-shared"]:TextInput(example, len)
end

function GetUser()
    return exports["geo"]:GetUser()
end

function Shared.Confirm(example, len)
    return exports["geo-shared"]:SystemNotify(example, len)
end

function GetClosestPlayer(dist)
    if dist == nil then
        dist = 5.0
    end

    local me = PlayerPedId()
    local pos = GetEntityCoords(PlayerPedId())
    local closest = nil
    local nDist = 99999.0

    for k, v in pairs(GetActivePlayers()) do
        local ped = GetPlayerPed(v)
        if ped ~= me then
            local distance = Vdist4(pos, GetEntityCoords(ped))
            if distance <= nDist then
                closest = v
                nDist = distance
            end
        end
    end

    if nDist <= dist then
        return closest
    end
end

function HelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, 1)
end

AddEventHandler(
    "enteredVehicle",
    function(veh, seat)
        Shared.CurrentVehicle = veh
    end
)

AddEventHandler(
    "leftVehicle",
    function()
        SetVehicleUsePlayerLightSettings(Shared.CurrentVehicle, true)
        Shared.CurrentVehicle = 0
    end
)

function New(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[New(orig_key)] = New(orig_value)
        end
        setmetatable(copy, New(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function Update(type, data)
    exports["geo"]:UpdateCharacter(type, data)
end

function SetVehicleData(veh, data, plate)
    SetVehicleModKit(veh, 0)
    if plate then
        SetVehicleNumberPlateText(veh, plate)
    end
    local custom = {}
    local lData = json.decode(data)
    for k, v in pairs(lData) do
        if tonumber(k) ~= nil then
            k = tonumber(k)
        end
        custom[k] = v
    end
    SetVehicleWheelType(veh, custom.wheeltype)
    for i = 0, 49 do
        SetVehicleMod(veh, i, custom[i], false)
    end
    SetVehicleColours(veh, custom["paint"], custom["paint2"])

    if custom['paintCustom'] then
        SetVehicleCustomPrimaryColour(veh, table.unpack(custom['paintCustom']))
    else
        ClearVehicleCustomPrimaryColour(veh)
    end

    if custom['paint2Custom'] then
        SetVehicleCustomSecondaryColour(veh, table.unpack(custom['paint2Custom']))
    else
        ClearVehicleCustomSecondaryColour(veh)
    end

    SetVehicleExtraColours(veh, custom["pearl"], custom["wheelColor"])
    SetVehicleLivery(veh, custom["livery"])
    if type(custom.extras) == "table" then
        for k, v in pairs(custom.extras) do
            SetVehicleExtra(veh, tonumber(k), v)
        end
    end
    ToggleVehicleMod(veh, 18, custom.turbo)
    ToggleVehicleMod(veh, 22, custom.xenon)
    SetVehicleWindowTint(veh, custom.tint)
    SetVehicleNumberPlateTextIndex(veh, custom.plateType or 3)

    SetVehicleEngineHealth(veh, custom.enginehealth + 0.0)
    SetVehicleBodyHealth(veh, custom.bodyhealth + 0.0)
end

function GetPlate(veh)
    return (Entity(veh).state.plate) or GetVehicleNumberPlateText(veh)
end

function GetVehicleData(veh)
    local mData = {}
    local waitingForData = Promise("GetVehicleData", GetPlate(veh))
    --[[ TriggerServerEvent('FetchVehicleData', GetVehicleNumberPlateText(veh))
    while waitingForData == nil do
        Wait(0)
    end ]]
    SetVehicleModKit(veh, 0)

    if waitingForData == nil then
        for i = 0, 49 do
            mData[i] = GetVehicleMod(veh, i)
        end
        mData["tint"] = GetVehicleWindowTint(veh)
        mData["wheeltype"] = GetVehicleWheelType(veh)
        
        local prim, sec = GetVehicleColours(veh)
        local pearl, wheelColor = GetVehicleExtraColours(veh)
        local r, g, b = GetVehicleNeonLightsColour(veh)
        local primR, primG, primB = GetVehicleCustomPrimaryColour(veh)
        local secR, secG, secB = GetVehicleCustomSecondaryColour(veh)

        mData["paint"] = prim
        mData["paint2"] = sec

        mData["paintCustom"] = false
        mData["paint2Custom"] = false

        mData["pearl"] = pearl
        mData["wheelColor"] = wheelColor
        mData["enginehealth"] = 1000.0
        mData["bodyhealth"] = 1000.0
        mData["turbo"] = IsToggleModOn(veh, 18) == 1
        mData["xenon"] = IsToggleModOn(veh, 22) == 1
        mData["xeonColor"] = GetVehicleXenonLightsColour(veh)
        mData["extras"] = {}
        mData["plate"] = GetVehicleNumberPlateText(veh)
        mData["livery"] = GetVehicleLivery(veh)
        mData["plateType"] = GetVehicleNumberPlateTextIndex(veh)
        mData["neon"] = {r, g, b}
        mData["hasNeon"] = false
        for i = 1, 30 do
            if DoesExtraExist(veh, i) then
                local num = 1
                if IsVehicleExtraTurnedOn(veh, i) then
                    num = 0
                end
                mData["extras"][i] = num
            end
        end
    else
        mData = json.decode(waitingForData)
    end

    local nVar = {}

    for k, v in pairs(mData) do
        if tonumber(k) ~= nil then
            k = tonumber(k)
        end
        nVar[k] = v
    end

    local extras = {}
    for k, v in pairs(mData.extras) do
        extras[tonumber(k)] = v
    end
    nVar["extras"] = extras

    return nVar
end

function LoadAnim(dict)
    if DoesAnimDictExist(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(0)
        end
    end

    CreateThread(
        function()
            Wait(1000)
            RemoveAnimDict(dict)
        end
    )
end

function RegisterProximityMenu(id, data)
    while GetResourceState("geo-menu") ~= "started" do
        Wait(0)
    end
    Wait(100)

    exports["geo-menu"]:ProximityMenu(id, data)
end

function RegisterAction(id, data)
    CreateThread(
        function()
            while GetResourceState("geo-menu") ~= "started" do
                Wait(0)
            end
            Wait(100)

            exports["geo-menu"]:RegisterAction(id, data)
        end
    )
end

RegisterNetEvent("State.Get")
AddEventHandler(
    "State.Get",
    function(data, id, res)
        if GetCurrentResourceName() == res then
            funcID[id] = data
        end
    end
)

State.Get = function(_type, ident, stat)
    if _type == nil or ident == nil or stat == nil then
        return false
    end

    count = count + 1
    if count > 65536 then
        count = 1
    end

    funcID[count] = "null"
    local time = GetGameTimer()
    TriggerServerEvent("State.Get", GetCurrentResourceName(), _type, ident, stat, count)
    while funcID[count] == "null" do
        Wait(100)
        if Shared.TimeSince(time) > 2500 then
            error("[State] Took to long to find data")
        end
    end
    local var = New(funcID[count])
    funcID[count] = nil
    return var
end

function comma_value(amount)
    local formatted = amount
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if (k == 0) then
            break
        end
    end
    return formatted
end

local seed = 0
function Random(min, max)
    local time = GetGameTimer()
    if Shared.TimeSince(seed) > 1000 then
        seed = time
        math.randomseed(time)
    end
    if not max then
        max = min
        min = 1
    end
    return math.random() and math.random() and math.random(min, max)
end

function IsNearLocation(list, pos, dist)
    for k, v in pairs(list) do
        if Vdist4(v.xyz, pos.xyz) <= dist then
            return true
        end
    end
end

function Shared.GetLocation(np)
    local coords = GetEntityCoords(PlayerPedId())
    if np then
        coords = np
    end

    if MyCharacter.interiorpos then
        coords = MyCharacter.interiorpos
    end

    local street, cross = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    street = GetStreetNameFromHashKey(street)
    cross = GetStreetNameFromHashKey(cross)
    local str = street
    if cross ~= "" then
        str = str .. " / " .. cross
    end

    local zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))

    str = str .. " in " .. zone

    if MyCharacter.interior then
        str = str .. " inside a property"
    end

    return {location = str, position = coords, street = street, cross = cross, zone = zone, interior = MyCharacter.interiorpos ~= nil}
end

function PlateForString(str)
    local model = GetHashKey("burrito")
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
    local veh = CreateVehicle(model, 0.0, 0.0, 0.0, false, false)
    SetVehicleNumberPlateText(veh, str)
    local plate = GetVehicleNumberPlateText(veh)
    SetEntityAsMissionEntity(veh)
    DeleteEntity(veh)
    return plate
end

local random = math.random
function uuid()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return string.gsub(
        template,
        "[xy]",
        function(c)
            local v = (c == "x") and random(0, 0xf) or random(8, 0xb)
            return string.format("%x", v)
        end
    )
end

function uuidshort()
    local template = "xxxxxxxx"
    return string.gsub(
        template,
        "[xy]",
        function(c)
            local v = (c == "x") and random(0, 0xf) or random(8, 0xb)
            return string.format("%x", v)
        end
    )
end

function Warp(pos, head, veh)
    if not IsScreenFadedOut() then
        DoScreenFadeOut(500)
        while not IsScreenFadedOut() do
            Wait(0)
        end
    end

    local ped = PlayerPedId()
    if veh ~= nil and veh ~= 0 then
        if GetPedInVehicleSeat(veh, -1) == ped then
            SetEntityCoords(veh, pos)
            if head then
                SetEntityHeading(veh, head)
            end
            SetGameplayCamRelativeHeading(0.0)

            FreezeEntityPosition(veh, true)
            RequestCollisionAtCoord(pos)
            while not HasCollisionLoadedAroundEntity(veh) do
                Wait(0)
            end
            FreezeEntityPosition(veh, false)
            SetEntityCoords(veh, pos.x, pos.y, pos.z - GetEntityHeightAboveGround(veh))
            SetVehicleOnGroundProperly(veh)
            DoScreenFadeIn(500)
            return
        else
            return
        end
    end
    SetEntityCoords(ped, pos)
    if head then
        SetEntityHeading(ped, head)
    end
    SetGameplayCamRelativeHeading(0.0)

    FreezeEntityPosition(ped, true)
    RequestCollisionAtCoord(pos)
    while not HasCollisionLoadedAroundEntity(ped) do
        Wait(0)
    end
    Wait(500)
    FreezeEntityPosition(ped, false)
    SetEntityCoords(ped, pos.x, pos.y, pos.z - GetEntityHeightAboveGround(ped) + 1.0)
    DoScreenFadeIn(500)
end

function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function SetOwned(veh)
    DecorSetBool(veh, "Locks", true)
    DecorSetBool(veh, "PlayerOwned", true)
end

function Minigame(...)
    return exports["geo-shared"]:Minigame(...)
end

local foc
function UIFocus(...)
    local cont = {...}
    SetNuiFocusKeepInput(cont[4] or false)
    SetNuiFocus(...)
    foc = cont[1] == true and cont[2] == true
    local str = (not cont[4] and ("~INPUT_SELECT_WEAPON~ Close") or "" .. (cont[3] and (" " .. cont[3]) or ""))
    TriggerEvent("UIFocus", foc, str)

    local val = (MyUser and MyUser.data and MyUser.data.settings or {}).uihelp
    if val == nil or val == true then
        CreateThread(
            function()
                while foc do
                    Wait(0)
                    InvalidateIdleCam()
                    if not (cont[3] == "" and cont[4]) then
                        if str == Shared.HelpString then
                            HelpText(str)
                        end
                    end
                end
            end
        )
    end

    if cont[4] then
        CreateThread(function()
            Update('range', 1)
            while foc do
                DisableAllControlActions(0)
                EnableControlAction(0, 249, true)

                if cont[3] then
                    for i=30,34 do
                        EnableControlAction(0, i, true)
                    end
                end
                Wait(0)
            end
            Update('range', 0)
        end)
    end
    Wait(100)
end

AddEventHandler(
    "UIFocus",
    function(val, str)
        Shared.UI = val
        Shared.HelpString = str
    end
)

function GetUIFocus()
    return foc
end

function ShowHelp(text, n)
    BeginTextCommandDisplayHelp(text)
    EndTextCommandDisplayHelp(n or 0, false, true, -1)
end

function ShowFloatingHelp(text, pos, color)
    SetDrawOrigin(pos.x, pos.y, pos.z)
    SetFloatingHelpTextWorldPosition(1, pos)
    SetFloatingHelpTextStyle(1, 1, color, -1, 3, 0)
    ShowHelp(text, 2)
    ClearDrawOrigin()
end

function PedAction(ped, func)
    local prom = promise:new()
    CreateThread(
        function()
            if DoesEntityExist(ped) and NetworkGetEntityIsNetworked(ped) and Entity(ped).state.controlled ~= true and Shared.GetEntityControl(ped) then
                local active = false
                TriggerServerEvent("Ped.Control", PedToNet(ped), true)
                SetBlockingOfNonTemporaryEvents(ped, true)
                SetPedFleeAttributes(ped, 0, 0)

                CreateThread(
                    function()
                        while active do
                            Wair(500)
                            Shared.GetEntityControl(ped)
                        end
                    end
                )

                func()
                Wait(500)
                active = false
                TriggerServerEvent("Ped.Control", PedToNet(ped), false)
                ClearPedTasks(ped)
                SetBlockingOfNonTemporaryEvents(ped, false)
                prom:resolve(true)
            else
                prom:resolve(true)
            end
        end
    )
    return prom
end

function find(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return k
        end
    end
end

VehicleColors = {
    ["0"] = "Metallic Black",
    ["1"] = "Metallic Graphite Black",
    ["2"] = "Metallic Black Steal",
    ["3"] = "Metallic Dark Silver",
    ["4"] = "Metallic Silver",
    ["5"] = "Metallic Blue Silver",
    ["6"] = "Metallic Steel Gray",
    ["7"] = "Metallic Shadow Silver",
    ["8"] = "Metallic Stone Silver",
    ["9"] = "Metallic Midnight Silver",
    ["10"] = "Metallic Gun Metal",
    ["11"] = "Metallic Anthracite Grey",
    ["12"] = "Matte Black",
    ["13"] = "Matte Gray",
    ["14"] = "Matte Light Grey",
    ["15"] = "Util Black",
    ["16"] = "Util Black Poly",
    ["17"] = "Util Dark silver",
    ["18"] = "Util Silver",
    ["19"] = "Util Gun Metal",
    ["20"] = "Util Shadow Silver",
    ["21"] = "Worn Black",
    ["22"] = "Worn Graphite",
    ["23"] = "Worn Silver Grey",
    ["24"] = "Worn Silver",
    ["25"] = "Worn Blue Silver",
    ["26"] = "Worn Shadow Silver",
    ["27"] = "Metallic Red",
    ["28"] = "Metallic Torino Red",
    ["29"] = "Metallic Formula Red",
    ["30"] = "Metallic Blaze Red",
    ["31"] = "Metallic Graceful Red",
    ["32"] = "Metallic Garnet Red",
    ["33"] = "Metallic Desert Red",
    ["34"] = "Metallic Cabernet Red",
    ["35"] = "Metallic Candy Red",
    ["36"] = "Metallic Sunrise Orange",
    ["37"] = "Metallic Classic Gold",
    ["38"] = "Metallic Orange",
    ["39"] = "Matte Red",
    ["40"] = "Matte Dark Red",
    ["41"] = "Matte Orange",
    ["42"] = "Matte Yellow",
    ["43"] = "Util Red",
    ["44"] = "Util Bright Red",
    ["45"] = "Util Garnet Red",
    ["46"] = "Worn Red",
    ["47"] = "Worn Golden Red",
    ["48"] = "Worn Dark Red",
    ["49"] = "Metallic Dark Green",
    ["50"] = "Metallic Racing Green",
    ["51"] = "Metallic Sea Green",
    ["52"] = "Metallic Olive Green",
    ["53"] = "Metallic Green",
    ["54"] = "Metallic Gasoline Blue Green",
    ["55"] = "Matte Lime Green",
    ["56"] = "Util Dark Green",
    ["57"] = "Util Green",
    ["58"] = "Worn Dark Green",
    ["59"] = "Worn Green",
    ["60"] = "Worn Sea Wash",
    ["61"] = "Metallic Midnight Blue",
    ["62"] = "Metallic Dark Blue",
    ["63"] = "Metallic Saxony Blue",
    ["64"] = "Metallic Blue",
    ["65"] = "Metallic Mariner Blue",
    ["66"] = "Metallic Harbor Blue",
    ["67"] = "Metallic Diamond Blue",
    ["68"] = "Metallic Surf Blue",
    ["69"] = "Metallic Nautical Blue",
    ["70"] = "Metallic Bright Blue",
    ["71"] = "Metallic Purple Blue",
    ["72"] = "Metallic Spinnaker Blue",
    ["73"] = "Metallic Ultra Blue",
    ["74"] = "Metallic Bright Blue",
    ["75"] = "Util Dark Blue",
    ["76"] = "Util Midnight Blue",
    ["77"] = "Util Blue",
    ["78"] = "Util Sea Foam Blue",
    ["79"] = "Uil Lightning blue",
    ["80"] = "Util Maui Blue Poly",
    ["81"] = "Util Bright Blue",
    ["82"] = "Matte Dark Blue",
    ["83"] = "Matte Blue",
    ["84"] = "Matte Midnight Blue",
    ["85"] = "Worn Dark blue",
    ["86"] = "Worn Blue",
    ["87"] = "Worn Light blue",
    ["88"] = "Metallic Taxi Yellow",
    ["89"] = "Metallic Race Yellow",
    ["90"] = "Metallic Bronze",
    ["91"] = "Metallic Yellow Bird",
    ["92"] = "Metallic Lime",
    ["93"] = "Metallic Champagne",
    ["94"] = "Metallic Pueblo Beige",
    ["95"] = "Metallic Dark Ivory",
    ["96"] = "Metallic Choco Brown",
    ["97"] = "Metallic Golden Brown",
    ["98"] = "Metallic Light Brown",
    ["99"] = "Metallic Straw Beige",
    ["100"] = "Metallic Moss Brown",
    ["101"] = "Metallic Biston Brown",
    ["102"] = "Metallic Beechwood",
    ["103"] = "Metallic Dark Beechwood",
    ["104"] = "Metallic Choco Orange",
    ["105"] = "Metallic Beach Sand",
    ["106"] = "Metallic Sun Bleeched Sand",
    ["107"] = "Metallic Cream",
    ["108"] = "Util Brown",
    ["109"] = "Util Medium Brown",
    ["110"] = "Util Light Brown",
    ["111"] = "Metallic White",
    ["112"] = "Metallic Frost White",
    ["113"] = "Worn Honey Beige",
    ["114"] = "Worn Brown",
    ["115"] = "Worn Dark Brown",
    ["116"] = "Worn straw beige",
    ["117"] = "Brushed Steel",
    ["118"] = "Brushed Black steel",
    ["119"] = "Brushed Aluminium",
    ["120"] = "Chrome",
    ["121"] = "Worn Off White",
    ["122"] = "Util Off White",
    ["123"] = "Worn Orange",
    ["124"] = "Worn Light Orange",
    ["125"] = "Metallic Securicor Green",
    ["126"] = "Worn Taxi Yellow",
    ["127"] = "police car blue",
    ["128"] = "Matte Green",
    ["129"] = "Matte Brown",
    ["130"] = "Worn Orange",
    ["131"] = "Matte White",
    ["132"] = "Worn White",
    ["133"] = "Worn Olive Army Green",
    ["134"] = "Pure White",
    ["135"] = "Hot Pink",
    ["136"] = "Salmon pink",
    ["137"] = "Metallic Vermillion Pink",
    ["138"] = "Orange",
    ["139"] = "Green",
    ["140"] = "Blue",
    ["141"] = "Mettalic Black Blue",
    ["142"] = "Metallic Black Purple",
    ["143"] = "Metallic Black Red",
    ["144"] = "hunter green",
    ["145"] = "Metallic Purple",
    ["146"] = "Metaillic V Dark Blue",
    ["147"] = "MODSHOP BLACK1",
    ["148"] = "Matte Purple",
    ["149"] = "Matte Dark Purple",
    ["150"] = "Metallic Lava Red",
    ["151"] = "Matte Forest Green",
    ["152"] = "Matte Olive Drab",
    ["153"] = "Matte Desert Brown",
    ["154"] = "Matte Desert Tan",
    ["155"] = "Matte Foilage Green",
    ["156"] = "DEFAULT ALLOY COLOR",
    ["157"] = "Epsilon Blue",
    ["158"] = "Shit Brown",
    ["159"] = "Shiny Shit Brown",
    ["160"] = "Puke Yellow",
    ["161"] = ""
}

local promList = {}

function Promise(event, ...)
    local id = #promList + 1
    promList[id] = promise.new()
    TriggerServerEvent(event, GetCurrentResourceName(), id, ...)
    return Citizen.Await(promList[id])
end

RegisterNetEvent("ReturnPromise")
AddEventHandler(
    "ReturnPromise",
    function(res, id, data)
        if res == GetCurrentResourceName() then
            if promList[id] then
                promList[id]:resolve(data)
                promList[id] = nil
            end
        end
    end
)

VehicleClass = {
    Compact = 0,
    Sedan = 1,
    SUV = 2,
    Coupe = 3,
    Muscle = 4,
    SportsClassic = 5,
    Sports = 6,
    Super = 7,
    Motorcycle = 8,
    OffRoad = 9,
    Industrial = 10,
    Utility = 11,
    Van = 12,
    Cycle = 13,
    Boat = 14,
    Helicopter = 15,
    Plane = 16,
    Service = 17,
    Emergency = 18,
    Military = 19,
    Commcerical = 20,
    Trains = 21
}

function SplitString(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function GetName(char)
    local name = char.first

    if char.username then
        return char.username
    end

    if char.Title then
        name = char.Title .. " " .. char.last
    else
        name = name .. " " .. char.last
    end

    return name
end

function AddZone(coords, data, ignore)
    CreateThread(
        function()
            while GetResourceState("PolyZone") ~= "started" do
                Wait(500)
            end
            Wait(500)
            data.res = GetCurrentResourceName()
            exports["PolyZone"]:CreateZone(coords, data, ignore)
        end
    )
end

function AddCircleZone(coords, h, data, ignore)
    CreateThread(
        function()
            while GetResourceState("PolyZone") ~= "started" do
                Wait(500)
            end
            Wait(500)
            data.res = GetCurrentResourceName()
            exports["PolyZone"]:CreateCircleZone(coords, h, data, ignore)
        end
    )
end

function AddBoxZone(coords, x, y, data, ignore)
    CreateThread(
        function()
            while GetResourceState("PolyZone") ~= "started" do
                Wait(500)
            end
            Wait(500)
            data.res = GetCurrentResourceName()
            exports["PolyZone"]:CreateBoxZone(coords, x, y, data, ignore)
        end
    )
end

function ScreenToWorld(x, y)
    local camPos, camRot = GetGameplayCamCoord(), GetGameplayCamRot()
    local _cam = GetRenderingCam()
    if _cam ~= -1 then
        camPos, camRot = GetCamCoord(_cam), GetCamRot(_cam)
    end

    local coord = vec(x, y)
    local camForward = RotationToDirection(camRot)
    local rotUp = camRot + vec(1, 0, 0)
    local rotDown = camRot + vec(-1, 0, 0)
    local rotLeft = camRot + vec(0, 0, -1)
    local rotRight = camRot + vec(0, 0, 1)

    local camRight = RotationToDirection(rotRight) - RotationToDirection(rotLeft)
    local camUp = RotationToDirection(rotUp) - RotationToDirection(rotDown)

    local rollRad = -DegToRad(camRot.y)

    local camRightRoll = (camRight * math.cos(rollRad) - camUp * math.sin(rollRad)) + 0.0
    local camUpRoll = (camRight * math.sin(rollRad) + camUp * math.cos(rollRad)) + 0.0

    local point3D = camPos + camForward * 1.0 + camRightRoll + camUpRoll
    local point2D

    local found, _x, _y = GetScreenCoordFromWorldCoord(point3D.x, point3D.y, point3D.z)
    if not found then
        return camPos + camForward * 1.0, camForward
    end

    point2D = vec(_x, _y)
    local point3DZero = camPos + camForward * 1.0
    local found, _x, _y = GetScreenCoordFromWorldCoord(point3DZero.x, point3DZero.y, point3DZero.z)
    if not found then
        return camPos + camForward * 1.0, camForward
    end

    local point2DZero = vec(_x, _y)
    local eps = 0.001
    if (math.abs(point2D.x - point2DZero.x) < eps or math.abs(point2D.y - point2DZero.y) < eps) then
        return camPos + camForward * 1.0, camForward
    end

    local scaleX = (coord.x - point2DZero.x) / (point2D.x - point2DZero.x)
    local scaleY = (coord.y - point2DZero.y) / (point2D.y - point2DZero.y)
    local point3Dret = camPos + camForward * 1.0 + camRightRoll * scaleX + camUpRoll * scaleY
    local forwardDirection = camForward + camRightRoll * scaleX + camUpRoll * scaleY
    return point3Dret, forwardDirection
end

function DegToRad(deg)
    local Radian = (math.pi / 180) * deg
    return Radian + 0.0
end

function RotationToDirection(rot)
    local z = DegToRad(rot.z)
    local x = DegToRad(rot.x)
    local num = math.abs(math.cos(x))
    return vec((-math.sin(z) * num) + 0.0, (math.cos(z) * num) + 0.0, math.sin(x) + 0.0)
end

function GetPrice(amount)
    return amount + math.floor(amount * (taxRate) / 100)
end

local WEAPON_HASH_TO_LABEL = {
    [tostring(GetHashKey("WEAPON_UNARMED"))] = "WT_UNARMED",
    [tostring(GetHashKey("WEAPON_ANIMAL"))] = "WT_INVALID",
    [tostring(GetHashKey("WEAPON_COUGAR"))] = "WT_RAGE",
    [tostring(GetHashKey("WEAPON_KNIFE"))] = "WT_KNIFE",
    [tostring(GetHashKey("WEAPON_NIGHTSTICK"))] = "WT_NGTSTK",
    [tostring(GetHashKey("WEAPON_HAMMER"))] = "WT_HAMMER",
    [tostring(GetHashKey("WEAPON_BAT"))] = "WT_BAT",
    [tostring(GetHashKey("WEAPON_GOLFCLUB"))] = "WT_GOLFCLUB",
    [tostring(GetHashKey("WEAPON_CROWBAR"))] = "WT_CROWBAR",
    [tostring(GetHashKey("WEAPON_PISTOL"))] = "WT_PIST",
    [tostring(GetHashKey("WEAPON_COMBATPISTOL"))] = "WT_PIST_CBT",
    [tostring(GetHashKey("WEAPON_APPISTOL"))] = "WT_PIST_AP",
    [tostring(GetHashKey("WEAPON_PISTOL50"))] = "WT_PIST_50",
    [tostring(GetHashKey("WEAPON_MICROSMG"))] = "WT_SMG_MCR",
    [tostring(GetHashKey("WEAPON_SMG"))] = "WT_SMG",
    [tostring(GetHashKey("WEAPON_ASSAULTSMG"))] = "WT_SMG_ASL",
    [tostring(GetHashKey("WEAPON_ASSAULTRIFLE"))] = "WT_RIFLE_ASL",
    [tostring(GetHashKey("WEAPON_CARBINERIFLE"))] = "WT_RIFLE_CBN",
    [tostring(GetHashKey("WEAPON_ADVANCEDRIFLE"))] = "WT_RIFLE_ADV",
    [tostring(GetHashKey("WEAPON_MG"))] = "WT_MG",
    [tostring(GetHashKey("WEAPON_COMBATMG"))] = "WT_MG_CBT",
    [tostring(GetHashKey("WEAPON_PUMPSHOTGUN"))] = "WT_SG_PMP",
    [tostring(GetHashKey("WEAPON_SAWNOFFSHOTGUN"))] = "WT_SG_SOF",
    [tostring(GetHashKey("WEAPON_ASSAULTSHOTGUN"))] = "WT_SG_ASL",
    [tostring(GetHashKey("WEAPON_BULLPUPSHOTGUN"))] = "WT_SG_BLP",
    [tostring(GetHashKey("WEAPON_STUNGUN"))] = "WT_STUN",
    [tostring(GetHashKey("WEAPON_SNIPERRIFLE"))] = "WT_SNIP_RIF",
    [tostring(GetHashKey("WEAPON_HEAVYSNIPER"))] = "WT_SNIP_HVY",
    [tostring(GetHashKey("WEAPON_REMOTESNIPER"))] = "WT_SNIP_RMT",
    [tostring(GetHashKey("WEAPON_GRENADELAUNCHER"))] = "WT_GL",
    [tostring(GetHashKey("WEAPON_GRENADELAUNCHER_SMOKE"))] = "WT_GL_SMOKE",
    [tostring(GetHashKey("WEAPON_RPG"))] = "WT_RPG",
    [tostring(GetHashKey("WEAPON_PASSENGER_ROCKET"))] = "WT_INVALID",
    [tostring(GetHashKey("WEAPON_AIRSTRIKE_ROCKET"))] = "WT_INVALID",
    [tostring(GetHashKey("WEAPON_STINGER"))] = "WT_RPG",
    [tostring(GetHashKey("WEAPON_MINIGUN"))] = "WT_MINIGUN",
    [tostring(GetHashKey("WEAPON_GRENADE"))] = "WT_GNADE",
    [tostring(GetHashKey("WEAPON_STICKYBOMB"))] = "WT_GNADE_STK",
    [tostring(GetHashKey("WEAPON_SMOKEGRENADE"))] = "WT_GNADE_SMK",
    [tostring(GetHashKey("WEAPON_BZGAS"))] = "WT_BZGAS",
    [tostring(GetHashKey("WEAPON_MOLOTOV"))] = "WT_MOLOTOV",
    [tostring(GetHashKey("WEAPON_FIREEXTINGUISHER"))] = "WT_FIRE",
    [tostring(GetHashKey("WEAPON_PETROLCAN"))] = "WT_PETROL",
    [tostring(GetHashKey("WEAPON_DIGISCANNER"))] = "WT_DIGI",
    [tostring(GetHashKey("GADGET_NIGHTVISION"))] = "WT_NV",
    [tostring(GetHashKey("GADGET_PARACHUTE"))] = "WT_PARA",
    [tostring(GetHashKey("OBJECT"))] = "WT_OBJECT",
    [tostring(GetHashKey("WEAPON_BRIEFCASE"))] = "WT_INVALID",
    [tostring(GetHashKey("WEAPON_BRIEFCASE_02"))] = "WT_INVALID",
    [tostring(GetHashKey("WEAPON_BALL"))] = "WT_BALL",
    [tostring(GetHashKey("WEAPON_FLARE"))] = "WT_FLARE",
    [tostring(GetHashKey("WEAPON_ELECTRIC_FENCE"))] = "WT_ELCFEN",
    [tostring(GetHashKey("VEHICLE_WEAPON_TANK"))] = "WT_V_TANK",
    [tostring(GetHashKey("VEHICLE_WEAPON_SPACE_ROCKET"))] = "WT_V_SPACERKT",
    [tostring(GetHashKey("VEHICLE_WEAPON_PLAYER_LASER"))] = "WT_V_PLRLSR",
    [tostring(GetHashKey("AMMO_RPG"))] = "WT_A_RPG",
    [tostring(GetHashKey("AMMO_TANK"))] = "WT_A_TANK",
    [tostring(GetHashKey("AMMO_SPACE_ROCKET"))] = "WT_A_SPACERKT",
    [tostring(GetHashKey("AMMO_PLAYER_LASER"))] = "WT_A_PLRLSR",
    [tostring(GetHashKey("AMMO_ENEMY_LASER"))] = "WT_A_ENMYLSR",
    [tostring(GetHashKey("WEAPON_RAMMED_BY_CAR"))] = "WT_PIST",
    [tostring(GetHashKey("WEAPON_BOTTLE"))] = "WT_BOTTLE",
    [tostring(GetHashKey("WEAPON_GUSENBERG"))] = "WT_GUSENBERG",
    [tostring(GetHashKey("WEAPON_SNSPISTOL"))] = "WT_SNSPISTOL",
    [tostring(GetHashKey("WEAPON_VINTAGEPISTOL"))] = "WT_VPISTOL",
    [tostring(GetHashKey("WEAPON_DAGGER"))] = "WT_DAGGER",
    [tostring(GetHashKey("WEAPON_FLAREGUN"))] = "WT_FLAREGUN",
    [tostring(GetHashKey("WEAPON_HEAVYPISTOL"))] = "WT_HEAVYPSTL",
    [tostring(GetHashKey("WEAPON_SPECIALCARBINE"))] = "WT_RIFLE_SCBN",
    [tostring(GetHashKey("WEAPON_MUSKET"))] = "WT_MUSKET",
    [tostring(GetHashKey("WEAPON_FIREWORK"))] = "WT_FWRKLNCHR",
    [tostring(GetHashKey("WEAPON_MARKSMANRIFLE"))] = "WT_MKRIFLE",
    [tostring(GetHashKey("WEAPON_HEAVYSHOTGUN"))] = "WT_HVYSHOT",
    [tostring(GetHashKey("WEAPON_PROXMINE"))] = "WT_PRXMINE",
    [tostring(GetHashKey("WEAPON_HOMINGLAUNCHER"))] = "WT_HOMLNCH",
    [tostring(GetHashKey("WEAPON_HATCHET"))] = "WT_HATCHET",
    [tostring(GetHashKey("WEAPON_COMBATPDW"))] = "WT_COMBATPDW",
    [tostring(GetHashKey("WEAPON_KNUCKLE"))] = "WT_KNUCKLE",
    [tostring(GetHashKey("WEAPON_MARKSMANPISTOL"))] = "WT_MKPISTOL",
    [tostring(GetHashKey("WEAPON_MACHETE"))] = "WT_MACHETE",
    [tostring(GetHashKey("WEAPON_MACHINEPISTOL"))] = "WT_MCHPIST",
    [tostring(GetHashKey("WEAPON_FLASHLIGHT"))] = "WT_FLASHLIGHT",
    [tostring(GetHashKey("WEAPON_DBSHOTGUN"))] = "WT_DBSHGN",
    [tostring(GetHashKey("WEAPON_COMPACTRIFLE"))] = "WT_CMPRIFLE",
    [tostring(GetHashKey("WEAPON_SWITCHBLADE"))] = "WT_SWBLADE",
    [tostring(GetHashKey("WEAPON_REVOLVER"))] = "WT_REVOLVER",
    [tostring(GetHashKey("WEAPON_FIRE"))] = "WT_INVALID",
    [tostring(GetHashKey("WEAPON_HELI_CRASH"))] = "WT_INVALID",
    [tostring(GetHashKey("WEAPON_RUN_OVER_BY_CAR"))] = "WT_INVALID",
    [tostring(GetHashKey("WEAPON_HIT_BY_WATER_CANNON"))] = "WT_INVALID",
    [tostring(GetHashKey("WEAPON_EXHAUSTION"))] = "WT_INVALID",
    [tostring(GetHashKey("WEAPON_FALL"))] = "WT_INVALID",
    [tostring(GetHashKey("WEAPON_EXPLOSION"))] = "WT_INVALID",
    [tostring(GetHashKey("WEAPON_BLEEDING"))] = "WT_INVALID",
    [tostring(GetHashKey("WEAPON_DROWNING_IN_VEHICLE"))] = "WT_INVALID",
    [tostring(GetHashKey("WEAPON_DROWNING"))] = "WT_INVALID",
    [tostring(GetHashKey("WEAPON_BARBED_WIRE"))] = "WT_INVALID",
    [tostring(GetHashKey("WEAPON_VEHICLE_ROCKET"))] = "WT_INVALID",
    [tostring(GetHashKey("WEAPON_SNSPISTOL_MK2"))] = "WT_SNSPISTOL2",
    [tostring(GetHashKey("WEAPON_REVOLVER_MK2"))] = "WT_REVOLVER2",
    [tostring(GetHashKey("WEAPON_DOUBLEACTION"))] = "WT_REV_DA",
    [tostring(GetHashKey("WEAPON_SPECIALCARBINE_MK2"))] = "WT_SPCARBINE2",
    [tostring(GetHashKey("WEAPON_BULLPUPRIFLE_MK2"))] = "WT_BULLRIFLE2",
    [tostring(GetHashKey("WEAPON_PUMPSHOTGUN_MK2"))] = "WT_SG_PMP2",
    [tostring(GetHashKey("WEAPON_MARKSMANRIFLE_MK2"))] = "WT_MKRIFLE2",
    [tostring(GetHashKey("WEAPON_POOLCUE"))] = "WT_POOLCUE",
    [tostring(GetHashKey("WEAPON_WRENCH"))] = "WT_WRENCH",
    [tostring(GetHashKey("WEAPON_BATTLEAXE"))] = "WT_BATTLEAXE",
    [tostring(GetHashKey("WEAPON_MINISMG"))] = "WT_MINISMG",
    [tostring(GetHashKey("WEAPON_BULLPUPRIFLE"))] = "WT_BULLRIFLE",
    [tostring(GetHashKey("WEAPON_AUTOSHOTGUN"))] = "WT_AUTOSHGN",
    [tostring(GetHashKey("WEAPON_RAILGUN"))] = "WT_RAILGUN",
    [tostring(GetHashKey("WEAPON_COMPACTLAUNCHER"))] = "WT_CMPGL",
    [tostring(GetHashKey("WEAPON_SNOWBALL"))] = "WT_SNWBALL",
    [tostring(GetHashKey("WEAPON_PIPEBOMB"))] = "WT_PIPEBOMB",
    [tostring(GetHashKey("WEAPON_PISTOL_MK2"))] = "WT_PIST2",
    [tostring(GetHashKey("WEAPON_SMG_MK2"))] = "WT_SMG2",
    [tostring(GetHashKey("WEAPON_COMBATMG_MK2"))] = "WT_MG_CBT2",
    [tostring(GetHashKey("WEAPON_ASSAULTRIFLE_MK2"))] = "WT_RIFLE_ASL2",
    [tostring(GetHashKey("WEAPON_CARBINERIFLE_MK2"))] = "WT_RIFLE_CBN2",
    [tostring(GetHashKey("WEAPON_HEAVYSNIPER_MK2"))] = "WT_SNIP_HVY2",
    [tostring(GetHashKey("GADGET_NIGHTVISION"))] = "WT_NV",
    [tostring(GetHashKey("GADGET_PARACHUTE"))] = "WT_PARA",
    [tostring(GetHashKey("WEAPON_STONE_HATCHET"))] = "WT_SHATCHET"
}
function GetWeaponLabel(hash)
    if (type(hash) ~= "string") then
        hash = tostring(hash)
    end

    local label = WEAPON_HASH_TO_LABEL[hash]
    if label ~= nil then
        return label
    end

    Citizen.Trace('Error reversing weapon hash "' .. hash .. '". Maybe it\'s not been added yet?')
    return "WT_INVALID" -- Return the invalid label
end

function GetHeadBlendData()
    return Citizen.InvokeNative(0x2746BD9D88C5C5D0, PlayerPedId(), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueFloatInitialized(0), Citizen.PointerValueFloatInitialized(0), Citizen.PointerValueFloatInitialized(0))
end

local _key = RegisterKeyMapping
function RegisterKeyMapping(command, name, input, key)
    CreateThread(
        function()
            Wait(500)
            local item = json.decode(GlobalState.commandinfo)
            item[command] = name
            GlobalState.commandinfo = json.encode(item)
            TriggerEvent("MapKey", command, name, input, key)
        end
    )
end

if GetCurrentResourceName() == "geo-shared" then
    AddEventHandler(
        "MapKey",
        function(command, name, input, key)
            _key(command, name .. " ~", input, key)
        end
    )
end

function GlobalNUI(message)
    TriggerEvent("GlobalNUI", message)
end

AddEventHandler(
    "GlobalNUI",
    function(message)
        SendNUIMessage(message)
    end
)

local _messageCache = {}
function Shared.Interact(message, time, allowed)
    for k, v in pairs(_messageCache) do
        if v == message then
            return
        end
    end

    local id = exports["geo-shared"]:Interact(message, allowed)

    _messageCache[id] = message

    if tonumber(time) then
        Wait(time)
        exports["geo-shared"]:CloseInteract(id)
        _messageCache[id] = nil
    end

    return {
        id = id,
        stop = function()
            if _messageCache[id] then
                exports["geo-shared"]:CloseInteract(id)
                _messageCache[id] = nil
            end
        end,
        update = function(pMessage)
            if _messageCache[id] == pMessage then
                return
            end
            _messageCache[id] = pMessage
            exports["geo-shared"]:UpdateInteract(id, pMessage)
        end
    }
end

function Shared.Confirm2(message)
    return exports["geo-shared"]:Confirmation(message)
end

function RunMenu(menu)
    exports["geo-interface"]:InterfaceMessage(
        {
            interface = "OptionSelector",
            menu = menu
        },
        true
    )
end

local male = GetHashKey("mp_m_freemode_01")
local female = GetHashKey("mp_f_freemode_01")
function FreemodePed(ped)
    local model = GetEntityModel(ped)

    if model == male or model == female then
        return true
    end

    return false
end

local DrawableClothes = {}
local TextureClothes = {}
local PalleteClothes = {}
local FaceFeature = {}

local DrawableProp = {}
local TextureProp = {}

local HeadOverlayDraw = {}
local HeadOverlayTexture = {}
local HeadOverlayOpacity = {}

local hairColor = 0
local hairHighlight = 0

local eyeColor = 0

function GetClothing(OutfitName, id)
    local ped = PlayerPedId()
    for i = 0, 11 do
        DrawableClothes[i] = GetPedDrawableVariation(ped, i)
        TextureClothes[i] = GetPedTextureVariation(ped, i)
        PalleteClothes[i] = GetPedPaletteVariation(ped, i)
    end

    for i = 0, 7 do
        DrawableProp[i] = GetPedPropIndex(ped, i)
        TextureProp[i] = GetPedPropTextureIndex(ped, i)
    end

    for i = 0, 19 do
        FaceFeature[i] = GetPedFaceFeature(ped, i)
    end

    for i = 0, 12 do
        local found, ovly, cType, fColor, SCOLOR, opac = GetPedHeadOverlayData(PlayerPedId(), i)
        HeadOverlayDraw[i] = GetPedHeadOverlayValue(ped, i)

        if HeadOverlayDraw[i] == 255 then
            HeadOverlayDraw[i] = -1
        end

        HeadOverlayTexture[i] = fColor
        HeadOverlayOpacity[i] = opac
    end

    hairColor = GetPedHairColor(ped)
    hairHighlight = GetPedHairHighlightColor(ped)

    eyeColor = GetPedEyeColor(ped)
    --[[ local val = exports['hbw']:GetHeadBlendData(ped)
    local blend = {val.FirstFaceShape, val.SecondFaceShape, val.ThirdFaceShape, val.FirstSkinTone, val.SecondSkinTone, val.ThirdSkinTone, val.ParentFaceShapePercent, val.ParentSkinTonePercent, val.ParentThirdUnkPercent, val.IsParentInheritance} ]]
    local blend = {GetHeadBlendData()}
    MiscClothing = {}
    if FreemodePed(ped) then
        MiscClothing = {
            Clothing = {
                Drawable = DrawableClothes,
                Texture = TextureClothes
            },
            Props = {
                Drawable = DrawableProp,
                Texture = TextureProp
            },
            Overlay = {
                Drawable = HeadOverlayDraw,
                Texture = HeadOverlayTexture,
                Opacity = HeadOverlayOpacity
            },
            FaceData = blend,
            FaceShape = FaceFeature,
            HairColor = hairColor,
            EyeColor = eyeColor,
            Name = OutfitName or "Unset",
            Model = GetEntityModel(ped),
            HairHighlight = hairHighlight,
            ID = id or -1
        }
    else
        MiscClothing = {
            Clothing = {
                Drawable = DrawableClothes,
                Texture = TextureClothes
            },
            Props = {
                Drawable = DrawableProp,
                Texture = TextureProp
            },
            Name = OutfitName or "Unset",
            Model = GetEntityModel(ped),
            ID = id or -1
        }
    end

    local val = json.decode(json.encode(MiscClothing))
    return val
end

function ControlModCheck(raw)
    local continue = true
    if controlMod then
        continue = false
    end

    if exports['geo-interface']:IsPhoneOpen() and raw:match('voice') == nil then
        return false
    end

    if controlMod and MyUser.data.settings and MyUser.data.settings.commands then
        for k, v in pairs(MyUser.data.settings.commands) do
            if raw:match(k) then
                continue = not v
                break
            end
        end
    end

    return continue
end

Levels = {
    [1] = 0,
    [2] = 300,
    [3] = 600,
    [4] = 1100,
    [5] = 1600,
    [6] = 2300,
    [7] = 3200,
    [8] = 4200,
    [9] = 5500,
    [10] = 7100,
    [11] = 9000,
    [12] = 11300,
    [13] = 14100,
    [14] = 17600,
    [15] = 21700,
    [16] = 26800,
    [17] = 32900,
    [18] = 40200,
    [19] = 49100,
    [20] = 59700,
    [21] = 72500,
    [22] = 87900,
    [23] = 106200,
    [24] = 128100,
    [25] = 154300,
    [26] = 185400,
    [27] = 222400,
    [28] = 266300,
    [29] = 318400,
    [30] = 379900,
    [31] = 452600,
    [32] = 538200,
    [33] = 639000,
    [34] = 757500,
    [35] = 896300,
    [36] = 1058900,
    [37] = 1248900,
    [38] = 1470600,
    [39] = 1728800,
    [40] = 2029100,
    [41] = 2377600,
    [42] = 2781400,
    [43] = 3248500,
    [44] = 3787900,
    [45] = 4409800,
    [46] = 5125300,
    [47] = 5947300,
    [48] = 6889900,
    [49] = 7969000,
    [50] = 9202100,
    [51] = 10608700,
    [52] = 12210500,
    [53] = 14031400,
    [54] = 16097700,
    [55] = 18438200,
    [56] = 21084700,
    [57] = 24072000,
    [58] = 27438000,
    [59] = 31223800,
    [60] = 35474400,
    [61] = 40238200,
    [62] = 45567700,
    [63] = 51519400,
    [64] = 58154100,
    [65] = 65536800,
    [66] = 73737200,
    [67] = 82829300,
    [68] = 92892100,
    [69] = 104008900,
    [70] = 116268000,
    [71] = 129762200,
    [72] = 144588900,
    [73] = 160850100,
    [74] = 178652100,
    [75] = 198105200,
    [76] = 219323600,
    [77] = 242425300,
    [78] = 267530900,
    [79] = 294764300,
    [80] = 324251200,
    [81] = 356119200,
    [82] = 390496800,
    [83] = 427512900,
    [84] = 467296000,
    [85] = 509973200,
    [86] = 555669900,
    [87] = 604508200,
    [88] = 656606500,
    [89] = 712078200,
    [90] = 771030600,
    [91] = 833564500,
    [92] = 899772200,
    [93] = 969737200,
    [94] = 1043532800,
    [95] = 1121221100,
    [96] = 1202852100,
    [97] = 1288462500,
    [98] = 1378075300,
    [99] = 1471698300,
    [100] = 1569323600,
}