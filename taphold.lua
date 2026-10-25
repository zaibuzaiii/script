-- ============================================
-- TAP SIM REBORN - AUTO TAP + AUTO HATCH + ANTI AFK
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

local RemoteServices = ReplicatedStorage:WaitForChild("RemoteServices", 30)
if not RemoteServices then warn("[Auto] RemoteServices not found!"); return end

local TapService = RemoteServices:WaitForChild("TapService", 30)
local EggService = RemoteServices:WaitForChild("EggService", 30)
if not TapService or not EggService then warn("[Auto] Service not found!"); return end

local TapRequested = TapService:WaitForChild("RE", 30):WaitForChild("TapRequested", 30)
local EggHatchRequested = EggService:WaitForChild("RE", 30):WaitForChild("EggHatchRequested", 30)

if not TapRequested or not EggHatchRequested then
    warn("[Auto] Remote not found!")
    return
end

-- ===== STATE - TAP =====
local autoTap = false
local tapLoop = nil
_G.TapSeq = _G.TapSeq or 1
local tapSequence = _G.TapSeq

-- ===== STATE - HATCH =====
local autoHatch = false
local hatchLoop = nil
_G.HatchSeq = _G.HatchSeq or 1
local hatchSequence = _G.HatchSeq

-- ===== STATE - ANTI AFK =====
local antiAFK = true
local antiAFKLoop = nil
local ANTI_AFK_INTERVAL = 45   -- detik

-- ===== SETTINGS =====
local TAP_DELAY = 0.05
local AUTO_MODE_TAP = false
local TAP_SOURCE = "button_hold"

local HATCH_DELAY = 0.5
local HATCH_EGG = "Heaven"
local HATCH_COUNT = 8
local AUTO_MODE_HATCH = false

-- ============================================
-- AUTO TAP
-- ============================================
local function DoTap()
    local args = {
        {
            ClientSequence = tapSequence,
            Auto = AUTO_MODE_TAP,
            Source = TAP_SOURCE
        }
    }
    pcall(function()
        TapRequested:FireServer(unpack(args))
    end)
    tapSequence = tapSequence + 1
    _G.TapSeq = tapSequence
end

local function StartAutoTap()
    if tapLoop then return end
    autoTap = true
    print("[AutoTap] ⚡ Started | Seq:", tapSequence)
    tapLoop = task.spawn(function()
        while autoTap do
            DoTap()
            task.wait(TAP_DELAY)
        end
    end)
end

local function StopAutoTap()
    autoTap = false
    if tapLoop then task.cancel(tapLoop); tapLoop = nil end
    print("[AutoTap] ⏹️ Stopped | Seq:", tapSequence)
end

-- ============================================
-- AUTO HATCH
-- ============================================
local function DoHatch()
    local args = {
        {
            Egg = HATCH_EGG,
            Auto = AUTO_MODE_HATCH,
            Count = HATCH_COUNT,
            Seq = hatchSequence
        }
    }
    pcall(function()
        EggHatchRequested:FireServer(unpack(args))
    end)
    hatchSequence = hatchSequence + 1
    _G.HatchSeq = hatchSequence
end

local function StartAutoHatch()
    if hatchLoop then return end
    autoHatch = true
    print("[AutoHatch] 🥚 Started | Seq:", hatchSequence)
    hatchLoop = task.spawn(function()
        while autoHatch do
            DoHatch()
            task.wait(HATCH_DELAY)
        end
    end)
end

local function StopAutoHatch()
    autoHatch = false
    if hatchLoop then task.cancel(hatchLoop); hatchLoop = nil end
    print("[AutoHatch] ⏹️ Stopped | Seq:", hatchSequence)
end

-- ============================================
-- ANTI AFK
-- ============================================
local function DoAntiAFK()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
        VirtualUser:ClickButton1(Vector2.new(0, 0))
    end)
    print("[AntiAFK] 🛡️ Ping")
end

local function StartAntiAFK()
    if antiAFKLoop then return end
    antiAFK = true
    print("[AntiAFK] 🛡️ Started | Interval:", ANTI_AFK_INTERVAL, "s")
    antiAFKLoop = task.spawn(function()
        while antiAFK do
            task.wait(ANTI_AFK_INTERVAL)
            if antiAFK then
                DoAntiAFK()
            end
        end
    end)
end

local function StopAntiAFK()
    antiAFK = false
    if antiAFKLoop then task.cancel(antiAFKLoop); antiAFKLoop = nil end
    print("[AntiAFK] ⏹️ Stopped")
end

-- Auto-start anti AFK
StartAntiAFK()

-- ============================================
-- GUI
-- ============================================
local playerGui = player:WaitForChild("PlayerGui")
local oldGui = playerGui:FindFirstChild("TapSim_Auto")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TapSim_Auto"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local bubble = Instance.new("TextButton")
bubble.Size = UDim2.new(0, 55, 0, 55)
bubble.Position = UDim2.new(0, 20, 0.5, -27)
bubble.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
bubble.Text = "⚡"
bubble.TextSize = 28
bubble.Font = Enum.Font.FredokaOne
bubble.BorderSizePixel = 0
bubble.Visible = false
bubble.ZIndex = 50
bubble.Parent = screenGui
Instance.new("UICorner", bubble).CornerRadius = UDim.new(1, 0)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 260, 0, 400)
Main.Position = UDim2.new(0.5, -130, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(100, 200, 255)
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true
Main.Parent = screenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ AUTO TAP + HATCH"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.FredokaOne
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 26, 0, 26)
MinBtn.Position = UDim2.new(1, -60, 0, 4)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 55, 80)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.BorderSizePixel = 0
MinBtn.Parent = Header
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 5)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -32, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

local function CreateToggle(name, yPos, defaultState, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 50)
    frame.Position = UDim2.new(0, 8, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(30, 35, 55)
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(60, 60, 80)
    frame.Parent = Main
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -90, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.Font = Enum.Font.FredokaOne
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local switchBg = Instance.new("TextButton")
    switchBg.Size = UDim2.new(0, 60, 0, 26)
    switchBg.Position = UDim2.new(1, -70, 0.5, -13)
    switchBg.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
    switchBg.BorderSizePixel = 2
    switchBg.BorderColor3 = Color3.fromRGB(150, 150, 160)
    switchBg.Text = ""
    switchBg.AutoButtonColor = false
    switchBg.Parent = frame
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(0, 13)

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = UDim2.new(0, 2, 0.5, -11)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Text = ""
    knob.AutoButtonColor = false
    knob.ZIndex = 20
    knob.Parent = switchBg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = defaultState

    local function UpdateVisual(isOn)
        local targetPos = isOn and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
        TweenService:Create(knob, TweenInfo.new(0.15), {Position = targetPos}):Play()
        if isOn then
            switchBg.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
            switchBg.BorderColor3 = Color3.fromRGB(100, 200, 255)
        else
            switchBg.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
            switchBg.BorderColor3 = Color3.fromRGB(150, 150, 160)
        end
    end

    local function DoToggle()
        state = not state
        UpdateVisual(state)
        if callback then pcall(callback, state) end
    end

    knob.MouseButton1Click:Connect(DoToggle)
    switchBg.MouseButton1Click:Connect(DoToggle)

    UpdateVisual(defaultState)
end

CreateToggle("AUTO TAP ⚡", 42, false, function(on)
    if on then StartAutoTap() else StopAutoTap() end
end)

CreateToggle("AUTO HATCH 🥚", 96, false, function(on)
    if on then StartAutoHatch() else StopAutoHatch() end
end)

CreateToggle("ANTI AFK 🛡️", 150, true, function(on)
    if on then StartAntiAFK() else StopAntiAFK() end
end)

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -16, 0, 180)
infoLabel.Position = UDim2.new(0, 8, 0, 210)
infoLabel.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
infoLabel.BorderSizePixel = 0
infoLabel.Text = ""
infoLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
infoLabel.Font = Enum.Font.GothamBold
infoLabel.TextSize = 10
infoLabel.TextWrapped = true
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Parent = Main
Instance.new("UICorner", infoLabel).CornerRadius = UDim.new(0, 6)

task.spawn(function()
    while infoLabel and infoLabel.Parent do
        task.wait(0.2)
        infoLabel.Text = string.format(
            "⚡ TAP (CD %.2fs)\n" ..
            "   Seq: %d\n" ..
            "   Source: %s\n" ..
            "   %.0f tap/detik\n\n" ..
            "🥚 HATCH (CD %.1fs)\n" ..
            "   Seq: %d\n" ..
            "   Egg: %s | Count: %d\n\n" ..
            "🛡️ ANTI AFK\n" ..
            "   Interval: %ds\n\n" ..
            "✅ Sequence persist (no reset)",
            TAP_DELAY,
            tapSequence,
            TAP_SOURCE,
            1 / TAP_DELAY,
            HATCH_DELAY,
            hatchSequence,
            HATCH_EGG,
            HATCH_COUNT,
            ANTI_AFK_INTERVAL
        )
    end
end)

local function ToggleMinimize()
    Main.Visible = not Main.Visible
    bubble.Visible = not Main.Visible
end

MinBtn.MouseButton1Click:Connect(ToggleMinimize)
bubble.MouseButton1Click:Connect(ToggleMinimize)

CloseBtn.MouseButton1Click:Connect(function()
    StopAutoTap()
    StopAutoHatch()
    StopAntiAFK()
    screenGui:Destroy()
end)

local isDragging = false
local dragStart = Vector2.new()
local bubbleStartPos = UDim2.new()

bubble.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
        dragStart = input.Position
        bubbleStartPos = bubble.Position
    end
end)

bubble.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        if (input.Position - dragStart).Magnitude > 15 then
            isDragging = true
            local delta = input.Position - dragStart
            local screenSize = workspace.CurrentCamera.ViewportSize
            local newX = math.clamp(bubbleStartPos.X.Offset + delta.X, 0, screenSize.X - 55)
            local newY = math.clamp(bubbleStartPos.Y.Offset + delta.Y, 0, screenSize.Y - 55)
            bubble.Position = UDim2.new(0, newX, 0, newY)
        end
    end
end)

bubble.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

print("[Auto] ✅ Loaded - TAP + HATCH + ANTI AFK")
print("Tap CD:", TAP_DELAY, "s | Hatch CD:", HATCH_DELAY, "s")
print("Anti AFK: every", ANTI_AFK_INTERVAL, "s")