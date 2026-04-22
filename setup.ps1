. "$PSScriptRoot\roll.ps1"
. "$PSScriptRoot\items.ps1"
. "$PSScriptRoot\character.ps1"
. "$PSScriptRoot\monsters.ps1"
. "$PSScriptRoot\ui.ps1"
. "$PSScriptRoot\status.ps1"
. "$PSScriptRoot\save.ps1"
. "$PSScriptRoot\inventory.ps1"
. "$PSScriptRoot\combat.ps1"
. "$PSScriptRoot\quests.ps1"
. "$PSScriptRoot\city-quests.ps1"
. "$PSScriptRoot\town.ps1"
. "$PSScriptRoot\rooms.ps1"
. "$PSScriptRoot\encounters.ps1"
. "$PSScriptRoot\phases.ps1"
. "$PSScriptRoot\exploration.ps1"

function New-DefaultTownState {
    return @{
        DayNumber = 1
        TimeOfDay = "Day"
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
}

function Get-TownDayNumber {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town) {
        return 1
    }

    return [Math]::Max(1, [int]$Game.Town.DayNumber)
}

function Get-TownTimeOfDay {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town -or [string]::IsNullOrWhiteSpace([string]$Game.Town.TimeOfDay)) {
        return "Day"
    }

    $timeOfDay = [string]$Game.Town.TimeOfDay

    if ($timeOfDay -ne "Night") {
        return "Day"
    }

    return $timeOfDay
}

function Set-TownTimeOfDay {
    param(
        $Game,
        [string]$TimeOfDay = "Day"
    )

    if ($null -eq $Game -or $null -eq $Game.Town) {
        return
    }

    if ($TimeOfDay -ne "Night") {
        $TimeOfDay = "Day"
    }

    $Game.Town.TimeOfDay = $TimeOfDay
}

function Get-TownTimeStatusText {
    param($Game)

    return "Day $(Get-TownDayNumber -Game $Game) | $(Get-TownTimeOfDay -Game $Game)"
}

function Reset-TownDailyActivityState {
    param(
        $Game,
        [bool]$WorkedForRoomToday = $false,
        [bool]$RingFoughtToday = $false
    )

    if ($null -eq $Game -or $null -eq $Game.Town) {
        return
    }

    $Game.Town.WorkedForRoomToday = $WorkedForRoomToday
    $Game.Town.Ring.FoughtToday = $RingFoughtToday
    $Game.Town.StoryQuestDoneToday = $false
    $Game.Town.DayJobDoneToday = $false
    $Game.Town.PerformanceCountToday = 0
    $Game.Town.PerformanceVenuesToday = @{}
}

function Advance-TownToNextDay {
    param(
        $Game,
        [string]$StartingTimeOfDay = "Day",
        [bool]$WorkedForRoomToday = $false,
        [bool]$RingFoughtToday = $false
    )

    if ($null -eq $Game -or $null -eq $Game.Town) {
        return
    }

    $Game.Town.DayNumber = (Get-TownDayNumber -Game $Game) + 1
    Set-TownTimeOfDay -Game $Game -TimeOfDay $StartingTimeOfDay
    Reset-TownDailyActivityState -Game $Game -WorkedForRoomToday $WorkedForRoomToday -RingFoughtToday $RingFoughtToday
}

function Initialize-Game {
    param(
        [string]$Class = "Barbarian"
    )

    $hero = Get-Hero -Class $Class
    Set-UiHeroContext -Hero $hero
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
        Town = (New-DefaultTownState)
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
