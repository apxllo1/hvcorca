--[[
    Havoc Studios Runtime Engine
    Handles Instance creation, Module resolution, and Environment Sandboxing.
--]]

local Instance, game, task, require, setmetatable, pcall, error, warn

local instanceFromId = {}
local idFromInstance = {}
local modules = {}
local currentlyLoading = {}

-- Module resolution logic to handle circular dependencies
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
                    str = str .. "  ⇒ " .. currentModule.Name
                end
                error("Circular dependency detected: " .. str, 2)
            end
        end
    end
    return function ()
        if currentlyLoading[caller] == module then
            currentlyLoading[caller] = nil
        end
    end
end

local function loadModule(obj, this)
    local cleanup = this and validateRequire(obj, this)
    local module = modules[obj]
    
    if module.isLoaded then
        if cleanup then cleanup() end
        return module.value
    else
        local success, result = pcall(module.fn)
        if not success then
            error("\n[Havoc] Failed to load module: " .. obj:GetFullName() .. "\n[!] Error: " .. tostring(result), 0)
        end
        module.value = result
        module.isLoaded = true
        if cleanup then cleanup() end
        return result
    end
end

local function requireModuleInternal(target, this)
    if modules[target] and target:IsA("ModuleScript") then
        return loadModule(target, this)
    else
        return require(target)
    end
end

-- Generates a sandboxed environment for each script/module
local function newEnv(id)
    local success, env = pcall(getfenv, 0)
    if not success then env = _G end
    
    return setmetatable({
        VERSION = __VERSION__,
        script = instanceFromId[id],
        require = function (module)
            return requireModuleInternal(module, instanceFromId[id])
        end,
    }, {
        __index = env,
        __metatable = "This metatable is locked",
    })
end

-- safeNew: Ensures Instance.new works even on restricted executors
local function safeNew(className)
    local constructor = (Instance and Instance.new) or (_G.Instance and _G.Instance.new)
    
    -- Fallback: Metatable reflection
    if not constructor and game then
        local mt = getmetatable(game)
        if mt and mt.__index and mt.__index.new then
            constructor = mt.__index.new
        end
    end

    -- Ultimate Fallback: Registry Search
    if not constructor and debug and debug.getregistry then
        for _, v in pairs(debug.getregistry()) do
            if type(v) == "table" and v.new and type(v.new) == "function" then
                constructor = v.new
                break
            end
        end
    end

    if not constructor then 
        error("[Havoc Critical]: Instance.new not found. Executor is unsupported.", 0) 
    end
    
    return constructor(className)
end

-- Function to register new modules
local function newModule(name, className, path, parent, fn)
    local instance = safeNew(className)
    instance.Name = name
    if parent and instanceFromId[parent] then
        instance.Parent = instanceFromId[parent]
    end
    instanceFromId[path] = instance
    idFromInstance[instance] = path
    modules[instance] = {
        fn = fn,
        isLoaded = false,
        value = nil,
    }
end

-- Function to register standard instances (Folders, Frames, etc.)
local function newInstance(name, className, path, parent)
    local instance = safeNew(className)
    instance.Name = name
    if parent and instanceFromId[parent] then
        instance.Parent = instanceFromId[parent]
    end
    instanceFromId[path] = instance
    idFromInstance[instance] = path
end

-- Runtime Initialization
local function init(env)
    local e = env or getfenv() or _G
    
    -- Global Capture
    Instance = e.Instance or _G.Instance or shared.Instance
    game = e.game or _G.game or shared.game
    task = e.task or _G.task or shared.task
    require = e.require or _G.require
    setmetatable = e.setmetatable or _G.setmetatable
    pcall = e.pcall or _G.pcall
    error = e.error or _G.error
    warn = e.warn or _G.warn

    -- Secondary Metatable Recovery for Instance
    if not Instance and game then
        local mt = getmetatable(game)
        if mt and mt.__index then
            Instance = mt.__index
        end
    end

    if not game then return end
    
    -- Ensure game is ready
    if not game:IsLoaded() then 
        game.Loaded:Wait() 
    end
    
    -- Auto-run LocalScripts after they are bundled
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
return init, newModule, newInstance, newEnv
