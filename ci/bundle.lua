-- bundle.lua
local args = arg or {...} or {} -- Supports both Remodel 'arg' and standard Lua '...'

-- Check if a specific argument was passed
local input_file = args[1] or "Havoc.rbxm"
local output_file = args[2] or "latest.lua"

print("Starting bundle for: " .. input_file)

local model = remodel.readModelFile(input_file)[1]
local file = io.open(output_file, "w")

file:write("--[[\n    Havoc Studios Bundler (Richie-Style)\n--]]\n\n")
file:write("local function start()\n")
file:write("    local runEnv = (getfenv and getfenv()) or _G or shared;\n")
file:write("    local hInit, hMod, hInst, hEnv;\n\n")

-- Insert the Runtime Engine here
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
            -- Escape double brackets to prevent syntax errors in the bundle
            source = source:gsub("%]%]", "] ]")
            
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
print("Successfully bundled " .. output_file)
