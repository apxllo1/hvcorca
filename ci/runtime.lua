local instanceFromId, idFromInstance, modules, currentlyLoading = {}, {}, {}, {}

local function loadModule(obj, this)
    local module = modules[obj]
    if not module then return nil end
    if module.isLoaded then return module.value end
    
    -- FIX: Circular Dependency Protection
    -- If this module is already in 'currentlyLoading', it's a circular loop
    if currentlyLoading[obj] then
        error("[Havoc] Circular dependency detected while loading: " .. obj:GetFullName())
    end
    
    currentlyLoading[obj] = true
    
    local scriptWrapper = module.fn()
    
    -- Create the virtual environment for the script
    local env = setmetatable({
        script = obj,
        require = function(target)
            -- If the target is an Instance (like script.Parent.Module)
            if typeof(target) == "Instance" and modules[target] then
                return loadModule(target, obj)
            end
            -- Fallback to standard Roblox require
            return require(target)
        end
    }, { __index = getfenv(0) })
    
    -- Apply the environment
    setfenv(scriptWrapper, env)
    
    local success, result = pcall(scriptWrapper)
    
    -- Clean up loading state
    currentlyLoading[obj] = nil
    
    if not success then 
        error("[Havoc] Runtime Error in " .. obj:GetFullName() .. ": " .. tostring(result)) 
    end

    module.value = result
    module.isLoaded = true
    return result
end

-- FIX: Bridge for global access (often needed by compiled roblox-ts code)
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
    -- Initialize all LocalScripts (entry points)
    for obj in pairs(modules) do
        if obj:IsA("LocalScript") then 
            task.spawn(function()
                local ok, err = pcall(loadModule, obj)
                if not ok then warn(err) end
            end) 
        end
    end
end

return hInit, hMod, hInst
