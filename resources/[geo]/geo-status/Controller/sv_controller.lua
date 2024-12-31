function Status:Add(source, statusID, time, temp)
    if not self.Statuses[statusID] then
        Console('[Status]', 'Invalid Status: '..statusID)
    end

    local char = GetCharacter(source)
    local gTime = os.time()
    if char.dead == 1 then return false end

    if not Status.Players[char.id] then
        Status.Players[char.id] = {}
        Status.Players[char.id].Statuses = {}
    end

    time = time == -1 and 9999999999999 or time

    if self.Players[char.id].Statuses[statusID] ~= nil then
        self.Players[char.id].Statuses[statusID].seconds = self.Players[char.id].Statuses[statusID].seconds - (gTime - self.Players[char.id].Statuses[statusID].StartTime)
        self.Players[char.id].Statuses[statusID].StartTime = gTime
        if self.Players[char.id].Statuses[statusID].seconds <= 0 then
            self.Players[char.id].Statuses[statusID] = nil
        end
    end

    if self.Players[char.id].Statuses[statusID] == nil then
        self.Players[char.id].Statuses[statusID] = {
            StartTime = gTime,
            seconds = time
        }
    else
        self.Players[char.id].Statuses[statusID].seconds = self.Players[char.id].Statuses[statusID].seconds + time
        if self.Players[char.id].Statuses[statusID].seconds > 7200 then self.Players[char.id].Statuses[statusID].seconds = 7200 end
    end

    TriggerClientEvent('Status.Set', char.serverid, statusID,  self.Players[char.id].Statuses[statusID].seconds)
end

function Status:Remove(source, statusID, time, temp)
    if not self.Statuses[statusID] then
        Console('[Status]', 'Invalid Status: '..statusID)
    end

    local char = GetCharacter(source)

    if not Status.Players[char.id] then
        Status.Players[char.id] = {}
        Status.Players[char.id].Statuses = {}
    end

    if time == -1 then time = 99999999999999 end

    local gTime = os.time()
    if self.Players[char.id].Statuses[statusID] ~= nil then
        self.Players[char.id].Statuses[statusID].seconds = self.Players[char.id].Statuses[statusID].seconds - time
        self.Players[char.id].Statuses[statusID].StartTime = gTime
        if self.Players[char.id].Statuses[statusID].seconds <= 0 then
            self.Players[char.id].Statuses[statusID] = nil
        end
    end

    TriggerClientEvent('Status.Set', char.serverid, statusID,  (self.Players[char.id].Statuses[statusID] or {}).seconds or 0)
end

function Status:Has(charID, statusID)

    if not Status.Players[charID] then
        Status.Players[charID] = {}
        Status.Players[charID].Statuses = {}
    end

    local gTime = os.time()
    if self.Players[charID].Statuses[statusID] ~= nil then
        self.Players[charID].Statuses[statusID].seconds = self.Players[charID].Statuses[statusID].seconds - (gTime - self.Players[charID].Statuses[statusID].StartTime)
        self.Players[charID].Statuses[statusID].StartTime = gTime
        if self.Players[charID].Statuses[statusID].seconds <= 0 then
            self.Players[charID].Statuses[statusID] = nil
        end
    end
    
    return self.Players[charID].Statuses[statusID]
end

AddEventHandler('Login', function(char)
    TriggerClientEvent('Status.Clear', char.serverid)
    if not Status.Players[char.id] then
        Status.Players[char.id] = {}
        Status.Players[char.id].Statuses = {}
    end
   
    local gTime = os.time()
    for k,v in pairs(Status.Players[char.id].Statuses) do
        if v then
            v.seconds = v.seconds - (gTime - self.Players[char.id][statusID].StartTime)
            v.StartTime = gTime
            if v.seconds <= 0 then
                v = nil
            end
            TriggerClientEvent('Status.Set', char.serverid, k, Status.Players[char.id].Statuses[k])
        end
    end
end)

AddEventHandler('Logout', function(char)
    TriggerClientEvent('Status.Clear', char.serverid)
end)

exports('Add', function(...)
    Status:Add(...)
end)

exports('Remove', function(...)
    Status:Remove(...)
end)