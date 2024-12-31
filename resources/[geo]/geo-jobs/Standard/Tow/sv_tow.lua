local tow = {}
Impound = {}
local flatbeds = {}

RegisterNetEvent('Tow:RequestList')
AddEventHandler('Tow:RequestList', function()
    TriggerClientEvent('Tow:UpdateData', -1, tow)
end)

RegisterNetEvent('Tow:UpdateData')
AddEventHandler('Tow:UpdateData', function(tveh, veh, trailer, slot)
    if trailer then
        if not tow[tveh] then
            tow[tveh] = {}
        end
        tow[tveh][slot] = veh
    else
        tow[tveh] = veh
    end
    Entity(NetworkGetEntityFromNetworkId(veh)).state.towed = true
    TriggerClientEvent('Tow:UpdateData', -1, tow)
end)

RegisterNetEvent('Tow:Impound')
AddEventHandler('Tow:Impound', function(veh, plate)
    local source = source
    local ent = NetworkGetEntityFromNetworkId(veh)
    if DoesEntityExist(ent) then
        if Impound[plate] then
            local char = GetCharacter(source)

            if Entity(ent).state.vin ~= nil then
                SQL('UPDATE vehicles SET garage = "Impound" WHERE id = ?', Entity(ent).state.vin)
            end

            TriggerEvent('DeleteEntity', veh)

            if not Entity(ent).state.repo then
                exports['geo-inventory']:AddItem('Player', source, 'dollar', 750)
                TriggerClientEvent('Chat.Message.ES', -1, '[Impound]', Impound[plate]..' with plate "'..plate..'" has been impounded by '..GetName(char), 'job')
            else
                TriggerEvent('Repo.Impounded', Entity(ent).state.repo)
            end
            Impound[plate] = nil
        end
    end
end)

local towCalls = {}
RegisterNetEvent('Tow:MarkImpound')
AddEventHandler('Tow:MarkImpound', function(plate, title, ent, call)
    local source = source
    local char = GetCharacter(source)

    if char.Duty == 'Police' or char.Duty == 'EMS' then
        local id = #towCalls + 1
        if not Impound[plate] then
            Impound[plate] = title
            towCalls[id] = true

            if exports['geo-es']:DutyCount('Tow') == 0 then
                if Entity(NetworkGetEntityFromNetworkId(ent)).state.vin then
                    SQL('UPDATE vehicles SET garage = "Impound" WHERE id = ?', Entity(NetworkGetEntityFromNetworkId(ent)).state.vin)
                end
            end

            Entity(NetworkGetEntityFromNetworkId(ent)).state.impound = true
            TriggerClientEvent('Chat.Message.ES', -1, '[Impound]', title..' with plate "'..plate..'" marked for impound by '..GetName(char), 'job')
        
            if call then
                for k,v in pairs(GetPlayers()) do
                    local char = GetCharacter(v)
                    if char.Duty == 'Tow' then
                        CreateThread(function()
                            if exports['geo-interface']:PhoneConfirm(tonumber(v), 'Tow Job Available', 30, 'tow') then
                                if towCalls[id] then
                                    TriggerClientEvent('PhoneNotif', v, 'tow', 'This call is now yours', 5000)
                                    TriggerClientEvent('Tow.GPS', v, GetEntityCoords(NetworkGetEntityFromNetworkId(ent)))
                                    TriggerClientEvent('PhoneNotif', source, 'tow', 'Tow driver enroute', 5000)
                                    towCalls[id] = nil
                                else
                                    TriggerClientEvent('PhoneNotif', v, 'tow', 'This call was taken', 5000)
                                end
                            end
                        end)
                    end
                end
                Wait(31000)
                if towCalls[id] then
                    TriggerClientEvent('PhoneNotif', source, 'tow', 'No tows took your call', 5000)
                end
            end
        else
            TriggerClientEvent('Chat.Message', source, '[Impound]', 'This vehicle is already marked for impound', 'job')
        end
    end
end)

RegisterNetEvent('RegisterFlatbed')
AddEventHandler('RegisterFlatbed', function(flatbed)
    local source = source
    flatbeds[source] = NetworkGetEntityFromNetworkId(flatbed)
    TriggerClientEvent('Help', source, 12)
end)

AddEventHandler('entityRemoved', function(entity)
    for k,v in pairs(flatbeds) do
        if v == entity then
            flatbeds[k] = nil
            TriggerClientEvent('DeregisterFlatbed', k)
            break
        end
    end
end)