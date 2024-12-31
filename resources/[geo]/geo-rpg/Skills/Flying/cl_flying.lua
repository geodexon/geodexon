local directions = {107, 110}

AddEventHandler('enteredVehicle', function(veh)
    local class = GetVehicleClass(veh)
    local flyingSkill = MyCharacter.skills.Flying or 0

    if class == 15 or class == 16 then
        while Shared.CurrentVehicle == veh do
            Wait(0)
            local direction = directions[Random(#directions)]

            for i=1,60 do
                Wait(0)
                local rnd = Random(50, 100)
                local calc = (rnd / 100 + 0.0)
                SetControlNormal(0, direction, calc - (flyingSkill / 10000) * calc)
            end
        end
    end
end)