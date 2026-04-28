-- bundle.lua
local args = arg or {...} or {}

-- 1. Argument Extraction
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

-- Register the root container before walking
local rootPath = string.format("%q", model:GetFullName())
file:write(string.format(
    "    hInst(%s, %q, %s, \"ROOT\");\n",
    string.format("%q", model.Name), model.ClassName, rootPath
))

local function walk(parent)
    for _, object in ipairs(parent:GetChildren()) do
        local name = string.format("%q", object.Name)
        local path = string.format("%q", object:GetFullName())
        local parentPath = string.format("%q", parent:GetFullName())
        local class = object.ClassName

        local isScript = (class == "ModuleScript" or class == "LocalScript")

        if isScript then
            local success, source = pcall(function() return object.Source end)

            if not success or source == nil then
                file:close()
                error(string.format(
                    "[BUNDLE ERROR] Source inaccessible for %s (%s). Cannot produce valid bundle.",
                    object:GetFullName(), class
                ))
            end

            source = source:gsub("%]%]", "] ]")
            file:write(string.format("    hMod(%s, %q, %s, %s, function()\n", name, class, path, parentPath))
            file:write("        return (function(...)\n")
            file:write(source)
            file:write("\n        end)\n    end);\n")
        else
            file:write(string.format("    hInst(%s, %q, %s, %s);\n", name, class, path, parentPath))
        end

        walk(object)
    end
end

walk(model)

file:write("\n    hInit();\n")
file:write("end\n\nstart();")
file:close()

print("------------------------------------------")
print("SUCCESS: Final bundle ready in " .. output_file)
print("------------------------------------------")
