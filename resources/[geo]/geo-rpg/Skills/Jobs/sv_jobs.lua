Task.Register('RPG.JobLocation', function(source)
    exports['geo-instance']:EnterProperty(source, 'RPG Jobs', 'Lom_Ice', false, {238.19, -412.05, 48.11, 340.24})
end)

RegisterNetEvent('RPG.Job')
AddEventHandler('RPG.Job', function(jobID)
    local source = source
    local char = GetCharacter(source)
    if char and RPG.Jobs[jobID] then
        local val = SQL('SELECT * from rpg_jobtime WHERE cid = ?', char.id)[1]
        local comp = false
        if val then
            val.jtime = val.jtime / 1000
            if val.jtime - os.time() <= 0 and (char.job or 'Unemployed' ~= RPG.Jobs[jobID]) then
                comp = true
            end
        else
            comp = true
        end

        if comp then
            UpdateChar(source, 'job', RPG.Jobs[jobID])
            SQL('INSERT INTO rpg_jobtime (cid, jtime) VALUES (?, NOW() + INTERVAL 7 DAY)', char.id)
            SQL('UPDATE characters SET job = ? WHERE id = ?', RPG.Jobs[jobID], char.id)
            TriggerClientEvent('Shared.Notif', source, 'You are now a '..RPG.Jobs[jobID], 7500)
        else
            local since = TimeSince(val.jtime)
            TriggerClientEvent('Shared.Notif', source, (' %s hours %s minutes and %s seconds until next available career change'):format(since.hours, since.minutes, since.seconds), 7500)
        end
    end
end)