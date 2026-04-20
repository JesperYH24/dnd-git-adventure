. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Test-LanternRestAmbientTextShiftsBetweenDayAndNight {
    $game = Initialize-Game -Class "Bard"
    $game.Town.ActiveInn = (Get-TownInns | Where-Object { $_.Id -eq "lantern_rest" } | Select-Object -First 1)

    Set-TownTimeOfDay -Game $game -TimeOfDay "Day"
    $game.Town.InnFlags["InnAmbientIndex_lantern_rest"] = 0
    $dayText = Get-InnAmbientVisitText -Game $game -Inn $game.Town.ActiveInn

    Set-TownTimeOfDay -Game $game -TimeOfDay "Night"
    $game.Town.InnFlags["InnAmbientIndex_lantern_rest"] = 0
    $nightText = Get-InnAmbientVisitText -Game $game -Inn $game.Town.ActiveInn

    Assert-True -Condition ($dayText -like "*meal*" -or $dayText -like "*bread*" -or $dayText -like "*day*") -Message "Lantern Rest daytime ambient text should feel like food and daylight trade."
    Assert-True -Condition ($nightText -like "*tonight*" -or $nightText -like "*travelers*" -or $nightText -like "*room*") -Message "Lantern Rest nighttime ambient text should feel like evening room energy."
}

function Test-BentNailDiningRoomGetsDaytimeMealFlavor {
    $game = Initialize-Game
    $game.Town.ActiveInn = (Get-TownInns | Where-Object { $_.Id -eq "bent_nail" } | Select-Object -First 1)
    Set-TownTimeOfDay -Game $game -TimeOfDay "Day"
    $game.Town.InnFlags["InnAmbientIndex_bent_nail"] = 0

    $text = Get-InnAmbientVisitText -Game $game -Inn $game.Town.ActiveInn

    Assert-True -Condition ($text -like "*stew*" -or $text -like "*bread*" -or $text -like "*daylight*") -Message "Bent Nail daytime flavor should read like rough food and working-hour recovery."
}

function Test-InnkeeperConversationServiceChangesBetweenDayAndNight {
    $game = Initialize-Game
    $game.Town.ActiveInn = (Get-TownInns | Where-Object { $_.Id -eq "silver_kettle" } | Select-Object -First 1)

    Set-TownTimeOfDay -Game $game -TimeOfDay "Day"
    $dayText = Format-InnConversationText -Game $game -Topic "Rumor" -Line "Test line."

    Set-TownTimeOfDay -Game $game -TimeOfDay "Night"
    $nightText = Format-InnConversationText -Game $game -Topic "Rumor" -Line "Test line."

    Assert-True -Condition ($dayText -like "*Luncheon*" -or $dayText -like "*tea*" -or $dayText -like "*light course*") -Message "Daytime innkeeper talk should frame the conversation around daytime service."
    Assert-True -Condition ($nightText -like "*Wine*" -or $nightText -like "*dinner*" -or $nightText -like "*silver*") -Message "Night innkeeper talk should frame the conversation around evening service."
}

Test-LanternRestAmbientTextShiftsBetweenDayAndNight
Test-BentNailDiningRoomGetsDaytimeMealFlavor
Test-InnkeeperConversationServiceChangesBetweenDayAndNight

Write-Host "Inn day/night text tests passed." -ForegroundColor Green
