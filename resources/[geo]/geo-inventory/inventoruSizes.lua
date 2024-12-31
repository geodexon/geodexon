Slots = {
    ['Player'] = 48,
    ['Vehicle'] = 104,
    ['Locations'] = 104,
    ['Property'] = 104,
    ['Box'] = 16,
    ['Drops'] = 16,
    ['Glovebox'] = 16,
    ['Store'] = 104,
    ['StoreUI'] = 24,
    ['Locker'] = 32,
    ['Motel'] = 32,
    ['Jail'] = 200,
    ['Evidence'] = 104,
    ['Dumpster'] = 16,
    ['Register'] = 1,
    ['Credit'] = 48,
    ['EvidenceBag'] = 16,
}

Sizes = {
    ['Player'] = 50000,
    ['Vehicle'] = 200000,
    ['Locations'] = 1000000,
    ['Property'] = 1000000,
    ['Box'] = 5000,
    ['Drops'] = 50000,
    ['Glovebox'] = 50000,
    ['Store'] = 1000000,
    ['StoreUI'] = 1000000,
    ['Locker'] = 50000,
    ['Motel'] = 100000,
    ['Jail'] = 50000000000,
    ['Evidence'] = 1000000,
    ['Dumpster'] = 50000,
    ['Register'] = 5000,
    ['Credit'] = 5000000,
    ['EvidenceBag'] = 5000,
    
    -- Vehicle Classes
    [2] = 4000 * 100,
    [4] = 1500 * 100,
    [5] = 1500 * 100,
    [6] = 1500 * 100,
    [7] = 1200 * 100,
    [8] = 250 * 100,
    [9] = 3500 * 100,
    [10] = 5000 * 100,
    [11] = 5000 * 100,
    [12] = 4500 * 100,
    [15] = 1000 * 100,
    [16] = 50000 * 100,
    [19] = 10000 * 100,
    [20] = 4000 * 100,
}

Whitelists = {
    ['EvidenceBag'] = {
        items = {
            'evidence_blood', 'evidence_bullet', 'dollar'
        },
        Weapon = true
    }
}