-- ✅ Universal Admin Panel v19 (PC + Mobile)
-- Автор: @Wyoleu
-- Работает из StarterPlayerScripts

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- helper tween
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
local moveDir = Vector3.zero

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

-- === МОБИЛЬНЫЙ ДЖОЙСТИК ===
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

local dragging, touchInput = false, nil
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
		moveDir = Vector3.new(dir.X / 40, 0, dir.Y / 40)
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
		-- ✅ Исправлен
