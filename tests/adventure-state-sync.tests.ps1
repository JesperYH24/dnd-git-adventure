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
        damageMin = 8
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

function Test-OpeningPhaseStateSync {
    Set-TestOutputStubs

    function global:Roll-Dice { param([int]$Sides = 20) return 18 }
    function global:Roll-Damage { param([int]$Minimum = 1, [int]$Maximum = 6) return 11 }

    $game = @{
        Hero = New-TestHero
        Monster = New-TestMonster
        HeroHP = 20
        MonsterHP = 50
        HeroDroppedWeapon = $false
        MonsterOffBalance = $false
        HeroStarts = $false
        HeroBonusAttack = $false
        MonsterStarts = $true
    }

    $heroHP = $game.HeroHP
    $monsterHP = $game.MonsterHP
    $heroDroppedWeapon = $game.HeroDroppedWeapon
    $monsterOffBalance = $game.MonsterOffBalance

    $continueCombat = Start-OpeningPhase `
        -Hero $game.Hero `
        -Monster $game.Monster `
        -HeroHP ([ref]$heroHP) `
        -MonsterHP ([ref]$monsterHP) `
        -HeroDroppedWeapon ([ref]$heroDroppedWeapon) `
        -MonsterOffBalance ([ref]$monsterOffBalance) `
        -HeroStarts $game.HeroStarts `
        -HeroBonusAttack $game.HeroBonusAttack `
        -MonsterStarts $game.MonsterStarts

    $game.HeroHP = $heroHP
    $game.MonsterHP = $monsterHP
    $game.HeroDroppedWeapon = $heroDroppedWeapon
    $game.MonsterOffBalance = $monsterOffBalance

    Assert-Equal -Actual $continueCombat -Expected $true -Message "Combat should continue after the opening monster attack."
    Assert-Equal -Actual $game.HeroHP -Expected 9 -Message "Adventure state should keep the reduced hero HP after a monster-first opening attack."
}

Test-OpeningPhaseStateSync

Write-Host "Adventure state sync tests passed." -ForegroundColor Green
