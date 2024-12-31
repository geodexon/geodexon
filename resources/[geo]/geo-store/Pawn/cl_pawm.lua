CreateThread(function()
    Wait(1000)
    local ped = exports['geo-interface']:InterfacePed({
        model = 1224306523,
        position = vector4(51.66, -1317.84, 29.29, 317.48),
        title = 'Pawn Shop',
        event = 'Pawn:Menu'
    })
end)

AddEventHandler('Pawn:Menu', function()
    local data = Task.Run('GetPawnItems')

    local menu = {}

    for k,v in pairs(data) do
        table.insert(menu, {
            title = v[1]..' <font color ="#0de01f">x'..v[3], 
            sub = "We will give you <font color =\"#0eab1b\">$"..v[2] * v[3],
            serverevent = 'PawnShop:Sell',
            params = {v[4], v[3]}
        })
    end

    if #menu == 0 then
        table.insert(menu, {description = "You have nothing we want :("})
    end

    RunMenu(menu)
end)