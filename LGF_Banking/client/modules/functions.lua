---@diagnostic disable: need-check-nil, undefined-field, missing-parameter
local dispatchBlip = nil
local camera = nil
local difficultyPresets = {}
local batteryStatusMap = {}
local objectSpawnStatusMap = {}
local coolDownTime = 120
EditableFunction = {}
IsInCoolDown = false
local LGF <const> = GetResourceState('LegacyFramework'):find('start') and exports['LegacyFramework']:ReturnFramework() or
    nil
local ESX <const> = GetResourceState('es_extended'):find('start') and exports['es_extended']:getSharedObject() or nil
local QBCore <const> = GetResourceState('qb-core'):find('start') and exports['qb-core']:GetCoreObject() or nil


local Shared <const> = require 'utils.shared'
local PlaySound = PlaySound
local Await <const> = Wait


function EditableFunction:GetInventoryItem(item)
    local itemRequested = exports.ox_inventory:Search('count', item)
    return itemRequested
end

function EditableFunction:ClientNotification(msg, title, icon)
    PlaySound(-1, "Event_Message_Purple", "GTAO_FM_Events_Soundset")
    Shared:GetDebug("ClientNotification", msg, title, icon)
    if CB.ProviderNotify == 'lgf' then
        LGF.Utils.AdvancedNotify({
            icon = icon,
            colorIcon = "#FFA500",
            message = msg,
            title = title,
            position = "top-right",
            bgColor = "#495057",
            duration = 6
        })
    end
    if CB.ProviderNotify == 'ox' then
        lib.notify({
            title = title,
            description = msg,
            icon = icon,
            duration = 6000,
            position = 'top-right'
        })
    end
    if CB.ProviderNotify == 'esx' then
        exports["esx_notify"]:Notify('success', 6000, msg)
    end
    if CB.ProviderNotify == 'qb' then
    end
    if CB.ProviderNotify == 'custom' then
    end
end

function EditableFunction:NormalProgress(msg)
    local progressBarData = {
        duration = 5000,
        label = msg,
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
        },
    }

    if CB.TypeProgressBar == 'circle' then
        lib.progressCircle(progressBarData)
    elseif CB.TypeProgressBar == 'label' then
        lib.progressBar(progressBarData)
    end
end

function EditableFunction:ProgressBar(msg)
    local progressBarData = {
        duration = 2000,
        label = msg,
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
        },
        anim = {
            dict = 'mp_common',
            clip = 'givetake1_a'
        },
        prop = {
            model = `prop_cs_credit_card`,
            bone = 28422,
            pos = vec3(0.0, -0.03, 0.0),
            rot = vec3(20.0, -150.0, 60.0)
        }
    }

    if CB.TypeProgressBar == 'circle' then
        lib.progressCircle(progressBarData)
    elseif CB.TypeProgressBar == 'label' then
        lib.progressBar(progressBarData)
    end
end

function EditableFunction:ProgressHackingCoolDown(msg, duration)
    local progressBarData2 = {
        duration = duration,
        label = msg,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true
        },
        anim = {
            dict = 'amb@world_human_tourist_map@male@base' or false,
            clip = 'base' or false
        },
        prop = {
            bone = 28422 or false,
            model = `prop_cs_tablet` or false,
            pos = vec3(0.03, 0.03, 0.02) or false,
            rot = vec3(0.0, 0.0, -1.5) or false
        }
    }
    if CB.TypeProgressBar == 'circle' then
        lib.progressCircle(progressBarData2)
    elseif CB.TypeProgressBar == 'label' then
        lib.progressBar(progressBarData2)
    end
end

function EditableFunction:InstructionalButtonRaycast()
    local instructions = "[Q] - Rotate prop to the right, " .. '      \n' ..
        "[E] - Rotate prop to the left, " .. '      \n' ..
        "[RMB] - Place prop"

    local options = {
        position = "top-center",
        icon = 'rotate',
        iconColor = 'orange',
        iconAnimation = 'spin',
        style = {
            backgroundColor = 'rgba(0, 0, 0, 0.7)',
            color = 'white',
            fontFamily = 'Arial',
            fontSize = '16px',
            padding = '20px',
            borderRadius = '10px',
        },
    }

    lib.showTextUI(instructions, options)
end

function EditableFunction:CreateCam(ped)
    if CB.EnableCam then
        local coords = GetOffsetFromEntityInWorldCoords(ped, 0, 1.75, 0)
        camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamActive(camera, true)
        RenderScriptCams(true, true, 1250, 1, 0)
        SetCamCoord(camera, coords.x + 0.2, coords.y, coords.z + 0.65)
        SetCamFov(camera, 38.0)
        SetCamRot(camera, 0.0, 0.0, GetEntityHeading(ped) + 180)
        PointCamAtPedBone(camera, ped, 31086, 0.0 - 0.3, 0.0, 0.03, 1)
        local camCoords = GetCamCoord(camera)
        TaskLookAtCoord(ped, camCoords.x, camCoords.y, camCoords.z, 5000, 1, 1)
    end
end

function EditableFunction:CreateCamWeapon(weapon)
    local coords = GetOffsetFromEntityInWorldCoords(weapon, 0.0, -1.8, 0)
    camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(camera, true)
    RenderScriptCams(true, true, 1250, 1, 0)
    SetCamCoord(camera, coords.x, coords.y, coords.z)
    SetCamFov(camera, 38.0)
    SetCamRot(camera, 0.0, 0.0, GetEntityHeading(weapon))
    local forwardVector = GetEntityForwardVector(weapon)
    local camCoords = coords + forwardVector * -0.5
    TaskLookAtCoord(weapon, camCoords.x, camCoords.y, camCoords.z, 5000, 1, 1)
    SetCamUseShallowDofMode(camera, true)
    SetCamNearDof(camera, 1.2)
    SetCamFarDof(camera, 12.0)
    SetCamDofStrength(camera, 1.0)
    SetCamDofMaxNearInFocusDistance(camera, 1.0)
end

function EditableFunction:CreateBattery(itemID)
    if batteryStatusMap[itemID] then
        Shared:GetDebug("L'oggetto con ID " .. itemID .. " è già stato spawnato. Uscita dalla funzione.")
        return batteryStatusMap[itemID]
    end

    local baseBatteryStatus = 100
    local status = EditableFunction:GetBatteryStatusByDb()

    if status and status.battery then
        baseBatteryStatus = status.battery
    end

    batteryStatusMap[itemID] = baseBatteryStatus
    Shared:GetDebug("Object Placed " .. itemID .. ": " .. batteryStatusMap[itemID])
    local DurationBattery = CB.DurationBattery * 1000
    Citizen.CreateThread(function()
        while batteryStatusMap[itemID] and type(batteryStatusMap[itemID]) == "number" and batteryStatusMap[itemID] > 0 do
            if EditableFunction:IsObjectSpawned(itemID) then
                Citizen.Wait(DurationBattery)
                if batteryStatusMap[itemID] then
                    batteryStatusMap[itemID] = batteryStatusMap[itemID] - 1
                    if batteryStatusMap[itemID] < 0 then
                        batteryStatusMap[itemID] = 0
                    end
                    Shared:GetDebug("Stato della batteria per l'oggetto " .. itemID .. ": " .. batteryStatusMap[itemID])
                else
                    Shared:GetDebug("Errore: Il valore di batteryStatusMap[" ..
                        itemID .. "] non è stato inizializzato correttamente., azione Eseguita Correttamente")
                end
            else
                Citizen.Wait(1000)
                Shared:GetDebug("L'oggetto con ID " ..
                    itemID .. " non è stato spawnato. La batteria non verrà scaricata.")
            end
        end
    end)

    return batteryStatusMap[itemID]
end

function EditableFunction:DeleteBatteryProgress()
    lib.progressBar({
        duration = 7 * 1000,
        label = 'Destroy Printer',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
        },
        anim = {
            scenario = "WORLD_HUMAN_WELDING"
        }
    })
end

function EditableFunction:DeleteBattery(itemID)
    if batteryStatusMap[itemID] ~= nil then
        batteryStatusMap[itemID] = nil
        Shared:GetDebug("Battery with ID " .. itemID .. " deleted successfully.")
    else
        warn("Battery with ID " .. itemID .. " does not exist.")
    end
end

function EditableFunction:GetBatteryStatusByDb()
    local StatusData = lib.callback.await('LegacyBanking:GetStatusBatteryDb', false)
    if StatusData and next(StatusData) ~= nil then
        local firstData = StatusData[1]
        local ItemData = {
            serialNumber = firstData.serialNumber,
            battery = firstData.batteryStatus,
            identifier = firstData.identifier,
        }
        Shared:GetDebug("ItemData", json.encode(ItemData))
        return ItemData
    else
        warn("Battery status data is empty. Generating random battery status.")
        local randomBatteryStatus = math.random(1, 100)
        local randomItemData = {
            serialNumber = "randomSerialNumber",
            battery = randomBatteryStatus,
            identifier = "randomIdentifier",
        }
        Shared:GetDebug("randomItemData", json.encode(randomItemData))
        return randomItemData
    end
end

function EditableFunction:SetObjectSpawnStatus(itemID, isSpawned)
    objectSpawnStatusMap[itemID] = isSpawned
end

function EditableFunction:IsObjectSpawned(itemID)
    return objectSpawnStatusMap[itemID] or false
end

function EditableFunction:IsRaining()
    local weatherTypes = {
        "RAIN", "THUNDER", "CLEARING"
    }
    local _, currentWeatherType = GetWeatherTypeTransition()
    for _, weather in ipairs(weatherTypes) do
        if currentWeatherType == GetHashKey(weather) then
            return true
        end
    end
    return false
end

function EditableFunction:GetWeatherTypeNameFromHash(weatherHash)
    local WeatherTypes = {
        [joaat('BLIZZARD')] = 'Blizzard',
        [joaat('CLEAR')] = 'Clear',
        [joaat('CLEARING')] = 'Clearing',
        [joaat('CLOUDS')] = 'Clouds',
        [joaat('EXTRASUNNY')] = 'Extrasunny',
        [joaat('FOGGY')] = 'Foggy',
        [joaat('LIGHTSNOW')] = 'Lightsnow',
        [joaat('NEUTRAL')] = 'Neutral',
        [joaat('OVERCAST')] = 'Overcast',
        [joaat('RAIN')] = 'Rain',
        [joaat('SMOG')] = 'Smog',
        [joaat('SNOW')] = 'Snow',
        [joaat('THUNDER')] = 'Thunder',
        [joaat('XMAS')] = 'Xmas',
        [joaat('HALLOWEEN')] = 'Halloween',
    }

    return WeatherTypes[weatherHash] or "UNKNOWN"
end

function EditableFunction:GetBatteryStatus(itemID)
    return batteryStatusMap[itemID]
end

function EditableFunction:RestoredBatteryPrinter(itemID)
    if not batteryStatusMap[itemID] then
        print("Errore: Batteria non trovata per l'oggetto con ID:", itemID)
        return
    end

    EditableFunction:ProgressHackingCoolDown('Recharging Battery', 20000)
    batteryStatusMap[itemID] = 100

    Shared:GetDebug("Batteria per l'oggetto con ID", itemID, "ripristinata al 100%.")
end

function EditableFunction:SetBatteryStatus(itemID , percentuale)
    if not batteryStatusMap[itemID] then
        print("Errore: Batteria non trovata per l'oggetto con ID:", itemID)
        return
    end

    -- EditableFunction:ProgressHackingCoolDown('Recharging Battery', 20000)
    batteryStatusMap[itemID] = percentuale

    Shared:GetDebug("Batteria per l'oggetto con ID", itemID, "ripristinata al" .. ' ' ..percentuale)
end

function EditableFunction:DestroyCamera()
    DestroyAllCams(false)
    RenderScriptCams(false, true, 1250, 1, 0)
end

function EditableFunction:CreatePreset()
    for _, v in pairs(CB.FakeCreditCard) do
        local skillCheckData = v.SkillCheck
        local preset = {}
        if skillCheckData.Enable then
            if CB.SkillCheckType == 'ox' then
                if skillCheckData.Difficulty == 'easy' then
                    preset = {
                        { areaSize = 50, speedMultiplier = 1 },
                        { areaSize = 50, speedMultiplier = 1 }
                    }
                elseif skillCheckData.Difficulty == 'normal' then
                    preset = {
                        { areaSize = 40, speedMultiplier = 1.5 },
                        { areaSize = 40, speedMultiplier = 1.5 },
                        { areaSize = 40, speedMultiplier = 1.5 }
                    }
                elseif skillCheckData.Difficulty == 'hard' then
                    preset = {
                        { areaSize = 25, speedMultiplier = 1.75 },
                        { areaSize = 25, speedMultiplier = 1.75 },
                        { areaSize = 25, speedMultiplier = 1.75 },
                        { areaSize = 25, speedMultiplier = 1.75 },
                    }
                elseif skillCheckData.Difficulty == 'insane' then
                    preset = {
                        { areaSize = 20, speedMultiplier = 2 },
                        { areaSize = 20, speedMultiplier = 2 },
                        { areaSize = 20, speedMultiplier = 2 },
                        { areaSize = 20, speedMultiplier = 2 },
                        { areaSize = 20, speedMultiplier = 2 },
                    }
                end
            elseif CB.SkillCheckType == 'bl' then
                if skillCheckData.TypeSkill == 'circle' then
                    if skillCheckData.Difficulty == 'easy' then
                        preset = {
                            iterations = 2,
                            difficulty = 30
                        }
                    elseif skillCheckData.Difficulty == 'normal' then
                        preset = {
                            iterations = 4,
                            difficulty = 50
                        }
                    elseif skillCheckData.Difficulty == 'hard' then
                        preset = {
                            iterations = 5,
                            difficulty = 70
                        }
                    elseif skillCheckData.Difficulty == 'insane' then
                        preset = {
                            iterations = 7,
                            difficulty = 90
                        }
                    end
                elseif skillCheckData.TypeSkill == 'progress' then
                    if skillCheckData.Difficulty == 'easy' then
                        preset = {
                            iterations = 2,
                            difficulty = 40
                        }
                    elseif skillCheckData.Difficulty == 'normal' then
                        preset = {
                            iterations = 4,
                            difficulty = 60
                        }
                    elseif skillCheckData.Difficulty == 'hard' then
                        preset = {
                            iterations = 5,
                            difficulty = 80
                        }
                    elseif skillCheckData.Difficulty == 'insane' then
                        preset = {
                            iterations = 7,
                            difficulty = 100
                        }
                    end
                end
            end

            difficultyPresets[skillCheckData.Difficulty] = preset
        end
    end
end

function EditableFunction:performSkillCheck(zoneName)
    if CB.SkillCheckType == 'ox' then
        local preset = CB.FakeCreditCard[zoneName] or CB.BankingZone[zoneName]
        local difficulty = preset.SkillCheck.Difficulty
        if preset.SkillCheck.Enable then
            local presetData = difficultyPresets[difficulty]
            local success = lib.skillCheck(presetData, { 'w', 'a', 's', 'd' })
            return success
        else
            return false
        end
    elseif CB.SkillCheckType == 'bl' then
        local preset = CB.FakeCreditCard[zoneName] or CB.BankingZone[zoneName]
        local difficulty = preset.SkillCheck.Difficulty
        if preset.SkillCheck.Enable then
            local presetData = difficultyPresets[difficulty]
            if preset.SkillCheck.TypeSkill == 'circle' then
                local success = exports.bl_ui:CircleProgress(presetData.iterations, presetData.difficulty)
                return success
            elseif preset.SkillCheck.TypeSkill == 'progress' then
                local success = exports.bl_ui:Progress(presetData.iterations, presetData.difficulty)
                return success
            end
        else
            return false
        end
    end
end

local ConvarsAtm = GetConvar('LGF_Banking:EnableAllAtmBlips', 'false')

if ConvarsAtm == "true" then
    local ATM = {
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = -386.733,  y = 6045.953,  z = 31.501 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = -284.037,  y = 6224.385,  z = 31.187 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = -284.037,  y = 6224.385,  z = 31.187 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = -135.165,  y = 6365.738,  z = 31.101 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = -110.753,  y = 6467.703,  z = 31.784 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = -94.9690,  y = 6455.301,  z = 31.784 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 155.4300,  y = 6641.991,  z = 31.784 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 174.6720,  y = 6637.218,  z = 31.784 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 1703.138,  y = 6426.783,  z = 32.730 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 1735.114,  y = 6411.035,  z = 35.164 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 1702.842,  y = 4933.593,  z = 42.051 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 1967.333,  y = 3744.293,  z = 32.272 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 1821.917,  y = 3683.483,  z = 34.244 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 1174.532,  y = 2705.278,  z = 38.027 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 540.0420,  y = 2671.007,  z = 42.177 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 2564.399,  y = 2585.100,  z = 38.016 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 2558.683,  y = 349.6010,  z = 108.050 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 2558.051,  y = 389.4817,  z = 108.660 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 1077.692,  y = -775.796,  z = 58.218 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 1139.018,  y = -469.886,  z = 66.789 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 1168.975,  y = -457.241,  z = 66.641 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 1153.884,  y = -326.540,  z = 69.245 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 381.2827,  y = 323.2518,  z = 103.270 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 236.4638,  y = 217.4718,  z = 106.840 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 265.0043,  y = 212.1717,  z = 106.780 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 285.2029,  y = 143.5690,  z = 104.970 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = -203.548,  y = -861.588,  z = 30.205 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 112.4102,  y = -776.162,  z = 31.427 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 112.9290,  y = -818.710,  z = 31.386 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 119.9000,  y = -883.826,  z = 31.191 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 149.4551,  y = -1038.95,  z = 29.366 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = -846.304,  y = -340.402,  z = 38.687 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = -1204.35,  y = -324.391,  z = 37.877 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = -1216.27,  y = -331.461,  z = 37.773 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = -56.1935,  y = -1752.53,  z = 29.452 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = -261.692,  y = -2012.64,  z = 30.121 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = -273.001,  y = -2025.60,  z = 30.197 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 314.187,   y = -278.621,  z = 54.170 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = -351.534,  y = -49.529,   z = 49.042 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 24.589,    y = -946.056,  z = 29.357 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = -254.112,  y = -692.483,  z = 33.616 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = -1570.197, y = -546.651,  z = 34.955 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = -1415.909, y = -211.825,  z = 46.500 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = -1430.112, y = -211.014,  z = 46.500 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 33.232,    y = -1347.849, z = 29.497 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 129.216,   y = -1292.347, z = 29.269 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 287.645,   y = -1282.646, z = 29.659 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 289.012,   y = -1256.545, z = 29.440 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 295.839,   y = -895.640,  z = 29.217 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 1686.753,  y = 4815.809,  z = 42.008 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = -302.408,  y = -829.945,  z = 32.417 },
        { name = "ATM", id = 277, sprite = 108, scale = 1.0, shortrange = true, color = 2, x = 5.134,     y = -919.949,  z = 29.557 },
    }
    function EditableFunction.CreateBlipsForATMs()
        for _, atmData in ipairs(ATM) do
            local blip = AddBlipForCoord(atmData.x, atmData.y, atmData.z)
            SetBlipSprite(blip, atmData.id)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, atmData.scale or 0.9)
            SetBlipColour(blip, atmData.color or 2)
            SetBlipAsShortRange(blip, atmData.shortrange or true)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(atmData.name)
            EndTextCommandSetBlipName(blip)
        end
    end

    EditableFunction.CreateBlipsForATMs()
end

function EditableFunction:SendDispatchAlert(coords)
    PlaySound(-1, "Event_Message_Purple", "GTAO_FM_Events_Soundset")
    EditableFunction:CreateDispatchBlip(coords)
    Await(CB.DurationBlipDispatch * 1000)
    EditableFunction:RemoveDispatchBlip()
end

RegisterNetEvent('LegacyBanking:SendDispatchAlert', function(coords)
    EditableFunction:SendDispatchAlert(coords)
end)

function EditableFunction:CreateDispatchBlip(coords)
    dispatchBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(dispatchBlip, 161)
    SetBlipDisplay(dispatchBlip, 4)
    SetBlipScale(dispatchBlip, 1.0)
    SetBlipColour(dispatchBlip, 1)
    SetBlipAsShortRange(dispatchBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Dispatch Call")
    EndTextCommandSetBlipName(dispatchBlip)
    SetBlipShrink(dispatchBlip, true)
    SetBlipShowCone(dispatchBlip, true)
end

function EditableFunction:RemoveDispatchBlip()
    if dispatchBlip ~= nil then
        RemoveBlip(dispatchBlip)
        dispatchBlip = nil
    end
end

function EditableFunction:CreateProgressRobbery(zoneDispatch, msg)
    local ZoneData = CB.BankingZone[zoneDispatch]
    local promise = promise.new()
    local progressBarData = {
        duration = CB.DurationRobbery * 1000,
        label = msg,
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
        },
        anim = {
            scenario = "WORLD_HUMAN_WELDING"
        }
    }

    local function onComplete()
        promise:resolve()
    end

    if CB.TypeProgressBar == 'circle' then
        lib.progressCircle(progressBarData, onComplete)
    elseif CB.TypeProgressBar == 'label' then
        lib.progressBar(progressBarData, onComplete)
    else
        promise:resolve()
    end
    return promise
end

function EditableFunction:CheckCooldown()
    Citizen.CreateThread(function()
        local startTime = GetGameTimer()
        IsInCoolDown = true
        while IsInCoolDown do
            Wait(1000)
            local elapsedTime = GetGameTimer() - startTime
            local remainingTime = coolDownTime - (elapsedTime / 1000)
            Shared:GetDebug("Remaining cooldown time seconds: ", remainingTime)
            if remainingTime <= 0 then
                IsInCoolDown = false
                Shared:GetDebug('cooldown finito')
            end
        end
    end)
end

function EditableFunction:GetCooldown()
    return IsInCoolDown
end

function EditableFunction:ToolRemoveCoolDown()
    local playerId = cache.serverId
    local playerPed = cache.ped
    local playerCoords = GetEntityCoords(playerPed)
    if EditableFunction:GetCooldown() then
        local dict = lib.requestAnimDict("amb@world_human_tourist_map@male@base")
        local model = lib.requestModel("prop_cs_tablet")
        TaskPlayAnim(playerPed, dict, "base", 2.0, 2.0, -1, 51, 0, false, false, false)
        local toolReducerCooldown = CreateObject(model, playerCoords.x, playerCoords.y, playerCoords.z + 0.2, true, true,
            true)
        AttachEntityToEntity(toolReducerCooldown, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, -0.03, 0.0, 20.0,
            -90.0, 0.0, true, true, false, true, 1, true)
        Shared:GetDebug("Cooldown ridotto a 0.")
        EditableFunction:ProgressHackingCoolDown('Hacking Cooldown System', CB.TimeHackingCooldown * 1000)
        TriggerServerEvent('LegacyBanking:hackingCoolDown', playerId)
        ClearPedTasks(playerPed)
        DeleteObject(toolReducerCooldown)
        IsInCoolDown = false
    end
end

-- function EditableFunction:GetPlayerGroup()
--     local Playergroup
--     if CB.ProviderCore == 'lgf' then
--         local PlayerData = LGF.PlayerFunctions.GetClientData()[1]
--         Playergroup = PlayerData.playerGroup
--     end
--     if CB.ProviderCore == 'esx' then
        
--     end
--     if CB.ProviderCore == 'qb' then
        
--     end
--     return Playergroup
-- end

exports('ToolRemoveCoolDown', EditableFunction.ToolRemoveCoolDown)
EditableFunction:CreatePreset()
