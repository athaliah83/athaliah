--[[
    WORLD SHOP + LOADOUT DESIGN (VISUAL ONLY)
    Roblox server Script. Put this Script in ServerScriptService.

    This builds two decorative 3D showroom kiosks at the requested world location.
    It does NOT sell items, change coins, give tools, or save data.
    The front of the displays faces -Z.
]]

local Workspace = game:GetService("Workspace")

local ROOT_NAME = "DesignedShopLoadout"
local FLOOR_POSITION = Vector3.new(-11.11, 1.494, -22.26)
local old = Workspace:FindFirstChild(ROOT_NAME)
if old then old:Destroy() end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = Workspace

local COLORS = {
	black = Color3.fromRGB(21, 16, 24),
	dark = Color3.fromRGB(35, 25, 38),
	red = Color3.fromRGB(255, 35, 75),
	pink = Color3.fromRGB(255, 100, 133),
	white = Color3.fromRGB(247, 237, 244),
	glass = Color3.fromRGB(75, 43, 62),
	gold = Color3.fromRGB(255, 180, 62),
	green = Color3.fromRGB(156, 210, 63),
	grey = Color3.fromRGB(82, 73, 87),
}

local function part(parent, name, size, cf, color, material, transparency)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Transparency = transparency or 0
	p.Anchored = true
	p.CanCollide = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function sign(parent, host, title, subtitle)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "DisplaySign"
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 45
	gui.Parent = host

	local bg = Instance.new("Frame")
	bg.Size = UDim2.fromScale(1, 1)
	bg.BackgroundColor3 = COLORS.black
	bg.BorderSizePixel = 0
	bg.Parent = gui

	local topLine = Instance.new("Frame")
	topLine.Size = UDim2.new(1, 0, 0, 5)
	topLine.BackgroundColor3 = COLORS.red
	topLine.BorderSizePixel = 0
	topLine.Parent = bg

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -12, 0.68, 0)
	titleLabel.Position = UDim2.new(0, 6, 0.08, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = COLORS.red
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.TextScaled = true
	titleLabel.Parent = bg

	local subLabel = Instance.new("TextLabel")
	subLabel.Size = UDim2.new(1, -14, 0.2, 0)
	subLabel.Position = UDim2.new(0, 7, 0.73, 0)
	subLabel.BackgroundTransparency = 1
	subLabel.Text = subtitle
	subLabel.TextColor3 = COLORS.white
	subLabel.Font = Enum.Font.GothamBold
	subLabel.TextScaled = true
	subLabel.Parent = bg
end

local function displayText(parent, host, heading, detail)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "ShowroomInfo"
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 35
	gui.Parent = host

	local bg = Instance.new("Frame")
	bg.Size = UDim2.fromScale(1, 1)
	bg.BackgroundColor3 = COLORS.black
	bg.BorderSizePixel = 0
	bg.Parent = gui

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -12, 0.38, 0)
	title.Position = UDim2.new(0, 6, 0.1, 0)
	title.BackgroundTransparency = 1
	title.Text = heading
	title.TextColor3 = COLORS.red
	title.Font = Enum.Font.GothamBlack
	title.TextScaled = true
	title.Parent = bg

	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(1, -16, 0.42, 0)
	desc.Position = UDim2.new(0, 8, 0.52, 0)
	desc.BackgroundTransparency = 1
	desc.Text = detail
	desc.TextColor3 = COLORS.white
	desc.Font = Enum.Font.GothamBold
	desc.TextScaled = true
	desc.Parent = bg
end

local function makeWeapon(parent, at, tint, kind, scale)
	scale = scale or 1
	local model = Instance.new("Model")
	model.Name = "DecorativeWeapon_" .. kind
	model.Parent = parent
	local base = CFrame.new(at) * CFrame.Angles(0, math.rad(-90), 0)
	local function wp(name, size, offset, color, material, shape)
		local p = part(model, name, size * scale, base * CFrame.new(offset * scale), color, material or Enum.Material.Metal)
		if shape then
			local mesh = Instance.new("SpecialMesh")
			mesh.MeshType = shape
			mesh.Parent = p
		end
		return p
	end
	wp("Receiver", Vector3.new(0.42, 0.3, 1.15), Vector3.new(0, 0, 0), tint, Enum.Material.Metal)
	wp("Barrel", Vector3.new(0.14, 0.14, 0.78), Vector3.new(0, 0.02, -0.91), COLORS.grey, Enum.Material.Metal)
	wp("Muzzle", Vector3.new(0.22, 0.2, 0.18), Vector3.new(0, 0.02, -1.36), COLORS.black, Enum.Material.Metal)
	wp("Stock", Vector3.new(0.32, 0.25, 0.55), Vector3.new(0, 0.02, 0.82), COLORS.black, Enum.Material.Metal)
	wp("Grip", Vector3.new(0.2, 0.44, 0.27), Vector3.new(0, -0.31, 0.22), COLORS.black, Enum.Material.SmoothPlastic)
	wp("Sight", Vector3.new(0.15, 0.17, 0.2), Vector3.new(0, 0.22, -0.05), COLORS.red, Enum.Material.Neon)
	return model
end

local function makeBooth(name, title, subtitle, center, weaponSet)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = root
	local cf = CFrame.new(center)

	-- Raised display platform and red-lit front edge.
	part(model, "Platform", Vector3.new(9.4, 0.28, 6.8), cf * CFrame.new(0, 0.14, 0), COLORS.dark, Enum.Material.Slate)
	part(model, "PlatformNeonFront", Vector3.new(9.4, 0.08, 0.12), cf * CFrame.new(0, 0.31, -3.32), COLORS.red, Enum.Material.Neon)
	part(model, "PlatformNeonLeft", Vector3.new(0.1, 0.06, 6.4), cf * CFrame.new(-4.6, 0.31, 0), COLORS.pink, Enum.Material.Neon)
	part(model, "PlatformNeonRight", Vector3.new(0.1, 0.06, 6.4), cf * CFrame.new(4.6, 0.31, 0), COLORS.pink, Enum.Material.Neon)

	-- Rear wall, side pillars and the bold overhanging marquee.
	part(model, "BackWall", Vector3.new(8.7, 5.2, 0.34), cf * CFrame.new(0, 3.05, 2.85), COLORS.black, Enum.Material.SmoothPlastic)
	part(model, "LeftPillar", Vector3.new(0.38, 5.55, 0.48), cf * CFrame.new(-4.25, 3.0, -0.25), COLORS.redDark or COLORS.red, Enum.Material.SmoothPlastic)
	part(model, "RightPillar", Vector3.new(0.38, 5.55, 0.48), cf * CFrame.new(4.25, 3.0, -0.25), COLORS.redDark or COLORS.red, Enum.Material.SmoothPlastic)
	local marquee = part(model, "Marquee", Vector3.new(9.1, 0.9, 0.62), cf * CFrame.new(0, 5.92, 0.55), COLORS.black, Enum.Material.SmoothPlastic)
	sign(model, marquee, title, subtitle)
	part(model, "MarqueeUnderlight", Vector3.new(8.9, 0.09, 0.12), cf * CFrame.new(0, 5.43, 0.22), COLORS.red, Enum.Material.Neon)

	-- Weapon display board and decorative rails.
	local board = part(model, "WeaponBoard", Vector3.new(7.5, 2.45, 0.18), cf * CFrame.new(0, 3.62, 2.56), COLORS.panel or COLORS.dark, Enum.Material.SmoothPlastic)
	part(model, "BoardTopLine", Vector3.new(7.45, 0.07, 0.1), cf * CFrame.new(0, 4.86, 2.42), COLORS.red, Enum.Material.Neon)
	part(model, "BoardBottomLine", Vector3.new(7.45, 0.07, 0.1), cf * CFrame.new(0, 2.39, 2.42), COLORS.red, Enum.Material.Neon)
	displayText(model, board, "FEATURED", "DISPLAY  •  PREVIEW ONLY")

	-- Three glass display plinths/counters.
	for index, x in ipairs({-2.85, 0, 2.85}) do
		part(model, "CounterBase" .. index, Vector3.new(2.45, 0.75, 1.05), cf * CFrame.new(x, 0.82, -1.65), COLORS.grey, Enum.Material.SmoothPlastic)
		part(model, "CounterTop" .. index, Vector3.new(2.55, 0.12, 1.15), cf * CFrame.new(x, 1.25, -1.65), COLORS.redDark or COLORS.red, Enum.Material.SmoothPlastic)
		part(model, "GlassCase" .. index, Vector3.new(2.15, 0.88, 0.8), cf * CFrame.new(x, 1.76, -1.65), COLORS.glass, Enum.Material.Glass, 0.42)
	end

	-- A small shelf under the weapon wall.
	part(model, "WeaponShelf", Vector3.new(7.0, 0.18, 0.78), cf * CFrame.new(0, 2.15, 2.0), COLORS.grey, Enum.Material.SmoothPlastic)
	part(model, "ShelfNeon", Vector3.new(7.0, 0.06, 0.08), cf * CFrame.new(0, 2.05, 1.59), COLORS.red, Enum.Material.Neon)

	for index, spec in ipairs(weaponSet) do
		local x = -2.25 + (index - 1) * 2.25
		makeWeapon(model, (cf * CFrame.new(x, 3.68, 2.18)).Position, spec.color, spec.name, 0.88)
	end

	-- Side trim and stylized ceiling bars.
	for index = 1, 5 do
		local x = -3.2 + (index - 1) * 1.6
		part(model, "WallRib" .. index, Vector3.new(0.09, 2.1, 0.08), cf * CFrame.new(x, 3.25, 2.58), COLORS.red, Enum.Material.Neon)
	end
	part(model, "LeftTopBeam", Vector3.new(0.1, 0.08, 2.1), cf * CFrame.new(-3.8, 5.0, 1.0), COLORS.pink, Enum.Material.Neon)
	part(model, "RightTopBeam", Vector3.new(0.1, 0.08, 2.1), cf * CFrame.new(3.8, 5.0, 1.0), COLORS.pink, Enum.Material.Neon)

	-- Help the requested location be easy to identify in Studio.
	model:SetAttribute("DesignOnly", true)
	model:SetAttribute("CenterPosition", tostring(center))
	return model
end

local shopWeapons = {
	{name = "RookieRifle", color = COLORS.gold},
	{name = "ViperRifle", color = COLORS.green},
	{name = "StormSMG", color = COLORS.red},
}
local loadoutWeapons = {
	{name = "LoadoutRifle", color = COLORS.gold},
	{name = "LoadoutSMG", color = COLORS.green},
	{name = "LoadoutSidearm", color = COLORS.red},
}

-- Requested coordinate is the midpoint between the two kiosks, at their floor level.
makeBooth("ShopShowroom", "SHOP", "WEAPON SHOWROOM  •  PREVIEW ONLY", FLOOR_POSITION + Vector3.new(-5.1, 0, 0), shopWeapons)
makeBooth("LoadoutShowroom", "LOADOUT", "CHOOSE YOUR DISPLAY SETUP", FLOOR_POSITION + Vector3.new(5.1, 0, 0), loadoutWeapons)

print("Design-only Shop + Loadout showrooms created near " .. tostring(FLOOR_POSITION))

-- ==========================================================
-- SAFE DESERT + VOLCANO ADD-ON (does not destroy farm trees)
-- ==========================================================

local DESERT_FOLDER_NAME = "AFX_DesertVolcano"
local oldDesertFolder = Workspace:FindFirstChild(DESERT_FOLDER_NAME)
if oldDesertFolder then
	oldDesertFolder:Destroy()
end

local desertRoot = Instance.new("Folder")
desertRoot.Name = DESERT_FOLDER_NAME
desertRoot.Parent = Workspace

local DESERT_POSITION = Vector3.new(443.068, 1.236, 0.834)
local DESERT_SIZE = Vector3.new(253.528, 1, 101.283)
local VOLCANO_SIZE = DESERT_SIZE

local function makeGround(parent, name, size, position, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CanCollide = true
	part.Parent = parent
	return part
end

local function makeDecor(parent, name, size, position, color, material, shape, rotation)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material
	part.Shape = shape or Enum.PartType.Block
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	if rotation then
		part.CFrame = CFrame.new(position) * rotation
	end
	part.Parent = parent
	return part
end

local desertTopY = DESERT_POSITION.Y + DESERT_SIZE.Y / 2
local desertEndZ = DESERT_POSITION.Z + DESERT_SIZE.Z / 2
local volcanoPosition = Vector3.new(DESERT_POSITION.X, DESERT_POSITION.Y, desertEndZ + VOLCANO_SIZE.Z / 2)
local volcanoTopY = volcanoPosition.Y + VOLCANO_SIZE.Y / 2

makeGround(desertRoot, "DesertGround", DESERT_SIZE, DESERT_POSITION, Color3.fromRGB(221, 190, 120), Enum.Material.Sand)

local cactusOffsets = {
	{-105, -34},
	{-72, 12},
	{-36, 36},
	{28, -26},
	{68, 18},
	{104, 35},
	{-5, -8},
	{92, -30},
}

for index, offset in ipairs(cactusOffsets) do
	local x = DESERT_POSITION.X + offset[1]
	local z = DESERT_POSITION.Z + offset[2]
	local cactusColor = Color3.fromRGB(55, 145, 65)

	makeDecor(desertRoot, "CactusTrunk_" .. index, Vector3.new(1.5, 5, 1.5), Vector3.new(x, desertTopY + 2.5, z), cactusColor, Enum.Material.Grass)
	makeDecor(desertRoot, "CactusArm_" .. index, Vector3.new(1.2, 2.4, 1.2), Vector3.new(x + 1.1, desertTopY + 3.2, z), cactusColor, Enum.Material.Grass)
	makeDecor(desertRoot, "CactusArmTop_" .. index, Vector3.new(2.2, 1.2, 1.2), Vector3.new(x + 0.6, desertTopY + 4.3, z), cactusColor, Enum.Material.Grass)
	makeDecor(desertRoot, "DesertRock_" .. index, Vector3.new(3, 1.5, 2.5), Vector3.new(x - 4, desertTopY + 0.75, z + 4), Color3.fromRGB(145, 119, 87), Enum.Material.Slate)
end

makeGround(desertRoot, "VolcanoGround", VOLCANO_SIZE, volcanoPosition, Color3.fromRGB(75, 65, 60), Enum.Material.Basalt)

local verticalCylinder = CFrame.Angles(0, 0, math.rad(90))
local volcanoCenterX = volcanoPosition.X
local volcanoCenterZ = volcanoPosition.Z

makeDecor(desertRoot, "VolcanoBase", Vector3.new(12, 72, 72), Vector3.new(volcanoCenterX, volcanoTopY + 6, volcanoCenterZ), Color3.fromRGB(75, 48, 42), Enum.Material.Rock, Enum.PartType.Cylinder, verticalCylinder)
makeDecor(desertRoot, "VolcanoMiddle", Vector3.new(12, 54, 54), Vector3.new(volcanoCenterX, volcanoTopY + 18, volcanoCenterZ), Color3.fromRGB(92, 54, 43), Enum.Material.Rock, Enum.PartType.Cylinder, verticalCylinder)
makeDecor(desertRoot, "VolcanoTop", Vector3.new(6, 36, 36), Vector3.new(volcanoCenterX, volcanoTopY + 27, volcanoCenterZ), Color3.fromRGB(105, 57, 43), Enum.Material.Rock, Enum.PartType.Cylinder, verticalCylinder)
makeDecor(desertRoot, "VolcanoCraterRim", Vector3.new(22, 2, 22), Vector3.new(volcanoCenterX, volcanoTopY + 31, volcanoCenterZ), Color3.fromRGB(55, 45, 42), Enum.Material.Slate)

local lava = makeDecor(desertRoot, "VolcanoLava", Vector3.new(13, 0.5, 13), Vector3.new(volcanoCenterX, volcanoTopY + 32.25, volcanoCenterZ), Color3.fromRGB(255, 75, 10), Enum.Material.Neon)
lava.Transparency = 0.1

print("Safe desert + volcano add-on created without touching the farm folder.")
