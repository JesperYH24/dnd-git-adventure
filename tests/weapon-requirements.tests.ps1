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

function Test-HeroCannotEquipWeaponWithoutStats {
    $hero = Get-Hero
    $weapon = New-WeaponItem -Name "Heavy Trial Axe" -Value 0 -AttackBonus 0 -DamageDiceCount 1 -DamageDiceSides 12 -Handedness "Two-Handed" -RequiredSTR 16 -SlotCost 2
    $hero.Inventory += $weapon

    $result = Set-EquippedItem -Hero $hero -Item $weapon

    Assert-Equal -Actual $result.Success -Expected $false -Message "The hero should not equip weapons above the STR requirement."
    Assert-True -Condition ([bool]($hero.Inventory | Where-Object { $_.Name -eq "Great Axe" -and $_.Equipped })) -Message "The currently equipped weapon should remain equipped."
}

function Test-RequirementTextListsHandednessAndStats {
    $weapon = New-WeaponItem -Name "Test Dagger" -Value 0 -AttackBonus 0 -DamageDiceCount 1 -DamageDiceSides 4 -Handedness "One-Handed" -Light $true -RequiredDEX 11 -SlotCost 1
    $text = Get-WeaponRequirementText -Weapon $weapon

    Assert-True -Condition ($text -like "*One-Handed*") -Message "Requirement text should include handedness."
    Assert-True -Condition ($text -like "*Light*") -Message "Requirement text should include the light weapon tag."
    Assert-True -Condition ($text -like "*DEX 11*") -Message "Requirement text should include the DEX requirement."
}

function Test-FlameFangShowsBonusFireDamage {
    $weapon = New-WeaponItem -Name "Flame Fang" -Value 0 -AttackBonus 1 -DamageDiceCount 1 -DamageDiceSides 10 -Handedness "One-Handed" -RequiredSTR 14 -RequiredDEX 12 -BonusDamageDiceCount 1 -BonusDamageDiceSides 6 -BonusDamageType "Fire" -SlotCost 2
    $hero = Get-Hero
    $hero.Inventory += $weapon

    foreach ($item in $hero.Inventory) {
        if ($item.Type -eq "Weapon") {
            $item.Equipped = $false
        }
    }

    $weapon.Equipped = $true
    $profile = Get-HeroWeaponProfile -Hero $hero
    $text = Get-WeaponDamageRollText -WeaponProfile $profile

    Assert-True -Condition ($text -like "*1d10*") -Message "Weapon damage text should include the base weapon die."
    Assert-True -Condition ($text -like "*1d6 fire*") -Message "Weapon damage text should include the bonus fire damage."
}

Test-HeroCannotEquipWeaponWithoutStats
Test-RequirementTextListsHandednessAndStats
Test-FlameFangShowsBonusFireDamage

Write-Host "Weapon requirement tests passed." -ForegroundColor Green
