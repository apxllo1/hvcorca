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
local function hEnv(id)
    local inst = instanceFromId[id]
    return setmetatable({
        script = inst,
        require = function(target)
            if typeof(target) == "Instance" then
                if modules[target] then
                    return _G.__HAVOC_LOAD(target, inst)
                end
                -- LAYER 3 FIX: Loud error instead of silent hang
                error("[Havoc] require: '" .. tostring(target.Name) .. 
                      "' is not a registered module. Was it registered as hInst instead of hMod?", 2)
            end
            return require(target)
        end,
    }, { __index = getfenv and getfenv(1) or _G })
end

-- ─── Circular Dependency Check ────────────────────────────────────────────────
local function validateRequire(module, caller)
    currentlyLoading[caller] = module
    local visited = {}
    local current = module
    while current do
        if visited[current] then
            error("[Havoc] Circular dependency detected involving: " .. current.Name)
        end
        visited[current] = true
        current = currentlyLoading[current]
    end
end

-- ─── Module Loader ────────────────────────────────────────────────────────────
local function loadModule(obj, caller)
    local module = modules[obj]
    if not module then return nil end
    if module.isLoaded then return module.value end
    if module.isErrored then error("[Havoc] Module previously failed to load: " .. obj.Name) end

    if caller then validateRequire(obj, caller) end
    local success, result = pcall(module.fn)
    if caller then currentlyLoading[caller] = nil end

    if not success then
        module.isErrored = true
        error("[Havoc] Error loading module '" .. obj.Name .. "': " .. tostring(result), 2)
    end

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
end

-- ─── Bootstrap ────────────────────────────────────────────────────────────────
local function hInit()
    -- LAYER 2 FIX: Wait for game to load to prevent RuntimeLib hangs
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    for obj, _ in pairs(modules) do
        if obj:IsA("LocalScript") and not obj.Disabled then
            task.spawn(loadModule, obj, "root")
        end
    end
end

return hInit, hMod, hInst, hEnv
