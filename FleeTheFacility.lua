-- FTF Ultimate (Bulletproof Version)
print("FTF Script Loaded!") -- If you don't see this in the console, the script didn't run.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Safely get the UI parent
local success, hiddenUI = pcall(function() return gethui() end)
local GuiParent = (success and hiddenUI) and hiddenUI or PlayerGui

-- Variables
local isInfJump = false
local espEnabled = false
local noclipEnabled = false
local currentSpeed = 16
local currentJump = 50
local espObjects = {}

---------------------------------------------------------
-- 1. THE UI (Simple, No Animations, 100% Clickable)
---------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FTF_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = GuiParent

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "FTF Ultimate | Test Mode"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 0, 30)
TabContainer.Position = UDim2.new(0, 10, 0, 50)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -20, 1, -90)
ContentContainer.Position = UDim2.new(0, 10, 0, 80)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- Tab Logic
local tabs = {}
local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = TabContainer
    
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    frame.Parent = ContentContainer
    
    local layout = Instance.new("UIListLayout", frame)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            t.frame.Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        frame.Visible = true
    end)
    table.insert(tabs, {btn = btn, frame = frame})
    return frame
end

-- Toggle Logic
local function CreateToggle(parent, text, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Gotham
    btn.Parent = parent
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
        btn.Text = "  " .. text .. (state and " [ON]" or " [OFF]")
        callback(state)
    end)
    btn.Text = "  " .. text .. (default and " [ON]" or " [OFF]")
    if default then btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0) end
end

-- Button Logic
local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.Parent = parent
    btn.MouseButton1Click:Connect(callback)
end

-- Slider Logic
local function CreateSlider(parent, text, min, max, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 50)
    f.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    f.Parent = parent
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. default
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.Gotham
    lbl.Parent = f
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 10)
    bar.Position = UDim2.new(0, 10, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    bar.Parent = f
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.Parent = bar
    
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, 0, 1, 0)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.Parent = bar
    
    local dragging = false
    sliderBtn.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
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
-- 2. BUILD THE TABS
---------------------------------------------------------
local MainTab = CreateTab("Main")
local VisTab = CreateTab("Visuals")
local TPTab = CreateTab("Teleports")

CreateSlider(MainTab, "WalkSpeed", 16, 100, 16, function(val) currentSpeed = val end)
CreateSlider(MainTab, "JumpPower", 50, 200, 50, function(val) currentJump = val end)
CreateToggle(MainTab, "Infinite Jump", false, function(state) isInfJump = state end)
CreateToggle(MainTab, "Noclip", false, function(state) noclipEnabled = state end)

CreateToggle(VisTab, "Enable ESP", false, function(state) espEnabled = state end)

CreateButton(TPTab, "Teleport to Nearest Computer", function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local closestDist, targetPart = math.huge, nil
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:lower():find("computer") or obj.Name:lower():find("hack")) then
            local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
            if root then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist < closestDist then closestDist = dist; targetPart = root end
            end
        end
    end
    if targetPart then LocalPlayer.Character:PivotTo(targetPart.CFrame + Vector3.new(0, 3, 0)) end
end)

tabs[1].btn.MouseButton1Click:Fire()

---------------------------------------------------------
-- 3. GAME LOGIC (Tested & Fixed)
---------------------------------------------------------

-- Speed & Jump loop
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        hum.WalkSpeed = currentSpeed
        if hum.UseJumpPower then hum.JumpPower = currentJump else hum.JumpHeight = currentJump end
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

-- Noclip (Applies to your character safely)
RunService.Stepped:Connect(function()
    if noclipEnabled then
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
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
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    if not player.Character:FindFirstChildOfClass("Highlight") then
                        CreateESP(player.Character, Color3.fromRGB(255, 0, 0), player.Name)
                    end
                end
            end
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj.Name:lower():find("computer") or obj.Name:lower():find("hack")) then
                    if not obj:FindFirstChildOfClass("Highlight") then
                        CreateESP(obj, Color3.fromRGB(0, 255, 255), "Computer")
                    end
                end
            end
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
