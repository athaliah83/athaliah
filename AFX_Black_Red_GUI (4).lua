--[[
    WARDROBE CHARACTER CUSTOMIZER
    Roblox LocalScript
    Drag this into StarterPlayer > StarterPlayerScripts

    Features:
    - Character wardrobe UI matching the reference aesthetic
    - Outfit slots: Outfit 1 / 2 / 3
    - Categories: Body, Hair, Hats, Glasses, Masks, Hoodies, Pants, Shoes
    - Save outfit state locally
    - Dynamically applies visual wardrobe parts to the current character
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function getCharacter()
	local character = player.Character or player.CharacterAdded:Wait()
	character:WaitForChild("Humanoid")
	return character
end

local function makeCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
end

local function makeStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Parent = parent
end

local wardrobeState = {
	Slot = "Outfit 1",
	Category = "Body",
	Saved = {
		["Outfit 1"] = {},
		["Outfit 2"] = {},
		["Outfit 3"] = {},
	},
	Current = {
		Body = "Classic Skin",
		Hair = "None",
		Hat = "None",
		Glasses = "None",
		Mask = "None",
		Hoodie = "None",
		Pants = "None",
		Shoes = "None",
	},
}

local wardrobeCatalog = {
	Body = {
		{ Name = "Classic Skin", Color = Color3.fromRGB(235, 202, 174) },
		{ Name = "Warm Tan", Color = Color3.fromRGB(195, 140, 110) },
		{ Name = "Dark Brown", Color = Color3.fromRGB(135, 93, 70) },
		{ Name = "Pale", Color = Color3.fromRGB(248, 220, 196) },
	},
	Hair = {
		{ Name = "None", Color = Color3.fromRGB(0, 0, 0), Visible = false },
		{ Name = "Black Fade", Color = Color3.fromRGB(15, 15, 15), Shape = "Fade" },
		{ Name = "Dark Brown", Color = Color3.fromRGB(70, 48, 37), Shape = "Classic" },
		{ Name = "Blonde", Color = Color3.fromRGB(214, 177, 91), Shape = "Classic" },
		{ Name = "Silver", Color = Color3.fromRGB(196, 196, 196), Shape = "Classic" },
	},
	Hat = {
		{ Name = "None", Color = Color3.fromRGB(0, 0, 0), Visible = false },
		{ Name = "Red Cap", Color = Color3.fromRGB(220, 44, 44), Shape = "Cap" },
		{ Name = "Black Cap", Color = Color3.fromRGB(20, 20, 20), Shape = "Cap" },
		{ Name = "Blue Cap", Color = Color3.fromRGB(45, 96, 196), Shape = "Cap" },
		{ Name = "Beanie", Color = Color3.fromRGB(92, 62, 70), Shape = "Beanie" },
	},
	Glasses = {
		{ Name = "None", Visible = false },
		{ Name = "Round Glasses", Color = Color3.fromRGB(60, 60, 60), Shape = "Round" },
		{ Name = "Black Frame", Color = Color3.fromRGB(20, 20, 20), Shape = "Square" },
		{ Name = "Blue Lens", Color = Color3.fromRGB(62, 115, 176), Shape = "Round" },
	},
	Mask = {
		{ Name = "None", Visible = false },
		{ Name = "Black Mask", Color = Color3.fromRGB(15, 15, 15), Shape = "Mask" },
		{ Name = "White Mask", Color = Color3.fromRGB(235, 235, 235), Shape = "Mask" },
		{ Name = "Red Mask", Color = Color3.fromRGB(200, 30, 30), Shape = "Mask" },
	},
	Hoodie = {
		{ Name = "None", Visible = false },
		{ Name = "Black Hoodie", Color = Color3.fromRGB(20, 20, 20), Shape = "Jacket" },
		{ Name = "Red Hoodie", Color = Color3.fromRGB(180, 32, 32), Shape = "Jacket" },
		{ Name = "Blue Hoodie", Color = Color3.fromRGB(60, 98, 180), Shape = "Jacket" },
	},
	Pants = {
		{ Name = "None", Visible = false },
		{ Name = "Dark Shorts", Color = Color3.fromRGB(64, 52, 60), Shape = "Shorts" },
		{ Name = "Black Pants", Color = Color3.fromRGB(31, 31, 31), Shape = "Pants" },
		{ Name = "Blue Pants", Color = Color3.fromRGB(42, 69, 122), Shape = "Pants" },
		{ Name = "Grey Pants", Color = Color3.fromRGB(110, 110, 110), Shape = "Pants" },
	},
	Shoes = {
		{ Name = "None", Visible = false },
		{ Name = "Black Sneakers", Color = Color3.fromRGB(20, 20, 20), Shape = "Sneaker" },
		{ Name = "White Sneakers", Color = Color3.fromRGB(229, 229, 229), Shape = "Sneaker" },
		{ Name = "Red Sneakers", Color = Color3.fromRGB(210, 35, 35), Shape = "Sneaker" },
		{ Name = "Brown Boots", Color = Color3.fromRGB(90, 64, 36), Shape = "Boot" },
	},
}

local function clearWardrobeParts(character)
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Part") and child.Name:match("^Wardrobe_") then
			child:Destroy()
		end
	end
end

local function setPartColor(parts, color)
	for _, part in ipairs(parts) do
		if part and part:IsA("BasePart") then
			part.Color = color
		end
	end
end

local function getCharacterBodyParts(character)
	local parts = {}
	local partNames = {
		"Head",
		"Torso",
		"UpperTorso",
		"LowerTorso",
		"Left Arm",
		"Right Arm",
		"LeftUpperArm",
		"RightUpperArm",
		"LeftLowerArm",
		"RightLowerArm",
		"Left Leg",
		"Right Leg",
		"LeftUpperLeg",
		"RightUpperLeg",
		"LeftLowerLeg",
		"RightLowerLeg",
		"LeftHand",
		"RightHand",
		"LeftFoot",
		"RightFoot",
	}

	for _, name in ipairs(partNames) do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end

	return parts
end

local function makeAccessory(character, name, size, color, shape, cframeOffset)
	local part = Instance.new("Part")
	part.Name = "Wardrobe_" .. name
	part.Size = size
	part.Material = Enum.Material.SmoothPlastic
	part.Color = color
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Anchored = false
	part.Parent = character

	if shape == "Block" then
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Scale = Vector3.new(1, 1, 1)
		mesh.Parent = part
	end

	local head = character:FindFirstChild("Head") or character:FindFirstChild("Torso")
	if head then
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = head
		weld.Part1 = part
		weld.Parent = part
		part.CFrame = head.CFrame * (cframeOffset or CFrame.new())
	end

	return part
end

local function createHair(character, item)
	if not item or item.Name == "None" then
		return
	end

	local head = character:FindFirstChild("Head")
	if not head then
		return
	end

	local hair = Instance.new("Part")
	hair.Name = "Wardrobe_Hair"
	hair.Size = Vector3.new(1.5, 0.75, 1.2)
	hair.Color = item.Color or Color3.new(1, 1, 1)
	hair.Material = Enum.Material.SmoothPlastic
	hair.CanCollide = false
	hair.CanTouch = false
	hair.CanQuery = false
	hair.Anchored = false
	hair.Parent = character

	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Brick
	mesh.Scale = Vector3.new(1.1, 0.9, 1.1)
	mesh.Parent = hair

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = head
	weld.Part1 = hair
	weld.Parent = hair

	hair.CFrame = head.CFrame * CFrame.new(0, 0.45, 0.02)
end

local function createHat(character, item)
	if not item or item.Name == "None" then
		return
	end

	local head = character:FindFirstChild("Head")
	if not head then
		return
	end

	local hat = Instance.new("Part")
	hat.Name = "Wardrobe_Hat"
	hat.Size = Vector3.new(1.4, 0.5, 1.4)
	hat.Color = item.Color or Color3.new(1, 1, 1)
	hat.Material = Enum.Material.SmoothPlastic
	hat.CanCollide = false
	hat.CanTouch = false
	hat.CanQuery = false
	hat.Anchored = false
	hat.Parent = character

	local mesh = Instance.new("SpecialMesh")
	if item.Shape == "Cap" then
		mesh.MeshType = Enum.MeshType.Ball
		mesh.Scale = Vector3.new(1.1, 0.7, 1.1)
	elseif item.Shape == "Beanie" then
		mesh.MeshType = Enum.MeshType.Brick
		mesh.Scale = Vector3.new(1.2, 0.9, 1.2)
	else
		mesh.MeshType = Enum.MeshType.Brick
		mesh.Scale = Vector3.new(1.0, 0.8, 1.0)
	end
	mesh.Parent = hat

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = head
	weld.Part1 = hat
	weld.Parent = hat

	hat.CFrame = head.CFrame * CFrame.new(0, 0.7, 0)
end

local function createGlasses(character, item)
	if not item or item.Name == "None" then
		return
	end

	local head = character:FindFirstChild("Head")
	if not head then
		return
	end

	local left = Instance.new("Part")
	left.Name = "Wardrobe_GlassesLeft"
	left.Size = Vector3.new(0.55, 0.22, 0.12)
	left.Color = item.Color or Color3.fromRGB(20, 20, 20)
	left.Material = Enum.Material.SmoothPlastic
	left.CanCollide = false
	left.CanTouch = false
	left.CanQuery = false
	left.Anchored = false
	left.Parent = character

	local right = left:Clone()
	right.Name = "Wardrobe_GlassesRight"
	right.Parent = character

	local leftWeld = Instance.new("WeldConstraint")
	leftWeld.Part0 = head
	leftWeld.Part1 = left
	leftWeld.Parent = left

	local rightWeld = Instance.new("WeldConstraint")
	rightWeld.Part0 = head
	rightWeld.Part1 = right
	rightWeld.Parent = right

	left.CFrame = head.CFrame * CFrame.new(-0.25, 0.05, 0.55)
	right.CFrame = head.CFrame * CFrame.new(0.25, 0.05, 0.55)
end

local function createMask(character, item)
	if not item or item.Name == "None" then
		return
	end

	local head = character:FindFirstChild("Head")
	if not head then
		return
	end

	local mask = Instance.new("Part")
	mask.Name = "Wardrobe_Mask"
	mask.Size = Vector3.new(1.1, 0.55, 0.25)
	mask.Color = item.Color or Color3.fromRGB(20, 20, 20)
	mask.Material = Enum.Material.SmoothPlastic
	mask.CanCollide = false
	mask.CanTouch = false
	mask.CanQuery = false
	mask.Anchored = false
	mask.Parent = character

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = head
	weld.Part1 = mask
	weld.Parent = mask

	mask.CFrame = head.CFrame * CFrame.new(0, -0.15, 0.18)
end

local function createHoodie(character, item)
	if not item or item.Name == "None" then
		return
	end

	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not torso then
		return
	end

	local hoodie = Instance.new("Part")
	hoodie.Name = "Wardrobe_Hoodie"
	hoodie.Size = Vector3.new(2.2, 2.0, 1.1)
	hoodie.Color = item.Color or Color3.fromRGB(20, 20, 20)
	hoodie.Material = Enum.Material.SmoothPlastic
	hoodie.CanCollide = false
	hoodie.CanTouch = false
	hoodie.CanQuery = false
	hoodie.Anchored = false
	hoodie.Parent = character

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = torso
	weld.Part1 = hoodie
	weld.Parent = hoodie

	hoodie.CFrame = torso.CFrame * CFrame.new(0, 0.1, 0.05)
end

local function createPants(character, item)
	if not item or item.Name == "None" then
		return
	end

	local leftLeg = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftUpperLeg")
	local rightLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightUpperLeg")
	if leftLeg and rightLeg then
		leftLeg.Color = item.Color
		rightLeg.Color = item.Color
	end
end

local function createShoes(character, item)
	if not item or item.Name == "None" then
		return
	end

	local leftFoot = character:FindFirstChild("Left Foot") or character:FindFirstChild("LeftLowerLeg")
	local rightFoot = character:FindFirstChild("Right Foot") or character:FindFirstChild("RightLowerLeg")
	if leftFoot and rightFoot then
		leftFoot.Color = item.Color
		rightFoot.Color = item.Color
	end
end

local function applyCurrentOutfit()
	local character = getCharacter()
	clearWardrobeParts(character)

	local bodyItem = wardrobeCatalog.Body[1]
	for _, item in ipairs(wardrobeCatalog.Body) do
		if item.Name == wardrobeState.Current.Body then
			bodyItem = item
			break
		end
	end
	setPartColor(getCharacterBodyParts(character), bodyItem.Color)

	local hairItem = wardrobeCatalog.Hair[1]
	for _, item in ipairs(wardrobeCatalog.Hair) do
		if item.Name == wardrobeState.Current.Hair then
			hairItem = item
			break
		end
	end
	createHair(character, hairItem)

	local hatItem = wardrobeCatalog.Hat[1]
	for _, item in ipairs(wardrobeCatalog.Hat) do
		if item.Name == wardrobeState.Current.Hat then
			hatItem = item
			break
		end
	end
	createHat(character, hatItem)

	local glassesItem = wardrobeCatalog.Glasses[1]
	for _, item in ipairs(wardrobeCatalog.Glasses) do
		if item.Name == wardrobeState.Current.Glasses then
			glassesItem = item
			break
		end
	end
	createGlasses(character, glassesItem)

	local maskItem = wardrobeCatalog.Mask[1]
	for _, item in ipairs(wardrobeCatalog.Mask) do
		if item.Name == wardrobeState.Current.Mask then
			maskItem = item
			break
		end
	end
	createMask(character, maskItem)

	local hoodieItem = wardrobeCatalog.Hoodie[1]
	for _, item in ipairs(wardrobeCatalog.Hoodie) do
		if item.Name == wardrobeState.Current.Hoodie then
			hoodieItem = item
			break
		end
	end
	createHoodie(character, hoodieItem)

	local pantsItem = wardrobeCatalog.Pants[1]
	for _, item in ipairs(wardrobeCatalog.Pants) do
		if item.Name == wardrobeState.Current.Pants then
			pantsItem = item
			break
		end
	end
	createPants(character, pantsItem)

	local shoesItem = wardrobeCatalog.Shoes[1]
	for _, item in ipairs(wardrobeCatalog.Shoes) do
		if item.Name == wardrobeState.Current.Shoes then
			shoesItem = item
			break
		end
	end
	createShoes(character, shoesItem)
end

local function saveCurrentOutfit()
	local savedState = {}
	for key, value in pairs(wardrobeState.Current) do
		savedState[key] = value
	end
	wardrobeState.Saved[wardrobeState.Slot] = savedState
end

local function loadSavedOutfit(slot)
	wardrobeState.Slot = slot
	local data = wardrobeState.Saved[slot]
	if data then
		for key, value in pairs(data) do
			wardrobeState.Current[key] = value
		end
	end
	applyCurrentOutfit()
end

local function buildWardrobePanel()
	local oldGui = playerGui:FindFirstChild("WardrobeGui")
	if oldGui then
		oldGui:Destroy()
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "WardrobeGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = playerGui

	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(0, 240, 0, 46)
	topBar.Position = UDim2.new(0, 30, 0, 30)
	topBar.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
	topBar.BorderSizePixel = 0
	topBar.Parent = gui
	makeCorner(topBar, 8)
	makeStroke(topBar, Color3.fromRGB(255, 44, 56), 2)

	local logo = Instance.new("ImageLabel")
	logo.Size = UDim2.new(0, 38, 0, 38)
	logo.Position = UDim2.new(0, 12, 0, 4)
	logo.BackgroundTransparency = 1
	logo.Image = "rbxasset://textures/ui/RobloxGui/roblox.png"
	logo.ScaleType = Enum.ScaleType.Fit
	logo.Parent = topBar

	local menuButton = Instance.new("TextButton")
	menuButton.Size = UDim2.new(0, 40, 0, 32)
	menuButton.Position = UDim2.new(0, 12, 0.5, -16)
	menuButton.BackgroundColor3 = Color3.fromRGB(30, 30, 32)
	menuButton.BorderSizePixel = 0
	menuButton.Text = ""
	menuButton.Parent = topBar
	makeCorner(menuButton, 10)

	local panel = Instance.new("Frame")
	panel.Size = UDim2.new(0, 610, 0, 620)
	panel.Position = UDim2.new(1, -635, 0.5, -300)
	panel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	panel.BorderSizePixel = 0
	panel.Parent = gui
	makeCorner(panel, 18)
	makeStroke(panel, Color3.fromRGB(255, 26, 46), 2)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -60, 0, 44)
	title.Position = UDim2.new(0, 30, 0, 12)
	title.BackgroundTransparency = 1
	title.Text = "WARDROBE"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextScaled = true
	title.Parent = panel

	local accent = Instance.new("Frame")
	accent.Size = UDim2.new(0, 150, 0, 3)
	accent.Position = UDim2.new(0.5, -75, 0, 48)
	accent.BackgroundColor3 = Color3.fromRGB(255, 40, 56)
	accent.BorderSizePixel = 0
	accent.Parent = panel
	makeCorner(accent, 2)

	local outfitBar = Instance.new("Frame")
	outfitBar.Size = UDim2.new(1, -32, 0, 52)
	outfitBar.Position = UDim2.new(0, 16, 0, 72)
	outfitBar.BackgroundTransparency = 1
	outfitBar.Parent = panel

	local slotButtons = {}
	for idx, slotName in ipairs({"Outfit 1", "Outfit 2", "Outfit 3"}) do
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0, 160, 0, 32)
		b.Position = UDim2.new(0, 16 + (idx - 1) * 175, 0, 10)
		b.Text = slotName
		b.Font = Enum.Font.GothamBold
		b.TextSize = 13
		b.BackgroundColor3 = Color3.fromRGB(38, 40, 48)
		b.TextColor3 = Color3.fromRGB(200, 200, 200)
		b.BorderSizePixel = 0
		b.Parent = outfitBar
		makeCorner(b, 8)
		makeStroke(b, Color3.fromRGB(255, 35, 50), 1)

		b.MouseButton1Click:Connect(function()
			for _, btn in ipairs(slotButtons) do
				btn.BackgroundColor3 = Color3.fromRGB(38, 40, 48)
				btn.TextColor3 = Color3.fromRGB(200, 200, 200)
			end
			b.BackgroundColor3 = Color3.fromRGB(255, 35, 50)
			b.TextColor3 = Color3.fromRGB(255, 255, 255)
			loadSavedOutfit(slotName)
		end)

		table.insert(slotButtons, b)
	end

	local categoryFrame = Instance.new("Frame")
	categoryFrame.Size = UDim2.new(1, -32, 0, 220)
	categoryFrame.Position = UDim2.new(0, 16, 0, 128)
	categoryFrame.BackgroundTransparency = 1
	categoryFrame.Parent = panel

	local categoryButtons = {}
	local categoryOrder = {"Body", "Hair", "Hats", "Glasses", "Masks", "Hoodies", "Pants", "Shoes"}
	for idx, categoryName in ipairs(categoryOrder) do
		local col = idx % 3
		local row = math.floor((idx - 1) / 3)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0, 160, 0, 34)
		b.Position = UDim2.new(0, 8 + col * 170, 0, 10 + row * 42)
		b.Text = categoryName
		b.Font = Enum.Font.GothamBold
		b.TextSize = 12
		b.BackgroundColor3 = Color3.fromRGB(34, 36, 40)
		b.TextColor3 = Color3.fromRGB(255, 255, 255)
		b.BorderSizePixel = 0
		b.Parent = categoryFrame
		makeCorner(b, 8)

		b.MouseButton1Click:Connect(function()
			wardrobeState.Category = categoryName
			for _, btn in ipairs(categoryButtons) do
				btn.BackgroundColor3 = Color3.fromRGB(34, 36, 40)
			end
			b.BackgroundColor3 = Color3.fromRGB(255, 35, 50)
			populateCategoryGrid()
		end)

		table.insert(categoryButtons, b)
	end

	local gridHolder = Instance.new("ScrollingFrame")
	gridHolder.Size = UDim2.new(1, -32, 0, 300)
	gridHolder.Position = UDim2.new(0, 16, 0, 330)
	gridHolder.BackgroundColor3 = Color3.fromRGB(25, 26, 31)
	gridHolder.BorderSizePixel = 0
	gridHolder.ScrollBarThickness = 8
	gridHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
	gridHolder.Parent = panel
	makeCorner(gridHolder, 12)
	makeStroke(gridHolder, Color3.fromRGB(55, 55, 60), 1)

	local itemLayout = Instance.new("UIGridLayout")
	itemLayout.CellSize = UDim2.new(0, 150, 0, 70)
	itemLayout.CellPadding = UDim2.new(0, 10, 0, 10)
	itemLayout.FillDirectionMaxCells = 3
	itemLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	itemLayout.Parent = gridHolder

	local function populateCategoryGrid()
		for _, child in ipairs(gridHolder:GetChildren()) do
			if child:IsA("GuiObject") and child ~= itemLayout then
				child:Destroy()
			end
		end

		local categoryKey = wardrobeState.Category
		local catalog = wardrobeCatalog[categoryKey]
		if not catalog then
			return
		end

		for _, item in ipairs(catalog) do
			local itemButton = Instance.new("TextButton")
			itemButton.Size = UDim2.new(0, 150, 0, 70)
			itemButton.BackgroundColor3 = Color3.fromRGB(42, 45, 49)
			itemButton.BorderSizePixel = 0
			itemButton.Text = item.Name
			itemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			itemButton.Font = Enum.Font.GothamBold
			itemButton.TextSize = 11
			itemButton.Parent = gridHolder
			makeCorner(itemButton, 8)

			itemButton.MouseButton1Click:Connect(function()
				local keyMap = {
					["Body"] = "Body",
					["Hair"] = "Hair",
					["Hats"] = "Hat",
					["Glasses"] = "Glasses",
					["Masks"] = "Mask",
					["Hoodies"] = "Hoodie",
					["Pants"] = "Pants",
					["Shoes"] = "Shoes",
				}

				local stateKey = keyMap[categoryKey]
				if stateKey then
					wardrobeState.Current[stateKey] = item.Name
					applyCurrentOutfit()
				end
			end)
		end
	end

	local saveButton = Instance.new("TextButton")
	saveButton.Size = UDim2.new(0, 520, 0, 52)
	saveButton.Position = UDim2.new(0, 16, 1, -60)
	saveButton.BackgroundColor3 = Color3.fromRGB(255, 40, 52)
	saveButton.Text = "SAVE OUTFIT"
	saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	saveButton.Font = Enum.Font.GothamBold
	saveButton.TextSize = 16
	saveButton.Parent = panel
	makeCorner(saveButton, 10)
	saveButton.MouseButton1Click:Connect(function()
		saveCurrentOutfit()
		local tween = TweenService:Create(saveButton, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(220, 26, 40)})
		tween:Play()
		task.delay(0.15, function()
			TweenService:Create(saveButton, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(255, 40, 52)}):Play()
		end)
	end)

	local backButton = Instance.new("TextButton")
	backButton.Size = UDim2.new(0, 100, 0, 34)
	backButton.Position = UDim2.new(1, -120, 1, -60)
	backButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	backButton.Text = "BACK"
	backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	backButton.Font = Enum.Font.GothamBold
	backButton.TextSize = 14
	backButton.Parent = panel
	makeCorner(backButton, 10)
	backButton.MouseButton1Click:Connect(function()
		gui.Enabled = false
	end)

	local uiOpen = true
	buttonActivated = menuButton
	menuButton.MouseButton1Click:Connect(function()
		uiOpen = not uiOpen
		panel.Visible = uiOpen
		gui.Enabled = true
	end)

	categoryButtons[1].BackgroundColor3 = Color3.fromRGB(255, 35, 50)
	wardrobeState.Category = "Body"
	populateCategoryGrid()
	loadSavedOutfit("Outfit 1")
	return gui
end

local function onCharacterAdded(character)
	character:WaitForChild("Humanoid")
	applyCurrentOutfit()
end

player.CharacterAdded:Connect(onCharacterAdded)

buildWardrobePanel()
onCharacterAdded(getCharacter())

print("Wardrobe character system loaded")















































































































