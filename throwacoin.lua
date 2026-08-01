-- ============================================
-- ZAIXPLOIT | THROW A COIN + AUTO TRADE + MISC
-- Tab 1: [ MAIN ] - AUTO COIN
-- Tab 2: [ TRADE ] - AUTO ACCEPT + AUTO ACCEPT TRADE
-- Tab 3: [ MISC ] - CHANGE USERNAME + ANTI AFK
-- ============================================

local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events")

local CoinLanded = Events:WaitForChild("CoinLanded")

-- ============================================
-- REMOTE TRADE
-- ============================================

local TradeRequestResponse = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("TradeRequestResponse")
local TradeAccept = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("TradeAccept")

-- ============================================
-- TOGGLE VARIABEL
-- ============================================

-- TAB 1: MAIN (THROW A COIN)
local autoCoin = true
local coinLoop = nil

-- TAB 2: TRADE
local autoAccept = true
local autoAcceptTrade = true
local acceptLoop = nil
local acceptTradeLoop = nil
local alreadyAccepted = false

-- TAB 3: MISC
local antiAFK = true
local antiAFKLoop = nil
local currentTab = "MAIN"

-- ============================================
-- 1. ANTI AFK (TOGGLE ON/OFF)
-- ============================================

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

StartAntiAFK() -- DEFAULT ON

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
    local events = ReplicatedStorage:FindFirstChild("Assets")
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
-- 3. AUTO COIN (MAIN TAB)
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
-- 4. SET HOLD DURATION = 0
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
-- 5. TELEPORT (1x SAJA)
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
-- 6. TOGGLE 2: AUTO ACCEPT (TRADE TAB)
-- ============================================

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
                            print("✅ Auto Accept dari User ID: " .. userId)
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
                                            print("✅ Auto Accept - Lawan udah accept!")
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
            task.wait(0.1)
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
-- 7. TOGGLE 3: AUTO ACCEPT TRADE (TRADE TAB)
-- ============================================

local function IsLawanAccept()
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
    
    local theirOffer = tradeContainer:FindFirstChild("TheirOffer")
    if not theirOffer then return false end
    
    local profile = theirOffer:FindFirstChild("Profile")
    if not profile then return false end
    
    local username = profile:FindFirstChild("Username")
    if not username then return false end
    
    local readyIcon = username:FindFirstChild("ready")
    if readyIcon and readyIcon.Enabled then
        return true
    end
    
    return false
end

local function StartAcceptTradeLoop()
    if acceptTradeLoop then return end
    acceptTradeLoop = task.spawn(function()
        while autoAcceptTrade do
            if IsLawanAccept() then
                if not alreadyAccepted then
                    pcall(function()
                        TradeAccept:FireServer()
                        print("✅ Auto Accept Trade - Lawan udah accept!")
                        alreadyAccepted = true
                    end)
                end
            else
                if alreadyAccepted then
                    alreadyAccepted = false
                end
            end
            task.wait(0.1)
        end
    end)
end

local function StopAcceptTradeLoop()
    autoAcceptTrade = false
    if acceptTradeLoop then
        task.cancel(acceptTradeLoop)
        acceptTradeLoop = nil
    end
end

StartAcceptTradeLoop()

-- ============================================
-- 8. GUI
-- ============================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZAIXPLOIT"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 360, 0, 260)
Main.Position = UDim2.new(0.5, -180, 0.5, -130)
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
SubTitle.TextSize = 10
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
MinBtn.ZIndex = 30
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
        Main.Size = UDim2.new(0, 360, 0, 42)
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