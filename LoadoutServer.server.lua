-- ServerScriptService/LoadoutServer.server.lua
-- Server-authoritative shop purchases, loadout selection, and persistence.
-- Place weapon Tools in ServerStorage/LoadoutTools, matching Catalog toolName values.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")
local ServerScriptService = game:GetService("ServerScriptService")

local Catalog = require(ServerScriptService:WaitForChild("LoadoutCatalog"))
local Store = DataStoreService:GetDataStore("PlayerLoadouts_v1")
local REMOTE_NAME = "LoadoutRemote"
local TOOLS_FOLDER_NAME = "LoadoutTools"
local SAVE_COOLDOWN = 2

local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if not remote then
	remote = Instance.new("RemoteFunction")
	remote.Name = REMOTE_NAME
	remote.Parent = ReplicatedStorage
end

local toolFolder = ServerStorage:FindFirstChild(TOOLS_FOLDER_NAME)
if not toolFolder then
	toolFolder = Instance.new("Folder")
	toolFolder.Name = TOOLS_FOLDER_NAME
	toolFolder.Parent = ServerStorage
end

local catalogById = {}
for _, item in ipairs(Catalog.Weapons) do catalogById[item.id] = item end
local dataByPlayer = {}
local lastSave = {}

local function defaults()
	return {
		coins = Catalog.StartingCoins or 0,
		owned = { starter_rifle = true, sidekick = true, training_blade = true },
		equipped = { Primary = "starter_rifle", Secondary = "sidekick", Melee = "training_blade" },
	}
end

local function sanitize(data)
	local clean = defaults()
	if type(data) ~= "table" then return clean end
	if type(data.coins) == "number" and data.coins >= 0 then clean.coins = math.floor(data.coins) end
	if type(data.owned) == "table" then
		for id, owned in pairs(data.owned) do
			if owned == true and catalogById[id] then clean.owned[id] = true end
		end
	end
	if type(data.equipped) == "table" then
		for slot, id in pairs(data.equipped) do
			local item = catalogById[id]
			if item and item.slot == slot and clean.owned[id] then clean.equipped[slot] = id end
		end
	end
	return clean
end

local function publicCatalog(playerData)
	local result = {}
	for _, item in ipairs(Catalog.Weapons) do
		local tool = toolFolder:FindFirstChild(item.toolName)
		table.insert(result, {
			id = item.id, name = item.name, slot = item.slot, price = item.price,
			description = item.description, rarity = item.rarity,
			owned = playerData.owned[item.id] == true,
			available = tool ~= nil and tool:IsA("Tool"),
		})
	end
	return result
end

local function save(player, force)
	local data = dataByPlayer[player]
	if not data then return false, "No player data." end
	if not force and os.clock() - (lastSave[player] or 0) < SAVE_COOLDOWN then
		return false, "Please wait a moment before saving again."
	end
	lastSave[player] = os.clock()
	local ok, err = pcall(function()
		Store:SetAsync("player_" .. player.UserId, data)
	end)
	return ok, ok and nil or tostring(err)
end

local function removeLoadoutTools(player)
	local backpack = player:FindFirstChildOfClass("Backpack")
	local character = player.Character
	for _, container in ipairs({backpack, character}) do
		if container then
			for _, child in ipairs(container:GetChildren()) do
				if child:IsA("Tool") and child:GetAttribute("LoadoutItem") == true then child:Destroy() end
			end
		end
	end
end

local function equipSlot(player, slot)
	local data = dataByPlayer[player]
	local id = data and data.equipped[slot]
	local item = id and catalogById[id]
	if not item or not data.owned[id] then return false, "No owned item selected for this slot." end
	local source = toolFolder:FindFirstChild(item.toolName)
	if not source or not source:IsA("Tool") then return false, item.name .. " Tool is not configured in ServerStorage/LoadoutTools." end
	local backpack = player:FindFirstChildOfClass("Backpack")
	if not backpack then return false, "Backpack is not ready." end
	for _, container in ipairs({backpack, player.Character}) do
		if container then
			for _, child in ipairs(container:GetChildren()) do
				if child:IsA("Tool") and child:GetAttribute("LoadoutItem") == true and child:GetAttribute("LoadoutSlot") == slot then child:Destroy() end
			end
		end
	end
	local clone = source:Clone()
	clone:SetAttribute("LoadoutItem", true)
	clone:SetAttribute("LoadoutSlot", slot)
	clone.Parent = backpack
	return true
end

local function syncEquipped(player)
	removeLoadoutTools(player)
	for _, slot in ipairs({"Primary", "Secondary", "Melee"}) do
		equipSlot(player, slot)
	end
end

local function loadPlayer(player)
	local ok, stored = pcall(function() return Store:GetAsync("player_" .. player.UserId) end)
	dataByPlayer[player] = sanitize(ok and stored or nil)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = dataByPlayer[player].coins
	coins.Parent = stats
	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		if player.Parent and dataByPlayer[player] then syncEquipped(player) end
	end)
	if player.Character then task.defer(syncEquipped, player) end
end

Players.PlayerAdded:Connect(loadPlayer)
for _, player in ipairs(Players:GetPlayers()) do task.spawn(loadPlayer, player) end

Players.PlayerRemoving:Connect(function(player)
	local data = dataByPlayer[player]
	if data then save(player, true) end
	dataByPlayer[player] = nil
	lastSave[player] = nil
end)

game:BindToClose(function()
	for player in pairs(dataByPlayer) do task.spawn(save, player, true) end
	task.wait(2)
end)

remote.OnServerInvoke = function(player, action, payload)
	local data = dataByPlayer[player]
	if not data then return { ok = false, message = "Player data is still loading." } end

	if action == "Init" then
		return { ok = true, coins = data.coins, catalog = publicCatalog(data), equipped = data.equipped }
	elseif action == "Buy" then
		if type(payload) ~= "string" then return { ok = false, message = "Invalid item." } end
		local item = catalogById[payload]
		if not item then return { ok = false, message = "Item not found." } end
		if data.owned[item.id] then return { ok = false, message = "Already owned." } end
		if type(item.price) ~= "number" or item.price < 0 then return { ok = false, message = "Invalid price configuration." } end
		local source = toolFolder:FindFirstChild(item.toolName)
		if not source or not source:IsA("Tool") then return { ok = false, message = "Shop item is not available yet." } end
		if data.coins < item.price then return { ok = false, message = "Not enough coins." } end
		data.coins -= item.price
		data.owned[item.id] = true
		local stats = player:FindFirstChild("leaderstats")
		local coinValue = stats and stats:FindFirstChild("Coins")
		if coinValue then coinValue.Value = data.coins end
		local saved = save(player, true)
		if not saved then
			data.coins += item.price
			data.owned[item.id] = nil
			if coinValue then coinValue.Value = data.coins end
			return { ok = false, message = "Purchase could not be saved. Try again." }
		end
		return { ok = true, message = "Purchased " .. item.name .. "!", coins = data.coins, catalog = publicCatalog(data) }
	elseif action == "Equip" then
		if type(payload) ~= "string" then return { ok = false, message = "Invalid item." } end
		local item = catalogById[payload]
		if not item or not data.owned[payload] then return { ok = false, message = "You do not own that item." } end
		data.equipped[item.slot] = payload
		local ok, err = equipSlot(player, item.slot)
		if not ok then return { ok = false, message = err } end
		save(player, true)
		return { ok = true, message = item.name .. " equipped.", equipped = data.equipped }
	elseif action == "Save" then
		local ok, err = save(player, true)
		return { ok = ok, message = ok and "Loadout saved." or "Save failed: " .. tostring(err) }
	end
	return { ok = false, message = "Unknown request." }
end
