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
    $global:RollDiceOverride = $null
    function script:Write-TypeLine { param([string]$Text, [int]$Delay, [string]$Color) }
    function script:Write-Scene { param([string]$Text) $global:CapturedScenes += $Text }
    function script:Write-Action { param([string]$Text, [string]$Color) }
    function script:Write-ColorLine { param([string]$Text, [string]$Color) }
    function script:Write-BlinkingLine { param([string]$Text, [string]$Color1, [string]$Color2, [int]$Times) }

    if (Test-Path Function:\global:Roll-Dice) {
        Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
    }

    if (Test-Path Function:\global:Read-Host) {
        Remove-Item Function:\global:Read-Host -ErrorAction SilentlyContinue
    }
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

    Invoke-HeroAttack -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) -AttackBonusModifier 2

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

function Test-ClassCombatActionLabelsAreDistinct {
    $barbarian = Get-Hero
    $bard = Get-Hero -Class "Bard"
    $fighter = Get-Hero -Class "Fighter"

    Assert-Equal -Actual (Get-HeroBlockActionLabel -Hero $barbarian) -Expected "Block" -Message "Barbarian defensive action should keep the baseline Block label."
    Assert-Equal -Actual (Get-HeroFocusActionLabel -Hero $barbarian) -Expected "Focus" -Message "Barbarian focus action should keep the baseline Focus label."
    Assert-Equal -Actual (Get-HeroBlockActionLabel -Hero $bard) -Expected "Footwork" -Message "Bard defensive action should read as evasion, not blocking."
    Assert-Equal -Actual (Get-HeroFocusActionLabel -Hero $bard) -Expected "Set Tempo" -Message "Bard focus action should use performance-flavored wording."
    Assert-Equal -Actual (Get-HeroBlockActionLabel -Hero $fighter) -Expected "Shield Block" -Message "Fighter defensive action should emphasize the shield."
    Assert-Equal -Actual (Get-HeroFocusActionLabel -Hero $fighter) -Expected "Study Guard" -Message "Fighter focus action should read as martial discipline."
}

function Test-BardFootworkScalesWithDexterityAndProficiency {
    $barbarian = Get-Hero
    $bard = Get-Hero -Class "Bard"
    $fighter = Get-Hero -Class "Fighter"

    Assert-Equal -Actual (Get-HeroDefensiveActionArmorBonus -Hero $barbarian) -Expected 2 -Message "Barbarian Block should keep the baseline defensive bonus."
    Assert-Equal -Actual (Get-HeroDefensiveActionArmorBonus -Hero $fighter) -Expected 2 -Message "Fighter Shield Block should keep the baseline defensive bonus before riposte."
    Assert-Equal -Actual (Get-HeroDefensiveActionArmorBonus -Hero $bard) -Expected 4 -Message "Bard Footwork should add the bard's DEX modifier and proficiency bonus."

    $bard.DEX = 16
    Assert-Equal -Actual (Get-HeroDefensiveActionArmorBonus -Hero $bard) -Expected 5 -Message "Bard Footwork should improve when DEX improves."

    $bard.Level = 5
    Assert-Equal -Actual (Get-HeroDefensiveActionArmorBonus -Hero $bard) -Expected 6 -Message "Bard Footwork should improve when proficiency improves."
}

function Test-FighterShieldBlockRiposteTriggersOncePerFight {
    Set-TestOutputStubs

    $script:d20Rolls = [System.Collections.Generic.Queue[int]]::new()
    @(10, 15, 10) | ForEach-Object { $script:d20Rolls.Enqueue($_) }

    Set-TestRollStub {
        param([int]$Sides = 20)

        if ($Sides -eq 20) {
            return $script:d20Rolls.Dequeue()
        }

        if ($Sides -eq 6) {
            return 4
        }

        return 1
    }

    $hero = Get-Hero -Class "Fighter"
    $monster = New-TestMonster
    $heroHP = $hero.HP
    $monsterHP = $monster.hp
    $monsterOffBalance = $false
    $blockBonus = 2
    $recklessExposure = $false
    $riposteAvailable = $true

    Resolve-MonsterCombatTurn -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterOffBalance ([ref]$monsterOffBalance) -HeroBlockArmorBonus ([ref]$blockBonus) -HeroRecklessExposure ([ref]$recklessExposure) -MonsterHP ([ref]$monsterHP) -HeroRiposteAvailable ([ref]$riposteAvailable)

    $monsterHPAfterFirstBlock = $monsterHP
    Assert-True -Condition ($monsterHPAfterFirstBlock -lt $monster.hp) -Message "A Fighter should riposte once after a successful Shield Block."
    Assert-Equal -Actual $riposteAvailable -Expected $false -Message "Riposte should be spent after the first successful Shield Block."

    $blockBonus = 2
    Resolve-MonsterCombatTurn -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterOffBalance ([ref]$monsterOffBalance) -HeroBlockArmorBonus ([ref]$blockBonus) -HeroRecklessExposure ([ref]$recklessExposure) -MonsterHP ([ref]$monsterHP) -HeroRiposteAvailable ([ref]$riposteAvailable)

    Assert-Equal -Actual $monsterHP -Expected $monsterHPAfterFirstBlock -Message "Fighter riposte should not trigger a second time in the same fight."
}

function Test-HeroCriticalFailDealsMishapDamageAndEndsTurn {
    Set-TestOutputStubs

    Set-TestRollStub {
        param([int]$Sides = 20)

        if ($Sides -eq 20) { return 1 }
        if ($Sides -eq 4) { return 3 }
        return 1
    }

    $hero = Get-Hero
    $monster = New-TestMonster
    $monsterHP = $monster.hp
    $heroHP = $hero.HP
    $heroTurnEnded = $false

    Invoke-HeroAttack `
        -Hero $hero `
        -Monster $monster `
        -MonsterHP ([ref]$monsterHP) `
        -HeroHP ([ref]$heroHP) `
        -HeroTurnEnded ([ref]$heroTurnEnded)

    Assert-Equal -Actual $heroHP -Expected ($hero.HP - 3) -Message "A hero critical fail should deal mishap damage."
    Assert-Equal -Actual $heroTurnEnded -Expected $true -Message "A hero critical fail should end the rest of the hero's current turn."
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
    Assert-Equal -Actual $hero.CurrentBardicInspirationDice -Expected 1 -Message "Using bardic inspiration in combat should spend one prepared die."
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
    Assert-Equal -Actual $hero.CurrentBardicInspirationDice -Expected 1 -Message "Using bardic inspiration to block should spend one prepared die."
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

    Resolve-HeroBonusAction -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) | Out-Null

    Assert-Equal -Actual $monsterHP -Expected 17 -Message "Vicious Mockery should deal a small amount of psychic damage as a bonus action."
    Assert-Equal -Actual $monster.ViciousMockeryAttackDisadvantage -Expected $true -Message "Vicious Mockery should give disadvantage on the target's next attack when it lands."
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

    Resolve-HeroBonusAction -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) | Out-Null

    Assert-Equal -Actual $monsterHP -Expected 20 -Message "Vicious Mockery should deal no damage when the target passes its Wisdom save."
    Assert-True -Condition ($null -eq $monster.PSObject.Properties["ViciousMockeryAttackDisadvantage"] -or -not [bool]$monster.ViciousMockeryAttackDisadvantage) -Message "A saved-against Vicious Mockery should not weaken the next attack."
}

function Test-BardViciousMockeryTracksRepeatedCombatUseForShortText {
    Set-TestOutputStubs

    function global:Read-Host {
        param([string]$Prompt)
        return "M"
    }

    Set-TestRollStub {
        param([int]$Sides = 20)

        if ($Sides -eq 20) { return 5 }
        if ($Sides -eq 4) { return 1 }
        return 1
    }

    $hero = Get-Hero -Class "Bard"
    $monster = New-TestMonster
    $monsterHP = $monster.hp

    Resolve-HeroBonusAction -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) | Out-Null
    Resolve-HeroBonusAction -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) | Out-Null
    Resolve-HeroBonusAction -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) | Out-Null
    $briefText = Get-BardViciousMockeryFlavorText -Hero $hero -Monster $monster -Brief

    Assert-Equal -Actual $hero.ViciousMockeryUsesThisCombat -Expected 3 -Message "Repeated Vicious Mockery casts should be counted during combat."
    Assert-True -Condition ($briefText -like "*another cutting line*") -Message "Later Vicious Mockery uses should have a shorter repeat line available."
}

function Test-BardViciousMockeryWorksAtSixtyFeet {
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
    $distance = New-EncounterDistanceState -DistanceFeet 60

    Resolve-HeroBonusAction -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) -DistanceState $distance | Out-Null

    Assert-Equal -Actual $monsterHP -Expected 17 -Message "Vicious Mockery should be usable at its 60 ft range."
}

function Test-BardViciousMockeryCannotReachPastSixtyFeet {
    Set-TestOutputStubs

    $script:responses = @("M", "B")
    $script:index = 0
    function global:Read-Host {
        param([string]$Prompt)

        $response = $script:responses[$script:index]
        $script:index += 1
        return $response
    }

    Set-TestRollStub {
        param([int]$Sides = 20)
        throw "Vicious Mockery should not roll when target is out of range."
    }

    $hero = Get-Hero -Class "Bard"
    $monster = New-TestMonster
    $monsterHP = $monster.hp
    $distance = New-EncounterDistanceState -DistanceFeet 90
    $bonusCancelled = $false

    Resolve-HeroBonusAction -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) -BonusActionCancelled ([ref]$bonusCancelled) -DistanceState $distance | Out-Null

    Assert-Equal -Actual $monsterHP -Expected 20 -Message "Out-of-range Vicious Mockery should not damage the monster."
    Assert-Equal -Actual $bonusCancelled -Expected $true -Message "After an out-of-range warning, backing out should still cancel the bonus action."
}

function Test-BardViciousMockeryDisadvantageAppliesToNextMonsterAttack {
    Set-TestOutputStubs

    $script:rolls = @(17, 8)
    $script:rollIndex = 0
    Set-TestRollStub {
        param([int]$Sides = 20)

        if ($Sides -eq 20) {
            $roll = $script:rolls[$script:rollIndex]
            $script:rollIndex += 1
            return $roll
        }

        return 4
    }

    $hero = Get-Hero -Class "Bard"
    $monster = New-TestMonster
    Set-BardViciousMockeryDisadvantage -Monster $monster
    $heroHP = $hero.HP
    $monsterOffBalance = $false
    $attackResult = $null

    Invoke-MonsterAttack -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterOffBalance ([ref]$monsterOffBalance) -AttackResult ([ref]$attackResult)

    Assert-Equal -Actual $attackResult.AttackRoll -Expected 8 -Message "The next monster attack should use the lower d20 roll from Vicious Mockery disadvantage."
    Assert-Equal -Actual $attackResult.AttackTotal -Expected 10 -Message "The next monster attack should calculate from the disadvantage roll."
    Assert-Equal -Actual $attackResult.ViciousMockeryDisadvantage -Expected $true -Message "Attack result should report the consumed Vicious Mockery disadvantage."
    Assert-Equal -Actual $attackResult.AttackDisadvantage -Expected $true -Message "The attack roll should be marked as disadvantage."
    Assert-Equal -Actual $heroHP -Expected $hero.HP -Message "The mockery disadvantage should be able to turn a stronger roll into a miss."
    Assert-Equal -Actual $monster.ViciousMockeryAttackDisadvantage -Expected $false -Message "Vicious Mockery disadvantage should be consumed after the monster attacks."
}

function Test-BardViciousMockeryDisadvantageCancelsRecklessAdvantage {
    Set-TestOutputStubs

    Set-TestRollStub {
        param([int]$Sides = 20)
        return 12
    }

    $hero = Get-Hero -Class "Bard"
    $monster = New-TestMonster
    Set-BardViciousMockeryDisadvantage -Monster $monster
    $heroHP = $hero.HP
    $monsterOffBalance = $false
    $attackResult = $null

    Invoke-MonsterAttack -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterOffBalance ([ref]$monsterOffBalance) -Advantage $true -AttackResult ([ref]$attackResult)

    Assert-Equal -Actual $attackResult.AttackRoll -Expected 12 -Message "Advantage and disadvantage should cancel to a single d20 roll."
    Assert-Equal -Actual $attackResult.AttackDisadvantage -Expected $false -Message "Cancelled disadvantage should not remain marked on the roll."
    Assert-Equal -Actual $attackResult.AdvantageCancelled -Expected $true -Message "Attack result should report advantage/disadvantage cancellation."
    Assert-Equal -Actual $monster.ViciousMockeryAttackDisadvantage -Expected $false -Message "Cancelled Vicious Mockery disadvantage should still be consumed."
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
    $hero.Level = 3
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

function Test-BardCanBackOutOfBonusActionMenuWithoutSpendingIt {
    Set-TestOutputStubs

    $script:responses = @("2", "B", "2", "M", "1", "R")
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

    Assert-Equal -Actual $monsterHP -Expected 17 -Message "Backing out of the bonus action menu should leave the bonus action available."
    Assert-Equal -Actual $encounterFled -Expected $true -Message "Backing out should return to the combat menu without ending the turn."
    Assert-Equal -Actual $script:index -Expected 6 -Message "The turn should accept bonus action backout, later bonus action use, and then a normal action."
}

function Test-BardCanCastDissonantWhispersFromActionMenu {
    Set-TestOutputStubs

    $script:responses = @("1", "C", "D")
    $script:index = 0
    function global:Read-Host {
        param([string]$Prompt)

        $response = $script:responses[$script:index]
        $script:index += 1
        return $response
    }

    $script:rolls = @(5, 4, 3, 2)
    $script:rollIndex = 0
    Set-TestRollStub {
        param([int]$Sides = 20)

        $roll = $script:rolls[$script:rollIndex]
        $script:rollIndex += 1
        return $roll
    }

    $hero = Get-Hero -Class "Bard"
    $monster = New-TestMonster
    $heroHP = $hero.HP
    $monsterHP = $monster.hp
    $heroDroppedWeapon = $false
    $monsterOffBalance = $false
    $encounterFled = $false
    $heroBlockArmorBonus = 0
    $heroFocusAttackBonus = 0
    $heroRecklessExposure = $false

    Resolve-HeroCombatTurn `
        -Hero $hero `
        -Monster $monster `
        -HeroHP ([ref]$heroHP) `
        -MonsterHP ([ref]$monsterHP) `
        -HeroDroppedWeapon ([ref]$heroDroppedWeapon) `
        -MonsterOffBalance ([ref]$monsterOffBalance) `
        -EncounterFled ([ref]$encounterFled) `
        -HeroBlockArmorBonus ([ref]$heroBlockArmorBonus) `
        -HeroFocusAttackBonus ([ref]$heroFocusAttackBonus) `
        -HeroRecklessExposure ([ref]$heroRecklessExposure)

    Assert-Equal -Actual $monsterHP -Expected 11 -Message "Casting Dissonant Whispers from the action menu should damage the monster."
    Assert-Equal -Actual $monsterOffBalance -Expected $true -Message "Dissonant Whispers from the action menu should disrupt the monster on a failed save."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level1 -Expected 1 -Message "Casting Dissonant Whispers from the action menu should spend a level 1 slot."
}

function Test-BardCanCastFaerieFireFromActionMenu {
    Set-TestOutputStubs

    $script:responses = @("1", "C", "F")
    $script:index = 0
    function global:Read-Host {
        param([string]$Prompt)

        $response = $script:responses[$script:index]
        $script:index += 1
        return $response
    }

    Set-TestRollStub {
        param([int]$Sides = 20)
        return 5
    }

    $hero = Get-Hero -Class "Bard"
    $monster = New-TestMonster
    $heroHP = $hero.HP
    $monsterHP = $monster.hp
    $heroDroppedWeapon = $false
    $monsterOffBalance = $false
    $encounterFled = $false
    $heroBlockArmorBonus = 0
    $heroFocusAttackBonus = 0
    $heroRecklessExposure = $false

    Resolve-HeroCombatTurn `
        -Hero $hero `
        -Monster $monster `
        -HeroHP ([ref]$heroHP) `
        -MonsterHP ([ref]$monsterHP) `
        -HeroDroppedWeapon ([ref]$heroDroppedWeapon) `
        -MonsterOffBalance ([ref]$monsterOffBalance) `
        -EncounterFled ([ref]$encounterFled) `
        -HeroBlockArmorBonus ([ref]$heroBlockArmorBonus) `
        -HeroFocusAttackBonus ([ref]$heroFocusAttackBonus) `
        -HeroRecklessExposure ([ref]$heroRecklessExposure)

    Assert-Equal -Actual $monster.FaerieFireAttackAdvantage -Expected $true -Message "Casting Faerie Fire from the action menu should mark the monster on a failed save."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level1 -Expected 1 -Message "Casting Faerie Fire from the action menu should spend a level 1 slot."
}

function Test-BardActionSpellsUseSixtyFootRange {
    Set-TestOutputStubs

    $script:rolls = @(5, 4, 3, 2, 5)
    $script:rollIndex = 0
    Set-TestRollStub {
        param([int]$Sides = 20)

        $roll = $script:rolls[$script:rollIndex]
        $script:rollIndex += 1
        return $roll
    }

    $hero = Get-Hero -Class "Bard"
    $monster = New-TestMonster
    $monsterHP = $monster.hp
    $monsterOffBalance = $false
    $sixtyFeet = New-EncounterDistanceState -DistanceFeet 60
    $ninetyFeet = New-EncounterDistanceState -DistanceFeet 90

    $dissonance = Invoke-BardDissonantWhispers -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) -MonsterOffBalance ([ref]$monsterOffBalance) -DistanceState $sixtyFeet
    $faerieFire = Invoke-BardFaerieFire -Hero $hero -Monster $monster -DistanceState $sixtyFeet
    $slotsAfterSixty = $hero.CurrentSpellSlots.Level1
    $blockedHero = Get-Hero -Class "Bard"
    $blocked = Invoke-BardFaerieFire -Hero $blockedHero -Monster $monster -DistanceState $ninetyFeet
    $blockedDissonanceHP = $monster.hp
    $blockedDissonanceOffBalance = $false
    $blockedDissonanceHero = Get-Hero -Class "Bard"
    $blockedDissonance = Invoke-BardDissonantWhispers -Hero $blockedDissonanceHero -Monster $monster -MonsterHP ([ref]$blockedDissonanceHP) -MonsterOffBalance ([ref]$blockedDissonanceOffBalance) -DistanceState $ninetyFeet

    Assert-Equal -Actual $dissonance.Success -Expected $true -Message "Dissonant Whispers should be castable at 60 ft."
    Assert-Equal -Actual $faerieFire.Success -Expected $true -Message "Faerie Fire should be castable at 60 ft."
    Assert-Equal -Actual $slotsAfterSixty -Expected 0 -Message "The two successful ranged spells should spend the bard's two level 1 slots."
    Assert-Equal -Actual $blocked.Success -Expected $false -Message "Faerie Fire should not be castable past 60 ft."
    Assert-Equal -Actual $blockedHero.CurrentSpellSlots.Level1 -Expected 2 -Message "An out-of-range spell should not spend a slot."
    Assert-Equal -Actual $blockedDissonance.Success -Expected $false -Message "Dissonant Whispers should not be castable past 60 ft."
    Assert-Equal -Actual $blockedDissonanceHP -Expected $monster.hp -Message "Out-of-range Dissonant Whispers should not damage the monster."
    Assert-Equal -Actual $blockedDissonanceHero.CurrentSpellSlots.Level1 -Expected 2 -Message "Out-of-range Dissonant Whispers should not spend a slot."
}

function Test-FaerieFireAdvantageAppliesToNextHeroAttack {
    Set-TestOutputStubs

    $script:rolls = @(2, 12, 6)
    $script:rollIndex = 0
    Set-TestRollStub {
        param([int]$Sides = 20)

        $roll = $script:rolls[$script:rollIndex]
        $script:rollIndex += 1
        return $roll
    }

    $hero = Get-Hero -Class "Bard"
    $monster = New-TestMonster
    Set-BardFaerieFireAdvantage -Monster $monster
    $monsterHP = $monster.hp
    $heroHP = $hero.HP

    Invoke-HeroAttack -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual $monsterHP -Expected 12 -Message "Faerie Fire should let the bard use the higher d20 roll and hit."
    Assert-Equal -Actual $monster.FaerieFireAttackAdvantage -Expected $false -Message "Faerie Fire advantage should be consumed after the next hero attack."
}

function Test-BardBonusActionCanResolveAfterMainAction {
    Set-TestOutputStubs

    $script:responses = @("1", "A", "2", "M")
    $script:index = 0
    function global:Read-Host {
        param([string]$Prompt)

        $response = $script:responses[$script:index]
        $script:index += 1
        return $response
    }

    $script:rolls = @(2, 5, 3)
    $script:rollIndex = 0
    Set-TestRollStub {
        param([int]$Sides = 20)

        $roll = $script:rolls[$script:rollIndex]
        $script:rollIndex += 1
        return $roll
    }

    $hero = Get-Hero -Class "Bard"
    $monster = New-TestMonster
    $monster.hp = 3
    $heroHP = $hero.HP
    $monsterHP = $monster.hp
    $heroDroppedWeapon = $false
    $monsterOffBalance = $false
    $encounterFled = $false

    Start-CombatLoop -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterHP ([ref]$monsterHP) -HeroDroppedWeapon ([ref]$heroDroppedWeapon) -MonsterOffBalance ([ref]$monsterOffBalance) -EncounterFled ([ref]$encounterFled)

    Assert-Equal -Actual $monsterHP -Expected 0 -Message "The bard should be able to take a bonus action after using the main action."
}

function Test-HeroCanPassActionAndBonusAction {
    Set-TestOutputStubs

    $script:responses = @("1", "P", "2", "N")
    $script:index = 0
    function global:Read-Host {
        param([string]$Prompt)

        $response = $script:responses[$script:index]
        $script:index += 1
        return $response
    }

    $hero = Get-Hero -Class "Bard"
    $monster = New-TestMonster
    $heroHP = $hero.HP
    $monsterHP = $monster.hp
    $heroDroppedWeapon = $false
    $monsterOffBalance = $false
    $encounterFled = $false
    $heroBlockArmorBonus = 0
    $heroFocusAttackBonus = 0
    $heroRecklessExposure = $false

    Resolve-HeroCombatTurn `
        -Hero $hero `
        -Monster $monster `
        -HeroHP ([ref]$heroHP) `
        -MonsterHP ([ref]$monsterHP) `
        -HeroDroppedWeapon ([ref]$heroDroppedWeapon) `
        -MonsterOffBalance ([ref]$monsterOffBalance) `
        -EncounterFled ([ref]$encounterFled) `
        -HeroBlockArmorBonus ([ref]$heroBlockArmorBonus) `
        -HeroFocusAttackBonus ([ref]$heroFocusAttackBonus) `
        -HeroRecklessExposure ([ref]$heroRecklessExposure)

    Assert-Equal -Actual $heroHP -Expected $hero.HP -Message "Passing action and bonus action should not damage the hero."
    Assert-Equal -Actual $monsterHP -Expected $monster.hp -Message "Passing action and bonus action should not damage the monster."
    Assert-Equal -Actual $encounterFled -Expected $false -Message "Passing both slots should end the turn without fleeing."
    Assert-Equal -Actual $script:index -Expected 4 -Message "Passing both slots should consume the action prompt and the bonus action prompt cleanly."
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

    $usedBonusAction = Resolve-HeroBonusAction -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP)
    Invoke-HeroAttack -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP)

    Assert-Equal -Actual $usedBonusAction -Expected $true -Message "Rage should spend the barbarian's bonus action."
    Assert-Equal -Actual $hero.CurrentRages -Expected 1 -Message "Starting rage should spend one rage use."
    Assert-Equal -Actual $monsterHP -Expected 10 -Message "Rage should add +2 weapon damage to the barbarian's hit."
}

function Test-FighterSecondWindBonusActionHeals {
    Set-TestOutputStubs

    function global:Read-Host {
        param([string]$Prompt)
        return "S"
    }

    Set-TestRollStub {
        param([int]$Sides = 20)

        if ($Sides -eq 10) { return 5 }
        return 1
    }

    $hero = Get-Hero -Class "Fighter"
    $monster = New-TestMonster
    $monsterHP = $monster.hp
    $heroHP = 4

    $usedBonusAction = Resolve-HeroBonusAction -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual $usedBonusAction -Expected $true -Message "Second Wind should spend the fighter's bonus action."
    Assert-Equal -Actual $heroHP -Expected 10 -Message "Second Wind should heal 1d10 + Fighter level from the bonus action menu."
    Assert-Equal -Actual $hero.CurrentSecondWind -Expected 0 -Message "Second Wind should spend one use."
}

function Test-FighterCanOpenBonusActionMenuAndStillAct {
    Set-TestOutputStubs

    $script:responses = @("2", "N", "1", "R")
    $script:index = 0
    function global:Read-Host {
        param([string]$Prompt)

        $response = $script:responses[$script:index]
        $script:index += 1
        return $response
    }

    $hero = Get-Hero -Class "Fighter"
    $monster = New-TestMonster
    $heroHP = $hero.HP
    $monsterHP = $monster.hp
    $heroDroppedWeapon = $false
    $monsterOffBalance = $false
    $encounterFled = $false

    Start-CombatLoop -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterHP ([ref]$monsterHP) -HeroDroppedWeapon ([ref]$heroDroppedWeapon) -MonsterOffBalance ([ref]$monsterOffBalance) -EncounterFled ([ref]$encounterFled)

    Assert-Equal -Actual $encounterFled -Expected $true -Message "A fighter should still be able to act normally after checking the Second Wind menu."
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
    $hero.Level = 2
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

    Invoke-HeroAttack -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) -Advantage $true

    Assert-Equal -Actual $monsterHP -Expected 12 -Message "Reckless advantage should use the higher d20 roll and hit when the lower roll would miss."
}

function Test-LevelOneBarbarianCannotUseRecklessAttack {
    Set-TestOutputStubs

    $hero = Get-Hero
    $attackAdvantage = $false
    $recklessExposure = $false

    Resolve-HeroRecklessAttackChoice -Hero $hero -HeroAttackAdvantage ([ref]$attackAdvantage) -HeroRecklessExposure ([ref]$recklessExposure)

    Assert-Equal -Actual $attackAdvantage -Expected $false -Message "Reckless Attack should be locked until Barbarian level 2."
    Assert-Equal -Actual $recklessExposure -Expected $false -Message "A locked Reckless Attack should not expose the barbarian."
}

function Test-LevelOneBardCannotUseCuttingWords {
    Set-TestOutputStubs

    Set-TestRollStub {
        param([int]$Sides = 20)

        if ($Sides -eq 20) { return 11 }
        if ($Sides -eq 6) { return 4 }
        return 1
    }

    $hero = Get-Hero -Class "Bard"
    $monster = New-TestMonster
    $heroHP = $hero.HP
    $monsterOffBalance = $false
    Prepare-HeroBardicInspiration -Hero $hero | Out-Null

    Invoke-MonsterAttack -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterOffBalance ([ref]$monsterOffBalance)

    Assert-Equal -Actual $heroHP -Expected ($hero.HP - 1) -Message "A level 1 Bard should take the hit because Cutting Words unlocks at level 3."
    Assert-Equal -Actual $hero.CurrentBardicInspirationDice -Expected 2 -Message "Locked Cutting Words should not spend inspiration."
}

function Test-FighterActionSurgeUnlocksAtLevelTwo {
    Set-TestOutputStubs

    $script:responses = @("1", "A", "4", "1", "R")
    $script:index = 0
    function global:Read-Host {
        param([string]$Prompt)

        $response = $script:responses[$script:index]
        $script:index += 1
        return $response
    }

    Set-TestRollStub {
        param([int]$Sides = 20)

        return 2
    }

    $hero = Get-Hero -Class "Fighter"
    $hero.Level = 2
    Restore-HeroSecondWind -Hero $hero | Out-Null
    $monster = New-TestMonster
    $heroHP = $hero.HP
    $monsterHP = $monster.hp
    $heroDroppedWeapon = $false
    $monsterOffBalance = $false
    $encounterFled = $false

    Start-CombatLoop -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterHP ([ref]$monsterHP) -HeroDroppedWeapon ([ref]$heroDroppedWeapon) -MonsterOffBalance ([ref]$monsterOffBalance) -EncounterFled ([ref]$encounterFled)

    Assert-Equal -Actual $hero.CurrentActionSurges -Expected 0 -Message "Action Surge should spend its level 2 resource."
    Assert-Equal -Actual $encounterFled -Expected $true -Message "Action Surge should give the Fighter a second action in the same turn."
}

function Test-FighterImprovedCriticalAtLevelThree {
    Set-TestOutputStubs

    Set-TestRollStub {
        param([int]$Sides = 20)

        if ($Sides -eq 20) { return 19 }
        if ($Sides -eq 6) { return 4 }
        return 1
    }

    $hero = Get-Hero -Class "Fighter"
    $hero.Level = 3
    $monster = New-TestMonster
    $monsterHP = $monster.hp

    Invoke-HeroAttack -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP)

    Assert-Equal -Actual $monsterHP -Expected 8 -Message "Champion Improved Critical should crit on a natural 19 at level 3."
}

function Test-BarbarianFrenzyUnlocksAtLevelThree {
    Set-TestOutputStubs

    function global:Read-Host {
        param([string]$Prompt)
        return "F"
    }

    Set-TestRollStub {
        param([int]$Sides = 20)

        if ($Sides -eq 20) { return 12 }
        return 6
    }

    $hero = Get-Hero
    $hero.Level = 3
    Start-HeroRage -Hero $hero | Out-Null
    $monster = New-TestMonster
    $monsterHP = $monster.hp

    $usedBonusAction = Resolve-HeroBonusAction -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP)

    Assert-Equal -Actual $usedBonusAction -Expected $true -Message "Frenzy should spend the bonus action once rage is active at level 3."
    Assert-Equal -Actual $hero.FrenzyUsedThisRage -Expected $true -Message "Frenzy should mark the rage's extra attack as used."
    Assert-Equal -Actual $monsterHP -Expected 10 -Message "Frenzy should make one rage-boosted weapon attack."
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

function Test-EncounterDistanceMovementBands {
    $distance = New-EncounterDistanceState -DistanceFeet 60 -HeroSpeedFeet 30 -MonsterSpeedFeet 30 -MeleeRangeFeet 5 -MaxDistanceFeet 120

    Assert-Equal -Actual $distance.DistanceFeet -Expected 60 -Message "Open encounters should be able to start at far range."
    Assert-Equal -Actual (Get-EncounterDistanceBandText -DistanceState $distance) -Expected "Far" -Message "60 ft should read as far range."
    Assert-Equal -Actual (Test-EncounterInMeleeRange -DistanceState $distance) -Expected $false -Message "60 ft should not be melee range."

    Move-EncounterDistance -DistanceState $distance -Direction "Close" -Feet 30 | Out-Null
    Assert-Equal -Actual $distance.DistanceFeet -Expected 30 -Message "A normal 30 ft move should close from 60 ft to 30 ft."
    Assert-Equal -Actual (Get-EncounterDistanceBandText -DistanceState $distance) -Expected "Near" -Message "30 ft should read as near range."

    Move-EncounterDistance -DistanceState $distance -Direction "Close" -Feet 30 | Out-Null
    Assert-Equal -Actual $distance.DistanceFeet -Expected 5 -Message "Closing distance should stop at melee range instead of going below it."
    Assert-Equal -Actual (Test-EncounterInMeleeRange -DistanceState $distance) -Expected $true -Message "5 ft should count as melee range."

    Move-EncounterDistance -DistanceState $distance -Direction "Retreat" -Feet 60 | Out-Null
    Assert-Equal -Actual $distance.DistanceFeet -Expected 65 -Message "Retreating from melee by 60 ft should open distance to 65 ft."
    Assert-Equal -Actual (Get-EncounterDistanceBandText -DistanceState $distance) -Expected "Distant" -Message "More than 60 ft should read as distant."

    Move-EncounterDistance -DistanceState $distance -Direction "Retreat" -Feet 300 | Out-Null
    Assert-Equal -Actual $distance.DistanceFeet -Expected 120 -Message "Distance should respect the encounter's maximum range."
}

Test-FocusBonusImprovesHeroAttack
Test-BlockRaisesArmorClassAgainstNextAttack
Test-ClassCombatActionLabelsAreDistinct
Test-BardFootworkScalesWithDexterityAndProficiency
Test-FighterShieldBlockRiposteTriggersOncePerFight
Test-HeroCriticalFailDealsMishapDamageAndEndsTurn
Test-BarbarianCritKillGetsSavageFinisherText
Test-ClassActionFlavorTextResolvesCombatTokens
Test-BardInspirationBoostsCurrentAttack
Test-BardInspirationCanBoostBlock
Test-BardViciousMockeryBonusActionDealsPsychicDamage
Test-BardViciousMockeryCanBeSavedAgainst
Test-BardViciousMockeryTracksRepeatedCombatUseForShortText
Test-BardViciousMockeryWorksAtSixtyFeet
Test-BardViciousMockeryCannotReachPastSixtyFeet
Test-BardViciousMockeryDisadvantageAppliesToNextMonsterAttack
Test-BardViciousMockeryDisadvantageCancelsRecklessAdvantage
Test-BardCuttingWordsCanTurnHitIntoMiss
Test-BardBonusActionCanResolveBeforeMainAction
Test-BardCanBackOutOfBonusActionMenuWithoutSpendingIt
Test-BardCanCastDissonantWhispersFromActionMenu
Test-BardCanCastFaerieFireFromActionMenu
Test-BardActionSpellsUseSixtyFootRange
Test-FaerieFireAdvantageAppliesToNextHeroAttack
Test-BardBonusActionCanResolveAfterMainAction
Test-HeroCanPassActionAndBonusAction
Test-BarbarianCanOpenBonusActionMenuAndStillAct
Test-BarbarianRageBonusActionAddsDamage
Test-FighterSecondWindBonusActionHeals
Test-FighterCanOpenBonusActionMenuAndStillAct
Test-BarbarianRageReducesIncomingDamage
Test-BarbarianRecklessAttackGrantsAdvantageForExposure
Test-BarbarianRecklessAdvantageCanTurnMissIntoHit
Test-LevelOneBarbarianCannotUseRecklessAttack
Test-LevelOneBardCannotUseCuttingWords
Test-FighterActionSurgeUnlocksAtLevelTwo
Test-FighterImprovedCriticalAtLevelThree
Test-BarbarianFrenzyUnlocksAtLevelThree
Test-RecklessExposureGivesMonsterAdvantage
Test-BarbarianLongRestRestoresRages
Test-MonsterInitiativeMakesMonsterActFirstInCombatLoop
Test-EncounterDistanceMovementBands

Write-Host "Combat tactics tests passed." -ForegroundColor Green
$global:RollDiceOverride = $null
if (Test-Path Function:\global:Read-Host) {
    Remove-Item Function:\global:Read-Host -ErrorAction SilentlyContinue
}
if (Test-Path Function:\global:Roll-Dice) {
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
}
