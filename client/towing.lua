local qbx = exports.qbx_core
local CurrentTow = nil

-- Towing Logic for Flatbed
exports.ox_target:addGlobalVehicle({
    {
        name = 'mechanic_tow',
        icon = 'fa-solid fa-truck-pickup',
        label = 'Tow Vehicle',
        distance = Config.TargetSettings.distance,
        groups = {[Config.JobName] = 0},
        canInteract = function(entity, distance, coords, name, bone)
            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if vehicle == 0 then return false end
            local model = GetEntityModel(vehicle)
            return onDuty and Config.TowVehicles[model] and CurrentTow == nil
        end,
        onSelect = function(data)
            local targetVehicle = data.entity
            local playerPed = PlayerPedId()
            local towVehicle = GetVehiclePedIsIn(playerPed, false)

            if targetVehicle == towVehicle then
                exports.qbx_core:Notify('You cannot tow your own vehicle!', 'error')
                return
            end

            -- Attach Logic
            if lib.progressBar({
                duration = 3000,
                label = 'Attaching Vehicle...',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = true,
                },
            }) then
                AttachEntityToEntity(targetVehicle, towVehicle, GetEntityBoneIndexByName(towVehicle, 'bodyshell'), 0.0, -1.5, 0.4, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                CurrentTow = targetVehicle
                exports.qbx_core:Notify('Vehicle attached!', 'success')
            end
        end
    },
    {
        name = 'mechanic_untow',
        icon = 'fa-solid fa-truck-arrow-right',
        label = 'Untow Vehicle',
        distance = Config.TargetSettings.distance,
        groups = {[Config.JobName] = 0},
        canInteract = function(entity, distance, coords, name, bone)
            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if vehicle == 0 then return false end
            local model = GetEntityModel(vehicle)
            return onDuty and Config.TowVehicles[model] and CurrentTow ~= nil
        end,
        onSelect = function(data)
            local playerPed = PlayerPedId()
            local towVehicle = GetVehiclePedIsIn(playerPed, false)

            if lib.progressBar({
                duration = 3000,
                label = 'Detaching Vehicle...',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = true,
                },
            }) then
                DetachEntity(CurrentTow, true, true)
                local pos = GetOffsetFromEntityInWorldCoords(towVehicle, 0.0, -8.0, 0.0)
                SetEntityCoords(CurrentTow, pos.x, pos.y, pos.z, true, false, false, true)
                SetVehicleOnGroundProperly(CurrentTow)
                CurrentTow = nil
                exports.qbx_core:Notify('Vehicle detached!', 'success')
            end
        end
    }
})
