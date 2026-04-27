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

function Test-PersonalInventoryAndBackpackAreSeparate {
    $hero = Get-Hero

    Assert-Equal -Actual (Get-InventoryCapacity -Hero $hero) -Expected 8 -Message "Borzig should have eight ready inventory slots on hand."
    Assert-Equal -Actual (Get-BackpackCapacity -Hero $hero) -Expected 4 -Message "The backpack should provide its own separate storage."
    Assert-Equal -Actual (Get-InventoryUsedSlots -Hero $hero) -Expected 3 -Message "Starting on-hand gear should use only its own ready slots."
    Assert-Equal -Actual (Get-BackpackUsedSlots -Hero $hero) -Expected 0 -Message "The backpack should start empty."
}

function Test-ItemsCanOverflowIntoBackpack {
    $hero = Get-Hero

    $hero.Inventory += (New-WeaponItem -Name "Spare Pike" -Value 0 -AttackBonus 0 -DamageDiceCount 1 -DamageDiceSides 8 -Handedness "Two-Handed" -RequiredSTR 11 -SlotCost 3)
    $hero.Inventory += (New-ArmorItem -Name "Traveler Plates" -Value 0 -ArmorBonus 1 -SlotCost 2)

    $item = New-ConsumableItem -Name "Greater Healing Potion" -Value 25 -HealAmount 12 -SlotCost 1
    $storeResult = Add-ItemToHeroStorage -Hero $hero -Item $item

    Assert-Equal -Actual $storeResult.Success -Expected $true -Message "Overflow items should still be storable if the backpack has room."
    Assert-Equal -Actual $storeResult.Location -Expected "Backpack" -Message "Overflow items should go into the backpack."
    Assert-Equal -Actual (Get-BackpackUsedSlots -Hero $hero) -Expected 1 -Message "The backpack should track stored slots separately."
}

function Test-LootedPotionsCanBeUsed {
    function global:Write-Scene { param([string]$Text) }

    $hero = Get-Hero
    $heroHP = 4
    $smallPotion = New-ConsumableItem -Name "Small Healing Potion" -Value 10 -HealAmount 4 -SlotCost 1
    $greaterPotion = New-ConsumableItem -Name "Greater Healing Potion" -Value 25 -HealAmount 12 -SlotCost 1

    $smallUsed = Use-InventoryItem -Hero $hero -HeroHP ([ref]$heroHP) -Item $smallPotion
    Assert-Equal -Actual $smallUsed -Expected $true -Message "Small Healing Potion should be usable."
    Assert-Equal -Actual $heroHP -Expected 8 -Message "Small Healing Potion should restore its heal amount."

    $heroHP = 2
    $greaterUsed = Use-InventoryItem -Hero $hero -HeroHP ([ref]$heroHP) -Item $greaterPotion
    Assert-Equal -Actual $greaterUsed -Expected $true -Message "Greater Healing Potion should be usable."
    Assert-Equal -Actual $heroHP -Expected 14 -Message "Greater Healing Potion should restore up to the hero's max HP."
}

function Test-BackpackCannotBeManagedInCombat {
    $hero = Get-Hero
    $hero.BackpackInventory += (New-ConsumableItem -Name "Battle Tonic" -Value 0 -HealAmount 18 -SlotCost 1)
    $startingBackpackCount = $hero.BackpackInventory.Count

    $result = Open-BackpackMenu -Hero $hero -InCombat

    Assert-Equal -Actual $result -Expected $false -Message "Backpack management should be blocked in combat."
    Assert-Equal -Actual $hero.BackpackInventory.Count -Expected $startingBackpackCount -Message "Blocking backpack access in combat should leave stored gear untouched."
}

Test-PersonalInventoryAndBackpackAreSeparate
Test-ItemsCanOverflowIntoBackpack
Test-LootedPotionsCanBeUsed
Test-BackpackCannotBeManagedInCombat

Write-Host "Inventory capacity tests passed." -ForegroundColor Green
