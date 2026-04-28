local PARAMS = {...}
local function getFlag(f) for _, v in ipairs(PARAMS) do if v == f then return true end end return false end

local OUTPUT_PATH = assert(PARAMS[1], "No output path specified")
local VERSION = assert(PARAMS[2], "No version specified")
local MINIFY = getFlag("minify")

local ROJO_INPUT = "Havoc.rbxm"
local RUNTIME_FILE = "ci/runtime.lua"

local function writeModule(object, file)
    local id = object:GetFullName()
    local source = remodel.getRawProperty(object, "Source")
    source = source .. "\n" -- Prevent comment bleed

    local path, name = string.format("%q", id), string.format("%q", object.Name)
    local parent = object.Parent and string.format("%q", object.Parent:GetFullName()) or "nil"
    local className = string.format("%q", object.ClassName)

    -- Write directly to file handle to save memory
    file:write(string.format("newModule(%s, %s, %s, %s, function ()\n", name, className, path, parent))
    file:write("return setfenv(function()\n")
    file:write(source)
    file:write("\nend, newEnv(" .. path .. "))()\nend)\n\n")
end

local function writeInstance(object, file)
    local path, name = string.format("%q", object:GetFullName()), string.format("%q", object.Name)
    local parent = object.Parent and string.format("%q", object.Parent:GetFullName()) or "nil"
    file:write(string.format("newInstance(%s, %s, %s, %s)\n", name, string.format("%q", object.ClassName), path, parent))
end

local function walk(object, file)
    if object.ClassName == "LocalScript" or object.ClassName == "ModuleScript" then
        writeModule(object, file)
    else
        writeInstance(object, file)
    end
    for _, child in ipairs(object:GetChildren()) do walk(child, file) end
end

local function main()
    local model = remodel.readModelFile(ROJO_INPUT)[1]
    local runtime = string.gsub(remodel.readFile(RUNTIME_FILE), "__VERSION__", string.format("%q", VERSION))
    
    -- Open file for writing immediately
    remodel.createDirAll(string.match(OUTPUT_PATH, "^(.*)[/\\]"))
    local f = io.open(OUTPUT_PATH, "w")
    
    f:write(runtime .. "\n\n")
    walk(model, f)
    f:write("\ninit()\n")
    f:close()

    print("[CI] Bundle completed via Stream Write.")
end

main()
