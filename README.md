# DnD Git Adventure

A text-based fantasy adventure in PowerShell where you choose a class, survive a dangerous tutorial expedition, reach town, and begin uncovering a larger threat beneath the city.

## Quick overview

The project currently includes:

- a playable tutorial cave
- a full town hub with day/night state
- `Barbarian`, `Bard`, and `Fighter` as playable starting classes
- Chapter Two story content through `The Understreet Complex`
- the Lady Veyra reveal and a linear Docks discovery chain
- an open Docks district with strong/weak multi-quest Docks tiers through `The Shell Charter`, `Counting House Pressure`, `The Customs Stamp`, and the dungeon-style `Civic Vault` climax
- a Chapter Three cliffhanger where Lord Varric Halewick is publicly exposed, reveals a smaller draconic form, and escapes the Civic Keep
- level 4 Ability Score Increase support with derived-stat scaling for combat, HP, AC, skills, and Bard resources
- full DnD 5e skill list support with skill-to-ability mapping, class starting skill proficiencies, Jack of All Trades, and Expertise
- a Hero & Records skill tree submenu that shows every skill with proficiency and expertise markers
- Bard spellcasting with level-gated known spells and slots, including free `Vicious Mockery`, combat spells like `Healing Word`, `Dissonant Whispers`, and `Faerie Fire` with 60 ft monster-zone spell range, social quest spells like `Charm Person` and first-pass `Suggestion`, plus level 2 utility tools like level 3 `Invisibility` and level 4 `Enhance Ability`
- expanded town HUD status lines that surface HP, AC, XP or level-up readiness, coin, daily story/work availability, and class resources without opening the full status submenu
- Fighter tourney ground foot duels with coin purses, open guest-list sparring/duels for Bard and Barbarian, plus first-pass mounted jousting at level 4 once Lubert has a riding horse and splint or plate armor
- first-pass monster zone beyond the outer wall built to carry progression from level 4 toward level 6, with visible objectives, tracked landmarks that become easier to find across different visit days and eventually unlock direct travel from the gate, milestone XP for discoveries/proof/reports/contracts, level-cap-filtered threat escalation, a scripted level 6 gate-defense event with city allies and wave pressure, Perception/Stealth awareness checks, abstract encounter distance, camp safety, pack-animal monster oddity hauling, Wall Watch/Guard Station reactions, and Barbarian defeated-creature reports that let Dorr book delayed captured-monster ring contracts
- repeatable level-based day jobs
- split visual docs for game flow, code structure, story progression, dungeon maps, combat, and leveling

## Start the game

### Easiest way

Double-click:

`Start DnD Adventure.cmd`

### PowerShell

From the project folder:

```powershell
.\adventure.ps1
```

If your execution policy blocks scripts:

```powershell
powershell -ExecutionPolicy Bypass -File .\adventure.ps1
```

## Main docs

- [Game Mechanics](docs/game-mechanics.md)
- [Class Level 1-4 Progression](docs/class-level-1-4-progression.md)
- [Story and Progression](docs/story-and-progression.md)
- [Code Structure](docs/code-structure.md)
- [Visualizations](docs/visualizations.md)
- [Future Ideas](docs/future-ideas.md)

The class progression doc tracks the current level cap, including class kits, Bard spell slots, level-gated utility spells, and the next non-Bard priorities.

## Current next-work direction

The Bard spell pass is in a good stopping place, and ranged weapons are intentionally on ice for now. The monster zone now has a first level 4-to-6 progression spine, so the strongest next focus is making that arc richer: deepen objective follow-ups, connect Wall Watch reports and Docks buyers more directly to oddities/proof, add more level 5-6-worthy threats, and expand class-flavored wilderness reads into more encounters. After that, Fighter level 4 mounted jousting is the next large class identity system.

## Hidden test shortcut

At the campfire menu you can type:

`skip`

or:

`skiptutorial`

This shortcut:

- completes the tutorial immediately
- delivers the current hero to the city
- applies the level 2 long-rest level up with fixed HP gain
- restores the hero to full HP
- uses the same capped Shadow Sanctum d20 gold table as the normal tutorial flow

## Testing

The project includes focused PowerShell test scripts in:

`tests\`

Examples:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\city-quests.tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\day-job-progression.tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\town-inn.tests.ps1
```

## Project layout

Core scripts include:

- `adventure.ps1`
- `character.ps1`
- `combat.ps1`
- `city-quests.ps1`
- `quests.ps1`
- `town.ps1`
- `town-inns.ps1`
- `town-shops.ps1`
- `town-ring.ps1`
- `town-jousting.ps1`
- `monster-zone.ps1`
- `town-npcs.ps1`
- `ui.ps1`

For a fuller breakdown, see [Code Structure](docs/code-structure.md).
