local objList = {}

local locations = {
    --West LS
    vector3(-519.48, -819.61, 29.89),
    vector3(-1151.84, -1322.55, 4.44),
    vector3(-1585.25, -1031.60, 12.53),
    vector3(-383.72, 115.27, 65.17),
    vector3(-1421.44, 265.09, 60.03),
    --East LS,
    vector3(251.82, 429.53, 119.56),
    vector3(971.63, -182.42, 72.36),
    vector3(1274.62, -538.84, 68.47),
    vector3(788.61, -842.51, 25.40),
    vector3(1393.89, -1754.89, 65.45),
    vector3(907.84, -2239.44, 29.98),
    vector3(468.95, -1844.82, 27.40) ,
    vector3(-664.71, -1671.63, 24.70),
    --South LS,
    vector3(-948.17, -2152.24, 8.36),
    vector3(-203.58, -2614.14, 5.49),
    vector3(197.4, -2973.57, 5.41),
    vector3(648.22, -2972.97, 5.52),
    vector3(1078.55, -3225.92, 5.38),
    --Paleto,
    vector3(84.09, 6607.91, 30.93),
    vector3(-113.86, 6288.64, 30.85),
    vector3(-663.42, 5929.95, 15.55),
    vector3(1587.66, 6432.57, 24.59),
    --County Misc.,
    vector3(-1493.25,4985.55,62.14),
    vector3(-2208.87, 4285.34, 47.68),
    vector3(-868.92, 4404.43, 20.34),
    vector3(-214.25, 4225.94, 44.35),
    vector3(1445.65, 4489.36, 49.95),
    --Grapeseed,
    vector3(1662.36, 4848.39, 41.38),
    vector3(2107.43, 4738.48, 40.57),
    vector3(2779.19, 4924.30, 33.04),
    vector3(3785.48, 4471.22, 5.44),
    --Central County,
    vector3(1866.75, 3941.40, 32.44),
    vector3(407.57, 3485.30, 34.08),
    vector3(600.35, 2708.06, 41.03),
    vector3(2033.19, 3311.3, 45.46),
    vector3(-1885.05, 2017.37, 140.38) ,
}

Jobs:RegisterRanking('Burner', {
    {'r1', 1.4, 0},
    {'r2', 1.5, 300},
    {'r3', 1.6, 3000},
    {'r4', 1.7, 9000},
    {'r5', 1.8, 18000},
    {'r6', 1.9, 30000}
})

Task.Register('Burner.StartJob', function(source)
    local char = GetCharacter(source)
    if char.id then
        if not objList[char.id] then
            objList[char.id] = Jobs.Fetch('Burner', char.id)
            if not objList[char.id] then return end
            objList[char.id].job = 'none'
        end

        if objList[char.id].job ~= 'none' then
            return objList[char.id].job
        end

        objList[char.id]:CheckPromotion()
        objList[char.id].job = 'phase_1'
        objList[char.id].location = locations[Random(#locations)]
        JobTime[char.id] = os.time()

        if objList[char.id]:GetHours() == 0 or GetUser(source).data.settings.jobinfo then
            TriggerClientEvent('Shared.Notif', source, [[
                Go to the location on your GPS and use your burner to divert the cops. Be ready to stay in the area for a little.
            ]], 10000)
        end

        TriggerClientEvent('Burner.StartJob', source, objList[char.id].location)
        return objList[char.id].job
    end

    return 'none'
end)

Task.Register('Burner.QuitJob', function(source)
    local char = GetCharacter(source)
    if char.id then
        if not objList[char.id] then
           return 'none'
        end

        if objList[char.id].job ~= 'none' then
            objList[char.id].job = 'none'
            return 'none'
        end
    end

    return 'none'
end)

Task.Register('Burner.Call', function(source, loc)
    local char = GetCharacter(source)
    if char.id then
        if objList[char.id] and objList[char.id].job == 'phase_1' then
            local str = ''
            local code = ''

            local num = Random(4)
            if num == 1 then
                str = 'Fight in Progress'
                code = '10-10'
                TriggerClientEvent('Shared.Notif', source, 'Called in a fight', 5000)
            elseif num == 2 then
                str = 'MVA'
                code = '10-14'
                TriggerClientEvent('Shared.Notif', source, 'Called in a accident', 5000)
            elseif num == 3 then
                str = 'Attempted Arson'
                code = '10-71A'
                TriggerClientEvent('Shared.Notif', source, 'Called in a arson attempt', 5000)
            elseif num == 4 then
                str = 'Shots Fired'
                code = '10-32'
                TriggerClientEvent('Shared.Notif', source, 'Called in a gunshot', 5000)
            end

            TriggerEvent('Dispatch', {
                code = code,
                title =  str,
                location = loc.position,

                time =  os.date('%H:%M EST'),
                info = {
                    {
                        icon = 'location',
                        text = loc.location,
                        location = true
                    },
                }
            })

            objList[char.id].job = 'phase_2'
            objList[char.id].jobtime = os.time()
            return objList[char.id].job
        else
            return objList[char.id].job
        end
    end

    return 'none'
end)

Task.Register('Burner.Fail', function(source)
    local char = GetCharacter(source)
    if char.id then
        if objList[char.id] and objList[char.id].job == 'phase_2' then
            objList[char.id].job = 'none'
            TriggerClientEvent('Shared.Notif', source, 'You left the area too soon', 5000)
            return objList[char.id].job
        else
            return objList[char.id].job
        end
    end

    return 'none'
end)

Task.Register('Burner.Finish', function(source)
    local char = GetCharacter(source)
    if char.id then
        if objList[char.id] and objList[char.id].job == 'phase_2' and os.time() - objList[char.id].jobtime >= 280 then
            TriggerClientEvent('Shared.Notif', source, 'Return to your boss', 5000)
            objList[char.id].job = 'done'
            return objList[char.id].job
        else
            return objList[char.id].job
        end
    end

    return 'none'
end)

Task.Register('Burner.Pay', function(source)
    local char = GetCharacter(source)
    if char.id then
        if objList[char.id] and objList[char.id].job == 'done' then
            if exports['geo-inventory']:RemoveItem('Player', source, 'burner_phone', 1) and objList[char.id]:Pay(source, 1200) then
                objList[char.id].job = 'none'
            end

            return objList[char.id].job
        else
            return objList[char.id].job
        end
    end

    return 'none'
end)