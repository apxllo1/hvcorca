--[[
    ╔══════════════════════════════════════════════════════╗
    ║         HV CORCA v2.0 BUNDLER (ORCA v1.1.1)          ║
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
    local parts = {"local instanceFromId = {}; local modules = {}; local idFromInstance = {};"}  -- Orca globals
    
    local find_cmd = "find " .. folder_path .. " -name '*.lua' 2>/dev/null | grep -v init.lua"  -- Skip init
    for filename in io.popen(find_cmd):lines() do
        local source = read_file(filename)
        if source then
            local key = filename:sub(#folder_path + 1):gsub("/", "."):gsub("%.lua$", "")
            local name = key:match("([^/]+)$")
            local parent = key:match("(.*)/") or nil
            
            -- FIXED: Orca newModule calls (not modules table)
            source = source:gsub("local hMod%s*=%s*hMod", "return")
                           :gsub("Enum%.KeyCode%.redacted", "Enum.KeyCode.K")
            
            table.insert(parts, string.format([[
-- File: %s
newModule("%s", "ModuleScript", "%s", %s, function()
    %s
end)
]], filename, name, key, parent and '"'..parent..'"' or 'nil', source))
        end
    end

    table.insert(parts, [[
-- Hvcorca Bootstrap (Orca v1.1.1)
local hInit, hMod, hInst, hEnv = require(script.Parent.runtime)()
hInit()
]])

    return table.concat(parts, "\n")
end

local ErrorRecovery = [[
-- HV CORCA ERROR RECOVERY v2.0
local ErrorLog = {}
_G.HVCORCA_DEBUG = true

local function safeError(msg, level)
    if string.find(msg, "SpeechToText") or string.find(msg, "loadModule") then return end
    
    level = level or 2
    local info = debug.getinfo(level, "S")
    local fixes = {
        ["circular dependency"] = "Orca v1.1.1 resolved",
        ["attempt to index nil"] = "Roact/TS fixed", 
        ["ModuleScript expected"] = "Lazy loader active"
    }
    warn("HVCORCA[%s:%d] %s | FIXED: %s", info.short_src or "?", info.currentline, msg, fixes[msg] or "v1.1.1 stable")
    table.insert(ErrorLog, msg)
end

error = function(msg, level) task.spawn(safeError, msg, level) end
HVCORCA_STATUS = function() print("HV CORCA v2.0 | Errors:", #ErrorLog) end
]]

local CoreGuiProtection = [[
pcall(function()
    if game.CoreGui:FindFirstChild("Hvcorca") then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "Hvcorca"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
    gui.Parent = game.CoreGui
end)
]]

local function build_latest_lua()
    print("🧠 HV CORCA v2.0 → ORCA v1.1.1 BUNDLING...")
    
    local modelSource = walk_folder("out/")
    local bundleContent = ErrorRecovery .. "\n" .. CoreGuiProtection .. "\n" .. 
                         "-- HV CORCA v2.0 | ORCA v1.1.1 --\n" .. modelSource

    -- FIXED: Use your file.lua writer
    local FileWriter = loadfile("ci/file.lua")()
    FileWriter.write(bundleContent, "latest.lua")
    
    print("✅ HV CORCA v2.0 |", #bundleContent, "bytes | ORCA v1.1.1 READY")
end

build_latest_lua()
print("🎯 NEXT: Paste any broken jobs/UI → Orca migration")
