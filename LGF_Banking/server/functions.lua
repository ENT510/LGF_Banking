---@diagnostic disable: missing-parameter, undefined-field, need-check-nil, redundant-parameter
local LGF <const> = GetResourceState('LegacyFramework'):find('start') and exports['LegacyFramework']:ReturnFramework() or nil
local ESX <const> = GetResourceState('es_extended'):find('start') and exports['es_extended']:getSharedObject() or nil
local QBCore <const> = GetResourceState('qb-core'):find('start') and exports['qb-core']:GetCoreObject() or nil
SvEditableFunction = {}
local Shared = require 'utils.shared'
function SvEditableFunction:ServerNotification(source, msg, title, icon)
    if CB.ProviderNotify == 'lgf' then
        TriggerClientEvent('Legacy:AdvancedNotification', source, {
            icon = icon,
            message = msg,
            title = title,
            duration = 5,
            colorIcon = "#FFA500",
            position = 'top-right'
        })
    end
    if CB.ProviderNotify == 'ox' then
        TriggerClientEvent('ox_lib:notify', source,
            {
                icon = icon,
                title = title,
                position = 'top-right',
                description = msg,
                duration = 6000
            })
    end
    if CB.ProviderNotify == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.showNotification(msg)
    end
end

function SvEditableFunction:GetPlayerJob()
    local src = source
    local JobData
    if CB.ProviderCore == 'lgf' then
        local PlayerData = LGF.SvPlayerFunctions.GetPlayerData(src)[1]
        JobData = PlayerData.nameJob
    elseif CB.PriceCreditCard == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        JobData = xPlayer.job.name
    elseif CB.PriceCreditCard == 'qb' then
    end
    return JobData
end

function SvEditableFunction:SignalDispatch(playerId, coords, job)
    local Playerjob = job or SvEditableFunction:GetPlayerJob(playerId)
    for _, jobRequested in ipairs(CB.DistPatchJob) do
        if Playerjob == jobRequested then
            if CB.UseDispatchInternal then
                SvEditableFunction:ServerNotification(playerId, "A robbery is in progress at", "Warning",
                    "fa-solid fa-exclamation-triangle")
                Shared:GetDebug("Notification sent to player " .. playerId)
                TriggerClientEvent('LegacyBanking:SendDispatchAlert', playerId, coords)
                Shared:GetDebug("Internal dispatch executed")
            end
            if CB.UseCustomDispatch then
                CB.CustomDistPatch(playerId, coords, Playerjob)
                Shared:GetDebug("Custom dispatch executed")
            end
            break
        end
    end
end

function SvEditableFunction:CreateSerialNumber()
    local length = 9
    local characters = ""
    local returnTypeSerial = GetConvarInt("LGF_Banking:ReturnTypeSerial", 2)
    Shared:GetDebug("CreateSerialNumber", returnTypeSerial)

    if returnTypeSerial ~= 1 and returnTypeSerial ~= 2 and returnTypeSerial ~= 3 then
        returnTypeSerial = 1
    end

    if returnTypeSerial == 1 then
        characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    elseif returnTypeSerial == 2 then
        characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    elseif returnTypeSerial == 3 then
        characters = "0123456789"
    end

    local function checkSerial()
        local serial = ""
        for _ = 1, length do
            local randomIndex = math.random(1, #characters)
            serial = serial .. characters:sub(randomIndex, randomIndex)
        end

        if returnTypeSerial == 1 or returnTypeSerial == 2 then
            if serial:sub(1, 1):match("[A-Z]") then
                return "#" .. serial
            end
        else
            return "#" .. serial
        end
    end

    local result = lib.waitFor(checkSerial, "Failed to generate valid serial number")

    if result then
        Shared:GetDebug("Serial number generated successfully: " .. result)
    end

    return result
end

local ConvarsOxCheck = GetConvar('LGF_Banking:EnableOxHooksCheck', 'true')

if ConvarsOxCheck == "true" then
    local HookSwapItems = exports.ox_inventory:registerHook('swapItems', function(payload)
        if payload.action == 'move' or payload.action == 'give' then
            local itemData = payload.fromSlot
            if itemData and itemData.name == "tool_3dprint" then
                if payload.fromType == "player" then
                    print("L'oggetto viene spostato dall'inventario del giocatore.")
                    if payload.toType ~= "player" then
                        print(
                            "Tentativo di spostare il Printer 3D in un inventario diverso dal giocatore. Azione annullata.")
                        return false
                    end
                end
            end
        end
        return true
    end)
end

local PrinterMenu = lib.class('PrinterMenu')
local enableCommand = GetConvar("LGF_Banking:EnablePrinterMenuCommand", "true")
local CommandName = GetConvar("LGF_Banking:PrinterMenuCommand", "peppe")

Shared:GetDebug('Convar State:', enableCommand)
Shared:GetDebug('Convar Command:', CommandName)

if enableCommand == "true" then
    Shared:GetDebug("Convar is true,")

    function SvEditableFunction:EnableConvarsCommand()
        self.providerCore = CB.ProviderCore
        self.commandOpenMenu = CommandName
        self.groupOpenPrinterMenu = CB.GroupOpenPrinterMenu
        Shared:GetDebug("Convars set:", self.providerCore, self.commandOpenMenu, self.groupOpenPrinterMenu)
    end

    function PrinterMenu:registerCommand()
        if self.providerCore == 'lgf' then
            for _, group in ipairs(self.groupOpenPrinterMenu.lgf) do
                Shared:GetDebug("Registering command for group:", group)
                LGF.SvUtils.CreateNewCommand({
                    {
                        Command = self.commandOpenMenu,
                        Group = group,
                        Data = function(source, args)
                            TriggerClientEvent('LegacyBanking:OpenMenuDataPrinter', source)
                            Shared:GetDebug(self.providerCore)
                            Shared:GetDebug(self.commandOpenMenu)
                            Shared:GetDebug(self.groupOpenPrinterMenu)
                        end
                    }
                })
            end
        elseif self.providerCore == 'esx' then
            for _, group in ipairs(self.groupOpenPrinterMenu.esx) do
                Shared:GetDebug("Registering command for group:", group)
                ESX.RegisterCommand(self.commandOpenMenu, group, function(xPlayer, args, showError)
                    local source = xPlayer.source
                    TriggerClientEvent('LegacyBanking:OpenMenuDataPrinter', source)
                end, true, { help = 'Open the banking menu', validate = true, arguments = {} })
            end
        else
            warn("Unknown provider core:", self.providerCore)
        end
    end

    local function createPrinterMenu()
        local printerMenu = PrinterMenu:new()
        printerMenu.providerCore = SvEditableFunction.providerCore
        printerMenu.commandOpenMenu = SvEditableFunction.commandOpenMenu
        printerMenu.groupOpenPrinterMenu = SvEditableFunction.groupOpenPrinterMenu
        return printerMenu
    end

    SvEditableFunction:EnableConvarsCommand()
    local printerMenu = createPrinterMenu()
    printerMenu:registerCommand()
else
    Shared:GetDebug("Convar is not true, skipping command registration")
end
