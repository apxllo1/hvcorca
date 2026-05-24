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

---Wrap bare `for k,v in EXPR do` loops (Luau generalized iteration) with
---`pairs(EXPR)` so the bundle runs on script-executor VMs that still parse
---Lua 5.1 — those VMs accept the syntax but fail at runtime when they try
---to call the table as an iterator function. Darklua has no rule for this
---(checked against 0.18.0), and roblox-ts emits these loops freely.
---
---EXPR is anything between `in` and the matching top-level ` do`. We track
---paren / bracket / brace depth so we don't terminate on a `do` nested in
---a function literal or string. We then leave EXPR alone if it's already a
---known iterator form — pairs(…), ipairs(…), next, …, string.gmatch(…) —
---and otherwise wrap it.
---
---Handles all the call shapes roblox-ts emits after darklua minifies:
---   for k,v in tbl            do  →  for k,v in pairs(tbl)            do
---   for k,v in tbl.field      do  →  for k,v in pairs(tbl.field)      do
---   for k,v in obj:Method()   do  →  for k,v in pairs(obj:Method())   do
---   for k,v in (expr or alt)  do  →  for k,v in pairs((expr or alt))  do
---@param source string
---@return string
local function addPairsIterators(source)
	local len = #source
	local out = {}
	local cursor = 1

	-- Skip-the-iterator names (followed by `(`, whitespace, or `,` to bind
	-- as the boundary). `next` accepts `next, t` so we also allow `,`.
	local function alreadyIterator(expr)
		expr = expr:gsub("^%s+", "")
		for _, name in ipairs({ "pairs", "ipairs", "next", "string.gmatch", "io.lines" }) do
			if expr == name then return true end
			local nlen = #name
			if expr:sub(1, nlen) == name then
				local after = expr:sub(nlen + 1, nlen + 1)
				if after == "(" or after == " " or after == "\t" or after == "," then
					return true
				end
			end
		end
		return false
	end

	while cursor <= len do
		-- Find next candidate `for` keyword followed by IDS, space, `in`, then
		-- a space, newline, or open-paren (so we tolerate darklua's dense
		-- output where `in(` has no space).
		local fStart, fEnd = source:find("for[ \t\n][ \t\n%w_,]+[ \t\n]in[ \t\n%(]", cursor)
		if not fStart then
			table.insert(out, source:sub(cursor))
			break
		end

		-- Word-boundary check on the left.
		local skipThis = false
		if fStart > 1 then
			local left = source:sub(fStart - 1, fStart - 1)
			if left:match("[%w_]") then
				skipThis = true
			end
		end

		if skipThis then
			table.insert(out, source:sub(cursor, fStart))
			cursor = fStart + 1
		else
			-- Locate the position just past `in` — that's where the in-expr starts.
			local _, inEnd = source:find("[ \t\n]in[ \t\n%(]", fStart)
			local exprStart = inEnd

			-- Walk forward to matching ` do` at depth 0.
			local depth = 0
			local i = exprStart
			local doStart = nil
			while i <= len do
				local ch = source:sub(i, i)
				if ch == "(" or ch == "[" or ch == "{" then
					depth = depth + 1
				elseif ch == ")" or ch == "]" or ch == "}" then
					depth = depth - 1
				elseif ch == "'" or ch == "\"" then
					local q = ch
					i = i + 1
					while i <= len and source:sub(i, i) ~= q do
						if source:sub(i, i) == "\\" then i = i + 1 end
						i = i + 1
					end
				elseif depth == 0 and ch == "d" and source:sub(i + 1, i + 1) == "o" then
					local lc = source:sub(i - 1, i - 1)
					local rc = source:sub(i + 2, i + 2)
					local leftOk = lc == "" or not lc:match("[%w_]")
					local rightOk = rc == "" or not rc:match("[%w_]")
					if leftOk and rightOk then
						doStart = i
						break
					end
				end
				i = i + 1
			end

			if not doStart then
				table.insert(out, source:sub(cursor, fEnd))
				cursor = fEnd + 1
			else
				local rawExpr = source:sub(exprStart, doStart - 1)
				local trimmed = rawExpr:gsub("^%s+", ""):gsub("%s+$", "")
				table.insert(out, source:sub(cursor, exprStart - 1))
				if alreadyIterator(trimmed) then
					table.insert(out, rawExpr)
				else
					local leading = rawExpr:match("^(%s*)") or ""
					local trailing = rawExpr:match("(%s*)$") or ""
					-- Darklua emits dense output like `in(expr)` — no space
					-- after `in`. If we wrap without ensuring a separator we
					-- get `inpairs(...)`, which is one identifier. Force a
					-- single space when no leading whitespace exists.
					if leading == "" then leading = " " end
					table.insert(out, leading .. "pairs(" .. trimmed .. ")" .. trailing)
				end
				cursor = doStart
			end
		end
	end

	return table.concat(out)
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
