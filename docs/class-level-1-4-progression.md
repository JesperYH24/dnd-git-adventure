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
| 1 | Spellcasting | Partial | Spell slots, known-spell progression, free cantrips, `Healing Word`, `Dissonant Whispers`, `Faerie Fire`, `Charm Person`, first-pass `Suggestion`, and control-focused `Vicious Mockery` are implemented. Broader exploration spell use is still future work. |
| 2 | Jack of All Trades | Implemented | Adds half proficiency to non-proficient ability checks. |
| 2 | Song of Rest | Implemented | Adds `1d6` extra healing to Bard short rests. |
| 3 | College of Lore: Bonus Proficiencies | Implemented | Adds Lore-flavored `Lore`, `Investigation`, and `Insight` proficiencies at level 3. |
| 3 | College of Lore: Cutting Words | Implemented | Level-gated reaction that spends Bardic Inspiration to reduce incoming attack pressure. |
| 3 | Expertise | Implemented | Fixed first pass: doubles proficiency for `Performance` and `Perception` at level 3. |
| 4 | Ability Score Increase | Implemented | Level 4 ASI supports `+2` or split `+1/+1`, capped at 20. Default class focus is `CHA`. |
| Custom | Footwork | Implemented | Replaces basic block language and scales AC defense from positive `DEX` modifier plus proficiency bonus. |

Bard follow-ups:

- decide whether Expertise should become player-chosen later instead of fixed to `Performance` and `Perception`
- extend spellcasting beyond the first social/combat pass with level 2 utility/control spells
- make monster-zone class text lean into strange sounds, folklore, performance misdirection, and reading behavior instead of raw weapon dominance

### Bard Spell Slots Implementation Plan

The Bard should keep feeling like a control, tempo, and problem-solving class instead of becoming a weaker weapon fighter. Spell slots should be implemented as a clear resource layer, separate from cantrips.

Target Bard spell progression through the current level cap:

| Bard Level | Cantrips Known | Spells Known | Level 1 Slots | Level 2 Slots |
|---:|---:|---:|---:|---:|
| 1 | 2 | 4 | 2 | 0 |
| 2 | 2 | 5 | 3 | 0 |
| 3 | 2 | 6 | 4 | 2 |
| 4 | 3 | 7 | 4 | 3 |

Suggested first spell list:

| Unlock | Spell | Role |
|---|---|---|
| Level 1 cantrip | `Vicious Mockery` | Combat control cantrip. Should deal small psychic damage and weaken the target's next attack on a failed save. |
| Level 1 cantrip | `Minor Illusion` or `Friends` | Non-slot utility for social/exploration play. |
| Level 1 spell | `Healing Word` | Emergency sustain. Bonus action healing, spends a level 1 slot. |
| Level 1 spell | `Dissonant Whispers` | Offensive control. Psychic damage plus forced disruption/flee flavor, spends a level 1 slot. |
| Level 1 spell | `Faerie Fire` | Accuracy/control support. Helps Bard solve fights through setup rather than raw damage. |
| Level 1 spell | `Charm Person` | Social spell with quest and town use. |
| Level 2 spell | `Suggestion` | Social/control spell for level 3+. |
| Level 2 spell | `Invisibility` | Exploration and danger-avoidance spell for level 3+. |
| Level 2 spell | `Enhance Ability` or `Hold Person` | Level 4 candidate depending on whether we want broader skill support or stronger combat lockdown. |

Implementation order:

Completed:

1. Add Bard spellcasting state to `character.ps1`: `CantripsKnown`, `SpellsKnown`, `MaxSpellSlots`, and `CurrentSpellSlots`.
2. Add helpers: `Get-HeroSpellcastingProgression`, `Initialize-HeroSpellcasting`, `Restore-HeroSpellSlots`, `Use-HeroSpellSlot`, `Test-HeroCanCastSpell`, and `Get-HeroKnownSpells`.
3. Keep cantrips free. `Vicious Mockery` never spends a slot.
4. Long rest restores Bard spell slots. Short rest does not restore Bard slots; `Song of Rest` stays as healing support.
5. Add a combat `Cast Spell` path for Bard instead of crowding every spell into the bonus-action menu.
6. First playable pass implements slots, `Healing Word`, `Dissonant Whispers`, `Faerie Fire`, `Charm Person`, and control-focused `Vicious Mockery`.
7. Tests cover level-based slot counts, cantrips not spending slots, slotted spells spending slots, long-rest restoration, level 3 level-2 slot unlock, failed casting when slots are empty, and the first playable combat spells.

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

Completed next pass:

1. Implement Bard spell slots and known-spell progression.
2. Improve `Vicious Mockery` into a true control cantrip.
3. Add visible check-result explanations for passive class features.
4. Add `Faerie Fire` as a level 1 combat setup spell with a Dexterity save, level 1 slot cost, and next-attack advantage on a failed save.
5. Add `Charm Person` as a tagged social quest spell: spends a level 1 slot, gives the target a Wisdom save with advantage, and grants advantage on the social CHA check only if the save fails.
6. Add `Suggestion` as a first-pass level 2 social quest spell: spends a level 2 slot, gives the target a Wisdom save, and resolves tagged higher-pressure social openings on a failed save.

Next pass:

1. Tune level 3-4 enemy difficulty against the now-complete class kits.
2. Add the next Bard spell layer:
   - broaden level 2 utility/control beyond the first `Suggestion` social hooks.
3. Decide whether fixed Lore expertise should become player-chosen later.
