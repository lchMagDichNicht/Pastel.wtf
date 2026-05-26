loadstring(game:HttpGet("https://raw.githubusercontent.com/lchMagDichNicht/Pastel.wtf/refs/heads/main/Theme.lua"))()
wait(0.25)
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/placeholder14331/dependencies/refs/heads/main/ThemeManager"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()


-- =========================
-- Service
-- =========================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local cam = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local Camera = workspace.CurrentCamera
local Options = Library.Options
local Toggles = Library.Toggles
local player = Players.LocalPlayer
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Gui = Player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")


-- ================================
-- UI Window
-- ================================
local Window = Library:CreateWindow({
    Title = 'Pastel.wtf',
    Icon = 118706235232208,
    ShowCustomCursor = false,
    DisableSearch = true,
    Size = UDim2.fromOffset(650, 500),
    IconSize = UDim2.fromOffset(40, 40),
    Footer = '♡ made With Love',
    NotifySide = "Right",
    Resizable = false,
    ToggleKeybind = Enum.KeyCode.RightControl,
})

-- ================================
-- Tabs
-- ================================
local Tabs = {
	Home = Window:AddTab("Home", "house"),

    Combat = Window:AddTab("Combat", "swords"),
    Melee = Window:AddTab("Melee", "axe"),
    Gun = Window:AddTab("Gun", "crosshair"),

    Aimbot = Window:AddTab("Aimbot", "target"),
    Visuals = Window:AddTab("Visuals", "eye"),

    Player = Window:AddTab("Player", "user"),
    Movement = Window:AddTab("Movement", "zap"),

    World = Window:AddTab("World", "earth"),
    Utility = Window:AddTab("Utility", "sparkles"),

    Misc = Window:AddTab("Misc", "star"),

    Settings = Window:AddTab("Settings", "settings"),
}

-- ================================
-- Settings
-- ================================
local SettingsGroupLeft = Tabs.Settings:AddLeftGroupbox('UI', 'app-window')

SettingsGroupLeft:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})

local MyToggle = SettingsGroupLeft:AddToggle("MyToggle", {
    Text = "Custom Cursor",
    Default = false,
})

Toggles.MyToggle:OnChanged(function(state)
    Library.ShowCustomCursor = state
end)

SettingsGroupLeft:AddDivider()

-- Dpi Dropdown

SettingsGroupLeft:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",

	Text = "DPI Scale",

	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)

		Library:SetDPIScale(DPI)
	end,
})

-- Unload
SettingsGroupLeft:AddDivider()

SettingsGroupLeft:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "RightControl", NoUI = true, Text = "Menu keybind" })


SettingsGroupLeft:AddButton('Unload', function()
    Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind 

-- ================================
-- SaveManager & ThemeManager
-- ================================
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"MenuKeybind"})
ThemeManager:SetFolder("Pastel.wtf")
SaveManager:SetFolder("Pastel.wtf/Example")
SaveManager:SetSubFolder("")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:LoadAutoloadConfig("")

-- =========================
-- Loading Screen
-- =========================
local cancelled = false
local currentStep = 0

local cuteQuotes = {
    "✨ Making everything look adorable...",
    "🌸 Summoning pastel modules...",
    "💖 Preparing your comfy experience...",
    "🧸 Loading cute systems...",
    "🌈 Applying soft colors...",
    "💫 Pastel energy activated...",
    "🎀 Making the UI prettier...",
    "☁️ Almost ready cutie...",
    "✨ Syncing magical stuff...",
    "🌸 Preparing something special..."
}

local randomQuote = cuteQuotes[math.random(1, #cuteQuotes)]

local Loading = Library:CreateLoading({
    Title = "Pastel.wtf",
    Icon = 118706235232208,
    TotalSteps = 100,
    AutoResizeHeight = true
})

Loading:ShowSidebarPage(true)

Loading.Sidebar:AddLabel("💖 User: " .. player.Name)
Loading.Sidebar:AddLabel("✨ Display: " .. player.DisplayName)
Loading.Sidebar:AddLabel("🧸 Account Age: " .. player.AccountAge .. " days")
Loading.Sidebar:AddLabel(randomQuote)

local function smoothTo(target, speed)
    while currentStep < target do
        if cancelled then
            return
        end

        currentStep += 1

        Loading:SetCurrentStep(currentStep)

        task.wait(speed or 0.01)
    end
end

local function setFancyMessage(title, desc)
    if cancelled then
        return
    end

    Loading:SetMessage(title)
    Loading:SetDescription(desc)
end

local function findPaths(timeout)
    local start = tick()

    local found = {
        piles = nil,
        safes = nil
    }

    while tick() - start < timeout do
        if cancelled then
            return nil
        end

        local filter = workspace:FindFirstChild("Filter")

        if filter then
            found.piles = filter:FindFirstChild("SpawnedPiles")
        end

        local map = workspace:FindFirstChild("Map")

        if map then
            found.safes = map:FindFirstChild("BredMakurz")
        end

        if found.piles and found.safes then
            return found
        end

        task.wait(0.1)
    end

    return found
end

local function startLoading()
    if cancelled then
        return
    end

    setFancyMessage(
        "💖 Welcome back",
        "Initializing Pastel.wtf for " .. player.DisplayName .. "..."
    )

    smoothTo(10, 0.02)

    setFancyMessage(
        "✨ Loading interface",
        "Applying cute pastel themes..."
    )

    smoothTo(25, 0.015)

    setFancyMessage(
        "🌸 Preparing modules",
        "Making everything comfy and smooth..."
    )

    smoothTo(45, 0.012)

    setFancyMessage(
        "🧸 Loading assets",
        "Summoning pretty visuals..."
    )

    smoothTo(60, 0.01)

    setFancyMessage(
        "🔍 Checking systems",
        "Looking for required game paths..."
    )

    smoothTo(72, 0.015)

    local result = findPaths(3)

    if cancelled then
        return
    end

    local pilesOK = result and result.piles
    local safesOK = result and result.safes

    if (not pilesOK or not safesOK) then
        Loading:ShowErrorPage(true)

        local missing = ""

        if not pilesOK then
            missing = missing .. "• Filter.SpawnedPiles\n"
        end

        if not safesOK then
            missing = missing .. "• Map.BredMakurz\n"
        end

        Loading:SetErrorMessage(
            "💔 Some cute systems failed to load.\n\n" ..
            "Missing:\n" ..
            missing ..
            "\nThe script may not fully work."
        )

        local originalButtons

        local IgnoreButton = {
            Title = "Ignore",
            Variant = "Secondary",

            Callback = function()
                if cancelled then
                    return
                end

                Loading:SetErrorMessage(
                    "⚠️ Continuing may cause issues.\n\n" ..
                    "Some features could break or fail.\n\n" ..
                    "Do you still want to continue?"
                )

                Loading:SetErrorButtons({
                    Continue = {
                        Title = "Continue",
                        Variant = "Primary",

                        Callback = function()
                            if cancelled then
                                return
                            end

                            _G.HasPiles = pilesOK ~= nil
                            _G.HasSafes = safesOK ~= nil
                            _G.IgnoreMissingPath = true

                            Loading:ShowErrorPage(false)

                            setFancyMessage(
                                "✨ Bypassing checks",
                                "Trying to continue safely..."
                            )

                            smoothTo(100, 0.008)

                            Loading:Continue()
                        end
                    },

                    Back = {
                        Title = "Back",
                        Variant = "Secondary",

                        Callback = function()
                            if cancelled then
                                return
                            end

                            Loading:SetErrorMessage(
                                "💔 Some cute systems failed to load.\n\n" ..
                                "Missing:\n" ..
                                missing
                            )

                            Loading:SetErrorButtons(originalButtons)
                        end
                    },

                    Close = {
                        Title = "Close",
                        Variant = "Destructive",

                        Callback = function()
                            cancelled = true

                            Loading:Destroy()

                            pcall(function()
                                Library:Unload()
                            end)
                        end
                    }
                })
            end
        }

        originalButtons = {
            Retry = {
                Title = "Retry",
                Variant = "Primary",

                Callback = function()
                    if cancelled then
                        return
                    end

                    Loading:ShowErrorPage(false)

                    currentStep = 0

                    startLoading()
                end
            },

            Ignore = IgnoreButton,

            Close = {
                Title = "Close",
                Variant = "Destructive",

                Callback = function()
                    cancelled = true

                    Loading:Destroy()

                    pcall(function()
                        Library:Unload()
                    end)
                end
            }
        }

        Loading:SetErrorButtons(originalButtons)

        return
    end

    _G.HasPiles = true
    _G.HasSafes = true

    setFancyMessage(
        "🌈 Finalizing",
        "Applying final touches..."
    )

    smoothTo(88, 0.01)

    setFancyMessage(
        "🚀 Launching",
        "Your cute experience is ready >.<"
    )

    smoothTo(100, 0.008)

    task.wait(0.5)

    if not cancelled then
        Loading:Continue()
    end
end

startLoading()


local AlreadyAccepted = false

pcall(function()
    AlreadyAccepted = readfile("IchMagDichNicht_Accepted.txt") == "true"
end)

if not AlreadyAccepted then
    local ReadEverything = false

    local Dialog
    Dialog = Window:AddDialog("CreditsDialog", {
        Title = "💖 Welcome cutie~",

        Description = table.concat({
            "",
            "This script belongs to 'IchMagDichNicht'.",
            "",
            "Some people keep stealing and reposting",
            "the script without credits >:(",
            "",
            "✨ The official version will ALWAYS stay",
            "FREE & KEYLESS.",
            "",
            "If someone asks for a key, payment,",
            "or linkvertise, it's fake."
        }, "\n"),

        AutoDismiss = false,
        OutsideClickDismiss = false,

        FooterButtons = {
            Continue = {
                Title = "Continue",
                Variant = "Primary",
                Order = 1,

                Callback = function()
                    if not ReadEverything then
                        return
                    end

                    writefile("IchMagDichNicht_Accepted.txt", "true")

                    Dialog:Dismiss()
                end
            }
        }
    })

    Dialog:AddToggle("ReadToggle", {
        Text = "I have read everything",
        Default = false,

        Callback = function(Value)
            ReadEverything = Value

            Dialog:SetButtonDisabled("Continue", not Value)
        end
    })

    Dialog:SetButtonDisabled("Continue", true)
end


-- ================================
-- Home
-- ================================
do
	local request = (syn and syn.request)
        or (http and http.request)
        or http_request
        or request

local Account = Tabs.Home:AddLeftGroupbox("Account", "info")
local Discord = Tabs.Home:AddRightGroupbox("Discord", "message-circle")


local inviteCode = "RhSPM3P2XQ"

    Discord:AddButton({
        Text = "Join Discord",
        Func = function()
            setclipboard("https://discord.gg/" .. inviteCode)

            if request then
                request({
                    Url = "http://127.0.0.1:6463/rpc?v=1",
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["Origin"] = "https://discord.com"
                    },
                    Body = HttpService:JSONEncode({
                        cmd = "INVITE_BROWSER",
                        nonce = HttpService:GenerateGUID(false),
                        args = {
                            code = inviteCode
                        }
                    })
                })

                Library:Notify({
                    Title = "Discord",
                    Description = "Opened Discord invite :3",
                    Time = 5
                })
            else
                Library:Notify({
                    Title = "Discord",
                    Description = "Invite copied to clipboard",
                    Time = 5
                })
            end
        end,
        DoubleClick = false
    })
end