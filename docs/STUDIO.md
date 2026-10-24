# Studio acceptance tests — playable alpha 0.2

These are **manual tests still to run in Roblox Studio/client**. Cloud Lua adapters validate logic but do not simulate Roblox rendering, physics, replication, services or device input.

## Installation and exact script placement

Use the built `MoonScrubbers.rbxlx`. Scripts are already installed. For manual source installation:

| Source | Roblox location | Type |
| --- | --- | --- |
| `src/shared/*.lua` | `ReplicatedStorage/MoonScrubbers/Shared/<filename without .lua>` | ModuleScript |
| `src/server/Bootstrap.server.lua` | `ServerScriptService/MoonScrubbers/Bootstrap` | Script |
| `src/server/Services/*.lua` | `ServerScriptService/MoonScrubbers/Services/<filename without .lua>` | ModuleScript |
| `src/client/Bootstrap.client.lua` | `StarterPlayer/StarterPlayerScripts/MoonScrubbers/Bootstrap` | LocalScript |
| `src/client/Controllers/*.lua` | `StarterPlayer/StarterPlayerScripts/MoonScrubbers/Controllers/<filename without .lua>` | ModuleScript |

Keep existing filenames in the source tree when using Rojo. The project generates `MoonWorld`, lighting, remotes and GUI at runtime. Use an empty test-place, without a duplicate Baseplate, SpawnLocation or old Moon Scrubbers scripts. Set max players to 4 in Roblox place settings. No paid assets are needed.

## Essential playable loop

1. **Load:** press Play/F5. Expect a welcome menu, credits, tank bar, decorated moon, four bases, five fields and no Output errors. If Studio APIs are unavailable, allow the bounded load retries and check the visible session-only notice. A live-server load failure should refuse entry rather than reset progress.
2. **UI:** close/reopen screens and scroll cards/navigation on desktop and a small phone emulator. M or gamepad Y opens/closes menus while the brush is equipped; H returns home. GUI selection should allow gamepad navigation. Menu opening releases the camera and stops scrubbing; closing restores equipped first-person mode.
3. **Clean:** travel to plains, equip BRUSH, look down, hold and sweep. Brush/glove animate; grounded cells fade under the correct target in all four quadrants; dust particles approach the backpack; brushing audio starts only with accepted dust. Standing completely still cannot continuously earn. Full tank stops collection.
4. **SELL:** press H/HOME. Walk to your own gold SHIP DUST pad. Arrival, prompt, or SELL nearby launches a rocket, empties the backpack and credits its actual stored value. Empty sales pay nothing. Another owner's depot must not sell to their account. Return immediately to clean and repeat.
5. **Shop:** purchase the paintbrush after two ordinary full shipments (or claim the optional daily reward). Verify price deduction, changed tool name/shape, faster collection, then tank and suit upgrades. Purchases away from home must fail without charging.
6. **Base:** upgrade each building; inspect visible size/roof/sign changes. Compare configured bonuses. Radio level 2 enables FieldSell only near a zone beacon.
7. **Zones:** buying a locked zone without the required suit must fail. With the suit and money, unlock/travel; higher-zone dust must retain its higher value through sale, even mixed with plains dust. Rare golden cells are worth 8×. Recently worked cells refill after 100 seconds of inactivity.
8. **Reset:** reset the character. Your current session profile must survive; a single new tool, backpack and helmet should appear at your base. Menus, suit stats and camera must still work. Jumping should be noticeably lunar with gravity 32.7 and JumpPower 25.

## Automation, vehicles and retention

9. Buy a robot, verify it moves in the assigned zone, removes real dust and pays automatically. Reassign it. Higher tiers require radio levels and ownership caps at eight. Check dust conservation with two robots/players on the same cell.
10. Buy/deploy a vehicle at home. Validate steering/throttle/braking, jump-to-exit, passenger seat, low-gravity bounces, independent tank and automatic unloading near your own depot. A second player must not control the owner's driver input. Test every vehicle tier, especially wide brushes and the final ground-driven ship model.
11. Daily reward is claimable once per UTC day. At 250/2,000 dust, daily/weekly missions pay once. Every 500 career dust grants one capsule. Robot/vehicle dust counts. Open earned capsules, check reveals, duplicate fragments, crafting, cosmetic equip and displayed normal/pity odds. No Robux purchase should appear.
12. Confirm prestige only with sufficient credits and explicit confirmation. Business progress resets; cosmetics/fragments/capsules and prestige bonus remain. Check the same base's prompts still work after prestige.
13. Wait four minutes for the meteor event. Newly collected dust is worth 1.5× for one minute; stored dust cannot be revalued by waiting. Idle radio messages and the current-server earnings board should update.

## Multiplayer and live services

14. Start Server & Clients with two to four players. Verify exclusive bases, shared cell depletion, separate wallets/storage/shops, nearby teamwork value bonuses and late-join snapshots. Rapidly collecting while a second client joins must not resurrect dust in that client's view. Departure frees the base and removes robots/vehicles/prompts; a new player can reuse the plot.
15. In a **separate published test experience**, test save → leave → rejoin with tools, suits, money, tanks, buildings, robots, capsules, cosmetics, missions and prestige. Confirm no rollback after a normal autosave/shutdown. A simultaneous profile session must be denied. Offline robot income must be capped to 3h and only awarded once per restored profile.
16. Test Public/Solo/Friends through the Roblox client. Solo should reserve a private server. Friends displays an eight-character code before moving the host; joining with that code reaches their room. Wrong/expired codes fail safely. The reserved-server access code must never be sent to clients. Ordinary Studio Play should explain unsupported teleports and remain playable locally.
17. Real mobile and controller hardware: hold-to-scrub + camera movement; menu access; navigation scrolling; vehicle inputs; respawn; opening Roblox's system menu. No action should remain held after focus loss.

## Abuse checks in an owned test session

Use the client Command Bar to call `Remotes.Scrub` with a string, NaN/infinite vector, distant target, blocked target and unequipped tool; none should grant invalid dust or error. Flood actions and confirm catalog prices, range checks and rate limits remain authoritative. Try negative/NaN/table item indices, nonexistent item names, unaffordable purchases, repeated claims, empty sales and drive inputs from a non-driver. Legitimate requests that pass all checks may award bounded normal gameplay rewards; no client-provided price, amount or rarity is accepted.

## Known release limits

The cloud cannot complete this matrix. No claim of Roblox runtime readiness is made by a successful build. Art is procedural; the final starship is a ground sweeper, the leaderboard is server-local, achievements are career UI milestones, and paid products/global boards/direct-invite APIs are not configured. Treat this build as an alpha requiring the acceptance tests before public release.
