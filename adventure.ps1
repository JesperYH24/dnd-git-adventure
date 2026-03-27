. "$PSScriptRoot\Setup.ps1"

$game = Initialize-Game
$heroHP = $game.HeroHP
$monsterHP = $game.MonsterHP
$heroDroppedWeapon = $game.HeroDroppedWeapon
$monsterOffBalance = $game.MonsterOffBalance

Start-Intro -Hero $game.Hero -Monster $game.Monster -HeroHP ([ref]$heroHP)

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
    -HeroHP ([ref]$heroHP) `
    -MonsterHP ([ref]$monsterHP) `
    -HeroDroppedWeapon ([ref]$heroDroppedWeapon) `
    -MonsterOffBalance ([ref]$monsterOffBalance) `
    -HeroStarts $game.HeroStarts `
    -HeroBonusAttack $game.HeroBonusAttack `
    -MonsterStarts $game.MonsterStarts

$game.HeroHP = $heroHP
$game.MonsterHP = $monsterHP
$game.HeroDroppedWeapon = $heroDroppedWeapon
$game.MonsterOffBalance = $monsterOffBalance

if (-not $continueCombat) {
    return
}

Start-CombatLoop `
    -Hero $game.Hero `
    -Monster $game.Monster `
    -HeroHP ([ref]$heroHP) `
    -MonsterHP ([ref]$monsterHP) `
    -HeroDroppedWeapon ([ref]$heroDroppedWeapon) `
    -MonsterOffBalance ([ref]$monsterOffBalance)

$game.HeroHP = $heroHP
$game.MonsterHP = $monsterHP
$game.HeroDroppedWeapon = $heroDroppedWeapon
$game.MonsterOffBalance = $monsterOffBalance
