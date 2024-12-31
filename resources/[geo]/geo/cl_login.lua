Character = nil
MyCharacter = nil
User = {}
local cList = nil
local pedList = {}

local models = {'Male', 'Female', 'MP', 'Freemode'}
local mbl = {Models = true, Clothing = true}
local dob

Menu.CreateMenu('Login', 'Login')
Menu.CreateMenu('Models', 'Models')
Menu.CreateMenu('Clothing', 'Clothing')

local ind = {}
local l = {'Login', 'Delete'}
local sex = {'Male', 'Female'}

local peLoc = {
    vector3(-235.75, -2003.982, 24.69),
    vector3(-236.7159, -2003.723, 24.69),
    vector3(-234.7841, -2004.241, 24.69),
    vector3(-237.6819, -2003.464, 24.69),
    vector3(-233.8181, -2004.5, 24.69),
}

function Login()
    exports['geo-hud']:Render(false)

    DoScreenFadeOut(250)
    Wait(250)

    exports["spawnmanager"]:spawnPlayer()

    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    SetCamCoord(cam, vector3(-234.3451, -1998.153, 25.24519))
    SetCamRot(cam, vector3(-7.086481, -3.201651e-07, 166.5541))
    RenderScriptCams(1, 0, 0, 1, 1)
    SetEntityCoords(PlayerPedId(), peLoc[1] - vec(0, 0 , 20.0))
    FreezeEntityPosition(PlayerPedId(), true)
    TriggerServerEvent('Characters.Download')
end

Citizen.CreateThread(Login)

RegisterNetEvent('Characters.Download')
AddEventHandler('Characters.Download', function(list, user, time)

    for k,v in pairs(pedList) do
        DeleteEntity(v.ped)
    end

    cList = list

    pedList = {}
    local mth = 0
    SetFocusPosAndVel(peLoc[1], 0.0, 0.0, 0.0)

    CreateThread(function()
        if not Task.Run('CheckDiscord') then
            exports['geo-interface']:Discord()
        end
    end)
  
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()

    Wait(500)
    for i = 1, 5 do
        local v = cList[i]
        local loc = peLoc[i]
        local ped
        if v then
            local clothing = json.decode(v.clothing)
            ped = Shared.SpawnPed(clothing.Model, loc, true)
            LoadClothing(clothing, ped)
        else
            ped = Shared.SpawnPed('mp_m_freemode_01', loc, true)
            SetPedDefaultComponentVariation(ped)
            SetEntityAlpha(ped, 150, false)
        end
       
        SetEntityCoords(ped, loc.x, loc.y, 25.0)
        local pos = GetEntityCoords(ped)
        SetEntityCoords(ped, pos.x, pos.y, pos.z - GetEntityHeightAboveGround(ped))
        SetEntityHeading(ped, 345.0)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        table.insert(pedList, {
            ped = ped,
            cid = v and v.id or 'none',
            data = v or 'none'
        })
        mth = mth + 1

        CreateThread(function()
            if v and user.data.work and user.data.work[1] == v.id and time < user.data.work[3] then
                pedList[i].ped = 99999
                LoadAnim('move_weapon@jerrycan@generic')
                TaskPlayAnim(ped, 'move_weapon@jerrycan@generic', 'idle', 1.0, 1.0, -1, 51, 1.0, 0, 0, 0)
                local obj = Shared.SpawnObject('prop_ld_case_01', vec(0, 0, 0), true)
                AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, 57005),  0.12,
                0.0,
                0.0,
                0.0,
                255.0,
                80.0, true, true, false, true, 1, true)
                Wait(1000)
    
                FreezeEntityPosition(ped, false)
                TaskGoToCoordAnyMeans(ped, vector3(-226.64, -2005.93, 24.68), 1.30, 0, 0, 786603, 1.0)
            end
        end)

        if v and user.data.work and user.data.work[1] == v.id and time < user.data.work[3] then
            pedList[i].ped = 99999
        end
    end

    exports['geo-interface']:CharacterSelect(pedList)
    Wait(500)
    DoScreenFadeIn(1000)
end)

local Months = {}
Months[1] = 31
Months[2] = 28
Months[3] = 31
Months[4] = 30
Months[5] = 31
Months[6] = 30
Months[7] = 31
Months[8] = 31
Months[9] = 30
Months[10] = 31
Months[11] = 30
Months[12] = 31
function DOBCheck(pDob)
    if pDob == nil then
        return ''
    end
	local newDOB = {}
	local count = 0
	for w in pDob:gmatch("([^/]+),?") do
		table.insert(newDOB, w)
    end

    if pDob == dob then
        return dob
    end

    if tonumber(newDOB[1]) ~= nil and tonumber(newDOB[2]) ~= nil and tonumber(newDOB[3]) ~= nil then
        if tonumber(newDOB[1]) > 12 or tonumber(newDOB[1]) < 1 or tonumber(newDOB[2]) > 31 or tonumber(newDOB[2]) < 1 or tonumber(newDOB[3]) > 2001 or tonumber(newDOB[3]) < 1920 or (tonumber(newDOB[2]) > Months[tonumber(newDOB[1])]) then
            TriggerEvent('Shared.Notif', 'Invalid DOB')
        else
            for k,v in pairs(newDOB) do
                newDOB[k] = tonumber(v)
            end
            return (math.floor(newDOB[1]).."/"..math.floor(newDOB[2]).."/"..math.floor(newDOB[3]))
        end
    else
        TriggerEvent('Shared.Notif', 'Invalid DOB')
    end
end

function NameCheck(name)
    if name == nil then
        TriggerEvent('Shared.Notif', 'Invalid Name')
        return ''
    end
	local newName = {}
	for w in name:gmatch("([^ ]+),?") do
		table.insert(newName, w)
		return (newName[1]:gsub("^%l", string.upper))
	end
end



function CreateCharacter()
    newCharacter = true
    local ped = PlayerPedId()
    FreezeEntityPosition(PlayerPedId(), false)
    local first = ''
    local last = ''
    dob = ''
    local search = ''
    local mySex = 1


    DestroyCam(cam)
    RenderScriptCams(0, 0, 1, 1, 1)
    SetFocusEntity(ped)
    SetEntityCoords(ped, vector3(-1042.94, -2746.26, 22.84))
    SetEntityHeading(ped, 166.86)
    local sIndex = 1
    while Character == nil do
        Wait(0)

        if Menu.CurrentMenu ~= 'Login' then
            if not mbl[Menu.CurrentMenu] then
                Menu.CurrentMenu = 'Login'
            end
        end
        
        if Menu.CurrentMenu == 'Login' then
            if Menu.Button('First Name:', first) then
                first, last, dob = table.unpack(PersonalInfo(first, last, dob))
            end

            if Menu.Button('Last Name:', last) then
                first, last, dob = table.unpack(PersonalInfo(first, last, dob))
            end

            if Menu.Button('Date of Birth:', dob) then
                 first, last, dob = table.unpack(PersonalInfo(first, last, dob))
             end

            Menu.ComboBox('Sex', sex, mySex, function(current)
                if current ~= mySex then
                    mySex = current
                end
            end)

            if Menu.Button('Models') then
                Menu.CurrentMenu = 'Models'
            end

            if Menu.Button('Customize') then
                Menu.CurrentMenu = nil
                ClothingMenu()
            end

            if Menu.Button('Finalize Character') then
                if first ~= '' and last ~= '' and dob ~= '' and MiscClothing ~= nil then
                    TriggerServerEvent('Character.Finish', first, last, dob, MiscClothing, sex[mySex])
                    Wait(2000)
                end
            end

            if Menu.ActiveOption == 3 then
                Menu.Extra({{'Format: M/D/Y'}})
            end

        elseif Menu.CurrentMenu == 'Models' then
            
            if Menu.Button('Search: ', search) then
                search = Shared.TextInput('Search')
            end

            Menu.Slider(models[sIndex], models, sIndex, function(current)
                if sIndex ~= current then
                    sIndex = current
                end
            end)


            for k,v in pairs(List[models[sIndex]]) do
                if v:match(search) then
                    if Menu.Button(v) then
                        SetModel(v)
                    end
                end
            end
        end
        Menu.Display()
    end
end

function PersonalInfo(first, last, pDob)
    local val = exports['geo-shared']:Dialogue({
        {
            placeholder = 'First Name',
            value = first,
            title = 'Personal Info',
            image = 'person'
        },
        {
            placeholder = 'Last Name',
            value = last,
            image = 'person'
        },
        {
            placeholder = 'Date of Birth',
            value = pDob,
            image = 'person'
        }
    })

    if val then
        val[1] = NameCheck(val[1])
        val[2] = NameCheck(val[2])
        val[3] = DOBCheck(val[3])
    end

    return val and val or {first, last, pDob}
end

RegisterNetEvent('SetCharacter')
AddEventHandler('SetCharacter', function(char, user)
    Character = char
    MyCharacter = char
    User = user
    exports['geo-hud']:Render(true)
    TriggerEvent('Login', Character, User)
    Wait(1000)
    TriggerServerEvent('Bank:Create')
end)

RegisterNetEvent('Character.Select')
AddEventHandler('Character.Select', function(char, user, method)
    Character = char
    MyCharacter = char
    User = user
    local clothing = json.decode(Character.clothing)
    LoadClothing(clothing)
    local ped = PlayerPedId()
    exports['geo-hud']:Render(true)

    if method == 'wakeup_in_apartment' then
        DoScreenFadeOut(250)
        Wait(250)
        TriggerServerEvent('Apartment.Login')
    elseif method == 'wakeup_last_location' then
        local pos = json.decode(Character.pos)
        if pos[1] ~= nil then
            SetEntityCoords(ped, pos[1], pos[2], pos[3])
            RequestCollisionAtCoord(pos[1], pos[2], pos[3])
            FreezeEntityPosition(ped, true)
            SetEntityHeading(ped, 166.86)
            TriggerServerEvent('Apartment.Login', true)
        else
            Wait(1000)
            TriggerServerEvent('Bank:Create')
        end
    elseif method == 'jail' then
        TriggerServerEvent('Jail.Login')
        TriggerServerEvent('Apartment.Login', true)
        Wait(1000)
    end

    SetEntityVisible(PlayerPedId(), true)
    DestroyCam(cam)
    TriggerEvent('Login', Character, User)
    RenderScriptCams(0, 1, 1000, 1, 1)
    Wait(1000)
    FreezeEntityPosition(PlayerPedId(), false)
    SetFocusEntity(ped)
end)

AddEventHandler('Login', function()
    SetEntityMaxHealth(PlayerPedId(), 200)
    SetEntityHealth(PlayerPedId(), 200)
    SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
    SetPedSuffersCriticalHits(PlayerPedId(), false)
    TriggerEvent('Holster:PauseFor', 5000)
    TriggerServerEvent('Inventory:FetchMe')

    for k,v in pairs(pedList) do
        SetEntityAsNoLongerNeeded(v.ped)
    end
end)

RegisterNetEvent('Character.Update')
AddEventHandler('Character.Update', function(type, data)
    Character[type] = data
    MyCharacter = Character

    TriggerEvent('Login:Ret', Character, User, type, data)
end)

RegisterNetEvent('User.Update')
AddEventHandler('User.Update', function(type, data)
    User[type] = data
    MyCharacter = Character

    TriggerEvent('Login:Ret', Character, User, type, data)
end)


RegisterNetEvent('Logout')
AddEventHandler('Logout', function()
    Character = nil
    MyCharacter = nil
    TriggerEvent('Logout2')
    Login()
end)

AddEventHandler('Login:Info', function(callback)
	callback((Character), (User))
end)

function UpdateCharacter(type, data)
    TriggerServerEvent('UpdateCharacter', type, data)
end

exports('UpdateCharacter', UpdateCharacter)
exports('GetUser', function()
    return User
end)

exports('CreateCharacter', CreateCharacter)

SetDiscordAppId(784551292235677717)
SetDiscordRichPresenceAsset("gdx")
SetDiscordRichPresenceAssetText('GeoDexon')

SetDiscordRichPresenceAction(0, 'Join Server', 'fivem://connect/rp.geodexon.net')
SetDiscordRichPresenceAction(1, 'Join Discord', 'https://discord.gg/dsPDHEcWkX')

AddBoxZone(vector3(-1035.01, -2732.88, 20.17), 10.6, 3.0, {
    name="school",
    heading=240,
    --debugPoly=true
})

local inside = false
AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'school' and newCharacter then
        inside = inZone
        if inside then
            local _int
            while inside do
                Wait(500)
                _int = Shared.Interact('[E] Take the Magic School Bus') or _int
            end

            if _int then _int.stop() end
        end
    end
end)

AddEventHandler('Interact', function()
    if inside then
        newCharacter = false
        Task.Run('MagicSchoolBus')
        inside = false
        exports['geo-hud']:Render(false)
        local ped = Shared.SpawnPed('s_m_m_gardener_01', vec(-1080.54, -2694.73, 20.08))
        local veh = Shared.SpawnVehicle('bus', vector4(-1080.54, -2694.73, 20.08, 215.7), true)
        SetVehicleDoorsLocked(veh, 1)
        local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
        SetCamCoord(cam, vector3(-1041.56, -2743.61, 24.69))
        SetCamRot(cam, vec(-13.97636, -3.415095e-06, -30.10134))
        RenderScriptCams(1, 1, 500, 1, 1)

        SetPedIntoVehicle(ped, veh, -1)
        TaskVehicleDriveToCoordLongrange(ped, veh, vector3(-1032.0, -2729.99, 20.13), 5.0, 786603, 1.0)
        
        local active = true
        CreateThread(function()
            while active do
                Wait(0)
                DisableAllControlActions(0)
            end
        end)

        while Vdist3(GetEntityCoords(ped), vector3(-1032.0, -2729.99, 20.13)) >= 7.0 do
            Wait(500)
        end

        TaskEnterVehicle(Shared.Ped, veh, 5000, 0, 1.0, 1, 0)
        Wait(5000)
        DoScreenFadeOut(5000)
        TaskVehicleDriveToCoordLongrange(ped, veh, vector3(-859.98, -2632.81, 17.51), 5.0, 786603, 1.0)
        Wait(6000)
        DeleteEntity(veh)
        DeleteEntity(ped)
        DestroyCam(cam)
        RenderScriptCams(0, 1, 1000, 1, 1)
        active = false

        local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
        SetCamCoord(cam, vector3(-557.85, -838.65, 31.51))
        SetCamRot(cam, -16.45665, -0, 176.7832)
        RenderScriptCams(1, 1, 0, 1, 1)

        SetEntityCoords(Shared.Ped, vector3(-558.29, -848.74, 27.57))
        SetEntityHeading(Shared.Ped, 5.56)
        Wait(500)
        ExecuteCommand('e sitchair3')
        Wait(500)
        DoScreenFadeIn(2500)
        Wait(2500)

        RenderScriptCams(0, 1, 1500, 1, 1)
        DestroyCam(cam)
        Wait(1500)
        ExecuteCommand('ec sitchair3')
        Task.Run('MagicSchoolBusDone')
        TriggerEvent('Help', 1)
        exports['geo-hud']:Render(true)
    end
end)