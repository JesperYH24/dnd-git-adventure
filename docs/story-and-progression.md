# Story and Progression

## Current game flow

The current build is split into three major phases:

1. Tutorial cave
2. Town and Chapter Two city story
3. Chapter Three Docks / Civic Keep story

## Tutorial cave

The hero begins outside the cave at a campfire.

From there the player can:

- check inventory
- enter the cave
- head to town
- read the quest log
- save the adventure

The city remains blocked until the tutorial quest is completed.

If the hero is defeated during the tutorial, the cave run resets and the adventure returns to the campfire from a fresh tutorial state.

## Town

After the warning is delivered, the game opens into a full town hub where the hero can:

- choose an inn for the first night
- keep or cancel a room booking through the innkeeper
- stash gear in inn storage
- walk the streets
- talk to townsfolk
- receive small rewards and information hooks
- unlock shop discounts
- accept town quests
- visit the fighting ring
- buy and sell gear
- buy pack animals or a riding horse at the stable yard
- if playing `Bard`, perform for coin, build venue reputation, and later turn Silver Kettle/private salon standing into patron-paid upper-room work
- if playing `Barbarian` or `Fighter`, test the public market crowd with a rough war-rhythm or old war-ballad, but not inn stages or private salons
- any class can test the tourney ground's open guest lists, while `Fighter` gets the real squire, patron, armored-duel, and later mounted-jousting progression

If the hero is defeated during a city quest, the quest fails and the player chooses between:

- a `Town Doctor` recovery that costs coin and keeps the same day going
- returning to the booked inn for a full long rest that ends the day and resets daily limits

## Chapter Two

Chapter Two is playable from opening clues through the finale. While the arc is active, the quest log can still surface individual evidence notes. Once `The Understreet Complex` is cleared, the visible log condenses the Understreet evidence into one Chapter Two summary based on what the player actually found, while the raw flags remain available for progression and future detail views.

Opening layer:

- `Night Watch Relief`
- `Storehouse Trouble`
- `Missing Herb Satchel`

Follow-up quests:

- `Ledger of Ash`
- `Night Courier Intercept`
- `Whispers Beneath the Bent Nail`

Understreet access quests:

- `Broken Seal Patrol`
- `Warehouse Ledger Recovery`

Finale:

- `The Understreet Complex`

Chapter Two is written as a loose shared investigation:

- the `Guard Station` follows breaches, courier movement, patrol violence, and tunnel access
- the `Quest Giver` / clerk follows ledgers, missing stock, hidden payments, and merchant pressure
- the `Bent Nail` exposes criminal whispers and route names the other two sources cannot reach directly

The hero becomes the bridge between those angles until the city has enough proof to strike below the streets.

The level 3 XP curve is paced so the tutorial leaves the hero at 300 XP, clearing every Tier 1 and Tier 2 story quest still stays below the 900 XP level 3 threshold, and a normal strong route reaches level 3 readiness when the first Tier 3 access breakthrough lands.

Story quests now also remember successful class-specific solutions as a small persistent track. This is not awarded just for being the right class or completing a quest; the player needs to pick the class-shaped option and make it land.

- Barbarian successes can add hard-proof marks when Borzig solves trouble through protection, pressure, endurance, or visible force.
- Bard successes can add soft-power marks when Gariand solves trouble through performance, social reading, contradiction, or controlled rumor.
- Fighter successes can add civic-trust marks when Lubert solves trouble through discipline, formal inquiry, patrol sense, or protection under authority.

The current quest-check model has moved from fixed stat choices into explicit approach menus for non-combat story quests and day jobs. Each approach has its own flavor text, skill pairing, DC, success text, and failure text. A player can also `Read the scene` first, usually with `Insight`, to learn which approaches look promising without solving the quest outright. Dungeon navigation, combat entries, recovery prompts, and locked-cache interactions remain separate utility flows rather than quest-approach menus.

## Understreet finale

`The Understreet Complex` currently includes:

- a level 3 gate before the assault begins
- branching routes and dead ends
- searchable rooms
- hidden lore
- locked caches
- safe-room short rests
- simple encounter loot from defeated Understreet mobs, mostly small coin pouches and a few low-tier recovery finds that are collected through the normal room-loot action
- stronger finale encounters that make potion use and pacing matter, with non-boss hound burst tuned down so the route stays tense without randomly deleting a healthy level 3 Bard before Serik

## Post-Chapter-Two state

After the finale, the city shifts into a stronger level 3 state with:

- stronger NPC greetings
- updated town tone
- tougher ring progression
- better-paying veteran day jobs without granting XP

Day-job tracks now continue beyond the original level 1-3 errands into level 4-6 follow-ups. They stay non-XP economy work, but their fiction keeps pace with the city: market runners move wall supplies and evacuation tokens, gate labor becomes Wall Watch support and breach drills, dock work handles wall timber and monster oddity crates, and scribe work turns wall reports, creature ledgers, and defense orders into usable records.

## Lady Veyra and The Silent Knife

After `The Understreet Complex`, the `Quest Giver` path now continues through:

- `The Silent Knife`

This quest:

- turns the anonymous patron setup into an active city threat
- foils an assassination attempt against the clerk
- reveals Lady Veyra of the High Ledger as the power behind the private jobs
- unlocks the first Docks lead without making Docks a free-roam district yet

## Docks and the contract organization

The Docks begin as a linear investigation rather than a normal town district.

Docks Tier 1:

- the hero follows Lady Veyra's assassination trail from town work leads
- the first stop reveals Auntie Brindle's Rag-and-Bone Teapot, a strange junk-buying shop
- Auntie points the hero toward black wax, dock ledgers, and the `Tide-Ledger Shack`
- `Black Contract on the Tide` follows the route from wharf records to the hired killers
- `Salvage Witness` turns Auntie Brindle's thrown-away evidence into a second usable clue
- `Tide-Ledger Marks` lets the hero strengthen a weak contract trail through dockside paperwork
- completing `2` strong Docks Tier 1 quests opens the next Docks tier
- if Docks Tier 1 results are weak, `3` total completed Tier 1 quests can still open the next tier
- after major Docks and High Ledger beats, the town menu now surfaces a short next-step reminder so the player knows whether to visit Auntie Brindle, meet Mira Kest, expose the charter scribe, rest for a level-up, or press toward the Civic Vault

When `Black Contract on the Tide` is complete, Docks opens as a visitable town district. When enough Tier 1 work is strong, or when the fallback total is complete, the organization tier opens.

From this point, Lady Veyra's dock contact `Mira Kest` becomes the in-world lead hub. Mechanically the quests still use `Source = "Docks"`, but the player-facing text frames later clues as Mira turning dockside rumors, ledgers, and witnesses into actionable work.

Open Docks currently includes:

- Auntie Brindle's Rag-and-Bone Teapot
- `Tide-Ledger Shack`
- `Warehouse Row`
- `Old Knife Berth`
- `Mira Kest's Dock Leads` for the organization behind Lady Veyra's contract

Docks Tier 2:

- `The Broker's Wake` profiles what the organization actually does
- `Debt Hooks on Warehouse Row` proves how the organization buys obedience through debt and protection money
- `The Blackmail Book` proves the organization also keeps people useful through shame, secrets, and leverage
- completing `2` strong Docks Tier 2 quests unlocks the clean-paper lead
- if Docks Tier 2 results are weak, `3` total completed Tier 2 quests can still unlock the clean-paper lead

Together they show that the group behind the contract is not only a murder crew. It uses false manifests, dock debt pressure, protection money, blackmail, and paid blades. The higher patron is not confirmed until the later Civic Vault proof names Lord Varric Halewick.

Docks Tier 3 is `The Charter Scribe`.

It:

- follows the clean-paper trail from dirty dock business into legal charters
- exposes the scribe who makes stolen cargo and coercive debt look lawful
- removes the organization's current legal shield without revealing the higher patron yet
- raises the hero's level cap to 4
- gives enough milestone XP for level 4 readiness before the Civic Vault arc

On the next long rest, level 4 can apply an Ability Score Increase.

After the level 4 long rest, Docks Tier 4 opens:

- `The Shell Charter` follows Odran Pell's exposed seal into a clean company with no honest owner
- `Counting House Pressure` proves dockside protection money is being cleaned through legal desks
- `The Customs Stamp` traces repeated official clearance marks on cargo that should never pass inspection
- completing `2` strong Docks Tier 4 quests marks `HigherPatronSuspected`, confirming that the contract organization answers to higher city hands without naming the patron yet
- if Docks Tier 4 results are weak, `3` total completed Tier 4 quests can still finish the current Docks chain

At level 4, the fighting ring connects to the outer monster-zone track: after the hero defeats and reports matching creatures beyond the wall, Dorr can book captured-monster contracts for later unarmed ring exhibitions.

At level 4, the Fighter route can start looking past foot duels toward true knightly tournament play. Mounted jousting now opens once Lubert has a stable-owned riding horse and equipped splint or plate armor, using a list-master practice lance and three distance-marked passes.

Once the higher-city trail is complete, Docks Tier 5 opens `The Civic Vault`.

This is the current Chapter Three climax dungeon:

- Mira Kest finds a hidden service route beneath the Civic Keep
- the hero enters a dungeon-like secret base under the place where the city is ruled
- rooms include the `Hidden Culvert`, `Seal Lift`, `Ledger Refuge`, `Petition Gallery`, `Mirror Cells`, `Servant Sluice`, `Charter Archive`, `Private War Room`, and `Hidden Court`
- the dungeon reuses the Understreet-style room system: navigation, encounters, searchable clues, room loot, a locked cache, and short rests in defensible rooms
- the locked archive cache can reward a `Civic Guard Blade`, a `Potion of Haste`, and coin
- the final boss is `Lord Varric Halewick`, the civic power behind Lady Veyra's death contract
- after the hidden-court fight, Halewick is forced up into the Civic Keep's public court room before magistrates and other high officials
- Halewick curses the hero, threatens Lady Veyra and the city, reveals a smaller draconic form that echoes the great dragon presence from the tutorial cave, then bursts through the court windows and escapes into the sky
- mechanically, the quest still completes and grants its rewards; narratively, Halewick remains alive as an exposed draconic threat
- before the next inn rest turns the panic toward the outer wall, town aftermath text now surfaces Civic Keep repairs, witness sorting, Guard Station alarm, Belor's immediate reaction, Docks escape-route rumors, High Ledger proof work, and innkeeper talk about officials trying to rename what they saw
- after the next inn rest, city rumors shift from palace repair aftershock into reports of creatures growing bolder against the outer wall, establishing the playable monster zone beyond the city

## Monster zone

The monster zone is the first playable answer to the post-Civic-Vault wall rumors. It sits outside the city as a dangerous wilderness layer rather than a dungeon.

Current first-pass implementation:

- the hero leaves through the outer gate and travels through abstract wilderness positions
- the zone menu shows an inferred objective so the player knows whether to find a landmark, track a creature, return a full oddity haul, or report proof to Dorr
- there is no visible room map, but landmarks are fixed and tracked so repeated direction choices can rediscover the same places
- landmarks remember visits across different days; familiar routes become easier to find and eventually unlock direct travel from the outer gate once the hero knows them well enough
- the zone contains fixed landmarks such as old shrines, watchtower ruins, burned sites, dry creek beds, camps, and boundary stones that can become future story hooks
- the zone edge is a soft boundary where the hero is warned about leaving the patrol radius or pushing into danger beyond the current chapter
- `Perception` and `Stealth` decide who notices whom before initiative
- monsters and beasts have their own perception and stealth values
- discovery results can allow avoidance, closing to melee for surprise, shadowing at `30 ft`, holding at `60 ft` for observation, ambush pressure, unclear first beats, or normal initiative
- the `60 ft` observation choice gives creature-specific tells about movement, attack style, senses, whether the threat seems beastlike, organized, trained, poisonous, or abomination-like
- monster-zone combat now tracks abstract distance: `5 ft` melee, `30 ft` normal movement, dash as an action, and monster attempts to close open ground before attacking
- the player can sleep under open sky for a risky long rest or spend time building/improving a camp for safer nights; the rest restores HP, but the camp result reports the weather-adjusted night risk and whether the rest was interrupted
- the zone menu shows a compact risk/recovery line so low HP, full oddity hauls, unreported proof, poor camp safety, and safer scouting windows are easier to read before choosing the next action
- pack animals from the stable yard let the hero haul more monster oddities back to town
- monster oddities are tracked separately from normal inventory, and Docks buyers now cash out carried hauls through Auntie Brindle; draconic salvage also gives Mira Kest and Lady Veyra's office a ledger-facing clue back into the wall pressure
- the Guard Station and Watchman Belor now treat wall attacks as a Wall Watch problem, reacting to discovered landmarks, creature proof, and Dorr-reported trails so the city watch has a visible stake in gates and wall pressure
- Dorr's monster board now makes proof reports pay in more than XP: unreported trails show wall-bounty coin, first reports pay the purse once, and Belor's watch turns the first serious report into practical supply discounts
- Dorr proof reports are available even when the hero is not on the Barbarian monster-contract path; Fighter-specific Dorr talk turns wall proof toward patrol sense, gate-defense credibility, and tourney-facing reputation instead of captured-monster pit fights
- the post-Halewick wall-rumor rest raises the hero's level cap to 5, making the monster zone the current level 4-to-5 pressure space
- the zone now tracks one-time milestone XP for landmark discoveries, direct-route unlocks, first defeated creature proofs, Dorr reports, and completed captured-monster ring contracts
- the level cap rises to 6 when the hero has built a real outer-wall case: at least 3 defeated creature types, 2 reported creature trails, 4 discovered landmarks, and either 1 reliable direct route or 1 completed monster contract
- the encounter pool now begins adding stronger and more varied post-wall-rumor threats as the cap rises: level 5 adds scouts, ambushers, route blockers, and the `ash_horn_drakelet`, while level 6 opens the `hollow_scale_wyrmling` and `gate_sunder_brute`
- after the hero actually reaches level 6 on a long rest, the first organized monster assault hits the gate in a scripted defense event
- that defense runs as three waves with visible city help: Guard Station shield lines and Belor, higher city champions, temple healers, and mages all hold parts of the wall while the hero takes the center fight
- the next monster-zone pass should add stronger follow-ups after the visible objective changes: track a creature, gather a requested oddity, investigate a landmark, return proof to Dorr or the Wall Watch, or face a stronger level 5-6 threat
- ranged weapons are intentionally deferred until the objective and contract loop gives the distance system stronger purpose
- the monster pressure should connect back to Halewick's escape and the larger draconic mystery through subtle signs before the full truth is revealed

The level 4 XP curve is meant to feel earned across the whole Docks arc:

- `Black Contract on the Tide`: 300 XP
- `Salvage Witness`: 220 XP
- `Tide-Ledger Marks`: 180 XP
- `The Broker's Wake`: 270 XP
- `Debt Hooks on Warehouse Row`: 250 XP
- `The Blackmail Book`: 230 XP
- `The Charter Scribe`: 300 XP
- post-level-4 Docks work continues with `The Shell Charter` at 320 XP, `Counting House Pressure` at 340 XP, and `The Customs Stamp` at 300 XP
- `The Civic Vault`: 420 XP as the Chapter Three climax dungeon

After that, the monster-zone curve carries the hero toward levels 5 and 6 through accumulated field proof instead of a single quest turn-in:

- post-Halewick wall rumors: raise level cap to 5
- first discovery of a landmark: 120 XP once per landmark
- familiar route unlocked from the outer gate: 180 XP once per landmark route
- first defeated creature type: 240 XP once per creature type
- first report of a defeated creature trail to Dorr: 160 XP once per creature type
- completed captured-monster ring contracts: contract-specific XP, currently 420-760 XP
- higher monster contracts now extend that range for level 5-6 threats, including `Ash-Horn Lockdown` and `Gate-Sunder Night`
- enough combined landmarks, proofs, reports, and route/contract progress: raise level cap to 6 and award a 600 XP Wall Watch campaign milestone
- long rest after reaching level 6: scripted gate defense, with wave XP and a 900 XP city-defense milestone once the gate holds

## Why High Ledger matters

Lady Veyra is not just a rich anonymous patron. She sits near the records that decide what the city officially:

- owes
- owns
- taxes
- forgives
- buries

That lets her notice hidden patterns before the watch can prove them, but it also makes public action politically dangerous. The clerk and the old `Quest Giver` mask exist because every open move from the High Ledger could become a council problem.

She is useful without being automatically safe. She can:

- pay
- protect
- open doors
- turn evidence into official pressure

But she can also:

- ruin reputations
- freeze charters
- decide which truths become part of the city's written reality

## Bard and class identity in story

The bard already has a meaningfully different city playthrough:

- more social and performance-flavored quest routes
- more polished crowd control and manipulation options
- stronger inn and venue identity
- bard-aware finale briefings and city narration

The barbarian remains stronger in:

- blunt-force solutions
- intimidation
- direct combat identity
- physical trust and enforcement roles

The fighter route is meant to grow toward upper-class legitimacy:

- `Lubert Stryer` begins with practical squire-grade kit rather than polished knight gear
- `Fighting Style: Defense` and `Second Wind` make him feel trained, armored, and hard to put down before he becomes a full knight
- `CON` and `WIS` define his non-combat identity: endurance, judgment, watchfulness, and lawful responsibility rather than raw barbarian strength
- the smithy and armorer should tempt him toward longsword, better shield work, and heavier armor
- inns now support his social climb: the Lantern Rest provides practical tourney talk, while the Silver Kettle can introduce him to patrons who care about restraint and presentation
- quest givers and guard contacts should increasingly read him as a disciplined aspirant with obligations, not a generic sellsword
- the tourney ground gives him a city pastime that is about posture, recognition, and class aspiration as much as fighting
- repeated squire sparring builds patron attention until the upper rail starts treating him as a possible aspirant instead of another armed townsman
- true mounted jousting is a level 4 knight-path goal, not part of Lubert's early city routine
- mounted jousting now requires a stable-owned riding horse and equipped splint or plate armor, then resolves as three distance-marked passes with a practice lance from the list-master and a tactical choice at `90 ft`, `60 ft`, and `30 ft`
