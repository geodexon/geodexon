
local lst = {}
local enum = {[0] = 'Spoilers', 'Front Bumper', 'Rear Bumper', 'Side Skirt', 'Exhaust', 'Frame', 'Grille', 'Hood', 'Fender', 'Right Fender', 'Roof', 'Engine', 'Brakes', 'Transmission', 'Horns', 'Suspension', 'Armor', 'UNK17', 'Turbo', 'UNK19', 'Tire Smoke', 'UNK21', 'Xenon Headlights', 'Front Wheels', 'Back Wheels', 'Plateholder', 'Vanity Plates', 'Trim', 'Ornaments', 'Dashboard', 'Dial', 'Door Speaker', 'Seats', 'Steering Wheel', 'Shifter', 'Plaques', 'Speakers', 'Trunk', 'Hydraulics', 'Engine Block', 'Air Filter', 'Struts', 'Arch Cover', 'Aerials', 'Trim', 'Tank', 'Windows', 'UNK47', 'Livery', 'UNK49'}
local customTitles = {
    [11] = {'EMS Upgrade, Level 0', 'EMS Upgrade, Level 1', 'EMS Upgrade, Level 2', 'EMS Upgrade, Level 3', 'EMS Upgrade, Level 4', 'EMS Upgrade, Level 5', 'EMS Upgrade, Level 6', 'EMS Upgrade, Level 7', 'EMS Upgrade, Level 8'},
    [12] = {'Stock Brakes', 'Street Brakes', 'Sport Brakes', 'Race Brakes', 'Super Brakes', 'Hardline Brakes'},
    [13] = {'Stock Transmission', 'Street Transmission', 'Sports Transmission', 'Race Transmission', 'Super Transmission', 'Hardline Transmission'},
    [15] = {'Stock Suspension', 'Lowered Suspension', 'Street Suspension', 'Sport Suspension', 'Competition Suspension', 'Race Suspension', 'Hardline Suspension', 'Hardline v2 Suspension', 'Hardline v3 Suspension' },
    [16] = {'Armor: 0%', 'Armor: 20%', 'Armor: 40%', 'Armor: 60%', 'Armor: 80%', 'Armor: 100%'},
}

local wheels = {[0] = 'Sport', 'Muscle', 'Lowrider', 'SUV', 'Offroad', 'Tuner', 'Bike Wheels', 'High End'}

local blackList = {
    [16] = true,
    [14] = true,
    [11] = true,
    [12] = true,
    [13] = true
}

local tints = {{'None', 0}, {'Stock', 4}, {'Limo', 5}, {'Light Smoke', 3}, {'Dark Smoke', 2}, {'Pure Black', 1}, {'Green', 6}}
local plateTypes = {{'Blue on White', 3}, {'Blue on White 2', 0}, {'Yellow on Blue', 2}, {'Yellow on Black', 1}, {'North Yankton', 5}}

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

Citizen.CreateThread(function()
    for k,v in pairs(repairLocations) do
        table.insert(lst, v.Position)
        local blip = AddBlipForCoord(v.Position)
        SetBlipSprite(blip, 72)
		SetBlipAsShortRange(blip, true)
		SetBlipScale(blip, 0.8)
		BeginTextCommandSetBlipName("STRING");
		AddTextComponentString('Los Santos Customs')
		EndTextCommandSetBlipName(blip)

        AddCircleZone(v.Position, v.Range or 25.0, {
            name="Store.Open",
            useZ=true,
            id = uuid(),
            pos = v.Position,
            storeID = k,
            entry = 'LSC',
        })
    end

    --RegisterProximityMenu('LSC', {Name = 'Los Santos Customs', pos = lst, func = LSC_Menu, range = 50.0})
end)

Menu.CreateMenu('LSC', 'Los Santos Customs')
Menu.CreateSubMenu('Customization', 'LSC', 'Customization')
Menu.CreateSubMenu('Paint', 'Customization', 'Paint')
Menu.Menus['Paint'].SubTitle = '$'..comma_value(prices['paint'].Base)..' each'
Menu.CreateSubMenu('WindowTint', 'Customization', 'Window Tint')
Menu.Menus['WindowTint'].SubTitle = '$'..comma_value(prices['tint'].Base)..' each'
Menu.CreateSubMenu('PlateType', 'Customization', 'Plate Type')
Menu.Menus['PlateType'].SubTitle = '$'..comma_value(prices['plateType'].Base)..' each'
Menu.CreateSubMenu('Extras', 'Customization', 'Extras')
Menu.CreateSubMenu('Checkout', 'LSC', 'Checkout')


for i=0,49 do
    Menu.CreateSubMenu(enum[i], 'Customization', enum[i])
end

function LSC_Menu()
    local fixing = false
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local veh = GetVehiclePedIsIn(ped, false)
    local currentMod
    local wasInMenu
    local modIndex = 1
    local openedCustom = false

    if veh == 0 then
        return
    end

    if Menu.CurrentMenu then
        return
    end

    SetVehicleModKit(veh, 0)
    local startData
    local moddedData
    local pSlider
    CreateThread(function()
        startData = GetVehicleData(veh)
        moddedData = New(startData)
        pSlider = {moddedData['paint'], moddedData['paint2'], moddedData['pearl'], moddedData['wheelColor']}
    end)
    local liveryCount = GetVehicleLiveryCount(veh)
    local liv = GetVehicleLivery(veh)
    local class = GetVehicleClass(veh)

    local extraCount = 0
    for i=1,14 do
        if DoesExtraExist(veh, i) then
            extraCount = extraCount + 1
        end
    end

    local shopID
    for k,v in pairs(repairLocations) do
        if Vdist4(pos, v.Position) <= 50.0 then
            shopID = k
            break
        end
    end

    if not shopID then
        return
    end

    local store = exports['geo-inventory']:GetStore('LSC', shopID)
    local worksHere
    local canCustomize
    if store then
        local storeGuild = exports['geo-instance']:GetProperty(store[1]).guild
        if storeGuild then
            worksHere = exports['geo-guilds']:GuildHasFlag(storeGuild, MyCharacter.id, 'Repair') or exports['geo-guilds']:GuildHasFlag(storeGuild, MyCharacter.id, 'Customize')
            canCustomize = exports['geo-guilds']:GuildHasFlag(storeGuild, MyCharacter.id, 'Customize')
        end
    end

    Menu.OpenMenu('LSC')
    local isOwner = GetOwner(GetPlate(veh))
    local owned = Entity(veh).state.owned
    while Menu.CurrentMenu do
        Wait(0)
        local pos = GetEntityCoords(ped)
        if not IsNearLocation(lst, pos, 50.0) then
            Menu.CloseMenu()
            break
        end

        if GetVehiclePedIsIn(ped, false) == 0 then
            Menu.CloseMenu()
            break
        end

        if Menu.CurrentMenu == 'LSC' then
            if GetPedInVehicleSeat(veh, -1) == ped then
                local engineHealth = GetVehicleEngineHealth(veh)
                local bodyHealth = GetVehicleBodyHealth(veh)
                local cost = GetRepairCost(engineHealth, bodyHealth, GetVehicleClass(veh))

                if cost > 0 then
                    if Menu.Button('Repair Vehicle', '$'..GetPrice(cost)) then
                        if not fixing then
                            fixing = true
                            exports['geo-shared']:Progress('Fixing', 2500, function(res)
                                if res then
                                    TriggerServerEvent('LSC:Fix', VehToNet(veh), engineHealth, bodyHealth, GetVehicleClass(veh), shopID)
                                    fixing = false
                                end
                            end)
                        end
                    end

                    if worksHere then
                        if Menu.Button('Repair Vehicle (Store Discount)', '$'..GetPrice(math.floor(cost * 0.6))) then
                            if not fixing then
                                fixing = true
                                exports['geo-shared']:Progress('Fixing', 2500, function(res)
                                    if res then
                                        TriggerServerEvent('LSC:Fix', VehToNet(veh), engineHealth, bodyHealth, GetVehicleClass(veh))
                                        fixing = false
                                    end
                                end)
                            end
                        end
                    end
                else
                    if Menu.Button('Clean Vehicle') then
                        if not fixing then
                            fixing = true
                            exports['geo-shared']:Progress('Cleaning', 2500, function(res)
                                if res then
                                    TriggerEvent('LSC:Fix')
                                    fixing = false
                                end
                            end)
                        end
                    end

                    if CanMod(MyCharacter.id, shopID) or isOwner or not owned then
                        if Menu.Button('Customize') then
                            Menu.OpenMenu('Customization')
                            openedCustom = true
                        end
                    end
                end

                if Menu.Button('Checkout') then
                    Menu.OpenMenu('Checkout')
                end
            end
        elseif Menu.CurrentMenu == 'Customization' then

            if Menu.Button('Paint') then
                modIndex = Menu.ActiveOption
                Menu.OpenMenu('Paint')
            end

            if GetVehicleClass(veh) == 13 then
                goto skip
            end

            if Menu.Button('Change Plate', '$'..comma_value(CalculatePrice(class, 'plate', moddedData['plate']))) then
                local _plate = Shared.TextInput('New Plate', 8)
                if _plate ~= '' then
                    _plate = PlateForString(_plate)
                    if Promise('LSC:CheckPlate', _plate) then
                        TriggerEvent('Shared.Notif', 'Plate is available, reserving it')
                        moddedData['plate'] = _plate
                    else
                        TriggerEvent('Shared.Notif', 'Plate is not available')
                    end
                end
            end

            if Menu.Button('Window Tint') then
                modIndex = Menu.ActiveOption
                Menu.OpenMenu('WindowTint')
            end

            if Menu.Button('Plate Type') then
                modIndex = Menu.ActiveOption
                Menu.OpenMenu('PlateType')
            end

            if extraCount > 0 then
                if Menu.Button('Extras') then
                    modIndex = Menu.ActiveOption
                    Menu.OpenMenu('Extras')
                end
            end

            if Menu.CheckBox('Xenon', moddedData['xenon'] == true) then
                moddedData['xenon'] = not moddedData['xenon']
                ToggleVehicleMod(veh, 22, moddedData['xenon'])
            end

            if Menu.CheckBox('Turbo', moddedData['turbo'] == true) then
                moddedData['turbo'] = not moddedData['turbo']
                ToggleVehicleMod(veh, 18, moddedData['turbo'])
            end

            for i=0,49 do
                if blackList[i] == nil then
                    if GetNumVehicleMods(veh, i) > 0 then
                        if Menu.Button(enum[i]) then
                            modIndex = Menu.ActiveOption
                            Menu.OpenMenu(enum[i])
                            currentMod = i
                        end
                    end
                end
            end

            if liveryCount ~= -1 then
                local str = 'Livery'

                if liv == startData['livery'] then
                    str = str..' [Owned]'
                elseif liv == moddedData['livery'] then
                    str = str..' [Selected]'
                end

                if Menu.SliderStep(str, 0, liveryCount - 1, 1.0, liv, function(current)
                    if liv ~= current then
                        current = math.floor(current)
                        liv = current
                        SetVehicleLivery(veh, liv)
                    end
                end) then
                    moddedData['livery'] = liv
                end
            end

            if wasInMenu then
                wasInMenu = nil
                if currentMod then
                    Menu.ActiveOption = modIndex
                    currentMod = nil
                end
                SetVehicleColours(veh, moddedData['paint'], moddedData['paint2'])
                SetVehicleExtraColours(veh,  moddedData['pearl'], moddedData['wheelColor'])
                SetVehicleData(veh, json.encode(moddedData))
            end

            ::skip::

        elseif Menu.CurrentMenu == 'Paint' then
            if not wasInMenu then
                wasInMenu = true
            end

            if Menu.Button(not moddedData['paintCustom'] and 'Custom Primary Color' or 'Remove Custom Primary Paint') then
                if not moddedData['paintCustom'] then
                    local customColor = Shared.TextInput('Custom Color, Example: 255 0 255', 11)
                    local var = SplitString(customColor, ' ')
                    if tonumber(var[1]) and tonumber(var[2]) and tonumber(var[3]) then
                        SetVehicleCustomPrimaryColour(veh, tonumber(var[1]), tonumber(var[2]), tonumber(var[3]))
                        moddedData['paintCustom'] = {tonumber(var[1]), tonumber(var[2]), tonumber(var[3])}
                    else
                        TriggerEvent('Shared.Notif', 'Invalid Input')
                    end
                else
                    ClearVehicleCustomPrimaryColour(veh)
                    SetVehicleColours(veh, moddedData['paint'], moddedData['paint2'])
                    moddedData['paintCustom'] = false
                end
            end

            if Menu.Button(not moddedData['paint2Custom'] and 'Custom Secondary Color' or 'Remove Custom Secondary Paint') then
                if not moddedData['paint2Custom'] then
                    local customColor = Shared.TextInput('Custom Color, Example: 255 0 255', 11)
                    local var = SplitString(customColor, ' ')
                    
                    if tonumber(var[1]) and tonumber(var[2]) and tonumber(var[3]) then
                        SetVehicleCustomSecondaryColour(veh, tonumber(var[1]), tonumber(var[2]), tonumber(var[3]))
                        moddedData['paint2Custom'] = {tonumber(var[1]), tonumber(var[2]), tonumber(var[3])}
                    else
                        TriggerEvent('Shared.Notif', 'Invalid Input')
                    end
                else
                    ClearVehicleCustomSecondaryColour(veh)
                    SetVehicleColours(veh, moddedData['paint'], moddedData['paint2'])
                    moddedData['paint2Custom'] = false
                end
            end

            local str = 'Primary Color: '
            if pSlider[1] == startData['paint'] then
                str = str..' [Owned]'
            elseif pSlider[1] == moddedData['paint'] then
                str = str..' [Selected]'
            else
                str = str..VehicleColors[tostring(pSlider[1])]
            end
            if Menu.SliderStep(str, 0, 160, 1, pSlider[1], function(current)
                if pSlider[1] ~= current then
                    current = math.floor(current)
                    pSlider[1] = current
                    SetVehicleColours(veh, pSlider[1], moddedData['paint2'])
                end
            end) then
                moddedData['paint'] = pSlider[1]
                SetVehicleColours(veh, moddedData['paint'], moddedData['paint2'])
            end

            local str = 'Secondary Color: '
            if pSlider[2] == startData['paint2'] then
                str = str..' [Owned]'
            elseif pSlider[2] == moddedData['paint2'] then
                str = str..' [Selected]'
            else
                str = str..VehicleColors[tostring(pSlider[2])]
            end
            if Menu.SliderStep(str, 0, 160, 1, pSlider[2], function(current)
                if pSlider[2] ~= current then
                    current = math.floor(current)
                    pSlider[2] = current
                    SetVehicleColours(veh, moddedData['paint'], pSlider[2])
                end
            end) then
                moddedData['paint2'] = pSlider[2]
                SetVehicleColours(veh, moddedData['paint'], moddedData['paint2'])
                moddedData['paint2Custom'] = false
            end

            local str = 'Pearl Color: '
            if pSlider[3] == startData['pearl'] then
                str = str..' [Owned]'
            elseif pSlider[3] == moddedData['pearl'] then
                str = str..' [Selected]'
            else
                str = str..VehicleColors[tostring(pSlider[3])]
            end
            if Menu.SliderStep(str, 0, 160, 1, pSlider[3], function(current)
                if pSlider[3] ~= current then
                    current = math.floor(current)
                    pSlider[3] = current
                    SetVehicleExtraColours(veh, pSlider[3], moddedData['wheelColor'])
                end
            end) then
                moddedData['pearl'] = pSlider[3]
                SetVehicleExtraColours(veh,  moddedData['pearl'], moddedData['wheelColor'])
            end

            local str = 'Wheel Color: '
            if pSlider[4] == startData['wheelColor'] then
                str = str..' [Owned]'
            elseif pSlider[4] == moddedData['wheelColor'] then
                str = str..' [Selected]'
            else
                str = str..VehicleColors[tostring(pSlider[4])]
            end
            if Menu.SliderStep(str, 0, 160, 1, pSlider[4], function(current)
                if pSlider[4] ~= current then
                    current = math.floor(current)
                    pSlider[4] = current
                    SetVehicleExtraColours(veh, moddedData['pearl'], pSlider[4])
                end
            end) then
                moddedData['wheelColor'] = pSlider[4]
                SetVehicleExtraColours(veh,  moddedData['pearl'], moddedData['wheelColor'])
            end
        elseif Menu.CurrentMenu == 'WindowTint' then
            if not wasInMenu then
                wasInMenu = true
            end

            for k,v in pairs(tints) do
                local str = v[1]
                if v[2] == startData['tint'] then
                    str = str..' [Owned]'
                elseif v[2] == moddedData['tint'] then
                    str = str..' [Selected]'
                end
                if Menu.Button(str, '$'..comma_value(CalculatePrice(class, 'tint', moddedData['tint']))) then
                    moddedData['tint'] = v[2]
                end
            end

            SetVehicleWindowTint(veh, tints[Menu.ActiveOption][2])
        elseif Menu.CurrentMenu == 'PlateType' then
            if not wasInMenu then
                wasInMenu = true
            end
            for k,v in pairs(plateTypes) do
                local str = v[1]
                if v[2] == startData['plateType'] then
                    str = str..' [Owned]'
                elseif v[2] == moddedData['plateType'] then
                    str = str..' [Selected]'
                end
                if Menu.Button(str, '$'..comma_value(CalculatePrice(class, 'plateType', moddedData['plateType']))) then
                    moddedData['plateType'] = v[2]
                end
            end

            SetVehicleNumberPlateTextIndex(veh, plateTypes[Menu.ActiveOption][2])
        elseif Menu.CurrentMenu == 'Extras' then

            for i=1,14 do
                if DoesExtraExist(veh, i) then
                    local on = IsVehicleExtraTurnedOn(veh, i)
                    if Menu.CheckBox('Extra: '..i, on) then
                        if on then
                            SetVehicleExtra(veh, i, 1)
                            moddedData['extras'][i] = 1
                        else
                            SetVehicleExtra(veh, i, 0)
                            moddedData['extras'][i] = 0
                        end
                    end
                end
            end
        elseif Menu.CurrentMenu == 'Checkout' then

            local total = 0
            for k,v in pairs(moddedData) do
                if v ~= startData[k] and json.encode(v) ~= json.encode(startData[k]) then
                    local string = (k ~= 'extras' and k ~= 'neon' and type(v) ~= 'table') and GetLabelText(GetModTextLabel(veh, k, v)) or k
                    if k == 'tint' then
                        --string = 'Tint: '..tints[v+1]
                    elseif k == 'paint' then
                        string = 'Primary Color: '..VehicleColors[tostring(moddedData['paint'])]
                    elseif k == 'paintCustom' then
                        string = 'Custom Primary Color'
                    elseif k == 'paint2Custom' then
                        string = 'Custom Secondary Color'
                    elseif k == 'paint2' then
                        string = 'Secondary Color: '..VehicleColors[tostring(moddedData['paint2'])]
                    elseif k == 'pearl' then
                        string = 'Pearl Color: '..VehicleColors[tostring(moddedData['pearl'])]
                    elseif k == 'wheelColor' then
                        string = 'Wheel Color: '..VehicleColors[tostring(moddedData['wheelColor'])]
                    elseif k == 11 then
                        string = 'EMS Upgrade Level '..moddedData[11]+1
                    elseif k == 12 then
                        string = customTitles[12][moddedData[12]+2]
                    elseif k == 13 then
                        string = customTitles[13][moddedData[13]+2]
                    elseif k == 15 then
                        string = customTitles[15][moddedData[15]+2]
                    elseif k == 'turbo' then
                        string = 'Turbo '..ToText(moddedData['turbo'])
                    elseif k == 'xenon' then
                        string = 'Xenon '..ToText(moddedData['xenon'])
                    elseif k == 'plate' then
                        string = 'Plate: '..moddedData['plate']
                    elseif k == 'wheeltype' then
                        string = 'New Rims'
                    elseif k == 'livery' then
                        string = 'Paint Based Livery'
                    else
                        string = k
                    end

                    if Menu.Button(string, '$'..comma_value(CalculatePrice(class, k, v))) then
                        moddedData[k] = startData[k]
                        SetVehicleData(veh, json.encode(moddedData))
                    end
                    total = total + CalculatePrice(class, k, v)
                end
            end

            if total > 0 then
                Menu.EmptyButton()
                if Menu.Button('Checkout', '$'..comma_value(total)) then
                    if Promise('LSC:ModVehicle', startData, moddedData, GetPlate(veh), class, shopID, VehToNet(veh)) then
                        startData = moddedData
                        Menu.CloseMenu()
                    end
                end

                if canCustomize then
                    if Menu.Button('Checkout (Store Discount)', '$'..comma_value(math.floor(total * 0.6))) then
                        if Promise('LSC:ModVehicle', startData, moddedData, GetPlate(veh), class, shopID, VehToNet(veh)) then
                            startData = moddedData
                            Menu.CloseMenu()
                        end
                    end
                end
            end

        else
            if currentMod then
                if not wasInMenu then
                    Menu.ActiveOption = startData[currentMod] + 2
                    wasInMenu = true
                end
                SetVehicleMod(veh, currentMod, Menu.ActiveOption - 2 - (currentMod == 23 and 1 or 0))

                if currentMod == 23 then
                    Menu.SliderStep('Wheel Type', 0, 8, 1, moddedData['wheeltype'], function(current)
                        current = math.floor(current)
                        if current ~= moddedData['wheeltype'] then
                            moddedData['wheeltype'] = current
                            SetVehicleWheelType(veh, current)
                        end
                    end, wheels[moddedData['wheeltype']])
                end

                for i=-1, GetNumVehicleMods(veh, currentMod) - 1 do
                    local str = GetLabelText(GetModTextLabel(veh, currentMod, i))

                    if customTitles[currentMod] then
                        str = customTitles[currentMod][i + 2]
                    end

                    if str == 'NULL' then
                        str = 'None'
                    end

                    if startData[currentMod] == i then
                        str = str..' [Owned]'
                    elseif moddedData[currentMod] == i then
                        str = str..' [Selected]'
                    end

                    if Menu.Button(str, '$'..comma_value(CalculatePrice(class, currentMod, i))) then
                        moddedData[currentMod] = i
                    end
                end
            end
        end

        Menu.Display(100)
    end

    if openedCustom then
        SetVehicleData(veh, json.encode(startData), startData['plate'])
    end
    TriggerServerEvent('LSC:Clear')
end

RegisterNetEvent('LSC:Fix')
AddEventHandler('LSC:Fix', function()
    local veh = GetVehiclePedIsIn(Shared.Ped, false)
    SetVehicleFixed(veh)
    SetVehicleDirtLevel(veh, 0.0)
    SetVehicleEngineHealth(veh, 1000.0)
    SetVehicleBodyHealth(veh, 1000.0)
    TriggerServerEvent('Vehicle.UpdateHealth', VehToNet(veh), GetVehicleEngineHealth(veh), GetVehicleBodyHealth(veh))
end)

local promList = {}
RegisterNetEvent('GetVehicleOwner')
AddEventHandler('GetVehicleOwner', function(cid, id)
    promList[id]:resolve(cid == MyCharacter.id)
end)

function ToText(bool)
    if bool then
        return 'Added'
    end

    return 'Removed'
end


function GetOwner(plate)
    local bool = promise:new()
    local id = #promList + 1
    promList[id] = bool
    TriggerServerEvent('GetVehicleOwner', plate, id)
    return Citizen.Await(bool)
end

exports('AtRepair', function()
    local pos = GetEntityCoords(Shared.Ped)
    for k,v in pairs(repairLocations) do
        if Vdist4(pos, v.Position) <= 50.0 then
            return k
        end
    end
end)

exports('Customize', LSC_Menu)

AddEventHandler('InspectVehicle', function(ent)
    local data = GetVehicleData(ent)
    local menu = {
        {title = 'Engine: '..(customTitles[11][data[11] + 2] or customTitles[11][1])},
        {title = 'Brakes: '..(customTitles[12][data[12] + 2] or customTitles[12][1])},
        {title = 'Transmission: '..(customTitles[13][data[13] + 2] or customTitles[13][1])},
        {title = 'Suspension: '..(customTitles[15][data[15] + 2] or customTitles[15][1])},
        {title = 'Armor: '..(customTitles[16][data[16] + 2] or customTitles[16][1]), hidden = data[16] == -1},
        {title = 'Turbo: '..(data.turbo == true and 'Installed' or 'None')},
        {title = 'NOS: '..(Entity(ent).state.nos ~= nil and 'Installed' or 'None')},
    }

    RunMenu(menu)
end)

AddEventHandler('Use:free_plate', function()
    if Shared.CurrentVehicle ~= 0 and Entity(Shared.CurrentVehicle).state.vin then
        local _plate = Shared.TextInput('New Plate', 8)
        if _plate ~= '' then
            _plate = PlateForString(_plate)
            if Promise('LSC:CheckPlate', _plate) then
                if exports['geo-shared']:Confirmation('Are you sure you want the plate "'.._plate..'" ?') then
                    Task.Run('ChangePlate', VehToNet(Shared.CurrentVehicle), _plate)
                end
            else
                TriggerEvent('Shared.Notif', 'Plate is not available')
            end
        end
    else
        TriggerEvent('Shared.Notif', 'You can not put a plate on this vehicle')
    end
end)