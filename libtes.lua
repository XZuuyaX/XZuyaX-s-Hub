local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

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

-- Helper untuk membuat ikon dari asset id
local function makeIcon(assetId, size)
	local icon = create("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, size, 0, size),
		Image = assetId,
		ScaleType = Enum.ScaleType.Fit,
	})
	return icon
end

-- Helper untuk membuat tombol dengan ikon (untuk topbar)
local function makeIconButton(iconText, callback, theme, tooltip)
	local btn = create("TextButton", {
		Size = UDim2.new(0, 28, 0, 28),
		Text = iconText,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = theme.Text,
		BackgroundColor3 = theme.Panel2,
		AutoButtonColor = false,
		BorderSizePixel = 0,
	})
	roundify(btn, 8)
	addStroke(btn, theme.Stroke, 0.65, 1)

	if tooltip then
		local tip = create("TextLabel", {
			Text = tooltip,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = theme.Text,
			BackgroundColor3 = theme.Panel,
			BackgroundTransparency = 0.2,
			Size = UDim2.new(0, 80, 0, 24),
			Position = UDim2.new(0.5, -40, 1, 4),
			Visible = false,
			ZIndex = 2,
			Parent = btn,
		})
		roundify(tip, 6)
		addStroke(tip, theme.Stroke, 0.8, 1)

		btn.MouseEnter:Connect(function()
			tip.Visible = true
		end)
		btn.MouseLeave:Connect(function()
			tip.Visible = false
		end)
	end

	btn.MouseEnter:Connect(function()
		tween(btn, {BackgroundColor3 = theme.Panel}, 0.12)
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, {BackgroundColor3 = theme.Panel2}, 0.12)
	end)
	btn.MouseButton1Click:Connect(callback)
	return btn
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
	local size = config.Size or UDim2.new(0, 680, 0, 480)  -- Lebar lebih besar untuk sidebar

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

	-- Topbar
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
		Size = UDim2.new(1, -200, 0, 18),
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
		Size = UDim2.new(1, -200, 0, 14),
		Font = Enum.Font.Gotham,
		Text = tostring(windowSubTitle),
		TextColor3 = theme.SubText,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topContent,
	})

	-- Tombol kontrol window (minimize, maximize, close)
	local btnContainer = create("Frame", {
		Name = "ButtonContainer",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.new(0, 96, 0, 32),
		BackgroundTransparency = 1,
		Parent = topContent,
	})

	local minimizeBtn = makeIconButton("−", function()
		if minimized then
			-- Restore
			main.Size = originalSize
			main.Position = originalPosition
			body.Visible = true
			minimized = false
		else
			-- Minimize
			originalSize = main.Size
			originalPosition = main.Position
			main.Size = UDim2.new(0, originalSize.X.Offset, 0, 56)  -- Hanya topbar
			body.Visible = false
			minimized = true
		end
	end, theme, "Minimize")

	local maximizeBtn = makeIconButton("□", function()
		if maximized then
			-- Restore
			main.Size = originalSize
			main.Position = originalPosition
			maximized = false
		else
			-- Maximize
			originalSize = main.Size
			originalPosition = main.Position
			local viewport = workspace.CurrentCamera.ViewportSize
			main.Size = UDim2.new(0, viewport.X - 40, 0, viewport.Y - 40)
			main.Position = UDim2.new(0.5, 0, 0.5, 0)
			maximized = true
		end
	end, theme, "Maximize")

	local destroyBtn = makeIconButton("×", function()
		Window:Destroy()
	end, theme, "Close")

	-- Tata letak tombol
	local btnLayout = create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
	})
	btnLayout.Parent = btnContainer

	minimizeBtn.Parent = btnContainer
	maximizeBtn.Parent = btnContainer
	destroyBtn.Parent = btnContainer

	-- Body utama (sidebar + content)
	local body = create("Frame", {
		Name = "Body",
		Position = UDim2.new(0, 0, 0, 56),
		Size = UDim2.new(1, 0, 1, -56),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = main,
	})

	-- Sidebar (kiri)
	local sidebar = create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 220, 1, 0),
		BackgroundColor3 = theme.Panel2,
		BorderSizePixel = 0,
		Parent = body,
	})
	roundify(sidebar, 12)
	addStroke(sidebar, theme.Stroke, 0.7, 1)

	-- Profile section di sidebar
	local profileFrame = create("Frame", {
		Name = "Profile",
		Size = UDim2.new(1, 0, 0, 80),
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		Parent = sidebar,
	})
	roundify(profileFrame, 12)
	addStroke(profileFrame, theme.Stroke, 0.7, 1)

	-- Avatar
	local avatar = create("ImageLabel", {
		Name = "Avatar",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0.5, -25),
		Size = UDim2.new(0, 50, 0, 50),
		Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=100&h=100",
		ScaleType = Enum.ScaleType.Fit,
		Parent = profileFrame,
	})
	roundify(avatar, 25)
	addStroke(avatar, theme.Stroke, 0.5, 1)

	-- Nama user
	local userName = create("TextLabel", {
		Name = "UserName",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 72, 0.5, -15),
		Size = UDim2.new(1, -84, 0, 24),
		Font = Enum.Font.GothamBold,
		Text = LocalPlayer.Name,
		TextColor3 = theme.Text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = profileFrame,
	})

	-- Status (online)
	local status = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 72, 0.5, 10),
		Size = UDim2.new(1, -84, 0, 18),
		Font = Enum.Font.Gotham,
		Text = "Online",
		TextColor3 = theme.Success,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = profileFrame,
	})

	-- Tab buttons container
	local tabContainer = create("ScrollingFrame", {
		Name = "TabContainer",
		Position = UDim2.new(0, 0, 0, 90),
		Size = UDim2.new(1, 0, 1, -90),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = sidebar,
	})

	local tabList = create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	tabList.Parent = tabContainer

	-- Content area (kanan)
	local contentArea = create("Frame", {
		Name = "ContentArea",
		Position = UDim2.new(0, 228, 0, 0),
		Size = UDim2.new(1, -236, 1, 0),
		BackgroundTransparency = 1,
		Parent = body,
	})

	-- Variabel untuk tabs
	local tabs = {}
	local activeTab = nil
	local minimized = false
	local maximized = false
	local originalSize = size
	local originalPosition = main.Position

	-- Fungsi untuk membuat konten tab (scrolling frame)
	local function createTabContent()
		local tabFrame = create("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarImageColor3 = theme.Accent,
			ScrollBarThickness = 3,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.None,
			Visible = false,
			Parent = contentArea,
		})

		local padding = create("UIPadding", {
			PaddingTop = UDim.new(0, 14),
			PaddingLeft = UDim.new(0, 14),
			PaddingRight = UDim.new(0, 14),
			PaddingBottom = UDim.new(0, 14),
		})
		padding.Parent = tabFrame

		local layout = create("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		})
		layout.Parent = tabFrame

		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			tabFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 28)
		end)

		return tabFrame, layout
	end

	-- Fungsi untuk menambahkan elemen ke tab
	local function addElement(parent, type, ...)
		-- ... akan diisi sesuai method
		-- Karena kita akan membuat method di object tab, kita akan panggil fungsi pembuat elemen dengan parent yang sesuai
	end

	-- Kelas Tab
	local Tab = {}
	Tab.__index = Tab

	function Tab:Button(text, callback, iconAsset)
		local row = create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 42),
			Parent = self._content,
		})

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

		-- Ikon jika ada
		if iconAsset then
			local iconImg = makeIcon(iconAsset, 20)
			iconImg.Position = UDim2.new(0, 12, 0.5, -10)
			iconImg.Parent = btn
		end

		local label = create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, iconAsset and 42 or 14, 0, 0),
			Size = UDim2.new(1, -60, 1, 0),
			Font = Enum.Font.GothamSemibold,
			Text = tostring(text),
			TextColor3 = theme.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = btn,
		})

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

	function Tab:Toggle(text, default, callback, iconAsset)
		local state = default and true or false
		local row = create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 46),
			Parent = self._content,
		})

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

		if iconAsset then
			local iconImg = makeIcon(iconAsset, 20)
			iconImg.Position = UDim2.new(0, 12, 0.5, -10)
			iconImg.Parent = btn
		end

		local label = create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, iconAsset and 42 or 14, 0, 0),
			Size = UDim2.new(1, -80, 1, 0),
			Font = Enum.Font.GothamSemibold,
			Text = tostring(text),
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

	function Tab:Dropdown(text, list, callback, iconAsset)
		-- Implementasi dropdown dengan ikon opsional
		-- Sama seperti sebelumnya, tetapi menambahkan ikon jika ada
		local items = list or {}
		local rowHeight = 44
		local itemHeight = 32
		local visibleHeight = math.min(#items * itemHeight, 180)
		local closedHeight = rowHeight
		local openHeight = rowHeight + visibleHeight

		local holder = create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, closedHeight),
			ClipsDescendants = true,
			Parent = self._content,
		})

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

		if iconAsset then
			local iconImg = makeIcon(iconAsset, 20)
			iconImg.Position = UDim2.new(0, 12, 0.5, -10)
			iconImg.Parent = header
		end

		local titleLabel = create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, iconAsset and 42 or 14, 0, 0),
			Size = UDim2.new(1, -60, 1, 0),
			Font = Enum.Font.GothamSemibold,
			Text = tostring(text),
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
			if selected[1] then
				titleLabel.Text = tostring(text) .. ": " .. tostring(selected[1])
			else
				titleLabel.Text = tostring(text)
			end
		end

		local function emit()
			if callback then
				task.spawn(callback, selected[1])
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

		local function setOptionState(name)
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
		end

		for _, name in ipairs(items) do
			local opt = create("TextButton", {
				Name = tostring(name),
				Size = UDim2.new(1, 0, 0, itemHeight),
				BackgroundColor3 = theme.Panel2,
				BorderSizePixel = 0,
				Text = tostring(name),
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
				if selected[1] ~= name then
					tween(opt, {BackgroundColor3 = theme.Panel}, 0.12)
				end
			end)

			opt.MouseLeave:Connect(function()
				if selected[1] ~= name then
					tween(opt, {BackgroundColor3 = theme.Panel2}, 0.12)
				end
			end)

			opt.MouseButton1Click:Connect(function()
				setOptionState(name)
			end)

			table.insert(optionButtons, opt)
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
			end,
			Open = function()
				setOpen(true)
			end,
			Close = function()
				setOpen(false)
			end,
		}
	end

	function Tab:MultiDropdown(text, list, callback, iconAsset)
		-- Mirip dengan dropdown, tapi multi pilihan
		local items = list or {}
		local rowHeight = 44
		local itemHeight = 32
		local visibleHeight = math.min(#items * itemHeight, 180)
		local closedHeight = rowHeight
		local openHeight = rowHeight + visibleHeight

		local holder = create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, closedHeight),
			ClipsDescendants = true,
			Parent = self._content,
		})

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

		if iconAsset then
			local iconImg = makeIcon(iconAsset, 20)
			iconImg.Position = UDim2.new(0, 12, 0.5, -10)
			iconImg.Parent = header
		end

		local titleLabel = create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, iconAsset and 42 or 14, 0, 0),
			Size = UDim2.new(1, -60, 1, 0),
			Font = Enum.Font.GothamSemibold,
			Text = tostring(text),
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
			if #selected == 0 then
				titleLabel.Text = tostring(text)
			else
				titleLabel.Text = tostring(text) .. " (" .. tostring(#selected) .. ")"
			end
		end

		local function emit()
			if callback then
				task.spawn(callback, copyArray(selected))
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
			local idx = table.find(selected, name)
			local chosen = idx ~= nil

			button.Text = (chosen and "✓ " or "  ") .. name
			button.TextColor3 = chosen and theme.Accent2 or theme.Text
			button.BackgroundColor3 = chosen and theme.Accent or theme.Panel2

			if chosen then
				table.remove(selected, idx)
			else
				table.insert(selected, name)
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
				Text = "  " .. tostring(name),
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
				setOptionState(name, opt)
			end)

			table.insert(optionButtons, opt)
		end

		refreshText()

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
			end,
			Open = function()
				setOpen(true)
			end,
			Close = function()
				setOpen(false)
			end,
		}
	end

	function Tab:Label(text)
		local row = create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			Parent = self._content,
		})

		local label = create("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = tostring(text),
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
		return label
	end

	function Tab:Notify(titleText, messageText, duration)
		Library:Notify(titleText, messageText, duration)
	end

	-- Fungsi untuk membuat tab baru
	local function createTab(tabName, tabIcon)
		local content, layout = createTabContent()
		local tabButton = create("TextButton", {
			Name = "TabButton_" .. tabName,
			Size = UDim2.new(1, -20, 0, 44),
			BackgroundColor3 = theme.Panel2,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			Parent = tabContainer,
		})
		roundify(tabButton, 10)
		addStroke(tabButton, theme.Stroke, 0.7, 1)

		-- Ikon tab
		if tabIcon then
			local iconImg = makeIcon(tabIcon, 20)
			iconImg.Position = UDim2.new(0, 12, 0.5, -10)
			iconImg.Parent = tabButton
		end

		local label = create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, tabIcon and 42 or 12, 0, 0),
			Size = UDim2.new(1, -24, 1, 0),
			Font = Enum.Font.GothamSemibold,
			Text = tabName,
			TextColor3 = theme.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = tabButton,
		})

		tabButton.MouseEnter:Connect(function()
			if activeTab ~= tabButton then
				tween(tabButton, {BackgroundColor3 = theme.Panel}, 0.12)
			end
		end)
		tabButton.MouseLeave:Connect(function()
			if activeTab ~= tabButton then
				tween(tabButton, {BackgroundColor3 = theme.Panel2}, 0.12)
			end
		end)

		local tabObj = setmetatable({_content = content, _layout = layout}, Tab)

		tabButton.MouseButton1Click:Connect(function()
			if activeTab == tabButton then return end
			if activeTab then
				tween(activeTab, {BackgroundColor3 = theme.Panel2}, 0.12)
			end
			activeTab = tabButton
			tween(tabButton, {BackgroundColor3 = theme.Accent}, 0.12)
			for _, t in ipairs(tabs) do
				t._content.Visible = false
			end
			content.Visible = true
		end)

		table.insert(tabs, tabObj)
		content.Visible = false
		content.Parent = contentArea

		return tabObj
	end

	-- Fungsi untuk memilih tab secara programatis
	local function selectTab(tabObj)
		for i, t in ipairs(tabs) do
			if t == tabObj then
				local btn = tabContainer:FindFirstChild("TabButton_" .. i) -- perlu cara yang lebih baik
				if btn then
					btn.MouseButton1Click:Fire()
				end
				break
			end
		end
	end

	-- Drag window
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
	Window._tabs = tabs
	Window._selectTab = selectTab

	function Window:Tab(name, iconAsset)
		return createTab(name, iconAsset)
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

	-- Animate window in
	local function animateMainIn()
		main.Size = UDim2.new(0, 0, 0, 0)
		main.BackgroundTransparency = 1
		tween(main, {
			Size = size,
			BackgroundTransparency = 0,
		}, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	end

	animateMainIn()
	Library:Notify("Library Loaded", tostring(windowTitle) .. " siap dipakai.", 2.2)

	return Window
end

return Library
