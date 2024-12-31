local _zone =  {}

AddBoxZone(vector3(-660.93, -915.77, 24.43), 3, 3, {
    name="paycheck",
    heading=0,
})

AddEventHandler('Poly.Zone', function(zone, inZone)
    if zone == 'paycheck' then
        _zone.inside = inZone
        local _int
        while _zone.inside do
            Wait(0)
            _int = Shared.Interact('[E] Paycheck') or _int
            if IsControlJustPressed(0, 38) then
                local payAmount = Task.Run('ES.Pay')
                local menu = {
                    {title = 'Pay: $'..comma_value(payAmount), serverevent = 'ES.PayMe'},
                    {description = 'Pay from your cushy government job'}
                }
                exports['geo-interface']:InterfaceMessage({
                    interface = 'OptionSelector',
                    menu = menu
                }, true)
            end
        end
        if _int then _int.stop() end
    end
end)