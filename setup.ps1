. "$PSScriptRoot\roll.ps1"
. "$PSScriptRoot\character.ps1"
. "$PSScriptRoot\monsters.ps1"
. "$PSScriptRoot\ui.ps1"
. "$PSScriptRoot\status.ps1"
. "$PSScriptRoot\combat.ps1"
. "$PSScriptRoot\phases.ps1"

function Initialize-Game {

    $hero = Get-Hero
    $heroHP = $hero.HP

    $forceBossInput = (Read-Host "Vill du tvinga boss? (y/n)").ToLower()
    $forceBoss = ($forceBossInput -eq "y")

    if ($forceBoss) {
        $monster = Get-BossMonster
    }
    else {
        $monster = Get-RandomMonster
    }

    $monsterHP = $monster.HP

    $state = @{
        Hero = $hero
        Monster = $monster
        HeroHP = $heroHP
        MonsterHP = $monsterHP
        HeroDroppedWeapon = $false
        MonsterOffBalance = $false
        HeroStarts = $false
        HeroBonusAttack = $false
        MonsterStarts = $false
    }

    return $state
}