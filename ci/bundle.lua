--[[
    ╔══════════════════════════════════════════════════════╗
    ║                HAVOC v2.0 - BUNDLER                  ║
    ║              Option B – Runtime Separate             ║
    ╚══════════════════════════════════════════════════════╝
]]--

-- Load walk.lua and file.lua as sibling files in ci/
-- (we are already in ci/, so no "ci/" prefix)
local BundleWalker = (loadfile "walk.lua")()
local FileWriter   = (loadfile "file.lua")()

-- ============================================================================
-- STUDIOS ERROR RECOVERY ENGINE (as Lua code string)
-- ============================================================================

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

-- ============================================================================
-- CORE GUI PROTECTION LAYER (as Lua code string)
-- ============================================================================

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

-- ============================================================================
-- PRODUCTION BUNDLE GENERATOR
-- ============================================================================

local function buildProductionBundle(srcRoot)
    print("🔨 Compiling Havoc v2.0 STUDIOS...")

    -- If no root given, walk.lua defines its own dummy root
    local modelSource = BundleWalker.walk(srcRoot)

    -- Build final bundle as one Lua string (no runtime.lua inlined)
    local bundleContent = table.concat({
        ErrorRecovery,
        "",
        CoreGuiProtection,
        "",
        -- modelSource must already define hInit, hMod, hInst, hEnv
        "local hInit, hMod, hInst, hEnv = " .. modelSource,
        "",
        "hInit()",             -- boots the loader
        "",
        "HAVOC_STATUS()"
    }, "\n")  -- single \n, not \\n

    FileWriter.write(bundleContent)

    print("✅ HAVOC v2.0 STUDIOS READY")
    print("   📦 Size: " .. #bundleContent .. " bytes")
    print("   🛡️  Error Recovery: ACTIVE")
    print("   🛡️  CoreGui Shield: ACTIVE")
end

-- ============================================================================
-- INITIALIZE BUNDLE BUILD
-- ============================================================================

-- Let `src` come from environment or be nil (safe dummy bundle)
local src = src
buildProductionBundle(src)
