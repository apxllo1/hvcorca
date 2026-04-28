local PARAMS = {...}
local function getFlag(f) for _, v in ipairs(PARAMS) do if v == f then return true end end return false end

local OUTPUT_PATH = assert(PARAMS[1], "No output path specified")
local VERSION = assert(PARAMS[2], "No version specified")

local ROJO_INPUT = "Havoc.rbxm"
local RUNTIME_FILE = "ci/runtime.lua"

local function writeModule(object, file)
    local id = object:GetFullName()
    local source = remodel.getRawProperty(object, "Source")
    source = source .. "\n" 

    local path = string.format("%q", id)
    local name = string.format("%q", object.Name)
    local parentStr = (object.Parent and object.Parent.ClassName ~= "DataModel") 
        and string.format("%q", object.Parent:GetFullName()) 
        or "nil"
    
    local className = string.format("%q", object.ClassName)

    file:write(string.format("newModule(%s, %s, %s, %s, function ()\n", name, className, path, parentStr))
    file:write("    return setfenv(function()\n")
    file:write(source)
    file:write("\n    end, newEnv(" .. path .. "))()\nend)\n\n")
end

local function writeInstance(object, file)
    local id = object:GetFullName()
    local path = string.format("%q", id)
    local name = string.format("%q", object.Name)
    local parentStr = (object.Parent and object.Parent.ClassName ~= "DataModel") 
        and string.format("%q", object.Parent:GetFullName()) 
        or "nil"
    
    file:write(string.format("newInstance(%s, %q, %s, %s)\n", name, object.ClassName, path, parentStr))
end

local function walk(root, file)
    local queue = {root}
    while #queue > 0 do
        local object = table.remove(queue, 1)
        
        if object.Parent and object.Parent.ClassName ~= "DataModel" then
            if object.ClassName == "LocalScript" or object.ClassName == "ModuleScript" then
                writeModule(object, file)
            else
                writeInstance(object, file)
            end
        elseif not object.Parent then
            writeInstance(object, file)
        end

        for _, child in ipairs(object:GetChildren()) do
            table.insert(queue, child)
        end
    end
end

local function main()
    local model = remodel.readModelFile(ROJO_INPUT)[1]
    local runtime = remodel.readFile(RUNTIME_FILE)
    runtime = string.gsub(runtime, "__VERSION__", string.format("%q", VERSION))
    
    remodel.createDirAll(string.match(OUTPUT_PATH, "^(.*)[/\\]"))
    local f = io.open(OUTPUT_PATH, "w")
    
    f:write("--[[ Havoc Bundle: " .. VERSION .. " ]]\n\n")
    
    -- Wrap everything in a function to protect scope
    f:write("local function start()\n")
    f:write(runtime .. "\n\n")
    
    -- Write all the instances and modules
    walk(model, f)
    
    -- ENVIRONMENT CAPTURE: Finding the Roblox globals
    f:write("\n    -- Capture the best available environment\n")
    f:write("    local runEnv = (getfenv and getfenv()) or _G or shared\n")
    f:write("    init(runEnv)\n")
    f:write("    print('[Havoc]: Runtime initialized successfully.')\n")
    f:write("end\n\n")
    
    -- Execute with error handling
    f:write("local success, err = pcall(start)\n")
    f:write("if not success then\n")
    f:write("    warn('[Havoc Critical]: Bundle failed to load! Error: ' .. tostring(err))\n")
    f:write("end\n")

    f:close()

    print("[CI] Bundle completed via BFS Stream Write.")
end

main()
