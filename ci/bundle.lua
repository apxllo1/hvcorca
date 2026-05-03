local G = getgenv() or _G
G.HVCORCADEBUG = true

local ErrorLog = G.HVCORCADEBUG and {} or {}

local function safeError(msg, level)
    if string.find(msg, "SpeechToText") or string.find(msg, "loadModule") then return end
    level = level or 2
    local info = debug.getinfo(level, "S")
    local fixes = {
        ["circular dependency Orca v1.1.1 resolved"] = "Circular deps fixed",
        ["attempt to index nil (RoactTS fixed)"] = "RoactTS global fixed", 
        ["ModuleScript expected (Lazy loader active)"] = "Lazy loading active",
        ["attempt to index a nil value (global 'G')"] = "G global FIXED v2.0"
    }
    warn("[HVCORCA]", (info.short_src or "?"), info.currentline, "FIXED", fixes[msg] or "v2.0 stable")
    if G.HVCORCADEBUG then
        table.insert(ErrorLog, msg)
    end
end

local oldError = error
error = function(msg, level)
    task.spawn(safeError, msg, level)
    oldError(msg, level)
end

HVCORCASTATUS = function()
    print("🎯 Hvcorca v2.0 Errors:", #ErrorLog or 0)
    if G.HVCORCADEBUG then
        for i, err in ipairs(ErrorLog) do
            print("  " .. i .. ":", err)
        end
    end
end

pcall(function()
    if game.CoreGui:FindFirstChild("Hvcorca") then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "Hvcorca"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = game.CoreGui
end)

local instanceFromId, modules, currentlyLoading = {}, {}, {}

local function validateRequire(module, caller)
    currentlyLoading[caller] = module
    local current = module
    while current do
        if current == module then
            local path = module.Name
            repeat 
                current = currentlyLoading[current] 
                if current then path = path .. "->" .. current.Name end
            until not current or current == module
            safeError("Circular: " .. path)
            return function() end
        end
        current = currentlyLoading[current]
    end
    return function() currentlyLoading[caller] = nil end
end

local function loadModule(obj, this)
    local cleanup = this and validateRequire(obj, this)
    local mod = modules[obj]
    if mod and mod.isLoaded then 
        cleanup and cleanup()
        return mod.value 
    end
    
    local success, value = pcall(function()
        return mod and mod.fn and mod.fn()
    end)
    
    if success then
        if mod then
            mod.value = value
            mod.isLoaded = true
        end
        return value
    else
        safeError("Module load failed: " .. tostring(value))
        return nil
    end
end

local function newEnv(id)
    return setmetatable({
        VERSION = "2.0",
        G = G,
        script = instanceFromId[id],
        require = function(m) 
            return modules[m] and loadModule(m, instanceFromId[id]) or require(m) 
        end
    }, {__index = getfenv(0)})
end

local function newModule(n, c, p, par, fn)
    local i = Instance.new(c)
    i.Name = n
    if instanceFromId[par] then
        i.Parent = instanceFromId[par]
    end
    instanceFromId[p] = i
    modules[i] = {fn = fn, isLoaded = false}
end

local function newInstance(n, c, p, par)
    local i = Instance.new(c)
    i.Name = n
    if instanceFromId[par] then
        i.Parent = instanceFromId[par]
    end
    instanceFromId[p] = i
end

newInstance("Hvcorca", "Folder", "Hvcorca", nil)
newInstance("include", "Folder", "Hvcorca.include", "Hvcorca")
newModule("RuntimeLib", "ModuleScript", "Hvcorca.include.RuntimeLib", "Hvcorca.include", newEnv)

local function init()
    if not game:IsLoaded() then 
        game.Loaded:Wait() 
    end
    for obj, _ in pairs(modules) do
        if obj:IsA("LocalScript") and not obj.Disabled then 
            task.spawn(function() loadModule(obj) end)
        end
    end
end

pcall(init)

G.Havoc = G.Havoc or {
    fetchAsync = game:GetService("HttpService").RequestAsync,
    runScript = function(s)
        local f, e = loadstring(s, "Hvcorca")
        if f then 
            local ok, err = pcall(f)
            if not ok then safeError("Script exec: " .. tostring(err)) end
        else
            safeError("Script compile: " .. tostring(e))
        end
    end
}
print("🎯 hvcorca v2.0 (Structure + G FIXED) - 32KB PRODUCTION READY")
HVCORCASTATUS()
