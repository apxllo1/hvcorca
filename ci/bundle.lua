-- bundle.lua (Remodel Version)
local args = arg or {...} or {}
local input_file = "Havoc.rbxm"
local output_file = "latest.lua"

print("[Havoc] Starting Build...")

local model_data = remodel.readModelFile(input_file)
local model = model_data[1]

local file = io.open(output_file, "w")

-- 1. HEADER (The Engine)
file:write("local function start()\n")
file:write("    local hInit, hMod, hInst, hEnv = (function()\n")
file:write(remodel.readFile("ci/runtime.lua"))
file:write("\n    end)();\n\n")

-- 2. CORE FOLDERS
file:write(string.format("    hInst(%q, \"Folder\", %q, \"ROOT\");\n", model.Name, model:GetFullName()))

-- 3. THE RECURSIVE WALKER (The "No-File-Left-Behind" Loop)
local function walk(parent)
    for _, object in ipairs(parent:GetChildren()) do
        local name = string.format("%q", object.Name)
        local path = string.format("%q", object:GetFullName())
        local pPath = string.format("%q", parent:GetFullName())
        local class = object.ClassName
        
        if class == "ModuleScript" or class == "LocalScript" then
            -- Find the source file
            local parts = {}
            local curr = object
            while curr and curr.Name ~= model.Name do
                table.insert(parts, 1, curr.Name)
                curr = curr.Parent
            end
            local relPath = table.concat(parts, "/")
            
            -- Search locations for the actual code
            local src = nil
            local locs = {"out/"..relPath..".lua", "out/"..relPath.."/init.lua", "include/"..relPath..".lua"}
            for _, loc in ipairs(locs) do
                local ok, content = pcall(remodel.readFile, loc)
                if ok then src = content break end
            end

            if src then
                -- Wrap the code safely
                file:write(string.format("    hMod(%s, %q, %s, %s, function() return (function(...)\n", name, class, path, pPath))
                file:write(src)
                file:write("\n    end) end);\n")
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

-- 4. THE IGNITION
file:write("\n    hInit();\nend\nstart()\n-- BUNDLE_COMPLETE")
file:close()
print("[Havoc] Build Finished. Check " .. output_file)
