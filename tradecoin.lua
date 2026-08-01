-- ============================================
-- ZAIXPLOIT | AUTO TRADE + AUTO ACCEPT (SMART)
-- Toggle 1: Auto Trade (CUSTOM TARGET)
-- Toggle 2: Auto Accept UI (0.1s)
-- Toggle 3: Auto Accept Remote (NUNGGU LAWAN)
-- ============================================

local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

local targetName = "AIDILNV2"
local autoTrade = true
local autoAcceptUI = true
local autoAcceptRemote = true

local tradeLoop = nil
local acceptUILoop = nil
local acceptRemoteLoop = nil

local alreadyAccepted = false

-- ============================================
-- 5. TOGGLE 1: AUTO TRADE
-- ============================================

local function GetTradePrompt()
    if not targetName or targetName == "" then return nil end
    local target = workspace:FindFirstChild(targetName)
    if not target then return nil end
    local hrp = target:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    return hrp:FindFirstChild("TradePrompt")
end

local function FireTrade()
    local tradePrompt = GetTradePrompt()
    if not tradePrompt then return false end
    if not tradePrompt.Enabled then return false end
    
    pcall(function()
        tradePrompt:Prompt()
        task.wait(0.05)
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

local function StartTradeLoop()
    if tradeLoop then return end
    tradeLoop = task.spawn(function()
        while autoTrade do
            FireTrade()
            task.wait(1)
        end
    end)
end

local function StopTradeLoop()
    autoTrade = false
    if tradeLoop then
        task.cancel(tradeLoop)
        tradeLoop = nil
    end
end

StartTradeLoop()

-- ============================================
-- 6. TOGGLE 2: AUTO ACCEPT UI
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
                            print("✅ Auto Accept UI dari User ID: " .. userId)
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
                                            print("✅ Auto Accept UI - Lawan udah accept!")
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

local function StartAcceptUILoop()
    if acceptUILoop then return end
    acceptUILoop = task.spawn(function()
        while autoAcceptUI do
            AutoAcceptUI()
            task.wait(0.1)
        end
    end)
end

local function StopAcceptUILoop()
    autoAcceptUI = false
    if acceptUILoop then
        task.cancel(acceptUILoop)
        acceptUILoop = nil
    end
end

StartAcceptUILoop()

-- ============================================
-- 7. TOGGLE 3: AUTO ACCEPT REMOTE (NUNGGU LAWAN)
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

local function StartAcceptRemoteLoop()
    if acceptRemoteLoop then return end
    acceptRemoteLoop = task.spawn(function()
        while autoAcceptRemote do
            if IsLawanAccept() then
                if not alreadyAccepted then
                    pcall(function()
                        TradeAccept:FireServer()
                        print("⚡ Auto Accept Remote - Lawan udah accept! ✅")
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

local function StopAcceptRemoteLoop()
    autoAcceptRemote = false
    if acceptRemoteLoop then
        task.cancel(acceptRemoteLoop)
        acceptRemoteLoop = nil
    end
end

StartAcceptRemoteLoop()

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
SubTitle.Text = "🔄 AUTO TRADE + SMART ACCEPT"
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
MinBtn.ZIndex = 20
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
CloseBtn.ZIndex = 20
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
    StopAcceptUILoop()
    StopAcceptRemoteLoop()
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
-- INPUT TARGET NAME
-- ============================================

local targetFrame = Instance.new("Frame")
targetFrame.Size = UDim2.new(1, 0, 0, 40)
targetFrame.Position = UDim2.new(0, 0, 0, 2)
targetFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
targetFrame.BackgroundTransparency = 0.1
targetFrame.BorderSizePixel = 1
targetFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
targetFrame.Parent = Content

local targetCorner = Instance.new("UICorner")
targetCorner.CornerRadius = UDim.new(0, 8)
targetCorner.Parent = targetFrame

local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(0, 80, 1, 0)
targetLabel.Position = UDim2.new(0, 10, 0, 0)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "🎯 TARGET:"
targetLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
targetLabel.Font = Enum.Font.FredokaOne
targetLabel.TextSize = 12
targetLabel.TextXAlignment = Enum.TextXAlignment.Left
targetLabel.Parent = targetFrame

local targetBox = Instance.new("TextBox")
targetBox.Size = UDim2.new(0, 200, 0, 28)
targetBox.Position = UDim2.new(0, 85, 0.5, -14)
targetBox.BackgroundColor3 = Color3.fromRGB(15, 13, 30)
targetBox.BackgroundTransparency = 0.3
targetBox.BorderSizePixel = 2
targetBox.BorderColor3 = Color3.fromRGB(60, 200, 80)
targetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
targetBox.Font = Enum.Font.GothamBold
targetBox.TextSize = 14
targetBox.Text = "AIDILNV2"
targetBox.TextXAlignment = Enum.TextXAlignment.Left
targetBox.ZIndex = 15
targetBox.Parent = targetFrame

local targetBoxCorner = Instance.new("UICorner")
targetBoxCorner.CornerRadius = UDim.new(0, 6)
targetBoxCorner.Parent = targetBox

targetBox:GetPropertyChangedSignal("Text"):Connect(function()
    targetName = targetBox.Text
    print("🎯 Target changed to: " .. targetName)
    UpdateStatus()
end)

-- ============================================
-- TOGGLE 1: AUTO TRADE
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
tradeLabel.Size = UDim2.new(0, 160, 1, 0)
tradeLabel.Position = UDim2.new(0, 14, 0, 0)
tradeLabel.BackgroundTransparency = 1
tradeLabel.Text = "🔄 AUTO TRADE"
tradeLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
tradeLabel.Font = Enum.Font.FredokaOne
tradeLabel.TextSize = 13
tradeLabel.TextXAlignment = Enum.TextXAlignment.Left
tradeLabel.ZIndex = 10
tradeLabel.Parent = tradeFrame

local tradeSwitchBg = Instance.new("Frame")
tradeSwitchBg.Size = UDim2.new(0, 60, 0, 28)
tradeSwitchBg.Position = UDim2.new(1, -72, 0.5, -14)
tradeSwitchBg.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
tradeSwitchBg.BackgroundTransparency = 0.1
tradeSwitchBg.BorderSizePixel = 2
tradeSwitchBg.BorderColor3 = Color3.fromRGB(60, 200, 80)
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
tradeOffLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
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
tradeOnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
tradeOnLabel.Font = Enum.Font.FredokaOne
tradeOnLabel.TextSize = 9
tradeOnLabel.TextXAlignment = Enum.TextXAlignment.Center
tradeOnLabel.ZIndex = 10
tradeOnLabel.Parent = tradeSwitchBg

local tradeSwitchBtn = Instance.new("TextButton")
tradeSwitchBtn.Size = UDim2.new(0, 22, 0, 22)
tradeSwitchBtn.Position = UDim2.new(1, -26, 0.5, -11)
tradeSwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
tradeSwitchBtn.BackgroundTransparency = 0.05
tradeSwitchBtn.BorderSizePixel = 2
tradeSwitchBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
tradeSwitchBtn.Text = ""
tradeSwitchBtn.ZIndex = 20  -- TINGGI!
tradeSwitchBtn.Parent = tradeSwitchBg

local tradeSwitchBtnCorner = Instance.new("UICorner")
tradeSwitchBtnCorner.CornerRadius = UDim.new(0, 11)
tradeSwitchBtnCorner.Parent = tradeSwitchBtn

-- ============================================
-- TOGGLE 2: AUTO ACCEPT UI
-- ============================================

local acceptUIFrame = Instance.new("Frame")
acceptUIFrame.Size = UDim2.new(1, 0, 0, 42)
acceptUIFrame.Position = UDim2.new(0, 0, 0, 93)
acceptUIFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
acceptUIFrame.BackgroundTransparency = 0.1
acceptUIFrame.BorderSizePixel = 1
acceptUIFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
acceptUIFrame.ZIndex = 10
acceptUIFrame.Parent = Content

local acceptUICorner = Instance.new("UICorner")
acceptUICorner.CornerRadius = UDim.new(0, 8)
acceptUICorner.Parent = acceptUIFrame

local acceptUILabel = Instance.new("TextLabel")
acceptUILabel.Size = UDim2.new(0, 170, 1, 0)
acceptUILabel.Position = UDim2.new(0, 14, 0, 0)
acceptUILabel.BackgroundTransparency = 1
acceptUILabel.Text = "✅ AUTO ACCEPT UI (0.1s)"
acceptUILabel.TextColor3 = Color3.fromRGB(230, 230, 240)
acceptUILabel.Font = Enum.Font.FredokaOne
acceptUILabel.TextSize = 12
acceptUILabel.TextXAlignment = Enum.TextXAlignment.Left
acceptUILabel.ZIndex = 10
acceptUILabel.Parent = acceptUIFrame

local acceptUISwitchBg = Instance.new("Frame")
acceptUISwitchBg.Size = UDim2.new(0, 60, 0, 28)
acceptUISwitchBg.Position = UDim2.new(1, -72, 0.5, -14)
acceptUISwitchBg.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
acceptUISwitchBg.BackgroundTransparency = 0.1
acceptUISwitchBg.BorderSizePixel = 2
acceptUISwitchBg.BorderColor3 = Color3.fromRGB(60, 200, 80)
acceptUISwitchBg.ZIndex = 10
acceptUISwitchBg.Parent = acceptUIFrame

local acceptUISwitchCorner = Instance.new("UICorner")
acceptUISwitchCorner.CornerRadius = UDim.new(0, 14)
acceptUISwitchCorner.Parent = acceptUISwitchBg

local acceptUIOffLabel = Instance.new("TextLabel")
acceptUIOffLabel.Size = UDim2.new(0, 22, 1, 0)
acceptUIOffLabel.Position = UDim2.new(0, 4, 0, 0)
acceptUIOffLabel.BackgroundTransparency = 1
acceptUIOffLabel.Text = "OFF"
acceptUIOffLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
acceptUIOffLabel.Font = Enum.Font.FredokaOne
acceptUIOffLabel.TextSize = 9
acceptUIOffLabel.TextXAlignment = Enum.TextXAlignment.Center
acceptUIOffLabel.ZIndex = 10
acceptUIOffLabel.Parent = acceptUISwitchBg

local acceptUIOnLabel = Instance.new("TextLabel")
acceptUIOnLabel.Size = UDim2.new(0, 22, 1, 0)
acceptUIOnLabel.Position = UDim2.new(1, -26, 0, 0)
acceptUIOnLabel.BackgroundTransparency = 1
acceptUIOnLabel.Text = "ON"
acceptUIOnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
acceptUIOnLabel.Font = Enum.Font.FredokaOne
acceptUIOnLabel.TextSize = 9
acceptUIOnLabel.TextXAlignment = Enum.TextXAlignment.Center
acceptUIOnLabel.ZIndex = 10
acceptUIOnLabel.Parent = acceptUISwitchBg

local acceptUISwitchBtn = Instance.new("TextButton")
acceptUISwitchBtn.Size = UDim2.new(0, 22, 0, 22)
acceptUISwitchBtn.Position = UDim2.new(1, -26, 0.5, -11)
acceptUISwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
acceptUISwitchBtn.BackgroundTransparency = 0.05
acceptUISwitchBtn.BorderSizePixel = 2
acceptUISwitchBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
acceptUISwitchBtn.Text = ""
acceptUISwitchBtn.ZIndex = 20  -- TINGGI!
acceptUISwitchBtn.Parent = acceptUISwitchBg

local acceptUISwitchBtnCorner = Instance.new("UICorner")
acceptUISwitchBtnCorner.CornerRadius = UDim.new(0, 11)
acceptUISwitchBtnCorner.Parent = acceptUISwitchBtn

-- ============================================
-- TOGGLE 3: AUTO ACCEPT REMOTE
-- ============================================

local acceptRemoteFrame = Instance.new("Frame")
acceptRemoteFrame.Size = UDim2.new(1, 0, 0, 42)
acceptRemoteFrame.Position = UDim2.new(0, 0, 0, 139)
acceptRemoteFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
acceptRemoteFrame.BackgroundTransparency = 0.1
acceptRemoteFrame.BorderSizePixel = 1
acceptRemoteFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
acceptRemoteFrame.ZIndex = 10
acceptRemoteFrame.Parent = Content

local acceptRemoteCorner = Instance.new("UICorner")
acceptRemoteCorner.CornerRadius = UDim.new(0, 8)
acceptRemoteCorner.Parent = acceptRemoteFrame

local acceptRemoteLabel = Instance.new("TextLabel")
acceptRemoteLabel.Size = UDim2.new(0, 210, 1, 0)
acceptRemoteLabel.Position = UDim2.new(0, 14, 0, 0)
acceptRemoteLabel.BackgroundTransparency = 1
acceptRemoteLabel.Text = "🟢 AUTO ACCEPT (NUNGGU LAWAN)"
acceptRemoteLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
acceptRemoteLabel.Font = Enum.Font.FredokaOne
acceptRemoteLabel.TextSize = 12
acceptRemoteLabel.TextXAlignment = Enum.TextXAlignment.Left
acceptRemoteLabel.ZIndex = 10
acceptRemoteLabel.Parent = acceptRemoteFrame

local acceptRemoteSwitchBg = Instance.new("Frame")
acceptRemoteSwitchBg.Size = UDim2.new(0, 60, 0, 28)
acceptRemoteSwitchBg.Position = UDim2.new(1, -72, 0.5, -14)
acceptRemoteSwitchBg.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
acceptRemoteSwitchBg.BackgroundTransparency = 0.1
acceptRemoteSwitchBg.BorderSizePixel = 2
acceptRemoteSwitchBg.BorderColor3 = Color3.fromRGB(60, 200, 80)
acceptRemoteSwitchBg.ZIndex = 10
acceptRemoteSwitchBg.Parent = acceptRemoteFrame

local acceptRemoteSwitchCorner = Instance.new("UICorner")
acceptRemoteSwitchCorner.CornerRadius = UDim.new(0, 14)
acceptRemoteSwitchCorner.Parent = acceptRemoteSwitchBg

local acceptRemoteOffLabel = Instance.new("TextLabel")
acceptRemoteOffLabel.Size = UDim2.new(0, 22, 1, 0)
acceptRemoteOffLabel.Position = UDim2.new(0, 4, 0, 0)
acceptRemoteOffLabel.BackgroundTransparency = 1
acceptRemoteOffLabel.Text = "OFF"
acceptRemoteOffLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
acceptRemoteOffLabel.Font = Enum.Font.FredokaOne
acceptRemoteOffLabel.TextSize = 9
acceptRemoteOffLabel.TextXAlignment = Enum.TextXAlignment.Center
acceptRemoteOffLabel.ZIndex = 10
acceptRemoteOffLabel.Parent = acceptRemoteSwitchBg

local acceptRemoteOnLabel = Instance.new("TextLabel")
acceptRemoteOnLabel.Size = UDim2.new(0, 22, 1, 0)
acceptRemoteOnLabel.Position = UDim2.new(1, -26, 0, 0)
acceptRemoteOnLabel.BackgroundTransparency = 1
acceptRemoteOnLabel.Text = "ON"
acceptRemoteOnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
acceptRemoteOnLabel.Font = Enum.Font.FredokaOne
acceptRemoteOnLabel.TextSize = 9
acceptRemoteOnLabel.TextXAlignment = Enum.TextXAlignment.Center
acceptRemoteOnLabel.ZIndex = 10
acceptRemoteOnLabel.Parent = acceptRemoteSwitchBg

local acceptRemoteSwitchBtn = Instance.new("TextButton")
acceptRemoteSwitchBtn.Size = UDim2.new(0, 22, 0, 22)
acceptRemoteSwitchBtn.Position = UDim2.new(1, -26, 0.5, -11)
acceptRemoteSwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
acceptRemoteSwitchBtn.BackgroundTransparency = 0.05
acceptRemoteSwitchBtn.BorderSizePixel = 2
acceptRemoteSwitchBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
acceptRemoteSwitchBtn.Text = ""
acceptRemoteSwitchBtn.ZIndex = 20  -- TINGGI!
acceptRemoteSwitchBtn.Parent = acceptRemoteSwitchBg

local acceptRemoteSwitchBtnCorner = Instance.new("UICorner")
acceptRemoteSwitchBtnCorner.CornerRadius = UDim.new(0, 11)
acceptRemoteSwitchBtnCorner.Parent = acceptRemoteSwitchBtn

-- ============================================
-- STATUS LABEL
-- ============================================

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 18)
statusLabel.Position = UDim2.new(0, 0, 1, -2)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🟢 SEMUA ON | Target: AIDILNV2"
statusLabel.TextColor3 = Color3.fromRGB(60, 200, 80)
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
    if autoAcceptUI then count = count + 1 end
    if autoAcceptRemote then count = count + 1 end
    
    local statusText = "🎯 " .. targetName .. " | "
    if count == 3 then
        statusLabel.Text = statusText .. "🟢 SEMUA ON"
        statusLabel.TextColor3 = Color3.fromRGB(60, 200, 80)
    elseif count > 0 then
        statusLabel.Text = statusText .. "🟡 " .. count .. " ON"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    else
        statusLabel.Text = statusText .. "🔴 ALL OFF"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end

-- ============================================
-- KLIK TOGGLE (ZIndex tinggi biar bisa diklik)
-- ============================================

-- Toggle 1: AUTO TRADE
local function ToggleTrade()
    autoTrade = not autoTrade
    SetToggleState(tradeSwitchBtn, autoTrade, tradeSwitchBg, tradeOffLabel, tradeOnLabel)
    UpdateStatus()
    if autoTrade then
        StartTradeLoop()
        print("🔄 AUTO TRADE ON → Target: " .. targetName)
    else
        StopTradeLoop()
        print("🔴 AUTO TRADE OFF")
    end
end

tradeSwitchBtn.MouseButton1Click:Connect(ToggleTrade)
tradeFrame.MouseButton1Click:Connect(ToggleTrade)

-- Toggle 2: AUTO ACCEPT UI
local function ToggleAcceptUI()
    autoAcceptUI = not autoAcceptUI
    SetToggleState(acceptUISwitchBtn, autoAcceptUI, acceptUISwitchBg, acceptUIOffLabel, acceptUIOnLabel)
    UpdateStatus()
    if autoAcceptUI then
        StartAcceptUILoop()
        print("✅ AUTO ACCEPT UI ON")
    else
        StopAcceptUILoop()
        print("🔴 AUTO ACCEPT UI OFF")
    end
end

acceptUISwitchBtn.MouseButton1Click:Connect(ToggleAcceptUI)
acceptUIFrame.MouseButton1Click:Connect(ToggleAcceptUI)

-- Toggle 3: AUTO ACCEPT REMOTE
local function ToggleAcceptRemote()
    autoAcceptRemote = not autoAcceptRemote
    SetToggleState(acceptRemoteSwitchBtn, autoAcceptRemote, acceptRemoteSwitchBg, acceptRemoteOffLabel, acceptRemoteOnLabel)
    UpdateStatus()
    if autoAcceptRemote then
        StartAcceptRemoteLoop()
        print("🟢 AUTO ACCEPT REMOTE ON (NUNGGU LAWAN)")
    else
        StopAcceptRemoteLoop()
        print("🔴 AUTO ACCEPT REMOTE OFF")
    end
end

acceptRemoteSwitchBtn.MouseButton1Click:Connect(ToggleAcceptRemote)
acceptRemoteFrame.MouseButton1Click:Connect(ToggleAcceptRemote)

-- ============================================
-- SET INITIAL STATE
-- ============================================

SetToggleState(tradeSwitchBtn, true, tradeSwitchBg, tradeOffLabel, tradeOnLabel)
SetToggleState(acceptUISwitchBtn, true, acceptUISwitchBg, acceptUIOffLabel, acceptUIOnLabel)
SetToggleState(acceptRemoteSwitchBtn, true, acceptRemoteSwitchBg, acceptRemoteOffLabel, acceptRemoteOnLabel)
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
print("✅ ZAIXPLOIT | SMART AUTO TRADE + ACCEPT")
print("📌 TARGET: " .. targetName .. " (BISA DIGANTI)")
print("📌 AUTO TRADE: ON (1s)")
print("📌 AUTO ACCEPT UI: ON (0.1s)")
print("📌 AUTO ACCEPT REMOTE: ON (NUNGGU LAWAN) ⏳")
print("═══════════════════════════════════════════")