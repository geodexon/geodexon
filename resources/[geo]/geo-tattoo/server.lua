Task.Register('Tatoos.Update', function(source, amount, data)
    local char = GetCharacter(source)
    if exports['geo-eco']:DebitDefault(char, amount, 'Tattoos') then
        SQL('UPDATE characters SET tattoos = ? WHERE id = ?', json.encode(data), char.id)
        UpdateChar(source, 'tattoos', json.encode(data))
        return true
    end
end)