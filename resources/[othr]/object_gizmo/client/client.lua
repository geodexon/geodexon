local usingGizmo = false
local function toggleNuiFrame(bool)
    usingGizmo = bool
    SetNuiFocusKeepInput(true)
    UIFocus(bool, bool, 'eeee', bool)
end

function useGizmo(handle)

    SendNUIMessage({
        action = 'setGizmoEntity',
        data = {
            handle = handle,
            position = GetEntityCoords(handle),
            rotation = GetEntityRotation(handle)
        }
    })

    toggleNuiFrame(true)

    CreateThread(function()
        while usingGizmo do
            Wait(0)
            HelpText('[W] Position \n[R] Rotation\n[Q] Place On Ground\n[Left Alt (Hold)] Move Around \n[Tab] Finish')
            Shared.DisableWeapons()
            if not _cam then
                for i=30,35 do
                    DisableControlAction(0, i, true)
                end
            end
        end
    end)

    while usingGizmo do
        Wait(0)
        SendNUIMessage({
            action = 'setCameraPosition',
            data = {
                position = GetFinalRenderedCamCoord(),
                rotation = GetFinalRenderedCamRot()
            }
        })
    end

    return {
        handle = handle,
        position = GetEntityCoords(handle),
        rotation = GetEntityRotation(handle)
    }
end

RegisterNUICallback('moveEntity', function(data, cb)
    local entity = data.handle
    local position = data.position
    local rotation = data.rotation

    SetEntityCoords(entity, position.x, position.y, position.z)
    SetEntityRotation(entity, rotation.x, rotation.y, rotation.z)
    cb('ok')
end)

RegisterNUICallback('placeOnGround', function(data, cb)
    PlaceObjectOnGroundProperly(data.handle)
    cb('ok')
end)

RegisterNUICallback('FinishEdit', function(data, cb)
    toggleNuiFrame(false)
    SendNUIMessage({
        action = 'setGizmoEntity',
        data = {
            handle = nil,
        }
    })
    cb('ok')
end)

AddEventHandler('ClothingCam', function(bool)
    if usingGizmo then
        _cam = bool

        if _cam then
            SetNuiFocus(false, false)

            while _cam do
                Wait(0)
                EnableControlAction(0, 1, true)
                EnableControlAction(0, 2, true)
                Shared.DisableWeapons()
            end
            SetNuiFocus(usingGizmo, usingGizmo)
        end
    end
end)

RegisterNUICallback('finishEdit', function(data, cb)
    cb('ok')
end)

RegisterNUICallback('swapMode', function(data, cb)
    cb('ok')
end)


exports("useGizmo", useGizmo)
exports("GizmoActive", function()
    return usingGizmo
end)
