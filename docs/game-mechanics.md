# Game Mechanics

## Current gameplay pillars

- DnD-inspired hero stats: `STR`, `DEX`, `CON`, `INT`, `WIS`, `CHA`
- playable class selection at the start of the adventure:
  - `Barbarian` as `Borzig`
  - `Bard` as `Gariand`
  - `Fighter` as `Lubert Stryer`
- level-up readiness and long-rest leveling from level 1 to level 4
- level 4 Ability Score Increase choices during long rest, including `+2` or split `+1/+1` choices capped at 20
- derived-stat scaling from ability scores: STR/DEX attacks, DEX initiative and armor, CON HP and Unarmored Defense, CHA bard resources, and skill checks
- local `save/load` support with manual save slots and backward-safe state normalization
- inventory with ready-use slots, backpack storage, equipping, consumables, and persistent loot
- currency system with `CP`, `SP`, `GP` and a gold pouch
- quest log with accepted, completed, failed, and Chapter Two clue views
- class story approach tracking for story quests: Barbarian builds hard-proof identity, Bard builds soft-power identity, and Fighter builds civic-trust identity only when the player chooses a class-specific solution and succeeds
- class progression planning for level 1-4 is tracked in [Class Level 1-4 Progression](class-level-1-4-progression.md)

## Combat

- turn-based combat with initiative rolls and true initiative order
- no scripted free opening attack before the combat menu begins
- critical hits and critical fails
- hero Nat 1s cause mishap damage and end the current hero turn
- weapon damage dice and armor class
- `Block` and `Focus`
- class-ready turn flow where `Action` and `Bonus Action` can be used in either order or passed
- cleaner battle-status layout with stronger hero/enemy separation

## Monster-zone exploration

- the first monster zone opens after post-Civic-Vault outer-wall rumors start
- it uses wilderness travel rather than room navigation or a detailed map
- travel is tracked through hidden positions and persistent landmarks, so repeated directions can lead back to known places
- new wilderness skills: `Perception` and `Stealth`
- before wilderness combat begins, hero and monster awareness is resolved with opposed discovery checks:
  - hero `Perception` against monster/beast `Stealth`
  - monster/beast `Perception` against hero `Stealth`
- if the hero detects the threat first, the player can avoid, observe, track, or attempt a surprise approach
- if the monster detects the hero first, it can stalk, ambush, flee, or block the path before normal initiative
- if both sides notice each other, combat starts with normal initiative
- if neither side has a clear read, the game should surface tracks, sounds, disturbed ground, or another approach choice
- the zone supports soft boundaries near the edge of the city's patrol reach rather than a detailed hard map
- camping is a meaningful rest choice: open-sky sleep is fast but riskier, while building or improving camp lowers night attack risk
- stable-yard pack animals feed monster salvage capacity, especially for oddities requested by Docks buyers
- monster oddities are tracked separately from normal inventory so the monster-zone economy does not inflate tutorial loot
- defeated monster-zone creature types are tracked as proof for future city systems
- once a level 4 hero has defeated a matching outer-wall creature, they can report it to Dorr at the fighting ring to turn the trail into a unique unarmed monster contract
- Dorr does not instantly produce the monster: booking a contract sends a capture crew out for a few days, after which the captured creature can be fought in the ring
- current monster-zone creature set mixes beast-like threats and stranger monsters: `wall_wolf`, `razor_boar`, `grave_hungry_thing`, `kobold_wall_scout`, and `scale_touched_mastiff`
- all three current classes have `Perception` proficiency, so the Bard is not automatically worse in the wilderness awareness phase; Fighter is currently slightly weaker at raw `Stealth` because of lower `DEX`, and armor stealth penalties are not implemented yet
- creature flavor differs mechanically through HP, AC, attack, `PerceptionBonus`, and `StealthBonus`, but class-specific wilderness approach options are still future work

Current camp levels:

- `Open Sky`
- `Basic Camp`
- `Hidden Camp`
- `Fortified Camp`

## Barbarian mechanics

- `Rage` as a bonus action with limited uses per long rest
- rage adds weapon damage and reduces incoming weapon damage
- `Reckless Attack` gives the barbarian advantage and also gives the next enemy attack against him advantage
- `Unarmored Defense` uses `10 + DEX modifier + CON modifier` while unarmored
- status output shows rage uses, active rage state, and reckless exposure

## Bard mechanics

- `Bardic Inspiration` prepared before danger with an instrument
- inspiration dice equal to half Bard level plus positive `CHA` modifier, minimum 1
- inspiration dice used after `Attack`, `Block`, or `Focus`
- dedicated `Bonus Action` menu inside combat rounds
- `Vicious Mockery` uses a `WIS` save
- `Cutting Words` works as a reaction and spends bardic inspiration
- prepared bardic inspiration recovers on short rest
- `Footwork` replaces basic block and gives the bard's positive `DEX` modifier plus proficiency bonus as AC against the next attack
- visible `Spell Save DC`

## Fighter mechanics

- `Fighter` starts as `Lubert Stryer` with d10 HP scaling, `CON` as the default ASI focus, and `CON`/`WIS` check proficiencies
- starter kit is `Shortsword`, `Simple Round Shield`, and `Chain Mail`
- shields use their own equip slot and stack with armor instead of replacing it
- `Fighting Style: Defense` adds `+1 AC` while armor is equipped
- `Second Wind` is a Fighter bonus action that heals `1d10 + Fighter level` and restores on rest
- smithy and armorer progression can point Fighter toward `Knightly Longsword`, `Heater Shield`, `Squire Mail`, and later `Splint Armor` or `Plate Armor`
- `Lantern Rest` and `Silver Kettle` now recognize Fighter differently, feeding shield/mail discounts, tourney patron attention, and upper-table introductions
- patron standing can unlock the `Heraldic Surcoat` at the armorer as a presentation-focused tourney item
- guard and patron quest acceptance text now frames Fighter as disciplined, reliable, and knight-aspirant rather than generic hired muscle
- `Tourney Ground` is the Fighter city pastime: foot sparring and armored aspirant duels track wins/losses and build `PatronAttention`
- armored duels use Lubert's equipped weapon and armor against shield or two-handed knight aspirants; `Measured Guard`, `Committed Strike`, and unlockable `Shield Bash` give the foot lists their own tactics
- named aspirants in the foot lists keep individual win/loss records against Lubert and change their intro/outcome text on rematches
- `Shield Bash` unlocks after three armored duel wins while Lubert is fighting with a shield
- at `6` patron attention, upper-city patrons start watching Lubert as a `Patron-Noticed Aspirant`
- with patron notice plus a `Heraldic Surcoat`, Lubert can present colors to the patron rail, becoming a `Patron-Backed Aspirant` and unlocking future splint armor savings
- true mounted jousting is planned as a level 4 Fighter/knight unlock, not an early-town activity
- before level 4, the tourney ground should stay focused on foot sparring, armored aspirant duels, patron notice, and shield technique
- mounted jousting is still a future system: it should require level 4, stable-owned riding horse, equipped splint or plate armor, and lance support before it opens
- the stable yard now sells pack animals for future monster-zone hauling and a riding horse that satisfies the future jousting horse requirement

## Town and day/night systems

- explicit day/night state in town choice menus
- expanded town HUD showing hero name, class level, HP, AC, XP progress or level-up readiness, coin, daily story/work availability, and relevant class resources
- Bard town HUD resources include Bardic Inspiration dice, spell save DC, level 1/2 spell slots when unlocked, and daily performance count
- Barbarian and Fighter town HUD resources include rage state or Second Wind/Action Surge uses when relevant
- post-Civic-Vault inn rest can start the outer-wall monster rumor state after Halewick's draconic escape
- town hub now split into submenus:
  - streets
  - shops & services
  - work & trouble
  - inn / lodging
  - hero / inventory / quest log
- daytime supports shopping, street conversations, day jobs, and preparation
- nighttime opens the ring, bard performance venues, inn common-room activity, and night-oriented quests
- Fighter can visit the tourney ground from `Work & Trouble` to build early knight-facing arena standing
- market, smithy, and armorer close at night
- apothecary, instrument shop, inn, streets, quest log, and buyer flow remain available
- the daytime stable yard sells pack animals and riding horses; pack animals prepare the future monster-zone haul loop instead of using normal inventory slots
- manual `Wait for nightfall` transition
- long rests advance to the next day and reset daily limits
- once the future level 4 jousting system exists, the town day loop can reuse existing stable ownership while keeping mounted jousting itself gated behind level, armor, and lance support

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
- `RingReputation` as a public-name track separate from `RingWinsTotal`
- ring reputation titles, currently ranging from `Unproven` to `Ring Legend`
- derived unarmed ring titles from wins, unarmed training, ring reputation, Champion Night, and the future monster-challenge hook
- named rival arcs for selected opponents, with personal pre-fight and post-fight beats layered on top of the rivalry record
- `Champion Night` as a one-time title bout after 10 ring wins, currently built around Champion Breaker Ysold and a persistent `Pit Champion` title flag
- fight-style crowd taste for `Quick Finish`, `Technical`, `Grappler`, and `Brawler` wins, with small reputation bonuses and a saved dominant style
- wager choices before entering the ring: safe purse, crowd bet, or double-or-nothing
- post-fight ring rumors that react to Docks progress, Halewick aftershocks, level 4 monster-zone foreshadowing, and ring reputation
- level 4 monster-challenge cards in the ring become real contracts only after the hero defeats matching creatures in the monster zone and reports them to Dorr
- taking a monster contract books Dorr's capture crew; the actual unarmed monster fight happens in the ring after the contract's return day
- current Dorr monster contracts:
  - `Wall-Scraper Trial` from reported wall scouts or wall-prowling wolves
  - `Mire-Tusk Clinch` from reported razor-tusk boars, gated by stronger ring reputation
  - `Lantern-Eater Exhibition` from stranger reported threats, gated by the Pit Champion title
- champion-tier and veteran-tier opponent pools
- long-term progress toward stronger unarmed fighting features
- monster contract wins pay bounty coin, add ring reputation, and are tracked as completed so Dorr does not immediately repeat the same exhibition

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
- each venue keeps its own performance history: total plays, `Poor` / `Good` / `Great` outcomes, last outcome, and copper earned
- audiences react differently once they know the bard: shaky rooms are guarded after repeated poor sets, known rooms carry good performances, and favorite rooms forgive weaker nights while rewarding great ones harder in flavor
