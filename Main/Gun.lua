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
-- Gun
-- =========================
do
    local Gun = Tabs.Gun:AddLeftGroupbox("Gun", "bow-arrow")
    
    
    local NoRecoil_Enabled = false
    local NoRecoil_Connections = {}
    local GlobalOriginalValues = {}
    local WeaponCache = {}
    local Settings = {GunMods={NoRecoil=true,Spread=true,SpreadAmount=0}}
    local Player_nr = LocalPlayer
    
    local function cacheWeapons()
        WeaponCache = {}
        for _, v in pairs(getgc(true)) do
            if type(v) == 'table' and rawget(v, 'EquipTime') then
                table.insert(WeaponCache, v)
                if not GlobalOriginalValues[v] then
                    GlobalOriginalValues[v] = {
                        Recoil = v.Recoil,
                        CameraRecoilingEnabled = v.CameraRecoilingEnabled,
                        AngleX_Min = v.AngleX_Min, AngleX_Max = v.AngleX_Max,
                        AngleY_Min = v.AngleY_Min, AngleY_Max = v.AngleY_Max,
                        AngleZ_Min = v.AngleZ_Min, AngleZ_Max = v.AngleZ_Max,
                        Spread = v.Spread
                    }
                end
            end
        end
    end
    
    local function applyGunMods()
        for _, weapon in ipairs(WeaponCache) do
            if Settings.GunMods.NoRecoil then
                weapon.Recoil = 0
                weapon.CameraRecoilingEnabled = false
                weapon.AngleX_Min = 0; weapon.AngleX_Max = 0
                weapon.AngleY_Min = 0; weapon.AngleY_Max = 0
                weapon.AngleZ_Min = 0; weapon.AngleZ_Max = 0
            end
            if Settings.GunMods.Spread then
                weapon.Spread = Settings.GunMods.SpreadAmount
            end
        end
    end
    
    local function resetGunMods()
        for weapon, values in pairs(GlobalOriginalValues) do
            weapon.Recoil = values.Recoil
            weapon.CameraRecoilingEnabled = values.CameraRecoilingEnabled
            weapon.AngleX_Min = values.AngleX_Min; weapon.AngleX_Max = values.AngleX_Max
            weapon.AngleY_Min = values.AngleY_Min; weapon.AngleY_Max = values.AngleY_Max
            weapon.AngleZ_Min = values.AngleZ_Min; weapon.AngleZ_Max = values.AngleZ_Max
            weapon.Spread = values.Spread
        end
    end
    
    local function handleWeapon(weapon)
        if NoRecoil_Enabled then
            task.wait(0.1)
            cacheWeapons()
            applyGunMods()
        end
    end
    
    local function onCharacterAdded_nr(character)
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Tool") then handleWeapon(child) end
        end
        table.insert(NoRecoil_Connections, character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then handleWeapon(child) end
        end))
        local humanoid = character:WaitForChild("Humanoid", 2)
        if humanoid then
            table.insert(NoRecoil_Connections, humanoid.Died:Connect(function()
                if NoRecoil_Enabled then
                    task.wait(1.5)
                    cacheWeapons()
                    applyGunMods()
                end
            end))
        end
    end
    
    function NoRecoil_Enable()
        if NoRecoil_Enabled then return end
        NoRecoil_Enabled = true
        cacheWeapons()
        applyGunMods()
        table.insert(NoRecoil_Connections, Player_nr.CharacterAdded:Connect(onCharacterAdded_nr))
        if Player_nr.Character then onCharacterAdded_nr(Player_nr.Character) end
    end
    
    function NoRecoil_Disable()
        if not NoRecoil_Enabled then return end
        NoRecoil_Enabled = false
        resetGunMods()
        for _, conn in ipairs(NoRecoil_Connections) do conn:Disconnect() end
        NoRecoil_Connections = {}
    end
    
    local NoRecoilToggle = Gun:AddToggle("NoRecoilToggle", {
        Text = "No Recoil",
        Default = false,
    })
    
    Toggles.NoRecoilToggle:OnChanged(function(state)
        if state then
            NoRecoil_Enable()
        else
            NoRecoil_Disable()
        end
    end)
    
    local player = Players.LocalPlayer
    local AutoReload = false
    
    -- SETTINGS
    local MIN_DELAY = 0.15
    local MAX_DELAY = 0.35
    
    local function getCharacter()
        return player.Character or player.CharacterAdded:Wait()
    end
    
    local function getTool(character)
        return character:FindFirstChildOfClass("Tool")
    end
    
    local function reload(tool)
        local args = {
            [1] = tick(),
            [2] = "KLWE89U0",
            [3] = workspace:WaitForChild("Characters")
                :WaitForChild(player.Name)
                :WaitForChild(tool.Name);
        }
    
        game:GetService("ReplicatedStorage")
            :WaitForChild("Events")
            :WaitForChild("GNX_R")
            :FireServer(unpack(args))
    end
    
    -- TOGGLE
    local MyToggle = Gun:AddToggle("InstantReload", {
        Text = "Auto Reload",
        Default = false,
    })
    
    MyToggle:OnChanged(function(state)
        AutoReload = state
    
        if state then
            task.spawn(function()
                while AutoReload do
                    pcall(function()
                        local character = getCharacter()
                        local tool = getTool(character)
    
                        if tool then
                            -- optional: nur wenn Tool "Ammo" hat (falls existiert)
                            local ammo = tool:FindFirstChild("Ammo")
    
                            if ammo then
                                if ammo.Value <= 0 then
                                    reload(tool)
                                end
                            else
                                -- fallback: einfach reload mit delay (legit feeling)
                                reload(tool)
                            end
                        end
                    end)
    
                    task.wait(math.random(MIN_DELAY*100, MAX_DELAY*100)/100)
                end
            end)
        end
    end)
    end
end