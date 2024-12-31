properties = {}
local purchaseQueue = {}

CreateThread(function()
    local time = os.time()
    exports.ghmattimysql:execute('UPDATE properties SET owner = 0, renter = 0, tenants = "{}", owed = 0 WHERE DATEDIFF(CURRENT_TIMESTAMP, properties.lastpay) >= 15', function()
        exports.ghmattimysql:execute('SELECT * FROM properties', function(res)
            for k,v in pairs(res) do
                properties[v.pid] = v
                properties[v.pid].doors = json.decode(v.doors)
                properties[v.pid].garage = json.decode(v.garage)
                properties[v.pid].data = json.decode(v.data)
                properties[v.pid].tenants = json.decode(v.tenants)
                properties[v.pid].lastPaid = SQL('SELECT DATEDIFF(CURRENT_TIMESTAMP, properties.lastpay) as lData from properties where pid = ?', v.pid)[1].lData
                properties[v.pid].guid = v.guild
            end
            TriggerClientEvent('GetProperties', -1, properties)
        end)
    end)
end)

RegisterNetEvent('GetProperties')
AddEventHandler('GetProperties', function()
    local source = source
    TriggerClientEvent('GetProperties', source, properties)
end)

RegisterNetEvent('CreateProperty')
AddEventHandler('CreateProperty', function(propertyName, propertyType, interiorID, doors, garage, price)
    local source = source
    local char = GetCharacter(source)
    if exports['geo-guilds']:GuildAuthority('FHA', char.id) > 0 then
        if type(propertyName) ~= 'string' then
            TriggerClientEvent('Chat.Message', source, '[House]', 'Property Name is not valid', 'job')
            return
        end

        if type(propertyType) ~= 'string' then
            TriggerClientEvent('Chat.Message', source, '[House]', 'Property Type is not valid', 'job')
            return
        end

        if type(interiorID) ~= 'string' or interiors[interiorID] == nil then
            TriggerClientEvent('Chat.Message', source, '[House]', 'Interior is not valid', 'job')
            return
        end

        if type(doors) ~= 'table' then
            TriggerClientEvent('Chat.Message', source, '[House]', 'Doors is not valid', 'job')
            return
        end

        if type(garage) ~= 'table' then
            TriggerClientEvent('Chat.Message', source, '[House]', 'Garage is not valid', 'job')
            return
        end

        if type(price) ~= 'number' or price == 0 then
            TriggerClientEvent('Chat.Message', source, '[House]', 'Price is not valid', 'job')
            return
        end

        doors = json.encode(doors)
        garage = json.encode(garage)
        local buyable = 1
        if propertyType == 'Apartment' then
            buyable = 0
        elseif propertyType == 'Business' then
            buyable = 2
        end
        
        price = math.floor(math.abs(price))

        exports.ghmattimysql:execute('INSERT INTO properties (price, buyable, title, doors, garage, interior) VALUES (@Price, @Buyable, @Title, @Doors, @Garage, @Interior)', {
            Price = price,
            Buyable = buyable,
            Title = propertyName,
            Doors = doors,
            Garage = garage,
            Interior = interiorID
        }, function(res)

            if res == nil then
                TriggerClientEvent('Chat.Message', source, '[House]', 'Address already exists', 'job')
                return
            end


            exports.ghmattimysql:execute('SELECT * FROM properties WHERE pid = @ID', {
                ID = res.insertId
            }, function(result)
                for k,v in pairs(result) do
                    properties[v.pid] = v
                    properties[v.pid].doors = json.decode(v.doors)
                    properties[v.pid].garage = json.decode(v.garage)
                    properties[v.pid].data = json.decode(v.data)
                    properties[v.pid].tenants = json.decode(v.tenants)
                    properties[v.pid].lastPaid = 0
                    TriggerClientEvent('SetProperty', -1, v.pid, properties[v.pid])
                end
            end)
        end)
        TriggerClientEvent('PropertyComplete', source)
    end
end)

Task.Register('ModifyProperty', function(source, pid, doors, garage)
    local source = source
    if properties[pid].owner == GetCharacter(source).id then

        if type(doors) ~= 'table' then
            TriggerClientEvent('Chat.Message', source, '[House]', 'Doors is not valid', 'job')
            return
        end

        if type(garage) ~= 'table' then
            TriggerClientEvent('Chat.Message', source, '[House]', 'Garage is not valid', 'job')
            return
        end

        if #doors == 0 then return end

        properties[pid].doors = doors
        properties[pid].garage = garage
        SQL('UPDATE properties SET doors = ?, garage = ? WHERE pid = ?', json.encode(doors), json.encode(garage), pid)
        TriggerClientEvent('SetProperty', -1, pid, properties[pid])
        return true
    end
end)

RegisterNetEvent('Property:Lock')
AddEventHandler('Property:Lock', function(house)
    local source = source
    local char = GetCharacter(source)
    if PropertyAllowed(properties[house].title, char.id) then
        if properties[house].Locked == nil then
            properties[house].Locked = true
        end

        properties[house].Locked = not properties[house].Locked
        TriggerClientEvent('Shared.Notif', source, 'Property: '..(properties[house].Locked and 'Locked' or 'Unlocked'))
        TriggerClientEvent('SetProperty', -1, house, properties[house])
    end
end)

RegisterNetEvent('Property:Enter')
AddEventHandler('Property:Enter', function(home, veh, pos, players)
    local source = source
    local char = GetCharacter(source)
    if PropertyAllowed(properties[home].title, char.id) then
        EnterProperty(source, properties[home].title, properties[home].interior, true, pos, veh, players)
    elseif properties[home].Locked == false then
        EnterProperty(source, properties[home].title, properties[home].interior, false, pos, veh, players)
    else
        return
    end
end)

RegisterNetEvent('Property:OpenInventory')
AddEventHandler('Property:OpenInventory', function()
    local source = source
    local char = GetCharacter(source)
    if PropertyAllowed(char.interior, char.id) or Keys[source] then
        if char.interior:match('Motel') then
            exports['geo-inventory']:OpenInventory(source, 'Motel', char.interior)
        else
            exports['geo-inventory']:OpenInventory(source, 'Property', char.interior)
        end
    end
end)

RegisterNetEvent('Property:Release')
AddEventHandler('Property:Release', function(home)
    local source = source
    local char = GetCharacter(source)
    if exports['geo-guilds']:GuildAuthority('FHA', char.id) > 0 then
        local owned = IsOwned(home)
        if owned then
            local target = GetCharacterByID(owned)
            if target then
                TriggerClientEvent('Shared.Notif', source, 'Sent a request to release the property')

                if exports['geo-interface']:PhoneConfirm(target.serverid, 'a realtor would like you to sell: '..properties[home].title) then
                    SellProperty(target.serverid, home)
                end

                --TriggerClientEvent('Property:Release', target.serverid, home)
            else
                TriggerClientEvent('Shared.Notif', source, 'Property owner is not available')
            end
        end
    end
end)

RegisterNetEvent('Property:Sell')
AddEventHandler('Property:Sell', function(home)
    local source = source
    SellProperty(source, home)
end)

Task.Register('Property.Sell', function(source, home)
    SellProperty(source, home)
end)

function SellProperty(source, home)
    local char = GetCharacter(source)
    local owned = false

    if properties[home].owner == char.id then
        owned = true
    elseif properties[home].renter == char.id then
    else
        return
    end

    if not owned then
        if not exports['geo-interface']:PhoneConfirm(source, 'Would you sell this proprety?') then
            return
        end
    else
        if not exports['geo-interface']:PhoneConfirm(source, 'Would you sell this proprety for '..comma_value(math.floor((properties[home].price - properties[home].owed) * 0.75))..'?') then
            return
        end
    end

    properties[home].owner = 0
    properties[home].renter = 0
    properties[home].tenants = {}
    properties[home].guild = nil

    if owned then
        exports['geo-eco']:Deposit(char.account, math.floor((properties[home].price - properties[home].owed) * 0.75), source, 'House Sale')
    end

    exports.ghmattimysql:execute('UPDATE properties SET owner = 0, renter = 0, tenants = "{}", owed = 0, guild = NULL WHERE pid = @ID', {
        ID = home
    })

    TriggerClientEvent('SetProperty', -1, home, properties[home])
end

RegisterNetEvent('Property:SellToPlayer')
AddEventHandler('Property:SellToPlayer', function(home, target)
    local source = source
    local char = GetCharacter(source)
    if exports['geo-guilds']:GuildAuthority('FHA', char.id) > 0 then
        target = tonumber(target)
        if target == char.id and char.username == nil then
            TriggerClientEvent('Shared.Notif', source, 'You cannot sell to yourself')
            return
        end

        local owned = IsOwned(home)
        if not owned then
            local target = GetCharacterByID(target)
            if target then
                TriggerEvent('Property:Buy', home, target.serverid, char)
                --TriggerClientEvent('Property:SellToPlayer', target.serverid, home)
                --purchaseQueue[target.serverid] = source
            else
                TriggerClientEvent('Shared.Notif', source, 'This person is not available')
            end
        end
    end
end)

AddEventHandler('Property:Buy', function(home, sid, seller)
    local char = GetCharacter(sid)
    if not IsOwned(home) then
        if seller then
            if exports['geo-interface']:PhoneConfirm(sid, 'Would you buy this house? $'..comma_value(GetPrice(math.floor(properties[home].price * 0.6))), 60, 'housing') then
                local guild
                if properties[home].buyable == 2 then
                    local cancel = false
                    local val = Task.Run('House.GetGuild', char.serverid)

                    if val then
                        if not exports['geo-guilds']:GuildOwner(val) == char.id then
                            cancel = true
                        else
                            guild = val
                        end
                    else
                        cancel = true
                    end

                    if cancel then
                        TriggerClientEvent('PhoneNotif', char.serverid, 'housing', 'You need to own a guild to purchase this', 2500)
                        return
                    end
                end
                
                if exports['geo-eco']:DebitDefault(char, math.floor(properties[home].price * 0.6), 'Property Purchase') then
                    properties[home].owner = char.id
                    properties[home].renter = 0
                    properties[home].tenants = {}
                    properties[home].owed = properties[home].price - math.floor(properties[home].price * 0.6)
                    if sid ~= seller.serverid then
                        local earnings= math.floor(properties[home].price * 0.05)
                        if earnings > 10000 then earnings = 10000 end
                        exports['geo-eco']:Deposit(seller.account, earnings, seller.serverid, 'House Sale')
                    end
                    exports.ghmattimysql:execute('UPDATE properties SET owner = @Owner, renter = @Renter, tenants = "{}", owed = @Owed, lastpay = CURRENT_TIMESTAMP, guild = @Guild WHERE pid = @ID', {
                        ID = home,
                        Owner = properties[home].owner,
                        Renter = properties[home].renter,
                        Owed = properties[home].owed,
                        Guild = guild
                    }, function()
                        properties[home].lastPaid = SQL('SELECT DATEDIFF(CURRENT_TIMESTAMP, properties.lastpay) as lData from properties where pid = ?', home)[1].lData
                        properties[home].lastpay = SQL('SELECT properties.lastpay as lData from properties where pid = ?', home)[1].lData
                        TriggerClientEvent('SetProperty', -1, home, properties[home])
                    end)
                end
            end
        else
            TriggerClientEvent('Shared.Notif', sid, 'This person is not available')
        end
    end
end)

RegisterNetEvent('Property:Rent')
AddEventHandler('Property:Rent', function(home)
    local source = source
    local char = GetCharacter(source)
    local owned = IsOwned(home)
    if not owned then
        if properties[home].buyable == 0 then

            if SQL('SELECT * from properties WHERE renter = ?', char.id)[1] then
                TriggerClientEvent('PhoneNotif', source, 'housing', 'You can only rent 1 property at a time', 2500)
                return
            end

            if exports['geo-eco']:DebitDefault(char, properties[home].price, 'Property Rental') then
                properties[home].owner = 0
                properties[home].renter = char.id
                properties[home].tenants = {}
                exports.ghmattimysql:execute('UPDATE properties SET owner = @Owner, renter = @Renter, tenants = "{}", lastpay = CURRENT_TIMESTAMP WHERE pid = @ID', {
                    ID = home,
                    Owner = properties[home].owner,
                    Renter = properties[home].renter
                })
                TriggerClientEvent('SetProperty', -1, home, properties[home])
            end
        end
    end
end)

Task.Register('Property.Rent', function(source, home)
    local char = GetCharacter(source)
    local owned = IsOwned(home)
    if not owned then
        if properties[home].buyable == 0 then

            if SQL('SELECT * from properties WHERE renter = ?', char.id)[1] then
                TriggerClientEvent('PhoneNotif', source, 'housing', 'You can only rent 1 property at a time', 2500)
                return
            end

            if exports['geo-eco']:DebitDefault(char, properties[home].price, 'Property Rental') then
                properties[home].owner = 0
                properties[home].renter = char.id
                properties[home].tenants = {}
                exports.ghmattimysql:execute('UPDATE properties SET owner = @Owner, renter = @Renter, tenants = "{}", lastpay = CURRENT_TIMESTAMP WHERE pid = @ID', {
                    ID = home,
                    Owner = properties[home].owner,
                    Renter = properties[home].renter
                })
                TriggerClientEvent('SetProperty', -1, home, properties[home])
            end
        end
    end
end)

Task.Register('Property.AddTentant', function(source, id, home)
    local char = GetCharacter(source)
    id = math.floor(tonumber(id))
    if id and properties[home].owner == char.id then

        for k,v in pairs(properties[home].tenants) do
            if v == id then return end
        end

        local val = SQL('SELECT first, last from characters where id = ?', id)[1]
        TriggerClientEvent('PhoneNotif', source, 'housing', val.first..' '..val.last..' has been added as a tenant', 2500)

        table.insert(properties[home].tenants, id)
        SQL('UPDATE properties SET tenants = ? WHERE pid = ?', json.encode(properties[home].tenants), home)
        TriggerClientEvent('SetProperty', -1, home, properties[home])
    end
end)

Task.Register('Property.GetTenants', function(source, home)
    local char = GetCharacter(source)
    if properties[home].owner == char.id then

        local list = {}
        for k,v in pairs(properties[home].tenants) do
            local val =  SQL('SELECT first, last from characters where id = ?', v)[1]
            table.insert(list, {v, val.first..' '..val.last})
        end

        return list
    end
end)

Task.Register('Property.RemoveTenant', function(source, home, tenant)
    local char = GetCharacter(source)
    if properties[home].owner == char.id then
        tenant = tonumber(tenant)
        for k,v in pairs(properties[home].tenants) do
            if v == tenant then
                table.remove(properties[home].tenants, k)
                SQL('UPDATE properties SET tenants = ? WHERE pid = ?', json.encode(properties[home].tenants), home)
                TriggerClientEvent('SetProperty', -1, home, properties[home])
                break
            end
        end
    end
end)

Task.Register('Housing.Payment', function(source, home)
    local char = GetCharacter(source)
    if properties[home].owner == char.id then
        local payment = math.floor(properties[home].price * 0.05)
        local paystr = 'Property Payment'
        if properties[home].owed > 0 then
            if payment > properties[home].owed then payment = properties[home].owed end
        else
            payment = math.floor(properties[home].price * 0.01)
            paystr = 'Property Taxes'
        end
        if exports['geo-eco']:DebitDefault(char, payment, paystr) then
            SQL('UPDATE properties SET lastpay = CURRENT_TIMESTAMP, owed = ? WHERE pid = ?', properties[home].owed - payment, home)
            properties[home].lastPaid = SQL('SELECT DATEDIFF(CURRENT_TIMESTAMP, properties.lastpay) as lData from properties where pid = ?', home)[1].lData
            properties[home].lastpay = SQL('SELECT properties.lastpay as lData from properties where pid = ?', home)[1].lData
            if properties[home].owed > 0 then
                properties[home].owed = properties[home].owed - payment
            else
                exports['geo-guilds']:AddGuildFunds('CITY', payment)
            end
            TriggerClientEvent('SetProperty', -1, home, properties[home])
        end
    elseif properties[home].renter == char.id then
        local payment = properties[home].price
        if exports['geo-eco']:DebitDefault(char, payment, 'Property Rental') then
            SQL('UPDATE properties SET lastpay = CURRENT_TIMESTAMP WHERE pid = ?', home)
            properties[home].lastPaid = SQL('SELECT DATEDIFF(CURRENT_TIMESTAMP, properties.lastpay) as lData from properties where pid = ?', home)[1].lData
            properties[home].lastpay = SQL('SELECT properties.lastpay as lData from properties where pid = ?', home)[1].lData
            exports['geo-guilds']:AddGuildFunds('CITY', payment)
            TriggerClientEvent('SetProperty', -1, home, properties[home])
        end
    end
end)

function PropertyAllowed(property, char)

    if not property then
        return
    end

    for k,v in pairs(properties) do
        if v.title == property then
            if v.owner == char or v.renter == char or IsTenant(v.tenants, char) then
                return true
            end

            if v.guild then
                if exports['geo-guilds']:GuildHasFlag(v.guild, char, 'Property') then
                    return true
                end
            end
        end
    end

    if property:match('Motel') then
        local str = SplitString(property,'Motel: ')
        return char == tonumber(str[1]) or (str[1] == 'PD' and char == tonumber(str[2])) or  (str[1] == 'E' and char == tonumber(str[3]))
    end
end

function IsTenant(list, char)
    for k,v in pairs(list) do
        if char == v then
            return true
        end
    end
end

function IsOwned(home)
    if properties[home].owner ~= 0 then
        return properties[home].owner
    elseif properties[home].renter ~= 0 then
        return properties[home].renter
    end
end

exports('PropertyAllowed', PropertyAllowed)