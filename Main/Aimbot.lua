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

    -- =========================
-- Aimbot & Silent Aim Script
-- =========================
do
    local Aimbot = Tabs.Aimbot:AddLeftGroupbox("Aimbot", "crosshair")
    local SilentAim = Tabs.Aimbot:AddRightGroupbox("Silent Aim", "crosshair")

    local on = false
    local tgtPart = "Head"
    local sensitivity = 50
    local fovRadius = 40
    local visibleCheck = false

    -- Gemeinsame Whitelist-Tabelle für beide Systeme
    local GlobalWhitelist = {}

    -- DRAWING FOV
    local fovCircle
    if Drawing then
        fovCircle = Drawing.new("Circle")
        fovCircle.Visible = false
        fovCircle.Radius = fovRadius
        fovCircle.Thickness = 1
        fovCircle.Filled = false
        fovCircle.NumSides = 100
        fovCircle.Color = Color3.fromRGB(255,255,255)
    end

    -- UPDATE FOV POSITION
    RunService.RenderStepped:Connect(function()
        if fovCircle then
            local vp = cam.ViewportSize
            fovCircle.Position = Vector2.new(vp.X/2, vp.Y/2)
        end
    end)

    -- TARGET PART HELPERS (Aimbot)
    local function getTargetPart(char, partName)
        if not char then return end
        if partName == "Torso" then
            return char:FindFirstChild("UpperTorso") 
                or char:FindFirstChild("LowerTorso") 
                or char:FindFirstChild("Torso")
        end
        return char:FindFirstChild("Head")
    end

    -- VISIBLE CHECK (Raycast)
    local function isVisible(part, character)
        if not visibleCheck then return true end
        local origin = cam.CFrame.Position
        local direction = (part.Position - origin)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Blacklist
        params.FilterDescendantsInstances = {LocalPlayer.Character, character}
        local result = workspace:Raycast(origin, direction, params)
        return not result
    end

    -- GET CLOSEST TARGET (Standard Aimbot)
    local function getClosestTarget()
        local closestPart = nil
        local shortestDist = fovRadius
        local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)

        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                
                -- Whitelist Check für Standard Aimbot
                if table.find(GlobalWhitelist, plr.Name) then continue end

                local humanoid = plr.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local part = getTargetPart(plr.Character, tgtPart)
                    if part and isVisible(part, plr.Character) then
                        local pos, visible = cam:WorldToViewportPoint(part.Position)
                        if visible and pos.Z > 0 then
                            local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                closestPart = part
                            end
                        end
                    end
                end
            end
        end
        return closestPart
    end

    -- AIM LOOP
    RunService:BindToRenderStep("Aimbot", Enum.RenderPriority.Camera.Value + 1, function()
        if fovCircle then
            fovCircle.Radius = fovRadius
            fovCircle.Visible = on
        end
        if on then
            local part = getClosestTarget()
            if part then
                local current = cam.CFrame
                local target = CFrame.new(current.Position, part.Position)
                local alpha = math.clamp(sensitivity / 100, 0.05, 1)
                cam.CFrame = (sensitivity >= 100) and target  or current:Lerp(target, alpha)
            end
        end
    end)

    local SA = {
        On = false, DrawCircle = false, DrawSize = 100, ChkDowned = false, ChkTeam = false, VisChk = false,
        MaxDist = 500, AutoWall = true, HitChance = 100, UseFOV = true, Debug = false,
        FOVCol = Color3.fromRGB(255, 255, 255), TMode = "Head",
        Parts = { 
            ["Head"] = {"Head"}, 
            ["Torso"] = {"Torso", "UpperTorso", "LowerTorso", "HumanoidRootPart"},
            ["Arms"] = {"LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand", "Left Arm", "Right Arm"},
            ["Legs"] = {"LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot", "Left Leg", "Right Leg"}
        }
    }

    local SACircle = nil
    function crFOVCircle()
        if SACircle then SACircle:Remove(); SACircle = nil end
        if SA.DrawCircle and Drawing then
            SACircle = Drawing.new("Circle"); SACircle.Color = SA.FOVCol; SACircle.Filled = false
            SACircle.Thickness = 0.5; SACircle.Radius = SA.DrawSize; SACircle.Visible = true; SACircle.Transparency = 1
        end
    end

    function getValidT()
        if not SA.On then return nil end
        local Cam = workspace.CurrentCamera
        local t = nil; local minD = math.huge; local centerPos = UIS:GetMouseLocation()
        local LP = Players.LocalPlayer
        
        for _, p in pairs(Players:GetPlayers()) do
            if p == LP then continue end
            
            -- Whitelist Check für Silent Aim
            if table.find(GlobalWhitelist, p.Name) then continue end
            
            if not p.Character then continue end
            local c = p.Character; local h = c:FindFirstChildOfClass("Humanoid")
            if not h or h.Health <= 0 then continue end

            local currentMode = SA.TMode
            if currentMode == "Random" then
                local modes = {"Head", "Torso", "Arms", "Legs"}
                currentMode = modes[math.random(1, #modes)]
            end

            local validP = SA.Parts[currentMode]; if not validP then validP = {"Head"} end
            local avail = {}; for _, pn in ipairs(validP) do local pt = c:FindFirstChild(pn); if pt then table.insert(avail, {Part=pt, Name=pn}) end end
            if #avail == 0 then continue end
            
            local sel = avail[math.random(1, #avail)]

            if not sel or not sel.Part then continue end
            local tp = sel.Part; local pPos = tp.Position
            local myC = LP.Character; local myR = myC and myC:FindFirstChild("HumanoidRootPart")
            if myR then local d = (myR.Position - pPos).Magnitude; if d > SA.MaxDist then continue end end
            
            -- WALL CHECK
            local ray = Ray.new(Cam.CFrame.Position, (pPos - Cam.CFrame.Position).Unit * 1000)
            local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LP.Character, Cam})
            if hit and not hit:IsDescendantOf(c) and hit.Transparency < 1 then continue end
            
            local sPos, onSc = Cam:WorldToViewportPoint(pPos); if not onSc then continue end
            if SA.UseFOV then
                local closestLimbDist = math.huge
                for _, limb in pairs(c:GetChildren()) do
                    if limb:IsA("BasePart") then
                        local lsP, lsOnSc = Cam:WorldToViewportPoint(limb.Position)
                        if lsOnSc then
                            local ld2m = (centerPos - Vector2.new(lsP.X, lsP.Y)).Magnitude
                            if ld2m < closestLimbDist then closestLimbDist = ld2m end
                        end
                    end
                end
                
                if closestLimbDist > SA.DrawSize + 35 then continue end
                if closestLimbDist < minD then minD = closestLimbDist; t = {Player=p, Char=c, Part=tp, PName=sel.Name, Pos=pPos, Dist=closestLimbDist, ScPos=sPos, WDist=(myR and (myR.Position-pPos).Magnitude) or 0} end
            else
                if myR then local wd = (myR.Position - pPos).Magnitude; if wd < minD then minD = wd; t = {Player=p, Char=c, Part=tp, PName=sel.Name, Pos=pPos, Dist=0, ScPos=sPos, WDist=wd} end end
            end
        end
        
        -- HIT CHANCE LOGIK
        if t then 
            local chanceRoll = math.random(1, 100)
            if chanceRoll > SA.HitChance then 
                return nil
            end 
        end
        return t
    end

    function canFire(t) if not t then return false end; if SA.UseFOV and t.Dist > SA.DrawSize + 35 then return false end; return true end

    local SALoopConn = nil
    function updFOVCircle()
        if SACircle and SA.DrawCircle then
            SACircle.Position = UIS:GetMouseLocation()
            SACircle.Radius = SA.DrawSize; SACircle.Visible = SA.On; SACircle.Color = SA.FOVCol
        end
    end

    function startSALoop()
        if SALoopConn then SALoopConn:Disconnect() end
        SALoopConn = RunService.Heartbeat:Connect(function() updFOVCircle(); _G.CurSATarget = getValidT() end)
    end

    local SAConns = {}; local lastT = nil; local lastDmg = false
    local ev2_bindable = game:GetService("ReplicatedStorage"):FindFirstChild("Events2")
    local ZFK_remote = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and game:GetService("ReplicatedStorage").Events:FindFirstChild("ZFKLF__H")

    function hookShoot()
        for _, c in pairs(SAConns) do if c then c:Disconnect() end end; SAConns = {}
        local LP = Players.LocalPlayer
        
        if ev2_bindable and ZFK_remote then
            local viz = ev2_bindable:FindFirstChild("Visualize")
            if viz then
                local c = viz.Event:Connect(function(_, sc, _, gun, _, sPos, bps)
                    if not SA.On then return end
                    local t = getValidT(); if not t or not canFire(t) then lastT = nil; lastDmg = false; return end
                    lastT = t; local char = LP.Character; if not char then return end
                    local myG = char:FindFirstChildOfClass("Tool"); if not myG or myG ~= gun then return end
                    local h = t.Char:FindFirstChildOfClass("Humanoid"); if not h or h.Health <= 0 then return end
                    local tp = t.Part; local pPos = tp.Position
                    local rOff = Vector3.new((math.random()-0.5)*0.5,(math.random()-0.5)*0.5,(math.random()-0.5)*0.5)
                    local hitPos = pPos + rOff
                    local newB = {}; for i=1,#bps do
                        local dir = (hitPos - sPos).Unit; local spAmt = (100 - SA.HitChance)/500
                        local sp = Vector3.new((math.random()-0.5)*spAmt,(math.random()-0.5)*spAmt,(math.random()-0.5)*spAmt)
                        table.insert(newB, dir+sp)
                    end
                    lastDmg = true
                    task.spawn(function()
                        for i=1,#newB do task.wait(0.01); pcall(function() ZFK_remote:FireServer("🧈", gun, sc, i, tp, hitPos, newB[i]) end) end
                    end)
                    if gun:FindFirstChild("Hitmarker") and lastDmg then gun.Hitmarker:Fire(tp) end
                end)
                table.insert(SAConns, c)
            end
        end
    end

    function SA_Enable()
        if SA.On then return end
        SA.On = true
        crFOVCircle(); startSALoop(); hookShoot()
    end

    function SA_Disable()
        if not SA.On then return end
        SA.On = false
        if SALoopConn then SALoopConn:Disconnect(); SALoopConn = nil end
        if SACircle then SACircle:Remove(); SACircle = nil end
        for _, c in pairs(SAConns) do if c then c:Disconnect() end end; SAConns = {}
        _G.CurSATarget = nil; lastT = nil; lastDmg = false
    end

    Aimbot:AddToggle("AimEnabled", { Text = "Aimbot", Default = false }):AddKeyPicker("AimbotKey", { Default = "None", Text = "Aimbot", Mode = "Toggle", SyncToggleState = true })
    Toggles.AimEnabled:OnChanged(function(state) on = state end)

    Aimbot:AddDropdown("TargetPart", { Text = "Target Part", Values = { "Head", "Torso" }, Default = 1 })
    Options.TargetPart:OnChanged(function() tgtPart = Options.TargetPart.Value end)

    Aimbot:AddToggle("VisibleCheck", { Text = "Visible Check", Default = false })
    Toggles.VisibleCheck:OnChanged(function(state) visibleCheck = state end)

    Aimbot:AddSlider("Sensitivity", { Text = "Sensitivity", Default = 50, Min = 0, Max = 100, Rounding = 0, Suffix = "%" })
    Options.Sensitivity:OnChanged(function(v) sensitivity = v end)

    Aimbot:AddSlider("FOV", { Text = "FOV Size", Default = 40, Min = 10, Max = 500, Rounding = 0, Suffix = "px" })
    Options.FOV:OnChanged(function(v) fovRadius = v end)

    Aimbot:AddDropdown("PlayerWhitelistAimbot", { Text = "Whitelist (Don't Lock)", Values = {}, Multi = true, Default = {} })

    SilentAim:AddToggle("AimbotToggle", { Text = "Enable Silent Aim", Default = false }):AddKeyPicker("SilentAimKey", { Default = "None", Text = "Silent Aim", Mode = "Toggle", SyncToggleState = true })
    Toggles.AimbotToggle:OnChanged(function(state) if state then SA_Enable() else SA_Disable() end end)

    SilentAim:AddDropdown("SATargetPart", { Text = "Target Part", Values = { "Head", "Torso", "Arms", "Legs", "Random" }, Default = 1 })
    Options.SATargetPart:OnChanged(function() SA.TMode = Options.SATargetPart.Value end)

    SilentAim:AddToggle("DrawFOVToggle", { Text = "Draw FOV Circle", Default = false })
    Toggles.DrawFOVToggle:OnChanged(function(state) SA.DrawCircle = state; crFOVCircle() end)

    SilentAim:AddSlider("FOVSize", { Text = "FOV Size", Default = 100, Min = 50, Max = 300, Rounding = 0, Suffix = "px" })
    Options.FOVSize:OnChanged(function(v) SA.DrawSize = v; if SACircle then SACircle.Radius = v end end)

    SilentAim:AddSlider("HitChance", { Text = "Hit Chance", Default = 100, Min = 0, Max = 100, Rounding = 0, Suffix = "%" })
    Options.HitChance:OnChanged(function(v) SA.HitChance = v end)

    SilentAim:AddSlider("MaxDistance", { Text = "Max Distance", Default = 500, Min = 100, Max = 2000, Rounding = 0, Suffix = "studs" })
    Options.MaxDistance:OnChanged(function(v) SA.MaxDist = v end)

    SilentAim:AddDropdown("PlayerWhitelistSilent", { Text = "Whitelist (Don't Shoot)", Values = {}, Multi = true, Default = {} })

    local function UpdateWhitelistDropdowns()
        local playerNames = {}
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer then
                table.insert(playerNames, v.Name)
            end
        end
        Options.PlayerWhitelistAimbot:SetValues(playerNames)
        Options.PlayerWhitelistSilent:SetValues(playerNames)
    end

    Options.PlayerWhitelistAimbot:OnChanged(function()
        GlobalWhitelist = {}
        for name, selected in pairs(Options.PlayerWhitelistAimbot.Value) do
            if selected then table.insert(GlobalWhitelist, name) end
        end
        Options.PlayerWhitelistSilent:SetValue(Options.PlayerWhitelistAimbot.Value)
    end)

    Options.PlayerWhitelistSilent:OnChanged(function()
        GlobalWhitelist = {}
        for name, selected in pairs(Options.PlayerWhitelistSilent.Value) do
            if selected then table.insert(GlobalWhitelist, name) end
        end
        Options.PlayerWhitelistAimbot:SetValue(Options.PlayerWhitelistSilent.Value)
    end)

    Players.PlayerAdded:Connect(UpdateWhitelistDropdowns)
    Players.PlayerRemoving:Connect(UpdateWhitelistDropdowns)
    UpdateWhitelistDropdowns()
end
end