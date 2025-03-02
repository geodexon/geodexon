Crafting = {}

Crafting.Jobs = {"Smelting", "Carpenter", "Leatherworker", "Chef"}

Crafting.Lists = {}
Crafting.Lists.Smelting = {
    {
        ["Item"] = 'ingot_iron',
        ["Name"] = exports['geo-inventory']:GetItemName("ingot_iron"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"ore_iron", 4, exports['geo-inventory']:GetItemName("ore_iron")}
        },
        ["Level"] = 1,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 80,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'nails_iron',
        ["Name"] = exports['geo-inventory']:GetItemName("nails_iron"),
        ["Amount"] = 5,
        ["Requirements"] = {
            {"ingot_iron", 1, exports['geo-inventory']:GetItemName("ingot_iron")}
        },
        ["Level"] = 1,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 80,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'glass',
        ["Name"] = exports['geo-inventory']:GetItemName("glass"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"sand", 10, exports['geo-inventory']:GetItemName("sand")}
        },
        ["Level"] = 3,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 80,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'auto_parts',
        ["Name"] = exports['geo-inventory']:GetItemName("auto_parts"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"ingot_iron", 2, exports['geo-inventory']:GetItemName("ingot_iron")},
        },
        ["Level"] = 3,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 100,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'hatchet',
        ["Name"] = exports['geo-inventory']:GetItemName("hatchet"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"ingot_iron", 3, exports['geo-inventory']:GetItemName("ingot_iron")},
            {"lumber_maple", 3, exports['geo-inventory']:GetItemName("lumber_maple")},
        },
        ["Level"] = 3,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 80,
        ["ControlMin"] = 0,
        ["Control"] = 100,
        ["Durability"] = 80,
    },
    {
        ["Item"] = 'lockpick_flimsy',
        ["Name"] = exports['geo-inventory']:GetItemName("lockpick_flimsy"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"ingot_iron", 3, exports['geo-inventory']:GetItemName("ingot_iron")},
        },
        ["Level"] = 4,
        ["CraftsmanshipMin"] = 200,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 100,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'repair_kit',
        ["Name"] = exports['geo-inventory']:GetItemName("repair_kit"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"auto_parts", 4, exports['geo-inventory']:GetItemName("auto_parts")},
            {"nails_iron", 20, exports['geo-inventory']:GetItemName("nails_iron")},
        },
        ["Level"] = 6,
        ["CraftsmanshipMin"] = 200,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 100,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'ingot_copper',
        ["Name"] = exports['geo-inventory']:GetItemName("ingot_copper"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"ore_copper", 4, exports['geo-inventory']:GetItemName("ore_copper")},
        },
        ["Level"] = 6,
        ["CraftsmanshipMin"] = 200,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 100,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'knife',
        ["Name"] = exports['geo-inventory']:GetItemName("knife"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"ingot_iron", 2, exports['geo-inventory']:GetItemName("ingot_iron")},
            {"leather", 1, exports['geo-inventory']:GetItemName("leather")}
        },
        ["Level"] = 5,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 80,
        ["ControlMin"] = 0,
        ["Control"] = 100,
        ["Durability"] = 80,
    },
    {
        ["Item"] = 'pickaxe_iron_1',
        ["Name"] = exports['geo-inventory']:GetItemName("pickaxe_iron_1"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"ingot_iron", 5, exports['geo-inventory']:GetItemName("ingot_iron")},
            {"lumber_maple", 12, exports['geo-inventory']:GetItemName("lumber_maple")},
            {"nails_iron", 20, exports['geo-inventory']:GetItemName("nails_iron")}
        },
        ["Level"] = 7,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 80,
        ["ControlMin"] = 0,
        ["Control"] = 100,
        ["Durability"] = 80,
    },
    {
        ["Item"] = 'plating_copper',
        ["Name"] = exports['geo-inventory']:GetItemName("plating_copper"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"ingot_copper", 2, exports['geo-inventory']:GetItemName("ingot_copper")},
        },
        ["Level"] = 7,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 100,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'binoculars',
        ["Name"] = exports['geo-inventory']:GetItemName("binoculars"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"ingot_iron", 4, exports['geo-inventory']:GetItemName("ingot_iron")},
            {"ingot_copper", 2, exports['geo-inventory']:GetItemName("ingot_copper")},
            {"glass", 2, exports['geo-inventory']:GetItemName("glass")},
        },
        ["Level"] = 7,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 100,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'wire_copper',
        ["Name"] = exports['geo-inventory']:GetItemName("wire_copper"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"ingot_copper", 2, exports['geo-inventory']:GetItemName("ingot_copper")},
        },
        ["Level"] = 8,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 100,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'lightarmor',
        ["Name"] = exports['geo-inventory']:GetItemName("lightarmor"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"plating_copper", 4, exports['geo-inventory']:GetItemName("plating_copper")},
            {"armor_vest", 1, exports['geo-inventory']:GetItemName("armor_vest")},
        },
        ["Level"] = 10,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 80,
        ["ControlMin"] = 0,
        ["Control"] = 100,
        ["Durability"] = 80,
    },
    {
        ["Item"] = 'ingot_bronze',
        ["Name"] = exports['geo-inventory']:GetItemName("ingot_bronze"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"ore_copper", 3, exports['geo-inventory']:GetItemName("ore_copper")},
            {"ore_zinc", 3, exports['geo-inventory']:GetItemName("ore_zinc")},
        },
        ["Level"] = 10,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 100,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'lockpick',
        ["Name"] = exports['geo-inventory']:GetItemName("lockpick"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"ingot_iron", 3, exports['geo-inventory']:GetItemName("ingot_iron")},
            {"ingot_bronze", 2, exports['geo-inventory']:GetItemName("ingot_bronze")},
        },
        ["Level"] = 11,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 100,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'repair_kit_adv',
        ["Name"] = exports['geo-inventory']:GetItemName("repair_kit_adv"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"auto_parts", 6, exports['geo-inventory']:GetItemName("auto_parts")},
            {"ingot_bronze", 3, exports['geo-inventory']:GetItemName("ingot_bronze")},
        },
        ["Level"] = 15,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 100,
        ["Durability"] = 40,
    },
}

Crafting.Lists.Carpenter = {
    {
        ["Item"] = 'lumber_maple',
        ["Name"] = exports['geo-inventory']:GetItemName("lumber_maple"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"log_maple", 4, exports['geo-inventory']:GetItemName("log_maple")},
        },
        ["Level"] = 1,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 80,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'rod_maple',
        ["Name"] = exports['geo-inventory']:GetItemName("rod_maple"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"lumber_maple", 4, exports['geo-inventory']:GetItemName("lumber_maple")},
        },
        ["Level"] = 1,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 80,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'bat_maple',
        ["Name"] = exports['geo-inventory']:GetItemName("bat_maple"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"rod_maple", 2, exports['geo-inventory']:GetItemName("rod_maple")},
            {"nails_iron", 8, exports['geo-inventory']:GetItemName("nails_iron")},
        },
        ["Level"] = 3,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 80,
        ["ControlMin"] = 0,
        ["Control"] = 80,
        ["Durability"] = 80,
    },
    {
        ["Item"] = 'scythe',
        ["Name"] = exports['geo-inventory']:GetItemName("scythe"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"ingot_iron", 3, exports['geo-inventory']:GetItemName("ingot_iron")},
            {"lumber_maple", 3, exports['geo-inventory']:GetItemName("lumber_maple")},
        },
        ["Level"] = 3,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 80,
        ["ControlMin"] = 0,
        ["Control"] = 100,
        ["Durability"] = 80,
    },
}

Crafting.Lists.Leatherworker = {
    {
        ["Item"] = 'leather',
        ["Name"] = exports['geo-inventory']:GetItemName("leather"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"hide_animal", 2, exports['geo-inventory']:GetItemName("hide_animal")},
        },
        ["Level"] = 1,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 80,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'armor_vest',
        ["Name"] = exports['geo-inventory']:GetItemName("armor_vest"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"leather", 4, exports['geo-inventory']:GetItemName("hide_animal")},
        },
        ["Level"] = 3,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 80,
        ["Durability"] = 40,
    },
}

Crafting.Lists.Chef = {
    {
        ["Item"] = 'sandwich_deluxe',
        ["Name"] = exports['geo-inventory']:GetItemName("sandwich_deluxe"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"wheat", 4, exports['geo-inventory']:GetItemName("wheat")},
            {"tomato", 2, exports['geo-inventory']:GetItemName("tomato")},
            {"meat_pig", 2, exports['geo-inventory']:GetItemName("meat_pig")},
        },
        ["Level"] = 1,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 80,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'flour',
        ["Name"] = exports['geo-inventory']:GetItemName("flour"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"wheat", 4, exports['geo-inventory']:GetItemName("wheat")},
        },
        ["Level"] = 1,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 80,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'sauce_tomato',
        ["Name"] = exports['geo-inventory']:GetItemName("sauce_tomato"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"tomato", 3, exports['geo-inventory']:GetItemName("tomato")},
        },
        ["Level"] = 2,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 80,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'bread',
        ["Name"] = exports['geo-inventory']:GetItemName("bread"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"wheat", 8, exports['geo-inventory']:GetItemName("wheat")},
        },
        ["Level"] = 2,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 80,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'pancake',
        ["Name"] = exports['geo-inventory']:GetItemName("pancake"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"flour", 2, exports['geo-inventory']:GetItemName("flour")},
        },
        ["Level"] = 3,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 80,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'frenchfries',
        ["Name"] = exports['geo-inventory']:GetItemName("frenchfries"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"potato", 4, exports['geo-inventory']:GetItemName("potato")},
            {"salt", 2, exports['geo-inventory']:GetItemName("salt")},
        },
        ["Level"] = 3,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 80,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'pancake_deluxe',
        ["Name"] = exports['geo-inventory']:GetItemName("pancake_deluxe"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"pancake", 2, exports['geo-inventory']:GetItemName("pancake")},
            {"syrup_maple", 2, exports['geo-inventory']:GetItemName("syrup_maple")},
        },
        ["Level"] = 5,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 80,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'frenchfries_deluxe',
        ["Name"] = exports['geo-inventory']:GetItemName("frenchfries_deluxe"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"frenchfries", 2, exports['geo-inventory']:GetItemName("frenchfries")},
            {"sauce_tomato", 2, exports['geo-inventory']:GetItemName("sauce_tomato")},
        },
        ["Level"] = 7,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 80,
        ["Durability"] = 40,
    },
    {
        ["Item"] = 'omelette',
        ["Name"] = exports['geo-inventory']:GetItemName("omelette"),
        ["Amount"] = 1,
        ["Requirements"] = {
            {"egg", 2, exports['geo-inventory']:GetItemName("egg")},
            {"meat_pig", 2, exports['geo-inventory']:GetItemName("meat_pig")},
        },
        ["Level"] = 7,
        ["CraftsmanshipMin"] = 100,
        ["Craftsmanship"] = 40,
        ["ControlMin"] = 0,
        ["Control"] = 80,
        ["Durability"] = 40,
    },
}

for k,v in pairs(Crafting.Lists) do
    table.sort(v, function(a, b)
        return a.Level < b.Level
    end)
end