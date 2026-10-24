# Plaatsing en testen — stap 2

## Handmatige plaatsing zonder Rojo

Maak mappen aan met exact onderstaande namen. De inhoud van elk bestand hoort in het aangegeven script. De suffix `.lua` hoort niet bij de naam in Explorer.

| Bestand | Pad in Studio | Type |
| --- | --- | --- |
| `src/shared/Config.lua` | ReplicatedStorage/MoonScrubbers/Shared/Config | ModuleScript |
| `src/shared/Grid.lua` | ReplicatedStorage/MoonScrubbers/Shared/Grid | ModuleScript |
| `src/server/Bootstrap.server.lua` | ServerScriptService/MoonScrubbers/Bootstrap | Script |
| `src/server/Services/PlayerStateService.lua` | ServerScriptService/MoonScrubbers/Services/PlayerStateService | ModuleScript |
| `src/server/Services/CleaningService.lua` | ServerScriptService/MoonScrubbers/Services/CleaningService | ModuleScript |
| `src/client/Bootstrap.client.lua` | StarterPlayer/StarterPlayerScripts/MoonScrubbers/Bootstrap | LocalScript |
| `src/client/Controllers/InputController.lua` | StarterPlayer/StarterPlayerScripts/MoonScrubbers/Controllers/InputController | ModuleScript |
| `src/client/Controllers/ViewmodelController.lua` | StarterPlayer/StarterPlayerScripts/MoonScrubbers/Controllers/ViewmodelController | ModuleScript |
| `src/client/Controllers/CleaningController.lua` | StarterPlayer/StarterPlayerScripts/MoonScrubbers/Controllers/CleaningController | ModuleScript |
| `src/client/Controllers/UIController.lua` | StarterPlayer/StarterPlayerScripts/MoonScrubbers/Controllers/UIController | ModuleScript |
| `src/client/Controllers/EffectsController.lua` | StarterPlayer/StarterPlayerScripts/MoonScrubbers/Controllers/EffectsController | ModuleScript |

`Bootstrap` maakt de RemoteEvents, RemoteFunction en testgrond automatisch op de server. De client maakt de HUD en lokale viewmodel aan. Maak deze niet dubbel aan. Gebruik voor dit prototype een lege place en verwijder de standaard Baseplate en SpawnLocation. Publiceren, DataStore-toegang en betaalde assets zijn niet nodig voor deze stap. Stel voor latere gepubliceerde Moon-sessies het maximumspelersaantal in de Roblox-place-instellingen op 4; de configuratiewaarde alleen begrenst Roblox-servers niet.

## Handmatige functionele testmatrix

Deze tests moeten nog in Roblox Studio worden uitgevoerd:

1. **Start:** Play. Geen fouten in Output; HUD, stofgrond en tandenborstel zichtbaar. Begin niet boven een bestaande baseplate. Kijk omlaag tot het middelpunt de grond binnen 10 studs raakt.
2. **Fysiek poetsen:** houd de actie vast en beweeg de camera rustig links/rechts. De borstel beweegt, stofvlakken vervagen, de blauwe/grijze grond verschijnt, stofdeeltjes vliegen richting rugtank en de tankwaarde stijgt. Het schone vlak moet onder het richtpunt verschijnen, ook in alle vier kwadranten van de zone.
3. **Stilhouden en bereik:** houd vast zonder te bewegen; de teller mag niet blijven stijgen. Kijk naar de lucht, richt buiten de zone of op grond verder dan 10 studs; geen opbrengst. Een afgeschermd oppervlak achter een extra muur mag geen opbrengst geven.
4. **Tank en uitrusting:** vul tot exact 50; verdere beweging levert niets op en de HUD meldt vol. Maak voor inspectie in de serverweergave de rugtank zichtbaar: de meter moet dezelfde verhouding tonen. Berg de tool op; camera en poetsknop herstellen en poetsen stopt. Rust opnieuw uit en test opnieuw.
5. **Levenscyclus:** reset het personage. De tankinhoud blijft binnen deze sessie bestaan, er verschijnt één nieuwe tool en de bediening herstelt. Open het Roblox-menu of wissel venster tijdens poetsen: na terugkeer mag de actie niet vast blijven hangen.
6. **Multiplayer:** start Server & Clients met 2 spelers. Poets dezelfde cel tegelijk: gedeelde grond blijft consistent en maximaal 4 stof wordt uit die cel toegekend. Laat een tweede client later binnenkomen: deze moet direct de reeds schoongemaakte grond zien. Bekijk de tank van de andere speler.
7. **Apparaten:** gebruik de Device Emulator in telefoon- en tabletformaat. Houd POETS vast en beweeg met de andere vinger de camera. HUD en touchknop moeten leesbaar blijven. Test met gamepad R2 + rechterstick; opbergen/uitrusten blijft via de standaard Roblox-inventory mogelijk.
8. **Geluid (indien ingesteld):** zet een geautoriseerde audio-ID in Config. Geluid speelt tijdens daadwerkelijke verzameling en stopt bij loslaten, volle tank of geen nieuwe opbrengst. Check Output op assettoegangsproblemen.

## Remotevalidatie testen

Voer uitsluitend in een eigen Studio-testsessie deze code uit in de **client** Command Bar:

```lua
local remote = game.ReplicatedStorage.MoonScrubbers.Remotes.Scrub
remote:FireServer("invalid")
remote:FireServer(Vector3.new(0/0, 0, 0))
remote:FireServer(Vector3.new(100000, 0, 100000))
for _ = 1, 100 do remote:FireServer(Vector3.new(0, 0, 0)) end
```

Verwacht: geen serverfouten, geen tankoverflow en geen extra stof uit deze ongeldige/stilstaande verzoeken. Probeer daarna met opgeborgen tool een geldig ogend grondpunt te sturen: ook dat mag niets opleveren. Deze validatie voorkomt dat een client zelf bedragen of opbrengsten dicteert; geautomatiseerde beweging van een kwaadaardige client is hiermee niet volledig detecteerbaar.

## Architectuur en vervolg

`PlayerStateService` beheert tijdelijke tankattributen en de fysieke rugtank. `CleaningService` bezit het raster en valideert afstand, zichtlijn, tool, spelerleven, frequentie, eindige coördinaten en beweging. Geen handler yieldt tussen het verlagen van stof en het verhogen van de tank. Versienummers beschermen de eerste snapshot tegen oudere netwerkupdates. Alleen veranderingen worden gebundeld uitgezonden.

De client berekent het richtpunt en tekent effecten. Input, UI, viewmodel en cleaning zijn losse controllers. Stap 3 kan beweging en zwaartekracht toevoegen; stap 4 krijgt een serverfunctie om de tank bij een depot te legen. Opslag wordt pas in stap 7 toegevoegd. Er worden nu geen productiespelgegevens geschreven.
