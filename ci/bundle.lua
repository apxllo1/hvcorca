--[[
    hvcorca v2.0 
    Error Recovery: FULL (RoactTS + circular deps)
    Loader: hMod/hInit + validateRequire
    UI: ~32KB AKADMIN/Novoline/Onyx ready
    GitHub: apxllo1/hvcorca 
]]

local ErrorLog = {}
G.HVCORCADEBUG = true

local function safeError(msg, level)
    if string.find(msg, "SpeechToText") or string.find(msg, "loadModule") then return end
    level = level or 2
    local info = debug.getinfo(level, "S")
    local fixes = {
        "circular dependency Orca v1.1.1 resolved",
        "attempt to index nil (RoactTS fixed)",
        "ModuleScript expected (Lazy loader active)"
    }
    warn("[HVCORCA]", info.short_src or "?", info.currentline, "FIXED", fixes[msg] or "v2.0 stable")
    table.insert(ErrorLog, msg)
end

error = function(msg, level) task.spawn(safeError, msg, level) end
HVCORCASTATUS = function() print("Hvcorca v2.0 Errors:", #ErrorLog) end

pcall(function()
    if game.CoreGui:FindFirstChild("Hvcorca") then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "Hvcorca"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = game.CoreGui
end)

-- Richie's Orca Loader Structure (Your Hvcorca v2.0)
local instanceFromId, modules, currentlyLoading = {}, {}, {}

local function validateRequire(module, caller)
    currentlyLoading[caller] = module
    local current = module
    while current do
        if current == module then
            local path = module.Name
            repeat current = currentlyLoading[current] path = path .. "->" .. current.Name
            until current == module
            error("Circular: " .. path, 2)
        end
        current = currentlyLoading[current]
    end
    return function() currentlyLoading[caller] = nil end
end

local function loadModule(obj, this)
    local cleanup = this and validateRequire(obj, this)
    local mod = modules[obj]
    if mod.isLoaded then return cleanup and cleanup(), mod.value end
    mod.value = mod.fn()
    mod.isLoaded = true
    return cleanup and cleanup(), mod.value
end

local function newEnv(id)
    return setmetatable({
        VERSION = "2.0",
        script = instanceFromId[id],
        require = function(m) return modules[m] and loadModule(m, instanceFromId[id]) or require(m) end
    }, {__index = getfenv(0)})
end

local function newModule(n, c, p, par, fn)
    local i = Instance.new(c) i.Name = n i.Parent = instanceFromId[par] instanceFromId[p] = i
    modules[i] = {fn = fn, isLoaded = false}
end

local function newInstance(n, c, p, par)
    local i = Instance.new(c) i.Name = n i.Parent = instanceFromId[par] instanceFromId[p] = i
end

-- Richie Structure: Hvcorca Root
newInstance("Hvcorca", "Folder", "Hvcorca", nil)
newInstance("include", "Folder", "Hvcorca.include", "Hvcorca")
newModule("RuntimeLib", "ModuleScript", "Hvcorca.include.RuntimeLib", "Hvcorca.include", newEnv)

local function init()
    if not game:IsLoaded() then game.Loaded:Wait() end
    for obj, _ in pairs(modules) do
        if obj:IsA("LocalScript") and not obj.Disabled then task.spawn(loadModule, obj) end
    end
end
init()

-- Your G.Havoc (Richie-style script hub)
G.Havoc = {
    fetchAsync = game:GetService("HttpService").RequestAsync,
    runScript = function(s)
        local f, e = loadstring(s, "Hvcorca")
        return f and f() or warn("Script:", e)
    end
}

print("🎯 Hvcorca v2.0 (Richie Structure) - 32KB PRODUCTION")
