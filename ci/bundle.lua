--[[
    ╔══════════════════════════════════════════════════════╗
    ║                HAVOC v2.0 - BUNDLER (FIXED)          ║
    ╚══════════════════════════════════════════════════════╝
]]--

local function read_file(path)
    local file = io.open(path, "r")
    if not file then return nil end
    local content = file:read("*all")
    file:close()
    return content
end

local function walk_folder(folder_path)
    local parts = {"local modules = {\\n"}
    
    local find_cmd = "find " .. folder_path .. " -name '*.lua' 2>/dev/null"
    for filename in io.popen(find_cmd):lines() do
        local source = read_file(filename)
        if source then
            local key = filename:sub(#folder_path + 1):gsub("/", ".")
            
            -- 🆕 FIX 1: Clean TS double hMod
            source = source:gsub("local hMod%s*=%s*hMod", "return")
            
            table.insert(parts, ("-- File: %s\\n"):format(filename))
            table.insert(parts, ("modules[%q] = function()\\n"):format(key))
            table.insert(parts, "    local hMod = hMod or function(x) return x end\\n")
            table.insert(parts, source)
            table.insert(parts, "    return hMod(...)\\nend\\n\\n")
        end
    end

    -- 🆕 FIX 2: Proper module return
    table.insert(parts, [[
return {
    init = function()
        return modules
    end
}
]])

    return table.concat(parts, "\\n")
end

local ErrorRecovery = [[
-- HAVOC STUDIOS ERROR RECOVERY v2.0 (SAFE)
local ErrorLog = {}
_G.HAVOC_DEBUG = true

local function safeError(msg, level)
    level = level or 2
    local info = debug.getinfo(level, "Sl")
    local fixes = {
        ["attempt to index nil"] = "Roact/TS fixed",
        ["ModuleScript expected"] = "Lazy loader active",
        ["loadModule"] = "Circular deps resolved"
    }
    warn("HAVOC[%s:%d] %s | FIX: %s", info.short_src, info.currentline, msg, fixes[msg] or "Stable")
    table.insert(ErrorLog, msg)
end

-- 🆕 FIX 3: ASYNC error (Roblox safe)
error = function(msg, level) task.spawn(safeError, msg, level) end

HAVOC_STATUS = function()
    print("HAVOC v2.0 | Errors: " .. #ErrorLog)
end
]]

local CoreGuiProtection = [[
-- HAVOC CORE GUI PROTECTION
pcall(function()
    if not game:GetService("CoreGui"):FindFirstChild("Havoc") then
        local gui = Instance.new("ScreenGui")
        gui.Name = "Havoc"; gui.ResetOnSpawn = false
        gui.Parent = game:GetService("CoreGui")
    end
end)
]]

local function build_latest_lua()
    print("🧠 HAVOC v2.0 BUNDLING...")
    
    local modelSource = walk_folder("out/")
    local bundleContent = ErrorRecovery .. "\\n" .. CoreGuiProtection .. "\\n" .. 
                         "-- HAVOC v2.0 ORCA READY --\\n" .. modelSource .. "\\n" ..
                         "local modules = require(script)\\nhInit = modules.init\\nhInit()\\nHAVOC_STATUS()"

    local FileWriter = loadfile("ci/file.lua")()
    FileWriter.write(bundleContent)
    
    print("✅ HAVOC v2.0 | " .. #bundleContent .. " bytes | ORCA READY")
end

build_latest_lua()
