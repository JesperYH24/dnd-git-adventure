. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Test-HeroNarrativeTokensUseCurrentUiHero {
    $game = Initialize-Game -Class "Bard"

    $text = Resolve-UiHeroText -Text "{Hero} checks {his} route as a {class}, then Borzig steps forward."

    Assert-Equal -Actual $text -Expected "Gariand checks his route as a bard, then Gariand steps forward." -Message "UI narrative tokens and legacy Borzig text should resolve to the active hero."
}

function Test-ClassNarrativeTextChoosesClassBranch {
    $game = Initialize-Game -Class "Bard"

    $text = Get-ClassNarrativeText -Hero $game.Hero -DefaultText "{Hero} forces the issue." -ClassText @{
        Bard = "{Hero} turns the room with a careful phrase."
    }

    Assert-Equal -Actual $text -Expected "Gariand turns the room with a careful phrase." -Message "Class narrative text should choose the matching class branch."
}

function Test-ClassNarrativeTextFallsBackForFutureClass {
    $hero = [PSCustomObject]@{
        Name = "Nyra"
        Class = "Rogue"
        Pronouns = @{
            Subject = "she"
            Object = "her"
            Possessive = "her"
            Reflexive = "herself"
        }
    }

    $text = Get-ClassNarrativeText -Hero $hero -DefaultText "{Hero} trusts {his} read of the room and keeps {himself} ready." -ClassText @{
        Bard = "{Hero} makes the room listen."
    }

    Assert-Equal -Actual $text -Expected "Nyra trusts her read of the room and keeps herself ready." -Message "Unknown future classes should use tokenized default text instead of a hardcoded existing class branch."
}

Test-HeroNarrativeTokensUseCurrentUiHero
Test-ClassNarrativeTextChoosesClassBranch
Test-ClassNarrativeTextFallsBackForFutureClass

Write-Host "Narrative text tests passed." -ForegroundColor Green
