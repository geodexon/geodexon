isDead = false
CreateThread(function()
    while true do
        Wait(500)
        local ped = PlayerPedId()
        local health = GetEntityHealth(ped)
        if health <= 0 and not isDead then
            isDead = true
            TriggerEvent('baseevents:onPlayerDied')
            TriggerEvent('baseevents:onPlayerKilled')
        elseif health > 0 and isDead then
            isDead = false
        end
    end
end)