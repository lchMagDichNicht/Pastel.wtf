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

    -- ================================
-- Melee
-- ================================
do
    local Melee = Tabs.Melee:AddLeftGroupbox("Melee", "sword")
    local Targets = Tabs.Melee:AddRightGroupbox("Targets", "users")
    
    -- =========================
    -- Settings
    -- =========================
    local MeleeAura_Enabled = false
    local AuraRange = 5
    
    local SwingAnimation = false
    local ShowTarget = false
    local HitEffect = false
    
    local LastSwing = 0
    local SwingCooldown = 0.35
    
    local CurrentTarget = nil
    local SelectedHitPart = "Closest"
    
    local TargetMode = "Closest"
    
    -- =========================
    -- Notify
    -- =========================
    local LastNotification = 0
    
    local function Notify(desc, time)
        if tick() - LastNotification < 1 then
            return
        end
    
        LastNotification = tick()
    
        Library:Notify({
            Title = "Pastel.wtf",
            Description = desc,
            Time = time or 4
        })
    end
    
    -- =========================
    -- Toggle
    -- =========================
    local MyToggle = Melee:AddToggle("MeleeAuraToggle", {
        Text = "Melee Aura",
        Default = false
    })
    
    MyToggle:AddKeyPicker("AutoFarmKey", {
        Default = "None",
        Text = "Melee",
        Mode = "Toggle",
        SyncToggleState = true,
    })
    
    -- =========================
    -- Show Range
    -- =========================
    Melee:AddToggle("ShowAuraRange", {
        Text = "Show Range",
        Default = false
    })
    
    -- =========================
    -- Show Target
    -- =========================
    Melee:AddToggle("ShowTargetToggle", {
        Text = "Show Target",
        Default = false
    })
    
    Toggles.ShowTargetToggle:OnChanged(function(Value)
        ShowTarget = Value
    
        if not Value then
            Highlight.Enabled = false
            Highlight.Adornee = nil
        end
    end)
    
    -- =========================
    -- Swing Animation
    -- =========================
    Melee:AddToggle("SwingAnimationToggle", {
        Text = "Swing Animation",
        Default = false
    })
    
    Toggles.SwingAnimationToggle:OnChanged(function(Value)
        SwingAnimation = Value
    end)
    
    -- =========================
    -- Hit Effect
    -- =========================
    Melee:AddToggle("HitEffectToggle", {
        Text = "Hit Effect",
        Default = false
    })
    
    Toggles.HitEffectToggle:OnChanged(function(Value)
        HitEffect = Value
    end)
    
    -- =========================
    -- Aura Range Slider
    -- =========================
    Melee:AddSlider("MeleeAuraRange", {
        Text = "Aura Range",
        Default = 5,
        Min = 1,
        Max = 13.5,
        Rounding = 1,
        Suffix = " Studs",
    })
    
    Options.MeleeAuraRange:OnChanged(function(Value)
        AuraRange = Value
    
        Notify(
            string.format(
                "Aura Range: %.1f",
                AuraRange
            ),
            3
        )
    end)
    
    -- =========================
    -- Hit Part Dropdown
    -- =========================
    Melee:AddDropdown("MeleeHitPart", {
        Text = "Hit Part",
        Values = {
            "Head",
            "Torso",
            "Arms",
            "Legs",
            "Closest"
        },
        Default = 5,
        Multi = false
    })
    
    Options.MeleeHitPart:OnChanged(function(Value)
        SelectedHitPart = Value
    
        Notify(
            "Hit Part: " .. tostring(Value),
            3
        )
    end)
    
    -- =========================
    -- Target Dropdown
    -- =========================
    Targets:AddDropdown("TargetMode", {
        Text = "Target Mode",
        Values = {
            "Closest",
            "Lowest HP",
            "Highest HP"
        },
        Default = 1,
        Multi = false
    })
    
    Options.TargetMode:OnChanged(function(Value)
        TargetMode = Value
    
        Notify(
            "Target Mode: " .. tostring(Value),
            3
        )
    end)
    
    -- =========================
    -- Whitelist
    -- =========================
    local Whitelist = {}
    
    local WhitelistDropdown = Targets:AddDropdown("MeleeWhitelist", {
        Text = "Whitelist",
        Values = {},
        Multi = true,
        Default = {}
    })
    
    local function RefreshWhitelist()
        local names = {}
    
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                table.insert(names, plr.Name)
            end
        end
    
        WhitelistDropdown:SetValues(names)
    end
    
    RefreshWhitelist()
    
    Players.PlayerAdded:Connect(function()
        task.wait(1)
        RefreshWhitelist()
    end)
    
    Players.PlayerRemoving:Connect(function()
        task.wait(1)
        RefreshWhitelist()
    end)
    
    WhitelistDropdown:OnChanged(function(Value)
        Whitelist = Value
    end)
    
    -- =========================
    -- Range Circle
    -- =========================
    local RangePart = Instance.new("Part")
    RangePart.Name = "PastelAuraRange"
    RangePart.Anchored = true
    RangePart.CanCollide = false
    RangePart.CanQuery = false
    RangePart.CanTouch = false
    RangePart.Transparency = 0.5
    RangePart.Color = Color3.fromRGB(120, 170, 255)
    RangePart.Material = Enum.Material.Neon
    RangePart.Shape = Enum.PartType.Cylinder
    RangePart.Parent = workspace
    
    local PulseTime = 0
    
    RunService.RenderStepped:Connect(function(delta)
        PulseTime += delta * 2
    
        if not MeleeAura_Enabled or not Toggles.ShowAuraRange.Value then
            RangePart.Transparency = 1
            return
        end
    
        local Character = LocalPlayer.Character
    
        if not Character then
            RangePart.Transparency = 1
            return
        end
    
        local HRP = Character:FindFirstChild("HumanoidRootPart")
    
        if not HRP then
            RangePart.Transparency = 1
            return
        end
    
        local Pulse = math.sin(PulseTime) * 0.15
    
        local Diameter = (AuraRange * 2) + Pulse
    
        RangePart.Size = Vector3.new(
            0.1,
            Diameter,
            Diameter
        )
    
        RangePart.Transparency = 0.5
    
        RangePart.CFrame =
            CFrame.new(HRP.Position - Vector3.new(0, 2.9, 0))
            * CFrame.Angles(0, 0, math.rad(90))
    end)
    
    -- =========================
    -- Highlight
    -- =========================
    local Highlight = Instance.new("Highlight")
    Highlight.Enabled = false
    Highlight.FillColor = Color3.fromRGB(120, 170, 255)
    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    Highlight.FillTransparency = 0.45
    Highlight.OutlineTransparency = 0
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Highlight.Parent = CoreGui
    
    -- =========================
    -- Simple Hit Flash Effect
    -- =========================
    local HitGui = Instance.new("ScreenGui")
    HitGui.Name = "PastelHitFX"
    HitGui.IgnoreGuiInset = true
    HitGui.ResetOnSpawn = false
    HitGui.Parent = CoreGui
    
    local HitFlash = Instance.new("Frame")
    HitFlash.BackgroundColor3 = Color3.new(1, 1, 1)
    HitFlash.BackgroundTransparency = 1
    HitFlash.BorderSizePixel = 0
    HitFlash.Size = UDim2.fromScale(1, 1)
    HitFlash.Parent = HitGui
    
    local HitEffectTween
    
    local function CreateHitEffect()
        if not HitEffect then
            return
        end
    
        if HitEffectTween then
            pcall(function()
                HitEffectTween:Cancel()
            end)
        end
    
        HitFlash.BackgroundTransparency = 0.93
    
        HitEffectTween = TweenService:Create(
            HitFlash,
            TweenInfo.new(
                0.12,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                BackgroundTransparency = 1
            }
        )
    
        HitEffectTween:Play()
    end
    
    -- =========================
    -- Swing Animation
    -- =========================
    local CurrentSlash = 1
    
    local function PlaySwingAnimation(tool)
        if not SwingAnimation then
            return
        end
    
        if tick() - LastSwing < SwingCooldown then
            return
        end
    
        LastSwing = tick()
    
        local CharacterFolder = workspace:FindFirstChild("Characters")
    
        if not CharacterFolder then
            return
        end
    
        local PlayerCharacter = CharacterFolder:FindFirstChild(LocalPlayer.Name)
    
        if not PlayerCharacter then
            return
        end
    
        local WeaponModel = PlayerCharacter:FindFirstChild(tool.Name)
    
        if not WeaponModel then
            return
        end
    
        local AnimsFolder = WeaponModel:FindFirstChild("AnimsFolder")
    
        if not AnimsFolder then
            return
        end
    
        local SlashAnims = {
            AnimsFolder:FindFirstChild("Slash1"),
            AnimsFolder:FindFirstChild("Slash2"),
            AnimsFolder:FindFirstChild("Slash3")
        }
    
        local AnimObject = SlashAnims[CurrentSlash]
    
        if not AnimObject then
            return
        end
    
        local Character = LocalPlayer.Character
    
        if not Character then
            return
        end
    
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    
        if not Humanoid then
            return
        end
    
        local Animator = Humanoid:FindFirstChildOfClass("Animator")
    
        if not Animator then
            return
        end
    
        local success, track = pcall(function()
            return Animator:LoadAnimation(AnimObject)
        end)
    
        if success and track then
            track:Play(0.05, 1, 1)
    
            CurrentSlash += 1
    
            if CurrentSlash > #SlashAnims then
                CurrentSlash = 1
            end
        end
    end
    
    -- =========================
    -- Aura
    -- =========================
    local function RunMeleeAuraOnce()
        local me = LocalPlayer
        local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    
        if not eventsFolder then
            return
        end
    
        local remote1 = eventsFolder:FindFirstChild("XMHH.2")
        local remote2 = eventsFolder:FindFirstChild("XMHH2.2")
    
        if not remote1 or not remote2 then
            return
        end
    
        if not me.Character then
            return
        end
    
        local hrp = me.Character:FindFirstChild("HumanoidRootPart")
        local tool = me.Character:FindFirstChildOfClass("Tool")
    
        if not hrp or not tool then
            return
        end
    
        local targetChar = nil
        local bestValue = nil
    
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= me
            and plr.Character
            and not Whitelist[plr.Name] then
    
                local c = plr.Character
                local hrp2 = c:FindFirstChild("HumanoidRootPart")
                local hum = c:FindFirstChildOfClass("Humanoid")
    
                if hrp2
                and hum
                and hum.Health > 15
                and not c:FindFirstChildOfClass("ForceField") then
    
                    local dist = (hrp.Position - hrp2.Position).Magnitude
    
                    if dist <= AuraRange then
                        if TargetMode == "Closest" then
                            if not bestValue or dist < bestValue then
                                bestValue = dist
                                targetChar = c
                            end
    
                        elseif TargetMode == "Lowest HP" then
                            if not bestValue or hum.Health < bestValue then
                                bestValue = hum.Health
                                targetChar = c
                            end
    
                        elseif TargetMode == "Highest HP" then
                            if not bestValue or hum.Health > bestValue then
                                bestValue = hum.Health
                                targetChar = c
                            end
                        end
                    end
                end
            end
        end
    
        CurrentTarget = targetChar
    
        if Toggles.ShowTargetToggle.Value
        and CurrentTarget
        and CurrentTarget.Parent then
    
            Highlight.Enabled = true
            Highlight.Adornee = CurrentTarget
        else
            Highlight.Enabled = false
            Highlight.Adornee = nil
        end
    
        if not targetChar then
            return
        end
    
        -- =========================
        -- Hit Part
        -- =========================
        local hitPart = nil
    
        if SelectedHitPart == "Head" then
            hitPart = targetChar:FindFirstChild("Head")
    
        elseif SelectedHitPart == "Torso" then
            hitPart =
                targetChar:FindFirstChild("UpperTorso")
                or targetChar:FindFirstChild("Torso")
                or targetChar:FindFirstChild("LowerTorso")
    
        elseif SelectedHitPart == "Arms" then
            hitPart =
                targetChar:FindFirstChild("RightHand")
                or targetChar:FindFirstChild("LeftHand")
                or targetChar:FindFirstChild("Right Arm")
                or targetChar:FindFirstChild("Left Arm")
    
        elseif SelectedHitPart == "Legs" then
            hitPart =
                targetChar:FindFirstChild("RightFoot")
                or targetChar:FindFirstChild("LeftFoot")
                or targetChar:FindFirstChild("Right Leg")
                or targetChar:FindFirstChild("Left Leg")
    
        elseif SelectedHitPart == "Closest" then
            local parts = {}
    
            for _, obj in ipairs(targetChar:GetChildren()) do
                if obj:IsA("BasePart") then
                    table.insert(parts, obj)
                end
            end
    
            local closestDistance = math.huge
    
            for _, part in ipairs(parts) do
                local dist = (hrp.Position - part.Position).Magnitude
    
                if dist < closestDistance then
                    closestDistance = dist
                    hitPart = part
                end
            end
        end
    
        if not hitPart then
            return
        end
    
        local hitPartName = hitPart.Name
    
        local hum = targetChar:FindFirstChildOfClass("Humanoid")
    
        if not hum then
            return
        end
    
        local oldHealth = hum.Health
    
        PlaySwingAnimation(tool)
    
        local ok, result = pcall(function()
            return remote1:InvokeServer(
                "🍞",
                tick(),
                tool,
                "43TRFWX",
                "Normal",
                tick(),
                true
            )
        end)
    
        if not ok then
            return
        end
    
        task.wait(0.05)
    
        local handle =
            tool:FindFirstChild("WeaponHandle")
            or tool:FindFirstChild("Handle")
            or me.Character:FindFirstChild("Right Arm")
    
        if not handle then
            return
        end
    
        local success = pcall(function()
            remote2:FireServer(
                "🍞",
                tick(),
                tool,
                "2389ZFX34",
                result,
                false,
                handle,
                hitPart,
                targetChar,
                hrp.Position,
                hitPart.Position
            )
        end)
    
        if not success then
            return
        end
    
        task.wait(0.15)
    
        if hum.Health < oldHealth then
            CreateHitEffect()
    
            local hp = math.floor(hum.Health)
    
            if hp > 0 then
                Notify(
                    string.format(
                        "Hit %s [%s] (%d HP)",
                        targetChar.Name,
                        hitPartName,
                        hp
                    ),
                    4
                )
            else
                Notify(
                    string.format(
                        "Killed %s [%s] :3",
                        targetChar.Name,
                        hitPartName
                    ),
                    4
                )
            end
        end
    end
    
    -- =========================
    -- Toggle Logic
    -- =========================
    Toggles.MeleeAuraToggle:OnChanged(function(state)
        MeleeAura_Enabled = state
    
        if state then
            Notify("Melee Aura Enabled", 3)
    
            task.spawn(function()
                while MeleeAura_Enabled do
                    RunMeleeAuraOnce()
                    task.wait(0.08)
                end
            end)
        else
            RangePart.Transparency = 1
    
            Highlight.Enabled = false
            Highlight.Adornee = nil
    
            Notify("Melee Aura Disabled", 3)
        end
    end)
    end
end