local instanceFromId, modules = {}, {}
local runEnv = (getgenv and getgenv()) or (getfenv and getfenv()) or _G or shared
local ROOT_PARENT = "ROOT"

local function resolveParent(parentId)
    if parentId == ROOT_PARENT then
        return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    return instanceFromId[parentId] or error("[Havoc] resolveParent: no instance for " .. tostring(parentId))
end

local hEnv
local TS

TS = {
    import = function(self, s, ...)
        local args = {...}
        local last = s
        for _, v in ipairs(args) do
            last = (type(v) == "string" and last:FindFirstChild(v)) or v
        end
        if modules[last] then
            local m = modules[last]
            if not m.loaded then
                m.loaded = true
                local innerFunc = m.fn()
                setfenv(innerFunc, hEnv(last:GetFullName()))
                local ok, res = pcall(innerFunc)
                if not ok then
                    error("[Havoc] Import failed for " .. tostring(last) .. ": " .. tostring(res))
                end
                m.data = res
            end
            return m.data
        end
        return require(last)
    end,
    getModule = function(self, s, ...) return require(s) end,
}

hEnv = function(id)
    local inst = instanceFromId[id]
    return setmetatable({
        script = inst,
        TS = TS,
        require = function(target)
            if modules[target] then
                return TS:import(target)
            end
            return require(target)
        end,
    }, { __index = runEnv })
end

local function hMod(name, class, id, parentId, fn)
    local inst = Instance.new(class)
    inst.Name = name
    inst.Parent = resolveParent(parentId)
    instanceFromId[id] = inst
    modules[inst] = { fn = fn, loaded = false, data = nil }
end

local function hInst(name, class, id, parentId)
    local inst = Instance.new(class)
    inst.Name = name
    inst.Parent = resolveParent(parentId)
    instanceFromId[id] = inst
end

local function hInit()
    for inst, m in pairs(modules) do
        if inst:IsA("LocalScript") then
            task.spawn(function()
                local fn = m.fn()
                setfenv(fn, hEnv(inst:GetFullName()))
                local ok, err = pcall(fn)
                if not ok then
                    warn("[Havoc] LocalScript error in " .. inst:GetFullName() .. ": " .. tostring(err))
                end
            end)
        end
    end
end

return hInit, hMod, hInst, hEnv
