local compList = {}
compList['mpairraces_overlays'] = json.decode(LoadResourceFile(GetCurrentResourceName(), 'items/mpairraces_overlays.json'))
compList['mpbeach_overlays'] = json.decode(LoadResourceFile(GetCurrentResourceName(), 'items/mpbeach_overlays.json'))
compList['mpbiker_overlays'] = json.decode(LoadResourceFile(GetCurrentResourceName(), 'items/mpbiker_overlays.json'))
compList['mpbusiness_overlays'] = json.decode(LoadResourceFile(GetCurrentResourceName(), 'items/mpbusiness_overlays.json'))
compList['mpchristmas2_overlays'] = json.decode(LoadResourceFile(GetCurrentResourceName(), 'items/mpchristmas2_overlays.json'))
compList['mpchristmas2017_overlays'] = json.decode(LoadResourceFile(GetCurrentResourceName(), 'items/mpchristmas2017_overlays.json'))
compList['mpchristmas2018_overlays'] = json.decode(LoadResourceFile(GetCurrentResourceName(), 'items/mpchristmas2018_overlays.json'))
compList['mpgunrunning_overlays'] = json.decode(LoadResourceFile(GetCurrentResourceName(), 'items/mpgunrunning_overlays.json'))
compList['mphipster_overlays'] = json.decode(LoadResourceFile(GetCurrentResourceName(), 'items/mphipster_overlays.json'))
compList['mpimportexport_overlays'] = json.decode(LoadResourceFile(GetCurrentResourceName(), 'items/mpimportexport_overlays.json'))
compList['mplowrider_overlays'] = json.decode(LoadResourceFile(GetCurrentResourceName(), 'items/mplowrider_overlays.json'))
compList['mplowrider2_overlays'] = json.decode(LoadResourceFile(GetCurrentResourceName(), 'items/mplowrider2_overlays.json'))
compList['mpluxe_overlays'] = json.decode(LoadResourceFile(GetCurrentResourceName(), 'items/mpluxe_overlays.json'))
compList['mpluxe2_overlays'] = json.decode(LoadResourceFile(GetCurrentResourceName(), 'items/mpluxe2_overlays.json'))
compList['mpsmuggler_overlays'] = json.decode(LoadResourceFile(GetCurrentResourceName(), 'items/mpsmuggler_overlays.json'))
compList['mpstunt_overlays'] = json.decode(LoadResourceFile(GetCurrentResourceName(), 'items/mpstunt_overlays.json'))
--compList['mpvinewood_overlays'] = json.decode(LoadResourceFile(GetCurrentResourceName(), 'items/mpvinewood_overlays.json'))
compList['multiplayer_overlays'] = json.decode(LoadResourceFile(GetCurrentResourceName(), 'items/multiplayer_overlays.json'))


local posList = {
    vector3(1323.77, -1652.42, 52.28),
    vector3(-1153.56, -1426.05, 4.95),
    vector3(322.29, 181.16, 103.59),
    vector3(1863.81, 3748.63, 33.03),
    vector3(-293.7, 6199.86, 31.49)
}

exports('NearTattoo', function()
    local pos = GetEntityCoords(Shared.Ped)
    for k,v in pairs(posList) do
        if Vdist4(pos, v) <= 50.0 then
            return true
        end
    end
end)

local myList = {
    ['ZONE_LEFT_ARM'] = {},
    ['ZONE_RIGHT_ARM'] = {},
    ['ZONE_LEFT_LEG'] = {},
    ['ZONE_RIGHT_LEG'] = {},
    ['ZONE_TORSO'] = {},
    ['ZONE_HEAD'] = {},
}

local sliderList = {'ZONE_LEFT_ARM', 'ZONE_RIGHT_ARM', 'ZONE_LEFT_LEG', 'ZONE_RIGHT_LEG', 'ZONE_TORSO', 'ZONE_HEAD'}
local sliderNames = {'Left Arm', 'Right Arm', 'Left Leg', 'Right Leg', 'Body', 'Head'}
for k,v in pairs(json.decode(LoadResourceFile(GetCurrentResourceName(), 'items/new_overlays.json'))) do
    local var = v
    for a, b in pairs(myList) do
        if v.Zone:match(a) then
            var.dictionary = 'new_overlays'
            table.insert(myList[a], var)
            break
        end
    end
end

for k,v in pairs(compList) do
    for key,val in pairs(v) do
        local var = val

        for a, b in pairs(myList) do
            if val.Zone:match(a) then
                var.dictionary = k
                table.insert(myList[a], var)
                break
            end
        end
    end
end

for k,v in pairs(posList) do
    local blip = AddBlipForCoord(v)
    SetBlipSprite(blip, 75)
    SetBlipAsShortRange(blip, true)
end

Menu.CreateMenu('Tattoo', 'Tattoo')
AddEventHandler('Tattoo:Shop', function()
    local pos = GetEntityCoords(Shared.Ped)
    for k,v in pairs(posList) do
        if Vdist4(pos, v) <= 50.0 then
            Menu.OpenMenu('Tattoo')
            local myTattoos = {}
            local ped = Shared.Ped
            local model = GetHashKey('mp_f_freemode_01')
            local myModel = GetEntityModel(Shared.Ped)

            if model == myModel then
                SetPedComponentVariation(ped, 11, 15, 0, 1)
                SetPedComponentVariation(ped, 4, 56, 0, 1)
                SetPedComponentVariation(ped, 3, 15, 0, 1)
                SetPedComponentVariation(ped, 8, 15, 0, 1)
            elseif myModel == GetHashKey('mp_m_freemode_01') then
                SetPedComponentVariation(ped, 11, 15, 0, 1)
                SetPedComponentVariation(ped, 4, 14, 0, 1)
                SetPedComponentVariation(ped, 3, 15, 0, 1)
                SetPedComponentVariation(ped, 8, 15, 0, 1)
            end

            local char = MyCharacter
            if MyCharacter.tattoos then
                myTattoos = json.decode(char.tattoos)
            end
        
            local lastTattoos = json.decode(json.encode(myTattoos))
            local slider = 1
            local option = Menu.ActiveOption - 1
            local IwantThis = {}
            local offset = 0 
            local added = 0
            for k,v in pairs(myTattoos) do
                for key,val in pairs(v) do
                    for n in pairs(val) do
                        added = added + 1
                    end
                end
            end
            while Menu.CurrentMenu do
                Wait(0)

                pos = GetEntityCoords(Shared.Ped)
                if Vdist2(pos, v) > 50.0 then
                    ClearPedDecorations(Shared.Ped)
                    for a,b in pairs(lastTattoos) do
                        for key,val in pairs(b) do
                            for n in pairs(val) do
                                SetPedDecoration(Shared.Ped, GetHashKey(key), GetHashKey(n))
                            end
                        end
                    end
                    return
                end

                
                Menu.Slider('Index:', sliderList, slider, function(current)
                    slider = current
                end, sliderNames[slider])
                for k,v in pairs(myList[sliderList[slider]]) do
                    local str = ''
                    if myModel == model then
                        str = v.HashNameFemale
                        if str == '' then
                            str = v.HashNameMale
                        end
                    else
                        str = v.HashNameMale
                        if str == '' then
                            str = v.HashNameFemale
                        end
                    end
                    if Menu.Button(v.LocalizedName, IwantThis[v.LocalizedName]) then
        
                        local amount = 0
                        for k,v in pairs(myTattoos) do
                            for key,val in pairs(v) do
                                for n in pairs(val) do
                                    amount = amount + 1
                                end
                            end
                        end
                        
                        if myTattoos[v.Zone] == nil then
                            myTattoos[v.Zone] = {}
                            lastTattoos[v.Zone] = {}
                        end
                        if myTattoos[v.Zone][v.dictionary] == nil then
                            myTattoos[v.Zone][v.dictionary] = {}
                            lastTattoos[v.Zone][v.dictionary] = {}
                        end
        
                        if model == myModel then
                            if myTattoos[v.Zone][v.dictionary][v.HashNameFemale] == nil then
                                if v.HashNameFemale == '' then
                                    if amount <= 30 then
                                        myTattoos[v.Zone][v.dictionary][v.HashNameMale] = v.HashNameMale
                                        SetPedDecoration(Shared.Ped, GetHashKey(v.dictionary), GetHashKey(v.HashNameMale))
                                    end
                                else
                                    if amount <= 30 then
                                        myTattoos[v.Zone][v.dictionary][v.HashNameFemale] = v.HashNameFemale
                                        SetPedDecoration(Shared.Ped, GetHashKey(v.dictionary), GetHashKey(v.HashNameFemale))
                                    end
                                end
                            end
                        else
                            if myTattoos[v.Zone][v.dictionary][v.HashNameMale] == nil then
                                if v.HashNameMale == '' then
                                    if amount <= 30 then
                                        myTattoos[v.Zone][v.dictionary][v.HashNameFemale] = v.HashNameFemale
                                        SetPedDecoration(Shared.Ped, GetHashKey(v.dictionary), GetHashKey(v.HashNameFemale))
                                    end
                                else
                                    if amount <= 30 then
                                        myTattoos[v.Zone][v.dictionary][v.HashNameMale] = v.HashNameMale
                                        SetPedDecoration(Shared.Ped, GetHashKey(v.dictionary), GetHashKey(v.HashNameMale))
                                    end
                                end
                            end
                        end
                        
                        if IwantThis[v.LocalizedName] then
                            IwantThis[v.LocalizedName] = nil
                            if lastTattoos[v.Zone][v.dictionary][str] == nil then
                                if model == myModel then
                                    myTattoos[v.Zone][v.dictionary][v.HashNameFemale] = nil
                                    myTattoos[v.Zone][v.dictionary][v.HashNameMale] = nil
                                else
                                    myTattoos[v.Zone][v.dictionary][v.HashNameFemale] = nil
                                    myTattoos[v.Zone][v.dictionary][v.HashNameMale] = nil
                                end
        
                                if count == 0 then
                                    myTattoos[v.Zone][v.dictionary] = nil
                                end
                            end
                            ClearPedDecorations(Shared.Ped)
                            for a,b in pairs(myTattoos) do
                                for key,val in pairs(b) do
                                    for n in pairs(val) do
                                        SetPedDecoration(Shared.Ped, GetHashKey(key), GetHashKey(n))
                                    end
                                end
                            end
                        else
                            if amount <= 30 then
                                IwantThis[v.LocalizedName] = 'In Cart'
                            end
                        end
        
                        local count = 0
                        for ass in pairs(myTattoos[v.Zone][v.dictionary]) do
                            count = count + 1
                        end
        
                        if count == 0 then
                            myTattoos[v.Zone][v.dictionary] = nil
                        end
                    end
                end
        
                if (Menu.ActiveOption - 1 ~= option) then
                    if Menu.ActiveOption ~= 1 then
                        option = Menu.ActiveOption - 1
                        ClearPedDecorations(Shared.Ped)
        
                        for k,v in pairs(myTattoos) do
                            for key,val in pairs(v) do
                                for n in pairs(val) do
                                    SetPedDecoration(Shared.Ped, GetHashKey(key), GetHashKey(n))
                                end
                            end
                        end
        
                        if model == myModel then
                            if myList[sliderList[slider]][option].HashNameFemale == '' then
                                SetPedDecoration(Shared.Ped, GetHashKey(myList[sliderList[slider]][option].dictionary), GetHashKey(myList[sliderList[slider]][option].HashNameMale))
                            else
                                SetPedDecoration(Shared.Ped, GetHashKey(myList[sliderList[slider]][option].dictionary), GetHashKey(myList[sliderList[slider]][option].HashNameFemale))
                            end
                        else
                            if myList[sliderList[slider]][option].HashNameMale == '' then
                                SetPedDecoration(Shared.Ped, GetHashKey(myList[sliderList[slider]][option].dictionary), GetHashKey(myList[sliderList[slider]][option].HashNameFemale))
                            else
                                SetPedDecoration(Shared.Ped, GetHashKey(myList[sliderList[slider]][option].dictionary), GetHashKey(myList[sliderList[slider]][option].HashNameMale))
                            end
                        end
                    end
                end
        
                Menu.Display()
            end
            local amount = 0
            for k,v in pairs(myTattoos) do
                for key,val in pairs(v) do
                    for n in pairs(val) do
                        amount = amount + 1
                    end
                end
            end
        
            ClearPedDecorations(Shared.Ped)
            for k,v in pairs(myTattoos) do
                for key,val in pairs(v) do
                    for n in pairs(val) do
                        SetPedDecoration(Shared.Ped, GetHashKey(key), GetHashKey(n))
                    end
                end
            end
        
            Menu.OpenMenu('Tattoo')
            while Menu.CurrentMenu do
                Wait(0)
                if Menu.Button('Pay', '$'..GetPrice(math.abs((added - amount) * 150))) then
                    if Task.Run('Tatoos.Update', math.abs((added - amount) * 150), myTattoos) then
                        lastTattoos = myTattoos
                        Menu.CloseMenu()
                    end
                end
                Menu.Display()
            end
        
            ClearPedDecorations(Shared.Ped)
            for k,v in pairs(lastTattoos) do
                for key,val in pairs(v) do
                    for n in pairs(val) do
                        SetPedDecoration(Shared.Ped, GetHashKey(key), GetHashKey(n))
                    end
                end
            end

            local clothing = json.decode(MyCharacter.clothing)
            exports['geo']:LoadClothing(clothing)
        end
    end
end)

function CountKeys(tbl)
    local count = 0
    for k,v in pairs(tbl) do
        count = count + 1
    end
    return count
end