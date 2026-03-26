@"
# DnD Git Adventure

Ett textbaserat stridsbaserat äventyr i PowerShell där spelaren styr hjälten Borzig genom ett encounter mot ett monster.

---

## Syfte

Projektet är byggt för att:

- träna PowerShell och scripting
- arbeta med modulär kod (flera .ps1-filer)
- separera ansvar (Setup vs Gameplay)
- implementera ett enkelt state-baserat spel
- skapa ett stridssystem med tärningsmekanik

---

## Hur spelet fungerar

Spelet är uppdelat i två huvuddelar:

### 1. Setup (Setup.ps1)

När spelet startar:

- alla script laddas in
- hjälten skapas via `Get-Hero`
- spelaren kan välja att tvinga fram en boss
- ett monster väljs (random eller boss)
- startvärden sätts (HP, flags etc)
- ett GameState skapas (hashtable)

GameState returneras till Adventure.ps1

---

### 2. Gameplay (Adventure.ps1)

Adventure.ps1 ansvarar för flödet:

1. Initiera spelet via `Initialize-Game`
2. Starta intro
3. Köra detection phase
4. Köra opening phase
5. Om båda lever → starta combat loop

---

## GameState

Spelet använder en central hashtable som innehåller all data:

- Hero
- Monster
- HeroHP
- MonsterHP
- HeroDroppedWeapon
- MonsterOffBalance
- HeroStarts
- HeroBonusAttack
- MonsterStarts

Den skickas mellan funktioner och uppdateras via `[ref]`.

---

## Faser i spelet

### Intro
- Visar scenen
- Presenter hjälten och monstret

---

### Detection Phase

Avgör initiativ via d20:

- **15+** → hjälten får bonusattack
- **8–14** → hjälten börjar
- **1–7** → monstret börjar

---

### Opening Phase

- Första attacken sker
- Kan avgöra striden direkt

---

### Combat Loop

Spelaren väljer varje runda:

- **A** = Attack
- **R** = Run

Loopen fortsätter tills:

- hjälten dör
- monstret dör
- spelaren flyr

---

## Stridssystem

### Attack

- d20 används för träff
- **20** → Critical Hit
- **1** → Critical Fail
- **10+** → träff
- annars miss

---

### Critical Hit

- maxskada + extra skadeslag

---

### Critical Fail

Hjälte:
- tappar vapnet
- måste plocka upp det nästa runda

Monster:
- blir ur balans
- missar nästa attack

---

## Statussystem

Visar HP med färger:

### Hjälte
- Grön = hög HP
- Gul = medium
- Röd = låg

### Monster
- DarkYellow = hög HP
- Gul = skadad
- Röd = nära död
- Magenta = boss

---

## Kodstruktur

Projektet är uppdelat i tydliga ansvarsområden:

---

### Adventure.ps1 (Main)

- laddar Setup.ps1
- startar spelet
- kör alla faser
- hanterar spel-flödet

---

### Setup.ps1

- laddar alla scripts
- skapar hjälte
- väljer monster
- initierar GameState
- returnerar spelets startläge

---

### character.ps1

- `Get-Hero`
- definierar spelarens stats

---

### monsters.ps1

- `Get-RandomMonster`
- `Get-BossMonster`
- innehåller alla monster

---

### roll.ps1

- hanterar tärningsslag
- används för attack och skada

---

### ui.ps1

- ansvarar för all output
- färger
- textanimationer

---

### status.ps1

- visar HP-status
- färgkodning

---

### combat.ps1

- attackfunktioner
- critical hits/fails
- combat loop

---

### phases.ps1

- `Start-Intro`
- `Start-DetectionPhase`
- `Start-OpeningPhase`

---

## Starta spelet

```powershell
.\Adventure.ps1

Vid behov:
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### Framtida utveckling
GameState som klass istället för hashtable
inventory-system
fler actions (defend, special attacks)
potions/healing
flera encounters
leveling-system
save/load

### Sammanfattning

## Projektet demonstrerar:

modulär PowerShell-arkitektur
separation av ansvar (Setup vs Gameplay)
state-driven design
enkel spel-loop med faser