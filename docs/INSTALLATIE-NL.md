# Installatie — Moon Scrubbers speelbare alpha 0.2

## Downloaden en openen op Windows

1. Download `MoonScrubbers-installatie.zip` uit de map `build` op GitHub. Open de bestandsweergave en gebruik **Download raw file** (het downloadpictogram).
2. Ga in Windows Verkenner naar Downloads, rechtsklik op de ZIP en kies **Alles uitpakken**. Kies bijvoorbeeld `Documenten\MoonScrubbers`.
3. Start Roblox Studio en meld je aan. Kies **File → Open from File** en open het uitgepakte `MoonScrubbers.rbxlx`.
4. De scripts zitten al in het placebestand. Je hoeft ze niet over te nemen. De basis en wereld worden tijdens Play gemaakt; een leeg werkgebied vóór Play is normaal.
5. Druk **F5 / Play**, niet alleen Run. Wacht tot je profiel en het startmenu geladen zijn. Open **Output** voor eventuele fouten.

## Je eerste verkoop en upgrade

1. Klik **START MY SHIFT**, of claim eerst de gratis **DAILY DELIVERY**.
2. Kies onderaan **ZONES → Dusty Plains → TRAVEL**.
3. Kies **BRUSH** of rust het gereedschap uit via je backpack. Kijk omlaag en houd de linkermuisknop ingedrukt terwijl je het richtpunt over het stof beweegt. Gamepad: R2 + rechterstick. Touch: POETS vasthouden en met een andere vinger richten.
4. Een volle tank is geen dood einde meer: klik **HOME**. Je komt bij je eigen maanbasis aan.
5. Loop op het gouden **SHIP DUST**-platform, gebruik de prompt, of klik dichtbij het platform op **SELL**. De capsule vliegt weg en je krijgt credits.
6. Open **SHOP** bij je basis. Koop een beter gereedschap, pak of tank. De upgrade wordt direct toegepast.
7. **BASE** verbetert je gebouwen, **ZONES** ontsluit waardevoller stof, **ROBOTS** automatiseert werk en **VEHICLES** opent de garage.
8. Druk **M** (gamepad **Y**) om een menu te openen terwijl je poetst; **H** brengt je thuis. De onderste balk is horizontaal scrollbaar op kleine schermen. Een geopend menu onderbreekt poetsen en laat je de cursor vrij bewegen.

## Voertuigen, robots en langere voortgang

- Koop een voertuig en kies **DEPLOY** terwijl je thuis bent. Bestuur met WASD, controllerstick of de standaard Roblox-touchbediening. Spring om uit te stappen. Rijd naar je gouden depot om de voertuigtank te legen.
- Robots koop je met credits. Hogere robottypes vereisen een betere radiotoren. Kies hun werkzone in het Robots-menu. Ze verwerken echt gedeeld stof en betalen automatisch uit.
- Dagelijkse/wekelijkse missies, loginbeloningen en elke 500 verzamelde stof leveren capsules op. Capsules zijn cosmetisch; duplicaten worden fragmenten.
- Prestige reset je bedrijf in ruil voor permanente verdiensten. Daarvoor is een apart bevestigingsscherm; cosmetica blijven behouden.

## Opslaan testen

Een ongepubliceerde Studio-test werkt ook zonder DataStore. In dat geval meldt de HUD **STUDIO: session only**: de voortgang blijft dan alleen in die testsessie bestaan.

Voor echte opslagtests: publiceer een **aparte test-experience**, schakel Studio-toegang tot API-services in via de beveiligingsinstellingen en test uitloggen/opnieuw verbinden met dezelfde experience. Gebruik geen productiespel voor experimentele save-tests. Op gepubliceerde live servers wordt laden geweigerd als bestaande gegevens niet veilig kunnen worden geladen.

Stop Play voordat je het placebestand bewaart. Bewaar een eigen `.rbxl`- of `.rbxlx`-kopie met **Save to File**. Servergegevens staan in DataStore en worden niet in een lokaal placebestand meegenomen.

## Solo en Friends

Public werkt direct in de huidige sessie. Solo en Friends gebruiken gereserveerde servers en hebben een gepubliceerde experience nodig; normale Studio-teleports worden niet ondersteund. Stel in Roblox het maximumspelersaantal op **4** in.

Maak een Friends-room in **CREW**, noteer de code die acht seconden verschijnt en deel deze met je vrienden. Zij voeren de code in bij Join. Codes verlopen na 24 uur. De geheime reserved-servercode blijft op de server.

## Broncode en beperkingen

`src` bevat alle scripts; `default.project.json` bevat de Rojo-mapping. Losse bronbestanden veranderen het al geopende placebestand pas na synchronisatie via Rojo of handmatig overnemen. `docs/STUDIO.md` bevat de testmatrix en scriptlocaties.

De alpha bevat de volledige basislus en meerdere voortgangssystemen. De cloud heeft geen Roblox-engine; visuele werking, voertuighandling, touch/gamepad, echte DataStore en teleports moeten nog in Roblox worden gecontroleerd. De modellen zijn procedurele prototypekunst. Betaalde producten en premiumcapsules zijn niet ingeschakeld.
