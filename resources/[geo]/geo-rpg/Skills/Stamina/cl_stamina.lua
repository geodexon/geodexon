CreateThread(function()
    while true do
        Wait(0)
        if IsPedSprinting(Shared.Ped) then
            local start = GetGameTimer()
            while IsPedSprinting(Shared.Ped) do
                Wait(0)
            end
            local endTime = Shared.TimeSince(start)
            if RateLimit('Skills.Stamina', 29000) then
                Task.Run('Skill.Stamina', endTime)
                Wait(29000)
            end
        else
            Wait(250)
        end
    end
end)

AddEventHandler('Login', function()
    StatSetInt(`MP0_STAMINA`, GetLevel(MyCharacter.skills.Stamina or 0), true)
end)

RegisterNetEvent('Skill.Update', function(skill, amount)
    StatSetInt(`MP0_STAMINA`, GetLevel(MyCharacter.skills.Stamina or 0), true)
end)

CreateThread(function()
    Wait(1000)
    if MyCharacter then
        StatSetInt(`MP0_STAMINA`, GetLevel(MyCharacter.skills.Stamina or 0), true)
    end
end)