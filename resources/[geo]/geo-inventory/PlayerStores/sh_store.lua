OwnedStores = {
    ConvStore = {
        
    },
    AmmuStore = {
        
    },
    LSC = {

    }
}

exports('GetStore', function(storeType, storeID)
    return OwnedStores[storeType][storeID]
end)