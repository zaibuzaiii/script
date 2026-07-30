local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local TradeAccept = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("TradeAccept")
local TradeRequestResponse = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("TradeRequestResponse")

local function DoTrade()
    local aidil = workspace:FindFirstChild("AIDILNV2")
    if not aidil then
        print("❌ AIDILNV2 tidak ditemukan!")
        return false
    end
    
    local hrp = aidil:FindFirstChild("HumanoidRootPart")
    if not hrp then
        print("❌ HumanoidRootPart tidak ditemukan!")
        return false
    end
    
    local character = player.Character
    if not character then
        character = player.CharacterAdded:Wait()
    end
    
    local playerHrp = character:FindFirstChild("HumanoidRootPart")
    if playerHrp then
        playerHrp.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 3, 2))
        task.wait(0.5)
        print("📍 Teleport ke AIDILNV2!")
    end
    
    local tradePrompt = hrp:FindFirstChild("TradePrompt")
    if not tradePrompt then
        print("❌ TradePrompt tidak ditemukan!")
        return false
    end
    
    if not tradePrompt.Enabled then
        print("❌ TradePrompt disabled!")
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
        print("✅ Trade Prompt fired!")
        statusLabel.Text = "✅ Trade sent!"
        statusLabel.TextColor3 = Color3.fromRGB(60, 200, 80)
        task.wait(1)
        statusLabel.Text = "⚪ Ready"
        statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)
    return true
end

local function AutoAccept()
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
                            print("✅ Auto Accept Trade Request dari User ID: " .. userId)
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

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZAIXPLOIT"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 340, 0, 230)
Main.Position = UDim2.new(0.5, -170, 0.5, -115)
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
SubTitle.Text = "🔄 TRADE + AUTO ACCEPT"
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
    screenGui:Destroy()
end)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -14, 0, 170)
Content.Position = UDim2.new(0, 7, 0, 48)
Content.BackgroundTransparency = 1
Content.Parent = Main

local targetFrame = Instance.new("Frame")
targetFrame.Size = UDim2.new(1, 0, 0, 35)
targetFrame.Position = UDim2.new(0, 0, 0, 5)
targetFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
targetFrame.BackgroundTransparency = 0.1
targetFrame.BorderSizePixel = 1
targetFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
targetFrame.Parent = Content

local targetCorner = Instance.new("UICorner")
targetCorner.CornerRadius = UDim.new(0, 8)
targetCorner.Parent = targetFrame

local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(1, 0, 1, 0)
targetLabel.Position = UDim2.new(0, 10, 0, 0)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "🎯 AIDILNV2"
targetLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
targetLabel.Font = Enum.Font.FredokaOne
targetLabel.TextSize = 14
targetLabel.TextXAlignment = Enum.TextXAlignment.Left
targetLabel.Parent = targetFrame

local tradeBtn = Instance.new("TextButton")
tradeBtn.Size = UDim2.new(0.8, 0, 0, 35)
tradeBtn.Position = UDim2.new(0.1, 0, 0, 45)
tradeBtn.Text = "🔄 TRADE"
tradeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tradeBtn.Font = Enum.Font.GothamBold
tradeBtn.TextSize = 16
tradeBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
tradeBtn.BackgroundTransparency = 0.2
tradeBtn.BorderSizePixel = 1
tradeBtn.BorderColor3 = Color3.fromRGB(60, 180, 60)
tradeBtn.Parent = Content

local tradeCorner = Instance.new("UICorner")
tradeCorner.CornerRadius = UDim.new(0, 8)
tradeCorner.Parent = tradeBtn

tradeBtn.MouseEnter:Connect(function()
    tradeBtn.BackgroundTransparency = 0.05
end)
tradeBtn.MouseLeave:Connect(function()
    tradeBtn.BackgroundTransparency = 0.2
end)

tradeBtn.MouseButton1Click:Connect(function()
    DoTrade()
end)

local autoAcceptBtn = Instance.new("TextButton")
autoAcceptBtn.Size = UDim2.new(0.8, 0, 0, 35)
autoAcceptBtn.Position = UDim2.new(0.1, 0, 0, 85)
autoAcceptBtn.Text = "✅ AUTO ACCEPT"
autoAcceptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoAcceptBtn.Font = Enum.Font.GothamBold
autoAcceptBtn.TextSize = 16
autoAcceptBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
autoAcceptBtn.BackgroundTransparency = 0.2
autoAcceptBtn.BorderSizePixel = 1
autoAcceptBtn.BorderColor3 = Color3.fromRGB(255, 170, 0)
autoAcceptBtn.Parent = Content

local autoAcceptCorner = Instance.new("UICorner")
autoAcceptCorner.CornerRadius = UDim.new(0, 8)
autoAcceptCorner.Parent = autoAcceptBtn

autoAcceptBtn.MouseEnter:Connect(function()
    autoAcceptBtn.BackgroundTransparency = 0.05
end)
autoAcceptBtn.MouseLeave:Connect(function()
    autoAcceptBtn.BackgroundTransparency = 0.2
end)

local autoAcceptEnabled = false
local acceptLoop = nil

local function StartAcceptLoop()
    if acceptLoop then return end
    acceptLoop = task.spawn(function()
        while autoAcceptEnabled do
            AutoAccept()
            task.wait(0.3)
        end
    end)
end

local function StopAcceptLoop()
    autoAcceptEnabled = false
    if acceptLoop then
        task.cancel(acceptLoop)
        acceptLoop = nil
    end
end

autoAcceptBtn.MouseButton1Click:Connect(function()
    autoAcceptEnabled = not autoAcceptEnabled
    if autoAcceptEnabled then
        autoAcceptBtn.Text = "✅ AUTO ACCEPT ON"
        autoAcceptBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
        autoAcceptBtn.BorderColor3 = Color3.fromRGB(60, 200, 80)
        StartAcceptLoop()
        print("✅ AUTO ACCEPT ON")
        statusLabel.Text = "✅ Auto Accept ON"
        statusLabel.TextColor3 = Color3.fromRGB(60, 200, 80)
    else
        autoAcceptBtn.Text = "✅ AUTO ACCEPT"
        autoAcceptBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
        autoAcceptBtn.BorderColor3 = Color3.fromRGB(255, 170, 0)
        StopAcceptLoop()
        print("🔴 AUTO ACCEPT OFF")
        statusLabel.Text = "⚪ Auto Accept OFF"
        statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 16)
statusLabel.Position = UDim2.new(0, 0, 1, -20)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "⚪ Ready"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.FredokaOne
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = Content

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