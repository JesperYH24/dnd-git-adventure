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
        damageMin  = 2
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

function Test-MonsterOpeningPhaseCriticalHit {
    Set-TestOutputStubs

    function global:Roll-Dice { param([int]$Sides = 20) return 20 }
    function global:Roll-Damage { param([int]$Minimum = 1, [int]$Maximum = 6) return 3 }

    $hero = New-TestHero
    $monster = New-TestMonster
    $heroHP = $hero.HP
    $monsterHP = $monster.hp
    $heroDroppedWeapon = $false
    $monsterOffBalance = $false

    $continueCombat = Start-OpeningPhase `
        -Hero $hero `
        -Monster $monster `
        -HeroHP ([ref]$heroHP) `
        -MonsterHP ([ref]$monsterHP) `
        -HeroDroppedWeapon ([ref]$heroDroppedWeapon) `
        -MonsterOffBalance ([ref]$monsterOffBalance) `
        -HeroStarts $false `
        -HeroBonusAttack $false `
        -MonsterStarts $true

    Assert-Equal -Actual $continueCombat -Expected $true -Message "Combat should continue after monster crits without lethal damage."
    Assert-Equal -Actual $heroHP -Expected 13 -Message "Monster crit in opening phase should reduce hero HP by max damage plus extra damage."
}

function Test-MonsterOpeningPhaseNormalHit {
    Set-TestOutputStubs

    function global:Roll-Dice { param([int]$Sides = 20) return 10 }
    function global:Roll-Damage { param([int]$Minimum = 1, [int]$Maximum = 6) return 3 }

    $hero = New-TestHero
    $monster = New-TestMonster
    $heroHP = $hero.HP
    $monsterHP = $monster.hp
    $heroDroppedWeapon = $false
    $monsterOffBalance = $false

    $continueCombat = Start-OpeningPhase `
        -Hero $hero `
        -Monster $monster `
        -HeroHP ([ref]$heroHP) `
        -MonsterHP ([ref]$monsterHP) `
        -HeroDroppedWeapon ([ref]$heroDroppedWeapon) `
        -MonsterOffBalance ([ref]$monsterOffBalance) `
        -HeroStarts $false `
        -HeroBonusAttack $false `
        -MonsterStarts $true

    Assert-Equal -Actual $continueCombat -Expected $true -Message "Combat should continue after a normal monster hit in opening phase."
    Assert-Equal -Actual $heroHP -Expected 17 -Message "Monster normal hit in opening phase should reduce hero HP by rolled damage."
}

Test-MonsterOpeningPhaseCriticalHit
Test-MonsterOpeningPhaseNormalHit

Write-Host "All opening phase monster attack tests passed." -ForegroundColor Green
