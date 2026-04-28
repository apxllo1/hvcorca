-- bundle.lua
local args = arg or {...} or {}

-- 1. Argument Extraction with Safety Swapping
local raw_arg1 = args[1]
local raw_arg2 = args[2]

local input_file, output_file

-- Scans all arguments to find the right files regardless of order
for _, v in ipairs(args) do
    if v:find("%.rbxm$") then
        input_file = v
    elseif v:find("%.lua$") then
        output_file = v
    end
end

-- Fallbacks if the CLI doesn't provide them clearly
input_file = input_file or "Havoc.rbxm"
output_file = output_file or "latest.lua"

-- 2. Final validation before reading
if not input_file or not input_file:find("%.rbxm$") then
    error("\n[BUNDLE ERROR] Could not find a valid .rbxm input file.\n" ..
          "Received: " .. tostring(input_file) .. "\n" ..
          "Ensure your command is: remodel run ci/bundle.lua Havoc.rbxm latest.lua")
end

print("------------------------------------------")
print("READING MODEL: " .. input_file)
print("WRITING SCRIPT: " .. output_file)
print("------------------------------------------")

-- 3. The logic
local model_data = remodel.readModelFile(input_file)
if not model_data or #model_data == 0 then
    error("The model file " .. input_file .. " is empty or invalid.")
end

local model = model_data[1]
local file, err = io.open(output_file, "w")

if not file then
    error("Could not open output file: " .. tostring(err))
end

file:write("--[[\n    Havoc Studios Bundler (Richie-Style)\n--]]\n\n")
file:write("local function start()\n")
file:write("    local runEnv = (getfenv and getfenv()) or _G or shared;\n")
file:write("    local hInit, hMod, hInst, hEnv;\n\n")

-- Insert the Runtime Engine
local runtime = remodel.readFile("ci/runtime.lua")
file:write("    hInit, hMod, hInst, hEnv = (function()\n")
file:write(runtime)
file:write("\n    end)();\n\n")

-- Recursive function to pack instances
local function walk(parent)
    for _, object in ipairs(parent:GetChildren()) do
        local name = string.format("%q", object.Name)
        local path = string.format("%q", object:GetFullName())
        local parentPath = string.format("%q", parent:GetFullName())
        
        -- FIX: Use remodel.isA instead of object:IsA
        if remodel.isA(object, "LuaSourceContainer") then
            local source = object.Source
            -- Escape double brackets to prevent syntax errors in the final bundle
            source = source:gsub("%]%]", "] ]")
            
            file:write(string.format("    hMod(%s, %q, %s, %s, function()\n", name, object.ClassName, path, parentPath))
            file:write("        return (function(...)\n")
            file:write(source)
            file:write("\n        end)\n    end);\n")
        else
            file:write(string.format("    hInst(%s, %q, %s, %s);\n", name, object.ClassName, path, parentPath))
        end
        
        -- Recurse into children
        walk(object)
    end
end

-- Start the walk from the root model
walk(model)

file:write("\n    hInit();\n")
file:write("end\n\nstart();")
file:close()

print("------------------------------------------")
print("SUCCESS: Final bundle ready in " .. output_file)
print("------------------------------------------")
