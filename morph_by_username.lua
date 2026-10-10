-- LocalScript placed in StarterPlayer > StarterPlayerScripts
-- GLOBAL Avatar Morph - Type ANY username, become their avatar (client-side only)
-- Uses the correct Roblox API method (PostAsync for username->ID lookup)

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
title.Text = "Morph by Username (GLOBAL)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = frame

local textBox = Instance.new("TextBox")
textBox.Name = "UsernameBox"
textBox.Size = UDim2.new(1, -20, 0, 45)
textBox.Position = UDim2.new(0, 10, 0, 50)
textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.PlaceholderText = "Enter ANY Username"
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
status.Text = "Ready to morph GLOBALLY"
status.TextColor3 = Color3.fromRGB(150, 200, 150)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextWrapped = true
status.Parent = frame

local function setStatus(msg, color)
	status.Text = msg
	status.TextColor3 = color or Color3.fromRGB(150, 200, 150)
end

local function getUserIdFromUsername(username)
	-- CORRECT METHOD: Use PostAsync with users/v1/usernames/users endpoint
	local success, result = pcall(function()
		local url = "https://users.roblox.com/v1/usernames/users"
		local data = HttpService:JSONEncode({usernames = {username}})
		local response = HttpService:PostAsync(url, data, Enum.HttpContentType.ApplicationJson, true)
		return HttpService:JSONDecode(response)
	end)
	
	if success and result and result.data and #result.data > 0 then
		return result.data[1].id
	end
	
	return nil
end

local function getAvatarDescription(userId)
	local success, result = pcall(function()
		local url = "https://avatar.roblox.com/v1/users/" .. userId .. "/avatar"
		local response = HttpService:GetAsync(url, true)
		return HttpService:JSONDecode(response)
	end)
	
	if success and result then
		return result
	end
	return nil
end

local morphedCharacter = nil
local renderConnection = nil

local function morphCharacter(username)
	setStatus("Fetching user ID...", Color3.fromRGB(200, 200, 100))
	task.wait(0.3)
	
	-- Get user ID using correct method
	local userId = getUserIdFromUsername(username)
	if not userId then
		setStatus("User '" .. username .. "' not found!", Color3.fromRGB(255, 100, 100))
		return
	end
	
	setStatus("Fetching avatar data...", Color3.fromRGB(200, 200, 100))
	task.wait(0.3)
	
	-- Get avatar data
	local avatarData = getAvatarDescription(userId)
	if not avatarData then
		setStatus("Failed to load avatar!", Color3.fromRGB(255, 100, 100))
		return
	end
	
	setStatus("Creating morph...", Color3.fromRGB(200, 200, 100))
	
	local currentChar = player.Character
	if not currentChar then
		setStatus("Spawn first!", Color3.fromRGB(255, 100, 100))
		return
	end
	
	local hrp = currentChar:FindFirstChild("HumanoidRootPart")
	if not hrp then
		setStatus("Error: No HumanoidRootPart!", Color3.fromRGB(255, 100, 100))
		return
	end
	
	local saveCFrame = hrp.CFrame
	local saveVelocity = hrp.AssemblyLinearVelocity
	
	-- Disconnect old render connection
	if renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end
	
	-- Remove old morph
	if morphedCharacter and morphedCharacter.Parent then
		morphedCharacter:Destroy()
	end
	
	-- Create HumanoidDescription
	local desc = Instance.new("HumanoidDescription")
	
	-- Set body colors from avatar data
	if avatarData.bodyColors then
		local bc = avatarData.bodyColors
		local function getColor(colorId)
			if colorId then
				local success, color = pcall(function() return BrickColor.new(colorId).Color end)
				return success and color or Color3.fromRGB(255, 224, 192)
			end
			return Color3.fromRGB(255, 224, 192)
		end
		desc.HeadColor3 = getColor(bc.headColorId)
		desc.TorsoColor3 = getColor(bc.torsoColorId)
		desc.LeftArmColor3 = getColor(bc.leftArmColorId)
		desc.RightArmColor3 = getColor(bc.rightArmColorId)
		desc.LeftLegColor3 = getColor(bc.leftLegColorId)
		desc.RightLegColor3 = getColor(bc.rightLegColorId)
	end
	
	-- Add accessories from avatar
	local accessories = {}
	if avatarData.assets then
		for _, asset in ipairs(avatarData.assets) do
			if asset.id and asset.assetType then
				local assetType = asset.assetType.name
				-- Add all non-body-part assets
				if assetType ~= "Head" and assetType ~= "Torso" and assetType ~= "LeftArm" and assetType ~= "RightArm" and assetType ~= "LeftLeg" and assetType ~= "RightLeg" then
					table.insert(accessories, asset.id)
				end
			end
		end
	end
	
	-- Set scale
	if avatarData.scales then
		local scales = avatarData.scales
		desc.HeadScale = scales.head or 1
		desc.BodyHeightScale = scales.bodyHeight or 1
		desc.BodyWidthScale = scales.bodyWidth or 1
		desc.HeadRadiusScale = scales.head or 1
	end
	
	if #accessories > 0 then
		desc.Accessories = accessories
	end
	
	-- Create new character model
	morphedCharacter = Instance.new("Model")
	morphedCharacter.Name = "MorphedChar"
	
	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = morphedCharacter
	humanoid:LoadDescription(desc)
	
	morphedCharacter.Parent = workspace
	
	-- Position the morph
	local newRoot = morphedCharacter:FindFirstChild("HumanoidRootPart")
	if newRoot then
		newRoot.CFrame = saveCFrame
		newRoot.AssemblyLinearVelocity = saveVelocity
	end
	
	-- Hide original character
	for _, part in pairs(currentChar:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = 1
			part.CanCollide = false
		end
	end
	
	-- Sync every frame
	renderConnection = RunService.RenderStepped:Connect(function()
		if not (currentChar and currentChar.Parent and morphedCharacter and morphedCharacter.Parent) then
			if renderConnection then
				renderConnection:Disconnect()
				renderConnection = nil
			end
			return
		end
		
		local origRoot = currentChar:FindFirstChild("HumanoidRootPart")
		local morphRoot = morphedCharacter:FindFirstChild("HumanoidRootPart")
		
		if origRoot and morphRoot then
			-- Sync position and velocity
			morphRoot.CFrame = origRoot.CFrame
			morphRoot.AssemblyLinearVelocity = origRoot.AssemblyLinearVelocity
			
			-- Sync animations
			local origHum = currentChar:FindFirstChildOfClass("Humanoid")
			local morphHum = morphedCharacter:FindFirstChildOfClass("Humanoid")
			
			if origHum and morphHum then
				morphHum:MoveTo(origHum.MoveDirection * 16)
			end
		end
	end)
	
	setStatus("Morphed into " .. username .. "!", Color3.fromRGB(100, 255, 100))
	textBox.Text = ""
end

button.MouseButton1Click:Connect(function()
	local username = textBox.Text:match("^%s*(.-)%s*$")
	
	if username == "" then
		setStatus("Enter a username!", Color3.fromRGB(255, 100, 100))
		return
	end
	
	morphCharacter(username)
end)

textBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		button:Fire("MouseButton1Click")
	end
end)

-- Cleanup on death
player.CharacterAdded:Connect(function(newChar)
	if morphedCharacter and morphedCharacter.Parent then
		morphedCharacter:Destroy()
		morphedCharacter = nil
	end
	if renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end
end)
