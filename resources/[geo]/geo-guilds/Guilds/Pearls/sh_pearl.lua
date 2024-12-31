CreateThread(function()
    Wait(1000)
    exports['geo-inventory']:AddLocation('Pearls', "Pearl's Seafood", vector3(-1844.31, -1198.68, 14.31), {{'PERL', 100}})
    exports['geo-inventory']:AddLocation('PearlsSafe', "Pearl's Safe", vector3(-1843.19, -1184.11, 14.31), {{'PERL', 1000}})
    exports['geo-inventory']:AddLocation('PearlsDrinks', "Fridge", vector3(-1843.19, -1184.11, 14.31), {{'PERL', 100}})
end)

Pearls = {
    Supplies = {
        {'packaged_fruit', 5},
        {'packaged_vegetables', 5},
        {'packaged_meat', 5},
        {'packaged_fish', 5},
        {'packaged_cheese', 5},
        {'packaged_deserts', 5},
        {'cappuccino', 5},
        {'latte_macchiato', 5},
        {'sprunk', 5},
        {'drang_o_tang', 5},
        {'ecola', 5},
        {'ecola_light', 5},
        {'ragga_rum', 5},
        {'cherenkov', 5},
    },
    CuttingBoard = {
        {
            product = 'frenchfries_uncooked',
            items = {
                {'packaged_vegetables', 1},
            },
        },
        {
            product = 'biscuit',
            items = {
                {'packaged_vegetables', 3},
            },
        },
        {
            product = 'noodles',
            items = {
                {'packaged_vegetables', 2},
            },
        },
        {
            product = 'pearlssalad',
            items = {
                {'packaged_vegetables', 4},
                {'packaged_fruit', 2}
            },
        }
    },
    Fryer = {
        {
            product = 'frenchfries',
            items = {
                {'frenchfries_uncooked', 1},
            },
        },
        {
            product = 'cheddarbiscuit',
            items = {
                {'biscuit', 1},
                {'packaged_cheese', 1}
            },
        },
        {
            product = 'loadedpotato',
            items = {
                {'biscuit', 1},
                {'packaged_cheese', 3},

            },
        },
    },
    Stove = {
        {
            product = 'calamari',
            items = {
                {'packaged_fish', 2},
            },
        },
        {
            product = 'crabrangoon',
            items = {
                {'packaged_fish', 3},
            },
        },
        {
            product = 'garlicmusels',
            items = {
                {'packaged_fish', 2},
                {'packaged_vegetables', 2},
            },
        },
        {
            product = 'coconutshrimp',
            items = {
                {'packaged_fish', 3},
                {'packaged_fruit', 4},
            },
        },
    },
    Range = {
        {
            product = 'atlanticsalmon',
            items = {
                {'packaged_fish', 4},
                {'packaged_vegetables', 3},
            },
        },
        {
            product = 'salmonrice',
            items = {
                {'packaged_fish', 4},
                {'packaged_vegetables', 5},
            },
        },
        {
            product = 'shrimplinguini',
            items = {
                {'packaged_fish', 5},
                {'noodles', 3},
            },
        },
        {
            product = 'octosoup',
            items = {
                {'packaged_fish', 6},
                {'packaged_vegetables', 2},
                {'packaged_fruit', 2},
            },
        },
        {
            product = 'crawfishboil',
            items = {
                {'packaged_fish', 4},
                {'packaged_vegetables', 2},
                {'packaged_fruit', 2},
            },
        },
    },
    Frozen = {
        {
            product = 'choclava',
            items = {
                {'packaged_deserts', 4},
            },
        },
        {
            product = 'nycheesecake',
            items = {
                {'packaged_deserts', 2},
            },
        },
        {
            product = 'pearlsbrownie',
            items = {
                {'packaged_deserts', 3},
            },
        },
    }
}