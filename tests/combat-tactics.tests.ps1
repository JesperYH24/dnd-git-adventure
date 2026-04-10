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
    $global:CapturedScenes = @()
    function global:Write-TypeLine { param([string]$Text, [int]$Delay, [string]$Color) }
    function global:Write-Scene { param([string]$Text) $global:CapturedScenes += $Text }
    function global:Write-Action { param([string]$Text, [string]$Color) }
    function global:Write-ColorLine { param([string]$Text, [string]$Color) }
    function global:Write-BlinkingLine { param([string]$Text, [string]$Color1, [string]$Color2, [int]$Times) }
}

function Set-TestRollStub {
    param([scriptblock]$Body)

    $global:RollDiceOverride = $Body
}

function New-TestMonster {
    return [PSCustomObject]@{
        name = "training dummy"
        definite = "The Training Dummy"
        hp = 20
        armorClass = 16
        attackBonus = 2
        damageDiceCount = 1
        damageDiceSides = 4
        damageBonus = 0
        isBoss = $false
    }
}

function Test-FocusBonusImprovesHeroAttack {
    Set-TestOutputStubs

    Set-TestRollStub {
        param([int]$Sides = 20)

        if ($Sides -eq 20) { return 12 }
        return 6
    }

    $hero = Get-Hero
    $monster = New-TestMonster
    $monsterHP = $monster.hp
    $heroDroppedWeapon = $false

    Invoke-HeroAttack -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) -HeroDroppedWeapon ([ref]$heroDroppedWeapon) -AttackBonusModifier 2

    Assert-Equal -Actual $monsterHP -Expected 12 -Message "Focus should let Borzig land a hit that would otherwise miss."
}

function Test-BlockRaisesArmorClassAgainstNextAttack {
    Set-TestOutputStubs

    Set-TestRollStub {
        param([int]$Sides = 20)

        if ($Sides -eq 20) { return 9 }
        return 4
    }

    $hero = Get-Hero
    $monster = New-TestMonster
    $heroHP = $hero.HP
    $monsterOffBalance = $false

    Invoke-MonsterAttack -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterOffBalance ([ref]$monsterOffBalance) -BlockArmorBonus 2

    Assert-Equal -Actual $heroHP -Expected $hero.HP -Message "Block should cause the next monster attack to miss if the bonus pushes AC high enough."
}

function Test-BarbarianCritKillGetsSavageFinisherText {
    $hero = Get-Hero
    $monster = New-TestMonster
    $weapon = Get-HeroWeaponProfile -Hero $hero
    $text = Get-BarbarianCriticalKillText -Hero $hero -Monster $monster -Weapon $weapon

    if ($text -notlike "*savage finishing blow*") {
        throw "A barbarian crit kill should produce the savage finishing blow text."
    }
}

Test-FocusBonusImprovesHeroAttack
Test-BlockRaisesArmorClassAgainstNextAttack
Test-BarbarianCritKillGetsSavageFinisherText

Write-Host "Combat tactics tests passed." -ForegroundColor Green
$global:RollDiceOverride = $null
