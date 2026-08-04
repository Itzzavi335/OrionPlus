OrionPlus = loadstring(game:HttpGet("YOUR_RAW_SOURCE_URL"))()

-- ════════════════════════════════════════════════════════════
-- 1. MAKE WINDOW
-- ════════════════════════════════════════════════════════════
--[[
    OrionPlus:MakeWindow({
        Name          = string,     -- Title shown at the top.         Default: "OrionPlus"
        IntroEnabled  = boolean,    -- Show the intro animation.       Default: true
        IntroText     = string,     -- Text during intro.              Default: "OrionPlus"
        IntroIcon     = string,     -- Roblox asset ID for intro icon. Default: built-in
        Icon          = string,     -- Asset ID shown next to title.   Default: built-in
        ShowIcon      = boolean,    -- Show the icon next to title.    Default: false
        HidePremium   = boolean,    -- Hide the premium label.         Default: false
        SaveConfig    = boolean,    -- Auto-save / auto-load flags.    Default: false
        ConfigFolder  = string,     -- Folder name for saved configs.  Default: Window name
        CloseCallback = function,   -- Called when the X is pressed.   Default: function()end
    })
    Returns: TabFunction (use :MakeTab on it)
]]

local Window = OrionPlus:MakeWindow({
    Name          = "My Script",
    IntroEnabled  = true,
    IntroText     = "My Script",
    IntroIcon     = "rbxassetid://8834748103",
    Icon          = "rbxassetid://8834748103",
    ShowIcon      = true,
    HidePremium   = false,
    SaveConfig    = true,
    ConfigFolder  = "MyScriptConfig",
    CloseCallback = function()
        print("UI was closed!")
    end,
})

-- ════════════════════════════════════════════════════════════
-- 2. MAKE TAB
-- ════════════════════════════════════════════════════════════
--[[
    Window:MakeTab({
        Name        = string,    -- Tab label.               Default: "Tab"
        Icon        = string,    -- Feather icon name OR asset ID. Default: ""
        PremiumOnly = boolean,   -- Locks tab to premium.   Default: false
    })
    Returns: ElementFunction (add elements to the tab)

    Feather icon names: "home", "settings", "user", "star", "zap",
    "shield", "lock", "eye", "compass", "activity", etc.
    Full list: https://github.com/evoincorp/lucideblox
]]

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345875",
})

local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://3610239960",
})

local PremiumTab = Window:MakeTab({
    Name        = "VIP",
    Icon        = "rbxassetid://4483345875",
    PremiumOnly = true,   -- shows a locked message instead of elements
})

-- ════════════════════════════════════════════════════════════
-- 3. SECTION  (groups elements under a heading)
-- ════════════════════════════════════════════════════════════
--[[
    Tab:AddSection({ Name = string })
    Returns: SectionFunction (same API as the tab — add elements inside)
]]

local CombatSection = MainTab:AddSection({ Name = "Combat" })

-- ════════════════════════════════════════════════════════════
-- 4. LABEL  (static read-only text row)
-- ════════════════════════════════════════════════════════════
--[[
    Tab/Section:AddLabel(text: string)
    Returns: LabelFunction
        :Set(text: string)   — update the label text at runtime
]]

local MyLabel = MainTab:AddLabel("This is a label")
MyLabel:Set("Label updated!")

-- ════════════════════════════════════════════════════════════
-- 5. PARAGRAPH  (title + wrapped body text)
-- ════════════════════════════════════════════════════════════
--[[
    Tab/Section:AddParagraph(title: string, content: string)
    Returns: ParagraphFunction
        :Set(content: string)  — update body text at runtime
]]

local MyParagraph = MainTab:AddParagraph(
    "About",
    "This script does awesome things. Drag the window by its top bar on any device."
)
MyParagraph:Set("Updated body text here.")

-- ════════════════════════════════════════════════════════════
-- 6. BUTTON
-- ════════════════════════════════════════════════════════════
--[[
    Tab/Section:AddButton({
        Name     = string,    -- Button label.  Default: "Button"
        Callback = function,  -- Fires on click.
        Icon     = string,    -- Asset ID for right-side icon. Default: built-in
    })
    Returns: ButtonObject
        :Set(text: string)   — change the button label at runtime
]]

local MyButton = MainTab:AddButton({
    Name     = "Teleport",
    Callback = function()
        print("Button pressed!")
    end,
    Icon = "rbxassetid://3944703587",
})

MyButton:Set("Teleport (updated)")

-- Can also add inside a section:
CombatSection:AddButton({
    Name     = "Kill Aura",
    Callback = function()
        print("Kill Aura activated")
    end,
})

-- ════════════════════════════════════════════════════════════
-- 7. TOGGLE
-- ════════════════════════════════════════════════════════════
--[[
    Tab/Section:AddToggle({
        Name     = string,    -- Label.                     Default: "Toggle"
        Default  = boolean,   -- Starting state.            Default: false
        Color    = Color3,    -- Checkbox accent color.     Default: blue
        Flag     = string,    -- Key in OrionPlus.Flags.    Default: nil
        Save     = boolean,   -- Include in saved config.   Default: false
        Callback = function(value: boolean),
    })
    Returns: ToggleObject
        .Value               — current boolean value
        :Set(value: boolean) — change state programmatically
]]

local SpeedToggle = MainTab:AddToggle({
    Name     = "Speed Hack",
    Default  = false,
    Color    = Color3.fromRGB(0, 170, 255),
    Flag     = "SpeedEnabled",
    Save     = true,
    Callback = function(value)
        print("Speed hack:", value)
    end,
})

SpeedToggle:Set(true)              -- turn on programmatically
print(SpeedToggle.Value)           -- read current value
print(OrionPlus.Flags["SpeedEnabled"].Value)  -- access via Flag key

-- ════════════════════════════════════════════════════════════
-- 8. SLIDER
-- ════════════════════════════════════════════════════════════
--[[
    Tab/Section:AddSlider({
        Name      = string,    -- Label.                    Default: "Slider"
        Min       = number,    -- Minimum value.            Default: 0
        Max       = number,    -- Maximum value.            Default: 100
        Increment = number,    -- Step size.                Default: 1
        Default   = number,    -- Starting value.           Default: 50
        ValueName = string,    -- Unit label (e.g. "ms").   Default: ""
        Color     = Color3,    -- Fill color.               Default: green
        Flag      = string,    -- Key in OrionPlus.Flags.   Default: nil
        Save      = boolean,   -- Include in saved config.  Default: false
        Callback  = function(value: number),
    })
    Returns: SliderObject
        .Value            — current number value
        :Set(value: number)
    
    MOBILE: Drag with finger — fully supported.
]]

local SpeedSlider = MainTab:AddSlider({
    Name      = "Walk Speed",
    Min       = 16,
    Max       = 300,
    Increment = 2,
    Default   = 16,
    ValueName = "studs/s",
    Color     = Color3.fromRGB(0, 200, 100),
    Flag      = "WalkSpeed",
    Save      = true,
    Callback  = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end,
})

SpeedSlider:Set(100)
print(SpeedSlider.Value)

-- ════════════════════════════════════════════════════════════
-- 9. DROPDOWN
-- ════════════════════════════════════════════════════════════
--[[
    Tab/Section:AddDropdown({
        Name     = string,          -- Label.                   Default: "Dropdown"
        Options  = {string, ...},   -- List of choices.         Default: {}
        Default  = string,          -- Pre-selected option.     Default: ""
        Flag     = string,          -- Key in OrionPlus.Flags.  Default: nil
        Save     = boolean,         -- Include in saved config. Default: false
        Callback = function(value: string),
    })
    Returns: DropdownObject
        .Value              — currently selected string
        :Set(value: string)
        :Refresh(options: {string}, delete: boolean)
            delete = true  clears existing buttons before adding new ones
]]

local TeamDropdown = MainTab:AddDropdown({
    Name     = "Select Team",
    Options  = {"Red", "Blue", "Green", "Yellow"},
    Default  = "Red",
    Flag     = "SelectedTeam",
    Save     = true,
    Callback = function(value)
        print("Team selected:", value)
    end,
})

TeamDropdown:Set("Blue")                          -- select programmatically
TeamDropdown:Refresh({"Alpha","Beta","Gamma"}, true)  -- replace all options
print(TeamDropdown.Value)

-- ════════════════════════════════════════════════════════════
-- 10. BIND  (keybind picker)
-- ════════════════════════════════════════════════════════════
--[[
    Tab/Section:AddBind({
        Name     = string,       -- Label.                   Default: "Bind"
        Default  = Enum.KeyCode, -- Starting key.            Default: Unknown
        Hold     = boolean,      -- Fire on hold/release too. Default: false
        Flag     = string,       -- Key in OrionPlus.Flags.  Default: nil
        Save     = boolean,      -- Include in saved config. Default: false
        Callback = function()    -- Called on keypress.
                                 -- If Hold=true: Callback(isHolding: boolean)
    })
    Returns: BindObject
        .Value          — current key name string
        :Set(key)       — set key (Enum.KeyCode or Enum.UserInputType)

    Usage:
      Click the bind box → it waits for your next input → saves that key.
      Blacklisted (cannot bind): W A S D arrows Tab Backspace Escape
      Allowed mouse buttons: Mouse1 Mouse2 Mouse3
]]

local FlyBind = SettingsTab:AddBind({
    Name     = "Fly Toggle",
    Default  = Enum.KeyCode.F,
    Hold     = false,
    Flag     = "FlyKey",
    Save     = true,
    Callback = function()
        print("Fly key pressed!")
    end,
})

local SprintBind = SettingsTab:AddBind({
    Name     = "Sprint (hold)",
    Default  = Enum.KeyCode.LeftShift,
    Hold     = true,           -- callback fires with true on press, false on release
    Callback = function(holding)
        print("Sprint:", holding)
    end,
})

FlyBind:Set(Enum.KeyCode.G)   -- change key programmatically
print(FlyBind.Value)          -- "G"

-- ════════════════════════════════════════════════════════════
-- 11. TEXTBOX
-- ════════════════════════════════════════════════════════════
--[[
    Tab/Section:AddTextbox({
        Name          = string,   -- Label.                      Default: "Textbox"
        Default       = string,   -- Pre-filled text.            Default: ""
        TextDisappear = boolean,  -- Clear text after unfocus.   Default: false
        Callback      = function(text: string),  -- fires on FocusLost
    })
    (No return object with extra methods.)
]]

SettingsTab:AddTextbox({
    Name          = "Player Name",
    Default       = "Player1",
    TextDisappear = false,
    Callback      = function(text)
        print("Entered:", text)
    end,
})

SettingsTab:AddTextbox({
    Name          = "Execute Command",
    Default       = "",
    TextDisappear = true,   -- clears after each submit
    Callback      = function(text)
        print("Command:", text)
    end,
})

-- ════════════════════════════════════════════════════════════
-- 12. COLORPICKER
-- ════════════════════════════════════════════════════════════
--[[
    Tab/Section:AddColorpicker({
        Name     = string,    -- Label.                   Default: "Colorpicker"
        Default  = Color3,    -- Starting color.          Default: white
        Flag     = string,    -- Key in OrionPlus.Flags.  Default: nil
        Save     = boolean,   -- Include in saved config. Default: false
        Callback = function(color: Color3),
    })
    Returns: ColorpickerObject
        .Value           — current Color3
        :Set(Color3)     — set color programmatically

    Click the color box to expand the picker.
    MOBILE: Drag the color/hue panels with your finger — fully supported.
]]

local TrailColor = SettingsTab:AddColorpicker({
    Name     = "Trail Color",
    Default  = Color3.fromRGB(255, 0, 128),
    Flag     = "TrailColor",
    Save     = true,
    Callback = function(color)
        print("Color:", color)
    end,
})

TrailColor:Set(Color3.fromRGB(0, 255, 100))
print(TrailColor.Value)

-- ════════════════════════════════════════════════════════════
-- 13. NOTIFICATION
-- ════════════════════════════════════════════════════════════
--[[
    OrionPlus:MakeNotification({
        Name    = string,    -- Bold title.                  Default: "Notification"
        Content = string,    -- Body text.                   Default: "Test"
        Image   = string,    -- Asset ID for left icon.      Default: built-in
        Time    = number,    -- Seconds before it fades.     Default: 15
    })
    Notifications appear in the bottom-right corner.
    They animate in and then auto-fade.
]]

OrionPlus:MakeNotification({
    Name    = "Script Loaded",
    Content = "OrionPlus loaded successfully. Drag the window to reposition.",
    Image   = "rbxassetid://4384403532",
    Time    = 6,
})

-- ════════════════════════════════════════════════════════════
-- 14. INIT (load saved config on startup)
-- ════════════════════════════════════════════════════════════
--[[
    OrionPlus:Init()
    Call AFTER all windows/tabs/elements are created and SaveConfig = true.
    It reads the saved .txt file for the current game ID and restores flags.
]]

OrionPlus:Init()

-- ════════════════════════════════════════════════════════════
-- 15. DESTROY
-- ════════════════════════════════════════════════════════════
--[[
    OrionPlus:Destroy()
    Removes the entire ScreenGui and disconnects all connections.
]]

-- OrionPlus:Destroy()   -- uncomment to tear down the UI

-- ════════════════════════════════════════════════════════════
-- 16. FLAGS  (global state table)
-- ════════════════════════════════════════════════════════════
--[[
    Any element created with a Flag = "key" is accessible at:
        OrionPlus.Flags["key"]        — the element object
        OrionPlus.Flags["key"].Value  — the current value
        OrionPlus.Flags["key"]:Set(v) — programmatic setter

    Example:
]]

-- Later in your code, after the UI is built:
task.wait(2)
print("Current speed:", OrionPlus.Flags["WalkSpeed"].Value)
print("Speed enabled:", OrionPlus.Flags["SpeedEnabled"].Value)
print("Team:", OrionPlus.Flags["SelectedTeam"].Value)
OrionPlus.Flags["WalkSpeed"]:Set(200)
