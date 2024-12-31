RegisterCommand('resurrect', function()
    if MyCharacter and MyCharacter.Duty == 'EMS' or MyCharacter.username then
        local ped = Shared.ClosestPed(5.0)
        if IsEntityDead(ped) and not IsPedAPlayer(ped) and not (GetPedType(ped) == 28) then
            Ressurect(ped)
        end
    end
end)

function Ressurect(ped)
    local dval = {}
    local DrawableClothes = {}
    local TextureClothes = {}
    local DrawableProp = {}
    local TextureProp = {}
    for i=0,11 do
        DrawableClothes[i] = GetPedDrawableVariation(ped, i)
        TextureClothes[i] = GetPedTextureVariation(ped, i)
    end
    for i=0,3 do
        DrawableProp[i] = GetPedPropIndex(ped, i)
        TextureProp[i] = GetPedPropTextureIndex(ped, i)
    end
    -------- NORMAL PEDS END HERE --------
    local DrawableOverlay = {}
    local TextureOverlay = {}
    local OverlayOpacity = {}
    local FacialVariations = {}
    local faceData
    local eyeColor = eyeSelected
    local hairColor = sHair
    dval = {
        Clothing = {
            Drawable = DrawableClothes,
            Texture = TextureClothes,
        },
        Props = {
            Drawable = DrawableProp,
            Texture = TextureProp,
        },
        Name = OutfitName,
        Model = GetEntityModel(ped)
    }
    local pos = GetEntityCoords(ped)
    TriggerServerEvent('DeleteEntity', PedToNet(ped))

    RequestModel(dval.Model)
    while not HasModelLoaded(dval.Model) do
        Wait(0)
    end

    local newPed = CreatePed(4, dval.Model, pos, 0.0, true, true)
    for i=0,11 do
        SetPedComponentVariation(newPed, i, dval.Clothing.Drawable[i], dval.Clothing.Texture[i], 1)
    end

    for i=0,3 do
        SetPedPropIndex(newPed, i, dval.Props.Drawable[i], dval.Props.Texture[i], 1)
    end
    TaskWanderStandard(newPed, 10.0, 10)
end

RegisterCommand('revive', function(source, args)
    local player = GetClosestPlayer(5.0)
    if player and MyCharacter.Duty == 'EMS' then
        TriggerEvent('revive', player)
    else
        if tonumber(args[1]) and MyCharacter.username then
            TriggerServerEvent('EMS.Revive', tonumber(args[1]), true)
        end
    end
end)

AddEventHandler('revive', function(id)
    ExecuteCommand('e mechanic4')
    for i=1,3 do
        if not Minigame(5) then
            ExecuteCommand('ec')
            return
        end
    end
    ExecuteCommand('ec')
    TriggerServerEvent('EMS.Revive', GetPlayerServerId(id))
end)

RegisterCommand('heal', function(source, args)
    if IsEMS(MyCharacter.id) then
        local player = GetClosestPlayer(5.0)
        if player then
            if not Minigame(20) then
                return
            end
            TriggerServerEvent('EMS.Heal', GetPlayerServerId(player))
        end
    end
end)

AddEventHandler('EMS.Heal', function(ped)
    LoadAnim("weapons@first_person@aim_rng@generic@projectile@thermal_charge@")
    TaskPlayAnim(Shared.Ped, "weapons@first_person@aim_rng@generic@projectile@thermal_charge@", "plant_floor", 1.0, -8, 5000, 51, 0, 0, 0, 0)
    if not exports['geo-shared']:ProgressSync('Healing', 5000) then
        return
    end
    TriggerServerEvent('EMS.Heal', GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped)))
end)

RegisterCommand('bodybag', function(source, args)
    if MyCharacter.Duty == 'Police' or MyCharacter.Duty == 'EMS' then
        local ped = Shared.ClosestPed(5.0)
        if ped ~= 0 and not IsPedAPlayer(ped) and IsEntityDead(ped) then
            TriggerServerEvent('DeleteEntity', PedToNet(ped))
        end
    end
end)

RegisterCommand('painkiller', function(source, args)
    if IsEMS(MyCharacter.id) and exports['geo-inventory']:HasItem('pain_killer') then
        local player = GetClosestPlayer(5.0)
        if player then
            if not Minigame(20) then
                return
            end
            TriggerServerEvent('EMS.Painkiller', GetPlayerServerId(player))
        end
    end
end)

RegisterNetEvent('EMS.Painkiller')
AddEventHandler('EMS.Painkiller', function()
    exports['geo-inventory']:AddBAC(0.8)
end)

RegisterNetEvent('EMS.KittyLitter')
AddEventHandler('EMS.KittyLitter', function(pos)
    RemoveDecalsInRange(pos.x, pos.y, pos.z, 5.0)
end)