local qbx = exports.qbx_core

-- Event triggered when a mechanic uses the "Mechanic Notes" item
RegisterNetEvent('qbx_mechanicjob_custom:client:startInstallation', function(slot, props)
    -- Check Job (Mechanic only)
    local playerData = exports.qbx_core:GetPlayerData()
    if playerData.job.name ~= Config.JobName then
        return exports.qbx_core:Notify('Only a mechanic can interpret these technical notes!', 'error')
    end
    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    local vehicle = lib.getClosestVehicle(coords, 3.0, false)

    if not vehicle then
        return exports.qbx_core:Notify('No vehicle nearby matching this work order!', 'error')
    end

    -- Security & Accuracy Check: Plate Matching
    local vehiclePlate = GetVehicleNumberPlateText(vehicle):gsub('%s+', '')
    local orderPlate = (props.plate or ""):gsub('%s+', '')

    if vehiclePlate ~= orderPlate then
        return exports.qbx_core:Notify('This work order is for vessel with plate ' .. orderPlate .. '. This vehicle is ' .. vehiclePlate .. '!', 'error')
    end

    -- Orientation: Face the vehicle
    TaskTurnPedToFaceEntity(ped, vehicle, 1000)
    Citizen.Wait(1000)

    -- Installation Progress (20 Seconds)
    if lib.progressBar({
        duration = 20000,
        label = 'Installing high-performance components...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false
        },
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped'
        },
    }) then
        -- Apply the actual modifications stored in the notes
        lib.setVehicleProperties(vehicle, props)
        
        -- Tell server to consume the item and issue a receipt
        TriggerServerEvent('qbx_mechanicjob_custom:server:finishInstallation', slot, props)
        
        exports.qbx_core:Notify('Modifications installed successfully!', 'success')
    else
        exports.qbx_core:Notify('Installation cancelled.', 'error')
    end
end)
