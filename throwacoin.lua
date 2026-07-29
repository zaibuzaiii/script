-- ============================================
-- ZAIXPLOIT | FULL SCRIPT
-- Auto Coin + Anti AFK + Matikan Anti Kick
-- ============================================

local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

-- ============================================
-- 1. MATIKAN ANTI KICK BAWAAN GAME
-- ============================================

pcall(function()
    local scripts = player:FindFirstChild("PlayerScripts")
    if scripts then
        scripts = scripts:FindFirstChild("Scripts")
        if scripts then
            local antiKick = scripts:FindFirstChild("AntiKickScript")
            if antiKick then
                antiKick:Destroy()
                print("✅ AntiKickScript (LocalPlayer) dihapus!")
            end
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
            if antiKick then
                antiKick:Destroy()
                print("✅ AntiKickScript (StarterPlayer) dihapus!")
            end
        end
    end
end)

pcall(function()
    local events = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Events")
    local remotes = {"AntiKickReconnect", "SetAFKSafe", "StartAFKSafe"}
    for _, name in ipairs(remotes) do
        local remote = events:FindFirstChild(name)
        if remote then
            remote:Destroy()
            print("✅ Remote " .. name .. " dihapus!")
        end
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
                if afkSafe then
                    afkSafe:Destroy()
                    print("✅ AFKSafe UI dihapus!")
                end
            end
        end
    end
end)

-- ============================================
-- 2. ANTI AFK SENDIRI
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
-- 3. REMOTE & ANIMASI
-- ============================================

local CoinLanded = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("CoinLanded")

local Animations = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Animations")
local ThrowAnim = Animations:WaitForChild("Throw")
local BackAnim = Animations:WaitForChild("Back")

-- ============================================
-- 4. VARIABEL
-- ============================================

local autoCoin = true
local useAnimasi = false
local coinLoop = nil

-- ============================================
-- 5. FUNGSI THROW COIN
-- ============================================

local function ThrowCoin()
    local args = {
        [1] = 1.3370886103455577,
        [2] = Vector3.new(-1155.1026611328125, 0.7260000109672546, 74.73015594482422),
        [3] = "Helios Coin",
        [4] = Vector3.new(-1160.6558837890625, 0.7260000109672546, 72.45848846435547),
        [6] = 1
    }
    pcall(function()
        CoinLanded:FireServer(unpack(args))
    end)
end

local function ThrowWithAnimasi()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChild("Animator")
    if not animator then return end
    
    local throwTrack = animator:LoadAnimation(ThrowAnim)
    throwTrack:Play()
    task.wait(0.3)
    ThrowCoin()
    task.wait(0.2)
    local backTrack = animator:LoadAnimation(BackAnim)
    backTrack:Play()
    task.wait(0.3)
end

local function StartCoinLoop()
    if coinLoop then return end
    coinLoop = task.spawn(function()
        while autoCoin do
            if useAnimasi then
                ThrowWithAnimasi()
                task.wait(0.1)
            else
                ThrowCoin()
                task.wait(0.05)
            end
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

-- ============================================
-- 6. BUAT GUI
-- ============================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZAIXPLOIT"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 340, 0, 170)
Main.Position = UDim2.new(0.5, -170, 0.5, -85)
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
SubTitle.Text = "🪙 AUTO COIN"
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
    screenGui:Destroy()
end)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -14, 0, 110)
Content.Position = UDim2.new(0, 7, 0, 48)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- ===== AUTO COIN TOGGLE =====
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(1, 0, 0, 45)
autoBtn.Position = UDim2.new(0, 0, 0, 5)
autoBtn.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
autoBtn.BackgroundTransparency = 0.1
autoBtn.BorderSizePixel = 1
autoBtn.BorderColor3 = Color3.fromRGB(60, 60, 80)
autoBtn.Text = ""
autoBtn.Font = Enum.Font.FredokaOne
autoBtn.TextSize = 14
autoBtn.TextXAlignment = Enum.TextXAlignment.Left
autoBtn.Parent = Content

local autoCorner = Instance.new("UICorner")
autoCorner.CornerRadius = UDim.new(0, 10)
autoCorner.Parent = autoBtn

local autoLabel = Instance.new("TextLabel")
autoLabel.Size = UDim2.new(0, 130, 1, 0)
autoLabel.Position = UDim2.new(0, 14, 0, 0)
autoLabel.BackgroundTransparency = 1
autoLabel.Text = "🪙 AUTO COIN"
autoLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
autoLabel.Font = Enum.Font.FredokaOne
autoLabel.TextSize = 14
autoLabel.TextXAlignment = Enum.TextXAlignment.Left
autoLabel.Parent = autoBtn

local autoSwitchBg = Instance.new("Frame")
autoSwitchBg.Size = UDim2.new(0, 60, 0, 30)
autoSwitchBg.Position = UDim2.new(1, -72, 0.5, -15)
autoSwitchBg.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
autoSwitchBg.BackgroundTransparency = 0.1
autoSwitchBg.BorderSizePixel = 2
autoSwitchBg.BorderColor3 = Color3.fromRGB(60, 200, 80)
autoSwitchBg.Parent = autoBtn

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

-- ===== ANIMASI TOGGLE =====
local animBtn = Instance.new("TextButton")
animBtn.Size = UDim2.new(1, 0, 0, 45)
animBtn.Position = UDim2.new(0, 0, 0, 55)
animBtn.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
animBtn.BackgroundTransparency = 0.1
animBtn.BorderSizePixel = 1
animBtn.BorderColor3 = Color3.fromRGB(60, 60, 80)
animBtn.Text = ""
animBtn.Font = Enum.Font.FredokaOne
animBtn.TextSize = 14
animBtn.TextXAlignment = Enum.TextXAlignment.Left
animBtn.Parent = Content

local animCorner = Instance.new("UICorner")
animCorner.CornerRadius = UDim.new(0, 10)
animCorner.Parent = animBtn

local animLabel = Instance.new("TextLabel")
animLabel.Size = UDim2.new(0, 160, 1, 0)
animLabel.Position = UDim2.new(0, 14, 0, 0)
animLabel.BackgroundTransparency = 1
animLabel.Text = "🎬 WITH ANIMASI"
animLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
animLabel.Font = Enum.Font.FredokaOne
animLabel.TextSize = 14
animLabel.TextXAlignment = Enum.TextXAlignment.Left
animLabel.Parent = animBtn

local animSwitchBg = Instance.new("Frame")
animSwitchBg.Size = UDim2.new(0, 60, 0, 30)
animSwitchBg.Position = UDim2.new(1, -72, 0.5, -15)
animSwitchBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
animSwitchBg.BackgroundTransparency = 0.1
animSwitchBg.BorderSizePixel = 2
animSwitchBg.BorderColor3 = Color3.fromRGB(80, 80, 100)
animSwitchBg.Parent = animBtn

local animSwitchCorner = Instance.new("UICorner")
animSwitchCorner.CornerRadius = UDim.new(0, 15)
animSwitchCorner.Parent = animSwitchBg

local animOffLabel = Instance.new("TextLabel")
animOffLabel.Size = UDim2.new(0, 22, 1, 0)
animOffLabel.Position = UDim2.new(0, 5, 0, 0)
animOffLabel.BackgroundTransparency = 1
animOffLabel.Text = "OFF"
animOffLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
animOffLabel.Font = Enum.Font.FredokaOne
animOffLabel.TextSize = 10
animOffLabel.TextXAlignment = Enum.TextXAlignment.Center
animOffLabel.Parent = animSwitchBg

local animOnLabel = Instance.new("TextLabel")
animOnLabel.Size = UDim2.new(0, 22, 1, 0)
animOnLabel.Position = UDim2.new(1, -27, 0, 0)
animOnLabel.BackgroundTransparency = 1
animOnLabel.Text = "ON"
animOnLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
animOnLabel.Font = Enum.Font.FredokaOne
animOnLabel.TextSize = 10
animOnLabel.TextXAlignment = Enum.TextXAlignment.Center
animOnLabel.Parent = animSwitchBg

local animSwitchBtn = Instance.new("TextButton")
animSwitchBtn.Size = UDim2.new(0, 24, 0, 24)
animSwitchBtn.Position = UDim2.new(0, 3, 0.5, -12)
animSwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
animSwitchBtn.BackgroundTransparency = 0.05
animSwitchBtn.BorderSizePixel = 2
animSwitchBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
animSwitchBtn.Text = ""
animSwitchBtn.ZIndex = 10
animSwitchBtn.Parent = animSwitchBg

local animSwitchBtnCorner = Instance.new("UICorner")
animSwitchBtnCorner.CornerRadius = UDim.new(0, 12)
animSwitchBtnCorner.Parent = animSwitchBtn

-- ============================================
-- 7. ANIMASI SWITCH
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

local function UpdateAnimSwitch(isOn)
    if isOn then
        animSwitchBg.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
        animSwitchBg.BorderColor3 = Color3.fromRGB(60, 200, 80)
        SmoothMove(animSwitchBtn, UDim2.new(1, -27, 0.5, -12), 0.3)
        animOffLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
        animOnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        animSwitchBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        animSwitchBg.BorderColor3 = Color3.fromRGB(80, 80, 100)
        SmoothMove(animSwitchBtn, UDim2.new(0, 3, 0.5, -12), 0.3)
        animOffLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        animOnLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
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
-- 8. KLIK TOGGLE
-- ============================================

autoBtn.MouseButton1Click:Connect(function()
    autoCoin = not autoCoin
    UpdateAutoSwitch(autoCoin)
    UpdateMainBorder()
    if autoCoin then
        StartCoinLoop()
        print("🟢 AUTO COIN ON")
    else
        StopCoinLoop()
        print("🔴 AUTO COIN OFF")
    end
end)

autoSwitchBtn.MouseButton1Click:Connect(function()
    autoCoin = not autoCoin
    UpdateAutoSwitch(autoCoin)
    UpdateMainBorder()
    if autoCoin then
        StartCoinLoop()
        print("🟢 AUTO COIN ON")
    else
        StopCoinLoop()
        print("🔴 AUTO COIN OFF")
    end
end)

animBtn.MouseButton1Click:Connect(function()
    useAnimasi = not useAnimasi
    UpdateAnimSwitch(useAnimasi)
    print(useAnimasi and "🎬 ANIMASI ON" or "🎬 ANIMASI OFF")
end)

animSwitchBtn.MouseButton1Click:Connect(function()
    useAnimasi = not useAnimasi
    UpdateAnimSwitch(useAnimasi)
    print(useAnimasi and "🎬 ANIMASI ON" or "🎬 ANIMASI OFF")
end)

-- ============================================
-- 9. START AUTO COIN (DEFAULT ON)
-- ============================================

StartCoinLoop()
print("✅ AUTO COIN LANGSUNG ON (Default)")

-- ============================================
-- 10. DRAG
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