local payType = {}

RegisterCommand('paywith', function(source, args)
    if args[1] == 'debit' then
        payType[source] = 'debit'
        TriggerClientEvent('Chat.Message', source, '[Bank]', 'Payment set to Debit for prices over $5,000', 'bank')
        UpdateChar(source, 'pay', 'debit')
    elseif args[1] == 'cash' then
        payType[source] = 'cash'
        TriggerClientEvent('Chat.Message', source, '[Bank]', 'Payment set to Cash', 'bank')
        UpdateChar(source, 'pay', 'cash')
    end
end)

--[[ RegisterCommand('balance', function(source, args)
    local char = GetCharacter(source)
    local accounts = GetMyAccounts(char)

    if args[1] == nil then
        for k,v in pairs(accounts) do
            TriggerClientEvent('Chat.Message', source, '[Account '..v.id..']', 'Balance: $'..comma_value(v.amount), 'bank')
        end
    else
        for k,v in pairs(accounts) do
            if v.id == tonumber(args[1]) then
                TriggerClientEvent('Chat.Message', source, '[Account '..v.id..']', 'Balance: $'..comma_value(v.amount), 'bank')
            end
        end
    end
end) ]]

RegisterNetEvent('Bank:Create')
AddEventHandler('Bank:Create', function(_type, guild)
    local source = source
    local char = GetCharacter(source)
    local accounts = GetMyAccounts(char)
    local aType = 'Personal'
    _type = _type or 'Personal'

    if _type == 'Business' and guild then
        guild = guild:upper()

        if exports['geo-guilds']:GuildOwner(guild) == char.id then
            aType = 'Business'  
        end
    end

    if _type ~= aType then
        TriggerClientEvent('Bank.Finish', source)
        return  
    end

    if #accounts > 5 and aType == 'Personal' then
        TriggerClientEvent('Bank.Finish', source)
    else
        local num = 0
        if #accounts == 0 then
            num = 1
        end

        if aType == 'Business' then
            local val = SQL('SELECT * from bank WHERE acro = ? and account_type = "Business"', guild)
            if val[1] ~= nil then
                TriggerClientEvent('Bank.Finish', source)
                return
            end
        end

        exports.ghmattimysql:executeSync('INSERT INTO bank (creator, access, locked, account_type, name, acro) VALUES (@Creator, @Access, @Lock, @Type, @Name, @Name)', {
            Creator = char.id,
            Access = json.encode({[tostring(char.id)] = char.first..' '..char.last}),
            Lock = num,
            Type = aType,
            Name = guild
        })

        if num == 1 then
            accounts = GetMyAccounts(char)
            exports.ghmattimysql:executeSync('UPDATE characters SET account = @Bank WHERE id = @ID', {
                Bank = accounts[1].id,
                ID = char.id
            })
            UpdateChar(source, 'account', accounts[1].id)
        end

        accounts = GetMyAccounts(char)
        TriggerClientEvent('GetAccounts', source, accounts)
        TriggerClientEvent('Bank.Finish', source)
    end
end)

local open = {}
RegisterNetEvent('GetAccounts')
AddEventHandler('GetAccounts', function()
    local source = source
    local char = exports['geo']:Char(source)
    local accounts = GetMyAccounts(char)
    local hasLux = exports['geo-instance']:HasLuxury(char.id)

    TriggerClientEvent('GetAccounts', source, accounts, hasLux)
    open[source] = true

    Citizen.CreateThread(function()
        while open[source] do
            Wait(5000)
            TriggerClientEvent('GetAccounts', source, GetMyAccounts(char))
        end
    end)
end)

Task.Register('Bank.Transactions', function(source, account)
    account = tonumber(account)
    return SQL('SELECT * FROM bank_log JOIN (SELECT id, `first`, `last` FROM characters) b ON json_value(bank_log.`data`, "$.cid") = b.id WHERE bank_log.`account` = ? ORDER BY bank_log.id desc', account)
end)

RegisterNetEvent('Accounts:Close')
AddEventHandler('Accounts:Close', function()
    local source = source
    open[source] = nil
end)

RegisterNetEvent('Bank:Deposit')
AddEventHandler('Bank:Deposit', function(amount, account)
    local source = source

    amount = tonumber(amount)
    if tonumber(amount) == nil then
        return
    end
    amount = math.floor(amount)
    amount = math.abs(amount)
    local char = exports['geo']:Char(source)
    local accounts = GetMyAccounts(char)


    for k,v in pairs(accounts) do
        if v.id == account then
            if exports['geo-inventory']:RemoveItem('Player', source, 'dollar', amount) then
                Deposit(account, amount, source, GetName(char))
            end
        end
    end
end)

RegisterNetEvent('Bank:Withdraw')
AddEventHandler('Bank:Withdraw', function(amount, account)
    local source = source

    amount = tonumber(amount)
    if tonumber(amount) == nil then
        return
    end
    amount = math.floor(amount)
    amount = math.abs(amount)
    local char = exports['geo']:Char(source)
    local accounts = GetMyAccounts(char)


    for k,v in pairs(accounts) do
        if v.id == account then
            Withdraw(account, amount, source, GetName(char))
        end
    end
end)

local atm = {}
local int = {}
RegisterNetEvent('ATM:Withdraw')
AddEventHandler('ATM:Withdraw', function(amount, account)
    local source = source

    amount = tonumber(amount)
    if tonumber(amount) == nil then
        return
    end
    amount = math.floor(amount)
    amount = math.abs(amount)
    local char = exports['geo']:Char(source)
    local accounts = GetMyAccounts(char)


    for k,v in pairs(accounts) do
        if v.id == account then

            if atm[source] == nil then
                atm[source] = 10000
            end

            if int[source] == nil then
                int[source] = os.time()
            else
                if os.time() - int[source] > 3600 then
                    atm[source] = 10000
                    int[source] = os.time()
                end
            end

            if atm[source] - amount < 0 then
                TriggerClientEvent('Chat.Message', source, '[ATM]', 'Max limit exceeded by $'..(math.abs(atm[source] - amount)), 'bank')
                return
            end

            if exports['geo-inventory']:CanFit('Player', source, 'dollar', amount) then
                if Withdraw(account, amount, source) then
                    atm[source] = atm[source] - amount
                end
            end
        end
    end
end)

RegisterNetEvent('Bank:NameAccount')
AddEventHandler('Bank:NameAccount', function(name, account)
    local source = source
    local char = exports['geo']:Char(source)
    local accounts = GetMyAccounts(char)


    for k,v in pairs(accounts) do
        if v.id == account and v.creator == char.id then
            exports.ghmattimysql:execute('UPDATE bank set name = @Name where id = @Account', {
                Account = account,
                Name = name
            }, function()
                TriggerClientEvent('GetAccounts', source, GetMyAccounts(char))
            end)
        end
    end
end)

RegisterNetEvent('Bank:DeleteAccount')
AddEventHandler('Bank:DeleteAccount', function(account)
    local source = source
    local char = exports['geo']:Char(source)
    local accounts = GetMyAccounts(char)


    for k,v in pairs(accounts) do
        if v.id == account and v.creator == char.id then

            if (v.locked == 1) or (v.amount > 0 or v.amount < 0) or (v.account_type == 'Business') then
                TriggerClientEvent('Chat.Message', source, '[Bank]', 'This account can not be deleted', 'bank')
                return
            end

            local var = json.decode(v.access)
            var[tostring(char.id)] = nil

            exports.ghmattimysql:execute('DELETE FROM bank WHERE creator = @Creator AND id = @Account and account_type != "Business"', {
                Account = account,
                Creator = char.id
            }, function()
                TriggerClientEvent('GetAccounts', source, GetMyAccounts(char))
            end)
        end
    end
end)

Task.Register('Bank:SetDefault', function(source, account)
    local source = source
    local char = GetCharacter(source)
    local prom = promise:new()
    exports.ghmattimysql:scalar('SELECT json_value(access, "$.?") from bank where id = ?', {
        char.id, account
    }, function(res)
        if res ~= nil then
            UpdateChar(source, 'default', account)
            exports.ghmattimysql:execute('UPDATE characters SET `default` = ? WHERE id = ?', {
               tonumber(account), char.id
            })
            prom:resolve(true)
        else
            prom:resolve(false)
        end
    end)

    return Citizen.Await(prom)
end)

RegisterNetEvent('Bank:RemoveClient')
AddEventHandler('Bank:RemoveClient', function(account, person)
    local source = source
    local char = GetCharacter(source)
    local accounts = GetMyAccounts(char)

    for k,v in pairs(accounts) do
        if v.id == account and v.creator == char.id then
            exports.ghmattimysql:execute('UPDATE bank SET access = JSON_remove(access, "$."?"") WHERE id = ?', {
               person, account
            }, function()
                TriggerClientEvent('GetAccounts', source, GetMyAccounts(char))
            end)
        end
    end
end)

RegisterNetEvent('Bank:AddClient')
AddEventHandler('Bank:AddClient', function(account, person)
    local source = source
    local char = GetCharacter(source)
    local accounts = GetMyAccounts(char)
    local num = tonumber(person)
    for k,v in pairs(accounts) do
        if v.id == account and v.creator == char.id and num then
            exports.ghmattimysql:execute('SELECT first, last, id from characters WHERE id = ?', {num}, function(res)
                if res[1] and res[1].id == num then
                    exports.ghmattimysql:execute('UPDATE bank SET access = JSON_SET(access, "$."?"", ?) WHERE id = ?', {
                        person, res[1].first..' '..res[1].last, account
                     }, function()
                         TriggerClientEvent('GetAccounts', source, GetMyAccounts(char))
                     end)
                end
            end)
        end
    end
end)

RegisterNetEvent('Bank.Transfer')
AddEventHandler('Bank.Transfer', function(data)
    local source = source
    local char = GetCharacter(source)

    for k,v in pairs(data) do
        if tonumber(v) then
            data[k] = math.floor(math.abs(tonumber(v)))
        else
            TriggerClientEvent('Bank.FinishTransfer', source)
            return
        end
    end

    local found = SQL('SELECT id from bank where id = ?', data.toAccount)[1]
    if not found or data.fromAccount == data.toAccount then
        TriggerClientEvent('Bank.FinishTransfer', source)
        return
    end

    local accounts = GetMyAccounts(char)
    for k,v in pairs(accounts) do
        if v.id == data.fromAccount then
            local completed = SQL('UPDATE bank set amount = amount - ? WHERE id = ? and amount - ? >= 0', data.amount, data.fromAccount, data.amount)
            if completed.changedRows == 1 then
                local completed = SQL('UPDATE bank set amount = amount + ? WHERE id = ?', data.amount, data.toAccount)
                BankLog(data.fromAccount, {type = 'withdraw', amount = data.amount, reason = 'Account Transfer: '..data.toAccount, cid = char.id})
                BankLog(data.toAccount, {type = 'deposit', amount = data.amount, reason = 'Account Transfer: '..data.fromAccount..(v.name and v.name ~= '' and ' ('..v.name..')' or ''), cid = char.id})
            end
        end
    end
    TriggerClientEvent('Bank.FinishTransfer', source, true)
end)

AddEventHandler('playerDropped', function()
    local source = source
    open[source] = nil
end)

function GetMyAccounts(char)
    return exports.ghmattimysql:executeSync('SELECT * from bank where json_value(access, "$.@Char") is not null OR creator = @Char', {
        Char = char.id
    })
end

function Deposit(account, amount, source, reason)

    amount = tonumber(amount)
    if tonumber(amount) == nil then
        return
    end
    amount = math.floor(amount)
    amount = math.abs(amount)

    exports.ghmattimysql:execute('SELECT amount from bank where id = @Account', {
        Account = account
    }, function(res)
        res[1].amount = res[1].amount + amount
        exports.ghmattimysql:execute('UPDATE bank set amount = amount + @Amount where id = @Account', {
            Account = account,
            Amount = amount
        }, function()
            if source and source ~= 0 then
                TriggerClientEvent('GetAccounts', source, GetMyAccounts(exports['geo']:Char(source)))
            end
            TriggerClientEvent('Bank:Notify', -1, GetAccountClients(account), '[Account '..account..']', '$'..amount..' added by '..(reason or 'Unknown'), 'bank', res[1].amount)
            BankLog(account, {type = 'deposit', amount = amount, reason = reason, cid = (GetCharacter(source) or {}).id or 0})
        end)
    end)
end

function Debit(account, amount, reason, force)
    local returner = nil
    local prom = promise:new()

    amount = tonumber(amount)
    if tonumber(amount) == nil then
        return
    end
    amount = math.floor(amount)
    amount = math.abs(amount)

    exports.ghmattimysql:execute('SELECT amount from bank where id = @Account', {
        Account = account
    }, function(res)
        local val = res[1].amount
        if val - amount >= 0 or force then
            exports.ghmattimysql:execute('UPDATE bank set amount = amount - @Amount where id = @Account', {
                Account = account,
                Amount = amount
            }, function()
                TriggerClientEvent('Bank:Notify', -1, GetAccountClients(account), '[Account '..account..']', '$'..amount..' removed: '..(reason or 'Unknown'), 'bank', comma_value(val - amount))
            end)
            prom:resolve(true)
        else
            prom:resolve(false)
        end
    end)
    return Citizen.Await(prom)
end

function Withdraw(account, amount, source, reason)
    local returner = nil

    amount = tonumber(amount)
    if tonumber(amount) == nil then
        return
    end
    amount = math.floor(amount)
    amount = math.abs(amount)

    exports.ghmattimysql:execute('SELECT amount from bank where id = @Account', {
        Account = account
    }, function(res)
        local val = res[1].amount

        if val - amount >= 0 then
            if exports['geo-inventory']:CanFit('Player', source, 'dollar', amount) then
                exports.ghmattimysql:execute('UPDATE bank set amount = amount - @Amount where id = @Account and amount - @Amount >= 0', {
                    Account = account,
                    Amount = amount
                }, function()
                    BankLog(account, {type = 'withdraw', amount = amount, reason = reason, cid = GetCharacter(source).id})
                    TriggerClientEvent('GetAccounts', source, GetMyAccounts(exports['geo']:Char(source)))
                    TriggerClientEvent('Bank:Notify', -1, GetAccountClients(account), '[Account '..account..']', '$'..amount..' removed by '..(reason or 'Unknown'), 'bank', res[1].amount - amount)
                end)
                exports['geo-inventory']:AddItem('Player', source, 'dollar', amount)
                returner = true
            else
                returner = false
            end
        else
            returner = false
        end
    end)

    while returner == nil do
        Wait(0)
    end

    return returner
end

function GetAccountClients(accountID)

    if accountID == nil then
        return
    end

    local val = exports.ghmattimysql:scalarSync('SELECT access from bank where id = @Account', {
        Account = accountID,
    })

    if val == nil then
        return {}
    end

    return json.decode(val)
end

function DebitDefault(char, amount, reason, force)
    local _amount = amount
    amount = GetPrice(amount)

    if payType[char.serverid] == nil then
        payType[char.serverid] = 'cash'
    end

    local account = char.default or char.account
    if force then
        account = char.account
    end

   --[[  if SQL('SELECT amount from bank WHERE id = ?', char.account)[1].amount < 0 then
        account = char.account
    end ]]

    local inDebt = SQL('SELECT * from bank WHERE creator = ? and amount < 0', char.id)[1]
    if inDebt then
        account = inDebt.id
        if payType[char.serverid] == 'debit' then
            TriggerClientEvent('Shared.Notif', char.serverid, 'You have an account in debt')
        end
    end

    if (payType[char.serverid] == 'debit' and amount >= 5000) or force then
        local val = exports.ghmattimysql:scalarSync('SELECT json_value(access, "$.?") from bank where id = ?', {
            char.id, account
        })

        if val ~= nil then
            if Debit(account, amount, reason, force) then
                BankLog(account, {type = 'debit', amount = amount, reason = reason, cid = char.id})
                exports['geo-guilds']:AddDepartmentFunds(math.floor(_amount * (exports['geo-guilds']:GetTax()) / 100))
                return true
            else
                TriggerClientEvent('Chat.Message', char.serverid, '[Account '..account..']', 'Account does not hold enough money', 'bank')
                return false
            end
        else
            TriggerClientEvent('Chat.Message', char.serverid, '[Account '..account..']', 'You dont have access to this account', 'bank')
            return false
        end
    else
        if exports['geo-inventory']:RemoveItem('Player', char.serverid, 'dollar', amount) then
            exports['geo-guilds']:AddDepartmentFunds(math.floor(_amount * (exports['geo-guilds']:GetTax()) / 100))
            TriggerClientEvent('Chat.Message', char.serverid, '[Bank]', '$'..amount..' paid in cash: '..reason, 'bank')
            return true
        else
            TriggerClientEvent('Chat.Message', char.serverid, '[Bank]', 'You do not have enough cash', 'bank')
            return false
        end
    end
end

function BankLog(account, data)
    exports.ghmattimysql:execute('INSERT INTO bank_log (account, data) VALUES (?, ?)', {account, json.encode(data)})
end

RegisterCommand('bankrecords', function(source, args)
    local char = GetCharacter(source)
    if char.Duty == 'DOJ' then
        local num = tonumber(args[1])
        if num then
            local val = GetMyAccounts({id = num})
            TriggerClientEvent('Bank.Records', source, val)
        end
    end
end)

RegisterCommand('credit', function(source, args)
    if source == 0 then
        if tonumber(args[1]) and tonumber(args[2]) then
            Deposit(tonumber(args[1]), tonumber(args[2]), 0, 'System Payment')
        end
    end
end)

exports('DebitDefault', DebitDefault)
exports('Deposit', Deposit)
exports('GetMyAccounts', GetMyAccounts)