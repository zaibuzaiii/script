local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

local Events = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events")
local CoinLanded = Events:WaitForChild("CoinLanded")
local SellAll = Events:WaitForChild("SellAll")
local RequestUpgrade = Events:WaitForChild("RequestUpgrade")
local TradeRequestResponse = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("TradeRequestResponse")
local TradeAccept = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("TradeAccept")
local TradeAddItem = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("TradeAddItem")

local coinList = {
    "Basic Coin", "Copper Coin", "Fire Coin", "Volt Coin", "Aether Coin",
    "Starlight Coin", "Galaxy Coin", "Void Coin", "Chronos Coin", "Eclipse Coin",
    "Mirage Coin", "Obsidian Coin", "Tempest Coin", "Soul Coin", "Paradox Coin",
    "Miracle Coin", "Nexus Coin", "Apex Coin", "Infinity Coin", "Grace Coin",
    "Dominion Coin", "Empyrean Coin", "Atlas Coin", "Judgement Coin", "Hercules Coin",
    "Helios Coin", "Nyx Coin", "Titan Coin", "Zeus Coin", "Phoenix Coin"
}

local selectedCoin = "Phoenix Coin"
local autoCoin = true
local coinLoop = nil
local autoSellAll = false
local sellAllLoop = nil
local autoUpgrade = false
local upgradeLoop = nil
local upgradeSettings = {
    ["Luck Multiplier"] = false,
    ["Value Multiplier"] = false,
    ["Throw Speed"] = false
}
local autoAccept = true
local acceptLoop = nil
local acceptDelay = 0.5
local autoAcceptRemote = true
local acceptRemoteLoop = nil
local autoAddRandomItem = false
local addRandomItemLoop = nil
local antiAFK = true
local antiAFKLoop = nil
local currentTab = "MAIN"

-- ===== NICKNAME COLOR PRESETS (30+ WARNA) =====
local nicknameColors = {
    ["🔴 Merah"] = Color3.fromRGB(255, 0, 0),
    ["🟢 Hijau"] = Color3.fromRGB(0, 255, 0),
    ["🔵 Biru"] = Color3.fromRGB(0, 150, 255),
    ["🟡 Emas"] = Color3.fromRGB(255, 215, 0),
    ["🟣 Ungu"] = Color3.fromRGB(200, 0, 255),
    ["⚪ Putih"] = Color3.fromRGB(255, 255, 255),
    ["🟠 Oranye"] = Color3.fromRGB(255, 165, 0),
    ["🌸 Pink"] = Color3.fromRGB(255, 105, 180),
    ["❤️ Merah Tua"] = Color3.fromRGB(139, 0, 0),
    ["🍏 Hijau Muda"] = Color3.fromRGB(144, 238, 144),
    ["💙 Biru Muda"] = Color3.fromRGB(173, 216, 230),
    ["💛 Kuning"] = Color3.fromRGB(255, 255, 0),
    ["🧡 Jingga"] = Color3.fromRGB(255, 140, 0),
    ["💗 Pink Muda"] = Color3.fromRGB(255, 182, 193),
    ["🤍 Abu-abu"] = Color3.fromRGB(128, 128, 128),
    ["🖤 Hitam"] = Color3.fromRGB(0, 0, 0),
    ["💜 Ungu Muda"] = Color3.fromRGB(218, 112, 214),
    ["💚 Toska"] = Color3.fromRGB(0, 255, 127),
    ["💛 Emas Tua"] = Color3.fromRGB(184, 134, 11),
    ["🧡 Salmon"] = Color3.fromRGB(250, 128, 114),
    ["💖 Pink Cerah"] = Color3.fromRGB(255, 20, 147),
    ["💙 Biru Laut"] = Color3.fromRGB(0, 0, 139),
    ["💚 Zamrud"] = Color3.fromRGB(80, 200, 120),
    ["🤎 Coklat"] = Color3.fromRGB(139, 69, 19),
    ["💜 Nila"] = Color3.fromRGB(75, 0, 130),
    ["💛 Madu"] = Color3.fromRGB(255, 215, 0),
    ["🧡 Karamel"] = Color3.fromRGB(200, 120, 50),
    ["💗 Mawar"] = Color3.fromRGB(255, 80, 120),
    ["💚 Daun"] = Color3.fromRGB(34, 139, 34),
    ["💙 Langit"] = Color3.fromRGB(135, 206, 235),
    ["❤️ Maroon"] = Color3.fromRGB(128, 0, 0),
    ["💜 Lavender"] = Color3.fromRGB(230, 230, 250),
    ["🧡 Coral"] = Color3.fromRGB(255, 127, 80),
    ["💚 Olive"] = Color3.fromRGB(128, 128, 0),
    ["💙 Navy"] = Color3.fromRGB(0, 0, 128),
    ["🖤 Dark"] = Color3.fromRGB(30, 30, 30),
}

local selectedNicknameColor = Color3.fromRGB(255, 215, 0)

local function ApplyNicknameColor(color)
    local character = player.Character
    if not character or not character.Parent then return end
    local head = character:FindFirstChild("Head")
    if head then
        local title = head:FindFirstChild("title")
        if title then
            local usernameLabel = title:FindFirstChild("Username")
            if usernameLabel then
                pcall(function()
                    usernameLabel.TextColor3 = color
                    print("✅ Nickname color changed!")
                end)
            end
        end
    end
end

-- ===== ANTI AFK =====
local function StartAntiAFK()
    if antiAFKLoop then return end
    antiAFKLoop = task.spawn(function()
        while antiAFK do
            task.wait(45)
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                VirtualUser:ClickButton1(Vector2.new())
            end)
        end
    end)
end

local function StopAntiAFK()
    antiAFK = false
    if antiAFKLoop then
        task.cancel(antiAFKLoop)
        antiAFKLoop = nil
    end
end

StartAntiAFK()

pcall(function()
    local antiKick = player.PlayerScripts:FindFirstChild("Scripts")
    if antiKick then
        antiKick = antiKick:FindFirstChild("AntiKickScript")
        if antiKick then antiKick:Destroy() end
    end
end)

pcall(function()
    local remotes = {"AntiKickReconnect", "SetAFKSafe", "StartAFKSafe"}
    for _, name in ipairs(remotes) do
        local remote = ReplicatedStorage:FindFirstChild(name)
        if remote then remote:Destroy() end
    end
end)

-- ===== COIN =====
local function ThrowCoin()
    local args = {
        3.00,
        Vector3.new(-1162.6304931640625, 0.7260000109672546, 89.36738586425781),
        selectedCoin,
        Vector3.new(-1156.7032470703125, 0.7260000109672546, 88.43637084960938),
        [6] = 1
    }
    pcall(function()
        CoinLanded:FireServer(unpack(args))
        print(" " .. selectedCoin .. " thrown!")
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

-- ===== SELL ALL =====
local function DoSellAll()
    pcall(function()
        SellAll:FireServer()
        print("💰 Sell All executed!")
    end)
end

local function StartSellAllLoop()
    if sellAllLoop then return end
    sellAllLoop = task.spawn(function()
        while autoSellAll do
            DoSellAll()
            task.wait(3)
        end
    end)
end

local function StopSellAllLoop()
    autoSellAll = false
    if sellAllLoop then
        task.cancel(sellAllLoop)
        sellAllLoop = nil
    end
end

-- ===== UPGRADE =====
local function DoUpgrade()
    for upgradeName, isEnabled in pairs(upgradeSettings) do
        if isEnabled then
            pcall(function()
                RequestUpgrade:FireServer(upgradeName)
                print("⚡ Upgraded: " .. upgradeName)
            end)
            task.wait(0.3)
        end
    end
end

local function StartUpgradeLoop()
    if upgradeLoop then return end
    upgradeLoop = task.spawn(function()
        while autoUpgrade do
            DoUpgrade()
            task.wait(0.1)
        end
    end)
end

local function StopUpgradeLoop()
    autoUpgrade = false
    if upgradeLoop then
        task.cancel(upgradeLoop)
        upgradeLoop = nil
    end
end

-- ===== PROXIMITY PROMPT INSTAN (LOOP + AUTO CLICK) =====
-- 🔄 LOOP CEK TIAP 2 DETIK
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            for _, prompt in pairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    prompt.HoldDuration = 0
                    prompt.RequiresLineOfSight = false
                end
            end
        end)
    end
end)

-- 📌 AUTO KLIK SAAT PROMPT MUNCUL
ProximityPromptService.PromptShown:Connect(function(prompt)
    task.wait(0.05)
    pcall(function()
        prompt.HoldDuration = 0
        prompt:Hold()
        print("✅ Prompt instan: " .. prompt.Name)
    end)
end)

-- 📌 CEK PROMPT YANG SUDAH ADA SEBELUM SCRIPT JALAN
task.wait(1)
pcall(function()
    for _, prompt in pairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            prompt.HoldDuration = 0
            prompt.RequiresLineOfSight = false
        end
    end
end)

-- 📌 CEK PROMPT BARU YANG MUNCUL
workspace.DescendantAdded:Connect(function(desc)
    task.wait(0.1)
    if desc:IsA("ProximityPrompt") then
        pcall(function()
            desc.HoldDuration = 0
            desc.RequiresLineOfSight = false
            print("✅ Prompt baru ditemukan: " .. desc.Name)
        end)
    end
end)

-- ===== TELEPORT =====
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
            hrp.CFrame = CFrame.new(Vector3.new(-1180, 72, 70))
            print("✅ Teleport ke VIP Position!")
        end)
    end
end

task.wait(1)
task.wait(3)
TeleportToVIPPosition()

-- ===== TRADE =====
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

local function StartAcceptLoop()
    if acceptLoop then return end
    acceptLoop = task.spawn(function()
        while autoAccept do
            AutoAcceptUI()
            task.wait(acceptDelay)
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

local function IsWeReady()
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
    local yourOffer = tradeContainer:FindFirstChild("YourOffer")
    if not yourOffer then return false end
    local profile = yourOffer:FindFirstChild("Profile")
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
            if not IsWeReady() then
                pcall(function()
                    TradeAccept:FireServer()
                    print("⚡ Auto Accept Remote - Jaga status hijau!")
                end)
                task.wait(0.3)
            end
            task.wait(0.2)
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

local function StartAddRandomItemLoop()
    if addRandomItemLoop then return end
    addRandomItemLoop = task.spawn(function()
        while autoAddRandomItem do
            local randomIndex = math.random(1, 10000)
            pcall(function()
                TradeAddItem:FireServer(randomIndex)
                print("📦 Auto Add Random Item: " .. randomIndex)
            end)
            task.wait(0)
        end
    end)
end

local function StopAddRandomItemLoop()
    autoAddRandomItem = false
    if addRandomItemLoop then
        task.cancel(addRandomItemLoop)
        addRandomItemLoop = nil
    end
end

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BEGE_IDN"
screenGui.ResetOnSpawn = false

local playerGui = player:FindFirstChild("PlayerGui")
if not playerGui then
    playerGui = player:WaitForChild("PlayerGui")
end
screenGui.Parent = playerGui

-- MAIN UI
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 380, 0, 300)
Main.Position = UDim2.new(0.5, -190, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(20, 18, 35)
Main.BackgroundTransparency = 0.1
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(255, 50, 50)
Main.ClipsDescendants = true
Main.Active = true
Main.Draggable = true
Main.Selectable = true
Main.Visible = true
Main.Parent = screenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local Glow = Instance.new("UIStroke")
Glow.Color = Color3.fromRGB(255, 50, 50)
Glow.Transparency = 0.2
Glow.Thickness = 2
Glow.Parent = Main

-- HEADER
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 36)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = Color3.fromRGB(30, 25, 50)
Header.BackgroundTransparency = 0.05
Header.BorderSizePixel = 0
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 0, 16)
Title.Position = UDim2.new(0, 10, 0, 2)
Title.BackgroundTransparency = 1
Title.Text = "🔥 BEGE IDN"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.LuckiestGuy
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -60, 0, 12)
SubTitle.Position = UDim2.new(0, 10, 0, 20)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "THROW A COIN"
SubTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
SubTitle.Font = Enum.Font.FredokaOne
SubTitle.TextSize = 10
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = Header

-- ===== BUBBLE - KIRI ATAS =====
local bubble = Instance.new("Frame")
bubble.Size = UDim2.new(0, 55, 0, 55)
bubble.Position = UDim2.new(0, 10, 0, 10)
bubble.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bubble.BackgroundTransparency = 0.3
bubble.BorderSizePixel = 3
bubble.BorderColor3 = Color3.fromRGB(255, 0, 0)
bubble.Visible = false
bubble.Active = true
bubble.ZIndex = 50
bubble.ClipsDescendants = false
bubble.Parent = screenGui

local bubbleCorner = Instance.new("UICorner")
bubbleCorner.CornerRadius = UDim.new(1, 0)
bubbleCorner.Parent = bubble

local bubbleGlow = Instance.new("UIStroke")
bubbleGlow.Color = Color3.fromRGB(255, 50, 50)
bubbleGlow.Transparency = 0.3
bubbleGlow.Thickness = 2
bubbleGlow.Parent = bubble

local bubbleIcon = Instance.new("ImageLabel")
bubbleIcon.Size = UDim2.new(0.85, 0, 0.85, 0)
bubbleIcon.Position = UDim2.new(0.075, 0, 0.075, 0)
bubbleIcon.BackgroundTransparency = 1
bubbleIcon.Image = "rbxassetid://134769830476755"
bubbleIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
bubbleIcon.ScaleType = Enum.ScaleType.Fit
bubbleIcon.ZIndex = 60
bubbleIcon.Parent = bubble

-- VARIABLES UNTUK DRAG + CLICK
local isDraggingBubble = false
local dragStartPos = Vector2.new()
local dragStartTime = 0
local bubbleStartPos = UDim2.new()
local hasMoved = false

-- FUNGSI TOGGLE MINIMIZE
local isMinimized = false
local function ToggleMinimize()
    isMinimized = not isMinimized
    if isMinimized then
        Main.Visible = false
        bubble.Visible = true
    else
        Main.Visible = true
        bubble.Visible = false
    end
end

-- EVENT LISTENER BUBBLE
local function OnBubbleInputBegan(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingBubble = false
        hasMoved = false
        dragStartPos = input.Position
        dragStartTime = tick()
        bubbleStartPos = bubble.Position
        bubble.BackgroundTransparency = 0.1
    end
end

local function OnBubbleInputChanged(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        local distance = (input.Position - dragStartPos).Magnitude
        
        if distance > 30 then
            isDraggingBubble = true
            hasMoved = true
            local delta = input.Position - dragStartPos
            local screenSize = workspace.CurrentCamera.ViewportSize
            
            local targetX = math.clamp(bubbleStartPos.X.Offset + delta.X, 0, screenSize.X - 55)
            local targetY = math.clamp(bubbleStartPos.Y.Offset + delta.Y, 0, screenSize.Y - 55)
            
            local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            local goal = {Position = UDim2.new(0, targetX, 0, targetY)}
            local tween = TweenService:Create(bubble, tweenInfo, goal)
            tween:Play()
        end
    end
end

local function OnBubbleInputEnded(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        bubble.BackgroundTransparency = 0.3
        
        if not isDraggingBubble and not hasMoved and (tick() - dragStartTime) < 0.3 then
            ToggleMinimize()
        end
        
        isDraggingBubble = false
        hasMoved = false
    end
end

bubble.InputBegan:Connect(OnBubbleInputBegan)
bubble.InputChanged:Connect(OnBubbleInputChanged)
bubble.InputEnded:Connect(OnBubbleInputEnded)

-- TOMBOL MINIMIZE
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 26, 0, 26)
MinBtn.Position = UDim2.new(1, -48, 0, 5)
MinBtn.Text = "➖"
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
MinBtn.BackgroundTransparency = 0.2
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.BorderSizePixel = 0
MinBtn.ZIndex = 30
MinBtn.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 5)
MinCorner.Parent = MinBtn

MinBtn.MouseEnter:Connect(function()
    MinBtn.BackgroundTransparency = 0.05
end)
MinBtn.MouseLeave:Connect(function()
    MinBtn.BackgroundTransparency = 0.2
end)
MinBtn.MouseButton1Click:Connect(ToggleMinimize)

-- TOMBOL CLOSE
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -26, 0, 5)
CloseBtn.Text = "✖"
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.BackgroundTransparency = 0.2
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 15
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 30
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    CloseBtn.BackgroundTransparency = 0.05
end)
CloseBtn.MouseLeave:Connect(function()
    CloseBtn.BackgroundTransparency = 0.2
end)
CloseBtn.MouseButton1Click:Connect(function()
    StopCoinLoop()
    StopSellAllLoop()
    StopUpgradeLoop()
    StopAcceptLoop()
    StopAcceptRemoteLoop()
    StopAddRandomItemLoop()
    StopAntiAFK()
    screenGui:Destroy()
end)

-- TAB
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -10, 0, 30)
TabContainer.Position = UDim2.new(0, 5, 0, 40)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Main

local TabMain = Instance.new("TextButton")
TabMain.Size = UDim2.new(0.23, -2, 1, 0)
TabMain.Position = UDim2.new(0, 0, 0, 0)
TabMain.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
TabMain.BackgroundTransparency = 0.3
TabMain.BorderSizePixel = 1
TabMain.BorderColor3 = Color3.fromRGB(255, 0, 0)
TabMain.Text = "MAIN"
TabMain.TextColor3 = Color3.fromRGB(255, 255, 255)
TabMain.Font = Enum.Font.GothamBold
TabMain.TextSize = 10
TabMain.ZIndex = 20
TabMain.Parent = TabContainer

local TabMainCorner = Instance.new("UICorner")
TabMainCorner.CornerRadius = UDim.new(0, 5)
TabMainCorner.Parent = TabMain

local TabUpgrade = Instance.new("TextButton")
TabUpgrade.Size = UDim2.new(0.23, -2, 1, 0)
TabUpgrade.Position = UDim2.new(0.23, 4, 0, 0)
TabUpgrade.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
TabUpgrade.BackgroundTransparency = 0.3
TabUpgrade.BorderSizePixel = 1
TabUpgrade.BorderColor3 = Color3.fromRGB(60, 60, 80)
TabUpgrade.Text = "UPGRADE"
TabUpgrade.TextColor3 = Color3.fromRGB(200, 200, 210)
TabUpgrade.Font = Enum.Font.GothamBold
TabUpgrade.TextSize = 9
TabUpgrade.ZIndex = 20
TabUpgrade.Parent = TabContainer

local TabUpgradeCorner = Instance.new("UICorner")
TabUpgradeCorner.CornerRadius = UDim.new(0, 5)
TabUpgradeCorner.Parent = TabUpgrade

local TabTrade = Instance.new("TextButton")
TabTrade.Size = UDim2.new(0.23, -2, 1, 0)
TabTrade.Position = UDim2.new(0.46, 8, 0, 0)
TabTrade.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
TabTrade.BackgroundTransparency = 0.3
TabTrade.BorderSizePixel = 1
TabTrade.BorderColor3 = Color3.fromRGB(60, 60, 80)
TabTrade.Text = "TRADE"
TabTrade.TextColor3 = Color3.fromRGB(200, 200, 210)
TabTrade.Font = Enum.Font.GothamBold
TabTrade.TextSize = 10
TabTrade.ZIndex = 20
TabTrade.Parent = TabContainer

local TabTradeCorner = Instance.new("UICorner")
TabTradeCorner.CornerRadius = UDim.new(0, 5)
TabTradeCorner.Parent = TabTrade

local TabMisc = Instance.new("TextButton")
TabMisc.Size = UDim2.new(0.23, -2, 1, 0)
TabMisc.Position = UDim2.new(0.69, 12, 0, 0)
TabMisc.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
TabMisc.BackgroundTransparency = 0.3
TabMisc.BorderSizePixel = 1
TabMisc.BorderColor3 = Color3.fromRGB(60, 60, 80)
TabMisc.Text = "MISC"
TabMisc.TextColor3 = Color3.fromRGB(200, 200, 210)
TabMisc.Font = Enum.Font.GothamBold
TabMisc.TextSize = 10
TabMisc.ZIndex = 20
TabMisc.Parent = TabContainer

local TabMiscCorner = Instance.new("UICorner")
TabMiscCorner.CornerRadius = UDim.new(0, 5)
TabMiscCorner.Parent = TabMisc

-- CONTENT
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -14, 0, 185)
Content.Position = UDim2.new(0, 7, 0, 74)
Content.BackgroundTransparency = 0.8
Content.BackgroundColor3 = Color3.fromRGB(15, 13, 30)
Content.Parent = Main

-- MAIN CONTENT
local MainContent = Instance.new("Frame")
MainContent.Size = UDim2.new(1, 0, 1, 0)
MainContent.Position = UDim2.new(0, 0, 0, 0)
MainContent.BackgroundTransparency = 1
MainContent.Visible = true
MainContent.Parent = Content

-- COIN TYPE
local coinTypeFrame = Instance.new("Frame")
coinTypeFrame.Size = UDim2.new(1, 0, 0, 34)
coinTypeFrame.Position = UDim2.new(0, 0, 0, 2)
coinTypeFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
coinTypeFrame.BackgroundTransparency = 0.2
coinTypeFrame.BorderSizePixel = 1
coinTypeFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
coinTypeFrame.Parent = MainContent

local coinTypeCorner = Instance.new("UICorner")
coinTypeCorner.CornerRadius = UDim.new(0, 6)
coinTypeCorner.Parent = coinTypeFrame

local coinTypeLabel = Instance.new("TextLabel")
coinTypeLabel.Size = UDim2.new(0, 55, 1, 0)
coinTypeLabel.Position = UDim2.new(0, 8, 0, 0)
coinTypeLabel.BackgroundTransparency = 1
coinTypeLabel.Text = "COIN:"
coinTypeLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
coinTypeLabel.Font = Enum.Font.FredokaOne
coinTypeLabel.TextSize = 10
coinTypeLabel.TextXAlignment = Enum.TextXAlignment.Left
coinTypeLabel.Parent = coinTypeFrame

local coinTypeBox = Instance.new("TextBox")
coinTypeBox.Size = UDim2.new(0, 130, 0, 22)
coinTypeBox.Position = UDim2.new(0, 62, 0.5, -11)
coinTypeBox.BackgroundColor3 = Color3.fromRGB(15, 13, 30)
coinTypeBox.BackgroundTransparency = 0.3
coinTypeBox.BorderSizePixel = 2
coinTypeBox.BorderColor3 = Color3.fromRGB(255, 50, 50)
coinTypeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
coinTypeBox.Font = Enum.Font.GothamBold
coinTypeBox.TextSize = 11
coinTypeBox.Text = "Phoenix Coin"
coinTypeBox.TextXAlignment = Enum.TextXAlignment.Left
coinTypeBox.ZIndex = 15
coinTypeBox.Parent = coinTypeFrame

local coinTypeBoxCorner = Instance.new("UICorner")
coinTypeBoxCorner.CornerRadius = UDim.new(0, 5)
coinTypeBoxCorner.Parent = coinTypeBox

coinTypeBox:GetPropertyChangedSignal("Text"):Connect(function()
    if coinTypeBox.Text ~= "" then
        selectedCoin = coinTypeBox.Text
        print(" Coin changed to: " .. selectedCoin)
    end
end)

-- AUTO COIN
local coinFrame = Instance.new("Frame")
coinFrame.Size = UDim2.new(1, 0, 0, 34)
coinFrame.Position = UDim2.new(0, 0, 0, 40)
coinFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
coinFrame.BackgroundTransparency = 0.2
coinFrame.BorderSizePixel = 1
coinFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
coinFrame.Parent = MainContent

local coinCorner = Instance.new("UICorner")
coinCorner.CornerRadius = UDim.new(0, 6)
coinCorner.Parent = coinFrame

local coinLabel = Instance.new("TextLabel")
coinLabel.Size = UDim2.new(0, 120, 1, 0)
coinLabel.Position = UDim2.new(0, 10, 0, 0)
coinLabel.BackgroundTransparency = 1
coinLabel.Text = "AUTO COIN"
coinLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
coinLabel.Font = Enum.Font.FredokaOne
coinLabel.TextSize = 11
coinLabel.TextXAlignment = Enum.TextXAlignment.Left
coinLabel.Parent = coinFrame

local coinSwitchBg = Instance.new("Frame")
coinSwitchBg.Size = UDim2.new(0, 55, 0, 24)
coinSwitchBg.Position = UDim2.new(1, -65, 0.5, -12)
coinSwitchBg.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
coinSwitchBg.BackgroundTransparency = 0.2
coinSwitchBg.BorderSizePixel = 2
coinSwitchBg.BorderColor3 = Color3.fromRGB(255, 50, 50)
coinSwitchBg.Parent = coinFrame

local coinSwitchCorner = Instance.new("UICorner")
coinSwitchCorner.CornerRadius = UDim.new(0, 12)
coinSwitchCorner.Parent = coinSwitchBg

local coinOffLabel = Instance.new("TextLabel")
coinOffLabel.Size = UDim2.new(0, 20, 1, 0)
coinOffLabel.Position = UDim2.new(0, 4, 0, 0)
coinOffLabel.BackgroundTransparency = 1
coinOffLabel.Text = "OFF"
coinOffLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
coinOffLabel.Font = Enum.Font.FredokaOne
coinOffLabel.TextSize = 8
coinOffLabel.TextXAlignment = Enum.TextXAlignment.Center
coinOffLabel.Parent = coinSwitchBg

local coinOnLabel = Instance.new("TextLabel")
coinOnLabel.Size = UDim2.new(0, 20, 1, 0)
coinOnLabel.Position = UDim2.new(1, -24, 0, 0)
coinOnLabel.BackgroundTransparency = 1
coinOnLabel.Text = "ON"
coinOnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
coinOnLabel.Font = Enum.Font.FredokaOne
coinOnLabel.TextSize = 8
coinOnLabel.TextXAlignment = Enum.TextXAlignment.Center
coinOnLabel.Parent = coinSwitchBg

local coinSwitchBtn = Instance.new("TextButton")
coinSwitchBtn.Size = UDim2.new(0, 20, 0, 20)
coinSwitchBtn.Position = UDim2.new(1, -24, 0.5, -10)
coinSwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
coinSwitchBtn.BackgroundTransparency = 0.05
coinSwitchBtn.BorderSizePixel = 2
coinSwitchBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
coinSwitchBtn.Text = ""
coinSwitchBtn.ZIndex = 20
coinSwitchBtn.Parent = coinSwitchBg

local coinSwitchBtnCorner = Instance.new("UICorner")
coinSwitchBtnCorner.CornerRadius = UDim.new(0, 10)
coinSwitchBtnCorner.Parent = coinSwitchBtn

-- SELL ALL
local sellAllFrame = Instance.new("Frame")
sellAllFrame.Size = UDim2.new(1, 0, 0, 34)
sellAllFrame.Position = UDim2.new(0, 0, 0, 78)
sellAllFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
sellAllFrame.BackgroundTransparency = 0.2
sellAllFrame.BorderSizePixel = 1
sellAllFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
sellAllFrame.Parent = MainContent

local sellAllCorner = Instance.new("UICorner")
sellAllCorner.CornerRadius = UDim.new(0, 6)
sellAllCorner.Parent = sellAllFrame

local sellAllLabel = Instance.new("TextLabel")
sellAllLabel.Size = UDim2.new(0, 120, 1, 0)
sellAllLabel.Position = UDim2.new(0, 10, 0, 0)
sellAllLabel.BackgroundTransparency = 1
sellAllLabel.Text = "💰 SELL ALL"
sellAllLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
sellAllLabel.Font = Enum.Font.FredokaOne
sellAllLabel.TextSize = 11
sellAllLabel.TextXAlignment = Enum.TextXAlignment.Left
sellAllLabel.Parent = sellAllFrame

local sellAllSwitchBg = Instance.new("Frame")
sellAllSwitchBg.Size = UDim2.new(0, 55, 0, 24)
sellAllSwitchBg.Position = UDim2.new(1, -65, 0.5, -12)
sellAllSwitchBg.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
sellAllSwitchBg.BackgroundTransparency = 0.2
sellAllSwitchBg.BorderSizePixel = 2
sellAllSwitchBg.BorderColor3 = Color3.fromRGB(150, 150, 160)
sellAllSwitchBg.Parent = sellAllFrame

local sellAllSwitchCorner = Instance.new("UICorner")
sellAllSwitchCorner.CornerRadius = UDim.new(0, 12)
sellAllSwitchCorner.Parent = sellAllSwitchBg

local sellAllOffLabel = Instance.new("TextLabel")
sellAllOffLabel.Size = UDim2.new(0, 20, 1, 0)
sellAllOffLabel.Position = UDim2.new(0, 4, 0, 0)
sellAllOffLabel.BackgroundTransparency = 1
sellAllOffLabel.Text = "OFF"
sellAllOffLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
sellAllOffLabel.Font = Enum.Font.FredokaOne
sellAllOffLabel.TextSize = 8
sellAllOffLabel.TextXAlignment = Enum.TextXAlignment.Center
sellAllOffLabel.Parent = sellAllSwitchBg

local sellAllOnLabel = Instance.new("TextLabel")
sellAllOnLabel.Size = UDim2.new(0, 20, 1, 0)
sellAllOnLabel.Position = UDim2.new(1, -24, 0, 0)
sellAllOnLabel.BackgroundTransparency = 1
sellAllOnLabel.Text = "ON"
sellAllOnLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
sellAllOnLabel.Font = Enum.Font.FredokaOne
sellAllOnLabel.TextSize = 8
sellAllOnLabel.TextXAlignment = Enum.TextXAlignment.Center
sellAllOnLabel.Parent = sellAllSwitchBg

local sellAllSwitchBtn = Instance.new("TextButton")
sellAllSwitchBtn.Size = UDim2.new(0, 20, 0, 20)
sellAllSwitchBtn.Position = UDim2.new(0, 4, 0.5, -10)
sellAllSwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sellAllSwitchBtn.BackgroundTransparency = 0.05
sellAllSwitchBtn.BorderSizePixel = 2
sellAllSwitchBtn.BorderColor3 = Color3.fromRGB(150, 150, 160)
sellAllSwitchBtn.Text = ""
sellAllSwitchBtn.ZIndex = 20
sellAllSwitchBtn.Parent = sellAllSwitchBg

local sellAllSwitchBtnCorner = Instance.new("UICorner")
sellAllSwitchBtnCorner.CornerRadius = UDim.new(0, 10)
sellAllSwitchBtnCorner.Parent = sellAllSwitchBtn

-- STATUS LABEL
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0, 14)
statusLabel.Position = UDim2.new(0, 5, 1, -16)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🟢 SEMUA ON"
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.Font = Enum.Font.FredokaOne
statusLabel.TextSize = 9
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.ZIndex = 5
statusLabel.Parent = Content

-- UPGRADE CONTENT
local UpgradeContent = Instance.new("Frame")
UpgradeContent.Size = UDim2.new(1, 0, 1, 0)
UpgradeContent.Position = UDim2.new(0, 0, 0, 0)
UpgradeContent.BackgroundTransparency = 1
UpgradeContent.Visible = false
UpgradeContent.Parent = Content

local autoUpgradeFrame = Instance.new("Frame")
autoUpgradeFrame.Size = UDim2.new(1, 0, 0, 34)
autoUpgradeFrame.Position = UDim2.new(0, 0, 0, 2)
autoUpgradeFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
autoUpgradeFrame.BackgroundTransparency = 0.2
autoUpgradeFrame.BorderSizePixel = 1
autoUpgradeFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
autoUpgradeFrame.Parent = UpgradeContent

local autoUpgradeCorner = Instance.new("UICorner")
autoUpgradeCorner.CornerRadius = UDim.new(0, 6)
autoUpgradeCorner.Parent = autoUpgradeFrame

local autoUpgradeLabel = Instance.new("TextLabel")
autoUpgradeLabel.Size = UDim2.new(0, 120, 1, 0)
autoUpgradeLabel.Position = UDim2.new(0, 10, 0, 0)
autoUpgradeLabel.BackgroundTransparency = 1
autoUpgradeLabel.Text = "⚡ AUTO UPGRADE"
autoUpgradeLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
autoUpgradeLabel.Font = Enum.Font.FredokaOne
autoUpgradeLabel.TextSize = 11
autoUpgradeLabel.TextXAlignment = Enum.TextXAlignment.Left
autoUpgradeLabel.Parent = autoUpgradeFrame

local autoUpgradeSwitchBg = Instance.new("Frame")
autoUpgradeSwitchBg.Size = UDim2.new(0, 55, 0, 24)
autoUpgradeSwitchBg.Position = UDim2.new(1, -65, 0.5, -12)
autoUpgradeSwitchBg.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
autoUpgradeSwitchBg.BackgroundTransparency = 0.2
autoUpgradeSwitchBg.BorderSizePixel = 2
autoUpgradeSwitchBg.BorderColor3 = Color3.fromRGB(150, 150, 160)
autoUpgradeSwitchBg.Parent = autoUpgradeFrame

local autoUpgradeSwitchCorner = Instance.new("UICorner")
autoUpgradeSwitchCorner.CornerRadius = UDim.new(0, 12)
autoUpgradeSwitchCorner.Parent = autoUpgradeSwitchBg

local autoUpgradeOffLabel = Instance.new("TextLabel")
autoUpgradeOffLabel.Size = UDim2.new(0, 20, 1, 0)
autoUpgradeOffLabel.Position = UDim2.new(0, 4, 0, 0)
autoUpgradeOffLabel.BackgroundTransparency = 1
autoUpgradeOffLabel.Text = "OFF"
autoUpgradeOffLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
autoUpgradeOffLabel.Font = Enum.Font.FredokaOne
autoUpgradeOffLabel.TextSize = 8
autoUpgradeOffLabel.TextXAlignment = Enum.TextXAlignment.Center
autoUpgradeOffLabel.Parent = autoUpgradeSwitchBg

local autoUpgradeOnLabel = Instance.new("TextLabel")
autoUpgradeOnLabel.Size = UDim2.new(0, 20, 1, 0)
autoUpgradeOnLabel.Position = UDim2.new(1, -24, 0, 0)
autoUpgradeOnLabel.BackgroundTransparency = 1
autoUpgradeOnLabel.Text = "ON"
autoUpgradeOnLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
autoUpgradeOnLabel.Font = Enum.Font.FredokaOne
autoUpgradeOnLabel.TextSize = 8
autoUpgradeOnLabel.TextXAlignment = Enum.TextXAlignment.Center
autoUpgradeOnLabel.Parent = autoUpgradeSwitchBg

local autoUpgradeSwitchBtn = Instance.new("TextButton")
autoUpgradeSwitchBtn.Size = UDim2.new(0, 20, 0, 20)
autoUpgradeSwitchBtn.Position = UDim2.new(0, 4, 0.5, -10)
autoUpgradeSwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
autoUpgradeSwitchBtn.BackgroundTransparency = 0.05
autoUpgradeSwitchBtn.BorderSizePixel = 2
autoUpgradeSwitchBtn.BorderColor3 = Color3.fromRGB(150, 150, 160)
autoUpgradeSwitchBtn.Text = ""
autoUpgradeSwitchBtn.ZIndex = 20
autoUpgradeSwitchBtn.Parent = autoUpgradeSwitchBg

local autoUpgradeSwitchBtnCorner = Instance.new("UICorner")
autoUpgradeSwitchBtnCorner.CornerRadius = UDim.new(0, 10)
autoUpgradeSwitchBtnCorner.Parent = autoUpgradeSwitchBtn

local upgradeListFrame = Instance.new("Frame")
upgradeListFrame.Size = UDim2.new(1, 0, 0, 95)
upgradeListFrame.Position = UDim2.new(0, 0, 0, 40)
upgradeListFrame.BackgroundColor3 = Color3.fromRGB(20, 18, 35)
upgradeListFrame.BackgroundTransparency = 0.2
upgradeListFrame.BorderSizePixel = 1
upgradeListFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
upgradeListFrame.ClipsDescendants = true
upgradeListFrame.Parent = UpgradeContent

local upgradeListCorner = Instance.new("UICorner")
upgradeListCorner.CornerRadius = UDim.new(0, 6)
upgradeListCorner.Parent = upgradeListFrame

local upgradeScroller = Instance.new("ScrollingFrame")
upgradeScroller.Size = UDim2.new(1, -10, 1, -10)
upgradeScroller.Position = UDim2.new(0, 5, 0, 5)
upgradeScroller.BackgroundTransparency = 1
upgradeScroller.BorderSizePixel = 0
upgradeScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
upgradeScroller.ScrollBarThickness = 4
upgradeScroller.Parent = upgradeListFrame

local upgradeLayout = Instance.new("UIListLayout")
upgradeLayout.Padding = UDim.new(0, 4)
upgradeLayout.SortOrder = Enum.SortOrder.LayoutOrder
upgradeLayout.Parent = upgradeScroller

local upgradeToggles = {}

local function CreateUpgradeToggle(upgradeName)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 28)
    frame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(60, 60, 80)
    frame.Parent = upgradeScroller

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 160, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = upgradeName
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.Font = Enum.Font.FredokaOne
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 50, 0, 20)
    switchBg.Position = UDim2.new(1, -58, 0.5, -10)
    switchBg.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
    switchBg.BackgroundTransparency = 0.2
    switchBg.BorderSizePixel = 2
    switchBg.BorderColor3 = Color3.fromRGB(150, 150, 160)
    switchBg.Parent = frame

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(0, 10)
    switchCorner.Parent = switchBg

    local offLabel = Instance.new("TextLabel")
    offLabel.Size = UDim2.new(0, 18, 1, 0)
    offLabel.Position = UDim2.new(0, 4, 0, 0)
    offLabel.BackgroundTransparency = 1
    offLabel.Text = "OFF"
    offLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    offLabel.Font = Enum.Font.FredokaOne
    offLabel.TextSize = 7
    offLabel.TextXAlignment = Enum.TextXAlignment.Center
    offLabel.Parent = switchBg

    local onLabel = Instance.new("TextLabel")
    onLabel.Size = UDim2.new(0, 18, 1, 0)
    onLabel.Position = UDim2.new(1, -22, 0, 0)
    onLabel.BackgroundTransparency = 1
    onLabel.Text = "ON"
    onLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    onLabel.Font = Enum.Font.FredokaOne
    onLabel.TextSize = 7
    onLabel.TextXAlignment = Enum.TextXAlignment.Center
    onLabel.Parent = switchBg

    local switchBtn = Instance.new("TextButton")
    switchBtn.Size = UDim2.new(0, 18, 0, 18)
    switchBtn.Position = UDim2.new(0, 4, 0.5, -9)
    switchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    switchBtn.BackgroundTransparency = 0.05
    switchBtn.BorderSizePixel = 2
    switchBtn.BorderColor3 = Color3.fromRGB(150, 150, 160)
    switchBtn.Text = ""
    switchBtn.ZIndex = 20
    switchBtn.Parent = switchBg

    local switchBtnCorner = Instance.new("UICorner")
    switchBtnCorner.CornerRadius = UDim.new(0, 9)
    switchBtnCorner.Parent = switchBtn

    local function UpdateState(isOn)
        if isOn then
            switchBtn.Position = UDim2.new(1, -22, 0.5, -9)
            switchBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
            switchBg.BorderColor3 = Color3.fromRGB(255, 50, 50)
            switchBg.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            offLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
            onLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            switchBtn.Position = UDim2.new(0, 4, 0.5, -9)
            switchBtn.BorderColor3 = Color3.fromRGB(150, 150, 160)
            switchBg.BorderColor3 = Color3.fromRGB(150, 150, 160)
            switchBg.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
            offLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            onLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
        end
    end

    switchBtn.MouseButton1Click:Connect(function()
        upgradeSettings[upgradeName] = not upgradeSettings[upgradeName]
        UpdateState(upgradeSettings[upgradeName])
        UpdateStatus()
        if upgradeSettings[upgradeName] then
            print("✅ " .. upgradeName .. ": ON")
        else
            print("❌ " .. upgradeName .. ": OFF")
        end
    end)

    return {UpdateState = UpdateState}
end

for _, name in ipairs({"Luck Multiplier", "Value Multiplier", "Throw Speed"}) do
    upgradeToggles[name] = CreateUpgradeToggle(name)
    upgradeToggles[name].UpdateState(false)
end

upgradeScroller.CanvasSize = UDim2.new(0, 0, 0, (3 * 32) + 10)

-- TRADE CONTENT
local TradeContent = Instance.new("Frame")
TradeContent.Size = UDim2.new(1, 0, 1, 0)
TradeContent.Position = UDim2.new(0, 0, 0, 0)
TradeContent.BackgroundTransparency = 1
TradeContent.Visible = false
TradeContent.Parent = Content

local acceptFrame = Instance.new("Frame")
acceptFrame.Size = UDim2.new(1, 0, 0, 34)
acceptFrame.Position = UDim2.new(0, 0, 0, 2)
acceptFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
acceptFrame.BackgroundTransparency = 0.2
acceptFrame.BorderSizePixel = 1
acceptFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
acceptFrame.Parent = TradeContent

local acceptCorner = Instance.new("UICorner")
acceptCorner.CornerRadius = UDim.new(0, 6)
acceptCorner.Parent = acceptFrame

local acceptLabel = Instance.new("TextLabel")
acceptLabel.Size = UDim2.new(0, 120, 1, 0)
acceptLabel.Position = UDim2.new(0, 10, 0, 0)
acceptLabel.BackgroundTransparency = 1
acceptLabel.Text = "✅ AUTO ACCEPT"
acceptLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
acceptLabel.Font = Enum.Font.FredokaOne
acceptLabel.TextSize = 11
acceptLabel.TextXAlignment = Enum.TextXAlignment.Left
acceptLabel.Parent = acceptFrame

local acceptSwitchBg = Instance.new("Frame")
acceptSwitchBg.Size = UDim2.new(0, 55, 0, 24)
acceptSwitchBg.Position = UDim2.new(1, -65, 0.5, -12)
acceptSwitchBg.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
acceptSwitchBg.BackgroundTransparency = 0.2
acceptSwitchBg.BorderSizePixel = 2
acceptSwitchBg.BorderColor3 = Color3.fromRGB(255, 50, 50)
acceptSwitchBg.Parent = acceptFrame

local acceptSwitchCorner = Instance.new("UICorner")
acceptSwitchCorner.CornerRadius = UDim.new(0, 12)
acceptSwitchCorner.Parent = acceptSwitchBg

local acceptOffLabel = Instance.new("TextLabel")
acceptOffLabel.Size = UDim2.new(0, 20, 1, 0)
acceptOffLabel.Position = UDim2.new(0, 4, 0, 0)
acceptOffLabel.BackgroundTransparency = 1
acceptOffLabel.Text = "OFF"
acceptOffLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
acceptOffLabel.Font = Enum.Font.FredokaOne
acceptOffLabel.TextSize = 8
acceptOffLabel.TextXAlignment = Enum.TextXAlignment.Center
acceptOffLabel.Parent = acceptSwitchBg

local acceptOnLabel = Instance.new("TextLabel")
acceptOnLabel.Size = UDim2.new(0, 20, 1, 0)
acceptOnLabel.Position = UDim2.new(1, -24, 0, 0)
acceptOnLabel.BackgroundTransparency = 1
acceptOnLabel.Text = "ON"
acceptOnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
acceptOnLabel.Font = Enum.Font.FredokaOne
acceptOnLabel.TextSize = 8
acceptOnLabel.TextXAlignment = Enum.TextXAlignment.Center
acceptOnLabel.Parent = acceptSwitchBg

local acceptSwitchBtn = Instance.new("TextButton")
acceptSwitchBtn.Size = UDim2.new(0, 20, 0, 20)
acceptSwitchBtn.Position = UDim2.new(1, -24, 0.5, -10)
acceptSwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
acceptSwitchBtn.BackgroundTransparency = 0.05
acceptSwitchBtn.BorderSizePixel = 2
acceptSwitchBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
acceptSwitchBtn.Text = ""
acceptSwitchBtn.ZIndex = 20
acceptSwitchBtn.Parent = acceptSwitchBg

local acceptSwitchBtnCorner = Instance.new("UICorner")
acceptSwitchBtnCorner.CornerRadius = UDim.new(0, 10)
acceptSwitchBtnCorner.Parent = acceptSwitchBtn

local acceptRemoteFrame = Instance.new("Frame")
acceptRemoteFrame.Size = UDim2.new(1, 0, 0, 34)
acceptRemoteFrame.Position = UDim2.new(0, 0, 0, 40)
acceptRemoteFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
acceptRemoteFrame.BackgroundTransparency = 0.2
acceptRemoteFrame.BorderSizePixel = 1
acceptRemoteFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
acceptRemoteFrame.Parent = TradeContent

local acceptRemoteCorner = Instance.new("UICorner")
acceptRemoteCorner.CornerRadius = UDim.new(0, 6)
acceptRemoteCorner.Parent = acceptRemoteFrame

local acceptRemoteLabel = Instance.new("TextLabel")
acceptRemoteLabel.Size = UDim2.new(0, 150, 1, 0)
acceptRemoteLabel.Position = UDim2.new(0, 10, 0, 0)
acceptRemoteLabel.BackgroundTransparency = 1
acceptRemoteLabel.Text = "⚡ AUTO ACCEPT REMOTE"
acceptRemoteLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
acceptRemoteLabel.Font = Enum.Font.FredokaOne
acceptRemoteLabel.TextSize = 11
acceptRemoteLabel.TextXAlignment = Enum.TextXAlignment.Left
acceptRemoteLabel.Parent = acceptRemoteFrame

local acceptRemoteSwitchBg = Instance.new("Frame")
acceptRemoteSwitchBg.Size = UDim2.new(0, 55, 0, 24)
acceptRemoteSwitchBg.Position = UDim2.new(1, -65, 0.5, -12)
acceptRemoteSwitchBg.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
acceptRemoteSwitchBg.BackgroundTransparency = 0.2
acceptRemoteSwitchBg.BorderSizePixel = 2
acceptRemoteSwitchBg.BorderColor3 = Color3.fromRGB(255, 50, 50)
acceptRemoteSwitchBg.Parent = acceptRemoteFrame

local acceptRemoteSwitchCorner = Instance.new("UICorner")
acceptRemoteSwitchCorner.CornerRadius = UDim.new(0, 12)
acceptRemoteSwitchCorner.Parent = acceptRemoteSwitchBg

local acceptRemoteOffLabel = Instance.new("TextLabel")
acceptRemoteOffLabel.Size = UDim2.new(0, 20, 1, 0)
acceptRemoteOffLabel.Position = UDim2.new(0, 4, 0, 0)
acceptRemoteOffLabel.BackgroundTransparency = 1
acceptRemoteOffLabel.Text = "OFF"
acceptRemoteOffLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
acceptRemoteOffLabel.Font = Enum.Font.FredokaOne
acceptRemoteOffLabel.TextSize = 8
acceptRemoteOffLabel.TextXAlignment = Enum.TextXAlignment.Center
acceptRemoteOffLabel.Parent = acceptRemoteSwitchBg

local acceptRemoteOnLabel = Instance.new("TextLabel")
acceptRemoteOnLabel.Size = UDim2.new(0, 20, 1, 0)
acceptRemoteOnLabel.Position = UDim2.new(1, -24, 0, 0)
acceptRemoteOnLabel.BackgroundTransparency = 1
acceptRemoteOnLabel.Text = "ON"
acceptRemoteOnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
acceptRemoteOnLabel.Font = Enum.Font.FredokaOne
acceptRemoteOnLabel.TextSize = 8
acceptRemoteOnLabel.TextXAlignment = Enum.TextXAlignment.Center
acceptRemoteOnLabel.Parent = acceptRemoteSwitchBg

local acceptRemoteSwitchBtn = Instance.new("TextButton")
acceptRemoteSwitchBtn.Size = UDim2.new(0, 20, 0, 20)
acceptRemoteSwitchBtn.Position = UDim2.new(1, -24, 0.5, -10)
acceptRemoteSwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
acceptRemoteSwitchBtn.BackgroundTransparency = 0.05
acceptRemoteSwitchBtn.BorderSizePixel = 2
acceptRemoteSwitchBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
acceptRemoteSwitchBtn.Text = ""
acceptRemoteSwitchBtn.ZIndex = 20
acceptRemoteSwitchBtn.Parent = acceptRemoteSwitchBg

local acceptRemoteSwitchBtnCorner = Instance.new("UICorner")
acceptRemoteSwitchBtnCorner.CornerRadius = UDim.new(0, 10)
acceptRemoteSwitchBtnCorner.Parent = acceptRemoteSwitchBtn

local addRandomFrame = Instance.new("Frame")
addRandomFrame.Size = UDim2.new(1, 0, 0, 34)
addRandomFrame.Position = UDim2.new(0, 0, 0, 78)
addRandomFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
addRandomFrame.BackgroundTransparency = 0.2
addRandomFrame.BorderSizePixel = 1
addRandomFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
addRandomFrame.Parent = TradeContent

local addRandomCorner = Instance.new("UICorner")
addRandomCorner.CornerRadius = UDim.new(0, 6)
addRandomCorner.Parent = addRandomFrame

local addRandomLabel = Instance.new("TextLabel")
addRandomLabel.Size = UDim2.new(0, 160, 1, 0)
addRandomLabel.Position = UDim2.new(0, 10, 0, 0)
addRandomLabel.BackgroundTransparency = 1
addRandomLabel.Text = "📦 AUTO ADD RANDOM"
addRandomLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
addRandomLabel.Font = Enum.Font.FredokaOne
addRandomLabel.TextSize = 11
addRandomLabel.TextXAlignment = Enum.TextXAlignment.Left
addRandomLabel.Parent = addRandomFrame

local addRandomSwitchBg = Instance.new("Frame")
addRandomSwitchBg.Size = UDim2.new(0, 55, 0, 24)
addRandomSwitchBg.Position = UDim2.new(1, -65, 0.5, -12)
addRandomSwitchBg.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
addRandomSwitchBg.BackgroundTransparency = 0.2
addRandomSwitchBg.BorderSizePixel = 2
addRandomSwitchBg.BorderColor3 = Color3.fromRGB(150, 150, 160)
addRandomSwitchBg.Parent = addRandomFrame

local addRandomSwitchCorner = Instance.new("UICorner")
addRandomSwitchCorner.CornerRadius = UDim.new(0, 12)
addRandomSwitchCorner.Parent = addRandomSwitchBg

local addRandomOffLabel = Instance.new("TextLabel")
addRandomOffLabel.Size = UDim2.new(0, 20, 1, 0)
addRandomOffLabel.Position = UDim2.new(0, 4, 0, 0)
addRandomOffLabel.BackgroundTransparency = 1
addRandomOffLabel.Text = "OFF"
addRandomOffLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
addRandomOffLabel.Font = Enum.Font.FredokaOne
addRandomOffLabel.TextSize = 8
addRandomOffLabel.TextXAlignment = Enum.TextXAlignment.Center
addRandomOffLabel.Parent = addRandomSwitchBg

local addRandomOnLabel = Instance.new("TextLabel")
addRandomOnLabel.Size = UDim2.new(0, 20, 1, 0)
addRandomOnLabel.Position = UDim2.new(1, -24, 0, 0)
addRandomOnLabel.BackgroundTransparency = 1
addRandomOnLabel.Text = "ON"
addRandomOnLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
addRandomOnLabel.Font = Enum.Font.FredokaOne
addRandomOnLabel.TextSize = 8
addRandomOnLabel.TextXAlignment = Enum.TextXAlignment.Center
addRandomOnLabel.Parent = addRandomSwitchBg

local addRandomSwitchBtn = Instance.new("TextButton")
addRandomSwitchBtn.Size = UDim2.new(0, 20, 0, 20)
addRandomSwitchBtn.Position = UDim2.new(0, 4, 0.5, -10)
addRandomSwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
addRandomSwitchBtn.BackgroundTransparency = 0.05
addRandomSwitchBtn.BorderSizePixel = 2
addRandomSwitchBtn.BorderColor3 = Color3.fromRGB(150, 150, 160)
addRandomSwitchBtn.Text = ""
addRandomSwitchBtn.ZIndex = 20
addRandomSwitchBtn.Parent = addRandomSwitchBg

local addRandomSwitchBtnCorner = Instance.new("UICorner")
addRandomSwitchBtnCorner.CornerRadius = UDim.new(0, 10)
addRandomSwitchBtnCorner.Parent = addRandomSwitchBtn

-- ===== MISC CONTENT =====
local MiscContent = Instance.new("Frame")
MiscContent.Size = UDim2.new(1, 0, 1, 0)
MiscContent.Position = UDim2.new(0, 0, 0, 0)
MiscContent.BackgroundTransparency = 1
MiscContent.Visible = false
MiscContent.Parent = Content

-- CHANGE USERNAME
local userFrame = Instance.new("Frame")
userFrame.Size = UDim2.new(1, 0, 0, 60)
userFrame.Position = UDim2.new(0, 0, 0, 2)
userFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
userFrame.BackgroundTransparency = 0.2
userFrame.BorderSizePixel = 1
userFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
userFrame.Parent = MiscContent

local userCorner = Instance.new("UICorner")
userCorner.CornerRadius = UDim.new(0, 6)
userCorner.Parent = userFrame

local userLabel = Instance.new("TextLabel")
userLabel.Size = UDim2.new(1, -10, 0, 14)
userLabel.Position = UDim2.new(0, 8, 0, 2)
userLabel.BackgroundTransparency = 1
userLabel.Text = "👤 CHANGE USERNAME"
userLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
userLabel.Font = Enum.Font.FredokaOne
userLabel.TextSize = 10
userLabel.TextXAlignment = Enum.TextXAlignment.Left
userLabel.Parent = userFrame

local userBox = Instance.new("TextBox")
userBox.Size = UDim2.new(0, 130, 0, 22)
userBox.Position = UDim2.new(0, 8, 0, 20)
userBox.BackgroundColor3 = Color3.fromRGB(15, 13, 30)
userBox.BackgroundTransparency = 0.3
userBox.BorderSizePixel = 2
userBox.BorderColor3 = Color3.fromRGB(255, 50, 50)
userBox.TextColor3 = Color3.fromRGB(255, 255, 255)
userBox.Font = Enum.Font.GothamBold
userBox.TextSize = 11
userBox.Text = player.Name
userBox.PlaceholderText = "Username..."
userBox.TextXAlignment = Enum.TextXAlignment.Left
userBox.ZIndex = 15
userBox.Parent = userFrame

local userBoxCorner = Instance.new("UICorner")
userBoxCorner.CornerRadius = UDim.new(0, 5)
userBoxCorner.Parent = userBox

local userApplyBtn = Instance.new("TextButton")
userApplyBtn.Size = UDim2.new(0, 65, 0, 22)
userApplyBtn.Position = UDim2.new(1, -73, 0, 20)
userApplyBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
userApplyBtn.BackgroundTransparency = 0.2
userApplyBtn.BorderSizePixel = 2
userApplyBtn.BorderColor3 = Color3.fromRGB(255, 0, 0)
userApplyBtn.Text = "APPLY"
userApplyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
userApplyBtn.Font = Enum.Font.GothamBold
userApplyBtn.TextSize = 10
userApplyBtn.ZIndex = 20
userApplyBtn.Parent = userFrame

local userApplyCorner = Instance.new("UICorner")
userApplyCorner.CornerRadius = UDim.new(0, 5)
userApplyCorner.Parent = userApplyBtn

userApplyBtn.MouseButton1Click:Connect(function()
    local newName = userBox.Text
    if newName == "" then
        print("❌ Username tidak boleh kosong!")
        return
    end
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        local model = workspace:FindFirstChild(v.Name)
        if model and model:FindFirstChild("Head") then
            local head = model.Head
            local title = head:FindFirstChild("title")
            if title then
                local usernameLabel = title:FindFirstChild("Username")
                if usernameLabel then
                    pcall(function()
                        usernameLabel.Text = newName
                        usernameLabel.TextColor3 = selectedNicknameColor
                        print("✅ " .. v.Name .. " → " .. newName)
                    end)
                end
            end
        end
    end
end)

-- NICKNAME COLOR DROPDOWN DENGAN SCROLL
local colorLabel = Instance.new("TextLabel")
colorLabel.Size = UDim2.new(1, -10, 0, 14)
colorLabel.Position = UDim2.new(0, 8, 0, 68)
colorLabel.BackgroundTransparency = 1
colorLabel.Text = "🎨 NICKNAME COLOR"
colorLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
colorLabel.Font = Enum.Font.FredokaOne
colorLabel.TextSize = 10
colorLabel.TextXAlignment = Enum.TextXAlignment.Left
colorLabel.Parent = MiscContent

local colorDropdown = Instance.new("TextButton")
colorDropdown.Size = UDim2.new(0, 150, 0, 28)
colorDropdown.Position = UDim2.new(0, 8, 0, 86)
colorDropdown.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
colorDropdown.BackgroundTransparency = 0.2
colorDropdown.BorderSizePixel = 2
colorDropdown.BorderColor3 = Color3.fromRGB(255, 50, 50)
colorDropdown.Text = "🟡 Emas"
colorDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
colorDropdown.Font = Enum.Font.GothamBold
colorDropdown.TextSize = 10
colorDropdown.ZIndex = 20
colorDropdown.Parent = MiscContent

local colorCorner = Instance.new("UICorner")
colorCorner.CornerRadius = UDim.new(0, 5)
colorCorner.Parent = colorDropdown

-- Dropdown Scrolling Frame (BISA DI-SCROLL/DOWN DRAG)
local colorList = Instance.new("ScrollingFrame")
colorList.Size = UDim2.new(0, 150, 0, 130)
colorList.Position = UDim2.new(0, 8, 0, 116)
colorList.BackgroundColor3 = Color3.fromRGB(20, 18, 35)
colorList.BackgroundTransparency = 0.05
colorList.BorderSizePixel = 1
colorList.BorderColor3 = Color3.fromRGB(60, 60, 80)
colorList.Visible = false
colorList.ClipsDescendants = true
colorList.ZIndex = 30
colorList.ScrollBarThickness = 6
colorList.Parent = MiscContent

local colorListCorner = Instance.new("UICorner")
colorListCorner.CornerRadius = UDim.new(0, 5)
colorListCorner.Parent = colorList

local colorLayout = Instance.new("UIListLayout")
colorLayout.Padding = UDim.new(0, 2)
colorLayout.SortOrder = Enum.SortOrder.LayoutOrder
colorLayout.Parent = colorList

-- Hitung jumlah warna
local colorCount = 0
for _ in pairs(nicknameColors) do colorCount = colorCount + 1 end

-- Buat tombol warna dengan scroll
for name, color in pairs(nicknameColors) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 26)
    btn.Position = UDim2.new(0, 5, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 28, 50)
    btn.BackgroundTransparency = 0.1
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(60, 60, 80)
    btn.Text = name
    btn.TextColor3 = color
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.ZIndex = 35
    btn.Parent = colorList
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        selectedNicknameColor = color
        colorDropdown.Text = name
        colorList.Visible = false
        ApplyNicknameColor(color)
    end)
end

-- Set canvas size biar bisa di-scroll
colorList.CanvasSize = UDim2.new(0, 0, 0, (colorCount * 28) + 10)

-- Toggle dropdown
colorDropdown.MouseButton1Click:Connect(function()
    colorList.Visible = not colorList.Visible
end)

-- Sembunyikan dropdown kalo klik di luar
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        task.wait(0.1)
        if colorList.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            local absPos = colorList.AbsolutePosition
            local absSize = colorList.AbsoluteSize
            if not (mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X and
                    mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y) then
                local dropPos = colorDropdown.AbsolutePosition
                local dropSize = colorDropdown.AbsoluteSize
                if not (mousePos.X >= dropPos.X and mousePos.X <= dropPos.X + dropSize.X and
                        mousePos.Y >= dropPos.Y and mousePos.Y <= dropPos.Y + dropSize.Y) then
                    colorList.Visible = false
                end
            end
        end
    end
end)

-- ANTI AFK
local antiAFKFrame = Instance.new("Frame")
antiAFKFrame.Size = UDim2.new(1, 0, 0, 34)
antiAFKFrame.Position = UDim2.new(0, 0, 0, 150)
antiAFKFrame.BackgroundColor3 = Color3.fromRGB(25, 23, 40)
antiAFKFrame.BackgroundTransparency = 0.2
antiAFKFrame.BorderSizePixel = 1
antiAFKFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
antiAFKFrame.Parent = MiscContent

local antiAFKCorner = Instance.new("UICorner")
antiAFKCorner.CornerRadius = UDim.new(0, 6)
antiAFKCorner.Parent = antiAFKFrame

local antiAFKLabel = Instance.new("TextLabel")
antiAFKLabel.Size = UDim2.new(0, 120, 1, 0)
antiAFKLabel.Position = UDim2.new(0, 10, 0, 0)
antiAFKLabel.BackgroundTransparency = 1
antiAFKLabel.Text = "🛡️ ANTI AFK"
antiAFKLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
antiAFKLabel.Font = Enum.Font.FredokaOne
antiAFKLabel.TextSize = 11
antiAFKLabel.TextXAlignment = Enum.TextXAlignment.Left
antiAFKLabel.Parent = antiAFKFrame

local antiAFKSwitchBg = Instance.new("Frame")
antiAFKSwitchBg.Size = UDim2.new(0, 55, 0, 24)
antiAFKSwitchBg.Position = UDim2.new(1, -65, 0.5, -12)
antiAFKSwitchBg.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
antiAFKSwitchBg.BackgroundTransparency = 0.2
antiAFKSwitchBg.BorderSizePixel = 2
antiAFKSwitchBg.BorderColor3 = Color3.fromRGB(255, 50, 50)
antiAFKSwitchBg.Parent = antiAFKFrame

local antiAFKSwitchCorner = Instance.new("UICorner")
antiAFKSwitchCorner.CornerRadius = UDim.new(0, 12)
antiAFKSwitchCorner.Parent = antiAFKSwitchBg

local antiAFKOffLabel = Instance.new("TextLabel")
antiAFKOffLabel.Size = UDim2.new(0, 20, 1, 0)
antiAFKOffLabel.Position = UDim2.new(0, 4, 0, 0)
antiAFKOffLabel.BackgroundTransparency = 1
antiAFKOffLabel.Text = "OFF"
antiAFKOffLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
antiAFKOffLabel.Font = Enum.Font.FredokaOne
antiAFKOffLabel.TextSize = 8
antiAFKOffLabel.TextXAlignment = Enum.TextXAlignment.Center
antiAFKOffLabel.Parent = antiAFKSwitchBg

local antiAFKOnLabel = Instance.new("TextLabel")
antiAFKOnLabel.Size = UDim2.new(0, 20, 1, 0)
antiAFKOnLabel.Position = UDim2.new(1, -24, 0, 0)
antiAFKOnLabel.BackgroundTransparency = 1
antiAFKOnLabel.Text = "ON"
antiAFKOnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
antiAFKOnLabel.Font = Enum.Font.FredokaOne
antiAFKOnLabel.TextSize = 8
antiAFKOnLabel.TextXAlignment = Enum.TextXAlignment.Center
antiAFKOnLabel.Parent = antiAFKSwitchBg

local antiAFKSwitchBtn = Instance.new("TextButton")
antiAFKSwitchBtn.Size = UDim2.new(0, 20, 0, 20)
antiAFKSwitchBtn.Position = UDim2.new(1, -24, 0.5, -10)
antiAFKSwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
antiAFKSwitchBtn.BackgroundTransparency = 0.05
antiAFKSwitchBtn.BorderSizePixel = 2
antiAFKSwitchBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
antiAFKSwitchBtn.Text = ""
antiAFKSwitchBtn.ZIndex = 20
antiAFKSwitchBtn.Parent = antiAFKSwitchBg

local antiAFKSwitchBtnCorner = Instance.new("UICorner")
antiAFKSwitchBtnCorner.CornerRadius = UDim.new(0, 10)
antiAFKSwitchBtnCorner.Parent = antiAFKSwitchBtn

-- ===== FUNCTIONS =====
local function SetToggleState(switchBtn, isOn, switchBg, offLabel, onLabel)
    if isOn then
        switchBtn.Position = UDim2.new(1, -24, 0.5, -10)
        switchBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
        switchBg.BorderColor3 = Color3.fromRGB(255, 50, 50)
        switchBg.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        offLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
        onLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        switchBtn.Position = UDim2.new(0, 4, 0.5, -10)
        switchBtn.BorderColor3 = Color3.fromRGB(150, 150, 160)
        switchBg.BorderColor3 = Color3.fromRGB(150, 150, 160)
        switchBg.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
        offLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        onLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    end
end

local function UpdateStatus()
    local count = 0
    if autoCoin then count = count + 1 end
    if autoSellAll then count = count + 1 end
    if autoUpgrade then count = count + 1 end
    if autoAccept then count = count + 1 end
    if autoAcceptRemote then count = count + 1 end
    if autoAddRandomItem then count = count + 1 end
    if antiAFK then count = count + 1 end
    
    if count == 7 then
        statusLabel.Text = "🟢 SEMUA ON"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    elseif count >= 4 then
        statusLabel.Text = "🟡 " .. count .. " ON"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    elseif count == 0 then
        statusLabel.Text = "🔴 ALL OFF"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    else
        statusLabel.Text = "🟡 " .. count .. " ON"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    end
end

local function SwitchTab(tab)
    currentTab = tab
    local tabs = {TabMain, TabUpgrade, TabTrade, TabMisc}
    for _, t in ipairs(tabs) do
        t.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
        t.BorderColor3 = Color3.fromRGB(60, 60, 80)
        t.TextColor3 = Color3.fromRGB(200, 200, 210)
        t.BackgroundTransparency = 0.3
    end
    
    MainContent.Visible = false
    UpgradeContent.Visible = false
    TradeContent.Visible = false
    MiscContent.Visible = false
    
    if tab == "MAIN" then
        TabMain.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        TabMain.BorderColor3 = Color3.fromRGB(255, 0, 0)
        TabMain.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabMain.BackgroundTransparency = 0.1
        MainContent.Visible = true
    elseif tab == "UPGRADE" then
        TabUpgrade.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        TabUpgrade.BorderColor3 = Color3.fromRGB(255, 0, 0)
        TabUpgrade.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabUpgrade.BackgroundTransparency = 0.1
        UpgradeContent.Visible = true
    elseif tab == "TRADE" then
        TabTrade.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        TabTrade.BorderColor3 = Color3.fromRGB(255, 0, 0)
        TabTrade.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabTrade.BackgroundTransparency = 0.1
        TradeContent.Visible = true
    elseif tab == "MISC" then
        TabMisc.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        TabMisc.BorderColor3 = Color3.fromRGB(255, 0, 0)
        TabMisc.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabMisc.BackgroundTransparency = 0.1
        MiscContent.Visible = true
    end
end

-- TAB BUTTONS
TabMain.MouseButton1Click:Connect(function() SwitchTab("MAIN") end)
TabUpgrade.MouseButton1Click:Connect(function() SwitchTab("UPGRADE") end)
TabTrade.MouseButton1Click:Connect(function() SwitchTab("TRADE") end)
TabMisc.MouseButton1Click:Connect(function() SwitchTab("MISC") end)

-- TOGGLE BUTTONS
coinSwitchBtn.MouseButton1Click:Connect(function()
    autoCoin = not autoCoin
    SetToggleState(coinSwitchBtn, autoCoin, coinSwitchBg, coinOffLabel, coinOnLabel)
    UpdateStatus()
    if autoCoin then StartCoinLoop() else StopCoinLoop() end
end)

sellAllSwitchBtn.MouseButton1Click:Connect(function()
    autoSellAll = not autoSellAll
    SetToggleState(sellAllSwitchBtn, autoSellAll, sellAllSwitchBg, sellAllOffLabel, sellAllOnLabel)
    UpdateStatus()
    if autoSellAll then StartSellAllLoop() else StopSellAllLoop() end
end)

autoUpgradeSwitchBtn.MouseButton1Click:Connect(function()
    autoUpgrade = not autoUpgrade
    SetToggleState(autoUpgradeSwitchBtn, autoUpgrade, autoUpgradeSwitchBg, autoUpgradeOffLabel, autoUpgradeOnLabel)
    UpdateStatus()
    if autoUpgrade then StartUpgradeLoop() else StopUpgradeLoop() end
end)

acceptSwitchBtn.MouseButton1Click:Connect(function()
    autoAccept = not autoAccept
    SetToggleState(acceptSwitchBtn, autoAccept, acceptSwitchBg, acceptOffLabel, acceptOnLabel)
    UpdateStatus()
    if autoAccept then StartAcceptLoop() else StopAcceptLoop() end
end)

acceptRemoteSwitchBtn.MouseButton1Click:Connect(function()
    autoAcceptRemote = not autoAcceptRemote
    SetToggleState(acceptRemoteSwitchBtn, autoAcceptRemote, acceptRemoteSwitchBg, acceptRemoteOffLabel, acceptRemoteOnLabel)
    UpdateStatus()
    if autoAcceptRemote then StartAcceptRemoteLoop() else StopAcceptRemoteLoop() end
end)

addRandomSwitchBtn.MouseButton1Click:Connect(function()
    autoAddRandomItem = not autoAddRandomItem
    SetToggleState(addRandomSwitchBtn, autoAddRandomItem, addRandomSwitchBg, addRandomOffLabel, addRandomOnLabel)
    UpdateStatus()
    if autoAddRandomItem then StartAddRandomItemLoop() else StopAddRandomItemLoop() end
end)

antiAFKSwitchBtn.MouseButton1Click:Connect(function()
    antiAFK = not antiAFK
    SetToggleState(antiAFKSwitchBtn, antiAFK, antiAFKSwitchBg, antiAFKOffLabel, antiAFKOnLabel)
    UpdateStatus()
    if antiAFK then StartAntiAFK() else StopAntiAFK() end
end)

-- SET DEFAULT STATES
SetToggleState(coinSwitchBtn, true, coinSwitchBg, coinOffLabel, coinOnLabel)
SetToggleState(sellAllSwitchBtn, false, sellAllSwitchBg, sellAllOffLabel, sellAllOnLabel)
SetToggleState(autoUpgradeSwitchBtn, false, autoUpgradeSwitchBg, autoUpgradeOffLabel, autoUpgradeOnLabel)
SetToggleState(acceptSwitchBtn, true, acceptSwitchBg, acceptOffLabel, acceptOnLabel)
SetToggleState(acceptRemoteSwitchBtn, true, acceptRemoteSwitchBg, acceptRemoteOffLabel, acceptRemoteOnLabel)
SetToggleState(addRandomSwitchBtn, false, addRandomSwitchBg, addRandomOffLabel, addRandomOnLabel)
SetToggleState(antiAFKSwitchBtn, true, antiAFKSwitchBg, antiAFKOffLabel, antiAFKOnLabel)

-- Apply default color
ApplyNicknameColor(selectedNicknameColor)

UpdateStatus()

print("✅ BEGE IDN | THROW A COIN + AUTO TRADE + MISC")
print("📌 Klik ➖ untuk minimize ke bubble")
print("📌 Klik bubble untuk munculin GUI lagi (support mobile)")
print("📌 Bubble bisa di-drag di mobile")
print("🎨 " .. colorCount .. " pilihan warna nickname di tab MISC")
print("📜 Dropdown warna bisa di-scroll/down drag!")
print("⚡ ProximityPrompt instan! (Loop tiap 2 detik)")