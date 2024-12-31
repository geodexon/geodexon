local maps = {
    --['prison'] = {'cs6_occl_02', 'hei_ch3_occl_03', 'int_prison_first_milo_', 'int_prison_main_milo_', 'int_prison_recep_milo_', 'int_prison_second_milo_', 'lr_cs6_04_critical_0', 'lr_cs6_04_strm_3', 'prison_windows'}
}

for k,v in pairs(maps) do
    for _,map in pairs(v) do
        RemoveIpl(map)
    end
end

function InteriorToggle(list, bool)
    if bool then
        for k,v in pairs(list) do
            RequestIpl(v)
        end
    else
        for k,v in pairs(list) do
            RemoveIpl(v)
        end
    end
end