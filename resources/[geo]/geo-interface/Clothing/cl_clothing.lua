local blend = {}

local disallow
local canWear = {}
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

local propNames = {'Glass', 'Ear', nil, nil, nil, 'Watch', 'Bracelt'}
MiscClothing = {}
propNames[0] = 'Hat'

local clothingNames = {[0] = 'Face', 'Mask', 'Hair', 'Torso', 'Leg', 'Parachute', 'Shoes', 'Accessories', 'Undershirt', 'Armor', 'Badge', 'Torso 2'}
local featureNames = {'Nose Width', 'Nose Peak Height', 'Nose Peak Length', 'Nose Bone High', 'Nose Peak Lowering', 'Nose Bone Twist', 'Eyebrow High', 'Eyebrow Forward', 'Cheek Bone High', 'Cheeck Bone Width', 'Cheeks Width', 'Eye Opening', 'Lip Thickness', 'Jaw Bone Width', 'Jaw Bone Back Length', 'Chimp Bone Lowering', 'Chimp Bone Length', 'Chimp Bone Width', 'Chimp Hole', 'Neck Thickness'}
local overlayNames = {'Blemishes', 'Facial Hair', 'Eyebrows', 'Age', 'Makeup', 'Blush', 'Complexion', 'Sun Damage', 'Lipstick', 'Moles', 'Chest Hair', 'Body Blemishes', 'Body Blemishes'}
local hasColors = {[1] = 1, [2] = 1, [4] = 1, [5] = 2, [8] = 2, [10] = 1}
_clothingOpen = false

Menu.CreateMenu('Clothing', 'Customization')
Menu.CreateSubMenu('Outfits', 'Clothing', 'Outfits')

local headCam

local dio = false
local _cam
local clothesList = {}

exports('ClothingMenu', function()
    GetClothing()
    canWear = {}
    if MyCharacter then
        local clothing = json.decode(MyCharacter.clothing)
        exports['geo']:LoadClothing(clothing)
    else
        exports['geo']:LoadClothing(GetClothing())
    end
    _clothingOpen = true
    local options = {}
    local outfits = Task.Run('Clothing.GetOutfits')
    options.clothing = {}
    options.props = {}
    local maxTex = {}
    clothesList = {}

    for i=0,11 do
        local max = GetNumberOfPedDrawableVariations(Shared.Ped, i)
        if clothesList[i] == nil then clothesList[i] = {} end

        for n=1,max do
            if IsAllowedToWear(i, n, 0) then
                table.insert(clothesList[i], n)
            end
        end

        maxTex[i] = {}
        for n = 0, #clothesList[i] do
            maxTex[i][n] = GetNumberOfPedTextureVariations(Shared.Ped, i, clothesList[i][n]) - 1
        end

        local current
        local _variation = GetPedDrawableVariation(Shared.Ped, i)
        for k,v in pairs(clothesList[i]) do
            if v == _variation then
                current = k
                break
            end
        end

        if #clothesList[i] >= 1 then
            options.clothing[i] = {
                min = 0, 
                max = #clothesList[i] - 1, 
                current = current or 0, 
                texture = GetPedTextureVariation(Shared.Ped, i), 
                maxTex = maxTex[i]
            }
        end
    end

    local maxProp = {}
    for i=0,7 do
        maxProp[i] = {}
        local max = GetNumberOfPedPropDrawableVariations(Shared.Ped, i)
        if max > 0 then

            for n = 0, max do
                maxProp[i][n] = GetNumberOfPedPropTextureVariations(Shared.Ped,i, n) - 1
            end

            options.props[i] = {
                min = -1, 
                max = max - 1, 
                current = GetPedPropIndex(Shared.Ped, i), 
                texture = GetPedPropTextureIndex(Shared.Ped, i), 
                maxTex = maxProp[i]
            }
        end
    end

    if FreemodePed(Shared.Ped)then
        options.face = {}
        for i=0,19 do
            options.face[i] = {
                min = -10, 
                max = 10, 
                current = GetPedFaceFeature(Shared.Ped, i) * 10, 
            }
        end

        options.overlay = {}

        table.insert(options.overlay, {
            min = 0,
            max = 64,
            current = GetPedHairColor(Shared.Ped),
            id = -1,
            event = 'HairColor',
            display = 'Hair Color',
        })

        table.insert(options.overlay, {
            min = 0,
            max = 64,
            current = GetPedHairHighlightColor(Shared.Ped),
            id = -1,
            event = 'HairHighlight',
            display = 'Hair Highlight Color',
        })

        table.insert(options.overlay, {
            min = 0,
            max = 64,
            current = GetPedEyeColor(Shared.Ped),
            id = -1,
            display = 'Eye Color',
            event = 'EyeColor',
        })

        for i=0,12 do
            local found, ovly, cType, fColor, SCOLOR, opac = GetPedHeadOverlayData(PlayerPedId(), i)

            table.insert(options.overlay, {
                min = -1.0,
                max = GetNumHeadOverlayValues(i) - 1,
                current = HeadOverlayDraw[i],
                id = i,
                event = 'SetPedHeadOverlay',
            })

            if hasColors[i] then
                table.insert(options.overlay, {
                    min = 0,
                    max = 64,
                    current = SCOLOR,
                    id = i,
                    event = 'SetPedHeadOverlayColor',
                    name = 'Color'
                })
            end
            
            table.insert(options.overlay, {
                min = 0,
                max = 10,
                step = 1,
                current = math.floor(HeadOverlayOpacity[i] * 10),
                id = i,
                event = 'SetPedHeadOpacity',
                name = 'Opacity'
            })
        end
    
        options.blend = {}
       --[[  local val = exports['hbw']:GetHeadBlendData(PlayerPedId())
        blend = {val.FirstFaceShape, val.SecondFaceShape, val.ThirdFaceShape, val.FirstSkinTone, val.SecondSkinTone, val.ThirdSkinTone, val.ParentFaceShapePercent, val.ParentSkinTonePercent, val.ParentThirdUnkPercent, val.IsParentInheritance}
 ]]
        blend = {GetHeadBlendData()}
        SetPedHeadBlendData(ped, blend[1], blend[2], blend[3], blend[4], blend[5], blend[6], blend[7], blend[8], blend[9], blend[10])

        options.blend[1] = {
            min = 0,
            max = 45,
            current = blend[1],
            id = 1,
            name = 'Face: Mother'
        }

        options.blend[2] = {
            min = 0,
            max = 45,
            current = blend[2],
            id = 2,
            name = 'Face: Father'
        }

        options.blend[3] = {
            min = 0,
            max = 10,
            current = blend[7] * 10,
            id = 7,
            name = 'Face: Mix',
            step = 1
        }

        options.blend[4] = {
            min = 0,
            max = 45,
            current = blend[4],
            id = 4,
            name = 'Skin: Father'
        }

        options.blend[5] = {
            min = 0,
            max = 45,
            current = blend[5],
            id = 5,
            name = 'Skin: Mother'
        }

        options.blend[6] = {
            min = 0,
            max = 10,
            current = blend[8] * 10,
            id = 8,
            name = 'Skin: Inheritance',
            step = 1
        }
    end

    UIFocus(true, true, '~INPUT_SELECT_WEAPON~ Close ~INPUT_225B6AB8~ Move Camera', true)
    SendNUIMessage({
        interface = 'clothing',
        options = options,
        outfits = outfits,
        showFace = FreemodePed(Shared.Ped),
        char = MyCharacter ~= nil
    })

    local heading = GetEntityHeading(Shared.Ped)
    while _clothingOpen do
        InvalidateIdleCam()
        if (not _cam) and (not dio) then
            SetNuiFocus(true, true)
        end

        SetEntityHeading(Shared.Ped, heading)
        TaskLookAtCoord(Shared.Ped, GetOffsetFromEntityInWorldCoords(Shared.Ped, 0.0, 5.0, 0.0), 1000, 1, 1)
        Wait(100)
    end

    DestroyCam(headCam)
    RenderScriptCams(0, 0, 250, 1, 1)
    UIFocus(false, false)
    if disallow then disallow = disallow.stop() end
    return GetClothing()
end)

RegisterNUICallback('Clothing.Change', function(data, cb)
    Wait(0)
    --if not IsAllowedToWear(tonumber(data.clothing), tonumber(data.drawable), tonumber(data.texture)) then return end
    --IsAllowedToWear(tonumber(data.clothing), tonumber(data.drawable), tonumber(data.texture))
    SetPedComponentVariation(Shared.Ped, tonumber(data.clothing), clothesList[tonumber(data.clothing)][tonumber(data.drawable)], tonumber(data.texture), 0)
    cb()
end)

RegisterNUICallback('Prop.Change', function(data, cb)
    SetPedPropIndex(Shared.Ped, tonumber(data.clothing), tonumber(data.drawable), tonumber(data.texture), 0)

    if tonumber(data.drawable) == -1 then
        ClearPedProp(Shared.Ped, tonumber(data.clothing))    
    end
    cb()
end)

RegisterNUICallback('Blend.Change', function(data, cb)
    blend[tonumber(data.clothing)] = tonumber(data.drawable)

    if data.step then
        blend[tonumber(data.clothing)] = (tonumber(data.drawable) / 10) + 0.0
    end

    SetPedHeadBlendData(Shared.Ped, blend[1], blend[2], blend[3], blend[4], blend[5], blend[6], blend[7], blend[8], blend[9], blend[10])
    cb()
end)

RegisterNUICallback('Face.Change', function(data, cb)
    SetPedFaceFeature(Shared.Ped, tonumber(data.clothing), (tonumber(data.drawable) / 10) + 0.0)
    cb()
end)

RegisterNUICallback('Overlay.Change', function(data, cb)
    if data.data.event == 'SetPedHeadOverlay' then
        HeadOverlayDraw[data.data.id] = math.floor(tonumber(data.drawable))
        SetPedHeadOverlay(Shared.Ped, tonumber(data.data.id), HeadOverlayDraw[data.data.id], HeadOverlayOpacity[data.data.id])
    elseif data.data.event == 'SetPedHeadOpacity' then
        HeadOverlayOpacity[data.data.id] = (tonumber(data.drawable) / 10) + 0.0
        SetPedHeadOverlay(Shared.Ped, tonumber(data.data.id), HeadOverlayDraw[data.data.id], HeadOverlayOpacity[data.data.id])
    elseif data.data.event == 'SetPedHeadOverlayColor' then
        HeadOverlayTexture[data.data.id] = math.floor(tonumber(data.drawable))
        SetPedHeadOverlayColor(Shared.Ped, data.data.id, hasColors[data.data.id], HeadOverlayTexture[data.data.id], 1)
    elseif data.data.event == 'HairColor' then
        SetPedHairColor(Shared.Ped, math.floor(tonumber(data.drawable)), GetPedHairHighlightColor(Shared.Ped))
        MiscClothing.HairColor = math.floor(tonumber(data.drawable))
    elseif data.data.event == 'HairHighlight' then
        SetPedHairColor(Shared.Ped, MiscClothing.HairColor, math.floor(tonumber(data.drawable)))
    elseif data.data.event == 'EyeColor' then
        SetPedEyeColor(Shared.Ped, math.floor(tonumber(data.drawable)))
    end
    cb()
end)

RegisterNUICallback('BagOutfit', function(data, cb)
    dio = true
    _cam = true
    local newClothes = {}
    for i=1,11 do
        if i ~= 2 then
            newClothes[i] = {Drawable = GetPedDrawableVariation(Shared.Ped, i), Texture = GetPedTextureVariation(Shared.Ped, i)}
        end
    end
    
    local val = exports['geo-shared']:Dialogue({
        {
            placeholder = 'Name',
            title = 'Give your old clothes a name',
            image = 'person'
        },
    })
    dio = false
    _cam = false
    newClothes.Name = val[1]
    newClothes.Model = GetEntityModel(Shared.Ped)
    Task.RunRemote('BuyOutfit', newClothes)
    cb(true)
end)

RegisterNUICallback('Clothing.Camera', function(data, cb)
    _cam = true
    FreezeEntityPosition(Shared.Ped, true)
    UIFocus(false, false)
    Wait(100)
    DisableControlAction(0, 24, true)
    for i=30,35 do
        DisableControlAction(0, i, true)
    end
    SetControlNormal(0, 24, 1.0)
    while IsDisabledControlPressed(0, 24) do
        Wait(0)
        Shared.DisableWeapons()
        for i=30,35 do
            DisableControlAction(0, i, true)
        end
    end
    _cam = false
    UIFocus(true, true)
    FreezeEntityPosition(Shared.Ped, false)
    cb()
end)

RegisterKeyMapping('+clothingCam', '[Clothing Store] Camera', 'keyboard', 'LMENU')

RegisterCommand('+clothingCam', function(source, args, raw)
    if not ControlModCheck(raw) then return end
    TriggerEvent('ClothingCam', true)
    if _clothingOpen then
        _cam = true
        SetNuiFocus(false, false)

        while _cam do
            Wait(0)
            Shared.DisableWeapons()
            for i=0,6 do
                EnableControlAction(0, i, true)
            end
            for i=30,35 do
                DisableControlAction(0, i, true)
            end
        end
    end
end)

RegisterCommand('-clothingCam', function()
    TriggerEvent('ClothingCam', false)
    if _clothingOpen then
        _cam = false
    end
end)

RegisterCommand('loadchar', function()
    local str = Shared.TextInput('Insert Copied Data', 99999)
    local blend = json.decode(str)
    exports['geo']:LoadClothing(blend)
end)

RegisterCommand('exportchar', function()
    local data = GetClothing()
    SendNUIMessage({interface = 'copy', data = json.encode(data)})
end)

RegisterNUICallback('Clothing.Done', function(data, cb)
    _clothingOpen = false
    cb()
end)

RegisterNUICallback('Clothing.LoadOutfit', function(data, cb)
    exports['geo']:LoadClothing(data.clothing)
    cb()
end)

RegisterNUICallback('Clothing.SaveOutfit', function(data, cb)
    ExecuteCommand('outfits save '..data.name)
    Wait(500)
    SendNUIMessage({
        interface = 'clothing.outfits',
        outfits = Task.Run('Clothing.GetOutfits')
    })
    cb()
end)

RegisterNUICallback('Clothing.HeadCam', function(data, cb)
    if headCam then
        DestroyCam(headCam)
        headCam = nil
        RenderScriptCams(0, 1, 250, 1, 1)
    else
        headCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
        SetCamCoord(headCam, GetOffsetFromEntityInWorldCoords(Shared.Ped, 0.0, 0.4, 0.7))
        SetCamRot(headCam, GetEntityRotation(Shared.Ped) + vec(0, 0, 180))
        RenderScriptCams(1, 1, 250, 1, 1)
    end
end)

local male = GetHashKey('mp_m_freemode_01')
local female = GetHashKey('mp_f_freemode_01')
function FreemodePed(ped)
    local model = GetEntityModel(ped)

    if model == male or model == female then
        return true
    end

    return false
end

function GetClothing(OutfitName, id)
    local ped = PlayerPedId()
    for i=0, 11 do
        DrawableClothes[i] = GetPedDrawableVariation(ped, i)
        TextureClothes[i] = GetPedTextureVariation(ped, i)
        PalleteClothes[i] = GetPedPaletteVariation(ped, i)
    end

    for i=0,7 do
        DrawableProp[i] = GetPedPropIndex(ped, i)
        TextureProp[i] =  GetPedPropTextureIndex(ped, i)
    end

    for i=0,19 do
        FaceFeature[i] = GetPedFaceFeature(ped, i)
    end


    for i=0,12 do
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
                Texture = TextureClothes,
            },
            Props = {
                Drawable = DrawableProp,
                Texture = TextureProp,
            },
            Overlay = {
                Drawable = HeadOverlayDraw,
                Texture = HeadOverlayTexture,
                Opacity = HeadOverlayOpacity,
            },
            FaceData = blend,
            FaceShape = FaceFeature,
            HairColor = hairColor,
            EyeColor = eyeColor,
            Name = OutfitName or 'Unset',
            Model = GetEntityModel(ped),
            HairHighlight = hairHighlight,
            ID = id or -1
        }
    else
        MiscClothing = {
            Clothing = {
                Drawable = DrawableClothes,
                Texture = TextureClothes,
            },
            Props = {
                Drawable = DrawableProp,
                Texture = TextureProp,
            },
            Name = OutfitName or 'Unset',
            Model = GetEntityModel(ped),
            ID = id or -1
        }
    end

    local val = json.decode(json.encode(MiscClothing))
    return val
end

RegisterNUICallback('CreateOutift', function(data, cb)
    dio = true
    _cam = true
    local outfit = exports['geo-shared']:Dialogue({
        {
            title = 'Outfit Name',
            placeholder = 'Set Outfit Name',
            image = 'person'
        }
    })

    local outfits
    if outfit[1] then
        outfits = Task.Run('Outfits.Save', json.encode(GetClothing(outfit[1])), outfit[1])
    else
        outfits = Task.Run('Clothing.GetOutfits')
    end
    dio = false
    _cam = false
    cb(outfits)
end)

RegisterNUICallback('DeleteOutfit', function(data, cb)
    local outfits = Task.Run('DeleteOutfit', data.outfit)
    cb(outfits)
end)

RegisterCommand('outfits', function(source, args)
    if MyCharacter then
        if args[1] == 'save' then
            if args[2] then
                Task.Run('Outfits.Save', json.encode(GetClothing(args[2])), args[2])
            end
        elseif args[1] == 'delete' then
            if args[2] then
                TriggerServerEvent('Outfits.Delete', args[2])
            end
        end
    end
end)

local clothesRequireMents = {
    [GetHashKey('mp_m_freemode_01')] = {
        ['clothing'] = {
            [8] = {
            },
            [9] = {
            },
            [11] = {
            }
        },
    },
    [GetHashKey('mp_f_freemode_01')] = {
        ['clothing'] = {
            [8] = {
            },
            [9] = {
            },
            [11] = {
            }
        },
    }
}

function IsAllowedToWear(pID, pDrawable, pTexture)
    --print('ID: '..pID, 'Drawble: '..pDrawable)
    local model = GetEntityModel(Shared.Ped)
    if clothesRequireMents[model] and clothesRequireMents[model]['clothing'][pID] and clothesRequireMents[model]['clothing'][pID][pDrawable] then
        local value = clothesRequireMents[model]['clothing'][pID][pDrawable]
        local allowed = false

        if MyCharacter ~= nil then
            if value == 'Police' then allowed = exports['geo-es']:IsPolice(MyCharacter.id) end
            if value == 'EMS' then allowed = exports['geo-es']:IsEMS(MyCharacter.id) end
            if value == 'ES' then allowed = exports['geo-es']:IsEs(MyCharacter.id) end
            if value:match('Business') then
                local business = SplitString(value, ':')[2]
                allowed = exports['geo-guilds']:GuildAuthority(business, MyCharacter.id) > 0
            end
        end

        return allowed
    end

    return true
end