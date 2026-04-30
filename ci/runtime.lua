local instanceFromId = {}
local idFromInstance = {}
local modules = {}
local currentlyLoading = {}

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
                    str = str .. "\n" .. currentModule.Name
                end
                error("Failed to load '" .. module.Name .. "'; Circular dependency:\n" .. str, 2)
            end
        end
    end
    return function()
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
        local data = module.fn()
        module.value = data
        module.isLoaded = true
        if cleanup then cleanup() end
        return data
    end
end

local function requireModuleInternal(target, this)
    if modules[target] and target:IsA("ModuleScript") then
        return loadModule(target, this)
    else
        return require(target)
    end
end

local function newEnv(id)
    return setmetatable({
        script = instanceFromId[id],
        require = function(module)
            return requireModuleInternal(module, instanceFromId[id])
        end,
    }, {
        __index = getfenv(0),
        __metatable = "This metatable is locked",
    })
end

local function hMod(name, class, id, parentId, fn)
    local inst = Instance.new(class)
    inst.Name = name
    inst.Parent = parentId ~= nil and instanceFromId[parentId] or nil
    instanceFromId[id] = inst
    idFromInstance[inst] = id
    modules[inst] = { fn = fn, isLoaded = false, value = nil }
end

local function hInst(name, class, id, parentId)
    local inst = Instance.new(class)
    inst.Name = name
    inst.Parent = parentId ~= nil and instanceFromId[parentId] or nil
    instanceFromId[id] = inst
    idFromInstance[inst] = id
end

local function hInit()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    for obj in pairs(modules) do
        if obj:IsA("LocalScript") and not obj.Disabled then
            task.spawn(loadModule, obj)
        end
    end
end

return hInit, hMod, hInst, newEnv
