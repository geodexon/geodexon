Departments = {
    ['Police'] = {
        ['LSPD'] = 100,
        ['BCSO'] = 100,
        ['SASP'] = 100
    },
    ['EMS'] = {
        ['EMS'] = 100
    },
    ['DOJ'] = {
        ['DOJ'] = 100
    }
}

function IsES(char)
    for k,v in pairs(Departments) do
        for key,val in pairs(v) do
            if exports['geo-guilds']:GuildAuthority(key, char) >= val then
                return key
            end
        end
    end
end

function IsPolice(char)
    for k,v in pairs(Departments.Police) do
        if exports['geo-guilds']:GuildAuthority(k, char) >= v then
            return k
        end
    end
end

function IsEMS(char)
    for k,v in pairs(Departments.EMS) do
        if exports['geo-guilds']:GuildAuthority(k, char) >= v then
            return k
        end
    end
end

function IsDOJ(char)
    for k,v in pairs(Departments.DOJ) do
        if exports['geo-guilds']:GuildAuthority(k, char) >= v then
            return k
        end
    end
end

function IsOnDuty(char)
    if IsES(char.id) then
        if char.Duty == 'Police' or char.Duty == 'EMS' then
            return true
        end
    end
end

exports('Departments', function()
    local l = {}
    for k,v in pairs(Departments) do
        for key,val in pairs(v) do
            table.insert(l, key)
        end
    end

    return l
end)

exports('IsPolice', IsPolice)
exports('IsEMS', IsEMS)
exports('IsDOJ', IsDOJ)
exports('IsEs', IsES)