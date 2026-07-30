local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local ToggleFavorite = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("ToggleFavorite")

local function DoToggle()
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then
        print("❌ Backpack tidak ditemukan!")
        return false
    end
    
    local item = backpack:FindFirstChild("Astral Mount Olympus x2")
    if not item then
        print("❌ Item 'Astral Mount Olympus x2' tidak ditemukan di backpack!")
        return false
    end
    
    local args = { item }
    pcall(function()
        ToggleFavorite:FireServer(unpack(args))
        print("⭐ Toggle Favorite executed!")
        statusLabel.Text = "✅ Toggled!"
        statusLabel.TextColor3 = Color3.fromRGB(60, 200, 80)
        task.wait(1)
        statusLabel.Text = "⚪ Ready"
        statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)
    return true
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZAIXPLOIT"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 300, 0, 150)
Main.Position = UDim2.new(0.5, -150, 0.5, -75)
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
SubTitle.Text = "⭐ TOGGLE FAVORITE"
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
        Main.Size = UDim2.new(0, 300, 0, 42)
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
Content.Size = UDim2.new(1, -14, 0, 90)
Content.Position = UDim2.new(0, 7, 0, 48)
Content.BackgroundTransparency = 1
Content.Parent = Main

local itemFrame = Instance.new("Frame")
itemFrame.Size = UDim2.new(1, 0, 0, 35)
itemFrame.Position = UDim2.new(0, 0, 0, 5)
itemFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
itemFrame.BackgroundTransparency = 0.1
itemFrame.BorderSizePixel = 1
itemFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
itemFrame.Parent = Content

local itemCorner = Instance.new("UICorner")
itemCorner.CornerRadius = UDim.new(0, 8)
itemCorner.Parent = itemFrame

local itemLabel = Instance.new("TextLabel")
itemLabel.Size = UDim2.new(1, 0, 1, 0)
itemLabel.Position = UDim2.new(0, 10, 0, 0)
itemLabel.BackgroundTransparency = 1
itemLabel.Text = "⭐ Astral Mount Olympus x2"
itemLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
itemLabel.Font = Enum.Font.FredokaOne
itemLabel.TextSize = 13
itemLabel.TextXAlignment = Enum.TextXAlignment.Left
itemLabel.Parent = itemFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8, 0, 0, 35)
toggleBtn.Position = UDim2.new(0.1, 0, 0, 45)
toggleBtn.Text = "⭐ TOGGLE"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
toggleBtn.BackgroundTransparency = 0.2
toggleBtn.BorderSizePixel = 1
toggleBtn.BorderColor3 = Color3.fromRGB(60, 180, 60)
toggleBtn.Parent = Content

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

toggleBtn.MouseEnter:Connect(function()
    toggleBtn.BackgroundTransparency = 0.05
end)
toggleBtn.MouseLeave:Connect(function()
    toggleBtn.BackgroundTransparency = 0.2
end)

toggleBtn.MouseButton1Click:Connect(function()
    DoToggle()
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