--[[
    ci/runtime.lua
    Havoc Runtime — injected verbatim into bundle output by bundle.lua.
    Returns: hInit, hMod, hInst, hEnv
--]]

local instanceFromId   = {}
local idFromInstance   = {}
local modules          = {}
local currentlyLoading = {}

-- ─── setfenv / getfenv Polyfill ───────────────────────────────────────────────
-- Modern Luau executors (Byfron/Hyperion: Xeno, Potassium, Delta, Codex, Zorara,
-- Electron, and others) do not expose setfenv/getfenv — they are Lua 5.1 only.
-- We polyfill via debug.setupvalue which IS available on all executors that
-- support loadstring. If even debug is missing, a no-op shim prevents the crash
-- (environment isolation is lost but execution continues).

local _setfenv = setfenv
local _getfenv = getfenv

if not _setfenv then
    if debug and debug.getupvalue and debug.setupvalue then
        _setfenv = function(fn, env)
            local i = 1
            while true do
                local name = debug.getupvalue(fn, i)
                if name == "_ENV" then
                    debug.setupvalue(fn, i, env)
                    return fn
                elseif name == nil then
                    break
                end
                i = i + 1
            end
            return fn  -- _ENV upvalue not found — compiled without it, best effort
        end
        _getfenv = function(fn)
            if type(fn) == "number" then
                fn = debug.getinfo(fn + 1, "f").func
            end
            local i = 1
            while true do
                local name, val = debug.getupvalue(fn, i)
                if name == "_ENV" then return val end
                if name == nil then break end
                i = i + 1
            end
            return _G
        end
    else
        -- Total fallback — no isolation but no crash
        _setfenv = function(fn, _) return fn end
        _getfenv = function(_) return _G end
    end
end

-- ─── Environment Builder ──────────────────────────────────────────────────────
-- Builds a per-module environment that shadows `script` and `require`
-- while inheriting all executor globals (Drawing, getrawmetatable, syn, etc.)

local function hEnv(id)
    local inst = instanceFromId[id]
    return setmetatable({
        script = inst,
        require = function(target)
            if typeof(target) == "Instance" then
                if modules[target] then
                    return _G.__HAVOC_LOAD(target, inst)
                end
                error(
                    "[Havoc] require: '" .. tostring(target.Name) ..
                    "' (" .. tostring(target:GetFullName()) .. ") is not a registered module." ..
                    " Was the source file missing at bundle time?",
                    2
                )
            end
            return require(target)
        end,
    }, { __index = _getfenv and _getfenv(1) or _G })
end

-- ─── Circular Dependency Check ────────────────────────────────────────────────

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

local function hInit()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    for obj in pairs(modules) do
        if obj:IsA("LocalScript") and not obj.Disabled then
            task.spawn(loadModule, obj, "root")
        end
    end
end

return hInit, hMod, hInst, hEnv
