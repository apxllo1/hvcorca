-- bundle.lua
local args = arg or {...} or {}

-- 1. Argument Extraction with Safety Swapping
local raw_arg1 = args[1]
local raw_arg2 = args[2]

local input_file, output_file

-- If the user swapped the order (put .lua first), we fix it for them
if raw_arg1 and raw_arg1:find("%.lua$") then
    input_file = raw_arg2
    output_file = raw_arg1
else
    input_file = raw_arg1 or "Havoc.rbxm"
    output_file = raw_arg2 or "latest.lua"
end

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
local file = io.open(output_file, "w")

file:write("--[[\n    Havoc Studios Bundler (Richie-Style)\n--]]\n\n")
file:write("local function start()\n")
file:write("    local runEnv = (getfenv and getfenv()) or _G or shared;\n")
file:write("    local hInit, hMod, hInst, hEnv;\n\n")

-- Insert the Runtime Engine
local runtime = remodel.readFile("ci/runtime.lua")
file:write("    hInit, hMod, hInst, hEnv = (function()\n")
file:write(runtime)
file:write("\n    end)();\n\n")

local function walk(parent)
    for _, object in ipairs(parent:GetChildren()) do
        local name = string.format("%q", object.Name)
        local path = string.format("%q", object:GetFullName())
        local parentPath = string.format("%q", parent:GetFullName())
        
        if object:IsA("LuaSourceContainer") then
            local source = object.Source
            source = source:gsub("%]%]", "] ]") -- Prevent double bracket syntax break
            
            file:write(string.format("    hMod(%s, %q, %s, %s, function()\n", name, object.ClassName, path, parentPath))
            file:write("        return (function(...)\n")
            file:write(source)
            file:write("\n        end)\n    end);\n")
        else
            file:write(string.format("    hInst(%s, %q, %s, %s);\n", name, object.ClassName, path, parentPath))
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
