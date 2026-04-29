# Visualizations

Det har dokumentet ar en visuell karta over spelet och koden.

Tanken ar inte att ersatta de andra dokumenten. Det ska vara en snabb "se helheten"-vy innan man gar in i detaljerna.

---

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
    Campfire --> Cave["Tutorial cave exploration"]
    Cave --> CaveCombat["Cave combat and encounters"]
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

## Code Map

```mermaid
flowchart LR
    Adventure["adventure.ps1\nentry + main loop"] --> Setup["setup.ps1\nload scripts + game state"]
    Setup --> Character["character.ps1\nhero, class, XP, ASI, HP, AC"]
    Setup --> UI["ui.ps1\nterminal output + HUD"]
    Setup --> Save["save.ps1\nsave/load normalization"]
    Setup --> Town["town.ps1\ntown hub + navigation"]
    Setup --> Tutorial["phases.ps1 + exploration.ps1\ntutorial flow"]

    Tutorial --> Rooms["rooms.ps1\ncave room data"]
    Tutorial --> Encounters["encounters.ps1\ncave events"]
    Tutorial --> Combat["combat.ps1\nturns, crits, class actions"]

    Town --> Inns["town-inns.ps1\nrooms, rests, tavern flavor"]
    Town --> Shops["town-shops.ps1\nbuy/sell/storage"]
    Town --> Ring["town-ring.ps1\nbrawls and rivals"]
    Town --> NPCs["town-npcs.ps1\nstreet scenes and hooks"]
    Town --> QuestDefs["quests.ps1\nquest definitions + unlocks"]
    QuestDefs --> CityQuests["city-quests.ps1\nplayable story quests"]
    CityQuests --> Combat
    Combat --> Monsters["monsters.ps1\nmonster profiles"]
    Character --> Items["items.ps1 + inventory.ps1\ngear and equipment"]
```

## Town Hub

```mermaid
flowchart TD
    Town["Town menu\nHUD: hero, place, day/night, HP, coin"] --> Time{"Day or night?"}

    Time -- "Day" --> DayChoices["Day choices"]
    DayChoices --> DayJobs["Day jobs"]
    DayChoices --> Shops["Shops"]
    DayChoices --> Guard["Guard station"]
    DayChoices --> QuestLeads["Quest leads"]
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
```

## Story Progression

```mermaid
flowchart TD
    Tutorial["Tutorial cave\nLevel 1 to 2"] --> TownOpen["Town opens"]
    TownOpen --> ChapterTwo["Chapter Two city investigation"]

    ChapterTwo --> Level23["Level 2 to 3 quest chain\nshared Guard + Quest Giver investigation"]
    Level23 --> Understreet["The Understreet Complex\nLevel 3 gate + finale dungeon"]

    Understreet --> SilentKnife["The Silent Knife\nLady Veyra revealed"]
    SilentKnife --> DocksLinear["Linear Docks discovery\nAuntie Brindle + contract trail"]
    DocksLinear --> DocksOpen["Docks opens as visitable district"]

    DocksOpen --> DocksT1["Docks Tier 1\n2 strong or 3 total"]
    DocksT1 --> DocksT2["Docks Tier 2\n2 strong or 3 total"]
    DocksT2 --> CharterScribe["Docks Tier 3\nThe Charter Scribe"]
    CharterScribe --> Level4["Long rest to level 4\nAbility Score Increase"]
    Level4 --> DocksT4["Docks Tier 4\n2 strong or 3 total"]
    DocksT4 --> CivicVault["Docks Tier 5\nThe Civic Vault climax"]
```

## Level 2-3 City Quest Chain

```mermaid
flowchart TD
    TownOpen["Town opens after tutorial\nHero is level 2"] --> T1["Chapter Two Tier 1\nopening city clues"]

    T1 --> GuardNight["Guard Station\nNight Watch Relief"]
    T1 --> Storehouse["Quest Giver / clerk\nStorehouse Trouble"]
    T1 --> Herbs["Quest Board\nMissing Herb Satchel"]
    T1 --> LedgerAsh["Quest Giver / clerk\nLedger of Ash"]

    GuardNight --> T1Gate{"Tier 2 gate\nGuard Night Watch complete\nAND Storehouse Trouble complete"}
    Storehouse --> T1Gate
    Herbs --> T1Support["Optional support clue / XP"]
    LedgerAsh --> T1Support

    T1Gate --> T2["Chapter Two Tier 2\nfollow-up investigation"]
    T2 --> Courier["Guard Station\nNight Courier Intercept"]
    T2 --> BentNail["Bent Nail\nWhispers Beneath the Bent Nail"]
    T2 --> LedgerRecovery["Quest Giver / clerk\nWarehouse Ledger Recovery"]
    T2 --> BrokenSeal["Guard Station\nBroken Seal Patrol"]

    Courier --> T2Gate{"Tier 3 gate\n2 strong Tier 2 results\nOR 3 total Tier 2 completions"}
    BentNail --> T2Gate
    LedgerRecovery --> T2Gate
    BrokenSeal --> T2Gate

    T2Gate --> T3["Chapter Two Tier 3\nunderstreet access proof"]
    T3 --> AccessProof["Confirm route, broker, and ledger evidence"]
    AccessProof --> T3Gate{"Finale gate\n1 strong Tier 3 result\nOR 2 total Tier 3 completions"}

    T3Gate --> Level3["Long rest to level 3"]
    Level3 --> Understreet["The Understreet Complex\nChapter Two dungeon finale"]
```

## Level 2-3 Lead Sources

```mermaid
flowchart LR
    Hero["Hero as bridge"] --> Guard["Guard Station\npatrols, courier movement,\nbreaches, tunnel access"]
    Hero --> Clerk["Quest Giver / clerk\nledgers, missing stock,\nhush money, merchant pressure"]
    Hero --> BentNail["Bent Nail\ncriminal whispers,\nroute names, broker lead"]
    Hero --> Board["Quest Board\npublic side clues and local needs"]

    Guard --> SharedCase["Shared city case\nprove the hidden understreet network"]
    Clerk --> SharedCase
    BentNail --> SharedCase
    Board --> SharedCase
    SharedCase --> Understreet["Understreet Complex"]
```

## Docks Quest Tiers

```mermaid
flowchart TD
    Lead["Lady Veyra / Mira Kest leads"] --> T1["Tier 1: contract origin"]
    T1 --> BlackContract["Black Contract on the Tide\nStrong clue path"]
    T1 --> SalvageWitness["Salvage Witness\nAuntie Brindle evidence"]
    T1 --> TideMarks["Tide-Ledger Marks\nPaper trail support"]
    BlackContract --> DocksOpen["Open Docks district"]
    SalvageWitness --> T1Gate{"Tier 1 gate\n2 strong or 3 total"}
    TideMarks --> T1Gate
    BlackContract --> T1Gate

    T1Gate --> T2["Tier 2: what the organization does"]
    T2 --> BrokerWake["The Broker's Wake"]
    T2 --> DebtHooks["Debt Hooks on Warehouse Row"]
    T2 --> BlackmailBook["The Blackmail Book"]
    BrokerWake --> T2Gate{"Tier 2 gate\n2 strong or 3 total"}
    DebtHooks --> T2Gate
    BlackmailBook --> T2Gate

    T2Gate --> T3["Tier 3: clean paper"]
    T3 --> CharterScribe["The Charter Scribe\nraises level cap to 4"]
    CharterScribe --> ASI["Level 4 long rest\nASI"]

    ASI --> T4["Tier 4: higher city hands"]
    T4 --> ShellCharter["The Shell Charter"]
    T4 --> CountingHouse["Counting House Pressure"]
    T4 --> CustomsStamp["The Customs Stamp"]
    ShellCharter --> T4Gate{"Tier 4 gate\n2 strong or 3 total"}
    CountingHouse --> T4Gate
    CustomsStamp --> T4Gate

    T4Gate --> T5["Tier 5: climax"]
    T5 --> CivicVault["The Civic Vault\nLord Varric Halewick"]
```

## Combat Turn

```mermaid
flowchart TD
    StartCombat["Combat starts"] --> Initiative["Roll initiative\nDEX modifier applies"]
    Initiative --> HeroTurn{"Hero acts first?"}
    HeroTurn -- "No" --> MonsterTurn["Monster turn"]
    MonsterTurn --> HeroRound["Hero round"]
    HeroTurn -- "Yes" --> HeroRound

    HeroRound --> ActionChoice["Choose action"]
    HeroRound --> BonusChoice["Choose bonus action"]
    ActionChoice --> ActionResult{"Nat 1?"}
    BonusChoice --> BonusResult{"Nat 1?"}

    ActionResult -- "Yes" --> CritFail["Hero takes mishap damage\nremaining hero turn ends"]
    BonusResult -- "Yes" --> CritFail
    ActionResult -- "No" --> ContinueTurn{"Action/bonus left?"}
    BonusResult -- "No" --> ContinueTurn
    ContinueTurn -- "Yes" --> HeroRound
    ContinueTurn -- "No" --> MonsterTurn

    MonsterTurn --> CombatEnd{"Fight over?"}
    CritFail --> MonsterTurn
    CombatEnd -- "No" --> HeroRound
    CombatEnd -- "Yes" --> Rewards["Rewards / quest outcome"]
```

## Level 4 Ability Score Increase

```mermaid
flowchart LR
    Level4["Reach level 4"] --> ASIChoice{"Choose ASI"}
    ASIChoice --> PlusTwo["+2 one ability\ncap 20"]
    ASIChoice --> Split["+1/+1 two abilities\ncap 20"]

    PlusTwo --> Derived["Derived stats refresh"]
    Split --> Derived

    Derived --> STR["STR\nSTR weapon hit + damage"]
    Derived --> DEX["DEX\nAC, initiative, DEX weapon hit + damage"]
    Derived --> CON["CON\nretroactive max HP + Unarmored Defense"]
    Derived --> INT["INT\nInvestigation-style checks"]
    Derived --> WIS["WIS\nfuture Wisdom checks"]
    Derived --> CHA["CHA\nBard save DC, CHA skills, Bardic Inspiration"]
```

---

## How To Use This

- Use `Game Flow` when debugging where the player should go next.
- Use `Code Map` when deciding which file to edit.
- Use `Town Hub` when polishing menus or day/night behavior.
- Use `Story Progression`, `Level 2-3 City Quest Chain`, and `Docks Quest Tiers` when adding quests.
- Use `Combat Turn` when changing action economy, crit fail, or class features.
- Use `Level 4 Ability Score Increase` when adding more derived stats or new classes.
