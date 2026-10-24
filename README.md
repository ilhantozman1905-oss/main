# Moon Scrubbers — playable alpha 0.2

A Roblox lunar cleaning tycoon: **scrub → return to your base → launch dust shipments → buy upgrades → unlock zones → automate and drive sweepers → prestige**. Built from the original Moon Scrubbers brief; this replaces the limited step-2 prototype.

## Play in Roblox Studio

Open **build/MoonScrubbers.rbxlx** with Studio's Open from File command, then press **Play / F5**. In the installation ZIP the place is at the ZIP root. The world, personal bases and UI are generated when Play starts; do not paste duplicate scripts into the place.

1. Click **START MY SHIFT**. Claim the free daily delivery if desired.
2. Open **ZONES → Dusty Plains → TRAVEL**.
3. Select **BRUSH** in the bottom bar (or equip the inventory tool). Look down, hold left mouse / R2 / the touch POETS button, and sweep your aim across nearby dust.
4. Select **HOME**, then walk onto your own gold **SHIP DUST** pad, use its proximity prompt, or press **SELL** nearby. A rocket launches and you receive credits.
5. Use **SHOP** at your base for better tools, suits and tank capacity. **BASE** upgrades your actual buildings.
6. Unlock better **ZONES**, buy **ROBOTS**, and deploy **VEHICLES**. Claim missions and open earned **CAPSULES**. All progression uses earned credits.

Press **M** (gamepad **Y**) to open menus while holding the brush; **H** returns home. The menu releases the first-person camera and cleaning input. The bottom navigation scrolls horizontally on small screens. Gamepad buttons are selectable; use Roblox's GUI selection control to enter navigation. Vehicles use standard Roblox vehicle inputs; jump to exit.

## Included gameplay

- Five distinct decorated work zones, a landing plaza, four personal bases, Earth and star backdrop, lunar gravity, first-person animated tools and physical dust backpacks.
- Eight tools, four visible suit tiers, ten tank upgrades, five buildings with five upgrade levels each, sequential zone unlocks and rare 8×-value dust.
- Personal shipping pads with automatic arrival sales, rocket launches, mixed-zone dust valuation, visible credit/tank HUD, and server-authoritative shops.
- Four robot tiers, up to eight robots per owner, zone assignment, visible movement, automatic payout, and three-hour capped offline earnings at 15% active rate.
- Six progressive ground-driven sweeper vehicles, separate storage, owner-validated driving, passenger seat, lunar physics and automatic depot unloading. The final ship-shaped sweeper is not a free-flight spacecraft.
- Daily login streaks, daily/weekly collection missions, career achievements, capsule milestones, cosmetic album, duplicate fragments, crafting, disclosed odds, rare-or-better pity and cosmetic reveals.
- Permanent prestige earnings bonuses, a recurring meteor-shower event, humorous idle radio messages, and a **current-server** earnings leaderboard.
- Public/local play, published-experience Solo reserved servers, and Friends rooms using shareable expiring codes.
- DataStore profiles with session leases, retries, autosave, leave/shutdown saving and explicit Studio fallback.

## Save and server settings

Local unpublished Studio sessions work without cloud access and clearly say **STUDIO: session only** if DataStore calls fail. To test persistence, publish a **separate test experience**, enable Studio API access in its security settings, and rejoin the same experience. Live servers never silently overwrite an unreadable profile with fresh progress.

Set the place maximum to **4 players** in Roblox settings. The game also limits active crews to its four base slots. Teleport/MemoryStore room tests require a published experience and Roblox client; they do not run in ordinary Studio play. See [Studio acceptance tests](docs/STUDIO.md) and [Dutch installation guide](docs/INSTALLATIE-NL.md).

## Development and checks

`default.project.json` maps source to the correct Roblox services. Use Rojo 7.6.1:

```sh
rojo serve default.project.json
rojo build default.project.json -o /tmp/MoonScrubbers.rbxlx
python3 tools/package.py --place /tmp/MoonScrubbers.rbxlx
```

The packager verifies every embedded script against `src`, archives replaced builds, creates both ZIPs, and validates their contents. `src/shared/GameRules.lua` is pure economy/progression logic; server services own all mutations. The shared `Grid.lua` handles dust conservation.

[Validation results](docs/VALIDATION.md) distinguish executed tests from pending Roblox runtime checks. [Gameplay and balance](docs/GAMEPLAY.md) lists costs and progression. Custom audio can replace the built-in movement-sound brush foley in `Config.Audio.BrushSoundId`.

## Release status

This is a **playable alpha implementation**, not a claim of completed Studio QA or a published production game. The cloud machine has no Roblox engine. Geometry, characters and tool/vehicle shapes are procedural art. Premium purchases, paid random items, Roblox Badge IDs, global cross-server leaderboards, direct friend invites, seasonal content and custom music are not enabled. No Robux products or paid boosts are required for any implemented progression.
