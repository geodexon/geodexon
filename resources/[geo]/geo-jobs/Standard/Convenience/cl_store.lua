AddEventHandler('Convenience.JobStatus', function(storeID)
    local active = not exports['geo-inventory']:IsStoreAvailable()
    local menu = {
        {title = 'Start Job', disabled = active, event = 'Convenience.SetJob', params = {true, storeID}, description = 'Due to the bonuses of this job, it will prevent you from activating another job for one hour.'},
        {title = 'End Job', event = 'Convenience.SetJob', params = {false, storeID}},
        {title = 'Ping Cashier', disabled = active, serverevent = 'Convenience.Ping', params = {storeID}},
        {title = 'Open Register', hidden = json.decode(GlobalState.Convenience)[storeID] ~= MyCharacter.id, serverevent = 'Convenience.OpenRegister', params = {storeID}},
        {title = '', event = '', params = {}, description = 'This job is mainly for RP, and will not make a lot of money unless you bring customers in'},
    }

    RunMenu(menu)
end)

AddEventHandler('Convenience.SetJob', function(bool, storeID)
    local val = Task.Run('Convenience.SetJob', bool, storeID)
    if val then
        Wait(2500)
        local origin = GetEntityCoords(Shared.Ped)
        while MyCharacter.job == 'Convenience' do
            Wait(1000)
            if Vdist3(GetEntityCoords(Shared.Ped), origin) >= 100.0 then
                Task.Run('Convenience.SetJob', false, storeID)
            end
        end
    end
end)
