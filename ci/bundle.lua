-- ci/bundle.lua
local args = arg or {...} or {}
local input_file = args[1] or "Havoc.rbxm"
local output_file = args[2] or "latest.lua"

print("------------------------------------------")
print("[Havoc] Build System Initialized")
print("[Havoc] Input:  " .. input_file)
print("[Havoc] Output: " .. output_file)

local model_data = remodel.readModelFile(input_file)
if not model_data or #model_data == 0 then
	error("[Havoc] Model file invalid or empty: " .. input_file)
end
local model = model_data[1]

local file, openErr = io.open(output_file, "w")
if not file then
	error("[Havoc] Cannot open output file: " .. tostring(openErr))
end

local scriptCount = 0
local missingCount = 0

local aliasMap = {
	services = "@rbxts/services",
	roact = "@rbxts/roact",
	rodux = "@rbxts/rodux", 
	flipper = "@rbxts/flipper",
	["roact-rodux"] = "@rbxts/roact-rodux",
}

local function getRelParts(inst)
	local parts = {}
	local curr = inst
	while curr and curr.Name ~= model.Name do
		table.insert(parts, 1, curr.Name)
		curr = curr.Parent
	end
	return parts
end

local function toLongString(src)
	local level = 0
	while src:find("%]" .. string.rep("=", level) .. "%]") do
		level = level + 1
	end
	local eq = string.rep("=", level)
	return "[" .. eq .. "[" .. src .. "]" .. eq .. "]"
end

local function readFile(path)
	local ok, content = pcall(remodel.readFile, path)
	if ok and content and #content > 0 then
		print("[Havoc] Found source: " .. path)
		return content
	end
	return nil
end

local function tryPaths(paths)
	for _, p in ipairs(paths) do
		local content = readFile(p)
		if content then
			return content, p
		end
	end
	return nil
end

local function push(t, v)
	t[#t + 1] = v
end

local function readSource(inst)
	local parts = getRelParts(inst)
	local relPath = table.concat(parts, "/")

	-- Priority 1: out/ (compiled app logic)
	local attempts = {
		"out/" .. relPath .. ".lua",
		"out/" .. relPath .. "/init.lua",
		"out/" .. relPath .. ".client.lua",
		"out/" .. relPath .. ".server.lua",
	}

	-- Priority 2: root include/ (no cleanRel stripping)
	push(attempts, "include/" .. relPath .. ".lua")
	push(attempts, "include/" .. relPath .. "/init.lua")

	-- Priority 3: Direct package aliases (services first)
	local pkgAlias = aliasMap[inst.Name]
	if pkgAlias then
		local pkgPaths = {
			"node_modules/" .. pkgAlias .. "/lib/init.lua",
			"node_modules/" .. pkgAlias .. "/out/init.lua", 
			"node_modules/" .. pkgAlias .. "/src/init.lua",
			"node_modules/" .. pkgAlias .. "/init.lua",
		}
		for _, path in ipairs(pkgPaths) do
			push(attempts, path)
		end
	end

	-- Priority 4: Generic node_modules probing
	local probes = {}
	local nmIdx
	for i, p in ipairs(parts) do
		if p == "node_modules" then
			nmIdx = i
			break
		end
	end
	if nmIdx then
		local pkgName = parts[nmIdx + 1]
		if pkgName then
			local base = "node_modules/@rbxts/" .. pkgName
			push(probes, base .. "/lib/init.lua")
			push(probes, base .. "/out/init.lua")
			push(probes, base .. "/src/init.lua")
			push(probes, base .. "/init.lua")
		end
	end
	for _, probe in ipairs(probes) do
		push(attempts, probe)
	end

	return tryPaths(attempts)
end

-- Write bundle header + runtime
file:write("-- Havoc | Auto-generated bundle.lua — do not edit\n")
file:write("local function start()\n")
file:write("    local hInit, hMod, hInst, hEnv = (function()\n")
file:write(remodel.readFile("ci/runtime.lua"))
file:write("\n    end)()\n\n")

local function walk(parent)
	for _, object in ipairs(parent:GetChildren()) do
		local name = string.format("%q", object.Name)
		local id = string.format("%q", object:GetFullName())
		local pId = string.format("%q", parent:GetFullName())
		local class = object.ClassName
		local isScript = (class == "ModuleScript" or class == "LocalScript")

		if isScript then
			local source = readSource(object)
			if source then
				scriptCount = scriptCount + 1
				local longSrc = toLongString(source)
				-- FIXED: Proper module registration pattern from Orca
				file:write(string.format(
					"    hMod(%s, %q, %s, %s, function()\n",
					name, class, id, pId
				))
				file:write("        return loadstring(" .. longSrc .. ")()\n")
				file:write("    end)\n")
			else
				missingCount = missingCount + 1
				print(string.format(
					"[Havoc] WARNING: no source for %s (%s)",
					object:GetFullName(), class
				))
				file:write(string.format(
					"    hInst(%s, %q, %s, %s)\n",
					name, class, id, pId
				))
			end
		else
			file:write(string.format(
				"    hInst(%s, %q, %s, %s)\n",
				name, class, id, pId
			))
		end
		walk(object)
	end
end

file:write(string.format(
	"    hInst(%q, %q, %q, nil)\n",
	model.Name, "Folder", model:GetFullName()
))
walk(model)
file:write("\n    hInit()\nend\nstart()\n")

file:close()
print(string.format(
	"[Havoc] Build complete — %d scripts, %d missing",
	scriptCount, missingCount
))
print("------------------------------------------")
