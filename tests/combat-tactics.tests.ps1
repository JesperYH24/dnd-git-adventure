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

function Test-ClassActionFlavorTextResolvesCombatTokens {
    $bard = Get-Hero -Class "Bard"
    $barbarian = Get-Hero -Class "Barbarian"
    $monster = New-TestMonster

    $mockery = Get-BardViciousMockeryFlavorText -Hero $bard -Monster $monster
    $cuttingWords = Get-BardCuttingWordsFlavorText -Hero $bard -Monster $monster
    $cuttingWordsPreventedHit = Get-BardCuttingWordsPreventedHitFlavorText -Hero $bard -Monster $monster
    $rage = Get-BarbarianRageFlavorText -Hero $barbarian
    $reckless = Get-BarbarianRecklessSwingFlavorText -Hero $barbarian -Monster $monster
    $explicitTargetLine = Resolve-CombatFlavorText -Text "{Hero} heckles {target}." -Hero $bard -Monster $monster

    Assert-True -Condition ($mockery -like "*$($bard.Name)*") -Message "Vicious Mockery flavor should include the bard's name."
    Assert-True -Condition ($cuttingWords -like "*$($bard.Name)*") -Message "Cutting Words flavor should include the bard's name."
    Assert-True -Condition ($explicitTargetLine -like "*$($bard.Name)*" -and $explicitTargetLine -like "*$($monster.definite)*") -Message "Combat flavor resolver should include hero and target names."
    Assert-True -Condition ($rage -like "*$($barbarian.Name)*" -or $rage -like "*$($barbarian.GenderPronouns.Possessive)*") -Message "Rage flavor should resolve barbarian hero tokens."
    Assert-True -Condition ($reckless -like "*$($barbarian.Name)*" -or $reckless -like "*$($barbarian.GenderPronouns.Subjective)*") -Message "Reckless flavor should resolve barbarian hero tokens."
    Assert-True -Condition ($reckless -like "*$($monster.definite)*" -or $reckless -notlike "*{target}*") -Message "Reckless flavor should resolve target tokens."
    Assert-True -Condition ($mockery -notlike "*{hero}*" -and $mockery -notlike "*{Hero}*" -and $mockery -notlike "*{target}*") -Message "Bard flavor should not leak raw combat tokens."
    Assert-True -Condition ($cuttingWords -notlike "*{hero}*" -and $cuttingWords -notlike "*{Hero}*" -and $cuttingWords -notlike "*{target}*") -Message "Cutting Words flavor should not leak raw combat tokens."
    Assert-True -Condition ($cuttingWordsPreventedHit -notlike "*{hero}*" -and $cuttingWordsPreventedHit -notlike "*{Hero}*" -and $cuttingWordsPreventedHit -notlike "*{target}*") -Message "Cutting Words payoff flavor should not leak raw combat tokens."
    Assert-True -Condition ($rage -notlike "*{hero}*" -and $rage -notlike "*{Hero}*") -Message "Rage flavor should not leak raw hero tokens."
    Assert-True -Condition ($reckless -notlike "*{hero}*" -and $reckless -notlike "*{Hero}*" -and $reckless -notlike "*{target}*") -Message "Reckless flavor should not leak raw combat tokens."
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

    Assert-Equal -Actual $attackBonus -Expected 4 -Message "A bard should be able to spend a prepared inspiration die on the current attack."
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
    Assert-Equal -Actual $blockBonus -Expected 3 -Message "A bard should be able to spend a prepared inspiration die to strengthen a block."
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

function Test-BardBonusActionCanResolveBeforeMainAction {
    Set-TestOutputStubs

    $script:responses = @("2", "M", "1", "R")
    $script:index = 0
    function global:Read-Host {
        param([string]$Prompt)

        $response = $script:responses[$script:index]
        $script:index += 1
        return $response
    }

    Set-TestRollStub {
        param([int]$Sides = 20)

        if ($Sides -eq 20) { return 5 }
        if ($Sides -eq 4) { return 3 }
        return 1
    }

    $hero = Get-Hero -Class "Bard"
    $monster = New-TestMonster
    $heroHP = $hero.HP
    $monsterHP = $monster.hp
    $heroDroppedWeapon = $false
    $monsterOffBalance = $false
    $encounterFled = $false

    Start-CombatLoop -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterHP ([ref]$monsterHP) -HeroDroppedWeapon ([ref]$heroDroppedWeapon) -MonsterOffBalance ([ref]$monsterOffBalance) -EncounterFled ([ref]$encounterFled)

    Assert-Equal -Actual $monsterHP -Expected 17 -Message "The bard should be able to use Vicious Mockery before taking the main action."
    Assert-Equal -Actual $encounterFled -Expected $true -Message "The bard should still be able to take a normal action after the bonus action menu."
}

function Test-BarbarianCanOpenBonusActionMenuAndStillAct {
    Set-TestOutputStubs

    $script:responses = @("2", "N", "1", "R")
    $script:index = 0
    function global:Read-Host {
        param([string]$Prompt)

        $response = $script:responses[$script:index]
        $script:index += 1
        return $response
    }

    $hero = Get-Hero
    $monster = New-TestMonster
    $heroHP = $hero.HP
    $monsterHP = $monster.hp
    $heroDroppedWeapon = $false
    $monsterOffBalance = $false
    $encounterFled = $false

    Start-CombatLoop -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterHP ([ref]$monsterHP) -HeroDroppedWeapon ([ref]$heroDroppedWeapon) -MonsterOffBalance ([ref]$monsterOffBalance) -EncounterFled ([ref]$encounterFled)

    Assert-Equal -Actual $encounterFled -Expected $true -Message "A barbarian should still be able to act normally after checking the future bonus action menu."
}

function Test-BarbarianRageBonusActionAddsDamage {
    Set-TestOutputStubs

    function global:Read-Host {
        param([string]$Prompt)
        return "R"
    }

    Set-TestRollStub {
        param([int]$Sides = 20)

        if ($Sides -eq 20) { return 12 }
        return 6
    }

    $hero = Get-Hero
    $monster = New-TestMonster
    $monsterHP = $monster.hp
    $heroDroppedWeapon = $false

    $usedBonusAction = Resolve-HeroBonusAction -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP)
    Invoke-HeroAttack -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) -HeroDroppedWeapon ([ref]$heroDroppedWeapon)

    Assert-Equal -Actual $usedBonusAction -Expected $true -Message "Rage should spend the barbarian's bonus action."
    Assert-Equal -Actual $hero.CurrentRages -Expected 1 -Message "Starting rage should spend one rage use."
    Assert-Equal -Actual $monsterHP -Expected 10 -Message "Rage should add +2 weapon damage to the barbarian's hit."
}

function Test-BarbarianRageReducesIncomingDamage {
    Set-TestOutputStubs

    Set-TestRollStub {
        param([int]$Sides = 20)

        if ($Sides -eq 20) { return 18 }
        return 5
    }

    $hero = Get-Hero
    Start-HeroRage -Hero $hero | Out-Null
    $monster = New-TestMonster
    $heroHP = $hero.HP
    $monsterOffBalance = $false

    Invoke-MonsterAttack -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterOffBalance ([ref]$monsterOffBalance)

    Assert-Equal -Actual $heroHP -Expected ($hero.HP - 3) -Message "Rage should halve incoming weapon damage, rounded up."
}

function Test-BarbarianRecklessAttackGrantsAdvantageForExposure {
    Set-TestOutputStubs

    function global:Read-Host {
        param([string]$Prompt)
        return "2"
    }

    $hero = Get-Hero
    $attackAdvantage = $false
    $recklessExposure = $false

    Resolve-HeroRecklessAttackChoice -Hero $hero -HeroAttackAdvantage ([ref]$attackAdvantage) -HeroRecklessExposure ([ref]$recklessExposure)

    Assert-Equal -Actual $attackAdvantage -Expected $true -Message "Reckless Attack should give advantage on the current attack roll."
    Assert-Equal -Actual $recklessExposure -Expected $true -Message "Reckless Attack should expose the barbarian to the next enemy attack."
    Assert-Equal -Actual $hero.RecklessAttackExposed -Expected $true -Message "The hero status should reflect reckless exposure."
}

function Test-BarbarianRecklessAdvantageCanTurnMissIntoHit {
    Set-TestOutputStubs

    $script:rolls = @(5, 12, 6)
    $script:rollIndex = 0
    Set-TestRollStub {
        param([int]$Sides = 20)

        $roll = $script:rolls[$script:rollIndex]
        $script:rollIndex += 1
        return $roll
    }

    $hero = Get-Hero
    $monster = New-TestMonster
    $monsterHP = $monster.hp
    $heroDroppedWeapon = $false

    Invoke-HeroAttack -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) -HeroDroppedWeapon ([ref]$heroDroppedWeapon) -Advantage $true

    Assert-Equal -Actual $monsterHP -Expected 12 -Message "Reckless advantage should use the higher d20 roll and hit when the lower roll would miss."
}

function Test-RecklessExposureGivesMonsterAdvantage {
    Set-TestOutputStubs

    $script:rolls = @(5, 18, 4)
    $script:rollIndex = 0
    Set-TestRollStub {
        param([int]$Sides = 20)

        $roll = $script:rolls[$script:rollIndex]
        $script:rollIndex += 1
        return $roll
    }

    $hero = Get-Hero
    $monster = New-TestMonster
    $heroHP = $hero.HP
    $monsterOffBalance = $false
    $blockBonus = 0
    $recklessExposure = $true

    Resolve-MonsterCombatTurn -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterOffBalance ([ref]$monsterOffBalance) -HeroBlockArmorBonus ([ref]$blockBonus) -HeroRecklessExposure ([ref]$recklessExposure)

    Assert-Equal -Actual $heroHP -Expected ($hero.HP - 4) -Message "Enemy advantage from Reckless Attack should use the higher d20 roll and land the hit."
    Assert-Equal -Actual $recklessExposure -Expected $false -Message "Reckless exposure should clear after the enemy attack resolves."
}

function Test-BarbarianLongRestRestoresRages {
    $hero = Get-Hero
    Start-HeroRage -Hero $hero | Out-Null
    Stop-HeroRage -Hero $hero

    Restore-HeroRages -Hero $hero

    Assert-Equal -Actual $hero.CurrentRages -Expected $hero.MaxRages -Message "A long rest should restore barbarian rage uses."
    Assert-Equal -Actual $hero.RageActive -Expected $false -Message "Rage should not remain active after rest."
}

function Test-MonsterInitiativeMakesMonsterActFirstInCombatLoop {
    Set-TestOutputStubs

    $script:responses = @("1", "R")
    $script:index = 0
    function global:Read-Host {
        param([string]$Prompt)

        $response = $script:responses[$script:index]
        $script:index += 1
        return $response
    }

    Set-TestRollStub {
        param([int]$Sides = 20)

        if ($Sides -eq 20) { return 15 }
        return 3
    }

    $hero = Get-Hero
    $monster = [PSCustomObject]@{
        name = "quick striker"
        definite = "The Quick Striker"
        hp = 20
        armorClass = 16
        attackBonus = 8
        damageDiceCount = 1
        damageDiceSides = 4
        damageBonus = 0
        isBoss = $false
    }
    $heroHP = $hero.HP
    $monsterHP = $monster.hp
    $heroDroppedWeapon = $false
    $monsterOffBalance = $false
    $encounterFled = $false

    Start-CombatLoop -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterHP ([ref]$monsterHP) -HeroDroppedWeapon ([ref]$heroDroppedWeapon) -MonsterOffBalance ([ref]$monsterOffBalance) -EncounterFled ([ref]$encounterFled) -HeroStarts $false

    Assert-True -Condition ($heroHP -lt $hero.HP) -Message "When the monster wins initiative, it should act before the hero can take a turn."
    Assert-Equal -Actual $encounterFled -Expected $true -Message "The hero should still be able to flee on the following turn."
}

Test-FocusBonusImprovesHeroAttack
Test-BlockRaisesArmorClassAgainstNextAttack
Test-BarbarianCritKillGetsSavageFinisherText
Test-ClassActionFlavorTextResolvesCombatTokens
Test-BardInspirationBoostsCurrentAttack
Test-BardInspirationCanBoostBlock
Test-BardViciousMockeryBonusActionDealsPsychicDamage
Test-BardViciousMockeryCanBeSavedAgainst
Test-BardCuttingWordsCanTurnHitIntoMiss
Test-BardBonusActionCanResolveBeforeMainAction
Test-BarbarianCanOpenBonusActionMenuAndStillAct
Test-BarbarianRageBonusActionAddsDamage
Test-BarbarianRageReducesIncomingDamage
Test-BarbarianRecklessAttackGrantsAdvantageForExposure
Test-BarbarianRecklessAdvantageCanTurnMissIntoHit
Test-RecklessExposureGivesMonsterAdvantage
Test-BarbarianLongRestRestoresRages
Test-MonsterInitiativeMakesMonsterActFirstInCombatLoop

Write-Host "Combat tactics tests passed." -ForegroundColor Green
$global:RollDiceOverride = $null
