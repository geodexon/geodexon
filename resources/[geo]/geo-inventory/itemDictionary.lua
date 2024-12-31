Inventories = {}

for k,v in pairs(Sizes) do
    Inventories[k] = {}
end

hidden = New(Inventories)

inventoryLocations = {
    ['Capital Hill Fire Station'] = {Name = 'Capital Fire Station', Pos = vector3(1209.32, -1480.79, 34.86), Guilds = {{'EMS', 100}}},
    ['Paleto Fire'] = {Name = 'Paleto Fire', Pos = vector3(-380.07, 6087.27, 31.6), Guilds = {{'EMS', 100}}},
}

exports('AddLocation', function(id, name, pos, guilds)
    inventoryLocations[id] = {Name = name, Pos = pos, Guilds = guilds or {}, dist = false}
end)

local customData = {
    ['carbine'] = {CurrentAmmo = 0, Ammo = 'ammo_556'},
    ['c4'] = {CurrentAmmo = 5, Ammo = 'ammo_556'},
    ['pistol'] = {CurrentAmmo = 0, Ammo = 'ammo_9mm'},
    ['pistol_mk2'] = {CurrentAmmo = 0, Ammo = 'ammo_9mm'},
    ['combat_pistol'] = {CurrentAmmo = 0, Ammo = 'ammo_9mm'},
    ['pump_shotgun'] = {CurrentAmmo = 0, Ammo = 'ammo_12g'},
    ['beanbag'] = {CurrentAmmo = 0, Ammo = 'ammo_taser'},
    ['extinguisher'] = {CurrentAmmo = 36400},
    ['huntingrifle'] = {CurrentAmmo = 0, Ammo = 'ammo_9mm', Mods = {0x4032B5E7}},
    ['huntingrifle_gold'] = {CurrentAmmo = 0, Ammo = 'ammo_9mm'},
}

items = {
    ['dollar'] = {Name = 'Dollar', Weight = 0, max = 5000,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'dollar', ID = 'dollar'},
    ['box'] = {Life = 60, Name = 'Box', Decay = 43200,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'box', ID = 'box'},
    ['lockpick'] = {Name = 'Lockpick', Decay = 1209600, Weight = 100, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'lockpick', ID = 'lockpick'},
    ['lockpick_adv'] = {Name = 'Advanced Lockpick', Decay = 2419200, Weight = 100, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'lockpick_adv', ID = 'lockpick_adv'},
    ['lockpick_flimsy'] = {Name = 'Flimsy Lockpick', Weight = 50, Amount = 1, BreakChance = 20, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'lockpick_flimsy', ID = 'lockpick_flimsy'},
    ['dolly'] = {Name = 'Dolly', Amount = 1, Data = {}, Decay = 43200, Weapon = false, Consumable = false, Stackable = true, Key = 'dolly', ID = 'dolly'},
    ['repair_kit'] = {Name = 'Repair Kit', Weight = 5000, Decay = 2592000, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'repair_kit', ID = 'repair_kit'},
    ['repair_kit_adv'] = {Name = 'Advanced Repair Kit', Weight = 5000, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'repair_kit_adv', ID = 'repair_kit_adv'},
    ['binoculars'] = {Name = 'Binoculars',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'binoculars', ID = 'binoculars'},

    ['ammo_556'] = {Name = '5.56mm',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'ammo_556', ID = 'ammo_556'},
    ['ammo_9mm'] = {Name = '9mm',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'ammo_9mm', ID = 'ammo_9mm'},
    ['ammo_12g'] = {Name = '12 Gauge',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'ammo_12g', ID = 'ammo_12g'},
    ['ammo_flare'] = {Name = 'Flare Pocket',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'ammo_flare', ID = 'ammo_flare'},
    ['ammo_taser'] = {Name = 'Taser Cartridge',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'ammo_taser', ID = 'ammo_taser'},

    -- Weapons
    ['pistol'] = {Deteriorate = 0.5, Repair = {{"ingot_iron", 4}}, Decay = 2592000, Weight = 2000, Name = 'Pistol',   Amount = 1, Data = New(customData['pistol']), Weapon = 'WEAPON_PISTOL', Consumable = false, Stackable = false, Key = 'pistol'},
    ['pistol_mk2'] = {Deteriorate = 0.5, Repair = {{"ingot_iron", 4}}, Weight = 2000, Name = 'Pistol Mk II',   Amount = 1, Data = New(customData['pistol_mk2']), Weapon = 'WEAPON_PISTOL_MK2', Consumable = false, Stackable = false, Key = 'pistol_mk2'},
    ['combat_pistol'] = {Deteriorate = 0.5, Repair = {{"ingot_iron", 4}}, Weight = 2000, Name = 'Combat Pistol',   Amount = 1, Data = New(customData['combat_pistol']), Weapon = 'WEAPON_COMBATPISTOL', Consumable = false, Stackable = false, Key = 'combat_pistol'},
    ['combat_pistol_lspd'] = {Deteriorate = 0.5,  Description = 'LSPD Issue', DefaultTint = 14 , Repair = {{"ingot_iron", 4}}, Weight = 2000, Name = 'Combat Pistol',   Amount = 1, Data = New(customData['combat_pistol']), Weapon = 'WEAPON_PISTOL_MK2', Consumable = false, Stackable = false, Key = 'combat_pistol_lspd'},
    ['revolver'] = {Deteriorate = 0.5, Repair = {{"ingot_iron", 4}}, Weight = 2000, Name = 'Revolver',   Amount = 1, Data = New(customData['pistol']), Weapon = 'WEAPON_REVOLVER', Consumable = false, Stackable = false, Key = 'revolver'},
    ['sns'] = {Deteriorate = 0.5, Repair = {{"ingot_iron", 4}}, Weight = 2000, Name = 'SNS Pistol',   Amount = 1, Data = New(customData['pistol']), Weapon = 'WEAPON_SNSPISTOL', Consumable = false, Stackable = false, Key = 'sns'},
    ['vintage'] = {Deteriorate = 0.5, Repair = {{"ingot_iron", 4}}, Weight = 2000, Name = 'Vintage Pistol',   Amount = 1, Data = New(customData['pistol']), Weapon = 'WEAPON_VINTAGEPISTOL', Consumable = false, Stackable = false, Key = 'vintage'},
    ['crowbar'] = {Name = 'crowbar', Repair = {{"ingot_iron", 4}}, Weight = 2500,  Amount = 1, Data = {}, Weapon = 'WEAPON_CROWBAR', Consumable = false, Stackable = false, Key = 'crowbar'},
    ['gascan'] = {Name = 'Gas Can', Repair = {{"ingot_iron", 4}}, Weight = 10000,  Amount = 1, Data = {CurrentAmmo = 9999999}, Weapon = 'WEAPON_PETROLCAN', Consumable = false, Stackable = false, Key = 'gascan'},
    ['flare'] = {Name = 'Flare', Repair = {{"ingot_iron", 4}}, Weight = 2000, Amount = 1, Data = {CurrentAmmo = 5, Ammo = 'ammo_flare'}, Weapon = 'WEAPON_FLARE', Consumable = false, Stackable = false, Key = 'flare'},
    ['bottle'] = {Name = 'Bottle', Repair = {{"ingot_iron", 4}}, Weight = 1000, Decay = 604800,  Amount = 1, Data = {}, Weapon = 'WEAPON_BOTTLE', Consumable = false, Stackable = false, Key = 'bottle'},
    ['snowball'] = {Name = 'snowball', Decay = 3600, Repair = {{"ingot_iron", 4}}, Weight = 100, Amount = 1, Data = {}, Weapon = 'WEAPON_SNOWBALL', Consumable = false, Stackable = true, Key = 'snowball', ID = 'snowball'},
    ['bat_maple'] = {Name = 'Maple Bat', Decay = 2592000, Weight = 1000, Amount = 1, Data = {}, Weapon = 'WEAPON_BAT', Consumable = false, Stackable = false, Key = 'bat_maple'},

    ['carbine'] = {Deteriorate = 0.5, Weight = 3000, Name = 'Carbine',   Amount = 1, Data = New(customData['carbine']), Weapon = 'WEAPON_CARBINERIFLE', Consumable = false, Stackable = false, Key = 'carbine'},
    ['knife'] = {Name = 'Knife', Weight = 1000, Amount = 1, Equippable = 'Main Hand', Skill = 'Leatherworker', Data = {Durability = 100, Crafting = 100, Control = 100}, Weapon = 'WEAPON_KNIFE', Consumable = false, Stackable = false, Key = 'knife'},
    ['switchblade'] = {Name = 'Switch Blade', Weight = 1000, Amount = 1, Data = {}, Weapon = 'WEAPON_SWITCHBLADE', Consumable = false, Stackable = false, Key = 'switchblade'},
    ['taser'] = {Name = 'Taser',  Weight = 2000, Amount = 1, Data = {Ammo = 'ammo_taser', CurrentAmmo = 3}, Weapon = 'WEAPON_PDSTUN', Consumable = false, Stackable = false, Key = 'taser'},
    ['nightstick'] = {Name = 'Nightstick', Weight = 1000,  Amount = 1, Data = {}, Weapon = 'WEAPON_NIGHTSTICK', Consumable = false, Stackable = false, Key = 'nightstick'},
    ['flashlight'] = {Name = 'Flashlight', Weight = 1000, Amount = 1, Data = {}, Weapon = 'WEAPON_FLASHLIGHT', Consumable = false, Stackable = false, Key = 'flashlight'},
    ['pump_shotgun'] = {Deteriorate = 0.5, Weight = 5000, Name = 'Pump Shotgun',   Amount = 1, Data = New(customData['pump_shotgun']), Weapon = 'WEAPON_PUMPSHOTGUN', Consumable = false, Stackable = false, Key = 'pump_shotgun'},
    ['beanbag'] = {Deteriorate = 0.5, DefaultTint = 1, Weight = 5000, Name = 'Beanbag Shotgun',   Amount = 1, Data = New(customData['beanbag']), Weapon = 'WEAPON_BEANBAG', Consumable = false, Stackable = false, Key = 'beanbag'},
    ['extinguisher'] = {Name = 'Fire Extinguisher', Weight = 7500, Amount = 1, Data = New(customData['extinguisher']), Weapon = 'WEAPON_FIREEXTINGUISHER', Consumable = false, Stackable = false, Key = 'extinguisher'},
    ['armor'] = {Name = 'Armor', Amount = 1, Weight = 10000, Repair = {{'ingot_steel', 10}}, Equippable = 'Armor', Data = {Armor = 100}, Consumable = false, Stackable = false, MaxArmor = 100, Key = 'armor'},
    ['lightarmor'] = {Name = 'Light Armor', Amount = 1, Weight = 7500, Repair = {{'ingot_steel', 5}}, Equippable = 'Armor', Data = {Armor = 50}, Consumable = false, Stackable = false, MaxArmor = 50, Key = 'lightarmor'},
    ['armor_vest'] = {Name = 'Armor Vest', Weight = 1000, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'armor_vest', ID = 'armor_vest'},

    ['evidence_bullet'] = {Name = 'Evidence (Casing)', Amount = 1, Data = {}, Consumable = false, Stackable = false, Key = 'evidence_bullet'},
    ['evidence_blood'] = {Name = 'Evidence (Blood)', Amount = 1, Data = {}, Consumable = false, Stackable = false, Key = 'evidence_blood'},

    ['evidencebag'] = {Name = 'Evidence Bag', Amount = 1, Data = {}, Consumable = false, Stackable = false, Close = false, Key = 'evidencebag'},

    ['c4'] = {Deteriorate = 0.5, Weight = 3000, Name = 'C4', Amount = 1, Data = {}, Weapon = 'WEAPON_STICKYBOMB', Consumable = false, Stackable = true, Key = 'c4'},
    ['rpg'] = {Deteriorate = 0.5, Weight = 3000, Name = 'RPG',   Amount = 1, Data = New(customData['c4']), Weapon = 'WEAPON_RPG', Consumable = false, Stackable = false, Key = 'rpg'},


    -- Hunting
    ['meat_deer'] = {Name = 'Deer Meat',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'meat_deer', ID = 'meat_deer'},
    ['meat_coyote'] = {Name = 'Coyote Meat', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'meat_coyote', ID = 'meat_coyote'},
    ['meat_mtlion'] = {Name = 'Mountain Lion Meat', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'meat_mtlion', ID = 'meat_mtlion'},
    ['meat_pig'] = {Name = 'Pig Meat', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'meat_pig', ID = 'meat_pig'},
    ['meat_cow'] = {Name = 'Cow Meat', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'meat_cow', ID = 'meat_cow'},
    ['leather'] = {Name = 'Leather', Weight = 500, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'leather', ID = 'leather'},
    ['hide_animal'] = {Name = 'Animal Hide', Weight = 500, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'hide_animal', ID = 'hide_animal'},


    --Drugs
    ['weed_1g'] = {Name = 'Weed (1g)', Decay = 604800, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'weed_1g', ID = 'weed_1g'},
    ['weed_seed'] = {Name = 'Weed Seed', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'weed_seed', ID = 'weed_seed'},
    ['oxy'] = {Name = 'Oxycodone', Decay = 604800, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'oxy', ID = 'oxy'},

    -- Guilds
    ['keycard_blank'] = {Name = 'Blank Keycard',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'keycard_blank', ID = 'keycard_blank'},
    ['keycard'] = {Name = 'Keycard',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = false, Key = 'keycard'},

    ['guild_token'] = {Name = 'Guild Token', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'guild_token', ID = 'guild_token'},
    ['vehicle_token'] = {Name = 'Vehicle Token', Rarity = 'ultrarare',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'vehicle_token', ID = 'vehicle_token'},

    -- Keycards
    ['keycard_green'] = {Name = 'Keycard', Description = 'Marked for Police Seizure',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = false, Key = 'keycard_green'},
    ['keycard_red'] = {Name = 'Keycard', Description = 'Marked for Police Seizure',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'keycard_red', ID = 'keycard_red'},

    ['bandage'] = {Name = 'Bandage', Weight = 1000,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'bandage', ID = 'bandage'},
    ['ifak'] = {Name = 'IFAK', Weight = 1000, Decay = 259200, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'ifak', ID = 'ifak'},
    ['cigar'] = {Name = 'Cigar',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'cigar', ID = 'cigar'},
    ['egochaser'] = {Name = 'Egochaser',  Food = 10, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'egochaser', ID = 'egochaser'},
    ['meteorite'] = {Name = 'Meteorite', Food = 10, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'meteorite', ID = 'meteorite'},
    ['pisswasser'] = {BAC = 0.01, Water = 10, Name = 'Pisswasser',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'pisswasser', ID = 'pisswasser'},
    ['redwood'] = {Name = 'Redwoods',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'redwood', ID = 'redwood'},
    ['wine'] = {BAC = 0.03, Water = 10, Name = 'Wine',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'wine', ID = 'wine'},
    ['water'] = {Water = 50, Decay = 345600, Name = 'Water',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'water', ID = 'water'},
    ['sandwich'] = {Food = 10, Decay = 172800, Name = 'Sandwich',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'sandwich', ID = 'sandwich'},
    ['sandwich_deluxe'] = {Food = 20, Decay = 345600, Name = 'Deluxe Sandwich',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'sandwich_deluxe', ID = 'sandwich_deluxe'},
    ['radio'] = {Name = 'Radio', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'radio', ID = 'radio'},


    -- Props
    ['cone'] = {Name = 'Traffic Cone',  Prop = 'prop_roadcone01a', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'cone', ID = 'cone'},
    ['barrier'] = {Name = 'Traffic Barrier',  Prop = 'prop_mp_barrier_02b', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'barrier', ID = 'barrier'},
    ['medbag'] = {Name = 'Medical Bag',  Prop = 'xm_prop_x17_bag_med_01a', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'medbag', ID = 'medbag'},
    ['work_light'] = {Name = 'Work Light',  Prop = 'prop_worklight_03a', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'work_light', ID = 'work_light'},

    -- ES
    ['breathalyzer'] = {Name = 'Breathalyzer',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'breathalyzer', ID = 'breathalyzer'},
    ['gsr'] = {Name = 'GSR',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'gsr', ID = 'gsr'},
    ['donut'] = {Name = 'Donut',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'donut', ID = 'donut'},

    ['plasma_cutter'] = {Name = 'Plasma Cutter',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = false, Key = 'plasma_cutter'},
    ['pain_killer'] = {Name = 'Pain Killer',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'pain_killer', ID = 'pain_killer'},


    --Jobs
    ['propane_torch'] = {Rarity = 'Uncommon', Name = 'Propane Torch', max = 1, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'propane_torch', ID = 'propane_torch'},
    ['burner_phone'] = {Rarity = 'Uncommon', Name = 'Burner Phone', max = 1, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'burner_phone', ID = 'burner_phone'},


    -- Vangelico
    ['rolex'] = {Name = 'Rolex', Value = 20,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'rolex', ID = 'rolex'},
    ['goldchain'] = {Name = 'Gold Chain', Value = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'goldchain', ID = 'goldchain'},
    ['10kgoldchain'] = {Name = '10k Gold Chain', Value = 250, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = '10kgoldchain', ID = '10kgoldchain'},
    ['diamond'] = {Name = 'Diamond', Value = 500,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'diamond', ID = 'diamond'},
    ['painting'] = {Name = 'Painting', Value = 100,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'painting', ID = 'painting'},
    ['vandiamond'] = {Name = 'Vangelico Diamond', Value = 250, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'vandiamond', ID = 'vandiamond'},
    ['panther'] = {Name = 'Vintage Phanter', Value = 250, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'panther', ID = 'panther'},
    ['necklace'] = {Name = 'Vangelico Necklace', Value = 250, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'necklace', ID = 'necklace'},
    ['vanbottle'] = {Name = 'Vangelico Bottle', Value = 250, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'vanbottle', ID = 'vanbottle'},
    ['thermite'] = {Name = 'Thermite',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'thermite', ID = 'thermite'},

    -- Ingredients
    ['packaged_fruit'] = {Name = 'Packaged Fruit',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'packaged_fruit', ID = 'packaged_fruit'},
    ['packaged_vegetables'] = {Name = 'Packaged Vegetables',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'packaged_vegetables', ID = 'packaged_vegetables'},
    ['packaged_meat'] = {Name = 'Packaged Meat',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'packaged_meat', ID = 'packaged_meat'},
    ['packaged_fish'] = {Name = 'Packaged Fish',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'packaged_fish', ID = 'packaged_fish'},
    ['packaged_cheese'] = {Name = 'Packaged Cheese',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'packaged_cheese', ID = 'packaged_cheese'},
    ['packaged_deserts'] = {Name = 'Packaged Deserts',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'packaged_deserts', ID = 'packaged_deserts'},

    ['frenchfries_uncooked'] = {Name = 'French Fries (Uncooked)',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'frenchfries_uncooked', ID = 'frenchfries_uncooked'},
    ['biscuit'] = {Name = 'Biscuit',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'biscuit', ID = 'biscuit'},
    ['noodles'] = {Name = 'Noodles',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'noodles', ID = 'noodles'},

    --Resturant Food
    ['cheddarbiscuit'] = {Name = 'Cheddar Biscuit ', Food = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'cheddarbiscuit', ID = 'cheddarbiscuit'},
    ['loadedpotato'] = {Name = 'Loaded Baked Potato ', Food = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'loadedpotato', ID = 'loadedpotato'},
    ['frenchfries'] = {Name = 'French Fries', Food = 30,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'frenchfries', ID = 'frenchfries'},
    ['choclava'] = {Name = 'Chocolate Lava Cake', Food = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'choclava', ID = 'choclava'},
    ['nycheesecake'] = {Name = 'New York Cheesecake', Food = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'nycheesecake', ID = 'nycheesecake'},
    ['pearlsbrownie'] = {Name = 'Brownie Overload', Food = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'pearlsbrownie', ID = 'pearlsbrownie'},

    ['calamari'] = {Name = 'Calamari', Food = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'calamari', ID = 'calamari'},
    ['crabrangoon'] = {Name = 'Crab Rangoon', Food = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'crabrangoon', ID = 'crabrangoon'},
    ['garlicmusels'] = {Name = 'Garlic Mussells', Food = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'garlicmusels', ID = 'garlicmusels'},
    ['coconutshrimp'] = {Name = 'Coconut Shrimp', Food = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'coconutshrimp', ID = 'coconutshrimp'},

    ['atlanticsalmon'] = {Name = 'Atlantic Salmon', Food = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'atlanticsalmon', ID = 'atlanticsalmon'},
    ['salmonrice'] = {Name = 'Salmon Rice Bowl', Food = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'salmonrice', ID = 'salmonrice'},
    ['shrimplinguini'] = {Name = 'Shrimp Linguine', Food = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'shrimplinguini', ID = 'shrimplinguini'},
    ['octosoup'] = {Name = 'Octopus Soup', Food = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'octosoup', ID = 'octosoup'},
    ['crawfishboil'] = {Name = 'Crawfish Boil', Food = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'crawfishboil', ID = 'crawfishboil'},
    ['pearlssalad'] = {Name = 'House Salad', Food = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'pearlssalad', ID = 'pearlssalad'},

    ['cappuccino'] = {Name = 'Cappuccino', Water = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'cappuccino', ID = 'cappuccino'},
    ['latte_macchiato'] = {Name = 'Latte Macchiato ', Water = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'latte_macchiato', ID = 'latte_macchiato'},
    ['sprunk'] = {Name = 'Sprunk', Water = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'sprunk', ID = 'sprunk'},
    ['drang_o_tang'] = {Name = 'Drang O Tang', Water = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'drang_o_tang', ID = 'drang_o_tang'},
    ['ecola'] = {Name = 'Ecola', Water = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'ecola', ID = 'ecola'},
    ['ecola_light'] = {Name = 'Diet Ecola', Water = 50,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'ecola_light', ID = 'ecola_light'},
    ['ragga_rum'] = {Name = 'Rum', Water = 25,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'ragga_rum', ID = 'ragga_rum'},
    ['cherenkov'] = {Name = 'Cherenkov', Water = 25,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'cherenkov', ID = 'cherenkov'},


    -- Misc
    ['phone'] = {Name = 'Phone',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = false, Key = 'phone'},
    ['forklift_keys'] = {Name = 'Forklift Keys',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'forklift_keys', ID = 'forklift_keys'},
    ['camera'] = {Name = 'Camera',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'camera', ID = 'camera'},
    ['trophy_bronze'] = {Name = 'Bronze Trophy',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = false, Key = 'trophy_bronze', ID = 'trophy_bronze'},

    ['horn_christmas'] = {Name = 'Christmas Horn', Rarity = 'uncommon', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'horn_christmas', ID = 'horn_christmas'},
    ['horn_halloween'] = {Name = 'Halloween Horn', Rarity = 'uncommon', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'horn_halloween', ID = 'horn_halloween'},

    ['plate'] = {Name = 'License Plate', Description = 'Marked for Police Seizure', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'plate', ID = 'plate'},
    ['nos'] = {Name = 'Nitrous', Weight = 25000, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = false, Key = 'nos'},
    ['glass'] = {Name = 'Glass', Weight = 500, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'glass', ID = 'glass'},

    ['free_plate'] = {Name = 'Custom Plate', Rarity = 'Uncommon', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'free_plate', ID = 'free_plate'},

    ['auto_parts'] = {Name = 'Auto Parts', Weight = 1, max = 5000,  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'auto_parts', ID = 'auto_parts'},
    ['hdd'] = {Name = 'HDD',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = false, Key = 'hdd'},
    ['briefcase'] = {Name = 'Briefcase',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = false, Key = 'briefcase'},
    ['inventory_binder'] = {Name = 'Inventory Binder',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = false, Key = 'inventory_binder'},

    ['id'] = {Name = 'ID Card',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = false, Key = 'id'},

    ['mask'] = {Name = 'Mask',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'mask'},
    ['outfit'] = {Name = 'Outfit',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'outfit'},

    ['compass'] = {Name = 'Compass', Repair = {{'ingot_gold', 1}}, Decay = 604800, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = false, Key = 'compass'},
    ['gps'] = {Name = 'GPS Tracker', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'gps', ID = 'gps'},


    --Crafting / Gathering
    ['pickaxe'] = {Name = 'Pickaxe', Equippable = 'Main Hand', Repair = {{'stone', 20}}, Skill = 'Mining', Deteriorate = 0.5,  Amount = 1, Data = {Durability = 100, Gathering = 100, Perception = 20}, Weapon = false, Consumable = false, Stackable = false, Key = 'pickaxe'},
    ['pickaxe_iron_1'] = {Name = 'Reinforced Pickaxe', Equippable = 'Main Hand', Repair = {{'ingot_iron', 5}}, Skill = 'Mining', Deteriorate = 0.5,  Amount = 1, Data = {Durability = 100, Gathering = 140, Perception = 30}, Weapon = false, Consumable = false, Stackable = false, Key = 'pickaxe_iron_1'},

    ['hatchet'] = {Name = 'Hatchet', Equippable = 'Main Hand', Repair = {{'stone', 20}}, Skill = 'Botany', Deteriorate = 0.5,  Amount = 1, Data = {Durability = 100, Gathering = 100, Perception = 20}, Weapon = false, Consumable = false, Stackable = false, Key = 'hatchet'},
    
    ['scythe'] = {Name = 'Scythe', Equippable = 'Off Hand', Repair = {{'stone', 20}}, Skill = 'Botany', Deteriorate = 0.5,  Amount = 1, Data = {Durability = 100, Gathering = 100, Perception = 20}, Weapon = false, Consumable = false, Stackable = false, Key = 'scythe'},

    ['forging_hammer'] = {Name = 'Forging Hammer', Equippable = 'Main Hand', Skill = 'Smelting', Repair = {{'stone', 20}}, Deteriorate = 0.5,  Amount = 1, Data = {Durability = 100, Crafting = 100, Control = 100}, Weapon = false, Consumable = false, Stackable = false, Key = 'forging_hammer'},

    ['saw'] = {Name = 'Saw', Equippable = 'Main Hand', Repair = {{'stone', 20}}, Skill = 'Carpenter', Deteriorate = 0.5,  Amount = 1, Data = {Durability = 100, Crafting = 100, Control = 100}, Weapon = false, Consumable = false, Stackable = false, Key = 'saw'},

    ['skillet'] = {Name = 'Skillet', Equippable = 'Main Hand', Skill = 'Chef', Repair = {{'stone', 20}}, Deteriorate = 0.5,  Amount = 1, Data = {Durability = 100, Crafting = 100, Control = 100}, Weapon = false, Consumable = false, Stackable = false, Key = 'skillet'},

    
    ['stone'] = {Name = 'Stone', Weight = 100, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'stone', ID = 'stone'},
    
    ['ore_iron'] = {Name = 'Iron Ore', Weight = 100, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'ore_iron', ID = 'ore_iron'},
    ['ore_copper'] = {Name = 'Copper Ore', Weight = 150, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'ore_copper', ID = 'ore_copper'},
    ['ore_zinc'] = {Name = 'Zinc Ore', Weight = 100, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'ore_zinc', ID = 'ore_zinc'},

    ['plating_copper'] = {Name = 'Copper Plate', Weight = 200, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'plating_copper', ID = 'plating_copper'},
    ['wire_copper'] = {Name = 'Copper Wire', Weight = 100, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'wire_copper', ID = 'wire_copper'},


    ['branch_maple'] = {Name = 'Maple Branch', Weight = 100, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'branch_maple', ID = 'branch_maple'},

    ['log_maple'] = {Name = 'Maple Log', Weight = 500, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'log_maple', ID = 'log_maple'},

    ['tomato'] = {Name = 'Tomato', Weight = 100, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'tomato', ID = 'tomato'},

    ['seeds_wheat'] = {Name = 'Wheat Seeds', Weight = 10, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'seeds_wheat', ID = 'seeds_wheat'},
    ['wheat'] = {Name = 'Wheat', Weight = 50, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'wheat', ID = 'wheat'},

    ['sand'] = {Name = 'Sand', Weight = 100, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'sand', ID = 'sand'},

    ['ingot_iron'] = {Name = 'Iron Ingot', Weight = 100, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'ingot_iron', ID = 'ingot_iron'},
    ['ingot_bronze'] = {Name = 'Bronze Ingot', Weight = 100, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'ingot_bronze', ID = 'ingot_bronze'},
    ['ingot_steel'] = {Name = 'Steel Ingot', Weight = 100, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'ingot_steel', ID = 'ingot_steel'},
    ['ingot_copper'] = {Name = 'Copper Ingot', Weight = 100, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'ingot_copper', ID = 'ingot_copper'},
    ['ingot_gold'] = {Name = 'Gold Ingot', Weight = 100, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'ingot_gold', ID = 'ingot_gold'},
    ['ingot_brass'] = {Name = 'Brass Ingot', Weight = 200, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'ingot_brass', ID = 'ingot_brass'},

    ['nails_iron'] = {Name = 'Iron Nails', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'nails_iron', ID = 'nails_iron'},

    ['rod_maple'] = {Name = 'Maple Rod', Weight = 100, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'rod_maple', ID = 'rod_maple'},

    ['lumber_maple'] = {Name = 'Maple Lumber', Weight = 500, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'lumber_maple', ID = 'lumber_maple'},

    ['syrup_maple'] = {Name = 'Maple Syrup', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'syrup_maple', ID = 'syrup_maple'},

    ['egg'] = {Name = 'Egg', Weight = 10, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'egg', ID = 'egg'},
    ['omelette'] = {Name = 'Omelette', Food = 40, Weight = 10, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'omelette', ID = 'omelette'},

    ['flour'] = {Name = 'Flour', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'flour', ID = 'flour'},
    ['salt'] = {Name = 'Salt', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'salt', ID = 'salt'},

    ['pancake'] = {Food = 10, Decay = 345600, Name = 'Pancakes',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'pancake', ID = 'pancake'},
    ['pancake_deluxe'] = {Food = 30, Decay = 345600, Name = 'Deluxe Pancakes',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'pancake_deluxe', ID = 'pancake_deluxe'},
    ['potato'] = {Food = 5, Decay = 345600, Name = 'Potato',  Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'potato', ID = 'potato'},
    ['sauce_tomato'] = {Name = 'Tomato Sauce', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'sauce_tomato', ID = 'sauce_tomato'},
    ['frenchfries_deluxe'] = {Name = 'Deluxe French Fries', Food = 50, Decay = 345600, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'frenchfries_deluxe', ID = 'frenchfries_deluxe'},
    ['bread'] = {Name = 'Bread', Food = 10, Decay = 345600, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'bread', ID = 'bread'},


    --Events
    ['bone'] = {Name = 'Bone', Amount = 1, Description = "It's pretty humorous", Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'bone', ID = 'bone'},
    ['tint_halloween'] = {Name = 'Halloween Weapon Tint',  Soulbound = true, Deteriorate = 5, Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = false, Key = 'tint_halloween', ID = 'tint_halloween'},
    ['jack'] = {Name = 'Old Jack', Soulbound = true, Rarity = 'uncommon', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = false, Key = 'jack', ID = 'jack'},
    ['skeletonchalice'] = {Name = 'Skeleton Chalice', Description = 'At your greatest time of need, summon the power of skeletons to aid you', Rarity = 'uncommon', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'skeletonchalice', ID = 'skeletonchalice'},
    ['skullcrusher'] = {Deteriorate = 0.05, Soulbound = true, Rarity = 'rare', Repair = {{"ingot_iron", 4}}, Weight = 2000, Name = 'Skull Crusher',   Amount = 1, Data = New(customData['pistol']), Weapon = 'WEAPON_SKULLCRUSHER', Consumable = false, Stackable = false, Key = 'skullcrusher'},
    ['huntingrifle'] = {Deteriorate = 0.05, DefaultTint = 4, Hunting = true, Repair = {{"ingot_bronze", 4}}, Weight = 5000, Name = 'Hunting Rifle', Amount = 1, Data = New(customData['huntingrifle']), Weapon = 'WEAPON_SNIPERRIFLE', Consumable = false, Stackable = false, Key = 'huntingrifle'},
    ['huntingrifle_gold'] = {Deteriorate = 0.05, DefaultTint = 2, Hunting = true, Repair = {{"ingot_bronze", 4}}, Weight = 5000, Name = 'Golden Hunting Rifle', Amount = 1, Data = New(customData['huntingrifle_gold']), Weapon = 'WEAPON_SNIPERRIFLE', Consumable = false, Stackable = false, Key = 'huntingrifle_gold'},

    ['feather_turkey'] = {Name = 'Turkey Feather', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'feather_turkey', ID = 'feather_turkey'},
    ['feather_turkey_gold'] = {Name = 'Golden Turkey Feather', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'feather_turkey_gold', ID = 'feather_turkey_gold'},

    ['eventtoken'] = {Name = 'Event Token', Amount = 1, Data = {}, Weapon = false, Consumable = false, Stackable = true, Key = 'eventtoken', ID = 'eventtoken'},
}

local addonItems = {
}


local newItems = 0
for k,v in pairs(addonItems) do
    items[k] = v
    newItems = newItems + 1
end

print(newItems)

local nl = {}
for k,v in pairs(items) do
    nl[k] = v
end

for k,v in pairs(nl) do
    local item = New(v)
    item.HQ = item.Key

    if item.Key == 'dollar' then
        item.Description = 'Not Legal Tender'
    end

    item.Key = item.Key..'_hq'
    if item.ID then
        item.ID = item.ID..'_hq'
    end

    if item.Data.Gathering then
        item.Data.Gathering = math.floor(item.Data.Gathering * 1.2)
    end

    if item.Data.Crafting then
        item.Data.Crafting = math.floor(item.Data.Crafting * 1.2)
        item.Data.Control = math.floor(item.Data.Control * 1.2)
    end

    if item.Repair then
        for k,v in pairs(item.Repair) do
            v[2] = math.floor(v[2] * 1.5)
        end
    end

    item.Name = item.Name..' (HQ)'
    items[item.Key] = item
end

desc = {
}

breaksInto = {
    ['dollar'] = {{'dollar', 1}}
}

weaponMods = {
    -- Pistols
    ['WEAPON_PISTOL'] = {
        ['ExtendedClip'] = {Hash = 0xED265A1C, Item = 'extended_clip', Name = 'Extended Clip'},
        ['Flashlight'] = {Hash = 0x359B7AAE, Item = 'flashlight', Name = 'Flashlight'},
        ['Surpressor'] = {Hash = 0x65EA7EBB, Item = 'suppressor', Name = 'Surpressor'},
        ['Halloween Tint'] = {NoConsume = true, Hash = '6', Item = 'tint_halloween', Name = 'Halloween Tint'},
    },

    ['WEAPON_PISTOL_MK2'] = {
        ['ExtendedClip'] = {Hash = 0x5ED6C128, Item = 'extended_clip', Name = 'Extended Clip'},
        ['Flashlight'] = {Hash = 0x43FD595B, Item = 'flashlight', Name = 'Flashlight'},
        ['Surpressor'] = {Hash = 0x65EA7EBB, Item = 'suppressor', Name = 'Surpressor'},
        ['Halloween Tint'] = {NoConsume = true, Hash = '12', Item = 'tint_halloween', Name = 'Halloween Tint'},
    },

    ['WEAPON_COMBATPISTOL'] = {
        ['ExtendedClip'] = {Hash = 0xD67B4F2D, Item = 'extended_clip', Name = 'Extended Clip'},
        ['Flashlight'] = {Hash = 0x359B7AAE, Item = 'flashlight', Name = 'Flashlight'},
        ['Surpressor'] = {Hash = 0xC304849A, Item = 'suppressor', Name = 'Surpressor'},
        ['Halloween Tint'] = {NoConsume = true, Hash = '6', Item = 'tint_halloween', Name = 'Halloween Tint'},
    },
    ['WEAPON_APPISTOL'] = {
        ['ExtendedClip'] = {Hash = 0x249A17D5, Item = 'extended_clip', Name = 'Extended Clip'},
        ['Flashlight'] = {Hash = 0x359B7AAE, Item = 'flashlight', Name = 'Flashlight'},
        ['Surpressor'] = {Hash = 0xC304849A, Item = 'suppressor', Name = 'Surpressor'},
        ['Halloween Tint'] = {NoConsume = true, Hash = '6', Item = 'tint_halloween', Name = 'Halloween Tint'},
    },
    ['WEAPON_PISTOL50'] = {
        ['ExtendedClip'] = {Hash = 0xD9D3AC92, Item = 'extended_clip', Name = 'Extended Clip'},
        ['Flashlight'] = {Hash = 0x359B7AAE, Item = 'flashlight', Name = 'Flashlight'},
        ['Surpressor'] = {Hash = 0xA73D4664, Item = 'suppressor', Name = 'Surpressor'},
        ['Halloween Tint'] = {NoConsume = true, Hash = '6', Item = 'tint_halloween', Name = 'Halloween Tint'},
    },
    ['WEAPON_HEAVYPISTOL'] = {
        ['ExtendedClip'] = {Hash = 0x64F9C62B, Item = 'extended_clip', Name = 'Extended Clip'},
        ['Flashlight'] = {Hash = 0x359B7AAE, Item = 'flashlight', Name = 'Flashlight'},
        ['Surpressor'] = {Hash = 0xC304849A, Item = 'suppressor', Name = 'Surpressor'},
        ['Halloween Tint'] = {NoConsume = true, Hash = '6', Item = 'tint_halloween', Name = 'Halloween Tint'},
    },
    ['WEAPON_HEAVYREVOLVER'] = {
        ['ExtendedClip'] = {Hash = 0x64F9C62B, Item = 'extended_clip', Name = 'Extended Clip'},
        ['Flashlight'] = {Hash = 0x359B7AAE, Item = 'flashlight', Name = 'Flashlight'},
        ['Surpressor'] = {Hash = 0xC304849A, Item = 'suppressor', Name = 'Surpressor'},
        ['Halloween Tint'] = {NoConsume = true, Hash = '6', Item = 'tint_halloween', Name = 'Halloween Tint'},
    },
    ['WEAPON_SNSPISTOL'] = {
        ['ExtendedClip'] = {Hash = 0x7B0033B3, Item = 'extended_clip', Name = 'Extended Clip'},
        ['Halloween Tint'] = {NoConsume = true, Hash = '6', Item = 'tint_halloween', Name = 'Halloween Tint'},
    },
    ['WEAPON_VINTAGEPISTOL'] = {
        ['ExtendedClip'] = {Hash = 0x33BA12E8, Item = 'extended_clip', Name = 'Extended Clip'},
        ['Surpressor'] = {Hash = 0xC304849A, Item = 'suppressor', Name = 'Surpressor'},
        ['Halloween Tint'] = {NoConsume = true, Hash = '6', Item = 'tint_halloween', Name = 'Halloween Tint'},
    },

    ['WEAPON_SKULLCRUSHER'] = {
        ['ExtendedClip'] = {Hash = 0xED265A1C, Item = 'extended_clip', Name = 'Extended Clip'},
        ['Flashlight'] = {Hash = 0x359B7AAE, Item = 'flashlight', Name = 'Flashlight'},
        ['Surpressor'] = {Hash = 0x65EA7EBB, Item = 'suppressor', Name = 'Surpressor'},
    },

    -- ARs
    ['WEAPON_CARBINERIFLE'] = {
        ['ExtendedClip'] = {Hash = 0x91109691, Item = 'extended_clip_ar', Name = 'Extended Clip'},
        ['Surpressor'] = {Hash = 0x837445AA, Item = 'suppressor', Name = 'Surpressor'},
        ['Flashlight'] = {Hash = 0x7BC4CDDC, Item = 'flashlight', Name = 'Flashlight'},
        ['Scope'] = {Hash = 0xA0D89C42, Item = 'scope', Name = 'Scope'},
        ['Grip'] = {Hash = 0xC164F53, Item = 'grip', Name = 'Grip'},
        ['Halloween Tint'] = {NoConsume = true, Hash = '6', Item = 'tint_halloween', Name = 'Halloween Tint'},
    },

    -- Shotgun
    ['WEAPON_PUMPSHOTGUN'] = {
        ['Surpressor'] = {Hash = 0xE608B35E, Item = 'suppressor', Name = 'Surpressor'},
        ['Flashlight'] = {Hash = 0x7BC4CDDC, Item = 'flashlight', Name = 'Flashlight'},
        ['Halloween Tint'] = {NoConsume = true, Hash = '6', Item = 'tint_halloween', Name = 'Halloween Tint'},
    },

    ['WEAPON_PDSTUN'] = {
        ['Halloween Tint'] = {NoConsume = true, Hash = '6', Item = 'tint_halloween', Name = 'Halloween Tint'},
    },

    ['WEAPON_BEANBAG'] = {
        ['Halloween Tint'] = {NoConsume = true, Hash = '6', Item = 'tint_halloween', Name = 'Halloween Tint'},
        ['Surpressor'] = {Hash = 0xE608B35E, Item = 'suppressor', Name = 'Surpressor'},
    },
}


exports('Module', function()
    local obj = {}
    obj.Items = items
    return obj
end)