-- ReplicatedStorage/LoadoutCatalog.lua (keep a copy in ServerScriptService if desired)
-- Weapon tools must exist in ServerStorage/LoadoutTools with matching Tool names.
-- These are sample game items; customize names/costs to match your own experience.

return {
	StartingCoins = 3100,
	Weapons = {
		{ id = "starter_rifle", name = "Rookie Rifle", toolName = "RookieRifle", slot = "Primary", price = 0, description = "A dependable starter weapon.", rarity = "COMMON" },
		{ id = "storm_smg", name = "Storm SMG", toolName = "StormSMG", slot = "Primary", price = 850, description = "Fast handling for close-range fights.", rarity = "RARE" },
		{ id = "viper_rifle", name = "Viper Rifle", toolName = "ViperRifle", slot = "Primary", price = 1600, description = "Accurate, steady, and reliable.", rarity = "EPIC" },
		{ id = "sidekick", name = "Sidekick Pistol", toolName = "Sidekick", slot = "Secondary", price = 0, description = "A compact backup weapon.", rarity = "COMMON" },
		{ id = "pulse_pistol", name = "Pulse Pistol", toolName = "PulsePistol", slot = "Secondary", price = 650, description = "A lightweight energy sidearm.", rarity = "RARE" },
		{ id = "training_blade", name = "Training Blade", toolName = "TrainingBlade", slot = "Melee", price = 0, description = "A basic melee loadout item.", rarity = "COMMON" },
		{ id = "neon_blade", name = "Neon Blade", toolName = "NeonBlade", slot = "Melee", price = 900, description = "A bright cosmetic melee choice.", rarity = "EPIC" },
	},
}
