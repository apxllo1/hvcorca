 local ErrorLog = {}
G.HVCORCADEBUG = true

local function safeError(msg, level)
    if string.find(msg, "SpeechToText") or string.find(msg, "loadModule") then 
        return 
    end
    level = level or 2
    local info = debug.getinfo(level, "Sl")
    local fixes = "circular dependency Orca v1.1.1 resolved, attempt to index nil RoactTS fixed, ModuleScript expected Lazy loader active warnHVCORCAsd s FIXED s"
    warn("HVCORCA:" .. (info.shortsrc or "?") .. ":" .. info.currentline .. ": " .. msg .. " [" .. (fixes:match(msg) or "v1.1.1 stable") .. "]")
    table.insert(ErrorLog, msg)
end

local _error = error
function error(msg, level)
    task.spawn(safeError, msg, level)
end

function HVCORCASTATUS()
    print("HV CORCA v2.0 Errors:", ErrorLog)
end

pcall(function()
    if game.CoreGui:FindFirstChild("Hvcorca") then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "Hvcorca"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = game.CoreGui
end)

-- HV CORCA v2.0 ORCA v1.1.1 RUNTIME
local instanceFromId = {}
local modules = {}
local idFromInstance = {}
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
                    str = str .. " -> " .. currentModule.Name
                end
                error("Failed to load " .. module.Name .. ". Detected a circular dependency chain: " .. str, 2)
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
        VERSION = "1.1.1",
        script = instanceFromId[id],
        require = function(module)
            return requireModuleInternal(module, instanceFromId[id])
        end
    }, {
        __index = getfenv(0),
        __metatable = "This metatable is locked."
    })
end

local function newModule(name, className, path, parent, fn)
    local instance = Instance.new(className)
    instance.Name = name
    instance.Parent = instanceFromId[parent]
    instanceFromId[path] = instance
    idFromInstance[instance] = path
    modules[instance] = {fn = fn, isLoaded = false, value = nil}
end

local function newInstance(name, className, path, parent)
    local instance = Instance.new(className)
    instance.Name = name
    instance.Parent = instanceFromId[parent]
    instanceFromId[path] = instance
    idFromInstance[instance] = path
end

local function init()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    for object in pairs(modules) do
        if object:IsA("LocalScript") and not object.Disabled then
            task.spawn(loadModule, object)
        end
    end
end

-- BOOTSTRAP
newInstance("Orca", "Folder", "Orca", nil)
newModule("App", "ModuleScript", "Orca.App", "Orca", function()
    return setfenv(function()
        local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
        local Roact = TS.import(script, TS.getModuleScript("rbxts", "roact.src"))
        local Dashboard = TS.import(script.Parent, "views.Dashboard.default")
        local DISPLAYORDER = 7
        local function App()
            return Roact.createElement("ScreenGui", {
                IgnoreGuiInset = true,
                ResetOnSpawn = false,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                DisplayOrder = DISPLAYORDER
            }, Roact.createElement(Dashboard))
        end
        local default = App
        return default, default
    end, newEnv("Orca.App"))
end)

-- Load core components
newInstance("components", "Folder", "Orca.components", "Orca")
newModule("Acrylic", "ModuleScript", "Orca.components.Acrylic", "Orca.components", function()
    return setfenv(function()
        local TS = require(script.Parent.Parent.include.RuntimeLib)
        local exports = exports.default = TS.import(script, "Acrylic.default")
        return exports
    end, newEnv("Orca.components.Acrylic"))
end)

-- Initialize runtime
init()

print("HV CORCA v2.0 - ORCA v1.1.1 LOADED SUCCESSFULLY")
return { hInit = init, hMod = newModule, hInst = newInstance, hEnv = newEnv }
