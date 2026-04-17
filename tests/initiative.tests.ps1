. "$PSScriptRoot\..\setup.ps1"

function Assert-Equal {
    param(
        $Actual,
        $Expected,
        [string]$Message
    )

    if ($Actual -ne $Expected) {
        throw "$Message Expected: $Expected, Actual: $Actual"
    }
}

function New-TestHero {
    return [PSCustomObject]@{
        Name = "Test Hero"
        DEX = 14
    }
}

function New-TestMonster {
    return @{
        definite = "The Test Monster"
        initiativeBonus = 1
    }
}

function Set-TestOutputStubs {
    function global:Write-TypeLine { param([string]$Text, [int]$Delay, [string]$Color) }
    function global:Write-Scene { param([string]$Text) }
    function global:Write-Action { param([string]$Text, [string]$Color) }
    function global:Write-ColorLine { param([string]$Text, [string]$Color) }
    function global:Write-BlinkingLine { param([string]$Text, [string]$Color1, [string]$Color2, [int]$Times) }
}

function Set-TestRollStub {
    param([scriptblock]$Body)

    $global:RollDiceOverride = $Body
}

function Test-NaturalTwentyAlwaysLetsHeroStart {
    Set-TestOutputStubs

    $script:rollIndex = 0
    Set-TestRollStub {
        param([int]$Sides = 20)

        $script:rollIndex += 1
        if ($script:rollIndex -eq 1) { return 20 }
        return 19
    }

    $heroStarts = $false
    $monsterStarts = $false

    Start-DetectionPhase `
        -Hero (New-TestHero) `
        -Monster (New-TestMonster) `
        -HeroStarts ([ref]$heroStarts) `
        -MonsterStarts ([ref]$monsterStarts)

    Assert-Equal -Actual $heroStarts -Expected $true -Message "A natural 20 should always let the hero start."
    Assert-Equal -Actual $monsterStarts -Expected $false -Message "A natural 20 should prevent the monster from starting."
}

function Test-MonsterCanWinOpposedInitiative {
    Set-TestOutputStubs

    $script:rollIndex = 0
    Set-TestRollStub {
        param([int]$Sides = 20)

        $script:rollIndex += 1
        if ($script:rollIndex -eq 1) { return 7 }
        return 15
    }

    $heroStarts = $false
    $monsterStarts = $false

    Start-DetectionPhase `
        -Hero (New-TestHero) `
        -Monster (New-TestMonster) `
        -HeroStarts ([ref]$heroStarts) `
        -MonsterStarts ([ref]$monsterStarts)

    Assert-Equal -Actual $heroStarts -Expected $false -Message "The hero should not start when the monster wins initiative."
    Assert-Equal -Actual $monsterStarts -Expected $true -Message "The monster should start when it wins the opposed initiative roll."
}

Test-NaturalTwentyAlwaysLetsHeroStart
Test-MonsterCanWinOpposedInitiative

Write-Host "Initiative tests passed." -ForegroundColor Green
$global:RollDiceOverride = $null
