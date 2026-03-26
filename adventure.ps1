. "$PSScriptRoot\Setup.ps1"

$game = Initialize-Game

Start-Intro -Hero $game.Hero -Monster $game.Monster -HeroHP $game.HeroHP

Start-DetectionPhase `
    -Hero $game.Hero `
    -Monster $game.Monster `
    -HeroStarts ([ref]$game.HeroStarts) `
    -HeroBonusAttack ([ref]$game.HeroBonusAttack) `
    -MonsterStarts ([ref]$game.MonsterStarts)

$continueCombat = Start-OpeningPhase `
    -Hero $game.Hero `
    -Monster $game.Monster `
    -HeroHP ([ref]$game.HeroHP) `
    -MonsterHP ([ref]$game.MonsterHP) `
    -HeroDroppedWeapon ([ref]$game.HeroDroppedWeapon) `
    -MonsterOffBalance ([ref]$game.MonsterOffBalance) `
    -HeroStarts $game.HeroStarts `
    -HeroBonusAttack $game.HeroBonusAttack `
    -MonsterStarts $game.MonsterStarts

if (-not $continueCombat) {
    return
}

Start-CombatLoop `
    -Hero $game.Hero `
    -Monster $game.Monster `
    -HeroHP ([ref]$game.HeroHP) `
    -MonsterHP ([ref]$game.MonsterHP) `
    -HeroDroppedWeapon ([ref]$game.HeroDroppedWeapon) `
    -MonsterOffBalance ([ref]$game.MonsterOffBalance)