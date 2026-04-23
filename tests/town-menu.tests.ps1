. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Set-TestReadHostSequence {
    param([string[]]$Values)

    $script:ReadHostSequence = @($Values)
    $script:ReadHostIndex = 0

    function global:Read-Host {
        param([string]$Prompt)

        if ($script:ReadHostIndex -ge $script:ReadHostSequence.Count) {
            throw "Read-Host was called more times than the test expected."
        }

        $value = $script:ReadHostSequence[$script:ReadHostIndex]
        $script:ReadHostIndex += 1
        return $value
    }
}

function Test-TownMainMenuUsesSubmenus {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Town.MustChooseFirstInn = $false
    $game.Town.ChapterOneComplete = $true
    Set-TestReadHostSequence -Values @("2", "0", "3", "0", "5", "0", "0")

    $result = Start-TownMenu -Game $game -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual $result -Expected "EndGame" -Message "The town menu should still exit normally after entering and leaving its core submenus."
    Assert-Equal -Actual $script:ReadHostIndex -Expected 7 -Message "The town main menu should route through shops, work, and character submenus without extra prompts."
}

Test-TownMainMenuUsesSubmenus

Write-Host "Town menu tests passed." -ForegroundColor Green
