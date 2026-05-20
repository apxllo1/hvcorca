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

---Find the first `if` keyword in `line` starting at `from` that begins an
---inline if-then-else expression (preceded by whitespace and a token in
---`= ( , { return`). Returns the start index of `if`, the prefix string,
---and the index right after `if `. Returns nil if none found.
local function findInlineIfStart(line, from)
	local i = from or 1
	local len = #line
	while i <= len do
		local s, e = line:find("if[ \t]+", i)
		if not s then return nil end
		-- Scan backward to find prefix token (skipping whitespace).
		local j = s - 1
		while j >= 1 and (line:sub(j, j) == " " or line:sub(j, j) == "\t") do
			j = j - 1
		end
		local prevCh = j >= 1 and line:sub(j, j) or ""
		local isReturn = (j >= 6 and line:sub(j - 5, j) == "return" and (j == 6 or line:sub(j - 6, j - 6):match("[^%w_]")))
		if prevCh == "=" or prevCh == "(" or prevCh == "," or prevCh == "{" or prevCh == "[" or isReturn then
			return s, e
		end
		i = e + 1
	end
	return nil
end

---Find matching expression terminator on `line` starting at `from`.
---Tracks (), [], {} nesting and string quotes. Returns the index of the
---terminator char (a `,`, `)`, `]`, `}`, or end-of-line in the outer scope).
local function findExprEnd(line, from)
	local depthP, depthB, depthC = 0, 0, 0
	local i = from
	local len = #line
	while i <= len do
		local c = line:sub(i, i)
		if c == '"' or c == "'" then
			local q = c
			i = i + 1
			while i <= len and line:sub(i, i) ~= q do
				if line:sub(i, i) == "\\" then i = i + 1 end
				i = i + 1
			end
		elseif c == "(" then
			depthP = depthP + 1
		elseif c == "[" then
			depthB = depthB + 1
		elseif c == "{" then
			depthC = depthC + 1
		elseif c == ")" then
			if depthP == 0 then return i end
			depthP = depthP - 1
		elseif c == "]" then
			if depthB == 0 then return i end
			depthB = depthB - 1
		elseif c == "}" then
			if depthC == 0 then return i end
			depthC = depthC - 1
		elseif c == "," or c == ";" or c == "\n" then
			if depthP == 0 and depthB == 0 and depthC == 0 then return i end
		end
		i = i + 1
	end
	return len + 1
end

---Find the matching `then`, `else`, or `elseif` keyword (depth-aware for
---nested ifs).
local function findKeyword(line, from, kw)
	local i = from
	local depth = 0
	local len = #line
	local pattern = "([%w_]+)"
	while i <= len do
		local c = line:sub(i, i)
		if c == '"' or c == "'" then
			local q = c
			i = i + 1
			while i <= len and line:sub(i, i) ~= q do
				if line:sub(i, i) == "\\" then i = i + 1 end
				i = i + 1
			end
			i = i + 1
		else
			local s, e, word = line:find(pattern, i)
			if not s then return nil end
			if s == i then
				-- Boundary checked: word starts here.
				local left = i > 1 and line:sub(i - 1, i - 1) or " "
				if not left:match("[%w_]") then
					if word == "if" or word == "function" or word == "do" or word == "for" or word == "while" or word == "repeat" then
						depth = depth + 1
					elseif word == "end" or word == "until" then
						if depth == 0 then return nil end
						depth = depth - 1
					elseif depth == 0 and word == kw then
						return s, e
					end
				end
				i = e + 1
			else
				i = i + 1
			end
		end
	end
	return nil
end

---Transform Luau inline if-then-else expressions into Lua-compatible IIFEs.
---roblox-ts emits these; luamin's parser does not support them.
---@param source string
---@return string
local function transformInlineIfs(source)
	local changed = true
	while changed do
		changed = false
		local ifStart, afterIf = findInlineIfStart(source, 1)
		if ifStart then
			local thenStart, thenEnd = findKeyword(source, afterIf + 1, "then")
			if thenStart then
				local cond = source:sub(afterIf + 1, thenStart - 1):match("^%s*(.-)%s*$")
				local branches = { { cond = cond } }
				local cursor = thenEnd + 1
				while true do
					local elseifS = findKeyword(source, cursor, "elseif")
					local elseS = findKeyword(source, cursor, "else")
					local nextS, nextKind = nil, nil
					if elseifS and (not elseS or elseifS < elseS) then
						nextS, nextKind = elseifS, "elseif"
					elseif elseS then
						nextS, nextKind = elseS, "else"
					end
					if not nextS then break end
					branches[#branches].value = source:sub(cursor, nextS - 1):match("^%s*(.-)%s*$")
					if nextKind == "elseif" then
						local _, afterElseif = source:find("elseif[ \t\n]+", nextS)
						local thS, thE = findKeyword(source, afterElseif + 1, "then")
						if not thS then break end
						table.insert(branches, { cond = source:sub(afterElseif + 1, thS - 1):match("^%s*(.-)%s*$") })
						cursor = thE + 1
					else
						local _, afterElse = source:find("else[ \t\n]+", nextS)
						local endIdx = findExprEnd(source, afterElse + 1)
						local elseVal = source:sub(afterElse + 1, endIdx - 1):match("^%s*(.-)%s*$")
						table.insert(branches, { cond = nil, value = elseVal })
						cursor = endIdx
						break
					end
				end
				if branches[#branches].cond == nil then
					local body = ""
					for idx, b in ipairs(branches) do
						if b.cond then
							if idx == 1 then
								body = body .. "if " .. b.cond .. " then return " .. b.value .. " "
							else
								body = body .. "elseif " .. b.cond .. " then return " .. b.value .. " "
							end
						else
							body = body .. "else return " .. b.value .. " end"
						end
					end
					source = source:sub(1, ifStart - 1) .. "(function() " .. body .. " end)()" .. source:sub(cursor)
					changed = true
				end
			end
		end
	end
	return source
end

---Convert some specific snippets to work in luamin.
---@param source string
---@return string
---Convert Luau backtick template strings `text {expr} text` to plain Lua
---string concatenation with tostring(expr) for interpolations.
---@param source string
---@return string
local function transformBackticks(source)
	local out = {}
	local i = 1
	local len = #source
	while i <= len do
		local c = source:sub(i, i)
		-- Skip over comments and normal strings to avoid eating their content.
		if c == "-" and source:sub(i + 1, i + 1) == "-" then
			-- Long bracket comment?
			if source:sub(i + 2, i + 2) == "[" then
				local j = i + 3
				local eq = 0
				while source:sub(j, j) == "=" do eq = eq + 1; j = j + 1 end
				if source:sub(j, j) == "[" then
					local close = "]" .. string.rep("=", eq) .. "]"
					local endIdx = source:find(close, j + 1, true)
					if endIdx then
						table.insert(out, source:sub(i, endIdx + #close - 1))
						i = endIdx + #close
					else
						table.insert(out, source:sub(i))
						break
					end
				else
					-- Line comment
					local nl = source:find("\n", i, true) or (len + 1)
					table.insert(out, source:sub(i, nl - 1))
					i = nl
				end
			else
				local nl = source:find("\n", i, true) or (len + 1)
				table.insert(out, source:sub(i, nl - 1))
				i = nl
			end
		elseif c == '"' or c == "'" then
			local q = c
			local s = i
			i = i + 1
			while i <= len and source:sub(i, i) ~= q do
				if source:sub(i, i) == "\\" then i = i + 1 end
				i = i + 1
			end
			table.insert(out, source:sub(s, i))
			i = i + 1
		elseif c == "[" then
			-- Long bracket string?
			local j = i + 1
			local eq = 0
			while source:sub(j, j) == "=" do eq = eq + 1; j = j + 1 end
			if source:sub(j, j) == "[" then
				local close = "]" .. string.rep("=", eq) .. "]"
				local endIdx = source:find(close, j + 1, true)
				if endIdx then
					table.insert(out, source:sub(i, endIdx + #close - 1))
					i = endIdx + #close
				else
					table.insert(out, c)
					i = i + 1
				end
			else
				table.insert(out, c)
				i = i + 1
			end
		elseif c == "`" then
			-- Backtick template string. Parse until closing backtick.
			local parts = {}
			local buf = ""
			i = i + 1
			while i <= len and source:sub(i, i) ~= "`" do
				local ch = source:sub(i, i)
				if ch == "\\" and i + 1 <= len then
					buf = buf .. source:sub(i, i + 1)
					i = i + 2
				elseif ch == "{" then
					-- Flush literal
					if #buf > 0 then
						table.insert(parts, '"' .. buf .. '"')
						buf = ""
					end
					-- Parse expression until matching }, depth-tracked.
					local depth = 1
					i = i + 1
					local exprStart = i
					while i <= len and depth > 0 do
						local ec = source:sub(i, i)
						if ec == '"' or ec == "'" then
							local q = ec
							i = i + 1
							while i <= len and source:sub(i, i) ~= q do
								if source:sub(i, i) == "\\" then i = i + 1 end
								i = i + 1
							end
						elseif ec == "{" then
							depth = depth + 1
						elseif ec == "}" then
							depth = depth - 1
							if depth == 0 then break end
						end
						i = i + 1
					end
					local expr = source:sub(exprStart, i - 1)
					table.insert(parts, "tostring(" .. expr .. ")")
					i = i + 1 -- skip }
				else
					buf = buf .. ch
					i = i + 1
				end
			end
			if #buf > 0 then
				table.insert(parts, '"' .. buf .. '"')
			end
			i = i + 1 -- skip closing `
			if #parts == 0 then
				table.insert(out, '""')
			else
				table.insert(out, "(" .. table.concat(parts, " .. ") .. ")")
			end
		else
			table.insert(out, c)
			i = i + 1
		end
	end
	return table.concat(out)
end

local function transformInput(source)
	-- Luau inline if-then-else → Lua IIFEs (must run before luamin sees the source)
	source = transformInlineIfs(source)
	-- Luau backtick template strings → Lua string concatenation
	source = transformBackticks(source)
	-- Compound assignment operators
	source = string.gsub(source, "([%w_]+)%s*([%+%-%*/%%^%.]%.?)=%s*", "%1 = %1 %2")
	-- continue keyword
	source = string.gsub(source, "(%s+)continue(%s+)", "%1__CONTINUE__()%2")
	-- Luau generic-for without explicit iterator: `for k,v in tbl do` → `for k,v in pairs(tbl) do`
	-- Match when the in-expression is a single identifier path (no parens, no commas).
	source = string.gsub(source, "(for%s+[%w_,%s]+%s+in%s+)([%w_][%w_%.%[%]:]-)(%s+do)", function(pre, expr, post)
		-- If expr already contains a call (has parens) or starts with known iterators, skip.
		if expr:find("[%(%)]") then return pre .. expr .. post end
		if expr:match("^pairs$") or expr:match("^ipairs$") or expr:match("^next$") then
			return pre .. expr .. post
		end
		return pre .. "pairs(" .. expr .. ")" .. post
	end)
	return source
end

---@param source string
---@return string
local function transformOutput(source)
	source = string.gsub(source, "%.%.%.:", "(...):")
	source = string.gsub(source, "__CONTINUE__%(%)", "continue;")
	return source
end

---@param source string
---@return string
local function minify(source)
	remodel.writeFile(BUNDLE_TEMP, transformInput(source))
	local ok = os.execute("node ci/minify.js")
	if not ok then
		print("[Hvcorca " .. VERSION .. "] Minify step failed — falling back to unminified output")
		os.remove(BUNDLE_TEMP)
		return source
	end
	local output = remodel.readFile(BUNDLE_TEMP)
	os.remove(BUNDLE_TEMP)
	return transformOutput(output)
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

	-- Minify current output
	if MINIFY then
		output = { minify(table.concat(output, "\n")) }
	end

	-- Core runtime
	local runtime = string.gsub(remodel.readFile(RUNTIME_FILE), "__VERSION__", string.format("%q", VERSION))
	table.insert(output, 1, runtime)
	table.insert(output, "hInit()")

	if VERBOSE then
		table.insert(output, 2, "local START_TIME = os.clock()")
		table.insert(output, "print(\"[Hvcorca " .. VERSION .. "] Loaded in \" .. (os.clock() - START_TIME) * 1000 .. \" ms\")")
	end

	-- Write to file
	local dir = string.match(OUTPUT_PATH, "^(.*)[/\\]") or "."
	remodel.createDirAll(dir)
	remodel.writeFile(OUTPUT_PATH, table.concat(output, "\n\n"))

	print("[Hvcorca " .. VERSION .. "] Bundle written to " .. OUTPUT_PATH)
end

main()
