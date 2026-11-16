-- ServerScriptService/WardrobeServer.server.lua
-- Server-authoritative outfit application and persistence.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService:WaitForChild("WardrobeConfig"))
local Store = DataStoreService:GetDataStore("WardrobeOutfits_v1")
local REMOTE_NAME = "WardrobeRemote"
local MAX_SLOTS = 3

local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if not remote then
	remote = Instance.new("RemoteFunction")
	remote.Name = REMOTE_NAME
	remote.Parent = ReplicatedStorage
end

local savedByPlayer = {}
local activeSlot = {}
local baseDescriptions = {}

local function publicCatalog()
	local result = {}
	for category, items in pairs(Config.Categories) do
		result[category] = {}
		for _, item in ipairs(items) do
			table.insert(result[category], { name = item.name, enabled = item.assetId == nil or item.assetId > 0 })
		end
	end
	return result
end

local function cleanState(state)
	local clean = {}
	if type(state) ~= "table" then return clean end
	for category, itemName in pairs(state) do
		if type(category) == "string" and type(itemName) == "string" then
			local items = Config.Categories[category]
			if items then
				for _, item in ipairs(items) do
					if item.name == itemName then clean[category] = itemName break end
				end
			end
		end
	end
	return clean
end

local function appendAccessory(existing, assetId)
	local ids = {}
	for id in string.gmatch(existing or "", "[^,]+") do
		if tonumber(id) then table.insert(ids, id) end
	end
	table.insert(ids, tostring(assetId))
	return table.concat(ids, ",")
end

local function getBaseDescription(player, humanoid)
	local character = player.Character
	if character and baseDescriptions[character] then
		return baseDescriptions[character]:Clone()
	end
	local ok, description = pcall(function() return humanoid:GetAppliedDescription() end)
	if ok and description then
		if character then baseDescriptions[character] = description:Clone() end
		return description
	end
	return nil
end

local function applyState(player, state)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return false, "Character is not ready." end
	local description = getBaseDescription(player, humanoid)
	if not description then return false, "Could not load character appearance." end

	local faceAccessories = {}
	for category, itemName in pairs(state) do
		for _, item in ipairs(Config.Categories[category] or {}) do
			if item.name == itemName then
				if category == "Body" and item.color then
					description.HeadColor = item.color
					description.LeftArmColor = item.color
					description.RightArmColor = item.color
					description.LeftLegColor = item.color
					description.RightLegColor = item.color
					description.TorsoColor = item.color
				elseif item.assetId and item.assetId > 0 then
					if item.field == "FaceAccessory" then
						table.insert(faceAccessories, item.assetId)
					else
					description[item.field] = appendAccessory(description[item.field], item.assetId)
						if item.pairedField then
							description[item.pairedField] = appendAccessory(description[item.pairedField], item.assetId)
						end
					end
				end
				break
			end
		end
	end
	for _, id in ipairs(faceAccessories) do
		description.FaceAccessory = appendAccessory(description.FaceAccessory, id)
	end

	local ok, err = pcall(function() humanoid:ApplyDescription(description) end)
	description:Destroy()
	if not ok then return false, tostring(err) end
	return true
end

local function loadPlayer(player)
	local key = "player_" .. player.UserId
	local ok, data = pcall(function() return Store:GetAsync(key) end)
	savedByPlayer[player] = {}
	if ok and type(data) == "table" then
		for slot = 1, MAX_SLOTS do
			savedByPlayer[player][slot] = cleanState(data[slot])
		end
	end
	for slot = 1, MAX_SLOTS do
		savedByPlayer[player][slot] = savedByPlayer[player][slot] or {}
	end
	activeSlot[player] = 1
end

Players.PlayerAdded:Connect(function(player)
	loadPlayer(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid", 10)
		if not humanoid then return end
		task.wait(1)
		local ok, desc = pcall(function() return humanoid:GetAppliedDescription() end)
		if ok and desc then baseDescriptions[character] = desc:Clone() end
		local state = savedByPlayer[player] and savedByPlayer[player][activeSlot[player] or 1]
		if state then applyState(player, state) end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	local data = savedByPlayer[player]
	if data then
		pcall(function() Store:SetAsync("player_" .. player.UserId, data) end)
	end
	if player.Character then baseDescriptions[player.Character] = nil end
	savedByPlayer[player] = nil
	activeSlot[player] = nil
end)

game:BindToClose(function()
	for player, data in pairs(savedByPlayer) do
		pcall(function() Store:SetAsync("player_" .. player.UserId, data) end)
	end
end)

remote.OnServerInvoke = function(player, action, payload)
	if not savedByPlayer[player] then loadPlayer(player) end
	if action == "Init" then
		return { catalog = publicCatalog(), outfits = savedByPlayer[player], activeSlot = activeSlot[player] }
	elseif action == "Select" then
		local slot = tonumber(payload)
		if not slot or slot % 1 ~= 0 or slot < 1 or slot > MAX_SLOTS then return { ok = false, message = "Invalid outfit slot." } end
		activeSlot[player] = slot
		local state = savedByPlayer[player][slot]
		local ok, err = applyState(player, state)
		return { ok = ok, message = err, state = state }
	elseif action == "Equip" then
		if type(payload) ~= "table" then return { ok = false, message = "Invalid selection." } end
		local category, itemName = payload.category, payload.name
		local found = false
		for _, item in ipairs(Config.Categories[category] or {}) do
			if item.name == itemName and (not item.assetId or item.assetId > 0) then found = true break end
		end
		if not found then return { ok = false, message = "That item is not configured yet." } end
		local slot = activeSlot[player] or 1
		local state = savedByPlayer[player][slot]
		state[category] = itemName
		local ok, err = applyState(player, state)
		if not ok then state[category] = nil return { ok = false, message = err } end
		return { ok = true, state = state }
	elseif action == "Save" then
		local slot = activeSlot[player] or 1
		local data = savedByPlayer[player]
		local ok, err = pcall(function() Store:SetAsync("player_" .. player.UserId, data) end)
		return { ok = ok, message = ok and "Outfit saved." or "Save failed: " .. tostring(err) }
	end
	return { ok = false, message = "Unknown request." }
end
