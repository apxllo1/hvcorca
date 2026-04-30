local instanceFromId, idFromInstance, modules, currentlyLoading = {}, {}, {}, {}

-- SNAPSHOT STRICT: Environment Factory
-- This is called by the bundle for every hMod to bind the 'script' object
local function hEnv(id)
    local inst = instanceFromId[id]
    return setmetatable({
        script = inst,
        require = function(target)
            -- If requiring a bundled module
            if typeof(target) == "Instance" and modules[target] then
                return _G.__HAVOC_LOAD(target, inst)
            end
            -- Fallback to standard Roblox require (for built-ins)
            return require(target)
        end,
    }, { 
        __index = getfenv(0),
        __metatable = "This metatable is locked"
    })
end

-- SNAPSHOT STRICT: Circular Dependency Validator
local function validateRequire(module, caller)
    currentlyLoading[caller] = module
    local current = module
    local depth = 0
    while current do
        depth = depth + 1
        current = currentlyLoading[current]
        if current == module then
            local traceback = current.Name
            -- Build a readable chain for the error
            for _ = 1, depth do
                current = currentlyLoading[current]
                traceback = traceback .. " => " .. current.Name
            end
            error("[Havoc] Circular dependency detected: " .. traceback)
        end
    end
end

local function loadModule(obj, caller)
    local module = modules[obj]
    if not module then return nil end
    if module.isLoaded then return module.value end
    
    -- Check for loops
    validateRequire(obj, caller)
    
    -- Execute the factory function provided by hMod
    -- In the Snapshot logic, module.fn() already contains the setfenv wrapper
    local success, result = pcall(module.fn)
    
    -- Cleanup loading state
    currentlyLoading[caller] = nil
    
    if not success then 
        error("[Havoc] Runtime Error in " .. obj:GetFullName() .. ": " .. tostring(result)) 
    end

    module.value = result
    module.isLoaded = true
    return result
end

-- Global bridge for roblox-ts cross-module resolution
_G.__HAVOC_LOAD = loadModule

local function hMod(name, class, id, parentId, fn)
    local inst = Instance.new(class)
    inst.Name = name
    inst.Parent = parentId and instanceFromId[parentId] or nil
    instanceFromId[id] = inst
    idFromInstance[inst] = id
    modules[inst] = { fn = fn, isLoaded = false }
end

local function hInst(name, class, id, parentId)
    local inst = Instance.new(class)
    inst.Name = name
    inst.Parent = parentId and instanceFromId[parentId] or nil
    instanceFromId[id] = inst
    idFromInstance[inst] = id
end

local function hInit()
    -- Start entry point scripts (LocalScripts)
    for obj in pairs(modules) do
        if obj:IsA("LocalScript") then 
            task.spawn(function()
                local ok, err = pcall(loadModule, obj, "root")
                if not ok then warn(err) end
            end) 
        end
    end
end

-- CRITICAL: Return hEnv so bundle.lua can use it for setfenv
return hInit, hMod, hInst, hEnv
