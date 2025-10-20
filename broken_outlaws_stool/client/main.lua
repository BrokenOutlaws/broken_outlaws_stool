-- ========= Broken Outlaws: Multi-Stool/Chair =========

local currentProp = nil
local sitting = false
local lastUseTick = 0

local CHAIR_HASHES = {}

Citizen.CreateThread(function()
    if type(Item) == "table" then
        for _, c in ipairs(Item) do
            if c.PropModel then
                CHAIR_HASHES[#CHAIR_HASHES + 1] = GetHashKey(c.PropModel)
            end
        end
    end
end)

local function LOG(msg)
    print(("[BO_CHAIR][CLIENT] %s"):format(msg))
end
local function DBG(msg)
    if DebugMode then LOG(msg) end
end

local function sweepAndDeleteNearbyChairs()
    local ped = PlayerPedId()
    local px, py, pz = table.unpack(GetEntityCoords(ped))
    local radius = 3.0

    for _, hash in ipairs(CHAIR_HASHES) do
        local tries = 0
        while tries < 10 do
            local obj = GetClosestObjectOfType(px, py, pz, radius, hash, false, false, false)
            if obj ~= 0 and DoesEntityExist(obj) then
                local attachedTo = GetEntityAttachedTo(obj)
                local attached = (attachedTo == ped) or IsEntityAttachedToEntity(obj, ped)
                local ox, oy, oz = table.unpack(GetEntityCoords(obj))
                local dx, dy, dz = px - ox, py - oy, pz - oz
                local dist = math.sqrt(dx*dx + dy*dy + dz*dz)

                if attached or dist <= radius then
                    DetachEntity(obj, true, true)
                    SetEntityAsMissionEntity(obj, true, true)
                    DeleteObject(obj)
                    if DoesEntityExist(obj) then DeleteEntity(obj) end
                    DBG(("Sweep: deleted stray chair model %d (dist=%.2f, attached=%s)"):format(hash, dist, tostring(attached)))
                    Citizen.Wait(10)
                else
                    break
                end
            else
                break
            end
            tries = tries + 1
            Citizen.Wait(0)
        end
    end
end

local function canUse()
    local ped = PlayerPedId()
    if IsPedDeadOrDying(ped, true) then DBG("Blocked: dead/dying") return false end
    if IsPedOnMount(ped) then DBG("Blocked: on mount") return false end
    if IsPedInAnyVehicle(ped, true) then DBG("Blocked: in vehicle") return false end
    if IsPedSwimming(ped) then DBG("Blocked: swimming") return false end
    if sitting then DBG("Blocked: already sitting") return false end
    return true
end

local function startSitWith(chair)
    DBG("startSitWith()")
    if not canUse() then
        LOG("You can’t sit right now.")
        return
    end

    local propModel = (chair and chair.PropModel) or 'p_stoolfolding01x'
    local scenario  = (chair and chair.Scenario)  or 'PROP_HUMAN_SEAT_CHAIR_SMOKE_ROLL'
    local zOff      = (chair and chair.ZOffset)   or 0.48
    local rOff      = (chair and chair.ROffset)   or 0
    local fOff      = (chair and chair.FOffset)   or 0.0

    local ped = PlayerPedId()
    local x, y, z = table.unpack(GetEntityCoords(ped))
    local pedHeading = GetEntityHeading(ped) % 360.0

    DBG(("Use prop=%s, scen=%s, Z=%.2f, R=%.2f, F=%.2f -> pedHeading=%.2f"):format(
        propModel, scenario, zOff, rOff, fOff, pedHeading
    ))

    local modelHash = GetHashKey(propModel)
    RequestModel(modelHash)
    local tries = 0
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(25)
        tries = tries + 1
        if tries > 200 then
            LOG("ERROR: chair model load timeout")
            return
        end
    end

    local _, gz = GetGroundZFor_3dCoord(x, y, z, true)
    local adjustedZ = (gz > 0.0 and gz or z) + zOff

    TaskStartScenarioAtPosition(ped, GetHashKey(scenario), x, y, adjustedZ, pedHeading, -1, true, true)
    DBG("Scenario started")

    Citizen.Wait(2500)

    currentProp = CreateObject(modelHash, x, y, adjustedZ, true, true, true)
    SetEntityAsMissionEntity(currentProp, true, true)
    SetEntityCollision(currentProp, false, true)
    SetEntityVisible(currentProp, true, false)

    local boneIndex = GetPedBoneIndex(ped, 11816)
    AttachEntityToEntity(
        currentProp, ped, boneIndex,
        0.0,
        fOff,
        -0.50,
        0.0, 0.0,
        rOff + 0.0,
        true, true, false, true, 1, true
    )
    DBG("Prop created & attached (chair rotated/moved; ped unchanged)")

    sitting = true
    TriggerServerEvent('bo_stool:setSitting', true)
end

local function reallyDeleteProp()
    if currentProp and DoesEntityExist(currentProp) then
        DetachEntity(currentProp, true, true)
        SetEntityAsMissionEntity(currentProp, true, true)
        DeleteObject(currentProp)
        if DoesEntityExist(currentProp) then DeleteEntity(currentProp) end
        DBG("Deleted currentProp")
    end
    currentProp = nil
end

local function forceStand()
    local ped = PlayerPedId()
    ClearPedTasksImmediately(ped)
    Citizen.InvokeNative(0xE1EF3C1216AFF2CD, ped, 0, 0)
    Citizen.Wait(50)
    reallyDeleteProp()
    sweepAndDeleteNearbyChairs()
    sitting = false
end

local function stopSit()
    DBG("stopSit()")
    forceStand()
    TriggerServerEvent('bo_stool:setSitting', false)
end

RegisterNetEvent('bo_stool:use')
AddEventHandler('bo_stool:use', function(chairData)
    local now = GetGameTimer()
    local cd  = (UseCooldown or 2.5) * 1000
    if now - lastUseTick < cd then
        DBG("Cooldown active")
        return
    end
    lastUseTick = now
    startSitWith(chairData)
end)

RegisterNetEvent('bo_stool:stand')
AddEventHandler('bo_stool:stand', function()
    if sitting then
        stopSit()
    else
        DBG("stand ignored: not sitting")
    end
end)

RegisterNetEvent('bo_stool:notify')
AddEventHandler('bo_stool:notify', function(msg)
    LOG(tostring(msg))
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    DBG("onResourceStop -> forceStand + sweep")
    forceStand()
end)

AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    Citizen.CreateThread(function()
        Citizen.Wait(300)
        local ped = PlayerPedId()
        if IsPedActiveInScenario(ped) then
            DBG("Startup recovery: clearing active scenario")
            ClearPedTasksImmediately(ped)
            Citizen.InvokeNative(0xE1EF3C1216AFF2CD, ped, 0, 0)
        end
        reallyDeleteProp()
        sweepAndDeleteNearbyChairs()
        sitting = false
    end)
end)