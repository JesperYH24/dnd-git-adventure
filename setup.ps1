. "$PSScriptRoot\roll.ps1"
. "$PSScriptRoot\character.ps1"
. "$PSScriptRoot\monsters.ps1"
. "$PSScriptRoot\ui.ps1"
. "$PSScriptRoot\status.ps1"
. "$PSScriptRoot\combat.ps1"
. "$PSScriptRoot\phases.ps1"
. "$PSScriptRoot\exploration.ps1"

function Initialize-Game {

    $hero = Get-Hero
    $heroHP = $hero.HP

    $forceBossInput = (Read-Host "Force boss encounter? (y/n)").ToLower()
    $forceBoss = ($forceBossInput -eq "y")

    $rooms = Get-CaveRooms

    $state = @{
        Hero = $hero
        Rooms = $rooms
        CurrentRoomId = "entrance"
        LastRoomId = $null
        GameWon = $false
        HeroHP = $heroHP
        HeroDroppedWeapon = $false
        ForceBoss = $forceBoss
    }

    return $state
}
