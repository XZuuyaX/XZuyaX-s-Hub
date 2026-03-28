local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Library = {}
Library._notificationGui = nil
Library._notificationHolder = nil

local DEFAULT_THEME = {
	Background = Color3.fromRGB(18, 18, 24),
	Panel = Color3.fromRGB(24, 24, 32),
	Panel2 = Color3.fromRGB(30, 30, 40),
	Accent = Color3.fromRGB(130, 90, 255),
	Accent2 = Color3.fromRGB(95, 220, 255),
	Text = Color3.fromRGB(245, 245, 255),
	SubText = Color3.fromRGB(170, 170, 185),
	Stroke = Color3.fromRGB(60, 60, 78),
	Success = Color3.fromRGB(65, 200, 120),
	Danger = Color3.fromRGB(255, 90, 90),
}

local function mergeTheme(custom)
	local theme = {}
	for k, v in pairs(DEFAULT_THEME) do
		theme[k] = v
	end
	if type(custom) == "table" then
		for k, v in pairs(custom) do
			theme[k] = v
		end
	end
	return theme
end

local function create(className, props)
	local inst = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			inst[k] = v
		end
	end
	return inst
end

local function tween(obj, props, duration, style, direction)
	local info = TweenInfo.new(
		duration or 0.2,
		style or Enum.EasingStyle.Quart,
		direction or Enum.EasingDirection.Out
	)
	local tw = TweenService:Create(obj, info, props)
	tw:Play()
	return tw
end

local function roundify(obj, radius)
	local corner = create("UICorner", {
		CornerRadius = UDim.new(0, radius or 10),
	})
	corner.Parent = obj
	return corner
end

local function addStroke(obj, color, transparency, thickness)
	local stroke = create("UIStroke", {
		Color = color or Color3.new(1, 1, 1),
		Transparency = transparency or 0.7,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
	stroke.Parent = obj
	return stroke
end

local function copyArray(src)
	local out = {}
	for i, v in ipairs(src or {}) do
		out[i] = v
	end
	return out
end

local function safeDestroy(inst)
	if inst then
		pcall(function()
			inst:Destroy()
		end)
	end
end

function Library:_ensureNotificationGui()
	if self._notificationGui and self._notificationGui.Parent then
		return
	end

	local gui = create("ScreenGui", {
		Name = "ModernUILibrary_Notifications",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = CoreGui,
	})

	local holder = create("Frame", {
		Name = "Holder",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.new(0, 340, 1, -32),
		BackgroundTransparency = 1,
		Parent = gui,
	})

	local padding = create("UIPadding", {
		PaddingTop = UDim.new(0, 8),
	})
	padding.Parent = holder

	local layout = create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10),
	})
	layout.Parent = holder

	self._notificationGui = gui
	self._notificationHolder = holder
end

function Library:Notify(titleText, messageText, duration)
	self:_ensureNotificationGui()

	local theme = DEFAULT_THEME
	local notif = create("Frame", {
		Size = UDim2.new(1, 0, 0, 78),
		BackgroundColor3 = theme.Panel,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = self._notificationHolder,
		LayoutOrder = math.floor(os.clock() * 1000),
	})
	roundify(notif, 14)
	addStroke(notif, theme.Stroke, 0.55, 1)

	local accent = create("Frame", {
		Name = "Accent",
		Size = UDim2.new(0, 4, 1, -14),
		Position = UDim2.new(0, 10, 0, 7),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Parent = notif,
	})
	roundify(accent, 12)

	local title = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 22, 0, 8),
		Size = UDim2.new(1, -34, 0, 20),
		Font = Enum.Font.GothamBold,
		Text = tostring(titleText or "Notification"),
		TextColor3 = theme.Text,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = notif,
	})

	local body = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 22, 0, 30),
		Size = UDim2.new(1, -34, 0, 36),
		Font = Enum.Font.Gotham,
		Text = tostring(messageText or ""),
		TextColor3 = theme.SubText,
		TextSize = 13,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = notif,
	})

	local scale = create("UIScale", {
		Scale = 0.92,
	})
	scale.Parent = notif

	tween(notif, {BackgroundTransparency = 0}, 0.22)
	tween(scale, {Scale = 1}, 0.28)

	local life = tonumber(duration) or 2.5
	task.delay(math.max(life, 0.5), function()
		if notif and notif.Parent then
			tween(scale, {Scale = 0.96}, 0.16)
			tween(notif, {BackgroundTransparency = 1}, 0.18)
			task.wait(0.18)
			safeDestroy(notif)
		end
	end)
end

function Library:CreateWindow(config)
	if type(config) == "string" then
		config = { Title = config }
	end
	config = config or {}

	local theme = mergeTheme(config.Theme)
	local windowTitle = config.Title or "UI Library"
	local windowSubTitle = config.SubTitle or "Modern Hub"
	local iconImage = config.Icon or "rbxassetid://7072719338"
	local size = config.Size or UDim2.new(0, 520, 0, 420)

	local gui = create("ScreenGui", {
		Name = "ModernUILibrary",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = CoreGui,
	})

	local main = create("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = gui,
	})
	roundify(main, 18)
	addStroke(main, theme.Stroke, 0.55, 1)

	local topbar = create("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		Parent = main,
	})
	roundify(topbar, 18)

	local topMask = create("Frame", {
		Name = "TopMask",
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0.5, 0),
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		Parent = topbar,
	})

	local topStroke = create("Frame", {
		Name = "BottomLine",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.new(1, -18, 0, 1),
		BackgroundColor3 = theme.Stroke,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Parent = topbar,
	})

	local accentLine = create("Frame", {
		Name = "AccentLine",
		Position = UDim2.new(0, 0, 1, -2),
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Parent = topbar,
	})

	local topContent = create("Frame", {
		Name = "TopContent",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 0),
		Size = UDim2.new(1, -28, 1, 0),
		Parent = topbar,
	})

	local icon = create("ImageLabel", {
		Name = "Icon",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0.5, -15),
		Size = UDim2.new(0, 30, 0, 30),
		Image = iconImage,
		ImageColor3 = theme.Accent,
		ScaleType = Enum.ScaleType.Fit,
		Parent = topContent,
	})

	local title = create("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 40, 0, 10),
		Size = UDim2.new(1, -140, 0, 18),
		Font = Enum.Font.GothamBold,
		Text = tostring(windowTitle),
		TextColor3 = theme.Text,
		TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topContent,
	})

	local subtitle = create("TextLabel", {
		Name = "Subtitle",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 40, 0, 29),
		Size = UDim2.new(1, -140, 0, 14),
		Font = Enum.Font.Gotham,
		Text = tostring(windowSubTitle),
		TextColor3 = theme.SubText,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topContent,
	})

	local destroyBtn = create("TextButton", {
		Name = "Destroy",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 28, 0, 28),
		Text = "×",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = theme.Text,
		BackgroundColor3 = theme.Panel2,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = topContent,
	})
	roundify(destroyBtn, 8)
	addStroke(destroyBtn, theme.Stroke, 0.65, 1)

	local body = create("ScrollingFrame", {
		Name = "Body",
		Position = UDim2.new(0, 0, 0, 56),
		Size = UDim2.new(1, 0, 1, -56),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarImageColor3 = theme.Accent,
		ScrollBarImageTransparency = 0.3,
		ScrollBarThickness = 3,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.None,
		Parent = main,
	})

	local padding = create("UIPadding", {
		PaddingTop = UDim.new(0, 14),
		PaddingLeft = UDim.new(0, 14),
		PaddingRight = UDim.new(0, 14),
		PaddingBottom = UDim.new(0, 14),
	})
	padding.Parent = body

	local bodyLayout = create("UIListLayout", {
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	})
	bodyLayout.Parent = body

	bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		body.CanvasSize = UDim2.new(0, 0, 0, bodyLayout.AbsoluteContentSize.Y + 28)
	end)

	local connections = {}
	local function track(conn)
		table.insert(connections, conn)
		return conn
	end

	local dragging = false
	local dragStart
	local startPos

	track(topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
		end
	end))

	track(UIS.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end))

	track(UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))

	local Window = {}
	Window._gui = gui
	Window._main = main
	Window._body = body
	Window._theme = theme

	local function makeRow(height)
		local holder = create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, height),
			Parent = body,
		})
		return holder
	end

	local function makeCard(height)
		local card = create("Frame", {
			Size = UDim2.new(1, 0, 0, height),
			BackgroundColor3 = theme.Panel,
			BorderSizePixel = 0,
			Parent = body,
		})
		roundify(card, 14)
		addStroke(card, theme.Stroke, 0.7, 1)
		return card
	end

	local function animateMainIn()
		main.Size = UDim2.new(0, 0, 0, 0)
		main.BackgroundTransparency = 1
		tween(main, {
			Size = size,
			BackgroundTransparency = 0,
		}, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	end

	function Window:Button(text, callback)
		local row = makeRow(42)

		local btn = create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = theme.Panel2,
			BorderSizePixel = 0,
			Text = tostring(text or "Button"),
			Font = Enum.Font.GothamSemibold,
			TextSize = 14,
			TextColor3 = theme.Text,
			AutoButtonColor = false,
			Parent = row,
		})
		roundify(btn, 12)
		addStroke(btn, theme.Stroke, 0.78, 1)

		local hoverAccent = create("Frame", {
			BackgroundColor3 = theme.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Parent = btn,
		})
		roundify(hoverAccent, 12)

		btn.MouseEnter:Connect(function()
			tween(btn, {BackgroundColor3 = theme.Panel}, 0.16)
			tween(hoverAccent, {BackgroundTransparency = 0.92}, 0.16)
		end)

		btn.MouseLeave:Connect(function()
			tween(btn, {BackgroundColor3 = theme.Panel2}, 0.16)
			tween(hoverAccent, {BackgroundTransparency = 1}, 0.16)
		end)

		btn.MouseButton1Click:Connect(function()
			tween(btn, {BackgroundColor3 = theme.Accent}, 0.12)
			task.delay(0.12, function()
				if btn and btn.Parent then
					tween(btn, {BackgroundColor3 = theme.Panel2}, 0.18)
				end
			end)

			if callback then
				task.spawn(callback)
			end
		end)
	end

	function Window:Toggle(text, default, callback)
		local state = default and true or false
		local row = makeRow(46)

		local btn = create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = theme.Panel2,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			Parent = row,
		})
		roundify(btn, 12)
		addStroke(btn, theme.Stroke, 0.78, 1)

		local label = create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 14, 0, 0),
			Size = UDim2.new(1, -80, 1, 0),
			Font = Enum.Font.GothamSemibold,
			Text = tostring(text or "Toggle"),
			TextColor3 = theme.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = btn,
		})

		local pill = create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.new(0, 44, 0, 22),
			BackgroundColor3 = state and theme.Accent or theme.Panel,
			BorderSizePixel = 0,
			Parent = btn,
		})
		roundify(pill, 999)
		addStroke(pill, theme.Stroke, 0.75, 1)

		local knob = create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = state and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
			Size = UDim2.new(0, 18, 0, 18),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			Parent = pill,
		})
		roundify(knob, 999)

		local function setState(v)
			state = v and true or false
			tween(pill, {BackgroundColor3 = state and theme.Accent or theme.Panel}, 0.16)
			tween(knob, {
				Position = state and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
			}, 0.18)
			if callback then
				task.spawn(callback, state)
			end
		end

		btn.MouseEnter:Connect(function()
			tween(btn, {BackgroundColor3 = theme.Panel}, 0.14)
		end)

		btn.MouseLeave:Connect(function()
			tween(btn, {BackgroundColor3 = theme.Panel2}, 0.14)
		end)

		btn.MouseButton1Click:Connect(function()
			setState(not state)
		end)

		setState(state)
	end

	local function createDropdownBase(text, list, callback, multi)
		local items = list or {}
		local rowHeight = 44
		local itemHeight = 32
		local visibleHeight = math.min(#items * itemHeight, 180)
		local closedHeight = rowHeight
		local openHeight = rowHeight + visibleHeight

		local holder = makeRow(closedHeight)
		holder.ClipsDescendants = true

		local card = create("Frame", {
			Size = UDim2.new(1, 0, 0, closedHeight),
			BackgroundColor3 = theme.Panel,
			BorderSizePixel = 0,
			Parent = holder,
		})
		roundify(card, 12)
		addStroke(card, theme.Stroke, 0.78, 1)

		local header = create("TextButton", {
			Size = UDim2.new(1, 0, 0, rowHeight),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Parent = card,
		})

		local titleLabel = create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 14, 0, 0),
			Size = UDim2.new(1, -60, 1, 0),
			Font = Enum.Font.GothamSemibold,
			Text = tostring(text or "Dropdown"),
			TextColor3 = theme.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = header,
		})

		local arrow = create("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -14, 0.5, 0),
			Size = UDim2.new(0, 18, 0, 18),
			Font = Enum.Font.GothamBold,
			Text = "⌄",
			TextColor3 = theme.SubText,
			TextSize = 16,
			Rotation = 0,
			Parent = header,
		})

		local listFrame = create("ScrollingFrame", {
			Position = UDim2.new(0, 10, 0, rowHeight + 6),
			Size = UDim2.new(1, -20, 0, 0),
			BackgroundColor3 = theme.Panel2,
			BorderSizePixel = 0,
			ScrollBarImageColor3 = theme.Accent,
			ScrollBarImageTransparency = 0.35,
			ScrollBarThickness = 3,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.None,
			ClipsDescendants = true,
			Visible = true,
			Parent = card,
		})
		roundify(listFrame, 10)
		addStroke(listFrame, theme.Stroke, 0.82, 1)

		local listPad = create("UIPadding", {
			PaddingTop = UDim.new(0, 6),
			PaddingBottom = UDim.new(0, 6),
			PaddingLeft = UDim.new(0, 6),
			PaddingRight = UDim.new(0, 6),
		})
		listPad.Parent = listFrame

		local listLayout = create("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
		listLayout.Parent = listFrame

		listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 12)
		end)

		local open = false
		local selected = {}
		local optionButtons = {}

		local function refreshText()
			if multi then
				if #selected == 0 then
					titleLabel.Text = tostring(text or "Dropdown")
				else
					titleLabel.Text = tostring(text or "Dropdown") .. " (" .. tostring(#selected) .. ")"
				end
			else
				if selected[1] then
					titleLabel.Text = tostring(text or "Dropdown") .. ": " .. tostring(selected[1])
				else
					titleLabel.Text = tostring(text or "Dropdown")
				end
			end
		end

		local function emit()
			if callback then
				if multi then
					task.spawn(callback, copyArray(selected))
				else
					task.spawn(callback, selected[1])
				end
			end
		end

		local function setOpen(v)
			open = v and true or false

			if open then
				listFrame.Visible = true
				tween(holder, {Size = UDim2.new(1, 0, 0, openHeight)}, 0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				tween(card, {Size = UDim2.new(1, 0, 0, openHeight)}, 0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				tween(listFrame, {Size = UDim2.new(1, -20, 0, visibleHeight)}, 0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				tween(arrow, {Rotation = 180}, 0.2)
			else
				tween(holder, {Size = UDim2.new(1, 0, 0, closedHeight)}, 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				tween(card, {Size = UDim2.new(1, 0, 0, closedHeight)}, 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				tween(listFrame, {Size = UDim2.new(1, -20, 0, 0)}, 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				tween(arrow, {Rotation = 0}, 0.18)
				task.delay(0.23, function()
					if listFrame and listFrame.Parent and not open then
						listFrame.Visible = true
					end
				end)
			end
		end

		local function setOptionState(name, button)
			if multi then
				local idx = table.find(selected, name)
				local chosen = idx ~= nil

				button.Text = (chosen and "✓ " or "  ") .. name
				button.TextColor3 = chosen and theme.Accent2 or theme.Text
				button.BackgroundColor3 = chosen and theme.Accent or theme.Panel

				if chosen then
					table.remove(selected, idx)
				else
					table.insert(selected, name)
				end
			else
				selected[1] = name
				refreshText()
				emit()
				setOpen(false)
				for _, btn in ipairs(optionButtons) do
					if btn.Name == name then
						btn.BackgroundColor3 = theme.Panel
						btn.TextColor3 = theme.Text
					else
						btn.BackgroundColor3 = theme.Panel2
						btn.TextColor3 = theme.Text
					end
				end
				return
			end

			refreshText()
			emit()
		end

		for _, name in ipairs(items) do
			local opt = create("TextButton", {
				Name = tostring(name),
				Size = UDim2.new(1, 0, 0, itemHeight),
				BackgroundColor3 = theme.Panel2,
				BorderSizePixel = 0,
				Text = multi and ("  " .. tostring(name)) or tostring(name),
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutoButtonColor = false,
				Parent = listFrame,
			})
			roundify(opt, 8)
			addStroke(opt, theme.Stroke, 0.9, 1)

			local leftPad = create("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			})
			leftPad.Parent = opt

			opt.MouseEnter:Connect(function()
				if not table.find(selected, name) then
					tween(opt, {BackgroundColor3 = theme.Panel}, 0.12)
				end
			end)

			opt.MouseLeave:Connect(function()
				if not table.find(selected, name) then
					tween(opt, {BackgroundColor3 = theme.Panel2}, 0.12)
				end
			end)

			opt.MouseButton1Click:Connect(function()
				if multi then
					setOptionState(name, opt)
				else
					setOptionState(name, opt)
				end
			end)

			table.insert(optionButtons, opt)
		end

		if multi then
			refreshText()
		end

		header.MouseEnter:Connect(function()
			tween(card, {BackgroundColor3 = theme.Panel2}, 0.12)
		end)

		header.MouseLeave:Connect(function()
			tween(card, {BackgroundColor3 = theme.Panel}, 0.12)
		end)

		header.MouseButton1Click:Connect(function()
			setOpen(not open)
		end)

		return {
			Set = function(_, value)
				if multi then
					selected = {}
					if type(value) == "table" then
						for _, v in ipairs(value) do
							table.insert(selected, v)
						end
					end
					for _, btn in ipairs(optionButtons) do
						local chosen = table.find(selected, btn.Name) ~= nil
						btn.Text = (chosen and "✓ " or "  ") .. btn.Name
						btn.TextColor3 = chosen and theme.Accent2 or theme.Text
						btn.BackgroundColor3 = chosen and theme.Accent or theme.Panel2
					end
					refreshText()
					emit()
				else
					selected[1] = value
					for _, btn in ipairs(optionButtons) do
						if btn.Name == tostring(value) then
							btn.BackgroundColor3 = theme.Accent
							btn.TextColor3 = theme.Accent2
						else
							btn.BackgroundColor3 = theme.Panel2
							btn.TextColor3 = theme.Text
						end
					end
					refreshText()
					emit()
				end
			end,
			Open = function()
				setOpen(true)
			end,
			Close = function()
				setOpen(false)
			end,
		}
	end

	function Window:Dropdown(text, list, callback)
		return createDropdownBase(text, list, callback, false)
	end

	function Window:MultiDropdown(text, list, callback)
		return createDropdownBase(text, list, callback, true)
	end

	function Window:Label(text)
		local row = makeRow(30)

		local label = create("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = tostring(text or "Label"),
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
		return label
	end

	function Window:Notify(titleText, messageText, duration)
		Library:Notify(titleText, messageText, duration)
	end

	function Window:Destroy()
		for _, conn in ipairs(connections) do
			pcall(function()
				conn:Disconnect()
			end)
		end
		safeDestroy(gui)
	end

	destroyBtn.MouseEnter:Connect(function()
		tween(destroyBtn, {BackgroundColor3 = theme.Danger}, 0.12)
	end)

	destroyBtn.MouseLeave:Connect(function()
		tween(destroyBtn, {BackgroundColor3 = theme.Panel2}, 0.12)
	end)

	destroyBtn.MouseButton1Click:Connect(function()
		Window:Destroy()
	end)

	animateMainIn()
	Library:Notify("Library Loaded", tostring(windowTitle) .. " siap dipakai.", 2.2)

	return Window
end

return Library
