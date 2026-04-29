# Code Structure

Det här dokumentet är tänkt att vara den enkla kartan till projektet.

Om du vill förstå spelet snabbt:

1. börja i `adventure.ps1`
2. titta sedan på `setup.ps1`
3. följ vidare till `exploration.ps1` och `town.ps1`
4. öppna sedan de specialiserade systemen som `combat.ps1`, `quests.ps1`, `city-quests.ps1`, och `town-inns.ps1`

---

## Den enkla bilden

Spelet är i grunden:

- en **game state**
- en **huvudloop**
- två stora spelområden:
  - tutorial/cave
  - town/city

Det mesta i koden går ut på att:

- läsa spelarens val
- uppdatera game state
- skriva ut ny text
- hoppa till rätt meny eller scen

---

## Om du bara ska läsa tre filer

### `adventure.ps1`

Det här är spelets huvudingång.

Den:

- startar nytt spel eller load
- skapar hjälten
- kör introt
- håller igång huvudloopen
- skickar spelaren till:
  - campfire / tutorial
  - cave exploration
  - town

Tänk:  
`adventure.ps1` = spelets "nu kör vi"-fil

### `setup.ps1`

Det här är spelets grundmontering.

Den:

- laddar in alla andra scripts
- bygger upp default-state för town
- skapar game state via `Initialize-Game`
- definierar dag/natt och dagräkning på en grundnivå

Tänk:  
`setup.ps1` = spelets "koppla ihop allt"-fil

### `town.ps1`

Det här är city-hubben.

Den:

- visar huvudmenyn i town
- styr submenyerna
- styr dag/natt-relaterad navigation
- skickar spelaren vidare till:
  - shops
  - work / quests
  - inn
  - hero / inventory / quest log
- öppnar Docks som vanlig stadsdel först efter den linjära Docks-kedjan

Tänk:  
`town.ps1` = spelets "trafikpolis i stan"

---

## Hur spelet faktiskt flyter

### 1. Start

Spelaren börjar i:

- `adventure.ps1`

Den använder:

- `Start-AdventureStartMenu`
- `Start-ClassSelection`
- `Initialize-Game`

Så fort game state finns, ligger nästan allt i en hashtable som innehåller:

- `Hero`
- `Quest`
- `Town`
- `Rooms`
- `CurrentRoomId`
- `HeroHP`

### 2. Tutorial / cave

Om huvudquesten inte är klar, går spelet mot tutorial-spåret.

Viktiga filer:

- `phases.ps1`
  - campfire, intro, tidiga menyer
- `exploration.ps1`
  - själva utforskandet av cave
- `rooms.ps1`
  - rummens data
- `encounters.ps1`
  - fight- och eventkopplingar i cave

Tänk:  
tutorialen är “rum + val + encounters”

### 3. Town

När tutorialen är klar går spelet till:

- `Start-TownMenu` i `town.ps1`

Härifrån fördelas spelaren vidare till city-systemen:

- `town-shops.ps1`
- `town-inns.ps1`
- `town-ring.ps1`
- `town-npcs.ps1`
- `quests.ps1`
- `city-quests.ps1`

Tänk:  
`town.ps1` väljer vart spelaren går, men de andra filerna gör själva jobbet

---

## Vilken fil gör vad?

## Kärnlogik

### `adventure.ps1`

Ansvar:

- start/load
- introstart
- huvudloop
- växling mellan tutorial och town

Bra att läsa när:

- du vill förstå spelets övergripande flöde

### `setup.ps1`

Ansvar:

- laddar alla `.ps1`-filer
- skapar default town state
- skapar game state

Bra att läsa när:

- du vill förstå vilka delar av spelet som finns
- du vill lägga till nya state-fält

### `ui.ps1`

Ansvar:

- allmän utskrift
- section titles
- typewriter-text
- town time tracker
- kompakt HUD för namn, HP och coin

Bra att läsa när:

- du vill ändra hur spelet ser ut i terminalen

### `status.ps1`

Ansvar:

- detaljerad hjältestatus
- combat status
- snapshots av hero state

Bra att läsa när:

- du vill ändra vad spelaren ser i `Status`

---

## Hjälte, items och inventory

### `character.ps1`

Ansvar:

- hjältestats
- klassval och klassresurser
- XP och leveling
- valuta
- AC, ability modifiers, class-specific status

Bra att läsa när:

- du vill ändra hur `Barbarian` eller `Bard` fungerar

### `items.ps1`

Ansvar:

- item-definitioner
- vapen
- armor
- consumables
- currency items

### `inventory.ps1`

Ansvar:

- inventory-menyer
- backpack / ready slots
- equipping
- använda items
- stash/storage-rörelser

---

## Combat

### `combat.ps1`

Ansvar:

- vanliga fights
- hero turns
- monster turns
- nat 1 / crit systems
- action + bonus action flow
- barbarian combat features
- bard combat features

Bra att läsa när:

- du vill ändra stridssystemet

### `monsters.ps1`

Ansvar:

- monsterdata och monsterprofiler

### `roll.ps1`

Ansvar:

- tärningsslag
- små hjälpmetoder för randomness

---

## Tutorial / cave

### `phases.ps1`

Ansvar:

- intro
- campfire
- startfasen innan cave/town öppnar upp fullt

### `exploration.ps1`

Ansvar:

- rörelse mellan rum
- exploration-loop
- room actions

### `rooms.ps1`

Ansvar:

- cave room-data
- exits
- room descriptions

### `encounters.ps1`

Ansvar:

- särskilda encounters i tutorial/cave

---

## Town-system

### `town.ps1`

Ansvar:

- huvudmeny i stan
- submenyer
- work hub
- quest preparation
- bard performance hub
- övergripande dag/natt-navigation

Bra att läsa när:

- du vill ändra hur staden känns att navigera

### `town-inns.ps1`

Ansvar:

- inn-val
- room booking
- inn room
- common room / dining room
- innkeeper
- inn events
- long rest

Bra att läsa när:

- du vill ändra vila, rum, eller tavern flavor

### `town-shops.ps1`

Ansvar:

- shopmenyer
- köp/sälj
- specialistpriser
- storage-menyer

### `town-ring.ps1`

Ansvar:

- fighting ring
- brawls
- ring progression
- rivalries och prispengar

### `town-npcs.ps1`

Ansvar:

- street scenes
- named NPC interactions
- små rewards, hooks och flavor

---

## Quests och story

### `quests.ps1`

Ansvar:

- quest-definitioner
- unlock logic
- tier logic
- day job progression
- quest log support

Tänk:  
`quests.ps1` beskriver **vad** som finns och **när** det låses upp

### `city-quests.ps1`

Ansvar:

- själva spelbara city quests
- storyscener
- questval
- story combat
- Understreet-finale
- `The Silent Knife`
- den linjära Docks-upptäckten
- Docks-quests som `Black Contract on the Tide`, `Tide-Ledger Marks`, `The Broker's Wake`, `The Blackmail Book`, `The Charter Scribe`, `The Shell Charter`, `Counting House Pressure`, och `The Customs Stamp`
- Docks-specifika quest tiers efter Chapter Two, med strong/weak progression och flera quests per tier
- level 4 story-readiness via Docks quest flags och XP, plus post-level-4 Docks Tier 4

Tänk:  
`city-quests.ps1` beskriver **hur questen spelas**

---

## Save / load

### `save.ps1`

Ansvar:

- save slots
- load logic
- save normalization för äldre saves

Bra att läsa när:

- du vill lägga till nya state-fält utan att gamla saves kraschar

---

## Hur state är organiserat

Det viktigaste att förstå är att mycket ligger i `$Game`.

Vanliga delar:

- `$Game.Hero`
- `$Game.Quest`
- `$Game.Town`
- `$Game.Rooms`
- `$Game.CurrentRoomId`
- `$Game.HeroHP`

Och i `Town` ligger mycket city-state, t.ex.:

- dagnummer
- dag/natt
- quest flags
- inn flags
- relationships
- active inn
- day job usage
- story quest usage

Så när du undrar “var sparas detta?”, är svaret ofta:

- i `$Game.Hero`
- eller i `$Game.Town`

---

## Bra tumregler när man jobbar i koden

- Vill du ändra **startflödet**: öppna `adventure.ps1`
- Vill du ändra **game state**: öppna `setup.ps1`
- Vill du ändra **UI/text-output**: öppna `ui.ps1`
- Vill du ändra **statusrutor**: öppna `status.ps1`
- Vill du ändra **combat**: öppna `combat.ps1`
- Vill du ändra **tutorial/cave**: öppna `exploration.ps1`, `rooms.ps1`, `encounters.ps1`
- Vill du ändra **town-navigation**: öppna `town.ps1`
- Vill du ändra **inns**: öppna `town-inns.ps1`
- Vill du ändra **shops**: öppna `town-shops.ps1`
- Vill du ändra **ring**: öppna `town-ring.ps1`
- Vill du ändra **NPC street content**: öppna `town-npcs.ps1`
- Vill du ändra **vilka quests som finns / låses upp**: öppna `quests.ps1`
- Vill du ändra **hur en quest spelas**: öppna `city-quests.ps1`
- Vill du ändra **save/load**: öppna `save.ps1`

---

## Om du är ny och vill börja säkert

Bästa första läsordning:

1. `adventure.ps1`
2. `setup.ps1`
3. `town.ps1`
4. `quests.ps1`
5. `city-quests.ps1`
6. `combat.ps1`

Det räcker för att förstå:

- hur spelet startar
- hur state byggs
- hur staden fungerar
- hur quests låses upp
- hur storyquests spelas
- hur combat fungerar

---

## Tests

Tester finns i:

`tests\`

Bra förstaval:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\city-quests.tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\town-inn.tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\town-menu.tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\ring.tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\save-load.tests.ps1
```

Om du ändrat något i town är `town-inn`, `town-menu`, `town-shop`, och `town-social` ofta bra att köra tidigt.
