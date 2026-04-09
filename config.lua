Config = {}

Config.JobName = 'mechanic'
Config.SocietyName = 'mechanic' -- Account name in Renewed-Banking / qb-management

-- Self-Repair Settings
Config.SelfRepairPrice = 1000
Config.ShowRepairBlips = true -- Show wrenches on the map for repair stations
Config.RepairBlipSettings = { sprite = 402, color = 5, scale = 0.6 }
Config.RepairStations = {
    { label = 'Public Repair Station', coords = vec3(499.01, -1336.29, 28.32), size = vec3(4.0, 6.0, 2.0), heading = 0 },
    { label = 'Public Repair Station', coords = vec3(1177.3, 2640.1, 37.8), size = vec3(4.0, 6.0, 2.0), heading = 0 }
}

-- Duty & Management
Config.DutyLocations = {
    { coords = vec3(-337.3, -135.2, 39.0), size = vec3(1.5, 1.5, 2.0), heading = 340 }
}
Config.ManagementLocations = {
    { coords = vec4(472.07, -1310.73, 28.22, 120.22), size = vec3(1.5, 1.5, 2.0), heading = 340 }
}
Config.BossGrade = 4 -- Minimum grade index for boss menu

-- Blip Settings
Config.ShopBlips = {
    { label = 'Mechanic Shop', coords = vec3(-337.1, -135.9, 39.0), sprite = 446, color = 5 },
    { label = 'Mechanic Shop', coords = vec2(1177.3, 2640.1), sprite = 446, color = 5 },
    { label = 'Mechanic Shop', coords = vec2(110.8, 6625.5), sprite = 446, color = 5 }
}
Config.BlipOnlyOnDuty = true -- User requested only show when on duty

-- Towing Settings
Config.TowVehicles = {
    [`flatbed`] = true
}

-- Modification Settings
Config.ModItem = 'mechanic_brochure'
Config.NotesItem = 'mechanic_notes'
Config.ReceiptItem = 'modif_notes'
Config.InstallDuration = 20000 -- 20 seconds

-- Society Money Wrapper (Change this if you switch Boss Menu scripts)
Config.AddSocietyMoney = function(amount)
    -- Using the new Ricky-BossMenu system we just integrated
    if exports['Ricky-BossMenu'] then
        exports['Ricky-BossMenu']:AddMoneyToSociety(Config.JobName, amount)
    else
        -- Fallback to Renewed-Banking if Ricky-BossMenu is missing
        exports['Renewed-Banking']:addAccountMoney(Config.SocietyName, amount)
    end
end

Config.ModPrices = {
    -- Default multipliers or static prices for mods
    ['engine'] = 500,
    ['brakes'] = 300,
    ['transmission'] = 400,
    ['suspension'] = 250,
    ['turbo'] = 1000,
    ['cosmetic'] = 100, -- Default for non-performance
    ['paint'] = 50,
    ['wheels'] = 200,
    ['extras'] = 150
}

-- Labels for Receipt Generation (Translated from mods.lua)
Config.ModLabels = {
    [0] = 'Spoiler', [1] = 'Front Bumper', [2] = 'Rear Bumper', [3] = 'Side Skirt',
    [4] = 'Exhaust', [5] = 'Chassis', [6] = 'Grille', [7] = 'Hood',
    [8] = 'Left Wing', [9] = 'Right Wing', [10] = 'Roof', [11] = 'Engine',
    [12] = 'Brakes', [13] = 'Transmission', [15] = 'Suspension', [18] = 'Turbo',
    [22] = 'Xenon Lights', [23] = 'Wheels', [14] = 'Horn',
    [25] = 'Plate Holder', [26] = 'Vanity Plate', [27] = 'Trim Design',
    [28] = 'Ornaments', [29] = 'Dashboard', [30] = 'Dial Design', [31] = 'Door Speakers',
    [32] = 'Seats', [33] = 'Steering Wheel', [34] = 'Shifter Levers', [35] = 'Plaques',
    [36] = 'Speakers', [37] = 'Trunk', [38] = 'Hydraulics', [39] = 'Engine Block',
    [40] = 'Air Filter', [41] = 'Strut Bar', [42] = 'Arch Cover', [43] = 'Aerials',
    [44] = 'Trim', [45] = 'Tank', [46] = 'Windows', [48] = 'Livery'
}

-- Target Interactions
Config.TargetSettings = {
    distance = 2.5
}
