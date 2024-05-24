---@diagnostic disable: need-check-nil, undefined-field, missing-parameter

if not lib.checkDependency('ox_lib', '3.21.0', true) or not lib.checkDependency('ox_inventory', '2.40.0', true) then
    return warn('Obsolete Version, Download Latest versions for a safe approach')
end

local LGF = GetResourceState('LegacyFramework'):find('start') and exports['LegacyFramework']:ReturnFramework() or nil
local ESX = GetResourceState('es_extended'):find('start') and exports['es_extended']:getSharedObject() or nil
local QBCore = GetResourceState('qb-core'):find('start') and exports['qb-core']:GetCoreObject() or nil
local Shared = require 'utils.shared'
local StampEntity = {}
RegisterNetEvent('LegacyBanking:ChangePin', function(playerid, newpin)
    local playerId = source
    local currentDateTime = os.date("%Y-%m-%d %H:%M:%S")
    if CB.ProviderCore == 'lgf' then
        local PlayerData = LGF.SvPlayerFunctions.GetPlayerData(playerId)[1]
        local identifier = PlayerData.charName
        local function insertOrUpdatePin(identifier, pin)
            MySQL.scalar('SELECT COUNT(*) FROM lgf_banking WHERE identifier = ?', { identifier }, function(pinCount)
                local query
                local params

                if pinCount > 0 then
                    query = 'UPDATE lgf_banking SET pin = ?, last_updated = ? WHERE identifier = ?'
                    params = { pin, currentDateTime, identifier }
                else
                    query = 'INSERT INTO lgf_banking (identifier, pin, last_updated) VALUES (?, ?, ?)'
                    params = { identifier, pin, currentDateTime }
                end

                MySQL.execute(query, params, function(rowsAffected)
                    if pinCount > 0 then
                        Shared:GetDebug("PIN updated. Rows affected: ", rowsAffected)
                    else
                        Shared:GetDebug("New PIN inserted. Insert ID: ", rowsAffected)
                    end
                end)
            end)
        end

        insertOrUpdatePin(identifier, newpin)
        Wait(50)
        -- Player(playerId).state['pin'] = newpin
        -- Shared:GetDebug("New pin state bag:", Player(playerId).state['pin'])
    end
    if CB.ProviderCore == 'esx' then
        local identifier = ESX.GetIdentifier(playerId)
        local function insertOrUpdatePin(identifier, pin)
            MySQL.scalar('SELECT COUNT(*) FROM lgf_banking WHERE identifier = ?', { identifier }, function(pinCount)
                local query
                local params

                if pinCount > 0 then
                    query = 'UPDATE lgf_banking SET pin = ?, last_updated = ? WHERE identifier = ?'
                    params = { pin, currentDateTime, identifier }
                else
                    query = 'INSERT INTO lgf_banking (identifier, pin, last_updated) VALUES (?, ?, ?)'
                    params = { identifier, pin, currentDateTime }
                end

                MySQL.execute(query, params, function(rowsAffected)
                    if pinCount > 0 then
                        Shared:GetDebug("PIN updated. Rows affected: ", rowsAffected)
                    else
                        Shared:GetDebug("New PIN inserted. Insert ID: ", rowsAffected)
                    end
                end)
            end)
        end

        insertOrUpdatePin(identifier, newpin)
        Wait(50)
        -- Player(playerId).state['pin'] = newpin
        -- Shared:GetDebug("New pin state bag:", Player(playerId).state['pin'])
    end
    if CB.ProviderCore == 'qb' then
    end
end)

lib.callback.register('LegacyBanking:CheckPinStatus', function(src, cb)
    local player = src
    -- local item = exports.ox_inventory:GetItemCount(player, CB.ItemCreditCard)
    -- if item > 0 then
    if CB.ProviderCore == 'lgf' then
        local PlayerData = LGF.SvPlayerFunctions.GetPlayerData(player)[1]
        local identifier = PlayerData.charName
        local Pin = MySQL.query.await('SELECT pin FROM lgf_banking WHERE identifier = ?', { identifier })
        return Pin
    end
    if CB.ProviderCore == 'esx' then
        local identifier = ESX.GetIdentifier(src)
        local Pin = MySQL.query.await('SELECT pin FROM lgf_banking WHERE identifier = ?', { identifier })
        return Pin
    end
    if CB.ProviderCore == 'qb' then

    end
    -- else
    --     print('non hai carta di credito')
    -- end
end)

RegisterNetEvent('LegacyBanking:WithdrawMoney', function(quantity)
    local src = source
    local ItemLGF = 'money'
    local ItemESX = 'money'
    if CB.ProviderCore == 'lgf' then
        local bankMoney = LGF.SvPlayerFunctions.GetPlayerMoneyBank(src)
        if bankMoney >= quantity then
            local newBankMoney = bankMoney - quantity
            exports.ox_inventory:AddItem(src, ItemLGF, quantity)
            local playerData = LGF.SvPlayerFunctions.GetPlayerData(src)
            local moneyAccounts = json.decode(playerData[1].moneyAccounts)
            moneyAccounts.Bank = newBankMoney
            local newMoneyAccounts = json.encode(moneyAccounts)
            LGF.SvPlayerFunctions.SetPlayerData(src, "moneyAccounts", newMoneyAccounts)
        else
            SvEditableFunction:ServerNotification(src,
                "You do not have enough money in your bank account to withdraw this amount.", "Error",
                "fa-solid fa-exclamation-triangle")
        end
    end
    if CB.ProviderCore == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        local Account = xPlayer.getAccount('bank').money
        if Account >= quantity then
            exports.ox_inventory:AddItem(src, ItemESX, quantity)
            xPlayer.removeAccountMoney('bank', quantity)
        else
            SvEditableFunction:ServerNotification(src,
                "You do not have enough money in your bank account to withdraw this amount.", "Error",
                "fa-solid fa-exclamation-triangle")
        end
    end
    if CB.ProviderCore == 'qb' then
    end
end)

RegisterNetEvent('LegacyBanking:DepositMoney', function(quantity)
    local src = source
    local ItemLGF = 'money'
    local ItemESX = 'money'
    if CB.ProviderCore == 'lgf' then
        local itemCount = exports.ox_inventory:GetItemCount(src, ItemLGF)
        if itemCount >= quantity then
            exports.ox_inventory:RemoveItem(src, ItemLGF, quantity)
            local playerData = LGF.SvPlayerFunctions.GetPlayerData(src)
            if playerData and playerData[1] then
                local moneyAccounts = json.decode(playerData[1].moneyAccounts)
                moneyAccounts.Bank = moneyAccounts.Bank + quantity
                local newMoneyAccounts = json.encode(moneyAccounts)
                LGF.SvPlayerFunctions.SetPlayerData(src, "moneyAccounts", newMoneyAccounts)
            else
                print("Impossibile ottenere i dati del giocatore con ID " .. src)
            end
        else
            SvEditableFunction:ServerNotification(src, "You do not have enough money to deposit this amount.", "Error",
                "fa-solid fa-exclamation-triangle")
        end
    end
    if CB.ProviderCore == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        local cash = exports.ox_inventory:GetItemCount(src, ItemESX)
        if cash >= quantity then
            exports.ox_inventory:RemoveItem(src, ItemESX, quantity)
            xPlayer.addAccountMoney('bank', quantity)
        else
            SvEditableFunction:ServerNotification(src,
                "You do not have enough money in your bank account to deposit this amount.", "Error",
                "fa-solid fa-exclamation-triangle")
        end
    end
    if CB.ProviderCore == 'qb' then
    end
end)

RequestCreditCard = function(player, metadata)
    local item = CB.ItemCreditCard
    local priceCreditCard = CB.PriceCreditCard
    local date = os.date("%Y-%m-%d")
    local time = os.date("%H:%M:%S")
    local playerName

    if CB.ProviderCore == 'lgf' then
        local playerData = LGF.SvPlayerFunctions.GetPlayerData(player)[1]
        playerName = string.format("%s %s", playerData.firstName, playerData.lastName)
    elseif CB.ProviderCore == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(player)
        if xPlayer then
            playerName = string.format("%s %s", xPlayer.get("firstName"), xPlayer.get("lastName"))
        end
    elseif CB.ProviderCore == 'qb' then
        local QbPlayer = QBCore.Functions.GetPlayer(player)
        playerName = string.format("%s %s", QbPlayer.charinfo.firstname, QbPlayer.charinfo.lastname)
    end

    local itemAlreadyInInventory = exports.ox_inventory:GetItemCount(player, item) > 0

    if itemAlreadyInInventory then
        Shared:GetDebug("Il giocatore possiede già una carta di credito.")
        return false
    end

    if exports.ox_inventory:GetItemCount(player, 'money') >= priceCreditCard then
        exports.ox_inventory:RemoveItem(player, 'money', priceCreditCard)
        metadata = metadata or {}
        metadata.label = playerName
        metadata.description = "Owner: " ..
            playerName .. '  \n' .. "Date Released: " .. date .. '  \n' .. "Hour Released: " .. time
        metadata.type = "Credit Card"
        exports.ox_inventory:AddItem(player, item, 1, metadata)
        Shared:GetDebug("Carta di credito aggiunta all'inventario del giocatore.")
        return true
    else
        Shared:GetDebug("Il giocatore non ha abbastanza denaro per acquistare la carta di credito.")
        return false
    end
end

RegisterNetEvent('LegacyBanking:RequestCreditCard', function()
    local player = source
    local success = RequestCreditCard(player)
    if not success then
        SvEditableFunction:ServerNotification(player,
            "You don't have enough money to buy a credit card or you have already 1 card", "Error",
            "fa-solid fa-exclamation-triangle")
    end
end)

lib.callback.register('LegacyBanking:GetPlayerMoneyBank', function(src, cb)
    local player = src
    if CB.ProviderCore == 'lgf' then
        local PlayerData = LGF.SvPlayerFunctions.GetPlayerData(player)
        if PlayerData and PlayerData[1] then
            local moneyAccounts = json.decode(PlayerData[1].moneyAccounts)
            if moneyAccounts then
                return moneyAccounts
            else
                Shared:GetDebug("Failed to retrieve moneyAccounts!!.")
            end
        else
            Shared:GetDebug("Failed to retrieve player data!!.")
        end
    end
    if CB.ProviderCore == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(player)
        local Account = xPlayer.getAccount('bank').money
        return Account
    end
    if CB.ProviderCore == 'qb' then
    end
end)

lib.callback.register('LegacyBanking:GetSocietyFound', function(source)
    local Society = {}

    if CB.ProviderCore == 'lgf' then
        local playerData = LGF.SvPlayerFunctions.GetPlayerData(source)[1]
        local PlayerJob = playerData.nameJob
        Society = exports.LGF_Society:GetSocietyFounds(PlayerJob)
    elseif CB.ProviderCore == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            local PlayerJob = xPlayer.job.name
            Society = exports.esx_society:GetSociety(PlayerJob)
            TriggerEvent('esx_addonaccount:getSharedAccount', PlayerJob, function(account)
                local result = account and account?.money or 0
                Society[PlayerJob] = { founds = result }
            end)
        end
    elseif CB.ProviderCore == 'qb' then

    end


    return Society
end)

RegisterNetEvent('LegacyBanking:RemoveSocietyFounds', function(societyName, founds)
    local src = source
    local Society = nil
    if CB.ProviderCore == 'lgf' then
        Society = exports.LGF_Society:GetSocietyFounds(societyName)
    elseif CB.ProviderCore == 'esx' then
        local xPlayer = src and ESX.GetPlayerFromId(src) or nil
        Society = string.format("society_%s", societyName or xPlayer?.job?.name)
    elseif CB.ProviderCore == 'qb' then
    end

    if Society and Society.founds >= founds then
        if CB.ProviderCore == 'lgf' then
            exports.LGF_Society:RemoveSocietyFounds(societyName, founds)
        elseif CB.ProviderCore == 'esx' then
            TriggerEvent("esx_addonaccount:getSharedAccount", Society, function(account)
                if account.money >= founds then
                    account.removeMoney(founds)
                else
                    SvEditableFunction:ServerNotification(src, "You do not have enough money to withdraw.", "Error",
                        "fa-solid fa-exclamation-triangle")
                end
            end)
        elseif CB.ProviderCore == 'qb' then

        end
        exports.ox_inventory:AddItem(src, 'money', founds)
    else
        SvEditableFunction:ServerNotification(src, "You do not have enough money to withdraw.", "Error",
            "fa-solid fa-exclamation-triangle")
    end
end)

RegisterNetEvent('LegacyBanking:AddSocietyFounds', function(societyName, founds)
    local src = source
    local itemFound = exports.ox_inventory:GetItemCount(src, 'money')

    if itemFound >= founds then
        if CB.ProviderCore == 'lgf' then
            exports.LGF_Society:UpdateSocietyFounds(societyName, founds)
        elseif CB.ProviderCore == 'esx' then
            local xPlayer = ESX.GetPlayerFromId(src)
            local society = string.format("society_%s", xPlayer.job.name)

            TriggerEvent("esx_addonaccount:getSharedAccount", society, function(account)
                account.removeMoney(founds)
                xPlayer.addAccountMoney('money', founds)
            end, societyName, founds)
        elseif CB.ProviderCore == 'qb' then

        end
        exports.ox_inventory:RemoveItem(src, 'money', founds)
    else
        SvEditableFunction:ServerNotification(src, "You do not have enough money to deposit this amount.", "Error",
            "fa-solid fa-exclamation-triangle")
    end
end)

RegisterNetEvent('LegacyBanking:GetFakeCard:DeletePin', function(nameZone)
    local player = source
    local dataZone = CB.FakeCreditCard[nameZone]
    local PriceDelete = dataZone.PriceHackPin
    local Identifier

    if CB.ProviderCore == 'lgf' then
        local PlayerData = LGF.SvPlayerFunctions.GetPlayerData(player)[1]
        Identifier = PlayerData.charName
    elseif CB.ProviderCore == 'esx' then
        local identifier = ESX.GetIdentifier(player)
        Identifier = identifier
    elseif CB.ProviderCore == 'qb' then

    end

    if Identifier then
        if exports.ox_inventory:GetItemCount(player, 'money') >= PriceDelete then
            MySQL.execute('DELETE FROM lgf_banking WHERE identifier = ?', { Identifier }, function(rowsAffected)
                Shared:GetDebug("PIN deleted for player with identifier: ", Identifier)
                exports.ox_inventory:RemoveItem(player, 'money', PriceDelete)
            end)
        else
            SvEditableFunction:ServerNotification(player, "You don't have enough money to delete the PIN.", "Error",
                "fa-solid fa-exclamation-triangle")
        end
    else
        Shared:GetDebug("Unable to get player identifier for PIN deletion.")
    end
end)

ChangePin = function(data)
    local currentDateTime = os.date("%Y-%m-%d %H:%M:%S")
    local identifier = data.identifier
    local newPin = data.pin

    if not identifier or not newPin then
        Shared:GetDebug("Errore: identificatore o nuovo PIN mancanti.")
        return
    end

    MySQL.scalar('SELECT COUNT(*) FROM lgf_banking WHERE identifier = ?', { identifier }, function(pinCount)
        if pinCount > 0 then
            MySQL.execute('UPDATE lgf_banking SET pin = ?, last_updated = ? WHERE identifier = ?',
                { newPin, currentDateTime, identifier }, function(rowsAffected)
                    if rowsAffected then
                        Shared:GetDebug("PIN aggiornato con successo per l'identificatore:", identifier)
                    else
                        Shared:GetDebug("Errore durante l'aggiornamento del PIN per l'identificatore:", identifier)
                    end
                end)
        else
            Shared:GetDebug("Identificatore non trovato nella tabella lgf_banking:", identifier)
        end
    end)
end

RegisterNetEvent('LegacyBanking:GetFakeCard', function(label, desc, type, price, Weight, date)
    local _source = source
    local hour = os.date("%H:%M:%S")
    local moneyAmount = exports.ox_inventory:GetItemCount(_source, 'money')
    if moneyAmount >= price then
        exports.LGF_Banking:CreateCreditCard(_source, {
            label = label,
            description = 'Owned: ' .. desc .. '  \n' .. "Date Released: " .. date .. '  \n' .. "Hour Released: " .. hour,
            type = type,
            price = price,
            itemHash = CB.ItemFakeCreditCard,
            weight = Weight,
            imageUrl = 'nui://ox_inventory/data/images/fake_credit_card.png'
        })
    else
        print("Non hai abbastanza soldi per acquistare la carta falsa.")
    end
end)

CreateCreditCard = function(player, price, metadata)
    metadata = metadata or {}
    metadata.label = metadata.label or 'Credit Card'
    metadata.description = metadata.description or "Owner: Unknown"
    metadata.type = metadata.type or "Credit Card"
    metadata.itemHash = metadata.itemHash or CB.ItemCreditCard
    metadata.weight = metadata.weight or 10
    metadata.image = metadata.image
    if exports.ox_inventory:GetItemCount(player, 'money') >= price then
        exports.ox_inventory:RemoveItem(player, 'money', price)
        exports.ox_inventory:AddItem(player, metadata.itemHash, 1, metadata)
        return true
    else
        return false
    end
end

GetRandomItem = function(robberyDropTable)
    assert(next(robberyDropTable), "Error: robberyDropTable is empty")

    local keys = {}
    for key, _ in pairs(robberyDropTable) do
        table.insert(keys, key)
    end

    local randomKey = keys[math.random(1, #keys)]
    local randomItemData = robberyDropTable[randomKey]

    local minAmount = randomItemData.min
    local maxAmount = randomItemData.max
    return randomKey, minAmount, maxAmount
end

RegisterNetEvent('LegacyBanking:StealMoneyDropCash', function(ZoneRob)
    local ZoneData = CB.BankingZone[ZoneRob]
    local player = source
    local itemRequested = ZoneData.ItemRequestedRobbery
    local itemQuantity = ZoneData.QntItemRequested

    if exports.ox_inventory:GetItemCount(player, itemRequested) >= itemQuantity then
        exports.ox_inventory:RemoveItem(player, itemRequested, itemQuantity)
        local randomItem, minAmount, maxAmount = GetRandomItem(ZoneData.RobberyDrop)
        local randomQuantity = math.random(minAmount, maxAmount)
        exports.ox_inventory:AddItem(player, randomItem, randomQuantity)
    else
        print('You do not have the requested item or the required quantity.')
    end
end)

RegisterNetEvent('LegacyBanking:DispatchRobbery', function(ZoneDis, playerCoords)
    local zoneDisp = CB.BankingZone[ZoneDis]
    local promise = promise.new()
    Shared:GetDebug("dispatch called")
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        SvEditableFunction:SignalDispatch(playerId, playerCoords)
    end
    promise:resolve()
end)

RegisterNetEvent('LegacyBanking:hackingCoolDown', function(src)
    local itemReducer = 'tool_hack_cooldown'

    local itemData = exports.ox_inventory:GetItemCount(src, itemReducer)
    if CB.RemoveReducerItem == 'remove' then
        if itemData >= 1 then
            exports.ox_inventory:RemoveItem(src, itemReducer, 1)
        else
            print('Non hai l\'oggetto necessario per ridurre il cooldown')
        end
    elseif CB.RemoveReducerItem == 'consume' then
        return print('add Degrade if you dont have')
    end
end)

RegisterNetEvent('LegacyBanking:BuyToolsInShop', function(playerId, item, quantity, pricePerItem)
    local src = source
    local ItemCash = 'money'
    local printerItem = 'tool_3dprint'
    local PlayerName = GetPlayerName(playerId)

    if CB.ProviderCore == 'lgf' then
        local playerData = LGF.SvPlayerFunctions.GetPlayerData(src)[1]
        PlayerName = playerData.firstName .. ' ' .. playerData.lastName
    elseif CB.ProviderCore == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            PlayerName = string.format("%s %s", xPlayer.get("firstName"), xPlayer.get("lastName"))
        end
    elseif CB.ProviderCore == 'qb' then
    end

    local totalPrice = pricePerItem * quantity
    local moneyData = exports.ox_inventory:GetItemCount(src, ItemCash)
    local printerCount = exports.ox_inventory:GetItemCount(src, printerItem)

    if moneyData >= totalPrice then
        if item == printerItem and printerCount >= 1 then
            SvEditableFunction:ServerNotification(src, "You already have a 3D printer tool", "Error",
                "fa-solid fa-exclamation-triangle")
            return
        end

        exports.ox_inventory:RemoveItem(src, ItemCash, totalPrice)

        if item == printerItem then
            for i = 1, quantity do
                local GenerateSerial = SvEditableFunction:CreateSerialNumber()
                local Metadata = {
                    serial = GenerateSerial,
                    description = Shared:GetKeyTraduction('Owner'):format(PlayerName)
                }
                exports.ox_inventory:AddItem(src, item, 1, Metadata)
            end
        else
            exports.ox_inventory:AddItem(src, item, quantity)
        end

        SvEditableFunction:ServerNotification(src,
            Shared:GetKeyTraduction("PurchaseSuccess"):format(item .. ' x' .. quantity), "Success", "fa-solid fa-check")
    else
        SvEditableFunction:ServerNotification(src,
            Shared:GetKeyTraduction("NotEnoughMoney"):format(item .. ' x' .. quantity), "Error",
            "fa-solid fa-exclamation-triangle")
    end
end)

RegisterNetEvent('LegacyBanking:svSendSyncEffect', function(coords, stampante)
    local src = source
    local playerNearby = lib.getNearbyPlayers(coords, 20, true)
    for _, v in ipairs(playerNearby) do
        TriggerClientEvent('LegacyBanking:SendSyncEffect', v.id, stampante)
        Shared:GetDebug("svSendSyncEffect", json.encode(v))
    end
end)

RegisterNetEvent('LegacyBanking:FakeTool:PickUpPrinter', function(serial, description, netid)
    Shared:GetDebug('diocane printa ',netid)
    local Identifier
    local src = source
    local item = 'tool_3dprint'
    exports.ox_inventory:AddItem(src, item, 1, { serial = serial, description = description })
    if CB.ProviderCore == 'lgf' then
        local Player = LGF.SvPlayerFunctions.GetPlayerData(src)[1]
        Identifier = Player.charName
    elseif CB.ProviderCore == "esx" then
        local PlayerData = ESX.GetPlayerFromId(src)
        Identifier = PlayerData.identifier
    elseif CB.ProviderCore == "qb" then
    end

    if playerIdentifier == nil then print("[^1WARNING^7] No player Identifier cancelling") return end

    StampEntity[Identifier] = nil

    local entity = NetworkGetEntityFromNetworkId(netid)
    if DoesEntityExist(entity) then
        DeleteEntity(entity)
    else
        Shared:GetDebug('Entity is not networked diocane')
    end
end)

RegisterNetEvent('LegacyBanking:printer:CraftingTools', function(item, quantity, itemrequested)
    Shared:GetDebug("CraftingTools", item, itemrequested, quantity)
    local src = source
    exports.ox_inventory:RemoveItem(src, itemrequested, quantity)
    exports.ox_inventory:AddItem(src, item, 1)
end)

RegisterNetEvent('LegacyBanking:SendStatusBattery', function(source, serial, batteryStatus, stampante, restore)
    Shared:GetDebug("SendStatusBattery", source, serial, batteryStatus, stampante, restore)
    local identifier
    if CB.ProviderCore == 'lgf' then
        local playerData = LGF.SvPlayerFunctions.GetPlayerData(source)[1]
        local PlayerIdentifier = playerData.charName
        identifier = PlayerIdentifier
    end
    if CB.ProviderCore == 'esx' then
        identifier = ESX.GetIdentifier(source)
    end
    if CB.ProviderCore == 'qb' then

    end
    if not restore then
        StampEntity[identifier] = stampante
    else
        StampEntity[identifier] = nil
    end

    Shared:GetDebug('stampentity', StampEntity[identifier])
    MySQL.scalar('SELECT COUNT(*) FROM lgf_printer WHERE identifier = ? AND serialNumber = ?', { identifier, serial },
        function(count)
            if count > 0 then
                MySQL.update('UPDATE lgf_printer SET batteryStatus = ? WHERE identifier = ? AND serialNumber = ?',
                    { batteryStatus, identifier, serial }, function(affectedRows)
                        Shared:GetDebug('Updated battery status for serial:', serial)
                    end)
            else
                local id = MySQL.insert.await(
                    'INSERT INTO lgf_printer (identifier, serialNumber, batteryStatus) VALUES (?, ?, ?)',
                    { identifier, serial, batteryStatus })
                Shared:GetDebug('Inserted new printer with id:', id)
            end
        end)
end)

lib.callback.register('LegacyBanking:GetStatusBatteryDb', function(playerid)
    Shared:GetDebug("Received player id: " .. playerid)
    local playerIdentifier
    if CB.ProviderCore == 'lgf' then
        local PlayerData = LGF.SvPlayerFunctions.GetPlayerData(playerid)[1]
        playerIdentifier = PlayerData.charName
    elseif CB.ProviderCore == "esx" then
        local PlayerData = ESX.GetPlayerFromId(playerid)
        playerIdentifier = PlayerData.identifier
    elseif CB.ProviderCore == "qb" then
    end

    if playerIdentifier == nil then print("[^1WARNING^7] No player Identifier cancelling") return end

    local query = MySQL.Sync.fetchAll(
        'SELECT serialNumber, batteryStatus, identifier FROM lgf_printer WHERE identifier = ?', { playerIdentifier })

    if query and #query > 0 then
        Shared:GetDebug("Battery status data retrieved for player: " .. playerIdentifier)
        for _, data in ipairs(query) do
            Shared:GetDebug(json.encode(data))
        end
        return query
    else
        Shared:GetDebug("No battery status data found for player: " .. playerIdentifier)
        return nil
    end
end)

lib.callback.register('LegacyBanking:GetallBatteryData', function(source)
    local printerData = {}
    local playerNameMap = {}

    if CB.ProviderCore == 'lgf' then
        local LGF_DATAUSERS = MySQL.query.await('SELECT * FROM `users`')
        for _, userData in ipairs(LGF_DATAUSERS) do
            local playerName = userData.firstName .. ' ' .. userData.lastName
            local identifier = userData.charName
            playerNameMap[identifier] = playerName
        end
    elseif CB.ProviderCore == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            local playerName = xPlayer.get("firstName") .. ' ' .. xPlayer.get("lastName")
            local identifier = ESX.GetIdentifier(source)
            playerNameMap[identifier] = playerName
        end
    end

    local AllDataPrinter = MySQL.query.await('SELECT * FROM `lgf_printer`')


    for _, data in ipairs(AllDataPrinter) do
        local identifier = data.identifier
        local playerName = playerNameMap[identifier]
        data.playerName = playerName
        if StampEntity[identifier] then
            data.netId = StampEntity[identifier]
        end
        table.insert(printerData, data)
    end

    Shared:GetDebug(printerData)

    return printerData
end)

RegisterNetEvent('LegacyBanking:DestroyPrinterMenu')
AddEventHandler('LegacyBanking:DestroyPrinterMenu', function(netId, identifier, serialNumber)
    Shared:GetDebug('NET ID PRINTER:', netId)
    StampEntity[identifier] = nil
    MySQL.execute('DELETE FROM lgf_printer WHERE identifier = ? AND serialNumber = ?', { identifier, serialNumber },
        function(rowsAffected)
            Shared:GetDebug("Printer deleted for player with identifier: ", identifier)
        end)

    local entity = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(entity) then
        DeleteEntity(entity)
    else
        Shared:GetDebug('Entity is not networked')
    end
end)

RegisterNetEvent('LegacyBanking:ReloadByMenuRPrinter', function(batteryStatus, identifier, seriale)
    MySQL.update('UPDATE lgf_printer SET batteryStatus = ? WHERE identifier = ? AND serialNumber = ?',
        { batteryStatus, identifier, seriale }, function(affectedRows)
            Shared:GetDebug('Updated battery status for serial by menu:', seriale)
        end)
end)

RegisterNetEvent('LegacyBanking:DestroyPrinter', function(source, seriale)
    local IdentiFier

    if CB.ProviderCore == 'lgf' then
        local playerData = LGF.SvPlayerFunctions.GetPlayerData(source)[1]
        local PlayerIdentifier = playerData.charName
        IdentiFier = PlayerIdentifier
    end
    if CB.ProviderCore == 'esx' then
        IdentiFier = ESX.GetIdentifier(source)
    end
    if CB.ProviderCore == 'qb' then

    end
    StampEntity[IdentiFier] = nil
    MySQL.execute('DELETE FROM lgf_printer WHERE identifier = ? AND serialNumber = ?', { IdentiFier, seriale },
        function(rowsAffected)
            Shared:GetDebug("Printer deleted for player with identifier: ", IdentiFier)
        end)
    if exports.ox_inventory:GetItemCount(source, CB.ItemProviderWipe) >= 1 then
        exports.ox_inventory:RemoveItem(source, CB.ItemProviderWipe, 1)
    end
end)

RegisterNetEvent('LegacyBanking:RemoveBatteryItem', function(source, item)
    if exports.ox_inventory:GetItemCount(source, item) >= 1 then
        exports.ox_inventory:RemoveItem(source, item, 1)
    end
end)

local language = GetConvar("LGF_Banking:MetadataNPC", "it")

local NameCivil = {
    en = {
        { "John",      "Smith",     occupation = "Mechanic" },
        { "Jane",      "Doe",       occupation = "Teacher" },
        { "Michael",   "Johnson",   occupation = "Police Officer" },
        { "Emily",     "Williams",  occupation = "Nurse" },
        { "William",   "Brown",     occupation = "Engineer" },
        { "Olivia",    "Jones",     occupation = "Artist" },
        { "James",     "Garcia",    occupation = "Chef" },
        { "Emma",      "Martinez",  occupation = "Writer" },
        { "Alexander", "Hernandez", occupation = "Architect" },
        { "Sophia",    "Lopez",     occupation = "Doctor" },
        { "Jacob",     "Gonzalez",  occupation = "Pilot" },
        { "Isabella",  "Wilson",    occupation = "Lawyer" },
        { "Ethan",     "Anderson",  occupation = "Firefighter" },
        { "Mia",       "Thomas",    occupation = "Journalist" },
        { "Daniel",    "Taylor",    occupation = "Musician" },
        { "Ava",       "Moore",     occupation = "Veterinarian" },
        { "Matthew",   "Jackson",   occupation = "Photographer" },
        { "Charlotte", "White",     occupation = "Psychologist" },
        { "Ryan",      "Harris",    occupation = "Scientist" },
        { "Amelia",    "Martin",    occupation = "Entrepreneur" }
    },
    it = {
        { "Mario",     "Rossi",      occupation = "Meccanico" },
        { "Anna",      "Bianchi",    occupation = "Insegnante" },
        { "Luca",      "Russo",      occupation = "Poliziotto" },
        { "Sofia",     "Ferrari",    occupation = "Infermiera" },
        { "Giovanni",  "Esposito",   occupation = "Ingegnere" },
        { "Francesca", "Romano",     occupation = "Artista" },
        { "Marco",     "Gallo",      occupation = "Chef" },
        { "Giulia",    "Conti",      occupation = "Scrittore" },
        { "Alessio",   "Marini",     occupation = "Architetto" },
        { "Chiara",    "Bruno",      occupation = "Medico" },
        { "Paolo",     "Moretti",    occupation = "Pilota" },
        { "Elena",     "Barbieri",   occupation = "Avvocato" },
        { "Davide",    "Greco",      occupation = "Vigile del fuoco" },
        { "Laura",     "Santoro",    occupation = "Giornalista" },
        { "Roberto",   "Costa",      occupation = "Musicista" },
        { "Valentina", "Pellegrini", occupation = "Veterinario" },
        { "Simone",    "Ferrara",    occupation = "Fotografo" },
        { "Elisa",     "Galli",      occupation = "Psicologo" },
        { "Andrea",    "Barone",     occupation = "Scienziato" },
        { "Chiara",    "Marconi",    occupation = "Imprenditore" }
    }
}

RegisterNetEvent('LegacyBanking:StealMoneyNpc', function(entity)
    local src = source
    local randomIndex = math.random(1, #NameCivil[language])
    local randomName = NameCivil[language][randomIndex]
    local fullName = table.concat(randomName, " ")
    local age = math.random(18, 60)
    local occupation = randomName.occupation or "Unemployed"

    local Metadata = {
        description =
            Shared:GetKeyTraduction("MetadataCivilName"):format(fullName) .. "          \n" ..
            Shared:GetKeyTraduction("MetadataCivilAge"):format(age) .. "                 \n" ..
            Shared:GetKeyTraduction("MetadataCivilJob"):format(occupation)
    }

    if exports.ox_inventory:GetItemCount(src, CB.ItemProviderSteal) >= 1 then
        exports.ox_inventory:AddItem(src, CB.StealingNpc.CardstealItem, 1, Metadata)
        exports.ox_inventory:RemoveItem(src, CB.ItemProviderSteal, 1)
    end
end)

RegisterNetEvent('LegacyBanking:SellStealCards', function(item)
    local src = source
    local randomQuantity = math.random(0, 1)
    if exports.ox_inventory:GetItemCount(src, CB.StealingNpc.CardstealItem) >= 1 then
        if randomQuantity > 0 then
            local moneyToAdd = math.random(CB.StealingNpc.Price.min, CB.StealingNpc.Price.max)
            exports.ox_inventory:AddItem(src, 'money', moneyToAdd)
        end
    else
        warn('missing items')
    end

    exports.ox_inventory:RemoveItem(src, CB.StealingNpc.CardstealItem, 1)
end)

-- RegisterNetEvent('LegacyBanking:TeleportPrinter', function(netid, identifier, seriale)
--     local entity = NetworkGetEntityFromNetworkId(netid)
--     if DoesEntityExist(entity) then
--         SetE
--     else
--         Shared:GetDebug('Entity is not spawned')
--     end
-- end)

exports('ChangePin', ChangePin)

exports('CreateCreditCard', function(player, metadata)
    return CreateCreditCard(player, metadata.price, metadata)
end)

function SvEditableFunction:CreateSqlTable()
    local start = GetConvar("LGF_Banking:RunSqlTable", "false")
    if start == "true" then
        SqlBankingData()
        SqlPrinterData()
    end
end

SqlBankingData = function()
    local result = MySQL.query.await('SHOW TABLES LIKE ?', { 'lgf_banking' })

    if #result > 0 then
        Shared:GetDebug("The [^3lgf_banking^7] table already exists in the database")
    else
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS lgf_banking (
                id INT AUTO_INCREMENT PRIMARY KEY,
                identifier VARCHAR(255) NOT NULL,
                pin VARCHAR(255) NOT NULL,
                last_updated INT NOT NULL
            );
        ]])
        Shared:GetDebug("The [^4lgf_banking^7] table has been created correctly")
    end
end

SqlPrinterData = function()
    local result = MySQL.query.await('SHOW TABLES LIKE ?', { 'lgf_printer' })

    if #result > 0 then
        Shared:GetDebug("The [^3lgf_printer^7] table already exists in the database")
    else
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS lgf_printer (
                id INT AUTO_INCREMENT PRIMARY KEY,
                identifier VARCHAR(255) NOT NULL,
                serialNumber LONGTEXT NOT NULL,
                batteryStatus BIGINT NOT NULL
            );
        ]])
        Shared:GetDebug("The [^4lgf_printer^7] table has been created correctly")
    end
end


-- lib.callback.register('LegacyBanking:getPlayerGroup', function(source, name)
--     local playerGroup
--     if CB.ProviderCore == 'esx' then
--         playerGroup = ESX.GetPlayerFromId(source).getGroup()
--     end
--     if CB.ProviderCore == 'qb' then

--     end
--     return playerGroup
-- end)



SvEditableFunction:CreateSqlTable()

if CB.ProviderCore == 'esx' then
    CreateThread(function()
        for k, v in pairs(CB.GradeJob) do
            TriggerEvent('esx_society:registerSociety', v.Job, v.Job, 'society_' .. v.Job, 'society_' .. v.Job,
                'society_' .. v.Job, { type = 'public' })
        end
    end)
end
