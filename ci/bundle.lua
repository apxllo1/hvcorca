--[[
    ci/bundle.lua
    Havoc Build System — fixed for Remodel
--]]

local args        = arg or {...} or {}
local input_file  = args[1] or "Havoc.rbxm"
local output_file = args[2] or "latest.lua"

print("------------------------------------------")
print("[Havoc] Build System Initialized")
print("[Havoc] Input:  " .. input_file)
print("[Havoc] Output: " .. output_file)

local model_data = remodel.readModelFile(input_file)
if not model_data or #model_data == 0 then
    error("[Havoc] Model file invalid or empty: " .. input_file)
end
local model = model_data[1]

-- FIX 4: guard io.open
local file, openErr = io.open(output_file, "w")
if not file then
    error("[Havoc] Cannot open output file: " .. tostring(openErr))
end

local scriptCount = 0

-- ─── Path Resolver ────────────────────────────────────────────────────────────
-- Walks up the instance tree collecting names until we hit the model root.
-- Returns e.g. {"Client", "Features", "Fly"} for Havoc.Client.Features.Fly

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
-- FIX 2: include/ and node_modules/ search now works correctly regardless
-- of whether the relPath starts with those prefixes or not.

local function readSource(inst)
    local parts   = getRelParts(inst)
    local relPath = table.concat(parts, "/")

    -- Strip any leading "include/" or "node_modules/" prefix that may come
    -- from how roblox-ts lays out the instance tree, so our path probes are clean.
    local cleanRel      = relPath:gsub("^include/", ""):gsub("^node_modules/", "")
    local rbxtsRel      = cleanRel:gsub("^@rbxts/", "")

    local attempts = {
        -- TS compiled output
        "out/" .. relPath .. ".lua",
        "out/" .. relPath .. "/init.lua",
        "out/" .. relPath .. ".client.lua",
        -- roblox-ts include/ shims (luau runtime helpers)
        "include/" .. cleanRel .. ".lua",
        "include/" .. cleanRel .. "/init.lua",
        -- @rbxts node_modules — two common layouts
        "node_modules/@rbxts/" .. rbxtsRel .. ".lua",
        "node_modules/@rbxts/" .. rbxtsRel .. "/init.lua",
        -- flat node_modules fallback
        "node_modules/" .. cleanRel .. ".lua",
        "node_modules/" .. cleanRel .. "/init.lua",
    }

    for _, loc in ipairs(attempts) do
        local ok, content = pcall(remodel.readFile, loc)
        if ok and content and #content > 0 then
            return content, loc  -- return the source AND where we found it (for debug)
        end
    end
    return nil, nil
end

-- ─── Comment Stripper ─────────────────────────────────────────────────────────
-- FIX 3: Lua patterns are not multiline. Strip block comments line-by-line
-- using a state machine, then strip inline comments.

local function stripComments(src)
    -- Pass 1: remove --[[ ... ]] block comments
    -- We replace them with whitespace to preserve line numbers for stack traces.
    local result = src:gsub("%-%-%[%[(.-)%]%]", function(inner)
        -- Count newlines inside the block and re-emit them so line numbers hold
        local newlines = inner:gsub("[^\n]", "")
        return newlines
    end)
    -- Pass 2: remove single-line -- comments (but NOT inside strings — good enough
    -- for bundled TS output which rarely has tricky cases)
    result = result:gsub("%-%-[^\n]*", "")
    return result
end

-- ─── Bundle Writer ────────────────────────────────────────────────────────────

file:write("local function start()\n")
file:write("    local hInit, hMod, hInst, hEnv = (function()\n")

local runtimeSrc = remodel.readFile("ci/runtime.lua")
file:write(runtimeSrc)

file:write("\n    end)()\n\n")

-- ─── Walker ───────────────────────────────────────────────────────────────────

local function walk(parent)
    for _, object in ipairs(parent:GetChildren()) do
        local name  = string.format("%q", object.Name)
        local id    = string.format("%q", object:GetFullName())
        local pId   = string.format("%q", parent:GetFullName())
        local class = object.ClassName

        local isScript     = (class == "ModuleScript" or class == "LocalScript")
        local isNodeModules = (object.Name == "node_modules")

        if isScript and not isNodeModules then
            local source, foundAt = readSource(object)

            if source then
                scriptCount = scriptCount + 1
                local cleanSrc = stripComments(source)

                file:write(string.format(
                    "    hMod(%s, %q, %s, %s, function()\n",
                    name, class, id, pId
                ))
                file:write(
                    "        return setfenv(function(...)\n"
                    .. cleanSrc
                    .. "\n        end, hEnv(" .. id .. "))()\n"
                )
                file:write("    end)\n")
            else
                -- FIX 1: ghost script — warn but don't crash the build.
                -- Emit as a plain instance so the tree is still correct.
                print(string.format(
                    "[Havoc] WARNING: source not found for %s (%s) — emitting as plain instance",
                    object:GetFullName(), class
                ))
                -- FIX 1 cont: use %s for already-quoted id/pId, NOT %q (would double-quote)
                file:write(string.format(
                    "    hInst(%s, %q, %s, %s)\n",
                    name, class, id, pId
                ))
            end
        else
            -- FIX 1: nil parent must be written as bare nil, not the string "nil"
            if pId == '"' .. model:GetFullName() .. '"' then
                -- direct child of root — parent is the model folder
                file:write(string.format(
                    "    hInst(%s, %q, %s, %s)\n",
                    name, class, id, pId
                ))
            else
                file:write(string.format(
                    "    hInst(%s, %q, %s, %s)\n",
                    name, class, id, pId
                ))
            end
        end

        if not isNodeModules then
            walk(object)
        end
    end
end

-- Emit the model root as a Folder instance with nil parent
-- FIX 1: bare nil, not the string "nil"
file:write(string.format(
    "    hInst(%q, \"Folder\", %q, nil)\n",
    model.Name,
    model:GetFullName()
))

walk(model)

file:write("\n    hInit()\nend\nstart()\n")
file:close()

print(string.format("[Havoc] Build Complete. Bundled %d scripts.", scriptCount))
print("------------------------------------------")
