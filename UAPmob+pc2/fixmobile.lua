-- ✅ Universal Admin Panel (PC + Mobile)
-- Автор: @wyoleuu

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- tween helper
local function tween(obj, props, time)
	TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props):Play()
end

-- === ЗАСТАВКА ===
local splash = Instance.new("ScreenGui")
splash.Parent = player:WaitForChild("PlayerGui")
splash.IgnoreGuiInset = true
splash.ResetOnSpawn = false

local splashFrame = Instance.new("Frame")
splashFrame.Parent = splash
splashFrame.Size = UDim2.new(1, 0, 1, 0)
splashFrame.BackgroundColor3 = Color3.new(0, 0, 0)

local splashText = Instance.new("TextLabel")
splashText.Parent = splashFrame
splashText.Size = UDim2.new(1, 0, 1, 0)
splashText.Text = "Universal Admin Panel by wyoleuu\nУспешно запущена!"
splashText.TextColor3 = Color3.new(1, 1, 1)
splashText.Font = Enum.Font.GothamBold
splashText.TextScaled = true
splashText.BackgroundTransparency = 1

local sound = Instance.new("Sound")
sound.Parent = splashFrame
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
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")
gui.Name = "UniversalAdminPanel"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- === Главная кнопка ===
local mainButton = Instance.new("TextButton")
mainButton.Parent = gui
mainButton.Size = UDim2.new(0, 280, 0, 50)
mainButton.Position = UDim2.new(0.05, 0, 0.25, 0)
mainButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainButton.TextColor3 = Color3.new(1, 1, 1)
mainButton.Font = Enum.Font.GothamBold
mainButton.TextSize = 18
mainButton.Text = "Universal Admin Panel by wyoleuu"
Instance.new("UICorner").Parent = mainButton

-- === Перетаскивание любой GUI-кнопки ===
local function makeDraggable(guiObject)
	local dragging, dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		guiObject.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)
end

makeDraggable(mainButton)

-- === Панель ===
local panel = Instance.new("Frame")
panel.Parent = gui
panel.Size = UDim2.new(0, 280, 0, 0)
panel.Position = UDim2.new(0.05, 0, 0.25, 60)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
panel.Visible = false
Instance.new("UICorner").Parent = panel

makeDraggable(panel)

-- === МОБИЛЬНЫЙ ДЖОЙСТИК ===
local joystickGui = Instance.new("Frame")
joystickGui.Parent = gui
joystickGui.Size = UDim2.new(0, 120, 0, 120)
joystickGui.Position = UDim2.new(0.05, 0, 0.7, 0)
joystickGui.BackgroundTransparency = 1
joystickGui.Visible = UserInputService.TouchEnabled

local outer = Instance.new("ImageLabel")
outer.Parent = joystickGui
outer.Size = UDim2.new(0, 120, 0, 120)
outer.Image = "rbxassetid://5108535320"
outer.ImageTransparency = 0.3
outer.BackgroundTransparency = 1

local inner = Instance.new("ImageLabel")
inner.Parent = outer
inner.Size = UDim2.new(0, 40, 0, 40)
inner.Position = UDim2.new(0.5, -20, 0.5, -20)
inner.Image = "rbxassetid://5108534567"
inner.BackgroundTransparency = 1

local draggingJoy, touchInput = false, nil
outer.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		draggingJoy = true
		touchInput = input
	end
end)

outer.InputEnded:Connect(function(input)
	if input == touchInput then
		draggingJoy = false
		moveDir = Vector3.zero
		tween(inner, {Position = UDim2.new(0.5, -20, 0.5, -20)}, 0.2)
	end
end)

UserInputService.TouchMoved:Connect(function(input)
	if draggingJoy and input == touchInput then
		local center = outer.AbsolutePosition + outer.AbsoluteSize / 2
		local dir = Vector2.new(input.Position.X - center.X, input.Position.Y - center.Y)
		if dir.Magnitude > 0 then
			local dist = math.min(dir.Magnitude, 40)
			dir = dir.Unit * dist
			inner.Position = UDim2.new(0.5, dir.X - 20, 0.5, dir.Y - 20)
			moveDir = Vector3.new(dir.X / 40, 0, -dir.Y / 40)
		end
	end
end)

-- === КНОПКИ ===
local buttons = {}
local function newButton(text, order, func)
	local btn = Instance.new("TextButton")
	btn.Parent = panel
	btn.Size = UDim2.new(1, -20, 0, 40)
	btn.Position = UDim2.new(0, 10, 0, 10 + (order - 1) * 45)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 16
	btn.Text = text
	Instance.new("UICorner").Parent = btn

	local ind = Instance.new("TextLabel")
	ind.Parent = btn
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

-- === Остальные функции (Fly, Noclip, Spin, ESP, Goto) остаются без изменений ===
-- (тот же код, что в предыдущей версии)

print("✅ Universal Admin Panel by wyoleuu запущен успешно (PC + Mobile, movable panel)")
