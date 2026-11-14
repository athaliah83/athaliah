--// AFX EGG + CHICKEN + GARDEN + SELL SYSTEM
--// LOCATION: ServerScriptService
--// BLOCKY LAYERED EGGS + BROWN NEST
--// GROUND FIX + SITTING GUARDIAN
--// SELL: COMMON 25 CASH / RARE 100 CASH
--// KEEP EXISTING GARDEN / HATCH / INCOME SYSTEM

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- SETTINGS
local CHICKEN_POSITION = Vector3.new(663.7, 5.126, -34.78)
local CHICKEN_ROTATION = math.rad(-90)

local SAFE_ZONE_POSITION = Vector3.new(773.603, 1.167, -0.561)
local SAFE_ZONE_SIZE = Vector3.new(142.316, 1, 274.826)

local GUARDIAN_SPEED = 10
local GUARDIAN_RETURN_SPEED = 7
local GUARDIAN_EGG_SPEED = 7
local KILL_DISTANCE = 4.2

local GARDEN_HALF_X = 10
local GARDEN_HALF_Z = 13

local INCOME_INTERVAL = 2
local COMMON_INCOME = 200
local RARE_INCOME = 0
local MYTHIC_INCOME = 0

local PET_WALK_SPEED = 0.8
local PECK_INTERVAL_MIN = 9
local PECK_INTERVAL_MAX = 14
local PECK_DURATION = 1.1

-- SELL SETTINGS
local SELL_STALL_POSITION = Vector3.new(711.812, 5.492, 42.808)
local SELL_MAX_DISTANCE = 30

local SELL_PRICES = {
	Common = 25,
	Rare = 100,
}

local EGG_INFO = {
	Common = {
		HatchTime = 15,
		Color = Color3.fromRGB(245, 238, 215),
		Income = COMMON_INCOME,
	},
	Rare = {
		HatchTime = 30,
		Color = Color3.fromRGB(55, 160, 255),
		Income = RARE_INCOME,
	},
	Mythic = {
		HatchTime = 45,
		Color = Color3.fromRGB(175, 65, 255),
		Income = MYTHIC_INCOME,
	},
}

local EGG_SPAWNS = {
	{Type = "Common", Position = CHICKEN_POSITION + Vector3.new(5, 0, -7)},
	{Type = "Rare", Position = CHICKEN_POSITION + Vector3.new(-7, 0, -5)},
	{Type = "Mythic", Position = CHICKEN_POSITION + Vector3.new(7, 0, 7)},
}

-- CLEANUP
for _, name in ipairs({
	"AFX_FluffyChicken",
	"AFX_GuardianEggs",
	"AFX_GardenEggsPets",
	"AFX_EggPlacementPads",
	}) do
	local old = Workspace:FindFirstChild(name)
	if old then
		old:Destroy()
	end
end

local oldRemote = ReplicatedStorage:FindFirstChild("AFX_EggRemotes")
if oldRemote then
	oldRemote:Destroy()
end

local remotes = Instance.new("Folder")
remotes.Name = "AFX_EggRemotes"
remotes.Parent = ReplicatedStorage

local eggAction = Instance.new("RemoteEvent")
eggAction.Name = "AFX_EggAction"
eggAction.Parent = remotes

local eggState = Instance.new("RemoteEvent")
eggState.Name = "AFX_EggState"
eggState.Parent = remotes

-- SELL REMOTES
local getSellPets = Instance.new("RemoteFunction")
getSellPets.Name = "AFX_GetSellPets"
getSellPets.Parent = remotes

local sellPetEvent = Instance.new("RemoteEvent")
sellPetEvent.Name = "AFX_SellPet"
sellPetEvent.Parent = remotes

local guardianFolder = Instance.new("Folder")
guardianFolder.Name = "AFX_FluffyChicken"
guardianFolder.Parent = Workspace

local runwayEggFolder = Instance.new("Folder")
runwayEggFolder.Name = "AFX_GuardianEggs"
runwayEggFolder.Parent = Workspace

local petFolder = Instance.new("Folder")
petFolder.Name = "AFX_GardenEggsPets"
petFolder.Parent = Workspace

local padFolder = Instance.new("Folder")
padFolder.Name = "AFX_EggPlacementPads"
padFolder.Parent = Workspace

-- HELPERS
local function makePart(parent, name, size, color, cf, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.CFrame = cf
	p.Anchored = true
	p.CanCollide = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then
		p.Shape = shape
	end
	p.Parent = parent
	return p
end

local function addNameTag(part, title, color)
	local gui = Instance.new("BillboardGui")
	gui.Name = "AFX_NameTag"
	gui.Size = UDim2.fromOffset(105, 22)
	gui.StudsOffset = Vector3.new(0, 1.65, 0)
	gui.AlwaysOnTop = false
	gui.MaxDistance = 22
	gui.LightInfluence = 0
	gui.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = title
	label.TextColor3 = color
	label.TextStrokeTransparency = 0.4
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = gui

	return label
end

local function getRoot(player)
	local char = player.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

-- GROUND DETECTION
local function getGroundPosition(position)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude

	local excluded = {
		guardianFolder,
		runwayEggFolder,
		petFolder,
		padFolder,
	}

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			table.insert(excluded, player.Character)
		end
	end

	params.FilterDescendantsInstances = excluded
	params.IgnoreWater = false

	local result = Workspace:Raycast(
		Vector3.new(position.X, position.Y + 150, position.Z),
		Vector3.new(0, -500, 0),
		params
	)

	if result then
		return result.Position
	end

	return Vector3.new(position.X, position.Y, position.Z)
end

local function snapGuardianToGround(position)
	local ground = getGroundPosition(position)
	return Vector3.new(position.X, ground.Y, position.Z)
end

local function insideSafeZone(position)
	local p = position - SAFE_ZONE_POSITION
	return math.abs(p.X) <= SAFE_ZONE_SIZE.X / 2
		and math.abs(p.Z) <= SAFE_ZONE_SIZE.Z / 2
end

local function getGarden(player)
	local number = player:GetAttribute("GardenNumber")
	if not number then
		return nil
	end

	local folder = Workspace:FindFirstChild("AFX_Gardens")
	if not folder then
		return nil
	end

	local garden = folder:FindFirstChild("Garden" .. tostring(number))
	if not garden then
		return nil
	end

	local floor = garden:FindFirstChild("GardenFloor")
	if not floor or not floor:IsA("BasePart") then
		return nil
	end

	return garden, floor
end

local function getCash(player)
	local stats = player:FindFirstChild("leaderstats")
	if not stats then
		stats = Instance.new("Folder")
		stats.Name = "leaderstats"
		stats.Parent = player
	end

	local cash = stats:FindFirstChild("Cash")
	if cash and cash:IsA("IntValue") then
		return cash
	end

	local money = stats:FindFirstChild("Money")
	if money and money:IsA("IntValue") then
		return money
	end

	cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 0
	cash.Parent = stats
	return cash
end

local function gardenPosition(floor, x, z, height)
	return floor.CFrame:PointToWorldSpace(
		Vector3.new(x, floor.Size.Y / 2 + (height or 0), z)
	)
end

-- CHICKEN MODEL
local function createChicken(parent, name, color, scale, isRare)
	scale = scale or 1

	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent

	local wingColor = color
	local beakColor = Color3.fromRGB(255, 145, 25)
	local combColor = Color3.fromRGB(220, 45, 45)

	if isRare then
		wingColor = Color3.fromRGB(165, 220, 255)
		beakColor = Color3.fromRGB(255, 205, 55)
		combColor = Color3.fromRGB(255, 205, 55)
	end

	local function part(n, size, offset, partColor, shape)
		return makePart(
			model,
			n,
			size * scale,
			partColor,
			CFrame.new(offset * scale),
			shape
		)
	end

	local data = {
		Model = model,
		Scale = scale,
	}

	data.Body = part("Body", Vector3.new(2, 1.5, 2.5), Vector3.new(0, 1.1, 0), color, Enum.PartType.Ball)
	data.Head = part("Head", Vector3.new(1.15, 1.1, 1.1), Vector3.new(0, 2.15, -0.8), color, Enum.PartType.Ball)
	data.Beak = part("Beak", Vector3.new(0.5, 0.3, 0.55), Vector3.new(0, 1.95, -1.42), beakColor, Enum.PartType.Wedge)
	data.Comb = part("Comb", Vector3.new(0.35, 0.55, 0.3), Vector3.new(0, 2.78, -0.78), combColor, Enum.PartType.Ball)
	data.EyeL = part("EyeL", Vector3.new(0.13, 0.13, 0.13), Vector3.new(-0.38, 2.28, -1.25), Color3.new(0, 0, 0), Enum.PartType.Ball)
	data.EyeR = part("EyeR", Vector3.new(0.13, 0.13, 0.13), Vector3.new(0.38, 2.28, -1.25), Color3.new(0, 0, 0), Enum.PartType.Ball)
	data.WingL = part("WingL", Vector3.new(0.35, 0.8, 1.25), Vector3.new(-1, 1.2, 0.05), wingColor, Enum.PartType.Ball)
	data.WingR = part("WingR", Vector3.new(0.35, 0.8, 1.25), Vector3.new(1, 1.2, 0.05), wingColor, Enum.PartType.Ball)
	data.LegL = part("LegL", Vector3.new(0.18, 0.8, 0.18), Vector3.new(-0.4, 0.35, -0.15), Color3.fromRGB(255, 145, 25))
	data.LegR = part("LegR", Vector3.new(0.18, 0.8, 0.18), Vector3.new(0.4, 0.35, -0.15), Color3.fromRGB(255, 145, 25))
	data.FootL = part("FootL", Vector3.new(0.55, 0.14, 0.5), Vector3.new(-0.4, 0.04, -0.3), Color3.fromRGB(255, 145, 25))
	data.FootR = part("FootR", Vector3.new(0.55, 0.14, 0.5), Vector3.new(0.4, 0.04, -0.3), Color3.fromRGB(255, 145, 25))

	model.PrimaryPart = data.Body
	return data
end

-- CHICKEN ANIMATION
local function poseChicken(chicken, rootCF, walk, peck, sitting)
	local s = chicken.Scale
	local swing = walk * 0.18
	local bob = math.abs(walk) * 0.025
	peck = peck or 0

	local function set(part, x, y, z, angle)
		part.CFrame = rootCF
			* CFrame.new(x * s, y * s, z * s)
			* (angle or CFrame.new())
	end

	if sitting then
		local breathe = math.sin(os.clock() * 2) * 0.025

		set(chicken.Body, 0, 0.88 + breathe, 0)
		set(chicken.Head, 0, 1.82 + breathe - peck * 0.25, -0.8 + peck * 0.2)
		set(chicken.Beak, 0, 1.62 + breathe - peck * 0.4, -1.42 + peck * 0.4)
		set(chicken.Comb, 0, 2.45 + breathe - peck * 0.25, -0.78 + peck * 0.2)
		set(chicken.EyeL, -0.38, 1.95 + breathe - peck * 0.25, -1.25 + peck * 0.2)
		set(chicken.EyeR, 0.38, 1.95 + breathe - peck * 0.25, -1.25 + peck * 0.2)
		set(chicken.WingL, -0.95, 0.95 + breathe, 0.05)
		set(chicken.WingR, 0.95, 0.95 + breathe, 0.05)
		set(chicken.LegL, -0.4, 0.22, -0.15, CFrame.Angles(math.rad(65), 0, 0))
		set(chicken.LegR, 0.4, 0.22, -0.15, CFrame.Angles(math.rad(65), 0, 0))
		set(chicken.FootL, -0.4, 0.04, -0.3)
		set(chicken.FootR, 0.4, 0.04, -0.3)
		return
	end

	set(chicken.Body, 0, 1.1 + bob, 0)
	set(chicken.Head, 0, 2.15 + bob - peck * 0.35, -0.8 + peck * 0.25)
	set(chicken.Beak, 0, 1.95 + bob - peck * 0.65, -1.42 + peck * 0.55)
	set(chicken.Comb, 0, 2.78 + bob - peck * 0.35, -0.78 + peck * 0.25)
	set(chicken.EyeL, -0.38, 2.28 + bob - peck * 0.35, -1.25 + peck * 0.25)
	set(chicken.EyeR, 0.38, 2.28 + bob - peck * 0.35, -1.25 + peck * 0.25)
	set(chicken.WingL, -1, 1.2 + bob, 0, CFrame.Angles(0, 0, swing * 0.12))
	set(chicken.WingR, 1, 1.2 + bob, 0, CFrame.Angles(0, 0, -swing * 0.12))
	set(chicken.LegL, -0.4, 0.35, -0.15, CFrame.Angles(swing, 0, 0))
	set(chicken.LegR, 0.4, 0.35, -0.15, CFrame.Angles(-swing, 0, 0))
	set(chicken.FootL, -0.4, 0.04, -0.3, CFrame.Angles(swing, 0, 0))
	set(chicken.FootR, 0.4, 0.04, -0.3, CFrame.Angles(-swing, 0, 0))
end

-- GUARDIAN
local guardian = createChicken(
	guardianFolder,
	"GuardianChicken",
	Color3.fromRGB(245, 242, 230),
	1.5
)

addNameTag(guardian.Body, "EGG GUARDIAN", Color3.fromRGB(255, 220, 80))

local guardianHomePosition = snapGuardianToGround(CHICKEN_POSITION)
local guardianPosition = guardianHomePosition
local guardianWalkClock = 0

-- EGG STATE
local eggRecords = {}
local carriedBy
local carriedEgg
local carryWeld
local runningPlayers = {}
local securedPlayers = {}
local droppedEgg

local function setEggAnchored(record, anchored)
	for _, obj in ipairs(record.Model:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Anchored = anchored
			obj.CanCollide = false
		end
	end
end

local function updatePlayerEggState()
	for _, player in ipairs(Players:GetPlayers()) do
		eggState:FireClient(
			player,
			carriedBy == player,
			carriedBy == player and runningPlayers[player] == true,
			securedPlayers[player] == true
		)
	end
end

local function restoreEgg(record)
	if not record or not record.Model or not record.Model.Parent then
		return
	end

	if carryWeld then
		carryWeld:Destroy()
		carryWeld = nil
	end

	setEggAnchored(record, true)
	record.Model.Parent = runwayEggFolder
	record.Model:PivotTo(record.OriginalCFrame)

	record.Available = true
	record.Prompt.Enabled = true
	record.Returning = false

	if droppedEgg == record then
		droppedEgg = nil
	end

	if carriedEgg == record then
		carriedBy = nil
		carriedEgg = nil
	end

	if record.Owner then
		securedPlayers[record.Owner] = nil
		runningPlayers[record.Owner] = nil
	end

	updatePlayerEggState()
end

local function attachEgg(player, record)
	local character = player.Character
	if not character then
		return
	end

	local hand = character:FindFirstChild("RightHand")
		or character:FindFirstChild("Right Arm")

	local root = getRoot(player)
	local attachPart = hand or root
	if not attachPart then
		return
	end

	setEggAnchored(record, false)
	record.Model:PivotTo(attachPart.CFrame * CFrame.new(0, -0.2, -1.2))

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = attachPart
	weld.Part1 = record.Root
	weld.Parent = record.Root

	carryWeld = weld
	carriedBy = player
	carriedEgg = record

	record.Available = false
	record.Prompt.Enabled = false
	record.Owner = player

	securedPlayers[player] = nil
	runningPlayers[player] = false

	eggState:FireClient(player, true, false, false)
end

-- DROP: GUARDIAN WILL RETRIEVE THE EGG
local function dropEgg(player)
	if carriedBy ~= player or not carriedEgg then
		return
	end

	if securedPlayers[player] then
		return
	end

	local record = carriedEgg
	local root = getRoot(player)

	if carryWeld then
		carryWeld:Destroy()
		carryWeld = nil
	end

	if root then
		local dropXZ = root.Position + root.CFrame.LookVector * -4
		local ground = getGroundPosition(dropXZ)
		record.Model:PivotTo(CFrame.new(ground + Vector3.new(0, 1.05, 0)))
	end

	setEggAnchored(record, true)
	record.Model.Parent = runwayEggFolder

	record.Available = false
	record.Prompt.Enabled = false
	record.Returning = true
	record.Owner = nil

	carriedBy = nil
	carriedEgg = nil
	runningPlayers[player] = nil
	securedPlayers[player] = nil

	droppedEgg = record

	eggState:FireClient(player, false, false, false)
end

-- GARDEN PETS
local petsByPlayer = {}
local gardenPads = {}
local petCounter = 0

local function getPetSlot(player)
	petsByPlayer[player] = petsByPlayer[player] or {}

	local count = #petsByPlayer[player]
	local col = count % 4
	local row = math.floor(count / 4)

	return -7.5 + col * 5, -8 + row * 5
end

local function chooseGardenPosition(floor, homeX, homeZ)
	local x = math.clamp(homeX + math.random(-2, 2), -GARDEN_HALF_X, GARDEN_HALF_X)
	local z = math.clamp(homeZ + math.random(-2, 2), -GARDEN_HALF_Z, GARDEN_HALF_Z)
	return gardenPosition(floor, x, z, 0.1)
end

local function createPlacementPad(player, garden, floor)
	if gardenPads[player] and gardenPads[player].Parent then
		return
	end

	local pad = makePart(
		padFolder,
		"PlaceEggPad_" .. player.UserId,
		Vector3.new(4, 0.25, 4),
		Color3.fromRGB(45, 180, 255),
		floor.CFrame * CFrame.new(0, floor.Size.Y / 2 + 0.15, 0)
	)

	pad.Transparency = 0.25

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "PLACE EGG"
	prompt.ObjectText = "YOUR GARDEN"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = pad

	gardenPads[player] = pad

	prompt.Triggered:Connect(function(triggerPlayer)
		if triggerPlayer ~= player then
			return
		end

		if carriedBy ~= player or not carriedEgg then
			return
		end

		local currentGarden, currentFloor = getGarden(player)
		if currentGarden ~= garden or not currentFloor then
			return
		end

		local record = carriedEgg
		local info = EGG_INFO[record.Type]
		local slotX, slotZ = getPetSlot(player)
		local eggPosition = gardenPosition(currentFloor, slotX, slotZ, 1)

		if carryWeld then
			carryWeld:Destroy()
			carryWeld = nil
		end

		record.Model.Parent = petFolder
		setEggAnchored(record, true)
		record.Model:PivotTo(CFrame.new(eggPosition))
		record.Prompt.Enabled = false

		carriedBy = nil
		carriedEgg = nil
		runningPlayers[player] = nil
		securedPlayers[player] = nil

		eggState:FireClient(player, false, false, false)

		local tag = record.Root:FindFirstChild("AFX_NameTag")
		local label = tag and tag:FindFirstChildOfClass("TextLabel")

		task.spawn(function()
			for remaining = info.HatchTime, 1, -1 do
				if not record.Model.Parent then
					return
				end

				if label then
					label.Text = record.Type:upper()
						.. " HATCHING: " .. remaining .. "s"
				end

				task.wait(1)
			end

			if not record.Model.Parent then
				return
			end

			record.Model:Destroy()

			petCounter += 1

			local isRare = record.Type == "Rare"
			local petName = isRare and "RARE BLUE CHICKEN"
				or record.Type:upper() .. " CHICKEN"

			local petData = createChicken(
				petFolder,
				petName .. "_" .. petCounter,
				info.Color,
				0.8,
				isRare
			)

			addNameTag(petData.Body, petName, info.Color)

			local initialPosition = gardenPosition(
				currentFloor,
				slotX,
				slotZ,
				0.1
			)

			poseChicken(petData, CFrame.new(initialPosition), 0, 0)

			local pet = {
				Data = petData,
				Owner = player,
				HomeX = slotX,
				HomeZ = slotZ,
				Target = nil,
				NextMove = 0,
				NextPeck = os.clock() + math.random(
					PECK_INTERVAL_MIN,
					PECK_INTERVAL_MAX
				),
				PeckStart = 0,
				Income = info.Income,
				Alive = true,
			}

			table.insert(petsByPlayer[player], pet)

			task.spawn(function()
				while pet.Alive and pet.Data.Model.Parent and player.Parent do
					task.wait(INCOME_INTERVAL)

					if pet.Alive and pet.Data.Model.Parent and pet.Income > 0 then
						getCash(player).Value += pet.Income
					end
				end
			end)
		end)
	end)
end

-- BLOCKY LAYERED EGGS + BROWN NEST
local function weldEggPart(root, part)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = part
	weld.Parent = root
end

local EGG_STYLE = {
	Common = {
		Main = Color3.fromRGB(235, 211, 169),
		Light = Color3.fromRGB(255, 239, 205),
		Stripe = Color3.fromRGB(183, 137, 91),
	},
	Rare = {
		Main = Color3.fromRGB(92, 174, 240),
		Light = Color3.fromRGB(183, 225, 255),
		Stripe = Color3.fromRGB(48, 111, 190),
	},
	Mythic = {
		Main = Color3.fromRGB(163, 91, 238),
		Light = Color3.fromRGB(218, 173, 255),
		Stripe = Color3.fromRGB(104, 48, 166),
	},
}

local function createLayeredEgg(spawnInfo)
	local info = EGG_INFO[spawnInfo.Type]
	local colors = EGG_STYLE[spawnInfo.Type] or EGG_STYLE.Common

	local model = Instance.new("Model")
	model.Name = spawnInfo.Type .. "Egg"
	model.Parent = runwayEggFolder

	local ground = getGroundPosition(spawnInfo.Position)
	local rootCF = CFrame.new(ground + Vector3.new(0, 1.05, 0))

	local root = makePart(
		model,
		"EggRoot",
		Vector3.new(0.2, 0.2, 0.2),
		info.Color,
		rootCF
	)

	root.Transparency = 1
	root.CanQuery = false
	root.CanTouch = false
	model.PrimaryPart = root

	-- LAYERED EGG BODY
	local layers = {
		{Vector3.new(1.15, 0.20, 1.15), -0.12, colors.Stripe},
		{Vector3.new(1.48, 0.22, 1.48), 0.10, colors.Main},
		{Vector3.new(1.76, 0.24, 1.76), 0.34, colors.Light},
		{Vector3.new(1.92, 0.25, 1.92), 0.59, colors.Main},
		{Vector3.new(1.76, 0.24, 1.76), 0.84, colors.Stripe},
		{Vector3.new(1.48, 0.23, 1.48), 1.075, colors.Light},
		{Vector3.new(1.12, 0.22, 1.12), 1.30, colors.Main},
		{Vector3.new(0.70, 0.18, 0.70), 1.50, colors.Light},
	}

	for i, layer in ipairs(layers) do
		local part = makePart(
			model,
			"EggLayer" .. i,
			layer[1],
			layer[3],
			rootCF * CFrame.new(0, layer[2], 0)
		)

		weldEggPart(root, part)
	end

	-- BROWN TWIG NEST
	local nestColor = Color3.fromRGB(111, 68, 39)
	local nestLight = Color3.fromRGB(151, 101, 61)

	local twigs = {
		{Vector3.new(2.65, 0.16, 0.28), Vector3.new(0, -0.96, 0.98), nestColor, 0},
		{Vector3.new(2.65, 0.16, 0.28), Vector3.new(0, -0.96, -0.98), nestLight, 0},
		{Vector3.new(0.28, 0.16, 2.15), Vector3.new(1.18, -0.96, 0), nestLight, 0},
		{Vector3.new(0.28, 0.16, 2.15), Vector3.new(-1.18, -0.96, 0), nestColor, 0},
		{Vector3.new(2.45, 0.16, 0.25), Vector3.new(0.10, -0.77, 1.10), nestLight, math.rad(8)},
		{Vector3.new(2.45, 0.16, 0.25), Vector3.new(-0.10, -0.77, -1.10), nestColor, math.rad(-8)},
		{Vector3.new(0.25, 0.16, 2.25), Vector3.new(1.30, -0.77, 0.10), nestColor, math.rad(7)},
		{Vector3.new(0.25, 0.16, 2.25), Vector3.new(-1.30, -0.77, -0.10), nestLight, math.rad(-7)},
		{Vector3.new(2.20, 0.13, 0.20), Vector3.new(-0.20, -0.58, 1.15), nestColor, math.rad(-10)},
		{Vector3.new(2.20, 0.13, 0.20), Vector3.new(0.20, -0.58, -1.15), nestLight, math.rad(10)},
	}

	for i, twig in ipairs(twigs) do
		local part = makePart(
			model,
			"NestTwig" .. i,
			twig[1],
			twig[3],
			rootCF * CFrame.new(twig[2]) * CFrame.Angles(0, twig[4], 0)
		)

		weldEggPart(root, part)
	end

	-- PICKUP PROMPT
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "TakeEggPrompt"
	prompt.ActionText = "KUNIN"
	prompt.ObjectText = spawnInfo.Type:upper() .. " EGG"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.HoldDuration = 0.4
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Enabled = true
	prompt.Parent = root

	addNameTag(root, spawnInfo.Type:upper() .. " EGG", info.Color)

	local record = {
		Model = model,
		Root = root,
		Prompt = prompt,
		Type = spawnInfo.Type,
		OriginalCFrame = model:GetPivot(),
		Available = true,
		Returning = false,
	}

	table.insert(eggRecords, record)

	prompt.Triggered:Connect(function(player)
		if carriedBy or droppedEgg or not record.Available then
			return
		end

		if not getRoot(player) then
			return
		end

		attachEgg(player, record)
	end)
end

-- SPAWN EGGS
for _, spawnInfo in ipairs(EGG_SPAWNS) do
	createLayeredEgg(spawnInfo)
end

-- PLAYER GARDEN SETUP
local function setupPlayer(player)
	task.spawn(function()
		for _ = 1, 60 do
			if not player.Parent then
				return
			end

			local garden, floor = getGarden(player)
			if garden and floor then
				createPlacementPad(player, garden, floor)
				return
			end

			task.wait(1)
		end
	end)
end

Players.PlayerAdded:Connect(setupPlayer)

for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end

-- RUN AND DROP REQUESTS
eggAction.OnServerEvent:Connect(function(player, action, enabled)
	if carriedBy ~= player then
		return
	end

	if securedPlayers[player] then
		return
	end

	if action == "RUN" then
		runningPlayers[player] = enabled == true
		eggState:FireClient(player, true, runningPlayers[player], false)

	elseif action == "DROP" then
		dropEgg(player)
	end
end)

-- MOVEMENT
local guardianHitTimes = {}

RunService.Heartbeat:Connect(function(dt)
	local now = os.clock()

	-- SAFE ZONE DETECTION
	if carriedBy and carriedBy.Parent and not securedPlayers[carriedBy] then
		local root = getRoot(carriedBy)

		if root and insideSafeZone(root.Position) then
			local player = carriedBy

			securedPlayers[player] = true
			runningPlayers[player] = false

			eggState:FireClient(player, true, false, true)
		end
	end

	local targetRoot
	local targetPlayer

	-- GUARDIAN CHASES ONLY UNSAFE CARRIERS
	if carriedBy and carriedBy.Parent and not securedPlayers[carriedBy] then
		local root = getRoot(carriedBy)

		if root then
			targetRoot = root
			targetPlayer = carriedBy
		end
	end

	local guardianMoving = false

	-- GUARDIAN RETRIEVES DROPPED EGG OR CHASES PLAYER
	if droppedEgg and droppedEgg.Returning and droppedEgg.Model.Parent then
		local eggPosition = droppedEgg.Root.Position
		local flatTarget = Vector3.new(
			eggPosition.X,
			guardianPosition.Y,
			eggPosition.Z
		)

		local direction = flatTarget - guardianPosition
		local distance = direction.Magnitude

		if distance > 2.5 then
			guardianPosition += direction.Unit
				* math.min(distance, GUARDIAN_EGG_SPEED * dt)

			guardianPosition = snapGuardianToGround(guardianPosition)
			guardianMoving = true
		else
			local record = droppedEgg
			restoreEgg(record)
		end

	elseif targetRoot then
		local flatTarget = Vector3.new(
			targetRoot.Position.X,
			guardianPosition.Y,
			targetRoot.Position.Z
		)

		local direction = flatTarget - guardianPosition
		local distance = direction.Magnitude

		if distance > 0.1 then
			guardianPosition += direction.Unit
				* math.min(distance, GUARDIAN_SPEED * dt)

			guardianPosition = snapGuardianToGround(guardianPosition)
			guardianMoving = true
		end

		if distance <= KILL_DISTANCE
			and now - (guardianHitTimes[targetPlayer] or 0) > 1 then

			guardianHitTimes[targetPlayer] = now

			local humanoid = targetPlayer.Character
				and targetPlayer.Character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid.Health = 0
			end

			if carriedBy == targetPlayer and carriedEgg then
				restoreEgg(carriedEgg)
			end
		end

	else
		local homeTarget = Vector3.new(
			guardianHomePosition.X,
			guardianPosition.Y,
			guardianHomePosition.Z
		)

		local offset = homeTarget - guardianPosition

		if offset.Magnitude > 0.2 then
			guardianPosition += offset.Unit
				* math.min(offset.Magnitude, GUARDIAN_RETURN_SPEED * dt)

			guardianPosition = snapGuardianToGround(guardianPosition)
			guardianMoving = true
		else
			guardianPosition = guardianHomePosition
		end
	end

	-- GUARDIAN ANIMATION
	guardianWalkClock += dt

	local guardianCF = CFrame.new(guardianPosition)
		* CFrame.Angles(0, CHICKEN_ROTATION, 0)

	poseChicken(
		guardian,
		guardianCF,
		guardianMoving and math.sin(guardianWalkClock * 9) or 0,
		0,
		not guardianMoving and not targetRoot and not droppedEgg
	)

	-- PET CHICKEN WANDERING AND PECKING
	for player, pets in pairs(petsByPlayer) do
		local garden, floor = getGarden(player)

		if garden and floor then
			for _, pet in ipairs(pets) do
				if pet.Alive and pet.Data.Model.Parent then
					local currentPosition = pet.Data.Body.Position

					if not pet.Target
						or (pet.Target - currentPosition).Magnitude < 0.7 then

						if now >= pet.NextMove then
							pet.Target = chooseGardenPosition(
								floor,
								pet.HomeX,
								pet.HomeZ
							)

							pet.NextMove = now + math.random(2, 4)
						end
					end

					local target = pet.Target or currentPosition
					local difference = target - currentPosition

					local moving = difference.Magnitude > 0.25
					local nextPosition = currentPosition
					local walk = 0

					if moving then
						nextPosition += difference.Unit
							* math.min(
								difference.Magnitude,
								PET_WALK_SPEED * dt
							)

						walk = math.sin(now * 4)
					end

					local localPos = floor.CFrame:PointToObjectSpace(nextPosition)

					local x = math.clamp(
						localPos.X,
						-GARDEN_HALF_X,
						GARDEN_HALF_X
					)

					local z = math.clamp(
						localPos.Z,
						-GARDEN_HALF_Z,
						GARDEN_HALF_Z
					)

					nextPosition = gardenPosition(floor, x, z, 0.1)

					local facing = moving and difference.Unit
						or floor.CFrame.LookVector

					local rootCF = CFrame.lookAt(
						nextPosition,
						nextPosition + facing
					)

					if now >= pet.NextPeck then
						pet.PeckStart = now
						pet.NextPeck = now + math.random(
							PECK_INTERVAL_MIN,
							PECK_INTERVAL_MAX
						)
					end

					local peck = 0

					if pet.PeckStart > 0 then
						local elapsed = now - pet.PeckStart

						if elapsed < PECK_DURATION then
							peck = math.sin(
								(elapsed / PECK_DURATION) * math.pi
							)
						else
							pet.PeckStart = 0
						end
					end

					poseChicken(pet.Data, rootCF, walk, peck)
				end
			end
		end
	end
end)

-- SELL CHICKEN HELPERS
local function getSellPetInfo(pet)
	if not pet or not pet.Alive then
		return nil
	end

	if not pet.Data or not pet.Data.Model or not pet.Data.Model.Parent then
		return nil
	end

	local modelName = pet.Data.Model.Name

	if string.match(modelName, "^COMMON CHICKEN") then
		return {
			Id = modelName,
			Name = "Common Chicken",
			Price = SELL_PRICES.Common,
		}
	end

	if string.match(modelName, "^RARE BLUE CHICKEN") then
		return {
			Id = modelName,
			Name = "Rare Chicken",
			Price = SELL_PRICES.Rare,
		}
	end

	-- MYTHIC CHICKEN NOT SELLABLE YET
	return nil
end

-- SEND SELLABLE CHICKENS TO CLIENT
getSellPets.OnServerInvoke = function(player)
	local result = {}
	local pets = petsByPlayer[player]

	if not pets then
		return result
	end

	for _, pet in ipairs(pets) do
		local info = getSellPetInfo(pet)

		if info then
			table.insert(result, info)
		end
	end

	return result
end

-- SELL CHICKEN REQUEST
sellPetEvent.OnServerEvent:Connect(function(player, petId)
	if typeof(petId) ~= "string" or #petId > 100 then
		sellPetEvent:FireClient(player, "FAILED", "Invalid chicken.")
		return
	end

	local root = getRoot(player)

	if not root then
		sellPetEvent:FireClient(player, "FAILED", "Character not found.")
		return
	end

	local distance = (root.Position - SELL_STALL_POSITION).Magnitude

	if distance > SELL_MAX_DISTANCE then
		sellPetEvent:FireClient(player, "FAILED", "Pumunta muna sa SELL stall.")
		return
	end

	local pets = petsByPlayer[player]

	if not pets then
		sellPetEvent:FireClient(player, "FAILED", "Wala kang chicken.")
		return
	end

	for index = #pets, 1, -1 do
		local pet = pets[index]

		if pet.Alive
			and pet.Data
			and pet.Data.Model
			and pet.Data.Model.Name == petId then

			local info = getSellPetInfo(pet)

			if not info then
				sellPetEvent:FireClient(player, "FAILED", "Hindi puwedeng ibenta ang chicken na ito.")
				return
			end

			-- REMOVE CHICKEN
			pet.Alive = false
			pet.Data.Model:Destroy()
			table.remove(pets, index)

			-- GIVE CASH
			getCash(player).Value += info.Price

			sellPetEvent:FireClient(
				player,
				"SUCCESS",
				info.Name,
				info.Price
			)

			return
		end
	end

	sellPetEvent:FireClient(player, "FAILED", "Hindi makita ang chicken na iyon.")
end)

-- CLEANUP
Players.PlayerRemoving:Connect(function(player)
	if carriedBy == player and carriedEgg then
		restoreEgg(carriedEgg)
	end

	if gardenPads[player] then
		gardenPads[player]:Destroy()
		gardenPads[player] = nil
	end

	local pets = petsByPlayer[player]
	if pets then
		for _, pet in ipairs(pets) do
			pet.Alive = false
			if pet.Data.Model then
				pet.Data.Model:Destroy()
			end
		end

		petsByPlayer[player] = nil
	end

	guardianHitTimes[player] = nil
	runningPlayers[player] = nil
	securedPlayers[player] = nil
end)

print("AFX Egg + Chicken + Garden + SELL System Loaded!")
