local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local library = {}

function library:AddWindow(windowTitle, options)
    local defaultOptions = {
        main_color = Color3.fromRGB(41, 74, 122),
        main_size = Vector2.new(600, 340),
        Key_system = false,
        Key = "Avi",
        Note = "Enter your key here"
    }
    for k, v in pairs(options or {}) do
        defaultOptions[k] = v
    end
    options = defaultOptions

    local accent = options.main_color
    local function lighten(color, factor)
        local h, s, v = Color3.toHSV(color)
        v = math.min(1, v * factor)
        return Color3.fromHSV(h, s, v)
    end
    local function darken(color, factor)
        local h, s, v = Color3.toHSV(color)
        v = v * factor
        return Color3.fromHSV(h, s, v)
    end
    local colors = {
        accent = accent,
        hover = lighten(accent, 1.2),
        click = lighten(accent, 1.4),
        dark_accent = darken(accent, 0.8),
        on = accent,
        off = Color3.fromRGB(160, 80, 80)
    }

    local Quantum
    local MainFrame
    local TabHolder
    local ContentHolder
    local TopBar
    local Title
    local CloseButton
    local MinimizeButton
    local UICorner
    local TabListLayout
    local ParagraphFrame = Instance.new("Frame")
    local ParagraphLabel = Instance.new("TextLabel")
    local UICorner2 = Instance.new("UICorner")
    local UIStroke = Instance.new("UIStroke")

    local function createUI()
        Quantum = Instance.new("ScreenGui")
        MainFrame = Instance.new("Frame")
        TabHolder = Instance.new("Frame")
        ContentHolder = Instance.new("Frame")
        TopBar = Instance.new("Frame")
        Title = Instance.new("TextLabel")
        CloseButton = Instance.new("TextButton")
        MinimizeButton = Instance.new("TextButton")
        UICorner = Instance.new("UICorner")
        TabListLayout = Instance.new("UIListLayout")

        Quantum.Name = "Quantum"
        Quantum.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        Quantum.DisplayOrder = 999
        Quantum.ResetOnSpawn = false
        Quantum.Parent = player:WaitForChild("PlayerGui")

        MainFrame.Name = "MainFrame"
        MainFrame.Parent = Quantum
        MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        MainFrame.BorderSizePixel = 0
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        MainFrame.Size = UDim2.new(0, options.main_size.X, 0, options.main_size.Y)
        MainFrame.ClipsDescendants = true
        MainFrame.Active = true
        MainFrame.Draggable = true

        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = MainFrame

        TopBar.Name = "TopBar"
        TopBar.Parent = MainFrame
        TopBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        TopBar.BorderSizePixel = 0
        TopBar.Size = UDim2.new(1, 0, 0, 30)

        local topBarCorner = UICorner:Clone()
        topBarCorner.CornerRadius = UDim.new(0, 8)
        topBarCorner.Name = "TopBarCorner"
        topBarCorner.Parent = TopBar

        Title.Name = "Title"
        Title.Parent = TopBar
        Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Title.BackgroundTransparency = 1.0
        Title.Position = UDim2.new(0, 10, 0, 0)
        Title.Size = UDim2.new(0, 200, 1, 0)
        Title.Font = Enum.Font.GothamBold
        Title.Text = windowTitle
        Title.TextColor3 = Color3.fromRGB(220, 220, 220)
        Title.TextSize = 14.000
        Title.TextXAlignment = Enum.TextXAlignment.Left

        CloseButton.Name = "CloseButton"
        CloseButton.Parent = TopBar
        CloseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        CloseButton.BackgroundTransparency = 1.0
        CloseButton.Position = UDim2.new(1, -30, 0, 0)
        CloseButton.Size = UDim2.new(0, 30, 1, 0)
        CloseButton.Font = Enum.Font.GothamBold
        CloseButton.Text = "X"
        CloseButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        CloseButton.TextSize = 14.000

        MinimizeButton.Name = "MinimizeButton"
        MinimizeButton.Parent = TopBar
        MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        MinimizeButton.BackgroundTransparency = 1.0
        MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
        MinimizeButton.Size = UDim2.new(0, 30, 1, 0)
        MinimizeButton.Font = Enum.Font.GothamBold
        MinimizeButton.Text = "_"
        MinimizeButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        MinimizeButton.TextSize = 14.000

        TabHolder.Name = "TabHolder"
        TabHolder.Parent = MainFrame
        TabHolder.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        TabHolder.BorderSizePixel = 0
        TabHolder.Position = UDim2.new(0, 0, 0, 30)
        TabHolder.Size = UDim2.new(0, 150, 1, -30)

        ContentHolder.Name = "ContentHolder"
        ContentHolder.Parent = MainFrame
        ContentHolder.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ContentHolder.BorderSizePixel = 0
        ContentHolder.Position = UDim2.new(0, 150, 0, 30)
        ContentHolder.Size = UDim2.new(1, -150, 1, -30)

        TabListLayout.Name = "TabListLayout"
        TabListLayout.Parent = TabHolder
        TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabListLayout.Padding = UDim.new(0, 5)

        CloseButton.MouseButton1Click:Connect(function()
            Quantum:Destroy()
        end)

        local minimized = false
        MinimizeButton.MouseButton1Click:Connect(function()
            minimized = not minimized
            if minimized then
                TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, options.main_size.X, 0, 30)}):Play()
            else
                TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, options.main_size.X, 0, options.main_size.Y)}):Play()
            end
        end)

        MainFrame.Size = UDim2.new(0, options.main_size.X, 0, 0)
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.5), {Size = UDim2.new(0, options.main_size.X, 0, options.main_size.Y)}):Play()
    end

    local window = {}
    function window:AddTab(tabName)
        local TabButton = Instance.new("TextButton")
        local TabContent = Instance.new("ScrollingFrame")
        local TabContentList = Instance.new("UIListLayout")

        TabButton.Name = tabName .. "Tab"
        TabButton.Parent = TabHolder
        TabButton.BackgroundColor3 = colors.accent
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(0.9, 0, 0, 40)
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = tabName
        TabButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        TabButton.TextSize = 14.000
        TabButton.AutoButtonColor = false

        local tabCorner = UICorner:Clone()
        tabCorner.Parent = TabButton

        TabContent.Name = tabName .. "Content"
        TabContent.Parent = ContentHolder
        TabContent.Active = true
        TabContent.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        TabContent.BackgroundTransparency = 1.0
        TabContent.BorderSizePixel = 0
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.ScrollBarThickness = 3
        TabContent.ScrollBarImageColor3 = colors.dark_accent
        TabContent.Visible = false

        TabContentList.Name = "TabContentList"
        TabContentList.Parent = TabContent
        TabContentList.SortOrder = Enum.SortOrder.LayoutOrder
        TabContentList.Padding = UDim.new(0, 10)

        TabContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, TabContentList.AbsoluteContentSize.Y + 20)
        end)

        TabButton.MouseEnter:Connect(function()
            TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = colors.hover}):Play()
        end)

        TabButton.MouseLeave:Connect(function()
            TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = colors.accent}):Play()
        end)

        TabButton.MouseButton1Click:Connect(function()
            for _, child in ipairs(ContentHolder:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end
            TabContent.Visible = true
        end)

        local tab = {}
        function tab:AddLabel(text)
            local Label = Instance.new("TextLabel")

            Label.Name = "Label"
            Label.Parent = TabContent
            Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Label.BackgroundTransparency = 1.0
            Label.Size = UDim2.new(1, -20, 0, 20)
            Label.Font = Enum.Font.GothamBold
            Label.Text = text
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.TextSize = 14.000
            Label.TextXAlignment = Enum.TextXAlignment.Left

            return Label
        end

        function tab:AddButton(text, callback)
            local Button = Instance.new("TextButton")
            local ButtonCorner = Instance.new("UICorner")

            Button.Name = "Button"
            Button.Parent = TabContent
            Button.BackgroundColor3 = colors.accent
            Button.BorderSizePixel = 0
            Button.Position = UDim2.new(0, 10, 0, 0)
            Button.Size = UDim2.new(1, -20, 0, 30)
            Button.Font = Enum.Font.GothamBold
            Button.Text = text
            Button.TextColor3 = Color3.fromRGB(220, 220, 220)
            Button.TextSize = 14.000

            ButtonCorner.CornerRadius = UDim.new(0, 4)
            ButtonCorner.Parent = Button

            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = colors.hover}):Play()
            end)

            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = colors.accent}):Play()
            end)

            Button.MouseButton1Click:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = colors.click}):Play()
                wait(0.1)
                TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = colors.accent}):Play()
                if callback then callback() end
            end)

            return Button
        end

        function tab:AddToggle(text, callback)
            local ToggleFrame = Instance.new("Frame")
            local ToggleLabel = Instance.new("TextLabel")
            local ToggleButton = Instance.new("TextButton")
            local ToggleCorner = Instance.new("UICorner")

            ToggleFrame.Name = "ToggleFrame"
            ToggleFrame.Parent = TabContent
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleFrame.BackgroundTransparency = 1.0
            ToggleFrame.Size = UDim2.new(1, -20, 0, 25)

            ToggleLabel.Name = "ToggleLabel"
            ToggleLabel.Parent = ToggleFrame
            ToggleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleLabel.BackgroundTransparency = 1.0
            ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
            ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
            ToggleLabel.Font = Enum.Font.GothamBold
            ToggleLabel.Text = text
            ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            ToggleLabel.TextSize = 14.000
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

            ToggleButton.Name = "ToggleButton"
            ToggleButton.Parent = ToggleFrame
            ToggleButton.BackgroundColor3 = colors.off
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Position = UDim2.new(0.8, 0, 0.1, 0)
            ToggleButton.Size = UDim2.new(0.2, 0, 0.8, 0)
            ToggleButton.Font = Enum.Font.GothamBold
            ToggleButton.Text = "OFF"
            ToggleButton.TextColor3 = Color3.fromRGB(220, 220, 220)
            ToggleButton.TextSize = 12.000

            ToggleCorner.CornerRadius = UDim.new(0, 4)
            ToggleCorner.Parent = ToggleButton

            local toggled = false

            ToggleButton.MouseButton1Click:Connect(function()
                toggled = not toggled
                if toggled then
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = colors.on}):Play()
                    ToggleButton.Text = "ON"
                else
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = colors.off}):Play()
                    ToggleButton.Text = "OFF"
                end
                if callback then callback(toggled) end
            end)

            return {
                Set = function(self, value)
                    toggled = value
                    if toggled then
                        ToggleButton.BackgroundColor3 = colors.on
                        ToggleButton.Text = "ON"
                    else
                        ToggleButton.BackgroundColor3 = colors.off
                        ToggleButton.Text = "OFF"
                    end
                    if callback then callback(toggled) end
                end,
                Get = function(self)
                    return toggled
                end
            }
        end

        function tab:AddTextBox(text, callback)
            local TextboxFrame = Instance.new("Frame")
            local TextboxLabel = Instance.new("TextLabel")
            local Textbox = Instance.new("TextBox")
            local TextboxCorner = Instance.new("UICorner")

            TextboxFrame.Name = "TextboxFrame"
            TextboxFrame.Parent = TabContent
            TextboxFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextboxFrame.BackgroundTransparency = 1.0
            TextboxFrame.Size = UDim2.new(1, -20, 0, 50)

            TextboxLabel.Name = "TextboxLabel"
            TextboxLabel.Parent = TextboxFrame
            TextboxLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextboxLabel.BackgroundTransparency = 1.0
            TextboxLabel.Position = UDim2.new(0, 0, 0, 0)
            TextboxLabel.Size = UDim2.new(1, 0, 0, 20)
            TextboxLabel.Font = Enum.Font.GothamBold
            TextboxLabel.Text = text
            TextboxLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            TextboxLabel.TextSize = 14.000
            TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left

            Textbox.Name = "Textbox"
            Textbox.Parent = TextboxFrame
            Textbox.BackgroundColor3 = colors.accent
            Textbox.BorderSizePixel = 0
            Textbox.Position = UDim2.new(0, 0, 0, 25)
            Textbox.Size = UDim2.new(1, 0, 0, 25)
            Textbox.Font = Enum.Font.GothamBold
            Textbox.PlaceholderText = "Enter text..."
            Textbox.Text = ""
            Textbox.TextColor3 = Color3.fromRGB(220, 220, 220)
            Textbox.TextSize = 14.000

            TextboxCorner.CornerRadius = UDim.new(0, 4)
            TextboxCorner.Parent = Textbox

            Textbox.FocusLost:Connect(function(enterPressed)
                if enterPressed and callback then
                    callback(Textbox.Text)
                end
            end)

            return {
                Set = function(self, value)
                    Textbox.Text = tostring(value)
                end,
                Get = function(self)
                    return Textbox.Text
                end
            }
        end

        function tab:AddDropdown(text, callback)
            local DropdownFrame = Instance.new("Frame")
            local DropdownLabel = Instance.new("TextLabel")
            local DropdownButton = Instance.new("TextButton")
            local DropdownCorner = Instance.new("UICorner")
            local DropdownList = Instance.new("ScrollingFrame")
            local DropdownListLayout = Instance.new("UIListLayout")

            DropdownFrame.Name = "DropdownFrame"
            DropdownFrame.Parent = TabContent
            DropdownFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            DropdownFrame.BackgroundTransparency = 1.0
            DropdownFrame.Size = UDim2.new(1, -20, 0, 60)

            DropdownLabel.Name = "DropdownLabel"
            DropdownLabel.Parent = DropdownFrame
            DropdownLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            DropdownLabel.BackgroundTransparency = 1.0
            DropdownLabel.Position = UDim2.new(0, 0, 0, 0)
            DropdownLabel.Size = UDim2.new(1, 0, 0, 20)
            DropdownLabel.Font = Enum.Font.GothamBold
            DropdownLabel.Text = text
            DropdownLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            DropdownLabel.TextSize = 14.000
            DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left

            DropdownButton.Name = "DropdownButton"
            DropdownButton.Parent = DropdownFrame
            DropdownButton.BackgroundColor3 = colors.accent
            DropdownButton.BorderSizePixel = 0
            DropdownButton.Position = UDim2.new(0, 0, 0, 25)
            DropdownButton.Size = UDim2.new(1, 0, 0, 25)
            DropdownButton.Font = Enum.Font.GothamBold
            DropdownButton.Text = "Select..."
            DropdownButton.TextColor3 = Color3.fromRGB(220, 220, 220)
            DropdownButton.TextSize = 14.000

            DropdownCorner.CornerRadius = UDim.new(0, 4)
            DropdownCorner.Parent = DropdownButton

            DropdownList.Name = "DropdownList"
            DropdownList.Parent = DropdownFrame
            DropdownList.Active = true
            DropdownList.BackgroundColor3 = colors.dark_accent
            DropdownList.BorderSizePixel = 0
            DropdownList.Position = UDim2.new(0, 0, 0, 55)
            DropdownList.Size = UDim2.new(1, 0, 0, 0)
            DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
            DropdownList.ScrollBarThickness = 3
            DropdownList.ScrollBarImageColor3 = colors.dark_accent
            DropdownList.Visible = false

            DropdownListLayout.Name = "DropdownListLayout"
            DropdownListLayout.Parent = DropdownList
            DropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            DropdownListLayout.Padding = UDim.new(0, 2)

            DropdownListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                DropdownList.CanvasSize = UDim2.new(0, 0, 0, DropdownListLayout.AbsoluteContentSize.Y)
            end)

            DropdownButton.MouseButton1Click:Connect(function()
                DropdownList.Visible = not DropdownList.Visible
                if DropdownList.Visible then
                    DropdownList.Size = UDim2.new(1, 0, 0, math.min(100, DropdownListLayout.AbsoluteContentSize.Y))
                else
                    DropdownList.Size = UDim2.new(1, 0, 0, 0)
                end
            end)

            local dropdown = {}
            function dropdown:Add(option)
                local OptionButton = Instance.new("TextButton")
                local OptionCorner = Instance.new("UICorner")

                OptionButton.Name = option .. "Option"
                OptionButton.Parent = DropdownList
                OptionButton.BackgroundColor3 = colors.accent
                OptionButton.BorderSizePixel = 0
                OptionButton.Size = UDim2.new(1, 0, 0, 25)
                OptionButton.Font = Enum.Font.GothamBold
                OptionButton.Text = option
                OptionButton.TextColor3 = Color3.fromRGB(220, 220, 220)
                OptionButton.TextSize = 14.000

                OptionCorner.CornerRadius = UDim.new(0, 4)
                OptionCorner.Parent = OptionButton

                OptionButton.MouseEnter:Connect(function()
                    TweenService:Create(OptionButton, TweenInfo.new(0.2), {BackgroundColor3 = colors.hover}):Play()
                end)

                OptionButton.MouseLeave:Connect(function()
                    TweenService:Create(OptionButton, TweenInfo.new(0.2), {BackgroundColor3 = colors.accent}):Play()
                end)

                OptionButton.MouseButton1Click:Connect(function()
                    DropdownButton.Text = option
                    DropdownList.Visible = false
                    DropdownList.Size = UDim2.new(1, 0, 0, 0)
                    if callback then callback(option) end
                end)
            end

            function dropdown:Set(value)
                DropdownButton.Text = value
                if callback then callback(value) end
            end

            function dropdown:Get()
                return DropdownButton.Text
            end

            return dropdown
        end

        function tab:AddKeybind(text, callback)
            local KeybindFrame = Instance.new("Frame")
            local KeybindLabel = Instance.new("TextLabel")
            local KeybindButton = Instance.new("TextButton")
            local KeybindCorner = Instance.new("UICorner")

            KeybindFrame.Name = "KeybindFrame"
            KeybindFrame.Parent = TabContent
            KeybindFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            KeybindFrame.BackgroundTransparency = 1.0
            KeybindFrame.Size = UDim2.new(1, -20, 0, 25)

            KeybindLabel.Name = "KeybindLabel"
            KeybindLabel.Parent = KeybindFrame
            KeybindLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            KeybindLabel.BackgroundTransparency = 1.0
            KeybindLabel.Position = UDim2.new(0, 0, 0, 0)
            KeybindLabel.Size = UDim2.new(0.7, 0, 1, 0)
            KeybindLabel.Font = Enum.Font.GothamBold
            KeybindLabel.Text = text
            KeybindLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            KeybindLabel.TextSize = 14.000
            KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left

            KeybindButton.Name = "KeybindButton"
            KeybindButton.Parent = KeybindFrame
            KeybindButton.BackgroundColor3 = colors.accent
            KeybindButton.BorderSizePixel = 0
            KeybindButton.Position = UDim2.new(0.8, 0, 0.1, 0)
            KeybindButton.Size = UDim2.new(0.2, 0, 0.8, 0)
            KeybindButton.Font = Enum.Font.GothamBold
            KeybindButton.Text = "NONE"
            KeybindButton.TextColor3 = Color3.fromRGB(220, 220, 220)
            KeybindButton.TextSize = 12.000

            KeybindCorner.CornerRadius = UDim.new(0, 4)
            KeybindCorner.Parent = KeybindButton

            local listening = false
            local currentKey = nil

            KeybindButton.MouseButton1Click:Connect(function()
                listening = not listening
                if listening then
                    KeybindButton.Text = "..."
                    KeybindButton.BackgroundColor3 = colors.hover
                else
                    KeybindButton.Text = currentKey and tostring(currentKey.Name) or "NONE"
                    KeybindButton.BackgroundColor3 = colors.accent
                end
            end)

            local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if listening and not gameProcessed then
                    listening = false
                    if input.KeyCode ~= Enum.KeyCode.Unknown then
                        currentKey = input.KeyCode
                    else
                        currentKey = input.UserInputType
                    end
                    KeybindButton.Text = tostring(currentKey.Name)
                    KeybindButton.BackgroundColor3 = colors.accent
                    if callback then callback(currentKey) end
                end
            end)

            return {
                Set = function(self, value)
                    currentKey = value
                    KeybindButton.Text = tostring(value.Name)
                    if callback then callback(value) end
                end,
                Get = function(self)
                    return currentKey
                end
            }
        end
        
        function tab:AddParagraph(text)
    ParagraphFrame.Name = "ParagraphFrame"
    ParagraphFrame.Parent = TabContent
    ParagraphFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    ParagraphFrame.BorderSizePixel = 0
    ParagraphFrame.Position = UDim2.new(0.02, 0, 0, 0)
    ParagraphFrame.Size = UDim2.new(0.96, 0, 0, 0)
    ParagraphFrame.AutomaticSize = Enum.AutomaticSize.Y

    UICorner2.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = ParagraphFrame

    UIStroke.Color = colors.accent
    UIStroke.Thickness = 1
    UIStroke.Parent = ParagraphFrame

    ParagraphLabel.Name = "ParagraphLabel"
    ParagraphLabel.Parent = ParagraphFrame
    ParagraphLabel.BackgroundTransparency = 1
    ParagraphLabel.Size = UDim2.new(1, 0, 1, 0)
    ParagraphLabel.Font = Enum.Font.GothamBold
    ParagraphLabel.Text = text
    ParagraphLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    ParagraphLabel.TextSize = 14
    ParagraphLabel.TextWrapped = true
    ParagraphLabel.TextXAlignment = Enum.TextXAlignment.Center
    ParagraphLabel.TextYAlignment = Enum.TextYAlignment.Center
    ParagraphLabel.AutomaticSize = Enum.AutomaticSize.Y

    local paragraph = {}
    function paragraph:SetContent(newText)
        ParagraphLabel.Text = newText
    end

    return paragraph
end

        return tab
    end

    if options.Key_system then
        local successEvent = Instance.new("BindableEvent")

        local gui = Instance.new("ScreenGui")
        local frame = Instance.new("Frame")
        local frameCorner = Instance.new("UICorner")
        local shadow = Instance.new("ImageLabel")
        local title = Instance.new("TextLabel")
        local keyTextBox = Instance.new("TextBox")
        local keyTextBoxRoundify = Instance.new("ImageLabel")
        local noteLabel = Instance.new("TextLabel")

        gui.Name = "QuantumLibraryKeySystem"
        gui.Parent = player:WaitForChild("PlayerGui")
        gui.ResetOnSpawn = false

        frame.Size = UDim2.new(0, 467, 0, 175)
        frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        frame.BorderSizePixel = 0
        frame.Active = true
        frame.Draggable = true
        frame.Parent = gui

        frameCorner.CornerRadius = UDim.new(0, 12)
        frameCorner.Parent = frame

        local KeyMain = frame

        shadow.Name = "Shadow"
        shadow.ImageTransparency = 1
        shadow.Image = "rbxassetid://0"
        shadow.Size = UDim2.new(1, 10, 1, 10)
        shadow.BackgroundTransparency = 1
        shadow.Parent = KeyMain

        title.Name = "Title"
        title.Size = UDim2.new(0.8, 0, 0.2, 0)
        title.Position = UDim2.new(0.5, 0, 0.1, 0)
        title.AnchorPoint = Vector2.new(0.5, 0)
        title.BackgroundTransparency = 1
        title.Text = "Key System"
        title.TextColor3 = Color3.fromRGB(200, 200, 200)
        title.Font = Enum.Font.GothamSemibold
        title.TextSize = 20
        title.TextTransparency = 1
        title.Parent = frame

        keyTextBox.Parent = frame
        keyTextBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        keyTextBox.BackgroundTransparency = 0
        keyTextBox.BorderSizePixel = 0
        keyTextBox.Size = UDim2.new(0.7, 0, 0, 30)
        keyTextBox.Position = UDim2.new(0.5, 0, 0.35, 0)
        keyTextBox.AnchorPoint = Vector2.new(0.5, 0)
        keyTextBox.ZIndex = 2
        keyTextBox.Font = Enum.Font.GothamSemibold
        keyTextBox.PlaceholderColor3 = Color3.new(0.698, 0.698, 0.698)
        keyTextBox.PlaceholderText = "Key"
        keyTextBox.Text = ""
        keyTextBox.TextColor3 = Color3.fromRGB(200, 200, 200)
        keyTextBox.TextSize = 14
        keyTextBox.TextTransparency = 1

        keyTextBoxRoundify.Name = "TextBox_Roundify_4px"
        keyTextBoxRoundify.Parent = keyTextBox
        keyTextBoxRoundify.BackgroundColor3 = Color3.new(20, 20, 20)
        keyTextBoxRoundify.BackgroundTransparency = 1
        keyTextBoxRoundify.Size = UDim2.new(1, 0, 1, 0)
        keyTextBoxRoundify.Image = "rbxassetid://2851929490"
        keyTextBoxRoundify.ImageColor3 = Color3.new(0.3, 0.3, 0.3)
        keyTextBoxRoundify.ImageTransparency = 1
        keyTextBoxRoundify.ScaleType = Enum.ScaleType.Slice
        keyTextBoxRoundify.SliceCenter = Rect.new(4, 4, 4, 4)

        noteLabel.Size = UDim2.new(0.7, 0, 0, 40)
        noteLabel.Position = UDim2.new(0.5, 0, 0.75, 0)
        noteLabel.AnchorPoint = Vector2.new(0.5, 0)
        noteLabel.BackgroundTransparency = 1
        noteLabel.Text = options.Note
        noteLabel.TextColor3 = Color3.new(0.6, 0.6, 0.6)
        noteLabel.Font = Enum.Font.Gotham
        noteLabel.TextSize = 12
        noteLabel.TextTransparency = 1
        noteLabel.TextWrapped = true
        noteLabel.Parent = frame

        TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
        TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 500, 0, 187)}):Play()
        TweenService:Create(KeyMain.Shadow, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 0.5}):Play()
        TweenService:Create(title, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
        TweenService:Create(keyTextBox, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
        TweenService:Create(keyTextBoxRoundify, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
        TweenService:Create(noteLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()

        keyTextBox.FocusLost:Connect(function(enterPressed)
            if keyTextBox.Text == options.Key then
                TweenService:Create(KeyMain, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
                    Size = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1
                }):Play()

                TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                TweenService:Create(keyTextBox, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                TweenService:Create(keyTextBoxRoundify, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
                TweenService:Create(noteLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                TweenService:Create(shadow, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()

                wait(0.4)
                gui:Destroy()
                successEvent:Fire()
            else
                keyTextBox.Text = ""
            end
        end)

        successEvent.Event:Wait()
        successEvent:Destroy()
    end

    createUI()

    return window
end

return library
