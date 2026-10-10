-- LocalScript placed in StarterPlayer > StarterPlayerScripts
-- Client-sided Morph by Username (Avatar API - Only you see the morph)

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

local function getAvatarBodyColors(userId)
	local success, result = pcall(function()
		return HttpService:GetAsync("https://avatar.roblox.com/v1/avatar-fetch/metadata?userId=" .. userId)
	end)
	
	if success then
		return HttpService:JSONDecode(result)
	end
	return nil
end

local function createHumanoidDescriptionFromAvatar(userId)
	local avatarData = getAvatarAssets(userId)
	if not avatarData then
		return nil
	end

	local desc = Instance.new("HumanoidDescription")
	
	-- Set body part colors
	desc.HeadColor3 = Color3.fromRGB(255, 224, 192)
	desc.TorsoColor3 = Color3.fromRGB(255, 0, 0)
	desc.LeftArmColor3 = Color3.fromRGB(255, 224, 192)
	desc.RightArmColor3 = Color3.fromRGB(255, 224, 192)
	desc.LeftLegColor3 = Color3.fromRGB(0, 0, 139)
	desc.RightLegColor3 = Color3.fromRGB(0, 0, 139)
	
	-- Try to get actual colors from avatar
	local colorData = getAvatarBodyColors(userId)
	if colorData and colorData.bodyColors then
		local colors = colorData.bodyColors
		if colors.headColorId then desc.HeadColor3 = BrickColor.new(colors.headColorId).Color end
		if colors.torsoColorId then desc.TorsoColor3 = BrickColor.new(colors.torsoColorId).Color end
		if colors.leftArmColorId then desc.LeftArmColor3 = BrickColor.new(colors.leftArmColorId).Color end
		if colors.rightArmColorId then desc.RightArmColor3 = BrickColor.new(colors.rightArmColorId).Color end
		if colors.leftLegColorId then desc.LeftLegColor3 = BrickColor.new(colors.leftLegColorId).Color end
		if colors.rightLegColorId then desc.RightLegColor3 = BrickColor.new(colors.rightLegColorId).Color end
	end
	
	-- Add accessories/assets
	if avatarData.assets then
		for _, asset in ipairs(avatarData.assets) do
			if asset.assetType and asset.assetType.name then
				local assetType = asset.assetType.name
				if assetType ~= "Head" and assetType ~= "Torso" and assetType ~= "LeftArm" and assetType ~= "RightArm" and assetType ~= "LeftLeg" and assetType ~= "RightLeg" then
					-- Add as accessory
					table.insert(desc.Accessories, asset.id)
				end
			end
		end
	end
	
	return desc
end

local originalCharacter = player.Character
local morphedCharacter = nil

local function morphCharacter(username)
	setStatus("Fetching user data...", Color3.fromRGB(200, 200, 100))
	
	-- Get user ID from username
	local userId = getUserIdFromUsername(username)
	if not userId then
		setStatus("User not found!", Color3.fromRGB(255, 100, 100))
		return
	end
	
	setStatus("Fetching avatar...", Color3.fromRGB(200, 200, 100))
	task.wait(0.5)
	
	-- Get avatar description
	local desc = createHumanoidDescriptionFromAvatar(userId)
	if not desc then
		setStatus("Failed to fetch avatar!", Color3.fromRGB(255, 100, 100))
		return
	end
	
	setStatus("Creating morph...", Color3.fromRGB(200, 200, 100))
	task.wait(0.5)
	
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
	
	-- Remove old morphed character if it exists
	if morphedCharacter and morphedCharacter.Parent then
		morphedCharacter:Destroy()
	end
	
	-- Create new character from description
	morphedCharacter = Instance.new("Model")
	morphedCharacter.Name = "MorphedCharacter"
	morphedCharacter.Parent = workspace
	
	-- Create humanoid
	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = morphedCharacter
	
	-- Load description
	humanoid:LoadDescription(desc)
	
	-- Teleport to current position
	local newRoot = morphedCharacter:FindFirstChild("HumanoidRootPart")
	if newRoot then
		newRoot.CFrame = hrp.CFrame
	end
	
	-- Make original character invisible and uncollidable
	for _, part in pairs(currentChar:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = 1
			part.CanCollide = false
		end
	end
	
	-- Parent original character to morphed character so it follows
	for _, part in pairs(currentChar:GetChildren()) do
		if part:IsA("BasePart") or part:IsA("Humanoid") or part:IsA("BodyVelocity") or part:IsA("BodyGyro") then
			-- Keep these in original
		end
	end
	
	-- Update on every frame to keep sync
	local connection
	connection = RunService.RenderStepped:Connect(function()
		if currentChar and currentChar.Parent and morphedCharacter and morphedCharacter.Parent then
			local origRoot = currentChar:FindFirstChild("HumanoidRootPart")
			local morphRoot = morphedCharacter:FindFirstChild("HumanoidRootPart")
			if origRoot and morphRoot then
				morphRoot.CFrame = origRoot.CFrame
				-- Sync velocity
				if origRoot:FindFirstChild("BodyVelocity") then
					morphRoot.Velocity = origRoot.Velocity
				end
			end
		elseif not (morphedCharacter and morphedCharacter.Parent) then
			connection:Disconnect()
		end
	end)
	
	setStatus("Morphed into " .. username .. "!", Color3.fromRGB(100, 255, 100))
end

local function undoMorph()
	if morphedCharacter and morphedCharacter.Parent then
		morphedCharacter:Destroy()
		morphedCharacter = nil
	end
	
	local currentChar = player.Character
	if currentChar then
		for _, part in pairs(currentChar:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Transparency = 0
				part.CanCollide = true
			end
		end
	end
	
	setStatus("Morph removed", Color3.fromRGB(150, 200, 150))
end

button.MouseButton1Click:Connect(function()
	local username = textBox.Text:match("^%s*(.-)%s*$")
	
	if username == "" then
		setStatus("Enter a username!", Color3.fromRGB(255, 100, 100))
		return
	end
	
	if username:lower() == "undo" or username:lower() == "remove" then
		undoMorph()
		textBox.Text = ""
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
