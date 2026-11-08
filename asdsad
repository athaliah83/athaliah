--// XINN PANEL v2.2
--// Player ESP GUI
--// For your own Roblox Studio experience
--// StarterPlayer > StarterPlayerScripts > LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

--// CLEANUP OLD GUI
local old = PG:FindFirstChild("XINN_PANEL")
if old then
	old:Destroy()
end

--// SETTINGS
local Settings = {
	ESP = true,
	Name = true,
	Health = true,
	Distance = true,
	Highlight = true,
	Box = true,
	HeadDot = false,

	TargetEnabled = true,
	FOVVisible = true,
	FOVRadius = 130,
	TargetPart = "Head"
}

local running = true
local currentTarget = nil
local espObjects = {}
local toggleButtons = {}

local RED = Color3.fromRGB(255, 35, 55)
local DARK = Color3.fromRGB(12, 10, 14)
local PANEL = Color3.fromRGB(23, 19, 25)
local INNER = Color3.fromRGB(34, 27, 34)
local WHITE = Color3.fromRGB(245, 240, 245)
local MUTED = Color3.fromRGB(160, 150, 160)
local GREEN = Color3.fromRGB(70, 220, 130)

--// GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = "XINN_PANEL"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.DisplayOrder = 50
GUI.Parent = PG

local scale = Instance.new("UIScale")
scale.Parent = GUI

local function updateScale()
	local camera = workspace.CurrentCamera
	if not camera then return end

	local viewport = camera.ViewportSize
	scale.Scale = math.clamp(
		math.min(viewport.X / 540, viewport.Y / 430),
		0.55,
		1
	)
end

updateScale()

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(updateScale)

if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(520, 390)
Main.Position = UDim2.new(0.5, -260, 0.5, -195)
Main.BackgroundColor3 = DARK
Main.BorderSizePixel = 0
Main.Parent = GUI

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke")
Stroke.Color = RED
Stroke.Thickness = 1.5
Stroke.Parent = Main

--// HEADER
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = PANEL
Header.BorderSizePixel = 0
Header.Parent = Main

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -110, 1, 0)
Title.Position = UDim2.fromOffset(16, 0)
Title.BackgroundTransparency = 1
Title.Text = "XINN PANEL  |  v2.2"
Title.TextColor3 = RED
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(34, 30)
Close.Position = UDim2.new(1, -42, 0, 9)
Close.BackgroundColor3 = Color3.fromRGB(95, 20, 30)
Close.Text = "X"
Close.TextColor3 = WHITE
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Close.Parent = Header
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(34, 30)
Minimize.Position = UDim2.new(1, -82, 0, 9)
Minimize.BackgroundColor3 = INNER
Minimize.Text = "-"
Minimize.TextColor3 = WHITE
Minimize.Font = Enum.Font.GothamBold
Minimize.TextSize = 18
Minimize.Parent = Header
Instance.new("UICorner", Minimize).CornerRadius = UDim.new(0, 6)

--// SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Position = UDim2.fromOffset(10, 58)
Sidebar.Size = UDim2.new(0, 120, 1, -68)
Sidebar.BackgroundColor3 = PANEL
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

--// CONTENT
local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(140, 58)
Content.Size = UDim2.new(1, -150, 1, -68)
Content.BackgroundColor3 = PANEL
Content.BorderSizePixel = 0
Content.Parent = Main
Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 8)

local Pages = {}
local activePage = nil

local function makePage(name)
	local page = Instance.new("ScrollingFrame")
	page.Name = name
	page.Size = UDim2.new(1, -16, 1, -16)
	page.Position = UDim2.fromOffset(8, 8)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = RED
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.Visible = false
	page.Parent = Content

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = page

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
	end)

	Pages[name] = page
	return page
end

local function showPage(name)
	activePage = name

	for pageName, page in pairs(Pages) do
		page.Visible = pageName == name
	end
end

local function label(parent, text)
	local obj = Instance.new("TextLabel")
	obj.Size = UDim2.new(1, -4, 0, 28)
	obj.BackgroundTransparency = 1
	obj.Text = text
	obj.TextColor3 = WHITE
	obj.Font = Enum.Font.GothamBold
	obj.TextSize = 13
	obj.TextXAlignment = Enum.TextXAlignment.Left
	obj.Parent = parent
	return obj
end

local function button(parent, text, callback)
	local obj = Instance.new("TextButton")
	obj.Size = UDim2.new(1, -4, 0, 36)
	obj.BackgroundColor3 = INNER
	obj.Text = text
	obj.TextColor3 = WHITE
	obj.Font = Enum.Font.Gotham
	obj.TextSize = 12
	obj.AutoButtonColor = true
	obj.Parent = parent

	Instance.new("UICorner", obj).CornerRadius = UDim.new(0, 6)

	local line = Instance.new("UIStroke")
	line.Color = Color3.fromRGB(65, 45, 55)
	line.Thickness = 1
	line.Parent = obj

	obj.MouseButton1Click:Connect(callback)
	return obj
end

local function section(parent, text)
	local obj = label(parent, text)
	obj.TextColor3 = RED
	return obj
end

--// PAGES
local MainPage = makePage("MAIN")
local VisualPage = makePage("VISUALS")
local SettingsPage = makePage("SETTINGS")
local MiscPage = makePage("MISC")
local AboutPage = makePage("ABOUT")

--// SIDEBAR BUTTONS
local tabNames = {"MAIN", "VISUALS", "SETTINGS", "MISC", "ABOUT"}

for index, name in ipairs(tabNames) do
	local tab = Instance.new("TextButton")
	tab.Size = UDim2.new(1, -12, 0, 36)
	tab.Position = UDim2.fromOffset(6, 8 + (index - 1) * 43)
	tab.BackgroundColor3 = INNER
	tab.Text = name
	tab.TextColor3 = WHITE
	tab.Font = Enum.Font.GothamBold
	tab.TextSize = 11
	tab.Parent = Sidebar

	Instance.new("UICorner", tab).CornerRadius = UDim.new(0, 6)

	tab.MouseButton1Click:Connect(function()
		showPage(name)
	end)
end

--// TOGGLE SYSTEM
local function addToggle(parent, settingName, displayName)
	local btn

	local function refresh()
		local enabled = Settings[settingName]
		btn.Text = displayName .. " : " .. (enabled and "ON" or "OFF")
		btn.BackgroundColor3 = enabled and Color3.fromRGB(75, 20, 30) or INNER
	end

	btn = button(parent, displayName, function()
		Settings[settingName] = not Settings[settingName]
		refresh()
	end)

	toggleButtons[settingName] = refresh
	refresh()

	return btn
end

--// MAIN PAGE
section(MainPage, "PLAYER TARGET SELECTION")

addToggle(MainPage, "TargetEnabled", "PLAYER TARGET")

addToggle(MainPage, "FOVVisible", "SHOW FOV CIRCLE")

local targetPartButton

targetPartButton = button(MainPage, "TARGET PART : " .. Settings.TargetPart, function()
	if Settings.TargetPart == "Head" then
		Settings.TargetPart = "HumanoidRootPart"
	else
		Settings.TargetPart = "Head"
	end

	targetPartButton.Text = "TARGET PART : " .. Settings.TargetPart
end)

local radiusButton

radiusButton = button(MainPage, "FOV SIZE : " .. Settings.FOVRadius, function()
	Settings.FOVRadius += 30

	if Settings.FOVRadius > 250 then
		Settings.FOVRadius = 70
	end

	radiusButton.Text = "FOV SIZE : " .. Settings.FOVRadius
end)

local TargetLabel = label(MainPage, "CURRENT TARGET : NONE")
TargetLabel.TextColor3 = RED

--// VISUALS PAGE
section(VisualPage, "PLAYER ESP SETTINGS")

addToggle(VisualPage, "ESP", "MASTER ESP")
addToggle(VisualPage, "Name", "NAME ESP")
addToggle(VisualPage, "Health", "HEALTH ESP")
addToggle(VisualPage, "Distance", "DISTANCE ESP")
addToggle(VisualPage, "Highlight", "PLAYER HIGHLIGHT")
addToggle(VisualPage, "Box", "BOX ESP")
addToggle(VisualPage, "HeadDot", "HEAD DOT")

--// SETTINGS PAGE
section(SettingsPage, "INFORMATION")
label(SettingsPage, "ESP scans other player characters.")
label(SettingsPage, "Your own character is excluded.")
label(SettingsPage, "FOV is for visual target selection.")
label(SettingsPage, "No attack or aim automation.")

--// MISC PAGE
section(MiscPage, "OTHER OPTIONS")

button(MiscPage, "RESET ESP SETTINGS", function()
	Settings.ESP = true
	Settings.Name = true
	Settings.Health = true
	Settings.Distance = true
	Settings.Highlight = true
	Settings.Box = true
	Settings.HeadDot = false
	Settings.TargetEnabled = true
	Settings.FOVVisible = true
	Settings.FOVRadius = 130
	Settings.TargetPart = "Head"

	for _, refresh in pairs(toggleButtons) do
		refresh()
	end

	targetPartButton.Text = "TARGET PART : " .. Settings.TargetPart
	radiusButton.Text = "FOV SIZE : " .. Settings.FOVRadius
end)

--// ABOUT PAGE
section(AboutPage, "XINN PANEL")
label(AboutPage, "Version : 2.2")
label(AboutPage, "Player ESP Edition")
label(AboutPage, "Made for Roblox Studio")
label(AboutPage, "Black / Red Interface")

showPage("MAIN")

--// FOV CIRCLE
local FOV = Instance.new("Frame")
FOV.Name = "FOVCircle"
FOV.Size = UDim2.fromOffset(Settings.FOVRadius * 2, Settings.FOVRadius * 2)
FOV.AnchorPoint = Vector2.new(0.5, 0.5)
FOV.BackgroundTransparency = 1
FOV.BorderSizePixel = 0
FOV.Parent = GUI

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOV

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = RED
FOVStroke.Thickness = 1.5
FOVStroke.Parent = FOV

--// ESP OBJECTS
local function removeESP(player)
	local objects = espObjects[player]
	if not objects then return end

	for _, obj in pairs(objects) do
		if obj and obj.Parent then
			obj:Destroy()
		end
	end

	espObjects[player] = nil
end

local function createESP(player)
	if player == LP or espObjects[player] then
		return
	end

	local character = player.Character
	if not character then return end

	local head = character:FindFirstChild("Head")
	local root = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not head or not root or not humanoid then
		return
	end

	local objects = {}
	espObjects[player] = objects

	-- HIGHLIGHT
	local highlight = Instance.new("Highlight")
	highlight.Name = "XINN_Highlight"
	highlight.Adornee = character
	highlight.FillColor = RED
	highlight.OutlineColor = WHITE
	highlight.FillTransparency = 0.65
	highlight.OutlineTransparency = 0
	highlight.Parent = character
	objects.Highlight = highlight

	-- BOX
	local box = Instance.new("SelectionBox")
	box.Name = "XINN_Box"
	box.Adornee = character
	box.Color3 = RED
	box.LineThickness = 0.035
	box.SurfaceTransparency = 1
	box.Parent = character
	objects.Box = box

	-- HEAD DOT
	local dot = Instance.new("BillboardGui")
	dot.Name = "XINN_HeadDot"
	dot.Adornee = head
	dot.Size = UDim2.fromOffset(12, 12)
	dot.AlwaysOnTop = true
	dot.Parent = head

	local dotFrame = Instance.new("Frame")
	dotFrame.Size = UDim2.fromScale(1, 1)
	dotFrame.BackgroundColor3 = RED
	dotFrame.BorderSizePixel = 0
	dotFrame.Parent = dot
	Instance.new("UICorner", dotFrame).CornerRadius = UDim.new(1, 0)
	objects.Dot = dot

	-- INFO LABEL
	local info = Instance.new("BillboardGui")
	info.Name = "XINN_PlayerInfo"
	info.Adornee = head
	info.Size = UDim2.fromOffset(180, 55)
	info.StudsOffset = Vector3.new(0, 2.5, 0)
	info.AlwaysOnTop = true
	info.Parent = head

	local infoText = Instance.new("TextLabel")
	infoText.Name = "Info"
	infoText.Size = UDim2.fromScale(1, 1)
	infoText.BackgroundTransparency = 1
	infoText.TextColor3 = WHITE
	infoText.TextStrokeTransparency = 0.2
	infoText.Font = Enum.Font.GothamBold
	infoText.TextSize = 12
	infoText.Text = player.Name
	infoText.Parent = info
	objects.Info = info
	objects.InfoText = infoText
end

local function updateESP(player)
	local objects = espObjects[player]
	if not objects then return end

	local character = player.Character
	if not character then
		removeESP(player)
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	local head = character:FindFirstChild("Head")

	if not humanoid or not root or not head then
		removeESP(player)
		return
	end

	local enabled = Settings.ESP

	objects.Highlight.Enabled = enabled and Settings.Highlight
	objects.Box.Visible = enabled and Settings.Box
	objects.Dot.Enabled = enabled and Settings.HeadDot
	objects.Info.Enabled = enabled and (
		Settings.Name or Settings.Health or Settings.Distance
	)

	local text = {}

	if Settings.Name then
		table.insert(text, player.DisplayName)
	end

	if Settings.Health then
		table.insert(text, "HP: " .. math.floor(humanoid.Health))
	end

	if Settings.Distance then
		local myCharacter = LP.Character
		local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")

		if myRoot then
			local distance = (myRoot.Position - root.Position).Magnitude
			table.insert(text, math.floor(distance) .. " studs")
		end
	end

	objects.InfoText.Text = table.concat(text, "\n")
end

local function refreshAllESP()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LP then
			if Settings.ESP then
				if not espObjects[player] then
					createESP(player)
				end
				updateESP(player)
			elseif espObjects[player] then
				removeESP(player)
			end
		end
	end
end

--// PLAYER CONNECTIONS
local connections = {}

local function watchPlayer(player)
	if player == LP then return end

	local function onCharacter(character)
		removeESP(player)

		task.spawn(function()
			local humanoid = character:WaitForChild("Humanoid", 10)
			local root = character:WaitForChild("HumanoidRootPart", 10)
			local head = character:WaitForChild("Head", 10)

			if humanoid and root and head and running then
				createESP(player)
				updateESP(player)
			end
		end)
	end

	if player.Character then
		onCharacter(player.Character)
	end

	connections[player] = player.CharacterAdded:Connect(onCharacter)
end

for _, player in ipairs(Players:GetPlayers()) do
	watchPlayer(player)
end

local addedConnection = Players.PlayerAdded:Connect(watchPlayer)

local removingConnection = Players.PlayerRemoving:Connect(function(player)
	removeESP(player)

	if connections[player] then
		connections[player]:Disconnect()
		connections[player] = nil
	end
end)

--// TARGET SELECTION
local function getClosestPlayer()
	local camera = workspace.CurrentCamera
	if not camera then return nil end

	local mousePosition = UIS:GetMouseLocation()
	local closest = nil
	local shortestDistance = Settings.FOVRadius

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LP and player.Character then
			local character = player.Character
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local part = character:FindFirstChild(Settings.TargetPart)

			if humanoid and humanoid.Health > 0 and part then
				local screenPosition, visible =
					camera:WorldToViewportPoint(part.Position)

				if visible and screenPosition.Z > 0 then
					local distance = (
						Vector2.new(screenPosition.X, screenPosition.Y)
						- mousePosition
					).Magnitude

					if distance <= shortestDistance then
						shortestDistance = distance
						closest = player
					end
				end
			end
		end
	end

	return closest
end

--// DRAG GUI
local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = Main.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then
		local delta = input.Position - dragStart

		Main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

--// MINIMIZE
local minimized = false

Minimize.MouseButton1Click:Connect(function()
	minimized = not minimized
	Sidebar.Visible = not minimized
	Content.Visible = not minimized
	Main.Size = minimized
		and UDim2.fromOffset(520, 48)
		or UDim2.fromOffset(520, 390)

	Minimize.Text = minimized and "+" or "-"
end)

--// MAIN LOOP
local renderConnection

renderConnection = RunService.RenderStepped:Connect(function()
	if not running then return end

	local mousePosition = UIS:GetMouseLocation()

	FOV.Position = UDim2.fromOffset(mousePosition.X, mousePosition.Y)
	FOV.Size = UDim2.fromOffset(
		Settings.FOVRadius * 2,
		Settings.FOVRadius * 2
	)
	FOV.Visible = Settings.FOVVisible

	if Settings.TargetEnabled then
		currentTarget = getClosestPlayer()

		if currentTarget then
			TargetLabel.Text = "CURRENT TARGET : " .. currentTarget.DisplayName
		else
			TargetLabel.Text = "CURRENT TARGET : NONE"
		end
	else
		currentTarget = nil
		TargetLabel.Text = "CURRENT TARGET : DISABLED"
	end

	refreshAllESP()
end)

--// CLOSE / CLEANUP
Close.MouseButton1Click:Connect(function()
	running = false

	if renderConnection then
		renderConnection:Disconnect()
	end

	addedConnection:Disconnect()
	removingConnection:Disconnect()

	for player, connection in pairs(connections) do
		connection:Disconnect()
		connections[player] = nil
	end

	for player in pairs(espObjects) do
		removeESP(player)
	end

	GUI:Destroy()
end)

print("XINN PANEL v2.2 loaded successfully")
