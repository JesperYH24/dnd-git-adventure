# DnD Git Adventure

A text-based combat adventure in PowerShell where the player controls the hero Borzig through an encounter with a monster.

---

## Purpose

This project is built to:

- practice PowerShell and scripting
- work with modular code across multiple `.ps1` files
- separate responsibilities clearly (`Setup` vs `Gameplay`)
- implement a simple state-based game
- create a combat system with dice mechanics

---

## How the game works

The game is divided into two main parts:

### 1. Setup (`Setup.ps1`)

When the game starts:

- all scripts are loaded
- the hero is created through `Get-Hero`
- the player can choose to force a boss encounter
- a monster is selected (random or boss)
- starting values are initialized (HP, flags, etc.)
- a `GameState` hashtable is created

The `GameState` is then returned to `Adventure.ps1`.

---

### 2. Gameplay (`Adventure.ps1`)

`Adventure.ps1` is responsible for the game flow:

1. Initialize the game with `Initialize-Game`
2. Start the intro
3. Run the detection phase
4. Run the opening phase
5. If both combatants survive, start the combat loop

---

## GameState

The game uses a central hashtable that contains all game data:

- `Hero`
- `Monster`
- `HeroHP`
- `MonsterHP`
- `HeroDroppedWeapon`
- `MonsterOffBalance`
- `HeroStarts`
- `HeroBonusAttack`
- `MonsterStarts`

It is passed between functions and updated through `[ref]`.

---

## Game phases

### Intro

- shows the scene
- introduces the hero and the monster

---

### Detection Phase

Determines initiative with a d20 roll:

- **15+** -> the hero gets a bonus attack
- **8-14** -> the hero starts
- **1-7** -> the monster starts

---

### Opening Phase

- the first attack happens
- the fight can be decided immediately

---

### Combat Loop

Each round, the player chooses:

- **A** = Attack
- **I** = Inventory
- **R** = Run

The loop continues until:

- the hero dies
- the monster dies
- the player flees

---

## Combat system

### Attack

- a d20 is used to hit
- **20** -> Critical Hit
- **1** -> Critical Fail
- **10+** -> hit
- otherwise -> miss

---

### Critical Hit

- maximum damage + an extra damage roll

---

### Critical Fail

Hero:

- drops the weapon
- must pick it up next turn

Monster:

- becomes off balance
- misses the next attack

---

## Status system

Displays HP with colors:

### Hero

- Green = high HP
- Yellow = medium HP
- Red = low HP

### Monster

- DarkYellow = high HP
- Yellow = wounded
- Red = near death
- Magenta = boss

---

## Code structure

The project is split into clear responsibility areas:

### `Adventure.ps1` (Main)

- loads `Setup.ps1`
- starts the game
- runs all phases
- handles the overall game flow

### `Setup.ps1`

- loads all scripts
- creates the hero
- chooses a monster
- initializes the `GameState`
- returns the starting game state

### `character.ps1`

- `Get-Hero`
- defines the player's stats

### `monsters.ps1`

- `Get-RandomMonster`
- `Get-BossMonster`
- contains all monsters

### `roll.ps1`

- handles dice rolls
- used for attack and damage

### `ui.ps1`

- handles all output
- colors
- text animation

### `status.ps1`

- shows HP status
- color coding

### `combat.ps1`

- attack functions
- critical hits and fails
- combat loop

### `phases.ps1`

- `Start-Intro`
- `Start-DetectionPhase`
- `Start-OpeningPhase`

---

## Run the game

```powershell
.\Adventure.ps1

If needed:
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

## Future development

- `GameState` as a class instead of a hashtable
- inventory system improvements
- more actions (`defend`, special attacks)
- potions and healing expansion
- multiple encounters
- leveling system
- save/load support

## Summary

### This project demonstrates:

- modular PowerShell architecture
- separation of responsibilities (`Setup` vs `Gameplay`)
- state-driven design
- a simple phase-based game loop
