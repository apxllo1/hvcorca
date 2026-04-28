--[[
    Havoc Studios Runtime Engine
    FINAL EMERGENCY FIX: Global Handshake Logic
--]]

local Instance, game, task, require, setmetatable, pcall, error, warn
local instanceFromId, idFromInstance, modules, currentlyLoading = {}, {}, {}, {}

-- Module resolution
local function validateRequire(module, caller)
    currentlyLoading[caller] = module
    local currentModule, depth = module, 0
    if not modules[module] then
        while currentModule do
            depth = depth + 1
            currentModule = currentlyLoading[currentModule]
            if currentModule == module then error("Circular dependency detected", 2) end
        end
    end
    return function() if currentlyLoading[caller] == module then currentlyLoading[caller] = nil end end
end

local function loadModule(obj, this)
    local cleanup = this and validateRequire(obj, this)
    local module = modules[obj]
    if module.isLoaded then if cleanup then cleanup() end return module.value end
    local success, result = pcall(module.fn)
    if not success then error("\n[Havoc] Failed: " .. obj:GetFullName() .. "\nError: " .. tostring(result), 0) end
    module.value, module.isLoaded = result, true
    if cleanup then cleanup() end
    return result
end

local function requireModuleInternal(target, this)
    if modules[target] and target:IsA("ModuleScript") then return loadModule(target, this) end
    return require(target)
end

local function newEnv(id)
    local success, env = pcall(getfenv, 0)
    return setmetatable({
        VERSION = __VERSION__,
        script = instanceFromId[id],
        require = function(module) return requireModuleInternal(module, instanceFromId[id]) end,
    }, { __index = env or _G })
end

local function safeNew(className)
    local constructor = (Instance and Instance.new) or (_G.Instance and _G.Instance.new)
    if not constructor and game then
        local mt = getmetatable(game)
        if mt and mt.__index and mt.__index.new then constructor = mt.__index.new end
    end
    if not constructor and debug and debug.getregistry then
        for _, v in pairs(debug.getregistry()) do
            if type(v) == "table" and v.new and type(v.new) == "function" then constructor = v.new break end
        end
    end
    if not constructor then error("[Havoc Critical]: Instance.new not found.", 0) end
    return constructor(className)
end

local function newModule(name, className, path, parent, fn)
    local inst = safeNew(className)
    inst.Name = name
    if parent and instanceFromId[parent] then inst.Parent = instanceFromId[parent] end
    instanceFromId[path], idFromInstance[inst], modules[inst] = inst, path, { fn = fn, isLoaded = false }
end

local function newInstance(name, className, path, parent)
    local inst = safeNew(className)
    inst.Name = name
    if parent and instanceFromId[parent] then inst.Parent = instanceFromId[parent] end
    instanceFromId[path], idFromInstance[inst] = inst, path
end

local function init(env)
    local e = env or getfenv() or _G
    Instance, game, task, require, setmetatable, pcall, error, warn = e.Instance or _G.Instance, e.game or _G.game, e.task or _G.task, e.require or _G.require, e.setmetatable or _G.setmetatable, e.pcall or _G.pcall, e.error or _G.error, e.warn or _G.warn

    if not Instance and game then
        local mt = getmetatable(game)
        if mt and mt.__index then Instance = mt.__index end
    end

    if not game then return end
    
    pcall(function()
        if game.IsLoaded and not game:IsLoaded() then game.Loaded:Wait() end
    end)
    
    for object in pairs(modules) do
        if object:IsA("LocalScript") and not object.Disabled then
            task.spawn(function()
                local success, err = pcall(loadModule, object)
                if not success then warn("[Havoc Runtime Error]: " .. tostring(err)) end
            end)
        end
    end
end

-- CRITICAL: Force exposure to Global to stop the "nil" errors permanently
_G.Havoc_Init = init
_G.Havoc_NewModule = newModule
_G.Havoc_NewInstance = newInstance
_G.Havoc_NewEnv = newEnv

-- Return them anyway for the bundler to capture
return init, newModule, newInstance, newEnv
