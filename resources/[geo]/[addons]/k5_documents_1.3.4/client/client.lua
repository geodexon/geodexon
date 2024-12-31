local selectingPlayer = false
local prop = nil

local TriggerCallback
local Notification
local jobData = {}

CreateThread(function()
    Wait(1000)
    SendNUIMessage({
      interface = 'Guilds',
      data = exports['geo-guilds']:GetGuilds()
    })
end)

RegisterNetEvent('Guilds:UpdateSingle')
AddEventHandler('Guilds:UpdateSingle', function(guild, data)
    Wait(1000)
    SendNUIMessage({
        interface = 'GuildsAdjust',
        data = {guild, data}
    })
end)


TriggerCallback = function(name, cb, ...)
    local data = Task.Run(name, ...)
    cb(data)
end

Notification = function(msg)
    TriggerEvent('Shared.Notif', msg)
end

function holdDocument(shouldHold)
    if shouldHold then
        detachPaper()
        
        playAnim("missfam4", "base")
        
        attachPaper()
    
    else
        ClearPedTasks(GetPlayerPed(-1))
        detachPaper()
    end
end

function playAnim(dict, anim, duration)
    duration = duration or -1
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
    
    TaskPlayAnim(GetPlayerPed(-1), dict, anim, 2.0, 2.0, duration, 51, 0, false, false, false)
    RemoveAnimDict(dict)
end

function attachPaper()
    local player = PlayerPedId()
    local x, y, z = table.unpack(GetEntityCoords(player))
    
    while not HasModelLoaded(GetHashKey(Config.PaperProp.name)) do
        RequestModel(GetHashKey(Config.PaperProp.name))
        Wait(10)
    end
    
    prop = CreateObject(GetHashKey(Config.PaperProp.name), x, y, z + 0.2, true, true, true)
    SetEntityCompletelyDisableCollision(prop, false, false)
    AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 36029), 0.16, 0.08, 0.1, Config.PaperProp.xRot, Config.PaperProp.yRot, Config.PaperProp.zRot, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(Config.PaperProp.name)
end

function detachPaper()
    DeleteEntity(prop)
end

local function toggleNuiFrame(shouldShow, shouldHoldDocument)
    holdDocument(shouldHoldDocument)
    SetNuiFocus(shouldShow, shouldShow)
    SendReactMessage('setVisible', shouldShow)
end

local function toggleDocumentFrame(shouldShow, document)
    holdDocument(shouldShow)
    SetNuiFocus(shouldShow, shouldShow)
    SendReactMessage('setDocument', document)
end

RegisterNUICallback('hideDocument', function(_, cb)
    toggleDocumentFrame(false, nil)
    cb({})
end)

--toggleDocumentFrame
RegisterCommand(Config.Command, function()
    local guilds = exports['geo-guilds']:GetGuilds()
    
    local guildData = {}
    for k, v in pairs(guilds) do
        if exports['geo-guilds']:GuildAuthority(k, MyCharacter.id) >= 100 then
            table.insert(guildData, {k, v.owner == MyCharacter.id and 3 or 1, v.guild})
        end
    end
    
    if #guildData > 1 then
        local menu = {}
        for k, v in pairs(guildData) do
            table.insert(menu,{
                title = v[3],
                event = 'Documents.SetJobData',
                params = {v} 
        })
        end
        RunMenu(menu)
    elseif #guildData == 1 then
        jobData = {
            grade = guildData[1][2],
            --grade_label = 'Idiot',
            --grade_name = 'Idiot',
            grade_salary = 500,
            --label = 'Idiot',
            name = guildData[1][1],
        }
        TriggerServerEvent('Documents.JobData', guildData[1][1])
        toggleNuiFrame(true, true)
    else
        jobData = {
            grade = 1,
            --grade_label = 'Idiot',
            --grade_name = 'Idiot',
            grade_salary = 500,
            --label = 'Idiot',
            name = 'none',
        }
        jobData.isBoss = true
        TriggerServerEvent('Documents.JobData', 'none')
        toggleNuiFrame(true, true)
    end
end)

AddEventHandler('Documents.SetJobData', function(data)
    jobData = {
        grade = data[2],
        --grade_label = 'Idiot',
        --grade_name = 'Idiot',
        grade_salary = 500,
        --label = 'Idiot',
        name = data[1],
    }
    jobData.isBoss = true
    TriggerServerEvent('Documents.JobData', data[1])
    toggleNuiFrame(true, true)
end)

RegisterNUICallback('hideFrame', function(_, cb)
    toggleNuiFrame(false, false)
    cb({})
end)

RegisterNUICallback('getPlayerJob', function(data, cb)
    cb(jobData)
end)

RegisterNUICallback('getPlayerData', function(data, cb)
    cb({
        firstname = MyCharacter.first,
        lastname = MyCharacter.last,
        dateofbirth = MyCharacter.dob,
    })
end)

RegisterNUICallback('getPlayerCopies', function(data, cb)
    TriggerCallback('k5_documents:getPlayerCopies', function(result)
        cb(result)
    end)
end)

RegisterNUICallback('getIssuedDocuments', function(data, cb)
    TriggerCallback('k5_documents:getPlayerDocuments', function(result)
        cb(result)
    end)
end)

RegisterNUICallback('createDocument', function(data, cb)
    TriggerCallback('k5_documents:createDocument', function(result)
        cb(result)
    end,
    data)
end)

RegisterNUICallback('createTemplate', function(data, cb)
    TriggerCallback('k5_documents:createTemplate', function(result)
        cb(result)
    end,
    data)
end)

RegisterNUICallback('editTemplate', function(data, cb)
    TriggerCallback('k5_documents:editTemplate', function(result)
        cb(result)
    end,
    data)
end)

RegisterNUICallback('deleteTemplate', function(data, cb)
    TriggerCallback('k5_documents:deleteTemplate', function(result)
        cb(result)
    end,
    data)
end)

RegisterNUICallback('deleteDocument', function(data, cb)
    TriggerCallback('k5_documents:deleteDocument', function(result)
        cb(result)
    end,
    data)
end)

RegisterNUICallback('getMyTemplates', function(data, cb)
    TriggerCallback('k5_documents:getDocumentTemplates', function(result)
        cb(result)
    end)
end)

RegisterNUICallback('giveCopy', function(data, cb)
    Citizen.CreateThread(function()
        local targetId = playerSelector(Config.Locale.giveCopy)
        if targetId == -1 then
            holdDocument(false)
        else
            TriggerServerEvent("k5_documents:giveCopy", data, targetId)
        end
    end)
end)

RegisterNUICallback('showDocument', function(data, cb)
    Citizen.CreateThread(function()
        local targetId = playerSelector(Config.Locale.showDocument)
        if targetId == -1 then
            holdDocument(false)
        else
            holdDocument(false)
            playAnim("mp_common", "givetake1_a", 1500)
            TriggerServerEvent("k5_documents:receiveDocument", data, targetId)
        end
    end)
end)

RegisterNetEvent('k5_documents:copyGave')
AddEventHandler('k5_documents:copyGave', function(data)
    holdDocument(false)
    playAnim("mp_common", "givetake1_a", 1500)
    Notification(Config.Locale.giveNotification .. " " .. data)
end)

RegisterNetEvent("k5_documents:useItem")
AddEventHandler("k5_documents:useItem", function()
    toggleNuiFrame(true, true)
end)


RegisterNetEvent('k5_documents:copyReceived')
AddEventHandler('k5_documents:copyReceived', function(data)
    Notification(Config.Locale.receiveNotification .. " " .. data)
end)

RegisterNetEvent('k5_documents:viewDocument')
AddEventHandler('k5_documents:viewDocument', function(data)
    toggleDocumentFrame(true, data.data)
end)

if Config.RegisterKey then
    if Config.Command then
        RegisterKeyMapping(Config.Command, Config.Locale.registerMapDescription, "keyboard", Config.RegisterKey)
    else
        print("^8ERROR: ^3No document command found. Please provide a \"Config.Command\" value.^7")
    end
end

function playerSelector(confirmText)
    toggleNuiFrame(false, true, nil)
    selectingPlayer = true
    
    while selectingPlayer do
        local closestPlayer = GetClosestPlayer(2.0)
        
        DisableControlAction(2, 200, true)
        
        if IsControlJustReleased(0, 202) then
            selectingPlayer = false
            return -1
        end
        
        BeginTextCommandDisplayHelp('main')
        AddTextEntry('main', "~INPUT_CONTEXT~ " .. confirmText .. "  ~INPUT_FRONTEND_PAUSE_ALTERNATE~ " .. Config.Locale.cancel)
        EndTextCommandDisplayHelp(0, 0, 1, -1)
        
        if closestPlayer then
            local closestPlayerCoords = GetEntityCoords(GetPlayerPed(closestPlayer))
            DrawMarker(20, closestPlayerCoords.x, closestPlayerCoords.y, closestPlayerCoords.z + 1.2, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.4, 0.4, -0.4, 255, 255, 255, 100, false, true, 2, false, false, false, false)
            DrawMarker(25, closestPlayerCoords.x, closestPlayerCoords.y, closestPlayerCoords.z - 0.95, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 100, false, true, 2, false, false, false, false)
            if IsControlJustReleased(0, 38) then
                selectingPlayer = false
                local targetId = GetPlayerServerId(closestPlayer)
                return targetId
            end
        else
            if IsControlJustReleased(0, 38) then
                Notification(Config.Locale.noPlayersAround)
            end
        end
        Citizen.Wait(1)
    end
end
