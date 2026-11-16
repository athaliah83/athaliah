-- Loadout shop UI LocalScript
-- Put in StarterPlayer > StarterPlayerScripts.
-- Requires LoadoutServer.server.lua and LoadoutCatalog ModuleScript.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("LoadoutRemote")
local ok, initial = pcall(function() return remote:InvokeServer("Init") end)
if not ok or not initial or not initial.ok then warn("Loadout shop could not initialize") return end

local theme = {
	bg = Color3.fromRGB(15, 13, 19), panel = Color3.fromRGB(24, 21, 29), card = Color3.fromRGB(35, 30, 40),
	red = Color3.fromRGB(255, 40, 78), white = Color3.fromRGB(248, 245, 249), muted = Color3.fromRGB(164, 154, 168),
	green = Color3.fromRGB(63, 193, 128),
}
local catalog = initial.catalog or {}
local coins = initial.coins or 0
local equipped = initial.equipped or {}
local currentTab = "SHOP"
local selectedSlot = "Primary"
local gui = Instance.new("ScreenGui")
gui.Name = "LoadoutShopGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local function corner(instance, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = instance
end
local function button(parent, text, size, pos, color, textColor, fontSize)
	local b = Instance.new("TextButton")
	b.Size = size
	b.Position = pos
	b.BackgroundColor3 = color
	b.BorderSizePixel = 0
	b.Text = text
	b.TextColor3 = textColor or theme.white
	b.Font = Enum.Font.GothamBold
	b.TextSize = fontSize or 13
	b.TextWrapped = true
	b.Parent = parent
	corner(b, 8)
	return b
end
local function invoke(action, payload)
	local success, result = pcall(function() return remote:InvokeServer(action, payload) end)
	if not success then return nil end
	return result
end

-- Bottom navigation inspired by the screenshot.
local nav = Instance.new("Frame")
nav.Name = "BottomNavigation"
nav.Size = UDim2.new(0, 360, 0, 54)
nav.Position = UDim2.new(0, 16, 1, -70)
nav.BackgroundTransparency = 1
nav.Parent = gui
local shopOpen = button(nav, "SHOP", UDim2.new(0, 110, 1, 0), UDim2.new(), theme.panel, theme.white, 12)
local loadoutOpen = button(nav, "LOADOUT", UDim2.new(0, 110, 1, 0), UDim2.new(0, 120, 0, 0), theme.panel, theme.white, 12)
local plus = button(nav, "+", UDim2.new(0, 54, 1, 0), UDim2.new(0, 244, 0, 0), theme.red, theme.white, 24)

local panel = Instance.new("Frame")
panel.Name = "ShopLoadoutPanel"
panel.Size = UDim2.new(0, 440, 0, 520)
panel.Position = UDim2.new(1, -460, 0.5, -260)
panel.BackgroundColor3 = theme.bg
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui
corner(panel, 16)
local stroke = Instance.new("UIStroke")
stroke.Color = theme.red
stroke.Thickness = 1.5
stroke.Parent = panel

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -150, 0, 38)
title.Position = UDim2.new(0, 20, 0, 14)
title.Font = Enum.Font.GothamBold
title.TextSize = 23
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = theme.white
title.Text = "SHOP"
title.Parent = panel

local coinLabel = Instance.new("TextLabel")
coinLabel.Size = UDim2.new(0, 118, 0, 34)
coinLabel.Position = UDim2.new(1, -138, 0, 16)
coinLabel.BackgroundColor3 = theme.card
coinLabel.BorderSizePixel = 0
coinLabel.TextColor3 = theme.white
coinLabel.Font = Enum.Font.GothamBold
coinLabel.TextSize = 14
coinLabel.Parent = panel
corner(coinLabel, 8)

local tabShop = button(panel, "SHOP", UDim2.new(0, 185, 0, 36), UDim2.new(0, 18, 0, 62), theme.red, theme.white, 12)
local tabLoadout = button(panel, "LOADOUT", UDim2.new(0, 185, 0, 36), UDim2.new(0, 210, 0, 62), theme.card, theme.white, 12)
local slotTabs = Instance.new("Frame")
slotTabs.BackgroundTransparency = 1
slotTabs.Size = UDim2.new(1, -36, 0, 34)
slotTabs.Position = UDim2.new(0, 18, 0, 108)
slotTabs.Visible = false
slotTabs.Parent = panel
local slotButtons = {}
for index, slot in ipairs({"Primary", "Secondary", "Melee"}) do
	local b = button(slotTabs, slot:upper(), UDim2.new(0, 126, 1, 0), UDim2.new(0, (index - 1) * 132, 0, 0), slot == selectedSlot and theme.red or theme.card, theme.white, 10)
	slotButtons[slot] = b
end

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -36, 1, -202)
list.Position = UDim2.new(0, 18, 0, 154)
list.BackgroundColor3 = theme.panel
list.BorderSizePixel = 0
list.ScrollBarThickness = 5
list.CanvasSize = UDim2.new()
list.Parent = panel
corner(list, 10)
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list
local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = list
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end)
local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Size = UDim2.new(1, -36, 0, 24)
status.Position = UDim2.new(0, 18, 1, -34)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextColor3 = theme.muted
status.Text = ""
status.Parent = panel

local function updateCoins(value)
	coins = value or coins
	coinLabel.Text = string.format("◈ %d COINS", coins)
end
local function render()
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
	end
	local shopMode = currentTab == "SHOP"
	title.Text = shopMode and "SHOP" or "LOADOUT"
	slotTabs.Visible = not shopMode
	local items = {}
	for _, item in ipairs(catalog) do
		if shopMode or item.slot == selectedSlot then table.insert(items, item) end
	end
	for order, item in ipairs(items) do
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, -4, 0, 92)
		card.BackgroundColor3 = theme.card
		card.BorderSizePixel = 0
		card.LayoutOrder = order
		card.Parent = list
		corner(card, 9)
		local name = Instance.new("TextLabel")
		name.BackgroundTransparency = 1
		name.Position = UDim2.new(0, 14, 0, 10)
		name.Size = UDim2.new(1, -150, 0, 22)
		name.Text = item.name
		name.TextColor3 = theme.white
		name.Font = Enum.Font.GothamBold
		name.TextSize = 15
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.Parent = card
		local detail = Instance.new("TextLabel")
		detail.BackgroundTransparency = 1
		detail.Position = UDim2.new(0, 14, 0, 35)
		detail.Size = UDim2.new(1, -150, 0, 38)
		detail.Text = string.format("%s  •  %s\n%s", item.rarity or "ITEM", item.slot, item.description or "")
		detail.TextColor3 = theme.muted
		detail.Font = Enum.Font.Gotham
		detail.TextSize = 10
		detail.TextWrapped = true
		detail.TextXAlignment = Enum.TextXAlignment.Left
		detail.Parent = card

		local actionText
		local actionColor = theme.red
		local canClick = item.available
		if not item.available then
			actionText, actionColor, canClick = "UNAVAILABLE", theme.card, false
		elseif shopMode then
			if item.owned then actionText, actionColor = "OWNED", theme.green
			else actionText = item.price == 0 and "FREE" or ("◈ " .. tostring(item.price)) end
		else
			if item.owned and equipped[item.slot] == item.id then actionText, actionColor = "EQUIPPED", theme.green
			elseif item.owned then actionText = "EQUIP"
			else actionText, actionColor, canClick = "LOCKED", theme.card, false end
		end
		local action = button(card, actionText, UDim2.new(0, 114, 0, 38), UDim2.new(1, -126, 0.5, -19), actionColor, theme.white, 11)
		action.Active = canClick and not (shopMode and item.owned) and not (not shopMode and equipped[item.slot] == item.id)
		if action.Active then
			action.Activated:Connect(function()
				local result
				if shopMode then
					result = invoke("Buy", item.id)
				else
					result = invoke("Equip", item.id)
				end
				if not result then status.Text = "Request failed. Please try again." return end
				status.Text = result.message or ""
				if result.coins then updateCoins(result.coins) end
				if result.catalog then catalog = result.catalog end
				if result.equipped then equipped = result.equipped end
				if result.ok then
					local refresh = invoke("Init")
					if refresh and refresh.ok then catalog, equipped = refresh.catalog, refresh.equipped; updateCoins(refresh.coins) end
				end
				render()
			end)
		end
	end
end

local function setTab(tab)
	currentTab = tab
	tabShop.BackgroundColor3 = tab == "SHOP" and theme.red or theme.card
	tabLoadout.BackgroundColor3 = tab == "LOADOUT" and theme.red or theme.card
	status.Text = ""
	render()
end
for slot, b in pairs(slotButtons) do
	b.Activated:Connect(function()
		selectedSlot = slot
		for name, other in pairs(slotButtons) do other.BackgroundColor3 = name == slot and theme.red or theme.card end
		render()
	end)
end
tabShop.Activated:Connect(function() setTab("SHOP") end)
tabLoadout.Activated:Connect(function() setTab("LOADOUT") end)
local function toggle(tab)
	if panel.Visible and currentTab == tab then panel.Visible = false else panel.Visible = true; setTab(tab) end
end
shopOpen.Activated:Connect(function() toggle("SHOP") end)
loadoutOpen.Activated:Connect(function() toggle("LOADOUT") end)
plus.Activated:Connect(function() toggle("SHOP") end)
updateCoins(coins)
render()
