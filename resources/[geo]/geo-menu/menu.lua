local proximityMenus = {}
local actions = {}
Menu.CreateMenu('Menu', 'Menu')
Menu.CreateSubMenu('Actions', 'Menu', 'Menu')
local wStyle = 1
local startWstyle

function MenuCycle(source, args, raw)
    if not ControlModCheck(raw) then return end
    if MyCharacter == nil then
        return
    end

    if Menu.CurrentMenu == nil then
        Menu.OpenMenu('Menu')

        local n = 999
        local closeMenus = {}
        for k,v in pairs(Walks) do
            if v[2] == MyCharacter.walkstyle then
                wStyle = k
                startWstyle = wStyle
                break
            end
        end
        while Menu.CurrentMenu do
            ::refresh::
            Wait(0)
            local pos = GetEntityCoords(PlayerPedId())

            if Menu.CurrentMenu == 'Menu' then
                n = n + 1
                if n > 120 then
                    closeMenus = {}
                    for k,v in pairs(proximityMenus) do
                        if CheckPerms(v) then

                            if type(v.pos) == 'table' then
                                for index, value in pairs(v.pos) do
                                    if Vdist3(pos , value) <= 30.0 then
                                        closeMenus[k] = v
                                    end
                                end
                            else
                                if Vdist3(pos , v.pos) <= 30.0 then
                                    closeMenus[k] = v
                                end
                            end
                        end
                    end

                    n = 0
                end

                for k,v in pairs(closeMenus) do
                    if type(v.pos) == 'table' then
                        for index, value in pairs(v.pos) do
                            if Vdist3(pos , value) <= (v.range or 8.0) then
                                if Menu.Button(v.Name, v.Sub) then
                                    if v.func then
                                        Menu.Display()
                                        v.func(value, (v.range or 8.0))
                                        Menu.CurrentMenu = 'Menu'
                                        Menu.Flag = true
                                        goto refresh
                                    elseif v.Event then
                                        TriggerEvent(v.Event)
                                    end
                                end
                                break
                            end
                        end
                    else
                        if Vdist3(pos, v.pos) <= (v.range or 8.0) then
                            if Menu.Button(v.Name) then
                                if v.func then
                                    Menu.Display()
                                    v.func(v.pos, (v.range or 8.0))
                                    Menu.CurrentMenu = 'Menu'
                                    Menu.Flag = true
                                    goto refresh
                                elseif v.Event then
                                    TriggerEvent(v.Event)
                                end
                            end
                        end
                    end
                end

                if GetActionCount() > 0 then
                    Menu.MenuButton('Actions', 'Actions')
                end

                Menu.Slider('Walk', Walks, wStyle, function(cur)
                    if wStyle ~= cur then
                        wStyle = cur
                        CreateThread(function()
                            RequestAnimSet(Walks[wStyle][2])
                            while not HasAnimSetLoaded(Walks[wStyle][2]) do
                                Wait(0)
                            end 
                            SetPedMovementClipset(PlayerPedId(), Walks[wStyle][2], 0.2)
                            RemoveAnimSet(Walks[wStyle][2])
                        end)
                    end
                end, Walks[wStyle][1])
            elseif Menu.CurrentMenu == 'Actions' then
                for k,v in Shared.SortAlphabet(actions) do
                    if CheckPerms(v) then
                        if Menu.Button(v.Name, v.Sub) then
                            if v.func then
                                Menu.Display()
                                v.func()
                                Menu.CurrentMenu = 'Actions'
                                Menu.Flag = true
                                goto refresh
                            end
                        end
                    end
                end
            end

            Menu.Display(50)
        end

        if wStyle ~= startWstyle then
            TriggerServerEvent('SaveWalk', Walks[wStyle][2])
        end
    end
end

function ProximityMenu(key, menu)

    if menu == nil then
        proximityMenus[key] = nil
        return
    end

    if menu.range ~= nil then
        menu.range = math.sqrt(menu.range)
    end

    if type(menu.pos) == 'table' then
        for k,v in pairs(menu.pos) do
            menu.pos[k] = vector3(menu.pos[k].x, menu.pos[k].y, menu.pos[k].z)
        end
    else
        menu.pos = vector3(menu.pos.x, menu.pos.y, menu.pos.z)
    end
    proximityMenus[key] = menu
end

function RegisterAction(key, menu)

    if menu == nil then
        actions[key] = nil
        return
    end

    actions[key] = menu
end

function CheckPerms(data)
    if data.Groups == nil then
        return true
    end

    for k,v in pairs(data.Groups) do
        if exports['geo-guilds']:GuildAuthority(v, MyCharacter.id) > 0 then
            return true
        end
    end
end

function GetActionCount()
    local count = 0
    for k,v in pairs(actions) do
        count = count + 1
    end
    return count
end

exports('ProximityMenu', ProximityMenu)
exports('RegisterAction', RegisterAction)
RegisterKeyMapping('+Menu', '[General] Interaction Menu', 'keyboard', 'K')
RegisterCommand('-Menu', function() end)
RegisterCommand('+Menu', MenuCycle)
exports('ResetWalk', function()
    RequestAnimSet(MyCharacter.walkstyle or 'move_f@multiplayer')
    while not HasAnimSetLoaded(MyCharacter.walkstyle or 'move_f@multiplayer') do
        Wait(0)
    end 
    SetPedMovementClipset(PlayerPedId(), MyCharacter.walkstyle or 'move_f@multiplayer', 0.2)
    RemoveAnimSet(MyCharacter.walkstyle or 'move_f@multiplayer')
end)

AddEventHandler('Login', function()
    Wait(1000)
    exports['geo-menu']:ResetWalk()
end)