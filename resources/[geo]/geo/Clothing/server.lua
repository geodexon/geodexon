RegisterNetEvent('Clothing:SaveData')
AddEventHandler('Clothing:SaveData', function(clothing)
    local source = source
    if Characters[source] then
        exports.ghmattimysql:execute('UPDATE characters SET clothing = @Clothing WHERE id = @Char', {
            Clothing = clothing,
            Char = Characters[source].id
        })
        --exports.ghmattimysql:execute('UPDATE outfits SET clothing = ? WHERE cid = ? and json_value(clothing, "$.Name") = ?', {clothing, Characters[source].id, json.decode(clothing).Name})

        UpdateCharacter(source, 'clothing', clothing)
    end
end)

RegisterNetEvent('ClothingStore')
AddEventHandler('ClothingStore', function(prom)
    local source = source
    TriggerClientEvent('ClothingStore', source, exports['geo-inventory']:RemoveItem('Player', source, 'dollar', 50))
end)

RegisterNetEvent('Clothing.GetOutfits')
AddEventHandler('Clothing.GetOutfits', function()
    local source = source
    local char = GetCharacter(source)
    if char then
        exports.ghmattimysql:execute('SELECT * from outfits WHERE cid = ?', {char.id}, function(res)
            TriggerClientEvent('Clothing.GetOutfits', source, res)
        end)
    end
end)

Task.Register('GiveMask', function(source, pDrawable, pTexture, pModel)
    local item = exports['geo-inventory']:InstanceItem('mask')
    item.Data.Drawable = tonumber(pDrawable)
    item.Data.Texture = tonumber(pTexture)
    item.Data.Model = tonumber(pModel)
    exports['geo-inventory']:AddItem('Player', source, 'mask', 1, item)
end)

Task.Register('ConsumeMask', function(source, pID)
    exports['geo-inventory']:RemoveItem('Player', source, pID, 1)
end)