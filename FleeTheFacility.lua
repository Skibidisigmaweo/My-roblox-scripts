-- 1000000x Cleaner Custom FTF Script (No Libraries, Smooth UI)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local success, hiddenUI = pcall(function() return gethui() end)
local GuiParent = (success and hiddenUI) and hiddenUI or PlayerGui

-- Settings & Variables
local isInfJump = false
local espEnabled = false
local noclipEnabled = false
local espObjects = {}
local currentSpeed = 16
local currentJump = 50

---------------------------------------------------------
-- 1. THE UI FRAMEWORK (Clean & Animated)
---------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CleanFTF_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = GuiParent

-- Main Background
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 440, 0, 320)
MainFrame.Position = UDim2.new(0.5, -220, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(50, 50, 50)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TopBar.BackgroundTransparency = 0.2
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "FTF ULTIMATE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -12.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Text = ""
CloseBtn.Parent = TopBar
Instance.new("UICorner").Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Tabs Container
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 0, 35)
TabContainer.Position = UDim2.new(0, 10, 0, 50)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 8)
TabLayout.Parent = TabContainer

-- Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -20, 1, -95)
ContentContainer.Position = UDim2.new(0, 10, 0, 85)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- Tab Creation Helper
local tabs = {}
local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.Parent = TabContainer
    Instance.new("UICorner").Parent = btn
    
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.ScrollBarThickness = 2
    frame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    frame.Parent = ContentContainer
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            TweenService:Create(t.btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
            t.frame.Visible = false
        end
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        frame.Visible = true
    end)
    
    table.insert(tabs, {btn = btn, frame = frame})
    return frame
end

-- Animated Toggle Helper
local function CreateToggle(parent, text, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 40)
    f.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    f.Parent = parent
    Instance.new("UICorner").Parent = f
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 40, 0, 20)
    bg.Position = UDim2.new(1, -52, 0.5, -10)
    bg.BackgroundColor3 = default and Color3.fromRGB(50, 200, 80) or Color3.fromRGB(60, 60, 60)
    bg.Parent = f
    Instance.new("UICorner").Parent = bg
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.Parent = bg
    Instance.new("UICorner").Parent = circle
    
    local state = default
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = bg
    
    clickBtn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(50, 200, 80) or Color3.fromRGB(60, 60, 60)}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        callback(state)
    end)
end

-- Button Helper
local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.Parent = parent
    Instance.new("UICorner").Parent = btn
    
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play() end)
    btn.MouseButton1Click:Connect(callback)
end

-- Slider Helper
local function CreateSlider(parent, text, min, max, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 55)
    f.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    f.Parent = parent
    Instance.new("UICorner").Parent = f
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.Position = UDim2.new(0, 12, 0, 8)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. default
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -24, 0, 6)
    bar.Position = UDim2.new(0, 12, 0, 35)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    bar.Parent = f
    Instance.new("UICorner").Parent = bar
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    fill.Parent = bar
    Instance.new("UICorner").Parent = fill
    
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, 0, 1, 20)
    sliderBtn.Position = UDim2.new(0, 0, 0, -10)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.Parent = bar
    
    local dragging = false
    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + ((max - min) * percent))
            fill.Size = UDim2.new(percent, 0, 1, 0)
            lbl.Text = text .. ": " .. val
            callback(val)
        end
    end)
end

---------------------------------------------------------
-- 2. BUILD THE TABS
---------------------------------------------------------
local MainTab = CreateTab("Main")
local VisTab = CreateTab("Visuals")
local TPTab = CreateTab("Teleports")

-- Main Tab
CreateSlider(MainTab, "WalkSpeed", 16, 150, 16, function(val) currentSpeed = val end)
CreateSlider(MainTab, "JumpPower", 50, 250, 50, function(val) currentJump = val end)
CreateToggle(MainTab, "Infinite Jump", false, function(state) isInfJump = state end)
CreateToggle(MainTab, "Noclip (Walk through walls)", false, function(state) noclipEnabled = state end)

-- Visuals Tab
CreateToggle(VisTab, "Enable ESP (Computers/Exit/Players)", false, function(state) espEnabled = state end)

-- Teleports Tab
CreateButton(TPTab, "Teleport to Nearest Computer", function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local closestDist = math.huge
    local targetPart = nil
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:lower():find("computer") or obj.Name:lower():find("hack")) then
            local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
            if root then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    targetPart = root
                end
            end
        end
    end
    
    if targetPart then
        hrp.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
    end
end)

CreateButton(TPTab, "Teleport to Exit", function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("exit") then
            local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
            if root then
                hrp.CFrame = root.CFrame + Vector3.new(0, 3, 0)
                break
            end
        end
    end
end)

-- Set default tab
tabs[1].btn.MouseButton1Click:Fire()

---------------------------------------------------------
-- 3. GAME LOGIC
---------------------------------------------------------

-- Apply Speed and Jump
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum.WalkSpeed ~= currentSpeed then hum.WalkSpeed = currentSpeed end
        if hum.JumpPower ~= currentJump and hum.UseJumpPower then hum.JumpPower = currentJump end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if isInfJump then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Noclip Logic
RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- Clean ESP Logic
local function CreateESP(object, color, name)
    if not object then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.FillTransparency = 0.6
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0
    highlight.Parent = object
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 120, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = object
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = name
    text.TextColor3 = color
    text.Font = Enum.Font.GothamBold
    text.TextStrokeTransparency = 0
    text.TextScaled = true
    text.Parent = billboard
    
    table.insert(espObjects, object)
end

task.spawn(function()
    while task.wait(1.5) do
        if espEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    if not player.Character:FindFirstChildOfClass("Highlight") then
                        CreateESP(player.Character, Color3.fromRGB(255, 70, 70), player.Name)
                    end
                end
            end
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") then
                    local name = obj.Name:lower()
                    if (name:find("computer") or name:find("hack")) and not obj:FindFirstChildOfClass("Highlight") then
                        CreateESP(obj, Color3.fromRGB(0, 255, 255), "Computer")
                    elseif name:find("exit") and not obj:FindFirstChildOfClass("Highlight") then
                        CreateESP(obj, Color3.fromRGB(50, 255, 50), "EXIT")
                    end
                end
            end
        else
            for _, obj in ipairs(espObjects) do
                if obj then
                    local h = obj:FindFirstChildOfClass("Highlight")
                    if h then h:Destroy() end
                    local b = obj:FindFirstChildOfClass("BillboardGui")
                    if b then b:Destroy() end
                end
            end
            espObjects = {}
        end
    end
end)
