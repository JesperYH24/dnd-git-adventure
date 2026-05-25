# Game Mechanics

## Current gameplay pillars

- DnD-inspired hero stats: `STR`, `DEX`, `CON`, `INT`, `WIS`, `CHA`
- playable class selection at the start of the adventure:
  - `Barbarian` as `Borzig`
  - `Bard` as `Gariand`
  - `Fighter` as `Lubert Stryer`
- level-up readiness and long-rest leveling from level 1 to level 4, with the first monster-zone progression spine extending the level cap from 4 toward 6 after the Civic Vault
- level 4 Ability Score Increase choices during long rest, including `+2` or split `+1/+1` choices capped at 20
- derived-stat scaling from ability scores: STR/DEX attacks, DEX initiative and armor, CON HP and Unarmored Defense, CHA bard resources, and 5e-style skill checks
- the full DnD 5e skill list is now represented as a central rules table:
  - `STR`: `Athletics`
  - `DEX`: `Acrobatics`, `Sleight of Hand`, `Stealth`
  - `INT`: `Arcana`, `History`, `Investigation`, `Nature`, `Religion`
  - `WIS`: `Animal Handling`, `Insight`, `Medicine`, `Perception`, `Survival`
  - `CHA`: `Deception`, `Intimidation`, `Performance`, `Persuasion`
- skill checks can now resolve from a skill name to the correct ability automatically, while older ability-only quest checks continue to work
- non-combat quest checks now flow through the skill resolver: untagged quest checks default to `Athletics`, `Sleight of Hand`, `Investigation`, `Insight`, or `Persuasion` depending on the original ability, while `CON` remains a raw endurance check because 5e has no Constitution skill
- explicit quest tags such as `Performance`, `Perception`, `Stealth`, `Social`, or `Suggestion` can override that default; Bard social spell hooks still require those explicit social/suggestion tags rather than triggering on every Charisma check
- quest-approach menus now cover non-combat story quests and day jobs; the player can read the scene with `Insight` before committing, and the final quest result still comes from a chosen method such as `Intimidation`, `Persuasion`, `Survival`, `Investigation`, or `Performance`
- explicit quest approaches can preserve alternate ability pairings, such as `STR (Intimidation)`, when the fiction is physical pressure rather than courtly charisma
- the `Hero & Records` town submenu has a `Skill tree` view that lists all 18 skills, groups them by ability, and marks each as `[E]` Expertise, `[P]` Proficient, or `[-]` Untrained
- current starting skill identity:
  - Barbarian: `Athletics`, `Perception`, `Survival`
  - Bard: `Performance`, `Perception`, `Persuasion`
  - Fighter: `Athletics`, `Intimidation`, `Perception`
- local `save/load` support with manual save slots and backward-safe state normalization
- inventory with ready-use slots, backpack storage, equipping, consumables, and persistent loot
- currency system with `CP`, `SP`, `GP` and a gold pouch
- quest log with accepted, completed, failed, and story-note views; completed arcs such as Understreet collapse raw clues into a readable summary while detailed evidence remains available to the code
- class story approach tracking for story quests: Barbarian builds hard-proof identity, Bard builds soft-power identity, and Fighter builds civic-trust identity only when the player chooses a class-specific solution and succeeds
- town source and shop text now reinforces those identities more consistently: Barbarian reads as hard-proof force, Bard as social/performance leverage, and Fighter as civic trust, discipline, gear presentation, and knightly public credibility
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
- those wall rumors raise the level cap to `5`, making the monster zone the current progression space after level 4
- it uses wilderness travel rather than room navigation or a detailed map
- the menu shows a current objective inferred from state: find a landmark, track a wall creature, return full oddity haul, or report defeated-creature proof to Dorr
- the menu also shows a compact monster-zone progression line, so the player can see level 6 proof requirements, XP-to-level after cap unlock, or gate-defense completion without opening documentation
- travel is tracked through hidden positions and persistent landmarks, so repeated directions can lead back to known places
- landmarks now track route familiarity by different visit days; repeat visits on later days make the place easier to find, and at `3` familiarity the hero can travel there directly from the outer gate
- monster-zone class reads now cover search, long-range observation, weather, field leads, camp choices, proof handling, and oddity hauling: Barbarian reads body/ground/instinct, Bard reads rhythm/story/social value, and Fighter reads patrol logic/sightlines/civic evidence
- new wilderness skills: `Perception` and `Stealth`
- before wilderness combat begins, hero and monster awareness is resolved with opposed discovery checks:
  - hero `Perception` against monster/beast `Stealth`
  - monster/beast `Perception` against hero `Stealth`
- if the hero detects the threat first, the player can avoid, observe, track, or attempt a surprise approach
- if the monster detects the hero first, it can stalk, ambush, flee, or block the path before normal initiative
- if both sides notice each other, combat starts with normal initiative
- if neither side has a clear read, the game should surface tracks, sounds, disturbed ground, or another approach choice
- monster-zone combat now has a first-pass abstract distance state: melee is `5 ft`, normal movement is `30 ft`, dash can use the action for up to `60 ft` total movement, and open encounters can start at near or far range
- when the hero wins the awareness contest, the player can avoid the creature, close into melee for an off-balance opener, shadow it from `30 ft`, hold farther out at `60 ft` to read its movement and threat tells, or face it openly
- melee attacks require melee range; Bard combat spells can use the current `60 ft` range layer, while ranged weapons are intentionally deferred until the monster-zone objective and contract loop is stronger
- the zone supports soft boundaries near the edge of the city's patrol reach rather than a detailed hard map
- camping is a meaningful rest choice: open-sky sleep restores the hero but carries higher night risk, while building or improving camp lowers the chance of a dangerous interruption
- the monster-zone menu now surfaces a compact risk/recovery readout that combines current HP, oddity haul, camp safety, weather-adjusted night risk, and a short return-or-keep-scouting recommendation
- stable-yard pack animals feed monster salvage capacity, especially for oddities requested by Docks buyers
- monster oddities are tracked separately from normal inventory so the monster-zone economy does not inflate tutorial loot; carried oddity hauls can now be delivered in the Docks to Auntie Brindle for coin, and draconic salvage leaves a Veyra/Mira ledger note
- defeated monster-zone creature types are tracked as proof for future city systems
- monster-zone milestone XP is one-time per discovery/proof/report/contract: first landmark discoveries, direct-route unlocks, first defeated creature types, Dorr reports, and completed captured-monster ring contracts all move the hero along without repeat farming
- the level cap can rise to `6` once the hero has enough outer-wall proof: at least `3` defeated creature types, `2` reported creature trails, `4` discovered landmarks, and either `1` direct landmark route or `1` completed monster contract
- once the hero actually reaches level `6`, a one-time gate-defense event can trigger after a long rest: `3` waves hit the wall while Guard Station forces, Belor, higher city champions, temple healers, and mages support the hero
- gate-defense waves use allied opening damage and healer restoration between fights, then award wave XP plus a one-time city-defense milestone if the wall holds
- the Guard Station and Watchman Belor now connect post-Halewick wall attacks to monster-zone work: wall-watch reports react to discovered landmarks, unreported creature proof, and trails already reported through Dorr
- once a level 4 hero has defeated a matching outer-wall creature, they can report it to Dorr at the fighting ring to turn the trail into a unique unarmed monster contract
- Dorr's monster board previews wall-bounty coin for unreported proof; reporting pays that bounty once and unlocks a first Wall Watch supply favor for basic healing and starter hauling support
- Dorr does not instantly produce the monster: booking a contract sends a capture crew out for a few days, after which the captured creature can be fought in the ring
- current monster-zone creature set mixes beast-like threats and stranger monsters: `wall_wolf`, `razor_boar`, `grave_hungry_thing`, `kobold_wall_scout`, `scale_touched_mastiff`, `glass_carrion_crow`, `marsh_venom_adder`, `iron_root_stag`, the level 5 draconic-pressure `ash_horn_drakelet`, the level 6 `hollow_scale_wyrmling`, and the level 6 `gate_sunder_brute`
- random monster-zone encounters now filter by hero level cap, keeping the gate-breaker threat out of the pool until level 6 progression has opened
- all three current classes have `Perception` proficiency, so the Bard is not automatically worse in the wilderness awareness phase; Fighter is currently slightly weaker at raw `Stealth` because of lower `DEX`, and armor stealth penalties are not implemented yet
- creature flavor differs mechanically through HP, AC, attack, `PerceptionBonus`, `StealthBonus`, and senses; keen senses add extra Perception, while blindsight can counter the Invisibility stealth bonus

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
- long rests no longer auto-prepare bardic inspiration; the bard must still ready the pool with an instrument, while short rests can rebuild prepared inspiration during a dungeon push
- inspiration dice used after `Attack`, `Block`, or `Focus`
- dedicated `Bonus Action` menu inside combat rounds
- `Vicious Mockery` uses a `WIS` save and can target enemies up to `60 ft` away when monster-zone distance is active; after repeated uses in the same combat, its flavor text collapses into shorter repeat lines so long fights stay readable
- `Dissonant Whispers` and `Faerie Fire` also use `60 ft` combat range, so the Bard can use spell control from near/far monster-zone openings before melee weapons matter
- `Healing Word` targets the hero and is not blocked by enemy distance
- `Charm Person` can spend a level 1 slot on tagged social quest checks; the target rolls a Wisdom save with advantage, and a failed save grants advantage on the social check
- `Suggestion` can spend a level 2 slot on tagged higher-pressure social quest checks; the target rolls a Wisdom save, and a failed save resolves the social opening without a further ability check
- `Invisibility` can be cast from quest preparation, monster-zone exploration, or calm dungeon rooms as soon as Bard level 3 unlocks level 2 slots, spends a level 2 slot, and grants `+10` to `Stealth` checks and monster-zone stealth approach rolls while active; creatures with blindsight can counter that invisibility bonus
- `Enhance Ability` can be cast at Bard level 4 before non-combat quest checks, spends a level 2 slot, focuses the check's ability, and grants advantage on matching ability checks while active
- `Cutting Words` works as a reaction and spends bardic inspiration
- prepared bardic inspiration recovers on short rest, not automatically on an inn long rest
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
- mounted jousting is a first playable level 4 Fighter/knight unlock, not an early-town activity
- before level 4, the tourney ground should stay focused on foot sparring, armored aspirant duels, patron notice, and shield technique
- mounted jousting requires level 4, stable-owned riding horse, and equipped splint or plate armor; the list-master provides a blunted practice lance for the first pass
- mounted jousting uses three-pass scoring with a player choice at each distance beat: `90 ft` (`Hold the Line`, `Spur Early`, `Read the Line`), `60 ft` (`Adjust Seat`, `Lower the Lance`, `Set the Shield`), and `30 ft` (`Commit the Strike`, `Brace for Impact`, `Last-Breath Feint`)
- the stable yard now sells pack animals for future monster-zone hauling and a riding horse that satisfies the future jousting horse requirement

## Town and day/night systems

- explicit day/night state in town choice menus
- expanded town HUD showing hero name, class level, HP, AC, XP progress or level-up readiness, coin, daily story/work availability, and relevant class resources
- Bard town HUD resources include Bardic Inspiration dice, spell save DC, level 1/2 spell slots when unlocked, and daily performance count
- Barbarian and Fighter town HUD resources include rage state or Second Wind/Action Surge uses when relevant
- after the Civic Vault exposes Halewick, the town menu can show a short aftermath reminder that points the player toward an inn rest while the city gathers witness reports; this reminder clears once outer-wall monster rumors become the new next step
- before monster zone opens, the town menu can also show a compact next-step reminder for major progression beats: pending level-up rests, daily story-lock rests, Veyra/Docks leads, charter-scribe breakthroughs, higher-city proof, and Civic Vault direction
- town relationship hints surface active inn and social payoffs beside the main progression reminder, such as Bard private-salon openings, Fighter tourney-patron attention, Barbarian mercenary gear leads, and Bent Nail under-table leads
- post-Civic-Vault town reactions now appear before monster zone begins through Guard Station source text, Belor street talk, Docks/High Ledger intros, palace-repair ambience, and innkeeper rumor lines
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
- mounted jousting reuses existing stable ownership while keeping the mounted list gated behind level and tourney armor

## Inns

- first-night inn choice after the tutorial
- guaranteed coin for the cheapest first-night room if the hero reaches town broke
- `work off the room` fallback when money runs short
- inn booking stays active until cancelled with the innkeeper
- inn-first navigation where the player enters the inn before choosing room or common-room activities
- inn storage
- inn-specific dining-room and common-room activities based on time of day, inn quality, and clientele
- relationship payoffs from inns now feed back into town menu guidance, making unlocked discounts, patrons, venues, and under-table story leads easier to notice before the player leaves for the monster zone
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
- Bard and Fighter can enter the base fighting ring, build ordinary ring records, and take normal purses, but Dorr's captured-monster contract fights are reserved for the Barbarian path
- any class carrying defeated monster-zone proof can report it to Dorr for the wall-bounty purse, report XP, and the first Wall Watch supply favor; Fighter gets separate Dorr dialogue that frames proof through patrol sense, gate defense, and tourney-facing credibility instead of bare-hand monster contracts
- level 4 monster-challenge cards in the ring become real contracts only after a Barbarian defeats matching creatures in the monster zone and reports them to Dorr
- Dorr's monster contract board now separates unreported proof, bookable contracts, capture crews still out, captured monsters ready in the pit, and completed contracts
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
- repeatable level-based day-job tracks now run from level 1 through level 6
- higher-level heroes can catch up on missed earlier steps one day at a time
- level 4-6 follow-ups connect ordinary work to the wall and monster-zone arc: market wall supplies and evacuation tokens, gate wall-watch shifts and breach drills, dock wall timber and oddity crates, and scribe wall reports and defense orders
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
- Silver Kettle artist standing and private salon invitations now add patron retainer coin on successful upper-room performances, so the Bard has a class-shaped path toward finer lodging and equipment instead of needing the fighting ring economy
- Barbarian and Fighter can try only the public `Market Square` performance slot: Barbarian uses a stylized haka-like war rhythm, Fighter sings a melancholy historical war-ballad, and neither can perform inside inns or private rooms
- each venue keeps its own performance history: total plays, `Poor` / `Good` / `Great` outcomes, last outcome, and copper earned
- audiences react differently once they know the bard: shaky rooms are guarded after repeated poor sets, known rooms carry good performances, and favorite rooms forgive weaker nights while rewarding great ones harder in flavor

## Fighter tourney economy

- the `Tourney Ground` now pays coin directly as a Fighter income path:
  - squire spar win: `40 CP`
  - close squire loss: `10 CP`
  - armored duel win: `100 CP`, or `150 CP` after accepted patron presentation
  - close armored duel loss: `25 CP`
  - mounted jousting win: `180 CP`, or `250 CP` after accepted patron presentation
  - close mounted jousting loss: `40 CP`
- this keeps the fighting ring as the rough, high-risk public purse while giving Lubert a steadier knightly economy tied to discipline, patrons, horse, and armor progression
- Bard and Barbarian can still test the open tourney ground as guest challengers through squire sparring and ground duels, earning only modest guest purses and guest-list records; they do not gain Fighter patron attention, Shield Bash unlocks, patron presentation, or mounted-list progression
