-- bundle.lua (Final Master Version)
local args = arg or {...} or {}

-- 1. Grab paths from the command line arguments
local input_file = args[1] or "Havoc.rbxm"
local output_file = args[2] or "latest.lua"

print("------------------------------------------")
print("[Havoc] TARGET: " .. output_file)

local model_data = remodel.readModelFile(input_file)
local model = model_data[1]
local file = io.open(output_file, "w")

local scriptCount = 0

-- 2. HEADER
file:write("--[[\n    Havoc Studios Automated Bundle\n    Target: " .. output_file .. "\n--]]\n\n")
file:write("local function start()\n")
file:write("    local hInit, hMod, hInst, hEnv = (function()\n")
file:write(remodel.readFile("ci/runtime.lua"))
file:write("\n    end)();\n\n")

-- 3. WALKER
local function walk(parent)
    for _, object in ipairs(parent:GetChildren()) do
        local name = string.format("%q", object.Name)
        local path = string.format("%q", object:GetFullName())
        local pPath = string.format("%q", parent:GetFullName())
        local class = object.ClassName
        
        if class == "ModuleScript" or class == "LocalScript" then
            -- Get relative path for file searching
            local parts = {}
            local curr = object
            while curr and curr.Name ~= model.Name do
                table.insert(parts, 1, curr.Name)
                curr = curr.Parent
            end
            local relPath = table.concat(parts, "/")
            
            -- Search logic
            local src = nil
            local attempts = {
                "out/" .. relPath .. ".lua",
                "out/" .. relPath .. "/init.lua",
                "include/" .. relPath .. ".lua",
                "node_modules/@rbxts/" .. relPath:gsub("^include/node_modules/", "") .. "/init.lua"
            }
            
            for _, loc in ipairs(attempts) do
                local ok, content = pcall(remodel.readFile, loc)
                if ok then src = content break end
            end

            if src then
                scriptCount = scriptCount + 1
                file:write(string.format("    hMod(%s, %q, %s, %s, function() return (function(...)\n%s\nend) end);\n", name, class, path, pPath, src))
            else
                file:write(string.format("    hInst(%s, %q, %s, %s);\n", name, class, path, pPath))
            end
        else
            file:write(string.format("    hInst(%s, %q, %s, %s);\n", name, class, path, pPath))
        end
        walk(object)
    end
end

walk(model)

-- 4. FOOTER
file:write("\n    hInit();\nend\n\nstart()\n-- BUNDLE_COMPLETE")
file:close()

print("[Havoc] SUCCESS: Bundled " .. scriptCount .. " scripts into " .. output_file)
print("------------------------------------------")
