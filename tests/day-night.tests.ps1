. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Test-TutorialCompletionPushesTownToNight {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Complete-TutorialAndEnterTown -Game $game -HeroHP ([ref]$heroHP) -DebugSkip $true | Out-Null

    Assert-Equal -Actual $game.Town.TimeOfDay -Expected "Night" -Message "Completing the tutorial should push the city into its first mandatory night."
    Assert-Equal -Actual $game.Town.MustChooseFirstInn -Expected $true -Message "Tutorial completion should still require the first inn night."
}

function Test-NightQuestWaitsForNightfallWhenStartedEarly {
    $game = Initialize-Game
    Accept-TownQuest -Game $game -QuestId "guard_night_watch" | Out-Null

    $result = Start-TownQuestAttempt -Game $game -QuestId "guard_night_watch"

    Assert-Equal -Actual $result.Success -Expected $true -Message "Night quests should still be startable from daytime once Borzig waits for nightfall."
    Assert-Equal -Actual $game.Town.TimeOfDay -Expected "Night" -Message "Starting a night quest from daytime should advance the town clock to night."
    Assert-Equal -Actual $game.Town.StoryQuestDoneToday -Expected $true -Message "The story slot should still be consumed when the night quest begins."
}

function Test-DayJobStaysLockedAtNightUntilMorning {
    $game = Initialize-Game
    Set-TownTimeOfDay -Game $game -TimeOfDay "Night"
    Accept-TownQuest -Game $game -QuestId "dayjob_market_delivery" | Out-Null

    $result = Start-TownQuestAttempt -Game $game -QuestId "dayjob_market_delivery"

    Assert-Equal -Actual $result.Success -Expected $false -Message "Day jobs should stay unavailable once night has already fallen."
    Assert-True -Condition ($result.Message -like "*morning*") -Message "Night-time day-job lock text should tell the player to come back in the morning."
    Assert-Equal -Actual $game.Town.DayJobDoneToday -Expected $false -Message "A blocked day job should not consume the daily side-job slot."
}

Test-TutorialCompletionPushesTownToNight
Test-NightQuestWaitsForNightfallWhenStartedEarly
Test-DayJobStaysLockedAtNightUntilMorning

Write-Host "Day/night tests passed." -ForegroundColor Green
