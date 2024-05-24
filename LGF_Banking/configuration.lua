CB                    = {}

CB.ProviderCore       = 'lgf'              -- Put your Framework/Core - lgf, esx, qb
CB.ProviderNotify     = 'ox'               -- Put Your System Notification - lgf, esx, ox
-- CB.RunSqlTable             = false              -- If true, run and create table 'lgf_banking' and 'lgf_printer' in DB
CB.ItemCreditCard     = 'credit_card'      -- Item Credit Card
CB.PriceCreditCard    = 2000               -- Price for buying Credit Card
CB.ItemFakeCreditCard = 'fake_credit_card' -- Fake Item Credit Card
CB.TypeProgressBar    = 'label'            -- Type Progress Bar: circle or label
CB.SkillCheckType     = 'bl'               -- SkillCheck Type: 'bl' or 'ox'


-- Group allowed for open Menu Printer
CB.GroupOpenPrinterMenu    = {
    lgf = { -- lgf core

        { 'admin', 'player', }
    },
    esx = { -- esx core

        { 'admin', 'mod', 'user' }
    }
}

-- Prop Model for ATM
CB.PropAtm                 = {
    { "prop_atm_03" },
    { "prop_fleeca_atm" },
    { "prop_atm_01" },
    { "prop_atm_02" }
}

-- Determines the maximum rank for registered jobs, the highest rank will have access to Society Fund directly in the bank
CB.GradeJob                = {
    { Job = 'police',    GradeBoss = 2 },
    { Job = 'ambulance', GradeBoss = 2 }
}

-- Param Data SkillCheck
-- Types Difficulty
-- easy = Skill check with 2 spins
-- normal = Skill check with 3 spins
-- hard = Skill check with 4 spins
-- insane = Skill check with 5 spins

-- Ped Zone for Bank
CB.BankingZone             = {
    ['Bank-Aveneue'] = {
        PedPosBank           = vec4(149.4931, -1042.1469, 29.3680, 343.5447), -- Ped position (bank teller)
        PedModelBank         = 'cs_bankman',                                  -- Ped model (bank teller)
        PedScenarioBank      = 'WORLD_HUMAN_CLIPBOARD',                       -- Ped scenario (bank teller)
        RobberyZone          = vec3(143.4891, -1041.6813, 29.3679),           -- Zone for starting the robbery
        ItemRequestedRobbery = 'water',                                       -- Item requested to start the robbery
        QntItemRequested     = 3,                                             -- Quantity requested of the item to start the robbery
        RobberyDrop          = {                                              -- Items that can be dropped during the robbery with minimum and maximum quantity
            ['money'] = { min = 4420, max = 7850 },
        },
        SkillCheck           = {
            Enable     = true,     -- Enable or disable skill check for robbery
            Difficulty = 'normal', -- Difficulty of the skill check: easy, normal, hard, insane
            TypeSkill  = 'circle'  -- Type of skill check: circle or progress
        },
        BlipData             = {   -- Blip data for the bank
            Enable     = true,
            Label      = 'Bank',
            Scale      = 1.0,
            Sprite     = 108,
            ShortRange = true
        }
    }
}

CB.EnableCam               = true -- Enable Cam for Ped

CB.FakeCreditCard          = {     -- Data for Seller Credit Card Fake
    ['Seller1'] = {
        PedPosSell      = vec4(1276.6000, -1713.5, 54.3196, 110.4862),
        PedModelSell    = 'hc_hacker',
        PedScenarioSell = 'WORLD_HUMAN_SEAT_WALL_TABLET',
        PriceFakeCard   = 2000,
        PriceHackPin    = 1000,
        SkillCheck      = {         -- Skillcheck for hacking pin
            Enable     = true,      -- If false, disable skillcheck
            Difficulty = 'normal',  -- easy, normal, hard, insane
            TypeSkill  = 'progress' -- circle or progress (Only for bl_ui)
        },
        ShopTool        = {
            { LabelTool = 'Bypass CoolDown Tools',     NameTool = 'tool_hack_cooldown',      PriceTool = 2000,  Description = 'Hack Tool for Bypass CoolDown system' },
            { LabelTool = 'Crafting Tools Printer 3D', NameTool = 'tool_3dprint',            PriceTool = 10000, Description = 'Craft tools related to robbery and hacking' },
            { LabelTool = 'Battery Printer 3D',        NameTool = 'battery_printer',         PriceTool = 4000,  Description = 'Recharge the battery properly when it runs out' },
            { LabelTool = 'Printer Wipe',              NameTool = 'tool_3dprint_delprinter', PriceTool = 20000, Description = 'Erase the traces of your 3D printer with a simple tool' },
            { LabelTool = 'Credit Card Duplicator',    NameTool = 'tool_steal_npcmoney',     PriceTool = 15000, Description = 'Simple tool to bypass civilian credit cards and duplicate them' },
        }
    }
}

CB.RemoveReducerItem       = 'remove'         -- consume or remove / if you use 'consume', remove the degrade from the creation of the item, if you use 'remove', once used it will be removed
CB.TimeHackingCooldown     = 20               -- Progress Bar Duration for hack with tool cooldown
CB.DebugSphereZone         = false            -- Debug Ox Target zone robbery
CB.DistPatchJob            = { 'police' } -- Job to send Dispatch Notification
CB.UseDispatchInternal     = true            -- If use internal dispatch, send ox lib notification with sprite blip in map
CB.DurationRobbery         = 20               -- Duration progress bar for robbery
CB.DurationBlipDispatch    = 60               -- Duration blip after alert
CB.UseCustomDispatch       = false             -- If use CB.UseCustomDispatch set to false CB.UseDispatchInternal

CB.CustomDistPatch         = function(playerId, coords, job)
    print('player id scatenato rapina ', playerId)
    print('coords scatenato rapina ', coords)
    print('job che arriva notifica ', job)
end

CB.GetWeatherStatusPrinter = true                  -- When there is rain, the printer will have two more description options with the current weather, and if it rains it cannot be used, and a further option will be shown with a warning
CB.DurationBattery         = 20                    -- After 20 seconds, remove 1
CB.ItemBattery             = 'battery_printer'     -- Item for recharging printer
CB.ItemProviderWipe        = 'tool_3dprint_delprinter'
CB.ItemProviderSteal       = 'tool_steal_npcmoney' -- item requested for steal at npc

-- ItemData for crafting in printer
CB.CraftingPrinter         = {
    { Label = 'Weapon Pistol',  itemHash = 'WEAPON_PISTOL',       ItemRequestedPrint = 'water', ItemRequestedQnt = 3, Description = 'A standard issue pistol with moderate damage and accuracy.', CraftingTime = 10, propHash = 'w_pi_pistol' },
    { Label = 'Carabine Rifle', itemHash = 'WEAPON_CARBINERIFLE', ItemRequestedPrint = 'water', ItemRequestedQnt = 5, Description = 'A submachine gun with high fire rate and decent damage.',    CraftingTime = 10, propHash = 'w_ar_carbinerifle' }
}

-- Stealing NPC Configuration / set convars for enable o disable
CB.StealingNpc             = {
    CardstealItem = 'stealing_card',
    TimeStealing = 20,
    DistanceCancelSteal = 10,        -- if you move 10 meters away during the robbery, for example, you will lose the connection
    DistanceStartAngryorScaried = 2, -- Meters/ if you get 3 meters closer during the progress bar you will be discovered and could scare or anger the civilian
    Price = {
        min = 2000,
        max = 4000,
    },

}
