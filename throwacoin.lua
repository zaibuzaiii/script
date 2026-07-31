local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events")

local CoinLanded = Events:WaitForChild("CoinLanded")

-- ============================================
-- TOGGLE VARIABEL
-- ============================================

local autoCoin = true
local autoCoin2Spot = false  -- DEFAULT OFF

local coinLoop = nil
local coin2SpotLoop = nil

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
    local events = game:GetService("ReplicatedStorage"):FindFirstChild("Assets")
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

-- ============================================
-- 3. AUTO COIN (1 REMOTE) - PAKAI REMOTE BARU
-- ============================================

local function ThrowCoin()
    local args = {
        1.9999999999,
        Vector3.new(-1162.6304931640625, 0.7260000109672546, 89.36738586425781),
        "Helios Coin",
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

-- ============================================
-- 4. AUTO COIN 2 SPOT (GANTIAN 1 DETIK) - DEFAULT OFF
-- ============================================

-- SPOT 1: Remote 1 ([6]=5)
local function ThrowSpot1()
    local args = {
        1.933600201243827,
        Vector3.new(-1155.275634765625, 0.7260000109672546, -169.50115966796875),
        "Helios Coin",
        Vector3.new(-1161.054443359375, 0.7260000109672546, -171.1151123046875),
        [6] = 5
    }
    pcall(function()
        CoinLanded:FireServer(unpack(args))
        print("🪙 SPOT 1 thrown!")
    end)
end

-- SPOT 2: Remote 2 ([6]=3)
local function ThrowSpot2()
    local args = {
        1.9143838290784843,
        Vector3.new(-1168.4803466796875, 0.7260000109672546, 77.04112243652344),
        "Helios Coin",
        Vector3.new(-1169.2154541015625, 0.7260000109672546, 82.99591064453125),
        [6] = 3
    }
    pcall(function()
        CoinLanded:FireServer(unpack(args))
        print("👑 SPOT 2 thrown!")
    end)
end

local function StartCoin2SpotLoop()
    if coin2SpotLoop then return end
    coin2SpotLoop = task.spawn(function()
        local toggle = true
        while autoCoin2Spot do
            if toggle then
                ThrowSpot1()
            else
                ThrowSpot2()
            end
            toggle = not toggle
            task.wait(1)
        end
    end)
end

local function StopCoin2SpotLoop()
    autoCoin2Spot = false
    if coin2SpotLoop then
        task.cancel(coin2SpotLoop)
        coin2SpotLoop = nil
    end
end

-- TIDAK DIJALANKAN OTOMATIS (DEFAULT OFF)

-- ============================================
-- 5. SET HOLD DURATION = 0
-- ============================================

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

-- ============================================
-- 6. TELEPORT (1x SAJA)
-- ============================================

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

-- ============================================
-- 7. GUI
-- ============================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZAIXPLOIT"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 340, 0, 190)
Main.Position = UDim2.new(0.5, -170, 0.5, -95)
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
SubTitle.Text = "🪙 THROW A COIN"
SubTitle.TextColor3 = Color3.fromRGB(255, 200, 50)
SubTitle.Font = Enum.Font.FredokaOne
SubTitle.TextSize = 12
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
    StopCoin2SpotLoop()
    screenGui:Destroy()
end)

-- ============================================
-- CONTENT
-- ============================================

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -14, 0, 130)
Content.Position = UDim2.new(0, 7, 0, 48)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- ============================================
-- TOGGLE 1: AUTO COIN (DEFAULT ON)
-- ============================================

local coinFrame = Instance.new("Frame")
coinFrame.Size = UDim2.new(1, 0, 0, 45)
coinFrame.Position = UDim2.new(0, 0, 0, 5)
coinFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
coinFrame.BackgroundTransparency = 0.1
coinFrame.BorderSizePixel = 1
coinFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
coinFrame.Parent = Content

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

-- ============================================
-- TOGGLE 2: AUTO COIN 2 SPOT (DEFAULT OFF)
-- ============================================

local coin2SpotFrame = Instance.new("Frame")
coin2SpotFrame.Size = UDim2.new(1, 0, 0, 45)
coin2SpotFrame.Position = UDim2.new(0, 0, 0, 55)
coin2SpotFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
coin2SpotFrame.BackgroundTransparency = 0.1
coin2SpotFrame.BorderSizePixel = 1
coin2SpotFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
coin2SpotFrame.Parent = Content

local coin2SpotCorner = Instance.new("UICorner")
coin2SpotCorner.CornerRadius = UDim.new(0, 10)
coin2SpotCorner.Parent = coin2SpotFrame

local coin2SpotLabel = Instance.new("TextLabel")
coin2SpotLabel.Size = UDim2.new(0, 180, 1, 0)
coin2SpotLabel.Position = UDim2.new(0, 14, 0, 0)
coin2SpotLabel.BackgroundTransparency = 1
coin2SpotLabel.Text = "🪙 AUTO COIN 2 SPOT"
coin2SpotLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
coin2SpotLabel.Font = Enum.Font.FredokaOne
coin2SpotLabel.TextSize = 14
coin2SpotLabel.TextXAlignment = Enum.TextXAlignment.Left
coin2SpotLabel.Parent = coin2SpotFrame

local coin2SpotSwitchBg = Instance.new("Frame")
coin2SpotSwitchBg.Size = UDim2.new(0, 60, 0, 30)
coin2SpotSwitchBg.Position = UDim2.new(1, -72, 0.5, -15)
coin2SpotSwitchBg.BackgroundColor3 = Color3.fromRGB(150, 150, 160)  -- OFF STATE
coin2SpotSwitchBg.BackgroundTransparency = 0.1
coin2SpotSwitchBg.BorderSizePixel = 2
coin2SpotSwitchBg.BorderColor3 = Color3.fromRGB(150, 150, 160)  -- OFF STATE
coin2SpotSwitchBg.Parent = coin2SpotFrame

local coin2SpotSwitchCorner = Instance.new("UICorner")
coin2SpotSwitchCorner.CornerRadius = UDim.new(0, 15)
coin2SpotSwitchCorner.Parent = coin2SpotSwitchBg

local coin2SpotOffLabel = Instance.new("TextLabel")
coin2SpotOffLabel.Size = UDim2.new(0, 22, 1, 0)
coin2SpotOffLabel.Position = UDim2.new(0, 5, 0, 0)
coin2SpotOffLabel.BackgroundTransparency = 1
coin2SpotOffLabel.Text = "OFF"
coin2SpotOffLabel.TextColor3 = Color3.fromRGB(255, 255, 255)  -- ON STATE (karena OFF)
coin2SpotOffLabel.Font = Enum.Font.FredokaOne
coin2SpotOffLabel.TextSize = 10
coin2SpotOffLabel.TextXAlignment = Enum.TextXAlignment.Center
coin2SpotOffLabel.Parent = coin2SpotSwitchBg

local coin2SpotOnLabel = Instance.new("TextLabel")
coin2SpotOnLabel.Size = UDim2.new(0, 22, 1, 0)
coin2SpotOnLabel.Position = UDim2.new(1, -27, 0, 0)
coin2SpotOnLabel.BackgroundTransparency = 1
coin2SpotOnLabel.Text = "ON"
coin2SpotOnLabel.TextColor3 = Color3.fromRGB(150, 150, 160)  -- OFF STATE
coin2SpotOnLabel.Font = Enum.Font.FredokaOne
coin2SpotOnLabel.TextSize = 10
coin2SpotOnLabel.TextXAlignment = Enum.TextXAlignment.Center
coin2SpotOnLabel.Parent = coin2SpotSwitchBg

local coin2SpotSwitchBtn = Instance.new("TextButton")
coin2SpotSwitchBtn.Size = UDim2.new(0, 24, 0, 24)
coin2SpotSwitchBtn.Position = UDim2.new(0, 3, 0.5, -12)  -- POSISI OFF
coin2SpotSwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
coin2SpotSwitchBtn.BackgroundTransparency = 0.05
coin2SpotSwitchBtn.BorderSizePixel = 2
coin2SpotSwitchBtn.BorderColor3 = Color3.fromRGB(150, 150, 160)  -- OFF STATE
coin2SpotSwitchBtn.Text = ""
coin2SpotSwitchBtn.ZIndex = 10
coin2SpotSwitchBtn.Parent = coin2SpotSwitchBg

local coin2SpotSwitchBtnCorner = Instance.new("UICorner")
coin2SpotSwitchBtnCorner.CornerRadius = UDim.new(0, 12)
coin2SpotSwitchBtnCorner.Parent = coin2SpotSwitchBtn

-- ============================================
-- TOGGLE FUNCTIONS (SWITCH ANIMATION)
-- ============================================

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

-- ============================================
-- TOGGLE 1: AUTO COIN (DEFAULT ON)
-- ============================================

coinSwitchBtn.MouseButton1Click:Connect(function()
    autoCoin = not autoCoin
    
    if autoCoin then
        StartCoinLoop()
        SetToggleState(coinSwitchBtn, true, coinSwitchBg, coinOffLabel, coinOnLabel)
        print("✅ AUTO COIN: ON")
    else
        StopCoinLoop()
        SetToggleState(coinSwitchBtn, false, coinSwitchBg, coinOffLabel, coinOnLabel)
        print("❌ AUTO COIN: OFF")
    end
end)

-- ============================================
-- TOGGLE 2: AUTO COIN 2 SPOT (DEFAULT OFF)
-- ============================================

coin2SpotSwitchBtn.MouseButton1Click:Connect(function()
    autoCoin2Spot = not autoCoin2Spot
    
    if autoCoin2Spot then
        StartCoin2SpotLoop()
        SetToggleState(coin2SpotSwitchBtn, true, coin2SpotSwitchBg, coin2SpotOffLabel, coin2SpotOnLabel)
        print("✅ AUTO COIN 2 SPOT: ON")
    else
        StopCoin2SpotLoop()
        SetToggleState(coin2SpotSwitchBtn, false, coin2SpotSwitchBg, coin2SpotOffLabel, coin2SpotOnLabel)
        print("❌ AUTO COIN 2 SPOT: OFF")
    end
end)

-- ============================================
-- SET INITIAL STATE
-- ============================================

-- AUTO COIN: ON
SetToggleState(coinSwitchBtn, true, coinSwitchBg, coinOffLabel, coinOnLabel)

-- AUTO COIN 2 SPOT: OFF
SetToggleState(coin2SpotSwitchBtn, false, coin2SpotSwitchBg, coin2SpotOffLabel, coin2SpotOnLabel)

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

print("═══════════════════════════════════")
print("✅ ZAIXPLOIT RUNNING")
print("📌 AUTO COIN (ON)")
print("📌 AUTO COIN 2 SPOT (OFF) - Gantian 1s")
print("   ├─ Spot 1: [6]=5")
print("   └─ Spot 2: [6]=3")
print("📌 ANTI AFK (Backend)")
print("📌 TELEPORT: World 3 → VIP (1x)")
print("📌 ANTI KICK: Dimatikan")
print("📌 HoldDuration=0 (LOOP)")
print("═══════════════════════════════════")