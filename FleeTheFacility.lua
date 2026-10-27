-- FTF ULTIMATE | DIRECT INJECT TEST
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local noclip = false
local infjump = false
local espEnabled = false
local currentSpeed = 16
local currentJump = 50
local espObjects = {}

---------------------------------------------------------
-- THE UI
---------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FTF_Ultimate_Fixed"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", MainFrame)
stroke.Color = Color3.fromRGB(80, 80, 80)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.Text = "FTF ULTIMATE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Tab Logic
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 30)
TabBar.Position = UDim2.new(0, 10, 0, 50)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -95)
Content.Position = UDim2.new(0, 10, 0, 85)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local tabs = {}
local function MakeTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.33, -5, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = TabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.ScrollBarThickness = 2
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    frame.Parent = Content
    
    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            t.btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            t.frame.Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        frame.Visible = true
    end)
    
    table.insert(tabs, {btn = btn, frame = frame})
    return frame
end

local function MakeToggle(parent, text, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Gotham
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
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

local function MakeSlider(parent, text, min, max, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 45)
    f.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. default
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 6)
    bar.Position = UDim2.new(0, 10, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    bar.Parent = f
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 3)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)
    
    local dragBtn = Instance.new("TextButton")
    dragBtn.Size = UDim2.new(1, 0, 3, 0)
    dragBtn.Position = UDim2.new(0, 0, -1, 0)
    dragBtn.BackgroundTransparency = 1
    dragBtn.Text = ""
    dragBtn.Parent = bar
    
    local dragging = false
    dragBtn.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local v = math.floor(min + ((max - min) * p))
            fill.Size = UDim2.new(p, 0, 1, 0)
            lbl.Text = text .. ": " .. v
            callback(v)
        end
    end)
end

local function MakeButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
end

-- Build Tabs
local MainTab = MakeTab("Main")
local VisTab = MakeTab("Visuals")
local TPTab = MakeTab("Teleport")

MakeSlider(MainTab, "WalkSpeed", 16, 100, 16, function(v) currentSpeed = v end)
MakeSlider(MainTab, "JumpPower", 50, 200, 50, function(v) currentJump = v end)
MakeToggle(MainTab, "Infinite Jump", false, function(s) infjump = s end)
MakeToggle(MainTab, "Noclip", false, function(s) noclip = s end)

MakeToggle(VisTab, "Enable ESP", false, function(s) espEnabled = s end)

MakeButton(TPTab, "Teleport to Computer", function()
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
-- GAME LOGIC
---------------------------------------------------------
RunService.Heartbeat:Connect(function()
    local char = Player.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        pcall(function()
            hum.WalkSpeed = currentSpeed
            if hum.UseJumpPower then hum.JumpPower = currentJump else hum.JumpHeight = currentJump end
        end)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if infjump and Player.Character then
        pcall(function()
            Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
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
local function CreateESP(obj, color, name)
    local h = Instance.new("Highlight", obj)
    h.FillColor = color; h.OutlineColor = color
    local b = Instance.new("BillboardGui", obj)
    b.Size = UDim2.new(0, 100, 0, 50); b.StudsOffset = Vector3.new(0, 3, 0); b.AlwaysOnTop = true
    local t = Instance.new("TextLabel", b)
    t.Size = UDim2.new(1, 0, 1, 0); t.BackgroundTransparency = 1; t.Text = name; t.TextColor3 = color; t.Font = Enum.Font.GothamBold; t.TextScaled = true
    table.insert(espObjects, obj)
end

task.spawn(function()
    while task.wait(2) do
        if espEnabled then
            pcall(function()
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and not p.Character:FindFirstChildOfClass("Highlight") then
                        CreateESP(p.Character, Color3.fromRGB(255, 50, 50), p.Name)
                    end
                end
                for _, o in pairs(workspace:GetDescendants()) do
                    if o:IsA("Model") and (o.Name:lower():find("computer") or o.Name:lower():find("hack")) and not o:FindFirstChildOfClass("Highlight") then
                        CreateESP(o, Color3.fromRGB(0, 255, 255), "Computer")
                    end
                end
            end)
        else
            for _, o in ipairs(espObjects) do
                if o then
                    local h = o:FindFirstChildOfClass("Highlight"); if h then h:Destroy() end
                    local b = o:FindFirstChildOfClass("BillboardGui"); if b then b:Destroy() end
                end
            end
            espObjects = {}
        end
    end
end)
