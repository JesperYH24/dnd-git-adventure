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
        Name               = "Test Hero"
        Class              = "Tester"
        HP                 = 20
        BaseArmorClass     = 10
        BaseInventorySlots = 4
        Inventory          = @()
    }
}

function New-TestMonster {
    return @{
        name      = "testmonster"
        definite  = "Test Dragon"
        hp        = 50
        armorClass = 16
        attackBonus = 0
        damageDiceCount = 1
        damageDiceSides = 12
        damageBonus = 0
        damageMin = 1
        damageMax = 12
        isBoss    = $true
    }
}

function Set-TestOutputStubs {
    function global:Write-TypeLine { param([string]$Text, [int]$Delay, [string]$Color) }
    function global:Write-Scene { param([string]$Text) }
    function global:Write-Action { param([string]$Text, [string]$Color) }
    function global:Write-ColorLine { param([string]$Text, [string]$Color) }
    function global:Write-BlinkingLine { param([string]$Text, [string]$Color1, [string]$Color2, [int]$Times) }
}

function Test-MonsterFirstTurnStateSync {
    Set-TestOutputStubs

    $global:RollDiceOverride = {
        param([int]$Sides = 20)

        if ($Sides -eq 20) { return 18 }
        if ($Sides -eq 12) { return 11 }
        return $Sides
    }
    $game = @{
        Hero = New-TestHero
        Monster = New-TestMonster
        HeroHP = 20
        MonsterHP = 50
        MonsterOffBalance = $false
        HeroBlockArmorBonus = 0
    }

    $heroHP = $game.HeroHP
    $monsterOffBalance = $game.MonsterOffBalance
    $heroBlockArmorBonus = $game.HeroBlockArmorBonus

    Resolve-MonsterCombatTurn `
        -Hero $game.Hero `
        -Monster $game.Monster `
        -HeroHP ([ref]$heroHP) `
        -MonsterOffBalance ([ref]$monsterOffBalance) `
        -HeroBlockArmorBonus ([ref]$heroBlockArmorBonus)

    $game.HeroHP = $heroHP
    $game.MonsterOffBalance = $monsterOffBalance
    $game.HeroBlockArmorBonus = $heroBlockArmorBonus

    Assert-Equal -Actual $game.HeroHP -Expected 9 -Message "Adventure state should keep the reduced hero HP after a monster-first turn."

    $global:RollDiceOverride = $null
}

Test-MonsterFirstTurnStateSync

Write-Host "Adventure state sync tests passed." -ForegroundColor Green
