local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events")

local CoinLanded = Events:WaitForChild("CoinLanded")

local TradeRequestResponse = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("TradeRequestResponse")
local TradeAccept = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("TradeAccept")

local autoCoin = true
local coinLoop = nil

local autoAccept = true
local autoAcceptTrade = true
local acceptLoop = nil
local acceptTradeLoop = nil
local alreadyAccepted = false

local antiAFK = true
local antiAFKLoop = nil
local currentTab = "MAIN"

local function StartAntiAFK()
    if antiAFKLoop then return end
    antiAFKLoop = task.spawn(function()
        while antiAFK do
            task.wait(45)
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                VirtualUser:ClickButton1(Vector2.new())
            end)
        end
    end)
end

local function StopAntiAFK()
    antiAFK = false
    if antiAFKLoop then
        task.cancel(antiAFKLoop)
        antiAFKLoop = nil
    end
end

StartAntiAFK()

pcall(function()
    local scripts = player:FindFirstChild("PlayerScripts")
    if scripts then
        scripts = scripts:FindFirstChild("Scripts")
        if scripts then
            local antiKick = scripts:FindFirstChild("AntiKickScript")
            if antiKick then antiKick:Destroy() end
        end
    end
end)

pcall(function()
    local events = ReplicatedStorage:FindFirstChild("Assets")
    if events then
        events = events:FindFirstChild("Events")
        if events then
            local remotes = {"AntiKickReconnect", "SetAFKSafe", "StartAFKSafe"}
            for _, name in ipairs(remotes) do
                local remote = events:FindFirstChild(name)
                if remote then remote:Destroy() end
            end
        end
    end
end)

local function ThrowCoin()
    local args = {
        1.9999999999,
        Vector3.new(-1162.6304931640625, 0.7260000109672546, 89.36738586425781),
        "Zeus Coin",
        Vector3.new(-1156.7032470703125, 0.7260000109672546, 88.43637084960938),
        [6] = 1
    }
    pcall(function()
        CoinLanded:FireServer(unpack(args))
        print("🪙 Auto Coin thrown!")
    end)
end

local function StartCoinLoop()
    if coinLoop then return end
    coinLoop = task.spawn(function()
        while autoCoin do
            ThrowCoin()
            task.wait(2)
        end
    end)
end

local function StopCoinLoop()
    autoCoin = false
    if coinLoop then
        task.cancel(coinLoop)
        coinLoop = nil
    end
end

StartCoinLoop()

task.spawn(function()
    while true do
        for i, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
            if v.ClassName == "ProximityPrompt" then
                v.HoldDuration = 0
            end
        end
        task.wait(5)
    end
end)

local RequestWorldTeleport = ReplicatedStorage:FindFirstChild("Assets")
if RequestWorldTeleport then
    RequestWorldTeleport = RequestWorldTeleport:FindFirstChild("Events")
    if RequestWorldTeleport then
        RequestWorldTeleport = RequestWorldTeleport:FindFirstChild("RequestWorldTeleport")
    end
end

local function TeleportToWorld3()
    if not RequestWorldTeleport then return end
    pcall(function()
        RequestWorldTeleport:FireServer(3)
        print("✅ Teleport ke World 3!")
    end)
end

local function TeleportToVIPPosition()
    local character = player.Character
    if not character or not character.Parent then
        character = player.CharacterAdded:Wait()
        task.wait(1)
    end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        pcall(function()
            hrp.CFrame = CFrame.new(Vector3.new(-1152, 4, 52))
            print("✅ Teleport ke VIP Position!")
        end)
    end
end

task.wait(1)
TeleportToWorld3()
task.wait(3)
TeleportToVIPPosition()

local function AutoAcceptUI()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    local uiFolder = playerGui:FindFirstChild("UiFolder")
    if not uiFolder then return end
    
    local main = uiFolder:FindFirstChild("Main")
    if not main then return end
    
    local hud = main:FindFirstChild("HUD")
    if hud then
        local tradeRequests = hud:FindFirstChild("TradeRequests")
        if tradeRequests then
            for _, child in pairs(tradeRequests:GetChildren()) do
                if child:IsA("Frame") and child.Name:find("Request_") then
                    local userId = child.Name:gsub("Request_", "")
                    userId = tonumber(userId)
                    if userId then
                        pcall(function()
                            TradeRequestResponse:FireServer(userId, true)
                            print("✅ Auto Accept dari User ID: " .. userId)
                        end)
                        child:Destroy()
                    end
                end
            end
        end
    end
    
    local frames = main:FindFirstChild("Frames")
    if frames then
        local trade = frames:FindFirstChild("Trade")
        if trade then
            local tradeContainer = trade:FindFirstChild("TradeContainer")
            if tradeContainer then
                local buttons = tradeContainer:FindFirstChild("Buttons")
                if buttons then
                    local acceptBtn = buttons:FindFirstChild("AcceptButton")
                    if acceptBtn then
                        local theirProfile = tradeContainer:FindFirstChild("TheirOffer")
                        if theirProfile then
                            local profile = theirProfile:FindFirstChild("Profile")
                            if profile then
                                local username = profile:FindFirstChild("Username")
                                if username then
                                    local readyIcon = username:FindFirstChild("ready")
                                    if readyIcon and readyIcon.Enabled then
                                        pcall(function()
                                            acceptBtn:FireClick()
                                            print("✅ Auto Accept - Lawan udah accept!")
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local function StartAcceptLoop()
    if acceptLoop then return end
    acceptLoop = task.spawn(function()
        while autoAccept do
            AutoAcceptUI()
            task.wait(0.1)
        end
    end)
end

local function StopAcceptLoop()
    autoAccept = false
    if acceptLoop then
        task.cancel(acceptLoop)
        acceptLoop = nil
    end
end

StartAcceptLoop()

local function IsLawanAccept()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    
    local uiFolder = playerGui:FindFirstChild("UiFolder")
    if not uiFolder then return false end
    
    local main = uiFolder:FindFirstChild("Main")
    if not main then return false end
    
    local frames = main:FindFirstChild("Frames")
    if not frames then return false end
    
    local trade = frames:FindFirstChild("Trade")
    if not trade then return false end
    
    local tradeContainer = trade:FindFirstChild("TradeContainer")
    if not tradeContainer then return false end
    
    local theirOffer = tradeContainer:FindFirstChild("TheirOffer")
    if not theirOffer then return false end
    
    local profile = theirOffer:FindFirstChild("Profile")
    if not profile then return false end
    
    local username = profile:FindFirstChild("Username")
    if not username then return false end
    
    local readyIcon = username:FindFirstChild("ready")
    if readyIcon and readyIcon.Enabled then
        return true
    end
    
    return false
end

local function StartAcceptTradeLoop()
    if acceptTradeLoop then return end
    acceptTradeLoop = task.spawn(function()
        while autoAcceptTrade do
            if IsLawanAccept() then
                if not alreadyAccepted then
                    pcall(function()
                        TradeAccept:FireServer()
                        print("✅ Auto Accept Trade - Lawan udah accept!")
                        alreadyAccepted = true
                    end)
                end
            else
                if alreadyAccepted then
                    alreadyAccepted = false
                end
            end
            task.wait(0.1)
        end
    end)
end

local function StopAcceptTradeLoop()
    autoAcceptTrade = false
    if acceptTradeLoop then
        task.cancel(acceptTradeLoop)
        acceptTradeLoop = nil
    end
end

StartAcceptTradeLoop()

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZAIXPLOIT"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 360, 0, 260)
Main.Position = UDim2.new(0.5, -180, 0.5, -130)
Main.BackgroundColor3 = Color3.fromRGB(10, 8, 20)
Main.BackgroundTransparency = 0.05
Main.BorderSizePixel = 3
Main.BorderColor3 = Color3.fromRGB(60, 200, 80)
Main.ClipsDescendants = true
Main.Active = true
Main.Draggable = true
Main.Selectable = true
Main.Parent = screenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local Glow = Instance.new("UIStroke")
Glow.Color = Color3.fromRGB(60, 200, 80)
Glow.Transparency = 0.4
Glow.Thickness = 2
Glow.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = Color3.fromRGB(20, 18, 35)
Header.BackgroundTransparency = 0.1
Header.BorderSizePixel = 0
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 0, 18)
Title.Position = UDim2.new(0, 12, 0, 3)
Title.BackgroundTransparency = 1
Title.Text = "⭐ ZAIXPLOIT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.LuckiestGuy
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -60, 0, 14)
SubTitle.Position = UDim2.new(0, 12, 0, 23)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "🪙 THROW A COIN + AUTO TRADE + MISC"
SubTitle.TextColor3 = Color3.fromRGB(255, 200, 50)
SubTitle.Font = Enum.Font.FredokaOne
SubTitle.TextSize = 10
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = Header

local isMinimized = false
local originalSize = Main.Size

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -54, 0, 9)
MinBtn.Text = "➖"
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
MinBtn.BackgroundTransparency = 0.2
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.BorderSizePixel = 0
MinBtn.ZIndex = 30
MinBtn.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

MinBtn.MouseEnter:Connect(function()
    MinBtn.BackgroundTransparency = 0.05
end)
MinBtn.MouseLeave:Connect(function()
    MinBtn.BackgroundTransparency = 0.2
end)

MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        Main.Size = UDim2.new(0, 360, 0, 42)
        MinBtn.Text = "➕"
        Content.Visible = false
        CloseBtn.Visible = false
    else
        Main.Size = originalSize
        MinBtn.Text = "➖"
        Content.Visible = true
        CloseBtn.Visible = true
    end
end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -26, 0, 9)
CloseBtn.Text = "❌"
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.BackgroundTransparency = 0.2
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 30
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    CloseBtn.BackgroundTransparency = 0.05
end)
CloseBtn.MouseLeave:Connect(function()
    CloseBtn.BackgroundTransparency = 0.2
end)

CloseBtn.MouseButton1Click:Connect(function()
    StopCoinLoop()
    StopAcceptLoop()
    StopAcceptTradeLoop()
    StopAntiAFK()
    screenGui:Destroy()
end)

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -14, 0, 30)
TabContainer.Position = UDim2.new(0, 7, 0, 48)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Main

local TabMain = Instance.new("TextButton")
TabMain.Size = UDim2.new(0.33, -3, 1, 0)
TabMain.Position = UDim2.new(0, 0, 0, 0)
TabMain.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
TabMain.BackgroundTransparency = 0.2
TabMain.BorderSizePixel = 2
TabMain.BorderColor3 = Color3.fromRGB(60, 200, 80)
TabMain.Text = "[ MAIN ]"
TabMain.TextColor3 = Color3.fromRGB(255, 255, 255)
TabMain.Font = Enum.Font.GothamBold
TabMain.TextSize = 12
TabMain.ZIndex = 20
TabMain.Parent = TabContainer

local TabMainCorner = Instance.new("UICorner")
TabMainCorner.CornerRadius = UDim.new(0, 6)
TabMainCorner.Parent = TabMain

local TabTrade = Instance.new("TextButton")
TabTrade.Size = UDim2.new(0.33, -3, 1, 0)
TabTrade.Position = UDim2.new(0.33, 4, 0, 0)
TabTrade.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
TabTrade.BackgroundTransparency = 0.2
TabTrade.BorderSizePixel = 2
TabTrade.BorderColor3 = Color3.fromRGB(60, 60, 80)
TabTrade.Text = "[ TRADE ]"
TabTrade.TextColor3 = Color3.fromRGB(200, 200, 210)
TabTrade.Font = Enum.Font.GothamBold
TabTrade.TextSize = 12
TabTrade.ZIndex = 20
TabTrade.Parent = TabContainer

local TabTradeCorner = Instance.new("UICorner")
TabTradeCorner.CornerRadius = UDim.new(0, 6)
TabTradeCorner.Parent = TabTrade

local TabMisc = Instance.new("TextButton")
TabMisc.Size = UDim2.new(0.33, -3, 1, 0)
TabMisc.Position = UDim2.new(0.66, 8, 0, 0)
TabMisc.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
TabMisc.BackgroundTransparency = 0.2
TabMisc.BorderSizePixel = 2
TabMisc.BorderColor3 = Color3.fromRGB(60, 60, 80)
TabMisc.Text = "[ MISC ]"
TabMisc.TextColor3 = Color3.fromRGB(200, 200, 210)
TabMisc.Font = Enum.Font.GothamBold
TabMisc.TextSize = 12
TabMisc.ZIndex = 20
TabMisc.Parent = TabContainer

local TabMiscCorner = Instance.new("UICorner")
TabMiscCorner.CornerRadius = UDim.new(0, 6)
TabMiscCorner.Parent = TabMisc

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -14, 0, 155)
Content.Position = UDim2.new(0, 7, 0, 83)
Content.BackgroundTransparency = 1
Content.Parent = Main

local MainContent = Instance.new("Frame")
MainContent.Size = UDim2.new(1, 0, 1, 0)
MainContent.Position = UDim2.new(0, 0, 0, 0)
MainContent.BackgroundTransparency = 1
MainContent.Visible = true
MainContent.Parent = Content

local coinFrame = Instance.new("Frame")
coinFrame.Size = UDim2.new(1, 0, 0, 45)
coinFrame.Position = UDim2.new(0, 0, 0, 15)
coinFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
coinFrame.BackgroundTransparency = 0.1
coinFrame.BorderSizePixel = 1
coinFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
coinFrame.Parent = MainContent

local coinCorner = Instance.new("UICorner")
coinCorner.CornerRadius = UDim.new(0, 10)
coinCorner.Parent = coinFrame

local coinLabel = Instance.new("TextLabel")
coinLabel.Size = UDim2.new(0, 160, 1, 0)
coinLabel.Position = UDim2.new(0, 14, 0, 0)
coinLabel.BackgroundTransparency = 1
coinLabel.Text = "🪙 AUTO COIN"
coinLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
coinLabel.Font = Enum.Font.FredokaOne
coinLabel.TextSize = 14
coinLabel.TextXAlignment = Enum.TextXAlignment.Left
coinLabel.Parent = coinFrame

local coinSwitchBg = Instance.new("Frame")
coinSwitchBg.Size = UDim2.new(0, 60, 0, 30)
coinSwitchBg.Position = UDim2.new(1, -72, 0.5, -15)
coinSwitchBg.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
coinSwitchBg.BackgroundTransparency = 0.1
coinSwitchBg.BorderSizePixel = 2
coinSwitchBg.BorderColor3 = Color3.fromRGB(60, 200, 80)
coinSwitchBg.Parent = coinFrame

local coinSwitchCorner = Instance.new("UICorner")
coinSwitchCorner.CornerRadius = UDim.new(0, 15)
coinSwitchCorner.Parent = coinSwitchBg

local coinOffLabel = Instance.new("TextLabel")
coinOffLabel.Size = UDim2.new(0, 22, 1, 0)
coinOffLabel.Position = UDim2.new(0, 5, 0, 0)
coinOffLabel.BackgroundTransparency = 1
coinOffLabel.Text = "OFF"
coinOffLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
coinOffLabel.Font = Enum.Font.FredokaOne
coinOffLabel.TextSize = 10
coinOffLabel.TextXAlignment = Enum.TextXAlignment.Center
coinOffLabel.Parent = coinSwitchBg

local coinOnLabel = Instance.new("TextLabel")
coinOnLabel.Size = UDim2.new(0, 22, 1, 0)
coinOnLabel.Position = UDim2.new(1, -27, 0, 0)
coinOnLabel.BackgroundTransparency = 1
coinOnLabel.Text = "ON"
coinOnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
coinOnLabel.Font = Enum.Font.FredokaOne
coinOnLabel.TextSize = 10
coinOnLabel.TextXAlignment = Enum.TextXAlignment.Center
coinOnLabel.Parent = coinSwitchBg

local coinSwitchBtn = Instance.new("TextButton")
coinSwitchBtn.Size = UDim2.new(0, 24, 0, 24)
coinSwitchBtn.Position = UDim2.new(1, -27, 0.5, -12)
coinSwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
coinSwitchBtn.BackgroundTransparency = 0.05
coinSwitchBtn.BorderSizePixel = 2
coinSwitchBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
coinSwitchBtn.Text = ""
coinSwitchBtn.ZIndex = 10
coinSwitchBtn.Parent = coinSwitchBg

local coinSwitchBtnCorner = Instance.new("UICorner")
coinSwitchBtnCorner.CornerRadius = UDim.new(0, 12)
coinSwitchBtnCorner.Parent = coinSwitchBtn

local TradeContent = Instance.new("Frame")
TradeContent.Size = UDim2.new(1, 0, 1, 0)
TradeContent.Position = UDim2.new(0, 0, 0, 0)
TradeContent.BackgroundTransparency = 1
TradeContent.Visible = false
TradeContent.Parent = Content

local acceptFrame = Instance.new("Frame")
acceptFrame.Size = UDim2.new(1, 0, 0, 45)
acceptFrame.Position = UDim2.new(0, 0, 0, 10)
acceptFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
acceptFrame.BackgroundTransparency = 0.1
acceptFrame.BorderSizePixel = 1
acceptFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
acceptFrame.Parent = TradeContent

local acceptCorner = Instance.new("UICorner")
acceptCorner.CornerRadius = UDim.new(0, 10)
acceptCorner.Parent = acceptFrame

local acceptLabel = Instance.new("TextLabel")
acceptLabel.Size = UDim2.new(0, 160, 1, 0)
acceptLabel.Position = UDim2.new(0, 14, 0, 0)
acceptLabel.BackgroundTransparency = 1
acceptLabel.Text = "✅ AUTO ACCEPT"
acceptLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
acceptLabel.Font = Enum.Font.FredokaOne
acceptLabel.TextSize = 14
acceptLabel.TextXAlignment = Enum.TextXAlignment.Left
acceptLabel.Parent = acceptFrame

local acceptSwitchBg = Instance.new("Frame")
acceptSwitchBg.Size = UDim2.new(0, 60, 0, 30)
acceptSwitchBg.Position = UDim2.new(1, -72, 0.5, -15)
acceptSwitchBg.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
acceptSwitchBg.BackgroundTransparency = 0.1
acceptSwitchBg.BorderSizePixel = 2
acceptSwitchBg.BorderColor3 = Color3.fromRGB(60, 200, 80)
acceptSwitchBg.Parent = acceptFrame

local acceptSwitchCorner = Instance.new("UICorner")
acceptSwitchCorner.CornerRadius = UDim.new(0, 15)
acceptSwitchCorner.Parent = acceptSwitchBg

local acceptOffLabel = Instance.new("TextLabel")
acceptOffLabel.Size = UDim2.new(0, 22, 1, 0)
acceptOffLabel.Position = UDim2.new(0, 5, 0, 0)
acceptOffLabel.BackgroundTransparency = 1
acceptOffLabel.Text = "OFF"
acceptOffLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
acceptOffLabel.Font = Enum.Font.FredokaOne
acceptOffLabel.TextSize = 10
acceptOffLabel.TextXAlignment = Enum.TextXAlignment.Center
acceptOffLabel.Parent = acceptSwitchBg

local acceptOnLabel = Instance.new("TextLabel")
acceptOnLabel.Size = UDim2.new(0, 22, 1, 0)
acceptOnLabel.Position = UDim2.new(1, -27, 0, 0)
acceptOnLabel.BackgroundTransparency = 1
acceptOnLabel.Text = "ON"
acceptOnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
acceptOnLabel.Font = Enum.Font.FredokaOne
acceptOnLabel.TextSize = 10
acceptOnLabel.TextXAlignment = Enum.TextXAlignment.Center
acceptOnLabel.Parent = acceptSwitchBg

local acceptSwitchBtn = Instance.new("TextButton")
acceptSwitchBtn.Size = UDim2.new(0, 24, 0, 24)
acceptSwitchBtn.Position = UDim2.new(1, -27, 0.5, -12)
acceptSwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
acceptSwitchBtn.BackgroundTransparency = 0.05
acceptSwitchBtn.BorderSizePixel = 2
acceptSwitchBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
acceptSwitchBtn.Text = ""
acceptSwitchBtn.ZIndex = 10
acceptSwitchBtn.Parent = acceptSwitchBg

local acceptSwitchBtnCorner = Instance.new("UICorner")
acceptSwitchBtnCorner.CornerRadius = UDim.new(0, 12)
acceptSwitchBtnCorner.Parent = acceptSwitchBtn

local acceptTradeFrame = Instance.new("Frame")
acceptTradeFrame.Size = UDim2.new(1, 0, 0, 45)
acceptTradeFrame.Position = UDim2.new(0, 0, 0, 60)
acceptTradeFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
acceptTradeFrame.BackgroundTransparency = 0.1
acceptTradeFrame.BorderSizePixel = 1
acceptTradeFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
acceptTradeFrame.Parent = TradeContent

local acceptTradeCorner = Instance.new("UICorner")
acceptTradeCorner.CornerRadius = UDim.new(0, 10)
acceptTradeCorner.Parent = acceptTradeFrame

local acceptTradeLabel = Instance.new("TextLabel")
acceptTradeLabel.Size = UDim2.new(0, 190, 1, 0)
acceptTradeLabel.Position = UDim2.new(0, 14, 0, 0)
acceptTradeLabel.BackgroundTransparency = 1
acceptTradeLabel.Text = "⚡ AUTO ACCEPT TRADE"
acceptTradeLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
acceptTradeLabel.Font = Enum.Font.FredokaOne
acceptTradeLabel.TextSize = 14
acceptTradeLabel.TextXAlignment = Enum.TextXAlignment.Left
acceptTradeLabel.Parent = acceptTradeFrame

local acceptTradeSwitchBg = Instance.new("Frame")
acceptTradeSwitchBg.Size = UDim2.new(0, 60, 0, 30)
acceptTradeSwitchBg.Position = UDim2.new(1, -72, 0.5, -15)
acceptTradeSwitchBg.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
acceptTradeSwitchBg.BackgroundTransparency = 0.1
acceptTradeSwitchBg.BorderSizePixel = 2
acceptTradeSwitchBg.BorderColor3 = Color3.fromRGB(60, 200, 80)
acceptTradeSwitchBg.Parent = acceptTradeFrame

local acceptTradeSwitchCorner = Instance.new("UICorner")
acceptTradeSwitchCorner.CornerRadius = UDim.new(0, 15)
acceptTradeSwitchCorner.Parent = acceptTradeSwitchBg

local acceptTradeOffLabel = Instance.new("TextLabel")
acceptTradeOffLabel.Size = UDim2.new(0, 22, 1, 0)
acceptTradeOffLabel.Position = UDim2.new(0, 5, 0, 0)
acceptTradeOffLabel.BackgroundTransparency = 1
acceptTradeOffLabel.Text = "OFF"
acceptTradeOffLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
acceptTradeOffLabel.Font = Enum.Font.FredokaOne
acceptTradeOffLabel.TextSize = 10
acceptTradeOffLabel.TextXAlignment = Enum.TextXAlignment.Center
acceptTradeOffLabel.Parent = acceptTradeSwitchBg

local acceptTradeOnLabel = Instance.new("TextLabel")
acceptTradeOnLabel.Size = UDim2.new(0, 22, 1, 0)
acceptTradeOnLabel.Position = UDim2.new(1, -27, 0, 0)
acceptTradeOnLabel.BackgroundTransparency = 1
acceptTradeOnLabel.Text = "ON"
acceptTradeOnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
acceptTradeOnLabel.Font = Enum.Font.FredokaOne
acceptTradeOnLabel.TextSize = 10
acceptTradeOnLabel.TextXAlignment = Enum.TextXAlignment.Center
acceptTradeOnLabel.Parent = acceptTradeSwitchBg

local acceptTradeSwitchBtn = Instance.new("TextButton")
acceptTradeSwitchBtn.Size = UDim2.new(0, 24, 0, 24)
acceptTradeSwitchBtn.Position = UDim2.new(1, -27, 0.5, -12)
acceptTradeSwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
acceptTradeSwitchBtn.BackgroundTransparency = 0.05
acceptTradeSwitchBtn.BorderSizePixel = 2
acceptTradeSwitchBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
acceptTradeSwitchBtn.Text = ""
acceptTradeSwitchBtn.ZIndex = 10
acceptTradeSwitchBtn.Parent = acceptTradeSwitchBg

local acceptTradeSwitchBtnCorner = Instance.new("UICorner")
acceptTradeSwitchBtnCorner.CornerRadius = UDim.new(0, 12)
acceptTradeSwitchBtnCorner.Parent = acceptTradeSwitchBtn

local MiscContent = Instance.new("Frame")
MiscContent.Size = UDim2.new(1, 0, 1, 0)
MiscContent.Position = UDim2.new(0, 0, 0, 0)
MiscContent.BackgroundTransparency = 1
MiscContent.Visible = false
MiscContent.Parent = Content

local userFrame = Instance.new("Frame")
userFrame.Size = UDim2.new(1, 0, 0, 55)
userFrame.Position = UDim2.new(0, 0, 0, 5)
userFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
userFrame.BackgroundTransparency = 0.1
userFrame.BorderSizePixel = 1
userFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
userFrame.Parent = MiscContent

local userCorner = Instance.new("UICorner")
userCorner.CornerRadius = UDim.new(0, 10)
userCorner.Parent = userFrame

local userLabel = Instance.new("TextLabel")
userLabel.Size = UDim2.new(1, -10, 0, 16)
userLabel.Position = UDim2.new(0, 10, 0, 4)
userLabel.BackgroundTransparency = 1
userLabel.Text = "👤 CHANGE USERNAME"
userLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
userLabel.Font = Enum.Font.FredokaOne
userLabel.TextSize = 12
userLabel.TextXAlignment = Enum.TextXAlignment.Left
userLabel.Parent = userFrame

local userBox = Instance.new("TextBox")
userBox.Size = UDim2.new(1, -90, 0, 26)
userBox.Position = UDim2.new(0, 10, 0, 23)
userBox.BackgroundColor3 = Color3.fromRGB(15, 13, 30)
userBox.BackgroundTransparency = 0.3
userBox.BorderSizePixel = 2
userBox.BorderColor3 = Color3.fromRGB(255, 200, 50)
userBox.TextColor3 = Color3.fromRGB(255, 255, 255)
userBox.Font = Enum.Font.GothamBold
userBox.TextSize = 13
userBox.Text = player.Name
userBox.PlaceholderText = "Username..."
userBox.TextXAlignment = Enum.TextXAlignment.Left
userBox.ZIndex = 15
userBox.Parent = userFrame

local userBoxCorner = Instance.new("UICorner")
userBoxCorner.CornerRadius = UDim.new(0, 6)
userBoxCorner.Parent = userBox

local userApplyBtn = Instance.new("TextButton")
userApplyBtn.Size = UDim2.new(0, 70, 0, 26)
userApplyBtn.Position = UDim2.new(1, -80, 0, 23)
userApplyBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
userApplyBtn.BackgroundTransparency = 0.2
userApplyBtn.BorderSizePixel = 2
userApplyBtn.BorderColor3 = Color3.fromRGB(60, 200, 80)
userApplyBtn.Text = "APPLY"
userApplyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
userApplyBtn.Font = Enum.Font.GothamBold
userApplyBtn.TextSize = 11
userApplyBtn.ZIndex = 20
userApplyBtn.Parent = userFrame

local userApplyCorner = Instance.new("UICorner")
userApplyCorner.CornerRadius = UDim.new(0, 6)
userApplyCorner.Parent = userApplyBtn

userApplyBtn.MouseEnter:Connect(function()
    userApplyBtn.BackgroundTransparency = 0.05
end)
userApplyBtn.MouseLeave:Connect(function()
    userApplyBtn.BackgroundTransparency = 0.2
end)

userApplyBtn.MouseButton1Click:Connect(function()
    local newName = userBox.Text
    if newName == "" then
        print("❌ Username cannot be empty!")
        return
    end
    
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Head") then
            local head = obj.Head
            local title = head:FindFirstChild("title")
            if title then
                local usernameLabel = title:FindFirstChild("Username")
                if usernameLabel and usernameLabel:IsA("TextLabel") then
                    pcall(function()
                        usernameLabel.Text = newName
                        print("✅ Username changed to: " .. newName .. " for: " .. obj.Name)
                    end)
                end
            end
        end
    end
    
    for _, plr in ipairs(game.Players:GetPlayers()) do
        pcall(function()
            local playerGui = plr:FindFirstChild("PlayerGui")
            if playerGui then
                local uiFolder = playerGui:FindFirstChild("UiFolder")
                if uiFolder then
                    local main = uiFolder:FindFirstChild("Main")
                    if main then
                        local hud = main:FindFirstChild("HUD")
                        if hud then
                            local usernameLabel = hud:FindFirstChild("Username")
                            if usernameLabel and usernameLabel:IsA("TextLabel") then
                                usernameLabel.Text = newName
                                print("✅ HUD Username changed to: " .. newName)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

local antiAFKFrame = Instance.new("Frame")
antiAFKFrame.Size = UDim2.new(1, 0, 0, 45)
antiAFKFrame.Position = UDim2.new(0, 0, 0, 65)
antiAFKFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
antiAFKFrame.BackgroundTransparency = 0.1
antiAFKFrame.BorderSizePixel = 1
antiAFKFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
antiAFKFrame.Parent = MiscContent

local antiAFKCorner = Instance.new("UICorner")
antiAFKCorner.CornerRadius = UDim.new(0, 10)
antiAFKCorner.Parent = antiAFKFrame

local antiAFKLabel = Instance.new("TextLabel")
antiAFKLabel.Size = UDim2.new(0, 160, 1, 0)
antiAFKLabel.Position = UDim2.new(0, 14, 0, 0)
antiAFKLabel.BackgroundTransparency = 1
antiAFKLabel.Text = "🛡️ ANTI AFK"
antiAFKLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
antiAFKLabel.Font = Enum.Font.FredokaOne
antiAFKLabel.TextSize = 14
antiAFKLabel.TextXAlignment = Enum.TextXAlignment.Left
antiAFKLabel.Parent = antiAFKFrame

local antiAFKSwitchBg = Instance.new("Frame")
antiAFKSwitchBg.Size = UDim2.new(0, 60, 0, 30)
antiAFKSwitchBg.Position = UDim2.new(1, -72, 0.5, -15)
antiAFKSwitchBg.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
antiAFKSwitchBg.BackgroundTransparency = 0.1
antiAFKSwitchBg.BorderSizePixel = 2
antiAFKSwitchBg.BorderColor3 = Color3.fromRGB(60, 200, 80)
antiAFKSwitchBg.Parent = antiAFKFrame

local antiAFKSwitchCorner = Instance.new("UICorner")
antiAFKSwitchCorner.CornerRadius = UDim.new(0, 15)
antiAFKSwitchCorner.Parent = antiAFKSwitchBg

local antiAFKOffLabel = Instance.new("TextLabel")
antiAFKOffLabel.Size = UDim2.new(0, 22, 1, 0)
antiAFKOffLabel.Position = UDim2.new(0, 5, 0, 0)
antiAFKOffLabel.BackgroundTransparency = 1
antiAFKOffLabel.Text = "OFF"
antiAFKOffLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
antiAFKOffLabel.Font = Enum.Font.FredokaOne
antiAFKOffLabel.TextSize = 10
antiAFKOffLabel.TextXAlignment = Enum.TextXAlignment.Center
antiAFKOffLabel.Parent = antiAFKSwitchBg

local antiAFKOnLabel = Instance.new("TextLabel")
antiAFKOnLabel.Size = UDim2.new(0, 22, 1, 0)
antiAFKOnLabel.Position = UDim2.new(1, -27, 0, 0)
antiAFKOnLabel.BackgroundTransparency = 1
antiAFKOnLabel.Text = "ON"
antiAFKOnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
antiAFKOnLabel.Font = Enum.Font.FredokaOne
antiAFKOnLabel.TextSize = 10
antiAFKOnLabel.TextXAlignment = Enum.TextXAlignment.Center
antiAFKOnLabel.Parent = antiAFKSwitchBg

local antiAFKSwitchBtn = Instance.new("TextButton")
antiAFKSwitchBtn.Size = UDim2.new(0, 24, 0, 24)
antiAFKSwitchBtn.Position = UDim2.new(1, -27, 0.5, -12)
antiAFKSwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
antiAFKSwitchBtn.BackgroundTransparency = 0.05
antiAFKSwitchBtn.BorderSizePixel = 2
antiAFKSwitchBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
antiAFKSwitchBtn.Text = ""
antiAFKSwitchBtn.ZIndex = 10
antiAFKSwitchBtn.Parent = antiAFKSwitchBg

local antiAFKSwitchBtnCorner = Instance.new("UICorner")
antiAFKSwitchBtnCorner.CornerRadius = UDim.new(0, 12)
antiAFKSwitchBtnCorner.Parent = antiAFKSwitchBtn

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0, 16)
statusLabel.Position = UDim2.new(0, 5, 1, -18)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🟢 SEMUA ON"
statusLabel.TextColor3 = Color3.fromRGB(60, 200, 80)
statusLabel.Font = Enum.Font.FredokaOne
statusLabel.TextSize = 10
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.ZIndex = 5
statusLabel.Parent = Content

local function SetToggleState(switchBtn, isOn, switchBg, offLabel, onLabel)
    if isOn then
        switchBtn.Position = UDim2.new(1, -27, 0.5, -12)
        switchBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
        switchBg.BorderColor3 = Color3.fromRGB(60, 200, 80)
        switchBg.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
        offLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
        onLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        switchBtn.Position = UDim2.new(0, 3, 0.5, -12)
        switchBtn.BorderColor3 = Color3.fromRGB(150, 150, 160)
        switchBg.BorderColor3 = Color3.fromRGB(150, 150, 160)
        switchBg.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
        offLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        onLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    end
end

local function UpdateStatus()
    local count = 0
    if autoCoin then count = count + 1 end
    if autoAccept then count = count + 1 end
    if autoAcceptTrade then count = count + 1 end
    if antiAFK then count = count + 1 end
    
    if count == 4 then
        statusLabel.Text = "🟢 SEMUA ON"
        statusLabel.TextColor3 = Color3.fromRGB(60, 200, 80)
    elseif count == 3 then
        statusLabel.Text = "🟡 3 ON"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    elseif count == 2 then
        statusLabel.Text = "🟡 2 ON"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    elseif count == 1 then
        statusLabel.Text = "🟡 1 ON"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    else
        statusLabel.Text = "🔴 ALL OFF"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end

local function SwitchTab(tab)
    currentTab = tab
    
    TabMain.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
    TabMain.BackgroundTransparency = 0.2
    TabMain.BorderColor3 = Color3.fromRGB(60, 60, 80)
    TabMain.TextColor3 = Color3.fromRGB(200, 200, 210)
    
    TabTrade.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
    TabTrade.BackgroundTransparency = 0.2
    TabTrade.BorderColor3 = Color3.fromRGB(60, 60, 80)
    TabTrade.TextColor3 = Color3.fromRGB(200, 200, 210)
    
    TabMisc.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
    TabMisc.BackgroundTransparency = 0.2
    TabMisc.BorderColor3 = Color3.fromRGB(60, 60, 80)
    TabMisc.TextColor3 = Color3.fromRGB(200, 200, 210)
    
    MainContent.Visible = false
    TradeContent.Visible = false
    MiscContent.Visible = false
    
    if tab == "MAIN" then
        TabMain.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
        TabMain.BackgroundTransparency = 0.2
        TabMain.BorderColor3 = Color3.fromRGB(60, 200, 80)
        TabMain.TextColor3 = Color3.fromRGB(255, 255, 255)
        MainContent.Visible = true
    elseif tab == "TRADE" then
        TabTrade.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
        TabTrade.BackgroundTransparency = 0.2
        TabTrade.BorderColor3 = Color3.fromRGB(60, 200, 80)
        TabTrade.TextColor3 = Color3.fromRGB(255, 255, 255)
        TradeContent.Visible = true
    elseif tab == "MISC" then
        TabMisc.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
        TabMisc.BackgroundTransparency = 0.2
        TabMisc.BorderColor3 = Color3.fromRGB(60, 200, 80)
        TabMisc.TextColor3 = Color3.fromRGB(255, 255, 255)
        MiscContent.Visible = true
    end
end

TabMain.MouseButton1Click:Connect(function()
    SwitchTab("MAIN")
end)

TabTrade.MouseButton1Click:Connect(function()
    SwitchTab("TRADE")
end)

TabMisc.MouseButton1Click:Connect(function()
    SwitchTab("MISC")
end)

coinSwitchBtn.MouseButton1Click:Connect(function()
    autoCoin = not autoCoin
    SetToggleState(coinSwitchBtn, autoCoin, coinSwitchBg, coinOffLabel, coinOnLabel)
    UpdateStatus()
    if autoCoin then
        StartCoinLoop()
        print("🪙 AUTO COIN: ON")
    else
        StopCoinLoop()
        print("🪙 AUTO COIN: OFF")
    end
end)

acceptSwitchBtn.MouseButton1Click:Connect(function()
    autoAccept = not autoAccept
    SetToggleState(acceptSwitchBtn, autoAccept, acceptSwitchBg, acceptOffLabel, acceptOnLabel)
    UpdateStatus()
    if autoAccept then
        StartAcceptLoop()
        print("✅ AUTO ACCEPT: ON")
    else
        StopAcceptLoop()
        print("✅ AUTO ACCEPT: OFF")
    end
end)

acceptTradeSwitchBtn.MouseButton1Click:Connect(function()
    autoAcceptTrade = not autoAcceptTrade
    SetToggleState(acceptTradeSwitchBtn, autoAcceptTrade, acceptTradeSwitchBg, acceptTradeOffLabel, acceptTradeOnLabel)
    UpdateStatus()
    if autoAcceptTrade then
        StartAcceptTradeLoop()
        print("⚡ AUTO ACCEPT TRADE: ON")
    else
        StopAcceptTradeLoop()
        print("⚡ AUTO ACCEPT TRADE: OFF")
    end
end)

antiAFKSwitchBtn.MouseButton1Click:Connect(function()
    antiAFK = not antiAFK
    SetToggleState(antiAFKSwitchBtn, antiAFK, antiAFKSwitchBg, antiAFKOffLabel, antiAFKOnLabel)
    UpdateStatus()
    if antiAFK then
        StartAntiAFK()
        print("🛡️ ANTI AFK: ON")
    else
        StopAntiAFK()
        print("🛡️ ANTI AFK: OFF")
    end
end)

SetToggleState(coinSwitchBtn, true, coinSwitchBg, coinOffLabel, coinOnLabel)
SetToggleState(acceptSwitchBtn, true, acceptSwitchBg, acceptOffLabel, acceptOnLabel)
SetToggleState(acceptTradeSwitchBtn, true, acceptTradeSwitchBg, acceptTradeOffLabel, acceptTradeOnLabel)
SetToggleState(antiAFKSwitchBtn, true, antiAFKSwitchBg, antiAFKOffLabel, antiAFKOnLabel)
UpdateStatus()

local isDragging = false
local dragStartPos = Vector2.new()
local dragStartMousePos = Vector2.new()

local function onInputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = input.Position
        local framePos = Main.AbsolutePosition
        local frameSize = Main.AbsoluteSize
        if mousePos.X >= framePos.X and mousePos.X <= framePos.X + frameSize.X and
           mousePos.Y >= framePos.Y and mousePos.Y <= framePos.Y + frameSize.Y then
            isDragging = true
            dragStartPos = Main.Position
            dragStartMousePos = input.Position
            Main.BackgroundTransparency = 0.3
        end
    end
end

local function onInputChanged(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartMousePos
        Main.Position = UDim2.new(
            dragStartPos.X.Scale,
            dragStartPos.X.Offset + delta.X,
            dragStartPos.Y.Scale,
            dragStartPos.Y.Offset + delta.Y
        )
    end
end

local function onInputEnded(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
        Main.BackgroundTransparency = 0.05
    end
end

UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputChanged:Connect(onInputChanged)
UserInputService.InputEnded:Connect(onInputEnded)

print("✅ ZAIXPLOIT | THROW A COIN + AUTO TRADE + MISC")
print("📌 TAB 1: MAIN - AUTO COIN (ON)")
print("📌 TAB 2: TRADE - AUTO ACCEPT (ON) | AUTO ACCEPT TRADE (ON)")
print("📌 TAB 3: MISC - CHANGE USERNAME | ANTI AFK (ON)")
print("📌 ANTI KICK | HOLD DURATION=0 | TELEPORT")
