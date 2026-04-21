. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Use-DayJobReadHostSequence {
    param([string[]]$Values)

    $script:DayJobReadHostQueue = [System.Collections.Generic.Queue[string]]::new()

    foreach ($value in $Values) {
        $script:DayJobReadHostQueue.Enqueue($value)
    }

    function global:Read-Host {
        param([string]$Prompt)

        if ($script:DayJobReadHostQueue.Count -eq 0) {
            throw "Read-Host was called more times than expected."
        }

        return $script:DayJobReadHostQueue.Dequeue()
    }
}

function Test-LevelThreeBacklogStartsAtFirstMarketStep {
    $game = Initialize-Game
    $game.Hero.Level = 3
    $game.Hero.LevelCap = 3

    $boardJobs = @(Get-TownQuestList -Game $game -Source "Quest Board" | Where-Object {
        $_.QuestType -eq "DayJob" -and (Get-DayJobTrackId -Quest $_) -eq "market_runner"
    })

    Assert-Equal -Actual $boardJobs.Count -Expected 1 -Message "A level 3 hero with no day-job history should still see the first market runner step first."
    Assert-Equal -Actual $boardJobs[0].Id -Expected "dayjob_market_delivery" -Message "Day-job backlog should not skip older steps when later levels are already unlocked."
}

function Test-MarketDayJobProgressesOneStepPerRest {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Hero.Level = 3
    $game.Hero.LevelCap = 3

    Accept-TownQuest -Game $game -QuestId "dayjob_market_delivery" | Out-Null
    Use-DayJobReadHostSequence -Values @("1")
    $global:RollDiceOverride = { param([int]$Sides) return 15 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "dayjob_market_delivery"

    $firstStep = Find-TownQuest -Game $game -QuestId "dayjob_market_delivery"
    $secondStep = Find-TownQuest -Game $game -QuestId "dayjob_market_delivery_2"
    $sameDayStart = Start-TownQuestAttempt -Game $game -QuestId "dayjob_market_delivery_2"

    Assert-Equal -Actual $firstStep.Completed -Expected $true -Message "The first market runner step should complete normally."
    Assert-Equal -Actual (Test-DayJobStepAvailable -Game $game -Quest $secondStep) -Expected $true -Message "Completing step one should expose step two when the hero level allows it."
    Assert-Equal -Actual $sameDayStart.Success -Expected $false -Message "The next day-job step should still respect the one-day-job-per-day rule."

    Advance-TownToNextDay -Game $game
    Accept-TownQuest -Game $game -QuestId "dayjob_market_delivery_2" | Out-Null
    Use-DayJobReadHostSequence -Values @("3")
    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "dayjob_market_delivery_2"

    Assert-Equal -Actual $secondStep.Completed -Expected $true -Message "After a rest, the second market runner continuation should be playable."
}

function Test-LevelTwoGateJobUnlocksSecondStepOnlyAfterFirstCompletes {
    $game = Initialize-Game
    $game.Hero.Level = 2
    $game.Hero.LevelCap = 2

    $firstStep = Find-TownQuest -Game $game -QuestId "dayjob_gate_labor"
    $secondStep = Find-TownQuest -Game $game -QuestId "dayjob_gate_labor_2"
    $thirdStep = Find-TownQuest -Game $game -QuestId "dayjob_gate_labor_3"

    Assert-Equal -Actual (Test-DayJobStepAvailable -Game $game -Quest $firstStep) -Expected $true -Message "The first gate job should remain the next job if it was missed at level 1."
    Assert-Equal -Actual (Test-DayJobStepAvailable -Game $game -Quest $secondStep) -Expected $false -Message "The second gate job should wait behind the unfinished first step."

    $firstStep.Completed = $true

    Assert-Equal -Actual (Test-DayJobStepAvailable -Game $game -Quest $secondStep) -Expected $true -Message "Level 2 should unlock the second gate job once the first step is complete."
    Assert-Equal -Actual (Test-DayJobStepAvailable -Game $game -Quest $thirdStep) -Expected $false -Message "Level 2 should not unlock the level 3 gate continuation."
}

function Test-NewDayJobTracksStartAtFirstStep {
    $game = Initialize-Game
    $game.Hero.Level = 3
    $game.Hero.LevelCap = 3

    $questBoardJobs = @(Get-TownQuestList -Game $game -Source "Quest Board" | Where-Object { $_.QuestType -eq "DayJob" } | Sort-Object Id)
    $patronJobs = @(Get-TownQuestList -Game $game -Source "Quest Giver" | Where-Object { $_.QuestType -eq "DayJob" })

    Assert-True -Condition (@($questBoardJobs | Where-Object { $_.Id -eq "dayjob_dock_loading" }).Count -eq 1) -Message "The dock work track should start at its first step even for a higher-level hero."
    Assert-True -Condition (@($questBoardJobs | Where-Object { $_.Id -eq "dayjob_dock_loading_2" }).Count -eq 0) -Message "The dock work track should not skip to step two before step one is complete."
    Assert-Equal -Actual $patronJobs.Count -Expected 1 -Message "The quest giver should expose the first scribe work step as a day job."
    Assert-Equal -Actual $patronJobs[0].Id -Expected "dayjob_scribe_copy" -Message "The scribe work track should begin with clean copies."
}

function Test-DockAndScribeJobsArePlayable {
    $dockGame = Initialize-Game
    $dockHP = $dockGame.Hero.HP
    Accept-TownQuest -Game $dockGame -QuestId "dayjob_dock_loading" | Out-Null
    Use-DayJobReadHostSequence -Values @("2")
    $global:RollDiceOverride = { param([int]$Sides) return 15 }

    Start-TownQuest -Game $dockGame -HeroHP ([ref]$dockHP) -QuestId "dayjob_dock_loading"

    Assert-Equal -Actual (Find-TownQuest -Game $dockGame -QuestId "dayjob_dock_loading").Completed -Expected $true -Message "Dock work should complete as a playable day job."
    Assert-Equal -Actual $dockGame.Hero.CurrencyCopper -Expected 95 -Message "Dock work should pay its listed day-job wage."
    Assert-Equal -Actual $dockGame.Hero.XP -Expected 0 -Message "Dock work should not grant XP."

    $scribeGame = Initialize-Game
    $scribeHP = $scribeGame.Hero.HP
    Accept-TownQuest -Game $scribeGame -QuestId "dayjob_scribe_copy" | Out-Null
    Use-DayJobReadHostSequence -Values @("1")

    Start-TownQuest -Game $scribeGame -HeroHP ([ref]$scribeHP) -QuestId "dayjob_scribe_copy"

    Assert-Equal -Actual (Find-TownQuest -Game $scribeGame -QuestId "dayjob_scribe_copy").Completed -Expected $true -Message "Scribe work should complete as a playable day job."
    Assert-Equal -Actual $scribeGame.Hero.CurrencyCopper -Expected 85 -Message "Scribe work should pay its listed day-job wage."
    Assert-Equal -Actual $scribeGame.Hero.XP -Expected 0 -Message "Scribe work should not grant XP."
}

Test-LevelThreeBacklogStartsAtFirstMarketStep
Test-MarketDayJobProgressesOneStepPerRest
Test-LevelTwoGateJobUnlocksSecondStepOnlyAfterFirstCompletes
Test-NewDayJobTracksStartAtFirstStep
Test-DockAndScribeJobsArePlayable

$global:RollDiceOverride = $null

Write-Host "Day-job progression tests passed." -ForegroundColor Green
