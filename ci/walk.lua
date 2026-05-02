--[[
    walk.lua – HAVOC v2.0 Module Walker
]]--

local Walk = {}

local function stripModuleHeader(source)
    local _, afterReturn = source:find("^%s*return%s*")
    if afterReturn then
        local _, afterBrace = source:find("^{", afterReturn)
        if afterBrace then
            return source:sub(afterBrace)
        end
    end
    return source
end

local function walkModule(script, output)
    if not script:IsA("ModuleScript") then
        return
    end

    local source = script.Source
    local trimmed = stripModuleHeader(source)

    table.insert(output, ("-- Module: %s\n"):format(script:GetFullName()))
    table.insert(output, trimmed)
    table.insert(output, "\n")
end

local function walkRec(root, output)
    if not root then
        return  -- safely skip if root is nil
    end

    for _, child in ipairs(root:GetDescendants()) do
        walkModule(child, output)
    end
end

function Walk.walk(root)
    local parts = {
        "local modules = {}\n"
    }

    walkRec(root, parts)

    table.insert(parts, "\nreturn function(hInit, hMod, hInst, hEnv)\n")
    table.insert(parts, "    return hInit, hMod, hInst, hEnv\n")
    table.insert(parts, "end\n")

    return table.concat(parts, "\n")
end

return Walk
