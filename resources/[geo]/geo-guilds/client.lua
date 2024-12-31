local invites = {}
local cache = {}
local activeGuild
local activeRank
local hireTarget
local activeMember
local pendingInvs = {}
local tempMembers = false

RegisterNetEvent('RequestGuilds')
AddEventHandler('RequestGuilds', function(data)
    Guilds = data

    for k,v in pairs(Guilds) do
        Guilds[k].fakemembers = {}
        for key,val in pairs(v.members) do
            table.insert(Guilds[k].fakemembers, val)
            Guilds[k].fakemembers[#Guilds[k].fakemembers].cid = tonumber(key)
        end
    end

    for k,v in pairs(Guilds) do
        table.sort(Guilds[k].ranks, function(a, b)
            return a[2] < b[2]
        end)
        table.sort(Guilds[k].fakemembers, function(a, b)
            return GuildAuthority(k, a.cid) > GuildAuthority(k, b.cid)
        end)
    end

    table.sort(Guilds, function(a, b)
        return a.id > b.id
    end)
end)

RegisterNetEvent('Guilds:UpdateSingle')
AddEventHandler('Guilds:UpdateSingle', function(id, data)
    Guilds[id] = data

    Guilds[id].fakemembers = {}
    for key,val in pairs(Guilds[id].members) do
        table.insert(Guilds[id].fakemembers, val)
        Guilds[id].fakemembers[#Guilds[id].fakemembers].cid = tonumber(key)
    end

    table.sort(Guilds[id].ranks, function(a, b)
        return a[2] < b[2]
    end)

    table.sort(Guilds[id].fakemembers, function(a, b)
        return GuildAuthority(id, a.cid) > GuildAuthority(id, b.cid)
    end)

    table.sort(Guilds, function(a, b)
        return a.id > b.id
    end)

    if activeGuild then
        tempMembers = #json.encode(Guilds[activeGuild].temp) > 3
    end

    TriggerEvent('GuildUpdate', id, Guilds[id])
end)

RegisterNetEvent('Guild:Invite')
AddEventHandler('Guild:Invite', function(inviter, invitee, guild, rank)

    if not MyCharacter.id then
        return
    end

    if Guilds[guild] then
        if Guilds[guild].members[tostring(MyCharacter.id)] ~= nil then
            if MyCharacter.id == inviter.id then
                TriggerEvent('Chat.Message', '['..Guilds[guild].guild..']', 'You invited '..invitee.first..' '..invitee.last..' as a '..rank, 'guild')
            elseif MyCharacter.id ~= invitee.id then
                TriggerEvent('Chat.Message', '['..Guilds[guild].guild..']', inviter.first..' '..inviter.last..' invited '..invitee.first..' '..invitee.last..' as a '..rank, 'guild')
            end
        end

        if MyCharacter.id == invitee.id then
            TriggerEvent('Chat.Message', '['..Guilds[guild].guild..']', 'You have been invited as a '..rank..' by '..inviter.first..' '..inviter.last, 'guild')
        end
    end
end)

RegisterNetEvent('Guild:Rank')
AddEventHandler('Guild:Rank', function(inviter, invitee, guild, rank)

    if not MyCharacter.id then
        return
    end

    if Guilds[guild] then
        if Guilds[guild].members[tostring(MyCharacter.id)] ~= nil then
            TriggerEvent('Chat.Message', '['..Guilds[guild].guild..']', invitee.first..' '..invitee.last..' has been made a '..rank..' by '..inviter.first..' '..inviter.last, 'guild')
        end
    end
end)

RegisterNetEvent('Guild:Fire')
AddEventHandler('Guild:Fire', function(inviter, invitee, guild, rank)

    if not MyCharacter.id then
        return
    end

    if Guilds[guild] then
        if Guilds[guild].members[tostring(MyCharacter.id)] ~= nil then
            TriggerEvent('Chat.Message', '['..Guilds[guild].guild..']', inviter.first..' '..inviter.last..' has fired '..invitee.first..' '..invitee.last, 'guild')
        end

        if MyCharacter.id == invitee.id then
            TriggerEvent('Chat.Message', '['..Guilds[guild].guild..']', 'You were fired by '..inviter.first..' '..inviter.last, 'guild')
            if activeGuild == guild then
                Menu.CloseMenu()
            end
        end
    end
end)

RegisterNetEvent('RequestGuildInvites')
AddEventHandler('RequestGuildInvites', function(data)
    invites = data
end)

RegisterNetEvent('Guild:CacheNames')
AddEventHandler('Guild:CacheNames', function(list)
    for k,v in pairs(list) do
        cache[k] = v
    end
end)

RegisterNetEvent('Guild:PendingInvites')
AddEventHandler('Guild:PendingInvites', function(data)
    pendingInvs = data
end)

Menu.CreateMenu('Guilds', 'Guilds')
Menu.CreateSubMenu('GuildManager', 'Guilds', 'Guild Management')
Menu.CreateSubMenu('Invites', 'Guilds', 'Guild Invites')
Menu.CreateSubMenu('RankManager', 'GuildManager', 'Guild Ranks')
Menu.CreateSubMenu('SpecificRankManager', 'RankManager', 'Guild Ranks')
Menu.CreateSubMenu('HirePerson', 'GuildManager', 'Guild Ranks')
Menu.CreateSubMenu('HirePerson2', 'GuildManager', 'Guild Ranks')
Menu.CreateSubMenu('UserManagement', 'GuildManager', 'Guild Member')
Menu.CreateSubMenu('GuildInvites', 'GuildManager', 'Guild Invites')
Menu.CreateSubMenu('Keycards', 'GuildManager', 'Keycards')
TriggerServerEvent('RequestGuilds')

RegisterKeyMapping('guilds', '[General] Guilds', 'keyboard', 'U')
RegisterCommand('Guilds', function(source, args, raw)
    if Menu.CurrentMenu == nil and ControlModCheck(raw) then

        activeGuild = nil
        activeRank = nil
        hireTarget = nil
        activeMember = nil
        local pGuild = false
        local iIndex = {}
        if MyCharacter.id == nil then
            return
        end

        TriggerServerEvent('RequestGuilds')
        TriggerServerEvent('RequestGuildInvites')
        Menu.OpenMenu('Guilds')
        while Menu.CurrentMenu do
            Wait(0)
            if Menu.CurrentMenu == 'Guilds' then

                if pGuild then
                    pGuild = false
                    TriggerServerEvent('RequestGuildInvites')
                end

                if exports['geo-inventory']:HasItem('guild_token') then
                    if Menu.Button('Create Guild') then
                        local acro = Shared.TextInput('Guild Acronym', 4)
                        local name = Shared.TextInput('Guild Name', 46)
    
                        TriggerServerEvent('Guild:Create', acro, name)
                    end
                end

                if #invites > 0 then
                    if Menu.Button('[Invites]') then
                        Menu.OpenMenu('Invites')
                        pGuild = true
                    end
                end

                for k,v in pairs(Guilds) do
                    if GuildAuthority(v.ident, MyCharacter.id) > 0 then
                        if Menu.Button(v.guild) then
                            activeGuild = v.ident
                            pendingInvs = {}
                            tempMembers = #json.encode(Guilds[k].temp) > 3
                            CreateThread(function()
                                Task.Run('Guild:CacheNames', activeGuild)
                            end)
                            TriggerServerEvent('Guild:PendingInvites', activeGuild)
                            Menu.OpenMenu('GuildManager')
                            pGuild = true
                        end
                    end
                end
            elseif Menu.CurrentMenu == 'GuildManager' then
                if Menu.Button('Ranks') then
                    Menu.OpenMenu('RankManager')
                end

                if #pendingInvs > 0 then
                    if Menu.Button('[Pending Invites]') then
                        Menu.OpenMenu('GuildInvites')
                    end
                end

                if GuildAuthority(activeGuild, MyCharacter.id) > 999 then
                    if Menu.Button('Add Member') then
                        local id = tonumber(Shared.TextInput('Target ID', 'Add Guild Member'))
                        if id then
                            hireTarget = id
                            Menu.OpenMenu('HirePerson')
                        end
                    end

                    if Menu.Button('Add Temp Member') then
                        local id = tonumber(Shared.TextInput('Target ID', 'Add Guild Member'))
                        if id then
                            hireTarget = id
                            Menu.OpenMenu('HirePerson2')
                        end
                    end
                end

                --[[ if Menu.Button('Deposit Money', '$'..comma_value(Guilds[activeGuild].funds)) then
                    if exports['geo-eco']:NearBank() then
                        TriggerServerEvent('Guild.Deposit', activeGuild, Shared.TextInput('Deposit', 'Amount'))
                    else
                        TriggerEvent('Shared.Notif', 'You are not near a bank')
                    end
                end ]]

                if Guilds[activeGuild].owner == MyCharacter.id then
                    --[[ if Menu.Button('Withdraw Money', '$'..comma_value(Guilds[activeGuild].funds)) then
                        if exports['geo-eco']:NearBank() then
                            TriggerServerEvent('Guild.Withdraw', activeGuild, Shared.TextInput('Withdraw', 'Amount'))
                        else
                            TriggerEvent('Shared.Notif', 'You are not near a bank')
                        end
                    end ]]
                end

                for k,v in pairs(Guilds[activeGuild].fakemembers) do
                    if Menu.Button(cache[tonumber(v.cid)] or k, v.title) then
                        if GuildAuthority(activeGuild, MyCharacter.id) > 999 then
                            if GuildAuthority(activeGuild, MyCharacter.id) > GuildAuthority(activeGuild, tonumber(k)) or Guilds[activeGuild].owner == MyCharacter.id then
                                activeMember = tonumber(v.cid)
                                Menu.OpenMenu('UserManagement')
                            end
                        end
                    end
                end

                if tempMembers then
                    Menu.EmptyButton()
                    Menu.EmptyButton('Temp')
                    for k,v in pairs(Guilds[activeGuild].temp) do
                        if Menu.Button(cache[tonumber(k)] or k, v.title) then
                            if GuildAuthority(activeGuild, MyCharacter.id) > 999 then
                                if GuildAuthority(activeGuild, MyCharacter.id) > GuildAuthority(activeGuild, tonumber(k)) or Guilds[activeGuild].owner == MyCharacter.id then
                                    if Shared.Confirm('Would you like to fire this person?', 'Guild Managment') then
                                        TriggerServerEvent('Guild:FireTemp', activeGuild, k)
                                    end
                                end
                            end
                        end
                    end
                end

                if Guilds[activeGuild].owner == MyCharacter.id then
                    if Menu.Button('Create Keycard') then
                        local auth = Shared.TextInput('Keycard Identifier', 5)
                        if Shared.Confirm('Would you like to create a keycard?', 'Keycard') then
                            TriggerServerEvent('Guild:CreateKeycard', activeGuild, auth)
                        end
                    end

                    if #(Guilds[activeGuild].keycard) > 0 then
                        if Menu.Button('Keycards') then
                            Menu.OpenMenu('Keycards')
                        end
                    end
                end

            elseif Menu.CurrentMenu == 'RankManager' then

                if Guilds[activeGuild].owner == MyCharacter.id then
                    if Menu.Button('New Rank') then
                        local rank = Shared.TextInput('Rank Name', 46)
                        local auth = Shared.TextInput('Rank Authority', 5)
        
                        TriggerServerEvent('Guild:AddRank', activeGuild, rank, auth)
                    end

                    for k,v in pairs(Guilds[activeGuild].ranks) do
                        if Menu.Button(v[1], v[2]) then
                            activeRank = v
                            Menu.OpenMenu('SpecificRankManager')
                        end
                    end
                end
            elseif Menu.CurrentMenu == 'SpecificRankManager' then
                Menu.EmptyButton(activeRank[1], activeRank[2])

                if Menu.Button('Remove Rank') then
                    if Shared.Confirm('Are you Sure?', 'Remove Guild Rank') then
                        TriggerServerEvent('Guild:RemoveRank', activeGuild, activeRank[1])
                        Menu.CurrentMenu = 'RankManager'
                    end
                end

                if Menu.Button('Modify Rank Name') then
                    local newName = Shared.TextInput('New Rank Name', 46)
                    Wait(250)
                    if Shared.Confirm('Are you Sure?', 'Rename Guild Rank') then
                        TriggerServerEvent('Guild:RenameRank', activeGuild, activeRank[1], newName)
                        Menu.CurrentMenu = 'RankManager'
                    end
                end

                if Menu.Button('Modify Authority') then
                    local newAutg = Shared.TextInput('New Authority', 5)
                    Wait(250)
                    if Shared.Confirm('Are you Sure?', 'Adjust Authority') then
                        TriggerServerEvent('Guild:ModifyAuthority', activeGuild, activeRank[1], newAutg)
                        Menu.CurrentMenu = 'RankManager'
                    end
                end
            elseif Menu.CurrentMenu == 'HirePerson' then
                for k,v in pairs(Guilds[activeGuild].ranks) do
                    if Menu.Button(v[1], v[2]) then
                        TriggerServerEvent('Guild:Hire', activeGuild, hireTarget, v[1])
                        Menu.OpenMenu('GuildManager')
                    end
                end
            elseif Menu.CurrentMenu == 'HirePerson2' then
                for k,v in pairs(Guilds[activeGuild].ranks) do
                    if Menu.Button(v[1], v[2]) then
                        TriggerServerEvent('Guild:HireTemp', activeGuild, hireTarget, v[1])
                        Menu.OpenMenu('GuildManager')
                    end
                end
            elseif Menu.CurrentMenu == 'Invites' then
                for k,v in pairs(invites) do
                    if Menu.Button(v.guild, v.rank) then

                        if Shared.Confirm('Would you like to accept this invite?', 'Guild Invite') then
                            TriggerServerEvent('Guild:AcceptInvite', v.id)
                            Menu.OpenMenu('Guilds')
                        else
                            TriggerServerEvent('Guild:DenyInvite', v.id)
                            Menu.OpenMenu('Guilds')
                        end
                    end
                end
            elseif Menu.CurrentMenu == 'UserManagement' then

                Menu.EmptyButton(cache[activeMember])
                if Menu.Button('Change Rank') then
                    hireTarget = activeMember
                    Menu.OpenMenu('HirePerson')
                end

                if Menu.Button('Remove From Guild') then
                    if Shared.Confirm('Are you sure you want to remove '..cache[activeMember]..' from the guild?') then
                        TriggerServerEvent('Guild:Fire', activeGuild, activeMember)
                    end
                end

                if Guilds[activeGuild].owner == MyCharacter.id then
                    if Menu.Button('Add Flag') then
                        local flag = Shared.TextInput('Flag Name', 10)
                        if flag ~= '' and flag:len() <= 10 then
                            TriggerServerEvent('Guild:AddFlag', activeGuild, activeMember, flag)
                        end
                    end
                end

                if Guilds[activeGuild].members[tostring(activeMember)].flags then
                    Menu.EmptyButton()
                    for _,flag in pairs(Guilds[activeGuild].members[tostring(activeMember)].flags) do
                        if Menu.Button(flag) then
                            if Shared.Confirm('Are you sure you want to remove flag '..flag) then
                                TriggerServerEvent('Guild:RemoveFlag', activeGuild, activeMember, flag)
                            end
                        end
                    end
                end

            elseif Menu.CurrentMenu == 'GuildInvites' then
                for k,v in pairs(pendingInvs) do
                    if Menu.Button(v.first..' '..v.last, v.rank) then
                        if Shared.Confirm('Would you like to cancel this invite?') then
                            TriggerServerEvent('Guilds:RemoveInvite', v.char, v.guild)
                            Menu.OpenMenu('GuildManager')
                        end
                    end
                end
            elseif Menu.CurrentMenu == 'Keycards' then
                for k,v in pairs(Guilds[activeGuild].keycard) do
                    if Menu.Button(v) then
                        if Shared.Confirm('Remove keycard "'..v..'"?') then
                            TriggerServerEvent('Guilds:RemoveKeycard', activeGuild, k)
                        end
                    end
                end

                if #(Guilds[activeGuild].keycard) == 0 then
                    Menu.OpenMenu('GuildManager')
                end
            end

            Menu.Display()
        end
    else
        Menu.CloseMenu()
    end
end)

RegisterCommand('badge', function(source, args)
    if args[1] == nil then
        for k,v in pairs(Guilds) do
            if GuildAuthority(k, MyCharacter.id) > 0 then
                TriggerServerEvent('Chat.LocalMessage', '['..k..']', ('%s %s: %s %s'):format(GuildTitle(k, MyCharacter.id), MyCharacter.last, v.guild, IsDepartment(k)), 'guild', GetEntityCoords(PlayerPedId()), 150.0, false)
            end
        end
    else
        args[1] = args[1]:upper()
        if not Guilds[args[1]] then
            return
        end

        if GuildAuthority(args[1], MyCharacter.id) > 0 then
            TriggerServerEvent('Chat.LocalMessage', '['..args[1]..']', ('%s %s: %s %s'):format(GuildTitle(args[1], MyCharacter.id), MyCharacter.last, Guilds[args[1]].guild, IsDepartment(args[1])), 'guild', GetEntityCoords(PlayerPedId()), 150.0, false)
        end
    end
end)

function IsDepartment(g)
    local departments = exports['geo-es']:Departments()
    for k,v in pairs(departments) do
        if v == g then
            return '- '..MyCharacter.callsign
        end
    end

    return ''
end