. "$PSScriptRoot\roll.ps1"
. "$PSScriptRoot\items.ps1"
. "$PSScriptRoot\character.ps1"
. "$PSScriptRoot\monsters.ps1"
. "$PSScriptRoot\ui.ps1"
. "$PSScriptRoot\status.ps1"
. "$PSScriptRoot\inventory.ps1"
. "$PSScriptRoot\combat.ps1"
. "$PSScriptRoot\quests.ps1"
. "$PSScriptRoot\city-quests.ps1"
. "$PSScriptRoot\town.ps1"
. "$PSScriptRoot\rooms.ps1"
. "$PSScriptRoot\encounters.ps1"
. "$PSScriptRoot\phases.ps1"
. "$PSScriptRoot\exploration.ps1"

function Initialize-Game {
    param(
        [string]$Class = "Barbarian"
    )

    $hero = Get-Hero -Class $Class
    Set-UiHeroName -Name $hero.Name
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
            ChapterOneComplete = $false
            ChapterTwoComplete = $false
            ChapterThreeHookSeen = $false
            ActiveInn = $null
            MustChooseFirstInn = $false
            WorkedForRoomToday = $false
            StoryQuestDoneToday = $false
            DayJobDoneToday = $false
            PerformanceCountToday = 0
            PerformanceCountTotal = 0
            PerformanceVenuesToday = @{}
            QuestPayoutBonusCopper = 0
            Quests = (Initialize-TownQuests)
            Relationships = @{}
            InnFlags = @{}
            StoryFlags = @{}
            Ring = @{
                Visits = 0
                FoughtToday = $false
            }
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
