# Story and Progression

## Current game flow

The current build is split into two major phases:

1. Tutorial cave
2. Town and Chapter Two city story

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
- if playing `Bard`, perform for coin and build venue reputation

If the hero is defeated during a city quest, the quest fails and the player chooses between:

- a `Town Doctor` recovery that costs coin and keeps the same day going
- returning to the booked inn for a full long rest that ends the day and resets daily limits

## Chapter Two

Chapter Two is playable from opening clues through the finale.

Opening layer:

- `Night Watch Relief`
- `Storehouse Trouble`
- `Missing Herb Satchel`
- `Ledger of Ash`

Follow-up quests:

- `Broken Seal Patrol`
- `Whispers Beneath the Bent Nail`
- `Night Courier Intercept`
- `Warehouse Ledger Recovery`

Finale:

- `The Understreet Complex`

Chapter Two is written as a loose shared investigation:

- the `Guard Station` follows breaches, courier movement, patrol violence, and tunnel access
- the `Quest Giver` / clerk follows ledgers, missing stock, hidden payments, and merchant pressure
- the `Bent Nail` exposes criminal whispers and route names the other two sources cannot reach directly

The hero becomes the bridge between those angles until the city has enough proof to strike below the streets.

## Understreet finale

`The Understreet Complex` currently includes:

- a level 3 gate before the assault begins
- branching routes and dead ends
- searchable rooms
- hidden lore
- locked caches
- safe-room short rests
- stronger finale encounters that make potion use and pacing matter

## Post-Chapter-Two state

After the finale, the city shifts into a stronger level 3 state with:

- stronger NPC greetings
- updated town tone
- tougher ring progression
- better-paying veteran day jobs without granting XP

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

Together they show that the group behind the contract is not only a murder crew. It uses false manifests, dock debt pressure, protection money, blackmail, and paid blades. The higher noble or council-level patron is still deliberately unrevealed.

Docks Tier 3 is `The Charter Scribe`.

It:

- follows the clean-paper trail from dirty dock business into legal charters
- exposes the scribe who makes stolen cargo and coercive debt look lawful
- removes the organization's current legal shield without revealing the higher patron yet
- raises the hero's level cap to 4
- gives enough milestone XP for level 4 readiness before the next Docks / High Ledger climax

On the next long rest, level 4 can apply an Ability Score Increase.

After the level 4 long rest, Docks Tier 4 opens:

- `The Shell Charter` follows Odran Pell's exposed seal into a clean company with no honest owner
- `Counting House Pressure` proves dockside protection money is being cleaned through legal desks
- `The Customs Stamp` traces repeated official clearance marks on cargo that should never pass inspection
- completing `2` strong Docks Tier 4 quests marks `HigherPatronSuspected`, confirming that the contract organization answers to higher city hands without naming the patron yet
- if Docks Tier 4 results are weak, `3` total completed Tier 4 quests can still finish the current Docks chain

Once the higher-city trail is complete, Docks Tier 5 opens `The Civic Vault`.

This is the current Chapter Three climax dungeon:

- Mira Kest finds a hidden service route beneath the Civic Keep
- the hero enters a dungeon-like secret base under the place where the city is ruled
- rooms include the `Hidden Culvert`, `Seal Lift`, `Ledger Refuge`, `Petition Gallery`, `Mirror Cells`, `Servant Sluice`, `Charter Archive`, `Private War Room`, and `Hidden Court`
- the dungeon reuses the Understreet-style room system: navigation, encounters, searchable clues, room loot, a locked cache, and short rests in defensible rooms
- the locked archive cache can reward a `Civic Guard Blade`, a `Potion of Haste`, and coin
- the final boss is `Lord Varric Halewick`, the civic power behind Lady Veyra's death contract

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
