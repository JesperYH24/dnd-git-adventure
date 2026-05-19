# Future Ideas

## Near-term priorities

- next recommended focus: deepen playable monster-zone objectives and the Dorr contract loop now that Bard spell work is paused and ranged weapons are intentionally on ice
- follow up on Lord Varric Halewick after the Civic Vault: he is exposed, draconic, and escaped rather than dead
- decide what the city does after multiple high officials witness Halewick's transformation in the Civic Keep court room
- turn the public court reveal into the next political pressure state for Lady Veyra, the Guard Station, and the Docks
- develop Lady Veyra and the `High Ledger` into a stronger strategic quest-giver hub
- build the next post-Civic-Vault story chain around witnesses, dragon panic, civic cover-ups, and Halewick's escape route
- expand the first playable monster zone beyond the city with more landmarks, contracts, weather, return-to-town payouts, and dragon-pressure escalation
- deepen the existing day/night rhythm so more activities consume time or change their outcome by hour
- expand the post-Civic-Vault city state with more witness reactions, tougher ring tracks, and new equipment tiers
- let inn, street, and ring relationships feed more directly into future quest outcomes, payouts, and alternate leads

## Lady Veyra / High Ledger direction

- treat the High Ledger as the place where the city's official truth gets written: debts, taxes, charters, seized goods, forgiven payments, and buried names
- keep Veyra politically constrained, so she needs the hero to create proof before she can safely move the city's machinery
- make the clerk remain useful as the public face, but let the player gradually understand that the work now reaches into higher city power
- let Veyra react to Halewick's escape carefully: she has proof now, but proof against a dragon-politician may be more dangerous than suspicion
- give `Barbarian` routes a hard-proof identity: protection, intimidation, seizures, broken doors, and surviving people who want records destroyed
- give `Bard` routes a soft-power identity: salons, testimony, social pressure, forged confidence, overheard confessions, and performances used as cover
- give `Fighter` routes an upper-city aspiration identity: tourney recognition, patron etiquette, shield discipline, formal duels, and proof that a practical fighter can become knightly
- let future quests ask whether Veyra is simply helping the city or also choosing which version of the city survives in the ledgers

## Medium-term world and progression work

- plan the next level progression after the Civic Vault and decide whether Halewick's escaped-dragon arc points toward level 5
- keep day jobs non-lethal and expandable for future classes, so later heroes can solve them through charm, discipline, stealth, or negotiation instead of raw force
- add more day-job tracks that reinforce economy and city life without granting XP
- more city districts and stronger NPC quest lines
- additional caves or wilderness zones after the city-understreet arc
- more shop inventory, armor progression, and trader variety
- let the smithy offer branching weapon upgrades, such as a more accurate forged path versus a heavier, more brutal damage-focused path
- expand Fighter's tourney ground into level 4 mounted jousting using the new stable-owned riding horse state, splint-or-plate tourney armor, lances, heraldic rewards, and distance-before-clash choices
- deeper inn events, shady city routes, and economic info payoffs

## Monster zone design direction

The first monster zone now exists as a wilderness layer beyond the city walls, not a dungeon with rooms. It should keep becoming more explorable, trackable, and dangerous without needing a detailed map.

Core loop to deepen:

- leave town through the outer gate with current gear, coin, and any owned pack animal
- choose a travel activity such as `travel north/east/south/west`, `track signs`, `move carefully`, `search landmark`, `make camp`, or `return toward city`
- resolve wilderness pressure through discovery, weather, tracks, beast/monster encounters, salvage, and rest decisions
- return to town with monster oddities, rumors, and signs of the draconic threat

Next implementation priorities:

- deepen the first visible monster-zone objective layer with more explicit follow-ups after the player tracks a creature, collects an oddity, finds a landmark, reports proof to Dorr, or needs to return safely
- extend the new pre-combat distance choices so `Perception` and `Stealth` can lead to follow-ups after `avoid`, `close`, `shadow`, `hold range`, or `stand ground`
- connect Docks buyers more directly to monster oddities, with requests for specific parts such as `Black-Wax Scout Token`, `Razor Boar Tusk`, `Pale Grave Claw`, or `Black Scale Shard`
- expand Dorr's monster-contract board with stronger dialogue and board actions now that it separates unreported proof, bookable contracts, pending capture crews, ready fights, and completed contracts
- add class-flavored monster-zone text: Barbarian reads danger through instinct and physical signs, Bard notices folklore and strange sounds, and Fighter reads patrol logic, tracks, and wall-defense threats
- later, after objectives and contracts feel good, add ranged weapon support on top of the monster-zone distance state so open ground can make bows, thrown weapons, and monster approach behavior matter

Use a hidden coordinate-style zone rather than a visible dungeon map:

- city gate can be treated as the origin point
- each direction moves the hero to a persistent abstract position
- landmarks have fixed positions, so repeatedly traveling west from the same route can find the same landmark again
- the player should see prose, landmarks, and directional choices rather than coordinates
- landmarks should track first visit, repeat visit, discoveries, future hooks, and danger level

Possible landmarks:

- `Old Mile Shrine`
- `Collapsed Watchtower`
- `Burned Orchard`
- `Dry Creek Bed`
- `Hunter's Cairn`
- `Blackened Scale Hollow`
- `Abandoned Survey Camp`
- `Ancient Boundary Stones`

The zone edge should start as a soft edge:

- if the hero travels too far, the text warns that they are leaving the city's patrol radius or entering terrain too dangerous for the current chapter
- the game can steer the hero back rather than hard-blocking with a bare "cannot go there"
- later versions can use escalating danger near the edge instead of a simple boundary

Add `Perception` and `Stealth` as pre-initiative wilderness skills:

- `Perception` detects monsters, beasts, tracks, ambushes, hidden landmarks, and strange signs
- `Stealth` helps the hero move quietly, avoid unwanted encounters, or close in for a surprise attack
- monsters and beasts should have their own `PerceptionBonus` and `StealthBonus`
- before combat, compare hero perception against monster stealth and monster perception against hero stealth
- if the hero detects the creature first, the hero can observe, avoid, track, or attempt a surprise approach
- successful stealth should keep giving positional choices: slip away, close into melee, shadow from near range, hold farther out for creature-specific observation, or deliberately reveal the hero
- if the creature detects the hero first, it can stalk, ambush, flee, or block the route
- if both sides detect each other, roll normal initiative
- if neither side gets a clear read, surface tracks, sounds, disturbed ground, or a second approach choice

Class flavor for these skills:

- `Barbarian` should be less subtle, but strong at surviving bad starts and reading danger through instinct, endurance, and physical signs
- `Bard` can read odd sounds, behavior, and patterns, but should not automatically become the best wilderness scout
- `Fighter` should benefit from `WIS` and discipline: patrol sense, formations, tracks near roads, and danger to city defenses
- heavy armor can later create stealth penalties, while cloaks, boots, or careful travel choices can offset them
- build class-specific pre-combat choices so the Bard is not just a weaker weapon fighter in monster-zone play:
  - `Barbarian`: `Read the ground by instinct`, `Force it into the open`, `Endure the ambush`
  - `Bard`: `Listen for unnatural rhythm`, `Recall monster folklore`, `Distract with sound`
  - `Fighter`: `Read patrol disruption`, `Hold disciplined ground`, `Identify wall-defense threat`
- creature types should pressure different class strengths without becoming hard counters:
  - stealthy scouts like kobolds should reward perception, patience, and anti-ambush choices
  - hard-charging beasts like boars should reward preparation, armor, endurance, or clever avoidance
  - perceptive guard-beasts like scale-touched mastiffs should make sneaking harder and reward alternate approaches
  - strange monsters like grave-hungry things should give Bard/Fighter knowledge-style reads and Barbarian instinct-style warnings

Camp/rest loop:

- sleeping under open sky should be fast but risky
- making a basic camp should cost time and lower night encounter risk
- improving a camp should cost more time or materials and lower risk further
- returning to an existing camp should be possible if the player reaches the same landmark or tracked position
- both open-sky sleep and camp sleep can grant a long rest, but camp quality should affect safety, pack animal protection, and night interruption chance

Possible camp levels:

- `0` Open Sky
- `1` Basic Camp
- `2` Hidden Camp
- `3` Fortified Camp

Monster/beast direction:

- early beasts can include wolves, boars, carrion birds, stray war dogs, marsh snakes, and other grounded threats
- early monsters can include goblin scavengers, grave-hungry things, kobold scouts, blighted wolves, lesser drakes, and scale-touched beasts
- the draconic threat should start subtle: black scale shards, burn marks, animals behaving wrong, creatures probing the walls, and tracks that imply something is organizing pressure around the city

Pack animal economy:

- the stable yard should matter because monster salvage should not simply be normal inventory loot
- no pack animal means very limited monster oddity haul
- `Pack Goat`, `Donkey`, `Mule`, and `Riding Horse` should set different monster haul capacities
- Auntie Brindle or other Docks buyers can request monster oddities such as intact venom sacs, cracked horns, wyrm-bitten hide, glassy eyes, or black scale shards
- this lets monster zone rewards matter without making tutorial cave loot valuable in town

## Fighting ring direction

- expand the new `RingReputation` track so champion bouts and later monster challenges build different amounts of public name value
- use ring reputation to unlock stronger Dorr dialogue, better odds, special opponents, rumors, and future quest hooks
- expand the first named rival arcs beyond Vero, Nella, and Ysold so later specialists also remember style, losses, grudges, and respect
- expand `Champion Night` after its first Ysold title-bout version with more crowd buildup, Dorr presentation, alternate title challengers, and later renown rewards beyond the initial `Pit Champion` flag
- expand the first crowd-taste pass so quick finishes, technical wins, grapple-heavy wins, and brawls can unlock distinct Dorr comments, rival reactions, and betting hooks
- expand the first wager system with Dorr comments, odds that react to reputation, and special side bets tied to rival names or crowd taste
- expand the first post-fight ring rumor system with rumor memory, NPC-specific sources, and quest hooks that can mark leads instead of only surfacing flavor
- expand the first unarmed-title ladder beyond `Pit Champion` and `Beast-Hand Prospect` with more named thresholds, Dorr reactions, and monster-specific titles
- deepen the first monster-challenge contracts now that they connect to the outer monster zone:
  - monsters must be defeated in the monster zone and reported to Dorr before the contract can be booked
  - Dorr's capture crew should create a visible delay before the captured monster is ready in the ring
  - fights are unarmed-only and built for reputation rather than normal loot
  - rewards can include bounty coin, ring reputation, crowd titles, and monster-specific rumors

## Larger system expansions

- deepen `The Understreet Complex` further with more bespoke room mechanics, puzzles, and enemy-specific dungeon interactions
- explore dual-wield as a later combat style once the broader city/day rhythm and clue systems are in place
- more classes and class-specific dialogue, gear use, and social reactions
- class features beyond level 3
- resistances, elemental effects, and broader enemy mechanics

## Optional presentation and polish

- optional audio cues and simple visual scene flourishes such as ASCII art or external image moments
