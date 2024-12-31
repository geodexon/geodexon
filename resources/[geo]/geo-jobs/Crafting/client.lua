RegisterCommand('craft', function()
    local lst = exports['geo-inventory']:GetInventory()
    local amounts = {}

    for k,v in pairs(lst) do
        if amounts[v.Key] == nil then
            amounts[v.Key] = v.Amount
        else
            amounts[v.Key] = amounts[v.Key] + v.Amount
        end
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'CraftingData',
        data = Crafting,
        Amounts = amounts
    })
end)
