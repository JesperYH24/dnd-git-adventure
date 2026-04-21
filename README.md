# DnD Git Adventure

A text-based fantasy adventure in PowerShell where you choose a class, survive a dangerous tutorial expedition, reach town, and begin uncovering a larger threat beneath the city.

---

## Current features

- DnD-inspired hero stats: `STR`, `DEX`, `CON`, `INT`, `WIS`, `CHA`
- playable class selection at the start of the adventure with:
  - `Barbarian` as `Borzig`
  - `Bard` as `Gariand`
- level-up readiness and long-rest leveling from level 1 to level 3
- local `save/load` support with:
  - a startup menu for `New adventure` or `Load adventure`
  - `3` manual save slots
  - save access from campfire, town, and inn flows
  - backward-safe save normalization for newer state fields
- turn-based combat with:
  - initiative rolls
  - true initiative order where the winner actually takes the first turn inside the normal combat loop
  - no scripted free opening attack before the combat menu begins
  - critical hits and critical fails
  - weapon damage dice
  - armor class
  - `Block` and `Focus`
  - dropped-weapon recovery for the barbarian
  - barbarian `Rage` and `Reckless Attack`
  - bard spell/save support with a visible `Spell Save DC`
  - bard reactions and bonus offense through:
    - `Bardic Inspiration`
    - `Cutting Words`
    - `Vicious Mockery`
  - a cleaner battle-status layout with clearer separation between Borzig and the enemy
  - a class-ready turn menu with separate `Action` and `Bonus Action` entry points
  - brutal barbarian crit-finish text on lethal takedowns
- class-specific combat identity for the barbarian:
  - `Rage` as a bonus action with limited uses per long rest
  - rage adding weapon damage while reducing incoming weapon damage during the fight
  - `Reckless Attack` as a higher-risk attack style that gives Borzig advantage now and gives the next enemy attack against him advantage too
  - combat status showing rage uses, active rage state, and reckless exposure
- class-specific combat identity for the bard:
  - `Bardic Inspiration` prepared before danger with an instrument
  - inspiration dice equal to `1 + CHA modifier`
  - inspiration dice used after `Attack`, `Block`, or `Focus`
  - a dedicated `Bonus Action` menu inside combat rounds
  - `Vicious Mockery` using a `WIS` save instead of guaranteed damage
  - `Cutting Words` as a reaction that spends bardic inspiration
  - short-rest recovery of prepared bardic inspiration
- cave exploration with connected rooms, backtracking, room loot, and encounters
- defeat handling with:
  - tutorial defeat resetting the whole tutorial back to the campfire
  - town quest defeat offering either a same-day `Town Doctor` recovery for coin or a next-day `Inn` recovery through a long rest
  - ring defeat remaining separate from the heavier city defeat flow
- tutorial boss warning flow with a Shadow Sanctum reward choice
- tutorial support for the bard with:
  - class-aware intro and campfire hints
  - bardic inspiration preparation before the first dungeon
  - smoother tutorial combat onboarding for bard actions
- quest log with XP tracking plus separate views for accepted quests, completed quests, failed quests, and Chapter Two story clues
- player-facing status views across combat, town, inn, streets, quest sources, and bard performance menus
- class-aware check proficiency groundwork with:
  - `Barbarian` proficiency on `STR` and `CON` checks
  - `Bard` proficiency on `CHA` and `Performance` checks
  - a lighter bridge toward future skill tags beyond raw stats
- inventory with:
  - `8` ready-use personal slots
  - a separate backpack storage layer
  - out-of-combat transfer between backpack and ready gear
  - combat-only access to what Borzig is carrying on his person
  - equipping, consumables, and dropped loot persistence
- currency system with `CP`, `SP`, `GP` and a gold pouch
- weapon requirements with stat and handling restrictions such as `STR`, `DEX`, `One-Handed`, and `Two-Handed`
- town hub with:
  - explicit day/night state shown in town choice menus
  - day/night-aware activity access, NPC availability, inn flavor, and quest timing
  - first-night inn choice after the tutorial
  - guaranteed coin for the cheapest first-night room if the hero reaches town broke
  - `work off the room` fallback when money runs short
  - locked inn booking until the player cancels it with the innkeeper
  - inn-first navigation where the player enters the inn before choosing room or common-room activities
  - inn storage
  - inn-specific dining-room and common-room activities based on time of day, quality, and clientele
  - street interactions
  - quest board
  - guard station
  - market
  - smithy
  - apothecary
  - a dedicated town buyer
  - fighting ring that opens at night
  - small NPC rewards, information hooks, and discounts
  - deeper innkeeper and street-NPC conversations with repeat-aware dialogue
  - specialist selling prices depending on who Borzig sells to
  - comments and flavor around worn starting gear and rough cave salvage
- class-aware town and NPC reactions with:
  - different greetings, rewards, and utility hooks for barbarian and bard
  - bard-aware intros in quest sources, shops, streets, inns, and quest log text
  - cleaner use of `Gariand` / current hero name across tutorial, town, inn, and performance text
  - stronger barbarian-specific city rewards, quest routes, and trust hooks so Borzig feels more intentional outside the ring too
- fighting ring progression with:
  - unarmed combat with simultaneous round choices
  - more narrative round-to-round ring text with lighter rules-facing combat chatter
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
  - repeatable day-job tracks with level-based continuations:
    - `Market Runner`
    - `Gate Duty`
    - `Dock Work`
    - `Scribe Work`
  - separate daily limits for:
    - `1 story quest per day`
    - `1 day job per day`
  - story flags for the city mystery under the streets
  - a loose alliance structure between the watch, the patron's clerk, and Bent Nail broker leads, with Borzig acting as the link between official, mercantile, and criminal angles on the same investigation
  - bard-aware quest routes and briefings in the early city story, including alternate social or performance-flavored solutions
  - day jobs that pay coin but no XP
  - a playable finale in `The Understreet Complex`
  - a level 3 gate before the final assault begins
  - a larger finale layout with branching routes, dead ends, and a stronger maze feel
  - navigable finale rooms with searchable loot, hidden lore, and safe-room short-rest mechanics
  - locked side caches that can be opened by force, finesse, or recovered keys
  - tougher finale encounters that make potion use and short-rest timing matter
- post-Chapter-Two city state with:
  - stronger NPC greetings and town tone once Borzig returns as a proven level 3 hero
  - improved shop inventory for a level 3 barbarian
  - tougher fighting ring progression after champion status
  - better-paying day jobs for a proven veteran without granting XP
- bard city identity with:
  - nighttime `Find an audience and perform for coin`
  - up to `3` performances per day at different evening venues
  - venue progression through:
    - `Market Square`
    - `Bent Nail`
    - `Lantern Rest`
    - `Silver Kettle`
    - `Private Patron Salon`
  - performance rewards that do not consume the normal day-job slot
  - a Belor market performance permit that improves market-square performances
  - first-night inn events and social standing that can support the bard's audience/invitation loop
  - growing public recognition when the bard performs often in town and in inns
  - better fit with `Lantern Rest` and `Silver Kettle` as the bard's natural city homes

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
- delivers the current hero to the city
- applies the level 2 long-rest level up with fixed HP gain
- restores him to full HP
- always takes the reduced Shadow Sanctum gold reward path of `2 GP`
- never grants the haste reward

---

## Game flow

The current build is split into two major phases:

### 1. Tutorial cave

The hero begins outside the cave at a campfire.

From there the player can:

- check inventory
- enter the cave
- head to town
- read the quest log
- save the adventure

The city remains blocked until the tutorial quest is completed.

If the hero is defeated during the tutorial, the cave run resets and the adventure returns to the campfire from a fresh tutorial state.

### 2. Town

After the warning is delivered, the game opens into a simple town hub where the hero can:

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
- if playing `Bard`, perform for coin and build standing with audiences, patrons, and better venues
- save the adventure from the main town and inn flows

The town now uses an explicit day/night rhythm:

- daytime supports shopping, street conversations, day jobs, preparation, dining-room inn flavor, and the manual `Wait for nightfall` transition
- nighttime opens the fighting ring, bard performance venues, inn common-room activity, and night-oriented story quests
- market, smithy, and armorer close at night, while the apothecary, instrument shop, inn, streets, quest log, and buyer flow remain available
- paid bard performances are night-only, but bard-flavored `Performance` checks can still appear inside day jobs or quests
- long rests at an inn advance to the next day and reset daily limits

If the hero is defeated during a city quest, the game no longer assumes a manual reload. Instead, the quest fails and the player chooses between:

- a `Town Doctor` recovery that costs coin and keeps the same day going
- returning to the booked inn for a full long rest that ends the day and resets daily limits

### 3. Chapter Two

The Chapter Two quest chain is now playable from its opening clues through the current final assault.

`Night Watch Relief`, `Storehouse Trouble`, `Missing Herb Satchel`, and `Ledger of Ash` form the opening layer of Chapter Two. Those clues can branch into `Broken Seal Patrol`, `Whispers Beneath the Bent Nail`, `Night Courier Intercept`, and `Warehouse Ledger Recovery`, and enough gathered evidence now unlocks `The Understreet Complex` as the Chapter Two finale beneath the city.

The three main Chapter Two quest sources now read more clearly as a loose alliance investigating the same smugglers' network from different directions:

- the `Guard Station` follows breaches, patrol violence, courier movement, and tunnel access
- the `Quest Giver` / clerk follows ledgers, missing stock, hidden payments, and merchant pressure
- the `Bent Nail` and related shady contacts expose route names, handlers, and criminal whispers the other two sides cannot reach directly

Borzig effectively becomes the bridge between those three angles, carrying hard proof and rumors back and forth until the city has enough to strike below the streets.

When playing as `Bard`, several early city quests now support a different feel from the barbarian route. The bard can lean harder on `CHA`, crowd control, staged performances, merchant ego, and polished lies in places where Borzig would more often force, pressure, or outlast the same obstacle.

The final quest now plays as a more involved mini-dungeon with branching rooms, dead ends, a boss confrontation, and safe rooms that Borzig can secure for a short rest while pushing toward the end of the assault.

Day jobs now work as level-based job tracks instead of one-off filler. Each track keeps its own order of assignments, unlocks new continuations at later levels, and lets a higher-level hero catch up on missed earlier steps one day at a time. Current day-job tracks are:

- `Market Runner`: `Missing Delivery`, `Wrong Ledger`, `High-Value Hand-Off`
- `Gate Duty`: `Gate Duty Overflow`, `Toll Dispute`, `Noble Convoy`
- `Dock Work`: `Morning Load`, `Split Cargo`, `Heavy Tide`
- `Scribe Work`: `Clean Copies`, `Margin Errors`, `Sealed Abstract`

Searching rooms in the Understreet now uses `INT`, and several chambers deliberately hint when something feels hidden, recently disturbed, or worth forcing open. That gives the finale more of a real dungeon rhythm where observation, route choice, loot pressure, and resource management matter alongside combat.

Combat initiative now behaves more cleanly across the whole game: the opposed initiative roll decides who truly acts first in the standard combat loop, instead of creating a separate scripted opening attack phase before normal choices appear.

### 4. Bard v1

The bard is now a real alternate playthrough rather than just a combat variant.

`Gariand` currently has:

- distinct tutorial onboarding
- distinct combat tools and resource management
- a separate money loop through performances
- early city quest alternatives
- class-aware inn, NPC, shop, and quest-source reactions
- growing recognition through repeated performances and venue progression
- status, quest, and town flows that now read more cleanly as a bard playthrough

The remaining bard work is mostly polish and breadth rather than missing foundations:

- more full-playthrough testing from tutorial through Tier 2 city quests
- more scattered bard-specific dialogue and quest variants
- future gear/shop expansion for instruments and lighter armor
- later spell and class-depth work beyond the current `v1`

### 5. Class parity snapshot

The current build now supports both `Barbarian` and `Bard` as real starting classes, and the gap between them is much smaller than it was before.

Right now the class split looks roughly like this:

- `Barbarian` feels strongest in raw combat, ring identity, physical intimidation, and the blunt-force version of the adventure
- `Bard` feels strongest in town reactivity, social problem-solving, performance economy, and class-aware city flavor

That means both classes are playable and distinct, but they still express that identity through different pillars. The bard still has the cleaner social/economy fantasy, while the barbarian still has the clearer combat-first fantasy.

The recent class-balance work already added:

- more barbarian-specific quest outcomes where force, threat, toughness, or reputation solve problems in their own way
- more barbarian-specific city rewards, trust hooks, and inn/NPC utility
- barbarian combat resources through `Rage` and `Reckless Attack`
- clearer class-aware reactions for both `Borzig` and `Gariand`
- a shared check-proficiency foundation that makes future skill work easier to layer in cleanly

In short:

- `Bard v1` is close to feature-complete for this milestone
- `Barbarian` now feels much more deliberate in both city play and moment-to-moment combat
- the next major priorities should move toward clearer day-job presentation, broader quest polish, and later class depth beyond the current level range

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
- `town-inns.ps1`
- `town-shops.ps1`
- `town-ring.ps1`
- `town-npcs.ps1`
- `quests.ps1`

### Items and inventory

- `items.ps1`
- `inventory.ps1`

### Persistence

- `save.ps1`

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

Useful current suites include:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\city-quests.tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\day-job-progression.tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\day-night.tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\day-night-mechanics.tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\day-night-text.tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\initiative.tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\inn-day-night-text.tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\ring.tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\town-inn.tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\town-social.tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\save-load.tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\defeat.tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\tutorial-skip.tests.ps1
```

---

## Notes

- the game is currently built around a tutorial arc, a full city hub, and a first complete Chapter Two story chain
- Chapter Two is now playable from its opening story layer through its finale, with multiple replay-friendly clue paths and level-based day-job tracks implemented
- the current Chapter Two writing treats the watch, merchant-clerk, and Bent Nail leads as a loose shared investigation rather than disconnected quest boards
- some systems are intentionally lightweight for now so they can be expanded later
- several town information hooks are already in place as setup for later quest branches, payout modifiers, and post-Understreet story paths
- the current Understreet finale already supports hidden-search text, key-and-lock side rewards, and room-specific exploration hooks that can be expanded further

---

## Next possible steps

### Near-term priorities

- continue the story after `The Understreet Complex` with the consequences of breaking the network beneath the city
- build the next post-Understreet story chain with enough structure and replay value to carry Borzig toward the next level breakpoints
- deepen the existing day/night rhythm so more activities consume time or change their outcome by hour
- expand the level 3 city state with more veteran dialogue, tougher ring tracks, and new equipment tiers
- let inn, street, and ring relationships feed more directly into future quest outcomes, payouts, and alternate leads

### Medium-term world and progression work

- keep day jobs non-lethal and expandable for future classes, so later heroes can solve them through charm, discipline, stealth, or negotiation instead of raw force
- add more day-job tracks that reinforce economy and city life without granting XP
- more city districts and stronger NPC quest lines
- additional caves or wilderness zones after the city-understreet arc
- more shop inventory, armor progression, and trader variety
- let the smithy offer branching weapon upgrades, such as a more accurate forged path versus a heavier, more brutal damage-focused path
- deeper inn events, shady city routes, and economic info payoffs

### Larger system expansions

- deepen `The Understreet Complex` further with more bespoke room mechanics, puzzles, and enemy-specific dungeon interactions
- explore dual-wield as a later combat style once the broader city/day rhythm and clue systems are in place
- more classes and class-specific dialogue, gear use, and social reactions
- class features beyond level 3
- resistances, elemental effects, and broader enemy mechanics

### Optional presentation and polish

- optional audio cues and simple visual scene flourishes such as ASCII art or external image moments
