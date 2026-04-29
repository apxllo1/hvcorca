-- bundle.lua (Remodel Script)
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

-- HEADER
file:write("--[[\n    Havoc Studios Bundler (Automated)\n--]]\n\n")
file:write("local function start()\n")
file:write("    local runEnv = (getgenv and getgenv()) or (getfenv and getfenv()) or _G or shared;\n")
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

-- Register include folder explicitly
file:write(string.format(
    "    hInst(\"include\", \"Folder\", %q, %q);\n",
    model.Name .. ".include", model.Name
))

local function instanceToPath(inst)
    local parts = {}
    local current = inst
    -- Remodel comparison: check name or reference
    while current and current.Name ~= model.Name do
        table.insert(parts, 1, current.Name)
        current = current.Parent
    end
    return parts
end

local function readSource(inst)
    local parts = instanceToPath(inst)
    local pathStr = table.concat(parts, "/")

    local attempts = {
        "out/" .. pathStr .. ".lua",
        "out/" .. pathStr .. "/init.lua",
        "out/" .. pathStr .. ".client.lua",
        "include/" .. pathStr:gsub("^include/", "") .. ".lua",
        "include/" .. pathStr:gsub("^include/", "") .. "/init.lua",
        "node_modules/@rbxts/" .. pathStr:gsub("^include/node_modules/", "") .. ".lua",
        "node_modules/@rbxts/" .. pathStr:gsub("^include/node_modules/", "") .. "/init.lua"
    }

    for _, path in ipairs(attempts) do
        local ok, content = pcall(remodel.readFile, path)
        if ok and content then return content end
    end
    return nil
end

local function walk(parent)
    for _, object in ipairs(parent:GetChildren()) do
        local name       = string.format("%q", object.Name)
        local path       = string.format("%q", object:GetFullName())
        local parentPath = string.format("%q", parent:GetFullName())
        local class      = object.ClassName
        
        -- REMODEL FIX: Use ClassName check instead of IsA
        local isScript   = (class == "ModuleScript" or class == "LocalScript")

        if isScript then
            local source = readSource(object)
            if source and source ~= "" then
                -- Write as Module
                file:write(string.format("    hMod(%s, %q, %s, %s, function()\n", name, class, path, parentPath))
                file:write("        return (function(...)\n")
                file:write(source)
                file:write("\n        end)\n    end);\n")
            else
                -- Fallback to Instance if no file found
                file:write(string.format("    hInst(%s, %q, %s, %s);\n", name, class, path, parentPath))
            end
        else
            -- Regular Folder/Instance
            file:write(string.format("    hInst(%s, %q, %s, %s);\n", name, class, path, parentPath))
        end
        walk(object)
    end
end

walk(model)

file:write("\n    hInit();\n")
file:write("end\n\nstart()\n-- BUNDLE_COMPLETE")
file:close()

print("------------------------------------------")
print("SUCCESS: Final bundle ready in " .. output_file)
print("------------------------------------------")
