# DnD Git Adventure

A text-based fantasy adventure in PowerShell where you play as Borzig, a barbarian who survives a dangerous tutorial expedition, reaches town, and begins uncovering a larger threat beneath the city.

---

## Current features

- DnD-inspired hero stats: `STR`, `DEX`, `CON`, `INT`, `WIS`, `CHA`
- barbarian progression with XP, level-up readiness, and long-rest leveling from level 1 to level 3
- turn-based combat with:
  - initiative rolls
  - critical hits and critical fails
  - weapon damage dice
  - armor class
  - `Block` and `Focus`
  - dropped-weapon recovery for the barbarian
  - a cleaner battle-status layout with clearer separation between Borzig and the enemy
  - brutal barbarian crit-finish text on lethal takedowns
- cave exploration with connected rooms, backtracking, room loot, and encounters
- tutorial boss warning flow with a Shadow Sanctum reward choice
- quest log with tutorial progression, XP tracking, and accepted town quests
- inventory with:
  - `8` ready-use personal slots
  - a separate backpack storage layer
  - out-of-combat transfer between backpack and ready gear
  - combat-only access to what Borzig is carrying on his person
  - equipping, consumables, and dropped loot persistence
- currency system with `CP`, `SP`, `GP` and a gold pouch
- weapon requirements with stat and handling restrictions such as `STR`, `DEX`, `One-Handed`, and `Two-Handed`
- town hub with:
  - first-night inn choice after the tutorial
  - guaranteed coin for the cheapest first-night room if Borzig reaches town broke
  - `work off the room` fallback when money runs short
  - locked inn booking until the player cancels it with the innkeeper
  - inn-first navigation where the player enters the inn before choosing room or common-room activities
  - inn storage
  - inn-specific evening activities based on quality and clientele
  - street interactions
  - quest board
  - guard station
  - market
  - smithy
  - apothecary
  - a dedicated town buyer
  - fighting ring
  - small NPC rewards, information hooks, and discounts
  - deeper innkeeper and street-NPC conversations with repeat-aware dialogue
  - specialist selling prices depending on who Borzig sells to
  - comments and flavor around Borzig's worn starting gear and rough cave salvage
- class-aware town NPC reactions that already distinguish the current barbarian from future hero archetypes
- fighting ring progression with:
  - unarmed combat with simultaneous round choices
  - `Punch`, `Grapple`, `Block`, and `Focus`
  - matchup-style ring rounds where both fighters commit before the exchange is resolved
  - distinct opponents with different styles such as pressure fighters, clinch hunters, defensive readers, and heavy hitters
  - opponent rivalries that remember Borzig's record against specific fighters
  - rebalanced grapple pressure so takedowns disrupt the next exchange without deleting a full round
  - once-per-day tournament access
  - champion-tier and veteran-tier opponent pools
  - long-term progress toward stronger unarmed fighting features
- Chapter Two has a playable opening batch:
  - opening story quests:
    - `Night Watch Relief`
    - `Storehouse Trouble`
    - `Missing Herb Satchel`
    - `Ledger of Ash`
  - deeper follow-up quests:
    - `Broken Seal Patrol`
    - `Whispers Beneath the Bent Nail`
    - `Night Courier Intercept`
    - `Warehouse Ledger Recovery`
  - final story quest:
    - `The Understreet Complex`
  - day jobs:
    - `Missing Delivery`
    - `Gate Duty Overflow`
  - separate daily limits for:
    - `1 story quest per day`
    - `1 day job per day`
  - story flags for the city mystery under the streets
  - day jobs that pay coin but no XP
  - a playable finale in `The Understreet Complex`
  - a level 3 gate before the final assault begins
  - navigable finale rooms with a safe-room short-rest mechanic
- post-Chapter-Two city state with:
  - stronger NPC greetings and town tone once Borzig returns as a proven level 3 hero
  - improved shop inventory for a level 3 barbarian
  - tougher fighting ring progression after champion status
  - better-paying day jobs for a proven veteran without granting XP

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
- always takes the reduced Shadow Sanctum gold reward path of `2 GP`
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
- sell gear either to a dedicated town buyer or to specialists who value some item types more than others
- keep extra gear in the backpack, then move items onto Borzig's person before combat if they need to be used in battle
- begin the Chapter Two city story through the first guard quest chain

### 3. Chapter Two

The Chapter Two quest chain is now playable from its opening clues through the current final assault.

`Night Watch Relief`, `Storehouse Trouble`, `Missing Herb Satchel`, and `Ledger of Ash` form the opening layer of Chapter Two. Those clues can branch into `Broken Seal Patrol`, `Whispers Beneath the Bent Nail`, `Night Courier Intercept`, and `Warehouse Ledger Recovery`, and enough gathered evidence now unlocks `The Understreet Complex` as the Chapter Two finale beneath the city.

The final quest now plays as a focused mini-dungeon with connected rooms, a boss confrontation, and safe rooms that Borzig can secure for a short rest while pushing toward the end of the assault.

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

- the game is currently built around a tutorial arc, a full city hub, and a first complete Chapter Two story chain
- Chapter Two is now playable from its opening story layer through its finale, with multiple replay-friendly clue paths and first day jobs implemented
- some systems are intentionally lightweight for now so they can be expanded later
- several town information hooks are already in place as setup for later quest branches, payout modifiers, and post-Understreet story paths

---

## Next possible steps

### Near-term priorities

- continue the story after `The Understreet Complex` with the consequences of breaking the network beneath the city
- build the next post-Understreet story chain with enough structure and replay value to carry Borzig toward the next level breakpoints
- add a proper clue log or quest-notes system so gathered evidence can be reviewed in-character
- introduce a stronger day/night rhythm so inns, daily limits, ring access, and city activities feel tied to time passing
- expand the level 3 city state with more veteran dialogue, tougher ring tracks, and new equipment tiers
- let inn, street, and ring relationships feed more directly into future quest outcomes, payouts, and alternate leads

### Medium-term world and progression work

- keep day jobs non-lethal and expandable for future classes, so later heroes can solve them through charm, discipline, stealth, or negotiation instead of raw force
- add more day jobs that reinforce economy and city life without granting XP
- more city districts and stronger NPC quest lines
- additional caves or wilderness zones after the city-understreet arc
- more shop inventory, armor progression, and trader variety
- let the smithy offer branching weapon upgrades, such as a more accurate forged path versus a heavier, more brutal damage-focused path
- deeper inn events, shady city routes, and economic info payoffs

### Larger system expansions

- deepen `The Understreet Complex` with more room variety, routing choices, and encounter variety
- explore dual-wield as a later combat style once the broader city/day rhythm and clue systems are in place
- more classes and class-specific dialogue, gear use, and social reactions
- class features beyond level 3
- resistances, elemental effects, and broader enemy mechanics
- save/load support

### Optional presentation and polish

- optional audio cues and simple visual scene flourishes such as ASCII art or external image moments
