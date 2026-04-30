local instanceFromId, idFromInstance, modules, currentlyLoading = {}, {}, {}, {}

local function loadModule(obj, this)
    local module = modules[obj]
    if not module then return nil end
    if module.isLoaded then return module.value end
    
    currentlyLoading[this or "root"] = obj
    
    local scriptWrapper = module.fn()
    -- FIX: Ensure environment has access to the custom require
    local env = setmetatable({
        script = obj,
        require = function(target)
            if modules[target] then
                return loadModule(target, obj)
            end
            return require(target)
        end
    }, { __index = getfenv(0) })
    
    setfenv(scriptWrapper, env)
    local success, result = pcall(scriptWrapper)
    
    if not success then 
        error("[Havoc] Runtime Error in " .. obj.Name .. ": " .. tostring(result)) 
    end

    module.value = result
    module.isLoaded = true
    return result
end

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
            task.spawn(loadModule, obj) 
        end
    end
end

return hInit, hMod, hInst
