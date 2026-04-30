# Game Mechanics

## Current gameplay pillars

- DnD-inspired hero stats: `STR`, `DEX`, `CON`, `INT`, `WIS`, `CHA`
- playable class selection at the start of the adventure:
  - `Barbarian` as `Borzig`
  - `Bard` as `Gariand`
- level-up readiness and long-rest leveling from level 1 to level 4
- level 4 Ability Score Increase choices during long rest, including `+2` or split `+1/+1` choices capped at 20
- derived-stat scaling from ability scores: STR/DEX attacks, DEX initiative and armor, CON HP and Unarmored Defense, CHA bard resources, and skill checks
- local `save/load` support with manual save slots and backward-safe state normalization
- inventory with ready-use slots, backpack storage, equipping, consumables, and persistent loot
- currency system with `CP`, `SP`, `GP` and a gold pouch
- quest log with accepted, completed, failed, and Chapter Two clue views

## Combat

- turn-based combat with initiative rolls and true initiative order
- no scripted free opening attack before the combat menu begins
- critical hits and critical fails
- hero Nat 1s cause mishap damage and end the current hero turn
- weapon damage dice and armor class
- `Block` and `Focus`
- class-ready turn flow where `Action` and `Bonus Action` can be used in either order or passed
- cleaner battle-status layout with stronger hero/enemy separation

## Barbarian mechanics

- `Rage` as a bonus action with limited uses per long rest
- rage adds weapon damage and reduces incoming weapon damage
- `Reckless Attack` gives the barbarian advantage and also gives the next enemy attack against him advantage
- `Unarmored Defense` uses `10 + DEX modifier + CON modifier` while unarmored
- status output shows rage uses, active rage state, and reckless exposure

## Bard mechanics

- `Bardic Inspiration` prepared before danger with an instrument
- inspiration dice equal to `1 + CHA modifier`
- inspiration dice used after `Attack`, `Block`, or `Focus`
- dedicated `Bonus Action` menu inside combat rounds
- `Vicious Mockery` uses a `WIS` save
- `Cutting Words` works as a reaction and spends bardic inspiration
- prepared bardic inspiration recovers on short rest
- visible `Spell Save DC`

## Town and day/night systems

- explicit day/night state in town choice menus
- compact town HUD showing hero name, HP, and coin
- town hub now split into submenus:
  - streets
  - shops & services
  - work & trouble
  - inn / lodging
  - hero / inventory / quest log
- daytime supports shopping, street conversations, day jobs, and preparation
- nighttime opens the ring, bard performance venues, inn common-room activity, and night-oriented quests
- market, smithy, and armorer close at night
- apothecary, instrument shop, inn, streets, quest log, and buyer flow remain available
- manual `Wait for nightfall` transition
- long rests advance to the next day and reset daily limits

## Inns

- first-night inn choice after the tutorial
- guaranteed coin for the cheapest first-night room if the hero reaches town broke
- `work off the room` fallback when money runs short
- inn booking stays active until cancelled with the innkeeper
- inn-first navigation where the player enters the inn before choosing room or common-room activities
- inn storage
- inn-specific dining-room and common-room activities based on time of day, inn quality, and clientele
- first inn-room back-navigation now correctly returns to the inn wrapper instead of dropping straight to town

## Docks district flow

Docks is intentionally more linear at first than the main town hub.

- after `The Silent Knife`, Docks appears as a story lead rather than a free-roam district
- the first visit discovers Auntie Brindle's Rag-and-Bone Teapot
- the player follows dock clues through the tally shack, warehouse pressure, and old berth trail
- after the first chain opens Docks, Lady Veyra's contact `Mira Kest` becomes the player-facing source for later dock leads
- `Docks Tier 1`: complete `2` strong dockside clue quests, or `3` total completed Tier 1 quests after weak outcomes, to reach the organization layer
- `Docks Tier 2`: complete `2` strong organization quests, or `3` total completed Tier 2 quests after weak outcomes, to unlock the clean-paper lead
- `Docks Tier 3`: `The Charter Scribe` cracks the organization's legal-paper shield and makes the hero level 4-ready before the Civic Vault arc
- `Docks Tier 4`: after the level 4 long rest, complete `2` strong higher-city paper-trail quests, or `3` total completed Tier 4 quests after weak outcomes, before the chain points above the docks
- `Docks Tier 5`: `The Civic Vault` opens as a dungeon-style climax under the Civic Keep, using room navigation, combat encounters, searchable clues, loot, locked cache rewards, and short-rest rooms
- the Civic Vault finale exposes Lord Varric Halewick before the city's public court, reveals his smaller draconic form, and leaves him escaped as a future threat
- weak Docks outcomes still complete the quest, but pay less and may require an extra quest before the next tier opens
- Docks story XP is distributed across the whole chain instead of being topped up as a final remainder reward

## Ring and side systems

- nighttime fighting ring
- once-per-day tournament access
- matchup-style brawl rounds with simultaneous choices
- rivalries and record tracking against named opponents
- champion-tier and veteran-tier opponent pools
- long-term progress toward stronger unarmed fighting features

## Day jobs

- day jobs pay coin but no XP
- repeatable level-based day-job tracks
- higher-level heroes can catch up on missed earlier steps one day at a time
- current tracks:
  - `Market Runner`
  - `Gate Duty`
  - `Dock Work`
  - `Scribe Work`
- separate daily limits for:
  - `1 story quest per day`
  - `1 day job per day`

## Bard city economy

- nighttime `Find an audience and perform for coin`
- up to `3` performances per day at different evening venues
- venue progression through:
  - `Market Square`
  - `Bent Nail`
  - `Lantern Rest`
  - `Silver Kettle`
  - `Private Patron Salon`
- performances do not consume the normal day-job slot
- performance permit and venue recognition can improve bard income and standing
