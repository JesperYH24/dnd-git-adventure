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

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
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

function Test-BardInspirationBoostsCurrentAttack {
    Set-TestOutputStubs

    function global:Read-Host {
        param([string]$Prompt)
        return "1"
    }

    Set-TestRollStub {
        param([int]$Sides = 20)

        if ($Sides -eq 6) { return 4 }
        return 11
    }

    $hero = Get-Hero -Class "Bard"
    $attackBonus = 0
    $blockBonus = 0
    $focusBonus = 0
    Prepare-HeroBardicInspiration -Hero $hero | Out-Null

    Resolve-HeroInspirationBoost `
        -Hero $hero `
        -PrimaryAction "A" `
        -HeroAttackBonus ([ref]$attackBonus) `
        -HeroBlockArmorBonus ([ref]$blockBonus) `
        -HeroFocusAttackBonus ([ref]$focusBonus)

    Assert-Equal -Actual $attackBonus -Expected 5 -Message "A bard should be able to spend a prepared inspiration die plus instrument bonus on the current attack."
    Assert-Equal -Actual $hero.CurrentBardicInspirationDice -Expected 2 -Message "Using bardic inspiration in combat should spend one prepared die."
    Assert-Equal -Actual $blockBonus -Expected 0 -Message "Attack inspiration should not improve block."
    Assert-Equal -Actual $focusBonus -Expected 0 -Message "Current-round Inspire should not spill into future attacks."
}

function Test-BardInspirationCanBoostBlock {
    Set-TestOutputStubs

    function global:Read-Host {
        param([string]$Prompt)
        return "1"
    }

    Set-TestRollStub {
        param([int]$Sides = 20)

        if ($Sides -eq 6) { return 3 }
        return 1
    }

    $hero = Get-Hero -Class "Bard"
    $attackBonus = 0
    $blockBonus = 0
    $focusBonus = 0
    Prepare-HeroBardicInspiration -Hero $hero | Out-Null

    Resolve-HeroInspirationBoost `
        -Hero $hero `
        -PrimaryAction "B" `
        -HeroAttackBonus ([ref]$attackBonus) `
        -HeroBlockArmorBonus ([ref]$blockBonus) `
        -HeroFocusAttackBonus ([ref]$focusBonus)

    Assert-Equal -Actual $attackBonus -Expected 0 -Message "Block inspiration should not boost attack."
    Assert-Equal -Actual $blockBonus -Expected 4 -Message "A bard should be able to spend a prepared inspiration die plus instrument bonus to strengthen a block."
    Assert-Equal -Actual $hero.CurrentBardicInspirationDice -Expected 2 -Message "Using bardic inspiration to block should spend one prepared die."
}

function Test-BardViciousMockeryBonusActionDealsPsychicDamage {
    Set-TestOutputStubs

    function global:Read-Host {
        param([string]$Prompt)
        return "M"
    }

    Set-TestRollStub {
        param([int]$Sides = 20)

        if ($Sides -eq 20) { return 5 }
        if ($Sides -eq 4) { return 3 }
        return 1
    }

    $hero = Get-Hero -Class "Bard"
    $monster = New-TestMonster
    $monsterHP = $monster.hp

    Resolve-HeroBonusAction -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP)

    Assert-Equal -Actual $monsterHP -Expected 17 -Message "Vicious Mockery should deal a small amount of psychic damage as a bonus action."
}

function Test-BardViciousMockeryCanBeSavedAgainst {
    Set-TestOutputStubs

    function global:Read-Host {
        param([string]$Prompt)
        return "M"
    }

    Set-TestRollStub {
        param([int]$Sides = 20)

        if ($Sides -eq 20) { return 18 }
        if ($Sides -eq 4) { return 3 }
        return 1
    }

    $hero = Get-Hero -Class "Bard"
    $monster = New-TestMonster
    $monsterHP = $monster.hp

    Resolve-HeroBonusAction -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP)

    Assert-Equal -Actual $monsterHP -Expected 20 -Message "Vicious Mockery should deal no damage when the target passes its Wisdom save."
}

function Test-BardCuttingWordsCanTurnHitIntoMiss {
    Set-TestOutputStubs

    function global:Read-Host {
        param([string]$Prompt)
        return "1"
    }

    Set-TestRollStub {
        param([int]$Sides = 20)

        if ($Sides -eq 6) { return 4 }
        return 11
    }

    $hero = Get-Hero -Class "Bard"
    $monster = New-TestMonster
    $heroHP = $hero.HP
    $monsterOffBalance = $false
    Prepare-HeroBardicInspiration -Hero $hero | Out-Null

    Invoke-MonsterAttack -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterOffBalance ([ref]$monsterOffBalance)

    Assert-Equal -Actual $heroHP -Expected $hero.HP -Message "Cutting Words should be able to turn a hit into a miss."
    Assert-Equal -Actual $hero.CurrentBardicInspirationDice -Expected 2 -Message "Cutting Words should consume one bardic inspiration die."
}

Test-FocusBonusImprovesHeroAttack
Test-BlockRaisesArmorClassAgainstNextAttack
Test-BarbarianCritKillGetsSavageFinisherText
Test-BardInspirationBoostsCurrentAttack
Test-BardInspirationCanBoostBlock
Test-BardViciousMockeryBonusActionDealsPsychicDamage
Test-BardViciousMockeryCanBeSavedAgainst
Test-BardCuttingWordsCanTurnHitIntoMiss

Write-Host "Combat tactics tests passed." -ForegroundColor Green
$global:RollDiceOverride = $null
