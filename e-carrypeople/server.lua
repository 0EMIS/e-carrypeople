RegisterNetEvent('e-carrypeople:requestCarry', function(targetSrc, carryData)
    local src = source
    TriggerClientEvent('e-carrypeople:confirmCarry', targetSrc, src, carryData)
end)

RegisterNetEvent('e-carrypeople:acceptCarry', function(requesterSrc, carryData)
    local src = source
    TriggerClientEvent('e-carrypeople:syncTarget', src, requesterSrc, carryData)
    TriggerClientEvent('e-carrypeople:startCarry', requesterSrc, src, carryData)
end)

RegisterNetEvent('e-carrypeople:stop', function(targetSrc)
    TriggerClientEvent('e-carrypeople:stopCarrying', targetSrc)
end)
