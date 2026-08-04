OrionPlus = loadstring(game:HttpGet("https://raw.githubusercontent.com/Itzzavi335/OrionPlus/refs/heads/main/source.luau"))()

-- ════════════════════════════════════════════════════════════
-- 1. MAKE WINDOW  (with global key system)
-- ════════════════════════════════════════════════════════════
--[[
    OrionPlus:MakeWindow({
        -- Standard options
        Name          = string,
        IntroEnabled  = boolean,
        IntroText     = string,
        IntroIcon     = string,
        Icon          = string,
        ShowIcon      = boolean,
        HidePremium   = boolean,
        SaveConfig    = boolean,
        ConfigFolder  = string,
        CloseCallback = function,

        -- ── Key system ────────────────────────────────────────
        Keys           = {string, ...},  -- list of valid keys; ANY one grants access
                                         -- nil / omit = no key gate
        KeyTitle       = string,         -- modal heading.       Default: "Authentication Required"
        KeyDescription = string,         -- modal body text.     Default: auto ("X key(s) accepted")
        KeyNote        = string,         -- tiny grey footer.    Default: nil
    })

    HOW IT WORKS:
      • When Keys is provided, a full-screen themed modal appears BEFORE
        the main window is built.  The script blocks until the user types
        a matching key and presses "Confirm Key" (or Enter).
      • Wrong key  → red shake animation + error message.
      • Correct key → green flash, modal fades out, window builds normally.
      • OrionPlus.EnteredKey holds whichever key the user typed.
      • OrionPlus.Authenticated = true once the gate is passed.
      • Multiple keys = multiple users can each have their own unique key.
]]

-- Example A: no key gate
local Window = OrionPlus:MakeWindow({
    Name          = "My Script",
    HidePremium   = false,
    IntroEnabled  = true,
    IntroText     = "My Script",
    IntroIcon     = "rbxassetid://...",
    ShowIcon      = true,
    Icon          = "rbxassetid://...",
    SaveConfig    = true,
    ConfigFolder  = "MyScriptConfigs",
    CloseCallback = function()
        print("UI closed")
    end,
    Keys           = {
        "USER-KEY-ALPHA-001",
        "USER-KEY-BETA-002",
        "ADMIN-OVERRIDE-9999",
    },
    KeyTitle       = "Authentication",
    KeyDescription = "Enter your key below.",
    KeyNote        = "Keys at discord.gg/xyz",
})

-- After this line, the main UI builds.  Use OrionPlus.EnteredKey to tell
-- which key the user entered (e.g. to grant different tier access).
print("User key:", OrionPlus.EnteredKey)

-- ════════════════════════════════════════════════════════════
-- 2. MAKE TAB  (with optional per-tab key requirement)
-- ════════════════════════════════════════════════════════════
--[[
    Window:MakeTab({
        Name        = string,
        Icon        = string,
        PremiumOnly = boolean,   -- hardcoded lock (no key entry)

        -- ── Per-tab key system ────────────────────────────────
        Keys = {string, ...},    -- table of keys that unlock THIS tab
                                 -- nil / omit = tab is always accessible
    })

    HOW IT WORKS:
      • If OrionPlus.EnteredKey (from the global gate) is already in the
        tab's Keys list, the tab unlocks immediately — no extra prompt.
      • If the entered global key is NOT in the tab's list, the tab shows
        🔒 in the sidebar and an inline key-entry overlay instead of
        its content.  The user types the correct key inside the tab area
        and it unlocks for the rest of the session.
      • This lets you have:
          – A free tier: tabs with no Keys.
          – A paid tier: tabs whose Keys list only contains premium keys.
          – Admin-only tabs: tabs whose Keys list is just one secret key.
      • PremiumOnly = true is the old hardcoded lock (no key entry at all).
        Keys-based locking is the new flexible version.
]]

-- Normal tab (always accessible)
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345875",
})

-- Tab locked to a specific subset of keys
-- Users who entered "USER-KEY-ALPHA-001" or "ADMIN-OVERRIDE-9999"
-- at the global gate get in automatically.  Anyone else sees the
-- inline key prompt when they click the tab.
local PremiumTab = Window:MakeTab({
    Name = "Premium",
    Icon = "rbxassetid://3610239960",
    Keys = { "USER-KEY-ALPHA-001", "ADMIN-OVERRIDE-9999" },
})

-- Admin-only tab — only the admin override key works
local AdminTab = Window:MakeTab({
    Name = "Admin",
    Icon = "rbxassetid://3944703587",
    Keys = { "ADMIN-OVERRIDE-9999" },
})

-- Hardcoded locked (PremiumOnly — old style, no key entry prompt)
local HardLockTab = Window:MakeTab({
    Name        = "Locked",
    PremiumOnly = true,
})

-- ════════════════════════════════════════════════════════════
-- 3. SECTION
-- ════════════════════════════════════════════════════════════
local CombatSection = MainTab:AddSection({ Name = "Combat" })

-- ════════════════════════════════════════════════════════════
-- 4. LABEL
-- ════════════════════════════════════════════════════════════
local MyLabel = MainTab:AddLabel("This is a label")
MyLabel:Set("Label updated!")

-- ════════════════════════════════════════════════════════════
-- 5. PARAGRAPH
-- ════════════════════════════════════════════════════════════
local MyParagraph = MainTab:AddParagraph("About", "OrionPlus loaded successfully.")
MyParagraph:Set("Updated body text.")

-- ════════════════════════════════════════════════════════════
-- 6. BUTTON
-- ════════════════════════════════════════════════════════════
--[[
    Tab/Section:AddButton({
        Name     = string,
        Callback = function,
        Icon     = string,   -- asset ID, right side
    })
    Returns: ButtonObject
        :Set(text)
]]
local MyButton = MainTab:AddButton({
    Name     = "Teleport",
    Callback = function()  print("Button pressed!")  end,
    Icon     = "rbxassetid://3944703587",
})
MyButton:Set("Teleport (updated)")

CombatSection:AddButton({
    Name     = "Kill Aura",
    Callback = function()  print("Kill Aura activated")  end,
})

-- ════════════════════════════════════════════════════════════
-- 7. TOGGLE
-- ════════════════════════════════════════════════════════════
--[[
    Tab/Section:AddToggle({
        Name     = string,
        Default  = boolean,     -- Default: false
        Color    = Color3,      -- Checkbox accent.  Default: blue
        Flag     = string,
        Save     = boolean,
        Callback = function(value: boolean),
    })
    Returns: ToggleObject   .Value   :Set(bool)
]]
local SpeedToggle = MainTab:AddToggle({
    Name     = "Speed Hack",
    Default  = false,
    Color    = Color3.fromRGB(0, 170, 255),
    Flag     = "SpeedEnabled",
    Save     = true,
    Callback = function(v)  print("Speed:", v)  end,
})
SpeedToggle:Set(true)
print(SpeedToggle.Value)

-- ════════════════════════════════════════════════════════════
-- 8. SLIDER  (mobile touch supported)
-- ════════════════════════════════════════════════════════════
--[[
    Tab/Section:AddSlider({
        Name      = string,
        Min       = number,     -- Default: 0
        Max       = number,     -- Default: 100
        Increment = number,     -- Default: 1
        Default   = number,     -- Default: 50
        ValueName = string,     -- Unit label (e.g. "ms")
        Color     = Color3,
        Flag      = string,
        Save      = boolean,
        Callback  = function(value: number),
    })
    Returns: SliderObject   .Value   :Set(number)
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
    Callback  = function(v)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    end,
})
SpeedSlider:Set(100)

-- ════════════════════════════════════════════════════════════
-- 9. DROPDOWN
-- ════════════════════════════════════════════════════════════
--[[
    Tab/Section:AddDropdown({
        Name     = string,
        Options  = {string, ...},
        Default  = string,
        Flag     = string,
        Save     = boolean,
        Callback = function(value: string),
    })
    Returns: DropdownObject
        .Value
        :Set(string)
        :Refresh(options, deleteOld: boolean)
]]
local TeamDrop = MainTab:AddDropdown({
    Name     = "Select Team",
    Options  = {"Red", "Blue", "Green"},
    Default  = "Red",
    Flag     = "Team",
    Save     = true,
    Callback = function(v)  print("Team:", v)  end,
})
TeamDrop:Set("Blue")
TeamDrop:Refresh({"Alpha","Beta","Gamma"}, true)

-- ════════════════════════════════════════════════════════════
-- 10. BIND
-- ════════════════════════════════════════════════════════════
--[[
    Tab/Section:AddBind({
        Name     = string,
        Default  = Enum.KeyCode,
        Hold     = boolean,     -- fires Callback(true/false) on press/release
        Flag     = string,
        Save     = boolean,
        Callback = function() / function(holding: boolean),
    })
    Returns: BindObject   .Value (key name string)   :Set(key)
    Click bind box → waits for next input → stores it.
    Blacklisted: WASD, arrows, Tab, Backspace, Escape.
    Mouse buttons 1–3 are allowed.
]]
local FlyBind = PremiumTab:AddBind({
    Name     = "Fly Toggle",
    Default  = Enum.KeyCode.F,
    Hold     = false,
    Flag     = "FlyKey",
    Save     = true,
    Callback = function()  print("Fly!")  end,
})
FlyBind:Set(Enum.KeyCode.G)

-- ════════════════════════════════════════════════════════════
-- 11. TEXTBOX
-- ════════════════════════════════════════════════════════════
--[[
    Tab/Section:AddTextbox({
        Name          = string,
        Default       = string,
        TextDisappear = boolean,   -- clear after FocusLost
        Callback      = function(text: string),
    })
]]
PremiumTab:AddTextbox({
    Name          = "Player Name",
    Default       = "",
    TextDisappear = false,
    Callback      = function(t)  print("Entered:", t)  end,
})

-- ════════════════════════════════════════════════════════════
-- 12. COLORPICKER  (mobile touch supported)
-- ════════════════════════════════════════════════════════════
--[[
    Tab/Section:AddColorpicker({
        Name     = string,
        Default  = Color3,
        Flag     = string,
        Save     = boolean,
        Callback = function(color: Color3),
    })
    Returns: ColorpickerObject   .Value   :Set(Color3)
    Click color box to expand.  Drag panels with mouse OR finger.
]]
local TrailColor = PremiumTab:AddColorpicker({
    Name     = "Trail Color",
    Default  = Color3.fromRGB(255, 0, 128),
    Flag     = "TrailColor",
    Save     = true,
    Callback = function(c)  print("Color:", c)  end,
})
TrailColor:Set(Color3.fromRGB(0, 255, 100))

-- ════════════════════════════════════════════════════════════
-- 13. NOTIFICATION
-- ════════════════════════════════════════════════════════════
--[[
    OrionPlus:MakeNotification({
        Name    = string,   -- bold title
        Content = string,   -- body
        Image   = string,   -- asset ID
        Time    = number,   -- seconds before fade
    })
]]
OrionPlus:MakeNotification({
    Name    = "Script Loaded",
    Content = "OrionPlus ready.",
    Time    = 5,
})

-- ════════════════════════════════════════════════════════════
-- 14. INIT  (load saved config)
-- ════════════════════════════════════════════════════════════
-- Call AFTER all elements are created when SaveConfig = true.
OrionPlus:Init()

-- ════════════════════════════════════════════════════════════
-- 15. DESTROY
-- ════════════════════════════════════════════════════════════
-- OrionPlus:Destroy()

-- ════════════════════════════════════════════════════════════
-- 16. KEY SYSTEM — QUICK REFERENCE
-- ════════════════════════════════════════════════════════════
--[[
    ┌─────────────────────────────────────────────────────────┐
    │  GLOBAL key gate  (MakeWindow)                          │
    │  Keys = { "k1", "k2", ... }                             │
    │  → ANY one key in the list unlocks the whole UI.        │
    │  → Modal blocks until a valid key is typed.             │
    │  → OrionPlus.EnteredKey  = the key the user typed.      │
    │  → OrionPlus.Authenticated = true after passing.        │
    ├─────────────────────────────────────────────────────────┤
    │  PER-TAB key gate  (MakeTab)                            │
    │  Keys = { "k1", "k2", ... }                             │
    │  → Tab shows 🔒 in sidebar until a valid key is entered.│
    │  → If OrionPlus.EnteredKey is already in the list,      │
    │    the tab unlocks automatically (no extra prompt).     │
    │  → Wrong key → red shake + error inside the tab area.   │
    │  → Correct key → overlay fades, real content appears.   │
    ├─────────────────────────────────────────────────────────┤
    │  Tier example:                                          │
    │    Global Keys = { freeKey, premiumKey, adminKey }      │
    │    MainTab   → no Keys (everyone sees it)               │
    │    VIPTab    → Keys = { premiumKey, adminKey }          │
    │    AdminTab  → Keys = { adminKey }                      │
    │  A free user passes the gate with freeKey but sees      │
    │  🔒 on VIPTab and AdminTab.  A premium user auto-        │
    │  unlocks VIPTab.  Admin auto-unlocks both.              │
    └─────────────────────────────────────────────────────────┘

    FLAGS access (works the same as before):
        OrionPlus.Flags["FlagName"].Value
        OrionPlus.Flags["FlagName"]:Set(v)
]]

-- After UI is built, you can inspect EnteredKey to branch logic:
if OrionPlus.EnteredKey == "ADMIN-OVERRIDE-9999" then
    print("Admin user detected — granting extra access")
elseif OrionPlus.EnteredKey then
    print("Standard user:", OrionPlus.EnteredKey)
end
