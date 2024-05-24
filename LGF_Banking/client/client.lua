---@diagnostic disable: undefined-global, need-check-nil, undefined-field, missing-parameter
CreateFunction = {}
local interactedEntities = {}
local LGF <const> = GetResourceState('LegacyFramework'):find('start') and exports['LegacyFramework']:ReturnFramework() or
    nil
local ESX <const> = GetResourceState('es_extended'):find('start') and exports['es_extended']:getSharedObject() or nil
local QBCore <const> = GetResourceState('qb-core'):find('start') and exports['qb-core']:GetCoreObject() or nil
local Shared <const> = require 'utils.shared'
local Await <const> = Wait
local MAX_DISTANCE_ALLOWED <const> = CB.StealingNpc.DistanceCancelSteal
local MIN_DISTANCE_ALLOWED <const> = CB.StealingNpc.DistanceStartAngryorScaried

local bankPeds, fakeShopZones = {}, {}


CreateFunction.PedBanking = function(zoneName)
    local promise = promise.new()
    local zone <const> = CB.BankingZone[zoneName]
    local pedModel <const> = lib.RequestModel(zone.PedModelBank, 4000)
    local pedPos <const> = zone.PedPosBank
    local blipData = zone.BlipData
    if IsModelValid(pedModel) then
        local Ped = CreatePed(4, pedModel, pedPos.x, pedPos.y, pedPos.z - 1, pedPos.w, false, true)
        bankPeds[#bankPeds+1] = Ped
        SetEntityAsMissionEntity(Ped, true, true)
        SetEntityInvincible(Ped, true)
        FreezeEntityPosition(Ped, true)
        SetModelAsNoLongerNeeded(pedModel)
        SetBlockingOfNonTemporaryEvents(Ped, true)
        TaskStartScenarioInPlace(Ped, zone.PedScenarioBank, 0, false)
        local blip <const> = AddBlipForCoord(pedPos.x, pedPos.y, pedPos.z)
        SetBlipSprite(blip, blipData.Sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, blipData.Scale)
        SetBlipColour(blip, blipData.Color)
        SetBlipAsShortRange(blip, blipData.ShortRange)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blipData.Label)
        EndTextCommandSetBlipName(blip)
        promise:resolve(Ped)
        Await(100)
        exports.ox_target:addLocalEntity(Ped, {
            {
                icon = "fa-solid fa-money-check-dollar",
                label = Shared:GetKeyTraduction("OpenBank"),
                onSelect = function()
                    EditableFunction:ProgressBar(Shared:GetKeyTraduction("OpeningBankProg"))
                    local PinResponse <const> = lib.callback.await('LegacyBanking:CheckPinStatus', false)
                    if PinResponse then
                        if type(PinResponse) == "table" and PinResponse[1] and PinResponse[1].pin then
                            local Pin = tonumber(PinResponse[1].pin)
                            local PutPassword = lib.inputDialog(Shared:GetKeyTraduction("EnterPIN"), {
                                { type = 'input', label = Shared:GetKeyTraduction("PIN"), description = Shared:GetKeyTraduction("EnterPIN"), icon = 'hashtag', required = true, min = 4, password = true }
                            })

                            if not PutPassword then
                                return
                            end

                            local PinEntered = tonumber(PutPassword[1])
                            if PinEntered == Pin then
                                CreateFunction.CreateMenuBank(zoneName)
                            else
                                EditableFunction:ClientNotification(Shared:GetKeyTraduction("IncorrectPIN"), "Error",
                                    "fa-solid fa-exclamation-triangle")
                            end
                        else
                            local alertCreatePin <const> = lib.alertDialog({
                                header = Shared:GetKeyTraduction("BankAlert"),
                                content = Shared:GetKeyTraduction("MissingPINContent"),
                                centered = true,
                                cancel = true,
                                labels = {
                                    cancel = Shared:GetKeyTraduction("CloseBanking"),
                                    confirm = Shared:GetKeyTraduction("ProvidePin")
                                }
                            })
                            if alertCreatePin == 'cancel' then
                                return
                            else
                                local id = cache.serverId
                                local ChangePin = lib.inputDialog(Shared:GetKeyTraduction("EnterNewPIN"), {
                                    { type = 'input', label = Shared:GetKeyTraduction("NewPin"), description = Shared:GetKeyTraduction("EnterNewPIN"), icon = 'fas fa-lock', required = true, min = 4, password = true }
                                })
                                if not ChangePin then
                                    return
                                end
                                local newPin = tonumber(ChangePin[1])
                                if newPin then
                                    EditableFunction:ClientNotification(Shared:GetKeyTraduction("NewPinCreated"),
                                        "Success", "fa-solid fa-check")
                                    TriggerServerEvent('LegacyBanking:ChangePin', id, newPin)
                                else
                                    EditableFunction:ClientNotification(Shared:GetKeyTraduction("InvalidPIN"), "Error",
                                        "fa-solid fa-exclamation-triangle")
                                end
                            end
                        end
                    else
                        Shared:GetDebug("Failed to retrieve PIN information.")
                    end
                end,
            },
            {
                icon = "fa-solid fa-credit-card",
                label = Shared:GetKeyTraduction("RequestCreditCards"),
                onSelect = function()
                    TriggerServerEvent('LegacyBanking:RequestCreditCard')
                end,
            }
        })
    else
        error("ERROR: Ped model does not exist: " .. zone.PedModelBank)
    end

    return promise
end

CreateFunction.ModelAtm = function(zoneBank)
    local Zone <const> = CB.BankingZone[zoneBank]
    local promise = promise.new()
    local models <const> = CB.PropAtm
    for k, v in pairs(CB?.PropAtm) do
        exports.ox_target:addModel(v, {
            {
                icon = "fa-solid fa-money-check-dollar",
                label = Shared:GetKeyTraduction("OpenAtmBank"),
                onSelect = function()
                    EditableFunction:ProgressBar(Shared:GetKeyTraduction("OpeningAtm"))
                    local PinResponse <const> = lib.callback.await('LegacyBanking:CheckPinStatus', false)
                    if PinResponse then
                        if type(PinResponse) == "table" and PinResponse[1] and PinResponse[1].pin then
                            local Pin = tonumber(PinResponse[1].pin)
                            local PutPassword = lib.inputDialog(Shared:GetKeyTraduction("EnterPIN"), {
                                { type = 'input', label = 'PIN', description = Shared:GetKeyTraduction("EnterPIN"), icon = 'hashtag', required = true, min = 4, password = true }
                            })

                            if not PutPassword then
                                return
                            end

                            local PinEntered = tonumber(PutPassword[1])
                            if PinEntered == Pin then
                                CreateFunction.CreateMenuBank(zoneName)
                            else
                                EditableFunction:ClientNotification(Shared:GetKeyTraduction("IncorrectPIN"), "Error",
                                    "fa-solid fa-exclamation-triangle")
                            end
                        else
                            local alertCreatePin <const> = lib.alertDialog({
                                header = Shared:GetKeyTraduction("BankAlert"),
                                content = Shared:GetKeyTraduction("MissingPINContent"),
                                centered = true,
                                cancel = true,
                                labels = {
                                    cancel = Shared:GetKeyTraduction("CloseBanking"),
                                    confirm = Shared:GetKeyTraduction("ProvidePin")
                                }
                            })
                            if alertCreatePin == 'cancel' then
                                return
                            else
                                local id = cache.serverId
                                local ChangePin = lib.inputDialog(Shared:GetKeyTraduction("EnterNewPIN"), {
                                    { type = 'input', label = Shared:GetKeyTraduction("NewPin"), description = Shared:GetKeyTraduction("EnterNewPIN"), icon = 'fas fa-lock', required = true, min = 4, password = true }
                                })
                                if not ChangePin then
                                    return
                                end
                                local newPin = tonumber(ChangePin[1])
                                if newPin then
                                    TriggerServerEvent('LegacyBanking:ChangePin', id, newPin)
                                    EditableFunction:ClientNotification(Shared:GetKeyTraduction("NewPinCreated"),
                                        "Success", "fa-solid fa-check")
                                    Shared:GetDebug('pin cambiato')
                                else
                                    EditableFunction:ClientNotification(Shared:GetKeyTraduction("InvalidPIN"), "Error",
                                        "fa-solid fa-exclamation-triangle")
                                end
                            end
                        end
                    else
                        Shared:GetDebug("Failed to retrieve PIN information.")
                    end
                end,
            },
        })
    end

    promise:resolve(true)
    return promise
end

CreateFunction.CreateMenuBank = function(zoneBank)
    local ZoneData <const> = CB.BankingZone[zoneBank]
    local PlayerBankData <const> = lib.callback.await('LegacyBanking:GetPlayerMoneyBank', false)
    local PlayerData, PlayerJob, PlayerGrade, DataJob, BankAccount

    if CB.ProviderCore == 'lgf' then
        BankAccount = json.encode(PlayerBankData.Bank)
        local PlayerData = LGF.PlayerFunctions.GetClientData()[1]
        PlayerJob = PlayerData and PlayerData.nameJob
        PlayerGrade = PlayerData and PlayerData.gradeJob
        DataJob = {
            job = PlayerJob, grade = PlayerGrade
        }
        Shared:GetDebug('job dentro provider', PlayerJob)
    elseif CB.ProviderCore == 'esx' then
        BankAccount = json.encode(PlayerBankData)
        local xPlayer = ESX.GetPlayerData()
        PlayerJob = xPlayer and xPlayer.job.name
        PlayerGrade = xPlayer and xPlayer.job.grade
    elseif CB.ProviderCore == 'qb' then
        local QbPlayer = QBCore.Functions.GetPlayerData()
        PlayerJob = QbPlayer and QbPlayer.job.name
        PlayerGrade = QbPlayer and QbPlayer.job.grade
    end

    local options = {
        {
            title = Shared:GetKeyTraduction("BankBalance") .. BankAccount .. ' $',
            icon = 'fas fa-coins',
            disabled = false,
            readOnly = true,
            description = Shared:GetKeyTraduction("YourCurrentBalance")
        },
        {
            title = Shared:GetKeyTraduction("Deposit"),
            icon = 'fas fa-arrow-circle-up',
            onSelect = function()
                local DepMoney = lib.inputDialog(Shared:GetKeyTraduction("DepositMoney"), {
                    { type = 'number', label = Shared:GetKeyTraduction("Amount"), description = Shared:GetKeyTraduction("EnterAmountDeposit"), icon = 'fas fa-money-bill-wave', required = true }
                })

                if not DepMoney then
                    return CreateFunction.CreateMenuBank(zoneName)
                end

                local quantitydep = DepMoney[1]

                if type(quantitydep) == 'number' then
                    TriggerServerEvent('LegacyBanking:DepositMoney', quantitydep)
                    Await(100)
                    CreateFunction.CreateMenuBank(zoneName)
                else
                    EditableFunction:ClientNotification(Shared:GetKeyTraduction("InvalidQuantityEntered"), "Error",
                        "fa-solid fa-exclamation-triangle")
                end
            end,
            description = Shared:GetKeyTraduction("DepositDescription")
        },
        {
            title = Shared:GetKeyTraduction("Withdraw"),
            icon = 'fas fa-arrow-circle-down',
            onSelect = function()
                local PutQuantity = lib.inputDialog(Shared:GetKeyTraduction("WithdrawMoney"), {
                    { type = 'number', label = 'Amount', description = Shared:GetKeyTraduction("EnterAmountWithdraw"), icon = 'fas fa-money-bill-wave', required = true }
                })

                if not PutQuantity then
                    return CreateFunction.CreateMenuBank(zoneName)
                end

                local quantity = PutQuantity[1]

                if type(quantity) == 'number' then
                    TriggerServerEvent('LegacyBanking:WithdrawMoney', quantity)
                    Await(100)
                    CreateFunction.CreateMenuBank(zoneName)
                else
                    EditableFunction:ClientNotification(Shared:GetKeyTraduction("InvalidQuantityEntered"), "Error",
                        "fa-solid fa-exclamation-triangle")
                end
            end,
            description = Shared:GetKeyTraduction("WithdrawDescription")
        },
        {
            title = Shared:GetKeyTraduction("CreateChangePIN"),
            icon = 'fas fa-key',
            onSelect = function()
                local id = cache.serverId
                local ChangePin = lib.inputDialog(Shared:GetKeyTraduction("ChangePIN"), {
                    { type = 'input', label = Shared:GetKeyTraduction("NewPin"), description = Shared:GetKeyTraduction("EnterNewPIN"), icon = 'fas fa-lock', required = true, min = 4, password = true }
                })

                if not ChangePin then
                    return
                end

                local newPin = tonumber(ChangePin[1])

                if newPin then
                    TriggerServerEvent('LegacyBanking:ChangePin', id, newPin)
                    EditableFunction:ClientNotification(Shared:GetKeyTraduction("NewPinCreated"), "Success",
                        "fa-solid fa-check")
                else
                    EditableFunction:ClientNotification(Shared:GetKeyTraduction("InvalidPINEntered"), "Error",
                        "fa-solid fa-exclamation-triangle")
                end
            end,
            description = Shared:GetKeyTraduction("CreateChangePINDescription")
        }
    }

    if DataJob then
        local societyFound
        local societyName
        local SocietyData = lib.callback.await('LegacyBanking:GetSocietyFound', false)
        Shared:GetDebug("SocietyData", json.encode(SocietyData, { indent = true }))
        if CB.ProviderCore == 'lgf' then
            societyFound = SocietyData.founds
            societyName = SocietyData.name
        elseif CB.ProviderCore == 'esx' then
            societyFound = SocietyData[PlayerJob].founds
            societyName = SocietyData[PlayerJob].name
        elseif CB.ProviderCore == 'qb' then

        end

        for _, jobConfig in pairs(CB.GradeJob) do
            if PlayerJob == jobConfig.Job and tonumber(PlayerGrade) >= tonumber(jobConfig.GradeBoss) then
                local societyOption = {
                    title = Shared:GetKeyTraduction("SocietyFound"),
                    icon = 'fas fa-briefcase',
                    onSelect = function()
                        local subMenuOptions = {
                            {
                                title = Shared:GetKeyTraduction("SocietyDetails"),
                                icon = 'fas fa-info-circle',
                                readOnly = true,
                                description = Shared:GetKeyTraduction("Funds") ..
                                    ": " ..
                                    (societyFound or 0) ..
                                    "\n" .. Shared:GetKeyTraduction("Name") .. ": " .. (societyName or 'unknown'),
                                metadata = {
                                    { label = Shared:GetKeyTraduction("Job"),          value = PlayerJob },
                                    { label = Shared:GetKeyTraduction("Grade"),        value = PlayerGrade },
                                    { label = Shared:GetKeyTraduction("SocietyFunds"), value = societyFound },
                                    { label = Shared:GetKeyTraduction("SocietyName"),  value = societyName },
                                }
                            },
                            {
                                title = Shared:GetKeyTraduction("WithdrawMoneySociety"),
                                icon = 'fas fa-money-bill-wave',
                                onSelect = function()
                                    local amount = lib.inputDialog(Shared:GetKeyTraduction("SocietyFound"), {
                                        { type = 'number', label = Shared:GetKeyTraduction("Amount"), description = Shared:GetKeyTraduction("EnterSocietyAmount"), icon = 'fas fa-money-bill-wave', required = true }
                                    })

                                    if not amount then
                                        return lib.showContext('society_submenu')
                                    end

                                    local societyAmount = amount[1]

                                    if type(societyAmount) == 'number' then
                                        TriggerServerEvent('LegacyBanking:RemoveSocietyFounds', societyName,
                                            societyAmount)
                                        Await(100)
                                        CreateFunction.CreateMenuBank(zoneName)
                                    else
                                        EditableFunction:ClientNotification(
                                            Shared:GetKeyTraduction("InvalidQuantityEntered"), "Error",
                                            "fa-solid fa-exclamation-triangle")
                                    end
                                end,
                                description = Shared:GetKeyTraduction("WithdrawSocietyDescription"),
                                metadata = {
                                    { label = Shared:GetKeyTraduction("Operation"),   value = Shared:GetKeyTraduction("Withdraw") },
                                    { label = Shared:GetKeyTraduction("SocietyName"), value = societyName }
                                }
                            },
                            {
                                title = Shared:GetKeyTraduction("DepositSocietyFound"),
                                icon = 'fas fa-money-bill-wave',
                                onSelect = function()
                                    local amount = lib.inputDialog(Shared:GetKeyTraduction("SocietyFound"), {
                                        { type = 'number', label = Shared:GetKeyTraduction("Amount"), description = Shared:GetKeyTraduction("EnterSocietyAmount"), icon = 'fas fa-money-bill-wave', required = true }
                                    })

                                    if not amount then
                                        return lib.showContext('society_submenu')
                                    end

                                    local societyAmount = amount[1]
                                    if type(societyAmount) == 'number' then
                                        TriggerServerEvent('LegacyBanking:AddSocietyFounds', societyName, societyAmount)
                                        Await(100)
                                        CreateFunction.CreateMenuBank(zoneName)
                                    else
                                        EditableFunction:ClientNotification(
                                            Shared:GetKeyTraduction("InvalidQuantityEntered"), "Error",
                                            "fa-solid fa-exclamation-triangle")
                                    end
                                end,
                                description = Shared:GetKeyTraduction("DepositSocietyDesc"),
                                metadata = {
                                    { label = Shared:GetKeyTraduction("Operation"),   value = Shared:GetKeyTraduction("Deposit") },
                                    { label = Shared:GetKeyTraduction("SocietyName"), value = societyName }
                                }
                            }
                        }

                        lib.registerContext({
                            id = 'society_submenu',
                            title = Shared:GetKeyTraduction("SocietyDetails"),
                            menu = 'bank_menu',
                            options = subMenuOptions
                        })

                        lib.showContext('society_submenu')
                    end,
                    description = Shared:GetKeyTraduction("SocietyFoundDescription"),
                }

                table.insert(options, societyOption)
                break
            end
        end
    end


    lib.registerContext({
        id = 'bank_menu',
        title = Shared:GetKeyTraduction("BankMenu"),
        options = options
    })

    lib.showContext('bank_menu')
end

CreateFunction.CreateSellerPed = function(zoneSeller)
    local SellerData = CB.FakeCreditCard[zoneSeller]
    if SellerData then
        local pedModel = SellerData.PedModelSell
        local pedCoords = SellerData.PedPosSell
        local pedHeading = SellerData.PedPosSell.w
        local pedScenario = SellerData.PedScenarioSell
        local model = lib.RequestModel(pedModel, 3000)
        SellerPed = CreatePed(4, model, pedCoords.x, pedCoords.y, pedCoords.z - 1, pedHeading, false, true)
        SetEntityAsMissionEntity(SellerPed, true, true)
        SetBlockingOfNonTemporaryEvents(SellerPed, true)
        SetEntityInvincible(SellerPed, true)
        FreezeEntityPosition(SellerPed, true)
        TaskStartScenarioInPlace(SellerPed, pedScenario, 0, false)
        exports.ox_target:addLocalEntity(SellerPed, {
            {
                icon = 'fa-solid fa-bahai',
                label = Shared:GetKeyTraduction("MenuFakeCard"),
                onSelect = function()
                    CreateFunction.CreateMenuFakeSeller(zoneSeller)
                    EditableFunction:CreateCam(SellerPed)
                end
            }
        })
    else
        Shared:GetDebug("Zone seller data not found")
        return nil
    end
end

CreateFunction.CreateZone = function(zoneName)
    local DataZone = CB.FakeCreditCard[zoneName]
    local point = lib.points.new({
        coords = DataZone.PedPosSell,
        distance = 50,
    })

    function point:onEnter()
        CreateFunction.CreateSellerPed(zoneName)
    end

    function point:onExit()
        DeletePed(SellerPed)
    end

    return point
end

CreateFunction.getPinStatus = function()
    local Pin = lib.callback.await('LegacyBanking:CheckPinStatus', false)
    if type(Pin) == "table" and Pin[1] and Pin[1].pin then
        return false
    else
        return true
    end
end

CreateFunction.ShowDeletePinConfirmation = function(zoneSell)
    local confirmation = lib.alertDialog({
        header = "Confirmation",
        content = "Are you sure you want to delete the current PIN?",
        centered = true,
        cancel = true,
        labels = {
            cancel = "Cancel",
            confirm = "Confirm"
        }
    })

    if confirmation == 'confirm' then
        TriggerServerEvent('LegacyBanking:GetFakeCard:DeletePin', zoneSell)
        EditableFunction:DestroyCamera()
    else
        EditableFunction:DestroyCamera()
    end
end

CreateFunction.CreateMenuFakeSeller = function(zoneSell)
    local Seller = CB.FakeCreditCard[zoneSell]
    local GetConvarsStealing = GetConvar('LGF_Banking:EnableRobberyNpc', "true")
    local menuOptions = {

        {
            title = Shared:GetKeyTraduction("CreateFakeCardTitle"),
            description = Shared:GetKeyTraduction("CreateFakeCardDescription"),
            icon = 'fa-solid fa-credit-card',
            onSelect = function()
                local CreateFakeCard = lib.inputDialog(Shared:GetKeyTraduction("CreateFakeCardTitle"), {
                    { type = 'input',  label = Shared:GetKeyTraduction("CardLabel"),       description = Shared:GetKeyTraduction("EnterCardLabel"),       placeholder = 'Enter label...',       required = true,       min = 4 },
                    { type = 'input',  label = Shared:GetKeyTraduction("CardDescription"), description = Shared:GetKeyTraduction("EnterCardDescription"), placeholder = 'Enter description...', required = true,       min = 4 },
                    { type = 'input',  label = Shared:GetKeyTraduction("CardType"),        description = Shared:GetKeyTraduction("EnterCardType"),        placeholder = 'Enter type...',        required = true,       min = 4 },
                    { type = 'slider', label = Shared:GetKeyTraduction("CardWeight"),      description = Shared:GetKeyTraduction("SelectCardWeight"),     required = true,                      step = 0.01,           min = 0.10,         max = 0.50 },
                    { type = 'date',   label = Shared:GetKeyTraduction("PutDate"),         icon = { 'far', 'calendar' },                                  default = false,                      format = "DD/MM/YYYY", min = "01/01/2020", max = "01/01/2025", returnString = true, required = true }
                })
                if not CreateFakeCard then return EditableFunction:DestroyCamera() end
                local label = CreateFakeCard[1]
                local description = CreateFakeCard[2]
                local type = CreateFakeCard[3]
                local weight = CreateFakeCard[4]
                local date = CreateFakeCard[5]
                TriggerServerEvent('LegacyBanking:GetFakeCard', label, description, type, Seller.PriceFakeCard, weight,
                    date)
                Await(50)
                EditableFunction:DestroyCamera()
            end
        },
        {
            title = Shared:GetKeyTraduction("DeleteCurrentPin"),
            description = Shared:GetKeyTraduction("DeleteCurrentPinDesc"),
            icon = 'fa-solid fa-credit-card',
            disabled = CreateFunction.getPinStatus(),
            onSelect = function()
                EditableFunction:DestroyCamera()
                if Seller.SkillCheck.Enable then
                    local success = EditableFunction:performSkillCheck(zoneSell)
                    if success then
                        CreateFunction.ShowDeletePinConfirmation(zoneSell)
                    else
                        Shared:GetDebug('You Have Wrong')
                    end
                else
                    CreateFunction.ShowDeletePinConfirmation(zoneSell)
                end
            end
        },
        {
            title = Shared:GetKeyTraduction("ShopFake"),
            description = Shared:GetKeyTraduction("ShopFakedesc"),
            icon = 'fa-solid fa-credit-card',
            onSelect = function()
                CreateFunction.CreateMenuSeller(zoneSell)
            end
        }
    }

    if GetConvarsStealing == "true" then
        table.insert(menuOptions, {
            title = Shared:GetKeyTraduction('SellCreditCard'),
            description = Shared:GetKeyTraduction('SellCreditCardDesc'),
            icon = 'fa-solid fa-print',
            onSelect = function()
                EditableFunction:NormalProgress('Empty Civil Bank Account..')
                TriggerServerEvent('LegacyBanking:SellStealCards')
                EditableFunction:DestroyCamera()
            end
        })
    end

    lib.registerContext({
        id = 'CreateFakeCard' .. zoneSell,
        title = Shared:GetKeyTraduction("CreateFakeCard"),
        options = menuOptions,
        onExit = function()
            EditableFunction:DestroyCamera()
        end
    })

    lib.showContext('CreateFakeCard' .. zoneSell)
end


CreateFunction.CreateMenuSeller = function(zoneSell)
    local ped = cache.ped
    local playerId = cache.serverId
    local SellerFake = CB.FakeCreditCard[zoneSell]
    local menuOptions = {}
    for _, tool in ipairs(SellerFake.ShopTool) do
        table.insert(menuOptions, {
            title = tool.LabelTool,
            description = tool.Description .. '\n' .. Shared:GetKeyTraduction('Price') .. tool.PriceTool,
            icon = 'tools',
            image = "nui://ox_inventory/web/images/" .. tool.NameTool .. ".png",
            onSelect = function()
                Shared:GetDebug("Selected tool:", tool.NameTool, "Price:", tool.PriceTool)
                local inputBuy = lib.inputDialog(Shared:GetKeyTraduction('TitleItemShop'), {
                    { type = 'number', label = Shared:GetKeyTraduction('TextItemShop'), description = Shared:GetKeyTraduction('TextItemShopDescription'), required = true, min = 1 },
                })
                if not inputBuy then return EditableFunction:DestroyCamera() end
                local Quantity = inputBuy[1]
                TriggerServerEvent('LegacyBanking:BuyToolsInShop', playerId, tool.NameTool, Quantity, tool.PriceTool)
                EditableFunction:DestroyCamera()
            end
        })
    end

    lib.registerContext({
        id = 'seller_menu_' .. zoneSell,
        title = Shared:GetKeyTraduction('ShopTools'),
        menu = 'CreateFakeCard' .. zoneSell,
        options = menuOptions,
        onExit = function()
            EditableFunction:DestroyCamera()
        end
    })
    lib.showContext('seller_menu_' .. zoneSell)
end

CreateFunction.CreateRobberyPlayer = function(zoneRob)
    local Ped = cache.ped
    local PlayerId = cache.serverId
    local playerCoords = GetEntityCoords(Ped)
    local Zone <const> = CB.BankingZone[zoneRob]
    exports.ox_target:addSphereZone({
        coords = Zone.RobberyZone,
        radius = 1,
        debug = CB.DebugSphereZone,
        options = {
            {
                icon = 'fa-solid fa-circle',
                label = Shared:GetKeyTraduction('StartRobberyBank'),
                onSelect = function()
                    if IsPedArmed(Ped, 4) then
                        EditableFunction:CheckCooldown()
                        TriggerServerEvent('LegacyBanking:DispatchRobbery', zoneRob, playerCoords)
                        if Zone.SkillCheck.Enable then
                            local success = EditableFunction:performSkillCheck(zoneRob)
                            if success then
                                TriggerEvent('ox_inventory:disarm', PlayerId, true)
                                EditableFunction:CreateProgressRobbery(zoneRob,
                                    'You are Stealing from Safe Deposit Boxes')
                                TriggerServerEvent('LegacyBanking:StealMoneyDropCash', zoneRob)
                        
                            else
                                EditableFunction:ClientNotification(Shared:GetKeyTraduction("MissedSkill"), "Warning",
                                "fa-solid fa-exclamation-triangle")
                            end
                        else
                            TriggerClientEvent('ox_inventory:disarm', PlayerId, true)
                            EditableFunction:CreateProgressRobbery(zoneRob, 'You are Stealing from Safe Deposit Boxes')
                            TriggerServerEvent('LegacyBanking:StealMoneyDropCash', zoneRob)
                      
                            
                        end
                    else
                        EditableFunction:ClientNotification(Shared:GetKeyTraduction("NoWeaponHand"), "Warning","fa-solid fa-exclamation-triangle")
                    end
                end,
                canInteract = function(entity, distance, coords, name, bone)
                    local isInCooldown = IsInCoolDown
                    return not isInCooldown
                end
            }

        }
    })
end

local ConvarsNpc = GetConvar('LGF_Banking:EnableRobberyNpc', "true")


if ConvarsNpc == "true" then
    CreateFunction.ProgressRobberyNpc = function(msg, ped)
        local progressbar
        local robberySuccessful = false
        local isPedAngry = false

        Citizen.CreateThread(function()
            local lastPlayerPosition = GetEntityCoords(cache.ped)

            while true do
                Citizen.Wait(1000)

                local currentPlayerPosition = GetEntityCoords(cache.ped)
                local playerDistance = #(currentPlayerPosition - lastPlayerPosition)
                lastPlayerPosition = currentPlayerPosition
                local pedDistance = #(GetEntityCoords(ped) - currentPlayerPosition)

                Shared:GetDebug("Player distance: ", playerDistance)
                Shared:GetDebug("Ped distance: ", pedDistance)

                if lib.progressActive() then
                    if pedDistance > MAX_DISTANCE_ALLOWED then
                        lib.cancelProgress()
                        robberySuccessful = false
                        EditableFunction:ClientNotification(Shared:GetKeyTraduction("StealWrong"), "Warning",
                            "fa-solid fa-exclamation-triangle")
                        return
                    end

                    if pedDistance < MIN_DISTANCE_ALLOWED and not isPedAngry then
                        robberySuccessful = false
                        lib.cancelProgress()
                        TaskCombatPed(ped, cache.ped, 0, 16)
                        isPedAngry = true
                        EditableFunction:ClientNotification(Shared:GetKeyTraduction("StealWrongAllert"), "Warning",
                            "fa-solid fa-exclamation-triangle")
                        SetPedSeeingRange(ped, 100.0)
                        SetPedHearingRange(ped, 100.0)
                        SetPedAlertness(ped, 100.0)
                        Shared:GetDebug("Ped is now aggressive or scaried")
                        return
                    end
                else
                    return
                end
            end
        end)



        local Timing = CB.StealingNpc.TimeStealing
        if lib.progressCircle({
                duration = Timing * 1000,
                label = msg,
                position = 'middle',
                useWhileDead = false,
                canCancel = false,
                disable = {
                    car = true,
                },
                anim = {
                    dict = 'amb@world_human_tourist_map@male@base',
                    clip = 'base',
                },
                prop = {
                    bone = 28422,
                    model = `prop_cs_tablet`,
                    pos = vec3(0.03, 0.03, 0.02),
                    rot = vec3(0.0, 0.0, -1.5)
                }
            }) then
            robberySuccessful = true
        end

        if robberySuccessful then
            TriggerServerEvent('LegacyBanking:StealMoneyNpc')
        end
    end

    CreateFunction.StealingNpc = function()
        local item = CB.ItemProviderSteal
        exports.ox_target:addGlobalPed({
            {
                icon = 'fa-solid fa-male',
                label = Shared:GetKeyTraduction("StealNPC"),
                items = item,
                onSelect = function(data)
                    local entity = data.entity
                    CreateFunction.ProgressRobberyNpc('Hacking Device Npc..', data.entity)

                    interactedEntities[entity] = true
                end,
                canInteract = function(entity)
                    return not IsEntityAMissionEntity(entity) and not interactedEntities[entity]
                end
            }
        })
    end
    CreateFunction.StealingNpc()
else
    print('convars Disabled for robbery npc')
end


AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, ped in pairs(bankPeds) do
            DeleteEntity(ped)
        end
        for _, point in pairs(fakeShopZones) do
            point:remove()
        end
        for printer, _ in pairs(Printers) do
            DeleteEntity(printer)
        end
        DeleteEntity(SellerPed)
    end
end)

for zoneName, zoneData in pairs(CB.BankingZone) do
    Await(500)
    CreateFunction.PedBanking(zoneName)
    CreateFunction.ModelAtm()
    CreateFunction.CreateRobberyPlayer(zoneName)
end

for k, v in pairs(CB.FakeCreditCard) do
    local point = CreateFunction.CreateZone(k)
    fakeShopZones[#fakeShopZones + 1] = point
end

return CreateFunction
