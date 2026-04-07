# DnD Git Adventure

A text-based fantasy adventure in PowerShell where you play as Borzig, a level 1 barbarian exploring a dangerous cave, surviving a tutorial quest, and returning to town to recover, shop, and prepare for what comes next.

---

## Current features

- DnD-inspired hero stats: `STR`, `DEX`, `CON`, `INT`, `WIS`, `CHA`
- level 1 barbarian start with XP, level-up readiness, and long-rest leveling
- turn-based combat with:
  - initiative rolls
  - critical hits and critical fails
  - weapon damage dice
  - armor class
  - dropped-weapon recovery for the barbarian
- cave exploration with connected rooms, backtracking, room loot, and encounters
- tutorial boss warning flow
- quest log with tutorial progression
- inventory with slot limits, equipping, consumables, and dropped loot persistence
- currency system with `CP`, `SP`, `GP` and a gold pouch
- town hub with:
  - street interactions
  - market
  - smithy
  - apothecary
  - small NPC rewards and discounts

---

## Start the game

### Easiest way

Double-click:

`Start DnD Adventure.cmd`

This launcher:

- opens the game with PowerShell automatically
- starts from the correct folder
- keeps the window open if an error appears

The project also includes a custom icon asset:

`dnd-adventure.ico`

You can use it for shortcuts or launcher customization.

### PowerShell

From the project folder:

```powershell
.\adventure.ps1
```

If your execution policy blocks scripts:

```powershell
powershell -ExecutionPolicy Bypass -File .\adventure.ps1
```

---

## Game flow

The current build is split into two major phases:

### 1. Tutorial cave

Borzig begins outside the cave at a campfire.

From there the player can:

- check inventory
- enter the cave
- head to town
- read the quest log

The city remains blocked until the tutorial quest is completed.

### 2. Town

After the warning is delivered, the game opens into a simple town hub where Borzig can:

- walk the streets
- talk to townsfolk
- receive small rewards
- unlock shop discounts
- spend gold on weapons and potions

---

## Core scripts

### Main flow

- `adventure.ps1`
- `setup.ps1`
- `phases.ps1`

### Combat and character systems

- `character.ps1`
- `combat.ps1`
- `monsters.ps1`
- `roll.ps1`
- `status.ps1`

### Exploration and world

- `exploration.ps1`
- `rooms.ps1`
- `encounters.ps1`
- `town.ps1`
- `quests.ps1`

### Items and inventory

- `items.ps1`
- `inventory.ps1`

### Presentation

- `ui.ps1`
- `dnd-adventure.ico`
- `Start DnD Adventure.cmd`

---

## Testing

The project includes focused PowerShell test scripts in:

`tests\`

Examples:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\town-shop.tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\currency-and-buff.tests.ps1
```

---

## Notes

- the game is currently built around a tutorial arc and a first town hub
- some systems are intentionally lightweight for now so they can be expanded later
- armor and utility progression will likely need another balance pass before larger content drops

---

## Next possible steps

- more city districts and NPC quest lines
- additional caves or wilderness zones
- short rests and secured rooms
- stronger town economy and more shop inventory
- class features beyond level 2
- save/load support
