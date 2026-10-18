-- ============================================
-- DUCK CITY AUTO - BREED BERGANTIAN + PLACE EGG 1-500
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- ===== WAIT REMOTES =====
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
if not Remotes then
    warn("[DuckAuto] Remotes folder tidak ditemukan!")
    return
end

local BreedEgg = Remotes:WaitForChild("BreedEgg", 30)
local HatchAll = Remotes:WaitForChild("HatchAll", 30)
local PlaceEggOnNest = Remotes:WaitForChild("PlaceEggOnNest", 30)

if not BreedEgg or not HatchAll or not PlaceEggOnNest then
    warn("[DuckAuto] Salah satu remote tidak ditemukan!")
    return
end

-- ===== STATE =====
local autoBreed = false
local autoHatch = false
local autoPlaceEgg = false

local breedLoop = nil
local hatchLoop = nil
local placeEggLoop = nil

-- ===== SETTINGS =====
local BREED1_A = 11        -- ← Breed 1: (11, 13)
local BREED1_B = 13
local BREED2_A = 86        -- ← Breed 2: (86, 82)
local BREED2_B = 82

local BREED_DELAY = 1
local HATCH_DELAY = 1
local PLACE_EGG_DELAY = 0.1
local PLACE_EGG_MIN = 1
local PLACE_EGG_MAX = 500

-- ===== AUTO BREED (BERGANTIAN) =====
local function StartAutoBreed()
    if breedLoop then return end
    autoBreed = true
    breedLoop = task.spawn(function()
        local turn = 1
        while autoBreed do
            if turn == 1 then
                pcall(function()
                    BreedEgg:InvokeServer(BREED1_A, BREED1_B)
                end)
                turn = 2
            else
                pcall(function()
                    BreedEgg:InvokeServer(BREED2_A, BREED2_B)
                end)
                turn = 1
            end
            task.wait(BREED_DELAY)
        end
    end)
end

local function StopAutoBreed()
    autoBreed = false
    if breedLoop then
        task.cancel(breedLoop)
        breedLoop = nil
    end
end

-- ===== AUTO HATCH =====
local function StartAutoHatch()
    if hatchLoop then return end
    autoHatch = true
    hatchLoop = task.spawn(function()
        while autoHatch do
            pcall(function()
                HatchAll:InvokeServer()
            end)
            task.wait(HATCH_DELAY)
        end
    end)
end

local function StopAutoHatch()
    autoHatch = false
    if hatchLoop then
        task.cancel(hatchLoop)
        hatchLoop = nil
    end
end

-- ===== AUTO PLACE EGG (LOOP 1-500) =====
local function StartAutoPlaceEgg()
    if placeEggLoop then return end
    autoPlaceEgg = true
    placeEggLoop = task.spawn(function()
        while autoPlaceEgg do
            for i = PLACE_EGG_MIN, PLACE_EGG_MAX do
                if not autoPlaceEgg then break end
                pcall(function()
                    PlaceEggOnNest:InvokeServer(i, 0)
                end)
                task.wait(PLACE_EGG_DELAY)
            end
            if autoPlaceEgg then
                task.wait(0.2)
            end
        end
    end)
end

local function StopAutoPlaceEgg()
    autoPlaceEgg = false
    if placeEggLoop then
        task.cancel(placeEggLoop)
        placeEggLoop = nil
    end
end

-- ===== GUI =====
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("DuckCity_Auto_Safe")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DuckCity_Auto_Safe"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Bubble
local bubble = Instance.new("TextButton")
bubble.Size = UDim2.new(0, 55, 0, 55)
bubble.Position = UDim2.new(0, 20, 0.5, -27)
bubble.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
bubble.Text = "D"
bubble.TextColor3 = Color3.fromRGB(255, 255, 255)
bubble.TextScaled = true
bubble.Font = Enum.Font.FredokaOne
bubble.BorderSizePixel = 0
bubble.Visible = false
bubble.ZIndex = 50
bubble.Parent = screenGui

local bc = Instance.new("UICorner", bubble)
bc.CornerRadius = UDim.new(1, 0)

-- Main
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 240, 0, 230)
Main.Position = UDim2.new(0.5, -120, 0.5, -115)
Main.BackgroundColor3 = Color3.fromRGB(25, 22, 40)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(255, 180, 0)
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true
Main.Parent = screenGui

local mc = Instance.new("UICorner", Main)
mc.CornerRadius = UDim.new(0, 10)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
Header.BorderSizePixel = 0
Header.Parent = Main

local hc = Instance.new("UICorner", Header)
hc.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DUCK AUTO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.FredokaOne
Title.TextSize = 14
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

local minc = Instance.new("UICorner", MinBtn)
minc.CornerRadius = UDim.new(0, 5)

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

local cc = Instance.new("UICorner", CloseBtn)
cc.CornerRadius = UDim.new(0, 5)

-- ===== TOGGLE CREATOR =====
local function CreateToggle(name, yPos, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 42)
    frame.Position = UDim2.new(0, 8, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(35, 30, 55)
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(60, 55, 80)
    frame.Parent = Main

    local fc = Instance.new("UICorner", frame)
    fc.CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -90, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.Font = Enum.Font.FredokaOne
    label.TextSize = 12
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
    switchBg.ZIndex = 15
    switchBg.Parent = frame

    local sc = Instance.new("UICorner", switchBg)
    sc.CornerRadius = UDim.new(0, 13)

    local offLabel = Instance.new("TextLabel")
    offLabel.Size = UDim2.new(0, 24, 1, 0)
    offLabel.Position = UDim2.new(0, 4, 0, 0)
    offLabel.BackgroundTransparency = 1
    offLabel.Text = "OFF"
    offLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    offLabel.Font = Enum.Font.FredokaOne
    offLabel.TextSize = 8
    offLabel.ZIndex = 16
    offLabel.Parent = switchBg

    local onLabel = Instance.new("TextLabel")
    onLabel.Size = UDim2.new(0, 24, 1, 0)
    onLabel.Position = UDim2.new(1, -28, 0, 0)
    onLabel.BackgroundTransparency = 1
    onLabel.Text = "ON"
    onLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    onLabel.Font = Enum.Font.FredokaOne
    onLabel.TextSize = 8
    onLabel.ZIndex = 16
    onLabel.Parent = switchBg

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = UDim2.new(0, 2, 0.5, -11)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Text = ""
    knob.AutoButtonColor = false
    knob.ZIndex = 20
    knob.Parent = switchBg

    local kc = Instance.new("UICorner", knob)
    kc.CornerRadius = UDim.new(1, 0)

    local state = false

    local function UpdateVisual(isOn)
        local targetPos = isOn and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
        TweenService:Create(knob, TweenInfo.new(0.15), {Position = targetPos}):Play()

        if isOn then
            switchBg.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
            switchBg.BorderColor3 = Color3.fromRGB(255, 180, 0)
            offLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
            onLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            switchBg.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
            switchBg.BorderColor3 = Color3.fromRGB(150, 150, 160)
            offLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            onLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
        end
    end

    local function DoToggle()
        state = not state
        UpdateVisual(state)
        if callback then
            pcall(callback, state)
        end
    end

    knob.MouseButton1Click:Connect(DoToggle)
    switchBg.MouseButton1Click:Connect(DoToggle)

    UpdateVisual(false)
end

CreateToggle("AUTO BREED (2x)", 42, function(on)
    if on then StartAutoBreed() else StopAutoBreed() end
end)

CreateToggle("AUTO HATCH", 90, function(on)
    if on then StartAutoHatch() else StopAutoHatch() end
end)

CreateToggle("AUTO PLACE EGG", 138, function(on)
    if on then StartAutoPlaceEgg() else StopAutoPlaceEgg() end
end)

-- Info
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -16, 0, 34)
infoLabel.Position = UDim2.new(0, 8, 0, 186)
infoLabel.BackgroundColor3 = Color3.fromRGB(30, 26, 45)
infoLabel.BorderSizePixel = 0
infoLabel.Text = "Breed: (11,13) <-> (86,82) | Egg: 1-500"
infoLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
infoLabel.Font = Enum.Font.GothamBold
infoLabel.TextSize = 10
infoLabel.Parent = Main

local ic = Instance.new("UICorner", infoLabel)
ic.CornerRadius = UDim.new(0, 6)

-- ===== MINIMIZE =====
local function ToggleMinimize()
    Main.Visible = not Main.Visible
    bubble.Visible = not Main.Visible
end

MinBtn.MouseButton1Click:Connect(ToggleMinimize)
bubble.MouseButton1Click:Connect(ToggleMinimize)

CloseBtn.MouseButton1Click:Connect(function()
    StopAutoBreed()
    StopAutoHatch()
    StopAutoPlaceEgg()
    screenGui:Destroy()
end)

-- Bubble drag
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

print("[DuckAuto] Loaded OK - Breed (11,13)<->(86,82) | Place Egg 1-500")