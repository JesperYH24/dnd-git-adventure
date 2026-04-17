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
        name       = "testmonster"
        definite   = "The Test Monster"
        hp         = 10
        armorClass = 10
        attackBonus = 0
        damageDiceCount = 1
        damageDiceSides = 4
        damageBonus = 0
        damageMin  = 1
        damageMax  = 4
        isBoss     = $false
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

function Test-MonsterFirstTurnCriticalHit {
    Set-TestOutputStubs

    Set-TestRollStub {
        param([int]$Sides = 20)

        if ($Sides -eq 20) { return 20 }
        return $Sides
    }

    $hero = New-TestHero
    $monster = New-TestMonster
    $heroHP = $hero.HP
    $monsterOffBalance = $false
    $heroBlockArmorBonus = 0

    Resolve-MonsterCombatTurn `
        -Hero $hero `
        -Monster $monster `
        -HeroHP ([ref]$heroHP) `
        -MonsterOffBalance ([ref]$monsterOffBalance) `
        -HeroBlockArmorBonus ([ref]$heroBlockArmorBonus)

    Assert-Equal -Actual $heroHP -Expected 12 -Message "Monster crit on a monster-first turn should deal max die plus a fresh damage roll."
}

function Test-MonsterFirstTurnNormalHit {
    Set-TestOutputStubs

    Set-TestRollStub {
        param([int]$Sides = 20)

        if ($Sides -eq 20) { return 10 }
        return $Sides
    }

    $hero = New-TestHero
    $monster = New-TestMonster
    $heroHP = $hero.HP
    $monsterOffBalance = $false
    $heroBlockArmorBonus = 0

    Resolve-MonsterCombatTurn `
        -Hero $hero `
        -Monster $monster `
        -HeroHP ([ref]$heroHP) `
        -MonsterOffBalance ([ref]$monsterOffBalance) `
        -HeroBlockArmorBonus ([ref]$heroBlockArmorBonus)

    Assert-Equal -Actual $heroHP -Expected 16 -Message "Monster normal hit on a monster-first turn should reduce hero HP by rolled damage."
}

Test-MonsterFirstTurnCriticalHit
Test-MonsterFirstTurnNormalHit

Write-Host "All monster-first turn tests passed." -ForegroundColor Green
$global:RollDiceOverride = $null
