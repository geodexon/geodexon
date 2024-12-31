local GlassLooted = {
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
}

local Cooldown = false

local PaintingLooted = {
    false,
    false,
    false,
    false,
}

local bigItem = {
    stolen = false,
    curentItem = 1,
    items = {
        'vanDiamond',
        'panther',
        'necklace',
        'vanbottle'
    }
}

-- cool down for job
RegisterServerEvent('mv-vangelico:server:coolout', function()
    Cooldown = true
    local timer = VangConfig.Cooldown * 60000
    while timer > 0 do
        Wait(1000)
        timer = timer - 1000
        if timer == 0 then
            Cooldown = false

        end
    end

    for k,v in pairs(GlassLooted) do
        GlassLooted[k] = false
    end
    for k,v in pairs(PaintingLooted) do
        PaintingLooted[k] = false
    end
    bigItem.stolen = false
end)

Task.Register('Vangelico.Cooldown', function(source, loc)
    if Cooldown == true then return false end

    if exports['geo-es']:DutyCount('Police') < 1 then
        TriggerClientEvent('Shared.Notif', source, "You remember the store feels empty right now, maybe later.")
        return false
    end

    if not exports['geo-inventory']:RemoveItem('Player', source, 'thermite', 1) then
        TriggerClientEvent('Shared.Notif', source, 'You need Thermite')
        return false
    end

    TriggerEvent('Dispatch', {
        code = '10-39',
        title = 'Disturbance at Vangelico\'s',
        location = loc.position,

        time =  os.date('%H:%M EST'),
        info = {
            {
                icon = 'location',
                text = loc.location,
                location = false
            },
        }
    })

    Cooldown = true
    return true
end)

RegisterNetEvent("mv-vangelico:server:setDoorStatus", function()
    TriggerEvent('UnlockVangelico')
end)

--thermite particulas
RegisterServerEvent("mv-vangelico:server:particleserver")
AddEventHandler("mv-vangelico:server:particleserver", function(particleCoords)
    TriggerClientEvent("mv-vangelico:client:ptfxparticle", -1, particleCoords)
end)


RegisterServerEvent("mv-vangelico:server:lasertimeout")
AddEventHandler("mv-vangelico:server:lasertimeout", function()
    TriggerClientEvent("mv-vangelico:client:LasersCoolout", -1)
end)

RegisterServerEvent("mv-vangelico:server:synctargets")
AddEventHandler("mv-vangelico:server:synctargets", function()
    TriggerClientEvent("mv-vangelico:client:synctargets",-1)
    
end)
--sync loot vitrine
RegisterServerEvent("mv-vangelico:server:syncloot")
AddEventHandler("mv-vangelico:server:syncloot", function(index)
    TriggerClientEvent("mv-vangelico:client:syncloot", -1, index)
end)

--sync loot painting
RegisterServerEvent("mv-vangelico:server:synclootPainting")
AddEventHandler("mv-vangelico:server:synclootPainting", function(index)
    TriggerClientEvent("mv-vangelico:client:synclootPainting", -1, index)
end)

--sync loot overheat
RegisterServerEvent("mv-vangelico:server:synclootOverheat")
AddEventHandler("mv-vangelico:server:synclootOverheat", function()
    TriggerClientEvent("mv-vangelico:client:synclootOverheat", -1)
end)

RegisterServerEvent('mv-vangelico:server:smashSync')
AddEventHandler('mv-vangelico:server:smashSync', function(index)
    TriggerClientEvent('mv-vangelico:client:smashSync', -1, index)
end)


RegisterServerEvent('mv-vangelico:server:globalObject')
AddEventHandler('mv-vangelico:server:globalObject', function(obj, random)
    TriggerClientEvent('mv-vangelico:client:globalObject', -1, obj, random)
end)

RegisterServerEvent('mv-vangelico:server:syncAlarm')
AddEventHandler('mv-vangelico:server:syncAlarm', function()
    TriggerClientEvent('mv-vangelico:client:alarmsync', -1)
end)

RegisterServerEvent('mv-vangelico:server:syncLasersobj')
AddEventHandler('mv-vangelico:server:syncLasersobj', function()
    TriggerClientEvent('mv-vangelico:client:LasersObjDisable', -1)
end)


local ItemTable = VangConfig.VitrineReward

RegisterServerEvent("mv-vangelico:server:lootVitrine")
AddEventHandler("mv-vangelico:server:lootVitrine", function(id)
    local source = source
    if GlassLooted[id] == false then
        if GetLoot(source, 'Vangelico') then
            GlassLooted[id] = true
        end
    end
end)

RegisterServerEvent("mv-vangelico:server:lootOverHeat")
AddEventHandler("mv-vangelico:server:lootOverHeat", function(item)
    local source = source
    if bigItem.stolen == false then
        if exports['geo-inventory']:ReceiveItem('Player', source, bigItem.items[item], 1) then
            bigItem.stolen = true
        end
    end
end)

RegisterServerEvent("mv-vangelico:server:lootPainting")
AddEventHandler("mv-vangelico:server:lootPainting", function(paintingID)
    local source = source
    if PaintingLooted[paintingID] == false then
        if exports['geo-inventory']:ReceiveItem('Player', source, 'painting', 1) then
            PaintingLooted[paintingID] = true
        end
    end
end)