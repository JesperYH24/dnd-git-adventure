. "$PSScriptRoot\Setup.ps1"

$game = Initialize-Game

Start-Intro -Hero $game.Hero -Monster $game.Monster -HeroHP ([ref]$game.HeroHP)

$heroStarts = $game.HeroStarts
$heroBonusAttack = $game.HeroBonusAttack
$monsterStarts = $game.MonsterStarts

Start-DetectionPhase `
    -Hero $game.Hero `
    -Monster $game.Monster `
    -HeroStarts ([ref]$heroStarts) `
    -HeroBonusAttack ([ref]$heroBonusAttack) `
    -MonsterStarts ([ref]$monsterStarts)

$game.HeroStarts = $heroStarts
$game.HeroBonusAttack = $heroBonusAttack
$game.MonsterStarts = $monsterStarts

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