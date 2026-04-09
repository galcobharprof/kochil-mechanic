local qbx = exports.qbx_core
local blips = {}
local onDuty = false

-- Update duty status local
AddEventHandler('QBCore:Client:SetDuty', function(duty)
    onDuty = duty
    RefreshBlips()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local player = qbx:GetPlayerData()
    onDuty = player.job and player.job.onduty or false
    RefreshBlips()
end)

-- Handle resource restarts
Citizen.CreateThread(function()
    Wait(500)
    local player = qbx:GetPlayerData()
    if player and player.job then
        onDuty = player.job.onduty
        RefreshBlips()
    end
end)

-- Blip Logic
function RefreshBlips()
    for _, blip in pairs(blips) do
        RemoveBlip(blip)
    end
    blips = {}

    -- 1. Public Repair Blips (Always Visible if enabled)
    if Config.ShowRepairBlips then
        for _, loc in pairs(Config.RepairStations) do
            local blip = AddBlipForCoord(loc.coords)
            SetBlipSprite(blip, Config.RepairBlipSettings.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.RepairBlipSettings.scale)
            SetBlipColour(blip, Config.RepairBlipSettings.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(loc.label)
            EndTextCommandSetBlipName(blip)
            table.insert(blips, blip)
        end
    end

    -- 2. Shop Blips (Duty Dependent)
    if Config.BlipOnlyOnDuty and not onDuty then return end

    local player = qbx:GetPlayerData()
    if not player or not player.job or player.job.name ~= Config.JobName then return end

    for _, shop in pairs(Config.ShopBlips) do
        local blip = AddBlipForCoord(shop.coords)
        SetBlipSprite(blip, shop.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, shop.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(shop.label)
        EndTextCommandSetBlipName(blip)
        table.insert(blips, blip)
    end
end

-- Setup Interactions for Duty & Boss
Citizen.CreateThread(function()
    -- Duty Locations
    for i, loc in pairs(Config.DutyLocations) do
        exports.ox_target:addBoxZone({
            coords = loc.coords,
            size = loc.size,
            rotation = loc.heading,
            debug = false,
            options = {
                {
                    name = 'mechanic_duty_'..i,
                    icon = 'fa-solid fa-clipboard-user',
                    label = 'On/Off Duty',
                    groups = {[Config.JobName] = 0},
                    onSelect = function()
                        TriggerServerEvent('QBCore:ToggleDuty')
                    end
                }
            }
        })
    end

    -- Management Locations
    for i, loc in pairs(Config.ManagementLocations) do
        exports.ox_target:addBoxZone({
            coords = loc.coords,
            size = loc.size,
            rotation = loc.heading,
            debug = false,
            options = {
                {
                    name = 'mechanic_boss_'..i,
                    icon = 'fa-solid fa-user-tie',
                    label = 'Boss Management',
                    groups = {[Config.JobName] = Config.BossGrade},
                    onSelect = function()
                        exports['Ricky-BossMenu']:OpenBossMenu(Config.JobName)
                    end
                }
            }
        })
    end
end)

-- Self Repair Stations Logic (Press E)
Citizen.CreateThread(function()
    local showingUI = false
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == playerPed then
            local player = qbx:GetPlayerData()
            local isMechanic = player and player.job and player.job.name == Config.JobName
            
            if not isMechanic then
                local pos = GetEntityCoords(playerPed)
                local inRange = false

                for _, loc in pairs(Config.RepairStations) do
                    -- Using box zone logic for distance check
                    local dist = #(pos - loc.coords)
                    if dist < 5.0 then -- Base detection radius
                        inRange = true
                        sleep = 0
                        if not showingUI then
                            lib.showTextUI('[E] Self Repair Vehicle ($'..Config.SelfRepairPrice..')', {
                                position = "left-center",
                                icon = 'wrench'
                            })
                            showingUI = true
                        end

                        if IsControlJustReleased(0, 38) then -- E
                            local success = lib.callback.await('qbx_mechanicjob_custom:server:selfRepair', false)
                            if success then
                                if lib.progressBar({
                                    duration = 5000,
                                    label = 'Repairing Vehicle...',
                                    useWhileDead = false,
                                    canCancel = true,
                                    disable = { car = true },
                                    anim = { dict = 'mini@repair', clip = 'fixing_a_ped' },
                                }) then
                                    SetVehicleFixed(vehicle)
                                    SetVehicleEngineHealth(vehicle, 1000.0)
                                    SetVehicleBodyHealth(vehicle, 1000.0)
                                    SetVehicleFuelLevel(vehicle, GetVehicleFuelLevel(vehicle))
                                    exports.qbx_core:Notify('Vehicle repaired!', 'success')
                                end
                            end
                        end
                        break
                    end
                end

                if not inRange and showingUI then
                    lib.hideTextUI()
                    showingUI = false
                end
            end
        elseif showingUI then
            lib.hideTextUI()
            showingUI = false
        end
        Citizen.Wait(sleep)
    end
end)

-- Generic Mechanic Target Interactions
exports.ox_target:addGlobalVehicle({
    {
        name = 'mechanic_repair',
        icon = 'fa-solid fa-wrench',
        label = 'Repair Vehicle',
        distance = Config.TargetSettings.distance,
        groups = {[Config.JobName] = 0},
        canInteract = function(entity, distance, coords, name, bone)
            return onDuty
        end,
        onSelect = function(data)
            local vehicle = data.entity
            if lib.progressBar({
                duration = 5000,
                label = 'Repairing Vehicle...',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = true,
                },
                anim = {
                    dict = 'mini@repair',
                    clip = 'fixing_a_ped'
                },
            }) then
                SetVehicleFixed(vehicle)
                SetVehicleEngineHealth(vehicle, 1000.0)
                exports.qbx_core:Notify('Vehicle repaired!', 'success')
            end
        end
    },
    {
        name = 'mechanic_clean',
        icon = 'fa-solid fa-soap',
        label = 'Clean Vehicle',
        distance = Config.TargetSettings.distance,
        groups = {[Config.JobName] = 0},
        canInteract = function(entity, distance, coords, name, bone)
            return onDuty
        end,
        onSelect = function(data)
            local vehicle = data.entity
            if lib.progressBar({
                duration = 3000,
                label = 'Cleaning Vehicle...',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = true,
                },
                anim = {
                    dict = 'amb@world_human_maid_clean@',
                    clip = 'base'
                },
            }) then
                SetVehicleDirtLevel(vehicle, 0.0)
                exports.qbx_core:Notify('Vehicle cleaned!', 'success')
            end
        end
    },
    {
        name = 'mechanic_flip',
        icon = 'fa-solid fa-rotate',
        label = 'Flip Vehicle',
        distance = Config.TargetSettings.distance,
        groups = {[Config.JobName] = 0},
        canInteract = function(entity, distance, coords, name, bone)
            return onDuty and IsEntityUpsidedown(entity)
        end,
        onSelect = function(data)
            local vehicle = data.entity
            if lib.progressBar({
                duration = 2000,
                label = 'Flipping Vehicle...',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = true,
                },
            }) then
                SetVehicleOnGroundProperly(vehicle)
                exports.qbx_core:Notify('Vehicle flipped!', 'success')
            end
        end
    },
    {
        name = 'mechanic_impound',
        icon = 'fa-solid fa-building-shield',
        label = 'Impound Vehicle',
        distance = Config.TargetSettings.distance,
        groups = {[Config.JobName] = 0},
        canInteract = function(entity, distance, coords, name, bone)
            return onDuty
        end,
        onSelect = function(data)
            local vehicle = data.entity
            local plate = GetVehicleNumberPlateText(vehicle)
            if lib.progressBar({
                duration = 4000,
                label = 'Impounding Vehicle...',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = true,
                },
            }) then
                TriggerServerEvent('qbx_mechanicjob_custom:server:impoundVehicle', plate)
                DeleteEntity(vehicle)
                exports.qbx_core:Notify('Vehicle impounded!', 'success')
            end
        end
    }
})

-- View Modification Receipt Event
RegisterNetEvent('qbx_mechanicjob_custom:client:viewReceipt', function(text)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openReceipt',
        text = text
    })
end)
