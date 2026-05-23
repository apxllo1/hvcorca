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

local ROJO_INPUT = "hvcorca.rbxm"
local RUNTIME_FILE = "ci/runtime.lua"
local BUNDLE_TEMP = "ci/bundle.tmp"
local DARKLUA_CONFIG = "ci/darklua.json"

---Wrap bare `for k,v in tbl do` loops (Luau generalized iteration) with
---`pairs(tbl)` so the bundle runs on script-executor VMs that still parse
---Lua 5.1 — those VMs accept the syntax but fail at runtime when they try
---to call the table as an iterator function. Darklua has no rule for this
---(checked against 0.18.0), and roblox-ts emits these loops freely.
---
---Only matches when the in-expression is a single identifier or dotted
---path — anything with parens, commas, or method-call colons is already a
---valid Lua-5.1 iterator (pairs(x), ipairs(x), next, t, foo:iter(), …) so
---we leave it alone.
---@param source string
---@return string
local function addPairsIterators(source)
	return (source:gsub("(for [%w_,]+ in )([%w_][%w_%.]*)( do)", function(prefix, expr, suffix)
		-- Defensive: skip the four built-in iterator names. The pattern can't
		-- match `pairs(x)` (parens) but `pairs` alone (as a function value)
		-- would mis-wrap to `pairs(pairs)`.
		if expr == "pairs" or expr == "ipairs" or expr == "next" then
			return prefix .. expr .. suffix
		end
		return prefix .. "pairs(" .. expr .. ")" .. suffix
	end))
end

---Minify the given Luau source by passing it through darklua. Darklua
---natively understands Luau-specific syntax (inline if-then-else, backtick
---template strings, continue, +=), so the bundle no longer needs the
---bespoke regex-based transforms that luamin required.
---
---After minification, run `addPairsIterators` to fix the one Luau feature
---darklua doesn't normalize — generic-for loops without an explicit
---iterator function.
---@param source string
---@return string
local function minify(source)
	remodel.writeFile(BUNDLE_TEMP, source)
	local ok = os.execute("darklua process " .. BUNDLE_TEMP .. " " .. BUNDLE_TEMP .. " --config " .. DARKLUA_CONFIG)
	if not ok then
		print("[Hvcorca " .. VERSION .. "] darklua failed — falling back to unminified output")
		os.remove(BUNDLE_TEMP)
		return source
	end
	local output = remodel.readFile(BUNDLE_TEMP)
	os.remove(BUNDLE_TEMP)
	return addPairsIterators(output)
end

---@param object LocalScript | ModuleScript
---@param output table<number, string>
local function writeModule(object, output)
	local id = object:GetFullName()
	local source = remodel.getRawProperty(object, "Source")

	local path = string.format("%q", id)
	local parent = object.Parent and string.format("%q", object.Parent:GetFullName()) or "nil"
	local name = string.format("%q", object.Name)
	local className = string.format("%q", object.ClassName)

	if DEBUG_MODE then
		local def = table.concat({
			"newModule(" .. name .. ", " .. className .. ", " .. path .. ", " .. parent .. ", function ()",
			"local fn = assert(loadstring(" .. string.format("%q", source) .. ", '@'.." .. path .. "))",
			"setfenv(fn, newEnv(" .. path .. "))",
			"return fn()",
			"end)",
		}, " ")
		table.insert(output, def)
	else
		local def = table.concat({
			"newModule(" .. name .. ", " .. className .. ", " .. path .. ", " .. parent .. ", function ()",
			"return setfenv(function()",
			source,
			"end, newEnv(" .. path .. "))()",
			"end)",
		}, " ")
		table.insert(output, def)
	end
end

---@param object Instance
---@param output table<number, string>
local function writeInstance(object, output)
	local id = object:GetFullName()

	local path = string.format("%q", id)
	local parent = object.Parent and string.format("%q", object.Parent:GetFullName()) or "nil"
	local name = string.format("%q", object.Name)
	local className = string.format("%q", object.ClassName)

	local def = table.concat({
		"newInstance(" .. name .. ", " .. className .. ", " .. path .. ", " .. parent .. ")",
	}, "\n")
	table.insert(output, def)
end

---@param object LocalScript | ModuleScript
---@param output table<number, string>
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
	local model = remodel.readModelFile(ROJO_INPUT)[1]

	-- Add instances
	writeInstanceTree(model, output)

	-- Core runtime
	local runtime = string.gsub(remodel.readFile(RUNTIME_FILE), "__VERSION__", string.format("%q", VERSION))
	table.insert(output, 1, runtime)
	table.insert(output, "hInit()")

	if VERBOSE then
		table.insert(output, 2, "local START_TIME = os.clock()")
		table.insert(output, "print(\"[Hvcorca " .. VERSION .. "] Loaded in \" .. (os.clock() - START_TIME) * 1000 .. \" ms\")")
	end

	local source = table.concat(output, "\n\n")

	-- Minify the assembled bundle as a single unit so darklua can rename
	-- locals consistently and drop dead branches across the whole tree.
	-- For the unminified path (debug bundle), still run addPairsIterators
	-- so executor VMs that can't iterate tables directly don't blow up at
	-- runtime inside loadstring'd module bodies.
	if MINIFY then
		source = minify(source)
	else
		source = addPairsIterators(source)
	end

	-- Write to file
	local dir = string.match(OUTPUT_PATH, "^(.*)[/\\]") or "."
	remodel.createDirAll(dir)
	remodel.writeFile(OUTPUT_PATH, source)

	print("[Hvcorca " .. VERSION .. "] Bundle written to " .. OUTPUT_PATH)
end

main()
