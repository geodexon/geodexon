Guilds = {}
function GuildAuthority(guild, charid)
    if not Guilds[guild] then
        return 0
    end

    if Guilds[guild].owner == charid then
        return 999999
    end

    local members = GuildMembers(guild)

    if members[tostring(charid)] ~= nil then
        local val = members[tostring(charid or 0)] and members[tostring(charid or 0)].title

        local found = false
        for k,v in pairs(Guilds[guild].ranks) do
            if v[1] == val then
                return v[2]
            end
        end
    else
        if Guilds[guild].temp[tostring(charid)] then
            local val = Guilds[guild].temp[tostring(charid)].title
            for k,v in pairs(Guilds[guild].ranks) do
                if v[1] == val then
                    return v[2] < 1000 and v[2] or 999
                end
            end
        end
    end

    return 0
end

function GuildHasFlag(guild, charid, flag)
    if not Guilds[guild] then
        return 0
    end

   --[[  if Guilds[guild].owner == charid then
        return true
    end ]]

    local members = GuildMembers(guild)
    charid = tostring(charid)
    if members[charid] ~= nil then
        local title = members[charid].title
        if members[charid].flags then
            for k,v in pairs(members[charid].flags) do
                if v == flag then return true end
            end
        end

        local ranks = Guilds[guild].ranks
        for k,v in pairs(ranks) do
            if title == v[1] then
                if v[3] then
                    for key,val in pairs(v[3]) do
                        if val == flag then return true end
                    end
                end
            end
        end
    end

    return false
end

function RankAuthority(guild, rank)
    if not Guilds[guild] then
        return 0
    end

    for k,v in pairs(Guilds[guild].ranks) do
        if v[1] == rank then return v[2] end
    end

    return 0
end

function GuildTitle(guild, charid)
    if not Guilds[guild] then
        return 'NULL'
    end

    local members = GuildMembers(guild)
    for k,v in pairs(members) do
        if k == tostring(charid) then
            return v.title
        end
    end

    for k,v in pairs(Guilds[guild].temp) do
        if k == tostring(charid) then
            return v.title
        end
    end

    return 'NULL'
end

function GuildMembers(guild)
    if not Guilds[guild] then
        return {}
    end

    return Guilds[guild].members
end

function GuildOwner(guild)
    if not Guilds[guild] then
        return {}
    end

    return Guilds[guild].owner
end

function HasFlag(guild, charid, flag)
    if not Guilds[guild] then
        return false
    end

    local members = GuildMembers(guild)
    if members[tostring(charid)] then
        if members[tostring(charid)].flags then
            for key, val in pairs(members[tostring(charid)].flags) do
                if val == flag  then
                    return true
                end
            end
        end
    end

    return false
end

exports('HasFlag', HasFlag)
exports('GuildAuthority', GuildAuthority)
exports('GuildTitle', GuildTitle)
exports('GuildOwner', GuildOwner)
exports('GuildHasFlag', GuildHasFlag)
exports('GetGuilds', function()
    return Guilds
end)