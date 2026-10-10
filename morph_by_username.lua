-- LocalScript placed in StarterPlayer > StarterPlayerScripts
-- Morph by Player Name with Draggable UI

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MorphGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 300, 0, 180)
frame.Position = UDim2.new(0.5, -150, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Draggable functionality
local dragging = false
local dragInput, mousePos, framePos

frame.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		mousePos = input.Position
		framePos = frame.Position
	end
end)

frame.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input, gameProcessed)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - mousePos
		frame.Position = framePos + UDim2.new(0, delta.X, 0, delta.Y)
	end
end)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "Morph by Username"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.Parent = frame

local textBox = Instance.new("TextBox")
textBox.Name = "UsernameBox"
textBox.Size = UDim2.new(1, -20, 0, 40)
textBox.Position = UDim2.new(0, 10, 0, 50)
textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.PlaceholderText = "Enter Username"
textBox.Text = ""
textBox.Font = Enum.Font.Gotham
textBox.TextSize = 18
textBox.ClearTextOnFocus = false
textBox.Parent = frame

local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(0, 8)
tbCorner.Parent = textBox

local button = Instance.new("TextButton")
button.Name = "MorphButton"
button.Size = UDim2.new(1, -20, 0, 45)
button.Position = UDim2.new(0, 10, 0, 105)
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button.Text = "Morph"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 20
button.Parent = frame

local bCorner = Instance.new("UICorner")
bCorner.CornerRadius = UDim.new(0, 10)
bCorner.Parent = button

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Size = UDim2.new(1, -20, 0, 20)
status.Position = UDim2.new(0, 10, 0, 155)
status.BackgroundTransparency = 1
status.Text = "Ready to morph"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.Parent = frame

local function setStatus(msg)
	status.Text = msg
end

button.MouseButton1Click:Connect(function()
	local username = textBox.Text
	if username == "" then
		setStatus("Enter a username first.")
		return
	end

	-- Find player by username
	local targetPlayer = nil
	for _, p in pairs(Players:GetPlayers()) do
		if p.Name:lower() == username:lower() then
			targetPlayer = p
			break
		end
	end

	if not targetPlayer then
		setStatus("No player found: " .. username)
		return
	end

	if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
		setStatus(username .. "'s character not loaded.")
		return
	end

	local character = player.Character
	if not character then
		setStatus("Spawn your character first.")
		return
	end

	local oldCharacter = character
	local hrp = oldCharacter:FindFirstChild("HumanoidRootPart")
	local cframe = hrp and hrp.CFrame or CFrame.new()

	-- Clone the target player's character
	local newRig = targetPlayer.Character:Clone()
	newRig.Name = oldCharacter.Name

	-- Remove old humanoid
	local oldHumanoid = oldCharacter:FindFirstChildOfClass("Humanoid")
	if oldHumanoid then
		oldHumanoid:Destroy()
	end

	-- Remove any existing scripts to avoid conflicts
	for _, script in pairs(newRig:GetDescendants()) do
		if script:IsA("LocalScript") or script:IsA("Script") then
			script:Destroy()
		end
	end

	-- Parent the new rig
	newRig.Parent = workspace
	player.Character = newRig

	task.wait(0.1)
	
	-- Move to old position
	newRig:PivotTo(cframe)

	-- Destroy old character
	if oldCharacter and oldCharacter.Parent then
		oldCharacter:Destroy()
	end

	setStatus("Morphed into " .. targetPlayer.Name .. "!")
end)
