# Moon Scrubbers installeren in Roblox Studio

Dit pakket bevat alle huidige voortgang tot en met ontwikkelstap 2. Je kunt het meegeleverde placebestand direct openen; programmeren, Rojo installeren en scripts overnemen zijn daarvoor niet nodig.

## 1. ZIP uitpakken op Windows

1. Download `MoonScrubbers-installatie.zip` naar je computer.
2. Open Windows Verkenner en ga naar Downloads.
3. Klik met de rechtermuisknop op de ZIP en kies **Alles uitpakken**.
4. Kies bijvoorbeeld `Documenten\MoonScrubbers` en klik op **Uitpakken**.
5. Werk vanuit de uitgepakte map, niet vanuit het ZIP-venster.

## 2. Het spel openen

1. Installeer Roblox Studio via de officiële Roblox-website als dit nog niet is geïnstalleerd.
2. Start Roblox Studio en meld je aan met je Roblox-account.
3. Kies **File / Bestand → Open from File / Openen vanuit bestand** (de benaming kan per Studio-versie verschillen).
4. Selecteer `MoonScrubbers.rbxlx` in de uitgepakte map.
5. Open zo nodig **Explorer**, **Properties** en **Output** via de Studio-menu's.
6. De scripts staan al op de juiste plek. Plak ze niet opnieuw in het placebestand.

Het testveld en de spawn worden pas tijdens Play door het serverscript aangemaakt. Een leeg werkgebied vóór het starten is dus normaal. Voeg geen overlappende Baseplate of extra SpawnLocation toe.

## 3. Het prototype spelen

1. Klik op **Play** of druk op **F5**; gebruik Play met een personage, niet alleen Run.
2. De `LSD Toothbrush` wordt automatisch uitgerust en de camera gaat naar first-person.
3. Kijk omlaag tot het richtpunt op de grond vlak bij je voeten staat.
4. Houd de linkermuisknop vast en beweeg de camera rustig heen en weer over het stof. Met een controller gebruik je R2 en de rechterstick. Op mobiel houd je POETS vast en richt je met je andere vinger.
5. Het stof moet vervagen, de schone grond wordt zichtbaar en de stofteller loopt op. Alleen vasthouden zonder het richtpunt te verplaatsen levert geen blijvende opbrengst op.
6. De tank is vol bij 50. Verkopen wordt pas in stap 4 toegevoegd. Klik op **Stop** en daarna opnieuw op **Play** om de testsessie met lege tank te herstarten.
7. Volg `docs/STUDIO.md` voor de volledige testmatrix, multiplayer en foutdiagnose.

## 4. Je werk bewaren

Stop de testsessie voordat je bewerkingen opslaat. Gebruik **Save to File / Opslaan naar bestand** of de equivalente optie in je Studio-versie en bewaar je eigen kopie als `.rbxl` of `.rbxlx`. Bewaar ook deze uitgepakte bronbestanden als back-up. Het pakket publiceert niets naar Roblox.

Wil je later publiceren, gebruik dan Studio's publicatieoptie en kies bewust een nieuwe experience of een bestaande test-place. Voor deze lokale test zijn publiceren, DataStore-API-toegang en betaalde assets niet nodig.

## 5. Broncode aanpassen (optioneel)

- De `src`-map bevat alle scripts. `docs/STUDIO.md` beschrijft hun exacte locaties en scriptsoorten in Studio.
- Je kunt de scripts rechtstreeks in Studio bewerken. Het veranderen van een `.lua`-bestand op je computer werkt niet automatisch door in het reeds geopende placebestand.
- Voor synchronisatie kun je Rojo 7 gebruiken: open een terminal in de uitgepakte hoofdmap, voer `rojo serve default.project.json` uit en verbind de officiële Rojo-plugin in Studio. Rojo en de plugin zijn niet meegeleverd.
- Een gewijzigd placebestand bouwen kan met `rojo build default.project.json -o MoonScrubbers-aangepast.rbxlx`. Gebruik een nieuwe bestandsnaam om je bestaande placebestand te behouden.

## Inhoud en beperkingen

Dit pakket bevat `MoonScrubbers.rbxlx`, de volledige mappen `src`, `docs` en `tests`, `default.project.json`, `README.md`, `.gitignore` en een SHA-256-bestandsmanifest.

De place en broncode bevatten first-person poetsen, gedeeld stofraster, servervalidatie en een stoftank. Maanzwaartekracht, verkopen, opslag en andere latere ontwikkelstappen zijn nog niet toegevoegd. Het poetsgeluid is standaard stil: stel een toegestane audio-asset in via `Config.Audio.BrushSoundId`. De cloudcontroles zijn beschreven in `docs/VALIDATION.md`; de Studio-runtime en apparaatbediening moeten nog door jou worden getest.

Het pad `/workspace/...` dat in de chat kan staan is een pad in de cloudomgeving, geen locatie op jouw Windows-computer. Na downloaden en uitpakken open je jouw eigen gekozen Windows-map via Verkenner.
