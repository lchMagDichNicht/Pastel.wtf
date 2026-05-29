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
-- View
-- =========================

local UseCheapESP = false

pcall(function()

    if identifyexecutor then

        local Executor = string.lower(
            tostring(identifyexecutor())
        )

        if Executor:find("xeno")
        or Executor:find("solara") then

            warn("Cheap ESP Enabled For: " .. Executor)

            UseCheapESP = true
        end
    end
end)

-- =========================
-- View
-- =========================
do

local ESPLeft = Tabs.Visuals:AddLeftGroupbox("ESP", "scan-eye")


-- =========================
-- CHEAP ESP FOR XENO/SOLARA
-- =========================

if UseCheapESP then

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "CheapESP"
    ESPFolder.Parent = game.CoreGui

    local function RemoveESP()

        for _, v in pairs(
            ESPFolder:GetChildren()
        ) do
            v:Destroy()
        end
    end

    local function CreateESP(Player)

        if Player == LocalPlayer then
            return
        end

        local function Setup(Character)

            if not Character
            or not Toggles.ESPEnabled.Value then
                return
            end

            local Head =
                Character:FindFirstChild("Head")

            if not Head then
                return
            end

            local Old =
                ESPFolder:FindFirstChild(Player.Name)

            if Old then
                Old:Destroy()
            end

            local Holder = Instance.new("Folder")
            Holder.Name = Player.Name
            Holder.Parent = ESPFolder

            -- Highlight
            local Highlight =
                Instance.new("Highlight")

            Highlight.Parent = Holder
            Highlight.Adornee = Character

            Highlight.FillColor =
                Color3.fromRGB(255,255,255)

            Highlight.OutlineColor =
                Color3.fromRGB(255,255,255)

            Highlight.FillTransparency = 0.7
            Highlight.OutlineTransparency = 0

            Highlight.DepthMode =
                Enum.HighlightDepthMode.AlwaysOnTop

            -- Name ESP
            local Billboard =
                Instance.new("BillboardGui")

            Billboard.Name = "NameESP"
            Billboard.Parent = Holder
            Billboard.Adornee = Head
            Billboard.AlwaysOnTop = true

            Billboard.Size =
                UDim2.new(0,100,0,20)

            Billboard.StudsOffset =
                Vector3.new(0,2.2,0)

            Billboard.MaxDistance = 500

            local Text =
                Instance.new("TextLabel")

            Text.Parent = Billboard
            Text.BackgroundTransparency = 1

            Text.Size =
                UDim2.new(1,0,1,0)

            Text.Text = Player.Name

            Text.TextColor3 =
                Color3.fromRGB(255,255,255)

            Text.TextStrokeTransparency = 0
            Text.TextScaled = true

            Text.Font =
                Enum.Font.SourceSansBold
        end

        if Player.Character then
            Setup(Player.Character)
        end

        Player.CharacterAdded:Connect(function(Character)

            task.wait(1)
            Setup(Character)
        end)
    end

    ESPLeft:AddToggle("ESPEnabled", {
        Text = "Enable ESP",
        Default = false,
    })

    Toggles.ESPEnabled:OnChanged(function(state)

        if state then

            for _, Player in ipairs(
                Players:GetPlayers()
            ) do
                CreateESP(Player)
            end

        else
            RemoveESP()
        end
    end)

    Players.PlayerAdded:Connect(function(Player)

        Player.CharacterAdded:Connect(function()

            task.wait(1)

            if Toggles.ESPEnabled.Value then
                CreateESP(Player)
            end
        end)
    end)

    Players.PlayerRemoving:Connect(function(Player)

        local ESP =
            ESPFolder:FindFirstChild(Player.Name)

        if ESP then
            ESP:Destroy()
        end
    end)

-- =========================
-- NORMAL ESP
-- =========================

else

ESPLeft:AddToggle("ESPEnabled", {
    Text = "Enable ESP",
    Default = false,
})

local BoxToggle = ESPLeft:AddToggle("ESPBox", {
    Text = "Box ESP",
    Default = false,
})

BoxToggle:AddColorPicker("ESPBoxColor", {
    Default = Color3.fromRGB(167,251,255),
    Title = "Box Color",
})

local FillToggle = ESPLeft:AddToggle("ESPFill", {
    Text = "Filled Box",
    Default = false,
})

FillToggle:AddColorPicker("ESPFillColor", {
    Default = Color3.fromRGB(167,251,255),
    Title = "Fill Color",
})

local NameToggle = ESPLeft:AddToggle("ESPName", {
    Text = "Name ESP",
    Default = false,
})

NameToggle:AddColorPicker("ESPNameColor", {
    Default = Color3.fromRGB(167,251,255),
    Title = "Name Color",
})

local DistanceToggle = ESPLeft:AddToggle("ESPDistance", {
    Text = "Distance ESP",
    Default = false,
})

DistanceToggle:AddColorPicker("ESPDistanceColor", {
    Default = Color3.fromRGB(167,251,255),
    Title = "Distance Color",
})

ESPLeft:AddToggle("ESPHealthBar", {
    Text = "Health Bar",
    Default = false,
})

ESPLeft:AddToggle("ESPHealthText", {
    Text = "Health Text",
    Default = false,
})

local TracerToggle = ESPLeft:AddToggle("ESPTracer", {
    Text = "Tracer ESP",
    Default = false,
})

TracerToggle:AddColorPicker("ESPTracerColor", {
    Default = Color3.fromRGB(167,251,255),
    Title = "Tracer Color",
})

ESPLeft:AddSlider("ESPMaxDistance", {
    Text = "Max Distance",
    Default = 2000,
    Min = 100,
    Max = 5000,
    Rounding = 0,
    Suffix = "m",
})

ESPLeft:AddSlider("ESPThickness", {
    Text = "Thickness",
    Default = 2,
    Min = 1,
    Max = 5,
    Rounding = 1,
})

ESPLeft:AddSlider("ESPTextSize", {
    Text = "Text Size",
    Default = 13,
    Min = 10,
    Max = 25,
    Rounding = 0,
})

ESPLeft:AddDropdown("ESPTracerOrigin", {
    Text = "Tracer Origin",
    Values = {
        "Bottom",
        "Center",
        "Mouse",
        "Top"
    },
    Default = 1,
})

-- =========================
-- DRAWINGS
-- =========================

local ESPCache = {}

local function Create(Type, Props)

    local Obj = Drawing.new(Type)

    for i,v in pairs(Props) do
        Obj[i] = v
    end

    return Obj
end

local function HideESP(Cache)

    for _,Obj in pairs(Cache) do
        Obj.Visible = false
    end
end

local function CreateESP(Player)

    ESPCache[Player] = {

        Box = Create("Square", {
            Visible = false,
            Filled = false,
            Thickness = 2,
        }),

        Fill = Create("Square", {
            Visible = false,
            Filled = true,
            Transparency = 0.2,
        }),

        Name = Create("Text", {
            Visible = false,
            Center = true,
            Outline = true,
            Font = 2,
            Size = 13,
        }),

        Distance = Create("Text", {
            Visible = false,
            Center = true,
            Outline = true,
            Font = 2,
            Size = 13,
        }),

        HealthText = Create("Text", {
            Visible = false,
            Center = true,
            Outline = true,
            Font = 2,
            Size = 13,
        }),

        HealthBarOutline = Create("Square", {
            Visible = false,
            Filled = true,
            Color = Color3.new(0,0,0),
        }),

        HealthBar = Create("Square", {
            Visible = false,
            Filled = true,
        }),

        Tracer = Create("Line", {
            Visible = false,
            Thickness = 2,
        }),
    }
end

for _,Player in pairs(Players:GetPlayers()) do

    if Player ~= LocalPlayer then
        CreateESP(Player)
    end
end

Players.PlayerAdded:Connect(function(Player)

    if Player ~= LocalPlayer then
        CreateESP(Player)
    end
end)

Players.PlayerRemoving:Connect(function(Player)

    if ESPCache[Player] then

        for _,Obj in pairs(ESPCache[Player]) do
            Obj:Remove()
        end

        ESPCache[Player] = nil
    end
end)

-- =========================
-- MAIN LOOP
-- =========================

RunService.RenderStepped:Connect(function()

    if not Toggles.ESPEnabled.Value then

        for _,Cache in pairs(ESPCache) do
            HideESP(Cache)
        end

        return
    end

    for Player,Cache in pairs(ESPCache) do

        local Character = Player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")

        if not Character
        or not Humanoid
        or not Root
        or Humanoid.Health <= 0 then

            HideESP(Cache)
            continue
        end

        local Distance = (Root.Position - Camera.CFrame.Position).Magnitude

        if Distance > Options.ESPMaxDistance.Value then

            HideESP(Cache)
            continue
        end

        local Vector, OnScreen =
            Camera:WorldToViewportPoint(Root.Position)

        if not OnScreen then

            HideESP(Cache)
            continue
        end

        local Top =
            Camera:WorldToViewportPoint(
                Root.Position + Vector3.new(0,3,0)
            )

        local Bottom =
            Camera:WorldToViewportPoint(
                Root.Position - Vector3.new(0,3,0)
            )

        local Height = math.abs(Top.Y - Bottom.Y)
        local Width = Height / 2

        local X = Vector.X - Width / 2
        local Y = Vector.Y - Height / 2

        -- BOX
        Cache.Box.Visible = Toggles.ESPBox.Value
        Cache.Box.Size = Vector2.new(Width, Height)
        Cache.Box.Position = Vector2.new(X, Y)
        Cache.Box.Color = Options.ESPBoxColor.Value
        Cache.Box.Thickness = Options.ESPThickness.Value

        -- FILL
        Cache.Fill.Visible =
            Toggles.ESPBox.Value
            and Toggles.ESPFill.Value

        Cache.Fill.Size = Vector2.new(Width, Height)
        Cache.Fill.Position = Vector2.new(X, Y)
        Cache.Fill.Color = Options.ESPFillColor.Value

        -- NAME
        Cache.Name.Visible = Toggles.ESPName.Value
        Cache.Name.Text = Player.Name

        Cache.Name.Position = Vector2.new(
            Vector.X,
            Y - 16
        )

        Cache.Name.Color =
            Options.ESPNameColor.Value

        Cache.Name.Size =
            Options.ESPTextSize.Value

        -- DISTANCE
        Cache.Distance.Visible =
            Toggles.ESPDistance.Value

        Cache.Distance.Text =
            math.floor(Distance) .. "m"

        Cache.Distance.Position = Vector2.new(
            Vector.X,
            Y + Height + 2
        )

        Cache.Distance.Color =
            Options.ESPDistanceColor.Value

        Cache.Distance.Size =
            Options.ESPTextSize.Value

        -- HEALTH TEXT
        Cache.HealthText.Visible =
            Toggles.ESPHealthText.Value

        Cache.HealthText.Text =
            tostring(math.floor(Humanoid.Health))

        Cache.HealthText.Position =
            Vector2.new(
                X - 25,
                Y + Height - 10
            )

        Cache.HealthText.Color =
            Color3.fromRGB(
                255 - (255 * (Humanoid.Health / Humanoid.MaxHealth)),
                255 * (Humanoid.Health / Humanoid.MaxHealth),
                0
            )

        Cache.HealthText.Size =
            Options.ESPTextSize.Value

        -- HEALTH BAR
        local HealthPercent =
            Humanoid.Health / Humanoid.MaxHealth

        local BarHeight =
            Height * HealthPercent

        Cache.HealthBarOutline.Visible =
            Toggles.ESPHealthBar.Value

        Cache.HealthBarOutline.Size =
            Vector2.new(4, Height)

        Cache.HealthBarOutline.Position =
            Vector2.new(X - 7, Y)

        Cache.HealthBar.Visible =
            Toggles.ESPHealthBar.Value

        Cache.HealthBar.Size =
            Vector2.new(2, BarHeight)

        Cache.HealthBar.Position =
            Vector2.new(
                X - 6,
                Y + (Height - BarHeight)
            )

        Cache.HealthBar.Color =
            Color3.fromRGB(
                255 - (255 * HealthPercent),
                255 * HealthPercent,
                0
            )

        -- TRACER
        Cache.Tracer.Visible =
            Toggles.ESPTracer.Value

        local TracerOrigin =
            Options.ESPTracerOrigin.Value

        local From

        if TracerOrigin == "Bottom" then

            From = Vector2.new(
                Camera.ViewportSize.X / 2,
                Camera.ViewportSize.Y
            )

        elseif TracerOrigin == "Center" then

            From = Vector2.new(
                Camera.ViewportSize.X / 2,
                Camera.ViewportSize.Y / 2
            )

        elseif TracerOrigin == "Mouse" then

            local MousePos =
                UserInputService:GetMouseLocation()

            From = Vector2.new(
                MousePos.X,
                MousePos.Y
            )

        elseif TracerOrigin == "Top" then

            From = Vector2.new(
                Camera.ViewportSize.X / 2,
                0
            )
        end

        Cache.Tracer.From = From

        Cache.Tracer.To = Vector2.new(
            Vector.X,
            Vector.Y + Height / 2
        )

        Cache.Tracer.Color =
            Options.ESPTracerColor.Value

        Cache.Tracer.Thickness =
            Options.ESPThickness.Value
    end
end)

end
end
end