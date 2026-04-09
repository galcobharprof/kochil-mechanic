local qbx = exports.qbx_core
local OriginalMods = {}
local IsModifying = false
local currentVehicle = 0

-- Camera State
local currentCamera = nil
local cameraRadius = 5.0
local cameraAzimuth = 0.0
local cameraElevation = 0.2

-- Mod Label Mapping
local ModLabels = {
    [0] = 'Spoiler', [1] = 'Front Bumper', [2] = 'Rear Bumper', [3] = 'Side Skirt',
    [4] = 'Exhaust', [5] = 'Chassis', [6] = 'Grille', [7] = 'Hood',
    [8] = 'Left Wing', [9] = 'Right Wing', [10] = 'Roof', [14] = 'Horn',
    [25] = 'Plate Holder', [26] = 'Vanity Plate', [27] = 'Trim Design',
    [28] = 'Ornaments', [29] = 'Dashboard', [30] = 'Dial Design', [31] = 'Door Speakers',
    [32] = 'Seats', [33] = 'Steering Wheel', [34] = 'Shifter Levers', [35] = 'Plaques',
    [36] = 'Speakers', [37] = 'Trunk', [38] = 'Hydraulics', [39] = 'Engine Block',
    [40] = 'Air Filter', [41] = 'Strut Bar', [42] = 'Arch Cover', [43] = 'Aerials',
    [44] = 'Trim', [45] = 'Tank', [46] = 'Windows', [48] = 'Livery'
}

-- Color Name Mapping
local ColorNames = {
    [0] = 'Black', [1] = 'Graphite', [2] = 'Black Steel', [3] = 'Dark Silver', [4] = 'Silver', [5] = 'Blue Silver', [6] = 'Steel Gray', [7] = 'Shadow Silver', [8] = 'Stone Silver', [9] = 'Midnight Silver', [10] = 'Gun Metal', [11] = 'Anthracite',
    [12] = 'Matte Black', [13] = 'Gray', [14] = 'Light Gray', [15] = 'Util Black', [16] = 'Util Black Poly', [17] = 'Util Dark silver', [18] = 'Util Silver', [19] = 'Util Gun Metal', [20] = 'Util Shadow Silver',
    [27] = 'Garnet Red', [28] = 'Candy Red', [29] = 'Tomato Red', [30] = 'Sunrise Orange', [31] = 'Italian Red', [32] = 'Candy Orange', [33] = 'Desert Gold', [34] = 'Dark Ivory', [35] = 'Beechwood', [36] = 'Sienna Brown', [37] = 'Golden Sand', [38] = 'Light Ivory',
    [39] = 'Matte Red', [40] = 'Matte Dark Red', [41] = 'Matte Orange', [42] = 'Matte Yellow', [49] = 'Metallic Dark Green', [50] = 'Metallic Racing Green', [51] = 'Metallic Sea Green', [52] = 'Metallic Olive Green', [53] = 'Metallic Green', [54] = 'Metallic Gasoline Blue',
    [61] = 'Metallic Midnight Blue', [62] = 'Metallic Dark Blue', [63] = 'Metallic Saxony Blue', [64] = 'Metallic Blue', [65] = 'Metallic Mariner Blue', [66] = 'Metallic Harbor Blue', [67] = 'Metallic Diamond Blue', [68] = 'Metallic Surf Blue', [69] = 'Metallic Nautical Blue', [70] = 'Metallic Bright Blue',
    [82] = 'Matte Dark Blue', [83] = 'Matte Blue', [84] = 'Matte Midnight Blue', [88] = 'Yellow', [89] = 'Race Yellow', [90] = 'Bronze', [91] = 'Flat Blue', [92] = 'Lime Green', [117] = 'Brushed Steel', [118] = 'Brushed Black steel', [119] = 'Aluminium', [120] = 'Chrome',
    [128] = 'Matte Green', [129] = 'Matte Brown', [131] = 'Matte White', [135] = 'Electric Pink', [136] = 'Salmon Pink', [137] = 'Sugar Pink', [145] = 'Bright Purple', [148] = 'Matte Purple', [149] = 'Matte Dark Purple', [150] = 'Lava Red', [151] = 'Matte Forest Green', [152] = 'Matte Olive Drab', [153] = 'Matte Desert Brown', [154] = 'Matte Desert Tan', [155] = 'Matte Foilage Green'
}

-- Paint Categories
local PaintCategories = {
    { label = 'Classic', colors = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 49, 50, 51, 52, 53, 54, 88, 89, 90} },
    { label = 'Matte', colors = {12, 13, 14, 39, 40, 41, 42, 82, 83, 84, 128, 129, 131, 148, 149, 151, 152, 153, 154, 155} },
    { label = 'Metals', colors = {117, 118, 119, 120} },
    { label = 'Pink & Purple', colors = {135, 136, 137, 145} }
}

-- Wheel Types
local WheelTypes = {
    { label = 'Sport', id = 0 }, { label = 'Muscle', id = 1 }, { label = 'Lowrider', id = 2 },
    { label = 'SUV', id = 3 }, { label = 'Offroad', id = 4 }, { label = 'High End', id = 5 },
    { label = 'Benny\'s', id = 6 }, { label = 'Open Wheel', id = 7 }
}

-- Camera Functions
function CreateModCamera()
    if not DoesEntityExist(currentVehicle) then return end
    local pos = GetEntityCoords(currentVehicle)
    cameraRadius = 5.0
    cameraAzimuth = 0.0
    cameraElevation = 0.2
    
    currentCamera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x, pos.y, pos.z + 1.0, 0.0, 0.0, 0.0, 50.0, false, 0)
    PointCamAtEntity(currentCamera, currentVehicle, 0.0, 0.0, 0.0, true)
    SetCamActive(currentCamera, true)
    RenderScriptCams(true, true, 500, true, true)
    UpdateCameraPosition()
end

function DestroyModCamera()
    if currentCamera then
        SetCamActive(currentCamera, false)
        RenderScriptCams(false, true, 500, true, true)
        DestroyCam(currentCamera, false)
        currentCamera = nil
        ClearFocus()
    end
end

function UpdateCameraPosition()
    if not currentCamera or not DoesEntityExist(currentVehicle) then return end
    local pos = GetEntityCoords(currentVehicle)
    local x = pos.x + cameraRadius * math.cos(cameraElevation) * math.sin(cameraAzimuth)
    local y = pos.y + cameraRadius * math.cos(cameraElevation) * math.cos(cameraAzimuth)
    local z = pos.z + cameraRadius * math.sin(cameraElevation)
    
    SetCamParams(currentCamera, x, y, z, 0.0, 0.0, 0.0, 50.0, 0, 1, 1, 2)
    PointCamAtEntity(currentCamera, currentVehicle, 0.0, 0.0, 0.0, true)
end

function GetNearestColorID(r, g, b)
    local minDistance = 1000000
    local nearestID = 0
    for id, color in pairs(VehicleColorRGB) do
        local dist = (r - color.r)^2 + (g - color.g)^2 + (b - color.b)^2
        if dist < minDistance then
            minDistance = dist
            nearestID = id
        end
    end
    return nearestID
end

-- Open Modification Menu Event
RegisterNetEvent('qbx_mechanicjob_custom:client:openBrochure', function()
    if IsModifying then return end
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if vehicle == 0 then
        exports.qbx_core:Notify('You must be inside a vehicle!', 'error')
        return
    end

    currentVehicle = vehicle
    -- Deep copy exactly here to prevent reference updates during preview
    local originalData = lib.getVehicleProperties(vehicle)
    OriginalMods = json.decode(json.encode(originalData))
    
    IsModifying = true
    
    CreateModCamera()
    local categories = GenerateCategoryData(vehicle)
    
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', categories = categories })
end)

function GenerateCategoryData(vehicle)
    SetVehicleModKit(vehicle, 0)
    local data = {
        performance = { isSub = true, label = 'Performance', subCategories = {} },
        cosmetic = { isSub = true, label = 'Cosmetic', subCategories = {} },
        paint = { isSub = true, label = 'Paint', subCategories = {} },
        wheels = { isSub = true, label = 'Wheels', subCategories = {} },
        extras = { isSub = false, label = 'Extras', items = {} }
    }

    -- 0. Extras Scan
    for i = 1, 20 do
        if DoesExtraExist(vehicle, i) then
            local isOn = IsVehicleExtraBroken(vehicle, i) == false
            table.insert(data.extras.items, { 
                label = 'Extra #' .. i .. (isOn and ' [ACTIVE]' or ' [INACTIVE]'), 
                extraId = i, 
                isOn = not isOn, -- We toggle it
                price = Config.ModPrices['extras'] or 150, 
                isExtra = true 
            })
        end
    end

    -- 1. Performance
    local perfGroups = {
        {label = 'Engine', id = 11, price = Config.ModPrices['engine']},
        {label = 'Brakes', id = 12, price = Config.ModPrices['brakes']},
        {label = 'Transmission', id = 13, price = Config.ModPrices['transmission']},
        {label = 'Suspension', id = 15, price = Config.ModPrices['suspension']},
    }
    for _, g in ipairs(perfGroups) do
        local sub = { label = g.label, items = {} }
        local count = GetNumVehicleMods(vehicle, g.id)
        for i = 0, count - 1 do
            table.insert(sub.items, { label = g.label .. ' - Lvl ' .. (i + 1), modId = g.id, level = i, price = g.price * (i + 1)})
        end
        if #sub.items > 0 then table.insert(data.performance.subCategories, sub) end
    end
    table.insert(data.performance.subCategories, { label = 'Turbo', items = {{ label = 'Turbo Tuning', modId = 18, level = 1, price = Config.ModPrices['turbo'], isToggle = true }} })

    -- 2. Cosmetic
    for slot, label in pairs(ModLabels) do
        local count = GetNumVehicleMods(vehicle, slot)
        if count > 0 then
            local sub = { label = label, items = {} }
            for i = -1, count - 1 do
                table.insert(sub.items, { label = label .. ' - Option ' .. (i + 1), modId = slot, level = i, price = Config.ModPrices['cosmetic'] })
            end
            table.insert(data.cosmetic.subCategories, sub)
        end
    end
    table.insert(data.cosmetic.subCategories, { label = 'Xenon Lights', items = {{ label = 'Enable Xenons', modId = 22, level = 1, price = Config.ModPrices['cosmetic'], isToggle = true }} })

    -- 3. Paint
    local paintTypes = {
        { label = 'Primary Color', type = 'primary' }, { label = 'Secondary Color', type = 'secondary' },
        { label = 'Pearlescent', type = 'pearl' }, { label = 'Wheel Color', type = 'wheel' },
        { label = 'Interior Color', type = 'interior' }
    }
    for _, pt in ipairs(paintTypes) do
        local ptSub = { isSub = true, label = pt.label, subCategories = {} }
        for _, pc in ipairs(PaintCategories) do
            local colorList = { label = pc.label, items = {} }
            for _, colorId in ipairs(pc.colors) do
                local colorName = ColorNames[colorId] or ('Color ' .. colorId)
                table.insert(colorList.items, { label = colorName, colorId = colorId, paintType = pt.type, price = Config.ModPrices['paint'], isColor = true })
            end
            table.insert(ptSub.subCategories, colorList)
        end
        table.insert(data.paint.subCategories, ptSub)
    end

    -- 4. Wheels
    local originalWheelType = GetVehicleWheelType(vehicle)
    for _, wt in ipairs(WheelTypes) do
        SetVehicleWheelType(vehicle, wt.id)
        local count = GetNumVehicleMods(vehicle, 23)
        if count > 0 then
            local sub = { label = wt.label, items = {} }
            for i = -1, count - 1 do -- Include -1 for stock rims in that category
                table.insert(sub.items, { label = wt.label .. ' - Rim #' .. (i + 1), modId = 23, level = i, wheelType = wt.id, price = Config.ModPrices['wheels'] })
            end
            table.insert(data.wheels.subCategories, sub)
        end
    end
    
    -- Restore original wheel type after generation
    SetVehicleWheelType(vehicle, originalWheelType)
    
    return data
end

function CleanupState()
    SetNuiFocus(false, false)
    
    if DoesEntityExist(currentVehicle) and OriginalMods and OriginalMods.plate then
        -- Force control of entity for critical updates
        
        -- Reset visual kit state
        SetVehicleModKit(currentVehicle, 0)
        
        -- Immediate restoration of primary visual flags
        if OriginalMods.color1 then
            SetVehicleColours(currentVehicle, OriginalMods.color1, OriginalMods.color2 or OriginalMods.color1)
            SetVehicleExtraColours(currentVehicle, OriginalMods.pearlescentColor or 0, OriginalMods.wheelColor or 0)
        end
        
        ToggleVehicleMod(currentVehicle, 18, OriginalMods.modTurbo or false)
        ToggleVehicleMod(currentVehicle, 22, OriginalMods.modXenon or false)
        
        -- Explicit manual reset for Spoiler (Mod 0) as it can be stubborn with state sync
        if OriginalMods.mods and OriginalMods.mods[0] ~= nil then
            SetVehicleMod(currentVehicle, 0, OriginalMods.mods[0], false)
        elseif OriginalMods.mods and OriginalMods.mods["0"] ~= nil then
            SetVehicleMod(currentVehicle, 0, tonumber(OriginalMods.mods["0"]), false)
        else
            SetVehicleMod(currentVehicle, 0, -1, false)
        end
        
        -- Final comprehensive set via lib
        Citizen.Wait(100)
        lib.setVehicleProperties(currentVehicle, OriginalMods)
    end
    
    IsModifying = false
    DestroyModCamera()
    currentVehicle = 0
    OriginalMods = {}
    SendNUIMessage({action = 'close'})
end

-- Callbacks
RegisterNUICallback('closeUI', function(data, cb) CleanupState(); cb('ok') end)
RegisterNUICallback('rotateCamera', function(data, cb)
    if not currentCamera then return cb('ok') end
    cameraAzimuth = cameraAzimuth - (data.x * 0.01)
    cameraElevation = math.max(-0.5, math.min(1.1, cameraElevation + (data.y * 0.01)))
    UpdateCameraPosition()
    cb('ok')
end)
RegisterNUICallback('zoomCamera', function(data, cb)
    if not currentCamera then return cb('ok') end
    cameraRadius = math.max(2.0, math.min(10.0, cameraRadius + (data.zoom * 0.5)))
    UpdateCameraPosition()
    cb('ok')
end)
RegisterNUICallback('previewMod', function(data, cb)
    if not IsModifying then return cb('ok') end
    if data.isColor then
        if data.isCustom then
            if data.paintType == 'primary' then
                SetVehicleCustomPrimaryColour(currentVehicle, data.r, data.g, data.b)
            elseif data.paintType == 'secondary' then
                SetVehicleCustomSecondaryColour(currentVehicle, data.r, data.g, data.b)
            elseif data.paintType == 'pearl' then
                local nearest = GetNearestColorID(data.r, data.g, data.b)
                local p, s = GetVehicleColours(currentVehicle)
                local _, wh = GetVehicleExtraColours(currentVehicle)
                SetVehicleExtraColours(currentVehicle, nearest, wh)
            elseif data.paintType == 'wheel' then
                local nearest = GetNearestColorID(data.r, data.g, data.b)
                local pr, _ = GetVehicleExtraColours(currentVehicle)
                SetVehicleExtraColours(currentVehicle, pr, nearest)
            elseif data.paintType == 'interior' then
                local nearest = GetNearestColorID(data.r, data.g, data.b)
                SetVehicleInteriorColour(currentVehicle, nearest)
            end
        else
            -- Standard GTA Color IDs
            local p, s = GetVehicleColours(currentVehicle)
            local pr, wh = GetVehicleExtraColours(currentVehicle)
            if data.paintType == 'primary' then 
                ClearVehicleCustomPrimaryColour(currentVehicle)
                SetVehicleColours(currentVehicle, data.colorId, s)
            elseif data.paintType == 'secondary' then 
                ClearVehicleCustomSecondaryColour(currentVehicle)
                SetVehicleColours(currentVehicle, p, data.colorId)
            elseif data.paintType == 'pearl' then SetVehicleExtraColours(currentVehicle, data.colorId, wh)
            elseif data.paintType == 'wheel' then SetVehicleExtraColours(currentVehicle, pr, data.colorId)
            elseif data.paintType == 'interior' then SetVehicleInteriorColour(currentVehicle, data.colorId) end
        end
    elseif data.isToggle then ToggleVehicleMod(currentVehicle, data.modId, true)
    elseif data.isExtra then SetVehicleExtra(currentVehicle, data.extraId, data.isOn and 0 or 1)
    elseif data.wheelType then SetVehicleWheelType(currentVehicle, data.wheelType); SetVehicleMod(currentVehicle, 23, data.level, false)
    else SetVehicleMod(currentVehicle, data.modId, data.level, false) end
    cb('ok')
end)
RegisterNUICallback('checkout', function(data, cb)
    if not IsModifying or currentVehicle == 0 then 
        return cb('ok') 
    end
    
    -- Capture the previewed modifications for the server to store
    local props = lib.getVehicleProperties(currentVehicle)
    print('DEBUG: [CLIENT] Sending checkout request to server...')
    
    -- Send to server via callback
    local success = lib.callback.await('qbx_mechanicjob_custom:server:completeCheckout', false, data.total, props, data.items)
    
    -- ALWAYS Cleanup/Reset visual state after checkout attempt (Success or Failure)
    -- This resets camera, focus, and restores the vehicle to OriginalMods
    CleanupState()

    if success then 
        exports.qbx_core:Notify('Checkout successful. Order placed!', 'success')
    else
        exports.qbx_core:Notify('Payment failed or inventory error!', 'error')
    end
    
    cb('ok')
end)

exports('mechanic_brochure', function()
    TriggerEvent('qbx_mechanicjob_custom:client:openBrochure')
end)
