luxuary = {}

CreateThread(function()
    SQL('DELETE FROM luxury_apartment WHERE DATEDIFF(NOW(), `date`) > 7 AND deposit - 5000 < 0')
    SQL('UPDATE luxury_apartment SET deposit = deposit - 5000, date = CURDATE() WHERE DATEDIFF(NOW(), `date`) > 7 AND deposit - 5000 >= 0')

    for k,v in pairs(GetPlayers()) do
        v = tonumber(v)
        local char = GetCharacter(v)
        if char then
            local hasLuxury = HasLuxury(char.id)
            if hasLuxury then
                TriggerClientEvent('Apartment.RentLuxury', v)
            end
        end
    end
end)

AddEventHandler('Login', function(char)
    local hasLuxury = HasLuxury(char.id)
    if hasLuxury then
        TriggerClientEvent('Apartment.RentLuxury', char.serverid)
    end
end)

RegisterNetEvent('Apartment.Login')
AddEventHandler('Apartment.Login', function(hasWoken)
    local source = source
    local char = GetCharacter(source)
    local hasLuxury = HasLuxury(char.id)
    local wentIn = false

    if not hasWoken then
        if char.lastproperty then
            local prop = json.decode(char.lastproperty)
            if prop[1] ~= 'Motel: '..char.id then
                if PropertyAllowed(prop[1], char.id) then
                    EnterProperty(source, prop[1], prop[2], true, prop[3])
                    wentIn = true
                else
                    SQL('UPDATE characters SET home = null, lastproperty = null WHERE id = ?', char.id)
                    UpdateChar(source, 'home', nil)
                    UpdateChar(source, 'lastproperty', nil)
                end
            end
        end
    end

    if hasLuxury then
        luxuary[char.id] = {title = 'Motel: '..char.id, Position = {-313.72, -1034.5, 31.03, 0.0},  interior = 'apartment_2'}
        if not hasWoken and not wentIn then
            EnterProperty(source, 'Motel: '..char.id, 'apartment_2', true, {-313.72, -1034.5, 31.03, 0.0})
        end
    else
        if char.motel then
            return
        end
    
        for k,v in pairs(Apartments) do
            if v.Available then
                v.Resident = char.id
                v.Available = false
                Console('[Motel]', Format('Motel %s has been taken', k))
                if not hasWoken and not wentIn then
                    EnterProperty(source, 'Motel: '..char.id, 'motel', true, {v.Position.x, v.Position.y, v.Position.z, v.Position.w})
                end
                UpdateChar(source, 'motel', k)
                break
            end
        end
    end
end)

RegisterNetEvent('Motel.Enter')
AddEventHandler('Motel.Enter', function()
    local source = source
    local char = GetCharacter(source)
    local hasLuxury = HasLuxury(char.id)

    if not hasLuxury then
        if Apartments[char.motel].Resident ~= char.id then
            TriggerClientEvent('Shared.Notif', source, 'Your reservation is over')
            UpdateChar(source, 'motel', nil)
            return
        end
    
        local v = Apartments[char.motel]
        EnterProperty(source, 'Motel: '..char.id, 'motel', true, {v.Position.x, v.Position.y, v.Position.z, v.Position.w})
    else
        luxuary[char.id] = {title = 'Motel: '..char.id, Position = {-313.72, -1034.5, 31.03, 0.0}, interior = 'apartment_2'}
        EnterProperty(source, 'Motel: '..char.id, 'apartment_2', true, {-313.72, -1034.5, 31.03, 0.0})
    end
end)

PDMotels = {
    {470.55, -984.93, 30.69, 91.0},
    {332.68, -569.67, 43.28, 158.8}
}
RegisterNetEvent('PDMotel.Enter')
AddEventHandler('PDMotel.Enter', function(id)
    local source = source
    local char = GetCharacter(source)

    local ems = exports['geo-es']:IsEMS(char.id)
    if exports['geo-es']:IsPolice(char.id) or exports['geo-es']:IsEMS(char.id) then
        local str = 'PD'
        if ems then str = 'EMS' end
        EnterProperty(source, str..' Motel: '..char.id, 'apartment_2', true, PDMotels[id])
    end
end)

RegisterNetEvent('Apartment.RentLuxury')
AddEventHandler('Apartment.RentLuxury', function()
    local source = source
    local char = GetCharacter(source)
    local hasLuxury = HasLuxury(char.id)
    if not hasLuxury then
        if exports['geo-eco']:DebitDefault(char, 5000, 'Apartment Rental') then
            exports.ghmattimysql:execute('INSERT INTO luxury_apartment (cid) VALUES (?)', {char.id}, function()
                TriggerClientEvent('Apartment.RentLuxury', source)
            end)
        end
    end
end)

RegisterNetEvent('Apartment.Deposit')
AddEventHandler('Apartment.Deposit', function(amount)
    local source = source
    local char = GetCharacter(source)

    local amount = math.abs(math.floor(tonumber(amount)))
    if amount then
        local current = SQL('SELECT deposit FROM luxury_apartment WHERE cid = ?', char.id)[1].deposit
        if exports['geo-inventory']:RemoveItem('Player', source, 'dollar', amount) then
            SQL('UPDATE luxury_apartment SET deposit = deposit + ? WHERE cid = ?', amount, char.id)
            TriggerClientEvent('Shared.Notif', source, 'Your current apartment balance is $'..comma_value(current + amount))
        end
    end
end)

RegisterNetEvent('Police.EnterRoom')
AddEventHandler('Police.EnterRoom', function(id, loc)
    local char = GetCharacter(source)
    local isPolice = exports['geo-es']:IsPolice(char.id)
    if isPolice then
        local id = math.floor(tonumber(id))

        if id then
            local myAuth = exports['geo-guilds']:GuildAuthority(isPolice, char.id)
            local targetAuth = exports['geo-guilds']:GuildAuthority(isPolice, id)

            if myAuth > 1500 and myAuth > targetAuth then
                if id and exports['geo-es']:IsPolice(id) then
                    EnterProperty(source, 'PD Motel: '..id, 'apartment_2', true, PDMotels[loc])
                else
                    TriggerClientEvent('Shared.Notif', source, 'This person is not an officer')
                end            
            end
        end
    end
end)

function HasLuxury(id)
    local val = SQL('SELECT active from luxury_apartment WHERE cid = ?', id)[1]
    if not val then
        return false
    end

    return val.active == 1
end

exports('HasLuxury', HasLuxury)

AddEventHandler('Logout', function(char)
    for k,v in pairs(Apartments) do
        if v.Resident == char.id then
            v.Available = true
            v.Resident = nil
            Console('[Motel]', Format('Motel %s has been freed', k))
            break
        end
    end
end)