-- LocalScript placed in StarterPlayer > StarterPlayerScripts
-- Type ANY username and become their avatar

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MorphGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 350, 0, 250)
frame.Position = UDim2.new(0.5, -175, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Draggable functionality
local dragging = false
local dragInput, mousePos, framePos

frame.InputBegan:Connect(function(input, gameProcessed)
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
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Morph by Username"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.Parent = frame

local textBox = Instance.new("TextBox")
textBox.Name = "UsernameBox"
textBox.Size = UDim2.new(1, -20, 0, 45)
textBox.Position = UDim2.new(0, 10, 0, 50)
textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.PlaceholderText = "Enter Username"
textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
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
button.Size = UDim2.new(1, -20, 0, 50)
button.Position = UDim2.new(0, 10, 0, 110)
button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
button.Text = "Morph"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 22
button.Parent = frame

local bCorner = Instance.new("UICorner")
bCorner.CornerRadius = UDim.new(0, 8)
bCorner.Parent = button

button.MouseEnter:Connect(function()
	button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
end)

button.MouseLeave:Connect(function()
	button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
end)

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Size = UDim2.new(1, -20, 0, 35)
status.Position = UDim2.new(0, 10, 0, 170)
status.BackgroundTransparency = 1
status.Text = "Ready to morph"
status.TextColor3 = Color3.fromRGB(150, 200, 150)
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextWrapped = true
status.Parent = frame

local function setStatus(msg, color)
	status.Text = msg
	status.TextColor3 = color or Color3.fromRGB(150, 200, 150)
end

local function getUserIdFromUsername(username)
	local success, result = pcall(function()
		return HttpService:GetAsync("https://api.roblox.com/users/get-by-username?username=" .. HttpService:UrlEncode(username))
	end)
	
	if success then
		local data = HttpService:JSONDecode(result)
		if data.id then
			return data.id
		end
	end
	return nil
end

local function getAvatarAssets(userId)
	local success, result = pcall(function()
		return HttpService:GetAsync("https://avatar.roblox.com/v1/users/" .. userId .. "/avatar")
	end)
	
	if success then
		local data = HttpService:JSONDecode(result)
		return data
	end
	return nil
end

local morphedCharacter = nil

local function morphCharacter(username)
	setStatus("Fetching user ID...", Color3.fromRGB(200, 200, 100))
	task.wait(0.3)
	
	-- Get user ID from username
	local userId = getUserIdFromUsername(username)
	if not userId then
		setStatus("User not found!", Color3.fromRGB(255, 100, 100))
		return
	end
	
	setStatus("Fetching avatar...", Color3.fromRGB(200, 200, 100))
	task.wait(0.3)
	
	-- Get avatar data
	local avatarData = getAvatarAssets(userId)
	if not avatarData then
		setStatus("Failed to fetch avatar!", Color3.fromRGB(255, 100, 100))
		return
	end
	
	setStatus("Creating morph...", Color3.fromRGB(200, 200, 100))
	task.wait(0.3)
	
	-- Get current character
	local currentChar = player.Character
	if not currentChar then
		setStatus("Spawn your character first!", Color3.fromRGB(255, 100, 100))
		return
	end
	
	local hrp = currentChar:FindFirstChild("HumanoidRootPart")
	if not hrp then
		setStatus("No HumanoidRootPart found!", Color3.fromRGB(255, 100, 100))
		return
	end
	
	local saveCFrame = hrp.CFrame
	
	-- Remove old morphed character if it exists
	if morphedCharacter and morphedCharacter.Parent then
		morphedCharacter:Destroy()
		morphedCharacter = nil
	end
	
	-- Create humanoid description from avatar data
	local desc = Instance.new("HumanoidDescription")
	
	-- Default body colors (R15)
	desc.HeadColor3 = Color3.fromRGB(255, 224, 192)
	desc.TorsoColor3 = Color3.fromRGB(255, 0, 0)
	desc.LeftArmColor3 = Color3.fromRGB(255, 224, 192)
	desc.RightArmColor3 = Color3.fromRGB(255, 224, 192)
	desc.LeftLegColor3 = Color3.fromRGB(0, 0, 139)
	desc.RightLegColor3 = Color3.fromRGB(0, 0, 139)
	
	-- Add accessories from avatar
	local accessories = {}
	if avatarData.assets then
		for _, asset in ipairs(avatarData.assets) do
			if asset.assetType and asset.assetType.name and asset.id then
				local assetType = asset.assetType.name
				-- Skip body parts, only add accessories and wearables
				if assetType ~= "Head" and assetType ~= "Torso" and assetType ~= "LeftArm" and assetType ~= "RightArm" and assetType ~= "LeftLeg" and assetType ~= "RightLeg" then
					table.insert(accessories, asset.id)
				end
			end
		end
	end
	
	if #accessories > 0 then
		desc.Accessories = accessories
	end
	
	-- Create new character
	morphedCharacter = Instance.new("Model")
	morphedCharacter.Name = "MorphedCharacter"
	
	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = morphedCharacter
	humanoid:LoadDescription(desc)
	
	morphedCharacter.Parent = workspace
	
	-- Move to current position
	local newRoot = morphedCharacter:FindFirstChild("HumanoidRootPart")
	if newRoot then
		newRoot.CFrame = saveCFrame
	end
	
	-- Hide original character
	for _, part in pairs(currentChar:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = 1
			part.CanCollide = false
		end
	end
	
	-- Keep synced with camera and movement
	local connection
	connection = RunService.RenderStepped:Connect(function()
		if currentChar and currentChar.Parent and morphedCharacter and morphedCharacter.Parent then
			local origRoot = currentChar:FindFirstChild("HumanoidRootPart")
			local morphRoot = morphedCharacter:FindFirstChild("HumanoidRootPart")
			if origRoot and morphRoot then
				morphRoot.CFrame = origRoot.CFrame
				morphRoot.Velocity = origRoot.Velocity
				
				-- Sync animations
				local origHumanoid = currentChar:FindFirstChildOfClass("Humanoid")
				local morphHumanoid = morphedCharacter:FindFirstChildOfClass("Humanoid")
				if origHumanoid and morphHumanoid then
					morphHumanoid.MoveDirection = origHumanoid.MoveDirection
					morphHumanoid:MoveTo(origHumanoid.MoveDirection)
				end
			end
		elseif not (morphedCharacter and morphedCharacter.Parent) then
			connection:Disconnect()
		end
	end)
	
	setStatus("Morphed into " .. username .. "!", Color3.fromRGB(100, 255, 100))
end

button.MouseButton1Click:Connect(function()
	local username = textBox.Text:match("^%s*(.-)%s*$")
	
	if username == "" then
		setStatus("Enter a username!", Color3.fromRGB(255, 100, 100))
		return
	end
	
	morphCharacter(username)
	textBox.Text = ""
end)

textBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		button:Fire("MouseButton1Click")
	end
end)
