-- bundle.lua (Remodel Script)
local args = arg or {...} or {}
local input_file = "Havoc.rbxm"
local output_file = "latest.lua"

local model_data = remodel.readModelFile(input_file)
local model = model_data[1]

local file = io.open(output_file, "w")

-- HEADER
file:write("--[[ Havoc Studios Automated Bundle ]]\n")
file:write("local function start()\n")
file:write("    local hInit, hMod, hInst, hEnv = (function()\n")
file:write(remodel.readFile("ci/runtime.lua"))
file:write("\n    end)();\n\n")

-- FOUNDATION
file:write(string.format("    hInst(%q, \"Folder\", %q, \"ROOT\");\n", model.Name, model:GetFullName()))
file:write(string.format("    hInst(\"include\", \"Folder\", %q, %q);\n", model.Name .. ".include", model.Name))

local function walk(parent)
    for _, object in ipairs(parent:GetChildren()) do
        local name, path, pPath = string.format("%q", object.Name), string.format("%q", object:GetFullName()), string.format("%q", parent:GetFullName())
        
        if object:IsA("LuaSourceContainer") then
            -- Note: We no longer escape ]] here; the minifier will strip comments safely.
            local source = readSource(object) 
            if source then
                file:write(string.format("    hMod(%s, %q, %s, %s, function() return (function(...)\n%s\nend) end);\n", name, object.ClassName, path, pPath, source))
            end
        else
            file:write(string.format("    hInst(%s, %q, %s, %s);\n", name, object.ClassName, path, pPath))
        end
        walk(object)
    end
end

walk(model)

-- FOOTER (The "Ignition" sequence)
file:write("\n    hInit();\nend\n\nstart()\n-- BUNDLE_COMPLETE")
file:close()
