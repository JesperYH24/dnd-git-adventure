# Game and Town Flow

## Game Flow

```mermaid
flowchart TD
    Start["Start adventure.ps1"] --> Menu["Start menu"]
    Menu --> NewGame["New game"]
    Menu --> LoadGame["Load save"]
    NewGame --> ClassSelect["Choose class"]
    ClassSelect --> Init["Initialize-Game"]
    LoadGame --> MainLoop["Main loop"]
    Init --> MainLoop

    MainLoop --> TutorialGate{"Tutorial complete?"}
    TutorialGate -- "No" --> Campfire["Campfire / tutorial staging"]
    Campfire --> Cave["Tutorial cave exploration\nStart-CaveExploration"]
    Cave --> ExploreCore["Reusable room exploration loop\nStart-RoomExploration"]
    ExploreCore --> CaveCombat["Cave combat and encounters"]
    CaveCombat --> TutorialDone{"Warning delivered?"}
    TutorialDone -- "No" --> Campfire
    TutorialDone -- "Yes" --> Town["Town hub"]

    TutorialGate -- "Yes" --> Town
    Town --> TownChoice{"Player choice"}
    TownChoice --> Inns["Inns and room"]
    TownChoice --> Shops["Shops"]
    TownChoice --> Quests["Quest work"]
    TownChoice --> Ring["Fighting ring"]
    TownChoice --> Streets["NPCs and street scenes"]
    TownChoice --> Save["Save / load"]
    TownChoice --> Status["Hero / inventory / quest log"]
```

## Exploration Foundation

```mermaid
flowchart TD
    Zone["Zone wrapper\nTutorial cave today, future monster zones later"] --> Core["Start-RoomExploration"]
    Core --> Show["Show current room"]
    Show --> Encounter["Resolve zone encounter"]
    Encounter --> EncounterResult{"Encounter result"}
    EncounterResult -- "Defeated / victory / zone exit" --> Wrapper["Wrapper-specific outcome"]
    EncounterResult -- "Fled" --> Show
    EncounterResult -- "Proceed" --> Actions["Room actions"]
    Actions --> Move["Move through exits"]
    Actions --> Common["Common actions\ninventory, loot, status, text speed"]
    Actions --> Custom["Zone-specific actions\nleave cave now, future travel hooks later"]
    Move --> Show
```

## Town Hub

```mermaid
flowchart TD
    Town["Town menu\nHUD: hero, place, day/night, HP, AC, XP, coin, class resources"] --> Time{"Day or night?"}

    Time -- "Day" --> DayChoices["Day choices"]
    DayChoices --> DayJobs["Day jobs"]
    DayChoices --> Shops["Shops"]
    DayChoices --> Guard["Guard station"]
    DayChoices --> QuestLeads["Quest leads"]
    DayChoices --> Tourney["Fighter tourney ground\nfoot duels before level 4"]
    DayChoices --> Streets["Walk streets"]

    Time -- "Night" --> NightChoices["Night choices"]
    NightChoices --> Inns["Inns"]
    NightChoices --> Gambling["Gambling"]
    NightChoices --> DrinkingSongs["Drinking songs"]
    NightChoices --> BardShows["Bard performances"]
    NightChoices --> NightQuests["Night-focused quests"]

    Town --> Districts["Districts"]
    Districts --> DocksGate{"Docks unlocked?"}
    DocksGate -- "No" --> DocksLead["Linear Docks lead only"]
    DocksGate -- "Yes" --> Docks["Open Docks district"]
    Town --> KnightGate{"Fighter level 4\nfuture jousting ready?"}
    KnightGate -- "Needs stable horse + splint/plate + lance" --> FutureJoust["Mounted jousting\nfuture knight progression"]
```
