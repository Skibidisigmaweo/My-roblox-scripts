-- FTF ULTIMATE | Clean UI + Bulletproof Logic
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Variables
local noclip = false
local infjump = false
local espEnabled = false
local currentSpeed = 16
local currentJump = 50
local espObjects = {}

---------------------------------------------------------
-- 1. THE CLEAN UI
---------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FTF_Ultimate_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999 -- Always on top
ScreenGui.Parent = PlayerGui

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 320)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", MainFrame)
stroke.Color = Color3.fromRGB(60, 60, 60)

-- Top Bar (Draggable)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TopBar.BorderSizePixel = 0
TopBar.Active = true
TopBar.Draggable = true
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "FTF ULTIMATE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -12.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Tabs Container
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 0, 35)
TabContainer.Position = UDim2.new(0, 10, 0, 50)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout", TabContainer)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 8)

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -20, 1, -95)
ContentContainer.Position = UDim2.new(0, 10, 0, 85)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local tabs = {}
local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.Parent = TabContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.ScrollBarThickness = 2
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    frame.Parent = ContentContainer
    
    local layout = Instance.new("UIListLayout", frame)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    
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

-- Bulletproof Toggle (Whole row is clickable)
local function CreateToggle(parent, text, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = ""
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 15, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 40, 0, 20)
    bg.Position = UDim2.new(1, -55, 0.5, -10)
    bg.BackgroundColor3 = default and Color3.fromRGB(50, 200, 80) or Color3.fromRGB(60, 60, 60)
    bg.Parent = btn
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.Parent = bg
    Instance.new("UICorner", circle).CornerRadius = UDim.new(0, 10)
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(50, 200, 80) or Color3.fromRGB(60, 60, 60)}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        callback(state)
    end)
end

-- Button Helper
local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play() end)
    btn.MouseButton1Click:Connect(callback)
end

-- Slider Helper
local function CreateSlider(parent, text, min, max, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 55)
    f.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.Position = UDim2.new(0, 15, 0, 8)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. default
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -30, 0, 8)
    bar.Position = UDim2.new(0, 15, 0, 35)
    bar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    bar.Parent = f
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)
    
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, 0, 3, 0)
    sliderBtn.Position = UDim2.new(0, 0, -1, 0)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.Parent = bar
    
    local dragging = false
    sliderBtn.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end 
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + ((max - min) * percent))
            fill.Size = UDim2.new(percent, 0, 1, 0)
            lbl.Text = text .. ": " .. val
            callback(val)
        end
    end)
end

---------------------------------------------------------
-- 2. BUILD THE MENU
---------------------------------------------------------
local MainTab = CreateTab("Main")
local VisTab = CreateTab("Visuals")
local TPTab = CreateTab("Teleports")

-- Main
CreateSlider(MainTab, "WalkSpeed", 16, 100, 16, function(val) currentSpeed = val end)
CreateSlider(MainTab, "JumpPower", 50, 200, 50, function(val) currentJump = val end)
CreateToggle(MainTab, "Infinite Jump", false, function(state) infjump = state end)
CreateToggle(MainTab, "Noclip", false, function(state) noclip = state end)

-- Visuals
CreateToggle(VisTab, "Enable ESP", false, function(state) espEnabled = state end)

-- Teleports
CreateButton(TPTab, "Teleport to Nearest Computer", function()
    local char = Player.Character
    if not char then return end
    local closest, target = math.huge, nil
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:lower():find("computer") or obj.Name:lower():find("hack")) then
            local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
            if root then
                local dist = (char.HumanoidRootPart.Position - root.Position).Magnitude
                if dist < closest then closest = dist; target = root end
            end
        end
    end
    if target then char:PivotTo(target.CFrame + Vector3.new(0, 3, 0)) end
end)

tabs[1].btn.MouseButton1Click:Fire()

---------------------------------------------------------
-- 3. BULLETPROOF GAME LOGIC
---------------------------------------------------------
RunService.Heartbeat:Connect(function()
    local char = Player.Character
    if not char then return end
    pcall(function()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.WalkSpeed ~= currentSpeed then hum.WalkSpeed = currentSpeed end
            if hum.UseJumpPower and hum.JumpPower ~= currentJump then hum.JumpPower = currentJump end
        end
    end)
end)

UserInputService.JumpRequest:Connect(function()
    if infjump and Player.Character then
        pcall(function()
            local hum = Player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end)

RunService.Stepped:Connect(function()
    if noclip and Player.Character then
        pcall(function()
            for _, v in pairs(Player.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
    end
end)

-- ESP
local function CreateESP(object, color, name)
    local highlight = Instance.new("Highlight", object)
    highlight.FillColor = color
    highlight.OutlineColor = color
    local billboard = Instance.new("BillboardGui", object)
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    local text = Instance.new("TextLabel", billboard)
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = name
    text.TextColor3 = color
    text.Font = Enum.Font.GothamBold
    text.TextScaled = true
    table.insert(espObjects, object)
end

task.spawn(function()
    while task.wait(2) do
        if espEnabled then
            pcall(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        if not player.Character:FindFirstChildOfClass("Highlight") then
                            CreateESP(player.Character, Color3.fromRGB(255, 50, 50), player.Name)
                        end
                    end
                end
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name:lower():find("computer") or obj.Name:lower():find("hack")) then
                        if not obj:FindFirstChildOfClass("Highlight") then
                            CreateESP(obj, Color3.fromRGB(0, 255, 255), "Computer")
                        end
                    end
                end
            end)
        else
            for _, obj in ipairs(espObjects) do
                if obj then
                    local h = obj:FindFirstChildOfClass("Highlight"); if h then h:Destroy() end
                    local b = obj:FindFirstChildOfClass("BillboardGui"); if b then b:Destroy() end
                end
            end
            espObjects = {}
        end
    end
end)
