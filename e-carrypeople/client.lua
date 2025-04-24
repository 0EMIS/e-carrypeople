local localePath = ('locales/%s.lua'):format(Config.Locale)
local localeFile = LoadResourceFile(GetCurrentResourceName(), localePath)
assert(localeFile, 'Locale file not found: ' .. localePath)
assert(load(localeFile))()

local function Translate(key)
    return Locales[Config.Locale][key] or key
end

local carry = {
	InProgress = false,
	targetSrc = -1,
	type = "",
	personCarrying = {},
	personCarried = {}
}

local function ensureAnimDict(animDict)
    if animDict ~= "" and not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end
    end
end

local function GetClosestPlayer(radius)
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _,playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords - playerCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = playerId
                closestDistance = distance
            end
        end
    end
    if closestDistance ~= -1 and closestDistance <= radius then
        return closestPlayer
    else
        return nil
    end
end

RegisterCommand(Config.CarryCommand, function()
    if carry.InProgress then
        carry.InProgress = false
        ClearPedSecondaryTask(PlayerPedId())
        DetachEntity(PlayerPedId(), true, false)
        TriggerServerEvent("e-carrypeople:stop", carry.targetSrc)
        carry.targetSrc = 0
        return
    end

    local closestPlayer = GetClosestPlayer(3.0)
    if not closestPlayer then
        lib.notify({title = Translate('error_title'), description = Translate('no_nearby_players'), type = 'error'})
        return
    end

    local targetSrc = GetPlayerServerId(closestPlayer)

    lib.registerContext({
        id = 'carry_select_menu',
        title = Translate('carry_request_header'),
        options = {
            {
                title = Translate('carry_style_1'),
                description = Translate('carry_style_1_desc'),
                onSelect = function()
                    TriggerServerEvent('e-carrypeople:requestCarry', targetSrc, {
                        animDict1 = "missfinale_c2mcs_1",
                        anim1 = "fin_c2_mcs_1_camman",
                        animDict2 = "nm",
                        anim2 = "firemans_carry",
                        attachX = 0.25,
                        attachY = 0.18,
                        attachZ = 0.63,
                        rot = 0.0,
                        flag1 = 49,
                        flag2 = 33,
                        animFlagTarget = 1,
                        duration = 10000000
                    })
                end
            },
            {
                title = Translate('carry_style_2'),
                description = Translate('carry_style_2_desc'),
                onSelect = function()
                    TriggerServerEvent('e-carrypeople:requestCarry', targetSrc, {
                        animDict1 = "anim@heists@box_carry@",
                        anim1 = "idle",
                        animDict2 = "timetable@ron@ig_5_p3",
                        anim2 = "ig_5_p3_base",
                        attachX = 0,
                        attachY = -0.30,
                        attachZ = 0.45,
                        rot = 195.0,
                        flag1 = 49,
                        flag2 = 33,
                        animFlagTarget = 1,
                        duration = 10000000
                    })
                end
            },
            {
                title = Translate('carry_style_3'),
                description = Translate('carry_style_3_desc'),
                onSelect = function()
                    TriggerServerEvent('e-carrypeople:requestCarry', targetSrc, {
                        animDict1 = "anim@heists@box_carry@",
                        anim1 = "idle",
                        animDict2 = "rcm_barry3",
                        anim2 = "barry_3_sit_loop",
                        attachX = 0,
                        attachY = 0.45,
                        attachZ = 0.90,
                        rot = 90.0,
                        flag1 = 49,
                        flag2 = 33,
                        animFlagTarget = 1,
                        duration = 10000000
                    })
                end
            },
            {
                title = Translate('carry_style_4'),
                description = Translate('carry_style_4_desc'),
                onSelect = function()
                    TriggerServerEvent('e-carrypeople:requestCarry', targetSrc, {
                        animDict1 = "",
                        anim1 = "",
                        animDict2 = "timetable@ron@ig_5_p3",
                        anim2 = "ig_5_p3_base",
                        attachX = 0,
                        attachY = 0.45,
                        attachZ = 1.1,
                        rot = 5.0,
                        flag1 = 49,
                        flag2 = 33,
                        animFlagTarget = 1,
                        duration = 10000000
                    })
                end
            }
        }
    })
    

    lib.showContext('carry_select_menu')
end)

RegisterNetEvent('e-carrypeople:confirmCarry', function(requesterSrc, carryData)
    local result = lib.alertDialog({
        header = Translate('carry_request_header'),
        content = Translate('carry_request_content'),
        centered = true,
        cancel = true
    })

    if result == 'confirm' then
        TriggerServerEvent('e-carrypeople:acceptCarry', requesterSrc, carryData)
    end
end)

RegisterNetEvent("e-carrypeople:startCarry", function(targetSrc, carryData)
    carry.InProgress = true
    carry.targetSrc = targetSrc
    carry.type = "carrying"
    carry.personCarrying = carryData

    ensureAnimDict(carryData.animDict1)
    TaskPlayAnim(PlayerPedId(), carryData.animDict1, carryData.anim1, 8.0, -8.0, -1, carryData.flag1, 0, false, false, false)
end)

RegisterNetEvent("e-carrypeople:syncTarget", function(requesterSrc, carryData)
    carry.InProgress = true
    carry.targetSrc = requesterSrc
    carry.type = "beingcarried"
    carry.personCarried = carryData

    ensureAnimDict(carryData.animDict2)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(requesterSrc))
    AttachEntityToEntity(PlayerPedId(), targetPed, 0, carryData.attachX, carryData.attachY, carryData.attachZ, 0.5, 0.5, carryData.rot, false, false, false, false, 2, false)
    TaskPlayAnim(PlayerPedId(), carryData.animDict2, carryData.anim2, 8.0, -8.0, -1, carryData.flag2, 0, false, false, false)
end)

RegisterNetEvent("e-carrypeople:stopCarrying", function()
    carry.InProgress = false
    ClearPedSecondaryTask(PlayerPedId())
    DetachEntity(PlayerPedId(), true, false)
end)

CreateThread(function()
    if Config.EnableTarget then
        exports.ox_target:addGlobalPlayer({
            {
                label = Translate('carry_target_label'),
                icon = Config.CarryTargetIcon,
                distance = 2.0,
                onSelect = function(data)
                    ExecuteCommand(Config.CarryCommand)
                end
            }
        })
    end
end)
