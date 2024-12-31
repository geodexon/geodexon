local hashes = {
    [GetHashKey('a_c_deer')] = {item = 'meat_deer', amount = 6, name = 'Deer Meat'},
    [GetHashKey('a_c_coyote')] = {item = 'meat_coyote', amount = 2, name = 'Coyote Meat'},
    [GetHashKey('a_c_pig')] = {item = 'meat_pig', amount = 4, name = 'Pig Meat'},
    [GetHashKey('a_c_mtlion')] = {item = 'meat_mtlion', amount = 3, name = 'Mountain Lion Meat'},
    [GetHashKey('a_c_cow')] = {item = 'meat_cow', amount = 6, name = 'Cow Meat'},
    [GetHashKey('a_c_hen')] = {item = 'none', amount = 1},
}

local list = {}

RegisterNetEvent('Hunting:Harvest')
AddEventHandler('Hunting:Harvest', function(ped)
    local source = source
    local ent = NetworkGetEntityFromNetworkId(ped)
    if DoesEntityExist(ent) then
        local model = GetEntityModel(ent)
        if hashes[model] then
            local str = ped..'.'..ent..'.'..model
            if list[str] == nil then
                list[str] = New(hashes[model])
            end

            if GetPedCauseOfDeath(ent) == `WEAPON_RUN_OVER_BY_CAR` then
                TriggerClientEvent('Shared.Notif', source, ' This carcass has been ruined')
                return
            end

            if list[str].item ~= 'none' and exports['geo-inventory']:ReceiveItem('Player', source, list[str].item, 1) then
                list[str].amount = list[str].amount - 1

                TriggerClientEvent('Shared.Notif', source, 'You got '..list[str].name)

                if Random(100) >= 75 then
                    exports['geo-inventory']:ReceiveItem('Player', source, 'hide_animal', 1)
                end


                if list[str].amount == 0 then
                    DeleteEntity(ent)
                    list[str] = nil
                end
            end

            TriggerEvent('Hunted', source, model, ent)
        end
    end
end)

RegisterNetEvent('Hunting:Sell')
AddEventHandler('Hunting:Sell', function(meat, amount)
    local source = source
    if meatPrices[meat] then
        if exports['geo-inventory']:RemoveItem('Player', source, meat, amount) then
            exports['geo-inventory']:AddItem('Player', source, 'dollar', amount * meatPrices[meat])
            TriggerClientEvent('Chat.Message', source, '[Hunting]', 'You were paid $'.. amount * meatPrices[meat], 'job')
        end
    end
end)