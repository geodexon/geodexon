local evidence = {}

RegisterNetEvent('Evidence.Shot')
AddEventHandler('Evidence.Shot', function(serialNumber, weapon, zone)
    local source = source
    local id = #evidence + 1
    if not serialNumber then return end
    evidence[id] = {
        eType = 'Casing',
        Serial = serialNumber:sub(Random(0, 6), 17),
        FullSerial = serialNumber,
        Weapon = weapon,
        ID = id,
        pos = GetEntityCoords(GetPlayerPed(source)) - vec(0.0, 0.0, 0.98),
        zone = zone
    }

    TriggerClientEvent('Evidence.Shot', -1, evidence[id], id)
end)

RegisterNetEvent('Evidence.Bleed', function(zone)
    local source = source
    local id = #evidence + 1
    local char = GetCharacter(source)
    if char.data.dna == nil then char.data.dna = uuidshort() end
    SetData(source, 'dna', char.data.dna)

    evidence[id] = {
        eType = 'Blood',
        Serial = char.data.dna,
        pos = GetEntityCoords(GetPlayerPed(source)) - vec(0.0, 0.0, 0.98),
        zone = zone
    }

    TriggerClientEvent('Evidence.Shot', -1, evidence[id], id)
end)

RegisterNetEvent('Evidence.Entity')
AddEventHandler('Evidence.Entity', function(ped, hash, serialNumber, male)
    ped = NetworkGetEntityFromNetworkId(ped)
    local ent = Entity(ped)
    if ent.state.evidence == nil then ent.state.evidence = '[]' end

    local evidence = json.decode(ent.state.evidence)
    evidence[#evidence + 1] = {
        hash = hash,
        Serial = serialNumber:sub(Random(0, 6), 17),
    }

    ent.state.evidence = json.encode(evidence)
end)

local peopleEvidence = {}

RegisterNetEvent('Evidence.Analyze')
AddEventHandler('Evidence.Analyze', function(ped)
    local source = source
    local char = GetCharacter(source)
    ped = NetworkGetEntityFromNetworkId(ped)
    local ent = Entity(ped)
    if ent.state.evidence == nil then ent.state.evidence = '[]' end

    local pEvidence = json.decode(ent.state.evidence)
    if exports['geo-interface']:PhoneConfirm(source, 'Would you like to subscribe for their injuries?', 60, 'echat') then
        if peopleEvidence[char.id] == nil then peopleEvidence[char.id] = {} end
        local first = firstNames[math.random(#firstNames)]
        local last = lastNames[math.random(#lastNames)]
        TriggerClientEvent('PhoneNotif', source, 'echat', ("%s %s's details will be available at the hospital later"):format(first, last))
        SetTimeout(60000 * 15, function()
            table.insert(peopleEvidence[char.id], {
                evidence = pEvidence,
                first = first,
                last = last
            })
        end)
    end
end)

AddStateBagChangeHandler(false, false, function(bagName, key, value, source, replicated)
    local entityNet
    local entity
    local ent

    if bagName:match('entity:') then
        entityNet = tonumber(bagName:gsub('entity:', ''), 10)
        entity = NetworkGetEntityFromNetworkId(entityNet)
        ent = Entity(entity)
    elseif bagName:match('player:') then
        entityNet = tonumber(bagName:gsub('player:', ''), 10)
        ent = Player(entityNet)
    end

    local curState = ent.state[key]

    if source ~= 0 then
        SetTimeout(0, function()
            print('removed fake bag: '..bagName)
            ent.state[key] = curState
        end)
    end
end)

Task.Register('PeopleEvidence', function(source)
    return peopleEvidence[GetCharacter(source).id]
end)

RegisterNetEvent('Evidence.Clear')
AddEventHandler('Evidence.Clear', function(list)
    local source = source
    local char = GetCharacter(source)
    if char.Duty == 'Police' then
        TriggerClientEvent('Evidence.Clear', -1, list)
    end
end)

RegisterNetEvent('ShotPlayer', function(id, wep)
    local source = source
    local me = GetCharacter(source)
    local other = GetCharacter(id)
    Log('PVP', Format('%s [%s] Attacked %s [%s] with %s', GetName(me), me.id, GetName(other), other.id, wep or 'Unknown'))
end)

RegisterNetEvent('EMSDown', function(loc)
    local source = source
    local char = GetCharacter(source)
    if char.Duty == 'Police' then
        TriggerEvent('Dispatch', {
            code = '10-13',
            title = 'Medic Dead',
            location = loc.position,
    
            time =  os.date('%H:%M EST'),
            info = {
                {
                    icon = 'location',
                    text = loc.location,
                    location = true
                },
                {
                    icon = 'person',
                    text = 'This medic has gone 10-42 on their final shift.'
                }
            }
        })
    end
end)

Task.Register('Evidence.Collect', function(source, id, count)
    if evidence[id] and GetCharacter(source).Duty == 'Police' then
        if evidence[id].eType == 'Casing' then
            local item = exports['geo-inventory']:InstanceItem('evidence_bullet')
            item.Data.Serial = evidence[id].FullSerial
            item.Data.Count = count
            return exports['geo-inventory']:AddItem('Player', source, 'evidence_bullet', 1, item)
        elseif evidence[id].eType == 'Blood' then
            local item = exports['geo-inventory']:InstanceItem('evidence_blood')
            item.Data.Serial = evidence[id].Serial
            item.Data.Count = count
            return exports['geo-inventory']:AddItem('Player', source, 'evidence_blood', 1, item)
        end
    end
end)

AddEventHandler('Login', function(char, user)
    if not char.data.dna then
        while char.data.dna == nil do
            Wait(100)
            local id = uuidshort()
            local found = SQL('SELECT JSON_VALUE(`data`, "$.dna") FROM characters WHERE JSON_VALUE(`data`, "$.dna") = ?', id)[1]
            if not found then
                SetData(char.serverid, 'dna', id)
                Console('[DNA]', 'Assigned DNA to '..GetName(char))
                break
            end
        end
    end

    if not user.data.ref then
        while user.data.ref == nil do
            Wait(100)
            local id = uuidshort()
            local found = SQL('SELECT JSON_VALUE(`data`, "$.ref") FROM users WHERE JSON_VALUE(`data`, "$.ref") = ?', id)[1]
            if not found then
                SetUserData(char.serverid, 'ref', id)
                Console('[Ref]', 'Assigned Ref code to '..user.username)
                break
            end
        end
    end
end)