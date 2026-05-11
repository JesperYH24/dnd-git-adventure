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
| 2 | Reckless Attack | Implemented | Level-gated. Gives advantage on the barbarian's attack, then exposes him to advantage on the next enemy attack. |
| 2 | Danger Sense | Implemented | Adds a monster-zone awareness bonus before encounters, helping against ambushes and creature approach reads. |
| 3 | Berserker: Frenzy | Implemented | Local version: while raging, the barbarian can spend one bonus action per rage for an extra weapon attack. |
| 4 | Ability Score Increase | Implemented | Level 4 ASI supports `+2` or split `+1/+1`, capped at 20. Default class focus is `STR`. |

Barbarian follow-ups:

- extend `Danger Sense` beyond monster-zone awareness into traps, dragon signs, and strange hazards
- tune `Frenzy` after more level 3-4 enemies exist so it stays exciting without erasing fights
- make monster-zone class text lean into instinct, scent, tracks, muscle memory, and surviving bad starts

## Fighter: Champion

Lubert Stryer is the knight-aspirant: defense, discipline, civic trust, and formal martial progression.

| Level | Target Feature | Current Status | Notes |
|---:|---|---|---|
| 1 | Fighting Style: Defense | Implemented | Adds `+1 AC` while armor is equipped. |
| 1 | Second Wind | Implemented | Bonus action heal: `1d10 + Fighter level`, restores on rest. |
| 2 | Action Surge | Implemented | Once per rest. Appears in the combat turn menu after the Fighter has spent an action and restores one action that turn. |
| 3 | Champion: Improved Critical | Implemented | Weapon attacks crit on natural `19-20`. |
| 4 | Ability Score Increase | Implemented | Level 4 ASI supports `+2` or split `+1/+1`, capped at 20. Default class focus is `CON`. |

Fighter follow-ups:

- decide how Fighter's level 4 jousting hook should sit beside ASI, stable-owned horse, splint/plate requirement, and future lance support
- add more combat text around `Action Surge` and `Improved Critical` so Lubert's discipline feels distinct from raw aggression
- make monster-zone class text lean into patrol logic, shield discipline, wall defense, and reading organized threats

## Bard: College of Lore

Gariand is the soft-power hero: performance, knowledge, timing, insults, favors, and social control.

| Level | Target Feature | Current Status | Notes |
|---:|---|---|---|
| 1 | Bardic Inspiration | Implemented | Prepared with an instrument. Dice scale from CHA in this game and can support attack/defense/focus moments. |
| 1 | Spellcasting | Partial | `Vicious Mockery` exists, but the bard does not yet have a broader spell list or spell-slot identity. |
| 2 | Jack of All Trades | Implemented | Adds half proficiency to non-proficient ability checks. |
| 2 | Song of Rest | Implemented | Adds `1d6` extra healing to Bard short rests. |
| 3 | College of Lore: Bonus Proficiencies | Implemented | Adds Lore-flavored `Lore`, `Investigation`, and `Insight` proficiencies at level 3. |
| 3 | College of Lore: Cutting Words | Implemented | Level-gated reaction that spends Bardic Inspiration to reduce incoming attack pressure. |
| 3 | Expertise | Implemented | Fixed first pass: doubles proficiency for `Performance` and `Perception` at level 3. |
| 4 | Ability Score Increase | Implemented | Level 4 ASI supports `+2` or split `+1/+1`, capped at 20. Default class focus is `CHA`. |
| Custom | Footwork | Implemented | Replaces basic block language and scales AC defense from positive `DEX` modifier plus proficiency bonus. |

Bard follow-ups:

- add UI/status language that makes Jack of All Trades and Expertise easier to notice when checks happen
- decide whether Expertise should become player-chosen later instead of fixed to `Performance` and `Perception`
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

Completed first pass:

1. Fighter `Action Surge`.
2. Fighter Champion `Improved Critical`.
3. Barbarian `Danger Sense`.
4. Berserker `Frenzy`.
5. Bard `Jack of All Trades`.
6. Bard `Song of Rest`.
7. Bard Lore expertise/bonus proficiency support.

Next pass:

1. Revisit Bard spellcasting scope before adding more spells.
2. Add visible check-result explanations for passive class features.
3. Tune level 3-4 enemy difficulty against the now-complete class kits.
