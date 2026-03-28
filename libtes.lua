local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local Library = {}

-- Theme
local Theme = {
    Background = Color3.fromRGB(25,25,35),
    Accent = Color3.fromRGB(130,90,255),
    Text = Color3.fromRGB(255,255,255),
    Secondary = Color3.fromRGB(40,40,55),
}

-- Tween helper
local function tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- WINDOW
function Library:CreateWindow(titleText)
    local gui = Instance.new("ScreenGui")
    gui.Parent = game.CoreGui
    gui.Name = "ModernUI"

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 320, 0, 400)
    main.Position = UDim2.new(0.5, -160, 0.5, -200)
    main.BackgroundColor3 = Theme.Background
    main.Parent = gui

    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = titleText or "UI"
    title.TextColor3 = Theme.Text
    title.Font = Enum.Font.GothamBold
    title.Parent = main

    -- Drag
    local dragging, dragStart, startPos

    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 1, -40)
    container.Position = UDim2.new(0, 10, 0, 35)
    container.BackgroundTransparency = 1
    container.Parent = main

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = container

    local Window = {}

    -- BUTTON
    function Window:Button(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.Text = text
        btn.TextColor3 = Theme.Text
        btn.BackgroundColor3 = Theme.Secondary
        btn.Parent = container

        Instance.new("UICorner", btn)

        btn.MouseEnter:Connect(function()
            tween(btn, {BackgroundColor3 = Theme.Accent})
        end)

        btn.MouseLeave:Connect(function()
            tween(btn, {BackgroundColor3 = Theme.Secondary})
        end)

        btn.MouseButton1Click:Connect(callback)
    end

    -- TOGGLE
    function Window:Toggle(text, default, callback)
        local state = default

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        btn.TextColor3 = Theme.Text
        btn.BackgroundColor3 = Theme.Secondary
        btn.Parent = container

        Instance.new("UICorner", btn)

        local function update()
            btn.Text = text .. ": " .. (state and "ON" or "OFF")
            callback(state)
        end

        btn.MouseButton1Click:Connect(function()
            state = not state
            tween(btn, {
                BackgroundColor3 = state and Theme.Accent or Theme.Secondary
            })
            update()
        end)

        update()
    end

    -- MULTI DROPDOWN
    function Window:MultiDropdown(text, list, callback)
        local selected = {}

        local mainBtn = Instance.new("TextButton")
        mainBtn.Size = UDim2.new(1, 0, 0, 30)
        mainBtn.Text = text
        mainBtn.TextColor3 = Theme.Text
        mainBtn.BackgroundColor3 = Theme.Secondary
        mainBtn.Parent = container

        Instance.new("UICorner", mainBtn)

        local dropdown = Instance.new("Frame")
        dropdown.Size = UDim2.new(1, 0, 0, 0)
        dropdown.ClipsDescendants = true
        dropdown.BackgroundColor3 = Theme.Background
        dropdown.Parent = container

        Instance.new("UICorner", dropdown)

        local layout = Instance.new("UIListLayout")
        layout.Parent = dropdown

        local function toggleItem(name, btn)
            local found = table.find(selected, name)

            if found then
                table.remove(selected, found)
                btn.Text = "[ ] " .. name
            else
                table.insert(selected, name)
                btn.Text = "[✓] " .. name
            end

            callback(selected)
        end

        for _, name in ipairs(list) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 25)
            btn.Text = "[ ] " .. name
            btn.TextColor3 = Theme.Text
            btn.BackgroundTransparency = 1
            btn.Parent = dropdown

            btn.MouseButton1Click:Connect(function()
                toggleItem(name, btn)
            end)
        end

        local open = false

        mainBtn.MouseButton1Click:Connect(function()
            open = not open

            local targetSize = open and UDim2.new(1, 0, 0, #list * 25) or UDim2.new(1, 0, 0, 0)

            tween(dropdown, {Size = targetSize}, 0.25)
        end)
    end

    return Window
end

return Library
