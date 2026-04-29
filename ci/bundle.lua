-- bundle.lua
local args = arg or {...} or {}

local input_file, output_file
for _, v in ipairs(args) do
    if v:find("%.rbxm$") then
        input_file = v
    elseif v:find("%.lua$") then
        output_file = v
    end
end
input_file = input_file or "Havoc.rbxm"
output_file = output_file or "latest.lua"

print("------------------------------------------")
print("READING MODEL: " .. input_file)
print("WRITING SCRIPT: " .. output_file)
print("------------------------------------------")

local model_data = remodel.readModelFile(input_file)
if not model_data or #model_data == 0 then
    error("The model file " .. input_file .. " is empty or invalid.")
end
local model = model_data[1]

local file, err = io.open(output_file, "w")
if not file then error("Could not open output file: " .. tostring(err)) end

file:write("--[[\n    Havoc Studios Bundler (Richie-Style)\n--]]\n\n")
file:write("local function start()\n")
file:write("    local runEnv = (getfenv and getfenv()) or _G or shared;\n")
file:write("    local hInit, hMod, hInst, hEnv;\n\n")

local runtime = remodel.readFile("ci/runtime.lua")
file:write("    hInit, hMod, hInst, hEnv = (function()\n")
file:write(runtime)
file:write("\n    end)();\n\n")

-- Register root folder
local rootPath = string.format("%q", model:GetFullName())
file:write(string.format(
    "    hInst(%s, \"Folder\", %s, \"ROOT\");\n",
    string.format("%q", model.Name), rootPath
))

-- Register include folder explicitly so RuntimeLib can be parented correctly
file:write(string.format(
    "    hInst(\"include\", \"Folder\", %q, %q);\n",
    model.Name .. ".include", model.Name
))

local SKIP_NAMES = { include = true, node_modules = true }

local function instanceToPath(inst)
    local parts = {}
    local current = inst
    while current and current ~= model do
        table.insert(parts, 1, current.Name)
        current = current.Parent
    end
    return parts
end

local function readSource(inst)
    local parts = instanceToPath(inst)
    local fullPath = table.concat(parts, "/")

    -- Check out/ first
    local base = "out/" .. fullPath
    local ok, src = pcall(remodel.readFile, base .. ".lua")
    if ok and src then return src end
    local ok2, src2 = pcall(remodel.readFile, base .. "/init.lua")
    if ok2 and src2 then return src2 end
    local ok3, src3 = pcall(remodel.readFile, base .. ".client.lua")
    if ok3 and src3 then return src3 end

    -- Check node_modules/@rbxts for include/node_modules packages
    local stripped = fullPath:match("^include/node_modules/(.+)$")
    if stripped then
        local nmBase = "node_modules/@rbxts/" .. stripped
        local ok4, src4 = pcall(remodel.readFile, nmBase .. ".lua")
        if ok4 and src4 then return src4 end
        local ok5, src5 = pcall(remodel.readFile, nmBase .. "/init.lua")
        if ok5 and src5 then return src5 end
    end

    -- Check include/ directly for Promise and RuntimeLib
    local includePath = fullPath:match("^include/(.+)$")
    if includePath then
        local ok6, src6 = pcall(remodel.readFile, "include/" .. includePath .. ".lua")
        if ok6 and src6 then return src6 end
        local ok7, src7 = pcall(remodel.readFile, "include/" .. includePath .. "/init.lua")
        if ok7 and src7 then return src7 end
    end

    return nil
end

local function walk(parent)
    for _, object in ipairs(parent:GetChildren()) do
        local name       = string.format("%q", object.Name)
        local path       = string.format("%q", object:GetFullName())
        local parentPath = string.format("%q", parent:GetFullName())
        local class      = object.ClassName
        local isScript   = (class == "ModuleScript" or class == "LocalScript")

        if SKIP_NAMES[object.Name] then
            file:write(string.format("    hInst(%s, %q, %s, %s);\n", name, class, path, parentPath))
            walk(object)
        elseif isScript then
            local source = readSource(object)
            if not source or source == "" then
                print(string.format("[WARN] No source file found for %s (%s)", object:GetFullName(), class))
                file:write(string.format("    hInst(%s, %q, %s, %s);\n", name, class, path, parentPath))
            else
                source = source:gsub("%]%]", "] ]")
                file:write(string.format("    hMod(%s, %q, %s, %s, function()\n", name, class, path, parentPath))
                file:write("        return (function(...)\n")
                file:write(source)
                file:write("\n        end)\n    end);\n")
            end
            walk(object)
        else
            file:write(string.format("    hInst(%s, %q, %s, %s);\n", name, class, path, parentPath))
            walk(object)
        end
    end
end

walk(model)

file:write("\n    hInit();\n")
file:write("end\n\nstart()")
file:close()

print("------------------------------------------")
print("SUCCESS: Final bundle ready in " .. output_file)
print("------------------------------------------")
