Task.Register('CanRob', function(source, id)
    return exports['geo-es']:Handsup(id) or GetCharacter(id).dead == 1
end)

Task.Register('Rob', function(source, id)
    if exports['geo-es']:Handsup(id) or GetCharacter(id).dead == 1 then
        exports['geo-inventory']:OpenInventory(source, 'Player', tostring(id))
    end
end)

local boughtid = {}
RegisterNetEvent('BuyIDCard', function()
    local source = source
    local char = GetCharacter(source)

    local img = Task.Run('GetImage', source)

    if boughtid[char.id] then
        TriggerClientEvent('Shared.Notif', source, 'You can not buy another ID today', 5000)
        return
    end

    if exports['geo-inventory']:CanFit('Player', source, 'id', 1) and exports['geo-inventory']:RemoveItem('Player', source, 'dollar', 100) then
        boughtid[char.id] = true
        local item = exports['geo-inventory']:InstanceItem('id')
        item.Data.cid = char.id
        item.Data.first = char.first
        item.Data.last = char.last
        item.Data.dob = char.dob
        item.Data.sex = char.sex == 1 and 'Female' or 'Male'
        item.Data.Image = img
        exports['geo-inventory']:AddItem('Player', source, 'id', 1, item)
    end
end)

Task.Register('GetSnowball', function(source)
    exports['geo-inventory']:AddItem('Player', source, 'snowball', 1)
end)

Task.Register('Ped.Work', function(source, id)
    local user = GetUser(source)
    local time = os.time()
    if user.data.work == nil then user.data.work = {0, time - 50} end
    if time > user.data.work[2] then
        SetUserData(source, 'work', {id, os.time() + 172800, os.time() + 57600})
        local account = SQL('SELECT account from characters WHERE id = ?', id)[1].account
        exports['geo-eco']:Deposit(account, 5000, 0, 'Working a 9-5')
        return true
    else
        local since = _TimeSince(user.data.work[2])
        TriggerClientEvent('Shared.Notif', source, ('%s hours and %s minutes and %s minutes until next available job'):format(since.hours, since.minutes, since.seconds))
    end
end)

Task.Register('TakeVehicle', function(source, veh)
    local char = GetCharacter(source)
    veh = NetworkGetEntityFromNetworkId(veh)
    if char.id == Entity(veh).state.owner then
        Entity(veh).state.fake = false
        TriggerEvent('GiveKey', source, NetworkGetNetworkIdFromEntity(veh))
        SetVehicleDoorsLocked(veh, 2)
        SQL('UPDATE vehicles SET location = null WHERE id = ?', Entity(veh).state.vin)
    end
end)