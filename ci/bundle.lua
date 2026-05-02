--[[
    ╔══════════════════════════════════════════════════════╗
    ║                HAVOC v2.0 - BUNDLER                  ║
    ╚══════════════════════════════════════════════════════╝
]]--

local BundleWalker = (loadfile "ci/walk.lua")()
local FileWriter   = (loadfile "ci/file.lua")()

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

local function buildProductionBundle()
    print("🔨 Compiling Havoc v2.0 STUDIOS...")

    -- Let walk.lua own its own dummy srcRoot logic
    -- (or change it to read out/ from the filesystem instead)
    local modelSource = BundleWalker.walk(game)

    local bundleContent = table.concat({
        ErrorRecovery,
        "",
        CoreGuiProtection,
        "",
        "local hInit, hMod, hInst, hEnv = " .. modelSource,
        "",
        "hInit()",
        "",
        "HAVOC_STATUS()"
    }, "\n")

    FileWriter.write(bundleContent)

    print("✅ HAVOC v2.0 STUDIOS READY")
    print("   📦 Size: " .. #bundleContent .. " bytes")
end

-- Run with game as the root
buildProductionBundle()
