Jobs = {}
Jobs.Ranks = {}
Jobs.Current = {}

JobTime = {}

DefaultCriminal = {
    {'r1', 0.85, 0},
    {'r2', 0.9, 300},
    {'r3', 0.95, 3000},
    {'r4', 1.0, 9000},
    {'r5', 1.25, 18000},
    {'r6', 1.5, 30000}
}

DefaultCiv = {
    {'Trainee', 0.55, 0},
    {'Junior Driver', 0.6, 300},
    {'Driver', 0.7, 3600},
    {'Senior Driver', 0.8, 10080},
    {'Assistant Manager', 0.9, 21000},
    {'Manager', 1.0, 36000}
}

DefaultES = {
    {'r1', 0.7, 0},
}

jobCache = {}

Jobs.Fetch = function(jobName, charID)

    local time = os.time()
    if jobCache[charID] and jobCache[charID] > time then
        TriggerClientEvent('Shared.Notif', GetCharacterByID(charID).serverid, 'Your previous employer precvents you from getting another job for '..(math.ceil((jobCache[charID] - time) / 60)..' minutes'))
        return
    end

    local prom = promise.new()
    exports.ghmattimysql:execute('SELECT id, rank, time, count, pay from jobs where business = ? and cid = ?', {jobName, charID}, function(res)
        if res[1] == nil then
            exports.ghmattimysql:execute('INSERT INTO jobs (business, cid) VALUES (?, ?)', {jobName, charID}, function(result)
                exports.ghmattimysql:execute('SELECT id, rank, time, count, pay from jobs where business = ? and cid = ?', {jobName, charID}, function(res)
                    prom:resolve(res[1])
                end)
            end)
        else
            prom:resolve(res[1])
        end
    end)

    local value = Citizen.Await(prom)
    local rObject = {
        business = jobName,
        rank = value.rank,
        time = value.time,
        count = value.count,
        cid = charID,
        pay = value.pay
    }

    function rObject:AddTime(seconds)
        local calc = seconds / 60
        self.time = self.time + calc
        exports.ghmattimysql:execute('UPDATE jobs set time = ? WHERE business = ? and cid = ?', {
            self.time, self.business, self.cid
        })
    end

    function rObject:AddCount(amount)
        self.count = self.count + amount
        exports.ghmattimysql:execute('UPDATE jobs set count = ? WHERE business = ? and cid = ?', {
            self.count, self.business, self.cid
        })
    end

    function rObject:CheckPromotion()
        local currentRank = self.rank
        if not Jobs.Ranks[self.business] then
            return false, 1
        end

        for k,v in pairs(Jobs.Ranks[self.business]) do
            if self.time >= v[3] and Jobs.Ranks[self.business][k + 1] then
                currentRank = k
                if currentRank > self.rank then
                    break
                end
            end
        end

        if currentRank > self.rank then
            self.rank = currentRank
            exports.ghmattimysql:execute('UPDATE jobs set rank = ? WHERE business = ? and cid = ?', {
                self.rank, self.business, self.cid
            })
            return true, self.rank
        end

        return false, self.rank
    end

    function rObject:TimeUntilNextRank()
        local currentRank = self.rank
        local time = self.time

        if not Jobs.Ranks[self.business][self.rank + 1] then
            return 9999999999999999999999999999999.0
        end

        return Jobs.Ranks[self.business][self.rank + 1][3] - time
    end

    function rObject:IsNextRank()
        return Jobs.Ranks[self.business][self.rank + 1] ~= nil
    end

    function rObject:GetRank()
        if not Jobs.Ranks[self.business] then
            return 'null'
        end

        local val = self.rank
        for k,v in pairs(Jobs.Ranks[self.business]) do
            if self.time >= v[3] and self.rank >= k then
                val = k
            end
        end

        self.rank = val
        return Jobs.Ranks[self.business][val][1]
    end

    function rObject:GetHours()
        return self.time / 60
    end

    function rObject:GetPay()
        if not Jobs.Ranks[self.business] then
            return 'null'
        end

        local val = self.rank
        for k,v in pairs(Jobs.Ranks[self.business]) do
            if self.time >= v[3] and self.rank >= k then
                val = k
            end
        end

        return Jobs.Ranks[self.business][val][2]
    end

    function rObject:Pay(source, maxTime)
        maxTime = maxTime or 0
        local time = os.time()
        local mth = time - JobTime[self.cid]
        mth = mth > maxTime and maxTime or mth
        local money = math.floor(self.pay + (mth  * self:GetPay()))
        if exports['geo-inventory']:ReceiveItem('Player', source, 'dollar',  money) then
            local char = GetCharacter(source)
            self:AddTime(mth)
            self.pay = 0
            JobTime[self.cid] = time

            SQL('UPDATE jobs set pay = ? WHERE business = ? and cid = ?',
                self.pay, self.business, self.cid
            )

            Console('[Job]', GetName(char)..' (ID: '..char.id..') Paid $'..comma_value(money)..' from '..self.business)
            Log('Job', {type = 'pay', cid = char.id, user = char.user, amount = money})
            return true
        end
    end

    function rObject:AddPay(maxTime)
        local time = os.time()
        local mth = time - JobTime[self.cid]
        mth = mth > maxTime and maxTime or mth
        self.pay = self.pay + math.abs(math.floor(mth * self:GetPay()))
        self:AddTime(mth)
        JobTime[self.cid] = time
        exports.ghmattimysql:execute('UPDATE jobs set pay = ? WHERE business = ? and cid = ?', {
            self.pay, self.business, self.cid
        })
        return math.abs(math.floor(mth * self:GetPay()))
    end

    function rObject:AddPayNum(amount)
        self.pay = self.pay + amount
        exports.ghmattimysql:execute('UPDATE jobs set pay = ? WHERE business = ? and cid = ?', {
            self.pay, self.business, self.cid
        })

        return self.pay
    end

    rObject:GetRank()
    setmetatable(rObject, {})
    Console('[Jobs]', GetPlayerName(exports['geo']:CharFromID(charID).serverid).. ' ('..charID..') Loaded '..jobName)
    return rObject
end

Jobs.Get = function(char)
    return Jobs.Current[char]
end

Jobs.Busy = function(src)
    TriggerClientEvent('Shared.Notif', src, 'You are already on a job')
end

function Jobs:RegisterRanking(jobName, ranks)
    Jobs.Ranks[jobName] = ranks
end

exports('JobObject', Jobs.Fetch)
exports('JobController', function()
    return Jobs
end)

AddEventHandler('JobCache', function(charID)
    jobCache[charID] = os.time() + 3600
end)

local checkins = {}
CreateThread(function()
    while true do
        for k,v in pairs(GetPlayers()) do
            local char = GetCharacter(v)
            if char and JobTime[char.id] then
                local id = uuid()
                checkins[id] = char.id
                TriggerClientEvent('Job.CheckIn', v, id)
            end
        end

        Wait(60000 * 10)
    end
end)

local lastDistance = {}
RegisterNetEvent('Job.CheckIn', function(id, val)
    local source = source
    if checkins[id] then
       if lastDistance[checkins[id]] == nil then lastDistance[checkins[id]] = val - 100.0 end
       if val - lastDistance[checkins[id]] <= 50.0 then
           local char = GetCharacter(source)
           JobTime[checkins[id]] = JobTime[checkins[id]] + (60 * 10)
           Console('[AFK]', Format('%s [%s] Did not move enough recently, reducing job pay', GetName(char), char.id))
       end

        lastDistance[checkins[id]] = val
    end
end)