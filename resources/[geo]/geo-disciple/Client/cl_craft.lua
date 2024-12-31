
local craftingLog
craftMenu = false
AddEventHandler('Login', function()
    Task.Run('GetCraftingLog')
end)

CreateThread(function()
    Wait(1000)
    Task.Run('GetCraftingLog')
end)

RegisterNetEvent('CraftingLog', function(data)
    craftingLog = data
    if craftMenu then
        Craft()
    end
end)

RegisterKeyMapping('craftinternal', '[Disciple] Craft ~g~+Modifier~w~', 'keyboard', 'J')
RegisterCommand('craftinternal', function(source, args, raw)
    if controlMod then
        Craft()
    end
end)

RegisterCommand('craft', function(source, args, raw)
    Craft()
end)

function Craft()
    if MyCharacter.interior ~= nil then
        TriggerEvent('Shared.Notif', "This area does not fit your needs")
        return
    end

    local inv = exports['geo-inventory']:GetInventory()
    local amounts = {}

    for k,v in pairs(inv) do
        amounts[v.Key] = (amounts[v.Key] or 0) + v.Amount
    end

    craftMenu = true
    UIFocus(true, true)
    SendNUIMessage({
        interface = 'Craft',
        data = Crafting,
        inv = amounts,
        craftingLog = craftingLog,
        gatheringLog = gatheringLog,
        gatheringItems = Gathering.XP
    })
end

RegisterNUICallback('Craft', function(data, cb)
    Task.Run('Craft', data.job, data.item, data.items)
    local inv = exports['geo-inventory']:GetInventory()
    local amounts = {}

    for k,v in pairs(inv) do
        amounts[v.Key] = (amounts[v.Key] or 0) + v.Amount
    end
    cb(amounts)
end)

AddEventHandler('Repair', function(key, id, items)
    local inv = exports['geo-inventory']:GetInventory()
    local amounts = {}

    for k,v in pairs(inv) do
        amounts[v.Key] = (amounts[v.Key] or 0) + v.Amount
    end

    for k,v in pairs(items) do
        v[3] = exports['geo-inventory']:GetItemName(v[1])
    end

    UIFocus(true, true)
    SendNUIMessage({
        interface = 'Repair',
        key = key,
        id = id,
        items = items,
        inv = amounts
    })
end)

RegisterNUICallback('Repair', function(data, cb)
    cb(Task.Run('Repair', data.item))
end)

RegisterNUICallback('CraftingItem', function(data, cb)
    cb(Task.Run('StartCraft', data.job, data.index, data.items))
end)

RegisterNUICallback('Crafting.Skill', function(data, cb)
    local data = Task.Run('Crafting.Skill', data.skill)
    if data.completed then
        local inv = exports['geo-inventory']:GetInventory()
        local amounts = {}
    
        for k,v in pairs(inv) do
            amounts[v.Key] = (amounts[v.Key] or 0) + v.Amount
        end

        data.inv = amounts
    end
    cb(data)
end)

local quickCrafting = false
local isDone = false
RegisterNUICallback('QuickCraft', function(data, cb)
    quickCrafting = true
    local amount = data.amount or 1
    ExecuteCommand('e warmth')

    CreateThread(function()
        while quickCrafting do
            Wait(0)
            DrawLightWithRangeAndShadow(GetOffsetFromEntityInWorldCoords(Shared.Ped, 0.0, 0.1, 0.0), 255, 0, 0, 5.0, 1.0, 1.0)
            DrawSphere(GetOffsetFromEntityInWorldCoords(Shared.Ped, 0.0, 0.4, 0.05), 0.1,  255, 100, 100, 1.0)
        end
    end)

    while quickCrafting do
        Wait(0)
        if amount == 0 then quickCrafting = false break end
        Wait(5000)
        Task.Run('QuickCraft', data.job, data.index)
        amount = amount - 1
        if isDone then quickCrafting = false end
    end
    cb('done')
    Craft()
    ExecuteCommand('ec warmth')
    isDone = false
end)

RegisterNUICallback('CancelQuick', function(data, cb)
    isDone = true
    cb(true)
end)

RegisterNUICallback('MyLevel', function(data, cb)
    cb(GetLevel(MyCharacter.skills[data.job]))
end)

function GetLevel(xp)
    local level = 1
    xp = xp or 0
    for k,v in pairs(Levels) do
        if xp >= v then
            level = k
        else
            break
        end
    end

    return level
end