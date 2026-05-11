# Class Level 1-4 Progression

This document tracks the intended class feature shape up to the current level cap. The goal is not a full rules clone, but each class should feel recognizable, complete, and distinct by level 4.

Legend:

- `Implemented`: playable now
- `Partial`: represented, but not complete enough yet
- `Missing`: should be added or deliberately replaced
- `Custom`: local game feature, not a core DnD feature

## Barbarian: Berserker

Borzig is the people's hard-proof hero: endurance, force, survival, and visible fury.

| Level | Target Feature | Current Status | Notes |
|---:|---|---|---|
| 1 | Rage | Implemented | Bonus action. Adds weapon damage and reduces incoming weapon damage. Limited uses restore on long rest. |
| 1 | Unarmored Defense | Implemented | AC uses `10 + DEX modifier + CON modifier` while unarmored. |
| 2 | Reckless Attack | Implemented | Gives advantage on the barbarian's attack, then exposes him to advantage on the next enemy attack. |
| 2 | Danger Sense | Missing | Should help against traps, ambushes, dragon signs, and monster-zone danger reads. Good fit for `Perception`/survival moments. |
| 3 | Berserker: Frenzy | Missing | Needs a local version. Could be an extra offensive option during Rage, but should avoid making Barbarian erase every fight. |
| 4 | Ability Score Increase | Implemented | Level 4 ASI supports `+2` or split `+1/+1`, capped at 20. Default class focus is `STR`. |

Barbarian priorities:

- add `Danger Sense` as a reactive/awareness feature before monster-zone ambushes, traps, and strange hazards
- add a controlled Berserker `Frenzy` feature that makes Rage feel wilder without breaking action economy
- make monster-zone class text lean into instinct, scent, tracks, muscle memory, and surviving bad starts

## Fighter: Champion

Lubert Stryer is the knight-aspirant: defense, discipline, civic trust, and formal martial progression.

| Level | Target Feature | Current Status | Notes |
|---:|---|---|---|
| 1 | Fighting Style: Defense | Implemented | Adds `+1 AC` while armor is equipped. |
| 1 | Second Wind | Implemented | Bonus action heal: `1d10 + Fighter level`, restores on rest. |
| 2 | Action Surge | Missing | Should become the Fighter's signature action-economy burst. Needs careful UI integration with current action/bonus-action turn flow. |
| 3 | Champion: Improved Critical | Missing | Should expand critical threat range, likely crit on `19-20` for weapon attacks. |
| 4 | Ability Score Increase | Implemented | Level 4 ASI supports `+2` or split `+1/+1`, capped at 20. Default class focus is `CON`. |

Fighter priorities:

- add `Action Surge` as a once-per-rest combat feature
- add Champion `Improved Critical` so the subclass has a clear level 3 identity
- decide how Fighter's level 4 jousting hook should sit beside ASI, stable-owned horse, splint/plate requirement, and future lance support
- make monster-zone class text lean into patrol logic, shield discipline, wall defense, and reading organized threats

## Bard: College of Lore

Gariand is the soft-power hero: performance, knowledge, timing, insults, favors, and social control.

| Level | Target Feature | Current Status | Notes |
|---:|---|---|---|
| 1 | Bardic Inspiration | Implemented | Prepared with an instrument. Dice scale from CHA in this game and can support attack/defense/focus moments. |
| 1 | Spellcasting | Partial | `Vicious Mockery` exists, but the bard does not yet have a broader spell list or spell-slot identity. |
| 2 | Jack of All Trades | Missing | Should give the Bard a small bonus to non-proficient checks, especially city/social/exploration checks. |
| 2 | Song of Rest | Missing | Should improve short-rest recovery or inn/camp recovery flavor. |
| 3 | College of Lore: Bonus Proficiencies | Partial | Bard already has `Performance` and `Perception`, but Lore should broaden skill identity more deliberately. |
| 3 | College of Lore: Cutting Words | Implemented | Reaction that spends Bardic Inspiration to reduce incoming attack pressure. |
| 3 | Expertise | Missing | Should let Bard choose or receive stronger focus in key skills such as `Performance`, `Persuasion`-style checks, `Perception`, or future `Lore`. |
| 4 | Ability Score Increase | Implemented | Level 4 ASI supports `+2` or split `+1/+1`, capped at 20. Default class focus is `CHA`. |
| Custom | Footwork | Implemented | Replaces basic block language and scales AC defense from positive `DEX` modifier plus proficiency bonus. |

Bard priorities:

- add `Jack of All Trades` so Bard feels broadly capable outside combat
- add `Song of Rest` or a local equivalent for recovery during short rests, inns, or camps
- add Lore-flavored skill support: bonus proficiencies, expertise, and knowledge/social reads
- decide how much spellcasting this game actually wants before level 4, beyond `Vicious Mockery`
- make monster-zone class text lean into strange sounds, folklore, performance misdirection, and reading behavior instead of raw weapon dominance

## Cross-Class Level 4 Checklist

Before treating level 4 as fully stable, these should be true:

- every class has its level 1-3 defining features represented or intentionally replaced
- every class has a level 4 ASI path that updates derived stats cleanly
- combat UI shows class resources clearly enough to make choices obvious
- monster-zone and city quests can reference class identity without forcing only one correct class
- subclasses have at least one feature that changes play:
  - Berserker: `Frenzy` or equivalent rage escalation
  - Champion: `Improved Critical`
  - College of Lore: `Cutting Words` plus broader skill/lore identity

## Suggested Implementation Order

1. Add Fighter `Action Surge`.
2. Add Fighter Champion `Improved Critical`.
3. Add Barbarian `Danger Sense`.
4. Add Berserker `Frenzy`.
5. Add Bard `Jack of All Trades`.
6. Add Bard `Song of Rest`.
7. Add Bard Lore expertise/bonus proficiency support.
8. Revisit Bard spellcasting scope before adding more spells.
