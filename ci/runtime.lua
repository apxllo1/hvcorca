--[[
    ci/runtime.lua
    Havoc Runtime — injected verbatim into bundle output by bundle.lua.
    Returns: hInit, hMod, hInst, hEnv
--]]

local instanceFromId   = {}
local idFromInstance   = {}
local modules          = {}
local currentlyLoading = {}

-- ─── Environment Builder ──────────────────────────────────────────────────────
-- getfenv(1) gets the executor's full injected environment (Drawing, getrawmetatable, etc.)
-- Falls back to _G for executors that don't expose getfenv (some Byfron-era ones)

local function hEnv(id)
    local inst = instanceFromId[id]
    return setmetatable({
        script = inst,
        require = function(target)
            if typeof(target) == "Instance" then
                if modules[target] then
                    return _G.__HAVOC_LOAD(target, inst)
                end
                -- Loud error: instance exists in tree but has no module factory.
                -- Means it was registered as hInst (plain folder/instance) not hMod.
                -- Far easier to debug than a silent nil or infinite WaitForChild yield.
                error(
                    "[Havoc] require: '" .. tostring(target.Name) ..
                    "' (" .. tostring(target:GetFullName()) .. ") is not a registered module." ..
                    " Was the source file missing at bundle time?",
                    2
                )
            end
            -- Non-instance require (shouldn't happen in this bundle, but safe fallback)
            return require(target)
        end,
    }, { __index = getfenv and getfenv(1) or _G })
end

-- ─── Circular Dependency Check ────────────────────────────────────────────────
-- Tracks a proper visited set so cycle detection terminates correctly.

local function validateRequire(module, caller)
    currentlyLoading[caller] = module

    local visited = {}
    local current = module
    while current do
        if visited[current] then
            error("[Havoc] Circular dependency detected involving: " .. current.Name, 2)
        end
        visited[current] = true
        current = currentlyLoading[current]
    end
end

-- ─── Module Loader ────────────────────────────────────────────────────────────
-- isErrored flag: failed modules stay failed — no silent nil returns on re-require.

local function loadModule(obj, caller)
    local module = modules[obj]
    if not module then return nil end

    if module.isLoaded  then return module.value end
    if module.isErrored then
        error("[Havoc] Module previously failed to load: " .. obj.Name, 2)
    end

    if caller then validateRequire(obj, caller) end

    local success, result = pcall(module.fn)

    if caller then currentlyLoading[caller] = nil end

    if not success then
        module.isErrored = true
        error("[Havoc] Error in module '" .. obj.Name .. "': " .. tostring(result), 2)
    end

    -- Return empty table instead of nil so callers can always safely index the result
    module.value    = (result ~= nil) and result or {}
    module.isLoaded = true
    return module.value
end

_G.__HAVOC_LOAD = loadModule

-- ─── Instance Registration ────────────────────────────────────────────────────

local function hMod(name, class, id, parentId, fn)
    local inst  = Instance.new(class)
    inst.Name   = name
    inst.Parent = parentId and instanceFromId[parentId] or nil
    instanceFromId[id]   = inst
    idFromInstance[inst] = id
    modules[inst] = { fn = fn, isLoaded = false, isErrored = false }
end

local function hInst(name, class, id, parentId)
    local inst  = Instance.new(class)
    inst.Name   = name
    inst.Parent = parentId and instanceFromId[parentId] or nil
    instanceFromId[id]   = inst
    idFromInstance[inst] = id
end

-- ─── Bootstrap ────────────────────────────────────────────────────────────────
-- Waits for game to finish loading before spawning LocalScripts.
-- Prevents RuntimeLib's internal game.Loaded:Wait() from racing or hanging.
-- Works on: Synapse X, ScriptWare, KRNL, Fluxus, Xeno, Potassium, Electron,
--           Delta, Zorara, Codex, and any executor that respects task.spawn.

local function hInit()
    -- Some executors inject before game:IsLoaded() is true
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    for obj in pairs(modules) do
        -- Only auto-spawn LocalScripts; ModuleScripts load lazily on first require()
        if obj:IsA("LocalScript") and not obj.Disabled then
            task.spawn(loadModule, obj, "root")
        end
    end
end

return hInit, hMod, hInst, hEnv
