--[[
    ci/bundle.lua
    Havoc Build System — fixed for Remodel
--]]

local args        = arg or {...} or {}
local input_file  = args[1] or "Havoc.rbxm"
local output_file = args[2] or "latest.lua"

print("------------------------------------------")
print("[Havoc] Build System Initialized")

local model_data = remodel.readModelFile(input_file)
local model = model_data[1]

local file, openErr = io.open(output_file, "w")
if not file then error("[Havoc] Cannot open output file: " .. tostring(openErr)) end

local scriptCount = 0

local function getRelParts(inst)
    local parts = {}
    local curr  = inst
    while curr and curr.Name ~= model.Name do
        table.insert(parts, 1, curr.Name)
        curr = curr.Parent
    end
    return parts
end

local function readSource(inst)
    local parts   = getRelParts(inst)
    local relPath = table.concat(parts, "/")
    local cleanRel = relPath:gsub("^include/", ""):gsub("^node_modules/", "")
    local rbxtsRel = cleanRel:gsub("^@rbxts/", "")

    local attempts = {
        "out/" .. relPath .. ".lua",
        "out/" .. relPath .. "/init.lua",
        "out/" .. relPath .. ".client.lua",
        "include/" .. cleanRel .. ".lua",
        "include/" .. cleanRel .. "/init.lua",
        -- LAYER 1 FIX: Specific @rbxts package probes
        "node_modules/@rbxts/" .. parts[#parts] .. "/src/init.lua",
        "node_modules/@rbxts/" .. parts[#parts] .. "/lib/init.lua",
        "node_modules/@rbxts/" .. parts[#parts] .. "/out/init.lua",
        "node_modules/@rbxts/" .. parts[#parts] .. "/init.lua",
    }

    for _, loc in ipairs(attempts) do
        local ok, content = pcall(remodel.readFile, loc)
        if ok and content and #content > 0 then return content, loc end
    end
    return nil, nil
end

local function stripComments(src)
    local result = src:gsub("%-%-%[%[(.-)%]%]", function(inner)
        return inner:gsub("[^\n]", "")
    end)
    result = result:gsub("%-%-[^\n]*", "")
    return result
end

file:write("local function start()\n")
file:write("    local hInit, hMod, hInst, hEnv = (function()\n")
file:write(remodel.readFile("ci/runtime.lua"))
file:write("\n    end)()\n\n")

local function walk(parent)
    for _, object in ipairs(parent:GetChildren()) do
        local name  = string.format("%q", object.Name)
        local id    = string.format("%q", object:GetFullName())
        local pId   = string.format("%q", parent:GetFullName())
        local class = object.ClassName
        local isScript = (class == "ModuleScript" or class == "LocalScript")
        local isNodeModules = (object.Name == "node_modules")

        -- LAYER 1 FIX: Walk node_modules to register children, but don't readSource the folder itself
        if isScript and not isNodeModules then
            local source, foundAt = readSource(object)
            if source then
                scriptCount = scriptCount + 1
                file:write(string.format("    hMod(%s, %q, %s, %s, function()\n", name, class, id, pId))
                file:write("        return setfenv(function(...)\n" .. stripComments(source) .. "\n        end, hEnv(" .. id .. "))()\n")
                file:write("    end)\n")
            else
                file:write(string.format("    hInst(%s, %q, %s, %s)\n", name, class, id, pId))
            end
        else
            file:write(string.format("    hInst(%s, %q, %s, %s)\n", name, class, id, pId))
        end

        -- LAYER 1 FIX: Always recurse, even into node_modules
        walk(object)
    end
end

file:write(string.format("    hInst(%q, \"Folder\", %q, nil)\n", model.Name, model:GetFullName()))
walk(model)
file:write("\n    hInit()\nend\nstart()\n")
file:close()

print(string.format("[Havoc] Build Complete. Bundled %d scripts.", scriptCount))
