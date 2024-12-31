local pedDamage = {}
RegisterServerEvent('EMS:PedDamage')
AddEventHandler('EMS:PedDamage', function(damage)
    local source = source
    local time = GetGameTimer()
    if pedDamage[source] == nil then
        pedDamage[source] = {}
    end
    for k,v in pairs(damage) do
        if pedDamage[source][v.type] == nil then
            pedDamage[source][v.type] = {}
        end
        pedDamage[source][v.type][#pedDamage[source][v.type] + 1] = {type = v.type, bone = v.bone, time = time}
    end
end)

RegisterServerEvent('EMS:Triage')
AddEventHandler('EMS:Triage', function(serverID)
    local source = source
    local char = GetCharacter(source)
    if not IsES(char.id) then
        return
    end

    local time = GetGameTimer()
    if pedDamage[serverID] == nil then
        pedDamage[serverID] = {}
    end
    for k,v in pairs(pedDamage[serverID]) do
        for key,value in pairs(v) do
            if time + 7200000 < value.time then
                pedDamage[k][key] = nil
            end
        end
    end
    TriggerClientEvent('EMS:Triage', source, pedDamage[serverID])
end)