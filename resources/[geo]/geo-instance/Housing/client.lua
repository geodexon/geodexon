properties = {}
local myProperties = {}
local gList = {}
local inVeh = false
local toSell
local toBuy

CreateThread(function()
    Wait(1000)
    TriggerServerEvent('GetProperties')
end)

RegisterNetEvent('GetProperties')
AddEventHandler('GetProperties', function(prop)
    properties = prop
    PropertyChange()
end)

RegisterNetEvent('SetProperty')
AddEventHandler('SetProperty', function(id, prop)
    properties[id] = prop
    PropertyChange()
end)

AddEventHandler('Login', function()
    Wait(1000)
    PropertyChange()
end)

Menu.CreateMenu('PropertyCreation', 'Property')
function Property()
    local propertyName
    local ped = PlayerPedId()
    local garage = {}
    local doors = {}
    local price = 0
    local thisType = 1
    local thisInt = 1
    Menu.OpenMenu('PropertyCreation')
    while Menu.CurrentMenu do
        Wait(0)
        local pos = GetEntityCoords(ped)

        if Menu.Button('Property Name', propertyName) then
            propertyName = Shared.TextInput('Property Name', 50)
        end

        Menu.ComboBox('Property Type', propertyTypes, thisType, function(current)
            if current ~= thisType then
                thisType = current
            end
        end)

        if Menu.ComboBox('Interior', interiorList, thisInt, function(current)
            if current ~= thisInt then
                thisInt = current
            end
        end) then
            if MyCharacter.interior == nil then
                ExecuteCommand('view '..interiorList[thisInt])
            end
        end

        if Menu.Button('Add Door') then
            local thisDoor
            while thisDoor == nil do
                Wait(0)
                pos = GetEntityCoords(ped)
                DrawMarker(26, pos.x, pos.y, pos.z - 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, GetEntityHeading(PlayerPedId()), 1.0, 1.0, 1.0, 0, 150, 0, 255, 0, 0, 1, 0)
            
                if IsControlJustPressed(0, 38) then
                    thisDoor = {pos.x, pos.y, pos.z - 0.98, GetEntityHeading(PlayerPedId())}
                end
            end

            table.insert(doors, thisDoor)
        end

        for k,v in pairs(doors) do
            DrawMarker(27, v[1], v[2],v[3], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 150, 0, 255, 0, 0, 1, 0)
            if Menu.Button('Remove Door', round(Vdist3(pos, vec(v[1], v[2], v[3])), 1)) then
                table.remove(doors, k)
            end
        end

        if Menu.Button('Set Garage', #garage > 0) then
            garage = {}
            while #garage == 0 do
                Wait(0)
                pos = GetEntityCoords(ped)
                DrawMarker(26, pos.x, pos.y, pos.z - 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, GetEntityHeading(ped), 4.0, 4.0, 1.0, 0, 150, 0, 255, 0, 0, 1, 0)
            
                if IsControlJustPressed(0, 38) then
                    garage = {pos.x, pos.y, pos.z - 0.98, GetEntityHeading(ped)}
                end
            end
        end

        if Menu.Button('Set Price', '$'..comma_value(price)) then
            price = tonumber(Shared.TextInput('Property Price', 8)) or price
        end

        if #garage > 0 then
            DrawMarker(27, garage[1], garage[2],garage[3], 0.0, 0.0, 0.0, 0.0, 0.0, garage[4], 4.0, 4.0, 1.0, 0, 150, 0, 255, 0, 0, 1, 0)
        end

        if Menu.Button('Finalize') then
            TriggerServerEvent('CreateProperty', propertyName, propertyTypes[thisType], interiorList[thisInt], doors, garage, price)
        end

        Menu.Display()
    end
end

AddEventHandler('ModHouse', function(pid)
    local ped = PlayerPedId()
    local garage = properties[pid].garage
    local doors = properties[pid].doors
    Menu.OpenMenu('PropertyCreation')
    while Menu.CurrentMenu do
        Wait(0)
        local pos = GetEntityCoords(ped)

        if Menu.Button('Add Door') then
            local thisDoor
            while thisDoor == nil do
                Wait(0)
                pos = GetEntityCoords(ped)
                DrawMarker(26, pos.x, pos.y, pos.z - 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, GetEntityHeading(PlayerPedId()), 1.0, 1.0, 1.0, 0, 150, 0, 255, 0, 0, 1, 0)
            
                if IsControlJustPressed(0, 38) then
                    thisDoor = {pos.x, pos.y, pos.z - 0.98, GetEntityHeading(PlayerPedId())}
                end
            end

            table.insert(doors, thisDoor)
        end

        for k,v in pairs(doors) do
            DrawMarker(27, v[1], v[2],v[3], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 150, 0, 255, 0, 0, 1, 0)
            if Menu.Button('Remove Door', round(Vdist3(pos, vec(v[1], v[2], v[3])), 1)) then
                table.remove(doors, k)
            end
        end

        if Menu.Button('Set Garage', #garage > 0) then
            garage = {}
            while #garage == 0 do
                Wait(0)
                pos = GetEntityCoords(ped)
                DrawMarker(26, pos.x, pos.y, pos.z - 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, GetEntityHeading(ped), 4.0, 4.0, 1.0, 0, 150, 0, 255, 0, 0, 1, 0)
            
                if IsControlJustPressed(0, 38) then
                    garage = {pos.x, pos.y, pos.z - 0.98, GetEntityHeading(ped)}
                end
            end
        end

        if #garage > 0 then
            DrawMarker(27, garage[1], garage[2],garage[3], 0.0, 0.0, 0.0, 0.0, 0.0, garage[4], 4.0, 4.0, 1.0, 0, 150, 0, 255, 0, 0, 1, 0)
        end

        if Menu.Button('Finalize') then
            if Task.Run('ModifyProperty', pid, doors, garage) then
                Menu.CloseMenu()
            end
        end

        Menu.Display()
    end
end)

local viewing = false
function PropertyView()
    viewing = not viewing
    local ped = PlayerPedId()
    CreateThread(function()
        while viewing do
            Wait(0)
            local pos = GetEntityCoords(ped)
            for k,v in pairs(properties) do
                local n = vec(table.unpack(v.doors[1], 1, 3))
                if Vdist4(pos, n) <= 50.0 then
                    if v.owner == 0 and v.renter == 0 then
                        DrawMarker(27, n, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 150, 0, 255, 0, 0, 1, 0)
                        if v.buyable ~= 0 then
                            Shared.WorldText(v.title..' : $'..comma_value(v.price), n + vector3(0.0, 0.0, 1.0))
                        else
                            Shared.WorldText('[E] '..v.title..' : $'..comma_value(v.price), n + vector3(0.0, 0.0, 1.0))
                            if IsControlJustPressed(0, 38) then
                                if Shared.Confirm('Would you like to rent this property?', 'Rent') then
                                    TriggerServerEvent('Property:Rent', GetClosestProperty())
                                end
                            end
                        end
                    else
                        DrawMarker(27, n, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 150, 150, 0, 255, 0, 0, 1, 0)
                        Shared.WorldText(v.title..' : $'..comma_value(v.price), n + vector3(0.0, 0.0, 1.0))
                    end
                end
            end
        end
    end)
end

local houseBlips = {}
function PropertyChange()
    if MyCharacter then
        myProperties = {}
        gList = {}
        for k,v in pairs(properties) do
            if v.owner == MyCharacter.id or v.renter == MyCharacter.id or IsTenant(v.tenants) then
                myProperties[v.pid] = v
                table.insert(gList, vec(table.unpack(v.garage)))
            end
        end

        --[[ if inVeh then
            RegisterProximityMenu('PropertyGarage', {Name = 'Park Vehicle', pos = gList, Event = 'PropertyGarage', range = 50.0})
        else
            RegisterProximityMenu('PropertyGarage', {Name = 'Retrieve Vehicle', pos = gList, Event = 'PropertyGarage', range = 50.0})
        end ]]

        for k,v in pairs(houseBlips) do
            RemoveBlip(v)
        end
        houseBlips = {}

        for k,v in pairs(myProperties) do
            local blip = AddBlipForCoord(v.doors[1][1], v.doors[1][2], v.doors[1][3])
            SetBlipSprite(blip, 492)
            SetBlipColour(blip, 0)
            SetBlipAsShortRange(blip, true)
            SetBlipScale(blip, 1.0)
            BeginTextCommandSetBlipName("STRING");
            AddTextComponentString(v.title)
            EndTextCommandSetBlipName(blip)
            table.insert(houseBlips, blip)
            SetBlipCategory(blip, 11)

            local blip2 = AddBlipForCoord(v.garage[1], v.garage[2], v.garage[3])
            SetBlipSprite(blip2, 357)
            SetBlipColour(blip2, 0)
            SetBlipAsShortRange(blip2, true)
            SetBlipScale(blip2, 1.0)
            BeginTextCommandSetBlipName("STRING");
            AddTextComponentString(v.title..' Garage')
            EndTextCommandSetBlipName(blip2)
            table.insert(houseBlips, blip2)
            SetBlipCategory(blip2, 11)
        end
    end
end

RegisterNetEvent('User.Update', function()
    Wait(100)
    if MyUser.data.settings and MyUser.data.settings.garage then
        ShowGarage()
    end
end)

AddEventHandler('Login', function(char, user)
    Wait(100)
    if MyUser.data.settings and MyUser.data.settings.garage then
        ShowGarage()
    end
end)

CreateThread(function()
    Wait(100)
    if MyUser and MyUser.data.settings and MyUser.data.settings.garage then
        ShowGarage()
    end
end)

local showingGarages = false
function ShowGarage()
    if not showingGarages then
        showingGarages = true
        while MyUser and MyUser.data.settings.garage do
            local found = false
            local pos = GetEntityCoords(Shared.Ped)
            for k,v in pairs(myProperties) do
                local gPos = vec(v.garage[1], v.garage[2], v.garage[3])
                if Vdist3(pos, gPos) <= 30.0 then
                    DrawMarker(36, gPos + vec(0.0, 0.0, 1.0), 0.0, 0.0, 0.0, 0.0, 0.0, v.garage[4], 1.0, 1.0, 1.0, 146, 122, 146, 150, 0, 0, 1, 0)
                    found = true
                end
            end
            Wait(found and 0 or 1000)
        end
        showingGarages = false
    end
end

AddEventHandler('enteredVehicle', function()
    inVeh = true
    RegisterProximityMenu('PropertyGarage', {Name = 'Park Vehicle', pos = gList, Event = 'PropertyGarage', range = 25.0})
end)

AddEventHandler('leftVehicle', function()
    inVeh = false
    RegisterProximityMenu('PropertyGarage', {Name = 'Retrieve Vehicle', pos = gList, Event = 'PropertyGarage', range = 25.0})
end)

function IsTenant(list)
    for k,v in pairs(list) do
        if MyCharacter.id == v then
            return true
        end
    end
end

AddEventHandler('Interact', function()
    local pos = GetEntityCoords(Shared.Ped)
    for k,v in pairs(properties) do
        for key,val in pairs(v.doors) do
            local n = vec(table.unpack(val, 1 ,3))
            local dist = Vdist4(pos, n)
            if dist <= 10.0 then
                ExecuteCommand('enter')
                Wait(1000)
            end
        end
    end
end)

RegisterNetEvent('PropertyComplete')
AddEventHandler('PropertyComplete', function()
    if Menu.CurrentMenu == 'PropertyCreation' then
        Menu.CloseMenu()
    end
end)

RegisterNetEvent('Property:Release')
AddEventHandler('Property:Release', function(home)
    toSell = home
    TriggerEvent('Shared.Notif', 'You have recieved a request to release property: '..properties[home].title)
    RegisterAction('SellMyProperty', {Name = '> Sell Owned Property', func = SellMyProperty})
    SetTimeout(60000, function()
        if toSell == home then
            RegisterAction('SellMyProperty', nil)
        end
    end)
end)

RegisterNetEvent('Property:SellToPlayer')
AddEventHandler('Property:SellToPlayer', function(home)
    toBuy = home
    TriggerEvent('Shared.Notif', 'You have recieved a request to purchase property: '..properties[home].title)
    RegisterAction('BuyProperty', {Name = '> Purchase Property', func = BuyProperty})
    SetTimeout(60000, function()
        if toBuy == home then
            RegisterAction('BuyProperty', nil)
        end
    end)
end)

RegisterCommand('LockHome', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    local home = GetClosestProperty()
    if home then
        TriggerServerEvent('Property:Lock', home)
    else
        if MyCharacter.interior then
            for k,v in pairs(myProperties) do
                if v.title == MyCharacter.interior then
                    if Vdist3(GetEntityCoords(Shared.Ped), vec(interiors[v.interior].Spawn.x, interiors[v.interior].Spawn.y, interiors[v.interior].Spawn.z)) <= 2.0 then
                        TriggerServerEvent('Property:Lock', k)
                    end
                end
            end
        end
    end
end)

RegisterCommand('enter', function()
    local home = GetClosestProperty()
    if home then
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 then

            local plyrs = {}
            for i=0,5 do
                if GetPedInVehicleSeat(veh, i) ~= 0 then
                    table.insert(plyrs, {GetPlayerServerId(NetworkGetPlayerIndexFromPed(GetPedInVehicleSeat(veh, i))), i})
                end
            end

            if GetPedInVehicleSeat(veh, -1) == PlayerPedId() then
                TriggerServerEvent('Property:Enter', home, VehToNet(veh) or 0, GetClosestDoor(home), plyrs)
                return
            end
        end
        TriggerServerEvent('Property:Enter', home, 0, GetClosestDoor(home))
    end
end)

function GetClosestProperty()
    local pos = GetEntityCoords(PlayerPedId())
    local closest
    local dist = 10000.0

    for k,v in pairs(properties) do
        for key,val in pairs(v.doors) do
            local distance = Vdist4(pos, vec(table.unpack(val, 1 ,3)))
            if distance <= dist then
                closest = k
                dist = distance
            end
        end
    end

    if dist <= 50.0 then
        return closest
    end
end

function GetClosestPropertyData()
    local pos = GetEntityCoords(PlayerPedId())
    local closest
    local dist = 10000.0

    for k,v in pairs(properties) do
        for key,val in pairs(v.doors) do
            local distance = Vdist3(pos, vec(table.unpack(val, 1 ,3)))
            if distance <= dist then
                closest = k
                dist = distance
            end
        end
    end

    if dist <= 2.0 then
        return properties[closest]
    end
end

function GetClosestPropertyGarage()
    local pos = GetEntityCoords(PlayerPedId())
    local closest
    local dist = 10000.0

    for k,v in pairs(myProperties) do
        local distance = Vdist3(pos, vec(v.garage[1], v.garage[2], v.garage[3]))
        if distance <= dist then
            closest = k
            dist = distance
        end
    end

    if dist <= 5.0 then
        return closest
    end
end

exports('GetClosestPropertyGarage', GetClosestPropertyGarage)
exports('GetClosestPropertyData', GetClosestPropertyData)
function GetClosestDoor(houseid)
    local pos = GetEntityCoords(PlayerPedId())
    local closest
    local dist = 10000.0

    for k,v in pairs(properties[houseid].doors) do
        local distance = Vdist4(pos, vec(v[1], v[2], v[3]))
        if distance <= dist then
            closest = v
            dist = distance
        end
    end

    if dist <= 50.0 then
        return closest
    end
end

function IsOwned(home)
    if properties[home].owner ~= 0 then
        return '[Owned]'
    elseif properties[home].renter ~= 0 then
        return '[Rented]'
    end
end

Menu.CreateMenu('SellPMyroperty', 'Sell')
function SellMyProperty()
    if toSell then
        Menu.OpenMenu('SellPMyroperty')
        while Menu.CurrentMenu do
            Wait(0)
            local home = GetClosestProperty()
            if home == toSell then
                if Menu.Button('Release Property') then
                    if Shared.Confirm('If you own this property, you will receive up to 75% of the properties value.', 'Verify Sell') then
                        TriggerServerEvent('Property:Sell', home)
                        toSell = nil
                        RegisterAction('SellMyProperty', nil)
                        Menu.CloseMenu()
                        return
                    end
                end
            end
            Menu.Display()
        end
    end
end

Menu.CreateMenu('BuyProperty', 'Buy Property')
function BuyProperty()
    if toBuy then
        Menu.OpenMenu('BuyProperty')
        while Menu.CurrentMenu do
            Wait(0)
            local home = GetClosestProperty()
            if home == toBuy then
                Menu.Button(properties[home].title, '$'..comma_value(properties[home].price))
                Menu.Button('Down Payment', '$'..comma_value(math.floor(properties[home].price * 0.6)))
                Menu.Button('Weekly Payment', '$'..comma_value(math.floor(properties[home].price * 0.075)))

                if Menu.Button('Buy Property', '$'..comma_value(math.floor(properties[home].price * 0.4))) then
                    if Shared.Confirm('Would you like to purchase this property', 'Verify Sell') then
                        TriggerServerEvent('Property:Buy', home)
                        toBuy = nil
                        RegisterAction('BuyProperty', nil)
                        Menu.CloseMenu()
                        return
                    end
                end
            end
            Menu.Display()
        end
    end
end

Menu.CreateMenu('SellProperty', 'Sell')
function SellProperty()
    if not Menu.CurrentMenu then
        Menu.OpenMenu('SellProperty')
        while Menu.CurrentMenu do
            Wait(0)
            local home = GetClosestProperty()
            if home then
                if properties[home].buyable ~= 0 then
                    local owned = IsOwned(home)
                    if owned then
                        Menu.Button(properties[home].title, owned)
                        if Menu.Button('Request To Release Property') then
                            TriggerServerEvent('Property:Release', home)
                        end
                    else
                        Menu.Button(properties[home].title, '$'..comma_value(properties[home].price))
                        Menu.Button('Down Payment', '$'..comma_value(math.floor(properties[home].price * 0.6)))
                        Menu.Button('Weekly Payment', '$'..comma_value(math.floor(properties[home].price * 0.075)))

                        if Menu.Button('Sell Property') then
                            local target = tonumber(Shared.TextInput('Target ID', 6))
                            if target then
                                TriggerServerEvent('Property:SellToPlayer', home, target)
                            end
                        end
                    end
                end
            end
            Menu.Display()
        end
    end
end

AddEventHandler('PropertyGarage', function()
    local garage = GetClosestPropertyGarage()
    local vec = vec(properties[garage].garage[1], properties[garage].garage[2], properties[garage].garage[3], properties[garage].garage[4])
    TriggerEvent('Garage:Valet', 'Property: '..properties[garage].title, { 
        Name = 'Property: '..properties[garage].title,
        Position = vec,
        SpawnPosition = {
        vec,
    }})
end)

local housingShown = false
local tempBlips = {}
AddEventHandler('ToggleHousing', function()
    housingShown = not housingShown
    if housingShown then
        for k,v in pairs(properties) do
            if v.owner == 0 and v.renter == 0 then
                local blip = AddBlipForCoord(v.doors[1][1], v.doors[1][2], v.doors[1][3])
                SetBlipSprite(blip, 492)
                SetBlipColour(blip, 0)
                SetBlipAsShortRange(blip, true)
                SetBlipScale(blip, 1.0)
                BeginTextCommandSetBlipName("STRING");
                AddTextComponentString(v.title)
                EndTextCommandSetBlipName(blip)
                table.insert(tempBlips, blip)
                SetBlipCategory(blip, 10)
                tempBlips[k] = blip
            end
        end
        TriggerEvent('Shared.Notif', 'Showing Housing')
    else
        for k,v in pairs(tempBlips) do
            RemoveBlip(v)
        end
        TriggerEvent('Shared.Notif', 'Hiding Housing')
        tempBlips = {}
    end
end)

local guildSelection
Task.Register('House.GetGuild', function()
    local guilds = exports['geo-guilds']:GetGuilds()
    local menu = {}
    for k,v in pairs(guilds) do
        if v.owner == MyCharacter.id then
            table.insert(menu, {
                title = v.guild, func = GuildSelection, params = {v.ident}
            })
        end
    end

    guildSelection = promise:new()
    RunMenu(menu)
    Citizen.SetTimeout(5000, function()
        if guildSelection then
            guildSelection:resolve(false)
            guildSelection = nil
        end
    end)

    return Citizen.Await(guildSelection)
end)

function GuildSelection(id)
    guildSelection:resolve(id)
    guildSelection = nil
end

RegisterAction('PropertyView', {Name = 'View Properties', func = PropertyView})
RegisterAction('PropertyCreation', {Name = 'Create Property', func = Property, Groups = {'FHA'}})
RegisterAction('PropertySell', {Name = 'Sell Property', func = SellProperty, Groups = {'FHA'}})
RegisterKeyMapping('LockHome', '[Property] Lock Property', 'keyboard', 'L')