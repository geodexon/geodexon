Status.Statuses['bleeding'] = function()
    SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) - 1)
    TriggerServerEvent('Evidence.Bleed', Shared.GetLocation().zone)
end

Status.Statuses['hospital'] = function()
    SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) + 1)
end