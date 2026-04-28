local PARAMS = {...}

local function getFlag(flag)
	for _, v in ipairs(PARAMS) do
		if v == flag then
			return true
		end
	end
	return false
end

local OUTPUT_PATH = assert(PARAMS[1], "No output path specified")
local VERSION = assert(PARAMS[2], "No version specified")
local DEBUG_MODE = getFlag("debug")
local VERBOSE = getFlag("verbose")
local MINIFY = getFlag("minify")

local ROJO_INPUT = "Havoc.rbxm"
local RUNTIME_FILE = "ci/runtime.lua"
local BUNDLE_TEMP = "ci/bundle.tmp"

---Convert some specific snippets to work in luamin.
local function transformInput(source)
	source = string.gsub(source, "([%w_]+)%s*([%+%-%*/%%^%.]%.?)=%s*", "%1 = %1 %2")
	source = string.gsub(source, "(%s+)continue(%s+)", "%1__CONTINUE__()%2")
	return source
end

local function transformOutput(source)
	source = string.gsub(source, "%.%.%.:", "(...):")
	source = string.gsub(source, "__CONTINUE__%(%)", "continue;")
	return source
end

local function minify(source)
	remodel.writeFile(BUNDLE_TEMP, transformInput(source))
	os.execute("node ci/minify.js")
	local output = remodel.readFile(BUNDLE_TEMP)
	os.remove(BUNDLE_TEMP)
	return transformOutput(output)
end

local function writeModule(object, output)
	local id = object:GetFullName()
	local source = remodel.getRawProperty(object, "Source")
	
	-- CLEANUP: Ensure source doesn't have a trailing comment that eats the 'end'
	source = source .. "\n"

	local path = string.format("%q", id)
	local parent = object.Parent and string.format("%q", object.Parent:GetFullName()) or "nil"
	local name = string.format("%q", object.Name)
	local className = string.format("%q", object.ClassName)

	if DEBUG_MODE then
		local def = "newModule(" .. name .. ", " .. className .. ", " .. path .. ", " .. parent .. ", function ()\n" ..
			"local fn = assert(loadstring(" .. string.format("%q", source) .. ", '@'.." .. path .. "))\n" ..
			"setfenv(fn, newEnv(" .. path .. "))\n" ..
			"return fn()\n" ..
			"end)\n"
		table.insert(output, def)
	else
		-- WRAP: Using a more robust wrapper for compiled TS code
		local def = "newModule(" .. name .. ", " .. className .. ", " .. path .. ", " .. parent .. ", function ()\n" ..
			"return setfenv(function()\n" ..
			source .. "\n" ..
			"end, newEnv(" .. path .. "))()\n" ..
			"end)\n"
		table.insert(output, def)
	end
end

local function writeInstance(object, output)
	local id = object:GetFullName()
	local path = string.format("%q", id)
	local parent = object.Parent and string.format("%q", object.Parent:GetFullName()) or "nil"
	local name = string.format("%q", object.Name)
	local className = string.format("%q", object.ClassName)

	local def = "newInstance(" .. name .. ", " .. className .. ", " .. path .. ", " .. parent .. ")\n"
	table.insert(output, def)
end

local function writeInstanceTree(object, output)
	if object.ClassName == "LocalScript" or object.ClassName == "ModuleScript" then
		writeModule(object, output)
	else
		writeInstance(object, output)
	end

	for _, child in ipairs(object:GetChildren()) do
		writeInstanceTree(child, output)
	end
end

local function main()
	local output = {}
	local success, model = pcall(function() return remodel.readModelFile(ROJO_INPUT)[1] end)
	
	if not success or not model then
		error("Failed to read " .. ROJO_INPUT .. ". Make sure Rojo build finished first!")
	end

	writeInstanceTree(model, output)

	local runtime = string.gsub(remodel.readFile(RUNTIME_FILE), "__VERSION__", string.format("%q", VERSION))
	
	-- Join modules with massive separation to prevent "Merging" errors
	local final_source = table.concat(output, "\n\n")

	if MINIFY then
		final_source = minify(final_source)
	end

	local result = {
		runtime,
		final_source,
		"\ninit()\n" -- Ensure init() is on its own clean line
	}

	if VERBOSE then
		table.insert(result, 2, "local START_TIME = os.clock()")
		table.insert(result, "print(\"[CI \" .. " .. string.format("%q", VERSION) .. " .. \"] Havoc run in \" .. (os.clock() - START_TIME) * 1000 .. \" ms\")")
	end

	remodel.createDirAll(string.match(OUTPUT_PATH, "^(.*)[/\\]"))
	
	-- FINAL CONCAT: The big one
	local bundle_data = table.concat(result, "\n\n")
	
	remodel.writeFile(OUTPUT_PATH, bundle_data)

	print("[CI " .. VERSION .. "] Bundle written: " .. #bundle_data .. " bytes to " .. OUTPUT_PATH)
end

main()
