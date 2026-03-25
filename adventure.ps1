#======================
#IMPORTS
#======================
. "$PSScriptRoot\roll.ps1"
. "$PSScriptRoot\character.ps1"
. "$PSScriptRoot\monsters.ps1"
. "$PSScriptRoot\ui.ps1"
. "$PSScriptRoot\status.ps1"
. "$PSScriptRoot\combat.ps1"
. "$PSScriptRoot\phases.ps1"
#======================
#SETUP
#======================
$hero = Get-Hero

$forceBossInput = (Read-Host "Vill du tvinga boss? (y/n)").ToLower()
$forceBoss = ($forceBossInput -eq "y")

if ($forceBoss) {
    $monster = Get-BossMonster
}
else {
    $monster = Get-RandomMonster
}

$heroHP = $hero.HP

$monsterHP = $monster.hp

$heroDroppedWeapon = $false
$monsterOffBalance = $false
$heroStarts = $false
$heroBonusAttack = $false
$monsterStarts = $false
#======================
#INTRO
#======================
Start-Intro -Hero $hero -Monster $monster -HeroHP $heroHP
#======================
#UPPTÄCKSFAS
#======================
Start-DetectionPhase -Hero $hero -Monster $monster -HeroStarts ([ref]$heroStarts) -HeroBonusAttack ([ref]$heroBonusAttack) -MonsterStarts ([ref]$monsterStarts)
#======================
#STARTFAS
#======================
$continueCombat = Start-OpeningPhase -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterHP ([ref]$monsterHP) -HeroDroppedWeapon ([ref]$heroDroppedWeapon) -MonsterOffBalance ([ref]$monsterOffBalance) -HeroStarts $heroStarts -HeroBonusAttack $heroBonusAttack -MonsterStarts $monsterStarts

if (-not $continueCombat) {
    return
}
#======================
# STRIDSLOOP (MAIN GAME LOOP)
#======================
Start-CombatLoop -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterHP ([ref]$monsterHP) -HeroDroppedWeapon ([ref]$heroDroppedWeapon) -MonsterOffBalance ([ref]$monsterOffBalance)