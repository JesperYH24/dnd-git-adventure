. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Test-NightWatchReliefCompletesAndSetsStoryFlag {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Accept-TownQuest -Game $game -QuestId "guard_night_watch" | Out-Null

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

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "guard_night_watch"

    $quest = Find-TownQuest -Game $game -QuestId "guard_night_watch"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "Night Watch Relief should complete after a successful patrol."
    Assert-Equal -Actual $game.Town.StoryFlags["FoundTunnelAccess"] -Expected $true -Message "Night Watch Relief should confirm tunnel access for chapter two."
    Assert-Equal -Actual $game.Hero.XP -Expected 200 -Message "Night Watch Relief should grant 200 XP."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 180 -Message "Night Watch Relief should pay its listed copper reward."
    Assert-Equal -Actual $game.Town.Relationships["NightCaptain"] -Expected "Respectful" -Message "Finishing the patrol should improve the guard relationship."
}

Test-NightWatchReliefCompletesAndSetsStoryFlag

Write-Host "City quest tests passed." -ForegroundColor Green
