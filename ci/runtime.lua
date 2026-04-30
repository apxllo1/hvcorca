local instanceFromId, idFromInstance, modules, currentlyLoading = {}, {}, {}, {}

local function hEnv(id)
    local inst = instanceFromId[id]
    return setmetatable({
        script = inst,
        require = function(target)
            if typeof(target) == "Instance" and modules[target] then
                return _G.__HAVOC_LOAD(target, inst)
            end
            return require(target)
        end,
    }, { 
        __index = getfenv(0),
        __metatable = "This metatable is locked"
    })
end

local function validateRequire(module, caller)
    currentlyLoading[caller] = module
    local current = module
    while current do
        current = currentlyLoading[current]
        if current == module then
            error("[Havoc] Circular dependency detected at " .. module.Name)
        end
    end
end

local function loadModule(obj, caller)
    local module = modules[obj]
    if not module then return nil end
    if module.isLoaded then return module.value end
    
    validateRequire(obj, caller)
    
    local success, result = pcall(module.fn)
    
    currentlyLoading[caller] = nil
    
    if not success then 
        error("[Havoc] Runtime Error in " .. obj.Name .. ": " .. tostring(result)) 
    end

    module.value = result
    module.isLoaded = true
    return result
end

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
    for obj in pairs(modules) do
        if obj:IsA("LocalScript") then 
            task.spawn(function()
                local ok, err = pcall(loadModule, obj, "root")
                if not ok then warn(err) end
            end) 
        end
    end
end

return hInit, hMod, hInst, hEnv
