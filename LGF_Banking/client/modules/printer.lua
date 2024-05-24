-- Tx admin particles

local PTFX_ASSET <const> = 'ent_dst_elec_fire_sp'
local PTFX_DICT <const> = 'core'
local LOOP_AMOUNT <const> = 600
local PTFX_DURATION <const> = 30000



function CreateFunction:ParticleFX(entity)
    CreateThread(function()
        if entity <= 0 or entity == nil then return end
        RequestNamedPtfxAsset(PTFX_DICT)

        while not HasNamedPtfxAssetLoaded(PTFX_DICT) do
            Wait(0)
        end

        local particleTbl = {}

        for i = 0, LOOP_AMOUNT do
            UseParticleFxAssetNextCall(PTFX_DICT)
            local partiResult = StartParticleFxNonLoopedOnEntity(PTFX_ASSET, entity, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0,
                false, false, false)
            particleTbl[#particleTbl + 1] = partiResult
            Wait(0)
        end

        Wait(PTFX_DURATION)
        for _, parti in ipairs(particleTbl) do
            StopParticleFxLooped(parti, true)
        end
    end)
end

RegisterNetEvent('LegacyBanking:SendSyncEffect', function(entity)
    CreateFunction:ParticleFX(entity)
end)

CreateFunction.PlaceObjectRaycast = function(Prop)
    local model = lib.requestModel(Prop)
    if not model then return end

    local playerCoords = GetEntityCoords(cache.ped)

    local PrinterProp = CreateObject(model, playerCoords.x, playerCoords.y, playerCoords.z, false, true, true)
    SetEntityAlpha(PrinterProp, 170, false)
    SetEntityCollision(PrinterProp, false, false)
    FreezeEntityPosition(PrinterProp, true)
    SetModelAsNoLongerNeeded(model)

    DisableControlAction(0, 24, true)
    DisableControlAction(0, 25, true)
    DisableControlAction(0, 140, true)
    DisableControlAction(0, 141, true)
    DisableControlAction(0, 142, true)

    while true do
        local hit, entityHit, coords, surface, hash = lib.raycast.cam(1, 7, 15)
        if not hit then return end

        SetEntityCoords(PrinterProp, coords)
        PlaceObjectOnGroundProperly(PrinterProp)
        DisableControlAction(0, 24, true)

        local placingPropHeading = GetEntityHeading(PrinterProp)

        if ZonePlant then
            DeleteEntity(PrinterProp)
            lib.hideTextUI()
            break
        end

        if IsControlPressed(0, 38) then
            SetEntityHeading(PrinterProp, placingPropHeading + 1)
        end

        if IsControlPressed(0, 44) then
            SetEntityHeading(PrinterProp, placingPropHeading - 1)
        end

        if IsControlJustPressed(0, 18) then
            DeleteEntity(PrinterProp)
            lib.hideTextUI()
            Wait(0)
            return coords, placingPropHeading
        end
    end
end

CreateFunction.CreatePrinterOnGround = function(data, slot)
    local Status = lib.callback.await('LegacyBanking:GetStatusBatteryDb', false)
    Shared:GetDebug(Status)
    EditableFunction:InstructionalButtonRaycast()
    local playerid = cache.serverId
    exports.ox_inventory:useItem(data, function(dataitem)
        if dataitem then
            Shared:GetDebug("dataitem.name", json.encode(dataitem.name))
        end
        local playerPed = cache.ped
        local anim = lib.requestAnimDict("pickup_object", 5000)
        local model = lib.requestModel("bzzz_electro_prop_3dprinter", 5000)
        lib.requestModel(model, 2000)
        lib.requestAnimDict(anim, 2000)
        TaskPlayAnim(playerPed, anim, "pickup_low", 8.0, 8.0, 1000, 50, 0, false, false, false)
        Wait(900)
        local stamposition, heading = CreateFunction.PlaceObjectRaycast(model)
        if stamposition then
            lib.hideTextUI()
            local itemID = dataitem.metadata.serial
            if not Status or (Status[1] and Status[1].serialNumber == itemID) then
                Stampante = CreateObjectNoOffset(model, stamposition.x, stamposition.y, stamposition.z, false, true )
                NetworkRegisterEntityAsNetworked(Stampante)
                PlaceObjectOnGroundProperly(Stampante)
                SetEntityAsMissionEntity(Stampante, true, true)
                SetEntityHeading(Stampante, heading)
                Entity(Stampante).state.Placed = true
                Shared:GetDebug("StateBag of", Stampante, "under key Placed", Entity(Stampante).state.Placed)
                EditableFunction:CreateBattery(itemID)
                Wait(100)
                local batteryStatus = EditableFunction:GetBatteryStatus(itemID)
                TriggerServerEvent('LegacyBanking:SendStatusBattery', playerid, itemID, batteryStatus, ObjToNet(Stampante))
                EditableFunction:SetObjectSpawnStatus(itemID, true)
                exports.ox_target:addLocalEntity(Stampante, {
                    {
                        icon = 'fa-solid fa-handcuffs',
                        label = Shared:GetKeyTraduction("OpenPrinter"),

                        onSelect = function()
                            CreateFunction.Menu3dPrinter(dataitem, itemID)
                        end
                    },
                    {
                        icon = 'fa-solid fa-handcuffs',
                        label = Shared:GetKeyTraduction("PickUpPrinter"),
                        onSelect = function()
                            local itemPrinter = EditableFunction:GetInventoryItem(dataitem.name)
                            if type(itemPrinter) == "number" and itemPrinter >= 1 then
                                print("You already have a printer in your inventory.")
                                return
                            end
                            TaskPlayAnim(playerPed, anim, "pickup_low", 8.0, 8.0, 1000, 50, 0, false, false, false)
                            Entity(Stampante).state.Placed = false
                            Shared:GetDebug("StateBag of", Stampante, "under key Placed", Entity(Stampante).state.Placed)
                            Wait(1000)
                            local Stamp2= ObjToNet(Stampante)
                            TriggerServerEvent('LegacyBanking:FakeTool:PickUpPrinter', dataitem.metadata.serial,
                                dataitem.metadata.description,Stamp2)
                            local batteryStatus = EditableFunction:GetBatteryStatus(itemID)
                            TriggerServerEvent('LegacyBanking:SendStatusBattery', playerid, itemID, batteryStatus, ObjToNet(Stampante))
                            EditableFunction:SetObjectSpawnStatus(itemID, false)
                        end
                    },
                })
            else
                print("You can only place the printer with the received serial.")
            end
        else
            Shared:GetDebug("No data found in the database. Allowing printer placement.")
            local itemID = dataitem.metadata.serial
            Stampante = CreateObjectNoOffset(model, stamposition.x, stamposition.y, stamposition.z, false, true )
            NetworkRegisterEntityAsNetworked(Stampante)
            PlaceObjectOnGroundProperly(Stampante)
            SetEntityAsMissionEntity(Stampante, true, true)
            SetEntityHeading(Stampante, heading)
            Entity(Stampante).state.Placed = true
            EditableFunction:CreateBattery(itemID)
            Wait(100)
            local batteryStatus = EditableFunction:GetBatteryStatus(itemID)
            TriggerServerEvent('LegacyBanking:SendStatusBattery', playerid, itemID, batteryStatus, ObjToNet(Stampante))
            EditableFunction:SetObjectSpawnStatus(itemID, true)
            exports.ox_target:addLocalEntity(Stampante, {
                {
                    icon = 'fa-solid fa-handcuffs',
                    label = Shared:GetKeyTraduction("OpenPrinter"),

                    onSelect = function()
                        CreateFunction.Menu3dPrinter(dataitem, itemID)
                    end
                },
                {
                    icon = 'fa-solid fa-handcuffs',
                    label = Shared:GetKeyTraduction("PickUpPrinter"),
                    onSelect = function()
                        local itemPrinter = EditableFunction:GetInventoryItem(dataitem.name)
                        if type(itemPrinter) == "number" and itemPrinter >= 1 then
                            print("You already have a printer in your inventory.")
                            return
                        end
                        TaskPlayAnim(playerPed, anim, "pickup_low", 8.0, 8.0, 1000, 50, 0, false, false, false)
                        Entity(Stampante).state.Placed = false
                        Wait(1000)
                        local Stamp = ObjToNet(Stampante)
                        TriggerServerEvent('LegacyBanking:FakeTool:PickUpPrinter', dataitem.metadata.serial,dataitem.metadata.description,Stamp)
                        local batteryStatus = EditableFunction:GetBatteryStatus(itemID)
                        TriggerServerEvent('LegacyBanking:SendStatusBattery', playerid, itemID, batteryStatus, ObjToNet(Stampante),true)
                        EditableFunction:SetObjectSpawnStatus(itemID, false)
                    end
                },
            })
        end
    end)
end

CreateFunction.MenuAdminPrinter = function()
    local DataPrinter = lib.callback.await('LegacyBanking:GetallBatteryData', false)

    local options = {}

    for index, printer in ipairs(DataPrinter) do
        table.insert(options, {
            title = "Stampante " .. index,
            description = Shared:GetKeyTraduction("OwnerPrinter"):format(printer.playerName) .. "\n" ..
                Shared:GetKeyTraduction("PrinterBatteryDesc"):format(printer.batteryStatus) .. '%' .. "\n" ..
                Shared:GetKeyTraduction("SerialNumber"):format(printer.serialNumber),
            icon = "fa-solid fa-print",
            onSelect = function()
                CreateFunction.OpenPrinterData(printer)
            end
        })
    end

    lib.registerContext({
        id = 'menu_stampanti',
        title = Shared:GetKeyTraduction("3dMenuHeader"),
        options = options,
        canClose = true,
        onExit = function()
            EditableFunction:DestroyCamera()
        end
    })

    lib.showContext('menu_stampanti')
end


function CreateFunction.OpenPrinterData(printer)
    Shared:GetDebug('printer data', printer)
    local printerOptions = {
        {
            title = Shared:GetKeyTraduction('ReloadPrinterMenu'),
            description = Shared:GetKeyTraduction("ReloadPrinterMenudesc"),
            icon = "fa-solid fa-charging-station",
            onSelect = function()
                local ReloadInput = lib.inputDialog('Recharge Printer', {
                    { type = 'number', label = 'Set Battery Status', description = 'Set Specific Battery status for printer' .. ' '..printer.serialNumber, icon = 'hashtag', min = 0, max = 100 },
                })
                if not ReloadInput then return end
                local BatteryStatus = ReloadInput[1]
                EditableFunction:SetBatteryStatus(printer.serialNumber , BatteryStatus)
                Shared:GetDebug('printer seriale' , printer.serialNumber)
                Shared:GetDebug('new printer battery by input')
                TriggerServerEvent('LegacyBanking:ReloadByMenuRPrinter',BatteryStatus, printer.identifier, printer.serialNumber )
            end
        },
        {
            title = Shared:GetKeyTraduction("DeletePrint"),
            description = Shared:GetKeyTraduction("DeletePrintDesc"),
            icon = "fa-solid fa-trash-alt",
            onSelect = function()
                local netId = printer.netId
                Shared:GetDebug("netId", netId)
                TriggerServerEvent('LegacyBanking:DestroyPrinterMenu', netId, printer.identifier, printer.serialNumber)
            end
        },
        {
            title = Shared:GetKeyTraduction("TeleportPrinter"),
            description = Shared:GetKeyTraduction("TeleportPrinterDesc"),
            icon = "fa-solid fa-trash-alt",
            onSelect = function()
                local id = NetworkGetEntityFromNetworkId(printer.netId)
                local stamp = GetEntityCoords(id)
                SetEntityCoordsNoOffset(cache.ped,stamp)
            end
        }
    }

    lib.registerContext({
        id = 'menu_printer_' .. printer.serialNumber,
        title = "Printer Menu " .. printer.serialNumber,
        options = printerOptions,
        menu = 'menu_stampanti',
        canClose = true,
    })

    lib.showContext('menu_printer_' .. printer.serialNumber)
end

RegisterNetEvent('LegacyBanking:OpenMenuDataPrinter', function()
    CreateFunction.MenuAdminPrinter()
end)

function CreateFunction.Menu3dPrinter(dataitem, itemID)
    local BatteryData = EditableFunction:GetBatteryStatusByDb()
    local playerid = cache.serverId
    local isBatteryEmpty = BatteryData.battery <= 20
    local isBatteryFull = BatteryData.battery >= 20
    local weatherDescription = ""
    local warningDescription = ""
    local weather

    if isBatteryEmpty then
        EditableFunction:ClientNotification('batteria Scarica', "Error", "fa-solid fa-exclamation-triangle")
    end

    if CB.GetWeatherStatusPrinter then
        local currentWeather = GetWeatherTypeTransition()
        weatherDescription = "\nCurrent Weather: " .. EditableFunction:GetWeatherTypeNameFromHash(currentWeather)
        weather = EditableFunction:IsRaining(currentWeather)
        warningDescription = weather and "\nWarning: It's raining!" or ""
    end

    lib.registerContext({
        id = '3d_printer_menu',
        title = Shared:GetKeyTraduction('3dMenu'),
        options = {
            {
                readOnly = true,
                title = Shared:GetKeyTraduction('3dMenuHeader'),
                description = string.format(Shared:GetKeyTraduction('SerialNumber'), dataitem.metadata.serial) ..
                    ' \n' .. dataitem.metadata.description ..
                    ' \n' .. 'Battery: ' .. ' ' .. BatteryData.battery .. '%' ..
                    weatherDescription ..
                    warningDescription,
                icon = 'fa-solid fa-info-circle',
            },

            {
                title = Shared:GetKeyTraduction('StartPrinterCraft'),
                description = Shared:GetKeyTraduction('StartPrinterDescription'),
                icon = 'fa-solid fa-print',
                disabled = isBatteryEmpty or (CB.GetWeatherStatusPrinter and weather),
                onSelect = function()
                    CreateFunction.Menu3dPrinterItem()
                end
            },
            {
                title = Shared:GetKeyTraduction('RestoreBattery'),
                description = Shared:GetKeyTraduction('RestoreBatteryDesc'),
                disabled = isBatteryFull,
                icon = 'fa-solid fa-print',
                onSelect = function()
                    local ItemRequestedBattery = EditableFunction:GetInventoryItem(CB.ItemBattery)
                    local BatteryStatusNow = EditableFunction:GetBatteryStatus(dataitem.metadata.serial)
                    if BatteryStatusNow >= 20 then
                        return print('batteria sopra il 20 per ' .. itemID)
                    end

                    if type(ItemRequestedBattery) == "number" and ItemRequestedBattery >= 1 then
                        EditableFunction:RestoredBatteryPrinter(dataitem.metadata.serial)
                        TriggerServerEvent('LegacyBanking:RemoveBatteryItem', playerid, CB.ItemBattery)
                    else
                        EditableFunction:ClientNotification(Shared:GetKeyTraduction("NotEnoughItem"), "Error",
                            "fa-solid fa-exclamation-triangle")
                    end
                end,
                metadata = {
                    { label = 'Serial Number',                                value = dataitem.metadata.serial },
                    { label = 'Battery' .. ' ' .. BatteryData.battery .. '%', progress = BatteryData.battery,  colorScheme = 'orange' }
                }
            },
            {
                title = Shared:GetKeyTraduction('DestroyPrinter'),
                description = Shared:GetKeyTraduction('DestroyPrinterDesc'),
                icon = 'fa-solid fa-print',
                onSelect = function()
                    local item = CB.ItemProviderWipe
                    local itemData = EditableFunction:GetInventoryItem(item)
                    if type(itemData) == "number" and itemData >= 1 then
                        EditableFunction:DeleteBatteryProgress()
                        DeleteEntity(Stampante)
                        TriggerServerEvent('LegacyBanking:DestroyPrinter', playerid, dataitem.metadata.serial)
                        EditableFunction:SetObjectSpawnStatus(dataitem.metadata.serial, false)
                        EditableFunction:DeleteBattery(dataitem.metadata.serial)
                    else
                        EditableFunction:ClientNotification(Shared:GetKeyTraduction("NotEnoughItemy"), "Error",
                            "fa-solid fa-exclamation-triangle")
                    end
                end
            },
        }
    })

    lib.showContext('3d_printer_menu')
end

function CreateFunction.Menu3dPrinterItem()
    local CoordsPrinter = GetEntityCoords(Stampante)
    local options = {}
    for _, item in ipairs(CB.CraftingPrinter) do
        table.insert(options, {
            title = item.Label,
            description = item.Description,
            image = 'nui://ox_inventory/web/images/' .. item.itemHash .. '.png',
            icon = 'nui://ox_inventory/web/images/' .. item.itemHash .. '.png',
            metadata = {
                { label = Shared:GetKeyTraduction('RequiredItem'),   value = item.ItemRequestedPrint },
                { label = Shared:GetKeyTraduction('QuantityNeeded'), value = item.ItemRequestedQnt },
                { label = Shared:GetKeyTraduction('CraftingTime'),   value = item.CraftingTime }
            },
            onSelect = function()
                local itemData = EditableFunction:GetInventoryItem(item.ItemRequestedPrint)
                if type(itemData) == "number" and itemData >= item.ItemRequestedQnt then
                    Shared:GetDebug(string.format("Selected to craft %s with %d %s", item.ItemRequestedPrint,
                        item.ItemRequestedQnt, item.ItemRequestedPrint))
                    local x, y, z = table.unpack(CoordsPrinter)
                    local object = CreateObject(item.propHash, x, y, z + 0.70, true, true, true)
                    EditableFunction:CreateCamWeapon(object)
                    TriggerServerEvent('LegacyBanking:svSendSyncEffect', CoordsPrinter, Stampante)
                    EditableFunction:ProgressHackingCoolDown('Developing a .. ' .. item.Label, item.CraftingTime * 1000)
                    DeleteEntity(object)
                    EditableFunction:DestroyCamera()
                    TriggerServerEvent('LegacyBanking:printer:CraftingTools', item.itemHash, item.ItemRequestedQnt,
                        item.ItemRequestedPrint)
                else
                    Shared:GetDebug('Not enough required item in inventory')
                end
            end
        })
    end

    lib.registerContext({
        id = '3d_printer_item_menu',
        title = Shared:GetKeyTraduction('SelectItemToPrint'),
        menu = '3d_printer_menu',
        options = options
    })

    lib.showContext('3d_printer_item_menu')
end

exports('ToolCraftingItems', CreateFunction.CreatePrinterOnGround)
