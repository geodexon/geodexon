local tax = GetResourceKvpInt('taxval')

RegisterNetEvent('Mayor.GetTax')
AddEventHandler('Mayor.GetTax', function()
    local source = source
    TriggerClientEvent('_Mayor.GetTax', source, tax)
end)

RegisterCommand('settax', function(source, args)
    if tonumber(args[1]) and exports['geo-guilds']:GuildAuthority('CITY', GetCharacter(source).id) > 50000 then
        tax = math.floor(math.abs(tonumber(args[1])))
        tax = tax > 100 and 100 or tax
        tax = tax < 1 and 1 or tax
        SetResourceKvpInt('taxval', tax)
        TriggerClientEvent('_Mayor.GetTax', -1, tax)
        TriggerClientEvent('Shared.Notif', -1, 'Tax has been set to '..tax..'%')
    end
end)

RegisterCommand('tax', function(source, args)
    TriggerClientEvent('Shared.Notif', source, 'Current Tax Rate: '..tax..'%')
end)

exports('GetTax', function()
    return tax
end)