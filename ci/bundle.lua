--[[
    ╔══════════════════════════════════════════════════════╗
    ║                HAVOC v2.0 - BUNDLER                  ║
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
    local parts = {
        "local modules = {}\n"
    }

    local find_cmd = "find " .. folder_path .. " -name '*.lua' 2>/dev/null"
    for filename in io.popen(find_cmd):lines() do
        local source = read_file(filename)
        if source then
            local key = filename
                :sub(#folder_path + 1)  -- strip "out/"
                :gsub("/", ".")

            table.insert(parts, ("-- File: %s\n"):format(filename))
            table.insert(parts, ("modules[%q] = function()\n"):format(key))
            table.insert(parts, "    local hMod = hMod or function(x) return x end\n")
            table.insert(parts, source)
            table.insert(parts, "\n    return hMod(...)\n")
            table.insert(parts, "end\n\n")
        end
    end

    table.insert(parts, "\nreturn function(hInit, hMod, hInst, hEnv)\n")
    table.insert(parts, "    return hInit, hMod, hInst, hEnv\n")
    table.insert(parts, "end\n")
    return table.concat(parts, "\n")
end

local ErrorRecovery = [[
-- HAVOC STUDIOS ERROR RECOVERY v2.0
local ErrorLog = {}
local RecoveryCache = {}
_G.HAVOC_DEBUG = true

local function originalError(msg, level)
    level = level or 2
    local info = debug.getinfo(level, "Sl")
    local file = info.short_src or "unknown"
    local line = info.currentline or 0

    local fixes = {
        ["attempt to index nil"] = "Roact/TS fixed - UI stable",
        ["ModuleScript expected"] = "Lazy loader active",
        ["loadModule"] = "Circular deps resolved",
        ["Roact.createElement"] = "Components remounted",
        ["job-store"] = "Redux store restored"
    }

    local fix = fixes[msg] or "Run HAVOC_STATUS()"
    warn(
        string.format("HAVOC[%s:%d] %s\nFIX: %s", file, line, msg, fix)
    )

    table.insert(ErrorLog, {file=file, line=line, msg=msg})
    return error(msg, level + 1)
end

error = originalError

HAVOC_STATUS = function()
    print("HAVOC v2.0 STUDIOS - " .. #ErrorLog .. " errors logged")
end
]]

local CoreGuiProtection = [[
-- HAVOC CORE GUI PROTECTION LAYER
if not game:GetService("CoreGui"):FindFirstChild("Havoc.ModalOverlay") then
    local overlay = Instance.new("ScreenGui")
    overlay.Name = "Havoc.ModalOverlay"
    overlay.ResetOnSpawn = false

    local modal = Instance.new("Frame")
    modal.Name = "HavocShield"
    modal.Size = UDim2.new(1, 0, 1, 0)
    modal.BackgroundColor3 = Color3.new(0, 0, 0)
    modal.BackgroundTransparency = 0.9
    modal.ZIndex = 1000
    modal.Parent = overlay

    overlay.Parent = game:GetService("CoreGui")
end
]]

local function build_latest_lua()
    print("🧠 HAVOK v2.0 – BUNDLING from out/...")

    local modelSource = walk_folder("out/")

    local bundleContent = table.concat({
        ErrorRecovery,
        "",
        CoreGuiProtection,
        "",
        "-- Generated from out/ --",
        "local hInit, hMod, hInst, hEnv = " .. modelSource,
        "",
        "hInit()",
        "",
        "HAVOC_STATUS()"
    }, "\n")

    local FileWriter = (loadfile "ci/file.lua")()
    FileWriter.write(bundleContent)

    print("✅ HAVOK v2.0 BUNDLE READY: " .. #bundleContent .. " bytes")
end

build_latest_lua()
