ENDOFFILE'
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
-- Lua 5.1 functions absent on modern Luau executors (Xeno, Potassium, Delta,
-- Codex, Zorara, Electron, etc.). Polyfilled via debug.setupvalue.

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
            return fn
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
        _setfenv = function(fn, _) return fn end
        _getfenv = function(_) return _G end
    end
end

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
                error(
                    "[Havoc] require: '" .. tostring(target.Name) ..
                    "' (" .. tostring(target:GetFullName()) .. ") is not a registered module." ..
                    " Was the source file missing at bundle time?",
                    2
                )
            end
            return require(target)
        end,
    }, { __index = _getfenv and _getfenv(0) or _G })
end

-- ─── Circular Dependency Check ────────────────────────────────────────────────

local function validateRequire(module, caller)
    currentlyLoading[caller] = module

    local currentModule = module
    local depth = 0

    if not modules[module] then
        while currentModule do
            depth = depth + 1
            currentModule = currentlyLoading[currentModule]

            if currentModule == module then
                local str = currentModule.Name
                for _ = 1, depth do
                    currentModule = currentlyLoading[currentModule]
                    str = str .. " ⇒ " .. currentModule.Name
                end
                error("[Havoc] Circular dependency: " .. str, 2)
            end
        end
    end

    return function()
        if currentlyLoading[caller] == module then
            currentlyLoading[caller] = nil
        end
    end
end

-- ─── Module Loader ────────────────────────────────────────────────────────────

local function loadModule(obj, caller)
    local cleanup = caller and validateRequire(obj, caller)
    local module  = modules[obj]

    if not module then
        if cleanup then cleanup() end
        return nil
    end

    if module.isLoaded then
        if cleanup then cleanup() end
        return module.value
    end

    local data      = module.fn()
    module.value    = data
    module.isLoaded = true
    if cleanup then cleanup() end
    return data
end

_G.__HAVOC_LOAD = loadModule

-- ─── Instance Registration ────────────────────────────────────────────────────

local function hMod(name, class, id, parentId, fn)
    local inst  = Instance.new(class)
    inst.Name   = name
    inst.Parent = parentId and instanceFromId[parentId] or nil
    instanceFromId[id]   = inst
    idFromInstance[inst] = id
    modules[inst] = { fn = fn, isLoaded = false }
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
