local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Events = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events")

local CoinLanded = Events:WaitForChild("CoinLanded")

-- ============================================
-- TOGGLE VARIABEL
-- ============================================

local toggles = {
    autoCoin = true,
    autoCoin2Spot = true
}

local loops = {
    autoCoin = nil,
    autoCoin2Spot = nil
}

-- ============================================
-- AUTO COIN (1 REMOTE LAMA)
-- ============================================

local function ThrowOldCoin()
    local args = {
        [1] = 1.3370886103455577,
        [2] = Vector3.new(-1155.1026611328125, 0.7260000109672546, 74.73015594482422),
        [3] = "Helios Coin",
        [4] = Vector3.new(-1160.6558837890625, 0.7260000109672546, 72.45848846435547),
        [6] = 1
    }
    pcall(function()
        CoinLanded:FireServer(unpack(args))
        print("🪙 Old Coin thrown!")
    end)
end

local function StartAutoCoin()
    if loops.autoCoin then return end
    loops.autoCoin = task.spawn(function()
        while toggles.autoCoin do
            ThrowOldCoin()
            task.wait(2)
        end
    end)
end

local function StopAutoCoin()
    if loops.autoCoin then
        task.cancel(loops.autoCoin)
        loops.autoCoin = nil
    end
end

-- ============================================
-- AUTO COIN 2 SPOT (2 REMOTE BERGANTIAN)
-- ============================================

local coin2SpotIndex = 1

local function ThrowNormalCoin()
    local args = {
        [1] = 1.0064544024479687,
        [2] = Vector3.new(-1155.8770751953125, 0.7260000109672546, 87.9044189453125),
        [3] = "Helios Coin",
        [4] = Vector3.new(-1152.5770263671875, 0.7260000109672546, 82.89352416992188),
        [6] = 4
    }
    pcall(function()
        CoinLanded:FireServer(unpack(args))
        print("🪙 Normal Coin thrown!")
    end)
end

local function ThrowVIPCoin()
    local args = {
        [1] = 1.00916329985579,
        [2] = Vector3.new(-1164.35400390625, 0.7260000109672546, -155.0728759765625),
        [3] = "Helios Coin",
        [4] = Vector3.new(-1158.4072265625, 0.7260000109672546, -154.275146484375),
        [6] = 3
    }
    pcall(function()
        CoinLanded:FireServer(unpack(args))
        print("👑 VIP Coin thrown!")
    end)
end

local function StartAutoCoin2Spot()
    if loops.autoCoin2Spot then return end
    loops.autoCoin2Spot = task.spawn(function()
        while toggles.autoCoin2Spot do
            if coin2SpotIndex == 1 then
                ThrowNormalCoin()
                coin2SpotIndex = 2
            else
                ThrowVIPCoin()
                coin2SpotIndex = 1
            end
            task.wait(2)
        end
    end)
end

local function StopAutoCoin2Spot()
    if loops.autoCoin2Spot then
        task.cancel(loops.autoCoin2Spot)
        loops.autoCoin2Spot = nil
    end
end

-- ============================================
-- CONTROL FUNCTIONS
-- ============================================

local function RestartFeature(feature)
    if feature == "autoCoin" then
        StopAutoCoin()
        if toggles.autoCoin then StartAutoCoin() end
    elseif feature == "autoCoin2Spot" then
        StopAutoCoin2Spot()
        if toggles.autoCoin2Spot then StartAutoCoin2Spot() end
    end
end

local function StopFeature(feature)
    if feature == "autoCoin" then StopAutoCoin()
    elseif feature == "autoCoin2Spot" then StopAutoCoin2Spot()
    end
end

-- ============================================
-- START ALL (DEFAULT ON)
-- ============================================

StartAutoCoin()
StartAutoCoin2Spot()

-- ============================================
-- ANTI AFK
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
-- SET HOLD DURATION = 0
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
-- MATIKAN ANTI KICK
-- ============================================

task.spawn(function()
    while true do
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

        task.wait(10)
    end
end)

-- ============================================
-- INSTAN PROMPT
-- ============================================

local function GetAllPrompts()
    local prompts = {}
    local huntSlots = workspace:FindFirstChild("HuntSlots")
    if not huntSlots then return prompts end
    
    for _, slot in ipairs(huntSlots:GetChildren()) do
        if slot.Name:find("HuntSlot_") then
            for _, child in ipairs(slot:GetChildren()) do
                local prompt = child:FindFirstChild("ProximityPrompt")
                if prompt and prompt.Enabled then
                    table.insert(prompts, prompt)
                end
            end
        end
    end
    return prompts
end

local function FirePrompt(prompt)
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
    end)
    return true
end

task.spawn(function()
    while true do
        local prompts = GetAllPrompts()
        if #prompts > 0 then
            for _, prompt in ipairs(prompts) do
                FirePrompt(prompt)
                task.wait(0.2)
            end
        end
        task.wait(1)
    end
end)

-- ============================================
-- TELEPORT (1x SAJA)
-- ============================================

local RequestWorldTeleport = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("RequestWorldTeleport")

local function TeleportToWorld3()
    pcall(function()
        RequestWorldTeleport:FireServer(3)
        print("✅ Teleport ke World 3!")
    end)
end

local function TeleportToVIPPosition()
    local character = player.Character
    if not character then
        character = player.CharacterAdded:Wait()
    end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(Vector3.new(-1152, 4, 52))
        print("✅ Teleport ke VIP Position (-1152, 4, 52)!")
    end
end

task.wait(1)
TeleportToWorld3()
task.wait(3)
TeleportToVIPPosition()

-- ============================================
-- GUI
-- ============================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZAIXPLOIT"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 200)
Main.Position = UDim2.new(0.5, -160, 0.5, -100)
Main.BackgroundColor3 = Color3.fromRGB(10, 8, 20)
Main.BackgroundTransparency = 0
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(60, 200, 80)
Main.ClipsDescendants = true
Main.Active = true
Main.Draggable = true
Main.Selectable = true
Main.Parent = screenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 8, 20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 20, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 8, 20))
})
MainGradient.Rotation = 45
MainGradient.Parent = Main

local Glow = Instance.new("UIStroke")
Glow.Color = Color3.fromRGB(60, 200, 80)
Glow.Transparency = 0.3
Glow.Thickness = 1.5
Glow.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = Color3.fromRGB(20, 18, 35)
Header.BackgroundTransparency = 0.3
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 18, 35)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 35, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 18, 35))
})
HeaderGradient.Rotation = 90
HeaderGradient.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 0, 16)
Title.Position = UDim2.new(0, 12, 0, 3)
Title.BackgroundTransparency = 1
Title.Text = "⭐ ZAIXPLOIT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.LuckiestGuy
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -60, 0, 13)
SubTitle.Position = UDim2.new(0, 12, 0, 22)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "🪙 AUTO COIN"
SubTitle.TextColor3 = Color3.fromRGB(255, 200, 50)
SubTitle.Font = Enum.Font.FredokaOne
SubTitle.TextSize = 10
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = Header

local isMinimized = false
local originalSize = Main.Size

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 22, 0, 22)
MinBtn.Position = UDim2.new(1, -52, 0, 9)
MinBtn.Text = "➖"
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
MinBtn.BackgroundTransparency = 0.3
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.BorderSizePixel = 0
MinBtn.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

MinBtn.MouseEnter:Connect(function()
    MinBtn.BackgroundTransparency = 0.1
end)
MinBtn.MouseLeave:Connect(function()
    MinBtn.BackgroundTransparency = 0.3
end)

MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        Main.Size = UDim2.new(0, 320, 0, 42)
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
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -26, 0, 9)
CloseBtn.Text = "❌"
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.BackgroundTransparency = 0.3
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    CloseBtn.BackgroundTransparency = 0.1
end)
CloseBtn.MouseLeave:Connect(function()
    CloseBtn.BackgroundTransparency = 0.3
end)

CloseBtn.MouseButton1Click:Connect(function()
    StopAutoCoin()
    StopAutoCoin2Spot()
    screenGui:Destroy()
end)

-- ============================================
-- CONTENT
-- ============================================

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -14, 0, 140)
Content.Position = UDim2.new(0, 7, 0, 48)
Content.BackgroundTransparency = 1
Content.Parent = Main

local function CreateToggleButton(name, label, y)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.Position = UDim2.new(0, 0, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(60, 60, 80)
    frame.Parent = Content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(0.5, 0, 1, 0)
    text.Position = UDim2.new(0, 10, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = label
    text.TextColor3 = Color3.fromRGB(200, 200, 210)
    text.Font = Enum.Font.FredokaOne
    text.TextSize = 12
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0.2, 0, 1, 0)
    status.Position = UDim2.new(0.6, 0, 0, 0)
    status.BackgroundTransparency = 1
    status.Text = "✅ ON"
    status.TextColor3 = Color3.fromRGB(60, 200, 80)
    status.Font = Enum.Font.FredokaOne
    status.TextSize = 11
    status.TextXAlignment = Enum.TextXAlignment.Center
    status.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.2, 0, 0.7, 0)
    btn.Position = UDim2.new(0.8, 0, 0.5, -12)
    btn.Text = "⏹ OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(180, 60, 60)
    btn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundTransparency = 0.05
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundTransparency = 0.2
    end)
    
    btn.MouseButton1Click:Connect(function()
        toggles[name] = not toggles[name]
        if toggles[name] then
            status.Text = "✅ ON"
            status.TextColor3 = Color3.fromRGB(60, 200, 80)
            btn.Text = "⏹ OFF"
            btn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            btn.BorderColor3 = Color3.fromRGB(180, 60, 60)
            RestartFeature(name)
        else
            status.Text = "❌ OFF"
            status.TextColor3 = Color3.fromRGB(255, 50, 50)
            btn.Text = "▶ ON"
            btn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
            btn.BorderColor3 = Color3.fromRGB(60, 180, 60)
            StopFeature(name)
        end
        UpdateStatus()
    end)
    
    return status, btn
end

local statuses = {}
local buttons = {}

statuses.autoCoin, buttons.autoCoin = CreateToggleButton("autoCoin", "🪙 AUTO COIN", 2)
statuses.autoCoin2Spot, buttons.autoCoin2Spot = CreateToggleButton("autoCoin2Spot", "🪙 AUTO COIN 2 SPOT", 42)

-- ============================================
-- STATUS
-- ============================================

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 14)
statusLabel.Position = UDim2.new(0, 0, 1, -5)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🟢 2 Running"
statusLabel.TextColor3 = Color3.fromRGB(60, 200, 80)
statusLabel.Font = Enum.Font.FredokaOne
statusLabel.TextSize = 10
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = Content

local function UpdateStatus()
    local count = 0
    if toggles.autoCoin then count = count + 1 end
    if toggles.autoCoin2Spot then count = count + 1 end
    
    if count == 2 then
        statusLabel.Text = "🟢 2 Running"
        statusLabel.TextColor3 = Color3.fromRGB(60, 200, 80)
    elseif count == 1 then
        statusLabel.Text = "🟡 1 Running"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    else
        statusLabel.Text = "🔴 All Stopped"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end

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
        Main.BackgroundTransparency = 0
    end
end

UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputChanged:Connect(onInputChanged)
UserInputService.InputEnded:Connect(onInputEnded)

print("═══════════════════════════════════")
print("✅ ZAIXPLOIT RUNNING")
print("📌 AUTO COIN (ON)")
print("📌 AUTO COIN 2 SPOT (ON)")
print("📌 ANTI AFK (Backend)")
print("📌 INSTAN PROMPT (LOOP)")
print("📌 TELEPORT: World 3 → VIP (1x SAJA)")
print("📌 ANTI KICK: Dimatikan (LOOP)")
print("📌 HoldDuration=0 (LOOP)")
print("═══════════════════════════════════")