local model = remodel.readModelFile("Havoc.rbxm")
local root = model[1]

local checked = 0
local hasSource = 0
local noSource = 0

local function walk(obj)
    local class = obj.ClassName
    if class == "ModuleScript" or class == "LocalScript" then
        checked = checked + 1
        local ok, src = pcall(function() return obj.Source end)
        if ok and src and src ~= "" then
            hasSource = hasSource + 1
            if checked <= 3 then
                print("[HAS SOURCE] " .. obj:GetFullName() .. " (" .. #src .. " chars)")
            end
        else
            noSource = noSource + 1
            if noSource <= 5 then
                print("[NO SOURCE] " .. obj:GetFullName() .. " ok=" .. tostring(ok) .. " src=" .. tostring(src))
            end
        end
    end
    for _, child in ipairs(obj:GetChildren()) do
        walk(child)
    end
end

walk(root)
print("Total scripts: " .. checked)
print("Has source: " .. hasSource)
print("No source: " .. noSource)
