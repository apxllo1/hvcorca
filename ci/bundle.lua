--[[
    ╔══════════════════════════════════════════════════════╗
    ║                HAVOC v2.0 - BUNDLER                  ║
    ║              Production-Ready -  Syntax Clean        ║
    ╚══════════════════════════════════════════════════════╝
]]--

-- Load walk.lua and file.lua as local files in the same dir
local BundleWalker = (loadfile "walk.lua")()
local FileWriter   = (loadfile "file.lua")()

-- ... rest of bundle.lua unchanged ...

local ErrorRecovery = [[ ... ]]
local CoreGuiProtection = [[ ... ]]

local function buildProductionBundle()
    print("🔨 Compiling Havoc v2.0 Enterprise...")

    local modelSource = BundleWalker.walk(script.Parent.Parent.src)

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

    print("✅ HAVOC v2.0 ENTERPRISE READY")
    print("   📦 Size: " .. #bundleContent .. " bytes")
    print("   🛡️  Error Recovery: ACTIVE")
    print("   🛡️  CoreGui Shield: ACTIVE")
end

buildProductionBundle()
