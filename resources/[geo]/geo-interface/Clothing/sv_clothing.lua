Task.Register('Clothing.GetOutfits', function(source)
    local char = GetCharacter(source)
    if char then
        return SQL('SELECT * from outfits WHERE cid = ?', char.id)
    end
end)

Task.Register('Outfits.Save', function(source, outfit, name)
    local char = GetCharacter(source)
    if char then
        local found = SQL('SELECT outfit from outfits WHERE json_value(clothing, "$.Name") = ? and cid = ?', name, char.id)[1] ~= nil
        if not found then
            local count = SQL('SELECT COUNT(*) as res FROM outfits WHERE cid = ?', char.id)[1]
            if count.res <= 10 then
                SQL('INSERT INTO outfits (cid, clothing) VALUES (?, ?)', char.id, outfit)
                TriggerClientEvent('Shared.Notif', source, 'Outift: '..name..' Created')
            else
                TriggerClientEvent('Shared.Notif', source, 'You have too many outfits')
            end
        else
            SQL('UPDATE outfits SET clothing = ? WHERE json_value(clothing, "$.Name") = ? and cid = ?', outfit, name, char.id)
            TriggerClientEvent('Shared.Notif', source, 'Outift: '..name..' saved')
        end

        return SQL('SELECT * from outfits WHERE cid = ?', char.id)
    end
end)

Task.Register('DeleteOutfit', function(source, outfit, name)
    local char = GetCharacter(source)
    if char then
        SQL('DELETE FROM outfits WHERE outfit = ? and cid = ?', outfit, char.id)
        return SQL('SELECT * from outfits WHERE cid = ?', char.id)
    end
end)

RegisterNetEvent('Outfits.Delete')
AddEventHandler('Outfits.Delete', function(name)
    local source = source
    local char = GetCharacter(source)
    if char then
        SQL('DELETE FROM outfits WHERE json_value(clothing, "$.Name") = ? and cid = ?', name, char.id)
    end
end)