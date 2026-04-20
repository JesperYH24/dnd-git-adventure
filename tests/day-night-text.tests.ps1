. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Test-NightShopIntroTextChangesTone {
    $game = Initialize-Game -Class "Bard"
    Set-TownTimeOfDay -Game $game -TimeOfDay "Night"

    $text = Get-TownShopIntroText -Shop "Market" -Hero $game.Hero -Game $game

    Assert-True -Condition ($text -like "*night*" -or $text -like "*lantern*") -Message "Market intro text should reflect the city after dark."
}

function Test-NightStreetNpcIntrosChangeTone {
    $game = Initialize-Game
    Set-TownTimeOfDay -Game $game -TimeOfDay "Night"

    $eliraText = Get-WidowEliraIntro -Hero $game.Hero -Game $game
    $belorText = Get-BelorIntro -Hero $game.Hero -Game $game

    Assert-True -Condition ($eliraText -like "*night*" -or $eliraText -like "*dark*") -Message "Widow Elira should acknowledge the city's night mood."
    Assert-True -Condition ($belorText -like "*Night*" -or $belorText -like "*dark*") -Message "Belor should sound like a guard actually working the night watch."
}

function Test-NightQuestSourceTextFeelsDifferent {
    $game = Initialize-Game
    Set-TownTimeOfDay -Game $game -TimeOfDay "Night"

    $guardText = Get-TownQuestSourceIntroText -Source "Guard Station" -DefaultIntroText "unused" -Game $game

    Assert-True -Condition ($guardText -like "*night*" -or $guardText -like "*lantern*" -or $guardText -like "*after dark*") -Message "Guard-station intro text should change once the city shifts to night."
}

Test-NightShopIntroTextChangesTone
Test-NightStreetNpcIntrosChangeTone
Test-NightQuestSourceTextFeelsDifferent

Write-Host "Day/night text tests passed." -ForegroundColor Green
