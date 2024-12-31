HouseRob = {}
HouseRob.Zones = {
    ['Fridge'] = {
        zonetype = 'Box',
        zonedata = {vector3(344.45, -1001.22, -99.2), 1.05, 0.2, {
            name="houserob_fridge",
            heading=0,
            --debugPoly=true,
            minZ=-100.2,
            maxZ=-98.25,
            res = GetCurrentResourceName()
        }, true},
        zonename = 'houserob_fridge'
    },
    ['Entertainment Center'] = {
        zonetype = 'Box',
        zonedata = {vector3(337.56, -996.69, -99.2), 3.0, 0.8, {
            name="houserob_entertainment",
            heading=0,
            --debugPoly=true,
            minZ=-100.2,
            maxZ=-99.3
        }, true},
        zonename = 'houserob_entertainment'
    },
    ['Couch'] = {
        zonetype = 'Box',
        zonedata = {vector3(342.97, -996.39, -99.2), 3.4, 0.8, {
            name="houserob_couch",
            heading=0,
            --debugPoly=true,
            minZ=-100.2,
            maxZ=-99.6
        }, true},
        zonename = 'houserob_couch'
    },
    ['Cabinet'] = {
        zonetype = 'Box',
        zonedata = {vector3(342.1, -1004.14, -99.2), 0.6, 1.2, {
            name="house_cabinet",
            heading=0,
            --debugPoly=true,
            minZ=-98.8,
            maxZ=-97.8
        }, true},
        zonename = 'house_cabinet'
    },
    ['Box'] = {
        zonetype = 'Box',
        zonedata = {vector3(352.55, -998.8, -99.2), 1.25, 0.75, {
            name="house_box",
            heading=358,
            --debugPoly=true,
            minZ=-100.2,
            maxZ=-99.55
        }, true},
        zonename = 'house_box'
    },
    ['Bedside Table'] = {
        zonetype = 'Box',
        zonedata = {vector3(348.52, -994.86, -99.2), 0.75, 1, {
            name="house_bedtable",
            heading=0,
            --debugPoly=true,
            minZ=-100.2,
            maxZ=-99.4
        }, true},
        zonename = 'house_bedtable'
    },
    ['Closet'] = {
        zonetype = 'Box',
        zonedata = {vector3(350.69, -992.77, -99.2), 2.6, 1, {
            name="houserob_closet",
            heading=269,
            --debugPoly=true,
            minZ=-100.2,
            maxZ=-97.8
        }, true},
        zonename = 'houserob_closet'
    }
}