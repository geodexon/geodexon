local atStore
_interactOptions = {
    {
        name = 'Staff',
        requires = function ()
            return MyCharacter.username ~= nil
        end,

        children = {
            {
                name = 'Heal',
                func = function()
                    SetEntityHealth(Shared.Ped, 200)
                end
            },
            {
                name = 'Armor',
                func = function()
                    SetPedArmour(Shared.Ped, 100)
                end
            },
            {
                name = 'Revive',
                func = function()
                    TriggerServerEvent('EMS.Revive', GetPlayerServerId(PlayerId()), true)
                end
            },
        }
    },
    {
        name = 'Panic Button',
        icon = '#alert',
        requires = function ()
            return exports['geo-es']:IsEs(MyCharacter.id) and (MyCharacter.Duty == 'Police' or  MyCharacter.Duty == 'EMS')
        end,

        func = function()
            TriggerServerEvent('ES.Panic', Shared.GetLocation())
        end
    },
    {
        name = 'Kitty Litter',
        icon = '#kitty',
        requires = function ()
            return MyCharacter.Duty == 'EMS'
        end,

        func = function()
            ExecuteCommand('kittylitter')
        end
    },
    {
        name = 'Police Actions',
        icon = '#police',
        requires = function ()
            return MyCharacter.Duty == 'Police'
        end,

        children = {
            {
                name = 'MDT',
                icon = '#mdt',
                requires = function ()
                    return MyCharacter.Duty == 'Police' or MyCharacter.Duty == 'EMS'
                end,
        
                func = function()
                    ExecuteCommand('mdt')
                end
            },
            {
                name = 'Show Badge',
                icon = '#person',
                requires = function ()
                    return MyCharacter.Duty == 'Police'
                end,
        
                func = function()
                    TriggerEvent('Police.ShowBadge')
                end
            },
            {
                name = 'Spikestrip',
                icon = '#police',
                requires = function ()
                    return MyCharacter.Duty == 'Police'
                end,
        
                func = function()
                    ExecuteCommand('spikes')
                end
            },
            {
                name = 'Run Plate',
                type = 2,
                icon = '#vehicle',

                requires = function (data)
                    return MyCharacter.Duty == 'Police'
                    and (
                            Vdist3(GetOffsetFromEntityInWorldCoords(_ent, 0.0, data.max.y - 0.5, 0.0), data.ray.HitPosition) <= 1.0
                            or Vdist3(GetOffsetFromEntityInWorldCoords(_ent, 0.0, data.min.y + 0.5, 0.0), data.ray.HitPosition) <= 1.0
                        )

                end,
         
                func = function()
                     ExecuteCommand('runplate '..GetVehicleNumberPlateText(_ent))
                end
             },
             {
                 name = 'Impound',
                 type = 2,
                 icon = '#vehicle',
          
                 requires = function ()
                     return MyCharacter.Duty == 'Police' or MyCharacter.Duty == 'EMS'
                 end,
          
                 func = function()
                     local title = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(_ent)))
                     local plate = GetVehicleNumberPlateText(_ent)
                     TriggerServerEvent('Tow:MarkImpound', plate, title, NetworkGetNetworkIdFromEntity(_ent))
                 end
             },
             {
                name = 'Impound (Auto)',
                type = 2,
                icon = '#vehicle',
         
                requires = function ()
                    return MyCharacter.Duty == 'Police'
                end,
         
                func = function()
                    local title = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(_ent)))
                    local plate = GetVehicleNumberPlateText(_ent)
                    TriggerServerEvent('Tow:MarkImpound', plate, title, NetworkGetNetworkIdFromEntity(_ent), true)
                end
            },
             {
                name = 'Frisk',
                icon = '#person',
        
                requires = function ()
                    return _player and MyCharacter.Duty == 'Police'
                end,
        
                func = function()
                    ExecuteCommand('frisk')
                end
            },
            {
                name = 'Search',
                icon = '#person',
        
                requires = function ()
                    return _player and MyCharacter.Duty == 'Police'
                end,
        
                func = function()
                    ExecuteCommand('search')
                end
            },
            {
                name = 'Seize Items',
                icon = '#person',
        
                requires = function ()
                    return _player and MyCharacter.Duty == 'Police'
                end,
        
                func = function()
                    ExecuteCommand('_seizeinternal '..GetPlayerServerId(_player))
                end
            },
            {
                name = 'GSR',
                icon = '#person',
        
                requires = function ()
                    return _player ~= nil and exports['geo-inventory']:HasItem('gsr')
                end,
        
                func = function()
                    ExecuteCommand('gsr')
                end
            },
            {
                name = 'Fingerprint',
                icon = '#person',
        
                requires = function ()
                    return _player or MyCharacter.Dragging
                end,
        
                func = function()
                    ExecuteCommand('e texting')
                    local plyr = GetClosestPlayer(5.0)
                    if not plyr then
                        ExecuteCommand('ec texting')
                        return
                    end
        
                    local finish = nil
                    exports['geo-shared']:Progress('Fingerprinting', 5000, function(res, term)
                        terminate = term
                        if res then
                            finish = true
                        end
                    end)
        
                    local ped = GetPlayerPed(plyr)
                    while finish == nil do
                        Wait(0)
                        local pos = GetEntityCoords(ped)
                        DrawMarker(27, pos.x, pos.y, pos.z - 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 200, 0, 0, 2, 0, nil, nil, 0, 500.0)
                    end
        
                    if finish then
                        TriggerEvent('Shared.Notif', 'Fingerprinted: '..Player(GetPlayerServerId(plyr)).state.cid)
                    end
                    ExecuteCommand('ec texting')
                end
            },
            {
                name = 'Breathalyzer',
                icon = '#person',
        
                requires = function ()
                    return _player ~= nil and exports['geo-inventory']:HasItem('breathalyzer')
                end,
        
                func = function()
                    ExecuteCommand('breath')
                end
            },
            {
                name = 'Register Weapon',
                icon = '#person',
        
                requires = function ()
                    return true
                end,
        
                func = function()
                    ExecuteCommand('regser')
                end
            },
        }
    },
    {
        name = 'EMS Actions',
        icon = '#police',
        requires = function ()
            return MyCharacter.Duty == 'EMS'
        end,

        children = {
            {
                name = 'MDT',
                icon = '#mdt',
                requires = function ()
                    return MyCharacter.Duty == 'Police' or MyCharacter.Duty == 'EMS'
                end,
        
                func = function()
                    ExecuteCommand('mdt')
                end
            },
            {
                name = 'Show Badge',
                icon = '#person',
                requires = function ()
                    return MyCharacter.Duty == 'EMS'
                end,
        
                func = function()
                    TriggerEvent('Police.ShowBadge')
                end
            },
            {
                 name = 'Impound',
                 type = 2,
                 icon = '#vehicle',
          
                 requires = function ()
                     return MyCharacter.Duty == 'Police' or MyCharacter.Duty == 'EMS'
                 end,
          
                 func = function()
                     local title = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(_ent)))
                     local plate = GetVehicleNumberPlateText(_ent)
                     TriggerServerEvent('Tow:MarkImpound', plate, title, NetworkGetNetworkIdFromEntity(_ent))
                 end
             },
             {
                name = 'Impound (Auto)',
                type = 2,
                icon = '#vehicle',
         
                requires = function ()
                    return MyCharacter.Duty == 'Police' or MyCharacter.Duty == 'EMS'
                end,
         
                func = function()
                    local title = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(_ent)))
                    local plate = GetVehicleNumberPlateText(_ent)
                    TriggerServerEvent('Tow:MarkImpound', plate, title, NetworkGetNetworkIdFromEntity(_ent), true)
                end
            },
            {
                name = 'Breathalyzer',
                icon = '#person',
        
                requires = function ()
                    return _player ~= nil and exports['geo-inventory']:HasItem('breathalyzer')
                end,
        
                func = function()
                    ExecuteCommand('breath')
                end
            },
        }
    },
    {
        name = 'Global',
        icon = '#id',
        requires = function ()
            return MyCharacter
        end,
        children = {
            {
                name = 'Pay: Debit',
                icon = '#bank',

                requires = function()
                    return MyCharacter.pay == 'cash' or not MyCharacter.pay
                end,

                func = function()
                    ExecuteCommand('paywith debit')
                end
            },
            {
                name = 'Pay: Cash',
                icon = '#bank',

                requires = function()
                    return MyCharacter.pay == 'debit'
                end,

                func = function()
                    ExecuteCommand('paywith cash')
                end
            },
            {
                name = 'Chat',
                icon = '#person',
                children = {
                    {
                        name = 'Sticky Chat',
                        icon = '#person',
                        func = function()
                            ExecuteCommand('_hide')
                        end
                    },
                    {
                        name = 'Font Size',
                        icon = '#person',
                        func = function()
                            ExecuteCommand('_fontsize')
                        end
                    },
                }
            },
            {
                name = 'Clothing',
                requires = function ()
                    return MyCharacter
                end,
        
                icon = '#shirt',
                children = {
                    {
                        name = 'Mask',
                        icon = '#shirt',
                        func = function()
                            ExecuteCommand('mask')
                        end
                    },
                    {
                        name = 'Hat',
                        icon = '#shirt',
                        func = function()
                            ExecuteCommand('hat')
                        end
                    },
                    {
                        name = 'Bag',
                        icon = '#shirt',
                        func = function()
                            ExecuteCommand('bag')
                        end
                    },
                    {
                        name = 'Glasses',
                        icon = '#shirt',
                        func = function()
                            ExecuteCommand('glasses')
                        end
                    },
                    {
                        name = 'Shirt',
                        icon = '#shirt',
                        func = function()
                            ExecuteCommand('shirt')
                        end
                    },
                    {
                        name = 'Pants',
                        icon = '#shirt',
                        func = function()
                            ExecuteCommand('Pants')
                        end
                    },
                    {
                        name = 'Gloves',
                        icon = '#shirt',
                        func = function()
                            ExecuteCommand('Gloves')
                        end
                    }
                }
            },
            {
                name = 'Clear Evidence',
                requires = function ()
                    return MyCharacter.Duty == 'Police'
                end,
        
                icon = '#person',

                func = function()
                    TriggerEvent('RemoveEvidence')
                end
            },
            {
                name = 'Settings',
                icon = '#cog',
                func = function()
                    ExecuteCommand('Settings')
                end
            },
            {
                name = 'Expressions',
                icon = '#person',
                func = function()
                    ExecuteCommand('expressions')
                end
            },
        },
    },
    {
        name = 'Leave Trunk',
        icon = '#vehicle',
        requires = function ()
            return exports['geo-vehicle']:InTrunk() ~= false and GetVehicleDoorAngleRatio(exports['geo-vehicle']:InTrunk(), 5) > 0
        end,

        func = function()
            ExecuteCommand('getintrunk')
        end
    },
    {
        name = 'Bank',
        icon = '#bank',
        requires = function ()
            return exports['geo-eco']:NearBank()
        end,

        func = function()
            TriggerEvent('UseBank')
        end
    },
    {
        name = 'Garage',
        displayname = 'Garage',
        icon = '#garage',
        requires = function ()
            return exports['geo-vehicle']:NearGarage()
        end,

        func = function()
            TriggerEvent('Garage:Valet')
        end
    },
    {
        name = 'Garage2',
        displayname = 'Garage',
        icon = '#garage',
        requires = function ()
            return (MyCharacter.Duty == 'Police' or MyCharacter.Duty == 'EMS') and exports['geo-es']:NearGarage()
        end,

        func = function()
            TriggerEvent('Duty:Garage')
        end
    },
    {
        name = 'Garage3',
        displayname = 'Garage',
        icon = '#garage',
        requires = function ()
            return exports['geo-instance']:GetClosestPropertyGarage()
        end,

        func = function()
            TriggerEvent('PropertyGarage')
        end
    },

    -- Police Vehicle
    {
        name = 'Tow',
        type = 2,
        icon = '#vehicle',
 
        requires = function ()
            return exports['geo-jobs']:CanTow(GetVehiclePedIsIn(Shared.Ped, true))
        end,
 
        func = function()
            TriggerEvent('Tow', _ent)
        end
    },
    {
        name = 'Impound Vehicle',
        type = 2,
        icon = '#vehicle',
 
        requires = function ()
            return MyCharacter.Duty == 'Tow' and zoneData['ImpoundDrop'] and Entity(_ent).state.impound
        end,
 
        func = function()
            TriggerServerEvent('Tow:Impound', VehToNet(_ent), GetVehicleNumberPlateText(_ent))
        end
    },

    -- General Vehicle
    {
        name = 'Vehicle Doors',
        icon = '#vehicle',

        requires = function()
            return GetEntityType(_ent) == 2 or Shared.CurrentVehicle ~= 0
        end,

        children = {
            {
                name = 'Front Left',
                icon = '#door',
                requires = function()
                    return DoesVehicleHaveDoor(GetEntityType(_ent) == 2 and _ent or Shared.CurrentVehicle, 0) == 1
                end,
        
                func = function()
                    ExecuteCommand('door fl')
                end
            },
            {
                name = 'Front Right',
                icon = '#door',
                requires = function()
                    return DoesVehicleHaveDoor(GetEntityType(_ent) == 2 and _ent or Shared.CurrentVehicle, 1) == 1
                end,
        
                func = function()
                    ExecuteCommand('door fr')
                end
            },
            {
                name = 'Back Left',
                icon = '#door',
                requires = function()
                    return DoesVehicleHaveDoor(GetEntityType(_ent) == 2 and _ent or Shared.CurrentVehicle, 3) == 1
                end,
        
                func = function()
                    ExecuteCommand('door bl')
                end
            },
            {
                name = 'Back Right',
                icon = '#door',
                requires = function()
                    return DoesVehicleHaveDoor(GetEntityType(_ent) == 2 and _ent or Shared.CurrentVehicle, 2) == 1
                end,
        
                func = function()
                    ExecuteCommand('door br')
                end
            },
            {
                name = 'Trunk',
                icon = '#door',
                requires = function()
                    return DoesVehicleHaveDoor(GetEntityType(_ent) == 2 and _ent or Shared.CurrentVehicle, 5) == 1
                end,
        
                func = function()
                    ExecuteCommand('trunk')
                end
            },
            {
                name = 'Hood',
                icon = '#door',
                requires = function()
                    return DoesVehicleHaveDoor(GetEntityType(_ent) == 2 and _ent or Shared.CurrentVehicle, 4) == 1
                end,
        
                func = function()
                    ExecuteCommand('hood')
                end
            },
        }
    },
    {
        name = 'Windows',
        icon = '#vehicle',

        requires = function()
            return Shared.CurrentVehicle ~= 0
        end,

        children = {
            {
                name = 'window.fl',
                displayname = 'Front Left',
                icon = '#door',
        
                func = function()
                    ExecuteCommand('window fl')
                end
            },
            {
                name = 'window.fr',
                displayname = 'Front Right',
                icon = '#door',
        
                func = function()
                    ExecuteCommand('window fr')
                end
            },
            {
                name = 'window.bl',
                displayname = 'Back Left',
                icon = '#door',
        
                func = function()
                    ExecuteCommand('window bl')
                end
            },
            {
                name = 'window.br',
                displayname = 'Back Right',
                icon = '#door',
        
                func = function()
                    ExecuteCommand('window br')
                end
            },
        }
    },
    {
        name = 'Delete Vehicle',
        icon = '#vehicle',
        type = 2,

        requires = function ()
            return (exports['geo-es']:IsEs(MyCharacter.id) and (MyCharacter.Duty == 'Police' or MyCharacter.Duty == 'EMS')) or MyCharacter.username
        end,

        func = function()
            ExecuteCommand('rv')
        end
    },
    {
        name = 'Sell Vehicle',
        icon = '#vehicle',
        type = 2,
        requires = function(data)
            return Entity(_ent).state.owner == MyCharacter.id
            and IsPedAPlayer(GetPedInVehicleSeat(_ent, -1))
        end,

        func = function()
            local ent = _ent
            local player = GetPlayerServerId(NetworkGetPlayerIndexFromPed(GetPedInVehicleSeat(ent, -1)))
            local val = Shared.TextInput('Vehicle Sale Price', 7)
            if Shared.Confirm('Would you like to sell this vehicle for $'..comma_value(GetPrice(tonumber(val)))) then
                TriggerServerEvent('Vehicle.Sell', NetworkGetNetworkIdFromEntity(ent), player, tonumber(val))
            end
        end
    },
    {
        name = 'Cuff',
        icon = '#cuff',

        requires = function ()
            return _player and MyCharacter.Duty == 'Police'
        end,

        func = function()
            ExecuteCommand('cuff')
        end
    },
    
    {
        name = 'Give Key',
        type = 1,
        icon = '#key',

        requires = function ()
            local veh = GetVehiclePedIsIn(Shared.Ped, true)
            if IsPedAPlayer(_ent) and DoesEntityExist(veh) and exports['geo-vehicle']:HasKey(veh) and Vdist3(GetEntityCoords(veh), GetEntityCoords(Shared.Ped)) <= 10.0 then
                return true
            end
        end,

        func = function()
            local veh = GetVehiclePedIsIn(Shared.Ped, true)
            TriggerServerEvent('GiveKey', GetPlayerServerId(NetworkGetPlayerIndexFromPed(_ent)), VehToNet(veh))
            TriggerEvent('Shared.Notif', 'You have given keys to a vehicle')
        end
    },
    {
        name = 'Drag',
        icon = '#person',

        requires = function ()
            return IsPedAPlayer(_ent) or MyCharacter.Dragging
        end,

        func = function()
            ExecuteCommand('drag')
        end
    },

    -- Objects
    
    {
        name = 'LSC',
        icon = '#Wrench',

        requires = function(data)
            return Shared.CurrentVehicle ~= 0 and exports['geo-store']:AtRepair()
        end,

        func = function()
           exports['geo-store']:Customize()
        end
    },
    {
        name = 'My LSC',
        icon = '#Wrench',

        requires = function(data)
            local atRepair = exports['geo-store']:AtRepair()
            if atRepair then
                local store = exports['geo-inventory']:GetStore('LSC', atRepair)
                if store then
                    return exports['geo-instance']:GetProperty(store[1]).owner == MyCharacter.id
                end
            end
        end,

        func = function()
            TriggerEvent('LSC.Customize', atRepair)
        end
    },
    {
        name = 'Clothing Store',
        icon = '#shirt',

        requires = function(data)
            return exports['geo']:AtClothingStore()
        end,

        func = function()
            exports['geo']:ClothingStore()
        end
    },
    {
        name = 'Tattoos',
        icon = '#shirt',

        requires = function(data)
            return exports['geo-tattoo']:NearTattoo()
        end,

        func = function()
            TriggerEvent('Tattoo:Shop')
        end
    },
    {
        name = 'Refuel',
        icon = '#pump',
        type = 2,

        requires = function(data)
            return exports['geo-vehicle']:AtPump() and GetEntityType(Shared.EntityInFront(5.0)) == 2
        end,

        func = function()
            TriggerEvent('Fuel:Refill')
        end
    },
    {
        name = 'Logout',
        icon = '#person',

        requires = function()
            return MyCharacter and MyCharacter.interior and exports['geo-instance']:HasKey()
        end,

        func = function()
            ExecuteCommand('logout')
        end
    },
    {
        name = 'steal_player',
        displayname = 'Steal',
        icon = '#person',

        requires = function()
            local player = GetClosestPlayer(1.0)
            if player and Task.Run('CanRob', GetPlayerServerId(player)) then
                return true
            end
        end,

        func = function()
            local ped = GetPlayerPed(GetClosestPlayer(1.0))
            LoadAnim('random@mugging2')
            TaskPlayAnim(Shared.Ped, 'random@mugging2', 'ig_1_guy_stickup_loop', 8.0, -8, 10000, 1, 0, 0, 0, 0)
            if exports['geo-shared']:ProgressSync('Robbing', 10000) then
                if Vdist3(GetEntityCoords(ped), GetEntityCoords(Shared.Ped)) <= 1.0 then
                    Task.Run('Rob', GetPlayerServerId(GetClosestPlayer(1.0)))
                end
            end
            StopAnimTask(Shared.Ped, 'random@mugging2', 'ig_1_guy_stickup_loop', 1.0)
        end
    },
   --[[  {
        name = 'Pickup Snowball',
        icon = '#circle',
        requires = function ()
            return GetInteriorFromEntity(Shared.Ped) == 0
        end,

        func = function()
            ExecuteCommand('e pickup')
            Wait(1000)
            Task.Run('GetSnowball')
            ExecuteCommand('ec pickup')
        end
    }, ]]
}

_normalOptions = {
    
}

_selectOptions = {
    {
        name = 'Sit',
        icon = 'fas fa-chair',
        type = 3,
        distance = 2.0,

        requires = function()
            return exports['geo-emote']:ValidChair(GetEntityModel(_ent))
        end,

        func = function()
            TriggerEvent('Sit', _ent)
        end
    },
    {
        name = 'Search Trash',
        icon = 'fas fa-trash',
        type = 3,

        requires = function(data)
            return Models[data.model] == 'Trash' and data.incar == false and data.dist <= 3.0
        end,

        func = function()
            local pos = GetEntityCoords(_ent)
            TriggerServerEvent('Dumpster', math.floor(pos.x / 5)..'.'..math.floor(pos.y / 5)..'.'..math.floor(pos.z / 5))
        end
    },
    {
        name = 'Bed',
        icon = 'fas fa-procedures',
        type = 3,

        requires = function ()
            local obj = GetClosestObjectOfType(GetEntityCoords(Shared.Ped), 1.0, 2117668672, 0, 0, 0)
            return obj ~= 0
        end,

        func = function()
            ExecuteCommand('bed')
        end
    },
    {
        name = 'Resurrect',
        type = 1,

        requires = function ()
            return MyCharacter.Duty == 'EMS' and IsEntityDead(_ent)
        end,

        func = function()
            ExecuteCommand('resurrect')
        end
    },
    {
        name = 'Cause of Death',
        icon = 'fas fa-book-dead',
        type = 1,

        requires = function ()
            return IsEntityDead(_ent)
        end,

        func = function()
            TriggerEvent('Death.Cause', _ent)
        end
    },
    {
        displayname = 'Coroner',
        name = uuid(),
        icon = 'fas fa-book-dead',
        type = 1,

        requires = function ()
            return IsEntityDead(_ent) and MyCharacter.Duty == 'Police'
        end,

        func = function()
            TriggerEvent('Coroner', _ent)
        end
    },
    {
        displayname = 'Coroner',
        name = uuid(),
        icon = 'fas fa-book-dead',
        type = 3,

        requires = function ()
            return GetEntityModel(_ent) == -825556356 and MyCharacter.Duty == 'Police'
        end,

        func = function()
            TriggerEvent('Coroner', _ent)
        end
    },
    {
        name = 'Check Patient',
        icon = 'fas fa-book-dead',

        requires = function (pData)
            local data = pData.zone
            return data and data.name == 'evidence_patient' and MyCharacter.Duty == 'Police'
        end,

        func = function()
            TriggerEvent('PeopleEvidence')
        end
    },
    {
        name = 'Retrieve Items',
        icon = 'fas fa-book-dead',

        requires = function (pData)
            local data = pData.zone
            return data and data.name == 'reclaim'
        end,

        func = function()
            TriggerServerEvent('Jail.ReclaimGoods')
        end
    },
    {
        name =  uuid(),
        displayname = 'Elevator',
        icon = 'fas fa-door-closed',

        requires = function (pData)
            local data = pData.zone
            return data and data.elevator
        end,

        func = function(pData)
            TriggerEvent('Elevator', pData.zone)
        end
    },
    {
        name = 'police_notif',
        icon = 'fas fa-flag',
        displayname = 'Take Report',
        type = 1,

        requires = function ()
            return not IsEntityDead(_ent) and Entity(_ent).state.policenotif ~= nil
        end,

        func = function(data)
            TriggerEvent('Shared.Notif', ([[
                The person told me: %s
            ]]):format(Entity(_ent).state.policenotif), 10000, true)
        end
    },
    {
        name = 'police_pacify',
        icon = 'fas fa-flag',
        displayname = 'Calm Down',
        type = 1,

        requires = function ()
            return not IsEntityDead(_ent) and Entity(_ent).state.Pacify ~= nil and MyCharacter.Duty == 'Police'
        end,

        func = function(data)
            Task.RunRemote('Store.PacifyClerk', NetworkGetNetworkIdFromEntity(_ent))
        end
    },
    {
        name = 'Run Plate',
        icon = 'fas fa-car',
        type = 2,

        requires = function (data)
            return MyCharacter.Duty == 'Police'
            and (
                    Vdist3(GetOffsetFromEntityInWorldCoords(_ent, 0.0, data.max.y - 0.5, 0.0), data.ray.HitPosition) <= 1.0
                    or Vdist3(GetOffsetFromEntityInWorldCoords(_ent, 0.0, data.min.y + 0.5, 0.0), data.ray.HitPosition) <= 1.0
                )
        end,
 
        func = function()
             ExecuteCommand('runplate '..GetVehicleNumberPlateText(_ent))
        end
     },
     {
        name = 'Hood',
        icon = 'fas fa-car',
        type = 2,

        requires = function (data)
            local pos = GetOffsetFromEntityInWorldCoords(_ent, 0.0, data.max.y - 0.5, 0.0)
            return Vdist3(data.ray.HitPosition, pos) <= 0.75 and data.dist <= 2.0
        end,
 
        func = function()
             ExecuteCommand('hood')
        end
     },
     {
        name = 'Trunk',
        icon = 'fas fa-car',
        type = 2,

        requires = function (data)
            local pos = GetOffsetFromEntityInWorldCoords(_ent, 0.0, data.min.y + 0.5, 0.0)
            return Vdist3(data.ray.HitPosition, pos) <= 0.75 and data.dist <= 2.0
        end,
 
        func = function()
             ExecuteCommand('trunk')
        end
     },
     {
        name = 'Front Left Door',
        icon = 'fas fa-car',
        type = 2,

        requires = function (data)
            local pos = GetWorldPositionOfEntityBone(_ent, GetEntityBoneIndexByName(_ent, 'handle_dside_f'))
            return Vdist3(data.ray.HitPosition, pos) <= 0.25 and data.dist <= 2.0
        end,
 
        func = function()
             ExecuteCommand('door fl')
        end
     },
     {
        name = 'Back Left Door',
        icon = 'fas fa-car',
        type = 2,

        requires = function (data)
            local pos = GetWorldPositionOfEntityBone(_ent, GetEntityBoneIndexByName(_ent, 'handle_dside_r'))
            return Vdist3(data.ray.HitPosition, pos) <= 0.25 and data.dist <= 2.0
        end,
 
        func = function()
             ExecuteCommand('door bl')
        end
     },
     {
        name = 'Front Right Door',
        icon = 'fas fa-car',
        type = 2,

        requires = function (data)
            local pos = GetWorldPositionOfEntityBone(_ent, GetEntityBoneIndexByName(_ent, 'handle_pside_f'))
            return Vdist3(data.ray.HitPosition, pos) <= 0.25 and data.dist <= 2.0
        end,
 
        func = function()
             ExecuteCommand('door fr')
        end
     },
     {
        name = 'Back Right Door',
        icon = 'fas fa-car',
        type = 2,

        requires = function (data)
            local pos = GetWorldPositionOfEntityBone(_ent, GetEntityBoneIndexByName(_ent, 'handle_pside_r'))
            return Vdist3(data.ray.HitPosition, pos) <= 0.25 and data.dist <= 2.0
        end,
 
        func = function()
             ExecuteCommand('door br')
        end
     },
     {
        name = 'Check VIN',
        type = 2,
        icon = 'fas fa-car',

        requires = function (data)
            return MyCharacter.Duty == 'Police'
            and Vdist3(GetOffsetFromEntityInWorldCoords(_ent, data.min.x, 0.0, 0.0), data.ray.HitPosition) <= 0.5
        end,
 
        func = function(data)
            local vin = Entity(data.entity).state.vin
            if vin then
                TriggerEvent('Shared.Notif', 'Vehicle VIN: '..vin, 5000)
            else
                TriggerEvent('Shared.Notif', 'This vehicles VIN seems irrelevent')
            end
        end
     },
     {
        name = uuid(),
        displayname = 'Check Locks',
        type = 2,
        icon = 'fas fa-car',

        requires = function (data)
            return MyCharacter.Duty == 'Police'
            and Vdist3(GetOffsetFromEntityInWorldCoords(_ent, data.min.x, 0.0, 0.0), data.ray.HitPosition) <= 0.5
        end,
 
        func = function(data)
            local picked = Entity(data.entity).state.Lockpicked
            if picked then
                TriggerEvent('Shared.Notif', "The locks seem damaged", 5000)
            else
                TriggerEvent('Shared.Notif', "The locks don't seem damaged", 5000)
            end
        end
     },
     {
        name = 'Get In Trunk',
        icon = 'fas fa-car',
        type = 2,
        requires = function(data)
            return Shared.CurrentVehicle == 0 
            and GetVehicleDoorAngleRatio(_ent, 5) > 0 
            and not exports['geo-vehicle']:InTrunk()
            and Vdist3(GetEntityCoords(Shared.Ped), GetOffsetFromEntityInWorldCoords(_ent, 0.0, data.min.y, 0.0)) <= 3.0
        end,

        func = function()
            ExecuteCommand('getintrunk')
        end
    },
    {
        name = 'veh_inspect',
        icon = 'fas fa-car',
        displayname = 'Inspect Vehicle',
        type = 2,
        requires = function (data)
            return GetVehicleDoorAngleRatio(_ent, 4) > 0 and Vdist3(GetOffsetFromEntityInWorldCoords(_ent, 0.0, data.max.y - 0.5, 0.0), data.ray.HitPosition) <= 1.0
        end,
 
        func = function(data)
            TriggerEvent('InspectVehicle', _ent)
        end
    },
    {
        name = 'vehgps',
        icon = 'fas fa-car',
        displayname = 'Install LoJack',
        type = 2,
        requires = function (data)
            return Vdist3(GetOffsetFromEntityInWorldCoords(_ent, 0.0, data.max.y - 0.5, 0.0), data.ray.HitPosition) <= 1.0
            and exports['geo-inventory']:HasItemKey('gps')
        end,
 
        func = function(data)
            TriggerEvent('LoJack', _ent)
        end
    },
    {
        name = 'put_in_car',
        icon = 'fas fa-car',
        displayname = 'Place in Vehicle',
        type = 2,
        requires = function (data)
            if not MyCharacter.Dragging then return end
            if data.entity ~= 0 and IsEntityAVehicle(data.entity) and HasEntityClearLosToEntityInFront(Shared.Ped, data.entity) then
                return true
            end
        end,
 
        func = function(data)
            ExecuteCommand('putincar')
        end
    },
    {
        name = 'pull_out_car',
        icon = 'fas fa-car',
        displayname = 'Pull From Vehicle',
        type = 2,
        requires = function (data)
            if MyCharacter.Dragging then return end
            if data.entity ~= 0 and IsEntityAVehicle(data.entity) and HasEntityClearLosToEntityInFront(Shared.Ped, data.entity) then
                local player = GetClosestPlayer(5.0)
                if GetVehiclePedIsIn(GetPlayerPed(player)) == data.entity then
                    return true
                end
            end
        end,
 
        func = function(data)
            ExecuteCommand('pullout')
        end
    },
    {
        name = 'ATM',
        icon = 'fas fa-university',
        type = 3,
        requires = function ()
            local model = GetEntityModel(_ent)
            return (model == GetHashKey('prop_atm_01') or model == GetHashKey('prop_atm_02') or model == GetHashKey('prop_atm_03')) and Vdist3(GetEntityCoords(Shared.Ped), GetEntityCoords(_ent)) <= 2.0
        end,

        func = function()
            TriggerEvent('ATM')
        end
    },
    {
        name = '24/7',
        icon = 'fas fa-store',
        type = 3,
        requires = function ()
            return atStore and (GetEntityModel(_ent) == 303280717 and Vdist3(GetEntityCoords(Shared.Ped), GetEntityCoords(_ent)) <= 2.0)
        end,

        func = function()
            TriggerEvent('Convenience.JobStatus', atStore)
        end
    },
    {
        name = 'Warrant Board',
        icon = 'fas fa-gavel',
        requires = function (pData)
            local data = pData.zone
            return data and data.name == 'warrant_board'
        end,

        func = function()
            TriggerEvent('PD.WarrantBoard')
        end
    },
    {
        name = 'FleecaTerminal',
        icon = 'far fa-id-card',
        displayname = 'Swipe Card',
        requires = function (pData)
            local data = pData.zone
            return data and data.name == 'fleeca_vespucci'
        end,

        func = function(pData)
            TriggerEvent('Fleeca.Swipe', pData.zone)
        end
    },
    {
        name = 'FleecaTerminalClose',
        icon = 'fas fa-dungeon',
        displayname = 'Close Vault',
        requires = function (pData)
            local data = pData.zone
            return data and data.name == 'fleeca_vespucci' and MyCharacter.Duty == 'Police'
        end,

        func = function(pData)
            TriggerEvent('Fleeca.Close', pData.zone)
        end
    },
    {
        name = 'FleecaTerminalInner',
        icon = 'fas fa-hat-cowboy',
        displayname = 'Open Door',
        requires = function (pData)
            local data = pData.zone
            return data and data.name == 'fleeca_vaultinner'
        end,

        func = function()
            TriggerEvent('HackMe')
        end
    },
    {
        name = 'mdt_charges',
        icon = 'fas fa-gavel',
        displayname = 'View MDT Charges',
        requires = function (pData)
            local data = pData.zone
            return data and data.name == 'MDTCharges'
        end,

        func = function()
            TriggerEvent('MDT.Charges')
        end
    },
    {
        name = 'buy_id',
        icon = 'far fa-id-card',
        displayname = 'Buy ID Card $100',
        requires = function (pData)
            local data = pData.zone
            return data and data.name == 'MDTCharges'
        end,

        func = function()
            TriggerServerEvent('BuyIDCard')
        end
    },
    {
        name = 'gaterhing_node',
        icon = 'fas fa-feather',
        displayname = 'Gather',
        requires = function (pData)
            for k,v in pairs(GatheringNodes) do
                if Vdist3(pData.ray.HitPosition, v[1]) <= 3.0 and Vdist3(GetEntityCoords(Shared.Ped), v[1]) <= 3.0 then
                    return true
                end
            end
        end,

        func = function()
            TriggerEvent('Gathering.Harvest')
        end
    },
    {
        name = 'Angy Vehicle Owner',
        type = 1,
        icon = 'fas fa-user',

        requires = function ()
            return MyCharacter.Duty == 'Police' and not IsEntityDead(_ent) and Entity(_ent).state.angry
        end,

        func = function()
            TriggerEvent('Repo.Angy', _ent)
        end
    },
    {
        name =  uuid(),
        displayname = 'Triage',
        type = 1,
        icon = 'fas fa-user',

        requires = function (pData)
            return pData.dist <= 1.5 and MyCharacter.Duty == 'EMS' and IsPedAPlayer(_ent)
        end,

        func = function()
            TriggerServerEvent('EMS:Triage', GetPlayerServerId(NetworkGetPlayerIndexFromPed(_ent)))
        end
    },
    {
        name =  uuid(),
        displayname = 'Heal',
        type = 1,
        icon = 'fas fa-user',

        requires = function (pData)
            return pData.dist <= 1.5 and MyCharacter.Duty == 'EMS' and IsPedAPlayer(_ent)
        end,

        func = function()
            TriggerEvent('EMS.Heal', _ent)
        end
    },
    {
        name =  uuid(),
        displayname = 'Give Painkillers',
        type = 1,
        icon = 'fas fa-user',

        requires = function (pData)
            return pData.dist <= 1.5 and MyCharacter.Duty == 'EMS' and IsPedAPlayer(_ent) and exports['geo-inventory']:HasItem('pain_killer')
        end,

        func = function()
            TriggerServerEvent('EMS.Painkiller', GetPlayerServerId(NetworkGetPlayerIndexFromPed(_ent)))
        end
    },
    {
        name =  uuid(),
        displayname = 'Revive',
        type = 1,
        icon = 'fas fa-user',

        requires = function (pData)
            return pData.dist <= 1.5 and MyCharacter.Duty == 'EMS' and IsPedAPlayer(_ent) and Entity(_ent).state.dead == 1
        end,

        func = function()
            TriggerEvent('revive', NetworkGetPlayerIndexFromPed(_ent))
        end
    },
    {
        name =  uuid(),
        displayname = 'Body Bag',
        type = 1,
        icon = 'fas fa-user',

        requires = function (pData)
            return pData.dist <= 1.5 and (MyCharacter.Duty == 'EMS' or MyCharacter.Duty == 'Police') and IsEntityDead(_ent)
        end,

        func = function()
            ExecuteCommand('bodybag')
        end
    },
    {
        name =  uuid(),
        displayname = 'Triage',
        type = 1,
        icon = 'fas fa-user',

        requires = function (pData)
            return pData.dist <= 1.5 and (MyCharacter.Duty == 'EMS') and IsEntityDead(_ent) and not IsPedAPlayer(_ent)
        end,

        func = function()
            local evidence = Entity(_ent).state.evidence
            if evidence then
                evidence = json.decode(evidence)
                for k,v in pairs(evidence) do
                    TriggerEvent('Shared.Notif', v.hash..' ' ..v.Serial, 5000)
                end
            end
        end
    },
    {
        name =  uuid(),
        displayname = 'Breach',
        icon = 'fas fa-user',

        requires = function (pData)
            return pData.dist <= 1.5 and (MyCharacter.Duty == 'Police') and exports['geo-instance']:GetClosestPropertyData()
        end,

        func = function()
            TriggerServerEvent('BreachProperty', exports['geo-instance']:GetClosestPropertyData().pid)
        end
    },
    {
        name = uuid(),
        displayname = 'Take Vehicle',
        type = 2,
        icon = 'fas fa-car',

        requires = function (data)
            return Entity(_ent).state.owner == MyCharacter.id and Entity(_ent).state.fake
        end,
 
        func = function()
            Task.Run('TakeVehicle', NetworkGetNetworkIdFromEntity(_ent))
        end
     },
     {
        name = uuid(),
        displayname = 'Park Vehicle',
        type = 2,
        icon = 'fas fa-car',

        requires = function (data)
            return MyUser.data.parking and Entity(_ent).state.owner == MyCharacter.id and not Entity(_ent).state.fake
        end,
 
        func = function()
            TriggerServerEvent('Park', NetworkGetNetworkIdFromEntity(_ent))
        end
     },
}

function SetDisplayName(id, name)
    for k,v in pairs(_normalOptions) do
        if v.name == id then
            _normalOptions[k].displayname = name
            break
        end
    end
end


function SetPed(ped, title, pFunc, distance, params)
    for k,v in pairs(_selectOptions) do
        if v.pedid and v.pedid == ped then
            table.remove(_selectOptions, k)
            break
        end
    end

    if title == nil then return end

    table.insert(_selectOptions, {
        pedid = ped,
        name = uuid(),
        icon = 'fas fa-user',
        displayname = type(title) == 'table' and title() or title,
        type == 1,

        requires = function()
            return _ent == ped and Vdist3(GetEntityCoords(Shared.Ped), GetEntityCoords(ped)) <= (distance or 5.0)
        end,

        func = type(pFunc) ~= 'string' and pFunc or nil,
        event = type(pFunc) == 'string' and pFunc or nil,
        params = params
    })
end

function AddTargetZone(zone, title, event, params, distance, pIcon)
    local id = uuid()
    table.insert(_selectOptions, {
        name = id,
        icon = pIcon or 'fas fa-user',
        displayname = title,
        res = GetInvokingResource(),

        requires = function (pData)
            local data = pData.zone
            return data and data.name == zone and pData.dist <= (distance or 5.0)
        end,

        func = function(pData)
            TriggerEvent(event, table.unpack(params or {}))
        end
    })

    local data = {}
    data.remove = function(dontRemove)
        for k,v in pairs(_selectOptions) do
            if v.name == id then
                table.remove(_selectOptions, k)
                break
            end
        end
        if not dontRemove then
            TriggerEvent('RemoveZone', zone)
        end
    end

    return data
end

exports('AddTargetZone', AddTargetZone)

function AddTargetModel(modelHash, title, event, params, distance, pIcon)
    local id = uuid()
    table.insert(_selectOptions, {
        name = id,
        icon = pIcon or 'fas fa-user',
        displayname = title,
        res = GetInvokingResource(),

        requires = function(pData)
            return pData.model == modelHash and Vdist3(GetEntityCoords(Shared.Ped), GetEntityCoords(pData.entity)) <= (distance or 5.0)
        end,

        func = function(pData)
            TriggerEvent(event, table.unpack(params or {}), pData)
        end
    })

    local data = {}
    data.remove = function(dontRemove)
        for k,v in pairs(_selectOptions) do
            if v.name == id then
                table.remove(_selectOptions, k)
                break
            end
        end
    end

    return data
end

exports('AddTargetModel', AddTargetModel)

function AddTargetEntity(entity, title, event, params, data)
    local id = uuid()
    table.insert(_selectOptions, {
        name = id,
        icon = data and data.icon or 'fas fa-user',
        displayname = title,
        res = GetInvokingResource(),

        requires = function(pData)
            local val = true
            if data and data.req then
                val = data.req(pData)
            end

            return pData.entity == entity and val
        end,

        func = function(pData)
            table.insert(params, pData)
            TriggerEvent(event, table.unpack(params or {}))
        end
    })

    local data = {}
    data.remove = function(dontRemove)
        for k,v in pairs(_selectOptions) do
            if v.name == id then
                table.remove(_selectOptions, k)
                break
            end
        end
    end

    return data
end

exports('AddTargetEntity', AddTargetEntity)

local peds = {}
local ids = 0
function InterfacePed(data)
    local id = ids + 1
    ids = ids + 1
    local ped = Shared.SpawnPed(data.model, data.position, not (data.network or false))
    peds[id] = {ped, GetInvokingResource()}
    CreateThread(function()
        FreezeEntityPosition(ped,true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedCanBeTargetted(ped, false)

        if Vdist3(GetEntityCoords(Shared.Ped), vec(data.position.x, data.position.y, data.position.z)) > 200.0 then
            while (Vdist3(GetEntityCoords(Shared.Ped), vec(data.position.x, data.position.y, data.position.z)) >= 200.0) and DoesEntityExist(ped) do
                Wait(100)
            end
        end
       
        if not DoesEntityExist(ped) then return end
        while not HasCollisionLoadedAroundEntity(ped) do
            Wait(100)
        end

        SetEntityCoords(ped, GetEntityCoords(ped) - vec(0.0, 0.0, GetEntityHeightAboveGround(ped)))
        SetPed(ped, data.title, data.event, data.distance or 5.0, data.params)
        if data.scenario then
            TaskStartScenarioInPlace(ped, data.scenario, 0, true)
        end

        if data.network then
            Wait(100)
            TriggerServerEvent('Ped.Control', PedToNet(ped), true)
        end
    end)

    return id
end

function GetPed(id)
    return peds[id] and peds[id][1]
end

function RemovePed(dataid, bool)
    if not peds[dataid] then return end
    if NetworkGetEntityIsNetworked(peds[dataid][1]) then
        Shared.GetEntityControl(peds[dataid][1])
    end
    SetPed(peds[dataid][1])
    if bool then
        SetEntityAsNoLongerNeeded(peds[dataid][1])
        TaskWanderStandard(peds[dataid][1], 10.0, 10)
    else
        DeleteEntity(peds[dataid][1])
    end
    peds[dataid] = nil
end

exports('SetPed', SetPed)
exports('InterfacePed', InterfacePed)
exports('RemovePed', RemovePed)
exports('GetPed', GetPed)

AddEventHandler('Poly.Zone', function(zone, inZone, data)
    if zone == 'Store.Open' then
        if data.entry == 'ConvStore' then
            atStore = inZone
            if inZone then
                atStore = data.storeID
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        for k,v in pairs(peds) do
            SetPed(v[1])
            DeleteEntity(v[1])
            peds[k] = nil
        end
    else
        for k,v in pairs(peds) do
            if v[2] == res then
                SetPed(v[1])
                DeleteEntity(v[1])
                peds[k] = nil
            end
        end

        for i = #_selectOptions, 1, -1 do
            if _selectOptions[i].res == res then
                table.remove(_selectOptions, i)
            end
        end
    end
end)