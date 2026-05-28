return function(Tabs, Library)

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
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    -- =========================
-- Player
-- =========================
do
    local Player = Tabs.Player:AddLeftGroupbox("Local Player", "user")

    local FlySettings = {
        Enabled = false,
        Method = "Ragdoll"
    }

    local flySpeed = 60

    local Connections = {
        Fly = nil,
        Ragdoll = nil
    }

    local hrp

    local EventsFolder = ReplicatedStorage:FindFirstChild("Events")

    local flyEv = EventsFolder and EventsFolder:FindFirstChild("RZDONL")
    local ragEv = EventsFolder and EventsFolder:FindFirstChild("__RZDONL")

    local function disconnectConnection(name)
        if Connections[name] then
            Connections[name]:Disconnect()
            Connections[name] = nil
        end
    end

    local function stopFly()
        disconnectConnection("Fly")
        disconnectConnection("Ragdoll")

        if hrp then
            hrp.Velocity = Vector3.zero
        end
    end

    local function getMoveDirection()
        local move = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then
            move += Camera.CFrame.LookVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.S) then
            move -= Camera.CFrame.LookVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.A) then
            move -= Camera.CFrame.RightVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.D) then
            move += Camera.CFrame.RightVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            move += Vector3.new(0,1,0)
        end

        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            move -= Vector3.new(0,1,0)
        end

        return move.Magnitude > 0 and move.Unit or Vector3.zero
    end

    local function enableRagdollFly()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

        hrp = char:FindFirstChild("HumanoidRootPart")

        if not hrp then
            return
        end

        disconnectConnection("Ragdoll")

        Connections.Ragdoll = RunService.RenderStepped:Connect(function()
            if not FlySettings.Enabled or FlySettings.Method ~= "Ragdoll" then
                stopFly()
                return
            end

            if ragEv then
                ragEv:FireServer("__---r", Vector3.zero, hrp.CFrame, false)
            end
        end)

        disconnectConnection("Fly")

        Connections.Fly = RunService.RenderStepped:Connect(function()
            if not FlySettings.Enabled or FlySettings.Method ~= "Ragdoll" then
                stopFly()
                return
            end

            if not hrp or not hrp.Parent then
                return
            end

            local moveDir = getMoveDirection()

            hrp.Velocity = moveDir * flySpeed

            if flyEv then
                flyEv:FireServer("---r", Vector3.zero, hrp.CFrame, false)
            end
        end)
    end

    local function enableOldFly()
        stopFly()

        Connections.Fly = RunService.RenderStepped:Connect(function(dt)
            if not FlySettings.Enabled or FlySettings.Method ~= "Old" then
                stopFly()
                return
            end

            local char = LocalPlayer.Character

            if not char then
                return
            end

            local root = char:FindFirstChild("HumanoidRootPart")

            if not root then
                return
            end

            local moveDir = getMoveDirection()

            root.CFrame += moveDir * flySpeed * dt
        end)
    end

    local function applyFly()
        stopFly()

        if not FlySettings.Enabled then
            return
        end

        if FlySettings.Method == "Ragdoll" then
            enableRagdollFly()
        else
            enableOldFly()
        end
    end

    LocalPlayer.CharacterAdded:Connect(function()
        if FlySettings.Enabled then
            task.wait(1)
            applyFly()
        end
    end)

    Player:AddToggle("FlyToggle", {
        Text = "Enable Fly",
        Default = false,
    })

    Toggles.FlyToggle:OnChanged(function(state)
        FlySettings.Enabled = state
        applyFly()
    end)

    Toggles.FlyToggle:AddKeyPicker("FlyKeybind", {
        Default = "None",
        Text = "Fly Keybind",
        Mode = "Toggle",
        SyncToggleState = true,
    })

    Player:AddDropdown("FlyMethod", {
        Text = "Fly Method",
        Values = { "Ragdoll", "Old" },
        Default = 1,
    })

    Options.FlyMethod:OnChanged(function()
        FlySettings.Method = Options.FlyMethod.Value

        if FlySettings.Enabled then
            applyFly()
        end
    end)

    Player:AddSlider("FlySpeed", {
        Text = "Fly Speed",
        Default = 60,
        Min = 10,
        Max = 200,
        Rounding = 0,
        Suffix = " Speed",
    })

    Options.FlySpeed:OnChanged(function()
        flySpeed = Options.FlySpeed.Value
    end)



    local staminaConnection
    local staminaEnabled = false

    local function enableStamina()
        if staminaEnabled then
            return
        end

        staminaEnabled = true

        staminaConnection = RunService.RenderStepped:Connect(function()
            if not staminaEnabled then
                return
            end

            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildWhichIsA("Humanoid")

            if hum then
                hum:SetAttribute("ZSPRN_M", true)
            end
        end)
    end

    local function disableStamina()
        staminaEnabled = false

        if staminaConnection then
            staminaConnection:Disconnect()
            staminaConnection = nil
        end

        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")

        if hum then
            hum:SetAttribute("ZSPRN_M", nil)
        end
    end

    Player:AddToggle("InfStaminaToggle", {
        Text = "Infinite Stamina",
        Default = false,
    })

    Toggles.InfStaminaToggle:OnChanged(function(state)
        if state then
            enableStamina()
        else
            disableStamina()
        end
    end)


local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid
local HumanoidRootPart

local function UpdateCharacterReferences()
    Character = LocalPlayer.Character
    if Character then
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        Humanoid = Character:FindFirstChildOfClass("Humanoid")
    end
end

UpdateCharacterReferences()

local InvisEnabled = false
local Track = nil

local Animation = Instance.new("Animation")
Animation.AnimationId = "rbxassetid://215384594"

local GUI = Instance.new("ScreenGui")
GUI.Name = "InvisWarningGUI"
GUI.Parent = game:GetService("CoreGui")
GUI.ResetOnSpawn = false

local WarnLabel = Instance.new("TextLabel")
WarnLabel.Parent = GUI
WarnLabel.Text = "⚠️ You are visible ⚠️"
WarnLabel.Visible = false
WarnLabel.Size = UDim2.new(0, 200, 0, 30)
WarnLabel.Position = UDim2.new(0.5, -100, 0.85, 0)
WarnLabel.BackgroundTransparency = 1
WarnLabel.Font = Enum.Font.GothamSemibold
WarnLabel.TextSize = 24
WarnLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
WarnLabel.TextStrokeTransparency = 0
WarnLabel.TextStrokeColor3 = Color3.fromRGB(80, 80, 80)

local function Grounded()
    return Humanoid
        and Humanoid:IsDescendantOf(workspace)
        and Humanoid.FloorMaterial ~= Enum.Material.Air
end

local function ResetTransparency()
    if not Character then return end
    for _, obj in ipairs(Character:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.LocalTransparencyModifier = 0 -- Macht alles wieder 100% sichtbar
        end
    end
end

local function LoadAndPrepareTrack()
    if Track then
        pcall(function() Track:Stop() end)
        Track = nil
    end
    if Humanoid then
        local success, result = pcall(function()
            return Humanoid:LoadAnimation(Animation)
        end)
        if success then
            Track = result
            Track.Priority = Enum.AnimationPriority.Action4
        end
    end
end

local function Invis_Disable()
    InvisEnabled = false
    if Track then
        pcall(function() Track:Stop() end)
    end
    WarnLabel.Visible = false
    if Humanoid then
        workspace.CurrentCamera.CameraSubject = Humanoid
    end
    task.wait(0.1)
    ResetTransparency() -- Wichtig: Hier wird die Transparenz beim Ausschalten entfernt
end

local function Invis_Enable()
    UpdateCharacterReferences()
    if not Character or not Humanoid or not HumanoidRootPart then return end
    InvisEnabled = true
    workspace.CurrentCamera.CameraSubject = HumanoidRootPart
    LoadAndPrepareTrack()
end

-- Events
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    task.wait(1)
    UpdateCharacterReferences()
    ResetTransparency()
    if InvisEnabled then Invis_Enable() end
end)

-- Main Loop
game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
    if not InvisEnabled then
        return
    end

    if not Character or not Humanoid or not HumanoidRootPart or Humanoid.Health <= 0 then
        return
    end

    WarnLabel.Visible = not Grounded()
    local speed = 12
    local Camera = workspace.CurrentCamera

    if Humanoid.MoveDirection.Magnitude > 0 then
        local offset = Humanoid.MoveDirection * speed * deltaTime
        HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + offset
    end

    local OldCFrame = HumanoidRootPart.CFrame
    local OldCameraOffset = Humanoid.CameraOffset
    local _, y = Camera.CFrame:ToOrientation()

    HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position) 
        * CFrame.fromOrientation(0, y, 0) 
        * CFrame.Angles(math.rad(90), 0, 0)

    Humanoid.CameraOffset = Vector3.new(0, 1.44, 0)

    if Track then
        pcall(function()
            if not Track.IsPlaying then Track:Play() end
            Track:AdjustSpeed(0)
            Track.TimePosition = 0.3
        end)
    end

    game:GetService("RunService").RenderStepped:Wait()

    if Humanoid then Humanoid.CameraOffset = OldCameraOffset end
    if HumanoidRootPart then HumanoidRootPart.CFrame = OldCFrame end
    if Track then pcall(function() Track:Stop() end) end

    -- TRANSPARENZ LOGIK (Nur wenn Toggle AN ist)
    if Character and InvisEnabled then
        for _, v in ipairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then
                if v.Name == "HumanoidRootPart" then
                    v.LocalTransparencyModifier = 1
                else
                    v.LocalTransparencyModifier = 0.5 -- Hier kannst du den Wert ändern (0.5 = halb durchsichtig)
                end
            end
        end
    end
end)

local MyToggle = Player:AddToggle("Invisibility", {
    Text = "Invisibility",
    Default = false
})


local Keybind = MyToggle:AddKeyPicker("Invisibility", {
    Default = "None",
    Text = "Invisibility",
    Mode = "Toggle",
    SyncToggleState = true,
})

Toggles.Invisibility:OnChanged(function(v)
    if v then
        Invis_Enable()
    else
        Invis_Disable()
    end
end)


local NoclipToggle = Player:AddToggle("NoclipToggle", {
    Text = "Noclip",
    Default = false,
})

local Keybind = NoclipToggle:AddKeyPicker("NoclipToggle", {
    Default = "None",
    Text = "NoClip",
    Mode = "Toggle",
    SyncToggleState = true,
})

RunService.Stepped:Connect(function()
    if Toggles.NoclipToggle.Value and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)
Toggles.NoclipToggle:OnChanged(function(state)
end)
end
end