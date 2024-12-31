local cAccount = nil
local hasLux = false
local atm = false
local accounts = {}
local banks = {
    vector3(149.93, -1040.53, 29.37),
    vector3(314.38, -279.15, 54.17),
    vector3(-1212.94, -330.87, 37.79),
    vector3(242.24, 225.1, 106.29),
    vector3(247.47, 223.2, 106.29),
    vector3(252.66, 221.38, 106.29),
    vector3(-2962.6, 482.31, 15.7),
    vector3(1175.43, 2706.8, 38.09),
    vector3(-112.01, 6469.1, 31.63),
    vector3(-350.8, -49.9, 49.04)
}

Citizen.CreateThread(function()
    Menu.CreateMenu('Bank', 'Bank')
    Menu.Menus['Bank'].TitleColor = {0, 100, 0, 255}
    Menu.CreateSubMenu('Bank2', 'Bank', 'Bank2')

    Menu.CreateMenu('ATM', 'ATM')
    Menu.Menus['ATM'].TitleColor = {0, 100, 0, 255}
    Menu.CreateSubMenu('ATM2', 'ATM', 'ATM2')

    for k,v in pairs(banks) do
        if k == 5 or k == 6 then
            goto skipme
        end

        local blip = AddBlipForCoord(v)
        SetBlipSprite(blip, 207)
        SetBlipColour(blip, 2)
		SetBlipAsShortRange(blip, true)
		SetBlipScale(blip, 0.8)
		BeginTextCommandSetBlipName("STRING");
		AddTextComponentString('Bank')
        EndTextCommandSetBlipName(blip)
        ::skipme::
    end
end)

AddEventHandler('UseBank', function()
    BankMenu()
end)

local bankOpen = false
function BankMenu()

    if Task.RunRemote('BankHasBeenRobbed', GetEntityCoords(Shared.Ped)) then
        TriggerEvent('Shared.Notif', 'This bank has been robbed too recently', 5000)
        return
    end

    cAccount = nil
    local nacc = nil
    TriggerServerEvent('GetAccounts')
    UIFocus(true, true)
    SendNUIMessage({
        interface = 'bank.open',
        data = acc,
        account = MyCharacter.default or MyCharacter.account
    })

    bankOpen = true
    while bankOpen do
        Wait(100)
    end

   --[[
    Menu.OpenMenu('Bank', 'Bank')
    while Menu.CurrentMenu do
        Wait(0)
        if Menu.CurrentMenu == 'Bank' then
            if Menu.Button('Create Account') then
                TriggerServerEvent('Bank:Create')
            end

            for k,v in pairs(accounts) do
                local str = 'Account #'..v.id

                if MyCharacter.account == v.id then
                    str = '~g~'..str
                end

                if v.name then
                    str = str..' ['..v.name..']'
                end

                if Menu.Button(str, '$'..comma_value(v.amount)) then
                    Menu.OpenMenu('Bank2')
                    cAccount = v.id
                    nacc = k
                    for key,val in pairs(accounts) do
                        if val.id == cAccount then
                            Menu.Menus['Bank2'].SubTitle = 'Curent Balance : $'..val.amount
                            Menu.Menus['Bank2'].Title = val.name or ('Account #'..val.id)
                        end
                    end
                end
            end
            if not NearBank() then
                Menu.CloseMenu()
            end
        elseif Menu.CurrentMenu == 'Bank2' then
            if cAccount then
                if Menu.Button('Deposit') then
                    local val = Shared.TextInput('Amount', 5)

                    if tonumber(val) then
                        TriggerServerEvent('Bank:Deposit', tonumber(val), cAccount)
                    end
                end

                if Menu.Button('Withdraw') then
                    local val = Shared.TextInput('Amount', 5)

                    if tonumber(val) then
                        TriggerServerEvent('Bank:Withdraw', tonumber(val), cAccount)
                    end
                end

                if Menu.Button('Name Account') then
                    local val = Shared.TextInput('Acount Name', 20)

                    if val ~= '' then
                        if Shared.Confirm('Are you sure you want name the account "'..val..'" ?', 'Bank Name') then
                            TriggerServerEvent('Bank:NameAccount', val, cAccount)
                        end
                    end
                end

                if accounts[nacc] then
                    if accounts[nacc].creator == MyCharacter.id then
                        if Menu.Button('Delete Account') then
                            if Shared.Confirm('Are you sure you want to delete this account?', 'DELETE') then
                                TriggerServerEvent('Bank:DeleteAccount', cAccount)
                            end
                        end
                    end
                else
                    Menu.OpenMenu('Bank')
                end
            end
        end
        Menu.Display()
    end ]]
end

AddEventHandler('ATM', function()
    if NearATM() then

        LoadAnim('amb@prop_human_atm@male@idle_a')
        TaskPlayAnim(Shared.Ped, 'amb@prop_human_atm@male@idle_a', 'idle_b', 1.0, 1.0, -1, 1, 0, 0, 0, 0 )
        TriggerServerEvent('GetAccounts')
        UIFocus(true, true)
        SendNUIMessage({
            interface = 'bank.open',
            data = acc,
            account = MyCharacter.default or MyCharacter.account,
            ATM = true
        })

        atm = true
        if true then return end

        Menu.OpenMenu('ATM')
        TriggerServerEvent('GetAccounts')
        cAccount = nil
        local nacc = nil
        while Menu.CurrentMenu do
            Wait(0)
            if not NearATM() then
                break
            end
            if Menu.CurrentMenu == 'ATM' then
                for k,v in pairs(accounts) do
                    local str = 'Account #'..v.id
                
                    if MyCharacter.account == v.id then
                        str = '~g~'..str
                    end
                
                    if v.name then
                        str = str..' ['..v.name..']'
                    end
                
                    if Menu.Button(str, '$'..comma_value(v.amount)) then
                        Menu.OpenMenu('ATM2')
                        cAccount = v.id
                        nacc = k
                        for key,val in pairs(accounts) do
                            if val.id == cAccount then
                                Menu.Menus['ATM2'].SubTitle = 'Curent Balance : $'..val.amount
                                Menu.Menus['ATM2'].Title = val.name or ('Account #'..val.id)
                            end
                        end
                    end
                end
            elseif Menu.CurrentMenu == 'ATM2' then
                if Menu.Button('Withdraw') then
                    local val = Shared.TextInput('Amount', 5)

                    if tonumber(val) then
                        TriggerServerEvent('ATM:Withdraw', tonumber(val), cAccount)
                    end
                end
                if not accounts[nacc] then
                    Menu.OpenMenu('ATM')
                end
            end
            Menu.Display()
        end
        cAccount = nil
        TriggerServerEvent('Accounts:Close')
    end
end)

RegisterNetEvent('GetAccounts')
AddEventHandler('GetAccounts', function(acc)
    accounts = acc

    SendNUIMessage({
        interface = 'bankdata',
        data = acc
    })
    if cAccount ~= nil then
        for k,v in pairs(accounts) do
            if v.id == cAccount then

                if Menu.CurrentMenu == 'Bank2' then
                    Menu.Menus['Bank2'].SubTitle = 'Curent Balance : $'..v.amount
                    Menu.Menus['Bank2'].Title = v.name or ('Account #'..v.id)
                    return
                elseif Menu.CurrentMenu == 'ATM2' then
                    Menu.Menus['ATM2'].SubTitle = 'Curent Balance : $'..v.amount
                    Menu.Menus['ATM2'].Title = v.name or ('Account #'..v.id)
                    return
                end
            end
        end
    end
end)

RegisterNetEvent('Bank.Finish')
AddEventHandler('Bank.Finish', function()
    SendNUIMessage({
        interface = 'bank.finishcreation'
    })
end)

RegisterNetEvent('Bank.FinishTransfer')
AddEventHandler('Bank.FinishTransfer', function(val)
    SendNUIMessage({
        interface = 'bank.finishtransfer',
    })

    BankAlert(val and 'Transaction Compelted' or 'Transaction Not Completed')
end)

RegisterNetEvent('Bank.Records')
AddEventHandler('Bank.Records', function(data)
    UIFocus(true, true)
    ExecuteCommand('e tablet2')
    SendNUIMessage({
        interface = 'bank.open',
        data = acc,
        account = MyCharacter.default or MyCharacter.account
    })

    SendNUIMessage({
        interface = 'bankdata',
        data = data
    })

    bankOpen = true

    while bankOpen do
        Wait(100)
    end

    ExecuteCommand('ec tablet2')
end)

RegisterNUICallback('close', function(data, cb)
    UIFocus(false, false)
    bankOpen = false
    cAccount = nil
    TriggerServerEvent('Accounts:Close')
    if atm then
        atm = false
        LoadAnim('amb@prop_human_atm@male@exit')
        TaskPlayAnim(Shared.Ped, 'amb@prop_human_atm@male@exit', 'exit', 1.0, 1.0, -1, 1, 0, 0, 0, 0)
        Wait(3000)
        StopAnimTask(Shared.Ped, 'amb@prop_human_atm@male@exit', 'exit', 1.0)
    end
    cb()
end)

RegisterNUICallback('bank.name', function(data, cb)
    for k,v in pairs(accounts) do
        if v.id == tonumber(data.account) then
            if v.name == data.text then
                cb()
                return
            end
        end
    end
    
    TriggerServerEvent('Bank:NameAccount', data.text, tonumber(data.account))
    cb()
end)

RegisterNUICallback('bank.deposit', function(data, cb)
    TriggerServerEvent('Bank:Deposit', tonumber(data.amount), tonumber(data.account))
    cb()
end)

RegisterNUICallback('bank.withdraw', function(data, cb)
    TriggerServerEvent('Bank:Withdraw', tonumber(data.amount), tonumber(data.account))
    cb()
end)

RegisterNUICallback('bank.create', function(data, cb)
    TriggerServerEvent('Bank:Create', data and data.business and 'Business' or 'Personal', data and data.businessName)
    cb()
end)

RegisterNUICallback('bank.removefromaccount', function(data, cb)
    TriggerServerEvent('Bank:RemoveClient', data.account, data.person)
    cb()
end)

RegisterNUICallback('bank.addtoaccount', function(data, cb)
    TriggerServerEvent('Bank:AddClient', data.account, data.person)
    cb()
end)

RegisterNUICallback('bank.delete', function(data, cb)
    TriggerServerEvent('Bank:DeleteAccount', data.account)
    cb()
end)

RegisterNUICallback('bank.gettransactions', function(data, cb)
    local data = Task.Run('Bank.Transactions', data.account)
    SendNUIMessage({
        interface = 'bank.transactions',
        data = data
    })
    cb()
end)

RegisterNUICallback('bank.default', function(data, cb)
    cb(Task.Run('Bank:SetDefault', data.account))
end)

RegisterNUICallback('bank.transfer', function(data, cb)
    TriggerServerEvent('Bank.Transfer', data)
    cb()
end)

RegisterNetEvent('Bank:Notify')
AddEventHandler('Bank:Notify', function(info, pre, main, ender, newAmount)
    for k,v in pairs(info) do
        if MyCharacter.id == tonumber(k) then
            TriggerEvent('PhoneNotif', 'fleeca', main)
            break
        end
    end
end)

function NearBank()
    local pos = GetEntityCoords(PlayerPedId())
    for k,v in pairs(banks) do
        if Vdist3(pos, v) <= 2.0 then
            return true
        end
    end
end

function NearATM()
    local coords = GetEntityCoords(PlayerPedId())
    if GetClosestObjectOfType(coords, 2.0, GetHashKey('prop_atm_02'), 0, 0, 0) ~= 0 then
        return true
    end
    if GetClosestObjectOfType(coords, 2.0, GetHashKey('prop_atm_01'), 0, 0, 0) ~= 0 then
        return true
    end
    if GetClosestObjectOfType(coords, 2.0, GetHashKey('prop_atm_03'), 0, 0, 0) ~= 0 then
        return true
    end
    return false
end

function BankAlert(text)
    SendNUIMessage({
        interface = 'bank.alert',
        text = text
    })
end

exports('NearATM', NearATM)
exports('NearBank', NearBank)