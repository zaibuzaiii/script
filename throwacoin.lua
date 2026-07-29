-- ============================================
-- ZAIXPLOIT | AUTO COIN + INSTAN PROMPT
-- HoldDuration = 0 (Langsung trigger)
-- ============================================

local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ============================================
-- 1. SET HOLD DURATION = 0 (INSTAN PROMPT)
-- ============================================

for i, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
    if v.ClassName == "ProximityPrompt" then
        v.HoldDuration = 0
        print("✅ ProximityPrompt HoldDuration set to 0!")
    end
end

-- ============================================
-- 2. ANTI AFK
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
-- 3. MATIKAN ANTI KICK BAWAAN
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
    local starterPlayer = game:GetService("StarterPlayer")
    local scripts = starterPlayer:FindFirstChild("StarterPlayerScripts")
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

pcall(function()
    local playerGui = player:WaitForChild("PlayerGui")
    local uiFolder = playerGui:FindFirstChild("UiFolder")
    if uiFolder then
        local main = uiFolder:FindFirstChild("Main")
        if main then
            local hud = main:FindFirstChild("HUD")
            if hud then
                local afkSafe = hud:FindFirstChild("AFKSafe")
                if afkSafe then afkSafe:Destroy() end
            end
        end
    end
end)

-- ============================================
-- 4. REMOTE COIN
-- ============================================

local CoinLanded = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("CoinLanded")

-- ============================================
-- 5. FUNGSI THROW HELIOS COIN
-- ============================================

local function ThrowHeliosCoin()
    local args = {
        [1] = 1.3370886103455577,
        [2] = Vector3.new(-1155.1026611328125, 0.7260000109672546, 74.73015594482422),
        [3] = "Helios Coin",
        [4] = Vector3.new(-1160.6558837890625, 0.7260000109672546, 72.45848846435547),
        [6] = 1
    }
    pcall(function()
        CoinLanded:FireServer(unpack(args))
        print("🪙 Helios Coin thrown!")
    end)
end

-- ============================================
-- 6. AUTO COIN LOOP (DEFAULT ON)
-- ============================================

local autoCoin = true
local coinLoop = nil

local function StartCoinLoop()
    if coinLoop then return end
    coinLoop = task.spawn(function()
        while autoCoin do
            ThrowHeliosCoin()
            task.wait(0.05)
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
print("✅ AUTO HELIOS COIN ON (Default)")

-- ============================================
-- 7. FUNGSI GET PROMPT & INSTAN PROMPT
-- ============================================

local function GetPrompt()
    local huntSlots = workspace:FindFirstChild("HuntSlots")
    if not huntSlots then return nil end
    local huntSlot = huntSlots:FindFirstChild("HuntSlot_1")
    if not huntSlot then return nil end
    for _, child in ipairs(huntSlot:GetChildren()) do
        local prompt = child:FindFirstChild("ProximityPrompt")
        if prompt and prompt.Enabled then
            return prompt
        end
    end
    return nil
end

local function FirePrompt()
    local prompt = GetPrompt()
    if not prompt then return false end
    
    pcall(function()
        prompt:Prompt()
        task.wait(0.05)
        VirtualUser:Button1Down(Vector2.new())
        task.wait(0.05)
        VirtualUser:Button1Up(Vector2.new())
        VirtualUser:Button2Down(Vector2.new())
        task.wait(0.05)
        VirtualUser:Button2Up(Vector2.new())
        print("✅ Prompt fired!")
    end)
    return true
end

-- ============================================
-- 8. AUTO PROMPT LOOP
-- ============================================

local autoPrompt = true
local promptLoop = nil

local function StartPromptLoop()
    if promptLoop then return end
    promptLoop = task.spawn(function()
        while autoPrompt do
            FirePrompt()
            task.wait(0.5)
        end
    end)
end

local function StopPromptLoop()
    autoPrompt = false
    if promptLoop then
        task.cancel(promptLoop)
        promptLoop = nil
    end
end

StartPromptLoop()
print("✅ AUTO PROMPT ON (Default)")

-- ============================================
-- 9. BUAT GUI
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
SubTitle.Text = "🪙 AUTO HELIOS + INSTAN PROMPT"
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
    StopCoinLoop()
    StopPromptLoop()
    screenGui:Destroy()
end)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -14, 0, 120)
Content.Position = UDim2.new(0, 7, 0, 48)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- ===== AUTO COIN TOGGLE =====
local autoFrame = Instance.new("Frame")
autoFrame.Size = UDim2.new(1, 0, 0, 45)
autoFrame.Position = UDim2.new(0, 0, 0, 5)
autoFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
autoFrame.BackgroundTransparency = 0.1
autoFrame.BorderSizePixel = 1
autoFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
autoFrame.Parent = Content

local autoCorner = Instance.new("UICorner")
autoCorner.CornerRadius = UDim.new(0, 10)
autoCorner.Parent = autoFrame

local autoLabel = Instance.new("TextLabel")
autoLabel.Size = UDim2.new(0, 160, 1, 0)
autoLabel.Position = UDim2.new(0, 14, 0, 0)
autoLabel.BackgroundTransparency = 1
autoLabel.Text = "🪙 AUTO HELIOS"
autoLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
autoLabel.Font = Enum.Font.FredokaOne
autoLabel.TextSize = 14
autoLabel.TextXAlignment = Enum.TextXAlignment.Left
autoLabel.Parent = autoFrame

local autoSwitchBg = Instance.new("Frame")
autoSwitchBg.Size = UDim2.new(0, 60, 0, 30)
autoSwitchBg.Position = UDim2.new(1, -72, 0.5, -15)
autoSwitchBg.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
autoSwitchBg.BackgroundTransparency = 0.1
autoSwitchBg.BorderSizePixel = 2
autoSwitchBg.BorderColor3 = Color3.fromRGB(60, 200, 80)
autoSwitchBg.Parent = autoFrame

local autoSwitchCorner = Instance.new("UICorner")
autoSwitchCorner.CornerRadius = UDim.new(0, 15)
autoSwitchCorner.Parent = autoSwitchBg

local autoOffLabel = Instance.new("TextLabel")
autoOffLabel.Size = UDim2.new(0, 22, 1, 0)
autoOffLabel.Position = UDim2.new(0, 5, 0, 0)
autoOffLabel.BackgroundTransparency = 1
autoOffLabel.Text = "OFF"
autoOffLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
autoOffLabel.Font = Enum.Font.FredokaOne
autoOffLabel.TextSize = 10
autoOffLabel.TextXAlignment = Enum.TextXAlignment.Center
autoOffLabel.Parent = autoSwitchBg

local autoOnLabel = Instance.new("TextLabel")
autoOnLabel.Size = UDim2.new(0, 22, 1, 0)
autoOnLabel.Position = UDim2.new(1, -27, 0, 0)
autoOnLabel.BackgroundTransparency = 1
autoOnLabel.Text = "ON"
autoOnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
autoOnLabel.Font = Enum.Font.FredokaOne
autoOnLabel.TextSize = 10
autoOnLabel.TextXAlignment = Enum.TextXAlignment.Center
autoOnLabel.Parent = autoSwitchBg

local autoSwitchBtn = Instance.new("TextButton")
autoSwitchBtn.Size = UDim2.new(0, 24, 0, 24)
autoSwitchBtn.Position = UDim2.new(1, -27, 0.5, -12)
autoSwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
autoSwitchBtn.BackgroundTransparency = 0.05
autoSwitchBtn.BorderSizePixel = 2
autoSwitchBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
autoSwitchBtn.Text = ""
autoSwitchBtn.ZIndex = 10
autoSwitchBtn.Parent = autoSwitchBg

local autoSwitchBtnCorner = Instance.new("UICorner")
autoSwitchBtnCorner.CornerRadius = UDim.new(0, 12)
autoSwitchBtnCorner.Parent = autoSwitchBtn

-- ============================================
-- 10. ANIMASI SWITCH
-- ============================================

local function SmoothMove(object, targetPos, duration)
    local tween = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos})
    tween:Play()
end

local function UpdateAutoSwitch(isOn)
    if isOn then
        autoSwitchBg.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
        autoSwitchBg.BorderColor3 = Color3.fromRGB(60, 200, 80)
        SmoothMove(autoSwitchBtn, UDim2.new(1, -27, 0.5, -12), 0.3)
        autoOffLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
        autoOnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        autoSwitchBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        autoSwitchBg.BorderColor3 = Color3.fromRGB(80, 80, 100)
        SmoothMove(autoSwitchBtn, UDim2.new(0, 3, 0.5, -12), 0.3)
        autoOffLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        autoOnLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    end
end

local function UpdateMainBorder()
    if autoCoin then
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BorderColor3 = Color3.fromRGB(60, 200, 80)}):Play()
        TweenService:Create(Glow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = Color3.fromRGB(60, 200, 80)}):Play()
    else
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BorderColor3 = Color3.fromRGB(200, 50, 50)}):Play()
        TweenService:Create(Glow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = Color3.fromRGB(200, 50, 50)}):Play()
    end
end

-- ============================================
-- 11. KLIK TOGGLE
-- ============================================

autoSwitchBtn.MouseButton1Click:Connect(function()
    autoCoin = not autoCoin
    UpdateAutoSwitch(autoCoin)
    UpdateMainBorder()
    if autoCoin then
        StartCoinLoop()
        print("🟢 AUTO HELIOS ON")
    else
        StopCoinLoop()
        print("🔴 AUTO HELIOS OFF")
    end
end)

autoFrame.MouseButton1Click:Connect(function()
    autoCoin = not autoCoin
    UpdateAutoSwitch(autoCoin)
    UpdateMainBorder()
    if autoCoin then
        StartCoinLoop()
        print("🟢 AUTO HELIOS ON")
    else
        StopCoinLoop()
        print("🔴 AUTO HELIOS OFF")
    end
end)

-- ============================================
-- 12. DRAG
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
print("✅ ZAIXPLOIT | AUTO HELIOS + INSTAN PROMPT")
print("📌 HoldDuration = 0 (Langsung trigger)")
print("📌 AUTO COIN DEFAULT ON")
print("📌 AUTO PROMPT DEFAULT ON")
print("═══════════════════════════════════")