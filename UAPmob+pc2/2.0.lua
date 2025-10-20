-- ✅ Universal Admin Panel (PC + Mobile)
-- Создатель: @Wyoleu

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- tween helper
local function tween(obj, props, time)
	TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props):Play()
end

-- === ЗАСТАВКА ===
local splash = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
splash.IgnoreGuiInset = true
splash.ResetOnSpawn = false

local splashFrame = Instance.new("Frame", splash)
splashFrame.Size = UDim2.new(1, 0, 1, 0)
splashFrame.BackgroundColor3 = Color3.new(0, 0, 0)

local splashText = Instance.new("TextLabel", splashFrame)
splashText.Size = UDim2.new(1, 0, 1, 0)
splashText.Text = "Universal Admin Panel by @Wyoleu\nУспешно запущена!"
splashText.TextColor3 = Color3.new(1, 1, 1)
splashText.Font = Enum.Font.GothamBold
splashText.TextScaled = true
splashText.BackgroundTransparency = 1

local sound = Instance.new("Sound", splashFrame)
sound.SoundId = "rbxassetid://9120846534"
sound.Volume = 2
sound:Play()

task.wait(2)
tween(splashFrame, {BackgroundTransparency = 1}, 1)
tween(splashText, {TextTransparency = 1}, 1)
task.wait(1)
splash:Destroy()

-- === ПЕРЕМЕННЫЕ ===
local flying, noclip, spinEnabled, espEnabled = false, false, false, false
local flightSpeed, spinSpeed = 50, 5
local bodyGyro, bodyVelocity

-- === GUI ===
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "UniversalAdminPanel"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Главная кнопка
local mainButton = Instance.new("TextButton", gui)
mainButton.Size = UDim2.new(0, 280, 0, 50)
mainButton.Position = UDim2.new(0.05, 0, 0.25, 0)
mainButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainButton.TextColor3 = Color3.new(1, 1, 1)
mainButton.Font = Enum.Font.GothamBold
mainButton.TextSize = 18
mainButton.Text = "📂 Universal Admin Panel"
mainButton.Active = true
mainButton.Draggable = true
Instance.new("UICorner", mainButton)

-- Панель
local panel = Instance.new("Frame", gui)
panel.Size = UDim2.new(0, 280, 0, 0)
panel.Position = UDim2.new(0.05, 0, 0.25, 60)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
panel.Visible = false
panel.Active = true
panel.Draggable = true
Instance.new("UICorner", panel)

-- === МОБИЛЬНОЕ УПРАВЛЕНИЕ (аналог WASD) ===
local moveDir = Vector3.zero

local joystickGui = Instance.new("Frame", gui)
joystickGui.Size = UDim2.new(0, 120, 0, 120)
joystickGui.Position = UDim2.new(0.05, 0, 0.7, 0)
joystickGui.BackgroundTransparency = 1
joystickGui.Visible = UserInputService.TouchEnabled

local outer = Instance.new("ImageLabel", joystickGui)
outer.Size = UDim2.new(0, 120, 0, 120)
outer.Image = "rbxassetid://5108535320"
outer.ImageTransparency = 0.3
outer.BackgroundTransparency = 1

local inner = Instance.new("ImageLabel", outer)
inner.Size = UDim2.new(0, 40, 0, 40)
inner.Position = UDim2.new(0.5, -20, 0.5, -20)
inner.Image = "rbxassetid://5108534567"
inner.BackgroundTransparency = 1

local dragging = false
local touchInput

outer.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		touchInput = input
	end
end)

outer.InputEnded:Connect(function(input)
	if input == touchInput then
		dragging = false
		moveDir = Vector3.zero
		tween(inner, {Position = UDim2.new(0.5, -20, 0.5, -20)}, 0.2)
	end
end)

UserInputService.TouchMoved:Connect(function(input)
	if dragging and input == touchInput then
		local center = outer.AbsolutePosition + outer.AbsoluteSize / 2
		local dir = Vector2.new(input.Position.X - center.X, input.Position.Y - center.Y)
		local dist = math.min(dir.Magnitude, 40)
		dir = dir.Unit * dist
		inner.Position = UDim2.new(0.5, dir.X - 20, 0.5, dir.Y - 20)
		moveDir = Vector3.new(dir.X / 40, 0, -dir.Y / 40)
	end
end)

-- === КНОПКИ ===
local buttons = {}

local function newButton(text, order, func)
	local btn = Instance.new("TextButton", panel)
	btn.Size = UDim2.new(1, -20, 0, 40)
	btn.Position = UDim2.new(0, 10, 0, 10 + (order - 1) * 45)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 16
	btn.Text = text
	btn.AutoButtonColor = true
	Instance.new("UICorner", btn)
	local ind = Instance.new("TextLabel", btn)
	ind.Size = UDim2.new(0, 60, 1, 0)
	ind.Position = UDim2.new(1, -70, 0, 0)
	ind.BackgroundTransparency = 1
	ind.Text = "OFF"
	ind.TextColor3 = Color3.fromRGB(255, 50, 50)
	ind.Font = Enum.Font.GothamBold
	btn.MouseButton1Click:Connect(func)
	buttons[text] = ind
	return btn
end

local function toggleIndicator(name, state)
	local ind = buttons[name]
	if ind then
		ind.Text = state and "ON" or "OFF"
		ind.TextColor3 = state and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,50,50)
	end
end

-- === ФУНКЦИИ ===
local function toggleFly()
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local root = char.HumanoidRootPart
	flying = not flying
	toggleIndicator("Fly", flying)
	if flying then
		bodyGyro = Instance.new("BodyGyro", root)
		bodyGyro.MaxTorque = Vector3.new(400000,400000,400000)
		bodyVelocity = Instance.new("BodyVelocity", root)
		bodyVelocity.MaxForce = Vector3.new(400000,400000,400000)
	else
		if bodyGyro then bodyGyro:Destroy() end
		if bodyVelocity then bodyVelocity:Destroy() end
	end
end

local function flightController()
	if not flying or not bodyVelocity or not player.Character then return end
	local cam = workspace.CurrentCamera
	local move = Vector3.zero

	if UserInputService.KeyboardEnabled then
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end
	else
		local dir = moveDir
		move = workspace.CurrentCamera.CFrame:VectorToWorldSpace(Vector3.new(dir.X, 0, dir.Z))
	end

	bodyVelocity.Velocity = move.Magnitude > 0 and move.Unit * flightSpeed or Vector3.zero
end

local function toggleNoClip()
	noclip = not noclip
	toggleIndicator("Noclip", noclip)
end

RunService.Stepped:Connect(function()
	if noclip and player.Character then
		for _, part in ipairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
end)

local function toggleSpin()
	spinEnabled = not spinEnabled
	toggleIndicator("Spin", spinEnabled)
end

local function toggleESP()
	espEnabled = not espEnabled
	toggleIndicator("ESP (Wallhack)", espEnabled)
	for _, p in ipairs(game.Players:GetPlayers()) do
		if p ~= player and p.Character then
			local char = p.Character
			local highlight = char:FindFirstChild("ESPHighlight")
			if espEnabled then
				if not highlight then
					highlight = Instance.new("Highlight", char)
					highlight.Name = "ESPHighlight"
					highlight.FillTransparency = 1
					highlight.OutlineColor = Color3.fromRGB(255,0,0)
					highlight.OutlineTransparency = 0
					local head = char:FindFirstChild("Head")
					if head and not head:FindFirstChild("ESPName") then
						local tag = Instance.new("BillboardGui", head)
						tag.Name = "ESPName"
						tag.Size = UDim2.new(0,100,0,20)
						tag.AlwaysOnTop = true
						local lbl = Instance.new("TextLabel", tag)
						lbl.Size = UDim2.new(1,0,1,0)
						lbl.BackgroundTransparency = 1
						lbl.TextColor3 = Color3.new(1,0,0)
						lbl.Font = Enum.Font.GothamBold
						lbl.Text = p.Name
					end
				end
			else
				if highlight then highlight:Destroy() end
				local head = char:FindFirstChild("Head")
				if head and head:FindFirstChild("ESPName") then head.ESPName:Destroy() end
			end
		end
	end
end

-- === GOTO POPUP ===
local gotoPopup = Instance.new("Frame", panel)
gotoPopup.Size = UDim2.new(0, 200, 0, 100)
gotoPopup.Position = UDim2.new(0.5, -100, 0.5, -50)
gotoPopup.BackgroundColor3 = Color3.fromRGB(40,40,40)
gotoPopup.Visible = false
gotoPopup.ZIndex = 5
Instance.new("UICorner", gotoPopup)

local nameBox = Instance.new("TextBox", gotoPopup)
nameBox.Size = UDim2.new(0.9, 0, 0, 35)
nameBox.Position = UDim2.new(0.05, 0, 0.1, 0)
nameBox.PlaceholderText = "Введите ник"
nameBox.Font = Enum.Font.GothamBold
nameBox.TextSize = 16
nameBox.TextColor3 = Color3.new(1,1,1)
nameBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", nameBox)

local goBtn = Instance.new("TextButton", gotoPopup)
goBtn.Size = UDim2.new(0.9, 0, 0, 35)
goBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
goBtn.Text = "Teleport"
goBtn.Font = Enum.Font.GothamBold
goBtn.TextColor3 = Color3.new(1,1,1)
goBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
Instance.new("UICorner", goBtn)

goBtn.MouseButton1Click:Connect(function()
	local targetName = nameBox.Text
	for _, p in ipairs(game.Players:GetPlayers()) do
		if string.lower(p.Name) == string.lower(targetName) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
		end
	end
	gotoPopup.Visible = false
end)

-- === КНОПКИ ===
newButton("1. Fly", 1, toggleFly)
newButton("2. Noclip", 2, toggleNoClip)
newButton("3. Spin", 3, toggleSpin)
newButton("4. Spin +", 4, function() spinSpeed += 2 end)
newButton("5. Spin -", 5, function() spinSpeed = math.max(0, spinSpeed - 2) end)
newButton("6. ESP (Wallhack)", 6, toggleESP)
newButton("7. Fly Speed+", 7, function() flightSpeed += 10 end)
newButton("8. Fly Speed-", 8, function() flightSpeed = math.max(10, flightSpeed - 10) end)
newButton("9. Goto", 9, function() gotoPopup.Visible = not gotoPopup.Visible end)
newButton("10. Exit", 10, function() gui:Destroy() end)

-- === ПАНЕЛЬ ОТКРЫТИЕ ===
mainButton.MouseButton1Click:Connect(function()
	if panel.Visible then
		tween(panel, {Size = UDim2.new(0,280,0,0)}, 0.3)
		task.wait(0.3)
		panel.Visible = false
	else
		panel.Visible = true
		panel.Size = UDim2.new(0,280,0,0)
		tween(panel, {Size = UDim2.new(0,280,0,480)}, 0.3)
	end
end)

-- === ОСНОВНОЙ ЦИКЛ ===
RunService.Heartbeat:Connect(function()
	if spinEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(spinSpeed), 0)
	end
	flightController()
end)

print("✅ Universal Admin Panel by @wyoleu запущен (PC + Mobile)")
