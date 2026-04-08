# DnD Git Adventure

A text-based fantasy adventure in PowerShell where you play as Borzig, a barbarian who survives a dangerous tutorial expedition, reaches town, and begins uncovering a larger threat beneath the city.

---

## Current features

- DnD-inspired hero stats: `STR`, `DEX`, `CON`, `INT`, `WIS`, `CHA`
- barbarian progression with XP, level-up readiness, and long-rest leveling from level 1 to level 2
- turn-based combat with:
  - initiative rolls
  - critical hits and critical fails
  - weapon damage dice
  - armor class
  - `Block` and `Focus`
  - dropped-weapon recovery for the barbarian
- cave exploration with connected rooms, backtracking, room loot, and encounters
- tutorial boss warning flow with a Shadow Sanctum reward choice
- quest log with tutorial progression, XP tracking, and accepted town quests
- inventory with slot limits, equipping, consumables, and dropped loot persistence
- currency system with `CP`, `SP`, `GP` and a gold pouch
- weapon requirements with stat and handling restrictions such as `STR`, `DEX`, `One-Handed`, and `Two-Handed`
- town hub with:
  - first-night inn choice after the tutorial
  - guaranteed coin for the cheapest first-night room if Borzig reaches town broke
  - `work off the room` fallback when money runs short
  - locked inn booking until the player cancels it with the innkeeper
  - inn storage
  - inn-specific evening activities based on quality and clientele
  - street interactions
  - quest board
  - guard station
  - market
  - smithy
  - apothecary
  - fighting ring
  - small NPC rewards, information hooks, and discounts
- class-aware town NPC reactions that already distinguish the current barbarian from future hero archetypes
- fighting ring progression with:
  - unarmed combat with simultaneous round choices
  - `Punch`, `Grapple`, `Block`, and `Focus`
  - matchup-style ring rounds where both fighters commit before the exchange is resolved
  - distinct opponents with different styles such as pressure fighters, clinch hunters, defensive readers, and heavy hitters
  - once-per-day tournament access
  - long-term progress toward an unarmed fighting feature
- Chapter Two has started with the first playable city quest chain:
  - `Night Watch Relief`
  - story flags for the city mystery under the streets
  - quest rewards in XP, currency, and reputation

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

### Hidden test shortcut

At the campfire menu you can type:

`skip`

or:

`skiptutorial`

This hidden shortcut:

- completes the tutorial immediately
- delivers Borzig to the city
- applies the level 2 long-rest level up with fixed HP gain
- restores him to full HP
- always takes the reduced Shadow Sanctum gold reward path
- never grants the haste reward

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

- choose an inn for the first night in the city
- keep or cancel a room booking through the innkeeper
- stash gear in inn storage
- walk the streets
- talk to townsfolk
- receive small rewards
- unlock shop discounts
- accept town quests
- visit the fighting ring
- spend gold on weapons and potions
- sell gear to free up slots
- begin the Chapter Two city story through the first guard quest chain

### 3. Chapter Two opening

The first step of the post-tutorial story is now playable.

`Night Watch Relief` begins the investigation into suspicious movement and broken seals near the city tunnels. It introduces the first story flag toward the larger underground plot that will lead into the Chapter Two finale beneath the city.

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
- `city-quests.ps1`
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
- Chapter Two is now partially playable, but only its opening quest chain is implemented so far
- some systems are intentionally lightweight for now so they can be expanded later
- several town information hooks are already in place as setup for later quest branches, payout modifiers, and underground story paths

---

## Next possible steps

- continue the Chapter Two story arc with:
  - `Storehouse Trouble`
  - `Whispers Beneath the Bent Nail`
  - `Ledger of Ash`
  - `Broken Seal Patrol`
  - the final underground chapter quest beneath the city
- progression from level 2 to level 3 across the Chapter Two quest arc
- more city districts and stronger NPC quest lines
- additional caves or wilderness zones after the city-understreet arc
- short rests and secured rooms
- more shop inventory, armor progression, and trader variety
- more classes and class-specific dialogue, gear use, and social reactions
- class features beyond level 2
- deeper inn events, shady city routes, and economic info payoffs
- resistances, elemental effects, and broader enemy mechanics
- optional audio cues and simple visual scene flourishes such as ASCII art or external image moments
- save/load support
