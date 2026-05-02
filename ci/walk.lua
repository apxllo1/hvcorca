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
    -- If root is nil, use game
    if not root then
        root = game
    end

    -- Now root is guaranteed not nil
    local descendants
    pcall(function()
        descendants = root:GetDescendants()
    end)

    if not descendants then
        descendants = {}
    end

    for _, child in ipairs(descendants) do
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
