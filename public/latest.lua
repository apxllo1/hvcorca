local function start()
    local hInit, hMod, hInst, hEnv = (function()
local instanceFromId = {}
local idFromInstance = {}
local modules = {}
local currentlyLoading = {}

local function validateRequire(module, caller)
    currentlyLoading[caller] = module
    local currentModule = module
    local depth = 0
    if not modules[module] then
        while currentModule do
            depth = depth + 1
            currentModule = currentlyLoading[currentModule]
            if currentModule == module then
                local str = currentModule.Name
                for _ = 1, depth do
                    currentModule = currentlyLoading[currentModule]
                    str = str .. "\n" .. currentModule.Name
                end
                error("Failed to load '" .. module.Name .. "'; Circular dependency:\n" .. str, 2)
            end
        end
    end
    return function()
        if currentlyLoading[caller] == module then
            currentlyLoading[caller] = nil
        end
    end
end

local function loadModule(obj, this)
    local cleanup = this and validateRequire(obj, this)
    local module = modules[obj]
    if module.isLoaded then
        if cleanup then cleanup() end
        return module.value
    else
        local data = module.fn()
        module.value = data
        module.isLoaded = true
        if cleanup then cleanup() end
        return data
    end
end

local function requireModuleInternal(target, this)
    if modules[target] and target:IsA("ModuleScript") then
        return loadModule(target, this)
    else
        return require(target)
    end
end

local function newEnv(id)
    return setmetatable({
        script = instanceFromId[id],
        require = function(module)
            return requireModuleInternal(module, instanceFromId[id])
        end,
    }, {
        __index = getfenv(0),
        __metatable = "This metatable is locked",
    })
end

local function hMod(name, class, id, parentId, fn)
    local inst = Instance.new(class)
    inst.Name = name
    inst.Parent = parentId ~= nil and instanceFromId[parentId] or nil
    instanceFromId[id] = inst
    idFromInstance[inst] = id
    modules[inst] = { fn = fn, isLoaded = false, value = nil }
end

local function hInst(name, class, id, parentId)
    local inst = Instance.new(class)
    inst.Name = name
    inst.Parent = parentId ~= nil and instanceFromId[parentId] or nil
    instanceFromId[id] = inst
    idFromInstance[inst] = id
end

local function hInit()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    for obj in pairs(modules) do
        if obj:IsA("LocalScript") and not obj.Disabled then
            task.spawn(loadModule, obj)
        end
    end
end

return hInit, hMod, hInst, newEnv

    end)()

    hInst("Havoc", "Folder", "Havoc", nil)
    hInst("include", "Folder", "Havoc.include", "Havoc")
    hMod("App", "ModuleScript", "Havoc.App", "Havoc", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local useEffect = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).useEffect
local Stats = TS.import(script, TS.getModule(script, "@rbxts", "services")).Stats
local Dashboard = TS.import(script, script.Parent, "views", "Dashboard").default
local _debug = TS.import(script, script.Parent, "utils", "debug")
local startTimer = _debug.startTimer
local endTimer = _debug.endTimer
local logger = _debug.logger
local logPerformance = _debug.logPerformance
local DISPLAY_ORDER = 7
local function App()
	useEffect(function()
		startTimer("Havoc_UI_Mount")
		logger.info("Havoc UI mounting sequence initiated...")
		local isRunning = true
		task.spawn(function()
			while isRunning do
				local mem = math.floor(Stats:GetTotalMemoryUsageMb())
				print("[Havoc Pulse]: Main UI Active. Memory: " .. (tostring(mem) .. "MB"))
				task.wait(5)
			end
		end)
		endTimer("Havoc_UI_Mount")
		logPerformance()
		return function()
			isRunning = false
		end
	end, {})
	return Roact.createElement("ScreenGui", {
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = DISPLAY_ORDER,
	}, {
		Roact.createElement(Dashboard),
	})
end
local default = App
return {
	default = default,
}

        end)
    end)
    hInst("components", "Folder", "Havoc.components", "Havoc")
    hMod("Acrylic", "ModuleScript", "Havoc.components.Acrylic", "Havoc.components", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Acrylic").default
return exports

        end)
    end)
    hMod("Acrylic", "ModuleScript", "Havoc.components.Acrylic.Acrylic", "Havoc.components.Acrylic", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local hooked = _roact_hooked.hooked
local useCallback = _roact_hooked.useCallback
local useEffect = _roact_hooked.useEffect
local useMemo = _roact_hooked.useMemo
local useMutable = _roact_hooked.useMutable
local Workspace = TS.import(script, TS.getModule(script, "@rbxts", "services")).Workspace
local acrylicInstance = TS.import(script, script.Parent, "acrylic-instance").acrylicInstance
local useAppSelector = TS.import(script, script.Parent.Parent.Parent, "hooks", "common", "rodux-hooks").useAppSelector
local map = TS.import(script, script.Parent.Parent.Parent, "utils", "number-util").map
local scale = TS.import(script, script.Parent.Parent.Parent, "utils", "udim2").scale
local cylinderAngleOffset = CFrame.Angles(0, math.rad(90), 0)
local function viewportPointToWorld(location, distance)
	local unitRay = Workspace.CurrentCamera:ScreenPointToRay(location.X, location.Y)
	local _origin = unitRay.Origin
	local _arg0 = unitRay.Direction * distance
	return _origin + _arg0
end
local function getOffset()
	return map(Workspace.CurrentCamera.ViewportSize.Y, 0, 2560, 8, 56)
end
local AcrylicBlur
local function Acrylic(_param)
	local radius = _param.radius
	local distance = _param.distance
	local isAcrylicBlurEnabled = useAppSelector(function(state)
		return state.options.config.acrylicBlur
	end)
	local _children = {}
	local _length = #_children
	local _child = isAcrylicBlurEnabled and Roact.createElement(AcrylicBlur, {
		radius = radius,
		distance = distance,
	})
	if _child then
		if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then
			_children[_length + 1] = _child
		else
			for _k, _v in ipairs(_child) do
				_children[_length + _k] = _v
			end
		end
	end
	return Roact.createFragment(_children)
end
local default = hooked(Acrylic)
local function AcrylicBlurComponent(_param)
	local radius = _param.radius
	if radius == nil then
		radius = 0
	end
	local distance = _param.distance
	if distance == nil then
		distance = 0.001
	end
	local frameInfo = useMutable({
		topleft2d = Vector2.new(),
		topright2d = Vector2.new(),
		bottomright2d = Vector2.new(),
		topleftradius2d = Vector2.new(),
	})
	local acrylic = useMemo(function()
		local clone = acrylicInstance:Clone()
		clone.Parent = Workspace
		return clone
	end, {})
	useEffect(function()
		return function()
			return acrylic:Destroy()
		end
	end, {})
	local updateFrameInfo = useCallback(function(size, position)
		local _arg0 = size / 2
		local topleftRaw = position - _arg0
		local info = frameInfo.current
		info.topleft2d = Vector2.new(math.ceil(topleftRaw.X), math.ceil(topleftRaw.Y))
		local _topleft2d = info.topleft2d
		local _vector2 = Vector2.new(size.X, 0)
		info.topright2d = _topleft2d + _vector2
		info.bottomright2d = info.topleft2d + size
		local _topleft2d_1 = info.topleft2d
		local _vector2_1 = Vector2.new(radius, 0)
		info.topleftradius2d = _topleft2d_1 + _vector2_1
	end, { distance, radius })
	local updateInstance = useCallback(function()
		local _binding = frameInfo.current
		local topleft2d = _binding.topleft2d
		local topright2d = _binding.topright2d
		local bottomright2d = _binding.bottomright2d
		local topleftradius2d = _binding.topleftradius2d
		local topleft = viewportPointToWorld(topleft2d, distance)
		local topright = viewportPointToWorld(topright2d, distance)
		local bottomright = viewportPointToWorld(bottomright2d, distance)
		local topleftradius = viewportPointToWorld(topleftradius2d, distance)
		local cornerRadius = (topleftradius - topleft).Magnitude
		local width = (topright - topleft).Magnitude
		local height = (topright - bottomright).Magnitude
		local center = CFrame.fromMatrix((topleft + bottomright) / 2, Workspace.CurrentCamera.CFrame.XVector, Workspace.CurrentCamera.CFrame.YVector, Workspace.CurrentCamera.CFrame.ZVector)
		if radius ~= nil and radius > 0 then
			acrylic.Horizontal.CFrame = center
			acrylic.Horizontal.Mesh.Scale = Vector3.new(width - cornerRadius * 2, height, 0)
			acrylic.Vertical.CFrame = center
			acrylic.Vertical.Mesh.Scale = Vector3.new(width, height - cornerRadius * 2, 0)
		else
			acrylic.Horizontal.CFrame = center
			acrylic.Horizontal.Mesh.Scale = Vector3.new(width, height, 0)
		end
		if radius ~= nil and radius > 0 then
			local _cFrame = CFrame.new(-width / 2 + cornerRadius, height / 2 - cornerRadius, 0)
			acrylic.TopLeft.CFrame = center * _cFrame * cylinderAngleOffset
			acrylic.TopLeft.Mesh.Scale = Vector3.new(0, cornerRadius * 2, cornerRadius * 2)
			local _cFrame_1 = CFrame.new(width / 2 - cornerRadius, height / 2 - cornerRadius, 0)
			acrylic.TopRight.CFrame = center * _cFrame_1 * cylinderAngleOffset
			acrylic.TopRight.Mesh.Scale = Vector3.new(0, cornerRadius * 2, cornerRadius * 2)
			local _cFrame_2 = CFrame.new(-width / 2 + cornerRadius, -height / 2 + cornerRadius, 0)
			acrylic.BottomLeft.CFrame = center * _cFrame_2 * cylinderAngleOffset
			acrylic.BottomLeft.Mesh.Scale = Vector3.new(0, cornerRadius * 2, cornerRadius * 2)
			local _cFrame_3 = CFrame.new(width / 2 - cornerRadius, -height / 2 + cornerRadius, 0)
			acrylic.BottomRight.CFrame = center * _cFrame_3 * cylinderAngleOffset
			acrylic.BottomRight.Mesh.Scale = Vector3.new(0, cornerRadius * 2, cornerRadius * 2)
		end
	end, { radius, distance })
	useEffect(function()
		updateInstance()
		local posHandle = Workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(updateInstance)
		local fovHandle = Workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(updateInstance)
		local viewportHandle = Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateInstance)
		return function()
			posHandle:Disconnect()
			fovHandle:Disconnect()
			viewportHandle:Disconnect()
		end
	end, { updateInstance })
	return Roact.createElement("Frame", {
		[Roact.Change.AbsoluteSize] = function(rbx)
			local blurOffset = getOffset()
			local _absoluteSize = rbx.AbsoluteSize
			local _vector2 = Vector2.new(blurOffset, blurOffset)
			local size = _absoluteSize - _vector2
			local _absolutePosition = rbx.AbsolutePosition
			local _arg0 = rbx.AbsoluteSize / 2
			local position = _absolutePosition + _arg0
			updateFrameInfo(size, position)
			task.spawn(updateInstance)
		end,
		[Roact.Change.AbsolutePosition] = function(rbx)
			local blurOffset = getOffset()
			local _absoluteSize = rbx.AbsoluteSize
			local _vector2 = Vector2.new(blurOffset, blurOffset)
			local size = _absoluteSize - _vector2
			local _absolutePosition = rbx.AbsolutePosition
			local _arg0 = rbx.AbsoluteSize / 2
			local position = _absolutePosition + _arg0
			updateFrameInfo(size, position)
			task.spawn(updateInstance)
		end,
		Size = scale(1, 1),
		BackgroundTransparency = 1,
	})
end
AcrylicBlur = hooked(AcrylicBlurComponent)
return {
	default = default,
}

        end)
    end)
    hMod("Acrylic.story", "ModuleScript", "Havoc.components.Acrylic.Acrylic.story", "Havoc.components.Acrylic", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local Provider = TS.import(script, TS.getModule(script, "@rbxts", "roact-rodux-hooked").out).Provider
local Acrylic = TS.import(script, script.Parent, "Acrylic").default
local DashboardPage = TS.import(script, script.Parent.Parent.Parent, "store", "models", "dashboard.model").DashboardPage
local configureStore = TS.import(script, script.Parent.Parent.Parent, "store", "store").configureStore
local hex = TS.import(script, script.Parent.Parent.Parent, "utils", "color3").hex
local _udim2 = TS.import(script, script.Parent.Parent.Parent, "utils", "udim2")
local px = _udim2.px
local scale = _udim2.scale
return function(target)
	local handle = Roact.mount(Roact.createElement(Provider, {
		store = configureStore({
			dashboard = {
				isOpen = true,
				page = DashboardPage.Apps,
				hint = nil,
				apps = {},
			},
		}),
	}, {
		Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = scale(0.3, 0.7),
			Size = px(250, 350),
			BackgroundColor3 = hex("#000000"),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
		}, {
			Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 64),
			}),
			Roact.createElement(Acrylic, {
				radius = 52,
			}),
		}),
	}), target, "Acrylic")
	return function()
		return Roact.unmount(handle)
	end
end

        end)
    end)
    hMod("acrylic-instance", "ModuleScript", "Havoc.components.Acrylic.acrylic-instance", "Havoc.components.Acrylic", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Make = TS.import(script, TS.getModule(script, "@rbxts", "make"))
local fill = {
	Color = Color3.new(0, 0, 0),
	Material = Enum.Material.Glass,
	Size = Vector3.new(1, 1, 0),
	Anchored = true,
	CanCollide = false,
	Locked = true,
	CastShadow = false,
	Transparency = 0.999,
}
local corner = {
	Color = Color3.new(0, 0, 0),
	Material = Enum.Material.Glass,
	Size = Vector3.new(0, 1, 1),
	Anchored = true,
	CanCollide = false,
	Locked = true,
	CastShadow = false,
	Transparency = 0.999,
}
local _object = {}
local _left = "Children"
local _object_1 = {
	Name = "Horizontal",
	Children = { Make("SpecialMesh", {
		MeshType = Enum.MeshType.Brick,
		Offset = Vector3.new(0, 0, -0.000001),
	}) },
}
for _k, _v in pairs(fill) do
	_object_1[_k] = _v
end
local _exp = Make("Part", _object_1)
local _object_2 = {
	Name = "Vertical",
	Children = { Make("SpecialMesh", {
		MeshType = Enum.MeshType.Brick,
		Offset = Vector3.new(0, 0, 0.000001),
	}) },
}
for _k, _v in pairs(fill) do
	_object_2[_k] = _v
end
local _exp_1 = Make("Part", _object_2)
local _object_3 = {
	Name = "TopRight",
	Children = { Make("SpecialMesh", {
		MeshType = Enum.MeshType.Cylinder,
	}) },
}
for _k, _v in pairs(corner) do
	_object_3[_k] = _v
end
local _exp_2 = Make("Part", _object_3)
local _object_4 = {
	Name = "TopLeft",
	Children = { Make("SpecialMesh", {
		MeshType = Enum.MeshType.Cylinder,
	}) },
}
for _k, _v in pairs(corner) do
	_object_4[_k] = _v
end
local _exp_3 = Make("Part", _object_4)
local _object_5 = {
	Name = "BottomRight",
	Children = { Make("SpecialMesh", {
		MeshType = Enum.MeshType.Cylinder,
	}) },
}
for _k, _v in pairs(corner) do
	_object_5[_k] = _v
end
local _exp_4 = Make("Part", _object_5)
local _object_6 = {
	Name = "BottomLeft",
	Children = { Make("SpecialMesh", {
		MeshType = Enum.MeshType.Cylinder,
	}) },
}
for _k, _v in pairs(corner) do
	_object_6[_k] = _v
end
_object[_left] = { _exp, _exp_1, _exp_2, _exp_3, _exp_4, Make("Part", _object_6) }
local acrylicInstance = Make("Model", _object)
return {
	acrylicInstance = acrylicInstance,
}

        end)
    end)
    hMod("ActionButton", "ModuleScript", "Havoc.components.ActionButton", "Havoc.components", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local hooked = _roact_hooked.hooked
local useState = _roact_hooked.useState
local BrightButton = TS.import(script, script.Parent, "BrightButton").default
local _rodux_hooks = TS.import(script, script.Parent.Parent, "hooks", "common", "rodux-hooks")
local useAppDispatch = _rodux_hooks.useAppDispatch
local useAppSelector = _rodux_hooks.useAppSelector
local useSpring = TS.import(script, script.Parent.Parent, "hooks", "common", "use-spring").useSpring
local _dashboard_action = TS.import(script, script.Parent.Parent, "store", "actions", "dashboard.action")
local clearHint = _dashboard_action.clearHint
local setHint = _dashboard_action.setHint
local setJobActive = TS.import(script, script.Parent.Parent, "store", "actions", "jobs.action").setJobActive
local px = TS.import(script, script.Parent.Parent, "utils", "udim2").px
local function ActionButton(_param)
	local action = _param.action
	local hint = _param.hint
	local theme = _param.theme
	local image = _param.image
	local position = _param.position
	local canDeactivate = _param.canDeactivate
	local dispatch = useAppDispatch()
	local active = useAppSelector(function(state)
		local job = state.jobs[action]
		local _result = job
		if _result ~= nil then
			_result = _result.active
		end
		local _condition = _result
		if _condition == nil then
			_condition = false
		end
		return _condition
	end)
	local _binding = useState(false)
	local hovered = _binding[1]
	local setHovered = _binding[2]
	local highlightMap = theme.highlight
	local _condition = highlightMap[action]
	if _condition == nil then
		_condition = theme.button.background
	end
	local accent = _condition
	local _result
	if active then
		_result = accent
	else
		local _result_1
		if hovered then
			local _condition_1 = theme.button.backgroundHovered
			if _condition_1 == nil then
				_condition_1 = theme.button.background:Lerp(accent, 0.1)
			end
			_result_1 = _condition_1
		else
			_result_1 = theme.button.background
		end
		_result = _result_1
	end
	local background = useSpring(_result, {})
	local foreground = useSpring(active and theme.button.foregroundAccent and theme.button.foregroundAccent or theme.button.foreground, {})
	return Roact.createElement(BrightButton, {
		onActivate = function()
			if active and canDeactivate then
				dispatch(setJobActive(action, false))
			elseif not active then
				dispatch(setJobActive(action, true))
			end
		end,
		onHover = function(isHovered)
			setHovered(isHovered)
			if isHovered then
				dispatch(setHint(hint))
			else
				dispatch(clearHint())
			end
		end,
		size = px(61, 49),
		position = position,
		radius = 8,
		color = background,
		borderEnabled = theme.button.outlined,
		borderColor = foreground,
		transparency = theme.button.backgroundTransparency,
	}, {
		Roact.createElement("ImageLabel", {
			Image = image,
			ImageColor3 = foreground,
			ImageTransparency = useSpring(active and 0 or (hovered and theme.button.foregroundTransparency - 0.25 or theme.button.foregroundTransparency), {}),
			Size = px(36, 36),
			Position = px(12, 6),
			BackgroundTransparency = 1,
		}),
	})
end
local default = hooked(ActionButton)
return {
	default = default,
}

        end)
    end)
    hMod("Border", "ModuleScript", "Havoc.components.Border", "Havoc.components", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).hooked
local _binding_util = TS.import(script, script.Parent.Parent, "utils", "binding-util")
local asBinding = _binding_util.asBinding
local mapBinding = _binding_util.mapBinding
local hex = TS.import(script, script.Parent.Parent, "utils", "color3").hex
local px = TS.import(script, script.Parent.Parent, "utils", "udim2").px
local function Border(_param)
	local size = _param.size
	if size == nil then
		size = 1
	end
	local radius = _param.radius
	if radius == nil then
		radius = 0
	end
	local color = _param.color
	if color == nil then
		color = hex("#ffffff")
	end
	local transparency = _param.transparency
	if transparency == nil then
		transparency = 0
	end
	local children = _param[Roact.Children]
	local _attributes = {
		Size = mapBinding(size, function(s)
			return UDim2.new(1, -s * 2, 1, -s * 2)
		end),
		Position = mapBinding(size, function(s)
			return px(s, s)
		end),
		BackgroundTransparency = 1,
	}
	local _children = {}
	local _length = #_children
	local _attributes_1 = {
		Thickness = size,
		Color = color,
		Transparency = transparency,
	}
	local _children_1 = {}
	local _length_1 = #_children_1
	if children then
		for _k, _v in pairs(children) do
			if type(_k) == "number" then
				_children_1[_length_1 + _k] = _v
			else
				_children_1[_k] = _v
			end
		end
	end
	_children[_length + 1] = Roact.createElement("UIStroke", _attributes_1, _children_1)
	_children[_length + 2] = Roact.createElement("UICorner", {
		CornerRadius = Roact.joinBindings({
			radius = asBinding(radius),
			size = asBinding(size),
		}):map(function(_param_1)
			local radius = _param_1.radius
			local size = _param_1.size
			return radius == "circular" and UDim.new(1, 0) or UDim.new(0, radius - size * 2)
		end),
	})
	return Roact.createElement("Frame", _attributes, _children)
end
local default = hooked(Border)
return {
	default = default,
}

        end)
    end)
    hMod("BrightButton", "ModuleScript", "Havoc.components.BrightButton", "Havoc.components", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).hooked
local Border = TS.import(script, script.Parent, "Border").default
local Canvas = TS.import(script, script.Parent, "Canvas").default
local Fill = TS.import(script, script.Parent, "Fill").default
local _Glow = TS.import(script, script.Parent, "Glow")
local Glow = _Glow.default
local GlowRadius = _Glow.GlowRadius
local hex = TS.import(script, script.Parent.Parent, "utils", "color3").hex
local _udim2 = TS.import(script, script.Parent.Parent, "utils", "udim2")
local px = _udim2.px
local scale = _udim2.scale
local function BrightButton(_param)
	local size = _param.size
	if size == nil then
		size = px(100, 100)
	end
	local position = _param.position
	if position == nil then
		position = px(0, 0)
	end
	local radius = _param.radius
	if radius == nil then
		radius = 8
	end
	local color = _param.color
	if color == nil then
		color = hex("#FFFFFF")
	end
	local borderEnabled = _param.borderEnabled
	local borderColor = _param.borderColor
	if borderColor == nil then
		borderColor = hex("#FFFFFF")
	end
	local transparency = _param.transparency
	if transparency == nil then
		transparency = 0
	end
	local onActivate = _param.onActivate
	local onPress = _param.onPress
	local onRelease = _param.onRelease
	local onHover = _param.onHover
	local children = _param[Roact.Children]
	local _attributes = {
		size = size,
		position = position,
	}
	local _children = {
		Roact.createElement(Glow, {
			radius = GlowRadius.Size70,
			color = color,
			size = UDim2.new(1, 36, 1, 36),
			position = px(-18, 5 - 18),
			transparency = transparency,
		}),
		Roact.createElement(Fill, {
			color = color,
			radius = radius,
			transparency = transparency,
		}),
	}
	local _length = #_children
	local _child = borderEnabled and Roact.createElement(Border, {
		color = borderColor,
		radius = radius,
		transparency = 0.8,
	})
	if _child then
		if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then
			_children[_length + 1] = _child
		else
			for _k, _v in ipairs(_child) do
				_children[_length + _k] = _v
			end
		end
	end
	_length = #_children
	_children[_length + 1] = Roact.createElement("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = scale(1, 1),
		BackgroundTransparency = 1,
		[Roact.Event.Activated] = function()
			local _result = onActivate
			if _result ~= nil then
				_result = _result()
			end
			return _result
		end,
		[Roact.Event.MouseButton1Down] = function()
			local _result = onPress
			if _result ~= nil then
				_result = _result()
			end
			return _result
		end,
		[Roact.Event.MouseButton1Up] = function()
			local _result = onRelease
			if _result ~= nil then
				_result = _result()
			end
			return _result
		end,
		[Roact.Event.MouseEnter] = function()
			local _result = onHover
			if _result ~= nil then
				_result = _result(true)
			end
			return _result
		end,
		[Roact.Event.MouseLeave] = function()
			local _result = onHover
			if _result ~= nil then
				_result = _result(false)
			end
			return _result
		end,
	})
	if children then
		for _k, _v in pairs(children) do
			if type(_k) == "number" then
				_children[_length + 1 + _k] = _v
			else
				_children[_k] = _v
			end
		end
	end
	return Roact.createElement(Canvas, _attributes, _children)
end
local default = hooked(BrightButton)
return {
	default = default,
}

        end)
    end)
    hMod("BrightSlider", "ModuleScript", "Havoc.components.BrightSlider", "Havoc.components", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Spring = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src).Spring
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local hooked = _roact_hooked.hooked
local useCallback = _roact_hooked.useCallback
local useEffect = _roact_hooked.useEffect
local useState = _roact_hooked.useState
local UserInputService = TS.import(script, TS.getModule(script, "@rbxts", "services")).UserInputService
local _flipper_hooks = TS.import(script, script.Parent.Parent, "hooks", "common", "flipper-hooks")
local getBinding = _flipper_hooks.getBinding
local useMotor = _flipper_hooks.useMotor
local _udim2 = TS.import(script, script.Parent.Parent, "utils", "udim2")
local px = _udim2.px
local scale = _udim2.scale
local Border = TS.import(script, script.Parent, "Border").default
local Canvas = TS.import(script, script.Parent, "Canvas").default
local Fill = TS.import(script, script.Parent, "Fill").default
local _Glow = TS.import(script, script.Parent, "Glow")
local Glow = _Glow.default
local GlowRadius = _Glow.GlowRadius
local SPRING_OPTIONS = {
	frequency = 8,
}
local Drag
local function BrightSlider(_param)
	local min = _param.min
	local max = _param.max
	local initialValue = _param.initialValue
	local size = _param.size
	local position = _param.position
	local radius = _param.radius
	local color = _param.color
	local accentColor = _param.accentColor
	local borderEnabled = _param.borderEnabled
	local borderColor = _param.borderColor
	local transparency = _param.transparency
	local indicatorTransparency = _param.indicatorTransparency
	local onValueChanged = _param.onValueChanged
	local onRelease = _param.onRelease
	local children = _param[Roact.Children]
	local valueMotor = useMotor(initialValue)
	local valueBinding = getBinding(valueMotor)
	useEffect(function()
		local _result = onValueChanged
		if _result ~= nil then
			_result(initialValue)
		end
	end, {})
	useEffect(function()
		return function()
			return valueMotor:destroy()
		end
	end, {})
	local _attributes = {
		size = size,
		position = position,
	}
	local _children = {
		Roact.createElement(Glow, {
			radius = GlowRadius.Size70,
			color = accentColor,
			size = valueBinding:map(function(v)
				return UDim2.new((v - min) / (max - min), 36, 1, 36)
			end),
			position = px(-18, 5 - 18),
			transparency = 0,
			maintainCornerRadius = true,
		}),
		Roact.createElement(Fill, {
			color = color,
			radius = radius,
			transparency = transparency,
		}),
		Roact.createElement(Canvas, {
			size = valueBinding:map(function(v)
				return scale((v - min) / (max - min), 1)
			end),
			clipsDescendants = true,
		}, {
			Roact.createElement("Frame", {
				Size = size,
				BackgroundColor3 = accentColor,
				BackgroundTransparency = indicatorTransparency,
			}, {
				Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, radius),
				}),
			}),
		}),
	}
	local _length = #_children
	local _child = borderEnabled and Roact.createElement(Border, {
		color = borderColor,
		radius = radius,
		transparency = 0.8,
	})
	if _child then
		if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then
			_children[_length + 1] = _child
		else
			for _k, _v in ipairs(_child) do
				_children[_length + _k] = _v
			end
		end
	end
	_length = #_children
	_children[_length + 1] = Roact.createElement(Drag, {
		onChange = function(alpha)
			valueMotor:setGoal(Spring.new(alpha * (max - min) + min, SPRING_OPTIONS))
			local _result = onValueChanged
			if _result ~= nil then
				_result(alpha * (max - min) + min)
			end
		end,
		onRelease = function(alpha)
			local _result = onRelease
			if _result ~= nil then
				_result = _result(alpha * (max - min) + min)
			end
			return _result
		end,
	})
	if children then
		for _k, _v in pairs(children) do
			if type(_k) == "number" then
				_children[_length + 1 + _k] = _v
			else
				_children[_k] = _v
			end
		end
	end
	return Roact.createElement(Canvas, _attributes, _children)
end
local default = hooked(BrightSlider)
local function DragComponent(_param)
	local onChange = _param.onChange
	local onRelease = _param.onRelease
	local _binding = useState()
	local inputHandle = _binding[1]
	local setHandle = _binding[2]
	local updateValue = useCallback(function(alpha)
		alpha = math.clamp(alpha, 0, 1)
		onChange(alpha)
	end, {})
	local getValueFromPosition = useCallback(function(x, rbx)
		return (x - rbx.AbsolutePosition.X) / rbx.AbsoluteSize.X
	end, {})
	useEffect(function()
		return function()
			local _result = inputHandle
			if _result ~= nil then
				_result:Disconnect()
			end
		end
	end, {})
	return Roact.createElement("Frame", {
		Active = true,
		Size = scale(1, 1),
		BackgroundTransparency = 1,
		[Roact.Event.InputBegan] = function(rbx, input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local _result = inputHandle
				if _result ~= nil then
					_result:Disconnect()
				end
				local handle = UserInputService.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						updateValue(getValueFromPosition(input.Position.X, rbx))
					end
				end)
				setHandle(handle)
				updateValue(getValueFromPosition(input.Position.X, rbx))
			end
		end,
		[Roact.Event.InputEnded] = function(rbx, input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local _result = inputHandle
				if _result ~= nil then
					_result:Disconnect()
				end
				setHandle(nil)
				onRelease(getValueFromPosition(input.Position.X, rbx))
			end
		end,
	})
end
Drag = hooked(DragComponent)
return {
	default = default,
}

        end)
    end)
    hMod("Canvas", "ModuleScript", "Havoc.components.Canvas", "Havoc.components", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).hooked
local mapBinding = TS.import(script, script.Parent.Parent, "utils", "binding-util").mapBinding
local scale = TS.import(script, script.Parent.Parent, "utils", "udim2").scale
local function Canvas(_param)
	local size = _param.size
	if size == nil then
		size = scale(1, 1)
	end
	local position = _param.position
	if position == nil then
		position = scale(0, 0)
	end
	local anchor = _param.anchor
	local padding = _param.padding
	local clipsDescendants = _param.clipsDescendants
	local zIndex = _param.zIndex
	local onChange = _param.onChange
	if onChange == nil then
		onChange = {}
	end
	local children = _param[Roact.Children]
	local _attributes = {
		Size = size,
		Position = position,
		AnchorPoint = anchor,
		ClipsDescendants = clipsDescendants,
		BackgroundTransparency = 1,
		ZIndex = zIndex,
	}
	for _k, _v in pairs(onChange) do
		_attributes[Roact.Change[_k] ] = _v
	end
	local _children = {}
	local _length = #_children
	local _child = padding ~= nil and (Roact.createFragment({
		padding = Roact.createElement("UIPadding", {
			PaddingTop = mapBinding(padding.top, function(px)
				return UDim.new(0, px)
			end),
			PaddingRight = mapBinding(padding.right, function(px)
				return UDim.new(0, px)
			end),
			PaddingBottom = mapBinding(padding.bottom, function(px)
				return UDim.new(0, px)
			end),
			PaddingLeft = mapBinding(padding.left, function(px)
				return UDim.new(0, px)
			end),
		}),
	}))
	if _child then
		if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then
			_children[_length + 1] = _child
		else
			for _k, _v in ipairs(_child) do
				_children[_length + _k] = _v
			end
		end
	end
	_length = #_children
	if children then
		for _k, _v in pairs(children) do
			if type(_k) == "number" then
				_children[_length + _k] = _v
			else
				_children[_k] = _v
			end
		end
	end
	return Roact.createElement("Frame", _attributes, _children)
end
local default = hooked(Canvas)
return {
	default = default,
}

        end)
    end)
    hMod("Card", "ModuleScript", "Havoc.components.Card", "Havoc.components", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).hooked
local Acrylic = TS.import(script, script.Parent, "Acrylic").default
local Border = TS.import(script, script.Parent, "Border").default
local Canvas = TS.import(script, script.Parent, "Canvas").default
local Fill = TS.import(script, script.Parent, "Fill").default
local _Glow = TS.import(script, script.Parent, "Glow")
local Glow = _Glow.default
local GlowRadius = _Glow.GlowRadius
local useDelayedUpdate = TS.import(script, script.Parent.Parent, "hooks", "common", "use-delayed-update").useDelayedUpdate
local useSpring = TS.import(script, script.Parent.Parent, "hooks", "common", "use-spring").useSpring
local useIsPageOpen = TS.import(script, script.Parent.Parent, "hooks", "use-current-page").useIsPageOpen
local px = TS.import(script, script.Parent.Parent, "utils", "udim2").px
local function Card(_param)
	local index = _param.index
	local page = _param.page
	local theme = _param.theme
	local size = _param.size
	local position = _param.position
	local children = _param[Roact.Children]
	local isOpen = useIsPageOpen(page)
	local isActive = useDelayedUpdate(isOpen, index * 40)
	local _uDim2 = UDim2.new(UDim.new(), position.Y)
	local _arg0 = px((size.X.Offset + 48) * 2 - position.X.Offset, 0)
	local _arg0_1 = px(size.X.Offset + 48 * 2, 0)
	local positionWhenHidden = _uDim2 - _arg0 - _arg0_1
	local _attributes = {
		anchor = Vector2.new(0, 1),
		size = size,
		position = useSpring(isActive and position or positionWhenHidden, {
			frequency = 2,
			dampingRatio = 0.8,
		}),
	}
	local _children = {
		Roact.createElement(Glow, {
			radius = GlowRadius.Size198,
			size = UDim2.new(1, 100, 1, 96),
			position = px(-50, -28),
			color = theme.dropshadow,
			gradient = theme.dropshadowGradient,
			transparency = theme.dropshadowTransparency,
		}),
		Roact.createElement(Fill, {
			color = theme.background,
			gradient = theme.backgroundGradient,
			transparency = theme.transparency,
			radius = 16,
		}),
	}
	local _length = #_children
	if children then
		for _k, _v in pairs(children) do
			if type(_k) == "number" then
				_children[_length + _k] = _v
			else
				_children[_k] = _v
			end
		end
	end
	_length = #_children
	local _child = theme.acrylic and Roact.createFragment({
		acrylic = Roact.createElement(Acrylic),
	})
	if _child then
		if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then
			_children[_length + 1] = _child
		else
			for _k, _v in ipairs(_child) do
				_children[_length + _k] = _v
			end
		end
	end
	_length = #_children
	local _child_1 = theme.outlined and Roact.createElement(Border, {
		color = theme.foreground,
		radius = 16,
		transparency = 0.8,
	})
	if _child_1 then
		if _child_1.elements ~= nil or _child_1.props ~= nil and _child_1.component ~= nil then
			_children[_length + 1] = _child_1
		else
			for _k, _v in ipairs(_child_1) do
				_children[_length + _k] = _v
			end
		end
	end
	return Roact.createElement(Canvas, _attributes, _children)
end
local default = hooked(Card)
return {
	default = default,
}

        end)
    end)
    hMod("Fill", "ModuleScript", "Havoc.components.Fill", "Havoc.components", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).hooked
local mapBinding = TS.import(script, script.Parent.Parent, "utils", "binding-util").mapBinding
local hex = TS.import(script, script.Parent.Parent, "utils", "color3").hex
local scale = TS.import(script, script.Parent.Parent, "utils", "udim2").scale
local function Fill(_param)
	local color = _param.color
	if color == nil then
		color = hex("#ffffff")
	end
	local gradient = _param.gradient
	local transparency = _param.transparency
	if transparency == nil then
		transparency = 0
	end
	local radius = _param.radius
	if radius == nil then
		radius = 0
	end
	local children = _param[Roact.Children]
	local _attributes = {
		Size = scale(1, 1),
		BackgroundColor3 = color,
		BackgroundTransparency = transparency,
	}
	local _children = {}
	local _length = #_children
	local _child = gradient and (Roact.createFragment({
		gradient = Roact.createElement("UIGradient", {
			Color = gradient.color,
			Transparency = gradient.transparency,
			Rotation = gradient.rotation,
		}),
	}))
	if _child then
		if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then
			_children[_length + 1] = _child
		else
			for _k, _v in ipairs(_child) do
				_children[_length + _k] = _v
			end
		end
	end
	_length = #_children
	local _child_1 = radius ~= nil and (Roact.createFragment({
		corner = Roact.createElement("UICorner", {
			CornerRadius = mapBinding(radius, function(r)
				return r == "circular" and UDim.new(1, 0) or UDim.new(0, r)
			end),
		}),
	}))
	if _child_1 then
		if _child_1.elements ~= nil or _child_1.props ~= nil and _child_1.component ~= nil then
			_children[_length + 1] = _child_1
		else
			for _k, _v in ipairs(_child_1) do
				_children[_length + _k] = _v
			end
		end
	end
	_length = #_children
	if children then
		for _k, _v in pairs(children) do
			if type(_k) == "number" then
				_children[_length + _k] = _v
			else
				_children[_k] = _v
			end
		end
	end
	return Roact.createElement("Frame", _attributes, _children)
end
local default = hooked(Fill)
return {
	default = default,
}

        end)
    end)
    hMod("Glow", "ModuleScript", "Havoc.components.Glow", "Havoc.components", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local hooked = _roact_hooked.hooked
local useBinding = _roact_hooked.useBinding
local useScale = TS.import(script, script.Parent.Parent, "hooks", "use-scale").useScale
local asBinding = TS.import(script, script.Parent.Parent, "utils", "binding-util").asBinding
local map = TS.import(script, script.Parent.Parent, "utils", "number-util").map
local _udim2 = TS.import(script, script.Parent.Parent, "utils", "udim2")
local applyUDim2 = _udim2.applyUDim2
local px = _udim2.px
local Canvas = TS.import(script, script.Parent, "Canvas").default
local GlowRadius
do
	local _inverse = {}
	GlowRadius = setmetatable({}, {
		__index = _inverse,
	})
	GlowRadius.Size70 = "rbxassetid://8992230903"
	_inverse["rbxassetid://8992230903"] = "Size70"
	GlowRadius.Size146 = "rbxassetid://8992584561"
	_inverse["rbxassetid://8992584561"] = "Size146"
	GlowRadius.Size198 = "rbxassetid://8992230677"
	_inverse["rbxassetid://8992230677"] = "Size198"
end
local RADIUS_TO_CENTER_OFFSET = {
	[GlowRadius.Size70] = 70 / 2,
	[GlowRadius.Size146] = 146 / 2,
	[GlowRadius.Size198] = 198 / 2,
}
local function Glow(_param)
	local radius = _param.radius
	local size = _param.size
	local position = _param.position
	local color = _param.color
	local gradient = _param.gradient
	local transparency = _param.transparency
	if transparency == nil then
		transparency = 0
	end
	local maintainCornerRadius = _param.maintainCornerRadius
	local children = _param[Roact.Children]
	local _binding = useBinding(Vector2.new())
	local absoluteSize = _binding[1]
	local setAbsoluteSize = _binding[2]
	local scaleFactor = useScale()
	local centerOffset = RADIUS_TO_CENTER_OFFSET[radius]
	local sizeModifier = maintainCornerRadius and Roact.joinBindings({
		absoluteSize = absoluteSize,
		scaleFactor = scaleFactor,
		size = asBinding(size),
	}):map(function(_param_1)
		local absoluteSize = _param_1.absoluteSize
		local size = _param_1.size
		local scaleFactor = _param_1.scaleFactor
		local currentSize = applyUDim2(absoluteSize, size, scaleFactor)
		return px(math.max(currentSize.X, centerOffset * 2), math.max(currentSize.Y, centerOffset * 2))
	end) or size
	local transparencyModifier = maintainCornerRadius and Roact.joinBindings({
		absoluteSize = absoluteSize,
		scaleFactor = scaleFactor,
		size = asBinding(size),
		transparency = asBinding(transparency),
	}):map(function(_param_1)
		local absoluteSize = _param_1.absoluteSize
		local size = _param_1.size
		local transparency = _param_1.transparency
		local scaleFactor = _param_1.scaleFactor
		local minSize = centerOffset * 2
		local currentSize = applyUDim2(absoluteSize, UDim2.fromScale(size.X.Scale, size.Y.Scale), scaleFactor).X
		if currentSize < minSize then
			return 1 - (1 - transparency) * map(currentSize, 0, minSize, 0, 1)
		else
			return transparency
		end
	end) or transparency
	local _attributes = {
		onChange = {
			AbsoluteSize = maintainCornerRadius and function(rbx)
				return setAbsoluteSize(rbx.AbsoluteSize)
			end or nil,
		},
	}
	local _children = {}
	local _length = #_children
	local _attributes_1 = {
		Image = radius,
		ImageColor3 = color,
		ImageTransparency = transparencyModifier,
		ScaleType = "Slice",
		SliceCenter = Rect.new(Vector2.new(centerOffset, centerOffset), Vector2.new(centerOffset, centerOffset)),
		SliceScale = scaleFactor:map(function(factor)
			return factor * 0.1 + 0.9
		end),
		Size = sizeModifier,
		Position = position,
		BackgroundTransparency = 1,
	}
	local _children_1 = {}
	local _length_1 = #_children_1
	local _child = gradient and (Roact.createFragment({
		gradient = Roact.createElement("UIGradient", {
			Color = gradient.color,
			Transparency = gradient.transparency,
			Rotation = gradient.rotation,
		}),
	}))
	if _child then
		if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then
			_children_1[_length_1 + 1] = _child
		else
			for _k, _v in ipairs(_child) do
				_children_1[_length_1 + _k] = _v
			end
		end
	end
	_length_1 = #_children_1
	if children then
		for _k, _v in pairs(children) do
			if type(_k) == "number" then
				_children_1[_length_1 + _k] = _v
			else
				_children_1[_k] = _v
			end
		end
	end
	_children[_length + 1] = Roact.createElement("ImageLabel", _attributes_1, _children_1)
	return Roact.createElement(Canvas, _attributes, _children)
end
local default = hooked(Glow)
return {
	GlowRadius = GlowRadius,
	RADIUS_TO_CENTER_OFFSET = RADIUS_TO_CENTER_OFFSET,
	default = default,
}

        end)
    end)
    hMod("ParallaxImage", "ModuleScript", "Havoc.components.ParallaxImage", "Havoc.components", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local mapBinding = TS.import(script, script.Parent.Parent, "utils", "binding-util").mapBinding
local scale = TS.import(script, script.Parent.Parent, "utils", "udim2").scale
local function ParallaxImage(_param)
	local image = _param.image
	local imageSize = _param.imageSize
	local offset = _param.offset
	local padding = _param.padding
	local children = _param[Roact.Children]
	local _attributes = {
		Image = image,
	}
	local _arg0 = padding * 2
	_attributes.ImageRectSize = imageSize - _arg0
	_attributes.ImageRectOffset = mapBinding(offset, function(o)
		local _arg0_1 = o * padding
		return padding + _arg0_1
	end)
	_attributes.ScaleType = "Crop"
	_attributes.Size = scale(1, 1)
	_attributes.BackgroundTransparency = 1
	local _children = {}
	local _length = #_children
	if children then
		for _k, _v in pairs(children) do
			if type(_k) == "number" then
				_children[_length + _k] = _v
			else
				_children[_k] = _v
			end
		end
	end
	return Roact.createElement("ImageLabel", _attributes, _children)
end
local default = ParallaxImage
return {
	default = default,
}

        end)
    end)
    hMod("constants", "ModuleScript", "Havoc.constants", "Havoc", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local IS_DEV = getgenv == nil
local _condition = VERSION
if _condition == nil then
	_condition = "studio"
end
local VERSION_TAG = _condition
return {
	IS_DEV = IS_DEV,
	VERSION_TAG = VERSION_TAG,
}

        end)
    end)
    hInst("context", "Folder", "Havoc.context", "Havoc")
    hMod("scale-context", "ModuleScript", "Havoc.context.scale-context", "Havoc.context", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local ScaleContext = Roact.createContext((Roact.createBinding(1)))
return {
	ScaleContext = ScaleContext,
}

        end)
    end)
    hInst("hooks", "Folder", "Havoc.hooks", "Havoc")
    hInst("common", "Folder", "Havoc.hooks.common", "Havoc.hooks")
    hMod("flipper-hooks", "ModuleScript", "Havoc.hooks.common.flipper-hooks", "Havoc.hooks.common", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.getBinding = TS.import(script, script, "get-binding").getBinding
exports.useGoal = TS.import(script, script, "use-goal").useGoal
exports.useInstant = TS.import(script, script, "use-instant").useInstant
exports.useLinear = TS.import(script, script, "use-linear").useLinear
exports.useMotor = TS.import(script, script, "use-motor").useMotor
exports.useSpring = TS.import(script, script, "use-spring").useSpring
return exports

        end)
    end)
    hMod("get-binding", "ModuleScript", "Havoc.hooks.common.flipper-hooks.get-binding", "Havoc.hooks.common.flipper-hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local isMotor = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src).isMotor
local createBinding = TS.import(script, TS.getModule(script, "@rbxts", "roact").src).createBinding
local AssignedBinding = setmetatable({}, {
	__tostring = function()
		return "AssignedBinding"
	end,
})
local function getBinding(motor)
	assert(motor, "Missing argument #1: motor")
	local _arg0 = isMotor(motor)
	assert(_arg0, "Provided value is not a motor")
	if motor[AssignedBinding] ~= nil then
		return motor[AssignedBinding]
	end
	local binding, setBindingValue = createBinding(motor:getValue())
	motor:onStep(setBindingValue)
	motor[AssignedBinding] = binding
	return binding
end
return {
	getBinding = getBinding,
}

        end)
    end)
    hMod("use-goal", "ModuleScript", "Havoc.hooks.common.flipper-hooks.use-goal", "Havoc.hooks.common.flipper-hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local getBinding = TS.import(script, script.Parent, "get-binding").getBinding
local useMotor = TS.import(script, script.Parent, "use-motor").useMotor
local function useGoal(goal)
	local motor = useMotor(goal._targetValue)
	motor:setGoal(goal)
	return getBinding(motor)
end
return {
	useGoal = useGoal,
}

        end)
    end)
    hMod("use-instant", "ModuleScript", "Havoc.hooks.common.flipper-hooks.use-instant", "Havoc.hooks.common.flipper-hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Instant = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src).Instant
local useGoal = TS.import(script, script.Parent, "use-goal").useGoal
local function useInstant(targetValue)
	return useGoal(Instant.new(targetValue))
end
return {
	useInstant = useInstant,
}

        end)
    end)
    hMod("use-linear", "ModuleScript", "Havoc.hooks.common.flipper-hooks.use-linear", "Havoc.hooks.common.flipper-hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Linear = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src).Linear
local useGoal = TS.import(script, script.Parent, "use-goal").useGoal
local function useLinear(targetValue, options)
	return useGoal(Linear.new(targetValue, options))
end
return {
	useLinear = useLinear,
}

        end)
    end)
    hMod("use-motor", "ModuleScript", "Havoc.hooks.common.flipper-hooks.use-motor", "Havoc.hooks.common.flipper-hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local _flipper = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src)
local GroupMotor = _flipper.GroupMotor
local SingleMotor = _flipper.SingleMotor
local useMutable = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out.hooks).useMutable
local function createMotor(initialValue)
	if type(initialValue) == "number" then
		return SingleMotor.new(initialValue)
	elseif type(initialValue) == "table" then
		return GroupMotor.new(initialValue)
	else
		error("Invalid type for initialValue. Expected 'number' or 'table', got '" .. (tostring(initialValue) .. "'"))
	end
end
local function useMotor(initialValue)
	return useMutable(createMotor(initialValue)).current
end
return {
	useMotor = useMotor,
}

        end)
    end)
    hMod("use-spring", "ModuleScript", "Havoc.hooks.common.flipper-hooks.use-spring", "Havoc.hooks.common.flipper-hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Spring = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src).Spring
local useGoal = TS.import(script, script.Parent, "use-goal").useGoal
local function useSpring(targetValue, options)
	return useGoal(Spring.new(targetValue, options))
end
return {
	useSpring = useSpring,
}

        end)
    end)
    hMod("rodux-hooks", "ModuleScript", "Havoc.hooks.common.rodux-hooks", "Havoc.hooks.common", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local _roact_rodux_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-rodux-hooked").out)
local useBaseDispatch = _roact_rodux_hooked.useDispatch
local useBaseSelector = _roact_rodux_hooked.useSelector
local useBaseStore = _roact_rodux_hooked.useStore
local useSelector = useBaseSelector
local useDispatch = useBaseDispatch
local useStore = useBaseStore
local useAppSelector = useSelector
local useAppDispatch = useDispatch
local useAppStore = useStore
return {
	useSelector = useSelector,
	useDispatch = useDispatch,
	useStore = useStore,
	useAppSelector = useAppSelector,
	useAppDispatch = useAppDispatch,
	useAppStore = useAppStore,
}

        end)
    end)
    hMod("use-delayed-update", "ModuleScript", "Havoc.hooks.common.use-delayed-update", "Havoc.hooks.common", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local useEffect = _roact_hooked.useEffect
local useMutable = _roact_hooked.useMutable
local useState = _roact_hooked.useState
local _timeout = TS.import(script, script.Parent.Parent.Parent, "utils", "timeout")
local clearTimeout = _timeout.clearTimeout
local setTimeout = _timeout.setTimeout
local nextId = 0
local function clearUpdates(updates, laterThan)
	for id, update in pairs(updates) do
		if laterThan == nil or update.resolveTime >= laterThan then
			-- ▼ Map.delete ▼
			updates[id] = nil
			-- ▲ Map.delete ▲
			clearTimeout(update.timeout)
		end
	end
end
local function useDelayedUpdate(value, delay, isImmediate)
	local _binding = useState(value)
	local delayedValue = _binding[1]
	local setDelayedValue = _binding[2]
	local updates = useMutable({})
	useEffect(function()
		local _result = isImmediate
		if _result ~= nil then
			_result = _result(value)
		end
		if _result then
			clearUpdates(updates.current)
			setDelayedValue(value)
			return nil
		end
		local _original = nextId
		nextId += 1
		local id = _original
		local update = {
			timeout = setTimeout(function()
				setDelayedValue(value)
				-- ▼ Map.delete ▼
				updates.current[id] = nil
				-- ▲ Map.delete ▲
			end, delay),
			resolveTime = os.clock() + delay,
		}
		clearUpdates(updates.current, update.resolveTime)
		-- ▼ Map.set ▼
		updates.current[id] = update
		-- ▲ Map.set ▲
	end, { value })
	useEffect(function()
		return function()
			return clearUpdates(updates.current)
		end
	end, {})
	return delayedValue
end
return {
	useDelayedUpdate = useDelayedUpdate,
}

        end)
    end)
    hMod("use-did-mount", "ModuleScript", "Havoc.hooks.common.use-did-mount", "Havoc.hooks.common", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local useEffect = _roact_hooked.useEffect
local useMutable = _roact_hooked.useMutable
local function useDidMount(callback)
	local ref = useMutable(callback)
	useEffect(function()
		if ref.current then
			ref.current()
		end
	end, {})
	return ref
end
local function useIsMount()
	local ref = useMutable(true)
	useEffect(function()
		ref.current = false
	end, {})
	return ref.current
end
return {
	useDidMount = useDidMount,
	useIsMount = useIsMount,
}

        end)
    end)
    hMod("use-forced-update", "ModuleScript", "Havoc.hooks.common.use-forced-update", "Havoc.hooks.common", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local useCallback = _roact_hooked.useCallback
local useState = _roact_hooked.useState
local function useForcedUpdate()
	local _binding = useState(0)
	local setState = _binding[2]
	return useCallback(function()
		return setState(function(state)
			return state + 1
		end)
	end, {})
end
return {
	useForcedUpdate = useForcedUpdate,
}

        end)
    end)
    hMod("use-interval", "ModuleScript", "Havoc.hooks.common.use-interval", "Havoc.hooks.common", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local useEffect = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).useEffect
local _timeout = TS.import(script, script.Parent.Parent.Parent, "utils", "timeout")
local clearInterval = _timeout.clearInterval
local setInterval = _timeout.setInterval
local function useInterval(callback, delay, deps)
	if deps == nil then
		deps = {}
	end
	local _exp = function()
		if delay ~= nil then
			local interval = setInterval(callback, delay)
			return function()
				return clearInterval(interval)
			end
		end
	end
	local _array = { callback, delay }
	local _length = #_array
	table.move(deps, 1, #deps, _length + 1, _array)
	useEffect(_exp, _array)
	return setInterval
end
return {
	useInterval = useInterval,
}

        end)
    end)
    hMod("use-mouse-location", "ModuleScript", "Havoc.hooks.common.use-mouse-location", "Havoc.hooks.common", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local useBinding = _roact_hooked.useBinding
local useEffect = _roact_hooked.useEffect
local UserInputService = TS.import(script, TS.getModule(script, "@rbxts", "services")).UserInputService
local function useMouseLocation(onChange)
	local _binding = useBinding(UserInputService:GetMouseLocation())
	local location = _binding[1]
	local setLocation = _binding[2]
	useEffect(function()
		local handle = UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				setLocation(Vector2.new(input.Position.X, input.Position.Y))
				local _result = onChange
				if _result ~= nil then
					_result(Vector2.new(input.Position.X, input.Position.Y))
				end
			end
		end)
		return function()
			handle:Disconnect()
		end
	end, {})
	return location
end
return {
	useMouseLocation = useMouseLocation,
}

        end)
    end)
    hMod("use-promise", "ModuleScript", "Havoc.hooks.common.use-promise", "Havoc.hooks.common", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local useEffect = _roact_hooked.useEffect
local useReducer = _roact_hooked.useReducer
local function resolvePromise(promise)
	if type(promise) == "function" then
		return promise()
	end
	return promise
end
local states = {
	pending = "pending",
	rejected = "rejected",
	resolved = "resolved",
}
local defaultState = {
	err = nil,
	result = nil,
	state = states.pending,
}
local function reducer(state, action)
	local _exp = action.type
	repeat
		if _exp == (states.pending) then
			return defaultState
		end
		if _exp == (states.resolved) then
			return {
				err = nil,
				result = action.payload,
				state = states.resolved,
			}
		end
		if _exp == (states.rejected) then
			return {
				err = action.payload,
				result = nil,
				state = states.rejected,
			}
		end
		return state
	until true
end
local function usePromise(promise, deps)
	if deps == nil then
		deps = {}
	end
	local _binding = useReducer(reducer, defaultState)
	local _binding_1 = _binding[1]
	local err = _binding_1.err
	local result = _binding_1.result
	local state = _binding_1.state
	local dispatch = _binding[2]
	useEffect(function()
		promise = resolvePromise(promise)
		if not promise then
			return nil
		end
		local canceled = false
		dispatch({
			type = states.pending,
		})
		local _arg0 = function(result)
			return not canceled and dispatch({
				payload = result,
				type = states.resolved,
			})
		end
		local _arg1 = function(err)
			return not canceled and dispatch({
				payload = err,
				type = states.rejected,
			})
		end
		promise:andThen(_arg0, _arg1)
		return function()
			canceled = true
		end
	end, deps)
	return { result, err, state }
end
return {
	usePromise = usePromise,
}

        end)
    end)
    hMod("use-set-state", "ModuleScript", "Havoc.hooks.common.use-set-state", "Havoc.hooks.common", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local useState = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).useState
local function useSetState(initialState)
	local _binding = useState(initialState)
	local state = _binding[1]
	local setState = _binding[2]
	local merge = function(action)
		return setState(function(s)
			local _object = {}
			if type(s) == "table" then
				for _k, _v in pairs(s) do
					_object[_k] = _v
				end
			end
			local _result
			if type(action) == "function" then
				_result = action(s)
			else
				_result = action
			end
			if type(_result) == "table" then
				for _k, _v in pairs(_result) do
					_object[_k] = _v
				end
			end
			return _object
		end)
	end
	return { state, merge }
end
return {
	default = useSetState,
}

        end)
    end)
    hMod("use-spring", "ModuleScript", "Havoc.hooks.common.use-spring", "Havoc.hooks.common", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Spring = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src).Spring
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _flipper_hooks = TS.import(script, script.Parent, "flipper-hooks")
local getBinding = _flipper_hooks.getBinding
local useMotor = _flipper_hooks.useMotor
local useNumberSpring = _flipper_hooks.useSpring
local supportedTypes = {
	number = useNumberSpring,
	Color3 = function(color, options)
		local motor = useMotor({ color.R, color.G, color.B })
		motor:setGoal({ Spring.new(color.R, options), Spring.new(color.G, options), Spring.new(color.B, options) })
		return getBinding(motor):map(function(_param)
			local r = _param[1]
			local g = _param[2]
			local b = _param[3]
			return Color3.new(r, g, b)
		end)
	end,
	UDim = function(udim, options)
		local motor = useMotor({ udim.Scale, udim.Offset })
		motor:setGoal({ Spring.new(udim.Scale, options), Spring.new(udim.Offset, options) })
		return getBinding(motor):map(function(_param)
			local s = _param[1]
			local o = _param[2]
			return UDim.new(s, o)
		end)
	end,
	UDim2 = function(udim2, options)
		local motor = useMotor({ udim2.X.Scale, udim2.X.Offset, udim2.Y.Scale, udim2.Y.Offset })
		motor:setGoal({ Spring.new(udim2.X.Scale, options), Spring.new(udim2.X.Offset, options), Spring.new(udim2.Y.Scale, options), Spring.new(udim2.Y.Offset, options) })
		return getBinding(motor):map(function(_param)
			local xS = _param[1]
			local xO = _param[2]
			local yS = _param[3]
			local yO = _param[4]
			return UDim2.new(xS, math.round(xO), yS, math.round(yO))
		end)
	end,
	Vector2 = function(vector2, options)
		local motor = useMotor({ vector2.X, vector2.Y })
		motor:setGoal({ Spring.new(vector2.X, options), Spring.new(vector2.Y, options) })
		return getBinding(motor):map(function(_param)
			local X = _param[1]
			local Y = _param[2]
			return Vector2.new(X, Y)
		end)
	end,
}
local function useSpring(value, options)
	if not options then
		return (Roact.createBinding(value))
	end
	local useSpring = supportedTypes[typeof(value)]
	local _arg1 = "useAnySpring: " .. (typeof(value) .. " is not supported")
	assert(useSpring, _arg1)
	return useSpring(value, options)
end
return {
	useSpring = useSpring,
}

        end)
    end)
    hMod("use-viewport-size", "ModuleScript", "Havoc.hooks.common.use-viewport-size", "Havoc.hooks.common", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local useBinding = _roact_hooked.useBinding
local useEffect = _roact_hooked.useEffect
local useState = _roact_hooked.useState
local Workspace = TS.import(script, TS.getModule(script, "@rbxts", "services")).Workspace
local function useViewportSize(onChange)
	local _binding = useState(Workspace.CurrentCamera)
	local camera = _binding[1]
	local setCamera = _binding[2]
	local _binding_1 = useBinding(camera.ViewportSize)
	local size = _binding_1[1]
	local setSize = _binding_1[2]
	useEffect(function()
		local handle = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
			if Workspace.CurrentCamera then
				setCamera(Workspace.CurrentCamera)
				setSize(Workspace.CurrentCamera.ViewportSize)
				local _result = onChange
				if _result ~= nil then
					_result(Workspace.CurrentCamera.ViewportSize)
				end
			end
		end)
		return function()
			handle:Disconnect()
		end
	end, {})
	useEffect(function()
		local handle = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			setSize(camera.ViewportSize)
			local _result = onChange
			if _result ~= nil then
				_result(camera.ViewportSize)
			end
		end)
		return function()
			handle:Disconnect()
		end
	end, { camera })
	return size
end
return {
	useViewportSize = useViewportSize,
}

        end)
    end)
    hMod("use-current-page", "ModuleScript", "Havoc.hooks.use-current-page", "Havoc.hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local useAppSelector = TS.import(script, script.Parent, "common", "rodux-hooks").useAppSelector
local function useCurrentPage()
	return useAppSelector(function(state)
		return state.dashboard.page
	end)
end
local function useIsPageOpen(page)
	return useAppSelector(function(state)
		return state.dashboard.page == page
	end)
end
return {
	useCurrentPage = useCurrentPage,
	useIsPageOpen = useIsPageOpen,
}

        end)
    end)
    hMod("use-friends", "ModuleScript", "Havoc.hooks.use-friends", "Havoc.hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local useMemo = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).useMemo
local Players = TS.import(script, TS.getModule(script, "@rbxts", "services")).Players
local usePromise = TS.import(script, script.Parent, "common", "use-promise").usePromise
local function useFriends(deps)
	return usePromise(TS.async(function()
		return Players.LocalPlayer:GetFriendsOnline()
	end), deps)
end
local function useFriendsPlaying(deps)
	local _binding = useFriends(deps)
	local friends = _binding[1]
	local err = _binding[2]
	local status = _binding[3]
	local _friendsPlaying = friends
	if _friendsPlaying ~= nil then
		local _arg0 = function(friend)
			return friend.PlaceId ~= nil and friend.GameId ~= nil
		end
		-- ▼ ReadonlyArray.filter ▼
		local _newValue = {}
		local _length = 0
		for _k, _v in ipairs(_friendsPlaying) do
			if _arg0(_v, _k - 1, _friendsPlaying) == true then
				_length += 1
				_newValue[_length] = _v
			end
		end
		-- ▲ ReadonlyArray.filter ▲
		_friendsPlaying = _newValue
	end
	local friendsPlaying = _friendsPlaying
	return { friendsPlaying, err, status }
end
local function useFriendActivity(deps)
	local _binding = useFriendsPlaying(deps)
	local friends = _binding[1]
	local err = _binding[2]
	local status = _binding[3]
	local games = useMemo(function()
		return {}
	end, deps)
	if not friends or #games > 0 then
		return { games, err, status }
	end
	local _arg0 = function(friend)
		local _arg0_1 = function(g)
			return g.placeId == friend.PlaceId
		end
		-- ▼ ReadonlyArray.find ▼
		local _result = nil
		for _i, _v in ipairs(games) do
			if _arg0_1(_v, _i - 1, games) == true then
				_result = _v
				break
			end
		end
		-- ▲ ReadonlyArray.find ▲
		local gameActivity = _result
		if not gameActivity then
			gameActivity = {
				friends = { friend },
				placeId = friend.PlaceId,
				thumbnail = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. (tostring(friend.PlaceId) .. "&width=768&height=432&format=png"),
			}
			local _gameActivity = gameActivity
			-- ▼ Array.push ▼
			games[#games + 1] = _gameActivity
			-- ▲ Array.push ▲
		else
			local _friends = gameActivity.friends
			-- ▼ Array.push ▼
			_friends[#_friends + 1] = friend
			-- ▲ Array.push ▲
		end
	end
	-- ▼ ReadonlyArray.forEach ▼
	for _k, _v in ipairs(friends) do
		_arg0(_v, _k - 1, friends)
	end
	-- ▲ ReadonlyArray.forEach ▲
	return { games, err, status }
end
return {
	useFriends = useFriends,
	useFriendsPlaying = useFriendsPlaying,
	useFriendActivity = useFriendActivity,
}

        end)
    end)
    hMod("use-parallax-offset", "ModuleScript", "Havoc.hooks.use-parallax-offset", "Havoc.hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Spring = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src).Spring
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _flipper_hooks = TS.import(script, script.Parent, "common", "flipper-hooks")
local getBinding = _flipper_hooks.getBinding
local useMotor = _flipper_hooks.useMotor
local useMouseLocation = TS.import(script, script.Parent, "common", "use-mouse-location").useMouseLocation
local useViewportSize = TS.import(script, script.Parent, "common", "use-viewport-size").useViewportSize
local function useParallaxOffset()
	local mouseLocationMotor = useMotor({ 0, 0 })
	local mouseLocation = getBinding(mouseLocationMotor)
	local viewportSize = useViewportSize()
	local offset = Roact.joinBindings({
		viewportSize = viewportSize,
		mouseLocation = mouseLocation,
	}):map(function(_param)
		local viewportSize = _param.viewportSize
		local _binding = _param.mouseLocation
		local x = _binding[1]
		local y = _binding[2]
		return Vector2.new((x - viewportSize.X / 2) / viewportSize.X, (y - viewportSize.Y / 2) / viewportSize.Y)
	end)
	useMouseLocation(function(location)
		mouseLocationMotor:setGoal({ Spring.new(location.X, {
			dampingRatio = 5,
		}), Spring.new(location.Y, {
			dampingRatio = 5,
		}) })
	end)
	return offset
end
return {
	useParallaxOffset = useParallaxOffset,
}

        end)
    end)
    hMod("use-scale", "ModuleScript", "Havoc.hooks.use-scale", "Havoc.hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local useContext = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).useContext
local ScaleContext = TS.import(script, script.Parent.Parent, "context", "scale-context").ScaleContext
local defaultScale = Roact.createBinding(1)
local function useScale()
	local _condition = useContext(ScaleContext)
	if _condition == nil then
		_condition = defaultScale
	end
	return _condition
end
return {
	useScale = useScale,
}

        end)
    end)
    hMod("use-theme", "ModuleScript", "Havoc.hooks.use-theme", "Havoc.hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local useAppSelector = TS.import(script, script.Parent, "common", "rodux-hooks").useAppSelector
local getThemes = TS.import(script, script.Parent.Parent, "themes").getThemes
local darkTheme = TS.import(script, script.Parent.Parent, "themes", "sorbet").darkTheme
local _exp = getThemes()
local _arg0 = function(t)
	return { t.name, t }
end
-- ▼ ReadonlyArray.map ▼
local _newValue = table.create(#_exp)
for _k, _v in ipairs(_exp) do
	_newValue[_k] = _arg0(_v, _k - 1, _exp)
end
-- ▲ ReadonlyArray.map ▲
local _map = {}
for _, _v in ipairs(_newValue) do
	_map[_v[1] ] = _v[2]
end
local THEME_MAP = _map
local function useTheme(key)
	return useAppSelector(function(state)
		local themeName = state.options.currentTheme
		local _condition = THEME_MAP[themeName]
		if _condition == nil then
			_condition = darkTheme
		end
		local theme = _condition
		return theme[key]
	end)
end
return {
	useTheme = useTheme,
}

        end)
    end)
    hMod("jobs", "ModuleScript", "Havoc.jobs", "Havoc", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.include.RuntimeLib)
local exports = {}
exports.setStore = TS.import(script, script, "helpers", "job-store").setStore
TS.import(script, script, "acrylic")
TS.import(script, script, "freecam")
TS.import(script, script, "server")
TS.import(script, script, "character", "flight")
TS.import(script, script, "character", "ghost")
TS.import(script, script, "character", "godmode")
TS.import(script, script, "character", "humanoid")
TS.import(script, script, "character", "refresh")
TS.import(script, script, "players", "hide")
TS.import(script, script, "players", "kill")
TS.import(script, script, "players", "spectate")
TS.import(script, script, "players", "teleport")
TS.import(script, script, "players", "facebang")
return exports

        end)
    end)
    hMod("acrylic", "ModuleScript", "Havoc.jobs.acrylic", "Havoc.jobs", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Make = TS.import(script, TS.getModule(script, "@rbxts", "make"))
local Lighting = TS.import(script, TS.getModule(script, "@rbxts", "services")).Lighting
local getStore = TS.import(script, script.Parent, "helpers", "job-store").getStore
local setTimeout = TS.import(script, script.Parent.Parent, "utils", "timeout").setTimeout
local baseEffect = Make("DepthOfFieldEffect", {
	FarIntensity = 0,
	InFocusRadius = 0.1,
	NearIntensity = 1,
})
local depthOfFieldDefaults = {}
local function enableAcrylic()
	for effect in pairs(depthOfFieldDefaults) do
		effect.Enabled = false
	end
	baseEffect.Parent = Lighting
end
local function disableAcrylic()
	for effect, defaults in pairs(depthOfFieldDefaults) do
		effect.Enabled = defaults.enabled
	end
	baseEffect.Parent = nil
end
local main = TS.async(function()
	local store = TS.await(getStore())
	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("DepthOfFieldEffect") then
			local _arg1 = {
				enabled = effect.Enabled,
			}
			-- ▼ Map.set ▼
			depthOfFieldDefaults[effect] = _arg1
			-- ▲ Map.set ▲
		end
	end
	local timeout
	store.changed:connect(function(newState)
		local _result = timeout
		if _result ~= nil then
			_result:clear()
		end
		timeout = nil
		if not newState.dashboard.isOpen then
			timeout = setTimeout(disableAcrylic, 500)
			return nil
		end
		if newState.options.config.acrylicBlur then
			enableAcrylic()
		else
			disableAcrylic()
		end
	end)
end)
main():catch(function(err)
	warn("[acrylic-worker] " .. tostring(err))
end)
return nil

        end)
    end)
    hInst("character", "Folder", "Havoc.jobs.character", "Havoc.jobs")
    hMod("flight", "ModuleScript", "Havoc.jobs.character.flight", "Havoc.jobs.character", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local _flipper = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src)
local GroupMotor = _flipper.GroupMotor
local Spring = _flipper.Spring
local _services = TS.import(script, TS.getModule(script, "@rbxts", "services"))
local Players = _services.Players
local RunService = _services.RunService
local UserInputService = _services.UserInputService
local Workspace = _services.Workspace
local onJobChange = TS.import(script, script.Parent.Parent, "helpers", "job-store").onJobChange
local player = Players.LocalPlayer
local moveDirection = {
	forward = Vector3.new(),
	backward = Vector3.new(),
	left = Vector3.new(),
	right = Vector3.new(),
	up = Vector3.new(),
	down = Vector3.new(),
}
local enabled = false
local speed = 16
local humanoidRoot
local coordinate
local coordinateSpring = GroupMotor.new({ 0, 0, 0 }, false)
local resetCoordinate, resetSpring, updateDirection, updateCoordinate
local main = TS.async(function()
	TS.await(onJobChange("flight", function(job)
		enabled = job.active
		speed = job.value
		if enabled then
			resetCoordinate()
			resetSpring()
		end
	end))
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return nil
		end
		updateDirection(input.KeyCode, true)
	end)
	UserInputService.InputEnded:Connect(function(input)
		updateDirection(input.KeyCode, false)
	end)
	RunService.Heartbeat:Connect(function(deltaTime)
		if enabled and (humanoidRoot and coordinate) then
			updateCoordinate(deltaTime)
			coordinateSpring:setGoal({ Spring.new(coordinate.X), Spring.new(coordinate.Y), Spring.new(coordinate.Z) })
			coordinateSpring:step(deltaTime)
			local _binding = coordinateSpring:getValue()
			local x = _binding[1]
			local y = _binding[2]
			local z = _binding[3]
			humanoidRoot.AssemblyLinearVelocity = Vector3.new()
			local _rotation = Workspace.CurrentCamera.CFrame.Rotation
			local _vector3 = Vector3.new(x, y, z)
			humanoidRoot.CFrame = _rotation + _vector3
		end
	end)
	RunService.RenderStepped:Connect(function()
		if enabled and (humanoidRoot and coordinate) then
			local _rotation = Workspace.CurrentCamera.CFrame.Rotation
			local _position = humanoidRoot.CFrame.Position
			humanoidRoot.CFrame = _rotation + _position
		end
	end)
	player.CharacterAdded:Connect(function(character)
		local newHumanoidRoot = character:WaitForChild("HumanoidRootPart", 5)
		if newHumanoidRoot and newHumanoidRoot:IsA("BasePart") then
			humanoidRoot = newHumanoidRoot
		end
		resetCoordinate()
		resetSpring()
	end)
	local _currentHumanoidRoot = player.Character
	if _currentHumanoidRoot ~= nil then
		_currentHumanoidRoot = _currentHumanoidRoot:FindFirstChild("HumanoidRootPart")
	end
	local currentHumanoidRoot = _currentHumanoidRoot
	if currentHumanoidRoot and currentHumanoidRoot:IsA("BasePart") then
		humanoidRoot = currentHumanoidRoot
		resetCoordinate()
	end
end)
local function getUnitDirection()
	local sum = Vector3.new()
	for _, v3 in pairs(moveDirection) do
		sum = sum + v3
	end
	return sum.Magnitude > 0 and sum.Unit or sum
end
function resetCoordinate()
	if not humanoidRoot then
		return nil
	end
	local _binding = Workspace.CurrentCamera.CFrame
	local XVector = _binding.XVector
	local YVector = _binding.YVector
	local ZVector = _binding.ZVector
	coordinate = CFrame.fromMatrix(humanoidRoot.Position, XVector, YVector, ZVector)
end
function resetSpring()
	if not coordinate then
		return nil
	end
	coordinateSpring = GroupMotor.new({ coordinate.X, coordinate.Y, coordinate.Z }, false)
end
function updateCoordinate(deltaTime)
	if not coordinate then
		return nil
	end
	local _binding = Workspace.CurrentCamera.CFrame
	local XVector = _binding.XVector
	local YVector = _binding.YVector
	local ZVector = _binding.ZVector
	local direction = getUnitDirection()
	if direction.Magnitude > 0 then
		local _arg0 = speed * deltaTime
		local _binding_1 = direction * _arg0
		local X = _binding_1.X
		local Y = _binding_1.Y
		local Z = _binding_1.Z
		local _exp = CFrame.fromMatrix(coordinate.Position, XVector, YVector, ZVector)
		local _cFrame = CFrame.new(X, Y, Z)
		coordinate = _exp * _cFrame
	else
		coordinate = CFrame.fromMatrix(coordinate.Position, XVector, YVector, ZVector)
	end
end
function updateDirection(code, begin)
	repeat
		if code == (Enum.KeyCode.W) then
			moveDirection.forward = begin and Vector3.new(0, 0, -1) or Vector3.new()
			break
		end
		if code == (Enum.KeyCode.S) then
			moveDirection.backward = begin and Vector3.new(0, 0, 1) or Vector3.new()
			break
		end
		if code == (Enum.KeyCode.A) then
			moveDirection.left = begin and Vector3.new(-1, 0, 0) or Vector3.new()
			break
		end
		if code == (Enum.KeyCode.D) then
			moveDirection.right = begin and Vector3.new(1, 0, 0) or Vector3.new()
			break
		end
		if code == (Enum.KeyCode.Q) then
			moveDirection.up = begin and Vector3.new(0, -1, 0) or Vector3.new()
			break
		end
		if code == (Enum.KeyCode.E) then
			moveDirection.down = begin and Vector3.new(0, 1, 0) or Vector3.new()
			break
		end
	until true
end
main():catch(function(err)
	warn("[flight-worker] " .. tostring(err))
end)
return nil

        end)
    end)
    hMod("ghost", "ModuleScript", "Havoc.jobs.character.ghost", "Havoc.jobs.character", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local _services = TS.import(script, TS.getModule(script, "@rbxts", "services"))
local Players = _services.Players
local Workspace = _services.Workspace
local _job_store = TS.import(script, script.Parent.Parent, "helpers", "job-store")
local getStore = _job_store.getStore
local onJobChange = _job_store.onJobChange
local player = Players.LocalPlayer
local screenGuisWithResetOnSpawn = {}
local originalCharacter
local ghostCharacter
local lastPosition
local function disableResetOnSpawn()
	local playerGui = player:FindFirstChildWhichIsA("PlayerGui")
	if playerGui then
		for _, object in ipairs(playerGui:GetChildren()) do
			if object:IsA("ScreenGui") and object.ResetOnSpawn then
				-- ▼ Array.push ▼
				screenGuisWithResetOnSpawn[#screenGuisWithResetOnSpawn + 1] = object
				-- ▲ Array.push ▲
				object.ResetOnSpawn = false
			end
		end
	end
end
local function enableResetOnSpawn()
	for _, screenGui in ipairs(screenGuisWithResetOnSpawn) do
		screenGui.ResetOnSpawn = true
	end
	-- ▼ Array.clear ▼
	table.clear(screenGuisWithResetOnSpawn)
	-- ▲ Array.clear ▲
end
local deactivate, activateGhost, deactivateOnCharacterAdded, deactivateGhost
local main = TS.async(function()
	TS.await(onJobChange("ghost", function(job, state)
		if state.jobs.refresh.active and job.active then
			deactivate()
		elseif job.active then
			activateGhost():andThen(deactivateOnCharacterAdded):catch(function(err)
				warn("[ghost-worker-active] " .. tostring(err))
				deactivate()
			end)
		elseif not state.jobs.refresh.active then
			deactivateGhost():catch(function(err)
				warn("[ghost-worker-inactive] " .. tostring(err))
			end)
		end
	end))
end)
deactivate = TS.async(function()
	local store = TS.await(getStore())
	store:dispatch({
		type = "jobs/setJobActive",
		jobName = "ghost",
		active = false,
	})
end)
deactivateOnCharacterAdded = TS.async(function()
	TS.await(TS.Promise.fromEvent(player.CharacterAdded, function(character)
		return character ~= originalCharacter and character ~= ghostCharacter
	end))
	TS.await(deactivate())
end)
activateGhost = TS.async(function()
	local character = player.Character
	local _humanoid = character
	if _humanoid ~= nil then
		_humanoid = _humanoid:FindFirstChildWhichIsA("Humanoid")
	end
	local humanoid = _humanoid
	if not character or not humanoid then
		error("Character or Humanoid is null")
	end
	character.Archivable = true
	ghostCharacter = character:Clone()
	character.Archivable = false
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local _result = rootPart
	if _result ~= nil then
		_result = _result:IsA("BasePart")
	end
	lastPosition = _result and rootPart.CFrame or nil
	originalCharacter = character
	local ghostHumanoid = ghostCharacter:FindFirstChildWhichIsA("Humanoid")
	for _, child in ipairs(ghostCharacter:GetDescendants()) do
		if child:IsA("BasePart") then
			child.Transparency = 1 - (1 - child.Transparency) * 0.5
		end
	end
	if ghostHumanoid then
		ghostHumanoid.DisplayName = utf8.char(128123)
	end
	local _result_1 = ghostCharacter:FindFirstChild("Animate")
	if _result_1 ~= nil then
		_result_1:Destroy()
	end
	local animation = originalCharacter:FindFirstChild("Animate")
	if animation then
		animation.Disabled = true
		animation.Parent = ghostCharacter
	end
	disableResetOnSpawn()
	ghostCharacter.Parent = character.Parent
	player.Character = ghostCharacter
	Workspace.CurrentCamera.CameraSubject = ghostHumanoid
	enableResetOnSpawn()
	if animation then
		animation.Disabled = false
	end
	local handle
	handle = humanoid.Died:Connect(function()
		handle:Disconnect()
		deactivate()
	end)
end)
deactivateGhost = TS.async(function()
	if not originalCharacter or not ghostCharacter then
		return nil
	end
	local rootPart = originalCharacter:FindFirstChild("HumanoidRootPart")
	local ghostRootPart = ghostCharacter:FindFirstChild("HumanoidRootPart")
	local _result = ghostRootPart
	if _result ~= nil then
		_result = _result:IsA("BasePart")
	end
	local currentPosition = _result and ghostRootPart.CFrame or nil
	local animation = ghostCharacter:FindFirstChild("Animate")
	if animation then
		animation.Disabled = true
		animation.Parent = nil
	end
	ghostCharacter:Destroy()
	local humanoid = originalCharacter:FindFirstChildWhichIsA("Humanoid")
	local _result_1 = humanoid
	if _result_1 ~= nil then
		local _exp = _result_1:GetPlayingAnimationTracks()
		local _arg0 = function(track)
			return track:Stop()
		end
		-- ▼ ReadonlyArray.forEach ▼
		for _k, _v in ipairs(_exp) do
			_arg0(_v, _k - 1, _exp)
		end
		-- ▲ ReadonlyArray.forEach ▲
	end
	local position = currentPosition or lastPosition
	local _result_2 = rootPart
	if _result_2 ~= nil then
		_result_2 = _result_2:IsA("BasePart")
	end
	local _condition = _result_2
	if _condition then
		_condition = position
	end
	if _condition then
		rootPart.CFrame = position
	end
	disableResetOnSpawn()
	player.Character = originalCharacter
	Workspace.CurrentCamera.CameraSubject = humanoid
	enableResetOnSpawn()
	if animation then
		animation.Parent = originalCharacter
		animation.Disabled = false
	end
	originalCharacter = nil
	ghostCharacter = nil
	lastPosition = nil
end)
main():catch(function(err)
	warn("[ghost-worker] " .. tostring(err))
end)
return nil

        end)
    end)
    hMod("godmode", "ModuleScript", "Havoc.jobs.character.godmode", "Havoc.jobs.character", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local _services = TS.import(script, TS.getModule(script, "@rbxts", "services"))
local Players = _services.Players
local Workspace = _services.Workspace
local _job_store = TS.import(script, script.Parent.Parent, "helpers", "job-store")
local getStore = _job_store.getStore
local onJobChange = _job_store.onJobChange
local player = Players.LocalPlayer
local currentCharacter
local deactivate, activateGodmode, deactivateOnCharacterAdded
local main = TS.async(function()
	local function errorHandler(err)
		warn("[godmode-worker] " .. tostring(err))
		deactivate()
	end
	TS.await(onJobChange("godmode", function(job, state)
		if state.jobs.ghost.active and job.active then
			deactivate()
		elseif job.active then
			activateGodmode():andThen(deactivateOnCharacterAdded):catch(errorHandler)
		end
	end))
end)
deactivate = TS.async(function()
	local store = TS.await(getStore())
	store:dispatch({
		type = "jobs/setJobActive",
		jobName = "godmode",
		active = false,
	})
end)
deactivateOnCharacterAdded = TS.async(function()
	local store = TS.await(getStore())
	TS.await(TS.Promise.fromEvent(player.CharacterAdded, function(character)
		local jobs = store:getState().jobs
		return not jobs.ghost.active and character ~= currentCharacter
	end))
	TS.await(deactivate())
end)
activateGodmode = TS.async(function()
	local cameraCFrame = Workspace.CurrentCamera.CFrame
	local character = player.Character
	if not character then
		error("Character is null")
	end
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then
		error("No humanoid found")
	end
	local mockHumanoid = humanoid:Clone()
	mockHumanoid.Parent = character
	currentCharacter = character
	player.Character = nil
	mockHumanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	mockHumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	mockHumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	mockHumanoid.BreakJointsOnDeath = true
	mockHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid:Destroy()
	player.Character = character
	Workspace.CurrentCamera.CameraSubject = mockHumanoid
	task.defer(function()
		Workspace.CurrentCamera.CFrame = cameraCFrame
	end)
	local animation = character:FindFirstChild("Animate")
	if animation then
		animation.Disabled = true
		animation.Disabled = false
	end
	mockHumanoid.MaxHealth = math.huge
	mockHumanoid.Health = mockHumanoid.MaxHealth
end)
main():catch(function(err)
	warn("[godmode-worker] " .. tostring(err))
end)
return nil

        end)
    end)
    hMod("humanoid", "ModuleScript", "Havoc.jobs.character.humanoid", "Havoc.jobs.character", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Players = TS.import(script, TS.getModule(script, "@rbxts", "services")).Players
local _job_store = TS.import(script, script.Parent.Parent, "helpers", "job-store")
local getStore = _job_store.getStore
local onJobChange = _job_store.onJobChange
local JUMP_POWER_CONSTANT = 349.24
local player = Players.LocalPlayer
local defaults = {
	walkSpeed = 16,
	jumpHeight = 7.2,
}
local setDefaultWalkSpeed, updateWalkSpeed, setDefaultJumpHeight, updateJumpHeight
local main = TS.async(function()
	local store = TS.await(getStore())
	local _humanoid = player.Character
	if _humanoid ~= nil then
		_humanoid = _humanoid:FindFirstChildWhichIsA("Humanoid")
	end
	local humanoid = _humanoid
	local state = store:getState()
	local walkSpeedJob = state.jobs.walkSpeed
	local jumpHeightJob = state.jobs.jumpHeight
	TS.await(onJobChange("walkSpeed", function(job)
		if job.active and not walkSpeedJob.active then
			setDefaultWalkSpeed(humanoid)
		end
		walkSpeedJob = job
		updateWalkSpeed(humanoid, walkSpeedJob)
	end))
	TS.await(onJobChange("jumpHeight", function(job)
		if job.active and not jumpHeightJob.active then
			setDefaultJumpHeight(humanoid)
		end
		jumpHeightJob = job
		updateJumpHeight(humanoid, jumpHeightJob)
	end))
	player.CharacterAdded:Connect(function(character)
		local newHumanoid = character:WaitForChild("Humanoid", 5)
		if newHumanoid and newHumanoid:IsA("Humanoid") then
			humanoid = newHumanoid
			setDefaultWalkSpeed(newHumanoid)
			setDefaultJumpHeight(newHumanoid)
			if walkSpeedJob.active then
				updateWalkSpeed(newHumanoid, walkSpeedJob)
			end
			if jumpHeightJob.active then
				updateJumpHeight(newHumanoid, jumpHeightJob)
			end
		end
	end)
	setDefaultWalkSpeed(humanoid)
	setDefaultJumpHeight(humanoid)
end)
function setDefaultWalkSpeed(humanoid)
	if humanoid then
		defaults.walkSpeed = humanoid.WalkSpeed
	end
end
function setDefaultJumpHeight(humanoid)
	if humanoid then
		defaults.jumpHeight = humanoid.JumpHeight
	end
end
function updateWalkSpeed(humanoid, walkSpeedJob)
	if not humanoid then
		return nil
	end
	if walkSpeedJob.active then
		humanoid.WalkSpeed = walkSpeedJob.value
	else
		humanoid.WalkSpeed = defaults.walkSpeed
	end
end
function updateJumpHeight(humanoid, jumpHeightJob)
	if not humanoid then
		return nil
	end
	if jumpHeightJob.active then
		humanoid.JumpHeight = jumpHeightJob.value
		if humanoid.UseJumpPower then
			humanoid.JumpPower = math.sqrt(JUMP_POWER_CONSTANT * jumpHeightJob.value)
		end
	else
		humanoid.JumpHeight = defaults.jumpHeight
		if humanoid.UseJumpPower then
			humanoid.JumpPower = math.sqrt(JUMP_POWER_CONSTANT * defaults.jumpHeight)
		end
	end
end
main():catch(function(err)
	warn("[humanoid-worker] " .. tostring(err))
end)
return nil

        end)
    end)
    hMod("refresh", "ModuleScript", "Havoc.jobs.character.refresh", "Havoc.jobs.character", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local _services = TS.import(script, TS.getModule(script, "@rbxts", "services"))
local Players = _services.Players
local Workspace = _services.Workspace
local _job_store = TS.import(script, script.Parent.Parent, "helpers", "job-store")
local getStore = _job_store.getStore
local onJobChange = _job_store.onJobChange
local MAX_RESPAWN_TIME = 10
local player = Players.LocalPlayer
local respawn
local main = TS.async(function()
	local store = TS.await(getStore())
	local function deactivate()
		store:dispatch({
			type = "jobs/setJobActive",
			jobName = "refresh",
			active = false,
		})
	end
	TS.await(onJobChange("refresh", function(job, state)
		if state.jobs.ghost.active and job.active then
			deactivate()
		elseif job.active then
			respawn():catch(function(err)
				return warn("[refresh-worker-respawn] " .. tostring(err))
			end):finally(function()
				return deactivate()
			end)
		end
	end))
end)
respawn = TS.async(function()
	local character = player.Character
	if not character then
		error("Character is null")
	end
	local _respawnLocation = (character:FindFirstChild("HumanoidRootPart"))
	if _respawnLocation ~= nil then
		_respawnLocation = _respawnLocation.CFrame
	end
	local respawnLocation = _respawnLocation
	local humanoid = character:FindFirstAncestorWhichIsA("Humanoid")
	local _result = humanoid
	if _result ~= nil then
		_result:ChangeState(Enum.HumanoidStateType.Dead)
	end
	character:ClearAllChildren()
	local mockCharacter = Instance.new("Model", Workspace)
	player.Character = mockCharacter
	player.Character = character
	mockCharacter:Destroy()
	if not respawnLocation then
		return nil
	end
	local newCharacter = TS.await(TS.Promise.fromEvent(player.CharacterAdded):timeout(MAX_RESPAWN_TIME, "CharacterAdded event timed out"))
	local humanoidRoot = newCharacter:WaitForChild("HumanoidRootPart", 5)
	if humanoidRoot and (humanoidRoot:IsA("BasePart") and respawnLocation) then
		task.delay(0.1, function()
			humanoidRoot.CFrame = respawnLocation
		end)
	end
end)
main():catch(function(err)
	warn("[refresh-worker] " .. tostring(err))
end)
return nil

        end)
    end)
    hMod("freecam", "ModuleScript", "Havoc.jobs.freecam", "Havoc.jobs", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local _freecam = TS.import(script, script.Parent, "helpers", "freecam")
local DisableFreecam = _freecam.DisableFreecam
local EnableFreecam = _freecam.EnableFreecam
local onJobChange = TS.import(script, script.Parent, "helpers", "job-store").onJobChange
local main = TS.async(function()
	TS.await(onJobChange("freecam", function(job)
		if job.active then
			EnableFreecam()
		else
			DisableFreecam()
		end
	end))
end)
main():catch(function(err)
	warn("[freecam-worker] " .. tostring(err))
end)
return nil

        end)
    end)
    hInst("helpers", "Folder", "Havoc.jobs.helpers", "Havoc.jobs")
    hMod("freecam", "ModuleScript", "Havoc.jobs.helpers.freecam", "Havoc.jobs.helpers", function()
        return (function(...)
------------------------------------------------------------------------
-- Freecam
-- Cinematic free camera for spectating and video production.
------------------------------------------------------------------------

local pi    = math.pi
local abs   = math.abs
local clamp = math.clamp
local exp   = math.exp
local rad   = math.rad
local sign  = math.sign
local sqrt  = math.sqrt
local tan   = math.tan

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	LocalPlayer = Players.LocalPlayer
end

local Camera = Workspace.CurrentCamera
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local newCamera = Workspace.CurrentCamera
	if newCamera then
		Camera = newCamera
	end
end)

------------------------------------------------------------------------

local TOGGLE_INPUT_PRIORITY = Enum.ContextActionPriority.Low.Value
local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value
local FREECAM_MACRO_KB = {Enum.KeyCode.LeftShift, Enum.KeyCode.P}

local FREECAM_RENDER_ID = game:GetService("HttpService"):GenerateGUID(false)

local NAV_GAIN = Vector3.new(1, 1, 1)*64
local PAN_GAIN = Vector2.new(0.75, 1)*8
local FOV_GAIN = 300

local PITCH_LIMIT = rad(90)

local VEL_STIFFNESS = 2.0
local PAN_STIFFNESS = 3.0
local FOV_STIFFNESS = 4.0

------------------------------------------------------------------------

local Spring = {} do
	Spring.__index = Spring

	function Spring.new(freq, pos)
		local self = setmetatable({}, Spring)
		self.f = freq
		self.p = pos
		self.v = pos*0
		return self
	end

	function Spring:Update(dt, goal)
		local f = self.f*2*pi
		local p0 = self.p
		local v0 = self.v

		local offset = goal - p0
		local decay = exp(-f*dt)

		local p1 = goal + (v0*dt - offset*(f*dt + 1))*decay
		local v1 = (f*dt*(offset*f - v0) + v0)*decay

		self.p = p1
		self.v = v1

		return p1
	end

	function Spring:Reset(pos)
		self.p = pos
		self.v = pos*0
	end
end

------------------------------------------------------------------------

local cameraPos = Vector3.new()
local cameraRot = Vector2.new()
local cameraFov = 0

local velSpring = Spring.new(VEL_STIFFNESS, Vector3.new())
local panSpring = Spring.new(PAN_STIFFNESS, Vector2.new())
local fovSpring = Spring.new(FOV_STIFFNESS, 0)

------------------------------------------------------------------------

local Input = {} do
	local thumbstickCurve do
		local K_CURVATURE = 2.0
		local K_DEADZONE = 0.15

		local function fCurve(x)
			return (exp(K_CURVATURE*x) - 1)/(exp(K_CURVATURE) - 1)
		end

		local function fDeadzone(x)
			return fCurve((x - K_DEADZONE)/(1 - K_DEADZONE))
		end

		function thumbstickCurve(x)
			return sign(x)*clamp(fDeadzone(abs(x)), 0, 1)
		end
	end

	local gamepad = {
		ButtonX = 0,
		ButtonY = 0,
		DPadDown = 0,
		DPadUp = 0,
		ButtonL2 = 0,
		ButtonR2 = 0,
		Thumbstick1 = Vector2.new(),
		Thumbstick2 = Vector2.new(),
	}

	local keyboard = {
		W = 0,
		A = 0,
		S = 0,
		D = 0,
		E = 0,
		Q = 0,
		U = 0,
		H = 0,
		J = 0,
		K = 0,
		I = 0,
		Y = 0,
		Up = 0,
		Down = 0,
		LeftShift = 0,
		RightShift = 0,
	}

	local mouse = {
		Delta = Vector2.new(),
		MouseWheel = 0,
	}

	local NAV_GAMEPAD_SPEED  = Vector3.new(1, 1, 1)
	local NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)
	local PAN_MOUSE_SPEED    = Vector2.new(1, 1)*(pi/64)
	local PAN_GAMEPAD_SPEED  = Vector2.new(1, 1)*(pi/8)
	local FOV_WHEEL_SPEED    = 1.0
	local FOV_GAMEPAD_SPEED  = 0.25
	local NAV_ADJ_SPEED      = 0.75
	local NAV_SHIFT_MUL      = 0.25

	local navSpeed = 1

	function Input.Vel(dt)
		navSpeed = clamp(navSpeed + dt*(keyboard.Up - keyboard.Down)*NAV_ADJ_SPEED, 0.01, 4)

		local kGamepad = Vector3.new(
			thumbstickCurve(gamepad.Thumbstick1.X),
			thumbstickCurve(gamepad.ButtonR2) - thumbstickCurve(gamepad.ButtonL2),
			thumbstickCurve(-gamepad.Thumbstick1.Y)
		)*NAV_GAMEPAD_SPEED

		local kKeyboard = Vector3.new(
			keyboard.D - keyboard.A + keyboard.K - keyboard.H,
			keyboard.E - keyboard.Q + keyboard.I - keyboard.Y,
			keyboard.S - keyboard.W + keyboard.J - keyboard.U
		)*NAV_KEYBOARD_SPEED

		local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)

		return (kGamepad + kKeyboard)*(navSpeed*(shift and NAV_SHIFT_MUL or 1))
	end

	function Input.Pan(dt)
		local kGamepad = Vector2.new(
			thumbstickCurve(gamepad.Thumbstick2.Y),
			thumbstickCurve(-gamepad.Thumbstick2.X)
		)*PAN_GAMEPAD_SPEED
		local kMouse = mouse.Delta*PAN_MOUSE_SPEED/(dt*60)
		mouse.Delta = Vector2.new()
		return kGamepad + kMouse
	end

	function Input.Fov(dt)
		local kGamepad = (gamepad.ButtonX - gamepad.ButtonY)*FOV_GAMEPAD_SPEED
		local kMouse = mouse.MouseWheel*FOV_WHEEL_SPEED
		mouse.MouseWheel = 0
		return kGamepad + kMouse
	end

	do
		local function Keypress(action, state, input)
			keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
			return Enum.ContextActionResult.Sink
		end

		local function GpButton(action, state, input)
			gamepad[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
			return Enum.ContextActionResult.Sink
		end

		local function MousePan(action, state, input)
			local delta = input.Delta
			mouse.Delta = Vector2.new(-delta.y, -delta.x)
			return Enum.ContextActionResult.Sink
		end

		local function Thumb(action, state, input)
			gamepad[input.KeyCode.Name] = input.Position
			return Enum.ContextActionResult.Sink
		end

		local function Trigger(action, state, input)
			gamepad[input.KeyCode.Name] = input.Position.z
			return Enum.ContextActionResult.Sink
		end

		local function MouseWheel(action, state, input)
			mouse[input.UserInputType.Name] = -input.Position.z
			return Enum.ContextActionResult.Sink
		end

		local function Zero(t)
			for k, v in pairs(t) do
				t[k] = v*0
			end
		end

		function Input.StartCapture()
			ContextActionService:BindActionAtPriority(FREECAM_RENDER_ID .. "FreecamKeyboard", Keypress, false, INPUT_PRIORITY,
				Enum.KeyCode.W, -- Enum.KeyCode.U,
				Enum.KeyCode.A, -- Enum.KeyCode.H,
				Enum.KeyCode.S, -- Enum.KeyCode.J,
				Enum.KeyCode.D, -- Enum.KeyCode.K,
				Enum.KeyCode.E, -- Enum.KeyCode.I,
				Enum.KeyCode.Q, -- Enum.KeyCode.Y,
				Enum.KeyCode.Up, Enum.KeyCode.Down
			)
			ContextActionService:BindActionAtPriority(FREECAM_RENDER_ID .. "FreecamMousePan",          MousePan,   false, INPUT_PRIORITY, Enum.UserInputType.MouseMovement)
			ContextActionService:BindActionAtPriority(FREECAM_RENDER_ID .. "FreecamMouseWheel",        MouseWheel, false, INPUT_PRIORITY, Enum.UserInputType.MouseWheel)
			ContextActionService:BindActionAtPriority(FREECAM_RENDER_ID .. "FreecamGamepadButton",     GpButton,   false, INPUT_PRIORITY, Enum.KeyCode.ButtonX, Enum.KeyCode.ButtonY)
			ContextActionService:BindActionAtPriority(FREECAM_RENDER_ID .. "FreecamGamepadTrigger",    Trigger,    false, INPUT_PRIORITY, Enum.KeyCode.ButtonR2, Enum.KeyCode.ButtonL2)
			ContextActionService:BindActionAtPriority(FREECAM_RENDER_ID .. "FreecamGamepadThumbstick", Thumb,      false, INPUT_PRIORITY, Enum.KeyCode.Thumbstick1, Enum.KeyCode.Thumbstick2)
		end

		function Input.StopCapture()
			navSpeed = 1
			Zero(gamepad)
			Zero(keyboard)
			Zero(mouse)
			ContextActionService:UnbindAction(FREECAM_RENDER_ID .. "FreecamKeyboard")
			ContextActionService:UnbindAction(FREECAM_RENDER_ID .. "FreecamMousePan")
			ContextActionService:UnbindAction(FREECAM_RENDER_ID .. "FreecamMouseWheel")
			ContextActionService:UnbindAction(FREECAM_RENDER_ID .. "FreecamGamepadButton")
			ContextActionService:UnbindAction(FREECAM_RENDER_ID .. "FreecamGamepadTrigger")
			ContextActionService:UnbindAction(FREECAM_RENDER_ID .. "FreecamGamepadThumbstick")
		end
	end
end

local function GetFocusDistance(cameraFrame)
	local znear = 0.1
	local viewport = Camera.ViewportSize
	local projy = 2*tan(cameraFov/2)
	local projx = viewport.x/viewport.y*projy
	local fx = cameraFrame.rightVector
	local fy = cameraFrame.upVector
	local fz = cameraFrame.lookVector

	local minVect = Vector3.new()
	local minDist = 512

	for x = 0, 1, 0.5 do
		for y = 0, 1, 0.5 do
			local cx = (x - 0.5)*projx
			local cy = (y - 0.5)*projy
			local offset = fx*cx - fy*cy + fz
			local origin = cameraFrame.p + offset*znear
			local _, hit = Workspace:FindPartOnRay(Ray.new(origin, offset.unit*minDist))
			local dist = (hit - origin).magnitude
			if minDist > dist then
				minDist = dist
				minVect = offset.unit
			end
		end
	end

	return fz:Dot(minVect)*minDist
end

------------------------------------------------------------------------

local function StepFreecam(dt)
	local vel = velSpring:Update(dt, Input.Vel(dt))
	local pan = panSpring:Update(dt, Input.Pan(dt))
	local fov = fovSpring:Update(dt, Input.Fov(dt))

	local zoomFactor = sqrt(tan(rad(70/2))/tan(rad(cameraFov/2)))

	cameraFov = clamp(cameraFov + fov*FOV_GAIN*(dt/zoomFactor), 1, 120)
	cameraRot = cameraRot + pan*PAN_GAIN*(dt/zoomFactor)
	cameraRot = Vector2.new(clamp(cameraRot.x, -PITCH_LIMIT, PITCH_LIMIT), cameraRot.y%(2*pi))

	local cameraCFrame = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)*CFrame.new(vel*NAV_GAIN*dt)
	cameraPos = cameraCFrame.p

	Camera.CFrame = cameraCFrame
	Camera.Focus = cameraCFrame*CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
	Camera.FieldOfView = cameraFov
end

------------------------------------------------------------------------

local PlayerState = {} do
	local mouseBehavior
	local mouseIconEnabled
	local cameraType
	local cameraFocus
	local cameraCFrame
	local cameraFieldOfView
	local screenGuis = {}
	local coreGuis = {
		Backpack = true,
		Chat = true,
		Health = true,
		PlayerList = true,
	}
	local setCores = {
		BadgesNotificationsActive = true,
		PointsNotificationsActive = true,
	}

	-- Save state and set up for freecam
	function PlayerState.Push()
		-- for name in pairs(coreGuis) do
		-- 	coreGuis[name] = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType[name])
		-- 	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[name], false)
		-- end
		-- for name in pairs(setCores) do
		-- 	setCores[name] = StarterGui:GetCore(name)
		-- 	StarterGui:SetCore(name, false)
		-- end
		-- local playergui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
		-- if playergui then
		-- 	for _, gui in pairs(playergui:GetChildren()) do
		-- 		if gui:IsA("ScreenGui") and gui.Enabled then
		-- 			screenGuis[#screenGuis + 1] = gui
		-- 			gui.Enabled = false
		-- 		end
		-- 	end
		-- end

		cameraFieldOfView = Camera.FieldOfView
		Camera.FieldOfView = 70

		-- cameraType = Camera.CameraType
		-- Camera.CameraType = Enum.CameraType.Custom

		cameraCFrame = Camera.CFrame
		cameraFocus = Camera.Focus

		-- mouseIconEnabled = UserInputService.MouseIconEnabled
		-- UserInputService.MouseIconEnabled = false

		mouseBehavior = UserInputService.MouseBehavior
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end

	-- Restore state
	function PlayerState.Pop()
		-- for name, isEnabled in pairs(coreGuis) do
		-- 	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[name], isEnabled)
		-- end
		-- for name, isEnabled in pairs(setCores) do
		-- 	StarterGui:SetCore(name, isEnabled)
		-- end
		-- for _, gui in pairs(screenGuis) do
		-- 	if gui.Parent then
		-- 		gui.Enabled = true
		-- 	end
		-- end

		Camera.FieldOfView = cameraFieldOfView
		cameraFieldOfView = nil

		-- Camera.CameraType = cameraType
		-- cameraType = nil

		Camera.CFrame = cameraCFrame
		cameraCFrame = nil

		Camera.Focus = cameraFocus
		cameraFocus = nil

		-- UserInputService.MouseIconEnabled = mouseIconEnabled
		-- mouseIconEnabled = nil

		UserInputService.MouseBehavior = mouseBehavior
		mouseBehavior = nil
	end
end

local function StartFreecam()
	local cameraCFrame = Camera.CFrame
	cameraRot = Vector2.new(cameraCFrame:toEulerAnglesYXZ())
	cameraPos = cameraCFrame.p
	cameraFov = Camera.FieldOfView

	velSpring:Reset(Vector3.new())
	panSpring:Reset(Vector2.new())
	fovSpring:Reset(0)

	PlayerState.Push()
	RunService:BindToRenderStep(FREECAM_RENDER_ID, Enum.RenderPriority.Camera.Value + 1, StepFreecam)
	Input.StartCapture()
end

local function StopFreecam()
	Input.StopCapture()
	RunService:UnbindFromRenderStep(FREECAM_RENDER_ID)
	PlayerState.Pop()
end

------------------------------------------------------------------------

local enabled = false

local function EnableFreecam()
	if not enabled then
		StartFreecam()
		enabled = true
	end
end

local function DisableFreecam()
	if enabled then
		StopFreecam()
		enabled = false
	end
end

return {
	EnableFreecam = EnableFreecam,
	DisableFreecam = DisableFreecam,
}

        end)
    end)
    hMod("get-selected-player", "ModuleScript", "Havoc.jobs.helpers.get-selected-player", "Havoc.jobs.helpers", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Players = TS.import(script, TS.getModule(script, "@rbxts", "services")).Players
local getStore = TS.import(script, script.Parent, "job-store").getStore
local getSelectedPlayer = TS.async(function(onChange)
	local store = TS.await(getStore())
	local playerSelected = {
		current = nil,
	}
	store.changed:connect(function(newState)
		local name = newState.dashboard.apps.playerSelected
		local _result = playerSelected.current
		if _result ~= nil then
			_result = _result.Name
		end
		if _result ~= name then
			playerSelected.current = name ~= nil and (Players:FindFirstChild(name)) or nil
			if onChange then
				task.defer(onChange, playerSelected.current)
			end
		end
	end)
	return playerSelected
end)
return {
	getSelectedPlayer = getSelectedPlayer,
}

        end)
    end)
    hMod("job-store", "ModuleScript", "Havoc.jobs.helpers.job-store", "Havoc.jobs.helpers", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local setInterval = TS.import(script, script.Parent.Parent.Parent, "utils", "timeout").setInterval
local store = {}
local function setStore(newStore)
	if store.current then
		error("Store has already been set")
	end
	store.current = newStore
end
local getStore = TS.async(function()
	if store.current then
		return store.current
	end
	return TS.Promise.new(function(resolve, _, onCancel)
		local interval
		interval = setInterval(function()
			if store.current then
				resolve(store.current)
				interval:clear()
			end
		end, 100)
		onCancel(function()
			interval:clear()
		end)
	end)
end)
local shallowEqual
local onJobChange = TS.async(function(jobName, callback)
	local store = TS.await(getStore())
	local lastJob = store:getState().jobs[jobName]
	return store.changed:connect(function(newState)
		local job = newState.jobs[jobName]
		if job ~= nil and lastJob ~= nil then
			local currentJobObj = job
			local lastJobObj = lastJob
			if not shallowEqual(currentJobObj, lastJobObj) then
				lastJob = job
				task.defer(callback, job, newState)
			end
		end
	end)
end)
function shallowEqual(a, b)
	if a == b then
		return true
	end
	for key, value in pairs(a) do
		if value ~= b[key] then
			return false
		end
	end
	for key, value in pairs(b) do
		if value ~= a[key] then
			return false
		end
	end
	return true
end
return {
	setStore = setStore,
	getStore = getStore,
	onJobChange = onJobChange,
}

        end)
    end)
    hInst("players", "Folder", "Havoc.jobs.players", "Havoc.jobs")
    hMod("facebang", "ModuleScript", "Havoc.jobs.players.facebang", "Havoc.jobs.players", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local _services = TS.import(script, TS.getModule(script, "@rbxts", "services"))
local RunService = _services.RunService
local Players = _services.Players
local Workspace = _services.Workspace
local onJobChange = TS.import(script, script.Parent.Parent, "helpers", "job-store").onJobChange
local HEIGHT_OFFSET = 0.8
local DEPTH_OFFSET = -0.7
local DEFAULT_GRAVITY = 192.2
local isRunning = false
local CF_IDENTITY = CFrame.new()
local CF_HEIGHT = CFrame.new(0, HEIGHT_OFFSET, DEPTH_OFFSET)
local setPhysicsEnabled = function(char, enabled)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = not enabled
		hum.AutoRotate = enabled
	end
	Workspace.Gravity = enabled and DEFAULT_GRAVITY or 0
end
local ease = function(t)
	return -(math.cos(math.pi * t) - 1) / 2
end
local speedToDuration = function(speed)
	local clamped = math.clamp(speed, 0.1, 10)
	return 0.5 / clamped
end
onJobChange("facebang", function(job, state)
	local sliderJob = job
	local _result = sliderJob
	if _result ~= nil then
		_result = _result.sliders
	end
	local sliders = _result
	local localPlayer = Players.LocalPlayer
	local localChar = localPlayer.Character
	local _result_1 = sliderJob
	if _result_1 ~= nil then
		_result_1 = _result_1.active
	end
	local _condition = not _result_1
	if not _condition then
		_condition = not localChar
	end
	if _condition then
		isRunning = false
		if localChar then
			setPhysicsEnabled(localChar, true)
		end
		return nil
	end
	if isRunning then
		return nil
	end
	local targetName = state.dashboard.apps.playerSelected
	local targetPlayer = targetName ~= nil and (Players:FindFirstChild(targetName)) or nil
	if not targetPlayer or targetPlayer == localPlayer then
		return nil
	end
	isRunning = true
	task.spawn(function()
		local localRoot = localChar:WaitForChild("HumanoidRootPart")
		while isRunning do
			local targetChar = targetPlayer.Character
			local _result_2 = targetChar
			if _result_2 ~= nil then
				_result_2 = _result_2:FindFirstChild("Head")
			end
			local targetHead = _result_2
			if not targetHead then
				task.wait(0.1)
				continue
			end
			setPhysicsEnabled(localChar, false)
			local currentJob = (state.jobs).facebang
			local _result_3 = currentJob
			if _result_3 ~= nil then
				_result_3 = _result_3.sliders
			end
			local currentSliders = _result_3
			local _result_4 = currentSliders
			if _result_4 ~= nil then
				_result_4 = _result_4.distance
			end
			local _condition_1 = _result_4
			if _condition_1 == nil then
				_condition_1 = 1.9
			end
			local dist = _condition_1
			local _result_5 = currentSliders
			if _result_5 ~= nil then
				_result_5 = _result_5.speed
			end
			local _condition_2 = _result_5
			if _condition_2 == nil then
				_condition_2 = 5
			end
			local speed = _condition_2
			local _fn = math
			local _result_6 = currentSliders
			if _result_6 ~= nil then
				_result_6 = _result_6.angle
			end
			local _condition_3 = _result_6
			if _condition_3 == nil then
				_condition_3 = 180
			end
			local angle = _fn.rad(_condition_3)
			local duration = speedToDuration(speed)
			local angleRotation = CFrame.Angles(0, angle, 0)
			local relativeBase = CF_HEIGHT * angleRotation
			local _cFrame = CFrame.new(0, 0, -dist)
			local relativePeak = relativeBase * _cFrame
			local startTime = tick()
			while isRunning and tick() - startTime < duration do
				local elapsed = tick() - startTime
				local rawAlpha = elapsed / duration
				local pingPongAlpha = 1 - math.abs(1 - rawAlpha * 2)
				local smoothAlpha = ease(math.clamp(pingPongAlpha, 0, 1))
				if targetHead.Parent and localRoot.Parent then
					local targetCF = targetHead.CFrame
					local _arg0 = relativeBase:Lerp(relativePeak, smoothAlpha)
					localRoot.CFrame = targetCF * _arg0
				end
				RunService.RenderStepped:Wait()
			end
		end
		isRunning = false
		if localPlayer.Character then
			setPhysicsEnabled(localPlayer.Character, true)
		end
	end)
end)
return nil

        end)
    end)
    hMod("hide", "ModuleScript", "Havoc.jobs.players.hide", "Havoc.jobs.players", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Players = TS.import(script, TS.getModule(script, "@rbxts", "services")).Players
local getSelectedPlayer = TS.import(script, script.Parent.Parent, "helpers", "get-selected-player").getSelectedPlayer
local _job_store = TS.import(script, script.Parent.Parent, "helpers", "job-store")
local getStore = _job_store.getStore
local onJobChange = _job_store.onJobChange
local setJobActive = TS.import(script, script.Parent.Parent.Parent, "store", "actions", "jobs.action").setJobActive
local current = {}
local function hide(player)
	if current[player] ~= nil then
		return nil
	end
	local character = player.Character
	local data
	data = {
		character = character,
		parent = character.Parent,
		handle = player.CharacterAdded:Connect(function(newCharacter)
			newCharacter.Parent = nil
			data.character = character
		end),
	}
	-- ▼ Map.set ▼
	current[player] = data
	-- ▲ Map.set ▲
	character.Parent = nil
end
local function unhide(player, setParent)
	if not (current[player] ~= nil) then
		return nil
	end
	local data = current[player]
	if setParent then
		data.character.Parent = data.parent
	end
	data.handle:Disconnect()
	-- ▼ Map.delete ▼
	current[player] = nil
	-- ▲ Map.delete ▲
end
local main = TS.async(function()
	local store = TS.await(getStore())
	local playerSelected = TS.await(getSelectedPlayer(function(player)
		local _fn = store
		local _result
		if player then
			_result = current[player] ~= nil
		else
			_result = false
		end
		_fn:dispatch(setJobActive("hide", _result))
	end))
	Players.PlayerRemoving:Connect(function(player)
		if player == playerSelected.current then
			store:dispatch(setJobActive("hide", false))
		else
			unhide(player, false)
		end
	end)
	TS.await(onJobChange("hide", function(job)
		local player = playerSelected.current
		if not player then
			store:dispatch(setJobActive("hide", false))
			return nil
		end
		if job.active and player.Character then
			hide(player)
		elseif not job.active then
			unhide(player, true)
		end
	end))
end)
main():catch(function(err)
	warn("[hide-worker] " .. tostring(err))
end)
return nil

        end)
    end)
    hMod("kill", "ModuleScript", "Havoc.jobs.players.kill", "Havoc.jobs.players", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local _services = TS.import(script, TS.getModule(script, "@rbxts", "services"))
local Players = _services.Players
local Workspace = _services.Workspace
local getSelectedPlayer = TS.import(script, script.Parent.Parent, "helpers", "get-selected-player").getSelectedPlayer
local _job_store = TS.import(script, script.Parent.Parent, "helpers", "job-store")
local getStore = _job_store.getStore
local onJobChange = _job_store.onJobChange
local setJobActive = TS.import(script, script.Parent.Parent.Parent, "store", "actions", "jobs.action").setJobActive
local player = Players.LocalPlayer
local attachToVictim = TS.async(function(victim)
	local backpack = player:FindFirstChildWhichIsA("Backpack")
	if not backpack then
		error("No inventory found")
	end
	local playerCharacter = player.Character
	local victimCharacter = victim.Character
	if not playerCharacter or not victimCharacter then
		error("Victim or local player has no character")
	end
	local playerHumanoid = playerCharacter:FindFirstChildWhichIsA("Humanoid")
	local playerRootPart = playerCharacter:FindFirstChild("HumanoidRootPart")
	local victimRootPart = victimCharacter:FindFirstChild("HumanoidRootPart")
	if not playerHumanoid or (not playerRootPart or not victimRootPart) then
		error("Victim or local player has no Humanoid or root part")
	end
	local _array = {}
	local _length = #_array
	local _array_1 = playerCharacter:GetChildren()
	local _Length = #_array_1
	table.move(_array_1, 1, _Length, _length + 1, _array)
	_length += _Length
	local _array_2 = backpack:GetChildren()
	table.move(_array_2, 1, #_array_2, _length + 1, _array)
	local _arg0 = function(obj)
		return obj:IsA("Tool") and obj:FindFirstChild("Handle") ~= nil
	end
	-- ▼ ReadonlyArray.find ▼
	local _result = nil
	for _i, _v in ipairs(_array) do
		if _arg0(_v, _i - 1, _array) == true then
			_result = _v
			break
		end
	end
	-- ▲ ReadonlyArray.find ▲
	local tool = _result
	if not tool then
		error("A tool with a handle is required to kill this victim")
	end
	playerHumanoid.Name = ""
	local mockHumanoid = playerHumanoid:Clone()
	mockHumanoid.DisplayName = utf8.char(128298)
	mockHumanoid.Parent = playerCharacter
	mockHumanoid.Name = "Humanoid"
	task.wait()
	playerHumanoid:Destroy()
	Workspace.CurrentCamera.CameraSubject = mockHumanoid
	tool.Parent = playerCharacter
	do
		local count = 0
		local _shouldIncrement = false
		while true do
			if _shouldIncrement then
				count += 1
			else
				_shouldIncrement = true
			end
			if not (count < 250) then
				break
			end
			if victimRootPart.Parent ~= victimCharacter or playerRootPart.Parent ~= playerCharacter then
				error("Victim or local player has no root part; did a player respawn?")
			end
			if tool.Parent ~= playerCharacter then
				return playerRootPart
			end
			playerRootPart.CFrame = victimRootPart.CFrame
			task.wait(0.1)
		end
	end
	error("Failed to attach to victim")
end)
local bringVictimToVoid = TS.async(function(victim)
	local store = TS.await(getStore())
	local _oldRootPart = player.Character
	if _oldRootPart ~= nil then
		_oldRootPart = _oldRootPart:FindFirstChild("HumanoidRootPart")
	end
	local oldRootPart = _oldRootPart
	local _result = oldRootPart
	if _result ~= nil then
		_result = _result:IsA("BasePart")
	end
	local location = _result and oldRootPart.CFrame or nil
	store:dispatch(setJobActive("refresh", true))
	TS.await(TS.Promise.fromEvent(player.CharacterAdded, function(character)
		return character:WaitForChild("HumanoidRootPart", 5) ~= nil
	end))
	task.wait(0.3)
	local rootPart = TS.await(attachToVictim(victim))
	local _binding = { victim.Character, player.Character }
	local victimCharacter = _binding[1]
	local playerCharacter = _binding[2]
	repeat
		do
			task.wait(0.1)
			rootPart.CFrame = CFrame.new(1000000, Workspace.FallenPartsDestroyHeight + 5, 1000000)
		end
		local _result_1 = victimCharacter
		if _result_1 ~= nil then
			_result_1 = _result_1:FindFirstChild("HumanoidRootPart")
		end
		local _condition = _result_1 ~= nil
		if _condition then
			local _result_2 = playerCharacter
			if _result_2 ~= nil then
				_result_2 = _result_2:FindFirstChild("HumanoidRootPart")
			end
			_condition = _result_2 ~= nil
		end
	until not _condition
	local newCharacter = TS.await(TS.Promise.fromEvent(player.CharacterAdded, function(character)
		return character:WaitForChild("HumanoidRootPart", 5) ~= nil
	end))
	if location then
		newCharacter.HumanoidRootPart.CFrame = location
	end
end)
local main = TS.async(function()
	local store = TS.await(getStore())
	local playerSelected = TS.await(getSelectedPlayer())
	TS.await(onJobChange("kill", function(job)
		if job.active then
			if not playerSelected.current then
				store:dispatch(setJobActive("kill", false))
				return nil
			end
			bringVictimToVoid(playerSelected.current):catch(function(err)
				return warn("[kill-worker] " .. tostring(err))
			end):finally(function()
				return store:dispatch(setJobActive("kill", false))
			end)
		end
	end))
end)
main():catch(function(err)
	warn("[kill-worker] " .. tostring(err))
end)
return nil

        end)
    end)
    hMod("spectate", "ModuleScript", "Havoc.jobs.players.spectate", "Havoc.jobs.players", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Workspace = TS.import(script, TS.getModule(script, "@rbxts", "services")).Workspace
local getSelectedPlayer = TS.import(script, script.Parent.Parent, "helpers", "get-selected-player").getSelectedPlayer
local _job_store = TS.import(script, script.Parent.Parent, "helpers", "job-store")
local getStore = _job_store.getStore
local onJobChange = _job_store.onJobChange
local setJobActive = TS.import(script, script.Parent.Parent.Parent, "store", "actions", "jobs.action").setJobActive
local main = TS.async(function()
	local store = TS.await(getStore())
	local playerSelected = TS.await(getSelectedPlayer(function()
		store:dispatch(setJobActive("spectate", false))
	end))
	local shouldResetCameraSubject = false
	local currentSubject
	local defaultSubject
	local function connectCameraSubject(camera)
		camera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
			if currentSubject ~= camera.CameraSubject and store:getState().jobs.spectate.active then
				shouldResetCameraSubject = false
				store:dispatch(setJobActive("spectate", false))
			end
		end)
	end
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		connectCameraSubject(Workspace.CurrentCamera)
	end)
	connectCameraSubject(Workspace.CurrentCamera)
	TS.await(onJobChange("spectate", function(job)
		local camera = Workspace.CurrentCamera
		if job.active then
			local _cameraSubject = playerSelected.current
			if _cameraSubject ~= nil then
				_cameraSubject = _cameraSubject.Character
				if _cameraSubject ~= nil then
					_cameraSubject = _cameraSubject:FindFirstChildWhichIsA("Humanoid")
				end
			end
			local cameraSubject = _cameraSubject
			if not cameraSubject then
				store:dispatch(setJobActive("spectate", false))
			else
				shouldResetCameraSubject = true
				defaultSubject = camera.CameraSubject
				currentSubject = cameraSubject
				camera.CameraSubject = cameraSubject
			end
		elseif shouldResetCameraSubject then
			shouldResetCameraSubject = false
			camera.CameraSubject = defaultSubject
			defaultSubject = nil
			currentSubject = nil
		end
	end))
end)
main():catch(function(err)
	warn("[spectate-worker] " .. tostring(err))
end)
return nil

        end)
    end)
    hMod("teleport", "ModuleScript", "Havoc.jobs.players.teleport", "Havoc.jobs.players", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Players = TS.import(script, TS.getModule(script, "@rbxts", "services")).Players
local getSelectedPlayer = TS.import(script, script.Parent.Parent, "helpers", "get-selected-player").getSelectedPlayer
local _job_store = TS.import(script, script.Parent.Parent, "helpers", "job-store")
local getStore = _job_store.getStore
local onJobChange = _job_store.onJobChange
local setJobActive = TS.import(script, script.Parent.Parent.Parent, "store", "actions", "jobs.action").setJobActive
local setTimeout = TS.import(script, script.Parent.Parent.Parent, "utils", "timeout").setTimeout
local main = TS.async(function()
	local store = TS.await(getStore())
	local playerSelected = TS.await(getSelectedPlayer(function()
		store:dispatch(setJobActive("teleport", false))
	end))
	local timeout
	TS.await(onJobChange("teleport", function(job)
		local _result = timeout
		if _result ~= nil then
			_result:clear()
		end
		timeout = nil
		if job.active then
			local _rootPart = Players.LocalPlayer.Character
			if _rootPart ~= nil then
				_rootPart = _rootPart:FindFirstChild("HumanoidRootPart")
			end
			local rootPart = _rootPart
			local _targetRootPart = playerSelected.current
			if _targetRootPart ~= nil then
				_targetRootPart = _targetRootPart.Character
				if _targetRootPart ~= nil then
					_targetRootPart = _targetRootPart:FindFirstChild("HumanoidRootPart")
				end
			end
			local targetRootPart = _targetRootPart
			if not targetRootPart or (not rootPart or (not rootPart:IsA("BasePart") or not targetRootPart:IsA("BasePart"))) then
				store:dispatch(setJobActive("teleport", false))
				warn("[teleport-worker] Failed to find root parts (" .. (tostring(rootPart) .. (" -> " .. (tostring(targetRootPart) .. ")"))))
				return nil
			end
			timeout = setTimeout(function()
				store:dispatch(setJobActive("teleport", false))
				local _cFrame = targetRootPart.CFrame
				local _cFrame_1 = CFrame.new(0, 0, 1)
				rootPart.CFrame = _cFrame * _cFrame_1
			end, 1000)
		end
	end))
end)
main():catch(function(err)
	warn("[teleport-worker] " .. tostring(err))
end)
return nil

        end)
    end)
    hMod("server", "ModuleScript", "Havoc.jobs.server", "Havoc.jobs", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local _services = TS.import(script, TS.getModule(script, "@rbxts", "services"))
local HttpService = _services.HttpService
local Players = _services.Players
local TeleportService = _services.TeleportService
local _job_store = TS.import(script, script.Parent, "helpers", "job-store")
local getStore = _job_store.getStore
local onJobChange = _job_store.onJobChange
local setJobActive = TS.import(script, script.Parent.Parent, "store", "actions", "jobs.action").setJobActive
local http = TS.import(script, script.Parent.Parent, "utils", "http")
local setTimeout = TS.import(script, script.Parent.Parent, "utils", "timeout").setTimeout
local queueExecution
local onServerHop = TS.async(function()
	queueExecution()
	local servers = HttpService:JSONDecode(TS.await(http.get("https://games.roblox.com/v1/games/" .. (tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"))))
	local _data = servers.data
	local _arg0 = function(server)
		return server.playing < server.maxPlayers and server.id ~= game.JobId
	end
	-- ▼ ReadonlyArray.filter ▼
	local _newValue = {}
	local _length = 0
	for _k, _v in ipairs(_data) do
		if _arg0(_v, _k - 1, _data) == true then
			_length += 1
			_newValue[_length] = _v
		end
	end
	-- ▲ ReadonlyArray.filter ▲
	local serversAvailable = _newValue
	if #serversAvailable == 0 then
		error("[server-worker-switch] No servers available.")
	else
		local server = serversAvailable[math.random(#serversAvailable - 1) + 1]
		TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
	end
end)
local onRejoin = TS.async(function()
	queueExecution()
	if #Players:GetPlayers() == 1 then
		TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
	else
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
	end
end)
function queueExecution()
	local isRelease = { string.match(VERSION, "^.+%..+%..+$") } ~= nil
	local code = isRelease and 'loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/richie0866/orca/master/public/latest.lua"))()' or 'loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/richie0866/orca/master/public/snapshot.lua"))()'
	local _result = syn
	if _result ~= nil then
		_result = _result.queue_on_teleport
	end
	local _condition = _result
	if _condition == nil then
		_condition = queue_on_teleport
	end
	local _result_1 = _condition
	if _result_1 ~= nil then
		_result_1(code)
	end
end
local main = TS.async(function()
	local store = TS.await(getStore())
	local timeout
	local function clearTimeout()
		local _result = timeout
		if _result ~= nil then
			_result:clear()
		end
		timeout = nil
	end
	TS.await(onJobChange("rejoinServer", function(job, state)
		clearTimeout()
		if state.jobs.switchServer.active then
			setJobActive("switchServer", false)
		end
		if job.active then
			timeout = setTimeout(function()
				onRejoin():catch(function(err)
					warn("[server-worker-rejoin] " .. tostring(err))
					store:dispatch(setJobActive("rejoinServer", false))
				end)
			end, 1000)
		end
	end))
	TS.await(onJobChange("switchServer", function(job, state)
		clearTimeout()
		if state.jobs.rejoinServer.active then
			setJobActive("rejoinServer", false)
		end
		if job.active then
			timeout = setTimeout(function()
				onServerHop():catch(function(err)
					warn("[server-worker-switch] " .. tostring(err))
					store:dispatch(setJobActive("switchServer", false))
				end)
			end, 1000)
		end
	end))
end)
main():catch(function(err)
	warn("[server-worker] " .. tostring(err))
end)
return nil

        end)
    end)
    hMod("main", "LocalScript", "Havoc.main", "Havoc", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.include.RuntimeLib)
local Make = TS.import(script, TS.getModule(script, "@rbxts", "make"))
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local Provider = TS.import(script, TS.getModule(script, "@rbxts", "roact-rodux-hooked").out).Provider
local Players = TS.import(script, TS.getModule(script, "@rbxts", "services")).Players
local IS_DEV = TS.import(script, script.Parent, "constants").IS_DEV
local setStore = TS.import(script, script.Parent, "jobs").setStore
local toggleDashboard = TS.import(script, script.Parent, "store", "actions", "dashboard.action").toggleDashboard
local configureStore = TS.import(script, script.Parent, "store", "store").configureStore
local App = TS.import(script, script.Parent, "App").default
local LOAD_GUARD = "_HAVOC_IS_LOADED"
local MOUNT_TIMEOUT = 10
local function checkAlreadyLoaded()
	if getgenv and getgenv()[LOAD_GUARD] ~= nil then
		warn("[Havoc] Already loaded — skipping.")
		return true
	end
	return false
end
local mount = TS.async(function(store)
	local container = Make("Folder", {})
	Roact.mount(Roact.createElement(Provider, {
		store = store,
	}, {
		Roact.createElement(App),
	}), container)
	local app = container:WaitForChild(MOUNT_TIMEOUT)
	if not app then
		error("[Havoc] Mount timed out after " .. (tostring(MOUNT_TIMEOUT) .. "s — ScreenGui never appeared."))
	end
	return app
end)
local function render(app)
	local _result = syn
	if _result ~= nil then
		_result = _result.protect_gui
	end
	local _condition = _result
	if _condition == nil then
		_condition = protect_gui
	end
	local protect = _condition
	if protect then
		pcall(function()
			return protect(app)
		end)
	end
	if IS_DEV then
		app.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	elseif gethui then
		app.Parent = gethui()
	else
		app.Parent = game:GetService("CoreGui")
	end
end
local main = TS.async(function()
	if checkAlreadyLoaded() then
		return nil
	end
	local store = configureStore()
	setStore(store)
	local app = TS.await(mount(store))
	render(app)
	if time() > 3 then
		task.defer(function()
			return store:dispatch(toggleDashboard())
		end)
	end
	if getgenv then
		getgenv()[LOAD_GUARD] = true
	end
end)
main():catch(function(err)
	warn("[Havoc] Failed to load: " .. tostring(err))
end)

        end)
    end)
    hInst("store", "Folder", "Havoc.store", "Havoc")
    hInst("actions", "Folder", "Havoc.store.actions", "Havoc.store")
    hMod("dashboard.action", "ModuleScript", "Havoc.store.actions.dashboard.action", "Havoc.store.actions", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Rodux = TS.import(script, TS.getModule(script, "@rbxts", "rodux").src)
local setDashboardPage = Rodux.makeActionCreator("dashboard/setDashboardPage", function(page)
	return {
		page = page,
	}
end)
local toggleDashboard = Rodux.makeActionCreator("dashboard/toggleDashboard", function()
	return {}
end)
local setHint = Rodux.makeActionCreator("dashboard/setHint", function(hint)
	return {
		hint = hint,
	}
end)
local clearHint = Rodux.makeActionCreator("dashboard/clearHint", function()
	return {}
end)
local playerSelected = Rodux.makeActionCreator("dashboard/playerSelected", function(player)
	return {
		name = player.Name,
	}
end)
local playerDeselected = Rodux.makeActionCreator("dashboard/playerDeselected", function()
	return {}
end)
return {
	setDashboardPage = setDashboardPage,
	toggleDashboard = toggleDashboard,
	setHint = setHint,
	clearHint = clearHint,
	playerSelected = playerSelected,
	playerDeselected = playerDeselected,
}

        end)
    end)
    hMod("jobs.action", "ModuleScript", "Havoc.store.actions.jobs.action", "Havoc.store.actions", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local setJobActive = function(jobName, active)
	return {
		type = "jobs/setJobActive",
		jobName = jobName,
		active = active,
	}
end
local setJobValue = function(jobName, value)
	return {
		type = "jobs/setJobValue",
		jobName = jobName,
		value = value,
	}
end
local setJobSlider = function(jobName, slider, value)
	return {
		type = "jobs/setJobSlider",
		jobName = jobName,
		slider = slider,
		value = value,
	}
end
return {
	setJobActive = setJobActive,
	setJobValue = setJobValue,
	setJobSlider = setJobSlider,
}

        end)
    end)
    hMod("options.action", "ModuleScript", "Havoc.store.actions.options.action", "Havoc.store.actions", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Rodux = TS.import(script, TS.getModule(script, "@rbxts", "rodux").src)
local setConfig = Rodux.makeActionCreator("options/setConfig", function(name, active)
	return {
		name = name,
		active = active,
	}
end)
local setShortcut = Rodux.makeActionCreator("options/setShortcut", function(shortcut, keycode)
	return {
		shortcut = shortcut,
		keycode = keycode,
	}
end)
local removeShortcut = Rodux.makeActionCreator("options/removeShortcut", function(shortcut)
	return {
		shortcut = shortcut,
	}
end)
local setTheme = Rodux.makeActionCreator("options/setTheme", function(theme)
	return {
		theme = theme,
	}
end)
return {
	setConfig = setConfig,
	setShortcut = setShortcut,
	removeShortcut = removeShortcut,
	setTheme = setTheme,
}

        end)
    end)
    hInst("models", "Folder", "Havoc.store.models", "Havoc.store")
    hMod("dashboard.model", "ModuleScript", "Havoc.store.models.dashboard.model", "Havoc.store.models", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local DashboardPage
do
	local _inverse = {}
	DashboardPage = setmetatable({}, {
		__index = _inverse,
	})
	DashboardPage.Home = "home"
	_inverse.home = "Home"
	DashboardPage.Apps = "apps"
	_inverse.apps = "Apps"
	DashboardPage.Scripts = "scripts"
	_inverse.scripts = "Scripts"
	DashboardPage.Options = "options"
	_inverse.options = "Options"
	DashboardPage.Misc = "misc"
	_inverse.misc = "Misc"
end
local PAGE_TO_INDEX = {
	[DashboardPage.Home] = 0,
	[DashboardPage.Apps] = 1,
	[DashboardPage.Scripts] = 2,
	[DashboardPage.Options] = 3,
	[DashboardPage.Misc] = 4,
}
local PAGE_TO_ICON = {
	[DashboardPage.Home] = "rbxassetid://8992031167",
	[DashboardPage.Apps] = "rbxassetid://8992031246",
	[DashboardPage.Scripts] = "rbxassetid://8992030918",
	[DashboardPage.Options] = "rbxassetid://8992031056",
	[DashboardPage.Misc] = "rbxassetid://10651509376",
}
return {
	DashboardPage = DashboardPage,
	PAGE_TO_INDEX = PAGE_TO_INDEX,
	PAGE_TO_ICON = PAGE_TO_ICON,
}

        end)
    end)
    hMod("jobs.model", "ModuleScript", "Havoc.store.models.jobs.model", "Havoc.store.models", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7

        end)
    end)
    hMod("options.model", "ModuleScript", "Havoc.store.models.options.model", "Havoc.store.models", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local __FIX_OPTIONS = true
return {
	__FIX_OPTIONS = __FIX_OPTIONS,
}

        end)
    end)
    hMod("persistent-state", "ModuleScript", "Havoc.store.persistent-state", "Havoc.store", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local _services = TS.import(script, TS.getModule(script, "@rbxts", "services"))
local HttpService = _services.HttpService
local Players = _services.Players
local getStore = TS.import(script, script.Parent.Parent, "jobs", "helpers", "job-store").getStore
local setInterval = TS.import(script, script.Parent.Parent, "utils", "timeout").setInterval
if makefolder and not isfolder("_orca") then
	makefolder("_orca")
end
local function read(file)
	if readfile then
		return isfile(file) and readfile(file) or nil
	else
		print("READ   " .. file)
		return nil
	end
end
local function write(file, content)
	if writefile then
		return writefile(file, content)
	else
		print("WRITE  " .. (file .. (" => \n" .. content)))
		return nil
	end
end
local autosave
local function persistentState(name, selector, defaultValue)
	local _exitType, _returns = TS.try(function()
		local serializedState = read("_orca/" .. (name .. ".json"))
		if serializedState == nil then
			write("_orca/" .. (name .. ".json"), HttpService:JSONEncode(defaultValue))
			return TS.TRY_RETURN, { defaultValue }
		end
		local value = HttpService:JSONDecode(serializedState)
		autosave(name, selector):catch(function()
			warn("Autosave failed")
		end)
		return TS.TRY_RETURN, { value }
	end, function(err)
		warn("Failed to load " .. (name .. (".json: " .. tostring(err))))
		return TS.TRY_RETURN, { defaultValue }
	end)
	if _exitType then
		return unpack(_returns)
	end
end
autosave = TS.async(function(name, selector)
	local store = TS.await(getStore())
	local function save()
		local state = selector(store:getState())
		write("_orca/" .. (name .. ".json"), HttpService:JSONEncode(state))
	end
	setInterval(function()
		return save
	end, 60000)
	Players.PlayerRemoving:Connect(function(player)
		if player == Players.LocalPlayer then
			save()
		end
	end)
end)
return {
	persistentState = persistentState,
}

        end)
    end)
    hInst("reducers", "Folder", "Havoc.store.reducers", "Havoc.store")
    hMod("dashboard.reducer", "ModuleScript", "Havoc.store.reducers.dashboard.reducer", "Havoc.store.reducers", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Rodux = TS.import(script, TS.getModule(script, "@rbxts", "rodux").src)
local DashboardPage = TS.import(script, script.Parent.Parent, "models", "dashboard.model").DashboardPage
local initialState = {
	page = DashboardPage.Home,
	isOpen = false,
	hint = nil,
	apps = {
		playerSelected = nil,
	},
}
local dashboardReducer = Rodux.createReducer(initialState, {
	["dashboard/setDashboardPage"] = function(state, action)
		local _object = {}
		for _k, _v in pairs(state) do
			_object[_k] = _v
		end
		_object.page = action.page
		return _object
	end,
	["dashboard/toggleDashboard"] = function(state)
		local _object = {}
		for _k, _v in pairs(state) do
			_object[_k] = _v
		end
		_object.isOpen = not state.isOpen
		return _object
	end,
	["dashboard/setHint"] = function(state, action)
		local _object = {}
		for _k, _v in pairs(state) do
			_object[_k] = _v
		end
		_object.hint = action.hint
		return _object
	end,
	["dashboard/clearHint"] = function(state)
		local _object = {}
		for _k, _v in pairs(state) do
			_object[_k] = _v
		end
		_object.hint = nil
		return _object
	end,
	["dashboard/playerSelected"] = function(state, action)
		local _object = {}
		for _k, _v in pairs(state) do
			_object[_k] = _v
		end
		local _left = "apps"
		local _object_1 = {}
		for _k, _v in pairs(state.apps) do
			_object_1[_k] = _v
		end
		_object_1.playerSelected = action.name
		_object[_left] = _object_1
		return _object
	end,
	["dashboard/playerDeselected"] = function(state)
		local _object = {}
		for _k, _v in pairs(state) do
			_object[_k] = _v
		end
		local _left = "apps"
		local _object_1 = {}
		for _k, _v in pairs(state.apps) do
			_object_1[_k] = _v
		end
		_object_1.playerSelected = nil
		_object[_left] = _object_1
		return _object
	end,
})
return {
	dashboardReducer = dashboardReducer,
}

        end)
    end)
    hMod("jobs.reducer", "ModuleScript", "Havoc.store.reducers.jobs.reducer", "Havoc.store.reducers", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Rodux = TS.import(script, TS.getModule(script, "@rbxts", "rodux").src)
local initialState = {
	flight = {
		value = 60,
		active = false,
	},
	walkSpeed = {
		value = 80,
		active = false,
	},
	jumpHeight = {
		value = 200,
		active = false,
	},
	refresh = {
		active = false,
	},
	ghost = {
		active = false,
	},
	godmode = {
		active = false,
	},
	freecam = {
		active = false,
	},
	teleport = {
		active = false,
	},
	hide = {
		active = false,
	},
	kill = {
		active = false,
	},
	spectate = {
		active = false,
	},
	facebang = {
		active = false,
		sliders = {
			angle = 180,
			distance = 2.5,
		},
	},
	rejoinServer = {
		active = false,
	},
	switchServer = {
		active = false,
	},
}
local jobsReducer = Rodux.createReducer(initialState, {
	["jobs/setJobActive"] = function(state, action)
		local _object = {}
		for _k, _v in pairs(state) do
			_object[_k] = _v
		end
		local _left = action.jobName
		local _object_1 = {}
		for _k, _v in pairs(state[action.jobName]) do
			_object_1[_k] = _v
		end
		_object_1.active = action.active
		_object[_left] = _object_1
		return _object
	end,
	["jobs/setJobValue"] = function(state, action)
		local _object = {}
		for _k, _v in pairs(state) do
			_object[_k] = _v
		end
		local _left = action.jobName
		local _object_1 = {}
		for _k, _v in pairs(state[action.jobName]) do
			_object_1[_k] = _v
		end
		_object_1.value = action.value
		_object[_left] = _object_1
		return _object
	end,
	["jobs/setJobSlider"] = function(state, action)
		local job = state[action.jobName]
		if job.sliders ~= nil then
			local jobWithSliders = job
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			local _left = action.jobName
			local _object_1 = {}
			for _k, _v in pairs(jobWithSliders) do
				_object_1[_k] = _v
			end
			local _left_1 = "sliders"
			local _object_2 = {}
			for _k, _v in pairs(jobWithSliders.sliders) do
				_object_2[_k] = _v
			end
			_object_2[action.slider] = action.value
			_object_1[_left_1] = _object_2
			_object[_left] = _object_1
			return _object
		end
		return state
	end,
})
return {
	jobsReducer = jobsReducer,
}

        end)
    end)
    hMod("options.reducer", "ModuleScript", "Havoc.store.reducers.options.reducer", "Havoc.store.reducers", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Rodux = TS.import(script, TS.getModule(script, "@rbxts", "rodux").src)
local persistentState = TS.import(script, script.Parent.Parent, "persistent-state").persistentState
local initialState = persistentState("options", function(state)
	return state.options
end, {
	currentTheme = "Crimson",
	config = {
		acrylicBlur = true,
	},
	shortcuts = {
		toggleDashboard = Enum.KeyCode.K.Value,
	},
})
local optionsReducer = Rodux.createReducer(initialState, {
	["options/setConfig"] = function(state, action)
		local _object = {}
		for _k, _v in pairs(state) do
			_object[_k] = _v
		end
		local _left = "config"
		local _object_1 = {}
		for _k, _v in pairs(state.config) do
			_object_1[_k] = _v
		end
		_object_1[action.name] = action.active
		_object[_left] = _object_1
		return _object
	end,
	["options/setTheme"] = function(state, action)
		local _object = {}
		for _k, _v in pairs(state) do
			_object[_k] = _v
		end
		_object.currentTheme = action.theme
		return _object
	end,
	["options/setShortcut"] = function(state, action)
		local _object = {}
		for _k, _v in pairs(state) do
			_object[_k] = _v
		end
		local _left = "shortcuts"
		local _object_1 = {}
		for _k, _v in pairs(state.shortcuts) do
			_object_1[_k] = _v
		end
		_object_1[action.shortcut] = action.keycode
		_object[_left] = _object_1
		return _object
	end,
	["options/removeShortcut"] = function(state, action)
		local _object = {}
		for _k, _v in pairs(state) do
			_object[_k] = _v
		end
		local _left = "shortcuts"
		local _object_1 = {}
		for _k, _v in pairs(state.shortcuts) do
			_object_1[_k] = _v
		end
		_object_1[action.shortcut] = nil
		_object[_left] = _object_1
		return _object
	end,
})
return {
	optionsReducer = optionsReducer,
}

        end)
    end)
    hMod("store", "ModuleScript", "Havoc.store.store", "Havoc.store", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Rodux = TS.import(script, TS.getModule(script, "@rbxts", "rodux").src)
local dashboardReducer = TS.import(script, script.Parent, "reducers", "dashboard.reducer").dashboardReducer
local jobsReducer = TS.import(script, script.Parent, "reducers", "jobs.reducer").jobsReducer
local optionsReducer = TS.import(script, script.Parent, "reducers", "options.reducer").optionsReducer
local rootReducer = Rodux.combineReducers({
	dashboard = dashboardReducer,
	jobs = jobsReducer,
	options = optionsReducer,
})
local function configureStore(initialState)
	return Rodux.Store.new(rootReducer, initialState)
end
return {
	configureStore = configureStore,
}

        end)
    end)
    hMod("theme", "ModuleScript", "Havoc.theme", "Havoc", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local UI_COLORS = {
	Accent = Color3.fromRGB(235, 76, 105),
	AccentDark = Color3.fromRGB(150, 40, 60),
	MainBG = Color3.fromRGB(10, 10, 10),
	SectionBG = Color3.fromRGB(15, 15, 15),
	ElementBG = Color3.fromRGB(20, 20, 20),
	Border = Color3.fromRGB(35, 35, 35),
	Hover = Color3.fromRGB(45, 45, 45),
	TextMain = Color3.fromRGB(255, 255, 255),
	TextDim = Color3.fromRGB(180, 180, 180),
	TextDark = Color3.fromRGB(120, 120, 120),
}
local UI_ANIMATION = {
	SpringDamping = 0.8,
	SpringFrequency = 2.5,
	FastSpeed = 0.1,
	DefaultSpeed = 0.25,
}
local UI_LAYOUT = {
	Padding = UDim.new(0, 20),
	Spacing = UDim.new(0, 10),
	CornerRadius = UDim.new(0, 8),
	HeaderHeight = 60,
}
return {
	UI_COLORS = UI_COLORS,
	UI_ANIMATION = UI_ANIMATION,
	UI_LAYOUT = UI_LAYOUT,
}

        end)
    end)
    hMod("themes", "ModuleScript", "Havoc.themes", "Havoc", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.include.RuntimeLib)
local darkTheme = TS.import(script, script, "sorbet").darkTheme
local frostedGlass = TS.import(script, script, "frosted-glass").frostedGlass
local highContrast = TS.import(script, script, "high-contrast").highContrast
local lightTheme = TS.import(script, script, "light-theme").lightTheme
local obsidian = TS.import(script, script, "obsidian").obsidian
local crimson = TS.import(script, script, "crimson").crimson
local _exp = { crimson, darkTheme, lightTheme, frostedGlass, obsidian, highContrast }
local _arg0 = function(t)
	return t ~= nil
end
-- ▼ ReadonlyArray.filter ▼
local _newValue = {}
local _length = 0
for _k, _v in ipairs(_exp) do
	if _arg0(_v, _k - 1, _exp) == true then
		_length += 1
		_newValue[_length] = _v
	end
end
-- ▲ ReadonlyArray.filter ▲
local themeList = _newValue
local themeMap = {}
local _arg0_1 = function(theme)
	local _name = theme.name
	-- ▼ Map.set ▼
	themeMap[_name] = theme
	-- ▲ Map.set ▲
end
-- ▼ ReadonlyArray.forEach ▼
for _k, _v in ipairs(themeList) do
	_arg0_1(_v, _k - 1, themeList)
end
-- ▲ ReadonlyArray.forEach ▲
local function getThemes()
	return themeList
end
local function getThemeByName(name)
	local _condition = themeMap[name]
	if _condition == nil then
		_condition = darkTheme
	end
	return _condition
end
return {
	getThemes = getThemes,
	getThemeByName = getThemeByName,
	darkTheme = darkTheme,
}

        end)
    end)
    hMod("crimson", "ModuleScript", "Havoc.themes.crimson", "Havoc.themes", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local darkTheme = TS.import(script, script.Parent, "sorbet").darkTheme
local hex = TS.import(script, script.Parent.Parent, "utils", "color3").hex
local redAccent = hex("#FF2222")
local white = hex("#ffffff")
local black = hex("#0a0a0a")
local accentSequence = ColorSequence.new({ ColorSequenceKeypoint.new(0, hex("#FF4444")), ColorSequenceKeypoint.new(0.5, hex("#CC0000")), ColorSequenceKeypoint.new(1, hex("#880000")) })
local background = hex("#111111")
local backgroundDark = hex("#0a0a0a")
local view = {
	acrylic = false,
	outlined = true,
	foreground = white,
	background = background,
	backgroundGradient = nil,
	transparency = 0,
	dropshadow = background,
	dropshadowTransparency = 0.3,
}
local _object = {}
for _k, _v in pairs(darkTheme) do
	_object[_k] = _v
end
_object.name = "Crimson"
_object.preview = {
	foreground = {
		color = ColorSequence.new(white),
	},
	background = {
		color = ColorSequence.new(background),
	},
	accent = {
		color = accentSequence,
		rotation = 25,
	},
}
local _left = "navbar"
local _object_1 = {}
for _k, _v in pairs(darkTheme.navbar) do
	_object_1[_k] = _v
end
_object_1.outlined = true
_object_1.background = background
_object_1.dropshadow = background
_object_1.foreground = white
_object_1.accentGradient = {
	color = accentSequence,
}
_object[_left] = _object_1
local _left_1 = "clock"
local _object_2 = {}
for _k, _v in pairs(darkTheme.clock) do
	_object_2[_k] = _v
end
_object_2.outlined = true
_object_2.background = background
_object_2.dropshadow = background
_object_2.foreground = white
_object[_left_1] = _object_2
local _left_2 = "home"
local _object_3 = {}
local _left_3 = "title"
local _object_4 = {}
for _k, _v in pairs(view) do
	_object_4[_k] = _v
end
_object_4.background = white
_object_4.backgroundGradient = {
	color = accentSequence,
	rotation = 25,
}
_object_4.dropshadow = white
_object_4.dropshadowGradient = {
	color = accentSequence,
	rotation = 25,
}
_object_3[_left_3] = _object_4
local _left_4 = "profile"
local _object_5 = {}
for _k, _v in pairs(view) do
	_object_5[_k] = _v
end
local _left_5 = "avatar"
local _object_6 = {}
for _k, _v in pairs(darkTheme.home.profile.avatar) do
	_object_6[_k] = _v
end
_object_6.background = backgroundDark
_object_6.transparency = 0
_object_6.gradient = {
	color = accentSequence,
	rotation = 25,
}
_object_5[_left_5] = _object_6
_object_5.highlight = {
	flight = redAccent,
	walkSpeed = hex("#FF4444"),
	jumpHeight = hex("#FF6666"),
	refresh = redAccent,
	ghost = hex("#FF4444"),
	godmode = hex("#FF0000"),
	freecam = hex("#FF6666"),
}
local _left_6 = "slider"
local _object_7 = {}
for _k, _v in pairs(darkTheme.home.profile.slider) do
	_object_7[_k] = _v
end
_object_7.outlined = true
_object_7.foreground = white
_object_7.background = backgroundDark
_object_5[_left_6] = _object_7
local _left_7 = "button"
local _object_8 = {}
for _k, _v in pairs(darkTheme.home.profile.button) do
	_object_8[_k] = _v
end
_object_8.outlined = true
_object_8.foreground = white
_object_8.background = backgroundDark
_object_5[_left_7] = _object_8
_object_3[_left_4] = _object_5
local _left_8 = "server"
local _object_9 = {}
for _k, _v in pairs(view) do
	_object_9[_k] = _v
end
_object_9.background = hex("#CC0000")
_object_9.dropshadow = hex("#CC0000")
local _left_9 = "rejoinButton"
local _object_10 = {}
for _k, _v in pairs(darkTheme.home.server.rejoinButton) do
	_object_10[_k] = _v
end
_object_10.outlined = true
_object_10.foreground = white
_object_10.background = hex("#880000")
_object_10.foregroundTransparency = 0
_object_9[_left_9] = _object_10
local _left_10 = "switchButton"
local _object_11 = {}
for _k, _v in pairs(darkTheme.home.server.switchButton) do
	_object_11[_k] = _v
end
_object_11.outlined = true
_object_11.foreground = white
_object_11.background = hex("#880000")
_object_11.foregroundTransparency = 0
_object_9[_left_10] = _object_11
_object_3[_left_8] = _object_9
local _left_11 = "friendActivity"
local _object_12 = {}
for _k, _v in pairs(view) do
	_object_12[_k] = _v
end
local _left_12 = "friendButton"
local _object_13 = {}
for _k, _v in pairs(darkTheme.home.friendActivity.friendButton) do
	_object_13[_k] = _v
end
_object_13.outlined = true
_object_13.foreground = white
_object_13.background = backgroundDark
_object_12[_left_12] = _object_13
_object_3[_left_11] = _object_12
_object[_left_2] = _object_3
local _left_13 = "apps"
local _object_14 = {}
local _left_14 = "players"
local _object_15 = {}
for _k, _v in pairs(view) do
	_object_15[_k] = _v
end
_object_15.highlight = {
	teleport = hex("#FF4444"),
	hide = hex("#FF2222"),
	kill = hex("#CC0000"),
	spectate = hex("#FF6666"),
}
local _left_15 = "avatar"
local _object_16 = {}
for _k, _v in pairs(darkTheme.apps.players.avatar) do
	_object_16[_k] = _v
end
_object_16.background = backgroundDark
_object_16.transparency = 0
_object_16.gradient = {
	color = accentSequence,
	rotation = 25,
}
_object_15[_left_15] = _object_16
local _left_16 = "button"
local _object_17 = {}
for _k, _v in pairs(darkTheme.apps.players.button) do
	_object_17[_k] = _v
end
_object_17.outlined = true
_object_17.foreground = white
_object_17.background = backgroundDark
_object_15[_left_16] = _object_17
local _left_17 = "playerButton"
local _object_18 = {}
for _k, _v in pairs(darkTheme.apps.players.playerButton) do
	_object_18[_k] = _v
end
_object_18.outlined = true
_object_18.foreground = white
_object_18.background = backgroundDark
_object_18.dropshadow = backgroundDark
_object_18.accent = redAccent
_object_15[_left_17] = _object_18
_object_14[_left_14] = _object_15
_object[_left_13] = _object_14
local _left_18 = "options"
local _object_19 = {}
local _left_19 = "config"
local _object_20 = {}
for _k, _v in pairs(view) do
	_object_20[_k] = _v
end
local _left_20 = "configButton"
local _object_21 = {}
for _k, _v in pairs(darkTheme.options.config.configButton) do
	_object_21[_k] = _v
end
_object_21.outlined = true
_object_21.foreground = white
_object_21.background = backgroundDark
_object_21.dropshadow = backgroundDark
_object_21.accent = redAccent
_object_20[_left_20] = _object_21
_object_19[_left_19] = _object_20
local _left_21 = "shortcuts"
local _object_22 = {}
for _k, _v in pairs(view) do
	_object_22[_k] = _v
end
local _left_22 = "shortcutButton"
local _object_23 = {}
for _k, _v in pairs(darkTheme.options.shortcuts.shortcutButton) do
	_object_23[_k] = _v
end
_object_23.outlined = true
_object_23.foreground = white
_object_23.background = backgroundDark
_object_23.dropshadow = backgroundDark
_object_23.accent = redAccent
_object_22[_left_22] = _object_23
_object_19[_left_21] = _object_22
local _left_23 = "themes"
local _object_24 = {}
for _k, _v in pairs(view) do
	_object_24[_k] = _v
end
local _left_24 = "themeButton"
local _object_25 = {}
for _k, _v in pairs(darkTheme.options.themes.themeButton) do
	_object_25[_k] = _v
end
_object_25.outlined = true
_object_25.foreground = white
_object_25.background = backgroundDark
_object_25.dropshadow = backgroundDark
_object_25.accent = redAccent
_object_24[_left_24] = _object_25
_object_19[_left_23] = _object_24
_object[_left_18] = _object_19
local crimson = _object
return {
	crimson = crimson,
}

        end)
    end)
    hMod("frosted-glass", "ModuleScript", "Havoc.themes.frosted-glass", "Havoc.themes", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local darkTheme = TS.import(script, script.Parent, "sorbet").darkTheme
local hex = TS.import(script, script.Parent.Parent, "utils", "color3").hex
local accent = hex("#000000")
local accentSequence = ColorSequence.new(hex("#000000"))
local view = {
	acrylic = true,
	outlined = true,
	foreground = hex("#ffffff"),
	background = hex("#ffffff"),
	backgroundGradient = nil,
	transparency = 0.9,
	dropshadow = hex("#ffffff"),
	dropshadowTransparency = 0,
	dropshadowGradient = {
		color = ColorSequence.new(hex("#000000")),
		transparency = NumberSequence.new(1, 0.8),
		rotation = 90,
	},
}
local _object = {}
for _k, _v in pairs(darkTheme) do
	_object[_k] = _v
end
_object.name = "Frosted glass"
_object.preview = {
	foreground = {
		color = ColorSequence.new(hex("#ffffff")),
	},
	background = {
		color = ColorSequence.new(hex("#ffffff")),
	},
	accent = {
		color = accentSequence,
	},
}
local _left = "navbar"
local _object_1 = {}
for _k, _v in pairs(darkTheme.navbar) do
	_object_1[_k] = _v
end
_object_1.outlined = true
_object_1.acrylic = true
_object_1.foreground = hex("#ffffff")
_object_1.background = hex("#ffffff")
_object_1.backgroundGradient = nil
_object_1.transparency = 0.9
_object_1.dropshadow = hex("#000000")
_object_1.dropshadowTransparency = 0.2
_object_1.accentGradient = {
	color = ColorSequence.new(hex("#ffffff")),
	transparency = NumberSequence.new(0.8),
	rotation = 90,
}
_object_1.glowTransparency = 0.5
_object[_left] = _object_1
_object.clock = {
	outlined = true,
	acrylic = true,
	foreground = hex("#ffffff"),
	background = hex("#ffffff"),
	backgroundGradient = nil,
	transparency = 0.9,
	dropshadow = hex("#000000"),
	dropshadowTransparency = 0.2,
}
local _left_1 = "home"
local _object_2 = {}
local _left_2 = "title"
local _object_3 = {}
for _k, _v in pairs(view) do
	_object_3[_k] = _v
end
_object_2[_left_2] = _object_3
local _left_3 = "profile"
local _object_4 = {}
for _k, _v in pairs(view) do
	_object_4[_k] = _v
end
local _left_4 = "avatar"
local _object_5 = {}
for _k, _v in pairs(darkTheme.home.profile.avatar) do
	_object_5[_k] = _v
end
_object_5.background = hex("#ffffff")
_object_5.transparency = 0.7
_object_5.gradient = {
	color = ColorSequence.new(hex("#ffffff"), hex("#ffffff")),
	transparency = NumberSequence.new(0.5, 1),
	rotation = 45,
}
_object_4[_left_4] = _object_5
_object_4.highlight = {
	flight = accent,
	walkSpeed = accent,
	jumpHeight = accent,
	refresh = accent,
	ghost = accent,
	godmode = accent,
	freecam = accent,
}
local _left_5 = "slider"
local _object_6 = {}
for _k, _v in pairs(darkTheme.home.profile.slider) do
	_object_6[_k] = _v
end
_object_6.outlined = false
_object_6.foreground = hex("#ffffff")
_object_6.background = hex("#ffffff")
_object_6.backgroundTransparency = 0.8
_object_6.indicatorTransparency = 0.3
_object_4[_left_5] = _object_6
local _left_6 = "button"
local _object_7 = {}
for _k, _v in pairs(darkTheme.home.profile.button) do
	_object_7[_k] = _v
end
_object_7.outlined = false
_object_7.foreground = hex("#ffffff")
_object_7.background = hex("#ffffff")
_object_7.backgroundTransparency = 0.8
_object_4[_left_6] = _object_7
_object_2[_left_3] = _object_4
local _left_7 = "server"
local _object_8 = {}
for _k, _v in pairs(view) do
	_object_8[_k] = _v
end
local _left_8 = "rejoinButton"
local _object_9 = {}
for _k, _v in pairs(darkTheme.home.server.rejoinButton) do
	_object_9[_k] = _v
end
_object_9.outlined = false
_object_9.foreground = hex("#ffffff")
_object_9.background = hex("#ffffff")
_object_9.foregroundTransparency = 0.5
_object_9.backgroundTransparency = 0.8
_object_9.accent = accent
_object_8[_left_8] = _object_9
local _left_9 = "switchButton"
local _object_10 = {}
for _k, _v in pairs(darkTheme.home.server.switchButton) do
	_object_10[_k] = _v
end
_object_10.outlined = false
_object_10.foreground = hex("#ffffff")
_object_10.background = hex("#ffffff")
_object_10.foregroundTransparency = 0.5
_object_10.backgroundTransparency = 0.8
_object_10.accent = accent
_object_8[_left_9] = _object_10
_object_2[_left_7] = _object_8
local _left_10 = "friendActivity"
local _object_11 = {}
for _k, _v in pairs(view) do
	_object_11[_k] = _v
end
local _left_11 = "friendButton"
local _object_12 = {}
for _k, _v in pairs(darkTheme.home.friendActivity.friendButton) do
	_object_12[_k] = _v
end
_object_12.outlined = false
_object_12.foreground = hex("#ffffff")
_object_12.background = hex("#ffffff")
_object_12.dropshadow = hex("#ffffff")
_object_12.backgroundTransparency = 0.7
_object_11[_left_11] = _object_12
_object_2[_left_10] = _object_11
_object[_left_1] = _object_2
local _left_12 = "apps"
local _object_13 = {}
local _left_13 = "players"
local _object_14 = {}
for _k, _v in pairs(view) do
	_object_14[_k] = _v
end
_object_14.highlight = {
	teleport = accent,
	hide = accent,
	kill = accent,
	spectate = accent,
}
local _left_14 = "avatar"
local _object_15 = {}
for _k, _v in pairs(darkTheme.apps.players.avatar) do
	_object_15[_k] = _v
end
_object_15.background = hex("#ffffff")
_object_15.transparency = 0.7
_object_15.gradient = {
	color = ColorSequence.new(hex("#ffffff"), hex("#ffffff")),
	transparency = NumberSequence.new(0.5, 1),
	rotation = 45,
}
_object_14[_left_14] = _object_15
local _left_15 = "button"
local _object_16 = {}
for _k, _v in pairs(darkTheme.apps.players.button) do
	_object_16[_k] = _v
end
_object_16.outlined = false
_object_16.foreground = hex("#ffffff")
_object_16.background = hex("#ffffff")
_object_16.backgroundTransparency = 0.8
_object_14[_left_15] = _object_16
local _left_16 = "playerButton"
local _object_17 = {}
for _k, _v in pairs(darkTheme.apps.players.playerButton) do
	_object_17[_k] = _v
end
_object_17.outlined = false
_object_17.foreground = hex("#ffffff")
_object_17.background = hex("#ffffff")
_object_17.dropshadow = hex("#ffffff")
_object_17.accent = accent
_object_17.backgroundTransparency = 0.8
_object_17.dropshadowTransparency = 0.7
_object_14[_left_16] = _object_17
_object_13[_left_13] = _object_14
_object[_left_12] = _object_13
local _left_17 = "options"
local _object_18 = {}
local _left_18 = "config"
local _object_19 = {}
for _k, _v in pairs(view) do
	_object_19[_k] = _v
end
local _left_19 = "configButton"
local _object_20 = {}
for _k, _v in pairs(darkTheme.options.config.configButton) do
	_object_20[_k] = _v
end
_object_20.outlined = false
_object_20.foreground = hex("#ffffff")
_object_20.background = hex("#ffffff")
_object_20.dropshadow = hex("#ffffff")
_object_20.accent = accent
_object_20.backgroundTransparency = 0.8
_object_20.dropshadowTransparency = 0.7
_object_19[_left_19] = _object_20
_object_18[_left_18] = _object_19
local _left_20 = "shortcuts"
local _object_21 = {}
for _k, _v in pairs(view) do
	_object_21[_k] = _v
end
local _left_21 = "shortcutButton"
local _object_22 = {}
for _k, _v in pairs(darkTheme.options.shortcuts.shortcutButton) do
	_object_22[_k] = _v
end
_object_22.outlined = false
_object_22.foreground = hex("#ffffff")
_object_22.background = hex("#ffffff")
_object_22.dropshadow = hex("#ffffff")
_object_22.accent = accent
_object_22.backgroundTransparency = 0.8
_object_22.dropshadowTransparency = 0.7
_object_21[_left_21] = _object_22
_object_18[_left_20] = _object_21
local _left_22 = "themes"
local _object_23 = {}
for _k, _v in pairs(view) do
	_object_23[_k] = _v
end
local _left_23 = "themeButton"
local _object_24 = {}
for _k, _v in pairs(darkTheme.options.themes.themeButton) do
	_object_24[_k] = _v
end
_object_24.outlined = false
_object_24.foreground = hex("#ffffff")
_object_24.background = hex("#ffffff")
_object_24.dropshadow = hex("#ffffff")
_object_24.accent = accent
_object_24.backgroundTransparency = 0.8
_object_24.dropshadowTransparency = 0.7
_object_23[_left_23] = _object_24
_object_18[_left_22] = _object_23
_object[_left_17] = _object_18
local frostedGlass = _object
return {
	frostedGlass = frostedGlass,
}

        end)
    end)
    hMod("high-contrast", "ModuleScript", "Havoc.themes.high-contrast", "Havoc.themes", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local darkTheme = TS.import(script, script.Parent, "sorbet").darkTheme
local hex = TS.import(script, script.Parent.Parent, "utils", "color3").hex
local _object = {}
for _k, _v in pairs(darkTheme) do
	_object[_k] = _v
end
_object.name = "High contrast"
_object.preview = {
	foreground = {
		color = ColorSequence.new(hex("#ffffff")),
	},
	background = {
		color = ColorSequence.new(hex("#000000")),
	},
	accent = {
		color = ColorSequence.new({ ColorSequenceKeypoint.new(0, hex("#F6BD29")), ColorSequenceKeypoint.new(0.5, hex("#F64229")), ColorSequenceKeypoint.new(1, hex("#000000")) }),
		rotation = 25,
	},
}
local _left = "navbar"
local _object_1 = {}
for _k, _v in pairs(darkTheme.navbar) do
	_object_1[_k] = _v
end
_object_1.foreground = hex("#ffffff")
_object_1.background = hex("#000000")
_object_1.dropshadow = hex("#000000")
_object[_left] = _object_1
local _left_1 = "clock"
local _object_2 = {}
for _k, _v in pairs(darkTheme.clock) do
	_object_2[_k] = _v
end
_object_2.foreground = hex("#ffffff")
_object_2.background = hex("#000000")
_object_2.dropshadow = hex("#000000")
_object[_left_1] = _object_2
local _left_2 = "home"
local _object_3 = {}
local _left_3 = "title"
local _object_4 = {}
for _k, _v in pairs(darkTheme.home.title) do
	_object_4[_k] = _v
end
_object_4.foreground = hex("#ffffff")
_object_4.background = hex("#000000")
_object_4.dropshadow = hex("#000000")
_object_3[_left_3] = _object_4
local _left_4 = "profile"
local _object_5 = {}
for _k, _v in pairs(darkTheme.home.profile) do
	_object_5[_k] = _v
end
_object_5.foreground = hex("#ffffff")
_object_5.background = hex("#000000")
_object_5.dropshadow = hex("#000000")
local _left_5 = "avatar"
local _object_6 = {}
for _k, _v in pairs(darkTheme.home.profile.avatar) do
	_object_6[_k] = _v
end
_object_6.background = hex("#ffffff")
_object_6.transparency = 0.9
_object_6.gradient = {
	color = ColorSequence.new({ ColorSequenceKeypoint.new(0, hex("#F6BD29")), ColorSequenceKeypoint.new(0.5, hex("#F64229")), ColorSequenceKeypoint.new(1, hex("#000000")) }),
}
_object_5[_left_5] = _object_6
local _left_6 = "slider"
local _object_7 = {}
for _k, _v in pairs(darkTheme.home.profile.slider) do
	_object_7[_k] = _v
end
_object_7.foreground = hex("#ffffff")
_object_7.background = hex("#000000")
_object_5[_left_6] = _object_7
local _left_7 = "button"
local _object_8 = {}
for _k, _v in pairs(darkTheme.home.profile.button) do
	_object_8[_k] = _v
end
_object_8.foreground = hex("#ffffff")
_object_8.background = hex("#000000")
_object_5[_left_7] = _object_8
_object_3[_left_4] = _object_5
local _left_8 = "server"
local _object_9 = {}
for _k, _v in pairs(darkTheme.home.server) do
	_object_9[_k] = _v
end
_object_9.foreground = hex("#ffffff")
_object_9.background = hex("#000000")
_object_9.dropshadow = hex("#000000")
local _left_9 = "rejoinButton"
local _object_10 = {}
for _k, _v in pairs(darkTheme.home.server.rejoinButton) do
	_object_10[_k] = _v
end
_object_10.foreground = hex("#ffffff")
_object_10.background = hex("#000000")
_object_10.foregroundTransparency = 0.5
_object_10.accent = hex("#ff3f6c")
_object_9[_left_9] = _object_10
local _left_10 = "switchButton"
local _object_11 = {}
for _k, _v in pairs(darkTheme.home.server.switchButton) do
	_object_11[_k] = _v
end
_object_11.foreground = hex("#ffffff")
_object_11.background = hex("#000000")
_object_11.foregroundTransparency = 0.5
_object_11.accent = hex("#ff3f6c")
_object_9[_left_10] = _object_11
_object_3[_left_8] = _object_9
local _left_11 = "friendActivity"
local _object_12 = {}
for _k, _v in pairs(darkTheme.home.friendActivity) do
	_object_12[_k] = _v
end
_object_12.foreground = hex("#ffffff")
_object_12.background = hex("#000000")
_object_12.dropshadow = hex("#000000")
local _left_12 = "friendButton"
local _object_13 = {}
for _k, _v in pairs(darkTheme.home.friendActivity.friendButton) do
	_object_13[_k] = _v
end
_object_13.foreground = hex("#ffffff")
_object_13.background = hex("#000000")
_object_12[_left_12] = _object_13
_object_3[_left_11] = _object_12
_object[_left_2] = _object_3
local _left_13 = "apps"
local _object_14 = {}
local _left_14 = "players"
local _object_15 = {}
for _k, _v in pairs(darkTheme.apps.players) do
	_object_15[_k] = _v
end
_object_15.foreground = hex("#ffffff")
_object_15.background = hex("#000000")
_object_15.dropshadow = hex("#000000")
local _left_15 = "avatar"
local _object_16 = {}
for _k, _v in pairs(darkTheme.apps.players.avatar) do
	_object_16[_k] = _v
end
_object_16.background = hex("#ffffff")
_object_16.transparency = 0.9
_object_16.gradient = {
	color = ColorSequence.new({ ColorSequenceKeypoint.new(0, hex("#F6BD29")), ColorSequenceKeypoint.new(0.5, hex("#F64229")), ColorSequenceKeypoint.new(1, hex("#000000")) }),
}
_object_15[_left_15] = _object_16
local _left_16 = "button"
local _object_17 = {}
for _k, _v in pairs(darkTheme.apps.players.button) do
	_object_17[_k] = _v
end
_object_17.foreground = hex("#ffffff")
_object_17.background = hex("#000000")
_object_15[_left_16] = _object_17
local _left_17 = "playerButton"
local _object_18 = {}
for _k, _v in pairs(darkTheme.apps.players.playerButton) do
	_object_18[_k] = _v
end
_object_18.foreground = hex("#ffffff")
_object_18.background = hex("#000000")
_object_18.accent = hex("#ff3f6c")
_object_18.dropshadowTransparency = 0.7
_object_15[_left_17] = _object_18
_object_14[_left_14] = _object_15
_object[_left_13] = _object_14
local _left_18 = "options"
local _object_19 = {}
local _left_19 = "config"
local _object_20 = {}
for _k, _v in pairs(darkTheme.options.config) do
	_object_20[_k] = _v
end
_object_20.foreground = hex("#ffffff")
_object_20.background = hex("#000000")
_object_20.dropshadow = hex("#000000")
local _left_20 = "configButton"
local _object_21 = {}
for _k, _v in pairs(darkTheme.options.config.configButton) do
	_object_21[_k] = _v
end
_object_21.foreground = hex("#ffffff")
_object_21.background = hex("#000000")
_object_21.accent = hex("#ff3f6c")
_object_21.dropshadowTransparency = 0.7
_object_20[_left_20] = _object_21
_object_19[_left_19] = _object_20
local _left_21 = "shortcuts"
local _object_22 = {}
for _k, _v in pairs(darkTheme.options.shortcuts) do
	_object_22[_k] = _v
end
_object_22.foreground = hex("#ffffff")
_object_22.background = hex("#000000")
_object_22.dropshadow = hex("#000000")
local _left_22 = "shortcutButton"
local _object_23 = {}
for _k, _v in pairs(darkTheme.options.shortcuts.shortcutButton) do
	_object_23[_k] = _v
end
_object_23.foreground = hex("#ffffff")
_object_23.background = hex("#000000")
_object_23.accent = hex("#ff3f6c")
_object_23.dropshadowTransparency = 0.7
_object_22[_left_22] = _object_23
_object_19[_left_21] = _object_22
local _left_23 = "themes"
local _object_24 = {}
for _k, _v in pairs(darkTheme.options.themes) do
	_object_24[_k] = _v
end
_object_24.foreground = hex("#ffffff")
_object_24.background = hex("#000000")
_object_24.dropshadow = hex("#000000")
local _left_24 = "themeButton"
local _object_25 = {}
for _k, _v in pairs(darkTheme.options.themes.themeButton) do
	_object_25[_k] = _v
end
_object_25.foreground = hex("#ffffff")
_object_25.background = hex("#000000")
_object_25.accent = hex("#ff3f6c")
_object_25.dropshadowTransparency = 0.7
_object_24[_left_24] = _object_25
_object_19[_left_23] = _object_24
_object[_left_18] = _object_19
local highContrast = _object
return {
	highContrast = highContrast,
}

        end)
    end)
    hMod("light-theme", "ModuleScript", "Havoc.themes.light-theme", "Havoc.themes", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local darkTheme = TS.import(script, script.Parent, "sorbet").darkTheme
local hex = TS.import(script, script.Parent.Parent, "utils", "color3").hex
local _object = {}
for _k, _v in pairs(darkTheme) do
	_object[_k] = _v
end
_object.name = "Light theme"
_object.preview = {
	foreground = {
		color = ColorSequence.new(hex("#000000")),
	},
	background = {
		color = ColorSequence.new(hex("#ffffff")),
	},
	accent = {
		color = ColorSequence.new({ ColorSequenceKeypoint.new(0, hex("#F6BD29")), ColorSequenceKeypoint.new(0.5, hex("#F64229")), ColorSequenceKeypoint.new(1, hex("#000000")) }),
		rotation = 25,
	},
}
local _left = "navbar"
local _object_1 = {}
for _k, _v in pairs(darkTheme.navbar) do
	_object_1[_k] = _v
end
_object_1.foreground = hex("#000000")
_object_1.background = hex("#ffffff")
_object[_left] = _object_1
local _left_1 = "clock"
local _object_2 = {}
for _k, _v in pairs(darkTheme.clock) do
	_object_2[_k] = _v
end
_object_2.foreground = hex("#000000")
_object_2.background = hex("#ffffff")
_object[_left_1] = _object_2
local _left_2 = "home"
local _object_3 = {}
local _left_3 = "title"
local _object_4 = {}
for _k, _v in pairs(darkTheme.home.title) do
	_object_4[_k] = _v
end
_object_4.foreground = hex("#000000")
_object_4.background = hex("#ffffff")
_object_3[_left_3] = _object_4
local _left_4 = "profile"
local _object_5 = {}
for _k, _v in pairs(darkTheme.home.profile) do
	_object_5[_k] = _v
end
_object_5.foreground = hex("#000000")
_object_5.background = hex("#ffffff")
local _left_5 = "avatar"
local _object_6 = {}
for _k, _v in pairs(darkTheme.home.profile.avatar) do
	_object_6[_k] = _v
end
_object_6.background = hex("#000000")
_object_6.transparency = 0.9
_object_6.gradient = {
	color = ColorSequence.new(hex("#3ce09b")),
}
_object_5[_left_5] = _object_6
local _left_6 = "slider"
local _object_7 = {}
for _k, _v in pairs(darkTheme.home.profile.slider) do
	_object_7[_k] = _v
end
_object_7.foreground = hex("#000000")
_object_7.background = hex("#ffffff")
_object_5[_left_6] = _object_7
local _left_7 = "button"
local _object_8 = {}
for _k, _v in pairs(darkTheme.home.profile.button) do
	_object_8[_k] = _v
end
_object_8.foreground = hex("#000000")
_object_8.background = hex("#ffffff")
_object_5[_left_7] = _object_8
_object_3[_left_4] = _object_5
local _left_8 = "server"
local _object_9 = {}
for _k, _v in pairs(darkTheme.home.server) do
	_object_9[_k] = _v
end
_object_9.foreground = hex("#000000")
_object_9.background = hex("#ff3f6c")
_object_9.dropshadow = hex("#ff3f6c")
local _left_9 = "rejoinButton"
local _object_10 = {}
for _k, _v in pairs(darkTheme.home.server.rejoinButton) do
	_object_10[_k] = _v
end
_object_10.foreground = hex("#000000")
_object_10.background = hex("#ff3f6c")
_object_10.accent = hex("#ffffff")
_object_9[_left_9] = _object_10
local _left_10 = "switchButton"
local _object_11 = {}
for _k, _v in pairs(darkTheme.home.server.switchButton) do
	_object_11[_k] = _v
end
_object_11.foreground = hex("#000000")
_object_11.background = hex("#ff3f6c")
_object_11.accent = hex("#ffffff")
_object_9[_left_10] = _object_11
_object_3[_left_8] = _object_9
local _left_11 = "friendActivity"
local _object_12 = {}
for _k, _v in pairs(darkTheme.home.friendActivity) do
	_object_12[_k] = _v
end
_object_12.foreground = hex("#000000")
_object_12.background = hex("#ffffff")
local _left_12 = "friendButton"
local _object_13 = {}
for _k, _v in pairs(darkTheme.home.friendActivity.friendButton) do
	_object_13[_k] = _v
end
_object_13.foreground = hex("#ffffff")
_object_13.background = hex("#ffffff")
_object_12[_left_12] = _object_13
_object_3[_left_11] = _object_12
_object[_left_2] = _object_3
local _left_13 = "apps"
local _object_14 = {}
local _left_14 = "players"
local _object_15 = {}
for _k, _v in pairs(darkTheme.apps.players) do
	_object_15[_k] = _v
end
_object_15.foreground = hex("#000000")
_object_15.background = hex("#ffffff")
local _left_15 = "avatar"
local _object_16 = {}
for _k, _v in pairs(darkTheme.apps.players.avatar) do
	_object_16[_k] = _v
end
_object_16.background = hex("#000000")
_object_16.transparency = 0.9
_object_16.gradient = {
	color = ColorSequence.new(hex("#3ce09b")),
}
_object_15[_left_15] = _object_16
local _left_16 = "button"
local _object_17 = {}
for _k, _v in pairs(darkTheme.apps.players.button) do
	_object_17[_k] = _v
end
_object_17.foreground = hex("#000000")
_object_17.background = hex("#ffffff")
_object_15[_left_16] = _object_17
local _left_17 = "playerButton"
local _object_18 = {}
for _k, _v in pairs(darkTheme.apps.players.playerButton) do
	_object_18[_k] = _v
end
_object_18.foreground = hex("#000000")
_object_18.background = hex("#ffffff")
_object_18.backgroundHovered = hex("#eeeeee")
_object_18.accent = hex("#3ce09b")
_object_18.dropshadowTransparency = 0.7
_object_15[_left_17] = _object_18
_object_14[_left_14] = _object_15
_object[_left_13] = _object_14
local _left_18 = "options"
local _object_19 = {}
local _left_19 = "config"
local _object_20 = {}
for _k, _v in pairs(darkTheme.options.config) do
	_object_20[_k] = _v
end
_object_20.foreground = hex("#000000")
_object_20.background = hex("#ffffff")
local _left_20 = "configButton"
local _object_21 = {}
for _k, _v in pairs(darkTheme.options.config.configButton) do
	_object_21[_k] = _v
end
_object_21.foreground = hex("#000000")
_object_21.background = hex("#ffffff")
_object_21.backgroundHovered = hex("#eeeeee")
_object_21.accent = hex("#3ce09b")
_object_21.dropshadowTransparency = 0.7
_object_20[_left_20] = _object_21
_object_19[_left_19] = _object_20
local _left_21 = "shortcuts"
local _object_22 = {}
for _k, _v in pairs(darkTheme.options.shortcuts) do
	_object_22[_k] = _v
end
_object_22.foreground = hex("#000000")
_object_22.background = hex("#ffffff")
local _left_22 = "shortcutButton"
local _object_23 = {}
for _k, _v in pairs(darkTheme.options.shortcuts.shortcutButton) do
	_object_23[_k] = _v
end
_object_23.foreground = hex("#000000")
_object_23.background = hex("#ffffff")
_object_23.backgroundHovered = hex("#eeeeee")
_object_23.accent = hex("#3ce09b")
_object_23.dropshadowTransparency = 0.7
_object_22[_left_22] = _object_23
_object_19[_left_21] = _object_22
local _left_23 = "themes"
local _object_24 = {}
for _k, _v in pairs(darkTheme.options.themes) do
	_object_24[_k] = _v
end
_object_24.foreground = hex("#000000")
_object_24.background = hex("#ffffff")
local _left_24 = "themeButton"
local _object_25 = {}
for _k, _v in pairs(darkTheme.options.themes.themeButton) do
	_object_25[_k] = _v
end
_object_25.foreground = hex("#000000")
_object_25.background = hex("#ffffff")
_object_25.backgroundHovered = hex("#eeeeee")
_object_25.accent = hex("#3ce09b")
_object_25.dropshadowTransparency = 0.7
_object_24[_left_24] = _object_25
_object_19[_left_23] = _object_24
_object[_left_18] = _object_19
local lightTheme = _object
return {
	lightTheme = lightTheme,
}

        end)
    end)
    hMod("obsidian", "ModuleScript", "Havoc.themes.obsidian", "Havoc.themes", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local darkTheme = TS.import(script, script.Parent, "sorbet").darkTheme
local hex = TS.import(script, script.Parent.Parent, "utils", "color3").hex
local accent = hex("#000000")
local accentSequence = ColorSequence.new(hex("#000000"))
local _object = {}
for _k, _v in pairs(darkTheme) do
	_object[_k] = _v
end
_object.name = "Obsidian"
_object.preview = {
	foreground = {
		color = ColorSequence.new(hex("#ffffff")),
	},
	background = {
		color = ColorSequence.new(hex("#000000")),
	},
	accent = {
		color = ColorSequence.new(hex("#000000")),
	},
}
local _left = "navbar"
local _object_1 = {}
for _k, _v in pairs(darkTheme.navbar) do
	_object_1[_k] = _v
end
_object_1.acrylic = true
_object_1.outlined = false
_object_1.foreground = hex("#ffffff")
_object_1.background = hex("#000000")
_object_1.dropshadow = hex("#000000")
_object_1.transparency = 0.7
_object_1.accentGradient = {
	color = ColorSequence.new(hex("#000000")),
	transparency = NumberSequence.new(0.5),
}
_object[_left] = _object_1
local _left_1 = "clock"
local _object_2 = {}
for _k, _v in pairs(darkTheme.clock) do
	_object_2[_k] = _v
end
_object_2.acrylic = true
_object_2.outlined = false
_object_2.foreground = hex("#ffffff")
_object_2.background = hex("#000000")
_object_2.dropshadow = hex("#000000")
_object_2.transparency = 0.7
_object[_left_1] = _object_2
local _left_2 = "home"
local _object_3 = {}
local _left_3 = "title"
local _object_4 = {}
for _k, _v in pairs(darkTheme.home.title) do
	_object_4[_k] = _v
end
_object_4.acrylic = true
_object_4.outlined = false
_object_4.foreground = hex("#ffffff")
_object_4.background = hex("#000000")
_object_4.dropshadow = hex("#000000")
_object_4.transparency = 0.7
_object_4.dropshadowTransparency = 0.65
_object_3[_left_3] = _object_4
local _left_4 = "profile"
local _object_5 = {}
for _k, _v in pairs(darkTheme.home.profile) do
	_object_5[_k] = _v
end
_object_5.acrylic = true
_object_5.outlined = false
_object_5.foreground = hex("#ffffff")
_object_5.background = hex("#000000")
_object_5.dropshadow = hex("#000000")
_object_5.transparency = 0.7
_object_5.dropshadowTransparency = 0.65
local _left_5 = "avatar"
local _object_6 = {}
for _k, _v in pairs(darkTheme.home.profile.avatar) do
	_object_6[_k] = _v
end
_object_6.background = hex("#000000")
_object_6.transparency = 0.7
_object_6.gradient = {
	color = ColorSequence.new(hex("#000000")),
}
_object_5[_left_5] = _object_6
_object_5.highlight = {
	flight = accent,
	walkSpeed = accent,
	jumpHeight = accent,
	refresh = accent,
	ghost = accent,
	godmode = accent,
	freecam = accent,
}
local _left_6 = "slider"
local _object_7 = {}
for _k, _v in pairs(darkTheme.home.profile.slider) do
	_object_7[_k] = _v
end
_object_7.outlined = false
_object_7.foreground = hex("#ffffff")
_object_7.background = hex("#000000")
_object_7.backgroundTransparency = 0.5
_object_7.indicatorTransparency = 0.5
_object_5[_left_6] = _object_7
local _left_7 = "button"
local _object_8 = {}
for _k, _v in pairs(darkTheme.home.profile.button) do
	_object_8[_k] = _v
end
_object_8.outlined = false
_object_8.foreground = hex("#ffffff")
_object_8.background = hex("#000000")
_object_8.backgroundTransparency = 0.5
_object_5[_left_7] = _object_8
_object_3[_left_4] = _object_5
local _left_8 = "server"
local _object_9 = {}
for _k, _v in pairs(darkTheme.home.server) do
	_object_9[_k] = _v
end
_object_9.acrylic = true
_object_9.outlined = false
_object_9.foreground = hex("#ffffff")
_object_9.background = hex("#000000")
_object_9.dropshadow = hex("#000000")
_object_9.transparency = 0.7
_object_9.dropshadowTransparency = 0.65
local _left_9 = "rejoinButton"
local _object_10 = {}
for _k, _v in pairs(darkTheme.home.server.rejoinButton) do
	_object_10[_k] = _v
end
_object_10.outlined = false
_object_10.foreground = hex("#ffffff")
_object_10.background = hex("#000000")
_object_10.backgroundTransparency = 0.5
_object_10.foregroundTransparency = 0.5
_object_10.accent = accent
_object_9[_left_9] = _object_10
local _left_10 = "switchButton"
local _object_11 = {}
for _k, _v in pairs(darkTheme.home.server.switchButton) do
	_object_11[_k] = _v
end
_object_11.outlined = false
_object_11.foreground = hex("#ffffff")
_object_11.background = hex("#000000")
_object_11.backgroundTransparency = 0.5
_object_11.foregroundTransparency = 0.5
_object_11.accent = accent
_object_9[_left_10] = _object_11
_object_3[_left_8] = _object_9
local _left_11 = "friendActivity"
local _object_12 = {}
for _k, _v in pairs(darkTheme.home.friendActivity) do
	_object_12[_k] = _v
end
_object_12.acrylic = true
_object_12.outlined = false
_object_12.foreground = hex("#ffffff")
_object_12.background = hex("#000000")
_object_12.dropshadow = hex("#000000")
_object_12.transparency = 0.7
_object_12.dropshadowTransparency = 0.65
local _left_12 = "friendButton"
local _object_13 = {}
for _k, _v in pairs(darkTheme.home.friendActivity.friendButton) do
	_object_13[_k] = _v
end
_object_13.outlined = false
_object_13.foreground = hex("#ffffff")
_object_13.background = hex("#000000")
_object_13.dropshadow = hex("#000000")
_object_13.backgroundTransparency = 0.7
_object_12[_left_12] = _object_13
_object_3[_left_11] = _object_12
_object[_left_2] = _object_3
local _left_13 = "apps"
local _object_14 = {}
local _left_14 = "players"
local _object_15 = {}
for _k, _v in pairs(darkTheme.apps.players) do
	_object_15[_k] = _v
end
_object_15.acrylic = true
_object_15.outlined = false
_object_15.foreground = hex("#ffffff")
_object_15.background = hex("#000000")
_object_15.dropshadow = hex("#000000")
_object_15.transparency = 0.7
_object_15.dropshadowTransparency = 0.65
_object_15.highlight = {
	teleport = accent,
	hide = accent,
	kill = accent,
	spectate = accent,
}
local _left_15 = "avatar"
local _object_16 = {}
for _k, _v in pairs(darkTheme.apps.players.avatar) do
	_object_16[_k] = _v
end
_object_16.background = hex("#000000")
_object_16.transparency = 0.7
_object_16.gradient = {
	color = ColorSequence.new(hex("#000000")),
}
_object_15[_left_15] = _object_16
local _left_16 = "button"
local _object_17 = {}
for _k, _v in pairs(darkTheme.apps.players.button) do
	_object_17[_k] = _v
end
_object_17.outlined = false
_object_17.foreground = hex("#ffffff")
_object_17.background = hex("#000000")
_object_17.backgroundTransparency = 0.5
_object_15[_left_16] = _object_17
local _left_17 = "playerButton"
local _object_18 = {}
for _k, _v in pairs(darkTheme.apps.players.playerButton) do
	_object_18[_k] = _v
end
_object_18.outlined = false
_object_18.foreground = hex("#ffffff")
_object_18.background = hex("#000000")
_object_18.accent = accent
_object_18.backgroundTransparency = 0.5
_object_18.dropshadowTransparency = 0.7
_object_15[_left_17] = _object_18
_object_14[_left_14] = _object_15
_object[_left_13] = _object_14
local _left_18 = "options"
local _object_19 = {}
local _left_19 = "config"
local _object_20 = {}
for _k, _v in pairs(darkTheme.options.config) do
	_object_20[_k] = _v
end
_object_20.acrylic = true
_object_20.outlined = false
_object_20.foreground = hex("#ffffff")
_object_20.background = hex("#000000")
_object_20.dropshadow = hex("#000000")
_object_20.transparency = 0.7
_object_20.dropshadowTransparency = 0.65
local _left_20 = "configButton"
local _object_21 = {}
for _k, _v in pairs(darkTheme.options.config.configButton) do
	_object_21[_k] = _v
end
_object_21.outlined = false
_object_21.foreground = hex("#ffffff")
_object_21.background = hex("#000000")
_object_21.accent = accent
_object_21.backgroundTransparency = 0.5
_object_21.dropshadowTransparency = 0.7
_object_20[_left_20] = _object_21
_object_19[_left_19] = _object_20
local _left_21 = "shortcuts"
local _object_22 = {}
for _k, _v in pairs(darkTheme.options.shortcuts) do
	_object_22[_k] = _v
end
_object_22.acrylic = true
_object_22.outlined = false
_object_22.foreground = hex("#ffffff")
_object_22.background = hex("#000000")
_object_22.dropshadow = hex("#000000")
_object_22.transparency = 0.7
_object_22.dropshadowTransparency = 0.65
local _left_22 = "shortcutButton"
local _object_23 = {}
for _k, _v in pairs(darkTheme.options.shortcuts.shortcutButton) do
	_object_23[_k] = _v
end
_object_23.outlined = false
_object_23.foreground = hex("#ffffff")
_object_23.background = hex("#000000")
_object_23.accent = accent
_object_23.backgroundTransparency = 0.5
_object_23.dropshadowTransparency = 0.7
_object_22[_left_22] = _object_23
_object_19[_left_21] = _object_22
local _left_23 = "themes"
local _object_24 = {}
for _k, _v in pairs(darkTheme.options.themes) do
	_object_24[_k] = _v
end
_object_24.acrylic = true
_object_24.outlined = false
_object_24.foreground = hex("#ffffff")
_object_24.background = hex("#000000")
_object_24.dropshadow = hex("#000000")
_object_24.transparency = 0.7
_object_24.dropshadowTransparency = 0.65
local _left_24 = "themeButton"
local _object_25 = {}
for _k, _v in pairs(darkTheme.options.themes.themeButton) do
	_object_25[_k] = _v
end
_object_25.outlined = false
_object_25.foreground = hex("#ffffff")
_object_25.background = hex("#000000")
_object_25.accent = accent
_object_25.backgroundTransparency = 0.5
_object_25.dropshadowTransparency = 0.7
_object_24[_left_24] = _object_25
_object_19[_left_23] = _object_24
_object[_left_18] = _object_19
local obsidian = _object
return {
	obsidian = obsidian,
}

        end)
    end)
    hMod("sorbet", "ModuleScript", "Havoc.themes.sorbet", "Havoc.themes", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local hex = TS.import(script, script.Parent.Parent, "utils", "color3").hex
local redAccent = hex("#C6428E")
local blueAccent = hex("#484fd7")
local mixedAccent = hex("#9a3fe5")
local accentSequence = ColorSequence.new({ ColorSequenceKeypoint.new(0, redAccent), ColorSequenceKeypoint.new(0.5, mixedAccent), ColorSequenceKeypoint.new(1, blueAccent) })
local background = hex("#181818")
local backgroundDark = hex("#242424")
local view = {
	acrylic = false,
	outlined = false,
	foreground = hex("#ffffff"),
	background = background,
	transparency = 0,
	dropshadow = background,
	dropshadowTransparency = 0.3,
}
local _object = {
	name = "Sorbet",
	preview = {
		foreground = {
			color = ColorSequence.new(hex("#ffffff")),
		},
		background = {
			color = ColorSequence.new(background),
		},
		accent = {
			color = accentSequence,
		},
	},
	navbar = {
		outlined = false,
		acrylic = false,
		foreground = hex("#ffffff"),
		background = background,
		transparency = 0,
		accentGradient = {
			color = accentSequence,
		},
		dropshadow = background,
		dropshadowTransparency = 0.3,
		glowTransparency = 0,
	},
	clock = {
		outlined = false,
		acrylic = false,
		foreground = hex("#ffffff"),
		background = background,
		transparency = 0,
		dropshadow = background,
		dropshadowTransparency = 0.3,
	},
}
local _left = "home"
local _object_1 = {}
local _left_1 = "title"
local _object_2 = {}
for _k, _v in pairs(view) do
	_object_2[_k] = _v
end
_object_2.background = hex("#ffffff")
_object_2.backgroundGradient = {
	color = accentSequence,
	rotation = 30,
}
_object_2.dropshadow = hex("#ffffff")
_object_2.dropshadowGradient = {
	color = accentSequence,
	rotation = 30,
}
_object_2.dropshadowTransparency = 0.3
_object_1[_left_1] = _object_2
local _left_2 = "profile"
local _object_3 = {}
for _k, _v in pairs(view) do
	_object_3[_k] = _v
end
_object_3.avatar = {
	background = backgroundDark,
	transparency = 0,
	gradient = {
		color = accentSequence,
		rotation = 45,
	},
}
_object_3.highlight = {
	flight = redAccent,
	walkSpeed = mixedAccent,
	jumpHeight = blueAccent,
	refresh = redAccent,
	ghost = blueAccent,
	godmode = redAccent,
	freecam = blueAccent,
}
_object_3.slider = {
	outlined = false,
	foreground = hex("#ffffff"),
	foregroundTransparency = 0,
	background = backgroundDark,
	backgroundTransparency = 0,
}
_object_3.button = {
	outlined = false,
	foreground = hex("#ffffff"),
	foregroundTransparency = 0.5,
	background = backgroundDark,
	backgroundTransparency = 0,
}
_object_1[_left_2] = _object_3
local _left_3 = "server"
local _object_4 = {}
for _k, _v in pairs(view) do
	_object_4[_k] = _v
end
_object_4.rejoinButton = {
	outlined = false,
	foreground = hex("#ffffff"),
	background = backgroundDark,
	foregroundTransparency = 0.5,
	backgroundTransparency = 0,
	accent = redAccent,
}
_object_4.switchButton = {
	outlined = false,
	foreground = hex("#ffffff"),
	background = backgroundDark,
	foregroundTransparency = 0.5,
	backgroundTransparency = 0,
	accent = blueAccent,
}
_object_1[_left_3] = _object_4
local _left_4 = "friendActivity"
local _object_5 = {}
for _k, _v in pairs(view) do
	_object_5[_k] = _v
end
_object_5.friendButton = {
	outlined = false,
	foreground = hex("#ffffff"),
	background = backgroundDark,
	foregroundTransparency = 0,
	backgroundTransparency = 0,
	dropshadow = backgroundDark,
	dropshadowTransparency = 0.4,
	glowTransparency = 0.6,
	accent = mixedAccent,
}
_object_1[_left_4] = _object_5
_object[_left] = _object_1
local _left_5 = "apps"
local _object_6 = {}
local _left_6 = "players"
local _object_7 = {}
for _k, _v in pairs(view) do
	_object_7[_k] = _v
end
_object_7.highlight = {
	teleport = redAccent,
	hide = blueAccent,
	kill = redAccent,
	spectate = blueAccent,
}
_object_7.avatar = {
	background = backgroundDark,
	transparency = 0,
	gradient = {
		color = accentSequence,
		rotation = 45,
	},
}
_object_7.button = {
	outlined = false,
	foreground = hex("#ffffff"),
	foregroundTransparency = 0.5,
	background = backgroundDark,
	backgroundTransparency = 0,
}
_object_7.playerButton = {
	outlined = false,
	foreground = hex("#ffffff"),
	foregroundTransparency = 0.5,
	background = backgroundDark,
	backgroundTransparency = 0,
	dropshadow = backgroundDark,
	dropshadowTransparency = 0.5,
	glowTransparency = 0.2,
	accent = blueAccent,
}
_object_6[_left_6] = _object_7
_object[_left_5] = _object_6
local _left_7 = "options"
local _object_8 = {}
local _left_8 = "themes"
local _object_9 = {}
for _k, _v in pairs(view) do
	_object_9[_k] = _v
end
_object_9.themeButton = {
	outlined = false,
	foreground = hex("#ffffff"),
	foregroundTransparency = 0.5,
	background = backgroundDark,
	backgroundTransparency = 0,
	dropshadow = backgroundDark,
	dropshadowTransparency = 0.5,
	glowTransparency = 0.2,
	accent = blueAccent,
}
_object_8[_left_8] = _object_9
local _left_9 = "shortcuts"
local _object_10 = {}
for _k, _v in pairs(view) do
	_object_10[_k] = _v
end
_object_10.shortcutButton = {
	outlined = false,
	foreground = hex("#ffffff"),
	foregroundTransparency = 0.5,
	background = backgroundDark,
	backgroundTransparency = 0,
	dropshadow = backgroundDark,
	dropshadowTransparency = 0.5,
	glowTransparency = 0.2,
	accent = mixedAccent,
}
_object_8[_left_9] = _object_10
local _left_10 = "config"
local _object_11 = {}
for _k, _v in pairs(view) do
	_object_11[_k] = _v
end
_object_11.configButton = {
	outlined = false,
	foreground = hex("#ffffff"),
	foregroundTransparency = 0.5,
	background = backgroundDark,
	backgroundTransparency = 0,
	dropshadow = backgroundDark,
	dropshadowTransparency = 0.5,
	glowTransparency = 0.2,
	accent = redAccent,
}
_object_8[_left_10] = _object_11
_object[_left_7] = _object_8
local darkTheme = _object
return {
	darkTheme = darkTheme,
}

        end)
    end)
    hMod("theme.interface", "ModuleScript", "Havoc.themes.theme.interface", "Havoc.themes", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7

        end)
    end)
    hInst("utils", "Folder", "Havoc.utils", "Havoc")
    hMod("array-util", "ModuleScript", "Havoc.utils.array-util", "Havoc.utils", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local function arrayToMap(arr, mapper)
	-- ▼ ReadonlyArray.map ▼
	local _newValue = table.create(#arr)
	for _k, _v in ipairs(arr) do
		_newValue[_k] = mapper(_v, _k - 1, arr)
	end
	-- ▲ ReadonlyArray.map ▲
	local _map = {}
	for _, _v in ipairs(_newValue) do
		_map[_v[1] ] = _v[2]
	end
	return _map
end
return {
	arrayToMap = arrayToMap,
}

        end)
    end)
    hMod("binding-util", "ModuleScript", "Havoc.utils.binding-util", "Havoc.utils", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local function isBinding(binding)
	return type(binding) == "table" and binding.getValue ~= nil
end
local function mapBinding(value, transform)
	return isBinding(value) and value:map(transform) or (Roact.createBinding(transform(value)))
end
local function asBinding(value)
	return isBinding(value) and value or (Roact.createBinding(value))
end
return {
	isBinding = isBinding,
	mapBinding = mapBinding,
	asBinding = asBinding,
}

        end)
    end)
    hMod("color3", "ModuleScript", "Havoc.utils.color3", "Havoc.utils", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local function getLuminance(color)
	if typeof(color) == "ColorSequence" then
		color = color.Keypoints[1].Value
	end
	return color.R * 0.2126 + color.G * 0.7152 + color.B * 0.0722
end
local function getColorInSequence(sequence, alpha)
	local index = math.floor(alpha * (#sequence.Keypoints - 1))
	local nextIndex = math.min(index + 1, #sequence.Keypoints - 1)
	local _condition = sequence.Keypoints[index + 1]
	if _condition == nil then
		_condition = sequence.Keypoints[1]
	end
	local keypoint = _condition
	local _condition_1 = sequence.Keypoints[nextIndex + 1]
	if _condition_1 == nil then
		_condition_1 = keypoint
	end
	local nextKeypoint = _condition_1
	return keypoint.Value:Lerp(nextKeypoint.Value, alpha * (#sequence.Keypoints - 1) - index)
end
local hexStringToInt = function(hex)
	local newHex = string.gsub(hex, "#", "0x", 1)
	local _condition = tonumber(newHex)
	if _condition == nil then
		_condition = 0
	end
	return _condition
end
local intToColor3 = function(i)
	return Color3.fromRGB(math.floor(i / 65536) % 256, math.floor(i / 256) % 256, i % 256)
end
local hex = function(hex)
	return intToColor3(hexStringToInt(hex))
end
local rgb = function(r, g, b)
	return Color3.fromRGB(r, g, b)
end
local hsv = function(h, s, v)
	return Color3.fromHSV(h / 360, s / 100, v / 100)
end
local hsl = function(h, s, l)
	local hsv1 = (s * (l < 50 and l or 100 - l)) / 100
	local hsvS = hsv1 == 0 and 0 or ((2 * hsv1) / (l + hsv1)) * 100
	local hsvV = l + hsv1
	return Color3.fromHSV(h / 255, hsvS / 100, hsvV / 100)
end
return {
	getLuminance = getLuminance,
	getColorInSequence = getColorInSequence,
	hex = hex,
	rgb = rgb,
	hsv = hsv,
	hsl = hsl,
}

        end)
    end)
    hMod("debug", "ModuleScript", "Havoc.utils.debug", "Havoc.utils", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Stats = TS.import(script, TS.getModule(script, "@rbxts", "services")).Stats
local debugCounter = {}
local startTimes = {}
local function startTimer(name)
	local _condition = debugCounter[name]
	if _condition == nil then
		_condition = 0
	end
	debugCounter[name] = _condition + 1
	startTimes[name] = os.clock()
end
local function endTimer(name)
	local startTime = startTimes[name]
	if startTime == nil then
		return nil
	end
	local diff = os.clock() - startTime
	local _condition = debugCounter[name]
	if _condition == nil then
		_condition = 0
	end
	local count = _condition
	print("\n[Havoc Timer: " .. (name .. (" #" .. (tostring(count) .. ("]\nExecution: " .. (tostring(math.floor(diff * 10000) / 10) .. " ms\n"))))))
	startTimes[name + 1] = nil
end
local logger = {
	info = function(msg)
		return print("[Havoc INFO]: " .. msg)
	end,
	warn = function(msg)
		return warn("[Havoc WARNING]: " .. msg)
	end,
	critical = function(msg)
		warn("\n---------- CRITICAL ERROR ----------\n" .. (msg .. "\n------------------------------------\n"))
	end,
	debug = function(msg)
		local _value = _G["__DEV__" + 1]
		if _value ~= 0 and (_value == _value and (_value ~= "" and _value)) then
			print("[DEBUG]: " .. msg)
		end
	end,
}
local function logPerformance()
	local mem = Stats:GetTotalMemoryUsageMb()
	print("\n--- Havoc Performance ---")
	print("Memory: " .. (tostring(math.floor(mem)) .. " MB"))
	print("Lua GC: " .. (tostring(math.floor(collectgarbage("count"))) .. " KB"))
	print("-------------------------\n")
end
return {
	startTimer = startTimer,
	endTimer = endTimer,
	logPerformance = logPerformance,
	logger = logger,
}

        end)
    end)
    hMod("http", "ModuleScript", "Havoc.utils.http", "Havoc.utils", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local HttpService = TS.import(script, TS.getModule(script, "@rbxts", "services")).HttpService
local IS_DEV = TS.import(script, script.Parent.Parent, "constants").IS_DEV
local request
request = TS.async(function(requestOptions)
	if IS_DEV then
		return HttpService:RequestAsync(requestOptions)
	else
		local fn = syn and syn.request or request
		if not fn then
			error("request/syn.request is not available")
		end
		return fn(requestOptions)
	end
end)
local get = TS.async(function(url, requestType)
	return game:HttpGetAsync(url, requestType)
end)
local post = TS.async(function(url, data, contentType, requestType)
	return game:HttpPostAsync(url, data, contentType, requestType)
end)
return {
	request = request,
	get = get,
	post = post,
}

        end)
    end)
    hMod("number-util", "ModuleScript", "Havoc.utils.number-util", "Havoc.utils", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local function map(n, min0, max0, min1, max1)
	return min1 + ((n - min0) * (max1 - min1)) / (max0 - min0)
end
local function lerp(a, b, t)
	return a + (b - a) * t
end
return {
	map = map,
	lerp = lerp,
}

        end)
    end)
    hMod("timeout", "ModuleScript", "Havoc.utils.timeout", "Havoc.utils", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local RunService = TS.import(script, TS.getModule(script, "@rbxts", "services")).RunService
local Timeout
do
	Timeout = setmetatable({}, {
		__tostring = function()
			return "Timeout"
		end,
	})
	Timeout.__index = Timeout
	function Timeout.new(...)
		local self = setmetatable({}, Timeout)
		return self:constructor(...) or self
	end
	function Timeout:constructor(callback, milliseconds, ...)
		local args = { ... }
		self.running = true
		task.delay(milliseconds / 1000, function()
			if self.running then
				callback(unpack(args))
			end
		end)
	end
	function Timeout:clear()
		self.running = false
	end
end
local function setTimeout(callback, milliseconds, ...)
	local args = { ... }
	return Timeout.new(callback, milliseconds, unpack(args))
end
local function clearTimeout(timeout)
	timeout:clear()
end
local Interval
do
	Interval = setmetatable({}, {
		__tostring = function()
			return "Interval"
		end,
	})
	Interval.__index = Interval
	function Interval.new(...)
		local self = setmetatable({}, Interval)
		return self:constructor(...) or self
	end
	function Interval:constructor(callback, milliseconds, ...)
		local args = { ... }
		self.running = true
		task.defer(function()
			local clock = 0
			local hb
			hb = RunService.Heartbeat:Connect(function(step)
				clock += step
				if not self.running then
					hb:Disconnect()
				elseif clock >= milliseconds / 1000 then
					clock -= milliseconds / 1000
					callback(unpack(args))
				end
			end)
		end)
	end
	function Interval:clear()
		self.running = false
	end
end
local function setInterval(callback, milliseconds, ...)
	local args = { ... }
	return Interval.new(callback, milliseconds, unpack(args))
end
local function clearInterval(interval)
	interval:clear()
end
return {
	setTimeout = setTimeout,
	clearTimeout = clearTimeout,
	setInterval = setInterval,
	clearInterval = clearInterval,
	Timeout = Timeout,
	Interval = Interval,
}

        end)
    end)
    hMod("udim2", "ModuleScript", "Havoc.utils.udim2", "Havoc.utils", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local function px(x, y)
	return UDim2.new(0, x, 0, y)
end
local function scale(x, y)
	return UDim2.new(x, 0, y, 0)
end
local function applyUDim2(size, udim2, scaleFactor)
	if scaleFactor == nil then
		scaleFactor = 1
	end
	return Vector2.new(udim2.X.Offset + (udim2.X.Scale / scaleFactor) * size.X, udim2.Y.Offset + (udim2.Y.Scale / scaleFactor) * size.Y)
end
return {
	px = px,
	scale = scale,
	applyUDim2 = applyUDim2,
}

        end)
    end)
    hInst("views", "Folder", "Havoc.views", "Havoc")
    hMod("Clock", "ModuleScript", "Havoc.views.Clock", "Havoc.views", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Clock").default
return exports

        end)
    end)
    hMod("Clock", "ModuleScript", "Havoc.views.Clock.Clock", "Havoc.views.Clock", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local hooked = _roact_hooked.hooked
local useEffect = _roact_hooked.useEffect
local useMemo = _roact_hooked.useMemo
local useState = _roact_hooked.useState
local TextService = TS.import(script, TS.getModule(script, "@rbxts", "services")).TextService
local Acrylic = TS.import(script, script.Parent.Parent.Parent, "components", "Acrylic").default
local Border = TS.import(script, script.Parent.Parent.Parent, "components", "Border").default
local Fill = TS.import(script, script.Parent.Parent.Parent, "components", "Fill").default
local _Glow = TS.import(script, script.Parent.Parent.Parent, "components", "Glow")
local Glow = _Glow.default
local GlowRadius = _Glow.GlowRadius
local useAppSelector = TS.import(script, script.Parent.Parent.Parent, "hooks", "common", "rodux-hooks").useAppSelector
local useSpring = TS.import(script, script.Parent.Parent.Parent, "hooks", "common", "use-spring").useSpring
local useTheme = TS.import(script, script.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local setInterval = TS.import(script, script.Parent.Parent.Parent, "utils", "timeout").setInterval
local px = TS.import(script, script.Parent.Parent.Parent, "utils", "udim2").px
local MIN_CLOCK_SIZE = px(56, 56)
local CLOCK_PADDING = 14
local function getTime()
	return (string.gsub(os.date("%I:%M %p"), "^0([0-9])", "%1"))
end
local function Clock()
	local isOpen = useAppSelector(function(state)
		return state.dashboard.isOpen
	end)
	local theme = useTheme("clock")
	local _binding = useState(getTime())
	local currentTime = _binding[1]
	local setTime = _binding[2]
	local textWidth = useMemo(function()
		return TextService:GetTextSize(currentTime, 20, "GothamBold", Vector2.new(200, 56))
	end, { currentTime })
	useEffect(function()
		local interval = setInterval(function()
			return setTime(getTime())
		end, 1000)
		return function()
			return interval:clear()
		end
	end, {})
	local _attributes = {}
	local _arg0 = px(textWidth.X + CLOCK_PADDING, 0)
	_attributes.Size = MIN_CLOCK_SIZE + _arg0
	_attributes.Position = useSpring(isOpen and UDim2.new(0, 0, 1, 0) or UDim2.new(0, 0, 1, 48 + 56 + 20), {})
	_attributes.AnchorPoint = Vector2.new(0, 1)
	_attributes.BackgroundTransparency = 1
	local _children = {
		Roact.createElement(Glow, {
			radius = GlowRadius.Size146,
			size = UDim2.new(1, 80, 0, 146),
			position = px(-40, -20),
			color = theme.dropshadow,
			gradient = theme.dropshadowGradient,
			transparency = theme.transparency,
		}),
		Roact.createElement(Fill, {
			color = theme.background,
			gradient = theme.backgroundGradient,
			transparency = theme.transparency,
			radius = 8,
		}),
	}
	local _length = #_children
	local _child = theme.outlined and Roact.createFragment({
		border = Roact.createElement(Border, {
			color = theme.foreground,
			radius = 8,
			transparency = 0.8,
		}),
	})
	if _child then
		if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then
			_children[_length + 1] = _child
		else
			for _k, _v in ipairs(_child) do
				_children[_length + _k] = _v
			end
		end
	end
	_length = #_children
	_children[_length + 1] = Roact.createElement("ImageLabel", {
		Image = "rbxassetid://8992234911",
		ImageColor3 = theme.foreground,
		Size = px(36, 36),
		Position = px(10, 10),
		BackgroundTransparency = 1,
	})
	_children[_length + 2] = Roact.createElement("TextLabel", {
		Text = currentTime,
		Font = "GothamBold",
		TextColor3 = theme.foreground,
		TextSize = 20,
		TextXAlignment = "Left",
		TextYAlignment = "Center",
		Size = px(0, 0),
		Position = px(51, 27),
		BackgroundTransparency = 1,
	})
	local _child_1 = theme.acrylic and Roact.createElement(Acrylic)
	if _child_1 then
		if _child_1.elements ~= nil or _child_1.props ~= nil and _child_1.component ~= nil then
			_children[_length + 3] = _child_1
		else
			for _k, _v in ipairs(_child_1) do
				_children[_length + 2 + _k] = _v
			end
		end
	end
	return Roact.createElement("Frame", _attributes, _children)
end
local default = hooked(Clock)
return {
	default = default,
}

        end)
    end)
    hMod("Dashboard", "ModuleScript", "Havoc.views.Dashboard", "Havoc.views", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Dashboard").default
return exports

        end)
    end)
    hMod("Dashboard", "ModuleScript", "Havoc.views.Dashboard.Dashboard", "Havoc.views.Dashboard", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local hooked = _roact_hooked.hooked
local useMemo = _roact_hooked.useMemo
local Canvas = TS.import(script, script.Parent.Parent.Parent, "components", "Canvas").default
local ScaleContext = TS.import(script, script.Parent.Parent.Parent, "context", "scale-context").ScaleContext
local useAppSelector = TS.import(script, script.Parent.Parent.Parent, "hooks", "common", "rodux-hooks").useAppSelector
local useSpring = TS.import(script, script.Parent.Parent.Parent, "hooks", "common", "use-spring").useSpring
local useViewportSize = TS.import(script, script.Parent.Parent.Parent, "hooks", "common", "use-viewport-size").useViewportSize
local hex = TS.import(script, script.Parent.Parent.Parent, "utils", "color3").hex
local map = TS.import(script, script.Parent.Parent.Parent, "utils", "number-util").map
local scale = TS.import(script, script.Parent.Parent.Parent, "utils", "udim2").scale
local Hint = TS.import(script, script.Parent.Parent, "Hint").default
local Clock = TS.import(script, script.Parent.Parent, "Clock").default
local Navbar = TS.import(script, script.Parent.Parent, "Navbar").default
local Pages = TS.import(script, script.Parent.Parent, "Pages").default
local PADDING_MIN_HEIGHT = 980
local PADDING_MAX_HEIGHT = 1080
local MIN_PADDING_Y = 14
local MAX_PADDING_Y = 48
local function getPaddingY(height)
	if height < PADDING_MAX_HEIGHT and height >= PADDING_MIN_HEIGHT then
		return map(height, PADDING_MIN_HEIGHT, PADDING_MAX_HEIGHT, MIN_PADDING_Y, MAX_PADDING_Y)
	elseif height < PADDING_MIN_HEIGHT then
		return MIN_PADDING_Y
	else
		return MAX_PADDING_Y
	end
end
local function getScale(height)
	if height < PADDING_MIN_HEIGHT then
		return map(height, PADDING_MIN_HEIGHT, 130, 1, 0)
	else
		return 1
	end
end
local function Dashboard()
	local viewportSize = useViewportSize()
	local isOpen = useAppSelector(function(state)
		return state.dashboard.isOpen
	end)
	local _binding = useMemo(function()
		return { viewportSize:map(function(s)
			return getScale(s.Y)
		end), viewportSize:map(function(s)
			return getPaddingY(s.Y)
		end) }
	end, { viewportSize })
	local scaleFactor = _binding[1]
	local padding = _binding[2]
	return Roact.createElement(ScaleContext.Provider, {
		value = scaleFactor,
	}, {
		Roact.createElement("Frame", {
			Size = scale(1, 1),
			BackgroundColor3 = hex("#000000"),
			BackgroundTransparency = useSpring(isOpen and 0 or 1, {}),
			BorderSizePixel = 0,
		}, {
			Roact.createElement("UIGradient", {
				Transparency = NumberSequence.new(1, 0.25),
				Rotation = 90,
			}),
		}),
		Roact.createElement(Canvas, {
			padding = {
				top = 48,
				bottom = padding,
				left = 48,
				right = 48,
			},
		}, {
			Roact.createElement(Canvas, {
				padding = {
					bottom = padding:map(function(p)
						return 56 + p
					end),
				},
			}, {
				Roact.createElement(Pages),
				Roact.createElement(Hint),
			}),
			Roact.createElement(Navbar),
			Roact.createElement(Clock),
		}),
	})
end
local default = hooked(Dashboard)
return {
	default = default,
}

        end)
    end)
    hMod("Dashboard.story", "ModuleScript", "Havoc.views.Dashboard.Dashboard.story", "Havoc.views.Dashboard", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local Provider = TS.import(script, TS.getModule(script, "@rbxts", "roact-rodux-hooked").out).Provider
local DashboardPage = TS.import(script, script.Parent.Parent.Parent, "store", "models", "dashboard.model").DashboardPage
local configureStore = TS.import(script, script.Parent.Parent.Parent, "store", "store").configureStore
local Dashboard = TS.import(script, script.Parent, "Dashboard").default
return function(target)
	local handle = Roact.mount(Roact.createElement(Provider, {
		store = configureStore({
			dashboard = {
				isOpen = true,
				page = DashboardPage.Home,
				hint = nil,
				apps = {},
			},
		}),
	}, {
		Roact.createElement(Dashboard),
	}), target, "Dashboard")
	return function()
		return Roact.unmount(handle)
	end
end

        end)
    end)
    hMod("Hint", "ModuleScript", "Havoc.views.Hint", "Havoc.views", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Hint").default
return exports

        end)
    end)
    hMod("Hint", "ModuleScript", "Havoc.views.Hint.Hint", "Havoc.views.Hint", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local hooked = _roact_hooked.hooked
local useEffect = _roact_hooked.useEffect
local useState = _roact_hooked.useState
local useAppSelector = TS.import(script, script.Parent.Parent.Parent, "hooks", "common", "rodux-hooks").useAppSelector
local useDelayedUpdate = TS.import(script, script.Parent.Parent.Parent, "hooks", "common", "use-delayed-update").useDelayedUpdate
local useSpring = TS.import(script, script.Parent.Parent.Parent, "hooks", "common", "use-spring").useSpring
local useScale = TS.import(script, script.Parent.Parent.Parent, "hooks", "use-scale").useScale
local hex = TS.import(script, script.Parent.Parent.Parent, "utils", "color3").hex
local scale = TS.import(script, script.Parent.Parent.Parent, "utils", "udim2").scale
local function Hint()
	local scaleFactor = useScale()
	local hint = useAppSelector(function(state)
		return state.dashboard.hint
	end)
	local isDashboardOpen = useAppSelector(function(state)
		return state.dashboard.isOpen
	end)
	local _condition = hint
	if _condition == nil then
		_condition = ""
	end
	local _binding = useState(_condition)
	local hintDisplay = _binding[1]
	local setHintDisplay = _binding[2]
	local isHintVisible = useDelayedUpdate(hint ~= nil and isDashboardOpen, 500, function(visible)
		return not visible
	end)
	useEffect(function()
		if isHintVisible and hint ~= nil then
			setHintDisplay(hint)
		end
	end, { hint, isHintVisible })
	return Roact.createElement("TextLabel", {
		RichText = true,
		Text = hintDisplay,
		TextXAlignment = "Right",
		TextYAlignment = "Bottom",
		TextColor3 = hex("#FFFFFF"),
		TextTransparency = useSpring(isHintVisible and 0.4 or 1, {}),
		Font = "GothamSemibold",
		TextSize = 18,
		BackgroundTransparency = 1,
		Position = useSpring(isHintVisible and scale(1, 1) or UDim2.new(1, 0, 1, 48), {}),
	}, {
		Roact.createElement("UIScale", {
			Scale = scaleFactor,
		}),
	})
end
local default = hooked(Hint)
return {
	default = default,
}

        end)
    end)
    hMod("Navbar", "ModuleScript", "Havoc.views.Navbar", "Havoc.views", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Navbar").default
return exports

        end)
    end)
    hMod("Navbar", "ModuleScript", "Havoc.views.Navbar.Navbar", "Havoc.views.Navbar", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).hooked
local Acrylic = TS.import(script, script.Parent.Parent.Parent, "components", "Acrylic").default
local Border = TS.import(script, script.Parent.Parent.Parent, "components", "Border").default
local Canvas = TS.import(script, script.Parent.Parent.Parent, "components", "Canvas").default
local Fill = TS.import(script, script.Parent.Parent.Parent, "components", "Fill").default
local _Glow = TS.import(script, script.Parent.Parent.Parent, "components", "Glow")
local Glow = _Glow.default
local GlowRadius = _Glow.GlowRadius
local useAppSelector = TS.import(script, script.Parent.Parent.Parent, "hooks", "common", "rodux-hooks").useAppSelector
local useSpring = TS.import(script, script.Parent.Parent.Parent, "hooks", "common", "use-spring").useSpring
local useCurrentPage = TS.import(script, script.Parent.Parent.Parent, "hooks", "use-current-page").useCurrentPage
local useTheme = TS.import(script, script.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local _dashboard_model = TS.import(script, script.Parent.Parent.Parent, "store", "models", "dashboard.model")
local DashboardPage = _dashboard_model.DashboardPage
local PAGE_TO_INDEX = _dashboard_model.PAGE_TO_INDEX
local _color3 = TS.import(script, script.Parent.Parent.Parent, "utils", "color3")
local getColorInSequence = _color3.getColorInSequence
local hex = _color3.hex
local _udim2 = TS.import(script, script.Parent.Parent.Parent, "utils", "udim2")
local px = _udim2.px
local scale = _udim2.scale
local NavbarTab = TS.import(script, script.Parent, "NavbarTab").default
local NAVBAR_SIZE = px(500, 56)
local Underglow
local function Navbar()
	local theme = useTheme("navbar")
	local page = useCurrentPage()
	local isOpen = useAppSelector(function(state)
		return state.dashboard.isOpen
	end)
	local alpha = useSpring(PAGE_TO_INDEX[page] / 4, {
		frequency = 3.9,
		dampingRatio = 0.76,
	})
	local _attributes = {
		Size = NAVBAR_SIZE,
		Position = useSpring(isOpen and UDim2.new(0.5, 0, 1, -20) or UDim2.new(0.5, 0, 1, 100), {}),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 1,
	}
	local _children = {
		Roact.createElement(Glow, {
			radius = GlowRadius.Size146,
			size = UDim2.new(1, 80, 0, 146),
			position = px(-40, -20),
			color = theme.dropshadow,
			gradient = theme.dropshadowGradient,
			transparency = theme.transparency,
		}),
		Roact.createElement(Underglow, {
			transparency = theme.glowTransparency,
			position = alpha,
			sequenceColor = alpha:map(function(a)
				return getColorInSequence(theme.accentGradient.color, a)
			end),
		}),
		Roact.createElement(Fill, {
			color = theme.background,
			gradient = theme.backgroundGradient,
			radius = 8,
			transparency = theme.transparency,
		}),
		Roact.createElement(Canvas, {
			size = px(100, 56),
			position = alpha:map(function(a)
				return scale(a, 0)
			end),
			clipsDescendants = true,
		}, {
			Roact.createElement("Frame", {
				Size = NAVBAR_SIZE,
				Position = alpha:map(function(a)
					return scale(-a, 0)
				end),
				BackgroundColor3 = hex("#FFFFFF"),
				BorderSizePixel = 0,
			}, {
				Roact.createElement("UIGradient", {
					Color = theme.accentGradient.color,
					Transparency = theme.accentGradient.transparency,
					Rotation = theme.accentGradient.rotation,
				}),
				Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
			}),
		}),
	}
	local _length = #_children
	local _child = theme.outlined and Roact.createFragment({
		border = Roact.createElement(Border, {
			color = theme.foreground,
			radius = 8,
			transparency = 0.8,
		}),
	})
	if _child then
		if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then
			_children[_length + 1] = _child
		else
			for _k, _v in ipairs(_child) do
				_children[_length + _k] = _v
			end
		end
	end
	_length = #_children
	_children[_length + 1] = Roact.createElement(NavbarTab, {
		page = DashboardPage.Home,
	})
	_children[_length + 2] = Roact.createElement(NavbarTab, {
		page = DashboardPage.Apps,
	})
	_children[_length + 3] = Roact.createElement(NavbarTab, {
		page = DashboardPage.Scripts,
	})
	_children[_length + 4] = Roact.createElement(NavbarTab, {
		page = DashboardPage.Options,
	})
	_children[_length + 5] = Roact.createElement(NavbarTab, {
		page = DashboardPage.Misc,
	})
	local _child_1 = theme.acrylic and Roact.createElement(Acrylic)
	if _child_1 then
		if _child_1.elements ~= nil or _child_1.props ~= nil and _child_1.component ~= nil then
			_children[_length + 6] = _child_1
		else
			for _k, _v in ipairs(_child_1) do
				_children[_length + 5 + _k] = _v
			end
		end
	end
	return Roact.createFragment({
		Navbar = Roact.createElement("Frame", _attributes, _children),
	})
end
local default = hooked(Navbar)
function Underglow(props)
	return Roact.createFragment({
		Underglow = Roact.createElement("ImageLabel", {
			Image = "rbxassetid://8992238178",
			ImageColor3 = props.sequenceColor,
			ImageTransparency = props.transparency,
			Size = px(148, 104),
			Position = props.position:map(function(a)
				return UDim2.new(a, 0, 0, -18)
			end),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
		}),
	})
end
return {
	default = default,
}

        end)
    end)
    hMod("Navbar.story", "ModuleScript", "Havoc.views.Navbar.Navbar.story", "Havoc.views.Navbar", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local Provider = TS.import(script, TS.getModule(script, "@rbxts", "roact-rodux-hooked").out).Provider
local DashboardPage = TS.import(script, script.Parent.Parent.Parent, "store", "models", "dashboard.model").DashboardPage
local configureStore = TS.import(script, script.Parent.Parent.Parent, "store", "store").configureStore
local Navbar = TS.import(script, script.Parent, "Navbar").default
return function(target)
	local handle = Roact.mount(Roact.createElement(Provider, {
		store = configureStore({
			dashboard = {
				isOpen = true,
				page = DashboardPage.Home,
				hint = nil,
				apps = {},
			},
		}),
	}, {
		Roact.createElement(Navbar),
	}), target, "Navbar")
	return function()
		return Roact.unmount(handle)
	end
end

        end)
    end)
    hMod("NavbarTab", "ModuleScript", "Havoc.views.Navbar.NavbarTab", "Havoc.views.Navbar", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local hooked = _roact_hooked.hooked
local useState = _roact_hooked.useState
local useAppDispatch = TS.import(script, script.Parent.Parent.Parent, "hooks", "common", "rodux-hooks").useAppDispatch
local useSpring = TS.import(script, script.Parent.Parent.Parent, "hooks", "common", "use-spring").useSpring
local useIsPageOpen = TS.import(script, script.Parent.Parent.Parent, "hooks", "use-current-page").useIsPageOpen
local useTheme = TS.import(script, script.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local setDashboardPage = TS.import(script, script.Parent.Parent.Parent, "store", "actions", "dashboard.action").setDashboardPage
local _dashboard_model = TS.import(script, script.Parent.Parent.Parent, "store", "models", "dashboard.model")
local PAGE_TO_ICON = _dashboard_model.PAGE_TO_ICON
local PAGE_TO_INDEX = _dashboard_model.PAGE_TO_INDEX
local _udim2 = TS.import(script, script.Parent.Parent.Parent, "utils", "udim2")
local px = _udim2.px
local scale = _udim2.scale
local TAB_SIZE = px(100, 56)
local function NavbarTab(_param)
	local page = _param.page
	local theme = useTheme("navbar")
	local isActive = useIsPageOpen(page)
	local dispatch = useAppDispatch()
	local _binding = useState(false)
	local isHovered = _binding[1]
	local setHovered = _binding[2]
	return Roact.createFragment({
		[page] = Roact.createElement("TextButton", {
			Text = "",
			AutoButtonColor = false,
			Active = not isActive,
			Size = TAB_SIZE,
			Position = scale(PAGE_TO_INDEX[page] / 4, 0),
			BackgroundTransparency = 1,
			[Roact.Event.Activated] = function()
				return dispatch(setDashboardPage(page))
			end,
			[Roact.Event.MouseEnter] = function()
				return setHovered(true)
			end,
			[Roact.Event.MouseLeave] = function()
				return setHovered(false)
			end,
		}, {
			Roact.createElement("ImageLabel", {
				Image = PAGE_TO_ICON[page],
				ImageColor3 = theme.foreground,
				ImageTransparency = useSpring(isActive and 0 or (isHovered and 0.3 or 0.6), {
					frequency = 4,
					dampingRatio = 1,
				}),
				Size = px(24, 24),
				Position = scale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
			}),
		}),
	})
end
local default = hooked(NavbarTab)
return {
	default = default,
}

        end)
    end)
    hMod("Pages", "ModuleScript", "Havoc.views.Pages", "Havoc.views", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Pages").default
return exports

        end)
    end)
    hMod("Apps", "ModuleScript", "Havoc.views.Pages.Apps", "Havoc.views.Pages", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Apps").default
return exports

        end)
    end)
    hMod("Apps", "ModuleScript", "Havoc.views.Pages.Apps.Apps", "Havoc.views.Pages.Apps", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local pure = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).pure
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent, "components", "Canvas").default
local useScale = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-scale").useScale
local scale = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "udim2").scale
local Players = TS.import(script, script.Parent, "Players").default
local function Apps()
	local scaleFactor = useScale()
	return Roact.createElement(Canvas, {
		position = scale(0, 1),
		anchor = Vector2.new(0, 1),
	}, {
		Roact.createElement("UIScale", {
			Scale = scaleFactor,
		}),
		Roact.createElement(Players),
	})
end
local default = pure(Apps)
return {
	default = default,
}

        end)
    end)
    hMod("Players", "ModuleScript", "Havoc.views.Pages.Apps.Players", "Havoc.views.Pages.Apps", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Players").default
return exports

        end)
    end)
    hMod("Actions", "ModuleScript", "Havoc.views.Pages.Apps.Players.Actions", "Havoc.views.Pages.Apps.Players", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).hooked
local ActionButton = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "ActionButton").default
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Canvas").default
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local px = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2").px
local function Actions()
	local theme = useTheme("apps").players
	return Roact.createElement(Canvas, {
		anchor = Vector2.new(0.5, 0),
		size = px(278, 49),
		position = UDim2.new(0.5, 0, 0, 304),
	}, {
		Roact.createElement(ActionButton, {
			action = "teleport",
			hint = "<font face='GothamBlack'>Teleport to</font> this player, tap again to cancel",
			theme = theme,
			image = "rbxassetid://8992042585",
			position = px(0, 0),
			canDeactivate = true,
		}),
		Roact.createElement(ActionButton, {
			action = "hide",
			hint = "<font face='GothamBlack'>Hide</font> this player's character; persists between players",
			theme = theme,
			image = "rbxassetid://8992042653",
			position = px(72, 0),
			canDeactivate = true,
		}),
		Roact.createElement(ActionButton, {
			action = "kill",
			hint = "<font face='GothamBlack'>Kill</font> this player with a tool handle",
			theme = theme,
			image = "rbxassetid://8992042471",
			position = px(145, 0),
		}),
		Roact.createElement(ActionButton, {
			action = "spectate",
			hint = "<font face='GothamBlack'>Spectate</font> this player",
			theme = theme,
			image = "rbxassetid://8992042721",
			position = px(217, 0),
			canDeactivate = true,
		}),
	})
end
local default = hooked(Actions)
return {
	default = default,
}

        end)
    end)
    hMod("Avatar", "ModuleScript", "Havoc.views.Pages.Apps.Players.Avatar", "Havoc.views.Pages.Apps.Players", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).hooked
local Players = TS.import(script, TS.getModule(script, "@rbxts", "services")).Players
local Border = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Border").default
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Canvas").default
local useAppSelector = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "rodux-hooks").useAppSelector
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local px = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2").px
local function Avatar()
	local theme = useTheme("apps").players
	local playerSelected = useAppSelector(function(state)
		local _result
		if state.dashboard.apps.playerSelected ~= nil then
			_result = (Players:FindFirstChild(state.dashboard.apps.playerSelected))
		else
			_result = nil
		end
		return _result
	end)
	return Roact.createElement(Canvas, {
		anchor = Vector2.new(0.5, 0),
		size = px(186, 186),
		position = UDim2.new(0.5, 0, 0, 24),
	}, {
		Roact.createElement("ImageLabel", {
			Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. (tostring(playerSelected and playerSelected.UserId or Players.LocalPlayer.UserId) .. "&width=150&height=150&format=png"),
			Size = px(150, 150),
			Position = px(18, 18),
			BackgroundColor3 = theme.avatar.background,
			BackgroundTransparency = theme.avatar.transparency,
		}, {
			Roact.createElement("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
		}),
		Roact.createElement(Border, {
			size = 4,
			radius = "circular",
		}, {
			Roact.createElement("UIGradient", {
				Color = theme.avatar.gradient.color,
				Transparency = theme.avatar.gradient.transparency,
				Rotation = theme.avatar.gradient.rotation,
			}),
		}),
	})
end
local default = hooked(Avatar)
return {
	default = default,
}

        end)
    end)
    hMod("Players", "ModuleScript", "Havoc.views.Pages.Apps.Players.Players", "Havoc.views.Pages.Apps.Players", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).hooked
local Card = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Card").default
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "models", "dashboard.model").DashboardPage
local px = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2").px
local Actions = TS.import(script, script.Parent, "Actions").default
local Avatar = TS.import(script, script.Parent, "Avatar").default
local Selection = TS.import(script, script.Parent, "Selection").default
local Username = TS.import(script, script.Parent, "Username").default
local function Players()
	local theme = useTheme("apps").players
	return Roact.createElement(Card, {
		index = 1,
		page = DashboardPage.Apps,
		theme = theme,
		size = px(326, 648),
		position = UDim2.new(0, 0, 1, 0),
	}, {
		Roact.createElement(Avatar),
		Roact.createElement(Username),
		Roact.createElement(Actions),
		Roact.createElement(Selection),
	})
end
local default = hooked(Players)
return {
	default = default,
}

        end)
    end)
    hMod("Selection", "ModuleScript", "Havoc.views.Pages.Apps.Players.Selection", "Havoc.views.Pages.Apps.Players", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local hooked = _roact_hooked.hooked
local useEffect = _roact_hooked.useEffect
local useMemo = _roact_hooked.useMemo
local useState = _roact_hooked.useState
local _services = TS.import(script, TS.getModule(script, "@rbxts", "services"))
local Players = _services.Players
local TextService = _services.TextService
local Border = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Border").default
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Canvas").default
local Fill = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Fill").default
local _Glow = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Glow")
local Glow = _Glow.default
local GlowRadius = _Glow.GlowRadius
local IS_DEV = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "constants").IS_DEV
local useLinear = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "flipper-hooks").useLinear
local _rodux_hooks = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "rodux-hooks")
local useAppDispatch = _rodux_hooks.useAppDispatch
local useAppSelector = _rodux_hooks.useAppSelector
local useDelayedUpdate = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "use-delayed-update").useDelayedUpdate
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "use-spring").useSpring
local useIsPageOpen = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-current-page").useIsPageOpen
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local _dashboard_action = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "actions", "dashboard.action")
local playerDeselected = _dashboard_action.playerDeselected
local playerSelected = _dashboard_action.playerSelected
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "models", "dashboard.model").DashboardPage
local arrayToMap = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "array-util").arrayToMap
local lerp = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "number-util").lerp
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2")
local px = _udim2.px
local scale = _udim2.scale
local PADDING = 20
local ENTRY_HEIGHT = 60
local ENTRY_WIDTH = 326 - 24 * 2
local ENTRY_TEXT_PADDING = 60
local textFadeSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.05, 0), NumberSequenceKeypoint.new(0.9, 0), NumberSequenceKeypoint.new(0.95, 1), NumberSequenceKeypoint.new(1, 1) })
local function usePlayers()
	local _binding = useState(Players:GetPlayers())
	local players = _binding[1]
	local setPlayers = _binding[2]
	useEffect(function()
		local addedHandle = Players.PlayerAdded:Connect(function()
			setPlayers(Players:GetPlayers())
		end)
		local removingHandle = Players.PlayerRemoving:Connect(function()
			setPlayers(Players:GetPlayers())
		end)
		return function()
			addedHandle:Disconnect()
			removingHandle:Disconnect()
		end
	end, {})
	return players
end
local PlayerEntry
local function Selection()
	local dispatch = useAppDispatch()
	local players = usePlayers()
	local playerSelected = useAppSelector(function(state)
		return state.dashboard.apps.playerSelected
	end)
	local sortedPlayers = useMemo(function()
		local _arg0 = function(p)
			return p.Name == playerSelected
		end
		-- ▼ ReadonlyArray.find ▼
		local _result = nil
		for _i, _v in ipairs(players) do
			if _arg0(_v, _i - 1, players) == true then
				_result = _v
				break
			end
		end
		-- ▲ ReadonlyArray.find ▲
		local selected = _result
		local _arg0_1 = function(p)
			return p.Name ~= playerSelected and (p ~= Players.LocalPlayer or IS_DEV)
		end
		-- ▼ ReadonlyArray.filter ▼
		local _newValue = {}
		local _length = 0
		for _k, _v in ipairs(players) do
			if _arg0_1(_v, _k - 1, players) == true then
				_length += 1
				_newValue[_length] = _v
			end
		end
		-- ▲ ReadonlyArray.filter ▲
		local _arg0_2 = function(a, b)
			return string.lower(a.Name) < string.lower(b.Name)
		end
		-- ▼ Array.sort ▼
		table.sort(_newValue, _arg0_2)
		-- ▲ Array.sort ▲
		local sorted = _newValue
		local _result_1
		if selected then
			local _array = { selected }
			local _length_1 = #_array
			table.move(sorted, 1, #sorted, _length_1 + 1, _array)
			_result_1 = _array
		else
			_result_1 = sorted
		end
		return _result_1
	end, { players, playerSelected })
	useEffect(function()
		local _condition = playerSelected ~= nil
		if _condition then
			local _arg0 = function(player)
				return player.Name == playerSelected
			end
			-- ▼ ReadonlyArray.find ▼
			local _result = nil
			for _i, _v in ipairs(sortedPlayers) do
				if _arg0(_v, _i - 1, sortedPlayers) == true then
					_result = _v
					break
				end
			end
			-- ▲ ReadonlyArray.find ▲
			_condition = not _result
		end
		if _condition then
			dispatch(playerDeselected())
		end
	end, { players, playerSelected })
	local _attributes = {
		size = px(326, 280),
		position = px(0, 368),
		padding = {
			left = 24,
			right = 24,
			top = 8,
		},
		clipsDescendants = true,
	}
	local _children = {}
	local _length = #_children
	local _attributes_1 = {
		Size = scale(1, 1),
		CanvasSize = px(0, #sortedPlayers * (ENTRY_HEIGHT + PADDING) + PADDING),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarImageTransparency = 1,
		ScrollBarThickness = 0,
		ClipsDescendants = false,
	}
	local _children_1 = {}
	local _length_1 = #_children_1
	for _k, _v in pairs(arrayToMap(sortedPlayers, function(player, index)
		return { player.Name, Roact.createElement(PlayerEntry, {
			name = player.Name,
			displayName = player.DisplayName,
			userId = player.UserId,
			index = index,
		}) }
	end)) do
		_children_1[_k] = _v
	end
	_children[_length + 1] = Roact.createElement("ScrollingFrame", _attributes_1, _children_1)
	return Roact.createElement(Canvas, _attributes, _children)
end
local default = hooked(Selection)
local function PlayerEntryComponent(_param)
	local name = _param.name
	local userId = _param.userId
	local displayName = _param.displayName
	local index = _param.index
	local dispatch = useAppDispatch()
	local theme = useTheme("apps").players.playerButton
	local isOpen = useIsPageOpen(DashboardPage.Apps)
	local isVisible = useDelayedUpdate(isOpen, isOpen and 170 + index * 40 or 150)
	local isSelected = useAppSelector(function(state)
		return state.dashboard.apps.playerSelected == name
	end)
	local _binding = useState(false)
	local hovered = _binding[1]
	local setHovered = _binding[2]
	local text = "  " .. (displayName .. (" (@" .. (name .. ")")))
	local textSize = useMemo(function()
		return TextService:GetTextSize(text, 14, Enum.Font.GothamBold, Vector2.new(1000, ENTRY_HEIGHT))
	end, { text })
	local textScrollOffset = useLinear(hovered and ENTRY_WIDTH - ENTRY_TEXT_PADDING - 20 - textSize.X or 0, {
		velocity = hovered and 40 or 150,
	}):map(function(x)
		return UDim.new(0, math.min(x, 0))
	end)
	local _result
	if isSelected then
		_result = theme.accent
	else
		local _result_1
		if hovered then
			local _condition = theme.backgroundHovered
			if _condition == nil then
				_condition = theme.background:Lerp(theme.accent, 0.1)
			end
			_result_1 = _condition
		else
			_result_1 = theme.background
		end
		_result = _result_1
	end
	local background = useSpring(_result, {})
	local _result_1
	if isSelected then
		_result_1 = theme.accent
	else
		local _result_2
		if hovered then
			local _condition = theme.backgroundHovered
			if _condition == nil then
				_condition = theme.dropshadow:Lerp(theme.accent, 0.5)
			end
			_result_2 = _condition
		else
			_result_2 = theme.dropshadow
		end
		_result_1 = _result_2
	end
	local dropshadow = useSpring(_result_1, {})
	local foreground = useSpring(isSelected and theme.foregroundAccent and theme.foregroundAccent or theme.foreground, {})
	local _attributes = {
		size = px(ENTRY_WIDTH, ENTRY_HEIGHT),
		position = useSpring(isVisible and px(0, (PADDING + ENTRY_HEIGHT) * index) or px(-ENTRY_WIDTH - 24, (PADDING + ENTRY_HEIGHT) * index), {}),
		zIndex = index,
	}
	local _children = {
		Roact.createElement(Glow, {
			radius = GlowRadius.Size70,
			color = dropshadow,
			size = UDim2.new(1, 36, 1, 36),
			position = px(-18, 5 - 18),
			transparency = useSpring(isSelected and theme.glowTransparency or (hovered and lerp(theme.dropshadowTransparency, theme.glowTransparency, 0.5) or theme.dropshadowTransparency), {}),
		}),
		Roact.createElement(Fill, {
			color = background,
			transparency = useSpring(theme.backgroundTransparency, {}),
			radius = 8,
		}),
		Roact.createElement("TextLabel", {
			Text = text,
			Font = "GothamBold",
			TextSize = 14,
			TextColor3 = foreground,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextTransparency = useSpring(isSelected and 0 or (hovered and theme.foregroundTransparency / 2 or theme.foregroundTransparency), {}),
			BackgroundTransparency = 1,
			Position = px(ENTRY_TEXT_PADDING, 1),
			Size = UDim2.new(1, -ENTRY_TEXT_PADDING, 1, -1),
			ClipsDescendants = true,
		}, {
			Roact.createElement("UIPadding", {
				PaddingLeft = textScrollOffset,
			}),
			Roact.createElement("UIGradient", {
				Transparency = textFadeSequence,
			}),
		}),
		Roact.createElement("ImageLabel", {
			Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. (tostring(userId) .. "&width=60&height=60&format=png"),
			Size = UDim2.new(0, ENTRY_HEIGHT, 0, ENTRY_HEIGHT),
			BackgroundTransparency = 1,
		}, {
			Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		}),
	}
	local _length = #_children
	local _child = theme.outlined and Roact.createElement(Border, {
		color = foreground,
		transparency = 0.8,
		radius = 8,
	})
	if _child then
		if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then
			_children[_length + 1] = _child
		else
			for _k, _v in ipairs(_child) do
				_children[_length + _k] = _v
			end
		end
	end
	_length = #_children
	_children[_length + 1] = Roact.createElement("TextButton", {
		[Roact.Event.Activated] = function()
			local player = Players:FindFirstChild(name)
			local _condition = not isSelected
			if _condition then
				local _result_2 = player
				if _result_2 ~= nil then
					_result_2 = _result_2:IsA("Player")
				end
				_condition = _result_2
			end
			if _condition then
				dispatch(playerSelected(player))
			else
				dispatch(playerDeselected())
			end
		end,
		[Roact.Event.MouseEnter] = function()
			return setHovered(true)
		end,
		[Roact.Event.MouseLeave] = function()
			return setHovered(false)
		end,
		Text = "",
		Transparency = 1,
		Size = scale(1, 1),
	})
	return Roact.createElement(Canvas, _attributes, _children)
end
PlayerEntry = hooked(PlayerEntryComponent)
return {
	default = default,
}

        end)
    end)
    hMod("Username", "ModuleScript", "Havoc.views.Pages.Apps.Players.Username", "Havoc.views.Pages.Apps.Players", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).hooked
local Players = TS.import(script, TS.getModule(script, "@rbxts", "services")).Players
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Canvas").default
local useAppSelector = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "rodux-hooks").useAppSelector
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2")
local px = _udim2.px
local scale = _udim2.scale
local function Username()
	local theme = useTheme("apps").players
	local playerSelected = useAppSelector(function(state)
		local _result
		if state.dashboard.apps.playerSelected ~= nil then
			_result = (Players:FindFirstChild(state.dashboard.apps.playerSelected))
		else
			_result = nil
		end
		return _result
	end)
	return Roact.createElement(Canvas, {
		anchor = Vector2.new(0.5, 0),
		size = px(278, 49),
		position = UDim2.new(0.5, 0, 0, 231),
	}, {
		Roact.createElement("TextLabel", {
			Font = "GothamBlack",
			Text = playerSelected and playerSelected.DisplayName or "N/A",
			TextSize = 20,
			TextColor3 = theme.foreground,
			TextXAlignment = "Center",
			TextYAlignment = "Top",
			Size = scale(1, 1),
			BackgroundTransparency = 1,
		}),
		Roact.createElement("TextLabel", {
			Font = "GothamBold",
			Text = playerSelected and playerSelected.Name or "Select a player",
			TextSize = 16,
			TextColor3 = theme.foreground,
			TextXAlignment = "Center",
			TextYAlignment = "Bottom",
			TextTransparency = 0.7,
			Size = scale(1, 1),
			BackgroundTransparency = 1,
		}),
	})
end
local default = hooked(Username)
return {
	default = default,
}

        end)
    end)
    hMod("Home", "ModuleScript", "Havoc.views.Pages.Home", "Havoc.views.Pages", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Home").default
return exports

        end)
    end)
    hMod("FriendActivity", "ModuleScript", "Havoc.views.Pages.Home.FriendActivity", "Havoc.views.Pages.Home", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "FriendActivity").default
return exports

        end)
    end)
    hMod("FriendActivity", "ModuleScript", "Havoc.views.Pages.Home.FriendActivity.FriendActivity", "Havoc.views.Pages.Home.FriendActivity", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local hooked = _roact_hooked.hooked
local useEffect = _roact_hooked.useEffect
local useReducer = _roact_hooked.useReducer
local useState = _roact_hooked.useState
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Canvas").default
local Card = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Card").default
local useInterval = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "use-interval").useInterval
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "use-spring").useSpring
local useFriendActivity = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-friends").useFriendActivity
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "models", "dashboard.model").DashboardPage
local arrayToMap = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "array-util").arrayToMap
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2")
local px = _udim2.px
local scale = _udim2.scale
local _GameItem = TS.import(script, script.Parent, "GameItem")
local GameItem = _GameItem.default
local GAME_PADDING = _GameItem.GAME_PADDING
local function FriendActivity()
	local theme = useTheme("home").friendActivity
	local _binding = useReducer(function(state)
		return state + 1
	end, 0)
	local update = _binding[1]
	local forceUpdate = _binding[2]
	local _binding_1 = useFriendActivity({ update })
	local currentGames = _binding_1[1]
	local status = _binding_1[3]
	local _binding_2 = useState(currentGames)
	local games = _binding_2[1]
	local setGames = _binding_2[2]
	useEffect(function()
		if #currentGames > 0 then
			local _arg0 = function(a, b)
				return #a.friends > #b.friends
			end
			-- ▼ Array.sort ▼
			table.sort(currentGames, _arg0)
			-- ▲ Array.sort ▲
			setGames(currentGames)
		end
	end, { currentGames })
	useInterval(function()
		return forceUpdate()
	end, #currentGames == 0 and status ~= "pending" and 5000 or 30000)
	local _attributes = {
		index = 3,
		page = DashboardPage.Home,
		theme = theme,
		size = px(326, 416),
		position = UDim2.new(0, 374, 1, 0),
	}
	local _children = {
		Roact.createElement("TextLabel", {
			Text = "Friend Activity",
			Font = "GothamBlack",
			TextSize = 20,
			TextColor3 = theme.foreground,
			TextXAlignment = "Left",
			TextYAlignment = "Top",
			Position = px(24, 24),
			BackgroundTransparency = 1,
		}),
	}
	local _length = #_children
	local _attributes_1 = {
		anchor = Vector2.new(0, 1),
		size = useSpring(#games > 0 and UDim2.new(1, 0, 0, 344) or UDim2.new(1, 0, 0, 0), {}),
		position = scale(0, 1),
	}
	local _children_1 = {}
	local _length_1 = #_children_1
	local _attributes_2 = {
		Size = scale(1, 1),
		ScrollBarThickness = 0,
		ScrollBarImageTransparency = 1,
		ScrollingDirection = "Y",
		CanvasSize = px(0, #games * (GAME_PADDING + 156) + GAME_PADDING),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}
	local _children_2 = {}
	local _length_2 = #_children_2
	for _k, _v in pairs(arrayToMap(games, function(gameActivity, index)
		return { tostring(gameActivity.placeId), Roact.createElement(GameItem, {
			gameActivity = gameActivity,
			index = index,
		}) }
	end)) do
		_children_2[_k] = _v
	end
	_children_1[_length_1 + 1] = Roact.createElement("ScrollingFrame", _attributes_2, _children_2)
	_children[_length + 1] = Roact.createElement(Canvas, _attributes_1, _children_1)
	return Roact.createElement(Card, _attributes, _children)
end
local default = hooked(FriendActivity)
return {
	default = default,
}

        end)
    end)
    hMod("FriendItem", "ModuleScript", "Havoc.views.Pages.Home.FriendActivity.FriendItem", "Havoc.views.Pages.Home.FriendActivity", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local hooked = _roact_hooked.hooked
local useState = _roact_hooked.useState
local _services = TS.import(script, TS.getModule(script, "@rbxts", "services"))
local Players = _services.Players
local TeleportService = _services.TeleportService
local Border = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Border").default
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Canvas").default
local Fill = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Fill").default
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "use-spring").useSpring
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2")
local px = _udim2.px
local scale = _udim2.scale
local FRIEND_SPRING_OPTIONS = {
	frequency = 6,
}
local function FriendItem(_param)
	local friend = _param.friend
	local index = _param.index
	local theme = useTheme("home").friendActivity.friendButton
	local _binding = useState(false)
	local isHovered = _binding[1]
	local setHovered = _binding[2]
	local avatar = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. (tostring(friend.VisitorId) .. "&width=48&height=48&format=png")
	local _attributes = {
		size = useSpring(isHovered and px(96, 48) or px(48, 48), FRIEND_SPRING_OPTIONS),
	}
	local _children = {
		Roact.createElement("ImageLabel", {
			Image = "rbxassetid://8992244272",
			ImageColor3 = useSpring(isHovered and theme.accent or theme.dropshadow, FRIEND_SPRING_OPTIONS),
			ImageTransparency = useSpring(isHovered and theme.glowTransparency or theme.dropshadowTransparency, FRIEND_SPRING_OPTIONS),
			Size = useSpring(isHovered and px(88 + 36, 74) or px(76, 74), FRIEND_SPRING_OPTIONS),
			Position = px(-14, -10),
			ScaleType = "Slice",
			SliceCenter = Rect.new(Vector2.new(42, 42), Vector2.new(42, 42)),
			BackgroundTransparency = 1,
		}),
		Roact.createElement(Fill, {
			radius = 24,
			color = useSpring(isHovered and theme.accent or theme.background, FRIEND_SPRING_OPTIONS),
			transparency = theme.backgroundTransparency,
		}),
	}
	local _length = #_children
	local _child = theme.outlined and (Roact.createFragment({
		border = Roact.createElement(Border, {
			radius = 23,
			color = isHovered and theme.foregroundAccent and theme.foregroundAccent or theme.foreground,
			transparency = 0.7,
		}),
	}))
	if _child then
		if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then
			_children[_length + 1] = _child
		else
			for _k, _v in ipairs(_child) do
				_children[_length + _k] = _v
			end
		end
	end
	_length = #_children
	_children[_length + 1] = Roact.createElement("ImageLabel", {
		Image = avatar,
		ScaleType = "Crop",
		Size = px(48, 48),
		LayoutOrder = index,
		BackgroundTransparency = 1,
	}, {
		Roact.createElement("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
	})
	_children[_length + 2] = Roact.createElement(Canvas, {
		clipsDescendants = true,
	}, {
		Roact.createElement("ImageLabel", {
			Image = "rbxassetid://8992244380",
			ImageColor3 = isHovered and theme.foregroundAccent and theme.foregroundAccent or theme.foreground,
			ImageTransparency = theme.foregroundTransparency,
			Size = px(36, 36),
			Position = px(48, 6),
			BackgroundTransparency = 1,
		}),
	})
	_children[_length + 3] = Roact.createElement("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = scale(1, 1),
		BackgroundTransparency = 1,
		[Roact.Event.Activated] = function()
			pcall(function()
				TeleportService:TeleportToPlaceInstance(friend.PlaceId, friend.GameId, Players.LocalPlayer)
			end)
		end,
		[Roact.Event.MouseEnter] = function()
			return setHovered(true)
		end,
		[Roact.Event.MouseLeave] = function()
			return setHovered(false)
		end,
	})
	return Roact.createElement(Canvas, _attributes, _children)
end
local default = hooked(FriendItem)
return {
	default = default,
}

        end)
    end)
    hMod("GameItem", "ModuleScript", "Havoc.views.Pages.Home.FriendActivity.GameItem", "Havoc.views.Pages.Home.FriendActivity", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local pure = _roact_hooked.pure
local useMemo = _roact_hooked.useMemo
local Border = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Border").default
local useDelayedUpdate = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "use-delayed-update").useDelayedUpdate
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "use-spring").useSpring
local useIsPageOpen = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-current-page").useIsPageOpen
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "models", "dashboard.model").DashboardPage
local arrayToMap = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "array-util").arrayToMap
local px = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2").px
local FriendItem = TS.import(script, script.Parent, "FriendItem").default
local GAME_PADDING = 48
local function GameItem(_param)
	local gameActivity = _param.gameActivity
	local index = _param.index
	local theme = useTheme("home").friendActivity
	local isOpen = useIsPageOpen(DashboardPage.Home)
	local isVisible = useDelayedUpdate(isOpen, isOpen and 330 + index * 100 or 300)
	local canvasLength = useMemo(function()
		return #gameActivity.friends * (48 + 10) + 96
	end, { #gameActivity.friends })
	local _attributes = {
		Image = gameActivity.thumbnail,
		ScaleType = "Crop",
		Size = px(278, 156),
		Position = useSpring(isVisible and px(24, index * (GAME_PADDING + 156)) or px(-278, index * (GAME_PADDING + 156)), {}),
		BackgroundTransparency = 1,
	}
	local _children = {
		Roact.createElement(Border, {
			color = theme.foreground,
			radius = 8,
			transparency = 0.8,
		}),
		Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
	}
	local _length = #_children
	local _attributes_1 = {
		Size = UDim2.new(1, 0, 0, 64),
		Position = UDim2.new(0, 0, 1, -24),
		CanvasSize = px(canvasLength, 0),
		ScrollingDirection = "X",
		ScrollBarThickness = 0,
		ScrollBarImageTransparency = 1,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = false,
	}
	local _children_1 = {
		Roact.createElement("UIListLayout", {
			SortOrder = "LayoutOrder",
			FillDirection = "Horizontal",
			HorizontalAlignment = "Left",
			VerticalAlignment = "Top",
			Padding = UDim.new(0, 10),
		}),
		Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
		}),
	}
	local _length_1 = #_children_1
	for _k, _v in pairs(arrayToMap(gameActivity.friends, function(friend, index)
		return { tostring(friend.VisitorId), Roact.createElement(FriendItem, {
			friend = friend,
			index = index,
		}) }
	end)) do
		_children_1[_k] = _v
	end
	_children[_length + 1] = Roact.createElement("ScrollingFrame", _attributes_1, _children_1)
	return Roact.createElement("ImageLabel", _attributes, _children)
end
local default = pure(GameItem)
return {
	GAME_PADDING = GAME_PADDING,
	default = default,
}

        end)
    end)
    hMod("Home", "ModuleScript", "Havoc.views.Pages.Home.Home", "Havoc.views.Pages.Home", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local pure = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).pure
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent, "components", "Canvas").default
local useScale = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-scale").useScale
local scale = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "udim2").scale
local FriendActivity = TS.import(script, script.Parent, "FriendActivity").default
local Profile = TS.import(script, script.Parent, "Profile").default
local Server = TS.import(script, script.Parent, "Server").default
local Title = TS.import(script, script.Parent, "Title").default
local function Home()
	local scaleFactor = useScale()
	return Roact.createElement(Canvas, {
		position = scale(0, 1),
		anchor = Vector2.new(0, 1),
	}, {
		Roact.createElement("UIScale", {
			Scale = scaleFactor,
		}),
		Roact.createElement(Title),
		Roact.createElement(Server),
		Roact.createElement(FriendActivity),
		Roact.createElement(Profile),
	})
end
local default = pure(Home)
return {
	default = default,
}

        end)
    end)
    hMod("Profile", "ModuleScript", "Havoc.views.Pages.Home.Profile", "Havoc.views.Pages.Home", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Profile").default
return exports

        end)
    end)
    hMod("Actions", "ModuleScript", "Havoc.views.Pages.Home.Profile.Actions", "Havoc.views.Pages.Home.Profile", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).hooked
local ActionButton = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "ActionButton").default
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Canvas").default
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local px = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2").px
local function Actions()
	local theme = useTheme("home").profile
	return Roact.createElement(Canvas, {
		anchor = Vector2.new(0.5, 0),
		size = px(278, 49),
		position = UDim2.new(0.5, 0, 0, 575),
	}, {
		Roact.createElement(ActionButton, {
			action = "refresh",
			hint = "<font face='GothamBlack'>Refresh</font> your character at this location",
			theme = theme,
			image = "rbxassetid://8992253511",
			position = px(0, 0),
		}),
		Roact.createElement(ActionButton, {
			action = "ghost",
			hint = "<font face='GothamBlack'>Spawn a ghost</font> and go to it when disabled",
			theme = theme,
			image = "rbxassetid://8992253792",
			position = px(72, 0),
			canDeactivate = true,
		}),
		Roact.createElement(ActionButton, {
			action = "godmode",
			hint = "<font face='GothamBlack'>Set godmode</font>, may break respawn",
			theme = theme,
			image = "rbxassetid://8992253678",
			position = px(145, 0),
		}),
		Roact.createElement(ActionButton, {
			action = "freecam",
			hint = "<font face='GothamBlack'>Set freecam</font>, use Q & E to move vertically",
			theme = theme,
			image = "rbxassetid://8992253933",
			position = px(217, 0),
			canDeactivate = true,
		}),
	})
end
local default = hooked(Actions)
return {
	default = default,
}

        end)
    end)
    hMod("Avatar", "ModuleScript", "Havoc.views.Pages.Home.Profile.Avatar", "Havoc.views.Pages.Home.Profile", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).hooked
local Players = TS.import(script, TS.getModule(script, "@rbxts", "services")).Players
local Border = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Border").default
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Canvas").default
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local px = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2").px
local AVATAR = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. (tostring(Players.LocalPlayer.UserId) .. "&width=150&height=150&format=png")
local function Avatar()
	local theme = useTheme("home").profile
	return Roact.createElement(Canvas, {
		anchor = Vector2.new(0.5, 0),
		size = px(186, 186),
		position = UDim2.new(0.5, 0, 0, 24),
	}, {
		Roact.createElement("ImageLabel", {
			Image = AVATAR,
			Size = px(150, 150),
			Position = px(18, 18),
			BackgroundColor3 = theme.avatar.background,
			BackgroundTransparency = theme.avatar.transparency,
		}, {
			Roact.createElement("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
		}),
		Roact.createElement(Border, {
			size = 4,
			radius = "circular",
		}, {
			Roact.createElement("UIGradient", {
				Color = theme.avatar.gradient.color,
				Transparency = theme.avatar.gradient.transparency,
				Rotation = theme.avatar.gradient.rotation,
			}),
		}),
	})
end
local default = hooked(Avatar)
return {
	default = default,
}

        end)
    end)
    hMod("Info", "ModuleScript", "Havoc.views.Pages.Home.Profile.Info", "Havoc.views.Pages.Home.Profile", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).hooked
local Players = TS.import(script, TS.getModule(script, "@rbxts", "services")).Players
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Canvas").default
local useDelayedUpdate = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "use-delayed-update").useDelayedUpdate
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "use-spring").useSpring
local useIsPageOpen = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-current-page").useIsPageOpen
local useFriends = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-friends").useFriends
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "models", "dashboard.model").DashboardPage
local px = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2").px
local function Info()
	local theme = useTheme("home").profile
	local isOpen = useIsPageOpen(DashboardPage.Home)
	local _binding = useFriends()
	local friends = _binding[1]
	if friends == nil then
		friends = {}
	end
	local status = _binding[3]
	local friendsOnline = #friends
	local _arg0 = function(friend)
		return friend.PlaceId ~= nil and friend.PlaceId == game.PlaceId
	end
	-- ▼ ReadonlyArray.filter ▼
	local _newValue = {}
	local _length = 0
	for _k, _v in ipairs(friends) do
		if _arg0(_v, _k - 1, friends) == true then
			_length += 1
			_newValue[_length] = _v
		end
	end
	-- ▲ ReadonlyArray.filter ▲
	local friendsJoined = #_newValue
	local showJoinDate = useDelayedUpdate(isOpen, 400, function(open)
		return not open
	end)
	local showFriendsJoined = useDelayedUpdate(isOpen and status ~= "pending", 500, function(open)
		return not open
	end)
	local showFriendsOnline = useDelayedUpdate(isOpen and status ~= "pending", 600, function(open)
		return not open
	end)
	return Roact.createElement(Canvas, {
		anchor = Vector2.new(0.5, 0),
		size = px(278, 48),
		position = UDim2.new(0.5, 0, 0, 300),
	}, {
		Roact.createElement("Frame", {
			Size = px(0, 26),
			Position = px(90, 11),
			BackgroundTransparency = 1,
		}, {
			Roact.createElement("UIStroke", {
				Thickness = 0.5,
				Color = theme.foreground,
				Transparency = 0.7,
			}),
		}),
		Roact.createElement("Frame", {
			Size = px(0, 26),
			Position = px(187, 11),
			BackgroundTransparency = 1,
		}, {
			Roact.createElement("UIStroke", {
				Thickness = 0.5,
				Color = theme.foreground,
				Transparency = 0.7,
			}),
		}),
		Roact.createElement("TextLabel", {
			Font = "GothamBold",
			Text = "Joined\n" .. tostring((os.date("%m/%d/%Y", os.time() - Players.LocalPlayer.AccountAge * 24 * 60 * 60))),
			TextSize = 13,
			TextColor3 = theme.foreground,
			TextXAlignment = "Center",
			TextYAlignment = "Center",
			TextTransparency = useSpring(showJoinDate and 0.2 or 1, {}),
			Size = px(85, 48),
			Position = useSpring(showJoinDate and px(0, 0) or px(-20, 0), {}),
			BackgroundTransparency = 1,
		}),
		Roact.createElement("TextLabel", {
			Font = "GothamBold",
			Text = friendsJoined == 1 and "1 friend\njoined" or tostring(friendsJoined) .. " friends\njoined",
			TextSize = 13,
			TextColor3 = theme.foreground,
			TextXAlignment = "Center",
			TextYAlignment = "Center",
			TextTransparency = useSpring(showFriendsJoined and 0.2 or 1, {}),
			Size = px(85, 48),
			Position = useSpring(showFriendsJoined and px(97, 0) or px(97 - 20, 0), {}),
			BackgroundTransparency = 1,
		}),
		Roact.createElement("TextLabel", {
			Font = "GothamBold",
			Text = friendsOnline == 1 and "1 friend\nonline" or tostring(friendsOnline) .. " friends\nonline",
			TextSize = 13,
			TextColor3 = theme.foreground,
			TextXAlignment = "Center",
			TextYAlignment = "Center",
			TextTransparency = useSpring(showFriendsOnline and 0.2 or 1, {}),
			Size = px(85, 48),
			Position = useSpring(showFriendsOnline and px(193, 0) or px(193 - 20, 0), {}),
			BackgroundTransparency = 1,
		}),
	})
end
local default = hooked(Info)
return {
	default = default,
}

        end)
    end)
    hMod("Profile", "ModuleScript", "Havoc.views.Pages.Home.Profile.Profile", "Havoc.views.Pages.Home.Profile", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).hooked
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Canvas").default
local Card = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Card").default
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "models", "dashboard.model").DashboardPage
local px = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2").px
local Actions = TS.import(script, script.Parent, "Actions").default
local Avatar = TS.import(script, script.Parent, "Avatar").default
local Info = TS.import(script, script.Parent, "Info").default
local Sliders = TS.import(script, script.Parent, "Sliders").default
local Username = TS.import(script, script.Parent, "Username").default
local function Profile()
	local theme = useTheme("home").profile
	return Roact.createElement(Card, {
		index = 1,
		page = DashboardPage.Home,
		theme = theme,
		size = px(326, 648),
		position = UDim2.new(0, 0, 1, 0),
	}, {
		Roact.createElement(Canvas, {
			padding = {
				left = 24,
				right = 24,
			},
		}, {
			Roact.createElement(Avatar),
			Roact.createElement(Username),
			Roact.createElement(Info),
			Roact.createElement(Sliders),
			Roact.createElement(Actions),
		}),
	})
end
local default = hooked(Profile)
return {
	default = default,
}

        end)
    end)
    hMod("Sliders", "ModuleScript", "Havoc.views.Pages.Home.Profile.Sliders", "Havoc.views.Pages.Home.Profile", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local hooked = _roact_hooked.hooked
local useBinding = _roact_hooked.useBinding
local useState = _roact_hooked.useState
local BrightButton = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "BrightButton").default
local BrightSlider = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "BrightSlider").default
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Canvas").default
local _rodux_hooks = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "rodux-hooks")
local useAppDispatch = _rodux_hooks.useAppDispatch
local useAppSelector = _rodux_hooks.useAppSelector
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "use-spring").useSpring
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local _dashboard_action = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "actions", "dashboard.action")
local clearHint = _dashboard_action.clearHint
local setHint = _dashboard_action.setHint
local _jobs_action = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "actions", "jobs.action")
local setJobActive = _jobs_action.setJobActive
local setJobValue = _jobs_action.setJobValue
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2")
local px = _udim2.px
local scale = _udim2.scale
local SPRING_OPTIONS = {
	frequency = 5,
}
local Slider
local function Sliders()
	return Roact.createElement(Canvas, {
		size = px(278, 187),
		position = px(0, 368),
	}, {
		Roact.createElement(Slider, {
			display = "Flight",
			hint = "<font face='GothamBlack'>Configure flight</font> in studs per second",
			jobName = "flight",
			units = "studs/s",
			min = 10,
			max = 100,
			position = 0,
		}),
		Roact.createElement(Slider, {
			display = "Speed",
			hint = "<font face='GothamBlack'>Configure speed</font> in studs per second",
			jobName = "walkSpeed",
			units = "studs/s",
			min = 0,
			max = 100,
			position = 69,
		}),
		Roact.createElement(Slider, {
			display = "Jump",
			hint = "<font face='GothamBlack'>Configure height</font> in studs",
			jobName = "jumpHeight",
			units = "studs",
			min = 0,
			max = 500,
			position = 138,
		}),
	})
end
local default = Sliders
local function SliderComponent(props)
	local theme = useTheme("home").profile
	local dispatch = useAppDispatch()
	local job = useAppSelector(function(state)
		return state.jobs[props.jobName]
	end)
	local _binding = useBinding(job.value)
	local value = _binding[1]
	local setValue = _binding[2]
	local _binding_1 = useState(false)
	local hovered = _binding_1[1]
	local setHovered = _binding_1[2]
	local highlightColors = theme.highlight
	local _condition = highlightColors[props.jobName]
	if _condition == nil then
		_condition = theme.foreground
	end
	local accent = _condition
	local _result
	if job.active then
		_result = accent
	else
		local _result_1
		if hovered then
			local _condition_1 = theme.button.backgroundHovered
			if _condition_1 == nil then
				_condition_1 = theme.button.background:Lerp(accent, 0.1)
			end
			_result_1 = _condition_1
		else
			_result_1 = theme.button.background
		end
		_result = _result_1
	end
	local buttonBackground = useSpring(_result, {})
	local buttonForeground = useSpring(job.active and theme.button.foregroundAccent and theme.button.foregroundAccent or theme.foreground, {})
	return Roact.createElement(Canvas, {
		size = px(278, 49),
		position = px(0, props.position),
	}, {
		Roact.createElement(BrightSlider, {
			onValueChanged = setValue,
			onRelease = function()
				return dispatch(setJobValue(props.jobName, math.round(value:getValue())))
			end,
			min = props.min,
			max = props.max,
			initialValue = job.value,
			size = px(181, 49),
			position = px(0, 0),
			radius = 8,
			color = theme.slider.background,
			accentColor = accent,
			borderEnabled = theme.slider.outlined,
			borderColor = theme.slider.foreground,
			transparency = theme.slider.backgroundTransparency,
			indicatorTransparency = theme.slider.indicatorTransparency,
		}, {
			Roact.createElement("TextLabel", {
				Font = "GothamBold",
				Text = value:map(function(v)
					return tostring(math.round(v)) .. (" " .. props.units)
				end),
				TextSize = 15,
				TextColor3 = theme.slider.foreground,
				TextXAlignment = "Center",
				TextYAlignment = "Center",
				TextTransparency = theme.slider.foregroundTransparency,
				Size = scale(1, 1),
				BackgroundTransparency = 1,
			}),
		}),
		Roact.createElement(BrightButton, {
			onActivate = function()
				return dispatch(setJobActive(props.jobName, not job.active))
			end,
			onHover = function(isHovered)
				setHovered(isHovered)
				if isHovered then
					dispatch(setHint(props.hint))
				else
					dispatch(clearHint())
				end
			end,
			size = px(85, 49),
			position = px(193, 0),
			radius = 8,
			color = buttonBackground,
			borderEnabled = theme.button.outlined,
			borderColor = buttonForeground,
			transparency = theme.button.backgroundTransparency,
		}, {
			Roact.createElement("TextLabel", {
				Font = "GothamBold",
				Text = props.display,
				TextSize = 15,
				TextColor3 = buttonForeground,
				TextXAlignment = "Center",
				TextYAlignment = "Center",
				TextTransparency = useSpring(job.active and 0 or (hovered and theme.button.foregroundTransparency - 0.25 or theme.button.foregroundTransparency), {}),
				Size = scale(1, 1),
				BackgroundTransparency = 1,
			}),
		}),
	})
end
Slider = hooked(SliderComponent)
return {
	default = default,
}

        end)
    end)
    hMod("Username", "ModuleScript", "Havoc.views.Pages.Home.Profile.Username", "Havoc.views.Pages.Home.Profile", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).hooked
local Players = TS.import(script, TS.getModule(script, "@rbxts", "services")).Players
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Canvas").default
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2")
local px = _udim2.px
local scale = _udim2.scale
local function Username()
	local theme = useTheme("home").profile
	return Roact.createElement(Canvas, {
		anchor = Vector2.new(0.5, 0),
		size = px(278, 49),
		position = UDim2.new(0.5, 0, 0, 231),
	}, {
		Roact.createElement("TextLabel", {
			Font = "GothamBlack",
			Text = Players.LocalPlayer.DisplayName,
			TextSize = 20,
			TextColor3 = theme.foreground,
			TextXAlignment = "Center",
			TextYAlignment = "Top",
			Size = scale(1, 1),
			BackgroundTransparency = 1,
		}),
		Roact.createElement("TextLabel", {
			Font = "GothamBold",
			Text = Players.LocalPlayer.Name,
			TextSize = 16,
			TextColor3 = theme.foreground,
			TextXAlignment = "Center",
			TextYAlignment = "Bottom",
			TextTransparency = 0.7,
			Size = scale(1, 1),
			BackgroundTransparency = 1,
		}),
	})
end
local default = hooked(Username)
return {
	default = default,
}

        end)
    end)
    hMod("Server", "ModuleScript", "Havoc.views.Pages.Home.Server", "Havoc.views.Pages.Home", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Server").default
return exports

        end)
    end)
    hMod("Server", "ModuleScript", "Havoc.views.Pages.Home.Server.Server", "Havoc.views.Pages.Home.Server", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).hooked
local Players = TS.import(script, TS.getModule(script, "@rbxts", "services")).Players
local Card = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Card").default
local IS_DEV = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "constants").IS_DEV
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "models", "dashboard.model").DashboardPage
local px = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2").px
local ServerAction = TS.import(script, script.Parent, "ServerAction").default
local StatusLabel = TS.import(script, script.Parent, "StatusLabel").default
local function Server()
	local theme = useTheme("home").server
	return Roact.createElement(Card, {
		index = 2,
		page = DashboardPage.Home,
		theme = theme,
		size = px(326, 184),
		position = UDim2.new(0, 374, 1, -416 - 48),
	}, {
		Roact.createElement("TextLabel", {
			Text = "Server",
			Font = "GothamBlack",
			TextSize = 20,
			TextColor3 = theme.foreground,
			TextXAlignment = "Left",
			TextYAlignment = "Top",
			Position = px(24, 24),
			BackgroundTransparency = 1,
		}),
		Roact.createElement(StatusLabel, {
			index = 0,
			offset = 69,
			units = "players",
			getValue = function()
				return tostring(#Players:GetPlayers()) .. (" / " .. tostring(Players.MaxPlayers))
			end,
		}),
		Roact.createElement(StatusLabel, {
			index = 1,
			offset = 108,
			units = "elapsed",
			getValue = function()
				local uptime = IS_DEV and os.clock() or time()
				local days = math.floor(uptime / 86400)
				local hours = math.floor((uptime - days * 86400) / 3600)
				local minutes = math.floor((uptime - days * 86400 - hours * 3600) / 60)
				local seconds = math.floor(uptime - days * 86400 - hours * 3600 - minutes * 60)
				return days > 0 and tostring(days) .. " days" or (hours > 0 and tostring(hours) .. " hours" or (minutes > 0 and tostring(minutes) .. " minutes" or tostring(seconds) .. " seconds"))
			end,
		}),
		Roact.createElement(StatusLabel, {
			index = 2,
			offset = 147,
			units = "ping",
			getValue = function()
				return tostring(math.round(Players.LocalPlayer:GetNetworkPing() * 1000)) .. " ms"
			end,
		}),
		Roact.createElement(ServerAction, {
			action = "switchServer",
			hint = "<font face='GothamBlack'>Switch</font> to a different server",
			icon = "rbxassetid://8992259774",
			size = px(66, 50),
			position = UDim2.new(1, -66 - 24, 1, -100 - 16 - 12),
		}),
		Roact.createElement(ServerAction, {
			action = "rejoinServer",
			hint = "<font face='GothamBlack'>Rejoin</font> this server",
			icon = "rbxassetid://8992259894",
			size = px(66, 50),
			position = UDim2.new(1, -66 - 24, 1, -50 - 16),
		}),
	})
end
local default = hooked(Server)
return {
	default = default,
}

        end)
    end)
    hMod("ServerAction", "ModuleScript", "Havoc.views.Pages.Home.Server.ServerAction", "Havoc.views.Pages.Home.Server", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local hooked = _roact_hooked.hooked
local useState = _roact_hooked.useState
local BrightButton = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "BrightButton").default
local _rodux_hooks = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "rodux-hooks")
local useAppDispatch = _rodux_hooks.useAppDispatch
local useAppSelector = _rodux_hooks.useAppSelector
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "use-spring").useSpring
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local _dashboard_action = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "actions", "dashboard.action")
local clearHint = _dashboard_action.clearHint
local setHint = _dashboard_action.setHint
local setJobActive = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "actions", "jobs.action").setJobActive
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2")
local px = _udim2.px
local scale = _udim2.scale
local function ServerAction(_param)
	local action = _param.action
	local hint = _param.hint
	local icon = _param.icon
	local size = _param.size
	local position = _param.position
	local dispatch = useAppDispatch()
	local theme = useTheme("home").server[action == "switchServer" and "switchButton" or "rejoinButton"]
	local active = useAppSelector(function(state)
		local job = state.jobs[action]
		local _result = job
		if _result ~= nil then
			_result = _result.active
		end
		local _condition = _result
		if _condition == nil then
			_condition = false
		end
		return _condition
	end)
	local _binding = useState(false)
	local hovered = _binding[1]
	local setHovered = _binding[2]
	local _result
	if active then
		_result = theme.accent
	else
		local _result_1
		if hovered then
			local _condition = theme.backgroundHovered
			if _condition == nil then
				_condition = theme.background:Lerp(theme.accent, 0.1)
			end
			_result_1 = _condition
		else
			_result_1 = theme.background
		end
		_result = _result_1
	end
	local background = useSpring(_result, {})
	local foreground = useSpring(active and theme.foregroundAccent and theme.foregroundAccent or theme.foreground, {})
	return Roact.createElement(BrightButton, {
		onActivate = function()
			return dispatch(setJobActive(action, not active))
		end,
		onHover = function(isHovered)
			setHovered(isHovered)
			if isHovered then
				dispatch(setHint(hint))
			else
				dispatch(clearHint())
			end
		end,
		size = size,
		position = position,
		radius = 8,
		color = background,
		borderEnabled = theme.outlined,
		borderColor = foreground,
		transparency = theme.backgroundTransparency,
	}, {
		Roact.createElement("ImageLabel", {
			Image = icon,
			ImageColor3 = foreground,
			ImageTransparency = useSpring(active and 0 or (hovered and theme.foregroundTransparency - 0.25 or theme.foregroundTransparency), {}),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = px(36, 36),
			Position = scale(0.5, 0.5),
			BackgroundTransparency = 1,
		}),
	})
end
local default = hooked(ServerAction)
return {
	default = default,
}

        end)
    end)
    hMod("StatusLabel", "ModuleScript", "Havoc.views.Pages.Home.Server.StatusLabel", "Havoc.views.Pages.Home.Server", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local hooked = _roact_hooked.hooked
local useMemo = _roact_hooked.useMemo
local useState = _roact_hooked.useState
local TextService = TS.import(script, TS.getModule(script, "@rbxts", "services")).TextService
local useDelayedUpdate = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "use-delayed-update").useDelayedUpdate
local useInterval = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "use-interval").useInterval
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "use-spring").useSpring
local useIsPageOpen = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-current-page").useIsPageOpen
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "models", "dashboard.model").DashboardPage
local px = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2").px
local function StatusLabel(_param)
	local offset = _param.offset
	local index = _param.index
	local units = _param.units
	local getValue = _param.getValue
	local theme = useTheme("home").server
	local _binding = useState(getValue)
	local value = _binding[1]
	local setValue = _binding[2]
	local isOpen = useIsPageOpen(DashboardPage.Home)
	local isVisible = useDelayedUpdate(isOpen, isOpen and 330 + index * 100 or 300)
	local valueLength = useMemo(function()
		return TextService:GetTextSize(value .. " ", 16, "GothamBold", Vector2.new()).X
	end, { value })
	useInterval(function()
		setValue(getValue())
	end, 1000)
	return Roact.createFragment({
		Roact.createElement("TextLabel", {
			Text = value,
			RichText = true,
			Font = "GothamBold",
			TextSize = 16,
			TextColor3 = theme.foreground,
			TextTransparency = useSpring(isVisible and 0 or 1, {
				frequency = 2,
			}),
			TextXAlignment = "Left",
			TextYAlignment = "Top",
			Position = useSpring(isVisible and px(24, offset) or px(0, offset), {}),
			BackgroundTransparency = 1,
		}),
		Roact.createElement("TextLabel", {
			Text = units,
			RichText = true,
			Font = "GothamBold",
			TextSize = 16,
			TextColor3 = theme.foreground,
			TextTransparency = useSpring(isVisible and 0.4 or 1, {}),
			TextXAlignment = "Left",
			TextYAlignment = "Top",
			Position = useSpring(isVisible and px(24 + valueLength, offset) or px(0 + valueLength, offset), {}),
			BackgroundTransparency = 1,
		}),
	})
end
local default = hooked(StatusLabel)
return {
	default = default,
}

        end)
    end)
    hMod("Title", "ModuleScript", "Havoc.views.Pages.Home.Title", "Havoc.views.Pages.Home", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).hooked
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent, "components", "Canvas").default
local Card = TS.import(script, script.Parent.Parent.Parent.Parent, "components", "Card").default
local ParallaxImage = TS.import(script, script.Parent.Parent.Parent.Parent, "components", "ParallaxImage").default
local VERSION_TAG = TS.import(script, script.Parent.Parent.Parent.Parent, "constants").VERSION_TAG
local useDelayedUpdate = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "common", "use-delayed-update").useDelayedUpdate
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "common", "use-spring").useSpring
local useIsPageOpen = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-current-page").useIsPageOpen
local useParallaxOffset = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-parallax-offset").useParallaxOffset
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent, "store", "models", "dashboard.model").DashboardPage
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "udim2")
local px = _udim2.px
local scale = _udim2.scale
local Label
local function Title()
	local theme = useTheme("home").title
	local offset = useParallaxOffset()
	return Roact.createElement(Card, {
		index = 0,
		page = DashboardPage.Home,
		theme = theme,
		size = px(326, 184),
		position = UDim2.new(0, 0, 1, -648 - 48),
	}, {
		Roact.createElement(ParallaxImage, {
			image = "rbxassetid://9049308243",
			imageSize = Vector2.new(652, 368),
			padding = Vector2.new(30, 30),
			offset = offset,
		}, {
			Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 12),
			}),
		}),
		Roact.createElement("ImageLabel", {
			Image = "rbxassetid://9048947177",
			Size = scale(1, 1),
			ImageTransparency = 0.3,
			BackgroundTransparency = 1,
		}, {
			Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 12),
			}),
		}),
		Roact.createElement(Canvas, {
			padding = {
				top = 24,
				left = 24,
			},
		}, {
			Roact.createElement(Label, {
				index = 0,
				text = "Orca",
				font = Enum.Font.GothamBlack,
				size = 20,
				position = px(0, 0),
			}),
			Roact.createElement(Label, {
				index = 1,
				text = VERSION_TAG,
				position = px(0, 40),
			}),
			Roact.createElement(Label, {
				index = 2,
				text = "By 0866",
				position = px(0, 63),
				transparency = 0.15,
			}),
			Roact.createElement(Label, {
				index = 3,
				text = "Pls star repo",
				position = px(0, 86),
				transparency = 0.3,
			}),
			Roact.createElement(Label, {
				index = 4,
				text = "richie0866/orca",
				position = UDim2.new(0, 0, 1, -40),
				transparency = 0.45,
			}),
		}),
	})
end
local default = hooked(Title)
local function LabelComponent(props)
	local _binding = props
	local index = _binding.index
	local text = _binding.text
	local font = _binding.font
	if font == nil then
		font = Enum.Font.GothamBold
	end
	local size = _binding.size
	if size == nil then
		size = 16
	end
	local position = _binding.position
	local transparency = _binding.transparency
	if transparency == nil then
		transparency = 0
	end
	local theme = useTheme("home").title
	local isOpen = useIsPageOpen(DashboardPage.Home)
	local isActive = useDelayedUpdate(isOpen, index * 100 + 300, function(current)
		return not current
	end)
	local _attributes = {
		Text = text,
		Font = font,
		TextColor3 = theme.foreground,
		TextSize = size,
		TextTransparency = useSpring(isActive and transparency or 1, {
			frequency = 2,
		}),
		TextXAlignment = "Left",
		TextYAlignment = "Top",
		Size = px(200, 24),
	}
	local _result
	if isActive then
		_result = position
	else
		local _arg0 = px(24, 0)
		_result = position - _arg0
	end
	_attributes.Position = useSpring(_result, {})
	_attributes.BackgroundTransparency = 1
	return Roact.createElement("TextLabel", _attributes)
end
Label = hooked(LabelComponent)
return {
	default = default,
}

        end)
    end)
    hMod("Misc", "ModuleScript", "Havoc.views.Pages.Misc", "Havoc.views.Pages", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Misc").default
return exports

        end)
    end)
    hMod("FacebangModal", "ModuleScript", "Havoc.views.Pages.Misc.FacebangModal", "Havoc.views.Pages.Misc", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local hooked = _roact_hooked.hooked
local useCallback = _roact_hooked.useCallback
local useState = _roact_hooked.useState
local _rodux_hooks = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "common", "rodux-hooks")
local useSelector = _rodux_hooks.useSelector
local useDispatch = _rodux_hooks.useDispatch
local _jobs_action = TS.import(script, script.Parent.Parent.Parent.Parent, "store", "actions", "jobs.action")
local setJobActive = _jobs_action.setJobActive
local setJobSlider = _jobs_action.setJobSlider
local _services = TS.import(script, TS.getModule(script, "@rbxts", "services"))
local RunService = _services.RunService
local UserInputService = _services.UserInputService
local Players = _services.Players
local GREEN = Color3.fromRGB(80, 220, 140)
local BG_DARK = Color3.fromRGB(10, 10, 10)
local BG_ROW = Color3.fromRGB(20, 20, 20)
local BG_TRACK = Color3.fromRGB(15, 15, 15)
local Slider = hooked(function(_param)
	local label = _param.label
	local displayValue = _param.displayValue
	local percent = _param.percent
	local onUpdate = _param.onUpdate
	return Roact.createFragment({
		[label] = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 70),
			BackgroundTransparency = 1,
		}, {
			Label = Roact.createElement("TextLabel", {
				Text = label,
				Size = UDim2.new(0.5, 0, 0, 20),
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
			Value = Roact.createElement("TextLabel", {
				Text = displayValue,
				Size = UDim2.new(0.5, 0, 0, 20),
				Position = UDim2.new(0.5, 0, 0, 0),
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(160, 160, 160),
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Right,
			}),
			Track = Roact.createElement("TextButton", {
				Text = "",
				Size = UDim2.new(1, 0, 0, 36),
				Position = UDim2.new(0, 0, 0, 26),
				BackgroundColor3 = BG_TRACK,
				AutoButtonColor = false,
				[Roact.Event.MouseButton1Down] = function(rbx)
					local mouse = Players.LocalPlayer:GetMouse()
					local moveConn = RunService.RenderStepped:Connect(function()
						local relX = mouse.X - rbx.AbsolutePosition.X
						onUpdate(math.clamp(relX / rbx.AbsoluteSize.X, 0, 1))
					end)
					local upConn
					upConn = UserInputService.InputEnded:Connect(function(inp)
						if inp.UserInputType == Enum.UserInputType.MouseButton1 then
							moveConn:Disconnect()
							upConn:Disconnect()
						end
					end)
				end,
			}, {
				Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
				Fill = Roact.createElement("Frame", {
					Size = UDim2.new(percent, 0, 1, 0),
					BackgroundColor3 = GREEN,
					BorderSizePixel = 0,
				}, {
					Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 8),
					}),
					Thumb = Roact.createElement("Frame", {
						Size = UDim2.new(0, 4, 0, 18),
						Position = UDim2.new(1, -2, 0.5, -9),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
					}, {
						Roact.createElement("UICorner", {
							CornerRadius = UDim.new(1, 0),
						}),
					}),
				}),
			}),
		}),
	})
end)
local FacebangModal = hooked(function(_param)
	local isVisible = _param.isVisible
	local onClose = _param.onClose
	local job = useSelector(function(state)
		return state.jobs.facebang
	end)
	local dispatch = useDispatch()
	local _result = job
	if _result ~= nil then
		_result = _result.sliders
	end
	local sliders = _result
	local _binding = useState("Z")
	local keybind = _binding[1]
	local setKeybind = _binding[2]
	local _binding_1 = useState(false)
	local listeningForKey = _binding_1[1]
	local setListeningForKey = _binding_1[2]
	local handleToggleActive = useCallback(function()
		if job then
			dispatch(setJobActive("facebang", not job.active))
		end
	end, { job })
	local handleSpeedUpdate = useCallback(function(p)
		return dispatch(setJobSlider("facebang", "speed", p * 10))
	end, {})
	local handleDistanceUpdate = useCallback(function(p)
		return dispatch(setJobSlider("facebang", "distance", p * 15))
	end, {})
	if not isVisible or (not job or not sliders) then
		return Roact.createFragment()
	end
	local _attributes = {
		Size = UDim2.new(0, 380, 0, 480),
		Position = UDim2.new(0.5, -190, 0.5, -240),
		BackgroundColor3 = BG_DARK,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 11,
		[Roact.Event.InputBegan] = function(_, input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			end
		end,
	}
	local _children = {
		Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 14),
		}),
		Roact.createElement("UIStroke", {
			Color = Color3.fromRGB(30, 30, 30),
			Thickness = 1,
		}),
		Header = Roact.createElement("Frame", {
			Size = UDim2.new(1, -40, 0, 55),
			Position = UDim2.new(0, 20, 0, 15),
			BackgroundTransparency = 1,
		}, {
			Title = Roact.createElement("TextLabel", {
				Text = "Facebang",
				Size = UDim2.new(0, 140, 0, 30),
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.GothamBold,
				TextSize = 22,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
			Subtitle = Roact.createElement("TextLabel", {
				Text = job.active and "Running" or "Press keybind to start",
				Size = UDim2.new(1, -150, 0, 30),
				Position = UDim2.new(0, 150, 0, 0),
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(130, 130, 130),
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Right,
			}),
			FooterNote = Roact.createElement("TextLabel", {
				Text = "Keybind activates on nearest player",
				Size = UDim2.new(1, 0, 0, 18),
				Position = UDim2.new(0, 0, 0, 32),
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(90, 90, 90),
				Font = Enum.Font.Gotham,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
		}),
		Divider = Roact.createElement("Frame", {
			Size = UDim2.new(1, -40, 0, 1),
			Position = UDim2.new(0, 20, 0, 78),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
		}),
		StartButton = Roact.createElement("TextButton", {
			Text = job.active and "STOP" or "START",
			Size = UDim2.new(1, -40, 0, 52),
			Position = UDim2.new(0, 20, 0, 92),
			BackgroundColor3 = GREEN,
			Font = Enum.Font.GothamBold,
			TextColor3 = Color3.fromRGB(10, 10, 10),
			TextSize = 16,
			AutoButtonColor = false,
			[Roact.Event.MouseButton1Click] = handleToggleActive,
		}, {
			Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 10),
			}),
		}),
		Divider2 = Roact.createElement("Frame", {
			Size = UDim2.new(1, -40, 0, 1),
			Position = UDim2.new(0, 20, 0, 158),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
		}),
		KeybindRow = Roact.createElement("Frame", {
			Size = UDim2.new(1, -40, 0, 44),
			Position = UDim2.new(0, 20, 0, 170),
			BackgroundTransparency = 1,
		}, {
			KeybindLabel = Roact.createElement("TextLabel", {
				Text = "Keybind",
				Size = UDim2.new(0.5, 0, 1, 0),
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
			KeybindBox = Roact.createElement("TextButton", {
				Text = listeningForKey and "..." or keybind,
				Size = UDim2.new(0, 90, 0, 34),
				Position = UDim2.new(1, -90, 0.5, -17),
				BackgroundColor3 = BG_ROW,
				TextColor3 = Color3.fromRGB(220, 220, 220),
				Font = Enum.Font.GothamBold,
				TextSize = 14,
				AutoButtonColor = false,
				[Roact.Event.MouseButton1Click] = function()
					setListeningForKey(true)
					local conn
					conn = UserInputService.InputBegan:Connect(function(inp, gp)
						if not gp and inp.UserInputType == Enum.UserInputType.Keyboard then
							local _condition = inp.KeyCode.Name
							if _condition == nil then
								_condition = "Z"
							end
							setKeybind(_condition)
							setListeningForKey(false)
							conn:Disconnect()
						end
					end)
				end,
			}, {
				Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
				Roact.createElement("UIStroke", {
					Color = Color3.fromRGB(40, 40, 40),
					Thickness = 1,
				}),
			}),
		}),
	}
	local _length = #_children
	local _attributes_1 = {
		Size = UDim2.new(1, -40, 0, 160),
		Position = UDim2.new(0, 20, 0, 225),
		BackgroundTransparency = 1,
	}
	local _children_1 = {
		Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}
	local _length_1 = #_children_1
	local _attributes_2 = {
		label = "Speed",
	}
	local _fn = math
	local _condition = sliders.speed
	if _condition == nil then
		_condition = 5
	end
	_attributes_2.displayValue = tostring(_fn.round(_condition * 10) / 10) .. "x"
	local _condition_1 = sliders.speed
	if _condition_1 == nil then
		_condition_1 = 5
	end
	_attributes_2.percent = _condition_1 / 10
	_attributes_2.onUpdate = handleSpeedUpdate
	_children_1.SpeedSlider = Roact.createElement(Slider, _attributes_2)
	_children_1.DistanceSlider = Roact.createElement(Slider, {
		label = "Distance",
		displayValue = tostring(math.round(sliders.distance * 10) / 10) .. " studs",
		percent = sliders.distance / 15,
		onUpdate = handleDistanceUpdate,
	})
	_children.Sliders = Roact.createElement("Frame", _attributes_1, _children_1)
	_children.FooterBottom = Roact.createElement("TextLabel", {
		Text = "Keybind activates on nearest player",
		Size = UDim2.new(1, -40, 0, 20),
		Position = UDim2.new(0, 20, 1, -30),
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(80, 80, 80),
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	return Roact.createFragment({
		FacebangModal = Roact.createElement("Frame", _attributes, _children),
	})
end)
local default = FacebangModal
return {
	default = default,
}

        end)
    end)
    hMod("Misc", "ModuleScript", "Havoc.views.Pages.Misc.Misc", "Havoc.views.Pages.Misc", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local hooked = _roact_hooked.hooked
local useState = _roact_hooked.useState
local useCallback = _roact_hooked.useCallback
local Card = TS.import(script, script.Parent.Parent.Parent.Parent, "components", "Card").default
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent, "store", "models", "dashboard.model").DashboardPage
local px = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "udim2").px
local FacebangModal = TS.import(script, script.Parent, "FacebangModal").default
local function MiscPage()
	local theme = useTheme("apps").players
	local _binding = useState(false)
	local modalVisible = _binding[1]
	local setModalVisible = _binding[2]
	local _binding_1 = useState(false)
	local isHovered = _binding_1[1]
	local setHovered = _binding_1[2]
	local openModal = useCallback(function()
		return setModalVisible(true)
	end, {})
	local closeModal = useCallback(function()
		return setModalVisible(false)
	end, {})
	local _attributes = {
		index = 2,
		page = DashboardPage.Apps,
		theme = theme,
		size = px(326, 648),
		position = UDim2.new(0, 0, 1, 0),
	}
	local _children = {
		Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 20),
			PaddingLeft = UDim.new(0, 20),
			PaddingRight = UDim.new(0, 20),
		}),
		ContentScroll = Roact.createElement("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ScrollBarThickness = 2,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ZIndex = 1,
		}, {
			Roact.createElement("UIListLayout", {
				Padding = UDim.new(0, 12),
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
			}),
			FacebangButton = Roact.createElement("TextButton", {
				Text = "Facebang Settings",
				Size = UDim2.new(1, 0, 0, 55),
				BackgroundColor3 = isHovered and theme.button.background:Lerp(Color3.new(1, 1, 1), 0.05) or theme.button.background,
				TextColor3 = theme.button.foreground,
				Font = Enum.Font.GothamBold,
				TextSize = 16,
				AutoButtonColor = false,
				ZIndex = 1,
				[Roact.Event.Activated] = openModal,
				[Roact.Event.MouseEnter] = function()
					return setHovered(true)
				end,
				[Roact.Event.MouseLeave] = function()
					return setHovered(false)
				end,
			}, {
				Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 10),
				}),
				Roact.createElement("UIStroke", {
					Thickness = 2,
					Color = theme.button.background:Lerp(Color3.new(1, 1, 1), 0.15),
					Transparency = isHovered and 0.2 or 0.6,
				}),
			}),
		}),
	}
	local _length = #_children
	local _child = modalVisible and (Roact.createFragment({
		ModalOverlay = Roact.createElement("TextButton", {
			Text = "",
			Size = UDim2.new(1, 40, 1, 40),
			Position = UDim2.new(0, -20, 0, -20),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.4,
			AutoButtonColor = false,
			ZIndex = 10,
			[Roact.Event.Activated] = closeModal,
		}, {
			Roact.createElement(FacebangModal, {
				isVisible = modalVisible,
				onClose = closeModal,
			}),
		}),
	}))
	if _child then
		if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then
			_children[_length + 1] = _child
		else
			for _k, _v in ipairs(_child) do
				_children[_length + _k] = _v
			end
		end
	end
	return Roact.createElement(Card, _attributes, _children)
end
local default = hooked(MiscPage)
return {
	default = default,
}

        end)
    end)
    hMod("Options", "ModuleScript", "Havoc.views.Pages.Options", "Havoc.views.Pages", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Options").default
return exports

        end)
    end)
    hMod("Config", "ModuleScript", "Havoc.views.Pages.Options.Config", "Havoc.views.Pages.Options", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Config").default
return exports

        end)
    end)
    hMod("Config", "ModuleScript", "Havoc.views.Pages.Options.Config.Config", "Havoc.views.Pages.Options.Config", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).hooked
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Canvas").default
local Card = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Card").default
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "models", "dashboard.model").DashboardPage
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2")
local px = _udim2.px
local scale = _udim2.scale
local _ConfigItem = TS.import(script, script.Parent, "ConfigItem")
local ConfigItem = _ConfigItem.default
local ENTRY_HEIGHT = _ConfigItem.ENTRY_HEIGHT
local PADDING = _ConfigItem.PADDING
local ENTRY_COUNT = 1
local function Config()
	local theme = useTheme("options").config
	return Roact.createElement(Card, {
		index = 0,
		page = DashboardPage.Options,
		theme = theme,
		size = px(326, 184),
		position = UDim2.new(0, 0, 1, -416 - 48),
	}, {
		Roact.createElement("TextLabel", {
			Text = "Options",
			Font = "GothamBlack",
			TextSize = 20,
			TextColor3 = theme.foreground,
			TextXAlignment = "Left",
			TextYAlignment = "Top",
			Position = px(24, 24),
			BackgroundTransparency = 1,
		}),
		Roact.createElement(Canvas, {
			size = px(326, 348),
			position = px(0, 68),
			padding = {
				left = 24,
				right = 24,
				top = 8,
			},
			clipsDescendants = true,
		}, {
			Roact.createElement("ScrollingFrame", {
				Size = scale(1, 1),
				CanvasSize = px(0, ENTRY_COUNT * (ENTRY_HEIGHT + PADDING) + PADDING),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarImageTransparency = 1,
				ScrollBarThickness = 0,
				ClipsDescendants = false,
			}, {
				Roact.createElement(ConfigItem, {
					action = "acrylicBlur",
					description = "Acrylic background blurring",
					hint = "<font face='GothamBlack'>Toggle BG blur</font> in some themes. May be detectable when enabled.",
					index = 0,
				}),
			}),
		}),
	})
end
local default = hooked(Config)
return {
	default = default,
}

        end)
    end)
    hMod("ConfigItem", "ModuleScript", "Havoc.views.Pages.Options.Config.ConfigItem", "Havoc.views.Pages.Options.Config", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local pure = _roact_hooked.pure
local useState = _roact_hooked.useState
local Border = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Border").default
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Canvas").default
local Fill = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Fill").default
local _Glow = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Glow")
local Glow = _Glow.default
local GlowRadius = _Glow.GlowRadius
local _rodux_hooks = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "rodux-hooks")
local useAppDispatch = _rodux_hooks.useAppDispatch
local useAppSelector = _rodux_hooks.useAppSelector
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "use-spring").useSpring
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local _dashboard_action = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "actions", "dashboard.action")
local clearHint = _dashboard_action.clearHint
local setHint = _dashboard_action.setHint
local setConfig = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "actions", "options.action").setConfig
local lerp = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "number-util").lerp
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2")
local px = _udim2.px
local scale = _udim2.scale
local PADDING = 20
local ENTRY_HEIGHT = 60
local ENTRY_WIDTH = 326 - 24 * 2
local ENTRY_TEXT_PADDING = 16
local function ConfigItem(_param)
	local action = _param.action
	local description = _param.description
	local hint = _param.hint
	local index = _param.index
	local dispatch = useAppDispatch()
	local buttonTheme = useTheme("options").config.configButton
	local active = useAppSelector(function(state)
		return state.options.config[action]
	end)
	local _binding = useState(false)
	local hovered = _binding[1]
	local setHovered = _binding[2]
	local _result
	if active then
		_result = buttonTheme.accent
	else
		local _result_1
		if hovered then
			local _condition = buttonTheme.backgroundHovered
			if _condition == nil then
				_condition = buttonTheme.background:Lerp(buttonTheme.accent, 0.1)
			end
			_result_1 = _condition
		else
			_result_1 = buttonTheme.background
		end
		_result = _result_1
	end
	local background = useSpring(_result, {})
	local _result_1
	if active then
		_result_1 = buttonTheme.accent
	else
		local _result_2
		if hovered then
			local _condition = buttonTheme.backgroundHovered
			if _condition == nil then
				_condition = buttonTheme.dropshadow:Lerp(buttonTheme.accent, 0.5)
			end
			_result_2 = _condition
		else
			_result_2 = buttonTheme.dropshadow
		end
		_result_1 = _result_2
	end
	local dropshadow = useSpring(_result_1, {})
	local foreground = useSpring(active and buttonTheme.foregroundAccent and buttonTheme.foregroundAccent or buttonTheme.foreground, {})
	local _attributes = {
		size = px(ENTRY_WIDTH, ENTRY_HEIGHT),
		position = px(0, (PADDING + ENTRY_HEIGHT) * index),
		zIndex = index,
	}
	local _children = {
		Roact.createElement(Glow, {
			radius = GlowRadius.Size70,
			color = dropshadow,
			size = UDim2.new(1, 36, 1, 36),
			position = px(-18, 5 - 18),
			transparency = useSpring(active and buttonTheme.glowTransparency or (hovered and lerp(buttonTheme.dropshadowTransparency, buttonTheme.glowTransparency, 0.5) or buttonTheme.dropshadowTransparency), {}),
		}),
		Roact.createElement(Fill, {
			color = background,
			transparency = buttonTheme.backgroundTransparency,
			radius = 8,
		}),
		Roact.createElement("TextLabel", {
			Text = description,
			Font = "GothamBold",
			TextSize = 16,
			TextColor3 = foreground,
			TextXAlignment = "Left",
			TextYAlignment = "Center",
			TextTransparency = useSpring(active and 0 or (hovered and buttonTheme.foregroundTransparency / 2 or buttonTheme.foregroundTransparency), {}),
			Position = px(ENTRY_TEXT_PADDING, 1),
			Size = UDim2.new(1, -ENTRY_TEXT_PADDING, 1, -1),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
		}),
	}
	local _length = #_children
	local _child = buttonTheme.outlined and Roact.createElement(Border, {
		color = foreground,
		transparency = 0.8,
		radius = 8,
	})
	if _child then
		if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then
			_children[_length + 1] = _child
		else
			for _k, _v in ipairs(_child) do
				_children[_length + _k] = _v
			end
		end
	end
	_length = #_children
	_children[_length + 1] = Roact.createElement("TextButton", {
		[Roact.Event.Activated] = function()
			return dispatch(setConfig(action, not active))
		end,
		[Roact.Event.MouseEnter] = function()
			setHovered(true)
			dispatch(setHint(hint))
		end,
		[Roact.Event.MouseLeave] = function()
			setHovered(false)
			dispatch(clearHint())
		end,
		Text = "",
		Size = scale(1, 1),
		Transparency = 1,
	})
	return Roact.createElement(Canvas, _attributes, _children)
end
local default = pure(ConfigItem)
return {
	PADDING = PADDING,
	ENTRY_HEIGHT = ENTRY_HEIGHT,
	ENTRY_WIDTH = ENTRY_WIDTH,
	ENTRY_TEXT_PADDING = ENTRY_TEXT_PADDING,
	default = default,
}

        end)
    end)
    hMod("Options", "ModuleScript", "Havoc.views.Pages.Options.Options", "Havoc.views.Pages.Options", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local pure = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).pure
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent, "components", "Canvas").default
local useScale = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-scale").useScale
local scale = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "udim2").scale
local Config = TS.import(script, script.Parent, "Config").default
local Shortcuts = TS.import(script, script.Parent, "Shortcuts").default
local Themes = TS.import(script, script.Parent, "Themes").default
local function Options()
	local scaleFactor = useScale()
	return Roact.createElement(Canvas, {
		position = scale(0, 1),
		anchor = Vector2.new(0, 1),
	}, {
		Roact.createElement("UIScale", {
			Scale = scaleFactor,
		}),
		Roact.createElement(Config),
		Roact.createElement(Themes),
		Roact.createElement(Shortcuts),
	})
end
local default = pure(Options)
return {
	default = default,
}

        end)
    end)
    hMod("Shortcuts", "ModuleScript", "Havoc.views.Pages.Options.Shortcuts", "Havoc.views.Pages.Options", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Shortcuts").default
return exports

        end)
    end)
    hMod("ShortcutItem", "ModuleScript", "Havoc.views.Pages.Options.Shortcuts.ShortcutItem", "Havoc.views.Pages.Options.Shortcuts", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local pure = _roact_hooked.pure
local useEffect = _roact_hooked.useEffect
local useState = _roact_hooked.useState
local UserInputService = TS.import(script, TS.getModule(script, "@rbxts", "services")).UserInputService
local Border = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Border").default
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Canvas").default
local Fill = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Fill").default
local _Glow = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Glow")
local Glow = _Glow.default
local GlowRadius = _Glow.GlowRadius
local _rodux_hooks = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "rodux-hooks")
local useAppDispatch = _rodux_hooks.useAppDispatch
local useAppSelector = _rodux_hooks.useAppSelector
local useDelayedUpdate = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "use-delayed-update").useDelayedUpdate
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "use-spring").useSpring
local useIsPageOpen = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-current-page").useIsPageOpen
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local _options_action = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "actions", "options.action")
local removeShortcut = _options_action.removeShortcut
local setShortcut = _options_action.setShortcut
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "models", "dashboard.model").DashboardPage
local lerp = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "number-util").lerp
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2")
local px = _udim2.px
local scale = _udim2.scale
local PADDING = 20
local ENTRY_HEIGHT = 60
local ENTRY_WIDTH = 326 - 24 * 2
local ENTRY_TEXT_PADDING = 16
local function ShortcutItem(_param)
	local onActivate = _param.onActivate
	local onSelect = _param.onSelect
	local selectedItem = _param.selectedItem
	local action = _param.action
	local description = _param.description
	local index = _param.index
	local dispatch = useAppDispatch()
	local buttonTheme = useTheme("options").shortcuts.shortcutButton
	local isOpen = useIsPageOpen(DashboardPage.Options)
	local isVisible = useDelayedUpdate(isOpen, isOpen and 250 + index * 40 or 230)
	local shortcut = useAppSelector(function(state)
		return state.options.shortcuts[action]
	end)
	local _exp = Enum.KeyCode:GetEnumItems()
	local _arg0 = function(item)
		return item.Value == shortcut
	end
	-- ▼ ReadonlyArray.find ▼
	local _result = nil
	for _i, _v in ipairs(_exp) do
		if _arg0(_v, _i - 1, _exp) == true then
			_result = _v
			break
		end
	end
	-- ▲ ReadonlyArray.find ▲
	local shortcutEnum = _result
	local selected = selectedItem == action
	local _binding = useState(false)
	local hovered = _binding[1]
	local setHovered = _binding[2]
	useEffect(function()
		if selectedItem ~= nil then
			return nil
		end
		local handle = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not gameProcessed and input.KeyCode.Value == shortcut then
				onActivate()
			end
		end)
		return function()
			handle:Disconnect()
		end
	end, { selectedItem, shortcut })
	useEffect(function()
		if not selected then
			return nil
		end
		local handle = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return nil
			end
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				onSelect(nil)
				return nil
			end
			local _exp_1 = input.KeyCode
			repeat
				if _exp_1 == (Enum.KeyCode.Unknown) then
					break
				end
				if _exp_1 == (Enum.KeyCode.Escape) then
					dispatch(removeShortcut(action))
					onSelect(nil)
					break
				end
				if _exp_1 == (Enum.KeyCode.Backspace) then
					dispatch(removeShortcut(action))
					onSelect(nil)
					break
				end
				if _exp_1 == (Enum.KeyCode.Return) then
					onSelect(nil)
					break
				end
				dispatch(setShortcut(action, input.KeyCode.Value))
				onSelect(nil)
				break
			until true
		end)
		return function()
			handle:Disconnect()
		end
	end, { selected })
	local _result_1
	if selected then
		_result_1 = buttonTheme.accent
	else
		local _result_2
		if hovered then
			local _condition = buttonTheme.backgroundHovered
			if _condition == nil then
				_condition = buttonTheme.background:Lerp(buttonTheme.accent, 0.1)
			end
			_result_2 = _condition
		else
			_result_2 = buttonTheme.background
		end
		_result_1 = _result_2
	end
	local background = useSpring(_result_1, {})
	local _result_2
	if selected then
		_result_2 = buttonTheme.accent
	else
		local _result_3
		if hovered then
			local _condition = buttonTheme.backgroundHovered
			if _condition == nil then
				_condition = buttonTheme.dropshadow:Lerp(buttonTheme.accent, 0.5)
			end
			_result_3 = _condition
		else
			_result_3 = buttonTheme.dropshadow
		end
		_result_2 = _result_3
	end
	local dropshadow = useSpring(_result_2, {})
	local foreground = useSpring(selected and buttonTheme.foregroundAccent and buttonTheme.foregroundAccent or buttonTheme.foreground, {})
	local _attributes = {
		size = px(ENTRY_WIDTH, ENTRY_HEIGHT),
		position = useSpring(isVisible and px(0, (PADDING + ENTRY_HEIGHT) * index) or px(-ENTRY_WIDTH - 24, (PADDING + ENTRY_HEIGHT) * index), {}),
		zIndex = index,
	}
	local _children = {
		Roact.createElement(Glow, {
			radius = GlowRadius.Size70,
			color = dropshadow,
			size = UDim2.new(1, 36, 1, 36),
			position = px(-18, 5 - 18),
			transparency = useSpring(selected and buttonTheme.glowTransparency or (hovered and lerp(buttonTheme.dropshadowTransparency, buttonTheme.glowTransparency, 0.5) or buttonTheme.dropshadowTransparency), {}),
		}),
		Roact.createElement(Fill, {
			color = background,
			transparency = buttonTheme.backgroundTransparency,
			radius = 8,
		}),
		Roact.createElement("TextLabel", {
			Text = description,
			Font = "GothamBold",
			TextSize = 16,
			TextColor3 = foreground,
			TextXAlignment = "Left",
			TextYAlignment = "Center",
			TextTransparency = useSpring(selected and 0 or (hovered and buttonTheme.foregroundTransparency / 2 or buttonTheme.foregroundTransparency), {}),
			Position = px(ENTRY_TEXT_PADDING, 1),
			Size = UDim2.new(1, -ENTRY_TEXT_PADDING, 1, -1),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
		}),
		Roact.createElement("TextLabel", {
			Text = shortcutEnum and shortcutEnum.Name or "Not bound",
			Font = "GothamBold",
			TextSize = 16,
			TextColor3 = foreground,
			TextXAlignment = "Center",
			TextYAlignment = "Center",
			TextTransparency = useSpring(selected and 0 or (hovered and buttonTheme.foregroundTransparency / 2 or buttonTheme.foregroundTransparency), {}),
			TextTruncate = "AtEnd",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 1),
			Size = UDim2.new(0, 124, 1, -1),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
		}),
		Roact.createElement("Frame", {
			Size = buttonTheme.outlined and UDim2.new(0, 1, 1, -2) or UDim2.new(0, 1, 1, -36),
			Position = buttonTheme.outlined and UDim2.new(1, -124, 0, 1) or UDim2.new(1, -124, 0, 18),
			BackgroundColor3 = foreground,
			BackgroundTransparency = 0.8,
			BorderSizePixel = 0,
		}),
	}
	local _length = #_children
	local _child = buttonTheme.outlined and Roact.createElement(Border, {
		color = foreground,
		transparency = 0.8,
		radius = 8,
	})
	if _child then
		if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then
			_children[_length + 1] = _child
		else
			for _k, _v in ipairs(_child) do
				_children[_length + _k] = _v
			end
		end
	end
	_length = #_children
	_children[_length + 1] = Roact.createElement("TextButton", {
		[Roact.Event.Activated] = function()
			return onSelect(action)
		end,
		[Roact.Event.MouseEnter] = function()
			return setHovered(true)
		end,
		[Roact.Event.MouseLeave] = function()
			return setHovered(false)
		end,
		Text = "",
		Size = scale(1, 1),
		Transparency = 1,
	})
	return Roact.createElement(Canvas, _attributes, _children)
end
local default = pure(ShortcutItem)
return {
	PADDING = PADDING,
	ENTRY_HEIGHT = ENTRY_HEIGHT,
	ENTRY_WIDTH = ENTRY_WIDTH,
	ENTRY_TEXT_PADDING = ENTRY_TEXT_PADDING,
	default = default,
}

        end)
    end)
    hMod("Shortcuts", "ModuleScript", "Havoc.views.Pages.Options.Shortcuts.Shortcuts", "Havoc.views.Pages.Options.Shortcuts", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local hooked = _roact_hooked.hooked
local useState = _roact_hooked.useState
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Canvas").default
local Card = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Card").default
local _rodux_hooks = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "rodux-hooks")
local useAppDispatch = _rodux_hooks.useAppDispatch
local useAppStore = _rodux_hooks.useAppStore
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local toggleDashboard = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "actions", "dashboard.action").toggleDashboard
local setJobActive = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "actions", "jobs.action").setJobActive
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "models", "dashboard.model").DashboardPage
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2")
local px = _udim2.px
local scale = _udim2.scale
local _ShortcutItem = TS.import(script, script.Parent, "ShortcutItem")
local ShortcutItem = _ShortcutItem.default
local ENTRY_HEIGHT = _ShortcutItem.ENTRY_HEIGHT
local PADDING = _ShortcutItem.PADDING
local ENTRY_COUNT = 7
local function Shortcuts()
	local store = useAppStore()
	local dispatch = useAppDispatch()
	local theme = useTheme("options").shortcuts
	local _binding = useState(nil)
	local selectedItem = _binding[1]
	local setSelectedItem = _binding[2]
	return Roact.createElement(Card, {
		index = 1,
		page = DashboardPage.Options,
		theme = theme,
		size = px(326, 416),
		position = UDim2.new(0, 0, 1, 0),
	}, {
		Roact.createElement("TextLabel", {
			Text = "Shortcuts",
			Font = "GothamBlack",
			TextSize = 20,
			TextColor3 = theme.foreground,
			TextXAlignment = "Left",
			TextYAlignment = "Top",
			Position = px(24, 24),
			BackgroundTransparency = 1,
		}),
		Roact.createElement(Canvas, {
			size = px(326, 348),
			position = px(0, 68),
			padding = {
				left = 24,
				right = 24,
				top = 8,
			},
			clipsDescendants = true,
		}, {
			Roact.createElement("ScrollingFrame", {
				Size = scale(1, 1),
				CanvasSize = px(0, ENTRY_COUNT * (ENTRY_HEIGHT + PADDING) + PADDING),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarImageTransparency = 1,
				ScrollBarThickness = 0,
				ClipsDescendants = false,
			}, {
				Roact.createElement(ShortcutItem, {
					onActivate = function()
						dispatch(toggleDashboard())
					end,
					onSelect = setSelectedItem,
					selectedItem = selectedItem,
					action = "toggleDashboard",
					description = "Open Orca",
					index = 0,
				}),
				Roact.createElement(ShortcutItem, {
					onActivate = function()
						local state = store:getState()
						local job = state.jobs.flight
						dispatch(setJobActive("flight", not job.active))
					end,
					onSelect = setSelectedItem,
					selectedItem = selectedItem,
					action = "toggleFlight",
					description = "Toggle flight",
					index = 1,
				}),
				Roact.createElement(ShortcutItem, {
					onActivate = function()
						local state = store:getState()
						local job = state.jobs.freecam
						dispatch(setJobActive("freecam", not job.active))
					end,
					onSelect = setSelectedItem,
					selectedItem = selectedItem,
					action = "setFreecam",
					description = "Set freecam",
					index = 2,
				}),
				Roact.createElement(ShortcutItem, {
					onActivate = function()
						local state = store:getState()
						local job = state.jobs.ghost
						dispatch(setJobActive("ghost", not job.active))
					end,
					onSelect = setSelectedItem,
					selectedItem = selectedItem,
					action = "setGhost",
					description = "Set ghost mode",
					index = 3,
				}),
				Roact.createElement(ShortcutItem, {
					onActivate = function()
						local state = store:getState()
						local job = state.jobs.walkSpeed
						dispatch(setJobActive("walkSpeed", not job.active))
					end,
					onSelect = setSelectedItem,
					selectedItem = selectedItem,
					action = "setSpeed",
					description = "Set walk speed",
					index = 4,
				}),
				Roact.createElement(ShortcutItem, {
					onActivate = function()
						local state = store:getState()
						local job = state.jobs.jumpHeight
						dispatch(setJobActive("jumpHeight", not job.active))
					end,
					onSelect = setSelectedItem,
					selectedItem = selectedItem,
					action = "setJumpHeight",
					description = "Set jump height",
					index = 5,
				}),
				Roact.createElement(ShortcutItem, {
					onActivate = function()
						local state = store:getState()
						local job = state.jobs.facebang
						dispatch(setJobActive("facebang", not job.active))
					end,
					onSelect = setSelectedItem,
					selectedItem = selectedItem,
					action = "setFacebang",
					description = "Toggle Facebang",
					index = 6,
				}),
			}),
		}),
	})
end
local default = hooked(Shortcuts)
return {
	default = default,
}

        end)
    end)
    hMod("Themes", "ModuleScript", "Havoc.views.Pages.Options.Themes", "Havoc.views.Pages.Options", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Themes").default
return exports

        end)
    end)
    hMod("ThemeItem", "ModuleScript", "Havoc.views.Pages.Options.Themes.ThemeItem", "Havoc.views.Pages.Options.Themes", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local hooked = _roact_hooked.hooked
local useState = _roact_hooked.useState
local Border = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Border").default
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Canvas").default
local Fill = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Fill").default
local _Glow = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Glow")
local Glow = _Glow.default
local GlowRadius = _Glow.GlowRadius
local _rodux_hooks = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "rodux-hooks")
local useAppDispatch = _rodux_hooks.useAppDispatch
local useAppSelector = _rodux_hooks.useAppSelector
local useDelayedUpdate = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "use-delayed-update").useDelayedUpdate
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "common", "use-spring").useSpring
local useIsPageOpen = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-current-page").useIsPageOpen
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local setTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "actions", "options.action").setTheme
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "models", "dashboard.model").DashboardPage
local _color3 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "color3")
local getLuminance = _color3.getLuminance
local hex = _color3.hex
local lerp = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "number-util").lerp
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2")
local px = _udim2.px
local scale = _udim2.scale
local PADDING = 20
local ENTRY_HEIGHT = 60
local ENTRY_WIDTH = 326 - 24 * 2
local ENTRY_TEXT_PADDING = 16
local ThemePreview
local function ThemeItem(_param)
	local theme = _param.theme
	local index = _param.index
	local dispatch = useAppDispatch()
	local buttonTheme = useTheme("options").themes.themeButton
	local isOpen = useIsPageOpen(DashboardPage.Options)
	local isVisible = useDelayedUpdate(isOpen, isOpen and 300 + index * 40 or 280)
	local isSelected = useAppSelector(function(state)
		return state.options.currentTheme == theme.name
	end)
	local _binding = useState(false)
	local hovered = _binding[1]
	local setHovered = _binding[2]
	local _result
	if isSelected then
		_result = buttonTheme.accent
	else
		local _result_1
		if hovered then
			local _condition = buttonTheme.backgroundHovered
			if _condition == nil then
				_condition = buttonTheme.background:Lerp(buttonTheme.accent, 0.1)
			end
			_result_1 = _condition
		else
			_result_1 = buttonTheme.background
		end
		_result = _result_1
	end
	local background = useSpring(_result, {})
	local _result_1
	if isSelected then
		_result_1 = buttonTheme.accent
	else
		local _result_2
		if hovered then
			local _condition = buttonTheme.backgroundHovered
			if _condition == nil then
				_condition = buttonTheme.dropshadow:Lerp(buttonTheme.accent, 0.5)
			end
			_result_2 = _condition
		else
			_result_2 = buttonTheme.dropshadow
		end
		_result_1 = _result_2
	end
	local dropshadow = useSpring(_result_1, {})
	local foreground = useSpring(isSelected and buttonTheme.foregroundAccent and buttonTheme.foregroundAccent or buttonTheme.foreground, {})
	local _attributes = {
		size = px(ENTRY_WIDTH, ENTRY_HEIGHT),
		position = useSpring(isVisible and px(0, (PADDING + ENTRY_HEIGHT) * index) or px(-ENTRY_WIDTH - 24, (PADDING + ENTRY_HEIGHT) * index), {}),
		zIndex = index,
	}
	local _children = {
		Roact.createElement(Glow, {
			radius = GlowRadius.Size70,
			color = dropshadow,
			size = UDim2.new(1, 36, 1, 36),
			position = px(-18, 5 - 18),
			transparency = useSpring(isSelected and buttonTheme.glowTransparency or (hovered and lerp(buttonTheme.dropshadowTransparency, buttonTheme.glowTransparency, 0.5) or buttonTheme.dropshadowTransparency), {}),
		}),
		Roact.createElement(Fill, {
			color = background,
			transparency = buttonTheme.backgroundTransparency,
			radius = 8,
		}),
		Roact.createElement("TextLabel", {
			Text = theme.name,
			Font = "GothamBold",
			TextSize = 16,
			TextColor3 = foreground,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextTransparency = useSpring(isSelected and 0 or (hovered and buttonTheme.foregroundTransparency / 2 or buttonTheme.foregroundTransparency), {}),
			BackgroundTransparency = 1,
			Position = px(ENTRY_TEXT_PADDING, 1),
			Size = UDim2.new(1, -ENTRY_TEXT_PADDING, 1, -1),
			ClipsDescendants = true,
		}),
		Roact.createElement(ThemePreview, {
			color = background,
			previewTheme = theme.preview,
		}),
	}
	local _length = #_children
	local _child = buttonTheme.outlined and Roact.createElement(Border, {
		color = foreground,
		transparency = 0.8,
		radius = 8,
	})
	if _child then
		if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then
			_children[_length + 1] = _child
		else
			for _k, _v in ipairs(_child) do
				_children[_length + _k] = _v
			end
		end
	end
	_length = #_children
	_children[_length + 1] = Roact.createElement("TextButton", {
		[Roact.Event.Activated] = function()
			return not isSelected and dispatch(setTheme(theme.name))
		end,
		[Roact.Event.MouseEnter] = function()
			return setHovered(true)
		end,
		[Roact.Event.MouseLeave] = function()
			return setHovered(false)
		end,
		Text = "",
		Transparency = 1,
		Size = scale(1, 1),
	})
	return Roact.createElement(Canvas, _attributes, _children)
end
local default = hooked(ThemeItem)
function ThemePreview(_param)
	local color = _param.color
	local previewTheme = _param.previewTheme
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Size = UDim2.new(0, 114, 1, -4),
		Position = UDim2.new(1, -2, 0, 2),
		BackgroundColor3 = color,
		Transparency = 1,
		BorderSizePixel = 0,
	}, {
		Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Size = px(25, 25),
			Position = UDim2.new(0, 12, 0.5, 0),
			BackgroundColor3 = hex("#ffffff"),
			BorderSizePixel = 0,
		}, {
			Roact.createElement("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			Roact.createElement("UIGradient", {
				Color = previewTheme.foreground.color,
				Transparency = previewTheme.foreground.transparency,
				Rotation = previewTheme.foreground.rotation,
			}),
			Roact.createElement("UIStroke", {
				Color = getLuminance(previewTheme.foreground.color) > 0.5 and hex("#000000") or hex("#ffffff"),
				Transparency = 0.5,
				Thickness = 2,
			}),
		}),
		Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = px(25, 25),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BackgroundColor3 = hex("#ffffff"),
			BorderSizePixel = 0,
		}, {
			Roact.createElement("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			Roact.createElement("UIGradient", {
				Color = previewTheme.background.color,
				Transparency = previewTheme.background.transparency,
				Rotation = previewTheme.background.rotation,
			}),
			Roact.createElement("UIStroke", {
				Color = getLuminance(previewTheme.background.color) > 0.5 and hex("#000000") or hex("#ffffff"),
				Transparency = 0.5,
				Thickness = 2,
			}),
		}),
		Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Size = px(25, 25),
			Position = UDim2.new(1, -12, 0.5, 0),
			BackgroundColor3 = hex("#ffffff"),
			BorderSizePixel = 0,
		}, {
			Roact.createElement("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			Roact.createElement("UIGradient", {
				Color = previewTheme.accent.color,
				Transparency = previewTheme.accent.transparency,
				Rotation = previewTheme.accent.rotation,
			}),
			Roact.createElement("UIStroke", {
				Color = getLuminance(previewTheme.accent.color) > 0.5 and hex("#000000") or hex("#ffffff"),
				Transparency = 0.5,
				Thickness = 2,
			}),
		}),
	})
end
return {
	PADDING = PADDING,
	ENTRY_HEIGHT = ENTRY_HEIGHT,
	ENTRY_WIDTH = ENTRY_WIDTH,
	ENTRY_TEXT_PADDING = ENTRY_TEXT_PADDING,
	default = default,
}

        end)
    end)
    hMod("Themes", "ModuleScript", "Havoc.views.Pages.Options.Themes.Themes", "Havoc.views.Pages.Options.Themes", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local hooked = _roact_hooked.hooked
local useMemo = _roact_hooked.useMemo
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Canvas").default
local Card = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "components", "Card").default
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-theme").useTheme
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "store", "models", "dashboard.model").DashboardPage
local getThemes = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "themes").getThemes
local arrayToMap = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "array-util").arrayToMap
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "udim2")
local px = _udim2.px
local scale = _udim2.scale
local _ThemeItem = TS.import(script, script.Parent, "ThemeItem")
local ThemeItem = _ThemeItem.default
local ENTRY_HEIGHT = _ThemeItem.ENTRY_HEIGHT
local PADDING = _ThemeItem.PADDING
local function Themes()
	local theme = useTheme("options").themes
	local themes = useMemo(getThemes, {})
	local _attributes = {
		index = 2,
		page = DashboardPage.Options,
		theme = theme,
		size = px(326, 416),
		position = UDim2.new(0, 374, 1, 0),
	}
	local _children = {
		Roact.createElement("TextLabel", {
			Text = "Themes",
			Font = "GothamBlack",
			TextSize = 20,
			TextColor3 = theme.foreground,
			TextXAlignment = "Left",
			TextYAlignment = "Top",
			Position = px(24, 24),
			BackgroundTransparency = 1,
		}),
	}
	local _length = #_children
	local _attributes_1 = {
		size = px(326, 348),
		position = px(0, 68),
		padding = {
			left = 24,
			right = 24,
			top = 8,
		},
		clipsDescendants = true,
	}
	local _children_1 = {}
	local _length_1 = #_children_1
	local _attributes_2 = {
		Size = scale(1, 1),
		CanvasSize = px(0, #themes * (ENTRY_HEIGHT + PADDING) + PADDING),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarImageTransparency = 1,
		ScrollBarThickness = 0,
		ClipsDescendants = false,
	}
	local _children_2 = {}
	local _length_2 = #_children_2
	for _k, _v in pairs(arrayToMap(themes, function(theme, index)
		return { theme.name, Roact.createElement(ThemeItem, {
			theme = theme,
			index = index,
		}) }
	end)) do
		_children_2[_k] = _v
	end
	_children_1[_length_1 + 1] = Roact.createElement("ScrollingFrame", _attributes_2, _children_2)
	_children[_length + 1] = Roact.createElement(Canvas, _attributes_1, _children_1)
	return Roact.createElement(Card, _attributes, _children)
end
local default = hooked(Themes)
return {
	default = default,
}

        end)
    end)
    hMod("Pages", "ModuleScript", "Havoc.views.Pages.Pages", "Havoc.views.Pages", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).hooked
local useDelayedUpdate = TS.import(script, script.Parent.Parent.Parent, "hooks", "common", "use-delayed-update").useDelayedUpdate
local useCurrentPage = TS.import(script, script.Parent.Parent.Parent, "hooks", "use-current-page").useCurrentPage
local DashboardPage = TS.import(script, script.Parent.Parent.Parent, "store", "models", "dashboard.model").DashboardPage
local Apps = TS.import(script, script.Parent, "Apps").default
local Home = TS.import(script, script.Parent, "Home").default
local Options = TS.import(script, script.Parent, "Options").default
local Scripts = TS.import(script, script.Parent, "Scripts").default
local Misc = TS.import(script, script.Parent, "Misc", "Misc").default
local function Pages()
	local currentPage = useCurrentPage()
	local isScriptsVisible = useDelayedUpdate(currentPage == DashboardPage.Scripts, 2000, function(isVisible)
		return isVisible
	end)
	local _children = {}
	local _length = #_children
	local _child = currentPage == DashboardPage.Home and Roact.createFragment({
		home = Roact.createElement(Home),
	})
	if _child then
		if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then
			_children[_length + 1] = _child
		else
			for _k, _v in ipairs(_child) do
				_children[_length + _k] = _v
			end
		end
	end
	_length = #_children
	local _child_1 = currentPage == DashboardPage.Apps and Roact.createFragment({
		apps = Roact.createElement(Apps),
	})
	if _child_1 then
		if _child_1.elements ~= nil or _child_1.props ~= nil and _child_1.component ~= nil then
			_children[_length + 1] = _child_1
		else
			for _k, _v in ipairs(_child_1) do
				_children[_length + _k] = _v
			end
		end
	end
	_length = #_children
	local _child_2 = isScriptsVisible and Roact.createFragment({
		scripts = Roact.createElement(Scripts),
	})
	if _child_2 then
		if _child_2.elements ~= nil or _child_2.props ~= nil and _child_2.component ~= nil then
			_children[_length + 1] = _child_2
		else
			for _k, _v in ipairs(_child_2) do
				_children[_length + _k] = _v
			end
		end
	end
	_length = #_children
	local _child_3 = currentPage == DashboardPage.Options and Roact.createFragment({
		options = Roact.createElement(Options),
	})
	if _child_3 then
		if _child_3.elements ~= nil or _child_3.props ~= nil and _child_3.component ~= nil then
			_children[_length + 1] = _child_3
		else
			for _k, _v in ipairs(_child_3) do
				_children[_length + _k] = _v
			end
		end
	end
	_length = #_children
	local _child_4 = currentPage == DashboardPage.Misc and Roact.createFragment({
		misc = Roact.createElement(Misc),
	})
	if _child_4 then
		if _child_4.elements ~= nil or _child_4.props ~= nil and _child_4.component ~= nil then
			_children[_length + 1] = _child_4
		else
			for _k, _v in ipairs(_child_4) do
				_children[_length + _k] = _v
			end
		end
	end
	return Roact.createFragment(_children)
end
local default = hooked(Pages)
return {
	default = default,
}

        end)
    end)
    hMod("Scripts", "ModuleScript", "Havoc.views.Pages.Scripts", "Havoc.views.Pages", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Scripts").default
return exports

        end)
    end)
    hMod("Content", "ModuleScript", "Havoc.views.Pages.Scripts.Content", "Havoc.views.Pages.Scripts", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).hooked
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent, "components", "Canvas").default
local useScale = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-scale").useScale
local hex = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "color3").hex
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "udim2")
local px = _udim2.px
local scale = _udim2.scale
local HeaderCenter, HeaderTopLeft
local function Content(_param)
	local header = _param.header
	local body = _param.body
	local footer = _param.footer
	local scaleFactor = useScale()
	local _attributes = {
		padding = {
			top = scaleFactor:map(function(s)
				return s * 48
			end),
			left = scaleFactor:map(function(s)
				return s * 48
			end),
			bottom = scaleFactor:map(function(s)
				return s * 48
			end),
			right = scaleFactor:map(function(s)
				return s * 48
			end),
		},
	}
	local _children = {}
	local _length = #_children
	local _child = body == nil and Roact.createElement(HeaderCenter, {
		header = header,
		scaleFactor = scaleFactor,
	})
	if _child then
		if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then
			_children[_length + 1] = _child
		else
			for _k, _v in ipairs(_child) do
				_children[_length + _k] = _v
			end
		end
	end
	_length = #_children
	local _child_1 = body ~= nil and Roact.createElement(HeaderTopLeft, {
		header = header,
		scaleFactor = scaleFactor,
	})
	if _child_1 then
		if _child_1.elements ~= nil or _child_1.props ~= nil and _child_1.component ~= nil then
			_children[_length + 1] = _child_1
		else
			for _k, _v in ipairs(_child_1) do
				_children[_length + _k] = _v
			end
		end
	end
	_length = #_children
	local _child_2 = body ~= nil and (Roact.createElement("TextLabel", {
		Text = body,
		TextColor3 = hex("#FFFFFF"),
		Font = "GothamBlack",
		TextSize = 36,
		TextXAlignment = "Left",
		TextYAlignment = "Top",
		Size = scale(1, 70 / 416),
		Position = scaleFactor:map(function(s)
			return px(0, 110 * s)
		end),
		BackgroundTransparency = 1,
	}, {
		Roact.createElement("UIScale", {
			Scale = scaleFactor,
		}),
	}))
	if _child_2 then
		if _child_2.elements ~= nil or _child_2.props ~= nil and _child_2.component ~= nil then
			_children[_length + 1] = _child_2
		else
			for _k, _v in ipairs(_child_2) do
				_children[_length + _k] = _v
			end
		end
	end
	_length = #_children
	_children[_length + 1] = Roact.createElement("TextLabel", {
		Text = footer,
		TextColor3 = hex("#FFFFFF"),
		Font = "GothamBlack",
		TextSize = 18,
		TextXAlignment = "Center",
		TextYAlignment = "Bottom",
		AnchorPoint = Vector2.new(0.5, 1),
		Size = scale(1, 20 / 416),
		Position = scale(0.5, 1),
		BackgroundTransparency = 1,
	}, {
		Roact.createElement("UIScale", {
			Scale = scaleFactor,
		}),
	})
	return Roact.createElement(Canvas, _attributes, _children)
end
function HeaderTopLeft(props)
	return Roact.createElement("TextLabel", {
		Text = props.header,
		TextColor3 = hex("#FFFFFF"),
		Font = "GothamBlack",
		TextSize = 64,
		TextXAlignment = "Left",
		TextYAlignment = "Top",
		Size = scale(1, 70 / 416),
		BackgroundTransparency = 1,
	}, {
		Roact.createElement("UIScale", {
			Scale = props.scaleFactor,
		}),
	})
end
function HeaderCenter(props)
	return Roact.createElement("TextLabel", {
		Text = props.header,
		TextColor3 = hex("#FFFFFF"),
		Font = "GothamBlack",
		TextSize = 48,
		TextXAlignment = "Center",
		TextYAlignment = "Center",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = scale(1, 1),
		Position = scale(0.5, 0.5),
		BackgroundTransparency = 1,
	}, {
		Roact.createElement("UIScale", {
			Scale = props.scaleFactor,
		}),
	})
end
local default = hooked(Content)
return {
	default = default,
}

        end)
    end)
    hMod("ScriptCard", "ModuleScript", "Havoc.views.Pages.Scripts.ScriptCard", "Havoc.views.Pages.Scripts", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local hooked = _roact_hooked.hooked
local useEffect = _roact_hooked.useEffect
local Border = TS.import(script, script.Parent.Parent.Parent.Parent, "components", "Border").default
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent, "components", "Canvas").default
local Fill = TS.import(script, script.Parent.Parent.Parent.Parent, "components", "Fill").default
local ParallaxImage = TS.import(script, script.Parent.Parent.Parent.Parent, "components", "ParallaxImage").default
local useDelayedUpdate = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "common", "use-delayed-update").useDelayedUpdate
local useIsMount = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "common", "use-did-mount").useIsMount
local useForcedUpdate = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "common", "use-forced-update").useForcedUpdate
local useSetState = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "common", "use-set-state").default
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "common", "use-spring").useSpring
local useIsPageOpen = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-current-page").useIsPageOpen
local useParallaxOffset = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-parallax-offset").useParallaxOffset
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent, "store", "models", "dashboard.model").DashboardPage
local hex = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "color3").hex
local scale = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "udim2").scale
local shineSpringOptions = {
	dampingRatio = 3,
	frequency = 2,
}
local function ScriptCard(_param)
	local index = _param.index
	local backgroundImage = _param.backgroundImage
	local backgroundImageSize = _param.backgroundImageSize
	local dropshadow = _param.dropshadow
	local dropshadowSize = _param.dropshadowSize
	local dropshadowPosition = _param.dropshadowPosition
	local anchorPoint = _param.anchorPoint
	local size = _param.size
	local position = _param.position
	local onActivate = _param.onActivate
	local children = _param[Roact.Children]
	local rerender = useForcedUpdate()
	local isCurrentlyOpen = useIsPageOpen(DashboardPage.Scripts)
	local _result
	if useIsMount() then
		_result = false
	else
		_result = isCurrentlyOpen
	end
	local isOpen = _result
	local isTransitioning = useDelayedUpdate(isOpen, index * 30)
	useEffect(function()
		return rerender()
	end, {})
	local offset = useParallaxOffset()
	local _binding = useSetState({
		isHovered = false,
		isPressed = false,
	})
	local _binding_1 = _binding[1]
	local isHovered = _binding_1.isHovered
	local isPressed = _binding_1.isPressed
	local setButtonState = _binding[2]
	local _attributes = {
		anchor = anchorPoint,
		size = size,
	}
	local _result_1
	if isTransitioning then
		_result_1 = position
	else
		local _uDim2 = UDim2.new(0, 0, 1, 48 * 3 + 56)
		_result_1 = position + _uDim2
	end
	_attributes.position = useSpring(_result_1, {
		frequency = 2.2,
		dampingRatio = 0.75,
	})
	local _children = {}
	local _length = #_children
	local _attributes_1 = {
		anchor = Vector2.new(0.5, 0.5),
		size = useSpring(isHovered and not isPressed and UDim2.new(1, 48, 1, 48) or scale(1, 1), {
			frequency = 2,
		}),
		position = scale(0.5, 0.5),
	}
	local _children_1 = {
		Roact.createElement("ImageLabel", {
			Image = dropshadow,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = scale(dropshadowSize.X, dropshadowSize.Y),
			Position = scale(dropshadowPosition.X, dropshadowPosition.Y),
			BackgroundTransparency = 1,
		}),
		Roact.createElement(ParallaxImage, {
			image = backgroundImage,
			imageSize = backgroundImageSize,
			padding = Vector2.new(50, 50),
			offset = offset,
		}, {
			Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 16),
			}),
		}),
	}
	local _length_1 = #_children_1
	local _attributes_2 = {
		clipsDescendants = true,
	}
	local _children_2 = {}
	local _length_2 = #_children_2
	if children then
		for _k, _v in pairs(children) do
			if type(_k) == "number" then
				_children_2[_length_2 + _k] = _v
			else
				_children_2[_k] = _v
			end
		end
	end
	_children_1[_length_1 + 1] = Roact.createElement(Canvas, _attributes_2, _children_2)
	_children_1[_length_1 + 2] = Roact.createElement(Fill, {
		radius = 16,
		color = hex("#ffffff"),
		transparency = useSpring(isHovered and 0 or 1, shineSpringOptions),
	}, {
		Roact.createElement("UIGradient", {
			Transparency = NumberSequence.new(0.75, 1),
			Offset = useSpring(isHovered and Vector2.new(0, 0) or Vector2.new(-1, -1), shineSpringOptions),
			Rotation = 45,
		}),
	})
	_children_1[_length_1 + 3] = Roact.createElement(Border, {
		radius = 18,
		size = 3,
		color = hex("#ffffff"),
		transparency = useSpring(isHovered and 0 or 1, shineSpringOptions),
	}, {
		Roact.createElement("UIGradient", {
			Transparency = NumberSequence.new(0.7, 0.9),
			Offset = useSpring(isHovered and Vector2.new(0, 0) or Vector2.new(-1, -1), shineSpringOptions),
			Rotation = 45,
		}),
	})
	_children_1[_length_1 + 4] = Roact.createElement(Border, {
		color = hex("#ffffff"),
		radius = 16,
		transparency = useSpring(isHovered and 1 or 0.8, {}),
	})
	_children[_length + 1] = Roact.createElement(Canvas, _attributes_1, _children_1)
	_children[_length + 2] = Roact.createElement("TextButton", {
		[Roact.Event.Activated] = function()
			return onActivate()
		end,
		[Roact.Event.MouseEnter] = function()
			return setButtonState({
				isHovered = true,
			})
		end,
		[Roact.Event.MouseLeave] = function()
			return setButtonState({
				isHovered = false,
				isPressed = false,
			})
		end,
		[Roact.Event.MouseButton1Down] = function()
			return setButtonState({
				isPressed = true,
			})
		end,
		[Roact.Event.MouseButton1Up] = function()
			return setButtonState({
				isPressed = false,
			})
		end,
		Size = scale(1, 1),
		Text = "",
		Transparency = 1,
	})
	return Roact.createElement(Canvas, _attributes, _children)
end
local default = hooked(ScriptCard)
return {
	default = default,
}

        end)
    end)
    hMod("Scripts", "ModuleScript", "Havoc.views.Pages.Scripts.Scripts", "Havoc.views.Pages.Scripts", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local pure = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).pure
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent, "components", "Canvas").default
local http = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "http")
local scale = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "udim2").scale
local _constants = TS.import(script, script.Parent, "constants")
local BASE_PADDING = _constants.BASE_PADDING
local BASE_WINDOW_HEIGHT = _constants.BASE_WINDOW_HEIGHT
local Content = TS.import(script, script.Parent, "Content").default
local ScriptCard = TS.import(script, script.Parent, "ScriptCard").default
local runScriptFromUrl = TS.async(function(url, src)
	local _exitType, _returns = TS.try(function()
		local content = TS.await(http.get(url))
		local fn, err = loadstring(content, "@" .. src)
		local _arg1 = "Failed to call loadstring on Lua script from '" .. (url .. ("': " .. tostring(err)))
		assert(fn, _arg1)
		task.defer(fn)
	end, function(e)
		warn("Failed to run Lua script from '" .. (url .. ("': " .. tostring(e))))
		return TS.TRY_RETURN, { "" }
	end)
	if _exitType then
		return unpack(_returns)
	end
end)
local function Scripts()
	return Roact.createElement(Canvas, {
		position = scale(0, 1),
		anchor = Vector2.new(0, 1),
	}, {
		Roact.createElement(ScriptCard, {
			onActivate = function()
				return runScriptFromUrl("https://absent.wtf/AKADMIN.lua", "AKADMIN")
			end,
			index = 4,
			backgroundImage = "rbxassetid://84773916777698",
			backgroundImageSize = Vector2.new(1023, 682),
			dropshadow = "rbxassetid://8992292536",
			dropshadowSize = Vector2.new(1.15, 1.25),
			dropshadowPosition = Vector2.new(0.5, 0.55),
			anchorPoint = Vector2.new(0, 0),
			size = UDim2.new(1 / 3, -BASE_PADDING * (2 / 3), (416 + BASE_PADDING / 2) / BASE_WINDOW_HEIGHT, -BASE_PADDING / 2),
			position = scale(0, 0),
		}, {
			Roact.createElement(Content, {
				header = "AK ADMIN",
				body = "A universal script with 60k+ users!",
				footer = "absent.wtf",
			}),
		}),
		Roact.createElement(ScriptCard, {
			onActivate = function()
				return runScriptFromUrl("https://novoline.pro", "Novoline")
			end,
			index = 1,
			backgroundImage = "rbxassetid://127094516248328",
			backgroundImageSize = Vector2.new(1021, 1023),
			dropshadow = "rbxassetid://8992291993",
			dropshadowSize = Vector2.new(1.15, 1.25),
			dropshadowPosition = Vector2.new(0.5, 0.55),
			anchorPoint = Vector2.new(0, 1),
			size = UDim2.new(1 / 3, -BASE_PADDING * (2 / 3), (416 + BASE_PADDING / 2) / BASE_WINDOW_HEIGHT, -BASE_PADDING / 2),
			position = scale(0, 1),
		}, {
			Roact.createElement(Content, {
				header = "Novoline",
				body = "A universal script made by Gladius.",
				footer = "novoline.pro",
			}),
		}),
		Roact.createElement(ScriptCard, {
			onActivate = function()
				return runScriptFromUrl("https://onyxv2.lol/main.lua", "ONYX")
			end,
			index = 5,
			backgroundImage = "rbxassetid://8992291779",
			backgroundImageSize = Vector2.new(818, 1023),
			dropshadow = "rbxassetid://8992291581",
			dropshadowSize = Vector2.new(1.15, 1.4),
			dropshadowPosition = Vector2.new(0.5, 0.6),
			anchorPoint = Vector2.new(0.5, 0),
			size = UDim2.new(1 / 3, -BASE_PADDING * (2 / 3), (242 + BASE_PADDING / 2) / BASE_WINDOW_HEIGHT, -BASE_PADDING / 2),
			position = scale(0.5, 0),
		}, {
			Roact.createElement(Content, {
				header = "ONYX",
				footer = "Made by Biscit",
			}),
		}),
		Roact.createElement(ScriptCard, {
			onActivate = function()
				return runScriptFromUrl("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", "Infinite Yield")
			end,
			index = 3,
			backgroundImage = "rbxassetid://8992291444",
			backgroundImageSize = Vector2.new(1023, 682),
			dropshadow = "rbxassetid://8992291268",
			dropshadowSize = Vector2.new(1.15, 1.4),
			dropshadowPosition = Vector2.new(0.5, 0.6),
			anchorPoint = Vector2.new(0.5, 0),
			size = UDim2.new(1 / 3, -BASE_PADDING * (2 / 3), (242 + BASE_PADDING) / BASE_WINDOW_HEIGHT, -BASE_PADDING),
			position = UDim2.new(0.5, 0, 1 - (590 + BASE_PADDING / 2) / BASE_WINDOW_HEIGHT, BASE_PADDING / 2),
		}, {
			Roact.createElement(Content, {
				header = "Infinite Yield",
				footer = "github.com/EdgeIY",
			}),
		}),
		Roact.createElement(ScriptCard, {
			onActivate = function()
				return runScriptFromUrl("https://pastebin.com/raw/mMbsHWiQ", "Dex Explorer")
			end,
			index = 1,
			backgroundImage = "rbxassetid://8992290931",
			backgroundImageSize = Vector2.new(818, 1023),
			dropshadow = "rbxassetid://8992291101",
			dropshadowSize = Vector2.new(1.15, 1.35),
			dropshadowPosition = Vector2.new(0.5, 0.55),
			anchorPoint = Vector2.new(0.5, 1),
			size = UDim2.new(1 / 3, -BASE_PADDING * (2 / 3), (300 + BASE_PADDING / 2) / BASE_WINDOW_HEIGHT, -BASE_PADDING / 2),
			position = scale(0.5, 1),
		}, {
			Roact.createElement(Content, {
				header = "Dex Explorer",
				footer = "github.com/LorekeeperZinnia",
			}),
		}),
		Roact.createElement(ScriptCard, {
			onActivate = function()
				return runScriptFromUrl("https://raw.githubusercontent.com/ic3w0lf22/Unnamed-ESP/master/UnnamedESP.lua", "Unnamed ESP")
			end,
			index = 6,
			backgroundImage = "rbxassetid://8992290714",
			backgroundImageSize = Vector2.new(1023, 682),
			dropshadow = "rbxassetid://8992290570",
			dropshadowSize = Vector2.new(1.15, 1.35),
			dropshadowPosition = Vector2.new(0.5, 0.55),
			anchorPoint = Vector2.new(1, 0),
			size = UDim2.new(1 / 3, -BASE_PADDING * (2 / 3), (300 + BASE_PADDING / 2) / BASE_WINDOW_HEIGHT, -BASE_PADDING / 2),
			position = scale(1, 0),
		}, {
			Roact.createElement(Content, {
				header = "Unnamed ESP",
				footer = "github.com/ic3w0lf22",
			}),
		}),
		Roact.createElement(ScriptCard, {
			onActivate = function()
				return runScriptFromUrl("https://projectevo.xyz/script/loader.lua", "EvoV2")
			end,
			index = 2,
			backgroundImage = "rbxassetid://8992290314",
			backgroundImageSize = Vector2.new(682, 1023),
			dropshadow = "rbxassetid://8992290105",
			dropshadowSize = Vector2.new(1.15, 1.22),
			dropshadowPosition = Vector2.new(0.5, 0.53),
			anchorPoint = Vector2.new(1, 1),
			size = UDim2.new(1 / 3, -BASE_PADDING * (2 / 3), (532 + BASE_PADDING / 2) / BASE_WINDOW_HEIGHT, -BASE_PADDING / 2),
			position = scale(1, 1),
		}, {
			Roact.createElement(Content, {
				header = "EvoV2",
				body = "Reliable cheats for\nRoblox's top shooter\ngames, reimagined.",
				footer = "projectevo.xyz",
			}),
		}),
	})
end
local default = pure(Scripts)
return {
	default = default,
}

        end)
    end)
    hMod("constants", "ModuleScript", "Havoc.views.Pages.Scripts.constants", "Havoc.views.Pages.Scripts", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local BASE_WINDOW_HEIGHT = 880
local BASE_WINDOW_WIDTH = 1824
local BASE_PADDING = 48
return {
	BASE_WINDOW_HEIGHT = BASE_WINDOW_HEIGHT,
	BASE_WINDOW_WIDTH = BASE_WINDOW_WIDTH,
	BASE_PADDING = BASE_PADDING,
}

        end)
    end)
    hInst("include", "Folder", "Havoc.include", "Havoc")
    hMod("Promise", "ModuleScript", "Havoc.include.Promise", "Havoc.include", function()
        return (function(...)
--[[
	An implementation of Promises similar to Promise/A+.
] ]

local ERROR_NON_PROMISE_IN_LIST = "Non-promise value passed into %s at index %s"
local ERROR_NON_LIST = "Please pass a list of promises to %s"
local ERROR_NON_FUNCTION = "Please pass a handler function to %s!"
local MODE_KEY_METATABLE = {__mode = "k"}

--[[
	Creates an enum dictionary with some metamethods to prevent common mistakes.
] ]
local function makeEnum(enumName, members)
	local enum = {}

	for _, memberName in ipairs(members) do
		enum[memberName] = memberName
	end

	return setmetatable(enum, {
		__index = function(_, k)
			error(string.format("%s is not in %s!", k, enumName), 2)
		end,
		__newindex = function()
			error(string.format("Creating new members in %s is not allowed!", enumName), 2)
		end,
	})
end

--[[
	An object to represent runtime errors that occur during execution.
	Promises that experience an error like this will be rejected with
	an instance of this object.
] ]
local Error do
	Error = {
		Kind = makeEnum("Promise.Error.Kind", {
			"ExecutionError",
			"AlreadyCancelled",
			"NotResolvedInTime",
			"TimedOut",
		}),
	}
	Error.__index = Error

	function Error.new(options, parent)
		options = options or {}
		return setmetatable({
			error = tostring(options.error) or "[This error has no error text.]",
			trace = options.trace,
			context = options.context,
			kind = options.kind,
			parent = parent,
			createdTick = os.clock(),
			createdTrace = debug.traceback(),
		}, Error)
	end

	function Error.is(anything)
		if type(anything) == "table" then
			local metatable = getmetatable(anything)

			if type(metatable) == "table" then
				return rawget(anything, "error") ~= nil and type(rawget(metatable, "extend")) == "function"
			end
		end

		return false
	end

	function Error.isKind(anything, kind)
		assert(kind ~= nil, "Argument #2 to Promise.Error.isKind must not be nil")

		return Error.is(anything) and anything.kind == kind
	end

	function Error:extend(options)
		options = options or {}

		options.kind = options.kind or self.kind

		return Error.new(options, self)
	end

	function Error:getErrorChain()
		local runtimeErrors = { self }

		while runtimeErrors[#runtimeErrors].parent do
			table.insert(runtimeErrors, runtimeErrors[#runtimeErrors].parent)
		end

		return runtimeErrors
	end

	function Error:__tostring()
		local errorStrings = {
			string.format("-- Promise.Error(%s) --", self.kind or "?"),
		}

		for _, runtimeError in ipairs(self:getErrorChain()) do
			table.insert(errorStrings, table.concat({
				runtimeError.trace or runtimeError.error,
				runtimeError.context,
			}, "\n"))
		end

		return table.concat(errorStrings, "\n")
	end
end

--[[
	Packs a number of arguments into a table and returns its length.

	Used to cajole varargs without dropping sparse values.
] ]
local function pack(...)
	return select("#", ...), { ... }
end

--[[
	Returns first value (success), and packs all following values.
] ]
local function packResult(success, ...)
	return success, select("#", ...), { ... }
end


local function makeErrorHandler(traceback)
	assert(traceback ~= nil)

	return function(err)
		-- If the error object is already a table, forward it directly.
		-- Should we extend the error here and add our own trace?

		if type(err) == "table" then
			return err
		end

		return Error.new({
			error = err,
			kind = Error.Kind.ExecutionError,
			trace = debug.traceback(tostring(err), 2),
			context = "Promise created at:\n\n" .. traceback,
		})
	end
end

--[[
	Calls a Promise executor with error handling.
] ]
local function runExecutor(traceback, callback, ...)
	return packResult(xpcall(callback, makeErrorHandler(traceback), ...))
end

--[[
	Creates a function that invokes a callback with correct error handling and
	resolution mechanisms.
] ]
local function createAdvancer(traceback, callback, resolve, reject)
	return function(...)
		local ok, resultLength, result = runExecutor(traceback, callback, ...)

		if ok then
			resolve(unpack(result, 1, resultLength))
		else
			reject(result[1])
		end
	end
end

local function isEmpty(t)
	return next(t) == nil
end

local Promise = {
	Error = Error,
	Status = makeEnum("Promise.Status", {"Started", "Resolved", "Rejected", "Cancelled"}),
	_getTime = os.clock,
	_timeEvent = game:GetService("RunService").Heartbeat,
}
Promise.prototype = {}
Promise.__index = Promise.prototype

--[[
	Constructs a new Promise with the given initializing callback.

	This is generally only called when directly wrapping a non-promise API into
	a promise-based version.

	The callback will receive 'resolve' and 'reject' methods, used to start
	invoking the promise chain.

	Second parameter, parent, is used internally for tracking the "parent" in a
	promise chain. External code shouldn't need to worry about this.
] ]
function Promise._new(traceback, callback, parent)
	if parent ~= nil and not Promise.is(parent) then
		error("Argument #2 to Promise.new must be a promise or nil", 2)
	end

	local self = {
		-- Used to locate where a promise was created
		_source = traceback,

		_status = Promise.Status.Started,

		-- A table containing a list of all results, whether success or failure.
		-- Only valid if _status is set to something besides Started
		_values = nil,

		-- Lua doesn't like sparse arrays very much, so we explicitly store the
		-- length of _values to handle middle nils.
		_valuesLength = -1,

		-- Tracks if this Promise has no error observers..
		_unhandledRejection = true,

		-- Queues representing functions we should invoke when we update!
		_queuedResolve = {},
		_queuedReject = {},
		_queuedFinally = {},

		-- The function to run when/if this promise is cancelled.
		_cancellationHook = nil,

		-- The "parent" of this promise in a promise chain. Required for
		-- cancellation propagation upstream.
		_parent = parent,

		-- Consumers are Promises that have chained onto this one.
		-- We track them for cancellation propagation downstream.
		_consumers = setmetatable({}, MODE_KEY_METATABLE),
	}

	if parent and parent._status == Promise.Status.Started then
		parent._consumers[self] = true
	end

	setmetatable(self, Promise)

	local function resolve(...)
		self:_resolve(...)
	end

	local function reject(...)
		self:_reject(...)
	end

	local function onCancel(cancellationHook)
		if cancellationHook then
			if self._status == Promise.Status.Cancelled then
				cancellationHook()
			else
				self._cancellationHook = cancellationHook
			end
		end

		return self._status == Promise.Status.Cancelled
	end

	coroutine.wrap(function()
		local ok, _, result = runExecutor(
			self._source,
			callback,
			resolve,
			reject,
			onCancel
		)

		if not ok then
			reject(result[1])
		end
	end)()

	return self
end

function Promise.new(executor)
	return Promise._new(debug.traceback(nil, 2), executor)
end

function Promise:__tostring()
	return string.format("Promise(%s)", self:getStatus())
end

--[[
	Promise.new, except pcall on a new thread is automatic.
] ]
function Promise.defer(callback)
	local traceback = debug.traceback(nil, 2)
	local promise
	promise = Promise._new(traceback, function(resolve, reject, onCancel)
		local connection
		connection = Promise._timeEvent:Connect(function()
			connection:Disconnect()
			local ok, _, result = runExecutor(traceback, callback, resolve, reject, onCancel)

			if not ok then
				reject(result[1])
			end
		end)
	end)

	return promise
end

-- Backwards compatibility
Promise.async = Promise.defer

--[[
	Create a promise that represents the immediately resolved value.
] ]
function Promise.resolve(...)
	local length, values = pack(...)
	return Promise._new(debug.traceback(nil, 2), function(resolve)
		resolve(unpack(values, 1, length))
	end)
end

--[[
	Create a promise that represents the immediately rejected value.
] ]
function Promise.reject(...)
	local length, values = pack(...)
	return Promise._new(debug.traceback(nil, 2), function(_, reject)
		reject(unpack(values, 1, length))
	end)
end

--[[
	Runs a non-promise-returning function as a Promise with the
  given arguments.
] ]
function Promise._try(traceback, callback, ...)
	local valuesLength, values = pack(...)

	return Promise._new(traceback, function(resolve)
		resolve(callback(unpack(values, 1, valuesLength)))
	end)
end

--[[
	Begins a Promise chain, turning synchronous errors into rejections.
] ]
function Promise.try(...)
	return Promise._try(debug.traceback(nil, 2), ...)
end

--[[
	Returns a new promise that:
		* is resolved when all input promises resolve
		* is rejected if ANY input promises reject
] ]
function Promise._all(traceback, promises, amount)
	if type(promises) ~= "table" then
		error(string.format(ERROR_NON_LIST, "Promise.all"), 3)
	end

	-- We need to check that each value is a promise here so that we can produce
	-- a proper error rather than a rejected promise with our error.
	for i, promise in pairs(promises) do
		if not Promise.is(promise) then
			error(string.format(ERROR_NON_PROMISE_IN_LIST, "Promise.all", tostring(i)), 3)
		end
	end

	-- If there are no values then return an already resolved promise.
	if #promises == 0 or amount == 0 then
		return Promise.resolve({})
	end

	return Promise._new(traceback, function(resolve, reject, onCancel)
		-- An array to contain our resolved values from the given promises.
		local resolvedValues = {}
		local newPromises = {}

		-- Keep a count of resolved promises because just checking the resolved
		-- values length wouldn't account for promises that resolve with nil.
		local resolvedCount = 0
		local rejectedCount = 0
		local done = false

		local function cancel()
			for _, promise in ipairs(newPromises) do
				promise:cancel()
			end
		end

		-- Called when a single value is resolved and resolves if all are done.
		local function resolveOne(i, ...)
			if done then
				return
			end

			resolvedCount = resolvedCount + 1

			if amount == nil then
				resolvedValues[i] = ...
			else
				resolvedValues[resolvedCount] = ...
			end

			if resolvedCount >= (amount or #promises) then
				done = true
				resolve(resolvedValues)
				cancel()
			end
		end

		onCancel(cancel)

		-- We can assume the values inside `promises` are all promises since we
		-- checked above.
		for i, promise in ipairs(promises) do
			newPromises[i] = promise:andThen(
				function(...)
					resolveOne(i, ...)
				end,
				function(...)
					rejectedCount = rejectedCount + 1

					if amount == nil or #promises - rejectedCount < amount then
						cancel()
						done = true

						reject(...)
					end
				end
			)
		end

		if done then
			cancel()
		end
	end)
end

function Promise.all(promises)
	return Promise._all(debug.traceback(nil, 2), promises)
end

function Promise.fold(list, callback, initialValue)
	assert(type(list) == "table", "Bad argument #1 to Promise.fold: must be a table")
	assert(type(callback) == "function", "Bad argument #2 to Promise.fold: must be a function")

	local accumulator = Promise.resolve(initialValue)
	return Promise.each(list, function(resolvedElement, i)
		accumulator = accumulator:andThen(function(previousValueResolved)
			return callback(previousValueResolved, resolvedElement, i)
		end)
	end):andThenReturn(accumulator)
end

function Promise.some(promises, amount)
	assert(type(amount) == "number", "Bad argument #2 to Promise.some: must be a number")

	return Promise._all(debug.traceback(nil, 2), promises, amount)
end

function Promise.any(promises)
	return Promise._all(debug.traceback(nil, 2), promises, 1):andThen(function(values)
		return values[1]
	end)
end

function Promise.allSettled(promises)
	if type(promises) ~= "table" then
		error(string.format(ERROR_NON_LIST, "Promise.allSettled"), 2)
	end

	-- We need to check that each value is a promise here so that we can produce
	-- a proper error rather than a rejected promise with our error.
	for i, promise in pairs(promises) do
		if not Promise.is(promise) then
			error(string.format(ERROR_NON_PROMISE_IN_LIST, "Promise.allSettled", tostring(i)), 2)
		end
	end

	-- If there are no values then return an already resolved promise.
	if #promises == 0 then
		return Promise.resolve({})
	end

	return Promise._new(debug.traceback(nil, 2), function(resolve, _, onCancel)
		-- An array to contain our resolved values from the given promises.
		local fates = {}
		local newPromises = {}

		-- Keep a count of resolved promises because just checking the resolved
		-- values length wouldn't account for promises that resolve with nil.
		local finishedCount = 0

		-- Called when a single value is resolved and resolves if all are done.
		local function resolveOne(i, ...)
			finishedCount = finishedCount + 1

			fates[i] = ...

			if finishedCount >= #promises then
				resolve(fates)
			end
		end

		onCancel(function()
			for _, promise in ipairs(newPromises) do
				promise:cancel()
			end
		end)

		-- We can assume the values inside `promises` are all promises since we
		-- checked above.
		for i, promise in ipairs(promises) do
			newPromises[i] = promise:finally(
				function(...)
					resolveOne(i, ...)
				end
			)
		end
	end)
end

--[[
	Races a set of Promises and returns the first one that resolves,
	cancelling the others.
] ]
function Promise.race(promises)
	assert(type(promises) == "table", string.format(ERROR_NON_LIST, "Promise.race"))

	for i, promise in pairs(promises) do
		assert(Promise.is(promise), string.format(ERROR_NON_PROMISE_IN_LIST, "Promise.race", tostring(i)))
	end

	return Promise._new(debug.traceback(nil, 2), function(resolve, reject, onCancel)
		local newPromises = {}
		local finished = false

		local function cancel()
			for _, promise in ipairs(newPromises) do
				promise:cancel()
			end
		end

		local function finalize(callback)
			return function (...)
				cancel()
				finished = true
				return callback(...)
			end
		end

		if onCancel(finalize(reject)) then
			return
		end

		for i, promise in ipairs(promises) do
			newPromises[i] = promise:andThen(finalize(resolve), finalize(reject))
		end

		if finished then
			cancel()
		end
	end)
end

--[[
	Iterates serially over the given an array of values, calling the predicate callback on each before continuing.
	If the predicate returns a Promise, we wait for that Promise to resolve before continuing to the next item
	in the array. If the Promise the predicate returns rejects, the Promise from Promise.each is also rejected with
	the same value.

	Returns a Promise containing an array of the return values from the predicate for each item in the original list.
] ]
function Promise.each(list, predicate)
	assert(type(list) == "table", string.format(ERROR_NON_LIST, "Promise.each"))
	assert(type(predicate) == "function", string.format(ERROR_NON_FUNCTION, "Promise.each"))

	return Promise._new(debug.traceback(nil, 2), function(resolve, reject, onCancel)
		local results = {}
		local promisesToCancel = {}

		local cancelled = false

		local function cancel()
			for _, promiseToCancel in ipairs(promisesToCancel) do
				promiseToCancel:cancel()
			end
		end

		onCancel(function()
			cancelled = true

			cancel()
		end)

		-- We need to preprocess the list of values and look for Promises.
		-- If we find some, we must register our andThen calls now, so that those Promises have a consumer
		-- from us registered. If we don't do this, those Promises might get cancelled by something else
		-- before we get to them in the series because it's not possible to tell that we plan to use it
		-- unless we indicate it here.

		local preprocessedList = {}

		for index, value in ipairs(list) do
			if Promise.is(value) then
				if value:getStatus() == Promise.Status.Cancelled then
					cancel()
					return reject(Error.new({
						error = "Promise is cancelled",
						kind = Error.Kind.AlreadyCancelled,
						context = string.format(
							"The Promise that was part of the array at index %d passed into Promise.each was already cancelled when Promise.each began.\n\nThat Promise was created at:\n\n%s",
							index,
							value._source
						),
					}))
				elseif value:getStatus() == Promise.Status.Rejected then
					cancel()
					return reject(select(2, value:await()))
				end

				-- Chain a new Promise from this one so we only cancel ours
				local ourPromise = value:andThen(function(...)
					return ...
				end)

				table.insert(promisesToCancel, ourPromise)
				preprocessedList[index] = ourPromise
			else
				preprocessedList[index] = value
			end
		end

		for index, value in ipairs(preprocessedList) do
			if Promise.is(value) then
				local success
				success, value = value:await()

				if not success then
					cancel()
					return reject(value)
				end
			end

			if cancelled then
				return
			end

			local predicatePromise = Promise.resolve(predicate(value, index))

			table.insert(promisesToCancel, predicatePromise)

			local success, result = predicatePromise:await()

			if not success then
				cancel()
				return reject(result)
			end

			results[index] = result
		end

		resolve(results)
	end)
end

--[[
	Is the given object a Promise instance?
] ]
function Promise.is(object)
	if type(object) ~= "table" then
		return false
	end

	local objectMetatable = getmetatable(object)

	if objectMetatable == Promise then
		-- The Promise came from this library.
		return true
	elseif objectMetatable == nil then
		-- No metatable, but we should still chain onto tables with andThen methods
		return type(object.andThen) == "function"
	elseif
		type(objectMetatable) == "table"
		and type(rawget(objectMetatable, "__index")) == "table"
		and type(rawget(rawget(objectMetatable, "__index"), "andThen")) == "function"
	then
		-- Maybe this came from a different or older Promise library.
		return true
	end

	return false
end

--[[
	Converts a yielding function into a Promise-returning one.
] ]
function Promise.promisify(callback)
	return function(...)
		return Promise._try(debug.traceback(nil, 2), callback, ...)
	end
end

--[[
	Creates a Promise that resolves after given number of seconds.
] ]
do
	-- uses a sorted doubly linked list (queue) to achieve O(1) remove operations and O(n) for insert

	-- the initial node in the linked list
	local first
	local connection

	function Promise.delay(seconds)
		assert(type(seconds) == "number", "Bad argument #1 to Promise.delay, must be a number.")
		-- If seconds is -INF, INF, NaN, or less than 1 / 60, assume seconds is 1 / 60.
		-- This mirrors the behavior of wait()
		if not (seconds >= 1 / 60) or seconds == math.huge then
			seconds = 1 / 60
		end

		return Promise._new(debug.traceback(nil, 2), function(resolve, _, onCancel)
			local startTime = Promise._getTime()
			local endTime = startTime + seconds

			local node = {
				resolve = resolve,
				startTime = startTime,
				endTime = endTime,
			}

			if connection == nil then -- first is nil when connection is nil
				first = node
				connection = Promise._timeEvent:Connect(function()
					local threadStart = Promise._getTime()

					while first ~= nil and first.endTime < threadStart do
						local current = first
						first = current.next

						if first == nil then
							connection:Disconnect()
							connection = nil
						else
							first.previous = nil
						end

						current.resolve(Promise._getTime() - current.startTime)
					end
				end)
			else -- first is non-nil
				if first.endTime < endTime then -- if `node` should be placed after `first`
					-- we will insert `node` between `current` and `next`
					-- (i.e. after `current` if `next` is nil)
					local current = first
					local next = current.next

					while next ~= nil and next.endTime < endTime do
						current = next
						next = current.next
					end

					-- `current` must be non-nil, but `next` could be `nil` (i.e. last item in list)
					current.next = node
					node.previous = current

					if next ~= nil then
						node.next = next
						next.previous = node
					end
				else
					-- set `node` to `first`
					node.next = first
					first.previous = node
					first = node
				end
			end

			onCancel(function()
				-- remove node from queue
				local next = node.next

				if first == node then
					if next == nil then -- if `node` is the first and last
						connection:Disconnect()
						connection = nil
					else -- if `node` is `first` and not the last
						next.previous = nil
					end
					first = next
				else
					local previous = node.previous
					-- since `node` is not `first`, then we know `previous` is non-nil
					previous.next = next

					if next ~= nil then
						next.previous = previous
					end
				end
			end)
		end)
	end
end

--[[
	Rejects the promise after `seconds` seconds.
] ]
function Promise.prototype:timeout(seconds, rejectionValue)
	local traceback = debug.traceback(nil, 2)

	return Promise.race({
		Promise.delay(seconds):andThen(function()
			return Promise.reject(rejectionValue == nil and Error.new({
				kind = Error.Kind.TimedOut,
				error = "Timed out",
				context = string.format(
					"Timeout of %d seconds exceeded.\n:timeout() called at:\n\n%s",
					seconds,
					traceback
				),
			}) or rejectionValue)
		end),
		self,
	})
end

function Promise.prototype:getStatus()
	return self._status
end

--[[
	Creates a new promise that receives the result of this promise.

	The given callbacks are invoked depending on that result.
] ]
function Promise.prototype:_andThen(traceback, successHandler, failureHandler)
	self._unhandledRejection = false

	-- Create a new promise to follow this part of the chain
	return Promise._new(traceback, function(resolve, reject)
		-- Our default callbacks just pass values onto the next promise.
		-- This lets success and failure cascade correctly!

		local successCallback = resolve
		if successHandler then
			successCallback = createAdvancer(
				traceback,
				successHandler,
				resolve,
				reject
			)
		end

		local failureCallback = reject
		if failureHandler then
			failureCallback = createAdvancer(
				traceback,
				failureHandler,
				resolve,
				reject
			)
		end

		if self._status == Promise.Status.Started then
			-- If we haven't resolved yet, put ourselves into the queue
			table.insert(self._queuedResolve, successCallback)
			table.insert(self._queuedReject, failureCallback)
		elseif self._status == Promise.Status.Resolved then
			-- This promise has already resolved! Trigger success immediately.
			successCallback(unpack(self._values, 1, self._valuesLength))
		elseif self._status == Promise.Status.Rejected then
			-- This promise died a terrible death! Trigger failure immediately.
			failureCallback(unpack(self._values, 1, self._valuesLength))
		elseif self._status == Promise.Status.Cancelled then
			-- We don't want to call the success handler or the failure handler,
			-- we just reject this promise outright.
			reject(Error.new({
				error = "Promise is cancelled",
				kind = Error.Kind.AlreadyCancelled,
				context = "Promise created at\n\n" .. traceback,
			}))
		end
	end, self)
end

function Promise.prototype:andThen(successHandler, failureHandler)
	assert(
		successHandler == nil or type(successHandler) == "function",
		string.format(ERROR_NON_FUNCTION, "Promise:andThen")
	)
	assert(
		failureHandler == nil or type(failureHandler) == "function",
		string.format(ERROR_NON_FUNCTION, "Promise:andThen")
	)

	return self:_andThen(debug.traceback(nil, 2), successHandler, failureHandler)
end

--[[
	Used to catch any errors that may have occurred in the promise.
] ]
function Promise.prototype:catch(failureCallback)
	assert(
		failureCallback == nil or type(failureCallback) == "function",
		string.format(ERROR_NON_FUNCTION, "Promise:catch")
	)
	return self:_andThen(debug.traceback(nil, 2), nil, failureCallback)
end

--[[
	Like andThen, but the value passed into the handler is also the
	value returned from the handler.
] ]
function Promise.prototype:tap(tapCallback)
	assert(type(tapCallback) == "function", string.format(ERROR_NON_FUNCTION, "Promise:tap"))
	return self:_andThen(debug.traceback(nil, 2), function(...)
		local callbackReturn = tapCallback(...)

		if Promise.is(callbackReturn) then
			local length, values = pack(...)
			return callbackReturn:andThen(function()
				return unpack(values, 1, length)
			end)
		end

		return ...
	end)
end

--[[
	Calls a callback on `andThen` with specific arguments.
] ]
function Promise.prototype:andThenCall(callback, ...)
	assert(type(callback) == "function", string.format(ERROR_NON_FUNCTION, "Promise:andThenCall"))
	local length, values = pack(...)
	return self:_andThen(debug.traceback(nil, 2), function()
		return callback(unpack(values, 1, length))
	end)
end

--[[
	Shorthand for an andThen handler that returns the given value.
] ]
function Promise.prototype:andThenReturn(...)
	local length, values = pack(...)
	return self:_andThen(debug.traceback(nil, 2), function()
		return unpack(values, 1, length)
	end)
end

--[[
	Cancels the promise, disallowing it from rejecting or resolving, and calls
	the cancellation hook if provided.
] ]
function Promise.prototype:cancel()
	if self._status ~= Promise.Status.Started then
		return
	end

	self._status = Promise.Status.Cancelled

	if self._cancellationHook then
		self._cancellationHook()
	end

	if self._parent then
		self._parent:_consumerCancelled(self)
	end

	for child in pairs(self._consumers) do
		child:cancel()
	end

	self:_finalize()
end

--[[
	Used to decrease the number of consumers by 1, and if there are no more,
	cancel this promise.
] ]
function Promise.prototype:_consumerCancelled(consumer)
	if self._status ~= Promise.Status.Started then
		return
	end

	self._consumers[consumer] = nil

	if next(self._consumers) == nil then
		self:cancel()
	end
end

--[[
	Used to set a handler for when the promise resolves, rejects, or is
	cancelled. Returns a new promise chained from this promise.
] ]
function Promise.prototype:_finally(traceback, finallyHandler, onlyOk)
	if not onlyOk then
		self._unhandledRejection = false
	end

	-- Return a promise chained off of this promise
	return Promise._new(traceback, function(resolve, reject)
		local finallyCallback = resolve
		if finallyHandler then
			finallyCallback = createAdvancer(
				traceback,
				finallyHandler,
				resolve,
				reject
			)
		end

		if onlyOk then
			local callback = finallyCallback
			finallyCallback = function(...)
				if self._status == Promise.Status.Rejected then
					return resolve(self)
				end

				return callback(...)
			end
		end

		if self._status == Promise.Status.Started then
			-- The promise is not settled, so queue this.
			table.insert(self._queuedFinally, finallyCallback)
		else
			-- The promise already settled or was cancelled, run the callback now.
			finallyCallback(self._status)
		end
	end, self)
end

function Promise.prototype:finally(finallyHandler)
	assert(
		finallyHandler == nil or type(finallyHandler) == "function",
		string.format(ERROR_NON_FUNCTION, "Promise:finally")
	)
	return self:_finally(debug.traceback(nil, 2), finallyHandler)
end

--[[
	Calls a callback on `finally` with specific arguments.
] ]
function Promise.prototype:finallyCall(callback, ...)
	assert(type(callback) == "function", string.format(ERROR_NON_FUNCTION, "Promise:finallyCall"))
	local length, values = pack(...)
	return self:_finally(debug.traceback(nil, 2), function()
		return callback(unpack(values, 1, length))
	end)
end

--[[
	Shorthand for a finally handler that returns the given value.
] ]
function Promise.prototype:finallyReturn(...)
	local length, values = pack(...)
	return self:_finally(debug.traceback(nil, 2), function()
		return unpack(values, 1, length)
	end)
end

--[[
	Similar to finally, except rejections are propagated through it.
] ]
function Promise.prototype:done(finallyHandler)
	assert(
		finallyHandler == nil or type(finallyHandler) == "function",
		string.format(ERROR_NON_FUNCTION, "Promise:done")
	)
	return self:_finally(debug.traceback(nil, 2), finallyHandler, true)
end

--[[
	Calls a callback on `done` with specific arguments.
] ]
function Promise.prototype:doneCall(callback, ...)
	assert(type(callback) == "function", string.format(ERROR_NON_FUNCTION, "Promise:doneCall"))
	local length, values = pack(...)
	return self:_finally(debug.traceback(nil, 2), function()
		return callback(unpack(values, 1, length))
	end, true)
end

--[[
	Shorthand for a done handler that returns the given value.
] ]
function Promise.prototype:doneReturn(...)
	local length, values = pack(...)
	return self:_finally(debug.traceback(nil, 2), function()
		return unpack(values, 1, length)
	end, true)
end

--[[
	Yield until the promise is completed.

	This matches the execution model of normal Roblox functions.
] ]
function Promise.prototype:awaitStatus()
	self._unhandledRejection = false

	if self._status == Promise.Status.Started then
		local bindable = Instance.new("BindableEvent")

		self:finally(function()
			bindable:Fire()
		end)

		bindable.Event:Wait()
		bindable:Destroy()
	end

	if self._status == Promise.Status.Resolved then
		return self._status, unpack(self._values, 1, self._valuesLength)
	elseif self._status == Promise.Status.Rejected then
		return self._status, unpack(self._values, 1, self._valuesLength)
	end

	return self._status
end

local function awaitHelper(status, ...)
	return status == Promise.Status.Resolved, ...
end

--[[
	Calls awaitStatus internally, returns (isResolved, values...)
] ]
function Promise.prototype:await()
	return awaitHelper(self:awaitStatus())
end

local function expectHelper(status, ...)
	if status ~= Promise.Status.Resolved then
		error((...) == nil and "Expected Promise rejected with no value." or (...), 3)
	end

	return ...
end

--[[
	Calls await and only returns if the Promise resolves.
	Throws if the Promise rejects or gets cancelled.
] ]
function Promise.prototype:expect()
	return expectHelper(self:awaitStatus())
end

-- Backwards compatibility
Promise.prototype.awaitValue = Promise.prototype.expect

--[[
	Intended for use in tests.

	Similar to await(), but instead of yielding if the promise is unresolved,
	_unwrap will throw. This indicates an assumption that a promise has
	resolved.
] ]
function Promise.prototype:_unwrap()
	if self._status == Promise.Status.Started then
		error("Promise has not resolved or rejected.", 2)
	end

	local success = self._status == Promise.Status.Resolved

	return success, unpack(self._values, 1, self._valuesLength)
end

function Promise.prototype:_resolve(...)
	if self._status ~= Promise.Status.Started then
		if Promise.is((...)) then
			(...):_consumerCancelled(self)
		end
		return
	end

	-- If the resolved value was a Promise, we chain onto it!
	if Promise.is((...)) then
		-- Without this warning, arguments sometimes mysteriously disappear
		if select("#", ...) > 1 then
			local message = string.format(
				"When returning a Promise from andThen, extra arguments are " ..
				"discarded! See:\n\n%s",
				self._source
			)
			warn(message)
		end

		local chainedPromise = ...

		local promise = chainedPromise:andThen(
			function(...)
				self:_resolve(...)
			end,
			function(...)
				local maybeRuntimeError = chainedPromise._values[1]

				-- Backwards compatibility < v2
				if chainedPromise._error then
					maybeRuntimeError = Error.new({
						error = chainedPromise._error,
						kind = Error.Kind.ExecutionError,
						context = "[No stack trace available as this Promise originated from an older version of the Promise library (< v2)]",
					})
				end

				if Error.isKind(maybeRuntimeError, Error.Kind.ExecutionError) then
					return self:_reject(maybeRuntimeError:extend({
						error = "This Promise was chained to a Promise that errored.",
						trace = "",
						context = string.format(
							"The Promise at:\n\n%s\n...Rejected because it was chained to the following Promise, which encountered an error:\n",
							self._source
						),
					}))
				end

				self:_reject(...)
			end
		)

		if promise._status == Promise.Status.Cancelled then
			self:cancel()
		elseif promise._status == Promise.Status.Started then
			-- Adopt ourselves into promise for cancellation propagation.
			self._parent = promise
			promise._consumers[self] = true
		end

		return
	end

	self._status = Promise.Status.Resolved
	self._valuesLength, self._values = pack(...)

	-- We assume that these callbacks will not throw errors.
	for _, callback in ipairs(self._queuedResolve) do
		coroutine.wrap(callback)(...)
	end

	self:_finalize()
end

function Promise.prototype:_reject(...)
	if self._status ~= Promise.Status.Started then
		return
	end

	self._status = Promise.Status.Rejected
	self._valuesLength, self._values = pack(...)

	-- If there are any rejection handlers, call those!
	if not isEmpty(self._queuedReject) then
		-- We assume that these callbacks will not throw errors.
		for _, callback in ipairs(self._queuedReject) do
			coroutine.wrap(callback)(...)
		end
	else
		-- At this point, no one was able to observe the error.
		-- An error handler might still be attached if the error occurred
		-- synchronously. We'll wait one tick, and if there are still no
		-- observers, then we should put a message in the console.

		local err = tostring((...))

		coroutine.wrap(function()
			Promise._timeEvent:Wait()

			-- Someone observed the error, hooray!
			if not self._unhandledRejection then
				return
			end

			-- Build a reasonable message
			local message = string.format(
				"Unhandled Promise rejection:\n\n%s\n\n%s",
				err,
				self._source
			)

			if Promise.TEST then
				-- Don't spam output when we're running tests.
				return
			end

			warn(message)
		end)()
	end

	self:_finalize()
end

--[[
	Calls any :finally handlers. We need this to be a separate method and
	queue because we must call all of the finally callbacks upon a success,
	failure, *and* cancellation.
] ]
function Promise.prototype:_finalize()
	for _, callback in ipairs(self._queuedFinally) do
		-- Purposefully not passing values to callbacks here, as it could be the
		-- resolved values, or rejected errors. If the developer needs the values,
		-- they should use :andThen or :catch explicitly.
		coroutine.wrap(callback)(self._status)
	end

	self._queuedFinally = nil
	self._queuedReject = nil
	self._queuedResolve = nil

	-- Clear references to other Promises to allow gc
	if not Promise.TEST then
		self._parent = nil
		self._consumers = nil
	end
end

--[[
	Chains a Promise from this one that is resolved if this Promise is
	resolved, and rejected if it is not resolved.
] ]
function Promise.prototype:now(rejectionValue)
	local traceback = debug.traceback(nil, 2)
	if self:getStatus() == Promise.Status.Resolved then
		return self:_andThen(traceback, function(...)
			return ...
		end)
	else
		return Promise.reject(rejectionValue == nil and Error.new({
			kind = Error.Kind.NotResolvedInTime,
			error = "This Promise was not resolved in time for :now()",
			context = ":now() was called at:\n\n" .. traceback,
		}) or rejectionValue)
	end
end

--[[
	Retries a Promise-returning callback N times until it succeeds.
] ]
function Promise.retry(callback, times, ...)
	assert(type(callback) == "function", "Parameter #1 to Promise.retry must be a function")
	assert(type(times) == "number", "Parameter #2 to Promise.retry must be a number")

	local args, length = {...}, select("#", ...)

	return Promise.resolve(callback(...)):catch(function(...)
		if times > 0 then
			return Promise.retry(callback, times - 1, unpack(args, 1, length))
		else
			return Promise.reject(...)
		end
	end)
end

--[[
	Converts an event into a Promise with an optional predicate
] ]
function Promise.fromEvent(event, predicate)
	predicate = predicate or function()
		return true
	end

	return Promise._new(debug.traceback(nil, 2), function(resolve, reject, onCancel)
		local connection
		local shouldDisconnect = false

		local function disconnect()
			connection:Disconnect()
			connection = nil
		end

		-- We use shouldDisconnect because if the callback given to Connect is called before
		-- Connect returns, connection will still be nil. This happens with events that queue up
		-- events when there's nothing connected, such as RemoteEvents

		connection = event:Connect(function(...)
			local callbackValue = predicate(...)

			if callbackValue == true then
				resolve(...)

				if connection then
					disconnect()
				else
					shouldDisconnect = true
				end
			elseif type(callbackValue) ~= "boolean" then
				error("Promise.fromEvent predicate should always return a boolean")
			end
		end)

		if shouldDisconnect and connection then
			return disconnect()
		end

		onCancel(function()
			disconnect()
		end)
	end)
end

return Promise

        end)
    end)
    hMod("RuntimeLib", "ModuleScript", "Havoc.include.RuntimeLib", "Havoc.include", function()
        return (function(...)
local Promise = require(script.Parent.Promise)

local RunService = game:GetService("RunService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local TS = {}

TS.Promise = Promise

local function isPlugin(object)
	return RunService:IsStudio() and object:FindFirstAncestorWhichIsA("Plugin") ~= nil
end

function TS.getModule(object, scope, moduleName)
	if moduleName == nil then
		moduleName = scope
		scope = "@rbxts"
	end

	if RunService:IsRunning() and object:IsDescendantOf(ReplicatedFirst) then
		warn("roblox-ts packages should not be used from ReplicatedFirst!")
	end

	-- ensure modules have fully replicated
	if RunService:IsRunning() and RunService:IsClient() and not isPlugin(object) and not game:IsLoaded() then
		game.Loaded:Wait()
	end

	local globalModules = script.Parent:FindFirstChild("node_modules")
	if not globalModules then
		error("Could not find any modules!", 2)
	end

	repeat
		local modules = object:FindFirstChild("node_modules")
		if modules and modules ~= globalModules then
			modules = modules:FindFirstChild("@rbxts")
		end
		if modules then
			local module = modules:FindFirstChild(moduleName)
			if module then
				return module
			end
		end
		object = object.Parent
	until object == nil or object == globalModules

	local scopedModules = globalModules:FindFirstChild(scope or "@rbxts");
	return (scopedModules or globalModules):FindFirstChild(moduleName) or error("Could not find module: " .. moduleName, 2)
end

-- This is a hash which TS.import uses as a kind of linked-list-like history of [Script who Loaded] -> Library
local currentlyLoading = {}
local registeredLibraries = {}

function TS.import(caller, module, ...)
	for i = 1, select("#", ...) do
		module = module:WaitForChild((select(i, ...)))
	end

	if module.ClassName ~= "ModuleScript" then
		error("Failed to import! Expected ModuleScript, got " .. module.ClassName, 2)
	end

	currentlyLoading[caller] = module

	-- Check to see if a case like this occurs:
	-- module -> Module1 -> Module2 -> module

	-- WHERE currentlyLoading[module] is Module1
	-- and currentlyLoading[Module1] is Module2
	-- and currentlyLoading[Module2] is module

	local currentModule = module
	local depth = 0

	while currentModule do
		depth = depth + 1
		currentModule = currentlyLoading[currentModule]

		if currentModule == module then
			local str = currentModule.Name -- Get the string traceback

			for _ = 1, depth do
				currentModule = currentlyLoading[currentModule]
				str = str .. "  ⇒ " .. currentModule.Name
			end

			error("Failed to import! Detected a circular dependency chain: " .. str, 2)
		end
	end

	if not registeredLibraries[module] then
		if _G[module] then
			error(
				"Invalid module access! Do you have two TS runtimes trying to import this? " .. module:GetFullName(),
				2
			)
		end

		_G[module] = TS
		registeredLibraries[module] = true -- register as already loaded for subsequent calls
	end

	local data = require(module)

	if currentlyLoading[caller] == module then -- Thread-safe cleanup!
		currentlyLoading[caller] = nil
	end

	return data
end

function TS.instanceof(obj, class)
	-- custom Class.instanceof() check
	if type(class) == "table" and type(class.instanceof) == "function" then
		return class.instanceof(obj)
	end

	-- metatable check
	if type(obj) == "table" then
		obj = getmetatable(obj)
		while obj ~= nil do
			if obj == class then
				return true
			end
			local mt = getmetatable(obj)
			if mt then
				obj = mt.__index
			else
				obj = nil
			end
		end
	end

	return false
end

function TS.async(callback)
	return function(...)
		local n = select("#", ...)
		local args = { ... }
		return Promise.new(function(resolve, reject)
			coroutine.wrap(function()
				local ok, result = pcall(callback, unpack(args, 1, n))
				if ok then
					resolve(result)
				else
					reject(result)
				end
			end)()
		end)
	end
end

function TS.await(promise)
	if not Promise.is(promise) then
		return promise
	end

	local status, value = promise:awaitStatus()
	if status == Promise.Status.Resolved then
		return value
	elseif status == Promise.Status.Rejected then
		error(value, 2)
	else
		error("The awaited Promise was cancelled", 2)
	end
end

function TS.bit_lrsh(a, b)
	local absA = math.abs(a)
	local result = bit32.rshift(absA, b)
	if a == absA then
		return result
	else
		return -result - 1
	end
end

TS.TRY_RETURN = 1
TS.TRY_BREAK = 2
TS.TRY_CONTINUE = 3

function TS.try(func, catch, finally)
	local err, traceback
	local success, exitType, returns = xpcall(
		func,
		function(errInner)
			err = errInner
			traceback = debug.traceback()
		end
	)
	if not success and catch then
		local newExitType, newReturns = catch(err, traceback)
		if newExitType then
			exitType, returns = newExitType, newReturns
		end
	end
	if finally then
		local newExitType, newReturns = finally()
		if newExitType then
			exitType, returns = newExitType, newReturns
		end
	end
	return exitType, returns
end

function TS.generator(callback)
	local co = coroutine.create(callback)
	return {
		next = function(...)
			if coroutine.status(co) == "dead" then
				return { done = true }
			else
				local success, value = coroutine.resume(co, ...)
				if success == false then
					error(value, 2)
				end
				return {
					value = value,
					done = coroutine.status(co) == "dead",
				}
			end
		end,
	}
end

return TS

        end)
    end)
    hInst("node_modules", "Folder", "Havoc.include.node_modules", "Havoc.include")
    hInst("compiler-types", "Folder", "Havoc.include.node_modules.compiler-types", "Havoc.include.node_modules")
    hInst("types", "Folder", "Havoc.include.node_modules.compiler-types.types", "Havoc.include.node_modules.compiler-types")
    hInst("exploit-types", "Folder", "Havoc.include.node_modules.exploit-types", "Havoc.include.node_modules")
    hInst("types", "Folder", "Havoc.include.node_modules.exploit-types.types", "Havoc.include.node_modules.exploit-types")
    hInst("flipper", "Folder", "Havoc.include.node_modules.flipper", "Havoc.include.node_modules")
    hMod("src", "ModuleScript", "Havoc.include.node_modules.flipper.src", "Havoc.include.node_modules.flipper", function()
        return (function(...)
local Flipper = {
	SingleMotor = require(script.SingleMotor),
	GroupMotor = require(script.GroupMotor),

	Instant = require(script.Instant),
	Linear = require(script.Linear),
	Spring = require(script.Spring),
	
	isMotor = require(script.isMotor),
}

return Flipper
        end)
    end)
    hInst("typings", "Folder", "Havoc.include.node_modules.flipper.typings", "Havoc.include.node_modules.flipper")
    hMod("make", "ModuleScript", "Havoc.include.node_modules.make", "Havoc.include.node_modules", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.3
--[[
	*
	* Returns a table wherein an object's writable properties can be specified,
	* while also allowing functions to be passed in which can be bound to a RBXScriptSignal.
] ]
--[[
	*
	* Instantiates a new Instance of `className` with given `settings`,
	* where `settings` is an object of the form { [K: propertyName]: value }.
	*
	* `settings.Children` is an array of child objects to be parented to the generated Instance.
	*
	* Events can be set to a callback function, which will be connected.
	*
	* `settings.Parent` is always set last.
] ]
local function Make(className, settings)
	local _binding = settings
	local children = _binding.Children
	local parent = _binding.Parent
	local instance = Instance.new(className)
	for setting, value in pairs(settings) do
		if setting ~= "Children" and setting ~= "Parent" then
			local _binding_1 = instance
			local prop = _binding_1[setting]
			if typeof(prop) == "RBXScriptSignal" then
				prop:Connect(value)
			else
				instance[setting] = value
			end
		end
	end
	if children then
		for _, child in ipairs(children) do
			child.Parent = instance
		end
	end
	instance.Parent = parent
	return instance
end
return Make

        end)
    end)
    hInst("node_modules", "Folder", "Havoc.include.node_modules.make.node_modules", "Havoc.include.node_modules.make")
    hInst("@rbxts", "Folder", "Havoc.include.node_modules.make.node_modules.@rbxts", "Havoc.include.node_modules.make.node_modules")
    hInst("compiler-types", "Folder", "Havoc.include.node_modules.make.node_modules.@rbxts.compiler-types", "Havoc.include.node_modules.make.node_modules.@rbxts")
    hInst("types", "Folder", "Havoc.include.node_modules.make.node_modules.@rbxts.compiler-types.types", "Havoc.include.node_modules.make.node_modules.@rbxts.compiler-types")
    hMod("object-utils", "ModuleScript", "Havoc.include.node_modules.object-utils", "Havoc.include.node_modules", function()
        return (function(...)
local HttpService = game:GetService("HttpService")

local Object = {}

function Object.keys(object)
	local result = table.create(#object)
	for key in pairs(object) do
		result[#result + 1] = key
	end
	return result
end

function Object.values(object)
	local result = table.create(#object)
	for _, value in pairs(object) do
		result[#result + 1] = value
	end
	return result
end

function Object.entries(object)
	local result = table.create(#object)
	for key, value in pairs(object) do
		result[#result + 1] = { key, value }
	end
	return result
end

function Object.assign(toObj, ...)
	for i = 1, select("#", ...) do
		local arg = select(i, ...)
		if type(arg) == "table" then
			for key, value in pairs(arg) do
				toObj[key] = value
			end
		end
	end
	return toObj
end

function Object.copy(object)
	local result = table.create(#object)
	for k, v in pairs(object) do
		result[k] = v
	end
	return result
end

local function deepCopyHelper(object, encountered)
	local result = table.create(#object)
	encountered[object] = result

	for k, v in pairs(object) do
		if type(k) == "table" then
			k = encountered[k] or deepCopyHelper(k, encountered)
		end

		if type(v) == "table" then
			v = encountered[v] or deepCopyHelper(v, encountered)
		end

		result[k] = v
	end

	return result
end

function Object.deepCopy(object)
	return deepCopyHelper(object, {})
end

function Object.deepEquals(a, b)
	-- a[k] == b[k]
	for k in pairs(a) do
		local av = a[k]
		local bv = b[k]
		if type(av) == "table" and type(bv) == "table" then
			local result = Object.deepEquals(av, bv)
			if not result then
				return false
			end
		elseif av ~= bv then
			return false
		end
	end

	-- extra keys in b
	for k in pairs(b) do
		if a[k] == nil then
			return false
		end
	end

	return true
end

function Object.toString(data)
	return HttpService:JSONEncode(data)
end

function Object.isEmpty(object)
	return next(object) == nil
end

function Object.fromEntries(entries)
	local entriesLen = #entries

	local result = table.create(entriesLen)
	if entries then
		for i = 1, entriesLen do
			local pair = entries[i]
			result[pair[1] ] = pair[2]
		end
	end
	return result
end

return Object

        end)
    end)
    hInst("roact", "Folder", "Havoc.include.node_modules.roact", "Havoc.include.node_modules")
    hMod("src", "ModuleScript", "Havoc.include.node_modules.roact.src", "Havoc.include.node_modules.roact", function()
        return (function(...)
--[[
	Packages up the internals of Roact and exposes a public API for it.
] ]

local GlobalConfig = require(script.GlobalConfig)
local createReconciler = require(script.createReconciler)
local createReconcilerCompat = require(script.createReconcilerCompat)
local RobloxRenderer = require(script.RobloxRenderer)
local strict = require(script.strict)
local Binding = require(script.Binding)

local robloxReconciler = createReconciler(RobloxRenderer)
local reconcilerCompat = createReconcilerCompat(robloxReconciler)

local Roact = strict {
	Component = require(script.Component),
	createElement = require(script.createElement),
	createFragment = require(script.createFragment),
	oneChild = require(script.oneChild),
	PureComponent = require(script.PureComponent),
	None = require(script.None),
	Portal = require(script.Portal),
	createRef = require(script.createRef),
	forwardRef = require(script.forwardRef),
	createBinding = Binding.create,
	joinBindings = Binding.join,
	createContext = require(script.createContext),

	Change = require(script.PropMarkers.Change),
	Children = require(script.PropMarkers.Children),
	Event = require(script.PropMarkers.Event),
	Ref = require(script.PropMarkers.Ref),

	mount = robloxReconciler.mountVirtualTree,
	unmount = robloxReconciler.unmountVirtualTree,
	update = robloxReconciler.updateVirtualTree,

	reify = reconcilerCompat.reify,
	teardown = reconcilerCompat.teardown,
	reconcile = reconcilerCompat.reconcile,

	setGlobalConfig = GlobalConfig.set,

	-- APIs that may change in the future without warning
	UNSTABLE = {
	},
}

return Roact
        end)
    end)
    hInst("roact-hooked", "Folder", "Havoc.include.node_modules.roact-hooked", "Havoc.include.node_modules")
    hMod("out", "ModuleScript", "Havoc.include.node_modules.roact-hooked.out", "Havoc.include.node_modules.roact-hooked", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = _G[script]
local exports = {}
local _with_hooks = TS.import(script, script, "with-hooks")
local withHooks = _with_hooks.withHooks
local withHooksPure = _with_hooks.withHooksPure
for _k, _v in pairs(TS.import(script, script, "hooks")) do
	exports[_k] = _v
end
--[[
	*
	* `hooked` is a [higher-order component](https://reactjs.org/docs/higher-order-components.html) that turns your
	* Function Component into a [class component](https://roblox.github.io/roact/guide/components/).
	*
	* `hooked` allows you to hook into the Component's lifecycle through Hooks.
	*
	* @example
	* const MyComponent = hooked<Props>(
	*   (props) => {
	*     // render using props
	*   },
	* );
	*
	* @see https://reactjs.org/docs/hooks-intro.html
] ]
local function hooked(functionComponent)
	return withHooks(functionComponent)
end
--[[
	*
	* `pure` is a [higher-order component](https://reactjs.org/docs/higher-order-components.html) that turns your
	* Function Component into a [PureComponent](https://roblox.github.io/roact/performance/reduce-reconciliation/#purecomponent).
	*
	* If your function component wrapped in `pure` has a {@link useState}, {@link useReducer} or {@link useContext} Hook
	* in its implementation, it will still rerender when state or context changes.
	*
	* @example
	* const MyComponent = pure<Props>(
	*   (props) => {
	*     // render using props
	*   },
	* );
	*
	* @see https://reactjs.org/docs/react-api.html
	* @see https://roblox.github.io/roact/performance/reduce-reconciliation/
] ]
local function pure(functionComponent)
	return withHooksPure(functionComponent)
end
exports.hooked = hooked
exports.pure = pure
return exports

        end)
    end)
    hMod("hooks", "ModuleScript", "Havoc.include.node_modules.roact-hooked.out.hooks", "Havoc.include.node_modules.roact-hooked.out", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = _G[script]
local exports = {}
exports.useBinding = TS.import(script, script, "use-binding").useBinding
exports.useCallback = TS.import(script, script, "use-callback").useCallback
exports.useContext = TS.import(script, script, "use-context").useContext
exports.useEffect = TS.import(script, script, "use-effect").useEffect
exports.useMemo = TS.import(script, script, "use-memo").useMemo
exports.useReducer = TS.import(script, script, "use-reducer").useReducer
exports.useState = TS.import(script, script, "use-state").useState
exports.useMutable = TS.import(script, script, "use-mutable").useMutable
exports.useRef = TS.import(script, script, "use-ref").useRef
return exports

        end)
    end)
    hMod("use-binding", "ModuleScript", "Havoc.include.node_modules.roact-hooked.out.hooks.use-binding", "Havoc.include.node_modules.roact-hooked.out.hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = _G[script]
local createBinding = TS.import(script, TS.getModule(script, "@rbxts", "roact").src).createBinding
local memoizedHook = TS.import(script, script.Parent.Parent, "utils", "memoized-hook").memoizedHook
--[[
	*
	* `useBinding` returns a memoized *`Binding`*, a special object that Roact automatically unwraps into values. When a
	* binding is updated, Roact will only change the specific properties that are subscribed to it.
	*
	* The first value returned is a `Binding` object, which will typically be passed as a prop to a Roact host component.
	* The second is a function that can be called with a new value to update the binding.
	*
	* @example
	* const [binding, setBindingValue] = useBinding(initialValue);
	*
	* @param initialValue - Initialized as the `.current` property
	* @returns A memoized `Binding` object, and a function to update the value of the binding.
	*
	* @see https://roblox.github.io/roact/advanced/bindings-and-refs/#bindings
] ]
local function useBinding(initialValue)
	return memoizedHook(function()
		local bindingSet = { createBinding(initialValue) }
		return bindingSet
	end).state
end
return {
	useBinding = useBinding,
}

        end)
    end)
    hMod("use-callback", "ModuleScript", "Havoc.include.node_modules.roact-hooked.out.hooks.use-callback", "Havoc.include.node_modules.roact-hooked.out.hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = _G[script]
local useMemo = TS.import(script, script.Parent, "use-memo").useMemo
--[[
	*
	* Returns a memoized version of the callback that only changes if one of the dependencies has changed.
	*
	* This is useful when passing callbacks to optimized child components that rely on reference equality to prevent
	* unnecessary renders.
	*
	* `useCallback(fn, deps)` is equivalent to `useMemo(() => fn, deps)`.
	*
	* @example
	* const memoizedCallback = useCallback(
	*   () => {
	*     doSomething(a, b);
	*   },
	*   [a, b],
	* );
	*
	* @param callback - An inline callback
	* @param deps - An array of dependencies
	* @returns A memoized version of the callback
	*
	* @see https://reactjs.org/docs/hooks-reference.html#usecallback
] ]
local function useCallback(callback, deps)
	return useMemo(function()
		return callback
	end, deps)
end
return {
	useCallback = useCallback,
}

        end)
    end)
    hMod("use-context", "ModuleScript", "Havoc.include.node_modules.roact-hooked.out.hooks.use-context", "Havoc.include.node_modules.roact-hooked.out.hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = _G[script]
--[[
	*
	* @see https://github.com/Kampfkarren/roact-hooks/blob/main/src/createUseContext.lua
] ]
local _memoized_hook = TS.import(script, script.Parent.Parent, "utils", "memoized-hook")
local memoizedHook = _memoized_hook.memoizedHook
local resolveCurrentComponent = _memoized_hook.resolveCurrentComponent
local useEffect = TS.import(script, script.Parent, "use-effect").useEffect
local useState = TS.import(script, script.Parent, "use-state").useState
local function copyComponent(component)
	return setmetatable({}, {
		__index = component,
	})
end
--[[
	*
	* Accepts a context object (the value returned from `Roact.createContext`) and returns the current context value, as
	* given by the nearest context provider for the given context.
	*
	* When the nearest `Context.Provider` above the component updates, this Hook will trigger a rerender with the latest
	* context value.
	*
	* If there is no Provider, `useContext` returns the default value of the context.
	*
	* @param context - The Context object to read from
	* @returns The latest context value of the nearest Provider
	*
	* @see https://reactjs.org/docs/hooks-reference.html#usecontext
] ]
local function useContext(context)
	local thisContext = context
	local _binding = memoizedHook(function()
		local consumer = copyComponent(resolveCurrentComponent())
		thisContext.Consumer.init(consumer)
		return consumer.contextEntry
	end)
	local contextEntry = _binding.state
	if contextEntry then
		local _binding_1 = useState(contextEntry.value)
		local value = _binding_1[1]
		local setValue = _binding_1[2]
		useEffect(function()
			return contextEntry.onUpdate:subscribe(setValue)
		end, {})
		return value
	else
		return thisContext.defaultValue
	end
end
return {
	useContext = useContext,
}

        end)
    end)
    hMod("use-effect", "ModuleScript", "Havoc.include.node_modules.roact-hooked.out.hooks.use-effect", "Havoc.include.node_modules.roact-hooked.out.hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = _G[script]
local areDepsEqual = TS.import(script, script.Parent.Parent, "utils", "are-deps-equal").areDepsEqual
local _memoized_hook = TS.import(script, script.Parent.Parent, "utils", "memoized-hook")
local memoizedHook = _memoized_hook.memoizedHook
local resolveCurrentComponent = _memoized_hook.resolveCurrentComponent
local function scheduleEffect(effect)
	local _binding = resolveCurrentComponent()
	local effects = _binding.effects
	if effects.tail == nil then
		-- This is the first effect in the list
		effects.tail = effect
		effects.head = effects.tail
	else
		-- Append to the end of the list
		local _exp = effects.tail
		_exp.next = effect
		effects.tail = _exp.next
	end
	return effect
end
--[[
	*
	* Accepts a function that contains imperative, possibly effectful code. The function passed to `useEffect` will run
	* synchronously (thread-blocking) after the Roblox Instance is created and rendered.
	*
	* The clean-up function (returned by the effect) runs before the component is removed from the UI to prevent memory
	* leaks. Additionally, if a component renders multiple times, the **previous effect is cleaned up before executing
	* the next effect**.
	*
	*`useEffect` runs in the same phase as `didMount` and `didUpdate`. All cleanup functions are called on `willUnmount`.
	*
	* @example
	* useEffect(() => {
	*   // use value
	*   return () => {
	*     // cleanup
	*   }
	* }, [value]);
	*
	* useEffect(() => {
	*   // did update
	* });
	*
	* useEffect(() => {
	*   // did mount
	*   return () => {
	*     // will unmount
	*   }
	* }, []);
	*
	* @param callback - Imperative function that can return a cleanup function
	* @param deps - If present, effect will only activate if the values in the list change
	*
	* @see https://reactjs.org/docs/hooks-reference.html#useeffect
] ]
local function useEffect(callback, deps)
	local hook = memoizedHook(nil)
	local _prevDeps = hook.state
	if _prevDeps ~= nil then
		_prevDeps = _prevDeps.deps
	end
	local prevDeps = _prevDeps
	if deps and areDepsEqual(deps, prevDeps) then
		return nil
	end
	hook.state = scheduleEffect({
		id = hook.id,
		callback = callback,
		deps = deps,
	})
end
return {
	useEffect = useEffect,
}

        end)
    end)
    hMod("use-memo", "ModuleScript", "Havoc.include.node_modules.roact-hooked.out.hooks.use-memo", "Havoc.include.node_modules.roact-hooked.out.hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = _G[script]
local areDepsEqual = TS.import(script, script.Parent.Parent, "utils", "are-deps-equal").areDepsEqual
local memoizedHook = TS.import(script, script.Parent.Parent, "utils", "memoized-hook").memoizedHook
--[[
	*
	* `useMemo` will only recompute the memoized value when one of the `deps` has changed. This optimization helps to
	* avoid expensive calculations on every render.
	*
	* Remember that the function passed to `useMemo` runs during rendering. Don’t do anything there that you wouldn’t
	* normally do while rendering. For example, side effects belong in `useEffect`, not `useMemo`.
	*
	* If no array is provided, a new value will be computed on every render. This is usually a mistake, so `deps` must be
	* explicitly written as `undefined`.
	*
	* @example
	* const memoizedValue = useMemo(() => computeExpensiveValue(a, b), [a, b]);
	*
	* @param factory - A "create" function that computes a value
	* @param deps - An array of dependencies
	* @returns A memoized value
	*
	* @see https://reactjs.org/docs/hooks-reference.html#usememo
] ]
local function useMemo(factory, deps)
	local hook = memoizedHook(function()
		return {}
	end)
	local _binding = hook.state
	local prevValue = _binding[1]
	local prevDeps = _binding[2]
	if prevValue ~= nil and (deps and areDepsEqual(deps, prevDeps)) then
		return prevValue
	end
	local nextValue = factory()
	hook.state = { nextValue, deps }
	return nextValue
end
return {
	useMemo = useMemo,
}

        end)
    end)
    hMod("use-mutable", "ModuleScript", "Havoc.include.node_modules.roact-hooked.out.hooks.use-mutable", "Havoc.include.node_modules.roact-hooked.out.hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = _G[script]
local memoizedHook = TS.import(script, script.Parent.Parent, "utils", "memoized-hook").memoizedHook
-- Function overloads from https://github.com/DefinitelyTyped/DefinitelyTyped/blob/master/types/react/index.d.ts#L1061
--[[
	*
	* `useMutable` returns a mutable object whose `.current` property is initialized to the argument `initialValue`.
	* The returned object will persist for the full lifetime of the component.
	*
	* `useMutable()` is handy for keeping any mutable value around similar to how you’d use instance fields in classes.
	*
	* This cannot be used as a [Roact Ref](https://roblox.github.io/roact/advanced/bindings-and-refs/#refs). If you want
	* to reference a Roblox Instance, refer to {@link useRef}.
	*
	* @example
	* const container = useMutable(initialValue);
	* useEffect(() => {
	*   container.current = value;
	* });
	*
	* @param initialValue - Initialized as the `.current` property
	* @returns A memoized, mutable object
	*
	* @see https://reactjs.org/docs/hooks-reference.html#useref
] ]
--[[
	*
	* `useMutable` returns a mutable object whose `.current` property is initialized to the argument `initialValue`.
	* The returned object will persist for the full lifetime of the component.
	*
	* `useMutable()` is handy for keeping any mutable value around similar to how you’d use instance fields in classes.
	*
	* This cannot be used as a [Roact Ref](https://roblox.github.io/roact/advanced/bindings-and-refs/#refs). If you want
	* to reference a Roblox Instance, refer to {@link useRef}.
	*
	* @example
	* const container = useMutable(initialValue);
	* useEffect(() => {
	*   container.current = value;
	* });
	*
	* @param initialValue - Initialized as the `.current` property
	* @returns A memoized, mutable object
	*
	* @see https://reactjs.org/docs/hooks-reference.html#useref
] ]
-- convenience overload for refs given as a ref prop as they typically start with a null value
--[[
	*
	* `useMutable` returns a mutable object whose `.current` property is initialized to the argument `initialValue`.
	* The returned object will persist for the full lifetime of the component.
	*
	* `useMutable()` is handy for keeping any mutable value around similar to how you’d use instance fields in classes.
	*
	* This cannot be used as a [Roact Ref](https://roblox.github.io/roact/advanced/bindings-and-refs/#refs). If you want
	* to reference a Roblox Instance, refer to {@link useRef}.
	*
	* @example
	* const container = useMutable(initialValue);
	* useEffect(() => {
	*   container.current = value;
	* });
	*
	* @returns A memoized, mutable object
	*
	* @see https://reactjs.org/docs/hooks-reference.html#useref
] ]
-- convenience overload for potentially undefined initialValue / call with 0 arguments
-- has a default to stop it from defaulting to {} instead
--[[
	*
	* `useMutable` returns a mutable object whose `.current` property is initialized to the argument `initialValue`.
	* The returned object will persist for the full lifetime of the component.
	*
	* `useMutable()` is handy for keeping any mutable value around similar to how you’d use instance fields in classes.
	*
	* This cannot be used as a [Roact Ref](https://roblox.github.io/roact/advanced/bindings-and-refs/#refs). If you want
	* to reference a Roblox Instance, refer to {@link useRef}.
	*
	* @example
	* const container = useMutable(initialValue);
	* useEffect(() => {
	*   container.current = value;
	* });
	*
	* @param initialValue - Initialized as the `.current` property
	* @returns A memoized, mutable object
	*
	* @see https://reactjs.org/docs/hooks-reference.html#useref
] ]
local function useMutable(initialValue)
	return memoizedHook(function()
		return {
			current = initialValue,
		}
	end).state
end
return {
	useMutable = useMutable,
}

        end)
    end)
    hMod("use-reducer", "ModuleScript", "Havoc.include.node_modules.roact-hooked.out.hooks.use-reducer", "Havoc.include.node_modules.roact-hooked.out.hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = _G[script]
local _memoized_hook = TS.import(script, script.Parent.Parent, "utils", "memoized-hook")
local memoizedHook = _memoized_hook.memoizedHook
local resolveCurrentComponent = _memoized_hook.resolveCurrentComponent
--[[
	*
	* Accepts a reducer of type `(state, action) => newState`, and returns the current state paired with a `dispatch`
	* method.
	*
	* If a new state is the same value as the current state, this will bail out without rerendering the component.
	*
	* `useReducer` is usually preferable to `useState` when you have complex state logic that involves multiple sub-values.
	* It also lets you optimize performance for components that trigger deep updates because [you can pass `dispatch` down
	* instead of callbacks](https://reactjs.org/docs/hooks-faq.html#how-to-avoid-passing-callbacks-down).
	*
	* There are two different ways to initialize `useReducer` state. You can use the initial state as a second argument,
	* or [create the initial state lazily](https://reactjs.org/docs/hooks-reference.html#lazy-initialization). To do this,
	* you can pass an init function as the third argument. The initial state will be set to `initializer(initialArg)`.
	*
	* @param reducer - Function that returns a state given the current state and an action
	* @param initializerArg - State used during the initial render, or passed to `initializer` if provided
	* @param initializer - Optional function that returns an initial state given `initializerArg`
	* @returns The current state, and an action dispatcher
	*
	* @see https://reactjs.org/docs/hooks-reference.html#usereducer
] ]
-- overload where dispatch could accept 0 arguments.
--[[
	*
	* Accepts a reducer of type `(state, action) => newState`, and returns the current state paired with a `dispatch`
	* method.
	*
	* If a new state is the same value as the current state, this will bail out without rerendering the component.
	*
	* `useReducer` is usually preferable to `useState` when you have complex state logic that involves multiple sub-values.
	* It also lets you optimize performance for components that trigger deep updates because [you can pass `dispatch` down
	* instead of callbacks](https://reactjs.org/docs/hooks-faq.html#how-to-avoid-passing-callbacks-down).
	*
	* There are two different ways to initialize `useReducer` state. You can use the initial state as a second argument,
	* or [create the initial state lazily](https://reactjs.org/docs/hooks-reference.html#lazy-initialization). To do this,
	* you can pass an init function as the third argument. The initial state will be set to `initializer(initialArg)`.
	*
	* @param reducer - Function that returns a state given the current state and an action
	* @param initializerArg - State used during the initial render, or passed to `initializer` if provided
	* @param initializer - Optional function that returns an initial state given `initializerArg`
	* @returns The current state, and an action dispatcher
	*
	* @see https://reactjs.org/docs/hooks-reference.html#usereducer
] ]
-- overload where dispatch could accept 0 arguments.
--[[
	*
	* Accepts a reducer of type `(state, action) => newState`, and returns the current state paired with a `dispatch`
	* method.
	*
	* If a new state is the same value as the current state, this will bail out without rerendering the component.
	*
	* `useReducer` is usually preferable to `useState` when you have complex state logic that involves multiple sub-values.
	* It also lets you optimize performance for components that trigger deep updates because [you can pass `dispatch` down
	* instead of callbacks](https://reactjs.org/docs/hooks-faq.html#how-to-avoid-passing-callbacks-down).
	*
	* There are two different ways to initialize `useReducer` state. You can use the initial state as a second argument,
	* or [create the initial state lazily](https://reactjs.org/docs/hooks-reference.html#lazy-initialization). To do this,
	* you can pass an init function as the third argument. The initial state will be set to `initializer(initialArg)`.
	*
	* @param reducer - Function that returns a state given the current state and an action
	* @param initializerArg - State used during the initial render, or passed to `initializer` if provided
	* @param initializer - Optional function that returns an initial state given `initializerArg`
	* @returns The current state, and an action dispatcher
	*
	* @see https://reactjs.org/docs/hooks-reference.html#usereducer
] ]
-- overload for free "I"; all goes as long as initializer converts it into "ReducerState<R>".
--[[
	*
	* Accepts a reducer of type `(state, action) => newState`, and returns the current state paired with a `dispatch`
	* method.
	*
	* If a new state is the same value as the current state, this will bail out without rerendering the component.
	*
	* `useReducer` is usually preferable to `useState` when you have complex state logic that involves multiple sub-values.
	* It also lets you optimize performance for components that trigger deep updates because [you can pass `dispatch` down
	* instead of callbacks](https://reactjs.org/docs/hooks-faq.html#how-to-avoid-passing-callbacks-down).
	*
	* There are two different ways to initialize `useReducer` state. You can use the initial state as a second argument,
	* or [create the initial state lazily](https://reactjs.org/docs/hooks-reference.html#lazy-initialization). To do this,
	* you can pass an init function as the third argument. The initial state will be set to `initializer(initialArg)`.
	*
	* @param reducer - Function that returns a state given the current state and an action
	* @param initializerArg - State used during the initial render, or passed to `initializer` if provided
	* @param initializer - Optional function that returns an initial state given `initializerArg`
	* @returns The current state, and an action dispatcher
	*
	* @see https://reactjs.org/docs/hooks-reference.html#usereducer
] ]
-- overload where "I" may be a subset of ReducerState<R>; used to provide autocompletion.
-- If "I" matches ReducerState<R> exactly then the last overload will allow initializer to be omitted.
--[[
	*
	* Accepts a reducer of type `(state, action) => newState`, and returns the current state paired with a `dispatch`
	* method.
	*
	* If a new state is the same value as the current state, this will bail out without rerendering the component.
	*
	* `useReducer` is usually preferable to `useState` when you have complex state logic that involves multiple sub-values.
	* It also lets you optimize performance for components that trigger deep updates because [you can pass `dispatch` down
	* instead of callbacks](https://reactjs.org/docs/hooks-faq.html#how-to-avoid-passing-callbacks-down).
	*
	* There are two different ways to initialize `useReducer` state. You can use the initial state as a second argument,
	* or [create the initial state lazily](https://reactjs.org/docs/hooks-reference.html#lazy-initialization). To do this,
	* you can pass an init function as the third argument. The initial state will be set to `initializer(initialArg)`.
	*
	* @param reducer - Function that returns a state given the current state and an action
	* @param initializerArg - State used during the initial render, or passed to `initializer` if provided
	* @param initializer - Optional function that returns an initial state given `initializerArg`
	* @returns The current state, and an action dispatcher
	*
	* @see https://reactjs.org/docs/hooks-reference.html#usereducer
] ]
-- Implementation matches a previous overload, is this required?
local function useReducer(reducer, initializerArg, initializer)
	local currentComponent = resolveCurrentComponent()
	local hook = memoizedHook(function()
		local _result
		if initializer then
			_result = initializer(initializerArg)
		else
			_result = initializerArg
		end
		return _result
	end)
	local function dispatch(action)
		local nextState = reducer(hook.state, action)
		if hook.state ~= nextState then
			currentComponent:setHookState(hook.id, function()
				hook.state = nextState
				return hook.state
			end)
		end
	end
	return { hook.state, dispatch }
end
return {
	useReducer = useReducer,
}

        end)
    end)
    hMod("use-ref", "ModuleScript", "Havoc.include.node_modules.roact-hooked.out.hooks.use-ref", "Havoc.include.node_modules.roact-hooked.out.hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = _G[script]
local createRef = TS.import(script, TS.getModule(script, "@rbxts", "roact").src).createRef
local memoizedHook = TS.import(script, script.Parent.Parent, "utils", "memoized-hook").memoizedHook
--[[
	*
	* `useRef` returns a memoized *`Ref`*, a special type of binding that points to Roblox Instance objects that are
	* created by Roact. The returned object will persist for the full lifetime of the component.
	*
	* `useMutable()` is handy for keeping any mutable value around similar to how you’d use instance fields in classes.
	*
	* This is not mutable like React's `useRef` hook. If you want to use a mutable object, refer to {@link useMutable}.
	*
	* @example
	* const ref = useRef<TextBox>();
	*
	* useEffect(() => {
	* 	const textBox = ref.getValue();
	* 	if (textBox) {
	* 		textBox.CaptureFocus();
	* 	}
	* }, []);
	*
	* return <textbox Ref={ref} />;
	*
	* @returns A memoized `Ref` object
	*
	* @see https://roblox.github.io/roact/advanced/bindings-and-refs/#refs
] ]
local function useRef()
	return memoizedHook(function()
		return createRef()
	end).state
end
return {
	useRef = useRef,
}

        end)
    end)
    hMod("use-state", "ModuleScript", "Havoc.include.node_modules.roact-hooked.out.hooks.use-state", "Havoc.include.node_modules.roact-hooked.out.hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = _G[script]
local useReducer = TS.import(script, script.Parent, "use-reducer").useReducer
--[[
	*
	* Returns a stateful value, and a function to update it.
	*
	* During the initial render, the returned state (`state`) is the same as the value passed as the first argument
	* (`initialState`).
	*
	* The `setState` function is used to update the state. It always knows the current state, so it's safe to omit from
	* the `useEffect` or `useCallback` dependency lists.
	*
	* If you update a State Hook to the same value as the current state, this will bail out without rerendering the
	* component.
	*
	* @example
	* const [state, setState] = useState(initialState);
	* const [state, setState] = useState(() => someExpensiveComputation());
	* setState(newState);
	* setState((prevState) => prevState + 1)
	*
	* @param initialState - State used during the initial render. Can be a function, which will be executed on initial render
	* @returns A stateful value, and an updater function
	*
	* @see https://reactjs.org/docs/hooks-reference.html#usestate
] ]
--[[
	*
	* Returns a stateful value, and a function to update it.
	*
	* During the initial render, the returned state (`state`) is the same as the value passed as the first argument
	* (`initialState`).
	*
	* The `setState` function is used to update the state. It always knows the current state, so it's safe to omit from
	* the `useEffect` or `useCallback` dependency lists.
	*
	* If you update a State Hook to the same value as the current state, this will bail out without rerendering the
	* component.
	*
	* @example
	* const [state, setState] = useState(initialState);
	* const [state, setState] = useState(() => someExpensiveComputation());
	* setState(newState);
	* setState((prevState) => prevState + 1)
	*
	* @param initialState - State used during the initial render. Can be a function, which will be executed on initial render
	* @returns A stateful value, and an updater function
	*
	* @see https://reactjs.org/docs/hooks-reference.html#usestate
] ]
--[[
	*
	* Returns a stateful value, and a function to update it.
	*
	* During the initial render, the returned state (`state`) is the same as the value passed as the first argument
	* (`initialState`).
	*
	* The `setState` function is used to update the state. It always knows the current state, so it's safe to omit from
	* the `useEffect` or `useCallback` dependency lists.
	*
	* If you update a State Hook to the same value as the current state, this will bail out without rerendering the
	* component.
	*
	* @example
	* const [state, setState] = useState(initialState);
	* const [state, setState] = useState(() => someExpensiveComputation());
	* setState(newState);
	* setState((prevState) => prevState + 1)
	*
	* @param initialState - State used during the initial render. Can be a function, which will be executed on initial render
	* @returns A stateful value, and an updater function
	*
	* @see https://reactjs.org/docs/hooks-reference.html#usestate
] ]
local function useState(initialState)
	local _binding = useReducer(function(state, action)
		local _result
		if type(action) == "function" then
			_result = action(state)
		else
			_result = action
		end
		return _result
	end, nil, function()
		local _result
		if type(initialState) == "function" then
			_result = initialState()
		else
			_result = initialState
		end
		return _result
	end)
	local state = _binding[1]
	local dispatch = _binding[2]
	return { state, dispatch }
end
return {
	useState = useState,
}

        end)
    end)
    hMod("types", "ModuleScript", "Havoc.include.node_modules.roact-hooked.out.types", "Havoc.include.node_modules.roact-hooked.out", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
-- Roact
-- Reducers
-- Utility types
-- Hooks
return nil

        end)
    end)
    hInst("utils", "Folder", "Havoc.include.node_modules.roact-hooked.out.utils", "Havoc.include.node_modules.roact-hooked.out")
    hMod("are-deps-equal", "ModuleScript", "Havoc.include.node_modules.roact-hooked.out.utils.are-deps-equal", "Havoc.include.node_modules.roact-hooked.out.utils", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local function areDepsEqual(nextDeps, prevDeps)
	if prevDeps == nil then
		return false
	end
	if #nextDeps ~= #prevDeps then
		return false
	end
	do
		local i = 0
		local _shouldIncrement = false
		while true do
			if _shouldIncrement then
				i += 1
			else
				_shouldIncrement = true
			end
			if not (i < #nextDeps) then
				break
			end
			if nextDeps[i + 1] == prevDeps[i + 1] then
				continue
			end
			return false
		end
	end
	return true
end
return {
	areDepsEqual = areDepsEqual,
}

        end)
    end)
    hMod("memoized-hook", "ModuleScript", "Havoc.include.node_modules.roact-hooked.out.utils.memoized-hook", "Havoc.include.node_modules.roact-hooked.out.utils", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local EXCEPTION_INVALID_HOOK_CALL = table.concat({ "Invalid hook call. Hooks can only be called inside of the body of a function component.", "This is usually the result of conflicting versions of roact-hooked.", "See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem." }, "\n")
local EXCEPTION_RENDER_NOT_DONE = "Failed to render hook! (Another hooked component is rendering)"
local EXCEPTION_RENDER_OVERLAP = "Failed to render hook! (Another hooked component rendered during this one)"
local currentHook
local currentlyRenderingComponent
--[[
	*
	* Prepares for an upcoming render.
] ]
local function renderReady(component)
	local _arg0 = currentlyRenderingComponent == nil
	assert(_arg0, EXCEPTION_RENDER_NOT_DONE)
	currentlyRenderingComponent = component
end
--[[
	*
	* Cleans up hooks. Must be called after finishing a render!
] ]
local function renderDone(component)
	local _arg0 = currentlyRenderingComponent == component
	assert(_arg0, EXCEPTION_RENDER_OVERLAP)
	currentlyRenderingComponent = nil
	currentHook = nil
end
--[[
	*
	* Returns the currently-rendering component. Throws an error if a component is not mid-render.
] ]
local function resolveCurrentComponent()
	return currentlyRenderingComponent or error(EXCEPTION_INVALID_HOOK_CALL, 3)
end
--[[
	*
	* Gets or creates a new hook. Hooks are memoized for every component. See the original source
	* {@link https://github.com/facebook/react/blob/main/packages/react-reconciler/src/ReactFiberHooks.new.js#L619 here}.
	*
	* @param initialValue - Initial value for `Hook.state` and `Hook.baseState`.
] ]
local function memoizedHook(initialValue)
	local currentlyRenderingComponent = resolveCurrentComponent()
	local _result
	if currentHook then
		_result = currentHook.next
	else
		_result = currentlyRenderingComponent.firstHook
	end
	local nextHook = _result
	if nextHook then
		-- The hook has already been created
		currentHook = nextHook
	else
		-- This is a new hook, should be from an initial render
		local _result_1
		if type(initialValue) == "function" then
			_result_1 = initialValue()
		else
			_result_1 = initialValue
		end
		local state = _result_1
		local newHook = {
			id = currentHook and currentHook.id + 1 or 0,
			state = state,
			baseState = state,
		}
		if not currentHook then
			-- This is the first hook in the list
			currentHook = newHook
			currentlyRenderingComponent.firstHook = currentHook
		else
			-- Append to the end of the list
			currentHook.next = newHook
			currentHook = currentHook.next
		end
	end
	return currentHook
end
return {
	renderReady = renderReady,
	renderDone = renderDone,
	resolveCurrentComponent = resolveCurrentComponent,
	memoizedHook = memoizedHook,
}

        end)
    end)
    hMod("with-hooks", "ModuleScript", "Havoc.include.node_modules.roact-hooked.out.with-hooks", "Havoc.include.node_modules.roact-hooked.out", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = _G[script]
local exports = {}
local _with_hooks = TS.import(script, script, "with-hooks")
exports.withHooks = _with_hooks.withHooks
exports.withHooksPure = _with_hooks.withHooksPure
return exports

        end)
    end)
    hMod("component-with-hooks", "ModuleScript", "Havoc.include.node_modules.roact-hooked.out.with-hooks.component-with-hooks", "Havoc.include.node_modules.roact-hooked.out.with-hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = _G[script]
local _memoized_hook = TS.import(script, script.Parent.Parent, "utils", "memoized-hook")
local renderDone = _memoized_hook.renderDone
local renderReady = _memoized_hook.renderReady
local ComponentWithHooks
do
	ComponentWithHooks = {}
	function ComponentWithHooks:constructor()
	end
	function ComponentWithHooks:init()
		self.effects = {}
		self.effectHandles = {}
	end
	function ComponentWithHooks:setHookState(id, reducer)
		self:setState(function(state)
			return {
				[id] = reducer(state[id]),
			}
		end)
	end
	function ComponentWithHooks:render()
		renderReady(self)
		local _functionComponent = self.functionComponent
		local _props = self.props
		local _success, _valueOrError = pcall(_functionComponent, _props)
		local result = _success and {
			success = true,
			value = _valueOrError,
		} or {
			success = false,
			error = _valueOrError,
		}
		renderDone(self)
		if not result.success then
			error("(ComponentWithHooks) " .. result.error)
		end
		return result.value
	end
	function ComponentWithHooks:didMount()
		self:flushEffects()
	end
	function ComponentWithHooks:didUpdate()
		self:flushEffects()
	end
	function ComponentWithHooks:willUnmount()
		self:unmountEffects()
		self.effects.head = nil
	end
	function ComponentWithHooks:flushEffectsHelper(effect)
		if not effect then
			return nil
		end
		local _effectHandles = self.effectHandles
		local _id = effect.id
		local _result = _effectHandles[_id]
		if _result ~= nil then
			_result()
		end
		local handle = effect.callback()
		if handle then
			local _effectHandles_1 = self.effectHandles
			local _id_1 = effect.id
			-- ▼ Map.set ▼
			_effectHandles_1[_id_1] = handle
			-- ▲ Map.set ▲
		end
		self:flushEffectsHelper(effect.next)
	end
	function ComponentWithHooks:flushEffects()
		self:flushEffectsHelper(self.effects.head)
		self.effects.head = nil
		self.effects.tail = nil
	end
	function ComponentWithHooks:unmountEffects()
		-- This does not clean up effects by order of id, but it should not matter
		-- because this is on unmount
		local _effectHandles = self.effectHandles
		local _arg0 = function(handle)
			return handle()
		end
		-- ▼ ReadonlyMap.forEach ▼
		for _k, _v in pairs(_effectHandles) do
			_arg0(_v, _k, _effectHandles)
		end
		-- ▲ ReadonlyMap.forEach ▲
		-- ▼ Map.clear ▼
		table.clear(self.effectHandles)
		-- ▲ Map.clear ▲
	end
end
return {
	ComponentWithHooks = ComponentWithHooks,
}

        end)
    end)
    hMod("with-hooks", "ModuleScript", "Havoc.include.node_modules.roact-hooked.out.with-hooks.with-hooks", "Havoc.include.node_modules.roact-hooked.out.with-hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.7
local TS = _G[script]
local ComponentWithHooks = TS.import(script, script.Parent, "component-with-hooks").ComponentWithHooks
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local function componentWithHooksMixin(ctor)
	for k, v in pairs(ComponentWithHooks) do
		ctor[k] = v
	end
end
local function withHooks(functionComponent)
	local ComponentClass
	do
		ComponentClass = Roact.Component:extend("ComponentClass")
		function ComponentClass:init()
		end
		ComponentClass.functionComponent = functionComponent
	end
	componentWithHooksMixin(ComponentClass)
	return ComponentClass
end
local function withHooksPure(functionComponent)
	local ComponentClass
	do
		ComponentClass = Roact.PureComponent:extend("ComponentClass")
		function ComponentClass:init()
		end
		ComponentClass.functionComponent = functionComponent
	end
	componentWithHooksMixin(ComponentClass)
	return ComponentClass
end
return {
	withHooks = withHooks,
	withHooksPure = withHooksPure,
}

        end)
    end)
    hInst("roact-rodux-hooked", "Folder", "Havoc.include.node_modules.roact-rodux-hooked", "Havoc.include.node_modules")
    hMod("out", "ModuleScript", "Havoc.include.node_modules.roact-rodux-hooked.out", "Havoc.include.node_modules.roact-rodux-hooked", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.3
local TS = _G[script]
local exports = {}
exports.Provider = TS.import(script, script, "components", "provider").Provider
exports.useDispatch = TS.import(script, script, "hooks", "use-dispatch").useDispatch
exports.useSelector = TS.import(script, script, "hooks", "use-selector").useSelector
exports.useStore = TS.import(script, script, "hooks", "use-store").useStore
exports.shallowEqual = TS.import(script, script, "helpers", "shallow-equal").shallowEqual
exports.RoactRoduxContext = TS.import(script, script, "components", "context").RoactRoduxContext
return exports

        end)
    end)
    hInst("components", "Folder", "Havoc.include.node_modules.roact-rodux-hooked.out.components", "Havoc.include.node_modules.roact-rodux-hooked.out")
    hMod("context", "ModuleScript", "Havoc.include.node_modules.roact-rodux-hooked.out.components.context", "Havoc.include.node_modules.roact-rodux-hooked.out.components", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.3
local TS = _G[script]
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local RoactRoduxContext = Roact.createContext(nil)
return {
	RoactRoduxContext = RoactRoduxContext,
}

        end)
    end)
    hMod("provider", "ModuleScript", "Havoc.include.node_modules.roact-rodux-hooked.out.components.provider", "Havoc.include.node_modules.roact-rodux-hooked.out.components", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.3
local TS = _G[script]
local RoactRoduxContext = TS.import(script, script.Parent, "context").RoactRoduxContext
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local hooked = _roact_hooked.hooked
local useMemo = _roact_hooked.useMemo
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
--[[
	*
	* Makes the Rodux store available to the `useStore()` calls in the component hierarchy below.
] ]
local Provider = hooked(function(_param)
	local store = _param.store
	local children = _param[Roact.Children]
	local contextValue = useMemo(function()
		return {
			store = store,
		}
	end, { store })
	local _ptr = {
		value = contextValue,
	}
	local _ptr_1 = {}
	local _length = #_ptr_1
	if children then
		for _k, _v in pairs(children) do
			if type(_k) == "number" then
				_ptr_1[_length + _k] = _v
			else
				_ptr_1[_k] = _v
			end
		end
	end
	return Roact.createElement(RoactRoduxContext.Provider, _ptr, _ptr_1)
end)
return {
	Provider = Provider,
}

        end)
    end)
    hInst("helpers", "Folder", "Havoc.include.node_modules.roact-rodux-hooked.out.helpers", "Havoc.include.node_modules.roact-rodux-hooked.out")
    hMod("shallow-equal", "ModuleScript", "Havoc.include.node_modules.roact-rodux-hooked.out.helpers.shallow-equal", "Havoc.include.node_modules.roact-rodux-hooked.out.helpers", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.3
local TS = _G[script]
local Object = TS.import(script, TS.getModule(script, "@rbxts", "object-utils"))
--[[
	*
	* Compares two arbitrary values for shallow equality. Object values are compared based on their keys, i.e. they must
	* have the same keys and for each key the value must be equal.
] ]
local function shallowEqual(left, right)
	if left == right then
		return true
	end
	if not (type(left) == "table") or not (type(right) == "table") then
		return false
	end
	local keysLeft = Object.keys(left)
	local keysRight = Object.keys(right)
	if #keysLeft ~= #keysRight then
		return false
	end
	local _arg0 = function(value, index)
		return value == right[index]
	end
	-- ▼ ReadonlyArray.every ▼
	local _result = true
	for _k, _v in ipairs(keysLeft) do
		if not _arg0(_v, _k - 1, keysLeft) then
			_result = false
			break
		end
	end
	-- ▲ ReadonlyArray.every ▲
	return _result
end
return {
	shallowEqual = shallowEqual,
}

        end)
    end)
    hInst("hooks", "Folder", "Havoc.include.node_modules.roact-rodux-hooked.out.hooks", "Havoc.include.node_modules.roact-rodux-hooked.out")
    hMod("use-dispatch", "ModuleScript", "Havoc.include.node_modules.roact-rodux-hooked.out.hooks.use-dispatch", "Havoc.include.node_modules.roact-rodux-hooked.out.hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.3
local TS = _G[script]
local useMutable = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).useMutable
local useStore = TS.import(script, script.Parent, "use-store").useStore
--[[
	*
	* A hook to access the Rodux Store's `dispatch` method.
	*
	* @returns Rodux store's `dispatch` method
	*
	* @example
	* import Roact from "@rbxts/roact";
	* import { hooked } from "@rbxts/roact-hooked";
	* import { useDispatch } from "@rbxts/roact-rodux-hooked";
	* import type { RootStore } from "./store";
	*
	* export const CounterComponent = hooked(() => {
	*   const dispatch = useDispatch<RootStore>();
	*   return (
	*     <textlabel
	*       Text={"Increase counter"}
	*       Event={{
	*         Activated: () => dispatch({ type: "increase-counter" }),
	*       }}
	*     />
	*   );
	* });
] ]
local function useDispatch()
	local store = useStore()
	return useMutable(function(action)
		return store:dispatch(action)
	end).current
end
return {
	useDispatch = useDispatch,
}

        end)
    end)
    hMod("use-selector", "ModuleScript", "Havoc.include.node_modules.roact-rodux-hooked.out.hooks.use-selector", "Havoc.include.node_modules.roact-rodux-hooked.out.hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.3
local TS = _G[script]
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out)
local useEffect = _roact_hooked.useEffect
local useMutable = _roact_hooked.useMutable
local useReducer = _roact_hooked.useReducer
local useStore = TS.import(script, script.Parent, "use-store").useStore
--[[
	*
	* This interface allows you to easily create a hook that is properly typed for your store's root state.
	*
	* @example
	* interface RootState {
	*   property: string;
	* }
	*
	* const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
] ]
--[[
	*
	* A hook to access the Rodux Store's state. This hook takes a selector function as an argument. The selector is called
	* with the store state.
	*
	* This hook takes an optional equality comparison function as the second parameter that allows you to customize the
	* way the selected state is compared to determine whether the component needs to be re-rendered.
	*
	* @param selector - The selector function
	* @param equalityFn - The function that will be used to determine equality
	*
	* @returns The selected portion of the state
	*
	* @example
	* import Roact from "@rbxts/roact";
	* import { hooked } from "@rbxts/roact-hooked";
	* import { useSelector } from "@rbxts/roact-rodux-hooked";
	* import type { RootState } from "./store";
	*
	* export const CounterComponent = hooked(() => {
	*   const count = useSelector((state: RootState) => state.counter);
	*   return <textlabel Text={`Counter: ${count}`} />;
	* });
] ]
local function useSelector(selector, equalityFn)
	if equalityFn == nil then
		equalityFn = function(a, b)
			return a == b
		end
	end
	local _binding = useReducer(function(s)
		return s + 1
	end, 0)
	local forceRender = _binding[2]
	local store = useStore()
	local latestSubscriptionCallbackError = useMutable()
	local latestSelector = useMutable()
	local latestStoreState = useMutable()
	local latestSelectedState = useMutable()
	local storeState = store:getState()
	local selectedState
	TS.try(function()
		local _value = selector ~= latestSelector.current or storeState ~= latestStoreState.current or latestSubscriptionCallbackError.current
		if _value ~= "" and _value then
			local newSelectedState = selector(storeState)
			-- ensure latest selected state is reused so that a custom equality function can result in identical references
			if latestSelectedState.current == nil or not equalityFn(newSelectedState, latestSelectedState.current) then
				selectedState = newSelectedState
			else
				selectedState = latestSelectedState.current
			end
		else
			selectedState = latestSelectedState.current
		end
	end, function(err)
		if latestSubscriptionCallbackError.current ~= nil then
			err ..= "\nThe error may be correlated with this previous error:\n" .. latestSubscriptionCallbackError.current .. "\n\n"
		end
		error(err)
	end)
	useEffect(function()
		latestSelector.current = selector
		latestStoreState.current = storeState
		latestSelectedState.current = selectedState
		latestSubscriptionCallbackError.current = nil
	end)
	useEffect(function()
		local function checkForUpdates(newStoreState)
			local _exitType, _returns = TS.try(function()
				-- Avoid calling selector multiple times if the store's state has not changed
				if newStoreState == latestStoreState.current then
					return TS.TRY_RETURN, {}
				end
				local newSelectedState = latestSelector.current(newStoreState)
				if equalityFn(newSelectedState, latestSelectedState.current) then
					return TS.TRY_RETURN, {}
				end
				latestSelectedState.current = newSelectedState
				latestStoreState.current = newStoreState
			end, function(err)
				-- we ignore all errors here, since when the component
				-- is re-rendered, the selectors are called again, and
				-- will throw again, if neither props nor store state
				-- changed
				latestSubscriptionCallbackError.current = err
			end)
			if _exitType then
				return unpack(_returns)
			end
			task.spawn(forceRender)
		end
		local subscription = store.changed:connect(checkForUpdates)
		checkForUpdates(store:getState())
		return function()
			return subscription:disconnect()
		end
	end, { store })
	return selectedState
end
return {
	useSelector = useSelector,
}

        end)
    end)
    hMod("use-store", "ModuleScript", "Havoc.include.node_modules.roact-rodux-hooked.out.hooks.use-store", "Havoc.include.node_modules.roact-rodux-hooked.out.hooks", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.3
local TS = _G[script]
local RoactRoduxContext = TS.import(script, script.Parent.Parent, "components", "context").RoactRoduxContext
local useContext = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").out).useContext
--[[
	*
	* A hook to access the Rodux Store.
	*
	* @returns The Rodux store
	*
	* @example
	* import Roact from "@rbxts/roact";
	* import { hooked } from "@rbxts/roact-hooked";
	* import { useStore } from "@rbxts/roact-rodux-hooked";
	* import type { RootStore } from "./store";
	*
	* export const CounterComponent = hooked(() => {
	*   const store = useStore<RootStore>();
	*   return <textlabel Text={store.getState()} />;
	* });
] ]
local function useStore()
	return useContext(RoactRoduxContext).store
end
return {
	useStore = useStore,
}

        end)
    end)
    hMod("types", "ModuleScript", "Havoc.include.node_modules.roact-rodux-hooked.out.types", "Havoc.include.node_modules.roact-rodux-hooked.out", function()
        return (function(...)
-- Compiled with roblox-ts v1.2.3
--[[
	*
	* A Roact Context
] ]
return nil

        end)
    end)
    hInst("rodux", "Folder", "Havoc.include.node_modules.rodux", "Havoc.include.node_modules")
    hMod("src", "ModuleScript", "Havoc.include.node_modules.rodux.src", "Havoc.include.node_modules.rodux", function()
        return (function(...)
local Store = require(script.Store)
local createReducer = require(script.createReducer)
local combineReducers = require(script.combineReducers)
local makeActionCreator = require(script.makeActionCreator)
local loggerMiddleware = require(script.loggerMiddleware)
local thunkMiddleware = require(script.thunkMiddleware)

return {
	Store = Store,
	createReducer = createReducer,
	combineReducers = combineReducers,
	makeActionCreator = makeActionCreator,
	loggerMiddleware = loggerMiddleware.middleware,
	thunkMiddleware = thunkMiddleware,
}

        end)
    end)
    hMod("services", "ModuleScript", "Havoc.include.node_modules.services", "Havoc.include.node_modules", function()
        return (function(...)
return setmetatable({}, {
	__index = function(self, serviceName)
		local service = game:GetService(serviceName)
		self[serviceName] = service
		return service
	end,
})

        end)
    end)
    hInst("types", "Folder", "Havoc.include.node_modules.types", "Havoc.include.node_modules")
    hInst("include", "Folder", "Havoc.include.node_modules.types.include", "Havoc.include.node_modules.types")
    hInst("generated", "Folder", "Havoc.include.node_modules.types.include.generated", "Havoc.include.node_modules.types.include")

    hInit()
end

start()
