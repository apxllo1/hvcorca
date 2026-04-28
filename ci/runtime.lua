--[[
    Havoc Studios Runtime Engine
    MAX-STABILITY SYNC LOGIC
]]

local Instance, game, task, require, setmetatable, pcall, error, warn
local instanceFromId, idFromInstance, modules, currentlyLoading = {}, {}, {}, {}

-- 1. Optimized Module Resolution
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
    local module = modules[obj]
    if not module then 
        -- If the module isn't in Havoc's internal list, try standard require
        return require(obj)
    end
    
    local cleanup = this and validateRequire(obj, this)
    if module.isLoaded then if cleanup then cleanup() end return module.value end
    
    local success, result = pcall(module.fn)
    if not success then error("\n[Havoc] Failed: " .. obj:GetFullName() .. "\nError: " .. tostring(result), 0) end
    
    module.value, module.isLoaded = result, true
    if cleanup then cleanup() end
    return result
end

-- 2. Improved Environment Factory
local function newEnv(id)
    return setmetatable({
        VERSION = __VERSION__,
        script = instanceFromId[id],
        require = function(module) 
            return loadModule(module, instanceFromId[id]) 
        end,
    }, { __index = _G })
end

-- 3. Robust Instance Constructor
local function safeNew(className)
    local constructor = (Instance and Instance.new) or (_G.Instance and _G.Instance.new)
    if not constructor then
        -- Last ditch effort to find the constructor
        pcall(function() constructor = game.Instance.new end)
    end
    if not constructor then error("[Havoc Critical]: Instance.new not found.", 0) end
    return constructor(className)
end

local function newModule(name, className, path, parent, fn)
    local inst = safeNew(className)
    inst.Name = name
    if parent and instanceFromId[parent] then inst.Parent = instanceFromId[parent] end
    instanceFromId[path] = inst
    idFromInstance[inst] = path
    modules[inst] = { fn = fn, isLoaded = false }
end

local function newInstance(name, className, path, parent)
    local inst = safeNew(className)
    inst.Name = name
    if parent and instanceFromId[parent] then inst.Parent = instanceFromId[parent] end
    instanceFromId[path] = inst
    idFromInstance[inst] = path
end

-- 4. Secure Initialization
local function init(env)
    local e = env or getfenv() or _G
    
    -- Force sync with the environment
    Instance = e.Instance or _G.Instance
    game = e.game or _G.game
    task = e.task or _G.task
    require = e.require or _G.require
    setmetatable = e.setmetatable or _G.setmetatable
    pcall = e.pcall or _G.pcall
    error = e.error or _G.error
    warn = e.warn or _G.warn

    if not game then return end
    
    pcall(function()
        if not game:IsLoaded() then game.Loaded:Wait() end
    end)
    
    -- Launch LocalScripts AFTER they are all registered
    for object, data in pairs(modules) do
        if object:IsA("LocalScript") and not object.Disabled then
            task.spawn(function()
                local success, err = pcall(loadModule, object)
                if not success then warn("[Havoc Runtime Error]: " .. tostring(err)) end
            end)
        end
    end
end

-- Force exposure
_G.Havoc_Init = init
_G.Havoc_NewModule = newModule
_G.Havoc_NewInstance = newInstance
_G.Havoc_NewEnv = newEnv

return init, newModule, newInstance, newEnv
