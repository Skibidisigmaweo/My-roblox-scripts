-- Load the Rayfield UI Library (Clean interface)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "FTF Ultimate | Custom",
   LoadingTitle = "Loading script...",
   LoadingSubtitle = "by You",
   ConfigurationSaving = { Enabled = false },
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local espFolder = Instance.new("Folder", Workspace)
espFolder.Name = "FTF_ESP_Folder"

local isInfJump = false
local espEnabled = false

-- Infinite Jump Logic
UserInputService.JumpRequest:Connect(function()
    if isInfJump then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ESP Function
local function createESP(object, color, name)
    if not object then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_" .. object.Name
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0
    highlight.Parent = object
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = object
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = name
    text.TextColor3 = color
    text.TextStrokeTransparency = 0
    text.TextScaled = true
    text.Parent = billboard
end

-- ESP Update Loop
task.spawn(function()
    while task.wait(1) do
        if espEnabled then
            -- Player ESP
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    if not player.Character:FindFirstChild("ESP_HumanoidRootPart") then
                        createESP(player.Character, Color3.fromRGB(255, 0, 0), player.Name)
                    end
                end
            end
            -- Object ESP (Computers, Exits, Pods)
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") then
                    local name = obj.Name:lower()
                    if name:find("computer") or name:find("hack") then
                        if not obj:FindFirstChild("ESP_" .. obj.Name) then createESP(obj, Color3.fromRGB(0, 255, 255), "Computer") end
                    elseif name:find("exit") then
                        if not obj:FindFirstChild("ESP_" .. obj.Name) then createESP(obj, Color3.fromRGB(0, 255, 0), "EXIT") end
                    elseif name:find("pod") or name:find("freeze") then
                        if not obj:FindFirstChild("ESP_" .. obj.Name) then createESP(obj, Color3.fromRGB(0, 150, 255), "Freeze Pod") end
                    end
                end
            end
        else
            for _, child in pairs(Workspace:GetDescendants()) do
                if child.Name:find("ESP_") or child:findFirstChild("ESP_Billboard") then
                    child:Destroy()
                end
            end
        end
    end
end)

-- Create Tabs
local MainTab = Window:CreateTab("Main", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483362458)
local TeleportTab = Window:CreateTab("Teleports", 4483362458)

-- Main Tab
MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 150},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
   end,
})

MainTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 200},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 50,
   Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
   end,
})

MainTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfJumpToggle",
   Callback = function(Value)
        isInfJump = Value
   end,
})

-- Visual Tab
VisualTab:CreateToggle({
   Name = "Enable ESP (Players & Objects)",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
        espEnabled = Value
   end,
})

-- Teleport Tab
TeleportTab:CreateButton({
   Name = "Teleport to Computer",
   Callback = function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():find("computer") or obj.Name:lower():find("hack")) then
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                if root and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = root.CFrame + Vector3.new(0, 3, 0)
                    break
                end
            end
        end
   end,
})

TeleportTab:CreateButton({
   Name = "Teleport to Exit",
   Callback = function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find("exit") then
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                if root and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = root.CFrame + Vector3.new(0, 3, 0)
                    break
                end
            end
        end
   end,
})

Rayfield:LoadConfiguration()
