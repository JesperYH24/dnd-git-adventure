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

function Test-BetterArmorRaisesArmorClass {
    $hero = Get-Hero
    $startingArmorClass = Get-HeroArmorClass -Hero $hero

    $newArmor = New-ArmorItem -Name "Rotten Armor Scraps" -Value 3 -ArmorBonus 1 -SlotCost 2
    $hero.Inventory += $newArmor

    Set-EquippedItem -Hero $hero -Item $newArmor

    Assert-Equal -Actual $startingArmorClass -Expected 11 -Message "The hero should start with AC 11 from the helmet."
    Assert-Equal -Actual (Get-HeroArmorClass -Hero $hero) -Expected 12 -Message "Equipping better armor should raise armor class."
}

function Test-GreatAxeDamageProfile {
    $hero = Get-Hero
    $weapon = Get-HeroWeaponProfile -Hero $hero

    Assert-Equal -Actual $weapon.DamageMax -Expected 12 -Message "Great Axe should have a max damage of 12."
}

Test-BetterArmorRaisesArmorClass
Test-GreatAxeDamageProfile

Write-Host "Armor upgrade tests passed." -ForegroundColor Green
