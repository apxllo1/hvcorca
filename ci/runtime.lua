-- ci/runtime.lua (hvcorca v1.1.1 - FIXED)
local instanceFromId = {}
local modules = {}
local currentlyLoading = {}

-- FIXED: Proper _setfenv (Orca standard)
local function _setfenv(fn, env)
	local i = 1
	while true do
		local name, val = debug.getupvalue(fn, i)
		if name == "_ENV" then
			debug.setupvalue(fn, i, env)
			return fn
		elseif not name then break end
		i = i + 1
	end
	return fn
end

-- FIXED: Proper circular dep detection (Orca v1.1.1)
local function validateRequire(module, caller)
	currentlyLoading[caller] = module
	local currentModule = module
	local depth = 0
	while currentModule do
		depth = depth + 1
		currentModule = currentlyLoading[currentModule]
		if currentModule == module then
			local str = module.Name
			for _ = 1, depth do
				currentModule = currentlyLoading[currentModule]
				str = str .. " → " .. currentModule.Name
			end
			error("Hvcorca: Circular dependency " .. str, 2)
		end
	end
	return function()
		if currentlyLoading[caller] == module then
			currentlyLoading[caller] = nil
		end
	end
end

local function loadModule(obj, caller)
	local cleanup = caller and validateRequire(obj, caller)
	local module = modules[obj]
	if not module then 
		if cleanup then cleanup() end
		return nil 
	end
	
	if module.isLoaded then
		if cleanup then cleanup() end
		return module.value
	end
	
	local data = module.fn()
	module.value = data
	module.isLoaded = true
	if cleanup then cleanup() end
	return data
end

local function requireModule(target, this)
	if modules[target] and target:IsA("ModuleScript") then
		return loadModule(target, this)
	else
		return require(target)
	end
end

-- FIXED: Add idFromInstance (Orca registry complete)
local idFromInstance = {}
local function hEnv(id)
	local inst = instanceFromId[id]
	return setmetatable({
		script = inst,
		VERSION = "Hvcorca v1.1.1",  -- Your branding
		require = function(module)
			return requireModule(module, instanceFromId[id])
		end,
		_setfenv = _setfenv,
	}, {__index = getfenv(0) or _G})
end

local function hInst(name, class, id, parentId)
	local inst = Instance.new(class)
	inst.Name = name
	inst.Parent = parentId and instanceFromId[parentId] or nil
	instanceFromId[id] = inst
	idFromInstance[inst] = id
	return inst
end

-- FIXED: Proper env wrapping (Orca exact)
local function hMod(name, class, id, parentId, fn)
	local inst = hInst(name, class, id, parentId)
	modules[inst] = {
		fn = function()
			return _setfenv(fn, hEnv(id))()
		end,
		value = nil,
		isLoaded = false,
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
				loadModule(obj, nil)
			end)
		end
	end
end

return hInit, hMod, hInst, hEnv  -- FIXED: Remove trailing "1b1"
