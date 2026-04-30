local instanceFromId = {}
local idFromInstance = {}
local modules = {}
local currentlyLoading = {}

-- Helper to set up the environment for each script
local function newEnv(id)
    local inst = instanceFromId[id]
    local env = setmetatable({
        script = inst,
        -- Overwrite the global require with our virtual one
        require = function(target)
            if typeof(target) == "Instance" then
                if modules[target] then
                    -- We pass the current script instance so we can track circular deps
                    local loadModule = _G.__HAVOC_LOAD -- Accessed via _G to avoid scope issues
                    return loadModule(target, inst)
                end
            end
            return require(target)
        end,
    }, {
        __index = getfenv(0),
        __metatable = "This metatable is locked",
    })
    return env
end

local function validateRequire(module, caller)
    currentlyLoading[caller] = module
    local currentModule = module
    local depth = 0
    
    while currentModule do
        depth = depth + 1
        currentModule = currentlyLoading[currentModule]
        if currentModule == module then
            local str = currentModule.Name
            for _ = 1, depth do
                currentModule = currentlyLoading[currentModule]
                str = str .. "\n" .. currentModule.Name
            end
            error("[Havoc] Circular dependency detected:\n" .. str, 2)
        end
    end

    return function()
        if currentlyLoading[caller] == module then
            currentlyLoading[caller] = nil
        end
    end
end

local function loadModule(obj, this)
    local module = modules[obj]
    if not module then return nil end
    
    if module.isLoaded then
        return module.value
    end

    local cleanup = this and validateRequire(obj, this)
    
    -- bundle.lua wraps source in: function() return (function(...) [SRC] end) end
    -- We call the first function to get the actual script closure
    local scriptWrapper = module.fn()
    
    -- Inject the custom environment so 'script' and 'require' work as expected
    local env = newEnv(idFromInstance[obj])
    setfenv(scriptWrapper, env)

    -- Execute the module and catch exports
    local success, result = pcall(scriptWrapper)
    
    if not success then
        error(string.format("[Havoc] Runtime Error in %s: %s", obj:GetFullName(), tostring(result)), 0)
    end

    module.value = result
    module.isLoaded = true
    
    if cleanup then cleanup() end
    return result
end

-- Export to _G temporarily so the virtual require can see the loader
_G.__HAVOC_LOAD = loadModule

local function hMod(name, class, id, parentId, fn)
    local inst = Instance.new(class)
    inst.Name = name
    inst.Parent = (parentId ~= nil) and instanceFromId[parentId] or nil
    
    instanceFromId[id] = inst
    idFromInstance[inst] = id
    modules[inst] = { fn = fn, isLoaded = false, value = nil }
end

local function hInst(name, class, id, parentId)
    local inst = Instance.new(class)
    inst.Name = name
    inst.Parent = (parentId ~= nil) and instanceFromId[parentId] or nil
    
    instanceFromId[id] = inst
    idFromInstance[inst] = id
end

local function hInit()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    -- Run all LocalScripts to start the execution flow
    for obj, data in pairs(modules) do
        if obj:IsA("LocalScript") and not obj.Disabled then
            task.spawn(function()
                loadModule(obj)
            end)
        end
    end
end

return hInit, hMod, hInst, newEnv
