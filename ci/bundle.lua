local args = arg or {...} or {}
local input_file = args[1] or "Havoc.rbxm"
local output_file = args[2] or "latest.lua"

print("------------------------------------------")
print("[Havoc] Build System Initialized")
print("[Havoc] Input: " .. input_file)

local model_data = remodel.readModelFile(input_file)
if not model_data or #model_data == 0 then error("Model file invalid") end
local model = model_data[1]

local file = io.open(output_file, "w")
local scriptCount = 0

-- Path Resolver: Ensures script.Parent works in TS
local function getRelParts(inst)
    local parts = {}
    local curr = inst
    while curr and curr.Name ~= model.Name do
        table.insert(parts, 1, curr.Name)
        curr = curr.Parent
    end
    return parts
end

-- Source Finder: Maps Roblox Instances to your PC files
local function readSource(inst)
    local parts = getRelParts(inst)
    local relPath = table.concat(parts, "/")
    local attempts = {
        "out/" .. relPath .. ".lua",
        "out/" .. relPath .. "/init.lua",
        "out/" .. relPath .. ".client.lua",
        "include/" .. (relPath:match("^include/(.+)$") or relPath) .. ".lua",
        "node_modules/@rbxts/" .. (relPath:gsub("^include/node_modules/", "")) .. ".lua",
        "node_modules/@rbxts/" .. (relPath:gsub("^include/node_modules/", "")) .. "/init.lua",
    }
    for _, loc in ipairs(attempts) do
        local ok, content = pcall(remodel.readFile, loc)
        if ok and content then return content end
    end
    return nil
end

-- Start Output
file:write("local function start()\n    local hInit, hMod, hInst, hEnv = (function()\n")
file:write(remodel.readFile("ci/runtime.lua"))
file:write("\n    end)()\n\n")

local function walk(parent)
    for _, object in ipairs(parent:GetChildren()) do
        local name = string.format("%q", object.Name)
        local id = string.format("%q", object:GetFullName())
        local pId = string.format("%q", parent:GetFullName())
        local class = object.ClassName

        local isScript = (class == "ModuleScript" or class == "LocalScript")
        local isNodeModules = (object.Name == "node_modules")
        local source = nil

        if isScript and not isNodeModules then
            source = readSource(object)
        end

        if source then
            scriptCount = scriptCount + 1
            -- Clean comments to prevent injection syntax errors
            local cleanSrc = source:gsub("%-%-%[%[[%s%S]- %]%]", ""):gsub("%-%-[^\n]*", "")
            file:write("    hMod("..name..", "..string.format("%q", class)..", "..id..", "..pId..", function()\n")
            file:write("        return setfenv(function(...)\n" .. cleanSrc .. "\n        end, hEnv(" .. id .. "))()\n")
            file:write("    end)\n")
        else
            file:write(string.format("    hInst(%s, %q, %s, %s)\n", name, class, id, pId))
        end

        if not isNodeModules then
            walk(object)
        end
    end
end

file:write(string.format("    hInst(%q, \"Folder\", %q, nil)\n", model.Name, model:GetFullName()))
walk(model)
file:write("\n    hInit()\nend\nstart()")
file:close()
print("[Havoc] Build Complete. Bundled " .. scriptCount .. " scripts.")
print("------------------------------------------")
