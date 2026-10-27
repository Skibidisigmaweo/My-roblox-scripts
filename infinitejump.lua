local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local isInfJumpEnabled = false

-- The actual Infinite Jump logic
UserInputService.JumpRequest:Connect(function()
    if isInfJumpEnabled then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                -- Forces the humanoid to jump even if in mid-air
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Create the GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InfJumpGui"
ScreenGui.ResetOnSpawn = false

-- Delta-safe GUI parenting
local success, hiddenUI = pcall(function() return gethui() end)
if success and hiddenUI then
    ScreenGui.Parent = hiddenUI
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 150, 0, 50)
Button.Position = UDim2.new(0, 20, 0, 20)
Button.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Red
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 20
Button.Text = "Inf Jump: OFF"
Button.Parent = ScreenGui

Button.MouseButton1Click:Connect(function()
    isInfJumpEnabled = not isInfJumpEnabled 
    if isInfJumpEnabled then
        Button.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Green
        Button.Text = "Inf Jump: ON"
    else
        Button.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Red
        Button.Text = "Inf Jump: OFF"
    end
end)
