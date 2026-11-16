-- Wardrobe catalog configuration
-- Place this ModuleScript at ServerScriptService/WardrobeConfig.
-- Replace assetId = 0 examples with asset IDs you own or are allowed to use.

return {
	Categories = {
		Body = {
			{ name = "Classic", color = Color3.fromRGB(235, 202, 174) },
			{ name = "Warm Tan", color = Color3.fromRGB(195, 140, 110) },
			{ name = "Deep Brown", color = Color3.fromRGB(135, 93, 70) },
			{ name = "Pale", color = Color3.fromRGB(248, 220, 196) },
		},
		Hair = {
			-- HairAccessory is used for these accessory asset IDs.
			{ name = "Black Hair", assetId = 0, field = "HairAccessory" },
			{ name = "Brown Hair", assetId = 0, field = "HairAccessory" },
			{ name = "Blonde Hair", assetId = 0, field = "HairAccessory" },
		},
		Hats = {
			{ name = "Black Cap", assetId = 0, field = "HatAccessory" },
			{ name = "Red Cap", assetId = 0, field = "HatAccessory" },
		},
		Glasses = {
			{ name = "Black Glasses", assetId = 0, field = "FaceAccessory" },
			{ name = "Round Glasses", assetId = 0, field = "FaceAccessory" },
		},
		Masks = {
			{ name = "Black Mask", assetId = 0, field = "FaceAccessory" },
			{ name = "Red Mask", assetId = 0, field = "FaceAccessory" },
		},
		Hoodies = {
			-- Shirt asset ID (classic clothing).
			{ name = "Black Hoodie", assetId = 0, field = "Shirt" },
			{ name = "Red Hoodie", assetId = 0, field = "Shirt" },
		},
		Pants = {
			{ name = "Black Pants", assetId = 0, field = "Pants" },
			{ name = "Blue Pants", assetId = 0, field = "Pants" },
		},
		Shoes = {
			{ name = "Black Shoes", assetId = 0, field = "LeftShoeAccessory", pairedField = "RightShoeAccessory" },
			{ name = "White Shoes", assetId = 0, field = "LeftShoeAccessory", pairedField = "RightShoeAccessory" },
		},
	},
}
