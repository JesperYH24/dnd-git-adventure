. "$PSScriptRoot\roll.ps1"
. "$PSScriptRoot\items.ps1"
. "$PSScriptRoot\character.ps1"
. "$PSScriptRoot\monsters.ps1"
. "$PSScriptRoot\ui.ps1"
. "$PSScriptRoot\status.ps1"
. "$PSScriptRoot\inventory.ps1"
. "$PSScriptRoot\combat.ps1"
. "$PSScriptRoot\quests.ps1"
. "$PSScriptRoot\town.ps1"
. "$PSScriptRoot\rooms.ps1"
. "$PSScriptRoot\encounters.ps1"
. "$PSScriptRoot\phases.ps1"
. "$PSScriptRoot\exploration.ps1"

function Initialize-Game {

    $hero = Get-Hero
    $heroHP = $hero.HP

    $rooms = Get-CaveRooms
    $quest = [PSCustomObject]@{
        Name = "Scout the Cave"
        Description = "Explore the cave outside the campfire and learn what threat lies within."
        Objective = "Reach the deepest chamber and return to town with your report."
        SeenDragon = $false
        Completed = $false
    }

    $state = @{
        Hero = $hero
        Quest = $quest
        Town = @{
            StreetFlags = @{}
            Discounts = @{}
        }
        Rooms = $rooms
        CurrentRoomId = "entrance"
        LastRoomId = $null
        GameWon = $false
        ShadowSanctumRewardTaken = $false
        HeroHP = $heroHP
        HeroDroppedWeapon = $false
    }

    return $state
}
