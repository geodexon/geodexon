Citizen.CreateThread(function()
    local val = exports.ghmattimysql:executeSync('SELECT * FROM guilds')

    for k,v in pairs(val) do
        Guilds[v.ident] = v
        Guilds[v.ident].members = json.decode(v.members)
        Guilds[v.ident].ranks = json.decode(v.ranks)
        Guilds[v.ident].keycard = json.decode(v.keycard)
        Guilds[v.ident].image = v.image
        Guilds[v.ident].temp = {}
        Guilds[v.ident].role = v.role
    end

    --TriggerClientEvent('RequestGuilds', -1, Guilds)
end)

RegisterNetEvent('RequestGuilds')
AddEventHandler('RequestGuilds', function()
    local source = source
    local char = GetCharacter(source)
    TriggerClientEvent('RequestGuilds', source, Guilds)
end)

RegisterNetEvent('Guild:Create')
AddEventHandler('Guild:Create', function(acronym, name)
    local source = source
    local char = GetCharacter(source)

    if char == nil then
        return
    end

    if type(acronym) ~= 'string' or type(name) ~= 'string' then
        return
    end

    if acronym:len() <= 0 or name:len() <= 0 then
        return
    end

    if acronym:len() > 4 or name:len() > 46 then
        return
    end

    acronym = acronym:upper()

    if Guilds[acronym] ~= nil then
        return
    end

    if exports['geo-inventory']:RemoveItem('Player', source, 'guild_token', 1) then
        exports.ghmattimysql:executeSync('INSERT into guilds (ident, guild, owner) VALUES (@Acro, @Name, @Owner)', {
            Acro = acronym,
            Name = name,
            Owner = char.id
        })

        local val = exports.ghmattimysql:executeSync('SELECT * FROM guilds WHERE ident = @Ident', {Ident = acronym})[1]
        Guilds[val.ident] = val
        Guilds[val.ident].members = json.decode(val.members)
        Guilds[val.ident].ranks = json.decode(val.ranks)
        Guilds[val.ident].keycard = json.decode(val.keycard)
        Guilds[val.ident].temp = {}
        TriggerClientEvent('Guilds:UpdateSingle', -1, val.ident, Guilds[val.ident])
    end
end)

RegisterNetEvent('Guild:AddRank')
AddEventHandler('Guild:AddRank', function(guild, rank, auth)
    local source = source

    if not Guilds[guild] then
        return
    end

    auth = tonumber(auth)

    if type(rank) ~= 'string' or type(auth) ~= 'number' then
        return
    end

    if rank:len() <= 0 then
        return
    end

    if auth > 10000 or auth < 0 then
        return
    end

    if Guilds[guild].owner ~= GetCharacter(source).id then
        return
    end

    Guilds[guild] = New(Guilds[guild])

    local ranks = New(Guilds[guild].ranks)
    for k,v in pairs(ranks) do
        if v[1] == rank then
            return
        end
    end

    table.insert(ranks, {rank, auth})
    Guilds[guild].ranks = ranks
    exports.ghmattimysql:execute('UPDATE guilds SET ranks = @Ranks WHERE ident = @Ident', {
        Ranks = json.encode(ranks),
        Ident = guild
    })

    TriggerClientEvent('Guilds:UpdateSingle', -1, guild, Guilds[guild])
end)

RegisterNetEvent('Guild:RemoveRank')
AddEventHandler('Guild:RemoveRank', function(guild, rank)
    local source = source

    if not Guilds[guild] then
        return
    end

    if Guilds[guild].owner ~= GetCharacter(source).id then
        return
    end

    Guilds[guild] = New(Guilds[guild])

    local id
    local ranks = New(Guilds[guild].ranks)
    for k,v in pairs(ranks) do
        if v[1] == rank then
            id = k
        end
    end

    if not id then
        return
    end

    local value = ranks[id][2]
    table.remove(ranks, id)
    table.sort(ranks, function(a, b)
        return a[2] < b[2]
    end)

    local members = New(Guilds[guild].members)
    for k,v in pairs(members) do
        if v.title == rank then
            if ranks[1] then 
                if ranks[1][2] < value then
                    members[k].title = ranks[1][1]
                else
                    members[k].title = 'Invalid Rank'
                end
            else
                members[k].title = 'Invalid Rank'
            end
        end
    end

    Guilds[guild].ranks = ranks
    Guilds[guild].members = members

    exports.ghmattimysql:execute('UPDATE guilds SET ranks = @Ranks WHERE ident = @Ident', {
        Ranks = json.encode(ranks),
        Ident = guild
    })

    exports.ghmattimysql:execute('UPDATE guilds SET members = @Members WHERE ident = @Ident', {
        Members = json.encode(members),
        Ident = guild
    })

    TriggerClientEvent('Guilds:UpdateSingle', -1, guild, Guilds[guild])
end)

RegisterNetEvent('Guild:RenameRank')
AddEventHandler('Guild:RenameRank', function(guild, rank, newname)
    local source = source

    if not Guilds[guild] then
        return
    end

    if Guilds[guild].owner ~= GetCharacter(source).id then
        return
    end

    if type(newname) ~= 'string' then
        return
    end

    Guilds[guild] = New(Guilds[guild])

    local id
    local ranks = New(Guilds[guild].ranks)
    for k,v in pairs(ranks) do
        if v[1] == rank then
            id = k
        end
    end

    if not id then
        return
    end

    ranks[id][1] = newname
    table.sort(ranks, function(a, b)
        return a[2] < b[2]
    end)

    local members = New(Guilds[guild].members)
    for k,v in pairs(members) do
        if v == rank then
            members[k].title = newname
        end
    end

    Guilds[guild].ranks = ranks
    Guilds[guild].members = members

    exports.ghmattimysql:execute('UPDATE guilds SET ranks = @Ranks WHERE ident = @Ident', {
        Ranks = json.encode(ranks),
        Ident = guild
    })

    exports.ghmattimysql:execute('UPDATE guilds SET members = @Members WHERE ident = @Ident', {
        Members = json.encode(members),
        Ident = guild
    })

    TriggerClientEvent('Guilds:UpdateSingle', -1, guild, Guilds[guild])
end)

RegisterNetEvent('Guild:ModifyAuthority')
AddEventHandler('Guild:ModifyAuthority', function(guild, rank, newAuth)
    local source = source

    if not Guilds[guild] then
        return
    end

    if Guilds[guild].owner ~= GetCharacter(source).id then
        return
    end

    newAuth = tonumber(newAuth)
    if type(newAuth) ~= 'number' then
        return
    end

    if newAuth > 10000 or newAuth < 0 then
        return
    end

    Guilds[guild] = New(Guilds[guild])

    local id
    local ranks = New(Guilds[guild].ranks)
    for k,v in pairs(ranks) do
        if v[1] == rank then
            id = k
        end
    end

    if not id then
        return
    end

    ranks[id][2] = newAuth
    table.sort(ranks, function(a, b)
        return a[2] < b[2]
    end)

    Guilds[guild].ranks = ranks

    exports.ghmattimysql:execute('UPDATE guilds SET ranks = @Ranks WHERE ident = @Ident', {
        Ranks = json.encode(ranks),
        Ident = guild
    })

    TriggerClientEvent('Guilds:UpdateSingle', -1, guild, Guilds[guild])
end)

RegisterNetEvent('Guild:Hire')
AddEventHandler('Guild:Hire', function(guild, target, rank)
    local source = source

    if not Guilds[guild] then
        return
    end

    target = tonumber(target)
    if type(target) ~= 'number' then
        return
    end

    local char = GetCharacter(source)

    local myAuth = GuildAuthority(guild, char.id)
    if myAuth < 1000 then
        return
    end

    local rnk
    for k,v in pairs(Guilds[guild].ranks) do
        if v[1] == rank then
            rnk = v
            break
        end
    end

    if not rnk then
        return
    end

    if myAuth > rnk[2] then
        if Guilds[guild].members[tostring(target)] == nil then
            local person = exports.ghmattimysql:executeSync('SELECT id, first, last, username from characters where id = @ID', {ID = target})[1]
            if person then
                local attempt = GetCharacterByID(person.id)
                if attempt then
                    if exports['geo-interface']:PhoneConfirm(attempt.serverid, 'Join Guild:'..guild , 30, 'guilds') then
                        SetGuildRank(guild, target, rnk[1])
                        TriggerClientEvent('Guild:Rank', -1, char, person, guild, rnk[1])

                        if Guilds[guild].role then
                            PerformHttpRequest('127.0.0.1:8080/role', function(err, text, header) end, 'POST',
                            json.encode({
                                role = Guilds[guild].role,
                                user = GetUser(GetCharacterByID(target).serverid).discord,
                            }), { ['Content-Type'] = 'application/json'})
                        end
                    end
                else
                    --[[ exports.ghmattimysql:executeSync('DELETE FROM guild_invites WHERE `char` = @Char and `guild` = @Guild', {
                        Char = person.id,
                        Guild = guild,
                    })
    
                    exports.ghmattimysql:executeSync('INSERT INTO guild_invites (`char`, `guild`, `rank`, `author`) VALUES (@Char, @Guild, @Rank, @Author)', {
                        Char = person.id,
                        Guild = guild,
                        Rank = rnk[1],
                        Author = char.id
                    }) ]]
                end
                TriggerClientEvent('Guild:Invite', -1, char, person, guild, rnk[1])
            end
        else
            local targetAuth = GuildAuthority(guild, target)

            if myAuth > targetAuth or Guilds[guild].owner == char.id then

                local person = exports.ghmattimysql:executeSync('SELECT id, first, last, username from characters where id = @ID', {ID = target})[1]
                if person then
                    SetGuildRank(guild, target, rnk[1])
                    TriggerClientEvent('Guild:Rank', -1, char, person, guild, rnk[1])
                end
            end
        end
    end
end)

RegisterNetEvent('Guild:HireTemp')
AddEventHandler('Guild:HireTemp', function(guild, target, rank)
    local source = source

    if not Guilds[guild] then
        return
    end

    target = tonumber(target)
    if type(target) ~= 'number' then
        return
    end

    local char = GetCharacter(source)

    local myAuth = GuildAuthority(guild, char.id)
    if myAuth < 1000 then
        return
    end

    local rnk
    for k,v in pairs(Guilds[guild].ranks) do
        if v[1] == rank then
            rnk = v
            break
        end
    end

    if not rnk then
        return
    end

    if myAuth > rnk[2] then
        if Guilds[guild].members[tostring(target)] == nil then
            local pChar = GetCharacterByID(target)
            if pChar == nil then
                TriggerClientEvent('Shared.Notif', source, 'This person is not available', 2500)
                return 
            end

            Guilds[guild].temp[tostring(target)] = {title = rank}
            TriggerClientEvent('Guilds:UpdateSingle', -1, guild, Guilds[guild])

       --[[  else
            local targetAuth = GuildAuthority(guild, target)

            if myAuth > targetAuth or Guilds[guild].owner == char.id then

                local person = exports.ghmattimysql:executeSync('SELECT id, first, last, username from characters where id = @ID', {ID = target})[1]
                if person then
                    SetGuildRank(guild, target, rnk[1])
                    TriggerClientEvent('Guild:Rank', -1, char, person, guild, rnk[1])
                end
            end[[]]
        end 
    end
end)

RegisterNetEvent('Guild:FireTemp', function(guild, target)
    if not Guilds[guild] then
        return
    end

    target = tonumber(target)
    if type(target) ~= 'number' then
        return
    end

    local char = GetCharacter(source)

    local myAuth = GuildAuthority(guild, char.id)
    if myAuth < 1000 then
        return
    end

    if Guilds[guild].members[tostring(target)] == nil then
        Guilds[guild].temp[tostring(target)] = nil
        TriggerClientEvent('Guilds:UpdateSingle', -1, guild, Guilds[guild])
    end 
end)

RegisterNetEvent('Guild:Fire')
AddEventHandler('Guild:Fire', function(guild, target)
    local source = source

    if not Guilds[guild] then
        return
    end

    target = tonumber(target)
    if type(target) ~= 'number' then
        return
    end

    local char = GetCharacter(source)

    local myAuth = GuildAuthority(guild, char.id)
    if myAuth < 1000 then
        return
    end

    local targetAuth = GuildAuthority(guild, target)
    if myAuth > targetAuth or Guilds[guild].owner == char.id then

        local person = exports.ghmattimysql:executeSync('SELECT id, first, last, username, user from characters where id = @ID', {ID = target})[1]
        if person then
            SetGuildRank(guild, target, nil)
            TriggerClientEvent('Guild:Fire', -1, char, person, guild)
        else
            SetGuildRank(guild, target, nil)
        end

        if Guilds[guild].role then
            local pUser = SQL('SELECT discord from users WHERE id = ?', person.user)[1]
            print(pUser.discord)

            PerformHttpRequest('127.0.0.1:8080/roleoff', function(err, text, header) end, 'POST',
            json.encode({
                role = Guilds[guild].role,
                user = pUser.discord,
            }), { ['Content-Type'] = 'application/json'})
        end
    end
end)

RegisterNetEvent('RequestGuildInvites')
AddEventHandler('RequestGuildInvites', function()
    local source = source
    local char = GetCharacter(source)

    exports.ghmattimysql:execute('SELECT * from guild_invites WHERE `char` = @Char', {
        Char = char.id
    }, function(data)
        TriggerClientEvent('RequestGuildInvites', source, data)
    end)
end)

RegisterNetEvent('Guild:AcceptInvite')
AddEventHandler('Guild:AcceptInvite', function(inviteID)
    local source = source
    local char = GetCharacter(source)

    exports.ghmattimysql:execute('SELECT * from guild_invites WHERE `char` = @Char and id = @ID', {
        Char = char.id,
        ID = inviteID
    }, function(data)
        data = data[1]
        if data then
            if not Guilds[data.guild] then
                InvalidInvite(source, data)
                return
            end

            local found = false
            local rAuth
            for k,v in pairs(Guilds[data.guild].ranks) do
                if v[1] == data.rank then
                    found = true
                    rAuth = v[2]
                end
            end

            if not found then
                InvalidInvite(source, data)
                return
            end

            local auth = GuildAuthority(data.guild, data.author)

            if auth > rAuth then
                SetGuildRank(data.guild, data.char, data.rank)

                exports.ghmattimysql:execute('DELETE FROM guild_invites WHERE id = @ID', {
                    ID = data.id
                })

                exports.ghmattimysql:execute('SELECT * from guild_invites WHERE `char` = @Char', {
                    Char = char.id
                }, function(mdata)
                    TriggerClientEvent('RequestGuildInvites', source, mdata)
                end)

                return
            end

            InvalidInvite(source, data)
        end
    end)
end)

RegisterNetEvent('Guild:DenyInvite')
AddEventHandler('Guild:DenyInvite', function(inviteID)
    local source = source
    local char = GetCharacter(source)

    exports.ghmattimysql:execute('SELECT * from guild_invites WHERE `char` = @Char and id = @ID', {
        Char = char.id,
        ID = inviteID
    }, function(data)
        data = data[1]
        if data then
            exports.ghmattimysql:execute('DELETE FROM guild_invites WHERE id = @ID', {
                ID = data.id
            })

            exports.ghmattimysql:execute('SELECT * from guild_invites WHERE `char` = @Char', {
                Char = char.id
            }, function(mdata)
                TriggerClientEvent('RequestGuildInvites', source, mdata)
            end)
        end
    end)
end)

local cache = {}
Task.Register('Guild:CacheNames', function(source, guild)
    local source = source
    local nameList = {}
    for k,v in pairs(Guilds[guild].members) do
        if cache[tonumber(k)] == nil then
            local val = exports.ghmattimysql:executeSync('SELECT id, first, last, username from characters where id = @ID', {
                ID = tonumber(k)
            })[1]
    
            if val then
                nameList[val.id] = val.username or (val.first..' '..val.last) 
                cache[val.id] = val.username or (val.first..' '..val.last) 
            end
        else
            nameList[tonumber(k)] = cache[tonumber(k)]
        end
    end

    for k,v in pairs(Guilds[guild].temp) do
        if cache[tonumber(k)] == nil then
            local val = exports.ghmattimysql:executeSync('SELECT id, first, last, username from characters where id = @ID', {
                ID = tonumber(k)
            })[1]
    
            if val then
                nameList[val.id] = val.username or (val.first..' '..val.last) 
                cache[val.id] = val.username or (val.first..' '..val.last) 
            end
        else
            nameList[tonumber(k)] = cache[tonumber(k)]
        end
    end

    TriggerClientEvent('Guild:CacheNames', source, nameList)
    return nameList
end)

RegisterNetEvent('Guild:PendingInvites')
AddEventHandler('Guild:PendingInvites', function(guild)
    local source = source
    if Guilds[guild] == nil then
        return  
    end

    exports.ghmattimysql:execute('SELECT * from guild_invites inner JOIN characters ON guild_invites.`char` = characters.id WHERE guild = @Guild', {
        Guild = guild
    }, function(data)
        TriggerClientEvent('Guild:PendingInvites', source, data)
    end)
end)

RegisterNetEvent('Guilds:RemoveInvite')
AddEventHandler('Guilds:RemoveInvite', function(char, guild)
    local source = source
    local Char = GetCharacter(source)

    if Guilds[guild] == nil then
        return
    end

    if Guilds[guild].owner == Char.id then
        exports.ghmattimysql:execute('DELETE FROM guild_invites WHERE `char` = @Character and guild = @Guild', {
            Character = char,
            Guild = guild
        })

        exports.ghmattimysql:execute('SELECT * from guild_invites inner JOIN characters ON guild_invites.`char` = characters.id WHERE guild = @Guild', {
            Guild = guild
        }, function(data)
            TriggerClientEvent('Guild:PendingInvites', source, data)
        end)
    end
end)

RegisterNetEvent('Guild:CreateKeycard')
AddEventHandler('Guild:CreateKeycard', function(guild, ident)
    local source = source
    if not Guilds[guild] then
        return
    end

    if type(ident) ~= 'string' then
        return
    end

    if ident == '' then
        return
    end

    local char = GetCharacter(source)
    if Guilds[guild].owner == char.id then
        if exports['geo-inventory']:RemoveItem('Player', source, 'keycard_blank', 1) then
            local item = exports['geo-inventory']:InstanceItem('keycard')
            item.Data.Keycard = ident
            item.Data.Guild = 'EMS'
            table.insert(Guilds[guild].keycard, ident)
            exports['geo-inventory']:AddItem('Player', source, 'keycard', 1, item)
            exports.ghmattimysql:execute('UPDATE guilds set keycard = @Keycard WHERE ident = @Guild', {
                Keycard = json.encode(Guilds[guild].keycard),
                Guild = guild
            })
            TriggerClientEvent('Guilds:UpdateSingle', -1, guild, Guilds[guild])
        end
    end
end)

RegisterNetEvent('Guilds:RemoveKeycard')
AddEventHandler('Guilds:RemoveKeycard', function(guild, index)
    local source = source
    if not Guilds[guild] then
        return
    end

    if type(index) ~= 'number' then
        return
    end

    if Guilds[guild].keycard[index] == nil then
        return
    end

    local char = GetCharacter(source)
    if Guilds[guild].owner == char.id then
        table.remove(Guilds[guild].keycard, index)
        exports.ghmattimysql:execute('UPDATE guilds set keycard = @Keycard WHERE ident = @Guild', {
            Keycard = json.encode(Guilds[guild].keycard),
            Guild = guild
        })
        TriggerClientEvent('Guilds:UpdateSingle', -1, guild, Guilds[guild])
    end
end)

RegisterNetEvent('Guild:AddFlag')
AddEventHandler('Guild:AddFlag', function(guild, member, flag)
    local source = source
    AddGuildFlag(source, guild, member, flag)
end)

Task.Register('Guild.RankFlag', function(source, member, flag, guild)
    return AddRankFlag(source, guild, member, flag)
end)

Task.Register('Guild.RemoveRankFlag', function(source, member, flag, guild)
    return RemoveRankFlag(source, guild, member, flag)
end)

Task.Register('Guild.Flag', function(source, target, flag, guild)
    target = tonumber(target)
    return AddGuildFlag(source, guild, target, flag)
end)

Task.Register('Guild.RemoveFlag', function(source, target, flag, guild)
    target = tonumber(target)
    return RemoveGuildFlag(source, guild, target, flag)
end)

function AddGuildFlag(source, guild, member, flag)
    if not Guilds[guild] then
        return
    end

    if flag == '' or flag:len() > 20 then
        return
    end

    local char = GetCharacter(source)
    if Guilds[guild].owner == char.id then
        if Guilds[guild].members[tostring(member)].flags == nil then
            Guilds[guild].members[tostring(member)].flags = {}
        end

        table.insert(Guilds[guild].members[tostring(member)].flags, flag)
        exports.ghmattimysql:execute('UPDATE guilds set members = @Members WHERE ident = @Guild', {
            Members = json.encode(Guilds[guild].members),
            Guild = guild
        })

        TriggerClientEvent('Guilds:UpdateSingle', -1, guild, Guilds[guild])
        return Guilds[guild].members[tostring(member)].flags
    end
end

function AddRankFlag(source, guild, rank, flag)
    if not Guilds[guild] then
        return Guilds[guild].ranks[rank][3]
    end

    if flag == '' or flag:len() > 20 then
        return Guilds[guild].ranks[rank][3]
    end

    local char = GetCharacter(source)
    if Guilds[guild].owner == char.id then
        rank = tonumber(rank)
        rank = rank + 1
        if Guilds[guild].ranks[rank][3] == nil then
            Guilds[guild].ranks[rank][3] = {}
        end

        for k,v in pairs(Guilds[guild].ranks[rank][3]) do
            if v == flag then
                return Guilds[guild].ranks[rank][3]
            end
        end

        table.insert(Guilds[guild].ranks[rank][3], flag)
        exports.ghmattimysql:execute('UPDATE guilds set ranks = @Members WHERE ident = @Guild', {
            Members = json.encode(Guilds[guild].ranks),
            Guild = guild
        })

        TriggerClientEvent('Guilds:UpdateSingle', -1, guild, Guilds[guild])
        return Guilds[guild].ranks[rank][3]
    end
end

function RemoveRankFlag(source, guild, rank, flag)
    if not Guilds[guild] then
        return Guilds[guild].ranks[rank][3]
    end

    if flag == '' or flag:len() > 20 then
        return Guilds[guild].ranks[rank][3]
    end

    local char = GetCharacter(source)
    if Guilds[guild].owner == char.id then
        rank = tonumber(rank)
        rank = rank + 1
        if Guilds[guild].ranks[rank][3] == nil then
            Guilds[guild].ranks[rank][3] = {}
        end

        for k,v in pairs(Guilds[guild].ranks[rank][3]) do
            if v == flag then
                table.remove(Guilds[guild].ranks[rank][3], k)
                break
            end
        end

        exports.ghmattimysql:execute('UPDATE guilds set ranks = @Members WHERE ident = @Guild', {
            Members = json.encode(Guilds[guild].ranks),
            Guild = guild
        })

        TriggerClientEvent('Guilds:UpdateSingle', -1, guild, Guilds[guild])
        return Guilds[guild].ranks[rank][3]
    end
end

function RemoveGuildFlag(source, guild, member, flag)
    if not Guilds[guild] then
        return
    end

    local char = GetCharacter(source)
    if Guilds[guild].owner == char.id then
        if Guilds[guild].members[tostring(member)].flags == nil then
            return
        end


        for k,v in pairs(Guilds[guild].members[tostring(member)].flags) do
            if v == flag then
                table.remove(Guilds[guild].members[tostring(member)].flags, k)
                break
            end
        end

        if #Guilds[guild].members[tostring(member)].flags == 0 then
            Guilds[guild].members[tostring(member)].flags = nil
        end

        exports.ghmattimysql:execute('UPDATE guilds set members = @Members WHERE ident = @Guild', {
            Members = json.encode(Guilds[guild].members),
            Guild = guild
        })

        TriggerClientEvent('Guilds:UpdateSingle', -1, guild, Guilds[guild])
        return Guilds[guild].members[tostring(member)].flags
    end
end

RegisterNetEvent('Guild:RemoveFlag')
AddEventHandler('Guild:RemoveFlag', function(guild, member, flag)
    local source = source
   RemoveGuildFlag(source, guild, member, flag)
end)

RegisterNetEvent('Guild:SetGuildImage')
AddEventHandler('Guild:SetGuildImage', function(guild, image)
    local source = source
    if not Guilds[guild] then
        return
    end

    local char = GetCharacter(source)
    if Guilds[guild].owner == char.id then

        exports.ghmattimysql:execute('UPDATE guilds set image = @Image WHERE ident = @Guild', {
            Image = image,
            Guild = guild
        })

        Guilds[guild].image = image
        TriggerClientEvent('Guilds:UpdateSingle', -1, guild, Guilds[guild])
    end
end)

--[[ RegisterNetEvent('Guild.Deposit')
AddEventHandler('Guild.Deposit', function(guild, amount)
    local source = source
    amount = math.abs(math.floor(tonumber(amount)))
    if amount and exports['geo-inventory']:RemoveItem('Player', source, 'dollar', amount) then
        AddGuildFunds(guild, amount)
    end
end)

RegisterNetEvent('Guild.Withdraw')
AddEventHandler('Guild.Withdraw', function(guild, amount)
    local source = source
    local char = GetCharacter(source)
    amount = math.abs(math.floor(tonumber(amount)))

    if Guilds[guild].owner == char.id then
        if amount and exports['geo-inventory']:CanFit('Player', source, 'dollar', amount) then
            if Guilds[guild].funds - amount >= 0 then
                exports['geo-inventory']:AddItem('Player', source, 'dollar', amount)
                RemoveGuildFunds(guild, amount)
            end
        end
    end
end) ]]

function SetGuildRank(guild, id, rank)
    if Guilds[guild] == nil then
        return false
    end

    local found
    for k,v in pairs(Guilds[guild].ranks) do
        if v[1] == rank then
            found = true
            break
        end
    end

    if rank == nil then
        found = true
    end

    if found then
        if Guilds[guild].members[tostring(id)] == nil then
            Guilds[guild].members[tostring(id)] = {title = rank}
        else
            Guilds[guild].members[tostring(id)].title = rank
        end

        if rank == nil then
            Guilds[guild].members[tostring(id)] = nil
        end

        exports.ghmattimysql:execute('UPDATE guilds set members = @Members WHERE ident = @Guild', {
            Members = json.encode(Guilds[guild].members),
            Guild = guild
        })
        TriggerClientEvent('Guilds:UpdateSingle', -1, guild, Guilds[guild])
        return true
    end

    return false
end

function InvalidInvite(source, data)
    exports.ghmattimysql:execute('DELETE FROM guild_invites WHERE id = @ID', {
        ID = data.id
    })

    local char = GetCharacter(source)

    exports.ghmattimysql:execute('SELECT * from guild_invites WHERE `char` = @Char', {
        Char = char.id
    }, function(mdata)
        TriggerClientEvent('RequestGuildInvites', source, mdata)
    end)
end

function AddGuildFunds(guild, amount)
    exports.ghmattimysql:execute('UPDATE bank SET amount = amount + ? WHERE (acro = "LSPD" or acro = "BCSO" or acro = "EMS" or acro = "CITY" or acro = "DOJ") and account_type = "Business"', {amount, guild})
end

function AddDepartmentFunds(amount)
    exports.ghmattimysql:execute('UPDATE bank SET amount = amount + ? WHERE (acro = "LSPD" or acro = "BCSO" or acro = "EMS" or acro = "CITY" or acro = "DOJ") and account_type = "Business"', {amount, guild})
end

function RemoveGuildFunds(guild, amount)
    exports.ghmattimysql:execute('UPDATE bank SET amount = amount - ? WHERE acro = ? and account_type = "Business"', {amount, guild})
end

exports('SetGuildRank', SetGuildRank)
exports('AddGuildFunds', AddGuildFunds)
exports('AddDepartmentFunds', AddDepartmentFunds)
exports('RemoveGuildFunds', RemoveGuildFunds)

RegisterCommand('_hiretemp', function(source, args)
    if not (source == 0 or GetCharacter(source).username) then return end
    local person = tonumber(args[1])
    local guild = args[2]

    if person and Guilds[guild] then
        local foundRank = 0
        local rankName
        for k,v in pairs(Guilds[guild].ranks) do
            if v[2] > foundRank then
                foundRank = v[2]
                rankName = v[1]
            end
        end

        Guilds[guild].temp[tostring(person)] = {title = rankName}
        TriggerClientEvent('Guilds:UpdateSingle', -1, guild, Guilds[guild])
    end
end)