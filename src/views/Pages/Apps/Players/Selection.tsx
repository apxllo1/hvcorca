-- out/views/Pages/Apps/Players/Selection.lua (Orca v1.1.1)
return setfenv(function()
    local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
    local Roact = TS.import(script, TS.getModule(script, "@rbxts/roact.src"))
    local hooked = TS.import(script, TS.getModule(script, "@rbxts/roact-hooked.out.hooked"))
    local useEffect = TS.import(script, TS.getModule(script, "@rbxts/roact-hooked.out.useEffect"))
    local useMemo = TS.import(script, TS.getModule(script, "@rbxts/roact-hooked.out.useMemo"))
    local useState = TS.import(script, TS.getModule(script, "@rbxts/roact-hooked.out.useState"))
    local Players = TS.import(script, TS.getModule(script, "@rbxts/services.Players"))
    local TextService = TS.import(script, TS.getModule(script, "@rbxts/services.TextService"))
    local Border = TS.import(script, TS.getModule(script, "components/Border.default"))
    local Canvas = TS.import(script, TS.getModule(script, "components/Canvas.default"))
    local Fill = TS.import(script, TS.getModule(script, "components/Fill.default"))
    local Glow = TS.import(script, TS.getModule(script, "components/Glow.default"))
    local GlowRadius = TS.import(script, TS.getModule(script, "components/Glow.GlowRadius"))
    local IS_DEV = TS.import(script, TS.getModule(script, "constants.IS_DEV"))
    local useLinear = TS.import(script, TS.getModule(script, "hooks/common/flipper-hooks.useLinear"))
    local useAppDispatch = TS.import(script, TS.getModule(script, "hooks/common/rodux-hooks.useAppDispatch"))
    local useAppSelector = TS.import(script, TS.getModule(script, "hooks/common/rodux-hooks.useAppSelector"))
    local useDelayedUpdate = TS.import(script, TS.getModule(script, "hooks/common/use-delayed-update.useDelayedUpdate"))
    local useSpring = TS.import(script, TS.getModule(script, "hooks/common/use-spring.useSpring"))
    local useIsPageOpen = TS.import(script, TS.getModule(script, "hooks/use-current-page.useIsPageOpen"))
    local useTheme = TS.import(script, TS.getModule(script, "hooks/use-theme.useTheme"))
    local playerDeselected = TS.import(script, TS.getModule(script, "store/actions/dashboard.action.playerDeselected"))
    local playerSelected = TS.import(script, TS.getModule(script, "store/actions/dashboard.action.playerSelected"))
    local DashboardPage = TS.import(script, TS.getModule(script, "store/models/dashboard.model.DashboardPage"))
    local arrayToMap = TS.import(script, TS.getModule(script, "utils/array-util.arrayToMap"))
    local lerp = TS.import(script, TS.getModule(script, "utils/number-util.lerp"))
    local px = TS.import(script, TS.getModule(script, "utils/udim2.px"))
    local scale = TS.import(script, TS.getModule(script, "utils/udim2.scale"))

    local PADDING = 20
    local ENTRY_HEIGHT = 60
    local ENTRY_WIDTH = 326 - 24 * 2
    local ENTRY_TEXT_PADDING = 60

    local textFadeSequence = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.05, 0),
        NumberSequenceKeypoint.new(0.9, 0),
        NumberSequenceKeypoint.new(0.95, 1),
        NumberSequenceKeypoint.new(1, 1),
    })

    local function usePlayers()
        local players, setPlayers = useState(Players.GetPlayers())
        useEffect(function()
            local addedHandle = Players.PlayerAdded:Connect(function()
                setPlayers(Players.GetPlayers())
            end)
            local removingHandle = Players.PlayerRemoving:Connect(function()
                setPlayers(Players.GetPlayers())
            end)
            return function()
                addedHandle:Disconnect()
                removingHandle:Disconnect()
            end
        end, {})
        return players
    end

    local function Selection()
        local dispatch = useAppDispatch()
        local players = usePlayers()
        local playerSelected = useAppSelector(function(state)
            return state.dashboard.apps.playerSelected
        end)

        local sortedPlayers = useMemo(function()
            local selected = players:find(function(p) return p.Name == playerSelected end)
            local filtered = players:filter(function(p) 
                return p.Name ~= playerSelected and (p ~= Players.LocalPlayer or IS_DEV)
            end):sort(function(a, b) return string.lower(a.Name) < string.lower(b.Name) end)
            return selected and {selected, unpack(filtered)} or filtered
        end, {players, playerSelected})

        useEffect(function()
            if playerSelected ~= undefined and not sortedPlayers:find(function(player) 
                return player.Name == playerSelected 
            end) then
                dispatch(playerDeselected())
            end
        end, {players, playerSelected})

        return Roact.createElement(Canvas, {
            size = px(326, 280),
            position = px(0, 368),
            padding = {left = 24, right = 24, top = 8},
            clipsDescendants = true,
        }, {
            scrollingframe = Roact.createElement("ScrollingFrame", {
                Size = scale(1, 1),
                CanvasSize = px(0, #sortedPlayers * (ENTRY_HEIGHT + PADDING) + PADDING),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                ClipsDescendants = false,
            }, arrayToMap(sortedPlayers, function(player, index)
                return {player.Name, Roact.createElement(PlayerEntry, {
                    name = player.Name,
                    displayName = player.DisplayName,
                    userId = player.UserId,
                    index = index,
                })}
            end)),
        })
    end

    local function PlayerEntryComponent(props)
        local dispatch = useAppDispatch()
        local theme = useTheme("apps").players.playerButton
        local isOpen = useIsPageOpen(DashboardPage.Apps)
        local isVisible = useDelayedUpdate(isOpen, isOpen and 170 + props.index * 40 or 150)
        local isSelected = useAppSelector(function(state)
            return state.dashboard.apps.playerSelected == props.name
        end)
        local hovered, setHovered = useState(false)

        local text = "  " .. props.displayName .. " (@" .. props.name .. ")"
        local textSize = useMemo(function()
            return TextService:GetTextSize(text, 14, Enum.Font.GothamBold, Vector2.new(1000, ENTRY_HEIGHT))
        end, {text})

        local textScrollOffset = useLinear(hovered and ENTRY_WIDTH - ENTRY_TEXT_PADDING - 20 - textSize.X or 0, {
            velocity = hovered and 40 or 150,
        }):map(function(x)
            return UDim.new(0, math.min(x, 0))
        end)

        local background = useSpring(isSelected and theme.accent or 
            hovered and (theme.backgroundHovered or theme.background:lerp(theme.accent, 0.1)) or theme.background, {})

        local dropshadow = useSpring(isSelected and theme.accent or 
            hovered and (theme.backgroundHovered or theme.dropshadow:lerp(theme.accent, 0.5)) or theme.dropshadow, {})

        local foreground = useSpring(isSelected and theme.foregroundAccent or theme.foreground, {})

        return Roact.createElement(Canvas, {
            size = px(ENTRY_WIDTH, ENTRY_HEIGHT),
            position = useSpring(isVisible and px(0, (PADDING + ENTRY_HEIGHT) * props.index) or 
                px(-ENTRY_WIDTH - 24, (PADDING + ENTRY_HEIGHT) * props.index), {}),
            zIndex = props.index,
        }, {
            underglow = Roact.createElement(Glow, {
                radius = GlowRadius.Size70,
                color = dropshadow,
                size = UDim2.new(1, 36, 1, 36),
                position = px(-18, 5 - 18),
                transparency = useSpring(isSelected and theme.glowTransparency or 
                    hovered and lerp(theme.dropshadowTransparency, theme.glowTransparency, 0.5) or 
                    theme.dropshadowTransparency, {}),
            }),
            body = Roact.createElement(Fill, {
                color = background,
                transparency = useSpring(theme.backgroundTransparency, {}),
                radius = 8,
            }),
            text = Roact.createElement("TextLabel", {
                Text = text,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = foreground,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                TextTransparency = useSpring(isSelected and 0 or hovered and theme.foregroundTransparency / 2 or 
                    theme.foregroundTransparency, {}),
                BackgroundTransparency = 1,
                Position = px(ENTRY_TEXT_PADDING, 1),
                Size = UDim2.new(1, -ENTRY_TEXT_PADDING, 1, -1),
                ClipsDescendants = true,
            }, {
                uipadding = Roact.createElement("UIPadding", {PaddingLeft = textScrollOffset}),
                uigradient = Roact.createElement("UIGradient", {Transparency = textFadeSequence}),
            }),
            avatar = Roact.createElement("ImageLabel", {
                Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(props.userId) .. 
                        "&width=60&height=60&format=png",
                Size = UDim2.new(0, ENTRY_HEIGHT, 0, ENTRY_HEIGHT),
                BackgroundTransparency = 1,
            }, {
                uicorner = Roact.createElement("UICorner", {CornerRadius = UDim.new(0, 8)}),
            }),
            border = theme.outlined and Roact.createElement(Border, {
                color = foreground,
                transparency = 0.8,
                radius = 8,
            }),
            button = Roact.createElement("TextButton", {
                [Roact.Event.Activated] = function()
                    local player = Players:FindFirstChild(props.name)
                    if not isSelected and player and player:IsA("Player") then
                        dispatch(playerSelected(player))
                    else
                        dispatch(playerDeselected())
                    end
                end,
                [Roact.Event.MouseEnter] = function() setHovered(true) end,
                [Roact.Event.MouseLeave] = function() setHovered(false) end,
                Text = "",
                Transparency = 1,
                Size = scale(1, 1),
            }),
        })
    end

    local PlayerEntry = hooked(PlayerEntryComponent)
    return hooked(Selection)
end, hEnv("views/Pages/Apps/Players/Selection"))
