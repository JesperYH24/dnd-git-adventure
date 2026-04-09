. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Test-QuestSourcesListOpeningQuestsAndDayJobs {
    $game = Initialize-Game

    $questBoard = @(Get-TownQuestList -Game $game -Source "Quest Board")
    $guard = @(Get-TownQuestList -Game $game -Source "Guard Station")
    $patron = @(Get-TownQuestList -Game $game -Source "Quest Giver")

    Assert-Equal -Actual $questBoard.Count -Expected 2 -Message "The quest board should list one opening story quest and one day job."
    Assert-Equal -Actual $guard.Count -Expected 2 -Message "The guard station should list one opening story quest and one day job before deeper clues are found."
    Assert-Equal -Actual $patron.Count -Expected 2 -Message "The quest giver should list two opening story quests."
}

function Use-StoryCombatWinStub {
    function global:Invoke-StoryCombat {
        param(
            $Game,
            [ref]$HeroHP,
            $Monster,
            [string]$Title,
            [string]$IntroText
        )

        return [PSCustomObject]@{
            Won = $true
            Defeated = $false
            Fled = $false
        }
    }
}

function Use-ReadHostSequence {
    param([string[]]$Values)

    $script:QuestReadHostQueue = [System.Collections.Generic.Queue[string]]::new()

    foreach ($value in $Values) {
        $script:QuestReadHostQueue.Enqueue($value)
    }

    function global:Read-Host {
        param([string]$Prompt)

        if ($script:QuestReadHostQueue.Count -eq 0) {
            throw "Read-Host was called more times than expected."
        }

        return $script:QuestReadHostQueue.Dequeue()
    }
}

function Test-NightWatchReliefCompletesAndSetsStoryFlag {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Accept-TownQuest -Game $game -QuestId "guard_night_watch" | Out-Null
    Use-StoryCombatWinStub

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "guard_night_watch"

    $quest = Find-TownQuest -Game $game -QuestId "guard_night_watch"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "Night Watch Relief should complete after a successful patrol."
    Assert-Equal -Actual $game.Town.StoryFlags["FoundTunnelAccess"] -Expected $true -Message "Night Watch Relief should confirm tunnel access for chapter two."
    Assert-Equal -Actual $game.Hero.XP -Expected 200 -Message "Night Watch Relief should grant 200 XP."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 180 -Message "Night Watch Relief should pay its listed copper reward."
    Assert-Equal -Actual $game.Town.Relationships["NightCaptain"] -Expected "Respectful" -Message "Finishing the patrol should improve the guard relationship."
    Assert-Equal -Actual $game.Town.StoryQuestDoneToday -Expected $true -Message "A finished story quest should consume the daily story slot."
}

function Test-StorehouseTroubleCompletesAndGrantsItemReward {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Accept-TownQuest -Game $game -QuestId "patron_storehouse_rats" | Out-Null
    Use-StoryCombatWinStub

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "patron_storehouse_rats"

    $quest = Find-TownQuest -Game $game -QuestId "patron_storehouse_rats"
    $healingPotions = @($game.Hero.Inventory | Where-Object { $_.Name -eq "Healing Potion" })

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "Storehouse Trouble should complete after a successful fight."
    Assert-Equal -Actual $game.Town.StoryFlags["FoundSmugglingLink"] -Expected $true -Message "Storehouse Trouble should reveal the smuggling link."
    Assert-Equal -Actual $game.Hero.XP -Expected 180 -Message "Storehouse Trouble should grant story XP."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 150 -Message "Storehouse Trouble should pay its listed reward."
    Assert-True -Condition ($healingPotions.Count -ge 2) -Message "Storehouse Trouble should add the listed healing potion reward."
}

function Test-DayJobPaysCoinButNoXP {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Accept-TownQuest -Game $game -QuestId "dayjob_market_delivery" | Out-Null
    Use-ReadHostSequence -Values @("1")

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "dayjob_market_delivery"

    $quest = Find-TownQuest -Game $game -QuestId "dayjob_market_delivery"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "The day job should complete after its scene resolves."
    Assert-Equal -Actual $game.Hero.XP -Expected 0 -Message "Day jobs should not grant XP."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 90 -Message "The day job should still pay coin."
    Assert-Equal -Actual $game.Town.DayJobDoneToday -Expected $true -Message "Finishing a day job should consume the daily side-job slot."
}

function Test-OnlyOneStoryQuestCanBeStartedPerDay {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Accept-TownQuest -Game $game -QuestId "guard_night_watch" | Out-Null
    Accept-TownQuest -Game $game -QuestId "patron_storehouse_rats" | Out-Null
    Use-StoryCombatWinStub

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "guard_night_watch"
    $xpAfterFirst = $game.Hero.XP
    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "patron_storehouse_rats"

    $secondQuest = Find-TownQuest -Game $game -QuestId "patron_storehouse_rats"

    Assert-Equal -Actual $game.Hero.XP -Expected $xpAfterFirst -Message "Starting a second story quest on the same day should not grant more XP."
    Assert-Equal -Actual $secondQuest.Completed -Expected $false -Message "The second story quest should wait until the next day."
}

function Test-BrokenSealPatrolUnlocksAfterTwoStoryClues {
    $game = Initialize-Game
    $initialGuard = @(Get-TownQuestList -Game $game -Source "Guard Station")
    $initialBrokenSeal = $initialGuard | Where-Object { $_.Id -eq "guard_broken_seal" } | Select-Object -First 1

    $game.Town.StoryFlags["FoundTunnelAccess"] = $true
    $game.Town.StoryFlags["FoundSmugglingLink"] = $true

    $updatedGuard = @(Get-TownQuestList -Game $game -Source "Guard Station")
    $unlockedBrokenSeal = $updatedGuard | Where-Object { $_.Id -eq "guard_broken_seal" } | Select-Object -First 1

    Assert-Equal -Actual $initialBrokenSeal -Expected $null -Message "Broken Seal Patrol should stay hidden until enough clues are found."
    Assert-True -Condition ($null -ne $unlockedBrokenSeal) -Message "Broken Seal Patrol should unlock after two story clues."
}

Test-QuestSourcesListOpeningQuestsAndDayJobs
Test-NightWatchReliefCompletesAndSetsStoryFlag
Test-StorehouseTroubleCompletesAndGrantsItemReward
Test-DayJobPaysCoinButNoXP
Test-OnlyOneStoryQuestCanBeStartedPerDay
Test-BrokenSealPatrolUnlocksAfterTwoStoryClues

Write-Host "City quest tests passed." -ForegroundColor Green
