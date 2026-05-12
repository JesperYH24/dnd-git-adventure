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

function Test-NonBardDoesNotGetSpellcastingStatus {
    $hero = Get-Hero -Class "Fighter"

    Assert-Equal -Actual (Get-HeroSpellcastingStatus -Hero $hero) -Expected $null -Message "Fighters should not get bard spellcasting status."
}

Test-BardStartsWithSpellcastingState
Test-BardSpellcastingProgressionScalesByLevel
Test-BardCantripsDoNotSpendSpellSlots
Test-BardSlottedSpellsSpendAndRestoreSlots
Test-BardSpellcastingStatusReportsSlots
Test-BardLongRestRestoresSpellSlotsWithoutLevelUp
Test-BardHealingWordSpendsSlotAndHeals
Test-BardHealingWordFailsWithoutSlots
Test-NonBardDoesNotGetSpellcastingStatus

Write-Host "Bard spellcasting tests passed." -ForegroundColor Green
