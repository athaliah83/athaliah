# Wardrobe character system setup

This is a Roblox Studio wardrobe starter system for R6/R15 Humanoid characters. It uses Roblox `HumanoidDescription` for avatar appearance, a server script for applying outfits, and a DataStore for saving three outfit slots.

## Install in Roblox Studio

1. Create a **ModuleScript** under `ServerScriptService` named `WardrobeConfig` and paste in `WardrobeConfig.lua`.
2. Create a **Script** under `ServerScriptService` named `WardrobeServer` and paste in `WardrobeServer.server.lua`.
3. Put `AFX_Black_Red_GUI (4).lua` as a **LocalScript** under `StarterPlayer > StarterPlayerScripts`.
4. In `WardrobeConfig`, replace the sample `assetId = 0` values with valid Roblox avatar asset IDs that your experience is allowed to use. Body-color presets work without asset IDs.
5. Publish the experience and enable **Game Settings > Security > Enable Studio Access to API Services** to test DataStore saving in Studio.

The wardrobe UI appears in-game. Outfit slots are saved per player. `Shoes` uses layered clothing shoe accessory fields; confirm the selected assets support the relevant HumanoidDescription fields. Asset availability/permissions and avatar type may affect whether an item applies.

This repository is source code; scripts must be placed in the listed Roblox Studio locations. The code has not been run in Roblox Studio, so test it in a private test experience before release.
