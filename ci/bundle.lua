--[[
    ci/bundle.lua
    Havoc Build System — Remodel bundler.
    Reads Havoc.rbxm, walks the full instance tree including node_modules,
    and emits a self-contained latest.lua with runtime + all module sources.

    Usage:
        remodel run ci/bundle.lua
        remodel run ci/bundle.lua MyModel.rbxm output.lua
--]]

local args        = arg or {...} or {}
local input_file  = args[1] or "Havoc.rbxm"
local output_file = args[2] or "latest.lua"

print("------------------------------------------")
print("[Havoc] Build System Initialized")
print("[Havoc] Input:  " .. input_file)
print("[Havoc] Output: " .. output_file)

-- ─── Load Model ───────────────────────────────────────────────────────────────

local model_data = remodel.readModelFile(input_file)
if not model_data or #model_data == 0 then
    error("[Havoc] Model file invalid or empty: " .. input_file)
end
local model = model_data[1]

-- ─── Open Output File ─────────────────────────────────────────────────────────

local file, openErr = io.open(output_file, "w")
if not file then
    error("[Havoc] Cannot open output file: " .. tostring(openErr))
end

local scriptCount  = 0
local missingCount = 0

-- ─── Path Resolver ────────────────────────────────────────────────────────────
-- Returns ordered list of ancestor names from model root down to inst.
-- e.g. Havoc.include.node_modules.flipper.src → {"include","node_modules","flipper","src"}

local function getRelParts(inst)
    local parts = {}
    local curr  = inst
    while curr and curr.Name ~= model.Name do
        table.insert(parts, 1, curr.Name)
        curr = curr.Parent
    end
    return parts
end

-- ─── Source Finder ────────────────────────────────────────────────────────────
-- Your .rbxm node_modules layout (confirmed from build warnings):
--
--   CASE A — package has a compiled subfolder:
--     node_modules → flipper → src        parts = {..., "node_modules", "flipper", "src"}
--     node_modules → roact → src          parts = {..., "node_modules", "roact",   "src"}
--     node_modules → rodux → src          parts = {..., "node_modules", "rodux",   "src"}
--     node_modules → roact-hooked → out   parts = {..., "node_modules", "roact-hooked", "out"}
--     node_modules → roact-hooked → out → hooks → use-state  (deeply nested)
--
--   CASE B — package IS the leaf (flat):
--     node_modules → make                 parts = {..., "node_modules", "make"}
--     node_modules → services             parts = {..., "node_modules", "services"}
--     node_modules → object-utils         parts = {..., "node_modules", "object-utils"}
--
-- On disk, ALL packages live under node_modules/@rbxts/<pkgName>/
-- We find "node_modules" in the parts list and reconstruct the correct disk path.

local function getNodeModulesProbes(parts)
    -- Find the "node_modules" segment index
    local nmIdx = nil
    for i, p in ipairs(parts) do
        if p == "node_modules" then nmIdx = i; break end
    end
    if not nmIdx then return {} end

    local pkgName = parts[nmIdx + 1]   -- e.g. "flipper", "make", "roact-hooked"
    if not pkgName then return {} end

    -- Everything after the package name = in-package sub-path
    -- e.g. for "flipper.src" → subParts = {"src"}
    -- e.g. for "roact-hooked.out.hooks.use-state" → subParts = {"out","hooks","use-state"}
    -- e.g. for "make" (flat) → subParts = {}
    local subParts = {}
    for i = nmIdx + 2, #parts do
        table.insert(subParts, parts[i])
    end

    -- On-disk base: try both @rbxts/ scoped and unscoped layouts
    -- (some roblox-ts versions use @rbxts/, others install flat)
    local bases = {
        "node_modules/@rbxts/" .. pkgName,
        "node_modules/"        .. pkgName,
    }

    local probes = {}

    if #subParts == 0 then
        -- CASE B: flat package — instance IS the entry point
        for _, base in ipairs(bases) do
            table.insert(probes, base .. "/src/init.lua")
            table.insert(probes, base .. "/lib/init.lua")
            table.insert(probes, base .. "/out/init.lua")
            table.insert(probes, base .. "/init.lua")
        end
    else
        -- CASE A: package has subfolder(s)
        -- subPath e.g. "src", "out", "out/hooks/use-state"
        local subPath = table.concat(subParts, "/")
        for _, base in ipairs(bases) do
            table.insert(probes, base .. "/" .. subPath .. ".lua")
            table.insert(probes, base .. "/" .. subPath .. "/init.lua")
        end
    end

    return probes
end

local function readSource(inst)
    local parts   = getRelParts(inst)
    local relPath = table.concat(parts, "/")
    local cleanRel = relPath
        :gsub("^include/", "")
        :gsub("^node_modules/", "")

    local attempts = {
        -- ── Compiled app source (roblox-ts out/) ────────────────────────────
        "out/" .. relPath .. ".lua",
        "out/" .. relPath .. "/init.lua",
        "out/" .. relPath .. ".client.lua",
        -- ── roblox-ts include/ shims (RuntimeLib, Promise, etc.) ─────────────
        "include/" .. cleanRel .. ".lua",
        "include/" .. cleanRel .. "/init.lua",
    }

    -- ── node_modules packages — handles both flat and subfolder layouts ───────
    for _, probe in ipairs(getNodeModulesProbes(parts)) do
        table.insert(attempts, probe)
    end

    for _, loc in ipairs(attempts) do
        local ok, content = pcall(remodel.readFile, loc)
        if ok and content and #content > 0 then
            return content, loc
        end
    end

    return nil, nil
end

-- ─── Comment Stripper ─────────────────────────────────────────────────────────
-- Pass 1: block comments --[[ ... ]] — body chars stripped, newlines kept
--         (preserves line numbers so executor stack traces are accurate)
-- Pass 2: single-line -- comments

local function stripComments(src)
    -- Safe parser: tracks string state so -- inside strings is never stripped.
    -- The naive gsub approach breaks on: local s = "hello -- world"
    local out = {}
    local i   = 1
    local len = #src

    while i <= len do
        -- Block comment --[[ ... ]] — strip body, keep newlines for stack traces
        if src:sub(i, i+3) == "--[[" then
            local close = src:find("%]%]", i + 4)
            if close then
                out[#out+1] = src:sub(i + 4, close - 1):gsub("[^\n]", "")
                i = close + 2
            else
                i = len + 1  -- unclosed block comment, skip to end
            end

        -- Single-line comment -- (only when NOT inside a string)
        elseif src:sub(i, i+1) == "--" then
            local nl = src:find("\n", i + 2, true)
            i = nl or (len + 1)  -- skip to newline; newline itself kept next iter

        -- Double-quoted string "..." — copy verbatim, respect escapes
        elseif src:sub(i, i) == '"' then
            local j = i + 1
            while j <= len do
                local c = src:sub(j, j)
                if c == "\\" then j = j + 2
                elseif c == '"' then j = j + 1; break
                else j = j + 1 end
            end
            out[#out+1] = src:sub(i, j - 1)
            i = j

        -- Single-quoted string '...' — copy verbatim, respect escapes
        elseif src:sub(i, i) == "'" then
            local j = i + 1
            while j <= len do
                local c = src:sub(j, j)
                if c == "\\" then j = j + 2
                elseif c == "'" then j = j + 1; break
                else j = j + 1 end
            end
            out[#out+1] = src:sub(i, j - 1)
            i = j

        -- Long string [[...]] — copy verbatim (not a comment)
        elseif src:sub(i, i+1) == "[[" then
            local close = src:find("%]%]", i + 2)
            if close then
                out[#out+1] = src:sub(i, close + 1)
                i = close + 2
            else
                out[#out+1] = src:sub(i)
                i = len + 1
            end

        else
            out[#out+1] = src:sub(i, i)
            i = i + 1
        end
    end

    return table.concat(out)
end

-- ─── Bundle Header ────────────────────────────────────────────────────────────

file:write("-- Havoc | Auto-generated by ci/bundle.lua — do not edit\n")
file:write("local function start()\n")
file:write("    local hInit, hMod, hInst, hEnv = (function()\n")
file:write(remodel.readFile("ci/runtime.lua"))
file:write("\n    end)()\n\n")

-- ─── Walker ───────────────────────────────────────────────────────────────────
-- Walks the ENTIRE instance tree.
-- ModuleScript/LocalScript with found source → hMod (has factory fn)
-- Everything else, or scripts with no source → hInst (plain virtual instance)

local function walk(parent)
    for _, object in ipairs(parent:GetChildren()) do
        local name  = string.format("%q", object.Name)
        local id    = string.format("%q", object:GetFullName())
        local pId   = string.format("%q", parent:GetFullName())
        local class = object.ClassName
        local isScript = (class == "ModuleScript" or class == "LocalScript")

        if isScript then
            local source, foundAt = readSource(object)

            if source then
                scriptCount = scriptCount + 1
                local clean = stripComments(source)
                file:write(string.format(
                    "    hMod(%s, %q, %s, %s, function()\n",
                    name, class, id, pId
                ))
                file:write(
                    "        return _setfenv(function(...)\n"
                    .. clean
                    .. "\n        end, hEnv(" .. id .. "))()\n"
                )
                file:write("    end)\n")
            else
                missingCount = missingCount + 1
                print(string.format(
                    "[Havoc] WARNING: no source for %s (%s) — registered as plain instance",
                    object:GetFullName(), class
                ))
                file:write(string.format(
                    "    hInst(%s, %q, %s, %s)\n",
                    name, class, id, pId
                ))
            end
        else
            file:write(string.format(
                "    hInst(%s, %q, %s, %s)\n",
                name, class, id, pId
            ))
        end

        walk(object)
    end
end

-- Model root registered with nil parent
file:write(string.format(
    "    hInst(%q, \"Folder\", %q, nil)\n",
    model.Name,
    model:GetFullName()
))

walk(model)

-- ─── Footer ───────────────────────────────────────────────────────────────────

file:write("\n    hInit()\nend\nstart()\n")
file:close()

print(string.format(
    "[Havoc] Build complete — %d scripts bundled, %d missing sources.",
    scriptCount, missingCount
))
print("------------------------------------------")
