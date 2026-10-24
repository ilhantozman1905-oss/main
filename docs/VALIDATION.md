# Validation — alpha 0.2

Executed in the cloud on the packaged source:

- **8 grid tests:** cell bounds, brush overlap, conservation, capacity, fractional depletion, non-finite coordinates and shared depletion.
- **19 economy/progression tests:** complete collect/sell/buy shifts, empty sales, mixed backpack/vehicle values, costs and prerequisites, tank/suit scaling, building/robot caps, daily streaks, mission claiming, capsule probability boundaries, pity, duplicates, milestones, offline limits, prestige, profile normalization and credit-only access to all catalog tiers.
- **8 server integration tests:** the actual GameService action and CleaningService collection methods under minimal service adapters, covering payload rejection, location/rate checks, rare-value accounting, shared-cell conservation, locked zones, storage separation and meteor multipliers.
- **5 persistence tests:** the actual DataService against a mocked UpdateAsync store, covering exclusive leases, release/reload, fail-closed production loads, explicit Studio memory fallback and refusal to overwrite a lost lease.
- All Lua source/test files parsed with luaparse 0.3.1 (Lua 5.3 syntax). These sources use a Lua-compatible subset of Luau. This is not a Luau typecheck or Roblox API check.
- Rojo 7.6.1 builds the place. The packager checks embedded script text against every current source file, validates ZIP CRCs and byte-for-byte content, and supplies a SHA-256 manifest.

Total: **40 passing logic/integration/persistence tests**. Service adapters are not a Roblox engine. Not executed here: real Studio/client play, rendering/cell orientation, replication, physics, device input, audio loading, actual DataStore/MemoryStore or TeleportService. Run the complete matrix in `STUDIO.md` before public release.

Reproduce from the repository root with Node.js, Python 3 and Rojo 7.6.1:

```sh
npm install --prefix /tmp/moon-checks --cache /tmp/moon-npm-cache --no-audit --no-fund --ignore-scripts luaparse@0.3.1 fengari-node-cli@0.1.0
MOON_CHECK_TOOLS=/tmp/moon-checks/node_modules node tools/check.js
rojo build default.project.json -o /tmp/MoonScrubbers.rbxlx
python3 tools/package.py --place /tmp/MoonScrubbers.rbxlx
```

The previous step-2 version remains in Git history and replaced build artifacts are archived by the packager. No game progress has been deleted or reset in Roblox; this environment has not published a Roblox experience or written player DataStores.
