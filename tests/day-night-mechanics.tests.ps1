. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Test-DaytimeTownActionsShowAsClosed {
    $game = Initialize-Game

    Assert-Equal -Actual (Test-TownActionAvailableAtCurrentTime -Game $game -Action "Market") -Expected $true -Message "The market should be available during the day."
    Assert-Equal -Actual (Test-TownActionAvailableAtCurrentTime -Game $game -Action "Ring") -Expected $false -Message "The ring should stay closed until night."
    Assert-Equal -Actual (Test-TownActionAvailableAtCurrentTime -Game $game -Action "Performance") -Expected $false -Message "Paid performances should wait for the evening crowd."
}

function Test-NighttimeTownClosuresAndStreetContactsShift {
    $game = Initialize-Game
    Set-TownTimeOfDay -Game $game -TimeOfDay "Night"

    Assert-Equal -Actual (Test-TownActionAvailableAtCurrentTime -Game $game -Action "Market") -Expected $false -Message "The market should close once night falls."
    Assert-Equal -Actual (Test-TownActionAvailableAtCurrentTime -Game $game -Action "Smithy") -Expected $false -Message "The smithy should stop normal business at night."
    Assert-Equal -Actual (Test-TownActionAvailableAtCurrentTime -Game $game -Action "Ring") -Expected $true -Message "The ring should become available at night."
    Assert-Equal -Actual (Test-TownStreetContactAvailableAtCurrentTime -Game $game -ContactId "WidowElira") -Expected $false -Message "Widow Elira should not still be waiting in the street after dark."
    Assert-Equal -Actual (Test-TownStreetContactAvailableAtCurrentTime -Game $game -ContactId "Hadrik") -Expected $false -Message "Hadrik should have gone back behind the forge after dark."
    Assert-Equal -Actual (Test-TownStreetContactAvailableAtCurrentTime -Game $game -ContactId "Belor") -Expected $true -Message "Belor should remain available on the night watch."
}

function Test-DaytimePerformanceAttemptIsBlocked {
    $game = Initialize-Game -Class "Bard"

    $result = Resolve-BardPerformance -Game $game -VenueId "market_square"

    Assert-Equal -Actual $result.Success -Expected $false -Message "Performances should not run before the evening crowd forms."
    Assert-Equal -Actual $game.Town.PerformanceCountToday -Expected 0 -Message "A blocked daytime performance should not spend one of the bard's daily sets."
}

function Test-DaytimeRingVisitDoesNotConsumeAttempt {
    $game = Initialize-Game
    $game.Hero.CurrencyCopper = 200

    Start-FightingRing -Game $game

    Assert-Equal -Actual $game.Town.Ring.FoughtToday -Expected $false -Message "Checking the ring during the day should not spend the daily tournament entry."
}

Test-DaytimeTownActionsShowAsClosed
Test-NighttimeTownClosuresAndStreetContactsShift
Test-DaytimePerformanceAttemptIsBlocked
Test-DaytimeRingVisitDoesNotConsumeAttempt

Write-Host "Day/night mechanics tests passed." -ForegroundColor Green
