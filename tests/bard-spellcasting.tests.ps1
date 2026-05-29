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

function New-TestSpellMonster {
    return [PSCustomObject]@{
        name = "training dummy"
        definite = "The Training Dummy"
        hp = 20
        armorClass = 16
        attackBonus = 2
        damageDiceCount = 1
        damageDiceSides = 4
        damageBonus = 0
        wisdomSaveBonus = 0
        isBoss = $false
    }
}

function Test-BardStartsWithSpellcastingState {
    $hero = Get-Hero -Class "Bard"

    Assert-Equal -Actual $hero.CantripsKnown -Expected 2 -Message "A level 1 bard should know two cantrips."
    Assert-Equal -Actual $hero.SpellsKnown -Expected 4 -Message "A level 1 bard should know four slotted spells."
    Assert-Equal -Actual $hero.MaxSpellSlots.Level1 -Expected 2 -Message "A level 1 bard should have two level 1 spell slots."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level1 -Expected 2 -Message "A new bard should start with full level 1 spell slots."
    Assert-Equal -Actual $hero.MaxSpellSlots.Level2 -Expected 0 -Message "A level 1 bard should not have level 2 spell slots."
    Assert-True -Condition (@($hero.KnownSpells).Name -contains "Vicious Mockery") -Message "The bard should know Vicious Mockery as a cantrip."
    Assert-True -Condition (@($hero.KnownSpells).Name -contains "Healing Word") -Message "The bard should know Healing Word for the future combat-sustain pass."
}

function Test-BardSpellcastingProgressionScalesByLevel {
    $hero = Get-Hero -Class "Bard"

    $hero.Level = 2
    Initialize-HeroSpellcasting -Hero $hero | Out-Null
    Assert-Equal -Actual $hero.CantripsKnown -Expected 2 -Message "A level 2 bard should still know two cantrips."
    Assert-Equal -Actual $hero.SpellsKnown -Expected 5 -Message "A level 2 bard should know five slotted spells."
    Assert-Equal -Actual $hero.MaxSpellSlots.Level1 -Expected 3 -Message "A level 2 bard should have three level 1 slots."
    Assert-Equal -Actual $hero.MaxSpellSlots.Level2 -Expected 0 -Message "A level 2 bard should not have level 2 slots."

    $hero.Level = 3
    Restore-HeroSpellSlots -Hero $hero | Out-Null
    Assert-Equal -Actual $hero.SpellsKnown -Expected 6 -Message "A level 3 bard should know six slotted spells."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level1 -Expected 4 -Message "A level 3 bard should restore four level 1 slots."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level2 -Expected 2 -Message "A level 3 bard should unlock two level 2 slots."

    $hero.Level = 4
    Restore-HeroSpellSlots -Hero $hero | Out-Null
    Assert-Equal -Actual $hero.CantripsKnown -Expected 3 -Message "A level 4 bard should know a third cantrip."
    Assert-Equal -Actual $hero.SpellsKnown -Expected 7 -Message "A level 4 bard should know seven slotted spells."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level2 -Expected 3 -Message "A level 4 bard should restore three level 2 slots."

    $hero.Level = 5
    Restore-HeroSpellSlots -Hero $hero | Out-Null
    Assert-Equal -Actual $hero.SpellsKnown -Expected 8 -Message "A level 5 bard should know eight slotted spells."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level3 -Expected 2 -Message "A level 5 bard should unlock two level 3 spell slots."

    $hero.Level = 6
    Restore-HeroSpellSlots -Hero $hero | Out-Null
    Assert-Equal -Actual $hero.SpellsKnown -Expected 9 -Message "A level 6 bard should know nine slotted spells."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level3 -Expected 3 -Message "A level 6 bard should restore three level 3 spell slots."
}

function Test-BardLevelTwoSpellsStayLevelGated {
    $hero = Get-Hero -Class "Bard"

    foreach ($level in @(1, 2)) {
        $hero.Level = $level
        Initialize-HeroSpellcasting -Hero $hero | Out-Null

        Assert-Equal -Actual (@($hero.KnownSpells | Where-Object { [int]$_.SpellLevel -eq 2 }).Count) -Expected 0 -Message "A level $level bard should not know level 2 spells."
        Assert-Equal -Actual (Test-HeroCanCastSpell -Hero $hero -SpellName "Suggestion").CanCast -Expected $false -Message "Suggestion should not be castable at bard level $level."
        Assert-Equal -Actual (Test-HeroCanCastSpell -Hero $hero -SpellName "Invisibility").CanCast -Expected $false -Message "Invisibility should not be castable at bard level $level."
        Assert-Equal -Actual (Test-HeroCanCastSpell -Hero $hero -SpellName "Enhance Ability").CanCast -Expected $false -Message "Enhance Ability should not be castable at bard level $level."
    }

    $hero.Level = 3
    Restore-HeroSpellSlots -Hero $hero | Out-Null
    Assert-Equal -Actual (Test-HeroCanCastSpell -Hero $hero -SpellName "Suggestion").CanCast -Expected $true -Message "Suggestion should become castable at bard level 3."
    Assert-Equal -Actual (Test-HeroCanCastSpell -Hero $hero -SpellName "Invisibility").CanCast -Expected $true -Message "Invisibility should become castable when bard level 3 unlocks level 2 slots."
    Assert-Equal -Actual (Test-HeroCanCastSpell -Hero $hero -SpellName "Enhance Ability").CanCast -Expected $false -Message "Enhance Ability should remain locked until bard level 4."

    $hero.Level = 4
    Restore-HeroSpellSlots -Hero $hero | Out-Null
    Assert-Equal -Actual (Test-HeroCanCastSpell -Hero $hero -SpellName "Invisibility").CanCast -Expected $true -Message "Invisibility should become castable at bard level 4."
    Assert-Equal -Actual (Test-HeroCanCastSpell -Hero $hero -SpellName "Enhance Ability").CanCast -Expected $true -Message "Enhance Ability should become castable at bard level 4."
    Assert-Equal -Actual (@($hero.KnownSpells | Where-Object { [int]$_.SpellLevel -eq 2 }).Count) -Expected 3 -Message "A level 4 bard should know three level 2 utility/control spells in this pass."
}

function Test-BardUnimplementedKnownSpellsAreNotCastable {
    $hero = Get-Hero -Class "Bard"
    $hero.Level = 2
    Restore-HeroSpellSlots -Hero $hero | Out-Null

    $heroism = $hero.KnownSpells | Where-Object { $_.Name -eq "Heroism" } | Select-Object -First 1
    $heroismCast = Test-HeroCanCastSpell -Hero $hero -SpellName "Heroism"

    Assert-True -Condition ($null -ne $heroism) -Message "Heroism should still count as the bard's level 2 spell-known expansion."
    Assert-Equal -Actual $heroism.Implemented -Expected $false -Message "Heroism should be marked as known but not yet playable."
    Assert-Equal -Actual $heroismCast.CanCast -Expected $false -Message "Unimplemented known spells should not be castable."
    Assert-True -Condition ($heroismCast.Message -like "*not yet available*") -Message "Unimplemented spell feedback should be explicit."
}

function Test-BardLevelFiveAndSixFeatureUnlocks {
    $hero = Get-Hero -Class "Bard"

    $hero.Level = 5
    Prepare-HeroBardicInspiration -Hero $hero | Out-Null

    Assert-Equal -Actual (Test-HeroFeatureUnlocked -Hero $hero -Feature "BardicInspirationD8") -Expected $true -Message "Bardic Inspiration should improve to d8 at Bard level 5."
    Assert-Equal -Actual (Test-HeroFeatureUnlocked -Hero $hero -Feature "FontOfInspiration") -Expected $true -Message "Font of Inspiration should unlock at Bard level 5."
    Assert-Equal -Actual $hero.BardicInspirationDieSides -Expected 8 -Message "Prepared Bardic Inspiration should use d8 at level 5."

    $hero.Level = 6

    Assert-Equal -Actual (Test-HeroFeatureUnlocked -Hero $hero -Feature "Countercharm") -Expected $true -Message "Countercharm should unlock at Bard level 6."
    Assert-Equal -Actual (Test-HeroFeatureUnlocked -Hero $hero -Feature "AdditionalMagicalSecrets") -Expected $true -Message "Lore Bard Additional Magical Secrets should unlock at Bard level 6."
    Assert-Equal -Actual (Test-HeroConditionSaveAdvantage -Hero $hero -Condition "Charmed") -Expected $true -Message "Countercharm should flag advantage against charm saves."
    Assert-Equal -Actual (Test-HeroConditionSaveAdvantage -Hero $hero -Condition "Frightened") -Expected $true -Message "Countercharm should flag advantage against fear saves."
}

function Test-LevelThreeBardCanUseInvisibilityInCalmDungeonRooms {
    $hero = Get-Hero -Class "Bard"
    $hero.Level = 3
    Restore-HeroSpellSlots -Hero $hero | Out-Null

    Assert-Equal -Actual (Test-HeroInvisibilityOutOfCombatOptionVisible -Hero $hero) -Expected $true -Message "A level 3 bard with level 2 slots should see Invisibility in calm dungeon rooms."
    Assert-True -Condition ((Get-HeroInvisibilityOutOfCombatOptionText -Hero $hero) -like "*L2 slots 2/2*") -Message "The calm-room Invisibility option should show level 3 slot availability."

    $result = Invoke-HeroInvisibility -Hero $hero

    Assert-Equal -Actual $result.Success -Expected $true -Message "A level 3 bard should be able to cast Invisibility."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level2 -Expected 1 -Message "Casting Invisibility should spend one level 2 slot at level 3."
}

function Test-BardCantripsDoNotSpendSpellSlots {
    $hero = Get-Hero -Class "Bard"
    $beforeSlots = [int]$hero.CurrentSpellSlots.Level1

    $castCheck = Test-HeroCanCastSpell -Hero $hero -SpellName "Vicious Mockery"
    $slotUse = Use-HeroSpellSlot -Hero $hero -SpellLevel $castCheck.Spell.SpellLevel

    Assert-Equal -Actual $castCheck.CanCast -Expected $true -Message "A known cantrip should be castable."
    Assert-Equal -Actual $slotUse.Success -Expected $true -Message "Using a cantrip slot path should succeed without spending a slot."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level1 -Expected $beforeSlots -Message "A cantrip should not spend a level 1 spell slot."
}

function Test-BardSlottedSpellsSpendAndRestoreSlots {
    $hero = Get-Hero -Class "Bard"

    $castCheck = Test-HeroCanCastSpell -Hero $hero -SpellName "Healing Word"
    $firstUse = Use-HeroSpellSlot -Hero $hero -SpellLevel $castCheck.Spell.SpellLevel
    $secondUse = Use-HeroSpellSlot -Hero $hero -SpellLevel $castCheck.Spell.SpellLevel
    $emptyUse = Use-HeroSpellSlot -Hero $hero -SpellLevel $castCheck.Spell.SpellLevel

    Assert-Equal -Actual $castCheck.CanCast -Expected $true -Message "Healing Word should be known and castable at bard level 1."
    Assert-Equal -Actual $firstUse.Success -Expected $true -Message "The first Healing Word slot spend should work."
    Assert-Equal -Actual $secondUse.Success -Expected $true -Message "The second Healing Word slot spend should work."
    Assert-Equal -Actual $emptyUse.Success -Expected $false -Message "A level 1 bard should fail to spend a third level 1 slot."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level1 -Expected 0 -Message "Spending both level 1 slots should leave none remaining."

    Restore-HeroSpellSlots -Hero $hero | Out-Null
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level1 -Expected 2 -Message "Restoring spell slots should refill level 1 slots."
}

function Test-BardSpellcastingStatusReportsSlots {
    $hero = Get-Hero -Class "Bard"
    Use-HeroSpellSlot -Hero $hero -SpellLevel 1 | Out-Null

    $status = Get-HeroStatusSnapshot -Hero $hero -HeroHP $hero.HP

    Assert-Equal -Actual $status.Spellcasting.CurrentSpellSlots.Level1 -Expected 1 -Message "Status should report current level 1 spell slots."
    Assert-Equal -Actual $status.Spellcasting.MaxSpellSlots.Level1 -Expected 2 -Message "Status should report max level 1 spell slots."
    Assert-Equal -Actual $status.Spellcasting.CantripsKnown -Expected 2 -Message "Status should report known cantrips."
    Assert-Equal -Actual $status.Spellcasting.SpellsKnown -Expected 4 -Message "Status should report known slotted spells."
}

function Test-BardLongRestRestoresSpellSlotsWithoutLevelUp {
    $hero = Get-Hero -Class "Bard"
    $heroHP = $hero.HP
    Use-HeroSpellSlot -Hero $hero -SpellLevel 1 | Out-Null
    Use-HeroSpellSlot -Hero $hero -SpellLevel 1 | Out-Null

    Resolve-HeroLongRestLevelUp -Hero $hero -HeroHP ([ref]$heroHP) -HPMode "F" | Out-Null

    Assert-Equal -Actual $hero.CurrentSpellSlots.Level1 -Expected 2 -Message "A long rest should restore bard spell slots even without a level-up."
}

function Test-BardHealingWordSpendsSlotAndHeals {
    try {
        $global:RollDiceOverride = {
            param([int]$Sides = 20)
            if ($Sides -eq 4) { return 3 }
            return 10
        }

        $hero = Get-Hero -Class "Bard"
        $heroHP = 3
        $result = Invoke-BardHealingWord -Hero $hero -HeroHP ([ref]$heroHP)

        Assert-Equal -Actual $result.Success -Expected $true -Message "Healing Word should cast successfully when the bard has a level 1 slot."
        Assert-Equal -Actual $result.Healed -Expected 5 -Message "Healing Word should heal 1d4 plus Charisma modifier."
        Assert-Equal -Actual $heroHP -Expected 8 -Message "Healing Word should raise current HP by the healed amount."
        Assert-Equal -Actual $hero.CurrentSpellSlots.Level1 -Expected 1 -Message "Healing Word should spend one level 1 spell slot."
    }
    finally {
        $global:RollDiceOverride = $null
    }
}

function Test-BardHealingWordFailsWithoutSlots {
    $hero = Get-Hero -Class "Bard"
    $hero.CurrentSpellSlots.Level1 = 0
    $heroHP = 3

    $result = Invoke-BardHealingWord -Hero $hero -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual $result.Success -Expected $false -Message "Healing Word should fail when no level 1 slots remain."
    Assert-Equal -Actual $heroHP -Expected 3 -Message "Failed Healing Word should not heal."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level1 -Expected 0 -Message "Failed Healing Word should not change slot count."
}

function Test-BardDissonantWhispersFailsSaveDealsFullDamageAndDisrupts {
    try {
        $script:rolls = @(5, 4, 3, 2)
        $script:rollIndex = 0
        $global:RollDiceOverride = {
            param([int]$Sides = 20)
            $roll = $script:rolls[$script:rollIndex]
            $script:rollIndex += 1
            return $roll
        }

        $hero = Get-Hero -Class "Bard"
        $monster = New-TestSpellMonster
        $monsterHP = $monster.hp
        $monsterOffBalance = $false

        $result = Invoke-BardDissonantWhispers -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) -MonsterOffBalance ([ref]$monsterOffBalance)

        Assert-Equal -Actual $result.Success -Expected $true -Message "Dissonant Whispers should cast successfully when the bard has a level 1 slot."
        Assert-Equal -Actual $result.SaveSucceeded -Expected $false -Message "A low Wisdom save should fail against the bard's spell save DC."
        Assert-Equal -Actual $result.Damage -Expected 9 -Message "A failed Dissonant Whispers save should take full 3d6 psychic damage."
        Assert-Equal -Actual $monsterHP -Expected 11 -Message "Dissonant Whispers should damage the target."
        Assert-Equal -Actual $monsterOffBalance -Expected $true -Message "A failed Dissonant Whispers save should throw the target off balance."
        Assert-Equal -Actual $hero.CurrentSpellSlots.Level1 -Expected 1 -Message "Dissonant Whispers should spend one level 1 spell slot."
    }
    finally {
        $global:RollDiceOverride = $null
    }
}

function Test-BardDissonantWhispersSuccessfulSaveDealsHalfDamageOnly {
    try {
        $script:rolls = @(18, 5, 4, 3)
        $script:rollIndex = 0
        $global:RollDiceOverride = {
            param([int]$Sides = 20)
            $roll = $script:rolls[$script:rollIndex]
            $script:rollIndex += 1
            return $roll
        }

        $hero = Get-Hero -Class "Bard"
        $monster = New-TestSpellMonster
        $monsterHP = $monster.hp
        $monsterOffBalance = $false

        $result = Invoke-BardDissonantWhispers -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) -MonsterOffBalance ([ref]$monsterOffBalance)

        Assert-Equal -Actual $result.Success -Expected $true -Message "Dissonant Whispers should still resolve on a successful save."
        Assert-Equal -Actual $result.SaveSucceeded -Expected $true -Message "A high Wisdom save should succeed."
        Assert-Equal -Actual $result.Damage -Expected 6 -Message "A successful Dissonant Whispers save should take half psychic damage."
        Assert-Equal -Actual $monsterHP -Expected 14 -Message "Successful save damage should still be applied."
        Assert-Equal -Actual $monsterOffBalance -Expected $false -Message "A successful Dissonant Whispers save should not throw the target off balance."
        Assert-Equal -Actual $hero.CurrentSpellSlots.Level1 -Expected 1 -Message "Dissonant Whispers should spend one level 1 spell slot even on a successful save."
    }
    finally {
        $global:RollDiceOverride = $null
    }
}

function Test-BardDissonantWhispersFailsWithoutSlots {
    $hero = Get-Hero -Class "Bard"
    $hero.CurrentSpellSlots.Level1 = 0
    $monster = New-TestSpellMonster
    $monsterHP = $monster.hp
    $monsterOffBalance = $false

    $result = Invoke-BardDissonantWhispers -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) -MonsterOffBalance ([ref]$monsterOffBalance)

    Assert-Equal -Actual $result.Success -Expected $false -Message "Dissonant Whispers should fail when no level 1 slots remain."
    Assert-Equal -Actual $monsterHP -Expected $monster.hp -Message "Failed Dissonant Whispers should not damage the target."
    Assert-Equal -Actual $monsterOffBalance -Expected $false -Message "Failed Dissonant Whispers should not disrupt the target."
}

function Test-BardFaerieFireMarksTargetOnFailedSave {
    try {
        $global:RollDiceOverride = {
            param([int]$Sides = 20)
            return 5
        }

        $hero = Get-Hero -Class "Bard"
        $monster = New-TestSpellMonster

        $result = Invoke-BardFaerieFire -Hero $hero -Monster $monster

        Assert-Equal -Actual $result.Success -Expected $true -Message "Faerie Fire should cast successfully when the bard has a level 1 slot."
        Assert-Equal -Actual $result.Marked -Expected $true -Message "A failed Dexterity save should mark the target."
        Assert-Equal -Actual $monster.FaerieFireAttackAdvantage -Expected $true -Message "A marked target should grant advantage on the next hero attack."
        Assert-Equal -Actual $hero.CurrentSpellSlots.Level1 -Expected 1 -Message "Faerie Fire should spend one level 1 spell slot."
    }
    finally {
        $global:RollDiceOverride = $null
    }
}

function Test-BardFaerieFireSuccessfulSaveDoesNotMarkTarget {
    try {
        $global:RollDiceOverride = {
            param([int]$Sides = 20)
            return 18
        }

        $hero = Get-Hero -Class "Bard"
        $monster = New-TestSpellMonster

        $result = Invoke-BardFaerieFire -Hero $hero -Monster $monster

        Assert-Equal -Actual $result.Success -Expected $true -Message "Faerie Fire should still resolve on a successful save."
        Assert-Equal -Actual $result.Marked -Expected $false -Message "A successful Dexterity save should avoid the mark."
        Assert-True -Condition ($null -eq $monster.PSObject.Properties["FaerieFireAttackAdvantage"] -or -not [bool]$monster.FaerieFireAttackAdvantage) -Message "A successful Faerie Fire save should not grant attack advantage."
        Assert-Equal -Actual $hero.CurrentSpellSlots.Level1 -Expected 1 -Message "Faerie Fire should spend one level 1 spell slot even on a successful save."
    }
    finally {
        $global:RollDiceOverride = $null
    }
}

function Test-BardFaerieFireFailsWithoutSlots {
    $hero = Get-Hero -Class "Bard"
    $hero.CurrentSpellSlots.Level1 = 0
    $monster = New-TestSpellMonster

    $result = Invoke-BardFaerieFire -Hero $hero -Monster $monster

    Assert-Equal -Actual $result.Success -Expected $false -Message "Faerie Fire should fail when no level 1 slots remain."
    Assert-True -Condition ($null -eq $monster.PSObject.Properties["FaerieFireAttackAdvantage"] -or -not [bool]$monster.FaerieFireAttackAdvantage) -Message "Failed Faerie Fire should not mark the target."
}

function Test-NonBardDoesNotGetSpellcastingStatus {
    $hero = Get-Hero -Class "Fighter"

    Assert-Equal -Actual (Get-HeroSpellcastingStatus -Hero $hero) -Expected $null -Message "Fighters should not get bard spellcasting status."
}

Test-BardStartsWithSpellcastingState
Test-BardSpellcastingProgressionScalesByLevel
Test-BardLevelTwoSpellsStayLevelGated
Test-BardUnimplementedKnownSpellsAreNotCastable
Test-BardLevelFiveAndSixFeatureUnlocks
Test-LevelThreeBardCanUseInvisibilityInCalmDungeonRooms
Test-BardCantripsDoNotSpendSpellSlots
Test-BardSlottedSpellsSpendAndRestoreSlots
Test-BardSpellcastingStatusReportsSlots
Test-BardLongRestRestoresSpellSlotsWithoutLevelUp
Test-BardHealingWordSpendsSlotAndHeals
Test-BardHealingWordFailsWithoutSlots
Test-BardDissonantWhispersFailsSaveDealsFullDamageAndDisrupts
Test-BardDissonantWhispersSuccessfulSaveDealsHalfDamageOnly
Test-BardDissonantWhispersFailsWithoutSlots
Test-BardFaerieFireMarksTargetOnFailedSave
Test-BardFaerieFireSuccessfulSaveDoesNotMarkTarget
Test-BardFaerieFireFailsWithoutSlots
Test-NonBardDoesNotGetSpellcastingStatus

Write-Host "Bard spellcasting tests passed." -ForegroundColor Green
