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

function Set-TestOutputStubs {
    function global:Write-TypeLine { param([string]$Text, [int]$Delay, [string]$Color) }
    function global:Write-Scene { param([string]$Text) }
    function global:Write-Action { param([string]$Text, [string]$Color) }
    function global:Write-ColorLine { param([string]$Text, [string]$Color) }
    function global:Write-BlinkingLine { param([string]$Text, [string]$Color1, [string]$Color2, [int]$Times) }
}

function New-TestBarbarian {
    return [PSCustomObject]@{
        Name = "Borzig"
        Class = "Barbarian"
        STR = 15
        DEX = 14
        CON = 15
        INT = 8
        WIS = 10
        CHA = 8
        HP = 14
        BaseArmorClass = 10
        BaseInventorySlots = 4
        Inventory = @()
    }
}

function New-TestMonster {
    return @{
        definite = "The Test Monster"
        attackBonus = 0
        strengthCheckBonus = 0
        damageDiceCount = 1
        damageDiceSides = 4
        damageBonus = 0
        armorClass = 10
        hp = 10
        isBoss = $false
    }
}

function Test-BarbarianCanRecoverFromDroppedWeaponWithGrapple {
    Set-TestOutputStubs

    function global:Read-Host {
        param([string]$Prompt)
        return "G"
    }

    $script:rollIndex = 0
    function global:Roll-Dice {
        param([int]$Sides = 20)

        $script:rollIndex += 1
        if ($script:rollIndex -eq 1) { return 15 }
        return 8
    }

    $hero = New-TestBarbarian
    $monster = New-TestMonster
    $heroHP = $hero.HP
    $heroDroppedWeapon = $true
    $monsterOffBalance = $false

    Resolve-DroppedWeaponTurn `
        -Hero $hero `
        -Monster $monster `
        -HeroHP ([ref]$heroHP) `
        -HeroDroppedWeapon ([ref]$heroDroppedWeapon) `
        -MonsterOffBalance ([ref]$monsterOffBalance)

    Assert-Equal -Actual $heroDroppedWeapon -Expected $false -Message "A successful barbarian grapple should recover the dropped weapon."
    Assert-Equal -Actual $monsterOffBalance -Expected $true -Message "A successful barbarian grapple should leave the monster off balance."
    Assert-Equal -Actual $heroHP -Expected 14 -Message "A successful barbarian grapple should prevent immediate damage."
}

Test-BarbarianCanRecoverFromDroppedWeaponWithGrapple

Write-Host "Barbarian drop recovery tests passed." -ForegroundColor Green
