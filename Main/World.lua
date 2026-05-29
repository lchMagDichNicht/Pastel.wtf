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
-- World
-- =========================
do
    local WorldLeft = Tabs.World:AddLeftGroupbox("World", "earth")
    local WorldRight = Tabs.World:AddRightGroupbox("Filter", "funnel")


    -- =========================================================
    -- FPS BOOST
    -- =========================================================

    local fpsEnabled = false
    local saved = {}

    local function enableFPS()
        saved.GlobalShadows = Lighting.GlobalShadows
        saved.FogEnd = Lighting.FogEnd
        saved.Brightness = Lighting.Brightness

        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 0

        if Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
        end

        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("BasePart") then
                if not saved[v] then
                    saved[v] = {
                        Material = v.Material,
                        Reflectance = v.Reflectance
                    }
                end

                v.Material = Enum.Material.Plastic
                v.Reflectance = 0

            elseif v:IsA("Decal") or v:IsA("Texture") then
                if not saved[v] then
                    saved[v] = {
                        Transparency = v.Transparency
                    }
                end

                v.Transparency = 1

            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                if not saved[v] then
                    saved[v] = {
                        Enabled = v.Enabled
                    }
                end

                v.Enabled = false
            end
        end
    end

    local function disableFPS()
        Lighting.GlobalShadows = saved.GlobalShadows or true
        Lighting.FogEnd = saved.FogEnd or 100000
        Lighting.Brightness = saved.Brightness or 1

        for obj, data in pairs(saved) do
            if typeof(obj) == "Instance" and obj.Parent then
                if obj:IsA("BasePart") then
                    obj.Material = data.Material
                    obj.Reflectance = data.Reflectance

                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = data.Transparency

                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    obj.Enabled = data.Enabled
                end
            end
        end
    end

    WorldLeft:AddToggle("FPSBoost", {
        Text = "FPS Boost",
        Default = false,
    })

    Toggles.FPSBoost:OnChanged(function(state)
        fpsEnabled = state

        if state then
            enableFPS()
        else
            disableFPS()
        end
    end)

    -- =========================================================
    -- FULLBRIGHT
    -- =========================================================

    local FullBright_Enabled = false
    local FullBright_Connection

    local OriginalLighting = {
        ClockTime = Lighting.ClockTime,
        Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        ColorShift_Top = Lighting.ColorShift_Top,
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
    }

    local function applyFullBright()
        Lighting.Brightness = 5
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
        Lighting.ColorShift_Top = Color3.new(0,0,0)
        Lighting.FogStart = 0
        Lighting.FogEnd = 100000
    end

    local function FullBright_Enable()
        if FullBright_Enabled then
            return
        end

        FullBright_Enabled = true

        applyFullBright()

        FullBright_Connection = RunService.RenderStepped:Connect(function()
            if FullBright_Enabled then
                applyFullBright()
            end
        end)
    end

    local function FullBright_Disable()
        FullBright_Enabled = false

        if FullBright_Connection then
            FullBright_Connection:Disconnect()
            FullBright_Connection = nil
        end

        for i, v in pairs(OriginalLighting) do
            Lighting[i] = v
        end
    end

    WorldLeft:AddToggle("FullBrightToggle", {
        Text = "FullBright",
        Default = false,
    })

    Toggles.FullBrightToggle:OnChanged(function(state)
        if state then
            FullBright_Enable()
        else
            FullBright_Disable()
        end
    end)

    -- =========================================================
    -- FOV
    -- =========================================================

    local Original_Fov = Camera.FieldOfView
    local Fov_Enabled = false

    WorldLeft:AddToggle("FovToggle", {
        Text = "High Fov",
        Default = false,
    })

    WorldLeft:AddSlider("FovSlider", {
        Text = "Field of View",
        Default = 80,
        Min = 50,
        Max = 120,
        Rounding = 0,
        Suffix = "°",
        Visible = false,
    })

    Toggles.FovToggle:OnChanged(function(state)
        Fov_Enabled = state

        Options.FovSlider:SetVisible(state)

        if not state then
            Camera.FieldOfView = Original_Fov
        end
    end)

    RunService.RenderStepped:Connect(function()
        if Fov_Enabled then
            Camera.FieldOfView = Options.FovSlider.Value
        end
    end)

    -- =========================================================
    -- RED CRATE ESP
    -- =========================================================

    local espEnabled = false
    local espObjects = {}

    local crateContainer = workspace:WaitForChild("Filter"):WaitForChild("SpawnedPiles")

    local function isBest(particle)
        if not particle or not particle:IsA("ParticleEmitter") then
            return false
        end

        local kp = particle.Color.Keypoints

        if #kp == 0 then
            return false
        end

        local c = kp[1].Value

        local function close(a, b)
            return math.abs(a - b) < 0.08
        end

        return close(c.R,1)
            and close(c.G,0.18)
            and close(c.B,0.18)
    end

    local function getDistance(pos)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if not hrp then
            return 0
        end

        return math.floor((hrp.Position - pos).Magnitude)
    end

    local function createESP(obj)
        if not obj:IsA("MeshPart") then
            return
        end

        if espObjects[obj] then
            return
        end

        local particle = obj:FindFirstChildOfClass("ParticleEmitter")

        if not isBest(particle) then
            return
        end

        local text = Drawing.new("Text")
        text.Size = 16
        text.Center = true
        text.Outline = true
        text.OutlineColor = Color3.fromRGB(0,0,0)
        text.Color = Color3.fromRGB(255,0,0)
        text.Visible = false

        espObjects[obj] = text
    end

    local function removeESP(obj)
        if espObjects[obj] then
            espObjects[obj]:Remove()
            espObjects[obj] = nil
        end
    end

    for _, v in ipairs(crateContainer:GetDescendants()) do
        createESP(v)
    end

    crateContainer.DescendantAdded:Connect(createESP)
    crateContainer.DescendantRemoving:Connect(removeESP)

    RunService.RenderStepped:Connect(function()
        for obj, drawing in pairs(espObjects) do
            if espEnabled and obj and obj.Parent then
                local pos, onScreen = cam:WorldToViewportPoint(obj.Position)

                if onScreen then
                    local dist = getDistance(obj.Position)

                    drawing.Position = Vector2.new(pos.X, pos.Y)
                    drawing.Text = "Red Crate [" .. dist .. "m]"
                    drawing.Visible = true
                else
                    drawing.Visible = false
                end
            else
                drawing.Visible = false
            end
        end
    end)

    WorldLeft:AddToggle("BestESP", {
        Text = "Red Crate ESP",
        Default = false,
    })

    Toggles.BestESP:OnChanged(function(state)
        espEnabled = state
    end)

    -- =========================================================
    -- SAFE ESP
    -- =========================================================

    local safeEspEnabled = false
    local safeEspObjects = {}

    local safeContainer = workspace:WaitForChild("Map"):WaitForChild("BredMakurz")

    local selectedSafeFilter = "All"

    local function getSafeCleanName(name)
        if name:find("MediumSafe") then
            return "MediumSafe"
        elseif name:find("Register") then
            return "Register"
        elseif name:find("SmallSafe") then
            return "SmallSafe"
        end
    end

    local function getSafePosition(obj)
        if obj:IsA("BasePart") then
            return obj.Position
        elseif obj:IsA("Model") then
            local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            return primary and primary.Position
        end
    end

    local function isSafeBroken(obj)
        local values = obj:FindFirstChild("Values")
        local broken = values and values:FindFirstChild("Broken")

        return broken and broken.Value or false
    end

    local function createSafeESP(obj)
        local clean = getSafeCleanName(obj.Name)

        if not clean or safeEspObjects[obj] then
            return
        end

        local nameText = Drawing.new("Text")
        nameText.Size = 16
        nameText.Center = true
        nameText.Outline = true
        nameText.OutlineColor = Color3.fromRGB(0,0,0)
        nameText.Visible = false

        local distText = Drawing.new("Text")
        distText.Size = 14
        distText.Center = true
        distText.Outline = true
        distText.OutlineColor = Color3.fromRGB(0,0,0)
        distText.Color = Color3.fromRGB(255,255,255)
        distText.Visible = false

        safeEspObjects[obj] = {
            name = nameText,
            dist = distText,
            label = clean
        }
    end

    local function removeSafeESP(obj)
        if safeEspObjects[obj] then
            safeEspObjects[obj].name:Remove()
            safeEspObjects[obj].dist:Remove()
            safeEspObjects[obj] = nil
        end
    end

    for _, v in ipairs(safeContainer:GetDescendants()) do
        createSafeESP(v)
    end

    safeContainer.DescendantAdded:Connect(createSafeESP)
    safeContainer.DescendantRemoving:Connect(removeSafeESP)

    RunService.RenderStepped:Connect(function()
        for obj, data in pairs(safeEspObjects) do
            if safeEspEnabled and obj and obj.Parent then
                local pos3d = getSafePosition(obj)

                if pos3d then
                    local pos, onScreen = cam:WorldToViewportPoint(pos3d)

                    if onScreen then
                        if selectedSafeFilter ~= "All"
                            and data.label ~= selectedSafeFilter then

                            data.name.Visible = false
                            data.dist.Visible = false
                            continue
                        end

                        local dist = getDistance(pos3d)

                        data.name.Color = isSafeBroken(obj)
                            and Color3.fromRGB(255,0,0)
                            or Color3.fromRGB(0,255,0)

                        data.name.Position = Vector2.new(pos.X, pos.Y)
                        data.name.Text = data.label
                        data.name.Visible = true

                        data.dist.Position = Vector2.new(pos.X, pos.Y + 14)
                        data.dist.Text = "[" .. dist .. "m]"
                        data.dist.Visible = true
                    else
                        data.name.Visible = false
                        data.dist.Visible = false
                    end
                end
            else
                data.name.Visible = false
                data.dist.Visible = false
            end
        end
    end)

    WorldLeft:AddToggle("SafeESP", {
        Text = "Safe ESP",
        Default = false,
    })

    Toggles.SafeESP:OnChanged(function(state)
        safeEspEnabled = state
    end)

    WorldRight:AddDropdown("SafeFilter", {
        Text = "Safe Filter",
        Values = { "All", "MediumSafe", "Register", "SmallSafe" },
        Default = 1,
    })

    Options.SafeFilter:OnChanged(function()
        selectedSafeFilter = Options.SafeFilter.Value
    end)

    Options.SafeFilter:SetValue("All")

    -- =========================================================
    -- PILE ESP
    -- =========================================================

    local pileEspEnabled = false
    local pileEspObjects = {}

    local pileContainer = workspace:WaitForChild("Filter"):WaitForChild("SpawnedPiles")

    local selectedPileFilter = "All"

    local function getPileDistance(pos)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if not hrp then
            return 0
        end

        return math.floor((hrp.Position - pos).Magnitude)
    end

    local function getPilePosition(model)
        if not model or not model.Parent then
            return nil
        end

        local primary = model.PrimaryPart

        if primary then
            return primary.Position
        end

        local part = model:FindFirstChildWhichIsA("BasePart")

        if part then
            return part.Position
        end

        return nil
    end

    local function getPileType(name)
        if string.find(name, "S1") then
            return "S1"
        elseif string.find(name, "S2") then
            return "S2"
        end

        return nil
    end

    local function createPileESP(model)
        if not model:IsA("Model") then
            return
        end

        if pileEspObjects[model] then
            return
        end

        local pileType = getPileType(model.Name)

        if not pileType then
            return
        end

        local nameText = Drawing.new("Text")
        nameText.Size = 16
        nameText.Center = true
        nameText.Outline = true
        nameText.OutlineColor = Color3.fromRGB(0,0,0)
        nameText.Visible = false

        local distText = Drawing.new("Text")
        distText.Size = 14
        distText.Center = true
        distText.Outline = true
        distText.OutlineColor = Color3.fromRGB(0,0,0)
        distText.Color = Color3.fromRGB(255,255,255)
        distText.Visible = false

        pileEspObjects[model] = {
            name = nameText,
            dist = distText,
            pileType = pileType
        }
    end

    local function removePileESP(model)
        local data = pileEspObjects[model]

        if not data then
            return
        end

        if data.name then
            data.name:Remove()
        end

        if data.dist then
            data.dist:Remove()
        end

        pileEspObjects[model] = nil
    end

    for _, v in ipairs(pileContainer:GetChildren()) do
        createPileESP(v)
    end

    pileContainer.ChildAdded:Connect(createPileESP)
    pileContainer.ChildRemoved:Connect(removePileESP)

    RunService.RenderStepped:Connect(function()
        for model, data in pairs(pileEspObjects) do
            if not pileEspEnabled then
                data.name.Visible = false
                data.dist.Visible = false
                continue
            end

            if not model or not model.Parent then
                removePileESP(model)
                continue
            end

            if selectedPileFilter ~= "All"
                and data.pileType ~= selectedPileFilter then

                data.name.Visible = false
                data.dist.Visible = false
                continue
            end

            local pos3d = getPilePosition(model)

            if not pos3d then
                data.name.Visible = false
                data.dist.Visible = false
                continue
            end

            local pos, onScreen = cam:WorldToViewportPoint(pos3d)

            if not onScreen then
                data.name.Visible = false
                data.dist.Visible = false
                continue
            end

            local dist = getPileDistance(pos3d)

            if data.pileType == "S1" then
                data.name.Color = Color3.fromRGB(0,255,100)
            elseif data.pileType == "S2" then
                data.name.Color = Color3.fromRGB(255,80,80)
            end

            data.name.Position = Vector2.new(pos.X, pos.Y)
            data.name.Text = data.pileType .. " Pile"
            data.name.Visible = true

            data.dist.Position = Vector2.new(pos.X, pos.Y + 14)
            data.dist.Text = "[" .. dist .. "m]"
            data.dist.Visible = true
        end
    end)

    WorldLeft:AddToggle("PileESP", {
        Text = "Pile ESP",
        Default = false,
    })

    Toggles.PileESP:OnChanged(function(state)
        pileEspEnabled = state
    end)

    WorldRight:AddDropdown("PileFilter", {
        Text = "Pile Filter",
        Values = { "All", "S1", "S2" },
        Default = 1,
    })

    Options.PileFilter:OnChanged(function()
        selectedPileFilter = Options.PileFilter.Value
    end)

    Options.PileFilter:SetValue("All")

    -- =========================================================
    -- DEALER ESP
    -- =========================================================

    local DealerESPFolder = workspace:WaitForChild("Map"):WaitForChild("Shopz")

    local DealerESPObjects = {}
    local DealerConnections = {}

    local function clearDealerESP()
        for _, v in pairs(DealerESPObjects) do
            if typeof(v) == "Instance" and v.Parent then
                v:Destroy()
            end
        end

        for _, c in pairs(DealerConnections) do
            if c then
                c:Disconnect()
            end
        end

        table.clear(DealerESPObjects)
        table.clear(DealerConnections)
    end

    local function createDealerESP(model)
        if not model:IsA("Model") then
            return
        end

        if model:FindFirstChild("DealerHighlight") then
            return
        end

        local humanoid = model:FindFirstChildWhichIsA("Humanoid")

        if humanoid then
            humanoid.DisplayDistanceType =
                Enum.HumanoidDisplayDistanceType.None
        end

        local adornee =
            model:FindFirstChild("Head")
            or model:FindFirstChild("HumanoidRootPart")
            or model.PrimaryPart
            or model:FindFirstChildWhichIsA("BasePart")

        if not adornee then
            return
        end

        local highlight = Instance.new("Highlight")
        highlight.Name = "DealerHighlight"
        highlight.Adornee = model
        highlight.FillColor = Color3.fromRGB(255,140,0)
        highlight.OutlineColor = Color3.fromRGB(255,200,120)
        highlight.FillTransparency = 0.4
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = model

        table.insert(DealerESPObjects, highlight)

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "DealerBillboard"
        billboard.Adornee = adornee
        billboard.Size = UDim2.new(0,170,0,20)
        billboard.StudsOffset = Vector3.new(0,3,0)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = 1000
        billboard.Parent = model

        table.insert(DealerESPObjects, billboard)

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1,0,1,0)
        text.BackgroundTransparency = 1
        text.TextColor3 = Color3.fromRGB(255,140,0)
        text.TextStrokeTransparency = 0
        text.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        text.Font = Enum.Font.GothamBold
        text.TextSize = 13
        text.Parent = billboard

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not Toggles.DealerESP.Value then
                text.Visible = false
                return
            end

            if not model.Parent or not adornee.Parent then
                connection:Disconnect()
                return
            end

            local hrp = LocalPlayer.Character
                and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            if hrp then
                local distance =
                    math.floor((hrp.Position - adornee.Position).Magnitude)

                text.Text = model.Name .. " [" .. distance .. "m]"
                text.Visible = true
            end
        end)

        table.insert(DealerConnections, connection)
    end

    local function enableDealerESP()
        clearDealerESP()

        for _, v in ipairs(DealerESPFolder:GetChildren()) do
            if v:IsA("Model") then
                createDealerESP(v)
            end
        end
    end

    WorldLeft:AddToggle("DealerESP", {
        Text = "Dealer ESP",
        Default = false,
    })

    Toggles.DealerESP:OnChanged(function(state)
        if state then
            enableDealerESP()
        else
            clearDealerESP()
        end
    end)

    DealerESPFolder.ChildAdded:Connect(function(v)
        if Toggles.DealerESP.Value and v:IsA("Model") then
            task.wait(0.2)
            createDealerESP(v)
        end
    end)
end
end