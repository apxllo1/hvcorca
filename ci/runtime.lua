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
    }, { __index = getfenv(0) })
end

local function validateRequire(module, caller)
    currentlyLoading[caller] = module
    local current = module
    while current do
        current = currentlyLoading[current]
        if current == module then error("[Havoc] Circular dependency in " .. module.Name) end
    end
end

local function loadModule(obj, caller)
    local module = modules[obj]
    if not module or module.isLoaded then return module and module.value end
    validateRequire(obj, caller)
    local success, result = pcall(module.fn)
    currentlyLoading[caller] = nil
    if not success then error(tostring(result)) end
    module.value, module.isLoaded = result, true
    return result
end

_G.__HAVOC_LOAD = loadModule

local function hMod(name, class, id, parentId, fn)
    local inst = Instance.new(class)
    inst.Name, inst.Parent = name, (parentId and instanceFromId[parentId] or nil)
    instanceFromId[id], idFromInstance[inst] = inst, id
    modules[inst] = { fn = fn, isLoaded = false }
end

local function hInst(name, class, id, parentId)
    local inst = Instance.new(class)
    inst.Name, inst.Parent = name, (parentId and instanceFromId[parentId] or nil)
    instanceFromId[id], idFromInstance[inst] = inst, id
end

local function hInit()
    for obj in pairs(modules) do
        if obj:IsA("LocalScript") then task.spawn(loadModule, obj, "root") end
    end
end

return hInit, hMod, hInst, hEnv
