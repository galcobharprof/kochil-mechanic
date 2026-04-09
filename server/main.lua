local qbx = exports.qbx_core

-- Comprehensive GTA 5 Color Mapping Table
local VehicleColorNames = {
    [0] = "Metallic Black", [1] = "Metallic Graphite Black", [2] = "Metallic Black Steel", [3] = "Metallic Dark Silver", [4] = "Metallic Silver", [5] = "Metallic Blue Silver", [6] = "Metallic Steel Gray", [7] = "Metallic Shadow Silver", [8] = "Metallic Stone Silver", [9] = "Metallic Midnight Silver", [10] = "Metallic Gun Metal", [11] = "Metallic Anthracite Gray", [12] = "Matte Black", [13] = "Matte Gray", [14] = "Matte Light Gray", [15] = "Util Black", [16] = "Util Black Poly", [17] = "Util Dark Silver", [18] = "Util Silver", [19] = "Util Gun Metal", [20] = "Util Shadow Silver", [21] = "Worn Black", [22] = "Worn Graphite", [23] = "Worn Silver Gray", [24] = "Worn Silver", [25] = "Worn Blue Silver", [26] = "Worn Shadow Silver", [27] = "Metallic Red", [28] = "Metallic Torino Red", [29] = "Metallic Formula Red", [30] = "Metallic Blaze Red", [31] = "Metallic Graceful Red", [32] = "Metallic Garnet Red", [33] = "Metallic Desert Red", [34] = "Metallic Cabernet Red", [35] = "Metallic Candy Red", [36] = "Metallic Sunrise Orange", [37] = "Metallic Classic Gold", [38] = "Metallic Orange", [39] = "Matte Red", [40] = "Matte Dark Red", [41] = "Matte Orange", [42] = "Matte Yellow", [43] = "Util Red", [44] = "Util Bright Red", [45] = "Util Garnet Red", [46] = "Worn Red", [47] = "Worn Golden Red", [48] = "Worn Dark Red", [49] = "Metallic Dark Green", [50] = "Metallic Racing Green", [51] = "Metallic Sea Green", [52] = "Metallic Olive Green", [53] = "Metallic Green", [54] = "Metallic Gasoline Blue Green", [55] = "Matte Lime Green", [56] = "Util Dark Green", [57] = "Util Green", [58] = "Worn Dark Green", [59] = "Worn Green", [60] = "Worn Sea Wash", [61] = "Metallic Midnight Blue", [62] = "Metallic Dark Blue", [63] = "Metallic Saxony Blue", [64] = "Metallic Blue", [65] = "Metallic Mariner Blue", [66] = "Metallic Harbor Blue", [67] = "Metallic Diamond Blue", [68] = "Metallic Surf Blue", [69] = "Metallic Nautical Blue", [70] = "Metallic Bright Blue", [71] = "Metallic Purple Blue", [72] = "Metallic Spinnaker Blue", [73] = "Metallic Ultra Blue", [74] = "Metallic Bright Blue", [75] = "Util Dark Blue", [76] = "Util Midnight Blue", [77] = "Util Blue", [78] = "Util Sea Foam Blue", [79] = "Util Lightning Blue", [80] = "Util Maui Blue Poly", [81] = "Util Bright Blue", [82] = "Matte Dark Blue", [83] = "Matte Blue", [84] = "Matte Midnight Blue", [85] = "Worn Dark Blue", [86] = "Worn Blue", [87] = "Worn Light Blue", [88] = "Metallic Taxi Yellow", [89] = "Metallic Race Yellow", [90] = "Metallic Bronze", [91] = "Metallic Yellow Bird", [92] = "Metallic Lime", [93] = "Metallic Champagne", [94] = "Metallic Pueblo Beige", [95] = "Metallic Dark Ivory", [96] = "Metallic Choco Brown", [97] = "Metallic Golden Brown", [98] = "Metallic Light Brown", [99] = "Metallic Straw Beige", [100] = "Metallic Moss Brown", [101] = "Metallic Biston Brown", [102] = "Metallic Beechwood", [103] = "Metallic Dark Beechwood", [104] = "Metallic Choco Orange", [105] = "Metallic Beach Sand", [106] = "Metallic Sun Bleeched Sand", [107] = "Metallic Cream", [108] = "Util Brown", [109] = "Util Medium Brown", [110] = "Util Light Brown", [111] = "Metallic White", [112] = "Metallic Frost White", [113] = "Worn Honey Beige", [114] = "Worn Brown", [115] = "Worn Dark Brown", [116] = "Worn straw beige", [117] = "Brushed Steel", [118] = "Brushed Black steel", [119] = "Brushed Aluminium", [120] = "Chrome", [121] = "Worn Off White", [122] = "Util Off White", [123] = "Worn Orange", [124] = "Worn Light Orange", [125] = "Metallic Securicor Green", [126] = "Worn Taxi Yellow", [127] = "police car blue", [128] = "Matte Green", [129] = "Matte Brown", [130] = "Worn Orange", [131] = "Matte White", [132] = "Worn White", [133] = "Worn Olive Army Green", [134] = "Pure White", [135] = "Hot Pink", [136] = "Salmon pink", [137] = "Metallic Vermillion Pink", [138] = "Orange", [139] = "Green", [140] = "Blue", [141] = "Mettallic Black Blue", [142] = "Metallic Black Purple", [143] = "Metallic Black Red", [144] = "hunter green", [145] = "Metallic Purple", [146] = "Metaillic V Dark Blue", [147] = "MODSHOP BLACK1", [148] = "Matte Purple", [149] = "Matte Dark Purple", [150] = "Metallic Lava Red", [151] = "Matte Forest Green", [152] = "Matte Olive Drab", [153] = "Matte Desert Brown", [154] = "Matte Desert Tan", [155] = "Matte Foilage Green", [156] = "DEFAULT ALLOY COLOR", [157] = "Epsilon Blue", [158] = "Pure Gold", [159] = "Brushed Gold"
}

-- Performance Mods Mapping (Mod IDs that should show "Level" instead of "Option")
local PerformanceMods = {
    [11] = "Engine",
    [12] = "Brakes",
    [13] = "Transmission",
    [15] = "Suspension"
}

-- Helper function to generate human-readable detailed list from vehicle props
local function GetModDescription(props)
    local lines = {}
    if not props then return "No data found." end

    local hasMods = false

    -- Physical Mods
    if props.mods then
        for k, v in pairs(props.mods) do
            local modId = tonumber(k)
            if modId and Config.ModLabels[modId] then
                local label = Config.ModLabels[modId]
                local value = ""
                
                -- Check if it's a performance part
                if PerformanceMods[modId] then
                    value = "Level " .. (v + 1)
                else
                    value = "Option " .. (v + 1)
                end
                
                table.insert(lines, "- " .. label .. ": " .. value)
                hasMods = true
            end
        end
    end

    -- Performance Toggles
    if props.modTurbo then 
        table.insert(lines, "- Turbocharger: Installed") 
        hasMods = true
    end
    if props.modXenon then 
        table.insert(lines, "- Xenon Headlights: Active") 
        hasMods = true
    end
    
    -- Visual Elements (Painting with Name translation)
    if props.color1 then 
        local colorName = VehicleColorNames[props.color1] or ("Color #" .. props.color1)
        table.insert(lines, "- Primary Color: " .. colorName) 
        hasMods = true
    end
    if props.color2 then 
        local colorName = VehicleColorNames[props.color2] or ("Color #" .. props.color2)
        table.insert(lines, "- Secondary Color: " .. colorName) 
        hasMods = true
    end
    if props.pearlescentColor then
        local colorName = VehicleColorNames[props.pearlescentColor] or ("Color #" .. props.pearlescentColor)
        table.insert(lines, "- Pearlescent: " .. colorName)
        hasMods = true
    end
    if props.wheelColor then
        local colorName = VehicleColorNames[props.wheelColor] or ("Color #" .. props.wheelColor)
        table.insert(lines, "- Rim Color: " .. colorName)
        hasMods = true
    end

    if not hasMods then 
        return "No specific modifications were recorded for this work order." 
    else 
        return table.concat(lines, "\n")
    end
end

-- Registration for Brochure (Preview/Pay)
exports.qbx_core:CreateUseableItem(Config.ModItem, function(source, item)
    if item.name ~= Config.ModItem then return end
    TriggerClientEvent('qbx_mechanicjob_custom:client:openBrochure', source)
end)

-- Registration for Notes (Mechanic Install)
exports.qbx_core:CreateUseableItem(Config.NotesItem, function(source, item)
    if item.name ~= Config.NotesItem then return end
    
    local player = qbx:GetPlayer(source)
    if player.PlayerData.job.name ~= Config.JobName then
        exports.qbx_core:Notify(source, 'Only a '..Config.JobName..' can interpret these notes!', 'error')
        return
    end

    if not item.metadata or not item.metadata.vehicleProps then
        exports.qbx_core:Notify(source, 'These notes seem to be blank...', 'error')
        return
    end

    TriggerClientEvent('qbx_mechanicjob_custom:client:startInstallation', source, item.slot, item.metadata.vehicleProps)
end)

-- Registration for Receipt (View RP Details)
exports.qbx_core:CreateUseableItem(Config.ReceiptItem, function(source, item)
    if item.name ~= Config.ReceiptItem then return end
    
    if not item.metadata or not item.metadata.description then
        return exports.qbx_core:Notify(source, 'This receipt is unreadable.', 'error')
    end
    
    TriggerClientEvent('qbx_mechanicjob_custom:client:viewReceipt', source, item.metadata.description)
end)

-- Helper function to generate a vertical list directly from the shopping cart (items)
local function GenerateOrderDescription(items)
    if not items or items == "" or type(items) ~= "table" then return "Standard Adjustments" end
    
    local lines = {}
    for k, item in pairs(items) do
        if item and item.label then
            -- Detailed formatting: "- Name : Detail (Option/Level/Color)"
            local detail = "Modified"
            if item.level ~= nil then
                -- Performance parts or body parts that use 'level' as index
                local mid = tonumber(item.modId)
                if mid == 11 or mid == 12 or mid == 13 or mid == 15 then
                    detail = "Level " .. (item.level + 1)
                else
                    detail = "Option " .. (item.level + 1)
                end
            elseif item.colorId ~= nil then
                detail = VehicleColorNames[item.colorId] or ("Color #" .. item.colorId)
            end

            -- Special Case for Wheels: Include Category Name
            local label = item.label
            if item.wheelType ~= nil and item.modId == 23 then
                label = "Wheels (" .. label .. ")" 
            end

            table.insert(lines, "- " .. label .. " : " .. detail)
        end
    end

    if #lines == 0 then return "Standard Adjustments" end
    return table.concat(lines, "\n")
end

-- Step 1: Complete Checkout (Pay & Get Notes)
lib.callback.register('qbx_mechanicjob_custom:server:completeCheckout', function(source, totalCost, props, items)
    local player = qbx:GetPlayer(source)
    if not player then return false end

    -- 1. Generate Metadata FIRST
    local orderDetails = "Standard Adjustments"
    local pSuccess, pErr = pcall(function()
        orderDetails = GenerateOrderDescription(items)
    end)
    if not pSuccess then print('DEBUG: [SERVER] Error in description gen: ' .. tostring(pErr)) end

    local metadata = {
        vehicleProps = props,
        plate = props.plate,
        description = "Vehicle Order [" .. props.plate .. "]\n\n" .. orderDetails
    }

    -- 2. Validate Payment
    local paymentMethod = nil
    if player.PlayerData.money.cash >= totalCost then
        paymentMethod = 'cash'
    elseif player.PlayerData.money.bank >= totalCost then
        paymentMethod = 'bank'
    else
        exports.qbx_core:Notify(source, 'Insufficient funds!', 'error')
        return false
    end

    -- 3. Give Item FIRST (Safest approach)
    local added = exports.ox_inventory:AddItem(source, Config.NotesItem, 1, metadata)
    
    if added then
        -- 4. Finalize Payment
        player.Functions.RemoveMoney(paymentMethod, totalCost)
        Config.AddSocietyMoney(totalCost)
        exports.ox_inventory:RemoveItem(source, Config.ModItem, 1)
        print('DEBUG: [SERVER] Checkout SUCCESS for ' .. props.plate)
        return true
    else
        print('DEBUG: [SERVER] CRITICAL ERROR - AddItem FAILED. No money taken.')
        exports.qbx_core:Notify(source, 'Inventory error! Order cancelled.', 'error')
        return false
    end
end)

-- Step 2: Finalize Installation (Consume Notes & Get Receipt)
RegisterNetEvent('qbx_mechanicjob_custom:server:finishInstallation', function(slot, props)
    local source = source
    local player = qbx:GetPlayer(source)
    if not player then return end

    -- Fetch the specific item from slot to get the original order description
    local notesItem = exports.ox_inventory:GetSlot(source, slot)
    local orderDetails = "Standard Job"
    if notesItem and notesItem.metadata and notesItem.metadata.description then
        -- Extract the mods list (removing the header title we added in Step 1)
        orderDetails = notesItem.metadata.description:gsub("Vehicle Order %[(.-)%]%s+", "")
    end

    -- Remove the notes
    exports.ox_inventory:RemoveItem(source, Config.NotesItem, 1, nil, slot)

    -- Grant the Modification Receipt with the DETAILED description
    exports.ox_inventory:AddItem(source, Config.ReceiptItem, 1, {
        description = "RECEIPT FOR PLATE [" .. (props.plate or "N/A") .. "]\n\n" .. orderDetails
    })
    exports.qbx_core:Notify(source, 'Installation complete! Receipt issued.', 'success')
end)

-- Health/Repair Callback
lib.callback.register('qbx_mechanicjob_custom:server:selfRepair', function(source)
    local player = qbx:GetPlayer(source)
    local cash = player.PlayerData.money.cash
    local bank = player.PlayerData.money.bank

    if cash >= Config.SelfRepairPrice then
        player.Functions.RemoveMoney('cash', Config.SelfRepairPrice)
        Config.AddSocietyMoney(Config.SelfRepairPrice)
        return true
    elseif bank >= Config.SelfRepairPrice then
        player.Functions.RemoveMoney('bank', Config.SelfRepairPrice)
        Config.AddSocietyMoney(Config.SelfRepairPrice)
        return true
    else
        exports.qbx_core:Notify(source, 'Not enough money!', 'error')
        return false
    end
end)

-- Impound Vehicle Event
RegisterNetEvent('qbx_mechanicjob_custom:server:impoundVehicle', function(plate)
    MySQL.update('UPDATE player_vehicles SET state = 2 WHERE plate = ?', {plate})
    lib.print.info('Vehicle with plate '..plate..' has been impounded by a mechanic.')
end)
