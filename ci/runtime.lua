--[[
    ci/runtime.lua
    Havoc Runtime — injected verbatim into bundle output by bundle.lua.
    Returns: hInit, hMod, hInst, hEnv
--]]

local instanceFromId  = {}
local idFromInstance  = {}
local modules         = {}
local currentlyLoading = {}

-- ─── Environment Builder ──────────────────────────────────────────────────────
-- FIX 1: Use getfenv(1) not getfenv(0). In most executors getfenv(0) is the
-- C-level global which lacks injected executor globals. getfenv(1) or _G gets
-- the executor's full environment including Drawing, getrawmetatable, etc.

local function hEnv(id)
    local inst = instanceFromId[id]
    return setmetatable({
        script = inst,
        require = function(target)
            if typeof(target) == "Instance" and modules[target] then
                return _G.__HAVOC_LOAD(target, inst)
            end
            return require(target)
        end,
    }, { __index = getfenv and getfenv(1) or _G })
end

-- ─── Circular Dependency Check ────────────────────────────────────────────────
-- FIX 2: Track a proper visited set during the walk so the cycle detection
-- actually terminates and correctly identifies the looping module.

local function validateRequire(module, caller)
    currentlyLoading[caller] = module

    local visited = {}
    local current = module
    while current do
        if visited[current] then
            -- Found a cycle — build a readable chain for the error message
            error("[Havoc] Circular dependency detected involving: " .. current.Name)
        end
        visited[current] = true
        current = currentlyLoading[current]  -- follow the chain
    end
end

-- ─── Module Loader ────────────────────────────────────────────────────────────
-- FIX 3: On pcall failure, mark the module as errored so subsequent requires
-- get a clear error instead of silent nil.

local function loadModule(obj, caller)
    local module = modules[obj]
    if not module then return nil end

    if module.isLoaded then
        return module.value
    end

    if module.isErrored then
        error("[Havoc] Module previously failed to load: " .. obj.Name)
    end

    if caller then
        validateRequire(obj, caller)
    end

    local success, result = pcall(module.fn)

    if caller then
        currentlyLoading[caller] = nil
    end

    if not success then
        module.isErrored = true
        error("[Havoc] Error loading module '" .. obj.Name .. "': " .. tostring(result), 2)
    end

    -- A module that returns nothing exports an empty table (not nil),
    -- so callers can safely do `local x = require(mod); x.fn()` checks.
    module.value    = (result ~= nil) and result or {}
    module.isLoaded = true
    return module.value
end

_G.__HAVOC_LOAD = loadModule

-- ─── Instance Registration ────────────────────────────────────────────────────

local function hMod(name, class, id, parentId, fn)
    local inst   = Instance.new(class)
    inst.Name    = name
    inst.Parent  = parentId and instanceFromId[parentId] or nil
    instanceFromId[id]   = inst
    idFromInstance[inst] = id
    modules[inst] = { fn = fn, isLoaded = false, isErrored = false }
end

local function hInst(name, class, id, parentId)
    local inst   = Instance.new(class)
    inst.Name    = name
    inst.Parent  = parentId and instanceFromId[parentId] or nil
    instanceFromId[id]   = inst
    idFromInstance[inst] = id
    -- not a script, so no modules entry
end

-- ─── Bootstrap ────────────────────────────────────────────────────────────────
-- Spawns all LocalScripts. ModuleScripts are loaded lazily on first require().

local function hInit()
    for obj, _ in pairs(modules) do
        if obj:IsA("LocalScript") then
            task.spawn(loadModule, obj, "root")
        end
    end
end

return hInit, hMod, hInst, hEnv
