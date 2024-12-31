RegisterNetEvent('LocalChatMessage')
AddEventHandler('LocalChatMessage', function(type, message, sender, atEnd, id, distance)
    local source = source
    local char = exports['geo']:Char(source)
    TriggerClientEvent('LocalChatMessage', -1, type, message, sender, atEnd, id, distance, char.interior)
end)

RegisterNetEvent('Chat.LocalMessage')
AddEventHandler('Chat.LocalMessage', function(prefix, message, template, pos, distance, bypass)
    local source = source
    local char = exports['geo']:Char(source)

    if prefix == '[ID]' then
        message[6] = SQL('SELECT clothing from characters where id = ?', message[4])[1].clothing
    end

    TriggerClientEvent('Chat.LocalMessage', -1, prefix, message, template, pos, distance, bypass, char.interior, NetworkGetNetworkIdFromEntity(GetPlayerPed(source)))
end)

RegisterNetEvent('Chat.Message.Internal')   
AddEventHandler('Chat.Message.Internal', function(message)
    local source = source
    Console('[Chat]', GetPlayerName(source)..': '..message)
end)

RegisterNetEvent('me')
AddEventHandler('me', function(message)
    local source = source
    TriggerClientEvent('me', -1, source, message)
end)

RegisterCommand('ooc', function(source, args)
    local char = GetCharacter(source)
    if char then
        TriggerClientEvent('Chat.Message', -1, '[OOC] '..GetName(char), table.concat(args, ' '), 'ooc')
    end
end)