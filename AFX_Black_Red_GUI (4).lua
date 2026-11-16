-- Roblox wardrobe/customizer LocalScript
-- Put in StarterPlayer > StarterPlayerScripts.
-- Requires WardrobeServer.server.lua and WardrobeConfig.lua; see README setup notes.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("WardrobeRemote")
local C = {
	bg = Color3.fromRGB(17, 17, 21), panel = Color3.fromRGB(25, 26, 31), tile = Color3.fromRGB(35, 37, 43),
	red = Color3.fromRGB(255, 48, 65), white = Color3.fromRGB(245, 245, 247), muted = Color3.fromRGB(160, 162, 170),
}

local function invoke(action, payload)
	local ok, result = pcall(function() return remote:InvokeServer(action, payload) end)
	if not ok then return nil, "Connection error. Try again." end
	return result
end

local response, initError = invoke("Init")
if not response then warn(initError) return end
local catalog = response.catalog or {}
local currentCategory = "Body"
local currentSlot = response.activeSlot or 1
local gui = Instance.new("ScreenGui")
gui.Name = "WardrobeGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 480, 0, 570)
panel.Position = UDim2.new(1, -500, 0.5, -285)
panel.BackgroundColor3 = C.bg
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 18)
local outline = Instance.new("UIStroke", panel)
outline.Color = C.red
outline.Thickness = 1.5

local function label(parent, text, size, pos, fontSize, color, font)
	local obj = Instance.new("TextLabel")
	obj.BackgroundTransparency = 1
	obj.Size = size
	obj.Position = pos
	obj.Font = font or Enum.Font.Gotham
	obj.Text = text
	obj.TextSize = fontSize
	obj.TextColor3 = color or C.white
	obj.TextXAlignment = Enum.TextXAlignment.Left
	obj.Parent = parent
	return obj
end

local title = label(panel, "WARDROBE", UDim2.new(1, -40, 0, 42), UDim2.new(0, 22, 0, 14), 24, C.white, Enum.Font.GothamBold)
local subtitle = label(panel, "Customize your character", UDim2.new(1, -40, 0, 20), UDim2.new(0, 22, 0, 51), 12, C.muted)

local slotFrame = Instance.new("Frame")
slotFrame.BackgroundTransparency = 1
slotFrame.Size = UDim2.new(1, -32, 0, 42)
slotFrame.Position = UDim2.new(0, 16, 0, 82)
slotFrame.Parent = panel
local slotButtons = {}

local function roundedButton(parent, text, size, pos, color, textSize)
	local button = Instance.new("TextButton")
	button.Size = size
	button.Position = pos
	button.BackgroundColor3 = color or C.tile
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = C.white
	button.Font = Enum.Font.GothamBold
	button.TextSize = textSize or 12
	button.AutoButtonColor = true
	button.Parent = parent
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
	return button
end

local categoryFrame = Instance.new("Frame")
categoryFrame.Size = UDim2.new(1, -32, 0, 112)
categoryFrame.Position = UDim2.new(0, 16, 0, 132)
categoryFrame.BackgroundTransparency = 1
categoryFrame.Parent = panel
local categories = {"Body", "Hair", "Hats", "Glasses", "Masks", "Hoodies", "Pants", "Shoes"}
local categoryButtons = {}
local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -32, 0, 258)
list.Position = UDim2.new(0, 16, 0, 256)
list.BackgroundColor3 = C.panel
list.BorderSizePixel = 0
list.ScrollBarThickness = 5
list.CanvasSize = UDim2.new()
list.Parent = panel
Instance.new("UICorner", list).CornerRadius = UDim.new(0, 10)
local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0, 130, 0, 68)
grid.CellPadding = UDim2.new(0, 8, 0, 8)
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
grid.Parent = list

grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	list.CanvasSize = UDim2.new(0, 0, 0, grid.AbsoluteContentSize.Y + 12)
end)

local status = label(panel, "", UDim2.new(1, -32, 0, 20), UDim2.new(0, 18, 1, -62), 11, C.muted)
status.TextXAlignment = Enum.TextXAlignment.Center
local save = roundedButton(panel, "SAVE OUTFIT", UDim2.new(1, -32, 0, 40), UDim2.new(0, 16, 1, -38), C.red, 14)

local function refreshList()
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("GuiButton") then child:Destroy() end
	end
	local items = catalog[currentCategory] or {}
	if #items == 0 then
		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1, -20, 0, 70)
		empty.BackgroundTransparency = 1
		empty.Text = "No items configured for this category yet."
		empty.TextColor3 = C.muted
		empty.Font = Enum.Font.Gotham
		empty.TextSize = 12
		empty.Parent = list
		return
	end
	for _, item in ipairs(items) do
		local button = roundedButton(list, item.name .. (item.enabled and "" or "\n(set asset ID in config)"), UDim2.new(), UDim2.new(), C.tile, 11)
		button.TextWrapped = true
		button.TextColor3 = item.enabled and C.white or C.muted
		button.Activated:Connect(function()
			if not item.enabled then
				status.Text = "Add an allowed asset ID in WardrobeConfig.lua first."
				return
			end
			local result, err = invoke("Equip", { category = currentCategory, name = item.name })
			status.Text = result and (result.ok and (item.name .. " equipped.") or result.message or "Could not equip item.") or err
		end)
	end
end

for index, category in ipairs(categories) do
	local col = (index - 1) % 4
	local row = math.floor((index - 1) / 4)
	local button = roundedButton(categoryFrame, category, UDim2.new(0, 104, 0, 42), UDim2.new(0, col * 110, 0, row * 50), C.tile, 11)
	categoryButtons[category] = button
	button.Activated:Connect(function()
		currentCategory = category
		for name, other in pairs(categoryButtons) do other.BackgroundColor3 = name == category and C.red or C.tile end
		refreshList()
	end)
end

for slot = 1, 3 do
	local button = roundedButton(slotFrame, "OUTFIT " .. slot, UDim2.new(0, 137, 0, 36), UDim2.new(0, (slot - 1) * 144, 0, 0), slot == currentSlot and C.red or C.tile, 11)
	slotButtons[slot] = button
	button.Activated:Connect(function()
		local result, err = invoke("Select", slot)
		if not result then status.Text = err or "Could not load outfit." return end
		currentSlot = slot
		for i, other in ipairs(slotButtons) do other.BackgroundColor3 = i == slot and C.red or C.tile end
		status.Text = result.ok and "Outfit loaded." or (result.message or "Could not load outfit.")
	end)
end

save.Activated:Connect(function()
	local result, err = invoke("Save")
	status.Text = result and (result.message or (result.ok and "Outfit saved." or "Save failed.")) or err
end)

categoryButtons.Body.BackgroundColor3 = C.red
refreshList()
