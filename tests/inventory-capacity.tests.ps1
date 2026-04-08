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

function Test-BackpackCanBePickedUpAgain {
    $hero = Get-Hero
    $room = [PSCustomObject]@{
        Name = "Test Room"
        Loot = @()
    }

    $backpackIndex = -1

    for ($i = 0; $i -lt $hero.Inventory.Count; $i++) {
        if ($hero.Inventory[$i].Name -eq "Backpack") {
            $backpackIndex = $i
            break
        }
    }

    Drop-InventoryItem -Hero $hero -Index $backpackIndex -Room $room | Out-Null

    Assert-Equal -Actual (Get-InventoryUsedSlots -Hero $hero) -Expected 4 -Message "Used slots should shrink after dropping the backpack."
    Assert-Equal -Actual (Get-InventoryCapacity -Hero $hero) -Expected 4 -Message "Capacity should fall back to the base value after dropping the backpack."
    Assert-True -Condition (Can-HeroCarryItem -Hero $hero -Item $room.Loot[0]) -Message "The backpack should be pick-up-able even when it is the item that restores carrying capacity."
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

Test-BackpackCanBePickedUpAgain
Test-LootedPotionsCanBeUsed

Write-Host "Inventory capacity tests passed." -ForegroundColor Green
