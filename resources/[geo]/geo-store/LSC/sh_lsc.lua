repairLocations = {
    {
        Position = vector3(-223.5, -1329.56, 30.51),
        Customize = true,
        Name = 'Bennys',
        Owner = 0,
        Employees = {}
    },
    {
        Position = vector3(-198.06, -1382.68, 30.44),
        Customize = false,
        Name = 'Glass Heros',
        Owner = 0,
        Employees = {}
    },
    {
        Position = vector3(-1159.09, -2018.81, 12.35),
        Customize = true,
        Name = 'LSC Greenwich',
        Owner = 0,
        Employees = {},
    },
    {
        Position = vector3(732.81, -1086.6, 21.35),
        Customize = true,
        Name = 'LSC Popular',
        Owner = 0,
        Employees = {}
    },
    {
        Position = vector3(1150.19, -775.07, 56.79),
        Customize = false,
        Name = 'Mirror Park',
        Owner = 0,
        Employees = {}
    },
    {
        Position = vector3(-323.45, -134.16, 36.17),
        Customize = true,
        Name = 'LSC San Vitus',
        Owner = 0,
        Employees = {}
    },
    {
        Position = vector3(1175.1, 2640.15, 36.94),
        Customize = false,
        Name = 'Route 68 Store',
        Owner = 0,
        Employees = {}
    },
    {
        Position = vector3(216.86,2607.41,46.23),
        Customize = false,
        Name = 'Route 68 & Joshua',
        Owner = 0,
        Employees = {},
        Range = 20.0
    },
    {
        Position = vector3(258.34, 2590.28, 44.15),
        Customize = false,
        Name = 'Senora Road',
        Owner = 0,
        Employees = {}
    },
    {
        Position = vector3(111.69, 6626.0, 30.97),
        Customize = true,
        Name = 'Beekers',
        Owner = 0,
        Employees = {},
        Range = 15.0
    },
    {
        Position = vector3(139.09, 6635.92, 31.63),
        Customize = false,
        Name = 'Beekers2',
        Owner = 0,
        Employees = {},
        Range = 5.0
    },
    {
        Position = vector3(-1134.8, -1992.73, 13.17),
        Name = 'LS Customs Greenwich Parkway',
        Customize = false,
        Owner = 0,
        Employees = {},
        Range = 5.0
    },
    {
        Position = vector3(462.84, -1019.67, 28.11),
        Customize = true,
        Name = 'PD',
        Owner = 0,
        Employees = {}
    },
}

repairCosts = {
    [VehicleClass.Compact] = 0.8,
    [VehicleClass.Sedan] = 1.0,
    [VehicleClass.SUV] = 1.2,
    [VehicleClass.Coupe] = 1.4,
    [VehicleClass.Muscle] = 0.9,
    [VehicleClass.SportsClassic] = 1.4,
    [VehicleClass.Sports] = 1.6,
    [VehicleClass.Super] = 3.0,
    [VehicleClass.Motorcycle] = 0.75,
    [VehicleClass.OffRoad] = 0.8,
    [VehicleClass.Industrial] = 1.1,
    [VehicleClass.Utility] = 1.0,
    [VehicleClass.Van] = 1.05,
    [VehicleClass.Cycle] = 0.2,
    [VehicleClass.Boat] = 2.0,
    [VehicleClass.Helicopter] = 2.5,
    [VehicleClass.Plane] = 4.0,
    [VehicleClass.Service] = 0.6,
    [VehicleClass.Emergency] = 0.75,
    [VehicleClass.Military] = 2.2,
    [VehicleClass.Commcerical] = 1.5,
    [VehicleClass.Trains] = 10.0
}

bodyCosts = {
    [VehicleClass.Compact] = 0.8,
    [VehicleClass.Sedan] = 1.0,
    [VehicleClass.SUV] = 1.2,
    [VehicleClass.Coupe] = 1.4,
    [VehicleClass.Muscle] = 0.9,
    [VehicleClass.SportsClassic] = 1.4,
    [VehicleClass.Sports] = 1.6,
    [VehicleClass.Super] = 3.0,
    [VehicleClass.Motorcycle] = 0.75,
    [VehicleClass.OffRoad] = 0.8,
    [VehicleClass.Industrial] = 1.1,
    [VehicleClass.Utility] = 1.0,
    [VehicleClass.Van] = 1.05,
    [VehicleClass.Cycle] = 0.2,
    [VehicleClass.Boat] = 2.0,
    [VehicleClass.Helicopter] = 2.5,
    [VehicleClass.Plane] = 4.0,
    [VehicleClass.Service] = 0.6,
    [VehicleClass.Emergency] = 0.75,
    [VehicleClass.Military] = 2.2,
    [VehicleClass.Commcerical] = 1.5,
    [VehicleClass.Trains] = 10.0
}

class_mult = {
    [VehicleClass.Compact] = 0.8,
    [VehicleClass.Sedan] = 1.0,
    [VehicleClass.SUV] = 1.2,
    [VehicleClass.Coupe] = 1.4,
    [VehicleClass.Muscle] = 0.9,
    [VehicleClass.SportsClassic] = 1.4,
    [VehicleClass.Sports] = 2.0,
    [VehicleClass.Super] = 3.0,
    [VehicleClass.Motorcycle] = 0.75,
    [VehicleClass.OffRoad] = 0.8,
    [VehicleClass.Industrial] = 1.1,
    [VehicleClass.Utility] = 1.0,
    [VehicleClass.Van] = 1.05,
    [VehicleClass.Cycle] = 0.2,
    [VehicleClass.Boat] = 2.0,
    [VehicleClass.Helicopter] = 2.5,
    [VehicleClass.Plane] = 4.0,
    [VehicleClass.Service] = 0.6,
    [VehicleClass.Emergency] = 2.0,
    [VehicleClass.Military] = 2.2,
    [VehicleClass.Commcerical] = 1.5,
    [VehicleClass.Trains] = 10.0
}

prices = {
    ['tint'] = {
        Base = 1000,
        Addon = 0.0,
        nonMult = true
    },
    ['plateType'] = {
        Base = 500,
        Addon = 0.0,
        nonMult = true
    },
    ['plate'] = {
        Base = 10000,
        Addon = 0.0,
        nonMult = true
    },
    ['xenon'] = {
        Base = 2500,
        Addon = 0.0,
        nonMult = true
    },
    ['turbo'] = {
        Base = 5000,
        Addon = 0.0,
        nonMult = true
    },
    ['paint'] = {
        Base = 250,
        Addon = 0.0,
        nonMult = true
    },
    ['paint2'] = {
        Base = 250,
        Addon = 0.0,
        nonMult = true
    },
    ['paintCustom'] = {
        Base = 250,
        Addon = 0.0,
        nonMult = true
    },
    ['paint2Custom'] = {
        Base = 250,
        Addon = 0.0,
        nonMult = true
    },
    ['pearl'] = {
        Base = 250,
        Addon = 0.0,
        nonMult = true
    },
    ['wheelColor'] = {
        Base = 250,
        Addon = 0.0,
        nonMult = true
    },
    ['extras'] = {
        Base = 5,
        Addon = 0.0,
        nonMult = true
    },
    [0] = {
        Base = 400,
        Addon = 0.5
    },
    [1] = {
        Base = 300,
        Addon = 0.6
    },
    [2] = {
        Base = 300,
        Addon = 0.6
    },
    [3] = {
        Base = 400,
        Addon = 0.55
    },
    [4] = {
        Base = 300,
        Addon = 0.6
    },
    [5] = {
        Base = 300,
        Addon = 0.6
    },
    [6] = {
        Base = 700,
        Addon = 0.8
    },
    [7] = {
        Base = 700,
        Addon = 0.8
    },
    [8] = {
        Base = 700,
        Addon = 0.8
    },
    [9] = {
        Base = 700,
        Addon = 0.8
    },
    [10] = {
        Base = 700,
        Addon = 0.8
    },
    [11] = {
        Base = 5000,
        Addon = 0.8
    },
    [12] = {
        Base = 700,
        Addon = 0.8
    },
    [13] = {
        Base = 700,
        Addon = 0.8
    },
    [14] = {
        Base = 700,
        Addon = 0.8
    },
    [15] = {
        Base = 700,
        Addon = 0.8
    },
    [16] = {
        Base = 700,
        Addon = 0.8
    },
    [17] = {
        Base = 700,
        Addon = 0.8
    },
    [18] = {
        Base = 700,
        Addon = 0.8
    },
    [19] = {
        Base = 700,
        Addon = 0.8
    },
    [20] = {
        Base = 700,
        Addon = 0.8
    },
    [21] = {
        Base = 700,
        Addon = 0.8
    },
    [22] = {
        Base = 700,
        Addon = 0.8
    },
    [23] = {
        Base = 700,
        Addon = 0.1
    },
    [24] = {
        Base = 700,
        Addon = 0.8
    },
    [25] = {
        Base = 700,
        Addon = 0.8
    },
    [26] = {
        Base = 700,
        Addon = 0.8
    },
    [27] = {
        Base = 700,
        Addon = 0.8
    },
    [28] = {
        Base = 700,
        Addon = 0.8
    },
    [29] = {
        Base = 700,
        Addon = 0.8
    },
    [30] = {
        Base = 700,
        Addon = 0.8
    },
    [31] = {
        Base = 700,
        Addon = 0.8
    },
    [32] = {
        Base = 700,
        Addon = 0.8
    },
    [33] = {
        Base = 700,
        Addon = 0.8
    },
    [34] = {
        Base = 700,
        Addon = 0.8
    },
    [35] = {
        Base = 700,
        Addon = 0.8
    },
    [36] = {
        Base = 700,
        Addon = 0.8
    },
    [37] = {
        Base = 700,
        Addon = 0.8
    },
    [38] = {
        Base = 700,
        Addon = 0.8
    },
    [39] = {
        Base = 700,
        Addon = 0.8
    },
    [40] = {
        Base = 700,
        Addon = 0.8
    },
    [41] = {
        Base = 700,
        Addon = 0.8
    },
    [42] = {
        Base = 700,
        Addon = 0.8,
        nonMult = {[18] = true}
    },
    [43] = {
        Base = 700,
        Addon = 0.8,
        nonMult = {[18] = true}
    },
    [44] = {
        Base = 700,
        Addon = 0.8,
        nonMult = {[18] = true}
    },
    [45] = {
        Base = 700,
        Addon = 0.8
    },
    [46] = {
        Base = 700,
        Addon = 0.8
    },
    [47] = {
        Base = 700,
        Addon = 0.8
    },
    [48] = {
        Base = 10000,
        Addon = 1.0
    },
    [49] = {
        Base = 700,
        Addon = 0.8
    },
}

function GetRepairCost(engineHealth, bodyHealth, class)
    local cost = 0

    cost = cost + math.floor((1000 - engineHealth) * (repairCosts[class] or 1.0))
    cost = cost + math.floor((1000 - engineHealth) * (bodyCosts[class] or 1.0) / 10)
    return cost
end

local _server = IsDuplicityVersion()
function CalculatePrice(class, modID, index)

    if not prices[modID] then
        return 0
    end

    if prices[modID].nonMult then
        if type(prices[modID].nonMult) == 'table' then
            if prices[modID].nonMult[class] then
                return prices[modID].Base + (_server and 0 or GetPrice(prices[modID].Base) - prices[modID].Base)
            end
        else
            return prices[modID].Base + (_server and 0 or GetPrice(prices[modID].Base) - prices[modID].Base)
        end
    end

    local prce = math.floor((class_mult[class] or 1.0) * (prices[modID].Base + ((prices[modID].Base * prices[modID].Addon) * index)))
    if prce < 0 then
        prce = 0
    end
    return prce + (_server and 0 or GetPrice(prce) - prce)
end

function CanMod(id, shop)
    if repairLocations[shop] then
        if repairLocations[shop].Owner == id then
            return true
        end

        for k,v in pairs(repairLocations[shop].Employees) do
            if id == v then
                return true
            end
        end
    end
end

exports('RepairLocations', function()
    local tbl = {}
    for k,v in pairs(repairLocations) do
        table.insert(tbl, v.Position)
    end
    return tbl
end)