# Cloudvalidatie stap 2

Uitgevoerd op de huidige bronbestanden:

- 8 rastertests geslaagd met Fengari (Lua 5.3): grenzen, borsteloverlap, tanklimiet, lege capaciteit, gedeeld stof, fractionele deltas, ongeldige getallen en behoud van totale stofhoeveelheid.
- Alle 12 Lua-bronbestanden (inclusief testbestand) geparseerd met luaparse 0.3.1 in Lua 5.3-modus. Dit is syntaxvalidatie, geen Luau-typecheck of Roblox-API-controle.
- Rojo 7.6.1 heeft `default.project.json` succesvol gebouwd naar `build/MoonScrubbers.rbxlx`.
- Het gegenereerde XML-bestand bevat de verwachte 1 server-Script, 1 LocalScript en 9 ModuleScripts.

Niet uitgevoerd: Roblox Studio-runtime, multiplayer, audio, touch- en gamepadtests. Roblox Studio is niet aanwezig in deze cloudomgeving. Voer daarvoor de matrix in `STUDIO.md` uit. Het gegenereerde placebestand is een lokale, genegeerde buildoutput; broncode en Rojo-project zijn de reproduceerbare invoer. Er is niets naar Roblox gepubliceerd.

Gebruikte externe controletools staan buiten de repository. Reproduceren met geïnstalleerde Node.js/npm en Rojo 7.6.1:

```sh
npm install --prefix /tmp/moon-scrubbers-checks --cache /tmp/moon-scrubbers-npm-cache --no-audit --no-fund --ignore-scripts luaparse@0.3.1 fengari-node-cli@0.1.0
/tmp/moon-scrubbers-checks/node_modules/.bin/fengari tests/grid.spec.lua
rojo build default.project.json -o /tmp/moon-scrubbers.rbxlx
```
