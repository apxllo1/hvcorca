local args = arg or {...} or {}
local input_file = args[1] or "Havoc.rbxm"
local output_file = args[2] or "latest.lua"

local model_data = remodel.readModelFile(input_file)
local model = model_data[1]
local file = io.open(output_file, "w")

local function getRelParts(inst)
    local parts = {}
    local curr = inst
    while curr and curr.Name ~= model.Name do
        table.insert(parts, 1, curr.Name)
        curr = curr.Parent
    end
    return parts
end

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

file:write("local function start()\n    local hInit, hMod, hInst, hEnv = (function()\n")
file:write(remodel.readFile("ci/runtime.lua"))
file:write("\n    end)()\n\n")

local function walk(parent)
    for _, object in ipairs(parent:GetChildren()) do
        local name = string.format("%q", object.Name)
        local id = string.format("%q", object:GetFullName())
        local pId = string.format("%q", parent:GetFullName())
        
        if (object:IsA("ModuleScript") or object:IsA("LocalScript")) and object.Name ~= "node_modules" then
            local src = readSource(object)
            if src then
                src = src:gsub("%-%-%[%[[%s%S]- %]%]", ""):gsub("%-%-[^\n]*", "")
                file:write("    hMod("..name..", "..string.format("%q", object.ClassName)..", "..id..", "..pId..", function()\n")
                file:write("        return setfenv(function(...)\n" .. src .. "\n        end, hEnv(" .. id .. "))()\n")
                file:write("    end)\n")
            else
                file:write(string.format("    hInst(%s, %q, %s, %s)\n", name, object.ClassName, id, pId))
            end
        else
            file:write(string.format("    hInst(%s, %q, %s, %s)\n", name, object.ClassName, id, pId))
        end
        if object.Name ~= "node_modules" then walk(object) end
    end
end

file:write(string.format("    hInst(%q, \"Folder\", %q, nil)\n", model.Name, model:GetFullName()))
walk(model)
file:write("\n    hInit()\nend\nstart()")
file:close()
