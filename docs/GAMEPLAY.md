# Gameplay, ownership and initial balance

Each player owns a base and economy. Dust is shared; server-side collection removes actual remaining dust before awarding it. Crew members within 25 studs grant +5% dust value each, capped at +15%. Events affect newly collected value, not already-stored dust. Different-zone values stay in the tank until sale.

## First session

Start at 0 credits, a 50-unit tank and 5 dust/second toothbrush. Two ordinary full shipments buy the 100-credit paintbrush. An optional daily claim grants 150 credits on day one and one extra capsule. Tank upgrades begin at 80 credits; reinforced suit is 600; first robot 900; first zone unlock 1,400 and suit level 2; first vehicle 2,500. Dust regenerates 100 seconds after its last collection, so early zones never permanently run out.

## Catalogues

All authoritative catalogue data is in `src/shared/Config.lua`.

- Tools: Toothbrush → Paintbrush → Hand Brush → Broom → Lunar Mop → Handheld Vacuum → Leaf Blower → Laser Vacuum.
- Suits: Budget EVA → Reinforced → LSD Professional → Quantum EVA. Capacity multipliers 1 / 1.5 / 2 / 3, faster movement and sale multipliers accompany visible tint changes.
- Tank: ten levels, capacity `floor(50 × 1.8^level × suit capacity)`, next price `floor(80 × 2.25^level)`.
- Zones: Dusty Plains / Impact Craters / Dark Side / Abandoned Outpost / Crystal Caverns. Values 1 / 3 / 7 / 15 / 35 credits per dust before bonuses. Golden rare cells are worth 8×.
- Robots: four tiers, 1.2 / 4 / 12 / 30 dust per second, eight units per owner. Offline work pays at 15% rate for at most three hours. Active robots deliver automatically on each work cycle.
- Vehicles: Cleaning Cart / Cleaning Tractor / Street Sweeper / Lunar Buggy / Heavy Scrubber / Cleaning Starship. Storage 200 / 500 / 1,200 / 2,200 / 5,000 / 10,000. All use ground-based lunar vehicle physics; the ship does not have free-flight controls.
- Buildings cap at five levels. Depot: +10% shipment value per level. Workshop: +8% manual speed. Garage: +4% driving speed. HQ: +5% earnings. Radio: robot tiers; level 2 enables remote shipping near zone beacons.

## Retention

Daily login: 100 + 50 × streak-day credits (streak bonus capped at 7) and one capsule, once per UTC day. Daily mission: collect 250 dust, claim 400 credits + one capsule. Weekly mission: 2,000 dust, 3,000 credits + three capsules. Every 500 career dust grants a capsule. Robot and vehicle collection count toward missions.

Capsules cost 350 earned credits, or are earned free. Cosmetic-only odds: Common 60%, Rare 25%, Epic 10%, Legendary 4%, Mythic 1%. After 19 consecutive commons, opening 20 uses Rare 62.5%, Epic 25%, Legendary 10%, Mythic 2.5%. Any Rare-or-better resets pity. One finish per rarity is collectible; duplicates yield tier × 10 fragments; 100 fragments craft a capsule.

Prestige requires 250,000 unspent credits. Cash, tanks, buildings, tools, suits, robots, vehicles and zone unlocks reset; each prestige adds +25% permanent earnings. Cosmetics, fragments and capsule inventory are retained. Confirmation is required in the UI. The current-server earnings board and career milestones are in-game systems, not published Roblox badges or a global leaderboard.

Every four minutes a 60-second meteor shower increases newly collected dust value to 1.5×. Radio messages respond to inactivity. All timing, purchases, rolls, selling and robot payouts run on the server.
