local objList = {}
local jobList = {
    {vector3(1228.71, -725.66, 60.8), ''},
    {vector3(1222.59, -697.09, 60.8), ''},
    {vector3(1221.29, -668.81, 63.5), ''},
    {vector3(1207.02, -620.48, 66.44), ''},
    {vector3(1204.75, -557.77, 69.62), ''},
    {vector3(1265.57, -702.98, 64.57), ''},
    {vector3(1271.11, -683.36, 66.03), ''},
    {vector3(1265.8, -647.86, 67.92), ''},
    {vector3(1251.05, -621.4, 69.41), ''},
    {vector3(1240.56, -601.62, 69.78), ''},
    {vector3(1241.81, -566.14, 69.66), ''},
    {vector3(1300.96, -574.14, 71.73), ''},
    {vector3(1323.5, -582.9, 73.25), ''},
    {vector3(1341.65, -597.46, 74.7), ''},
    {vector3(1367.34, -606.53, 74.71), ''},
    {vector3(1385.93, -593.3, 74.49), ''},
    {vector3(1388.51, -569.82, 74.5), ''},
    {vector3(1372.9, -555.65, 74.69), ''},
    {vector3(1373.28, -555.6, 74.69), ''},
    {vector3(1348.35, -546.79, 73.89), ''},
    {vector3(1348.35, -546.79, 73.89), ''},
    {vector3(1303.07, -527.42, 71.46), ''},
    {vector3(1250.88, -515.56, 69.35), ''},
    {vector3(1251.6, -494.23, 69.9), ''},
    {vector3(1251.6, -494.23, 69.9), ''},
    {vector3(1265.73, -457.91, 70.52), ''},
    {vector3(1262.75, -429.7, 70.01), ''},
    {vector3(996.89, -729.47, 57.82), ''},
    {vector3(979.3, -715.97, 58.22), ''},
    {vector3(970.94, -701.41, 58.48), ''},
    {vector3(960.27, -669.51, 58.45), ''},
    {vector3(943.77, -653.49, 58.43), ''},
    {vector3(929.12, -639.46, 58.24), ''},
    {vector3(903.03, -615.48, 58.45), ''},
    {vector3(886.76, -608.17, 58.45), ''},
    {vector3(861.8, -583.32, 58.16), ''},
    {vector3(844.35, -563.24, 57.83), ''},
    {vector3(850.33, -532.74, 57.91), ''},
    {vector3(861.84, -509.3, 57.4), ''},
    {vector3(878.81, -498.28, 58.09), ''},
    {vector3(906.41, -489.38, 59.44), ''},
    {vector3(921.83, -477.88, 61.08), ''},
    {vector3(944.45, -463.35, 61.46), ''},
    {vector3(967.68, -452.04, 62.57), ''},
    {vector3(987.93, -433.15, 63.88), ''},
    {vector3(1010.5, -423.55, 65.37), ''},
    {vector3(1028.89, -408.54, 66.11), ''},
    {vector3(1060.64, -378.18, 68.23), ''},
    {vector3(980.38, -627.54, 59.24), ''},
    {vector3(920.05, -570.0, 58.37), ''},
    {vector3(893.1, -540.51, 58.51), ''},
    {vector3(924.38, -526.05, 59.8), ''},
    {vector3(946.03, -518.94, 60.65), ''},
    {vector3(969.95, -502.18, 62.14), ''},
    {vector3(1014.56, -469.38, 64.52), ''},
    {vector3(1100.99, -411.36, 67.56), ''},
    {vector3(1099.52, -438.55, 67.79), ''},
    {vector3(1056.52, -448.75, 66.25), ''},
    {vector3(1090.25, -484.48, 65.66), ''},
    {vector3(1051.68, -470.46, 63.9), ''},
    {vector3(126.5, -1929.88, 21.38), ''},
    {vector3(118.5, -1920.86, 21.32), ''},
    {vector3(114.57, -1961.17, 21.33), ''},
    {vector3(85.83, -1959.78, 21.12), ''},
    {vector3(76.38, -1948.17, 21.17), ''},
    {vector3(72.21, -1939.11, 21.36), ''},
    {vector3(56.63, -1922.76, 21.91), ''},
    {vector3(39.24, -1911.52, 21.95), ''},
    {vector3(22.96, -1897.0, 22.96), ''},
    {vector3(5.13, -1884.36, 23.7), ''},
    {vector3(-4.94, -1872.33, 24.15), ''},
    {vector3(-20.29, -1858.54, 25.41), ''},
    {vector3(-34.07, -1846.96, 26.19), ''},
    {vector3(-50.31, -1783.39, 28.3), ''},
    {vector3(-42.14, -1792.57, 27.83), ''},
    {vector3(21.76, -1844.28, 24.6), ''},
    {vector3(29.97, -1854.65, 24.05), ''},
    {vector3(46.05, -1864.29, 23.28), ''},
    {vector3(54.43, -1873.24, 22.81), ''},
    {vector3(130.36, -1853.31, 25.23), ''},
    {vector3(115.45, -1887.71, 23.93), ''},
    {vector3(128.06, -1896.73, 23.67), ''},
    {vector3(148.67, -1903.93, 23.53), ''},
    {vector3(150.2, -1864.73, 24.59), ''},
    {vector3(171.04, -1871.69, 24.4), ''},
    {vector3(192.34, -1883.25, 25.07), ''},
    {vector3(208.54, -1895.06, 24.81), ''},
    {vector3(197.72, -1725.76, 29.66), ''},
    {vector3(216.52, -1717.54, 29.68), ''},
    {vector3(222.58, -1702.53, 29.7), ''},
    {vector3(240.95, -1687.89, 29.69), ''},
    {vector3(253.06, -1670.97, 29.66), ''},
    {vector3(282.14, -1694.8, 29.65), ''},
    {vector3(269.67, -1712.85, 29.67), ''},
    {vector3(257.25, -1722.81, 29.65), ''},
    {vector3(250.21, -1730.67, 29.67), ''},
    {vector3(304.5, -1775.6, 29.1), ''},
    {vector3(320.86, -1759.66, 29.64), ''},
    {vector3(333.0, -1741.48, 29.73), ''},
    {vector3(405.47, -1751.49, 29.71), ''},
    {vector3(418.92, -1735.62, 29.61), ''},
    {vector3(430.98, -1725.33, 29.6), ''},
    {vector3(443.27, -1707.35, 29.71), ''},
    {vector3(500.55, -1697.16, 29.79), ''},
    {vector3(489.95, -1714.17, 29.71), ''},
    {vector3(479.54, -1736.16, 29.15), ''},
    {vector3(474.58, -1757.53, 29.09), ''},
    {vector3(472.14, -1775.38, 29.07), ''},
    {vector3(514.28, -1780.68, 28.91), ''},
    {vector3(512.51, -1790.75, 28.92), ''},
    {vector3(500.56, -1813.23, 28.89), ''},
    {vector3(495.42, -1823.36, 28.87), ''},
    {vector3(-64.21, -1449.2, 32.53), ''},
    {vector3(-45.75, -1445.68, 32.44), ''},
    {vector3(-32.28, -1446.24, 31.86), ''},
    {vector3(-14.21, -1441.92, 31.03), ''},
    {vector3(16.47, -1444.01, 30.96), ''},
    {vector3(-1111.5, -902.36, 3.78), ''},
    {vector3(-1090.56, -926.7, 3.1), ''},
    {vector3(-1031.16, -902.93, 3.69), ''},
    {vector3(-1022.52, -896.86, 5.41), ''},
    {vector3(-1076.23, -1026.95, 4.54), ''},
    {vector3(-1054.01, -1000.23, 6.41), ''},
    {vector3(-1063.83, -1054.76, 2.15), ''},
    {vector3(-991.76, -1103.5, 2.15), ''},
    {vector3(-938.67, -1087.83, 2.15), ''},
    {vector3(-1063.43, -1160.27, 2.77), ''},
    {vector3(-1068.21, -1163.14, 2.79), ''},
    {vector3(-1082.78, -1139.28, 2.16), ''},
    {vector3(-1113.9, -1193.81, 2.38), ''},
    {vector3(-1113.95, -1069.17, 2.15), ''},
    {vector3(-1104.09, -1060.01, 2.77), ''},
    {vector3(-830.37, 114.86, 56.03), ''},
    {vector3(-888.29, 42.57, 49.15), ''},
    {vector3(-930.18, 19.58, 48.53), ''},
    {vector3(-817.28, 177.98, 72.23), ''},
    {vector3(-998.2, 158.2, 62.32), ''},
    {vector3(-949.25, 196.86, 67.39), ''},
    {vector3(-1037.97, 222.09, 64.38), ''},
    {vector3(-902.19, 191.68, 69.45), ''},
    {vector3(-72.91, 428.51, 113.04), ''},
    {vector3(-2.83, 398.24, 120.41), ''},
    {vector3(-214.11, 399.53, 111.3), ''},
    {vector3(-298.0, 379.7, 112.1), ''},
    {vector3(-323.04, 378.54, 110.02), ''},
    {vector3(-371.91, 343.23, 109.94), ''},
    {vector3(-409.58, 341.57, 108.91), ''},
    {vector3(-444.4, 342.78, 105.62), ''},
    {vector3(-469.05, 329.35, 104.45), ''},
    {vector3(-476.8, 413.17, 103.12), ''},
    {vector3(-516.55, 433.4, 97.81), ''},
    {vector3(-536.69, 477.39, 103.19), ''},
    {vector3(-580.29, 491.7, 108.9), ''},
    {vector3(-622.89, 488.86, 108.88), ''},
    {vector3(-667.2, 471.53, 114.18), ''},
    {vector3(-678.89, 512.09, 113.53), ''},
    {vector3(-640.64, 520.59, 109.88), ''},
    {vector3(-595.43, 530.33, 107.75), ''},
    {vector3(-554.56, 541.24, 110.71), ''},
    {vector3(-667.19, 471.47, 114.15), ''},
    {vector3(-741.76, 485.28, 109.69), ''},
    {vector3(-718.04, 448.86, 106.91), ''},
    {vector3(-762.2, 430.84, 100.18), ''},
    {vector3(-824.86, 421.99, 92.13), ''},
    {vector3(-833.66, 456.39, 89.9), ''},
    {vector3(-866.25, 456.94, 88.28), ''}
}

local houses = {}

Jobs:RegisterRanking('HouseRob', DefaultCriminal)
RegisterNetEvent('HouseRob.Start', function()
    local source = source
    local char = GetCharacter(source)
    if char.id then
        if not objList[char.id] then
            objList[char.id] = Jobs.Fetch('HouseRob', char.id)
            if not objList[char.id] then return end
            objList[char.id].job = 'none'
            JobTime[char.id] = os.time()
        end

        if objList[char.id].job ~= 'none' then
            return
        end

        if not RateLimitSeconds('HouseRob'..char.id, 600) then
            TriggerClientEvent('Shared.Notif', source, 'Try again later', 5000)
            return
        end

        objList[char.id]:CheckPromotion()
        objList[char.id].job = 'phase_1'

        TriggerClientEvent('PhoneNotif', source, 'messages', [[
            Wel'll let you know when we find a house to rob
        ]], 7500)

        TriggerClientEvent('HouseRob.SetState', source, objList[char.id].job)


        Citizen.SetTimeout(Random(120, 480) * 1000, function()
            if exports['geo-interface']:PhoneConfirm(source, 'We found a house', 60, 'messages') then
                objList[char.id].job = 'phase_2'
                objList[char.id].location = jobList[Random(#jobList)][1]
                objList[char.id].robbed = {}
                TriggerClientEvent('HouseRob.SetState', source, objList[char.id].job, objList[char.id].location)
            else
                objList[char.id].job = 'none'
                TriggerClientEvent('HouseRob.SetState', source, objList[char.id].job)
            end
        end)
    end
end)

RegisterNetEvent('HouseRob.Quit', function()
    local source = source
    local char = GetCharacter(source)
    if char.id then
        if objList[char.id] then
            objList[char.id].job = 'none'
            TriggerClientEvent('HouseRob.SetState', source, objList[char.id].job)
        end
    end
end)

Task.Register('HouseRob.Enter', function(source)
    local char = GetCharacter(source)
    if char.id then
        if objList[char.id] and (objList[char.id].job == 'phase_2' or objList[char.id].job == 'done') then
            local pos =  {}
            pos.x = objList[char.id].location.x
            pos.y = objList[char.id].location.y
            pos.z = objList[char.id].location.z
            pos.w = GetEntityHeading(GetPlayerPed(source))
            exports['geo-es']:AddRaid('HouseRobbery '..char.id, 'apartment_2', {pos.x, pos.y, pos.z, pos.w - 180.0})
            houses['HouseRobbery '..char.id] = source
            exports['geo-instance']:EnterProperty(source, 'HouseRobbery '..char.id, 'apartment_2', false, {pos.x, pos.y, pos.z, pos.w - 180.0})
        end
    end
end)

Task.Register('HouseRob.HomeInvasion', function(source, loc)
    local char = GetCharacter(source)
    if char.id then
        if objList[char.id] then
            if objList[char.id].alert == nil then
                objList[char.id].alert = true
                TriggerEvent('Dispatch', {
                    code = '10-16',
                    title = 'Home Invasion',
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
                objList[char.id].job = 'done'
                TriggerClientEvent('HouseRob.SetState', source, objList[char.id].job)
            end
        end
    end 
end)

Task.Register('HouseRob.Loot', function(source, id)
    local char = GetCharacter(source)
    if objList[char.id] and (objList[char.id].job == 'phase_2' or objList[char.id].job == 'done') and HouseRob.Zones[id] then
        if not objList[char.id].robbed[id] then
            objList[char.id].robbed[id] = exports['geo-jobs']:Loot(source, 'HouseRobbery')
            objList[char.id].job = 'done'
            TriggerClientEvent('HouseRob.SetState', source, objList[char.id].job)
            return objList[char.id].robbed[id]
        end
    end
end)

RegisterNetEvent('HouseRob.Pay', function()
    local source = source
    local char = GetCharacter(source)
    if objList[char.id] and objList[char.id].job == 'done' then
        if objList[char.id]:Pay(source, 3600) then
            objList[char.id] = nil
            TriggerClientEvent('HouseRob.SetState', source, 'none')
        end
    end
end)

AddEventHandler('EnteredProperty', function(source, property)
    if houses[property] and source == houses[property] then
        local char = GetCharacter(source)
        TriggerClientEvent('HouseRob.Enter', houses[property], objList[char.id].firstenter == nil)
        objList[char.id].firstenter = true
    end
end)