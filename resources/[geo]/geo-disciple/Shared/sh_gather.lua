Gathering = {}

Gathering.Nodes = {

    -- Mining
    {
        ["Position"] = vector3(2952.26, 2768.17, 38.93),
        ["MinLevel"] = 1,
        ["RespawnTime"] = 60,
        ["Items"] = {
            "stone",
            "ore_iron"
        }
    },
    {
        ["Position"] = vector3(2921.95, 2799.38, 40.91),
        ["MinLevel"] = 1,
        ["RespawnTime"] = 60,
        ["Items"] = {
            "stone"
        }
    },
    {
        ["Position"] = vector3(2948.48, 2820.21, 42.49),
        ["MinLevel"] = 1,
        ["RespawnTime"] = 60,
        ["Items"] = {
            "stone"
        }
    },
    {
        ["Position"] = vector3(2972.17, 2798.61, 41.22),
        ["MinLevel"] = 1,
        ["RespawnTime"] = 60,
        ["Items"] = {
            "stone", 'ore_copper'
        }
    },
    {
        ["Position"] = vector3(2971.84, 2775.54, 38.11),
        ["MinLevel"] = 1,
        ["RespawnTime"] = 60,
        ["Items"] = {
            "stone",
        }
    },
    {
        ["Position"] = vector3(2989.92, 2809.85, 44.4),
        ["MinLevel"] = 1,
        ["RespawnTime"] = 60,
        ["Items"] = {
            "ore_zinc", 'ore_iron'
        }
    },

    -- Wood
    {
        ["Position"] = vector3(1346.17, 1283.29, 106.78),
        ["MinLevel"] = 1,
        ["RespawnTime"] = 60,
        ["Items"] = {
            "branch_maple", "log_maple",
        }
    },
    {
        ["Position"] = vector3(1355.53, 1270.93, 106.31),
        ["MinLevel"] = 1,
        ["RespawnTime"] = 60,
        ["Items"] = {
            "branch_maple", "log_maple"
        }
    },
    {
        ["Position"] = vector3(1344.81, 1264.04, 106.03),
        ["MinLevel"] = 1,
        ["RespawnTime"] = 60,
        ["Items"] = {
            "branch_maple", "log_maple"
        }
    },
    {
        ["Position"] = vector3(1316.98, 1285.31, 106.3),
        ["MinLevel"] = 1,
        ["RespawnTime"] = 60,
        ["Items"] = {
            "branch_maple", "log_maple", "syrup_maple"
        }
    },
    {
        ["Position"] = vector3(1312.89, 1325.97, 105.02),
        ["MinLevel"] = 1,
        ["RespawnTime"] = 60,
        ["Items"] = {
            "branch_maple", "log_maple"
        }
    },
    {
        ["Position"] = vector3(1311.88, 1359.83, 104.74),
        ["MinLevel"] = 1,
        ["RespawnTime"] = 60,
        ["Items"] = {
            "branch_maple", "log_maple", "tomato"
        }
    },
    {
        ["Position"] = vector3(1359.8, 1403.91, 103.4),
        ["MinLevel"] = 1,
        ["RespawnTime"] = 60,
        ["Items"] = {
            "branch_maple", "log_maple",
        }
    },
    {
        ["Position"] = vector3(1392.33, 1803.37, 99.39),
        ["MinLevel"] = 1,
        ["RespawnTime"] = 60,
        ["Items"] = {
            "egg", "syrup_maple",
        }
    },

    -- Plants
    {
        ["Position"] = vector3(997.0, 858.89, 207.5),
        ["MinLevel"] = 1,
        ["RespawnTime"] = 60,
        ["Items"] = {
            "tomato", "seeds_wheat"
        }
    },
    {
        ["Position"] = vector3(1006.0, 866.86, 212.37),
        ["MinLevel"] = 1,
        ["RespawnTime"] = 60,
        ["Items"] = {
            "tomato",
        }
    },
    {
        ["Position"] = vector3(1022.6, 898.18, 216.81),
        ["MinLevel"] = 1,
        ["RespawnTime"] = 60,
        ["Items"] = {
            "tomato", 'wheat'
        }
    },
    {
        ["Position"] = vector3(981.3, 894.67, 209.82),
        ["MinLevel"] = 1,
        ["RespawnTime"] = 60,
        ["Items"] = {
            "tomato",
        }
    },
    {
        ["Position"] = vector3(953.89, 854.14, 203.48),
        ["MinLevel"] = 1,
        ["RespawnTime"] = 60,
        ["Items"] = {
            "tomato", 'wheat'
        }
    },
    {
        ["Position"] = vector3(1357.35, 1568.67, 100.85),
        ["MinLevel"] = 1,
        ["RespawnTime"] = 60,
        ["Items"] = {
            "potato",
        }
    },

    -- Quarry
    {
        ["Position"] = vector3(3313.59, 2496.87, 2.57),
        ["MinLevel"] = 1,
        ["RespawnTime"] = 60,
        ["Items"] = {
            "sand", "stone", 'salt'
        }
    },

}

Gathering.XP = {

    -- Stone
    ["stone"] = {
        ["Name"] = "Stone",
        ["XP"] = 10,
        ["FirstMultiplier"] = 5,
        ["MinGather"] = 100,
        ["Chance"] = 80,
        ["HQChance"] = 2,
        ["HQDivisor"] = 50,
        ["Skill"] = "Mining",
        ["MinLevel"] = 1,
        ["Divisor"] = 10,
        ["Main Hand"] = true,
    },

    -- Ore
    ["ore_iron"] = {
        ["Name"] = "Iron Ore",
        ["XP"] = 25,
        ["FirstMultiplier"] = 5,
        ["MinGather"] = 140,
        ["Chance"] = 70,
        ["HQChance"] = 2,
        ["HQDivisor"] = 50,
        ["Skill"] = "Mining",
        ["MinLevel"] = 5,
        ["Divisor"] = 10,
        ["Main Hand"] = true,
    },

    ["ore_copper"] = {
        ["Name"] = "Copper Ore",
        ["XP"] = 35,
        ["FirstMultiplier"] = 5,
        ["MinGather"] = 210,
        ["Chance"] = 70,
        ["HQChance"] = 2,
        ["HQDivisor"] = 50,
        ["Skill"] = "Mining",
        ["MinLevel"] = 8,
        ["Divisor"] = 10,
        ["Main Hand"] = true,
    },

    ["ore_zinc"] = {
        ["Name"] = "Zinc Ore",
        ["XP"] = 40,
        ["FirstMultiplier"] = 5,
        ["MinGather"] = 250,
        ["Chance"] = 70,
        ["HQChance"] = 2,
        ["HQDivisor"] = 50,
        ["Skill"] = "Mining",
        ["MinLevel"] = 12,
        ["Divisor"] = 10,
        ["Main Hand"] = true,
    },

    --Branch
    ["branch_maple"] = {
        ["Name"] = "Maple Branch",
        ["XP"] = 10,
        ["FirstMultiplier"] = 5,
        ["MinGather"] = 100,
        ["Chance"] = 80,
        ["HQChance"] = 2,
        ["HQDivisor"] = 50,
        ["Skill"] = "Botany",
        ["MinLevel"] = 1,
        ["Divisor"] = 10,
        ["Main Hand"] = true,
    },

    --Log
    ["log_maple"] = {
        ["Name"] = "Maple Log",
        ["XP"] = 15,
        ["FirstMultiplier"] = 5,
        ["MinGather"] = 100,
        ["Chance"] = 80,
        ["HQChance"] = 2,
        ["HQDivisor"] = 50,
        ["Skill"] = "Botany",
        ["MinLevel"] = 3,
        ["Divisor"] = 10,
        ["Main Hand"] = true,
    },

    -- Plant
    ["tomato"] = {
        ["Name"] = "Tomato",
        ["XP"] = 15,
        ["FirstMultiplier"] = 5,
        ["MinGather"] = 100,
        ["Chance"] = 80,
        ["HQChance"] = 2,
        ["HQDivisor"] = 50,
        ["Skill"] = "Botany",
        ["MinLevel"] = 1,
        ["Divisor"] = 10,
        ["Main Hand"] = false,
    },

    -- Plant
    ["seeds_wheat"] = {
        ["Name"] = "Wheat Seeds",
        ["XP"] = 15,
        ["FirstMultiplier"] = 5,
        ["MinGather"] = 100,
        ["Chance"] = 80,
        ["HQChance"] = 2,
        ["HQDivisor"] = 50,
        ["Skill"] = "Botany",
        ["MinLevel"] = 1,
        ["Divisor"] = 10,
        ["Main Hand"] = false,
    },
    ["wheat"] = {
        ["Name"] = "Wheat",
        ["XP"] = 15,
        ["FirstMultiplier"] = 5,
        ["MinGather"] = 100,
        ["Chance"] = 80,
        ["HQChance"] = 2,
        ["HQDivisor"] = 50,
        ["Skill"] = "Botany",
        ["MinLevel"] = 1,
        ["Divisor"] = 10,
        ["Main Hand"] = false,
    },
    ["syrup_maple"] = {
        ["Name"] = "Maple Syrup",
        ["XP"] = 20,
        ["FirstMultiplier"] = 5,
        ["MinGather"] = 130,
        ["Chance"] = 70,
        ["HQChance"] = 2,
        ["HQDivisor"] = 50,
        ["Skill"] = "Botany",
        ["MinLevel"] = 4,
        ["Divisor"] = 10,
        ["Main Hand"] = false,
    },
    ["egg"] = {
        ["Name"] = "Egg",
        ["XP"] = 25,
        ["FirstMultiplier"] = 5,
        ["MinGather"] = 140,
        ["Chance"] = 50,
        ["HQChance"] = 2,
        ["HQDivisor"] = 50,
        ["Skill"] = "Botany",
        ["MinLevel"] = 5,
        ["Divisor"] = 10,
        ["Main Hand"] = false,
    },

     -- Sand
     ["sand"] = {
        ["Name"] = "Sand",
        ["XP"] = 15,
        ["FirstMultiplier"] = 5,
        ["MinGather"] = 100,
        ["Chance"] = 70,
        ["HQChance"] = 2,
        ["HQDivisor"] = 50,
        ["Skill"] = "Mining",
        ["MinLevel"] = 3,
        ["Divisor"] = 10,
        ["Main Hand"] = true,
    },
    ["salt"] = {
        ["Name"] = "Salt",
        ["XP"] = 30,
        ["FirstMultiplier"] = 5,
        ["MinGather"] = 160,
        ["Chance"] = 70,
        ["HQChance"] = 2,
        ["HQDivisor"] = 50,
        ["Skill"] = "Mining",
        ["MinLevel"] = 7,
        ["Divisor"] = 10,
        ["Main Hand"] = true,
    },
}

function New(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[New(orig_key)] = New(orig_value)
        end
        setmetatable(copy, New(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

if IsDuplicityVersion() then
    Tools = {
        ["pickaxe"] = {
            ["Skill"] = "Mining",
            ["Requirement"] = 1,
            ["Ability"] = exports['geo-inventory']:GetItem('pickaxe').Data.Gathering
        },

        ["pickaxe_iron_1"] = {
            ["Skill"] = "Mining",
            ["Requirement"] = 1,
            ["Ability"] = exports['geo-inventory']:GetItem('pickaxe_iron_1').Data.Gathering
        },

        ["hatchet"] = {
            ["Skill"] = "Botany",
            ["Requirement"] = 1,
            ["Ability"] = exports['geo-inventory']:GetItem('hatchet').Data.Gathering
        },

        ["scythe"] = {
            ["Skill"] = "Botany",
            ["Requirement"] = 1,
            ["Ability"] = exports['geo-inventory']:GetItem('scythe').Data.Gathering
        },

        ["forging_hammer"] = {
            ["Skill"] = "Smelting",
            ["Requirement"] = 1,
            ["Ability"] = exports['geo-inventory']:GetItem('forging_hammer').Data.Crafting
        }
    }

    for k,v in pairs(Tools) do
        if not k:match('_hq') then
            Tools[k..'_hq'] = New(v)
            Tools[k..'_hq'].Ability = exports['geo-inventory']:GetItem(k..'_hq').Data.Gathering or exports['geo-inventory']:GetItem(k..'_hq').Data.Crafting
        end
    end
end


function Gathering.NearNode(pos, nodeID)
    if not Gathering.Nodes[nodeID] then
        return
    end
    return Vdist3(pos, Gathering.Nodes[nodeID].Position) <= 3.0
end

function Gathering.NearAnyNode(pos)
    for k, v in pairs(Gathering.Nodes) do
        if Vdist3(pos, v.Position) <= 3.0 then
            return k
        end
    end
end