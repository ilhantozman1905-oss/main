# Moon Scrubbers — stap 2

Een Roblox/Luau-prototype van fysiek poetsen op de maan. Inbegrepen: first-person tandenborstel met handschoen, poetsanimatie, gedeeld stofraster, servervalidatie, stofdeeltjes richting rugtank, zichtbare rugtankmeter en HUD. Muis, touch en gamepad gebruiken dezelfde schoonmaakactie.

## Openen in Roblox Studio

Gebruik een **nieuwe lege test-place**. Verwijder de standaard Baseplate en SpawnLocation om overlappende grond en willekeurige spawnplaatsen te voorkomen. Importeer dit project via Rojo, of plaats de bestanden handmatig volgens [de Studio-handleiding](docs/STUDIO.md).

Met Rojo 7: voer vanuit deze repository `rojo serve default.project.json` uit en verbind de Rojo-plugin in Studio. `rojo build default.project.json -o /tmp/moon-scrubbers.rbxlx` maakt een place-bestand zonder Studio. Rojo moet afzonderlijk geïnstalleerd zijn; de cloudcontrole installeert geen Studio.

Druk op Play. De tandenborstel wordt automatisch uitgerust. Kijk naar de grond, houd de linkermuisknop, R2 of de mobiele POETS-knop vast en beweeg het richtpunt heen en weer. Alleen echte verplaatsing over bereikbaar stof levert stof op. Leeggepoetste cellen tonen de schone ondergrond.

## Afbakening

Dit is uitsluitend stap 2. Zwaartekracht, verkoop, geld, upgrades, lobby's, opslag, robots, voertuigen en capsules volgen na afzonderlijke goedkeuring. Stof en tanks bestaan alleen tijdens de serversessie. Een volle tank blijft vol; stop/start de testsessie om opnieuw te testen. De gridweergave vervaagt hele cellen; een doorlopende geschilderde texture-mask is een latere visuele verfijning. Het gereedschap en de handschoen zijn procedurele prototypevormen, geen definitieve assets.

Poetsgeluid is voorbereid, maar standaard stil: zet een toegestane audio-asset-ID (`rbxassetid://...`) in `Config.Audio.BrushSoundId`. Er is geen audio-asset meegeleverd. Stofdeeltjes gebruiken de ingebouwde Roblox-smoketextuur.

## Balans

Het veld is 64 × 64 studs met 256 logische cellen, één grond-Part en maximaal 256 lokale UI-vlakken. Per cel is er 4 stof, totaal 1024. De tank bevat 50; het maximum is 6 stof/seconde tijdens geldige beweging, dus theoretisch circa 8,3 seconden om te vullen. Dit is bewust snel voor deze functietest. Voor de eerder voorgestelde 45–60 seconden zet je `DustPerSecond` op 1. Bereik: 10 studs; borstelstraal: 1,6 studs; maximaal 10 verzoeken/seconde; gebundelde wijzigingen elke 0,15 seconde.

De logische brush-footprint bepaalt welke cellen vervagen. De viewmodel-animatie is cosmetisch en bepaalt nooit de serveropbrengst. Samenwerkende spelers delen resterend stof; er is nog geen teamworkbonus. Deze kleine zone gebruikt een eenvoudige scan van 256 cellen per geldige actie; grotere zones moeten cellen binnen de brush-bounds direct indexeren en alleen nabijgelegen zones repliceren.

## Controles

`tests/grid.spec.lua` test de werkelijke gedeelde rasterlogica met Lua 5.3+ of Fengari, vanuit de repositoryroot. De Studio-testmatrix, inclusief misbruiktests en multiplayer, staat in [docs/STUDIO.md](docs/STUDIO.md). Syntax- en rastertests vervangen geen Roblox-runtimecontrole. De cloudomgeving beschikt niet over Roblox Studio.
