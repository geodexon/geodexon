Task.Register('Skill.Stamina', function(source, pSkill)
    local char = GetCharacter(source)
    if char then
        if RateLimit('Skill.Stamina'..char.id, 30000) then
            if pSkill > 15000 then pSkill = 15000 end
            pSkill = pSkill / 175
            AddSkill(source, 'Stamina', pSkill)
        end
    end
end)