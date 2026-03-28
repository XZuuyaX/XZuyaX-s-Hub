local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Library = {}

-- Theme
local Theme = {
    Background = Color3.fromRGB(18,18,24),
    Panel = Color3.fromRGB(25,25,35),
    Panel2 = Color3.fromRGB(32,32,45),
    Accent = Color3.fromRGB(140,100,255),
    Text = Color3.fromRGB(255,255,255),
    SubText = Color3.fromRGB(170,170,180),
    Stroke = Color3.fromRGB(60,60,80),
}

local function tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function create(class, props)
    local inst = Instance.new(class)
    for k,v in pairs(props or {}) do inst[k] = v end
    return inst
end

local function round(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = obj
end

-- NOTIFICATION SYSTEM
function Library:Notify(title, text)
    local gui = create("ScreenGui", {Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    local frame = create("Frame", {
        Parent = gui,
        Size = UDim2.new(0, 260, 0, 60),
        Position = UDim2.new(1, 20, 1, -80),
        BackgroundColor3 = Theme.Panel,
    })
    round(frame, 10)

    local titleLbl = create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local desc = create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.SubText,
        Font = Enum.Font.Gotham,
        Size = UDim2.new(1, -10, 0, 30),
        Position = UDim2.new(0, 10, 0, 25),
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    tween(frame, {Position = UDim2.new(1, -280, 1, -80)}, 0.25)

    task.delay(2, function()
        tween(frame, {Position = UDim2.new(1, 20, 1, -80)}, 0.25)
        task.wait(0.3)
        gui:Destroy()
    end)
end

-- WINDOW
function Library:CreateWindow(title)
    local gui = create("ScreenGui", {Parent = CoreGui})

    local main = create("Frame", {
        Parent = gui,
        Size = UDim2.new(0, 700, 0, 420),
        Position = UDim2.new(0.5, -350, 0.5, -210),
        BackgroundColor3 = Theme.Background
    })
    round(main, 12)

    -- TOPBAR
    local top = create("Frame", {
        Parent = main,
        Size = UDim2.new(1,0,0,40),
        BackgroundColor3 = Theme.Panel
    })

    local titleLbl = create("TextLabel", {
        Parent = top,
        BackgroundTransparency = 1,
        Text = title or "Hub",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1,0,1,0)
    })

    -- SIDEBAR
    local sidebar = create("Frame", {
        Parent = main,
        Size = UDim2.new(0, 160, 1, -40),
        Position = UDim2.new(0,0,0,40),
        BackgroundColor3 = Theme.Panel
    })

    local tabHolder = create("Frame", {
        Parent = main,
        Size = UDim2.new(1, -160, 1, -40),
        Position = UDim2.new(0,160,0,40),
        BackgroundTransparency = 1
    })

    local tabs = {}
    local currentTab

    -- CREATE TAB
    function tabs:CreateTab(name)
        local btn = create("TextButton", {
            Parent = sidebar,
            Size = UDim2.new(1,0,0,40),
            Text = name,
            BackgroundTransparency = 1,
            TextColor3 = Theme.SubText,
            Font = Enum.Font.Gotham
        })

        local page = create("Frame", {
            Parent = tabHolder,
            Size = UDim2.new(1,0,1,0),
            Visible = false,
            BackgroundTransparency = 1
        })

        local layout = create("UIListLayout", {
            Padding = UDim.new(0,8),
            Parent = page
        })

        local function select()
            if currentTab then currentTab.Visible = false end
            currentTab = page
            page.Visible = true
        end

        btn.MouseButton1Click:Connect(select)

        -- FIRST TAB AUTO SELECT
        if not currentTab then
            select()
        end

        local tab = {}

        function tab:Section(text)
            local holder = create("Frame", {
                Parent = page,
                Size = UDim2.new(1,-20,0,120),
                BackgroundColor3 = Theme.Panel
            })
            round(holder, 10)

            local label = create("TextLabel", {
                Parent = holder,
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                Size = UDim2.new(1,-10,0,20),
                Position = UDim2.new(0,10,0,5),
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local container = create("Frame", {
                Parent = holder,
                Size = UDim2.new(1,-20,1,-30),
                Position = UDim2.new(0,10,0,30),
                BackgroundTransparency = 1
            })

            local list = create("UIListLayout", {
                Padding = UDim.new(0,6),
                Parent = container
            })

            return container
        end

        -- MODERN DROPDOWN
        function tab:Dropdown(text, list, multi, callback)
            local mainBtn = create("TextButton", {
                Parent = page,
                Size = UDim2.new(1,-20,0,40),
                Text = text,
                BackgroundColor3 = Theme.Panel,
                TextColor3 = Theme.Text
            })
            round(mainBtn, 8)

            local frame = create("Frame", {
                Parent = page,
                Size = UDim2.new(1,-20,0,0),
                BackgroundColor3 = Theme.Panel2,
                ClipsDescendants = true
            })
            round(frame, 8)

            local searchBox = create("TextBox", {
                Parent = frame,
                Size = UDim2.new(1,-10,0,30),
                Position = UDim2.new(0,5,0,5),
                Text = "",
                PlaceholderText = "Search...",
                BackgroundColor3 = Theme.Panel,
                TextColor3 = Theme.Text
            })
            round(searchBox, 6)

            local listFrame = create("Frame", {
                Parent = frame,
                Position = UDim2.new(0,5,0,40),
                Size = UDim2.new(1,-10,1,-45),
                BackgroundTransparency = 1
            })

            local layout = create("UIListLayout", {Parent = listFrame, Padding = UDim.new(0,5)})

            local selected = {}
            local open = false

            local function refresh()
                for _,v in pairs(listFrame:GetChildren()) do
                    if v:IsA("TextButton") then
                        local visible = v.Text:lower():find(searchBox.Text:lower())
                        v.Visible = visible
                    end
                end
            end

            for _,v in ipairs(list) do
                local btn = create("TextButton", {
                    Parent = listFrame,
                    Size = UDim2.new(1,0,0,30),
                    Text = v,
                    BackgroundColor3 = Theme.Panel,
                    TextColor3 = Theme.Text
                })
                round(btn, 6)

                btn.MouseButton1Click:Connect(function()
                    if multi then
                        if table.find(selected, v) then
                            table.remove(selected, table.find(selected, v))
                        else
                            table.insert(selected, v)
                        end
                    else
                        selected = {v}
                    end
                    callback(selected)
                end)
            end

            searchBox:GetPropertyChangedSignal("Text"):Connect(refresh)

            mainBtn.MouseButton1Click:Connect(function()
                open = not open
                local h = open and 200 or 0
                tween(frame, {Size = UDim2.new(1,-20,0,h)}, 0.25)
            end)
        end

        return tab
    end

    -- DRAG
    local dragging, dragStart, startPos
    top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = main.Position
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    tween(main, {Size = UDim2.new(0,700,0,420)}, 0.3)

    return tabs
end

return Library
