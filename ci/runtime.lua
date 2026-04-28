--[[
    Havoc Studios Runtime Engine
    FINAL EMERGENCY FIX: Local-to-Global Sync Logic
]]

local Instance, game, task, require, setmetatable, pcall, error, warn
local instanceFromId, idFromInstance, modules, currentlyLoading = {}, {}, {}, {}

-- Module resolution logic
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
    return function() 
        if currentlyLoading[caller] == module then currentlyLoading[caller] = nil end 
    end
end

local function loadModule(obj, this)
    local cleanup = this and validateRequire(obj, this)
    local module = modules[obj]
    if not module then error("Module not found in Havoc registry: " .. tostring(obj), 2) end
    
    if module.isLoaded then 
        if cleanup then cleanup() end 
        return module.value 
    end
    
    local success, result = pcall(module.fn)
    if not success then 
        error("\n[Havoc] Execution Failed: " .. obj:GetFullName() .. "\nError: " .. tostring(result), 0) 
    end
    
    module.value, module.isLoaded = result, true
    if cleanup then cleanup() end
    return result
end

local function requireModuleInternal(target, this)
    if modules[target] and target:IsA("ModuleScript") then 
        return loadModule(target, this) 
    end
    return require(target)
end

-- Environment Factory
local function newEnv(id)
    local success, env = pcall(getfenv, 0)
    local scriptObj = instanceFromId[id]
    
    return setmetatable({
        VERSION = __VERSION__,
        script = scriptObj,
        require = function(module) 
            return requireModuleInternal(module, scriptObj) 
        end,
    }, { 
        __index = env or _G 
    })
end

-- Robust Instance Constructor
local function safeNew(className)
    local constructor = (Instance and Instance.new) or (_G.Instance and _G.Instance.new)
    
    if not constructor then
        -- Fallback to game metatable for high-end executors
        local success, result = pcall(function() return game.Instance.new end)
        if success then constructor = result end
    end
    
    if not constructor then 
        error("[Havoc Critical]: Instance.new not found in this environment.", 0) 
    end
    return constructor(className)
end

local function newModule(name, className, path, parent, fn)
    local inst = safeNew(className)
    inst.Name = name
    if parent and instanceFromId[parent] then 
        inst.Parent = instanceFromId[parent] 
    end
    instanceFromId[path] = inst
    idFromInstance[inst] = path
    modules[inst] = { fn = fn, isLoaded = false }
end

local function newInstance(name, className, path, parent)
    local inst = safeNew(className)
    inst.Name = name
    if parent and instanceFromId[parent] then 
        inst.Parent = instanceFromId[parent] 
    end
    instanceFromId[path] = inst
    idFromInstance[inst] = path
end

local function init(env)
    local e = env or getfenv() or _G
    
    -- Sync standard libraries
    Instance = e.Instance or _G.Instance
    game = e.game or _G.game
    task = e.task or _G.task
    require = e.require or _G.require
    setmetatable = e.setmetatable or _G.setmetatable
    pcall = e.pcall or _G.pcall
    error = e.error or _G.error
    warn = e.warn or _G.warn

    if not game then return end
    
    -- Wait for game to load if necessary
    pcall(function()
        if not game:IsLoaded() then game.Loaded:Wait() end
    end)
    
    -- Auto-run LocalScripts
    for object in pairs(modules) do
        if object:IsA("LocalScript") and not object.Disabled then
            task.spawn(function()
                local success, err = pcall(loadModule, object)
                if not success then 
                    warn("[Havoc Runtime Error]: " .. tostring(err)) 
                end
            end)
        end
    end
end

-- Expose to Global table for handshake
_G.Havoc_Init = init
_G.Havoc_NewModule = newModule
_G.Havoc_NewInstance = newInstance
_G.Havoc_NewEnv = newEnv

-- IMPORTANT: This return must match the hInit, hMod, hInst, hEnv capture in bundle.lua
return init, newModule, newInstance, newEnv
