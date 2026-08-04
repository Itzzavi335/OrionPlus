
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

-- OrionPlus UI Library
-- Mobile dragging supported (Touch + Mouse)

local OrionPlus = {
	Elements = {},
	ThemeObjects = {},
	Connections = {},
	Flags = {},
	Themes = {
		Default = {
			Main = Color3.fromRGB(25, 25, 25),
			Second = Color3.fromRGB(32, 32, 32),
			Stroke = Color3.fromRGB(60, 60, 60),
			Divider = Color3.fromRGB(60, 60, 60),
			Text = Color3.fromRGB(240, 240, 240),
			TextDark = Color3.fromRGB(150, 150, 150)
		}
	},
	SelectedTheme = "Default",
	Folder = nil,
	SaveCfg = false,
	EnteredKey = nil,     -- stores whichever key the user typed successfully
	Authenticated = false -- true once global key (if any) is passed
}

-- Feather Icons https://github.com/evoincorp/lucideblox/tree/master/src/modules/util - Created by 7kayoh
local Icons = {}

local Success, Response = pcall(function()
	Icons = HttpService:JSONDecode(game:HttpGetAsync("https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json")).icons
end)

if not Success then
	warn("\nOrionPlus Library - Failed to load Feather Icons. Error code: " .. Response .. "\n")
end	

local function GetIcon(IconName)
	if Icons[IconName] ~= nil then
		return Icons[IconName]
	else
		return nil
	end
end   

local Orion = Instance.new("ScreenGui")
Orion.Name = "OrionPlus"
if syn then
	syn.protect_gui(Orion)
	Orion.Parent = game.CoreGui
else
	Orion.Parent = gethui() or game.CoreGui
end

if gethui then
	for _, Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
else
	for _, Interface in ipairs(game.CoreGui:GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
end

function OrionPlus:IsRunning()
	if gethui then
		return Orion.Parent == gethui()
	else
		return Orion.Parent == game:GetService("CoreGui")
	end
end

local function AddConnection(Signal, Function)
	if (not OrionPlus:IsRunning()) then
		return
	end
	local SignalConnect = Signal:Connect(Function)
	table.insert(OrionPlus.Connections, SignalConnect)
	return SignalConnect
end

task.spawn(function()
	while (OrionPlus:IsRunning()) do
		wait()
	end

	for _, Connection in next, OrionPlus.Connections do
		Connection:Disconnect()
	end
end)

-- ────────────────────────────────────────────────────────────
-- AddDraggingFunctionality
-- Supports both Mouse (PC) and Touch (Mobile) input.
-- ────────────────────────────────────────────────────────────
local function AddDraggingFunctionality(DragPoint, Main)
	pcall(function()
		local Dragging, DragInput, InputPos, FramePos = false

		-- Begin drag on MouseButton1 OR Touch
		DragPoint.InputBegan:Connect(function(Input)
			if
				Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.Touch
			then
				Dragging = true
				InputPos  = Input.Position
				FramePos  = Main.Position

				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)

		-- Track active drag input on MouseMovement OR Touch move
		DragPoint.InputChanged:Connect(function(Input)
			if
				Input.UserInputType == Enum.UserInputType.MouseMovement
				or Input.UserInputType == Enum.UserInputType.Touch
			then
				DragInput = Input
			end
		end)

		-- Apply position delta when dragging
		UserInputService.InputChanged:Connect(function(Input)
			if Input == DragInput and Dragging then
				local Delta = Input.Position - InputPos
				TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Position = UDim2.new(
						FramePos.X.Scale,  FramePos.X.Offset + Delta.X,
						FramePos.Y.Scale,  FramePos.Y.Offset + Delta.Y
					)
				}):Play()
			end
		end)
	end)
end   

local function Create(Name, Properties, Children)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do
		Object[i] = v
	end
	for i, v in next, Children or {} do
		v.Parent = Object
	end
	return Object
end

local function CreateElement(ElementName, ElementFunction)
	OrionPlus.Elements[ElementName] = function(...)
		return ElementFunction(...)
	end
end

local function MakeElement(ElementName, ...)
	local NewElement = OrionPlus.Elements[ElementName](...)
	return NewElement
end

local function SetProps(Element, Props)
	table.foreach(Props, function(Property, Value)
		Element[Property] = Value
	end)
	return Element
end

local function SetChildren(Element, Children)
	table.foreach(Children, function(_, Child)
		Child.Parent = Element
	end)
	return Element
end

local function Round(Number, Factor)
	local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
	if Result < 0 then Result = Result + Factor end
	return Result
end

local function ReturnProperty(Object)
	if Object:IsA("Frame") or Object:IsA("TextButton") then
		return "BackgroundColor3"
	end 
	if Object:IsA("ScrollingFrame") then
		return "ScrollBarImageColor3"
	end 
	if Object:IsA("UIStroke") then
		return "Color"
	end 
	if Object:IsA("TextLabel") or Object:IsA("TextBox") then
		return "TextColor3"
	end   
	if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
		return "ImageColor3"
	end   
end

local function AddThemeObject(Object, Type)
	if not OrionPlus.ThemeObjects[Type] then
		OrionPlus.ThemeObjects[Type] = {}
	end    
	table.insert(OrionPlus.ThemeObjects[Type], Object)
	Object[ReturnProperty(Object)] = OrionPlus.Themes[OrionPlus.SelectedTheme][Type]
	return Object
end    

local function SetTheme()
	for Name, Type in pairs(OrionPlus.ThemeObjects) do
		for _, Object in pairs(Type) do
			Object[ReturnProperty(Object)] = OrionPlus.Themes[OrionPlus.SelectedTheme][Name]
		end    
	end    
end

local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end    

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadCfg(Config)
	local Data = HttpService:JSONDecode(Config)
	table.foreach(Data, function(a,b)
		if OrionPlus.Flags[a] then
			spawn(function() 
				if OrionPlus.Flags[a].Type == "Colorpicker" then
					OrionPlus.Flags[a]:Set(UnpackColor(b))
				else
					OrionPlus.Flags[a]:Set(b)
				end    
			end)
		else
			warn("OrionPlus Config Loader - Could not find ", a ,b)
		end
	end)
end

local function SaveCfg(Name)
	local Data = {}
	for i,v in pairs(OrionPlus.Flags) do
		if v.Save then
			if v.Type == "Colorpicker" then
				Data[i] = PackColor(v.Value)
			else
				Data[i] = v.Value
			end
		end	
	end
	writefile(OrionPlus.Folder .. "/" .. Name .. ".txt", tostring(HttpService:JSONEncode(Data)))
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3}
local BlacklistedKeys  = {Enum.KeyCode.Unknown, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right, Enum.KeyCode.Slash, Enum.KeyCode.Tab, Enum.KeyCode.Backspace, Enum.KeyCode.Escape}

local function CheckKey(Table, Key)
	for _, v in next, Table do
		if v == Key then
			return true
		end
	end
end

CreateElement("Corner", function(Scale, Offset)
	local Corner = Create("UICorner", {
		CornerRadius = UDim.new(Scale or 0, Offset or 10)
	})
	return Corner
end)

CreateElement("Stroke", function(Color, Thickness)
	local Stroke = Create("UIStroke", {
		Color = Color or Color3.fromRGB(255, 255, 255),
		Thickness = Thickness or 1
	})
	return Stroke
end)

CreateElement("List", function(Scale, Offset)
	local List = Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(Scale or 0, Offset or 0)
	})
	return List
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
	local Padding = Create("UIPadding", {
		PaddingBottom = UDim.new(0, Bottom or 4),
		PaddingLeft   = UDim.new(0, Left   or 4),
		PaddingRight  = UDim.new(0, Right  or 4),
		PaddingTop    = UDim.new(0, Top    or 4)
	})
	return Padding
end)

CreateElement("TFrame", function()
	local TFrame = Create("Frame", {
		BackgroundTransparency = 1
	})
	return TFrame
end)

CreateElement("Frame", function(Color)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel  = 0
	})
	return Frame
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel  = 0
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(Scale, Offset)
		})
	})
	return Frame
end)

CreateElement("Button", function()
	local Button = Create("TextButton", {
		Text                = "",
		AutoButtonColor     = false,
		BackgroundTransparency = 1,
		BorderSizePixel     = 0
	})
	return Button
end)

CreateElement("ScrollFrame", function(Color, Width)
	local ScrollFrame = Create("ScrollingFrame", {
		BackgroundTransparency  = 1,
		MidImage                = "rbxassetid://7445543667",
		BottomImage             = "rbxassetid://7445543667",
		TopImage                = "rbxassetid://7445543667",
		ScrollBarImageColor3    = Color,
		BorderSizePixel         = 0,
		ScrollBarThickness      = Width,
		CanvasSize              = UDim2.new(0, 0, 0, 0)
	})
	return ScrollFrame
end)

CreateElement("Image", function(ImageID)
	local ImageNew = Create("ImageLabel", {
		Image                  = ImageID,
		BackgroundTransparency = 1
	})

	if GetIcon(ImageID) ~= nil then
		ImageNew.Image = GetIcon(ImageID)
	end	

	return ImageNew
end)

CreateElement("ImageButton", function(ImageID)
	local Image = Create("ImageButton", {
		Image                  = ImageID,
		BackgroundTransparency = 1
	})
	return Image
end)

CreateElement("Label", function(Text, TextSize, Transparency)
	local Label = Create("TextLabel", {
		Text               = Text or "",
		TextColor3         = Color3.fromRGB(240, 240, 240),
		TextTransparency   = Transparency or 0,
		TextSize           = TextSize or 15,
		Font               = Enum.Font.Gotham,
		RichText           = true,
		BackgroundTransparency = 1,
		TextXAlignment     = Enum.TextXAlignment.Left
	})
	return Label
end)

local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
	SetProps(MakeElement("List"), {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder           = Enum.SortOrder.LayoutOrder,
		VerticalAlignment   = Enum.VerticalAlignment.Bottom,
		Padding             = UDim.new(0, 5)
	})
}), {
	Position    = UDim2.new(1, -25, 1, -25),
	Size        = UDim2.new(0, 300, 1, -25),
	AnchorPoint = Vector2.new(1, 1),
	Parent      = Orion
})

function OrionPlus:MakeNotification(NotificationConfig)
	spawn(function()
		NotificationConfig.Name    = NotificationConfig.Name    or "Notification"
		NotificationConfig.Content = NotificationConfig.Content or "Test"
		NotificationConfig.Image   = NotificationConfig.Image   or "rbxassetid://4384403532"
		NotificationConfig.Time    = NotificationConfig.Time    or 15

		local NotificationParent = SetProps(MakeElement("TFrame"), {
			Size          = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent        = NotificationHolder
		})

		local NotificationFrame = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25, 25, 25), 0, 10), {
			Parent            = NotificationParent, 
			Size              = UDim2.new(1, 0, 0, 0),
			Position          = UDim2.new(1, -55, 0, 0),
			BackgroundTransparency = 0,
			AutomaticSize     = Enum.AutomaticSize.Y
		}), {
			MakeElement("Stroke", Color3.fromRGB(93, 93, 93), 1.2),
			MakeElement("Padding", 12, 12, 12, 12),
			SetProps(MakeElement("Image", NotificationConfig.Image), {
				Size        = UDim2.new(0, 20, 0, 20),
				ImageColor3 = Color3.fromRGB(240, 240, 240),
				Name        = "Icon"
			}),
			SetProps(MakeElement("Label", NotificationConfig.Name, 15), {
				Size     = UDim2.new(1, -30, 0, 20),
				Position = UDim2.new(0, 30, 0, 0),
				Font     = Enum.Font.GothamBold,
				Name     = "Title"
			}),
			SetProps(MakeElement("Label", NotificationConfig.Content, 14), {
				Size          = UDim2.new(1, 0, 0, 0),
				Position      = UDim2.new(0, 0, 0, 25),
				Font          = Enum.Font.GothamSemibold,
				Name          = "Content",
				AutomaticSize = Enum.AutomaticSize.Y,
				TextColor3    = Color3.fromRGB(200, 200, 200),
				TextWrapped   = true
			})
		})

		TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()

		wait(NotificationConfig.Time - 0.88)
		TweenService:Create(NotificationFrame.Icon,    TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		TweenService:Create(NotificationFrame,         TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
		wait(0.3)
		TweenService:Create(NotificationFrame.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0.9}):Play()
		TweenService:Create(NotificationFrame.Title,   TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
		TweenService:Create(NotificationFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
		wait(0.05)

		NotificationFrame:TweenPosition(UDim2.new(1, 20, 0, 0), 'In', 'Quint', 0.8, true)
		wait(1.35)
		NotificationFrame:Destroy()
	end)
end    

function OrionPlus:Init()
	if OrionPlus.SaveCfg then	
		pcall(function()
			if isfile(OrionPlus.Folder .. "/" .. game.GameId .. ".txt") then
				LoadCfg(readfile(OrionPlus.Folder .. "/" .. game.GameId .. ".txt"))
				OrionPlus:MakeNotification({
					Name    = "Configuration",
					Content = "Auto-loaded configuration for the game " .. game.GameId .. ".",
					Time    = 5
				})
			end
		end)		
	end	
end	

-- ════════════════════════════════════════════════════════════
-- Internal: themed key-entry modal
-- KeyConfig = { Keys={}, Title="", Description="", Note="" }
-- Blocks (using Heartbeat loop) until a valid key is entered.
-- Sets OrionPlus.EnteredKey on success.
-- ════════════════════════════════════════════════════════════
local function ShowKeyPrompt(KeyConfig)
	local Resolved  = false
	local FoundKey  = nil

	-- ── Overlay ──────────────────────────────────────────────
	local Overlay = Create("Frame", {
		Parent                 = Orion,
		Size                   = UDim2.new(1, 0, 1, 0),
		BackgroundColor3       = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel        = 0,
		ZIndex                 = 50,
	})

	-- ── Card ─────────────────────────────────────────────────
	local Card = Create("Frame", {
		Parent                 = Overlay,
		Size                   = UDim2.new(0, 400, 0, 248),
		AnchorPoint            = Vector2.new(0.5, 0.5),
		Position               = UDim2.new(0.5, 0, 0.45, 0),  -- starts slightly high; tweens to centre
		BackgroundColor3       = Color3.fromRGB(22, 22, 22),
		BorderSizePixel        = 0,
		ZIndex                 = 51,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
		Create("UIStroke",  { Color = Color3.fromRGB(60, 60, 60), Thickness = 1 }),
	})

	-- ── Lock icon ─────────────────────────────────────────────
	Create("ImageLabel", {
		Parent                 = Card,
		Size                   = UDim2.new(0, 26, 0, 26),
		AnchorPoint            = Vector2.new(0.5, 0),
		Position               = UDim2.new(0.5, 0, 0, 20),
		BackgroundTransparency = 1,
		Image                  = "rbxassetid://3610239960",
		ImageColor3            = Color3.fromRGB(200, 200, 200),
		ZIndex                 = 52,
	})

	-- ── Title ─────────────────────────────────────────────────
	Create("TextLabel", {
		Parent                 = Card,
		Size                   = UDim2.new(1, -40, 0, 22),
		Position               = UDim2.new(0, 20, 0, 54),
		BackgroundTransparency = 1,
		Text                   = KeyConfig.Title or "Authentication Required",
		TextColor3             = Color3.fromRGB(240, 240, 240),
		Font                   = Enum.Font.GothamBlack,
		TextSize               = 17,
		TextXAlignment         = Enum.TextXAlignment.Center,
		ZIndex                 = 52,
	})

	-- ── Description ───────────────────────────────────────────
	local keyCount = #KeyConfig.Keys
	Create("TextLabel", {
		Parent                 = Card,
		Size                   = UDim2.new(1, -40, 0, 34),
		Position               = UDim2.new(0, 20, 0, 80),
		BackgroundTransparency = 1,
		Text                   = KeyConfig.Description
			or ("Enter one of the " .. keyCount .. " accepted key" .. (keyCount ~= 1 and "s" or "") .. " to continue."),
		TextColor3             = Color3.fromRGB(140, 140, 140),
		Font                   = Enum.Font.GothamSemibold,
		TextSize               = 12,
		TextXAlignment         = Enum.TextXAlignment.Center,
		TextWrapped            = true,
		ZIndex                 = 52,
	})

	-- ── Input container ───────────────────────────────────────
	local InputStroke = Create("UIStroke", {
		Color     = Color3.fromRGB(60, 60, 60),
		Thickness = 1,
	})
	local InputContainer = Create("Frame", {
		Parent           = Card,
		Size             = UDim2.new(1, -40, 0, 38),
		Position         = UDim2.new(0, 20, 0, 122),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderSizePixel  = 0,
		ZIndex           = 52,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
		InputStroke,
	})

	local InputBox = Create("TextBox", {
		Parent                 = InputContainer,
		Size                   = UDim2.new(1, -20, 1, 0),
		Position               = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text                   = "",
		PlaceholderText        = "Enter key here...",
		PlaceholderColor3      = Color3.fromRGB(80, 80, 80),
		TextColor3             = Color3.fromRGB(240, 240, 240),
		Font                   = Enum.Font.GothamSemibold,
		TextSize               = 13,
		ClearTextOnFocus       = false,
		ZIndex                 = 53,
	})

	-- ── Error label ───────────────────────────────────────────
	local ErrorLabel = Create("TextLabel", {
		Parent                 = Card,
		Size                   = UDim2.new(1, -40, 0, 14),
		Position               = UDim2.new(0, 20, 0, 165),
		BackgroundTransparency = 1,
		Text                   = "✕  Invalid key — please try again.",
		TextColor3             = Color3.fromRGB(255, 75, 75),
		Font                   = Enum.Font.GothamSemibold,
		TextSize               = 11,
		TextXAlignment         = Enum.TextXAlignment.Center,
		Visible                = false,
		ZIndex                 = 52,
	})

	-- ── Submit button ─────────────────────────────────────────
	local SubmitNormal  = Color3.fromRGB(9, 99, 195)
	local SubmitHover   = Color3.fromRGB(20, 120, 220)
	local SubmitSuccess = Color3.fromRGB(0, 160, 80)
	local SubmitError   = Color3.fromRGB(150, 35, 35)

	local SubmitBtn = Create("TextButton", {
		Parent           = Card,
		Size             = UDim2.new(1, -40, 0, 38),
		Position         = UDim2.new(0, 20, 0, 186),
		BackgroundColor3 = SubmitNormal,
		BorderSizePixel  = 0,
		Text             = "Confirm Key",
		TextColor3       = Color3.fromRGB(255, 255, 255),
		Font             = Enum.Font.GothamBold,
		TextSize         = 13,
		AutoButtonColor  = false,
		ZIndex           = 52,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
	})

	-- ── Note (optional bottom text) ───────────────────────────
	if KeyConfig.Note then
		Create("TextLabel", {
			Parent                 = Card,
			Size                   = UDim2.new(1, -40, 0, 12),
			Position               = UDim2.new(0, 20, 1, -16),
			BackgroundTransparency = 1,
			Text                   = KeyConfig.Note,
			TextColor3             = Color3.fromRGB(80, 80, 80),
			Font                   = Enum.Font.Gotham,
			TextSize               = 10,
			TextXAlignment         = Enum.TextXAlignment.Center,
			ZIndex                 = 52,
		})
	end

	-- ── Shake animation ───────────────────────────────────────
	local function ShakeInput()
		local base = InputContainer.Position
		for i = 1, 6 do
			TweenService:Create(InputContainer, TweenInfo.new(0.045, Enum.EasingStyle.Linear), {
				Position = UDim2.new(base.X.Scale, base.X.Offset + ((i % 2 == 0) and 7 or -7), base.Y.Scale, base.Y.Offset)
			}):Play()
			task.wait(0.045)
		end
		InputContainer.Position = base
	end

	-- ── Key validation logic ──────────────────────────────────
	local Busy = false
	local function TrySubmit()
		if Busy or Resolved then return end
		Busy = true
		local typed = InputBox.Text

		for _, validKey in ipairs(KeyConfig.Keys) do
			if typed == validKey then
				-- ✓ Correct
				ErrorLabel.Visible = false
				TweenService:Create(InputStroke,  TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(0, 200, 100)}):Play()
				TweenService:Create(SubmitBtn,    TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = SubmitSuccess}):Play()
				SubmitBtn.Text = "✓  Access Granted"
				task.wait(0.55)
				-- Fade out overlay
				TweenService:Create(Overlay, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
				TweenService:Create(Card,    TweenInfo.new(0.35, Enum.EasingStyle.Quint), {BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.44, 0)}):Play()
				task.wait(0.4)
				Overlay:Destroy()
				OrionPlus.EnteredKey    = typed
				OrionPlus.Authenticated = true
				FoundKey                = typed
				Resolved                = true
				return
			end
		end

		-- ✗ Wrong key
		ErrorLabel.Visible = true
		TweenService:Create(InputStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(220, 55, 55)}):Play()
		TweenService:Create(SubmitBtn,   TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundColor3 = SubmitError}):Play()
		spawn(ShakeInput)
		task.wait(0.9)
		if not Resolved then
			TweenService:Create(InputStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(60, 60, 60)}):Play()
			TweenService:Create(SubmitBtn,   TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = SubmitNormal}):Play()
		end
		Busy = false
	end

	SubmitBtn.MouseButton1Up:Connect(function()   spawn(TrySubmit)  end)
	InputBox.FocusLost:Connect(function(enter)    if enter then spawn(TrySubmit) end  end)
	SubmitBtn.MouseEnter:Connect(function()
		if not Resolved then TweenService:Create(SubmitBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundColor3 = SubmitHover}):Play() end
	end)
	SubmitBtn.MouseLeave:Connect(function()
		if not Resolved then TweenService:Create(SubmitBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundColor3 = SubmitNormal}):Play() end
	end)

	-- ── Slide-in animation ────────────────────────────────────
	TweenService:Create(Card, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.5, 0)
	}):Play()

	-- Block until resolved
	while not Resolved do
		RunService.Heartbeat:Wait()
	end

	return FoundKey
end

-- ════════════════════════════════════════════════════════════
-- Internal: compact inline key-lock overlay for a single tab
-- Shown inside the tab's content area when the tab has Keys
-- and the user hasn't entered a valid one yet.
-- ════════════════════════════════════════════════════════════
local function MakeTabKeyLock(Parent, TabKeys, OnUnlock)
	local LockFrame = Create("Frame", {
		Parent                 = Parent,
		Size                   = UDim2.new(1, 0, 1, 0),
		BackgroundColor3       = Color3.fromRGB(22, 22, 22),
		BackgroundTransparency = 0,
		BorderSizePixel        = 0,
		ZIndex                 = 10,
		Name                   = "KeyLockOverlay",
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
	})

	-- Lock icon
	Create("ImageLabel", {
		Parent                 = LockFrame,
		Size                   = UDim2.new(0, 32, 0, 32),
		AnchorPoint            = Vector2.new(0.5, 0),
		Position               = UDim2.new(0.5, 0, 0, 30),
		BackgroundTransparency = 1,
		Image                  = "rbxassetid://3610239960",
		ImageColor3            = Color3.fromRGB(180, 180, 180),
		ZIndex                 = 11,
	})

	Create("TextLabel", {
		Parent                 = LockFrame,
		Size                   = UDim2.new(1, -40, 0, 20),
		AnchorPoint            = Vector2.new(0.5, 0),
		Position               = UDim2.new(0.5, 0, 0, 70),
		BackgroundTransparency = 1,
		Text                   = "Key Required",
		TextColor3             = Color3.fromRGB(220, 220, 220),
		Font                   = Enum.Font.GothamBlack,
		TextSize               = 15,
		TextXAlignment         = Enum.TextXAlignment.Center,
		ZIndex                 = 11,
	})

	Create("TextLabel", {
		Parent                 = LockFrame,
		Size                   = UDim2.new(1, -60, 0, 28),
		AnchorPoint            = Vector2.new(0.5, 0),
		Position               = UDim2.new(0.5, 0, 0, 96),
		BackgroundTransparency = 1,
		Text                   = "This tab requires a specific key. Enter it below to unlock.",
		TextColor3             = Color3.fromRGB(120, 120, 120),
		Font                   = Enum.Font.GothamSemibold,
		TextSize               = 11,
		TextXAlignment         = Enum.TextXAlignment.Center,
		TextWrapped            = true,
		ZIndex                 = 11,
	})

	-- Input
	local TabInputStroke = Create("UIStroke", { Color = Color3.fromRGB(60, 60, 60), Thickness = 1 })
	local TabInputCon = Create("Frame", {
		Parent           = LockFrame,
		Size             = UDim2.new(0, 240, 0, 34),
		AnchorPoint      = Vector2.new(0.5, 0),
		Position         = UDim2.new(0.5, 0, 0, 136),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderSizePixel  = 0,
		ZIndex           = 11,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 7) }),
		TabInputStroke,
	})
	local TabInputBox = Create("TextBox", {
		Parent                 = TabInputCon,
		Size                   = UDim2.new(1, -16, 1, 0),
		Position               = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		Text                   = "",
		PlaceholderText        = "Enter tab key...",
		PlaceholderColor3      = Color3.fromRGB(75, 75, 75),
		TextColor3             = Color3.fromRGB(240, 240, 240),
		Font                   = Enum.Font.GothamSemibold,
		TextSize               = 12,
		ClearTextOnFocus       = false,
		ZIndex                 = 12,
	})

	local TabErrorLabel = Create("TextLabel", {
		Parent                 = LockFrame,
		Size                   = UDim2.new(0, 240, 0, 14),
		AnchorPoint            = Vector2.new(0.5, 0),
		Position               = UDim2.new(0.5, 0, 0, 175),
		BackgroundTransparency = 1,
		Text                   = "✕  Invalid key.",
		TextColor3             = Color3.fromRGB(255, 75, 75),
		Font                   = Enum.Font.GothamSemibold,
		TextSize               = 11,
		TextXAlignment         = Enum.TextXAlignment.Center,
		Visible                = false,
		ZIndex                 = 11,
	})

	local TabSubmitNormal = Color3.fromRGB(9, 99, 195)
	local TabSubmitBtn = Create("TextButton", {
		Parent           = LockFrame,
		Size             = UDim2.new(0, 240, 0, 34),
		AnchorPoint      = Vector2.new(0.5, 0),
		Position         = UDim2.new(0.5, 0, 0, 195),
		BackgroundColor3 = TabSubmitNormal,
		BorderSizePixel  = 0,
		Text             = "Unlock Tab",
		TextColor3       = Color3.fromRGB(255, 255, 255),
		Font             = Enum.Font.GothamBold,
		TextSize         = 12,
		AutoButtonColor  = false,
		ZIndex           = 11,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 7) }),
	})

	local TabBusy = false
	local function TabTrySubmit()
		if TabBusy then return end
		TabBusy = true
		local typed = TabInputBox.Text
		for _, k in ipairs(TabKeys) do
			if typed == k then
				-- Success
				TabErrorLabel.Visible = false
				TweenService:Create(TabInputStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(0, 200, 100)}):Play()
				TweenService:Create(TabSubmitBtn,   TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(0, 160, 80)}):Play()
				TabSubmitBtn.Text = "✓  Unlocked"
				OrionPlus.EnteredKey = typed
				task.wait(0.4)
				TweenService:Create(LockFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
				task.wait(0.35)
				LockFrame:Destroy()
				OnUnlock(typed)
				return
			end
		end
		-- Fail
		TabErrorLabel.Visible = true
		TweenService:Create(TabInputStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(220, 55, 55)}):Play()
		TweenService:Create(TabSubmitBtn,   TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(150, 35, 35)}):Play()
		-- Shake
		local base = TabInputCon.Position
		for i = 1, 6 do
			TweenService:Create(TabInputCon, TweenInfo.new(0.045, Enum.EasingStyle.Linear), {
				Position = UDim2.new(base.X.Scale, base.X.Offset + ((i%2==0) and 6 or -6), base.Y.Scale, base.Y.Offset)
			}):Play()
			task.wait(0.045)
		end
		TabInputCon.Position = base
		task.wait(0.8)
		TweenService:Create(TabInputStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(60, 60, 60)}):Play()
		TweenService:Create(TabSubmitBtn,   TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = TabSubmitNormal}):Play()
		TabBusy = false
	end

	TabSubmitBtn.MouseButton1Up:Connect(function() spawn(TabTrySubmit) end)
	TabInputBox.FocusLost:Connect(function(enter) if enter then spawn(TabTrySubmit) end end)
	TabSubmitBtn.MouseEnter:Connect(function()
		TweenService:Create(TabSubmitBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(20, 120, 220)}):Play()
	end)
	TabSubmitBtn.MouseLeave:Connect(function()
		TweenService:Create(TabSubmitBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundColor3 = TabSubmitNormal}):Play()
	end)

	return LockFrame
end

function OrionPlus:MakeWindow(WindowConfig)
	local FirstTab  = true
	local Minimized = false
	local Loaded    = false
	local UIHidden  = false

	WindowConfig = WindowConfig or {}
	WindowConfig.Name          = WindowConfig.Name          or "OrionPlus"
	WindowConfig.ConfigFolder  = WindowConfig.ConfigFolder  or WindowConfig.Name
	WindowConfig.SaveConfig    = WindowConfig.SaveConfig    or false
	WindowConfig.HidePremium   = WindowConfig.HidePremium   or false
	if WindowConfig.IntroEnabled == nil then
		WindowConfig.IntroEnabled = true
	end
	WindowConfig.IntroText        = WindowConfig.IntroText        or "OrionPlus"
	WindowConfig.CloseCallback    = WindowConfig.CloseCallback    or function() end
	WindowConfig.ShowIcon         = WindowConfig.ShowIcon         or false
	WindowConfig.Icon             = WindowConfig.Icon             or "rbxassetid://8834748103"
	WindowConfig.IntroIcon        = WindowConfig.IntroIcon        or "rbxassetid://8834748103"
	-- Key system
	WindowConfig.Keys             = WindowConfig.Keys             or nil   -- table of valid key strings, or nil to disable
	WindowConfig.KeyTitle         = WindowConfig.KeyTitle         or "Authentication Required"
	WindowConfig.KeyDescription   = WindowConfig.KeyDescription   or nil   -- auto-generated if nil
	WindowConfig.KeyNote          = WindowConfig.KeyNote          or nil   -- small grey footer note
	OrionPlus.Folder              = WindowConfig.ConfigFolder
	OrionPlus.SaveCfg             = WindowConfig.SaveConfig

	if WindowConfig.SaveConfig then
		if not isfolder(WindowConfig.ConfigFolder) then
			makefolder(WindowConfig.ConfigFolder)
		end	
	end

	-- ── Global key gate ──────────────────────────────────────
	-- If Keys are configured, block here until the user enters
	-- a valid one.  Sets OrionPlus.EnteredKey on success.
	if WindowConfig.Keys and #WindowConfig.Keys > 0 then
		ShowKeyPrompt({
			Keys        = WindowConfig.Keys,
			Title       = WindowConfig.KeyTitle,
			Description = WindowConfig.KeyDescription,
			Note        = WindowConfig.KeyNote,
		})
	else
		OrionPlus.Authenticated = true
	end

	local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 4), {
		Size = UDim2.new(1, 0, 1, -50)
	}), {
		MakeElement("List"),
		MakeElement("Padding", 8, 0, 0, 8)
	}), "Divider")

	AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
	end)

	local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size                   = UDim2.new(0.5, 0, 1, 0),
		Position               = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072725342"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size     = UDim2.new(0, 18, 0, 18)
		}), "Text")
	})

	local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size                   = UDim2.new(0.5, 0, 1, 0),
		BackgroundTransparency = 1
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072719338"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size     = UDim2.new(0, 18, 0, 18),
			Name     = "Ico"
		}), "Text")
	})

	local DragPoint = SetProps(MakeElement("TFrame"), {
		Size = UDim2.new(1, 0, 0, 50)
	})

	local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
		Size     = UDim2.new(0, 150, 1, -50),
		Position = UDim2.new(0, 0, 0, 50)
	}), {
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size     = UDim2.new(1, 0, 0, 10),
			Position = UDim2.new(0, 0, 0, 0)
		}), "Second"), 
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size     = UDim2.new(0, 10, 1, 0),
			Position = UDim2.new(1, -10, 0, 0)
		}), "Second"), 
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size     = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(1, -1, 0, 0)
		}), "Stroke"), 
		TabHolder,
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size     = UDim2.new(1, 0, 0, 50),
			Position = UDim2.new(0, 0, 1, -50)
		}), {
			AddThemeObject(SetProps(MakeElement("Frame"), {
				Size = UDim2.new(1, 0, 0, 1)
			}), "Stroke"), 
			AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size        = UDim2.new(0, 32, 0, 32),
				Position    = UDim2.new(0, 10, 0.5, 0)
			}), {
				SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=".. LocalPlayer.UserId .."&width=420&height=420&format=png"), {
					Size = UDim2.new(1, 0, 1, 0)
				}),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4031889928"), {
					Size = UDim2.new(1, 0, 1, 0),
				}), "Second"),
				MakeElement("Corner", 1)
			}), "Divider"),
			SetChildren(SetProps(MakeElement("TFrame"), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size        = UDim2.new(0, 32, 0, 32),
				Position    = UDim2.new(0, 10, 0.5, 0)
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				MakeElement("Corner", 1)
			}),
			AddThemeObject(SetProps(MakeElement("Label", LocalPlayer.DisplayName, WindowConfig.HidePremium and 14 or 13), {
				Size             = UDim2.new(1, -60, 0, 13),
				Position         = WindowConfig.HidePremium and UDim2.new(0, 50, 0, 19) or UDim2.new(0, 50, 0, 12),
				Font             = Enum.Font.GothamBold,
				ClipsDescendants = true
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", "", 12), {
				Size     = UDim2.new(1, -60, 0, 12),
				Position = UDim2.new(0, 50, 1, -25),
				Visible  = not WindowConfig.HidePremium
			}), "TextDark")
		}),
	}), "Second")

	local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 14), {
		Size     = UDim2.new(1, -30, 2, 0),
		Position = UDim2.new(0, 25, 0, -24),
		Font     = Enum.Font.GothamBlack,
		TextSize = 20
	}), "Text")

	local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {
		Size     = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1)
	}), "Stroke")

	local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
		Parent           = Orion,
		Position         = UDim2.new(0.5, -307, 0.5, -172),
		Size             = UDim2.new(0, 615, 0, 344),
		ClipsDescendants = true
	}), {
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 50),
			Name = "TopBar"
		}), {
			WindowName,
			WindowTopBarLine,
			AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 7), {
				Size     = UDim2.new(0, 70, 0, 30),
				Position = UDim2.new(1, -90, 0, 10)
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				AddThemeObject(SetProps(MakeElement("Frame"), {
					Size     = UDim2.new(0, 1, 1, 0),
					Position = UDim2.new(0.5, 0, 0, 0)
				}), "Stroke"), 
				CloseBtn,
				MinimizeBtn
			}), "Second"), 
		}),
		DragPoint,
		WindowStuff
	}), "Main")

	if WindowConfig.ShowIcon then
		WindowName.Position = UDim2.new(0, 50, 0, -24)
		local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {
			Size     = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(0, 25, 0, 15)
		})
		WindowIcon.Parent = MainWindow.TopBar
	end	

	-- Attach drag (supports both mouse and touch)
	AddDraggingFunctionality(DragPoint, MainWindow)

	-- ────────────────────────────────────────────────────────
	-- Mobile reopen button (appears when UI is hidden)
	-- On PC, RightShift reopens; on mobile a tap button shows.
	-- ────────────────────────────────────────────────────────
	local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

	local MobileReopenBtn = Create("TextButton", {
		Parent               = Orion,
		Size                 = UDim2.new(0, 48, 0, 48),
		Position             = UDim2.new(0, 12, 0.5, -24),
		BackgroundColor3     = Color3.fromRGB(32, 32, 32),
		TextColor3           = Color3.fromRGB(240, 240, 240),
		Font                 = Enum.Font.GothamBold,
		TextSize             = 10,
		Text                 = "UI",
		Visible              = false,
		ZIndex               = 10,
		AutoButtonColor      = false,
	}, {
		Create("UICorner",  { CornerRadius = UDim.new(0, 10) }),
		Create("UIStroke",  { Color = Color3.fromRGB(60,60,60), Thickness = 1 }),
	})

	AddConnection(CloseBtn.MouseButton1Up, function()
		MainWindow.Visible = false
		UIHidden = true

		if isMobile then
			MobileReopenBtn.Visible = true
			OrionPlus:MakeNotification({
				Name    = "Interface Hidden",
				Content = "Tap the UI button on the left side to reopen.",
				Time    = 5
			})
		else
			OrionPlus:MakeNotification({
				Name    = "Interface Hidden",
				Content = "Press RightShift to reopen the interface.",
				Time    = 5
			})
		end

		WindowConfig.CloseCallback()
	end)

	-- Mobile reopen tap
	AddConnection(MobileReopenBtn.MouseButton1Up, function()
		MainWindow.Visible    = true
		MobileReopenBtn.Visible = false
		UIHidden = false
	end)

	-- PC reopen (RightShift)
	AddConnection(UserInputService.InputBegan, function(Input)
		if Input.KeyCode == Enum.KeyCode.RightShift and UIHidden then
			MainWindow.Visible    = true
			MobileReopenBtn.Visible = false
			UIHidden = false
		end
	end)

	AddConnection(MinimizeBtn.MouseButton1Up, function()
		if Minimized then
			TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 615, 0, 344)}):Play()
			MinimizeBtn.Ico.Image = "rbxassetid://7072719338"
			wait(.02)
			MainWindow.ClipsDescendants = false
			WindowStuff.Visible         = true
			WindowTopBarLine.Visible    = true
		else
			MainWindow.ClipsDescendants = true
			WindowTopBarLine.Visible    = false
			MinimizeBtn.Ico.Image       = "rbxassetid://7072720870"

			TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, WindowName.TextBounds.X + 140, 0, 50)}):Play()
			wait(0.1)
			WindowStuff.Visible = false	
		end
		Minimized = not Minimized    
	end)

	local function LoadSequence()
		MainWindow.Visible = false
		local LoadSequenceLogo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
			Parent            = Orion,
			AnchorPoint       = Vector2.new(0.5, 0.5),
			Position          = UDim2.new(0.5, 0, 0.4, 0),
			Size              = UDim2.new(0, 28, 0, 28),
			ImageColor3       = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 1
		})

		local LoadSequenceText = SetProps(MakeElement("Label", WindowConfig.IntroText, 14), {
			Parent             = Orion,
			Size               = UDim2.new(1, 0, 1, 0),
			AnchorPoint        = Vector2.new(0.5, 0.5),
			Position           = UDim2.new(0.5, 19, 0.5, 0),
			TextXAlignment     = Enum.TextXAlignment.Center,
			Font               = Enum.Font.GothamBold,
			TextTransparency   = 1
		})

		TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
		wait(0.8)
		TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -(LoadSequenceText.TextBounds.X/2), 0.5, 0)}):Play()
		wait(0.3)
		TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
		wait(2)
		TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
		MainWindow.Visible = true
		LoadSequenceLogo:Destroy()
		LoadSequenceText:Destroy()
	end 

	if WindowConfig.IntroEnabled then
		LoadSequence()
	end	

	local TabFunction = {}
	function TabFunction:MakeTab(TabConfig)
		TabConfig = TabConfig or {}
		TabConfig.Name        = TabConfig.Name        or "Tab"
		TabConfig.Icon        = TabConfig.Icon        or ""
		TabConfig.PremiumOnly = TabConfig.PremiumOnly or false
		TabConfig.Keys        = TabConfig.Keys        or nil  -- table of keys that unlock this tab

		-- Determine if this tab is already unlocked at creation time.
		-- A tab is unlocked when:
		--   • It has no Keys requirement, OR
		--   • The globally entered key (OrionPlus.EnteredKey) is in TabConfig.Keys
		local TabUnlocked = (TabConfig.Keys == nil)
		if not TabUnlocked and OrionPlus.EnteredKey then
			for _, k in ipairs(TabConfig.Keys) do
				if k == OrionPlus.EnteredKey then
					TabUnlocked = true
					break
				end
			end
		end

		-- Build the tab sidebar button.
		-- If the tab needs a key, append a small lock badge next to the title.
		local TitleText = TabConfig.Keys and not TabUnlocked
			and (TabConfig.Name .. "  🔒")
			or  TabConfig.Name

		local TabFrame = SetChildren(SetProps(MakeElement("Button"), {
			Size   = UDim2.new(1, 0, 0, 30),
			Parent = TabHolder
		}), {
			AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {
				AnchorPoint       = Vector2.new(0, 0.5),
				Size              = UDim2.new(0, 18, 0, 18),
				Position          = UDim2.new(0, 10, 0.5, 0),
				ImageTransparency = 0.4,
				Name              = "Ico"
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", TitleText, 14), {
				Size             = UDim2.new(1, -35, 1, 0),
				Position         = UDim2.new(0, 35, 0, 0),
				Font             = Enum.Font.GothamSemibold,
				TextTransparency = 0.4,
				Name             = "Title"
			}), "Text")
		})

		if GetIcon(TabConfig.Icon) ~= nil then
			TabFrame.Ico.Image = GetIcon(TabConfig.Icon)
		end	

		local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 5), {
			Size    = UDim2.new(1, -150, 1, -50),
			Position= UDim2.new(0, 150, 0, 50),
			Parent  = MainWindow,
			Visible = false,
			Name    = "ItemContainer"
		}), {
			MakeElement("List", 0, 6),
			MakeElement("Padding", 15, 10, 10, 15)
		}), "Divider")

		AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 30)
		end)

		-- Key-lock overlay (nil when the tab has no key requirement or is already unlocked)
		local LockOverlay = nil
		if TabConfig.Keys and not TabUnlocked then
			-- Build a Frame with the same position/size as the container so it slots
			-- in as another "ItemContainer"-named child and gets hidden on tab switches.
			local LockHost = Create("Frame", {
				Parent           = MainWindow,
				Size             = UDim2.new(1, -150, 1, -50),
				Position         = UDim2.new(0, 150, 0, 50),
				BackgroundColor3 = Color3.fromRGB(22, 22, 22),
				BorderSizePixel  = 0,
				Visible          = false,
				Name             = "ItemContainer",  -- same name → hidden by tab-switch loop
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 0) }),
			})

			LockOverlay = LockHost

			MakeTabKeyLock(LockHost, TabConfig.Keys, function(unlockedWith)
				-- Called when the user enters the correct key.
				-- Remove the lock badge from the tab label.
				TabFrame.Title.Text = TabConfig.Name
				TabUnlocked         = true
				LockOverlay         = nil
				-- Switch to the real container.
				for _, ic in next, MainWindow:GetChildren() do
					if ic.Name == "ItemContainer" then ic.Visible = false end
				end
				Container.Visible = true
			end)
		end

		if FirstTab then
			FirstTab = false
			TabFrame.Ico.ImageTransparency  = 0
			TabFrame.Title.TextTransparency = 0
			TabFrame.Title.Font             = Enum.Font.GothamBlack
			-- Only show the real container on first tab if it's unlocked
			if TabUnlocked then
				Container.Visible = true
			elseif LockOverlay then
				LockOverlay.Visible = true
			end
		end    

		AddConnection(TabFrame.MouseButton1Click, function()
			-- Dim all tab buttons
			for _, Tab in next, TabHolder:GetChildren() do
				if Tab:IsA("TextButton") then
					Tab.Title.Font = Enum.Font.GothamSemibold
					TweenService:Create(Tab.Ico,   TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0.4}):Play()
					TweenService:Create(Tab.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency  = 0.4}):Play()
				end    
			end
			-- Hide all containers
			for _, ItemContainer in next, MainWindow:GetChildren() do
				if ItemContainer.Name == "ItemContainer" then
					ItemContainer.Visible = false
				end    
			end
			-- Highlight this tab button
			TweenService:Create(TabFrame.Ico,   TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
			TweenService:Create(TabFrame.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency  = 0}):Play()
			TabFrame.Title.Font = Enum.Font.GothamBlack

			-- Show content: real container if unlocked, lock overlay otherwise
			if TabUnlocked then
				Container.Visible = true
			elseif LockOverlay and LockOverlay.Parent then
				LockOverlay.Visible = true
			end
		end)

		local function GetElements(ItemParent)
			local ElementFunction = {}

			function ElementFunction:AddLabel(Text)
				local LabelFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size                   = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent                 = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
						Size     = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font     = Enum.Font.GothamBold,
						Name     = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")

				local LabelFunction = {}
				function LabelFunction:Set(ToChange)
					LabelFrame.Content.Text = ToChange
				end
				return LabelFunction
			end

			function ElementFunction:AddParagraph(Text, Content)
				Text    = Text    or "Text"
				Content = Content or "Content"

				local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size                   = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent                 = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
						Size     = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 10),
						Font     = Enum.Font.GothamBold,
						Name     = "Title"
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Label", "", 13), {
						Size        = UDim2.new(1, -24, 0, 0),
						Position    = UDim2.new(0, 12, 0, 26),
						Font        = Enum.Font.GothamSemibold,
						Name        = "Content",
						TextWrapped = true
					}), "TextDark"),
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")

				AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), function()
					ParagraphFrame.Content.Size = UDim2.new(1, -24, 0, ParagraphFrame.Content.TextBounds.Y)
					ParagraphFrame.Size         = UDim2.new(1, 0, 0, ParagraphFrame.Content.TextBounds.Y + 35)
				end)

				ParagraphFrame.Content.Text = Content

				local ParagraphFunction = {}
				function ParagraphFunction:Set(ToChange)
					ParagraphFrame.Content.Text = ToChange
				end
				return ParagraphFunction
			end    

			function ElementFunction:AddButton(ButtonConfig)
				ButtonConfig = ButtonConfig or {}
				ButtonConfig.Name     = ButtonConfig.Name     or "Button"
				ButtonConfig.Callback = ButtonConfig.Callback or function() end
				ButtonConfig.Icon     = ButtonConfig.Icon     or "rbxassetid://3944703587"

				local Button = {}

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local ButtonFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size   = UDim2.new(1, 0, 0, 33),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name, 15), {
						Size     = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font     = Enum.Font.GothamBold,
						Name     = "Content"
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Image", ButtonConfig.Icon), {
						Size     = UDim2.new(0, 20, 0, 20),
						Position = UDim2.new(1, -30, 0, 7),
					}), "TextDark"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					Click
				}), "Second")

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionPlus.Themes[OrionPlus.SelectedTheme].Second.R * 255 + 3, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.G * 255 + 3, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)

				AddConnection(Click.MouseLeave, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionPlus.Themes[OrionPlus.SelectedTheme].Second}):Play()
				end)

				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionPlus.Themes[OrionPlus.SelectedTheme].Second.R * 255 + 3, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.G * 255 + 3, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.B * 255 + 3)}):Play()
					spawn(function()
						ButtonConfig.Callback()
					end)
				end)

				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionPlus.Themes[OrionPlus.SelectedTheme].Second.R * 255 + 6, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.G * 255 + 6, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)

				function Button:Set(ButtonText)
					ButtonFrame.Content.Text = ButtonText
				end	

				return Button
			end    

			function ElementFunction:AddToggle(ToggleConfig)
				ToggleConfig = ToggleConfig or {}
				ToggleConfig.Name     = ToggleConfig.Name     or "Toggle"
				ToggleConfig.Default  = ToggleConfig.Default  or false
				ToggleConfig.Callback = ToggleConfig.Callback or function() end
				ToggleConfig.Color    = ToggleConfig.Color    or Color3.fromRGB(9, 99, 195)
				ToggleConfig.Flag     = ToggleConfig.Flag     or nil
				ToggleConfig.Save     = ToggleConfig.Save     or false

				local Toggle = {Value = ToggleConfig.Default, Save = ToggleConfig.Save}

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local ToggleBox = SetChildren(SetProps(MakeElement("RoundFrame", ToggleConfig.Color, 0, 4), {
					Size        = UDim2.new(0, 24, 0, 24),
					Position    = UDim2.new(1, -24, 0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5)
				}), {
					SetProps(MakeElement("Stroke"), {
						Color        = ToggleConfig.Color,
						Name         = "Stroke",
						Transparency = 0.5
					}),
					SetProps(MakeElement("Image", "rbxassetid://3944680095"), {
						Size        = UDim2.new(0, 20, 0, 20),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position    = UDim2.new(0.5, 0, 0.5, 0),
						ImageColor3 = Color3.fromRGB(255, 255, 255),
						Name        = "Ico"
					}),
				})

				local ToggleFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size   = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", ToggleConfig.Name, 15), {
						Size     = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font     = Enum.Font.GothamBold,
						Name     = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					ToggleBox,
					Click
				}), "Second")

				function Toggle:Set(Value)
					Toggle.Value = Value
					TweenService:Create(ToggleBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Toggle.Value and ToggleConfig.Color or OrionPlus.Themes.Default.Divider}):Play()
					TweenService:Create(ToggleBox.Stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Toggle.Value and ToggleConfig.Color or OrionPlus.Themes.Default.Stroke}):Play()
					TweenService:Create(ToggleBox.Ico, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = Toggle.Value and 0 or 1, Size = Toggle.Value and UDim2.new(0, 20, 0, 20) or UDim2.new(0, 8, 0, 8)}):Play()
					ToggleConfig.Callback(Toggle.Value)
				end    

				Toggle:Set(Toggle.Value)

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionPlus.Themes[OrionPlus.SelectedTheme].Second.R * 255 + 3, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.G * 255 + 3, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)

				AddConnection(Click.MouseLeave, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionPlus.Themes[OrionPlus.SelectedTheme].Second}):Play()
				end)

				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionPlus.Themes[OrionPlus.SelectedTheme].Second.R * 255 + 3, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.G * 255 + 3, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.B * 255 + 3)}):Play()
					SaveCfg(game.GameId)
					Toggle:Set(not Toggle.Value)
				end)

				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionPlus.Themes[OrionPlus.SelectedTheme].Second.R * 255 + 6, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.G * 255 + 6, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)

				if ToggleConfig.Flag then
					OrionPlus.Flags[ToggleConfig.Flag] = Toggle
				end	
				return Toggle
			end  

			function ElementFunction:AddSlider(SliderConfig)
				SliderConfig = SliderConfig or {}
				SliderConfig.Name      = SliderConfig.Name      or "Slider"
				SliderConfig.Min       = SliderConfig.Min       or 0
				SliderConfig.Max       = SliderConfig.Max       or 100
				SliderConfig.Increment = SliderConfig.Increment or 1
				SliderConfig.Default   = SliderConfig.Default   or 50
				SliderConfig.Callback  = SliderConfig.Callback  or function() end
				SliderConfig.ValueName = SliderConfig.ValueName or ""
				SliderConfig.Color     = SliderConfig.Color     or Color3.fromRGB(9, 149, 98)
				SliderConfig.Flag      = SliderConfig.Flag      or nil
				SliderConfig.Save      = SliderConfig.Save      or false

				local Slider   = {Value = SliderConfig.Default, Save = SliderConfig.Save}
				local Dragging = false

				local SliderDrag = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 5), {
					Size                   = UDim2.new(0, 0, 1, 0),
					BackgroundTransparency = 0.3,
					ClipsDescendants       = true
				}), {
					AddThemeObject(SetProps(MakeElement("Label", "value", 13), {
						Size             = UDim2.new(1, -12, 0, 14),
						Position         = UDim2.new(0, 12, 0, 6),
						Font             = Enum.Font.GothamBold,
						Name             = "Value",
						TextTransparency = 0
					}), "Text")
				})

				local SliderBar = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 5), {
					Size                   = UDim2.new(1, -24, 0, 26),
					Position               = UDim2.new(0, 12, 0, 30),
					BackgroundTransparency = 0.9
				}), {
					SetProps(MakeElement("Stroke"), {
						Color = SliderConfig.Color
					}),
					AddThemeObject(SetProps(MakeElement("Label", "value", 13), {
						Size             = UDim2.new(1, -12, 0, 14),
						Position         = UDim2.new(0, 12, 0, 6),
						Font             = Enum.Font.GothamBold,
						Name             = "Value",
						TextTransparency = 0.8
					}), "Text"),
					SliderDrag
				})

				local SliderFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size   = UDim2.new(1, 0, 0, 65),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", SliderConfig.Name, 15), {
						Size     = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 10),
						Font     = Enum.Font.GothamBold,
						Name     = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					SliderBar
				}), "Second")

				-- Mouse + Touch begin
				SliderBar.InputBegan:Connect(function(Input)
					if
						Input.UserInputType == Enum.UserInputType.MouseButton1
						or Input.UserInputType == Enum.UserInputType.Touch
					then
						Dragging = true
					end
				end)

				-- Mouse + Touch end
				SliderBar.InputEnded:Connect(function(Input)
					if
						Input.UserInputType == Enum.UserInputType.MouseButton1
						or Input.UserInputType == Enum.UserInputType.Touch
					then
						Dragging = false
					end
				end)

				-- Mouse move + Touch move
				UserInputService.InputChanged:Connect(function(Input)
					if Dragging and (
						Input.UserInputType == Enum.UserInputType.MouseMovement
						or Input.UserInputType == Enum.UserInputType.Touch
					) then
						local SizeScale = math.clamp(
							(Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X,
							0, 1
						)
						Slider:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale))
						SaveCfg(game.GameId)
					end
				end)

				function Slider:Set(Value)
					self.Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
					TweenService:Create(SliderDrag, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromScale((self.Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 1)}):Play()
					SliderBar.Value.Text  = tostring(self.Value) .. " " .. SliderConfig.ValueName
					SliderDrag.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
					SliderConfig.Callback(self.Value)
				end      

				Slider:Set(Slider.Value)
				if SliderConfig.Flag then				
					OrionPlus.Flags[SliderConfig.Flag] = Slider
				end
				return Slider
			end  

			function ElementFunction:AddDropdown(DropdownConfig)
				DropdownConfig = DropdownConfig or {}
				DropdownConfig.Name     = DropdownConfig.Name     or "Dropdown"
				DropdownConfig.Options  = DropdownConfig.Options  or {}
				DropdownConfig.Default  = DropdownConfig.Default  or ""
				DropdownConfig.Callback = DropdownConfig.Callback or function() end
				DropdownConfig.Flag     = DropdownConfig.Flag     or nil
				DropdownConfig.Save     = DropdownConfig.Save     or false

				local Dropdown = {Value = DropdownConfig.Default, Options = DropdownConfig.Options, Buttons = {}, Toggled = false, Type = "Dropdown", Save = DropdownConfig.Save}
				local MaxElements = 5

				if not table.find(Dropdown.Options, Dropdown.Value) then
					Dropdown.Value = "..."
				end

				local DropdownList = MakeElement("List")

				local DropdownContainer = AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame", Color3.fromRGB(40, 40, 40), 4), {
					DropdownList
				}), {
					Parent           = ItemParent,
					Position         = UDim2.new(0, 0, 0, 38),
					Size             = UDim2.new(1, 0, 1, -38),
					ClipsDescendants = true
				}), "Divider")

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local DropdownFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size             = UDim2.new(1, 0, 0, 38),
					Parent           = ItemParent,
					ClipsDescendants = true
				}), {
					DropdownContainer,
					SetProps(SetChildren(MakeElement("TFrame"), {
						AddThemeObject(SetProps(MakeElement("Label", DropdownConfig.Name, 15), {
							Size     = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 12, 0, 0),
							Font     = Enum.Font.GothamBold,
							Name     = "Content"
						}), "Text"),
						AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072706796"), {
							Size        = UDim2.new(0, 20, 0, 20),
							AnchorPoint = Vector2.new(0, 0.5),
							Position    = UDim2.new(1, -30, 0.5, 0),
							ImageColor3 = Color3.fromRGB(240, 240, 240),
							Name        = "Ico"
						}), "TextDark"),
						AddThemeObject(SetProps(MakeElement("Label", "Selected", 13), {
							Size           = UDim2.new(1, -40, 1, 0),
							Font           = Enum.Font.Gotham,
							Name           = "Selected",
							TextXAlignment = Enum.TextXAlignment.Right
						}), "TextDark"),
						AddThemeObject(SetProps(MakeElement("Frame"), {
							Size     = UDim2.new(1, 0, 0, 1),
							Position = UDim2.new(0, 0, 1, -1),
							Name     = "Line",
							Visible  = false
						}), "Stroke"), 
						Click
					}), {
						Size             = UDim2.new(1, 0, 0, 38),
						ClipsDescendants = true,
						Name             = "F"
					}),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					MakeElement("Corner")
				}), "Second")

				AddConnection(DropdownList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
					DropdownContainer.CanvasSize = UDim2.new(0, 0, 0, DropdownList.AbsoluteContentSize.Y)
				end)  

				local function AddOptions(Options)
					for _, Option in pairs(Options) do
						local OptionBtn = AddThemeObject(SetProps(SetChildren(MakeElement("Button", Color3.fromRGB(40, 40, 40)), {
							MakeElement("Corner", 0, 6),
							AddThemeObject(SetProps(MakeElement("Label", Option, 13, 0.4), {
								Position = UDim2.new(0, 8, 0, 0),
								Size     = UDim2.new(1, -8, 1, 0),
								Name     = "Title"
							}), "Text")
						}), {
							Parent               = DropdownContainer,
							Size                 = UDim2.new(1, 0, 0, 28),
							BackgroundTransparency = 1,
							ClipsDescendants     = true
						}), "Divider")

						AddConnection(OptionBtn.MouseButton1Click, function()
							Dropdown:Set(Option)
							SaveCfg(game.GameId)
						end)

						Dropdown.Buttons[Option] = OptionBtn
					end
				end	

				function Dropdown:Refresh(Options, Delete)
					if Delete then
						for _,v in pairs(Dropdown.Buttons) do
							v:Destroy()
						end    
						table.clear(Dropdown.Options)
						table.clear(Dropdown.Buttons)
					end
					Dropdown.Options = Options
					AddOptions(Dropdown.Options)
				end  

				function Dropdown:Set(Value)
					if not table.find(Dropdown.Options, Value) then
						Dropdown.Value = "..."
						DropdownFrame.F.Selected.Text = Dropdown.Value
						for _, v in pairs(Dropdown.Buttons) do
							TweenService:Create(v, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
							TweenService:Create(v.Title, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
						end	
						return
					end

					Dropdown.Value = Value
					DropdownFrame.F.Selected.Text = Dropdown.Value

					for _, v in pairs(Dropdown.Buttons) do
						TweenService:Create(v, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
						TweenService:Create(v.Title, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
					end	
					TweenService:Create(Dropdown.Buttons[Value], TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
					TweenService:Create(Dropdown.Buttons[Value].Title, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
					return DropdownConfig.Callback(Dropdown.Value)
				end

				AddConnection(Click.MouseButton1Click, function()
					Dropdown.Toggled = not Dropdown.Toggled
					DropdownFrame.F.Line.Visible = Dropdown.Toggled
					TweenService:Create(DropdownFrame.F.Ico, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = Dropdown.Toggled and 180 or 0}):Play()
					if #Dropdown.Options > MaxElements then
						TweenService:Create(DropdownFrame, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Dropdown.Toggled and UDim2.new(1, 0, 0, 38 + (MaxElements * 28)) or UDim2.new(1, 0, 0, 38)}):Play()
					else
						TweenService:Create(DropdownFrame, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Dropdown.Toggled and UDim2.new(1, 0, 0, DropdownList.AbsoluteContentSize.Y + 38) or UDim2.new(1, 0, 0, 38)}):Play()
					end
				end)

				Dropdown:Refresh(Dropdown.Options, false)
				Dropdown:Set(Dropdown.Value)
				if DropdownConfig.Flag then				
					OrionPlus.Flags[DropdownConfig.Flag] = Dropdown
				end
				return Dropdown
			end

			function ElementFunction:AddBind(BindConfig)
				BindConfig.Name     = BindConfig.Name     or "Bind"
				BindConfig.Default  = BindConfig.Default  or Enum.KeyCode.Unknown
				BindConfig.Hold     = BindConfig.Hold     or false
				BindConfig.Callback = BindConfig.Callback or function() end
				BindConfig.Flag     = BindConfig.Flag     or nil
				BindConfig.Save     = BindConfig.Save     or false

				local Bind    = {Value = nil, Binding = false, Type = "Bind", Save = BindConfig.Save}
				local Holding = false

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local BindBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size        = UDim2.new(0, 24, 0, 24),
					Position    = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 14), {
						Size           = UDim2.new(1, 0, 1, 0),
						Font           = Enum.Font.GothamBold,
						TextXAlignment = Enum.TextXAlignment.Center,
						Name           = "Value"
					}), "Text")
				}), "Main")

				local BindFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size   = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 15), {
						Size     = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font     = Enum.Font.GothamBold,
						Name     = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					BindBox,
					Click
				}), "Second")

				AddConnection(BindBox.Value:GetPropertyChangedSignal("Text"), function()
					TweenService:Create(BindBox, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, BindBox.Value.TextBounds.X + 16, 0, 24)}):Play()
				end)

				AddConnection(Click.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						if Bind.Binding then return end
						Bind.Binding = true
						BindBox.Value.Text = ""
					end
				end)

				AddConnection(UserInputService.InputBegan, function(Input)
					if UserInputService:GetFocusedTextBox() then return end
					if (Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value) and not Bind.Binding then
						if BindConfig.Hold then
							Holding = true
							BindConfig.Callback(Holding)
						else
							BindConfig.Callback()
						end
					elseif Bind.Binding then
						local Key
						pcall(function()
							if not CheckKey(BlacklistedKeys, Input.KeyCode) then
								Key = Input.KeyCode
							end
						end)
						pcall(function()
							if CheckKey(WhitelistedMouse, Input.UserInputType) and not Key then
								Key = Input.UserInputType
							end
						end)
						Key = Key or Bind.Value
						Bind:Set(Key)
						SaveCfg(game.GameId)
					end
				end)

				AddConnection(UserInputService.InputEnded, function(Input)
					if Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value then
						if BindConfig.Hold and Holding then
							Holding = false
							BindConfig.Callback(Holding)
						end
					end
				end)

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionPlus.Themes[OrionPlus.SelectedTheme].Second.R * 255 + 3, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.G * 255 + 3, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)

				AddConnection(Click.MouseLeave, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionPlus.Themes[OrionPlus.SelectedTheme].Second}):Play()
				end)

				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionPlus.Themes[OrionPlus.SelectedTheme].Second.R * 255 + 3, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.G * 255 + 3, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)

				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionPlus.Themes[OrionPlus.SelectedTheme].Second.R * 255 + 6, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.G * 255 + 6, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)

				function Bind:Set(Key)
					Bind.Binding   = false
					Bind.Value     = Key or Bind.Value
					Bind.Value     = Bind.Value.Name or Bind.Value
					BindBox.Value.Text = Bind.Value
				end

				Bind:Set(BindConfig.Default)
				if BindConfig.Flag then				
					OrionPlus.Flags[BindConfig.Flag] = Bind
				end
				return Bind
			end  

			function ElementFunction:AddTextbox(TextboxConfig)
				TextboxConfig = TextboxConfig or {}
				TextboxConfig.Name           = TextboxConfig.Name           or "Textbox"
				TextboxConfig.Default        = TextboxConfig.Default        or ""
				TextboxConfig.TextDisappear  = TextboxConfig.TextDisappear  or false
				TextboxConfig.Callback       = TextboxConfig.Callback       or function() end

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local TextboxActual = AddThemeObject(Create("TextBox", {
					Size               = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					TextColor3         = Color3.fromRGB(255, 255, 255),
					PlaceholderColor3  = Color3.fromRGB(210, 210, 210),
					PlaceholderText    = "Input",
					Font               = Enum.Font.GothamSemibold,
					TextXAlignment     = Enum.TextXAlignment.Center,
					TextSize           = 14,
					ClearTextOnFocus   = false
				}), "Text")

				local TextContainer = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size        = UDim2.new(0, 24, 0, 24),
					Position    = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					TextboxActual
				}), "Main")

				local TextboxFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size   = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", TextboxConfig.Name, 15), {
						Size     = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font     = Enum.Font.GothamBold,
						Name     = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					TextContainer,
					Click
				}), "Second")

				AddConnection(TextboxActual:GetPropertyChangedSignal("Text"), function()
					TweenService:Create(TextContainer, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, TextboxActual.TextBounds.X + 16, 0, 24)}):Play()
				end)

				AddConnection(TextboxActual.FocusLost, function()
					TextboxConfig.Callback(TextboxActual.Text)
					if TextboxConfig.TextDisappear then
						TextboxActual.Text = ""
					end	
				end)

				TextboxActual.Text = TextboxConfig.Default

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionPlus.Themes[OrionPlus.SelectedTheme].Second.R * 255 + 3, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.G * 255 + 3, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)

				AddConnection(Click.MouseLeave, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionPlus.Themes[OrionPlus.SelectedTheme].Second}):Play()
				end)

				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionPlus.Themes[OrionPlus.SelectedTheme].Second.R * 255 + 3, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.G * 255 + 3, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.B * 255 + 3)}):Play()
					TextboxActual:CaptureFocus()
				end)

				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionPlus.Themes[OrionPlus.SelectedTheme].Second.R * 255 + 6, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.G * 255 + 6, OrionPlus.Themes[OrionPlus.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)
			end 

			function ElementFunction:AddColorpicker(ColorpickerConfig)
				ColorpickerConfig = ColorpickerConfig or {}
				ColorpickerConfig.Name     = ColorpickerConfig.Name     or "Colorpicker"
				ColorpickerConfig.Default  = ColorpickerConfig.Default  or Color3.fromRGB(255,255,255)
				ColorpickerConfig.Callback = ColorpickerConfig.Callback or function() end
				ColorpickerConfig.Flag     = ColorpickerConfig.Flag     or nil
				ColorpickerConfig.Save     = ColorpickerConfig.Save     or false

				local ColorH, ColorS, ColorV = 1, 1, 1
				local Colorpicker = {Value = ColorpickerConfig.Default, Toggled = false, Type = "Colorpicker", Save = ColorpickerConfig.Save}

				local ColorSelection = Create("ImageLabel", {
					Size              = UDim2.new(0, 18, 0, 18),
					Position          = UDim2.new(select(3, Color3.toHSV(Colorpicker.Value))),
					ScaleType         = Enum.ScaleType.Fit,
					AnchorPoint       = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image             = "http://www.roblox.com/asset/?id=4805639000"
				})

				local HueSelection = Create("ImageLabel", {
					Size              = UDim2.new(0, 18, 0, 18),
					Position          = UDim2.new(0.5, 0, 1 - select(1, Color3.toHSV(Colorpicker.Value))),
					ScaleType         = Enum.ScaleType.Fit,
					AnchorPoint       = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image             = "http://www.roblox.com/asset/?id=4805639000"
				})

				local Color = Create("ImageLabel", {
					Size    = UDim2.new(1, -25, 1, 0),
					Visible = false,
					Image   = "rbxassetid://4155801252"
				}, {
					Create("UICorner", {CornerRadius = UDim.new(0, 5)}),
					ColorSelection
				})

				local Hue = Create("Frame", {
					Size     = UDim2.new(0, 20, 1, 0),
					Position = UDim2.new(1, -20, 0, 0),
					Visible  = false
				}, {
					Create("UIGradient", {Rotation = 270, Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)), ColorSequenceKeypoint.new(0.20, Color3.fromRGB(234, 255, 0)), ColorSequenceKeypoint.new(0.40, Color3.fromRGB(21, 255, 0)), ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 17, 255)), ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 0, 251)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 4))}}),
					Create("UICorner", {CornerRadius = UDim.new(0, 5)}),
					HueSelection
				})

				local ColorpickerContainer = Create("Frame", {
					Position         = UDim2.new(0, 0, 0, 32),
					Size             = UDim2.new(1, 0, 1, -32),
					BackgroundTransparency = 1,
					ClipsDescendants = true
				}, {
					Hue,
					Color,
					Create("UIPadding", {
						PaddingLeft   = UDim.new(0, 35),
						PaddingRight  = UDim.new(0, 35),
						PaddingBottom = UDim.new(0, 10),
						PaddingTop    = UDim.new(0, 17)
					})
				})

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local ColorpickerBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size        = UDim2.new(0, 24, 0, 24),
					Position    = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Main")

				local ColorpickerFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size   = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					SetProps(SetChildren(MakeElement("TFrame"), {
						AddThemeObject(SetProps(MakeElement("Label", ColorpickerConfig.Name, 15), {
							Size     = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 12, 0, 0),
							Font     = Enum.Font.GothamBold,
							Name     = "Content"
						}), "Text"),
						ColorpickerBox,
						Click,
						AddThemeObject(SetProps(MakeElement("Frame"), {
							Size     = UDim2.new(1, 0, 0, 1),
							Position = UDim2.new(0, 0, 1, -1),
							Name     = "Line",
							Visible  = false
						}), "Stroke"), 
					}), {
						Size             = UDim2.new(1, 0, 0, 38),
						ClipsDescendants = true,
						Name             = "F"
					}),
					ColorpickerContainer,
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
				}), "Second")

				AddConnection(Click.MouseButton1Click, function()
					Colorpicker.Toggled = not Colorpicker.Toggled
					TweenService:Create(ColorpickerFrame, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Colorpicker.Toggled and UDim2.new(1, 0, 0, 148) or UDim2.new(1, 0, 0, 38)}):Play()
					Color.Visible = Colorpicker.Toggled
					Hue.Visible   = Colorpicker.Toggled
					ColorpickerFrame.F.Line.Visible = Colorpicker.Toggled
				end)

				local function UpdateColorPicker()
					ColorpickerBox.BackgroundColor3 = Color3.fromHSV(ColorH, ColorS, ColorV)
					Color.BackgroundColor3          = Color3.fromHSV(ColorH, 1, 1)
					Colorpicker:Set(ColorpickerBox.BackgroundColor3)
					ColorpickerConfig.Callback(ColorpickerBox.BackgroundColor3)
					SaveCfg(game.GameId)
				end

				ColorH = 1 - (math.clamp(HueSelection.AbsolutePosition.Y - Hue.AbsolutePosition.Y,   0, Hue.AbsoluteSize.Y)   / Hue.AbsoluteSize.Y)
				ColorS = (math.clamp(ColorSelection.AbsolutePosition.X  - Color.AbsolutePosition.X,  0, Color.AbsoluteSize.X)  / Color.AbsoluteSize.X)
				ColorV = 1 - (math.clamp(ColorSelection.AbsolutePosition.Y - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y) / Color.AbsoluteSize.Y)

				-- Color picker: Mouse + Touch
				AddConnection(Color.InputBegan, function(input)
					if
						input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch
					then
						if ColorInput then ColorInput:Disconnect() end
						ColorInput = AddConnection(RunService.RenderStepped, function()
							local posX = (input.UserInputType == Enum.UserInputType.Touch)
								and UserInputService:GetTouchState()[1] and UserInputService:GetTouchState()[1].Position.X or Mouse.X
							local posY = (input.UserInputType == Enum.UserInputType.Touch)
								and UserInputService:GetTouchState()[1] and UserInputService:GetTouchState()[1].Position.Y or Mouse.Y
							-- Fallback to Mouse for touch if touch state unavailable
							posX = posX or Mouse.X
							posY = posY or Mouse.Y
							local ColorX = (math.clamp(posX - Color.AbsolutePosition.X, 0, Color.AbsoluteSize.X) / Color.AbsoluteSize.X)
							local ColorY = (math.clamp(posY - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y) / Color.AbsoluteSize.Y)
							ColorSelection.Position = UDim2.new(ColorX, 0, ColorY, 0)
							ColorS = ColorX
							ColorV = 1 - ColorY
							UpdateColorPicker()
						end)
					end
				end)

				AddConnection(Color.InputEnded, function(input)
					if
						input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch
					then
						if ColorInput then ColorInput:Disconnect() end
					end
				end)

				-- Hue picker: Mouse + Touch
				AddConnection(Hue.InputBegan, function(input)
					if
						input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch
					then
						if HueInput then HueInput:Disconnect() end

						HueInput = AddConnection(RunService.RenderStepped, function()
							local posY = (input.UserInputType == Enum.UserInputType.Touch)
								and UserInputService:GetTouchState()[1] and UserInputService:GetTouchState()[1].Position.Y or Mouse.Y
							posY = posY or Mouse.Y
							local HueY = (math.clamp(posY - Hue.AbsolutePosition.Y, 0, Hue.AbsoluteSize.Y) / Hue.AbsoluteSize.Y)
							HueSelection.Position = UDim2.new(0.5, 0, HueY, 0)
							ColorH = 1 - HueY
							UpdateColorPicker()
						end)
					end
				end)

				AddConnection(Hue.InputEnded, function(input)
					if
						input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch
					then
						if HueInput then HueInput:Disconnect() end
					end
				end)

				function Colorpicker:Set(Value)
					Colorpicker.Value               = Value
					ColorpickerBox.BackgroundColor3 = Colorpicker.Value
					ColorpickerConfig.Callback(Colorpicker.Value)
				end

				Colorpicker:Set(Colorpicker.Value)
				if ColorpickerConfig.Flag then				
					OrionPlus.Flags[ColorpickerConfig.Flag] = Colorpicker
				end
				return Colorpicker
			end  

			return ElementFunction   
		end	

		local ElementFunction = {}

		function ElementFunction:AddSection(SectionConfig)
			SectionConfig.Name = SectionConfig.Name or "Section"

			local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {
				Size   = UDim2.new(1, 0, 0, 26),
				Parent = Container
			}), {
				AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name, 14), {
					Size     = UDim2.new(1, -12, 0, 16),
					Position = UDim2.new(0, 0, 0, 3),
					Font     = Enum.Font.GothamSemibold
				}), "TextDark"),
				SetChildren(SetProps(MakeElement("TFrame"), {
					AnchorPoint = Vector2.new(0, 0),
					Size        = UDim2.new(1, 0, 1, -24),
					Position    = UDim2.new(0, 0, 0, 23),
					Name        = "Holder"
				}), {
					MakeElement("List", 0, 6)
				}),
			})

			AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				SectionFrame.Size        = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 31)
				SectionFrame.Holder.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
			end)

			local SectionFunction = {}
			for i, v in next, GetElements(SectionFrame.Holder) do
				SectionFunction[i] = v 
			end
			return SectionFunction
		end	

		for i, v in next, GetElements(Container) do
			ElementFunction[i] = v 
		end

		if TabConfig.PremiumOnly then
			for i, v in next, ElementFunction do
				ElementFunction[i] = function() end
			end    
			Container:FindFirstChild("UIListLayout"):Destroy()
			Container:FindFirstChild("UIPadding"):Destroy()
			SetChildren(SetProps(MakeElement("TFrame"), {
				Size   = UDim2.new(1, 0, 1, 0),
				Parent = Container
			}), {
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://3610239960"), {
					Size             = UDim2.new(0, 18, 0, 18),
					Position         = UDim2.new(0, 15, 0, 15),
					ImageTransparency = 0.4
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Unauthorised Access", 14), {
					Size             = UDim2.new(1, -38, 0, 14),
					Position         = UDim2.new(0, 38, 0, 18),
					TextTransparency = 0.4
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4483345875"), {
					Size     = UDim2.new(0, 56, 0, 56),
					Position = UDim2.new(0, 84, 0, 110),
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Premium Features", 14), {
					Size     = UDim2.new(1, -150, 0, 14),
					Position = UDim2.new(0, 150, 0, 112),
					Font     = Enum.Font.GothamBold
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "This part of the script is locked to premium users.", 12), {
					Size             = UDim2.new(1, -200, 0, 14),
					Position         = UDim2.new(0, 150, 0, 138),
					TextWrapped      = true,
					TextTransparency = 0.4
				}), "Text")
			})
		end

		return ElementFunction   
	end  

	return TabFunction
end   

function OrionPlus:Destroy()
	Orion:Destroy()
end

return OrionPlus
