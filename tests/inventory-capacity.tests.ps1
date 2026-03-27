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

Test-BackpackCanBePickedUpAgain

Write-Host "Inventory capacity tests passed." -ForegroundColor Green
