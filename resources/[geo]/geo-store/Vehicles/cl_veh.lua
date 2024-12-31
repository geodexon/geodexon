local vehs = {}

Citizen.CreateThread(function()
    local lst = {}
    for k,v in pairs(VehicleShops) do
        table.insert(lst, v.Location)
        if not v.Hidden then
            local blip = AddBlipForCoord(v.Location)
            SetBlipSprite(blip, 225)
            SetBlipAsShortRange(blip, true)
            SetBlipScale(blip, 0.8)
            BeginTextCommandSetBlipName("STRING");
            AddTextComponentString('Vehicle Shop')
            EndTextCommandSetBlipName(blip)
        end

        AddCircleZone(v.Location, 10.0, {
            name="VehicleStore.Open",
            useZ = true,
            id = k
        })
    end
end)

local inLoc = false
AddEventHandler('Poly.Zone', function(zone, inZone, data)
    if zone == 'VehicleStore.Open' then
        inLoc = inZone
        if VehicleShops[data.id].requires then
            if not VehicleShops[data.id].requires(MyCharacter) then
                return
            end
        end

        local _int
        while inLoc do
            Wait(0)
            _int = Shared.Interact('[E] Open Vehicle Shop') or _int
            if IsControlJustPressed(0, 38) then
                VehStore_Menu(data.id)
            end
        end

        if _int then _int.stop() end
    end
end)

Menu.CreateMenu('VehShop', "Vehicle Shop")
Menu.CreateSubMenu('Confirm', 'VehShop', "Vehicle Shop")

function VehStore_Menu(id)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local option = 0
    local closest = id

    if VehicleShops[closest].requires then
        if not VehicleShops[closest].requires(MyCharacter) then
            return
        end
    end

    Menu.OpenMenu('VehShop')

    VehicleShops[closest].Vehicles = Task.Run('VehicleShop.GetCars', closest)
    while Menu.CurrentMenu do
        Wait(0)

        if Vdist3(GetEntityCoords(Shared.Ped), VehicleShops[closest].Location) >= 10.0 then
            break
        end

        if Menu.CurrentMenu == 'VehShop' then
            if option ~= Menu.ActiveOption then
                local nOp = option
                option = Menu.ActiveOption
                Citizen.CreateThread(function()
                    if vehs[nOp] then
                        local nVeh = vehs[nOp]

                        while not DoesEntityExist(nVeh) do
                            Wait(100)
                        end

                        Shared.GetEntityControl(nVeh)
                        SetEntityAsNoLongerNeeded(nVeh)
                        SetEntityCoords(nVeh, 0.0, 0.0, 0.0)
                        DeleteEntity(nVeh)
                        while DoesEntityExist(nVeh) do
                            DeleteEntity(nVeh)
                            Wait(100)
                        end
                        nVeh = nil
                    end
                    nOp = Menu.ActiveOption
                    vehs[nOp] = Shared.SpawnVehicle(VehicleShops[closest].Vehicles[nOp][1], VehicleShops[closest].VehSpawn)
                    SetVehicleColours(vehs[nOp], 0, 0)
                    SetVehicleExtraColours(vehs[nOp], 0, 0)
                    SetNetworkIdCanMigrate(VehToNet(vehs[nOp]), false)
                    FreezeEntityPosition(vehs[nOp], true)
                    SetEntityCollision(vehs[nOp], false, false)
                    SetVehicleOnGroundProperly(vehs[nOp])
                    SetEntityAlpha(vehs[nOp], 150, 1)
                end)
            end

            for k,v in pairs(VehicleShops[closest].Vehicles) do
                if VehiclePrices[v[1]] then
                    local _prce = math.floor(VehiclePrices[v[1]] * (VehicleShops[closest].Multiplier or 1.0))
                    if MyCharacter.job == 'Car Salesman' then
                        _prce = math.floor(_prce * 0.8)
                    end
                    if Menu.Button(GetLabelText(GetDisplayNameFromVehicleModel(GetHashKey(v[1])))..' ['..v[2]..']', '$'..comma_value(GetPrice(_prce))..(MyCharacter.job == 'Car Salesman' and ' [$'..comma_value(GetPrice(math.floor(VehiclePrices[v[1]] * (VehicleShops[closest].Multiplier or 1.0))))..']' or '')) then
                        Menu.OpenMenu('Confirm')
                    end
                end
            end
        elseif Menu.CurrentMenu == 'Confirm' then
            local _prce = math.floor(VehiclePrices[VehicleShops[closest].Vehicles[option][1]] * (VehicleShops[closest].Multiplier or 1.0))
            if MyCharacter.job == 'Car Salesman' then
                _prce = math.floor(_prce * 0.8)
            end
            Menu.EmptyButton(GetLabelText(GetDisplayNameFromVehicleModel(GetHashKey(VehicleShops[closest].Vehicles[option][1]))), '$'..comma_value(GetPrice(_prce)))
            Menu.EmptyButton()
            if Menu.Button('Purchase Vehicle') then
                TriggerServerEvent('PurchaseVehicle', closest, option, GetVehicleData(vehs[option]), VehToNet(vehs[option]), GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehs[option]))))
                Menu.CloseMenu()
            end

            if Menu.Button('Cancel') then
                Menu.OpenMenu('VehShop')
            end
        end

        Menu.Display()
    end

    for k,v in pairs(vehs) do
        TriggerServerEvent('DeleteEntity', VehToNet(v))
    end
    vehs = {}
end

RegisterNetEvent('PurchaseVehicle')
AddEventHandler('PurchaseVehicle', function(bool, data, plate, option)
    if bool then
        if vehs[option] then
            FreezeEntityPosition(vehs[option], false)
            SetEntityCollision(vehs[option], true, true)
            SetEntityAlpha(vehs[option], 255, 1)
            SetVehicleData(vehs[option], data, plate)
            TriggerEvent('AddKey', vehs[option])
            vehs[option] = nil
            Menu.CloseMenu()
        end
    end
end)

RegisterNetEvent('VehicleListings')
AddEventHandler('VehicleListings', function(index, val)
    VehicleShops[index].Vehicles = val
end)

AddTextEntry('police6', 'Police Buffalo')
AddTextEntry('police7', 'Police Dominator')
AddTextEntry('police9', 'Police Gresley')
AddTextEntry('police8', 'Police Dominator GTX')
AddTextEntryByHash(GetHashKey('saframb3'), 'Ambulance')
