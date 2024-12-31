local RegisterCallback
local RegisterItem
ESX = nil
local QBCore
local CurrentFramework

local currentJob = {}

RegisterCallback = function (name, fn)
  Task.Register(name, fn)
end

--[[ RegisterItem = function(itemName, fn)
  QBCore.Functions.CreateUseableItem(itemName, fn)
end ]]

Citizen.CreateThread(function()
    Citizen.Wait(5000)
    local resource = GetCurrentResourceName()
    local currentVersion = GetResourceMetadata(resource, 'version', 0)
    PerformHttpRequest('https://raw.githubusercontent.com/kac5a/k5_documents/master/fxmanifest.lua',function(error, result, headers)
      if not result then print('K5 Documents: ^1Couldn\'t check version.^0') end

      local update = (string.sub(result, string.find(result, 'update [^\n]+')))
      update = (string.sub(update, string.find(update, '[^update ].+'))):gsub('"', "")

      local version = string.sub(result, string.find(result, "%d.%d.%d"))
      local version_N = tonumber((version:gsub("%D+", "")))
      local currentVersion_N = tonumber((currentVersion:gsub("%D+", "")))

      if version_N > currentVersion_N then
        local title = "^4| K5 Documents                                                                                                          |"
        local message = '^4|^0 New version available on GitHub: ^1'..currentVersion.. '^0 -> ^2'..version..'^0'
        local messageLength = #(message) - 12
        local updateMessage = '^4| ^3Update: ^2'..update
        local updateMessageLength = #(updateMessage) - 6

        local length = 120

        for i=1, length - updateMessageLength do
          updateMessage = updateMessage.." "
        end
        updateMessage = updateMessage .. "^4|^0"

        for i=1, length - messageLength do
          message = message.." "
        end
        message = message .. "^4|^0"

        local border = "^4="
        for i=1, length do
          border = border .. "="
        end

        print(border)
        print(title)
        print(message)
        print(updateMessage)
        print(border.."^0")
      end
    end,'GET')
end)

RegisterCallback('k5_documents:getPlayerCopies', function(source)
  local src = source
  local PlayerIdentifier = GetPlayerIdentifier(src)

  local result = SQL(
    'SELECT id, data, isCopy FROM k5_documents WHERE ownerId = ? and isCopy = "1"', {
    PlayerIdentifier
  })
  local mappedResult = {}
  for k, v in pairs(result) do
    local thisData = json.decode(v.data)
    thisData.id = v.id
    thisData.isCopy = v.isCopy
    table.insert(mappedResult, thisData)
  end
  return (mappedResult)
end)

if Config.DocumentItemName then
  RegisterItem(Config.DocumentItemName, function(source)
    local src = source
    TriggerClientEvent("k5_documents:useItem", src)
  end)
end

RegisterCallback('k5_documents:getPlayerDocuments', function(source)
  local src = source
  local PlayerIdentifier = GetPlayerIdentifier(src)

    local result = SQL(
      'SELECT id, data, isCopy FROM k5_documents WHERE ownerId = ? and isCopy = "0"', {
       PlayerIdentifier
    })
    local mappedResult = {}
    for k, v in pairs(result) do
      local thisData = json.decode(v.data)
      thisData.id = v.id
      thisData.isCopy = v.isCopy
      table.insert(mappedResult, thisData)
    end

    return mappedResult
end)

RegisterCallback('k5_documents:getDocumentTemplates', function(source)
  local src = source  
  local PlayerJobName = GetPlayerJobName(src)

  local result = SQL(
    'SELECT id, data FROM k5_document_templates WHERE job = ?', {
    PlayerJobName
  })
    local mappedResult = {}
    for k, v in pairs(result) do
      local thisData = json.decode(v.data)
      thisData.id = v.id
      table.insert(mappedResult, thisData)
    end
    return (mappedResult)
end)

RegisterCallback('k5_documents:createTemplate', function(source, data)
  local src = source  
  local PlayerJobName = GetPlayerJobName(src)
  local prom = promise:new()

  exports.ghmattimysql:execute('INSERT INTO k5_document_templates (data, job) VALUES (?, ?)', {
			data,
			PlayerJobName
		}, function(result)
      prom:resolve(result)
		end)

    return Citizen.Await(prom)
end)

RegisterCallback('k5_documents:editTemplate', function(source, data)
  local obj = json.decode(data)
  local prom = promise:new()

  exports.ghmattimysql:execute('UPDATE k5_document_templates SET data = ? WHERE id = ?', {
			data,
			obj.id
		}, function(result)
      prom:resolve(result)
  end)

  return Citizen.Await(prom)
end)

RegisterCallback('k5_documents:deleteTemplate', function(source, data)
  local prom = promise:new()
  exports.ghmattimysql:execute('DELETE FROM k5_document_templates WHERE id = ?', {
			data
		}, function(result)
      prom:resolve(result)
  end)

  return Citizen.Await(prom)
end)


RegisterCallback('k5_documents:getPlayerData', function(source)
  local src = source
  local PlayerIdentifier = GetPlayerIdentifier(src)

  local result = SQL(
    'SELECT firstname, lastname, dateofbirth FROM users WHERE identifier = ?', {
     PlayerIdentifier
  })
  return (result[1])
end)

RegisterCallback('k5_documents:createDocument', function(source, data)
  local src = source
  local PlayerIdentifier = GetPlayerIdentifier(src)
  local prom = promise:new()

  exports.ghmattimysql:execute('INSERT INTO k5_documents (data, ownerId, isCopy) VALUES (?, ?, ?)', {
			data,
			PlayerIdentifier,
			json.decode(data).isCopy
		}, function(result)
      prom:resolve(result)
		end)

    return Citizen.Await(prom)
end)

RegisterServerEvent('k5_documents:createServerDocument')
AddEventHandler('k5_documents:createServerDocument', function(data)
  local src = source
  local PlayerIdentifier = GetPlayerIdentifier(src)
  data.createdAt = os.date()
  
  -- Example values. This data should be created on the
  -- client side and passed as the data parameter. You can
  -- delete this part.

  local firstname = "Thomas"
  local lastname = "Edison"

  local example_data = {
    name = "Vehicle Purchase Document",
    description = "This is an official purchase document",
    -- Any data that you can imagine. You can create up to 6 field sets.
    fields = {
      {
        name = "Firstname", 
        value = firstname -- Get the players firstname from the client
      },
      {
        name = "Lastname", 
        value = lastname -- Get the players lastname from the client
      },
      {
        name = "Vehicle Type", 
        value = "Nissan R35" -- Get the vehicle name from the client
      },
      {
        name = "Price", 
        value = "$100 000" -- Get the price from the client
      },
    },
    infoName = "INFORMATION",
    infoValue = "This vehicle was purchased by ".. firstname .. " " .. lastname .. ".\nThis paper is an official document that proves the original owner of the vehicle.",
    isCopy = true, -- This has to be true, so it shows up in the "My documents" tab
    issuer = {
      -- Any data that you can imagine. This can be a fake person, but the fields have to be the same (firstname, lastname, ...)
      firstname = "Simeon",
      lastname = "Yetarian",
      birthDate = "1954. 05. 26.",
      jobName = "Dealership Owner"
    }
  }

  -- DON'T DELETE THIS PART

  exports.ghmattimysql:execute('INSERT INTO k5_documents (data, ownerId, isCopy) VALUES (?, ?, ?)', {
			json.encode(data),
			PlayerIdentifier,
			true
		}, function(result)
		end)
end)

RegisterCallback('k5_documents:deleteDocument', function(source, data)
  local prom = promise:new()
  exports.ghmattimysql:execute('DELETE FROM k5_documents WHERE id = ?', {
			data
		}, function(result)
      prom:resolve(result)
  end)

  return Citizen.Await(prom)
end)

RegisterServerEvent('k5_documents:giveCopy')
AddEventHandler('k5_documents:giveCopy', function(data, targetId)
  local src = source
  local tsrc = targetId

  local TPlayerIdentifier = GetPlayerIdentifier(tsrc)

  exports.ghmattimysql:execute('INSERT INTO k5_documents (data, ownerId, isCopy) VALUES (?, ?, ?)', {
    json.encode(data),
    TPlayerIdentifier,
    true
  }, function(result)
    TriggerClientEvent("k5_documents:copyGave", src, data.name)
    TriggerClientEvent("k5_documents:copyReceived", tsrc, data.name)
  end)

end)

RegisterServerEvent("k5_documents:receiveDocument")
AddEventHandler("k5_documents:receiveDocument", function(data, targetId)
  local tsrc = targetId

  exports.ghmattimysql:execute('SELECT data FROM k5_documents WHERE id = ?', {
      data.docId,
  }, function(result)
    TriggerClientEvent("k5_documents:viewDocument", tsrc, result[1])
  end)
end)

RegisterNetEvent('Documents.JobData', function(data)
  local source = source
  currentJob[source] = data
end)


function GetPlayer(src)
  local Player
  if CurrentFramework == "esx" then
    Player = ESX.GetPlayerFromId(src)
  elseif CurrentFramework == "qb" then
    Player = QBCore.Functions.GetPlayer(src)
  end
  return Player
end

function GetPlayerIdentifier(src)
  return GetCharacter(src).id
end

function GetPlayerJobName(src)
  if exports['geo-guilds']:GuildAuthority(currentJob[src], GetCharacter(src).id) < 100 then return 'none' end
  return currentJob[src]
end