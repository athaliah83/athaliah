# Loadout shop setup

This adds an in-game Shop and Loadout UI with server-side purchases, equipping, coins, and saved player data.

## Roblox Studio setup

1. Create a **ModuleScript** under `ServerScriptService` named `LoadoutCatalog`, and paste in `LoadoutCatalog.lua`.
2. Create a **Script** under `ServerScriptService` named `LoadoutServer`, and paste in `LoadoutServer.server.lua`.
3. Create a **Folder** under `ServerStorage` named `LoadoutTools`.
4. Add your actual Roblox `Tool` instances to `ServerStorage/LoadoutTools`. Tool names must match `toolName` in the catalog (for example `RookieRifle`). These are your game's own tools; no weapon tool assets are included.
5. Put `LoadoutShop.client.lua` as a **LocalScript** under `StarterPlayer > StarterPlayerScripts`.
6. Publish the game and enable **Game Settings > Security > Enable Studio Access to API Services** when testing DataStore saves in Studio.
7. Adjust the sample catalog prices/items and starting coins before release.

Purchases and equip requests are checked on the server. Players start with 3,100 coins and the three zero-cost starter items. The UI shows an item as unavailable until the matching Tool exists in `ServerStorage/LoadoutTools`. The server saves coins, owned items, and selected slot items to `PlayerLoadouts_v1`.

For production, award currency from trusted server scripts only; never let a LocalScript set currency. Test purchases, respawns, and DataStore failure cases in a private experience before publishing.
