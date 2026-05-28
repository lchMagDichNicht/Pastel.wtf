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
    
    
    local Thumbnail = Players:GetUserThumbnailAsync(
        LocalPlayer.UserId,
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size420x420
    )
    
    local Image = Account:AddImage("MyAgaImage", {
        Image = Thumbnail,
        Transparency = 0,
        Color = Color3.new(1, 1, 1),
        ScaleType = Enum.ScaleType.Fit,
        Height = 200,
    })
    
    Image:SetTransparency(0.1)
    Image:SetColor(Color3.fromRGB(255, 200, 200))
    
    Account:AddDivider()
    
    Account:AddLabel({
        Text = "Welcome back, " .. LocalPlayer.DisplayName .. " ♡",
        DoesWrap = true,
        Size = 20
    })
    
    Account:AddLabel({
        Text = "Enjoy using Pastel.wtf :3",
        DoesWrap = true,
        Size = 15
    })
    
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
    
        Discord:AddDivider()
    
    Discord:AddLabel({
        Text = "♡ Pastel.wtf ♡",
        DoesWrap = true,
        Size = 20
    })
    
    Discord:AddLabel({
        Text = "Thank you for using my script :3",
        DoesWrap = true,
        Size = 15
    })
    
    Discord:AddDivider()
    
    Discord:AddLabel({
        Text = "Current Game",
        DoesWrap = true,
        Size = 18
    })
    
    Discord:AddLabel({
        Text = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
        DoesWrap = true,
        Size = 15
    })
    
    Discord:AddDivider()
    
    Discord:AddLabel({
        Text = "Have fun & stay pastel ♡",
        DoesWrap = true,
        Size = 16
    })
    end
    end