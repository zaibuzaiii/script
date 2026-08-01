-- ============================================
-- ZAIXPLOIT | AUTO TRADE
-- Toggle 1: AUTO TRADE (FOLLOW + TRADE) - DEFAULT OFF
-- Toggle 2: AUTO ACCEPT - DEFAULT ON
-- Toggle 3: AUTO ACCEPT TRADE - DEFAULT ON
-- ============================================

local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- ============================================
-- 1. ANTI AFK
-- ============================================

task.spawn(function()
    while true do
        task.wait(45)
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            VirtualUser:ClickButton1(Vector2.new())
        end)
    end
end)

-- ============================================
-- 2. MATIKAN ANTI KICK
-- ============================================

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
    local events = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events")
    local remotes = {"AntiKickReconnect", "SetAFKSafe", "StartAFKSafe"}
    for _, name in ipairs(remotes) do
        local remote = events:FindFirstChild(name)
        if remote then remote:Destroy() end
    end
end)

-- ============================================
-- 3. REMOTE
-- ============================================

local TradeRequestResponse = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("TradeRequestResponse")
local TradeAccept = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("TradeAccept")

-- ============================================
-- 4. VARIABEL
-- ============================================

local targetName = "username"
local autoTrade = false
local autoAccept = true
local autoAcceptTrade = true

local tradeLoop = nil
local acceptLoop = nil
local acceptTradeLoop = nil
local followConnection = nil

local alreadyAccepted = false

-- ============================================
-- 5. TOGGLE 1: AUTO TRADE (FOLLOW + TRADE)
-- ============================================

local function FollowTarget()
    if not targetName or targetName == "" or targetName == "username" then return end
    
    local target = workspace:FindFirstChild(targetName)
    if not target then
        print("❌ Target not found: " .. targetName)
        return
    end
    
    local targetHrp = target:FindFirstChild("HumanoidRootPart")
    if not targetHrp then return end
    
    local character = player.Character
    if not character or not character.Parent then
        character = player.CharacterAdded:Wait()
        task.wait(1)
    end
    
    local playerHrp = character:FindFirstChild("HumanoidRootPart")
    if not playerHrp then return end
    
    local targetPos = targetHrp.Position
    local followPos = targetPos + Vector3.new(0, 0, 5)
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(playerHrp, tweenInfo, {CFrame = CFrame.new(followPos)})
    tween:Play()
end

local function FireTrade()
    if not targetName or targetName == "" or targetName == "username" then return false end
    
    local target = workspace:FindFirstChild(targetName)
    if not target then
        print("❌ Target not found: " .. targetName)
        return false
    end
    
    local hrp = target:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local tradePrompt = hrp:FindFirstChild("TradePrompt")
    if not tradePrompt then
        print("❌ TradePrompt not found on: " .. targetName)
        return false
    end
    
    if not tradePrompt.Enabled then
        print("⚠️ TradePrompt disabled")
        return false
    end
    
    pcall(function()
        tradePrompt:Prompt()
        task.wait(0.1)
        VirtualUser:Button1Down(Vector2.new())
        task.wait(0.05)
        VirtualUser:Button1Up(Vector2.new())
        VirtualUser:Button2Down(Vector2.new())
        task.wait(0.05)
        VirtualUser:Button2Up(Vector2.new())
        print("✅ Trade Prompt fired to: " .. targetName)
    end)
    
    return true
end

local function StartFollowLoop()
    if followConnection then return end
    followConnection = RunService.Heartbeat:Connect(function()
        if not autoTrade then return end
        if not targetName or targetName == "" or targetName == "username" then return end
        
        local target = workspace:FindFirstChild(targetName)
        if not target then return end
        
        local targetHrp = target:FindFirstChild("HumanoidRootPart")
        if not targetHrp then return end
        
        local character = player.Character
        if not character or not character.Parent then return end
        
        local playerHrp = character:FindFirstChild("HumanoidRootPart")
        if not playerHrp then return end
        
        local distance = (playerHrp.Position - targetHrp.Position).Magnitude
        if distance > 8 then
            local targetPos = targetHrp.Position
            local followPos = targetPos + Vector3.new(0, 0, 5)
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(playerHrp, tweenInfo, {CFrame = CFrame.new(followPos)})
            tween:Play()
        end
    end)
end

local function StartTradeLoop()
    if tradeLoop then return end
    tradeLoop = task.spawn(function()
        while autoTrade do
            FollowTarget()
            task.wait(0.5)
            FireTrade()
            task.wait(1.5)
        end
    end)
end

local function StopTradeLoop()
    autoTrade = false
    if tradeLoop then
        task.cancel(tradeLoop)
        tradeLoop = nil
    end
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
end

-- ============================================
-- 6. TOGGLE 2: AUTO ACCEPT (DEFAULT ON)
-- ============================================

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

-- ============================================
-- 7. TOGGLE 3: AUTO ACCEPT TRADE (DEFAULT ON)
-- ============================================

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

-- ============================================
-- 8. GUI
-- ============================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZAIXPLOIT"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 360, 0, 280)
Main.Position = UDim2.new(0.5, -180, 0.5, -140)
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
Title.Text = "⭐ ZAIXPLOIT | AUTO TRADE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.LuckiestGuy
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -60, 0, 14)
SubTitle.Position = UDim2.new(0, 12, 0, 23)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "🪙 THROW A COIN"
SubTitle.TextColor3 = Color3.fromRGB(255, 200, 50)
SubTitle.Font = Enum.Font.FredokaOne
SubTitle.TextSize = 11
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
    StopTradeLoop()
    StopAcceptLoop()
    StopAcceptTradeLoop()
    screenGui:Destroy()
end)

-- ============================================
-- CONTENT
-- ============================================

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -14, 0, 220)
Content.Position = UDim2.new(0, 7, 0, 48)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- ============================================
-- INPUT USERNAME
-- ============================================

local userFrame = Instance.new("Frame")
userFrame.Size = UDim2.new(1, 0, 0, 40)
userFrame.Position = UDim2.new(0, 0, 0, 2)
userFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
userFrame.BackgroundTransparency = 0.1
userFrame.BorderSizePixel = 1
userFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
userFrame.Parent = Content

local userCorner = Instance.new("UICorner")
userCorner.CornerRadius = UDim.new(0, 8)
userCorner.Parent = userFrame

local userLabel = Instance.new("TextLabel")
userLabel.Size = UDim2.new(0, 90, 1, 0)
userLabel.Position = UDim2.new(0, 10, 0, 0)
userLabel.BackgroundTransparency = 1
userLabel.Text = "👤 USERNAME:"
userLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
userLabel.Font = Enum.Font.FredokaOne
userLabel.TextSize = 12
userLabel.TextXAlignment = Enum.TextXAlignment.Left
userLabel.Parent = userFrame

local userBox = Instance.new("TextBox")
userBox.Size = UDim2.new(0, 190, 0, 28)
userBox.Position = UDim2.new(0, 95, 0.5, -14)
userBox.BackgroundColor3 = Color3.fromRGB(15, 13, 30)
userBox.BackgroundTransparency = 0.3
userBox.BorderSizePixel = 2
userBox.BorderColor3 = Color3.fromRGB(60, 200, 80)
userBox.TextColor3 = Color3.fromRGB(255, 255, 255)
userBox.Font = Enum.Font.GothamBold
userBox.TextSize = 14
userBox.Text = "username"
userBox.TextXAlignment = Enum.TextXAlignment.Left
userBox.ZIndex = 15
userBox.Parent = userFrame

local userBoxCorner = Instance.new("UICorner")
userBoxCorner.CornerRadius = UDim.new(0, 6)
userBoxCorner.Parent = userBox

userBox:GetPropertyChangedSignal("Text"):Connect(function()
    targetName = userBox.Text
    print("👤 Username changed to: " .. targetName)
    UpdateStatus()
end)

-- ============================================
-- TOGGLE 1: AUTO TRADE (DEFAULT OFF)
-- ============================================

local tradeFrame = Instance.new("Frame")
tradeFrame.Size = UDim2.new(1, 0, 0, 42)
tradeFrame.Position = UDim2.new(0, 0, 0, 47)
tradeFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
tradeFrame.BackgroundTransparency = 0.1
tradeFrame.BorderSizePixel = 1
tradeFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
tradeFrame.ZIndex = 10
tradeFrame.Parent = Content

local tradeCorner = Instance.new("UICorner")
tradeCorner.CornerRadius = UDim.new(0, 8)
tradeCorner.Parent = tradeFrame

local tradeLabel = Instance.new("TextLabel")
tradeLabel.Size = UDim2.new(0, 200, 1, 0)
tradeLabel.Position = UDim2.new(0, 14, 0, 0)
tradeLabel.BackgroundTransparency = 1
tradeLabel.Text = "🔄 AUTO TRADE (FOLLOW)"
tradeLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
tradeLabel.Font = Enum.Font.FredokaOne
tradeLabel.TextSize = 12
tradeLabel.TextXAlignment = Enum.TextXAlignment.Left
tradeLabel.ZIndex = 10
tradeLabel.Parent = tradeFrame

local tradeSwitchBg = Instance.new("Frame")
tradeSwitchBg.Size = UDim2.new(0, 60, 0, 28)
tradeSwitchBg.Position = UDim2.new(1, -72, 0.5, -14)
tradeSwitchBg.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
tradeSwitchBg.BackgroundTransparency = 0.1
tradeSwitchBg.BorderSizePixel = 2
tradeSwitchBg.BorderColor3 = Color3.fromRGB(150, 150, 160)
tradeSwitchBg.ZIndex = 10
tradeSwitchBg.Parent = tradeFrame

local tradeSwitchCorner = Instance.new("UICorner")
tradeSwitchCorner.CornerRadius = UDim.new(0, 14)
tradeSwitchCorner.Parent = tradeSwitchBg

local tradeOffLabel = Instance.new("TextLabel")
tradeOffLabel.Size = UDim2.new(0, 22, 1, 0)
tradeOffLabel.Position = UDim2.new(0, 4, 0, 0)
tradeOffLabel.BackgroundTransparency = 1
tradeOffLabel.Text = "OFF"
tradeOffLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
tradeOffLabel.Font = Enum.Font.FredokaOne
tradeOffLabel.TextSize = 9
tradeOffLabel.TextXAlignment = Enum.TextXAlignment.Center
tradeOffLabel.ZIndex = 10
tradeOffLabel.Parent = tradeSwitchBg

local tradeOnLabel = Instance.new("TextLabel")
tradeOnLabel.Size = UDim2.new(0, 22, 1, 0)
tradeOnLabel.Position = UDim2.new(1, -26, 0, 0)
tradeOnLabel.BackgroundTransparency = 1
tradeOnLabel.Text = "ON"
tradeOnLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
tradeOnLabel.Font = Enum.Font.FredokaOne
tradeOnLabel.TextSize = 9
tradeOnLabel.TextXAlignment = Enum.TextXAlignment.Center
tradeOnLabel.ZIndex = 10
tradeOnLabel.Parent = tradeSwitchBg

local tradeSwitchBtn = Instance.new("TextButton")
tradeSwitchBtn.Size = UDim2.new(0, 22, 0, 22)
tradeSwitchBtn.Position = UDim2.new(0, 4, 0.5, -11)
tradeSwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
tradeSwitchBtn.BackgroundTransparency = 0.05
tradeSwitchBtn.BorderSizePixel = 2
tradeSwitchBtn.BorderColor3 = Color3.fromRGB(150, 150, 160)
tradeSwitchBtn.Text = ""
tradeSwitchBtn.ZIndex = 50
tradeSwitchBtn.Parent = tradeSwitchBg

local tradeSwitchBtnCorner = Instance.new("UICorner")
tradeSwitchBtnCorner.CornerRadius = UDim.new(0, 11)
tradeSwitchBtnCorner.Parent = tradeSwitchBtn

-- ============================================
-- TOGGLE 2: AUTO ACCEPT (DEFAULT ON) - DIPERBAIKI
-- ============================================

local acceptFrame = Instance.new("Frame")
acceptFrame.Size = UDim2.new(1, 0, 0, 42)
acceptFrame.Position = UDim2.new(0, 0, 0, 93)
acceptFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
acceptFrame.BackgroundTransparency = 0.1
acceptFrame.BorderSizePixel = 1
acceptFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
acceptFrame.ZIndex = 10
acceptFrame.Parent = Content

local acceptCorner = Instance.new("UICorner")
acceptCorner.CornerRadius = UDim.new(0, 8)
acceptCorner.Parent = acceptFrame

local acceptLabel = Instance.new("TextLabel")
acceptLabel.Size = UDim2.new(0, 160, 1, 0)
acceptLabel.Position = UDim2.new(0, 14, 0, 0)
acceptLabel.BackgroundTransparency = 1
acceptLabel.Text = "✅ AUTO ACCEPT TRADE"
acceptLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
acceptLabel.Font = Enum.Font.FredokaOne
acceptLabel.TextSize = 12
acceptLabel.TextXAlignment = Enum.TextXAlignment.Left
acceptLabel.ZIndex = 10
acceptLabel.Parent = acceptFrame

local acceptSwitchBg = Instance.new("Frame")
acceptSwitchBg.Size = UDim2.new(0, 60, 0, 28)
acceptSwitchBg.Position = UDim2.new(1, -72, 0.5, -14)
acceptSwitchBg.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
acceptSwitchBg.BackgroundTransparency = 0.1
acceptSwitchBg.BorderSizePixel = 2
acceptSwitchBg.BorderColor3 = Color3.fromRGB(60, 200, 80)
acceptSwitchBg.ZIndex = 10
acceptSwitchBg.Parent = acceptFrame

local acceptSwitchCorner = Instance.new("UICorner")
acceptSwitchCorner.CornerRadius = UDim.new(0, 14)
acceptSwitchCorner.Parent = acceptSwitchBg

local acceptOffLabel = Instance.new("TextLabel")
acceptOffLabel.Size = UDim2.new(0, 22, 1, 0)
acceptOffLabel.Position = UDim2.new(0, 4, 0, 0)
acceptOffLabel.BackgroundTransparency = 1
acceptOffLabel.Text = "OFF"
acceptOffLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
acceptOffLabel.Font = Enum.Font.FredokaOne
acceptOffLabel.TextSize = 9
acceptOffLabel.TextXAlignment = Enum.TextXAlignment.Center
acceptOffLabel.ZIndex = 10
acceptOffLabel.Parent = acceptSwitchBg

local acceptOnLabel = Instance.new("TextLabel")
acceptOnLabel.Size = UDim2.new(0, 22, 1, 0)
acceptOnLabel.Position = UDim2.new(1, -26, 0, 0)
acceptOnLabel.BackgroundTransparency = 1
acceptOnLabel.Text = "ON"
acceptOnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
acceptOnLabel.Font = Enum.Font.FredokaOne
acceptOnLabel.TextSize = 9
acceptOnLabel.TextXAlignment = Enum.TextXAlignment.Center
acceptOnLabel.ZIndex = 10
acceptOnLabel.Parent = acceptSwitchBg

local acceptSwitchBtn = Instance.new("TextButton")
acceptSwitchBtn.Size = UDim2.new(0, 22, 0, 22)
acceptSwitchBtn.Position = UDim2.new(1, -26, 0.5, -11)
acceptSwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
acceptSwitchBtn.BackgroundTransparency = 0.05
acceptSwitchBtn.BorderSizePixel = 2
acceptSwitchBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
acceptSwitchBtn.Text = ""
acceptSwitchBtn.ZIndex = 50
acceptSwitchBtn.Parent = acceptSwitchBg

local acceptSwitchBtnCorner = Instance.new("UICorner")
acceptSwitchBtnCorner.CornerRadius = UDim.new(0, 11)
acceptSwitchBtnCorner.Parent = acceptSwitchBtn

-- ============================================
-- TOGGLE 3: AUTO ACCEPT TRADE (DEFAULT ON) - DIPERBAIKI
-- ============================================

local acceptTradeFrame = Instance.new("Frame")
acceptTradeFrame.Size = UDim2.new(1, 0, 0, 42)
acceptTradeFrame.Position = UDim2.new(0, 0, 0, 139)
acceptTradeFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
acceptTradeFrame.BackgroundTransparency = 0.1
acceptTradeFrame.BorderSizePixel = 1
acceptTradeFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
acceptTradeFrame.ZIndex = 10
acceptTradeFrame.Parent = Content

local acceptTradeCorner = Instance.new("UICorner")
acceptTradeCorner.CornerRadius = UDim.new(0, 8)
acceptTradeCorner.Parent = acceptTradeFrame

local acceptTradeLabel = Instance.new("TextLabel")
acceptTradeLabel.Size = UDim2.new(0, 190, 1, 0)
acceptTradeLabel.Position = UDim2.new(0, 14, 0, 0)
acceptTradeLabel.BackgroundTransparency = 1
acceptTradeLabel.Text = "✅ AUTO ACCEPT"
acceptTradeLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
acceptTradeLabel.Font = Enum.Font.FredokaOne
acceptTradeLabel.TextSize = 12
acceptTradeLabel.TextXAlignment = Enum.TextXAlignment.Left
acceptTradeLabel.ZIndex = 10
acceptTradeLabel.Parent = acceptTradeFrame

local acceptTradeSwitchBg = Instance.new("Frame")
acceptTradeSwitchBg.Size = UDim2.new(0, 60, 0, 28)
acceptTradeSwitchBg.Position = UDim2.new(1, -72, 0.5, -14)
acceptTradeSwitchBg.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
acceptTradeSwitchBg.BackgroundTransparency = 0.1
acceptTradeSwitchBg.BorderSizePixel = 2
acceptTradeSwitchBg.BorderColor3 = Color3.fromRGB(60, 200, 80)
acceptTradeSwitchBg.ZIndex = 10
acceptTradeSwitchBg.Parent = acceptTradeFrame

local acceptTradeSwitchCorner = Instance.new("UICorner")
acceptTradeSwitchCorner.CornerRadius = UDim.new(0, 14)
acceptTradeSwitchCorner.Parent = acceptTradeSwitchBg

local acceptTradeOffLabel = Instance.new("TextLabel")
acceptTradeOffLabel.Size = UDim2.new(0, 22, 1, 0)
acceptTradeOffLabel.Position = UDim2.new(0, 4, 0, 0)
acceptTradeOffLabel.BackgroundTransparency = 1
acceptTradeOffLabel.Text = "OFF"
acceptTradeOffLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
acceptTradeOffLabel.Font = Enum.Font.FredokaOne
acceptTradeOffLabel.TextSize = 9
acceptTradeOffLabel.TextXAlignment = Enum.TextXAlignment.Center
acceptTradeOffLabel.ZIndex = 10
acceptTradeOffLabel.Parent = acceptTradeSwitchBg

local acceptTradeOnLabel = Instance.new("TextLabel")
acceptTradeOnLabel.Size = UDim2.new(0, 22, 1, 0)
acceptTradeOnLabel.Position = UDim2.new(1, -26, 0, 0)
acceptTradeOnLabel.BackgroundTransparency = 1
acceptTradeOnLabel.Text = "ON"
acceptTradeOnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
acceptTradeOnLabel.Font = Enum.Font.FredokaOne
acceptTradeOnLabel.TextSize = 9
acceptTradeOnLabel.TextXAlignment = Enum.TextXAlignment.Center
acceptTradeOnLabel.ZIndex = 10
acceptTradeOnLabel.Parent = acceptTradeSwitchBg

local acceptTradeSwitchBtn = Instance.new("TextButton")
acceptTradeSwitchBtn.Size = UDim2.new(0, 22, 0, 22)
acceptTradeSwitchBtn.Position = UDim2.new(1, -26, 0.5, -11)
acceptTradeSwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
acceptTradeSwitchBtn.BackgroundTransparency = 0.05
acceptTradeSwitchBtn.BorderSizePixel = 2
acceptTradeSwitchBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
acceptTradeSwitchBtn.Text = ""
acceptTradeSwitchBtn.ZIndex = 50
acceptTradeSwitchBtn.Parent = acceptTradeSwitchBg

local acceptTradeSwitchBtnCorner = Instance.new("UICorner")
acceptTradeSwitchBtnCorner.CornerRadius = UDim.new(0, 11)
acceptTradeSwitchBtnCorner.Parent = acceptTradeSwitchBtn

-- ============================================
-- STATUS LABEL
-- ============================================

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 18)
statusLabel.Position = UDim2.new(0, 0, 1, -2)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🟡 2 ON | USERNAME: username"
statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
statusLabel.Font = Enum.Font.FredokaOne
statusLabel.TextSize = 10
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.ZIndex = 5
statusLabel.Parent = Content

-- ============================================
-- TOGGLE FUNCTIONS
-- ============================================

local function SmoothMove(object, targetPos, duration)
    local tween = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos})
    tween:Play()
end

local function SetToggleState(switchBtn, isOn, switchBg, offLabel, onLabel)
    if isOn then
        switchBg.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
        switchBg.BorderColor3 = Color3.fromRGB(60, 200, 80)
        SmoothMove(switchBtn, UDim2.new(1, -26, 0.5, -11), 0.3)
        offLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
        onLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        switchBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        switchBg.BorderColor3 = Color3.fromRGB(80, 80, 100)
        SmoothMove(switchBtn, UDim2.new(0, 4, 0.5, -11), 0.3)
        offLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        onLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    end
end

local function UpdateStatus()
    local count = 0
    if autoTrade then count = count + 1 end
    if autoAccept then count = count + 1 end
    if autoAcceptTrade then count = count + 1 end
    
    local displayName = targetName
    if displayName == "" or displayName == "username" then
        displayName = "username"
    end
    
    local statusText = "USERNAME: " .. displayName .. " | "
    if count == 3 then
        statusLabel.Text = statusText .. "🟢 SEMUA ON"
        statusLabel.TextColor3 = Color3.fromRGB(60, 200, 80)
    elseif count == 2 then
        statusLabel.Text = statusText .. "🟡 2 ON"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    elseif count == 1 then
        statusLabel.Text = statusText .. "🟡 1 ON"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    else
        statusLabel.Text = statusText .. "🔴 ALL OFF"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end

-- ============================================
-- KLIK TOGGLE (PAKAI MOUSEBUTTON1CLICK)
-- ============================================

-- Toggle 1: AUTO TRADE
local function ToggleTrade()
    autoTrade = not autoTrade
    SetToggleState(tradeSwitchBtn, autoTrade, tradeSwitchBg, tradeOffLabel, tradeOnLabel)
    UpdateStatus()
    if autoTrade then
        StartTradeLoop()
        StartFollowLoop()
        print("🔄 AUTO TRADE ON → USERNAME: " .. targetName)
    else
        StopTradeLoop()
        print("🔴 AUTO TRADE OFF")
    end
end

tradeSwitchBtn.MouseButton1Click:Connect(ToggleTrade)
tradeFrame.MouseButton1Click:Connect(ToggleTrade)

-- Toggle 2: AUTO ACCEPT
local function ToggleAccept()
    autoAccept = not autoAccept
    SetToggleState(acceptSwitchBtn, autoAccept, acceptSwitchBg, acceptOffLabel, acceptOnLabel)
    UpdateStatus()
    if autoAccept then
        StartAcceptLoop()
        print("✅ AUTO ACCEPT ON")
    else
        StopAcceptLoop()
        print("🔴 AUTO ACCEPT OFF")
    end
end

acceptSwitchBtn.MouseButton1Click:Connect(ToggleAccept)
acceptFrame.MouseButton1Click:Connect(ToggleAccept)

-- Toggle 3: AUTO ACCEPT TRADE
local function ToggleAcceptTrade()
    autoAcceptTrade = not autoAcceptTrade
    SetToggleState(acceptTradeSwitchBtn, autoAcceptTrade, acceptTradeSwitchBg, acceptTradeOffLabel, acceptTradeOnLabel)
    UpdateStatus()
    if autoAcceptTrade then
        StartAcceptTradeLoop()
        print("✅ AUTO ACCEPT TRADE ON")
    else
        StopAcceptTradeLoop()
        print("🔴 AUTO ACCEPT TRADE OFF")
    end
end

acceptTradeSwitchBtn.MouseButton1Click:Connect(ToggleAcceptTrade)
acceptTradeFrame.MouseButton1Click:Connect(ToggleAcceptTrade)

-- ============================================
-- SET INITIAL STATE
-- ============================================

SetToggleState(tradeSwitchBtn, false, tradeSwitchBg, tradeOffLabel, tradeOnLabel)
SetToggleState(acceptSwitchBtn, true, acceptSwitchBg, acceptOffLabel, acceptOnLabel)
SetToggleState(acceptTradeSwitchBtn, true, acceptTradeSwitchBg, acceptTradeOffLabel, acceptTradeOnLabel)
UpdateStatus()

-- ============================================
-- DRAG
-- ============================================

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
            Main.BackgroundTransparency = 0.35
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

print("═══════════════════════════════════════════")
print("✅ ZAIXPLOIT | AUTO TRADE")
print("📌 USERNAME: " .. targetName)
print("📌 AUTO TRADE: OFF (Nyalakan manual)")
print("📌 AUTO ACCEPT: ON")
print("📌 AUTO ACCEPT TRADE: ON")
print("═══════════════════════════════════════════")