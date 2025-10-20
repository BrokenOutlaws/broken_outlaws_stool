-- ========= Broken Outlaws: Multi-Stool/Chair =========

local VORP = exports.vorp_core and exports.vorp_core:vorpAPI() or nil

local VORPInv = nil
if exports.vorp_inventory and exports.vorp_inventory.vorp_inventoryApi then
    VORPInv = exports.vorp_inventory:vorp_inventoryApi()
else
    VORPInv = exports.vorp_inventory
end

local lastUse = {}
local sittingPlayers = {}
local registeredItems = {}

local function logInfo(msg)
    if DebugMode then print(("[BO_CHAIR][INFO] %s"):format(msg)) end
end
local function logError(msg)
    print(("[BO_CHAIR][ERROR] %s"):format(msg))
end

local function hasMethod(obj, name) return obj and type(obj[name]) == "function" end

local function RegisterUsableItem(itemName, cb)
    if not VORPInv then logError("vorp_inventory API not found") return false end
    if hasMethod(VORPInv, "RegisterUsableItem") then VORPInv:RegisterUsableItem(itemName, cb) return true end
    if hasMethod(VORPInv, "registerUsableItem") then VORPInv:registerUsableItem(itemName, cb) return true end
    if hasMethod(VORPInv, "RegisterUsable") then VORPInv:RegisterUsable(itemName, cb) return true end
    if hasMethod(VORPInv, "registerUsable") then VORPInv:registerUsable(itemName, cb) return true end
    if exports.vorp_inventory and hasMethod(exports.vorp_inventory, "registerUsableItem") then
        exports.vorp_inventory:registerUsableItem(itemName, cb) return true
    end
    logError("No RegisterUsableItem method found in vorp_inventory")
    return false
end

local function UnregisterUsableItem(itemName)
    if not VORPInv then return false end
    local ok = false
    if hasMethod(VORPInv, "UnregisterUsableItem") then pcall(function() VORPInv:UnregisterUsableItem(itemName) end) ok = true
    elseif hasMethod(VORPInv, "unregisterUsableItem") then pcall(function() VORPInv:unregisterUsableItem(itemName) end) ok = true
    elseif hasMethod(VORPInv, "RemoveUsableItem") then pcall(function() VORPInv:RemoveUsableItem(itemName) end) ok = true
    elseif hasMethod(VORPInv, "removeUsableItem") then pcall(function() VORPInv:removeUsableItem(itemName) end) ok = true
    end
    return ok
end

local function closeInventory(_source)
    TriggerClientEvent('vorp_inventory:CloseInv', _source)
    logInfo(("Closed inventory for %d"):format(_source))
end

local function canUse(_source)
    local now = os.time()
    local cd = math.floor(UseCooldown or 2.5)
    local last = lastUse[_source] or 0
    if (now - last) < cd then
        logInfo(("Cooldown block for %d (%ds left)"):format(_source, cd - (now - last)))
        TriggerClientEvent('bo_stool:notify', _source, 'Easy there—give it a moment.')
        return false
    end
    lastUse[_source] = now
    return true
end

RegisterNetEvent('bo_stool:setSitting', function(flag)
    local _source = source
    sittingPlayers[_source] = flag and true or false
end)

local function sitWithChair(_source, chair)
    if not chair then
        logError("sitWithChair: nil chair")
        TriggerClientEvent('bo_stool:notify', _source, 'Invalid chair selection.')
        return
    end
    TriggerClientEvent('bo_stool:use', _source, {
        PropModel = chair.PropModel,
        Scenario  = chair.Scenario,
        ZOffset   = chair.ZOffset,
        ROffset   = chair.ROffset or 0,
        FOffset   = chair.FOffset or 0.0,
    })
end

local function getSourceFromUsableArgs(a1, a2, a3, a4)
    if type(a1) == "table" and type(a1.source) == "number" then return a1.source end
    if type(a1) == "number" then return a1 end
    if type(a2) == "number" then return a2 end
    if type(source) == "number" then return source end
    return nil
end

local function makeUsableCallback(chair)
    return function(a1, a2, a3, a4)
        local ok, err = pcall(function()
            local _source = getSourceFromUsableArgs(a1, a2, a3, a4)
            if type(_source) ~= "number" then
                logError(("Usable callback for '%s': could not resolve source from args"):format(chair.item))
                return
            end
            if not canUse(_source) then return end
            if sittingPlayers[_source] then
                TriggerClientEvent('bo_stool:stand', _source)
                closeInventory(_source)
                return
            end
            sitWithChair(_source, chair)
            closeInventory(_source)
        end)
        if not ok then
            logError(("Usable callback crashed for item '%s': %s"):format(chair.item, tostring(err)))
        end
        return true
    end
end

local CHAIRS = {}
do
    if type(Item) ~= "table" or #Item == 0 then
        logError("Config error: Item list is empty or not a list. Please fill config.lua 'Item = { ... }'.")
    else
        for idx, c in ipairs(Item) do
            if not c.item or not c.label or not c.CommandSit or not c.PropModel or not c.Scenario then
                logError(("Config error in Item[%d]: missing required field (need item, label, CommandSit, PropModel, Scenario)."):format(idx))
            end
            CHAIRS[#CHAIRS+1] = {
                item       = c.item,
                label      = c.label,
                CommandSit = c.CommandSit,
                PropModel  = c.PropModel,
                Scenario   = c.Scenario,
                ZOffset    = c.ZOffset or 0.48,
                ROffset    = c.ROffset or 0,
                FOffset    = c.FOffset or 0.0,
            }
        end
    end
    logInfo(("Loaded %d chair definitions"):format(#CHAIRS))
end

for _, chair in ipairs(CHAIRS) do
    RegisterCommand(chair.CommandSit, function(source)
        if UseItemToSit then
            TriggerClientEvent('bo_stool:notify', source, ('Command disabled. Use your %s item.'):format(chair.label or 'chair'))
            return
        end
        if not canUse(source) then return end
        if sittingPlayers[source] then
            TriggerClientEvent('bo_stool:notify', source, 'You are already sitting. Use /'..CommandGetUp..' to stand.')
            return
        end
        sitWithChair(source, chair)
    end, false)
end

RegisterCommand(CommandGetUp, function(source)
    if UseItemToSit then
        TriggerClientEvent('bo_stool:notify', source, 'Command disabled. Use your chair item.')
        return
    end
    TriggerClientEvent('bo_stool:stand', source)
end, false)

local function registerAllItems()
    if not UseItemToSit then
        logInfo("Command mode active; not registering usable items.")
        return
    end
    for _, chair in ipairs(CHAIRS) do
        UnregisterUsableItem(chair.item)
        if RegisterUsableItem(chair.item, makeUsableCallback(chair)) then
            registeredItems[#registeredItems+1] = chair.item
            logInfo(("Registered usable item: %s"):format(chair.item))
        end
    end
end

local function unregisterAllItems()
    if #registeredItems == 0 then return end
    for _, itemName in ipairs(registeredItems) do
        UnregisterUsableItem(itemName)
    end
    registeredItems = {}
end

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    Citizen.CreateThread(function()
        Citizen.Wait(250)
        registerAllItems()
    end)
end)

Citizen.CreateThread(function()
    Citizen.Wait(250)
    registerAllItems()
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    unregisterAllItems()
end)

AddEventHandler('playerDropped', function()
    local _source = source
    sittingPlayers[_source] = nil
    lastUse[_source] = nil
end)