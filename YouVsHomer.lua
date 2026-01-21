	local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
	local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

	local Window = Library:CreateWindow({
		Title = 'You VS Homer',
		Center = true,
		AutoShow = true,
		TabPadding = 8,
		MenuFadeTime = 0.2,
		Size = UDim2.new(0, 500, 0, 400)
	})

	local MainTab = Window:AddTab('Main')
	local LeftTabBox = MainTab:AddLeftTabbox()
	local LeftGroupBox = LeftTabBox:AddTab('General')
	local CoinFarmTabBox = MainTab:AddRightTabbox()
	local CoinFarmGroupBox = CoinFarmTabBox:AddTab('Coin Farm')
	local HomerTabBox = MainTab:AddRightTabbox()
	local HomerLeftGroupBox = HomerTabBox:AddTab('Homer Only')

	local Lighting = game:GetService("Lighting")
	local originalBrightness = Lighting.Brightness
	local originalAmbient = Lighting.Ambient
	local originalColorShift_Top = Lighting.ColorShift_Top
	local originalColorShift_Bottom = Lighting.ColorShift_Bottom
	local originalOutdoorAmbient = Lighting.OutdoorAmbient
	local originalFogEnd = Lighting.FogEnd
	local originalFogStart = Lighting.FogStart
	local originalGlobalShadows = Lighting.GlobalShadows

	LeftGroupBox:AddToggle('FullBright', {
		Text = 'FullBright',
		Default = false,
		Tooltip = 'Makes everything fully lit',
		Callback = function(Value)
			if Value then
				Lighting.Brightness = 2
				Lighting.Ambient = Color3.new(1, 1, 1)
				Lighting.ColorShift_Top = Color3.new(1, 1, 1)
				Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
				Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
				Lighting.FogEnd = 9e9
				Lighting.FogStart = 0
				Lighting.GlobalShadows = false
				for _, light in ipairs(Lighting:GetDescendants()) do
					if light:IsA("Light") then
						light.Shadows = false
					end
				end
			else
				Lighting.Brightness = originalBrightness
				Lighting.Ambient = originalAmbient
				Lighting.ColorShift_Top = originalColorShift_Top
				Lighting.ColorShift_Bottom = originalColorShift_Bottom
				Lighting.OutdoorAmbient = originalOutdoorAmbient
				Lighting.FogEnd = originalFogEnd
				Lighting.FogStart = originalFogStart
				Lighting.GlobalShadows = originalGlobalShadows
			end
		end
	})

	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")
	local LocalPlayer = Players.LocalPlayer
	local Camera = workspace.CurrentCamera
	local ESPBoxes = {}

	local function bypassanticheat()
		local Anticheats = {
			LocalPlayer.PlayerScripts:FindFirstChild("QuitsAntiCheatChecker"),
			LocalPlayer.PlayerScripts:FindFirstChild("QuitsAntiCheatLocal"),
			game:GetService("StarterPlayer").StarterPlayerScripts:FindFirstChild("QuitsAntiCheatChecker"),
			game:GetService("StarterPlayer").StarterPlayerScripts:FindFirstChild("QuitsAntiCheatLocal"),
		}
		for _, v in ipairs(Anticheats) do
			if v then v:Destroy() end
		end
	end

	bypassanticheat()

	local function showNotification(message)
		Library:Notify(message, 3)
	end

	local function getTeamColor(player)
		if player.Team then
			local teamName = player.Team.Name
			if teamName == "Homer" then
				return Color3.new(1, 0, 0)
			elseif teamName == "Bart" then
				return Color3.new(0, 1, 0)
			end
		end
		return Color3.new(1, 1, 1)
	end

	local function createESPBox(player)
		local box = Drawing.new("Square")
		box.Visible = false
		box.Color = getTeamColor(player)
		box.Thickness = 2
		box.Transparency = 1
		box.Filled = false
		
		local text = Drawing.new("Text")
		text.Visible = false
		text.Color = getTeamColor(player)
		text.Size = 14
		text.Center = true
		text.Outline = true
		text.Font = 2
		
		local nameText = Drawing.new("Text")
		nameText.Visible = false
		nameText.Color = getTeamColor(player)
		nameText.Size = 14
		nameText.Center = true
		nameText.Outline = true
		nameText.Font = 2
		
		ESPBoxes[player] = {box = box, text = text, nameText = nameText}
	end

	local function updateESP()
		local localCharacter = LocalPlayer.Character
		local localRootPart = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
		
		for player, espData in pairs(ESPBoxes) do
			local box = espData.box
			local text = espData.text
			local nameText = espData.nameText
			
			if player and player.Parent and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				local character = player.Character
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				local humanoid = character:FindFirstChild("Humanoid")
				
				if humanoidRootPart and Camera then
					local vector, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
					
					if onScreen then
						local size = humanoid and humanoidRootPart.Size.Y or 5
						local offset = Vector2.new(size * 2, size * 2)
						
						box.Size = offset
						box.Position = Vector2.new(vector.X - offset.X / 2, vector.Y - offset.Y / 2)
						box.Color = getTeamColor(player)
						box.Visible = true
						
						local distance = 0
						if localRootPart then
							distance = math.floor((humanoidRootPart.Position - localRootPart.Position).Magnitude)
						end
						
						nameText.Text = player.Name
						nameText.Position = Vector2.new(vector.X, vector.Y - offset.Y / 2 - 20)
						nameText.Color = getTeamColor(player)
						nameText.Visible = true
						
						text.Text = tostring(distance) .. " studs"
						text.Position = Vector2.new(vector.X, vector.Y + offset.Y / 2 + 15)
						text.Color = getTeamColor(player)
						text.Visible = true
					else
						box.Visible = false
						text.Visible = false
						nameText.Visible = false
					end
				else
					box.Visible = false
					text.Visible = false
					nameText.Visible = false
				end
			else
				box.Visible = false
				text.Visible = false
				nameText.Visible = false
			end
		end
	end

	local function cleanupESP()
		for player, espData in pairs(ESPBoxes) do
			if espData.box then
				espData.box:Remove()
			end
			if espData.text then
				espData.text:Remove()
			end
			if espData.nameText then
				espData.nameText:Remove()
			end
		end
		ESPBoxes = {}
	end

	local ESPConnection
	LeftGroupBox:AddToggle('ESP', {
		Text = 'ESP',
		Default = false,
		Tooltip = 'Shows boxes around players',
		Callback = function(Value)
			if Value then
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer then
						createESPBox(player)
					end
				end
				
				Players.PlayerAdded:Connect(function(player)
					createESPBox(player)
				end)
				
				Players.PlayerRemoving:Connect(function(player)
					if ESPBoxes[player] then
						if ESPBoxes[player].box then
							ESPBoxes[player].box:Remove()
						end
						if ESPBoxes[player].text then
							ESPBoxes[player].text:Remove()
						end
						if ESPBoxes[player].nameText then
							ESPBoxes[player].nameText:Remove()
						end
						ESPBoxes[player] = nil
					end
				end)
				
				ESPConnection = RunService.RenderStepped:Connect(updateESP)
			else
				if ESPConnection then
					ESPConnection:Disconnect()
					ESPConnection = nil
				end
				cleanupESP()
			end
		end
	})

	local noClipConnection
	local originalCanCollide = {}

	local function enableNoClip()
		if LocalPlayer.Character then
			for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					originalCanCollide[part] = true
					part.CanCollide = false
				end
			end
		end
	end

	local function disableNoClip()
		for part, canCollide in pairs(originalCanCollide) do
			if part and part.Parent then
				part.CanCollide = canCollide
			end
		end
		originalCanCollide = {}
	end

	LeftGroupBox:AddToggle('NoClip', {
		Text = 'NoClip',
		Default = false,
		Tooltip = 'Walk through walls',
		Callback = function(Value)
			if Value then
				enableNoClip()
				LocalPlayer.CharacterAdded:Connect(function()
					enableNoClip()
				end)
				noClipConnection = RunService.Stepped:Connect(function()
					if LocalPlayer.Character then
						for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
							if part:IsA("BasePart") then
								part.CanCollide = false
							end
						end
					end
				end)
			else
				disableNoClip()
				if noClipConnection then
					noClipConnection:Disconnect()
					noClipConnection = nil
				end
			end
		end
	})

	local infJumpConnection
	local UserInputService = game:GetService("UserInputService")

	LeftGroupBox:AddToggle('InfJump', {
		Text = 'INF Jump',
		Default = false,
		Tooltip = 'Jump infinitely',
		Callback = function(Value)
			if Value then
				infJumpConnection = UserInputService.JumpRequest:Connect(function()
					if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
						LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					end
				end)
			else
				if infJumpConnection then
					infJumpConnection:Disconnect()
					infJumpConnection = nil
				end
			end
		end
	})

	local currentWalkSpeed = 16
	local walkSpeedSlider

	local function updateWalkSpeed(speed)
		currentWalkSpeed = speed
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.WalkSpeed = speed
		end
	end

	walkSpeedSlider = LeftGroupBox:AddSlider('WalkSpeed', {
		Text = 'WalkSpeed',
		Default = 16,
		Min = 0,
		Max = 50,
		Rounding = 0,
		Compact = false,
		Callback = function(Value)
			updateWalkSpeed(Value)
		end
	})

	LocalPlayer.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid")
		updateWalkSpeed(currentWalkSpeed)
	end)

	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		updateWalkSpeed(currentWalkSpeed)
	end

	LeftGroupBox:AddButton({
		Text = 'Reset WalkSpeed',
		Func = function()
			currentWalkSpeed = 16
			updateWalkSpeed(16)
			if walkSpeedSlider then
				walkSpeedSlider:SetValue(16)
			end
		end,
		DoubleClick = false,
		Tooltip = 'Resets walkspeed to default (16)'
	})

	local autoKillRunning = false
	local autoKillThread
	local currentBartIndex = 1

	local function getBartTeamPlayers()
		local bartPlayers = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Team and player.Team.Name == "Bart" then
				if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
					table.insert(bartPlayers, player)
				end
			end
		end
		return bartPlayers
	end

	local function teleportToBartPlayer()
		if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			return
		end
		
		local localRootPart = LocalPlayer.Character.HumanoidRootPart
		local bartPlayers = getBartTeamPlayers()
		
		if #bartPlayers > 0 then
			if currentBartIndex > #bartPlayers then
				currentBartIndex = 1
			end
			
			local targetPlayer = bartPlayers[currentBartIndex]
			if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
				local targetRootPart = targetPlayer.Character.HumanoidRootPart
				localRootPart.CFrame = targetRootPart.CFrame
				currentBartIndex = currentBartIndex + 1
			else
				currentBartIndex = currentBartIndex + 1
			end
		end
	end

	HomerLeftGroupBox:AddToggle('AutoKill', {
		Text = 'Auto kill',
		Default = false,
		Tooltip = 'Teleports to Bart team players every second',
		Callback = function(Value)
			if Value then
				if LocalPlayer.Team and LocalPlayer.Team.Name == "Homer" then
					currentBartIndex = 1
					autoKillRunning = true
					autoKillThread = task.spawn(function()
						while autoKillRunning do
							if LocalPlayer.Team and LocalPlayer.Team.Name == "Homer" then
								teleportToBartPlayer()
							else
								autoKillRunning = false
								break
							end
							task.wait(1)
						end
					end)
				else
					showNotification("Auto kill only works when on team Homer!")
				end
			else
				autoKillRunning = false
				if autoKillThread then
					task.cancel(autoKillThread)
					autoKillThread = nil
				end
			end
		end
	})

	local coinFarmRunning = false
	local coinFarmThread
	local targetPos = CFrame.new(-33.09382247924805, 207.9499969482422, 111.34393310546875)
	local moveOffset = 0
	local originalTransparency = {}

	local function makeInvisible()
		if LocalPlayer.Character then
			for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					if not originalTransparency[part] then
						originalTransparency[part] = part.Transparency
					end
					part.Transparency = 1
				elseif part:IsA("Decal") or part:IsA("Texture") then
					if not originalTransparency[part] then
						originalTransparency[part] = part.Transparency
					end
					part.Transparency = 1
				end
			end
		end
	end

	local function makeVisible()
		for part, transparency in pairs(originalTransparency) do
			if part and part.Parent then
				part.Transparency = transparency
			end
		end
		originalTransparency = {}
	end

	local function autofarm()
		coinFarmThread = task.spawn(function()
			while coinFarmRunning do
				local character = LocalPlayer.Character
				if character and character:FindFirstChild("HumanoidRootPart") then
					local rootPart = character.HumanoidRootPart
					moveOffset = moveOffset + 0.1
					local offsetX = math.sin(moveOffset) * 2
					local offsetZ = math.cos(moveOffset) * 2
					local newPos = targetPos.Position + Vector3.new(offsetX, 0, offsetZ)
					rootPart.CFrame = CFrame.new(newPos)
					makeInvisible()
				end
				task.wait()
			end
		end)
	end

	CoinFarmGroupBox:AddToggle('CoinFarm', {
		Text = 'Coin Farm',
		Default = false,
		Tooltip = 'Automatically farms coins',
		Callback = function(Value)
			coinFarmRunning = Value
			if Value then
				bypassanticheat()
				task.wait(0.5)
				makeInvisible()
				autofarm()
				LocalPlayer.CharacterAdded:Connect(function()
					if coinFarmRunning then
						task.wait(0.1)
						makeInvisible()
					end
				end)
			else
				makeVisible()
				if coinFarmThread then
					task.cancel(coinFarmThread)
					coinFarmThread = nil
				end
			end
		end
	})

