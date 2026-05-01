-- ci/runtime.lua
local instanceFromId = {}
local modules = {}
local loading = {}

local function _setfenv(fn, env)
	local i = 1
	while true do
		local name = debug.getupvalue(fn, i)
		if name == "_ENV" then
			debug.setupvalue(fn, i, env)
			return fn
		elseif not name then
			break
		end
		i = i + 1
	end
	return fn
end

local function _getfenv(fn)
	if type(fn) == "number" then
		fn = debug.getinfo(fn + 1, "f").func
	end
	local i = 1
	while true do
		local name, val = debug.getupvalue(fn, i)
		if name == "_ENV" then
			return val
		elseif not name then
			break
		end
		i = i + 1
	end
	return _G
end

local function hEnv(id)
	local inst = instanceFromId[id]
	return setmetatable({
		script = inst,
		require = function(target)
			if typeof(target) == "Instance" then
				local module = modules[target]
				if module then
					if module.loaded then
						return module.value
					end
					if loading[target] then
						error("[Havoc] Circular dependency involving " .. target:GetFullName(), 2)
					end
					loading[target] = true
					local result = module.fn()
					module.value = result
					module.loaded = true
					loading[target] = nil
					return result
				end

				error(
					"[Havoc] require: '" .. tostring(target.Name) .. "' (" .. tostring(target:GetFullName()) ..
					") is not a registered module. Was the source file missing at bundle time?",
					2
				)
			end

			return require(target)
		end,
		_setfenv = _setfenv,
		_getfenv = _getfenv,
	}, { __index = _G })
end

local function hInst(name, class, id, parentId)
	local inst = Instance.new(class)
	inst.Name = name
	inst.Parent = parentId and instanceFromId[parentId] or nil
	instanceFromId[id] = inst
	return inst
end

local function hMod(name, class, id, parentId, fn)
	local inst = hInst(name, class, id, parentId)
	modules[inst] = {
		fn = fn,
		value = nil,
		loaded = false,
	}
	return inst
end

local function hInit()
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	for obj in pairs(modules) do
		if obj:IsA("LocalScript") and not obj.Disabled then
			task.spawn(function()
				local env = hEnv(obj:GetFullName())
				local fn = modules[obj].fn
				local result = fn()
				modules[obj].value = result
				modules[obj].loaded = true
				return result
			end)
		end
	end
end

return hInit, hMod, hInst, hEnv, _setfenv
