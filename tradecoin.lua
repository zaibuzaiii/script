-- ============================================
-- ZAIXPLOIT | AUTO TRADE + AUTO ACCEPT
-- Auto Trade ke AIDILNV2 + Auto Accept (Remote + UI)
-- ============================================

local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

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
    local events = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Events")
    local remotes = {"AntiKickReconnect", "SetAFKSafe", "StartAFKSafe"}
    for _, name in ipairs(remotes) do
        local remote = events:FindFirstChild(name)
        if remote then remote:Destroy() end
    end
end)

-- ============================================
-- 3. REMOTE
-- ============================================

local TradeRequestResponse = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("TradeRequestResponse")
local TradeAccept = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("TradeAccept")

-- ============================================
-- 4. AUTO TRADE KE AIDILNV2 (ON/OFF)
-- ============================================

local autoTrade = true
local tradeLoop = nil

local function GetTradePrompt()
    local aidil = workspace:FindFirstChild("AIDILNV2")
    if not aidil then return nil end
    local hrp = aidil:FindFirstChild("HumanoidRootPart")
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
        print("✅ Trade Prompt fired!")
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
-- 5. AUTO ACCEPT TRADE (REMOTE + UI)
-- ============================================

local autoAccept = true
local acceptLoop = nil

local function AutoAccept()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    local uiFolder = playerGui:FindFirstChild("UiFolder")
    if not uiFolder then return end
    
    local main = uiFolder:FindFirstChild("Main")
    if not main then return end
    
    -- CEK TRADE REQUEST (POPUP)
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
                            print("✅ Auto Accept Trade Request dari User ID: " .. userId)
                        end)
                        child:Destroy()
                    end
                end
            end
        end
    end
    
    -- CEK TRADE UI (UDH DI DALEM TRADE)
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
                        pcall(function()
                            acceptBtn:FireClick()
                            print("✅ Auto Accept Trade (UI Click)!")
                        end)
                    end
                    pcall(function()
                        TradeAccept:FireServer()
                        print("✅ Auto Accept Trade (Remote)!")
                    end)
                end
            end
        end
    end
end

local function StartAcceptLoop()
    if acceptLoop then return end
    acceptLoop = task.spawn(function()
        while autoAccept do
            AutoAccept()
            task.wait(0.3)
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
-- 6. GUI
-- ============================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZAIXPLOIT"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 340, 0, 180)
Main.Position = UDim2.new(0.5, -170, 0.5, -90)
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
SubTitle.Text = "🔄 AUTO TRADE + ACCEPT"
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
        Main.Size = UDim2.new(0, 340, 0, 42)
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
    screenGui:Destroy()
end)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -14, 0, 120)
Content.Position = UDim2.new(0, 7, 0, 48)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- ===== TOGGLE 1: AUTO TRADE =====
local tradeFrame = Instance.new("Frame")
tradeFrame.Size = UDim2.new(1, 0, 0, 45)
tradeFrame.Position = UDim2.new(0, 0, 0, 5)
tradeFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
tradeFrame.BackgroundTransparency = 0.1
tradeFrame.BorderSizePixel = 1
tradeFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
tradeFrame.Parent = Content

local tradeCorner = Instance.new("UICorner")
tradeCorner.CornerRadius = UDim.new(0, 10)
tradeCorner.Parent = tradeFrame

local tradeLabel = Instance.new("TextLabel")
tradeLabel.Size = UDim2.new(0, 160, 1, 0)
tradeLabel.Position = UDim2.new(0, 14, 0, 0)
tradeLabel.BackgroundTransparency = 1
tradeLabel.Text = "🔄 AUTO TRADE"
tradeLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
tradeLabel.Font = Enum.Font.FredokaOne
tradeLabel.TextSize = 14
tradeLabel.TextXAlignment = Enum.TextXAlignment.Left
tradeLabel.Parent = tradeFrame

local tradeSwitchBg = Instance.new("Frame")
tradeSwitchBg.Size = UDim2.new(0, 60, 0, 30)
tradeSwitchBg.Position = UDim2.new(1, -72, 0.5, -15)
tradeSwitchBg.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
tradeSwitchBg.BackgroundTransparency = 0.1
tradeSwitchBg.BorderSizePixel = 2
tradeSwitchBg.BorderColor3 = Color3.fromRGB(60, 200, 80)
tradeSwitchBg.Parent = tradeFrame

local tradeSwitchCorner = Instance.new("UICorner")
tradeSwitchCorner.CornerRadius = UDim.new(0, 15)
tradeSwitchCorner.Parent = tradeSwitchBg

local tradeOffLabel = Instance.new("TextLabel")
tradeOffLabel.Size = UDim2.new(0, 22, 1, 0)
tradeOffLabel.Position = UDim2.new(0, 5, 0, 0)
tradeOffLabel.BackgroundTransparency = 1
tradeOffLabel.Text = "OFF"
tradeOffLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
tradeOffLabel.Font = Enum.Font.FredokaOne
tradeOffLabel.TextSize = 10
tradeOffLabel.TextXAlignment = Enum.TextXAlignment.Center
tradeOffLabel.Parent = tradeSwitchBg

local tradeOnLabel = Instance.new("TextLabel")
tradeOnLabel.Size = UDim2.new(0, 22, 1, 0)
tradeOnLabel.Position = UDim2.new(1, -27, 0, 0)
tradeOnLabel.BackgroundTransparency = 1
tradeOnLabel.Text = "ON"
tradeOnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
tradeOnLabel.Font = Enum.Font.FredokaOne
tradeOnLabel.TextSize = 10
tradeOnLabel.TextXAlignment = Enum.TextXAlignment.Center
tradeOnLabel.Parent = tradeSwitchBg

local tradeSwitchBtn = Instance.new("TextButton")
tradeSwitchBtn.Size = UDim2.new(0, 24, 0, 24)
tradeSwitchBtn.Position = UDim2.new(1, -27, 0.5, -12)
tradeSwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
tradeSwitchBtn.BackgroundTransparency = 0.05
tradeSwitchBtn.BorderSizePixel = 2
tradeSwitchBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
tradeSwitchBtn.Text = ""
tradeSwitchBtn.ZIndex = 10
tradeSwitchBtn.Parent = tradeSwitchBg

local tradeSwitchBtnCorner = Instance.new("UICorner")
tradeSwitchBtnCorner.CornerRadius = UDim.new(0, 12)
tradeSwitchBtnCorner.Parent = tradeSwitchBtn

-- ===== TOGGLE 2: AUTO ACCEPT =====
local acceptFrame = Instance.new("Frame")
acceptFrame.Size = UDim2.new(1, 0, 0, 45)
acceptFrame.Position = UDim2.new(0, 0, 0, 55)
acceptFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
acceptFrame.BackgroundTransparency = 0.1
acceptFrame.BorderSizePixel = 1
acceptFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
acceptFrame.Parent = Content

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

-- ============================================
-- ANIMASI SWITCH
-- ============================================

local function SmoothMove(object, targetPos, duration)
    local tween = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos})
    tween:Play()
end

local function UpdateTradeSwitch(isOn)
    if isOn then
        tradeSwitchBg.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
        tradeSwitchBg.BorderColor3 = Color3.fromRGB(60, 200, 80)
        SmoothMove(tradeSwitchBtn, UDim2.new(1, -27, 0.5, -12), 0.3)
        tradeOffLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
        tradeOnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        tradeSwitchBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        tradeSwitchBg.BorderColor3 = Color3.fromRGB(80, 80, 100)
        SmoothMove(tradeSwitchBtn, UDim2.new(0, 3, 0.5, -12), 0.3)
        tradeOffLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        tradeOnLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    end
end

local function UpdateAcceptSwitch(isOn)
    if isOn then
        acceptSwitchBg.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
        acceptSwitchBg.BorderColor3 = Color3.fromRGB(60, 200, 80)
        SmoothMove(acceptSwitchBtn, UDim2.new(1, -27, 0.5, -12), 0.3)
        acceptOffLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
        acceptOnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        acceptSwitchBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        acceptSwitchBg.BorderColor3 = Color3.fromRGB(80, 80, 100)
        SmoothMove(acceptSwitchBtn, UDim2.new(0, 3, 0.5, -12), 0.3)
        acceptOffLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        acceptOnLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    end
end

local function UpdateMainBorder()
    if autoTrade or autoAccept then
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BorderColor3 = Color3.fromRGB(60, 200, 80)}):Play()
        TweenService:Create(Glow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = Color3.fromRGB(60, 200, 80)}):Play()
    else
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BorderColor3 = Color3.fromRGB(200, 50, 50)}):Play()
        TweenService:Create(Glow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = Color3.fromRGB(200, 50, 50)}):Play()
    end
end

-- ============================================
-- KLIK TOGGLE
-- ============================================

tradeSwitchBtn.MouseButton1Click:Connect(function()
    autoTrade = not autoTrade
    UpdateTradeSwitch(autoTrade)
    UpdateMainBorder()
    if autoTrade then
        StartTradeLoop()
        print("🔄 AUTO TRADE ON")
    else
        StopTradeLoop()
        print("🔴 AUTO TRADE OFF")
    end
end)

tradeFrame.MouseButton1Click:Connect(function()
    autoTrade = not autoTrade
    UpdateTradeSwitch(autoTrade)
    UpdateMainBorder()
    if autoTrade then
        StartTradeLoop()
        print("🔄 AUTO TRADE ON")
    else
        StopTradeLoop()
        print("🔴 AUTO TRADE OFF")
    end
end)

acceptSwitchBtn.MouseButton1Click:Connect(function()
    autoAccept = not autoAccept
    UpdateAcceptSwitch(autoAccept)
    UpdateMainBorder()
    if autoAccept then
        StartAcceptLoop()
        print("✅ AUTO ACCEPT ON")
    else
        StopAcceptLoop()
        print("🔴 AUTO ACCEPT OFF")
    end
end)

acceptFrame.MouseButton1Click:Connect(function()
    autoAccept = not autoAccept
    UpdateAcceptSwitch(autoAccept)
    UpdateMainBorder()
    if autoAccept then
        StartAcceptLoop()
        print("✅ AUTO ACCEPT ON")
    else
        StopAcceptLoop()
        print("🔴 AUTO ACCEPT OFF")
    end
end)

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

print("═══════════════════════════════════")
print("✅ ZAIXPLOIT | AUTO TRADE + ACCEPT")
print("📌 AUTO TRADE: ON/OFF")
print("📌 AUTO ACCEPT: ON/OFF (Remote + UI)")
print("═══════════════════════════════════")