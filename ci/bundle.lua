-- bundle.lua
local args = arg or {...} or {}
local input_file = args[1] or "Havoc.rbxm"
local output_file = args[2] or "latest.lua"

print("------------------------------------------")
print("[Havoc] Reading: " .. input_file)
print("[Havoc] Writing: " .. output_file)
print("------------------------------------------")

local model_data = remodel.readModelFile(input_file)
if not model_data or #model_data == 0 then
    error("[Havoc] Model file is empty or invalid: " .. input_file)
end
local model = model_data[1]

local file, err = io.open(output_file, "w")
if not file then
    error("[Havoc] Could not open output file: " .. tostring(err))
end

local scriptCount = 0

-- Helper: get path parts relative to model root
local function getRelParts(inst)
    local parts = {}
    local curr = inst
    while curr and curr.Name ~= model.Name do
        table.insert(parts, 1, curr.Name)
        curr = curr.Parent
    end
    return parts
end

-- Helper: try to read source from several locations
local function readSource(inst)
    local parts = getRelParts(inst)
    local relPath = table.concat(parts, "/")

    -- Strip leading "include/" to get the bare name for include/ folder lookups
    local includePath = relPath:match("^include/(.+)$") or relPath
    -- Strip "include/node_modules/" prefix for node_modules lookups
    local nmPath = relPath:gsub("^include/node_modules/", "")

    local attempts = {
        -- roblox-ts compiled output
        "out/" .. relPath .. ".lua",
        "out/" .. relPath .. "/init.lua",
        -- client scripts (main.client.tsx compiles to main.client.lua)
        "out/" .. relPath .. ".client.lua",
        "out/" .. relPath .. ".server.lua",
        -- include folder (Promise, RuntimeLib live here)
        "include/" .. includePath .. ".lua",
        "include/" .. includePath .. "/init.lua",
        -- node_modules
        "node_modules/@rbxts/" .. nmPath .. ".lua",
        "node_modules/@rbxts/" .. nmPath .. "/init.lua",
    }

    for _, loc in ipairs(attempts) do
        local ok, content = pcall(remodel.readFile, loc)
        if ok and content and #content > 0 then
            return content
        end
    end
    return nil
end

-- HEADER
file:write("local function start()\n")
file:write("    local hInit, hMod, hInst, hEnv = (function()\n")
file:write(remodel.readFile("ci/runtime.lua"))
file:write("\n    end)()\n\n")

-- Register root with nil parent (matches Richie's original)
local rootName = string.format("%q", model.Name)
local rootPath = string.format("%q", model:GetFullName())
file:write(string.format("    hInst(%s, \"Folder\", %s, nil)\n", rootName, rootPath))

-- Register include folder so RuntimeLib/Promise can be parented correctly
file:write(string.format(
    "    hInst(\"include\", \"Folder\", %q, %q)\n",
    model.Name .. ".include",
    model.Name
))

local SKIP_INLINE = { node_modules = true }

local function walk(parent)
    for _, object in ipairs(parent:GetChildren()) do
        local name     = string.format("%q", object.Name)
        local path     = string.format("%q", object:GetFullName())
        local pPath    = string.format("%q", parent:GetFullName())
        local class    = object.ClassName
        local isScript = class == "ModuleScript" or class == "LocalScript"

        -- node_modules: register as instances only, no inline source
        -- They are resolved by the TS runtime via require()
        if SKIP_INLINE[object.Name] then
            file:write(string.format("    hInst(%s, %q, %s, %s)\n", name, class, path, pPath))
            walk(object)

        elseif isScript then
            local src = readSource(object)
            if src and #src > 0 then
                -- Strip block comments to avoid executor parse errors on ] ] variants
                src = src:gsub("%-%-%[%[.-%]%]", "")
                src = src:gsub("%-%-%[%[.-%] %]", "")
                -- Strip line comments
                src = src:gsub("%-%-[^\n]*", "")
                -- Escape any remaining ]] just in case
                src = src:gsub("%]%]", "] ]")
                scriptCount = scriptCount + 1
                file:write(string.format(
                    "    hMod(%s, %q, %s, %s, function()\n        return (function(...)\n%s\n        end)\n    end)\n",
                    name, class, path, pPath, src
                ))
            else
                print("[WARN] No source found for: " .. object:GetFullName())
                file:write(string.format("    hInst(%s, %q, %s, %s)\n", name, class, path, pPath))
            end
            walk(object)

        else
            file:write(string.format("    hInst(%s, %q, %s, %s)\n", name, class, path, pPath))
            walk(object)
        end
    end
end

walk(model)

-- FOOTER
file:write("\n    hInit()\nend\n\nstart()\n")
file:close()

print("------------------------------------------")
print("[Havoc] Bundled " .. scriptCount .. " scripts into " .. output_file)
print("------------------------------------------")
