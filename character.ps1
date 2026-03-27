function New-WeaponItem {
    param(
        [string]$Name,
        [int]$Value,
        [int]$AttackBonus,
        [int]$DamageMin,
        [int]$DamageMax,
        [int]$SlotCost = 1,
        [bool]$Equipped = $false
    )

    return [PSCustomObject]@{
        Name        = $Name
        Type        = "Weapon"
        Value       = $Value
        AttackBonus = $AttackBonus
        DamageMin   = $DamageMin
        DamageMax   = $DamageMax
        SlotCost    = $SlotCost
        Equipped    = $Equipped
    }
}

function New-ArmorItem {
    param(
        [string]$Name,
        [int]$Value,
        [int]$ArmorBonus,
        [int]$SlotCost = 1,
        [bool]$Equipped = $false
    )

    return [PSCustomObject]@{
        Name       = $Name
        Type       = "Armor"
        Value      = $Value
        ArmorBonus = $ArmorBonus
        SlotCost   = $SlotCost
        Equipped   = $Equipped
    }
}

function New-ConsumableItem {
    param(
        [string]$Name,
        [int]$Value,
        [int]$HealAmount,
        [int]$SlotCost = 1
    )

    return [PSCustomObject]@{
        Name       = $Name
        Type       = "Consumable"
        Value      = $Value
        HealAmount = $HealAmount
        SlotCost   = $SlotCost
    }
}

function New-UtilityItem {
    param(
        [string]$Name,
        [int]$Value,
        [int]$SlotBonus = 0,
        [int]$SlotCost = 1,
        [bool]$Equipped = $false
    )

    return [PSCustomObject]@{
        Name      = $Name
        Type      = "Utility"
        Value     = $Value
        SlotBonus = $SlotBonus
        SlotCost  = $SlotCost
        Equipped  = $Equipped
    }
}

function Get-ItemSlotCost {
    param($Item)

    if ($null -ne $Item.SlotCost) {
        return [int]$Item.SlotCost
    }

    return 1
}

function Get-EquippedWeapon {
    param($Hero)

    return ($Hero.Inventory | Where-Object { $_.Type -eq "Weapon" -and $_.Equipped } | Select-Object -First 1)
}

function Get-EquippedArmor {
    param($Hero)

    return ($Hero.Inventory | Where-Object { $_.Type -eq "Armor" -and $_.Equipped } | Select-Object -First 1)
}

function Get-InventoryCapacity {
    param($Hero)

    $utilityBonus = 0

    foreach ($item in $Hero.Inventory) {
        if ($item.Type -eq "Utility" -and $null -ne $item.SlotBonus) {
            $utilityBonus += [int]$item.SlotBonus
        }
    }

    return $Hero.BaseInventorySlots + $utilityBonus
}

function Get-InventoryUsedSlots {
    param($Hero)

    $usedSlots = 0

    foreach ($item in $Hero.Inventory) {
        $usedSlots += Get-ItemSlotCost -Item $item
    }

    return $usedSlots
}

function Can-HeroCarryItem {
    param(
        $Hero,
        $Item
    )

    $usedSlots = Get-InventoryUsedSlots -Hero $Hero
    $capacity = Get-InventoryCapacity -Hero $Hero
    $projectedCapacity = $capacity

    if ($Item.Type -eq "Utility" -and $null -ne $Item.SlotBonus) {
        $projectedCapacity += [int]$Item.SlotBonus
    }

    return ($usedSlots + (Get-ItemSlotCost -Item $Item)) -le $projectedCapacity
}

function Get-HeroArmorClass {
    param($Hero)

    $armorBonus = 0

    foreach ($item in $Hero.Inventory) {
        if ($item.Type -eq "Armor" -and $item.Equipped -and $null -ne $item.ArmorBonus) {
            $armorBonus += [int]$item.ArmorBonus
        }
    }

    return $Hero.BaseArmorClass + $armorBonus
}

function Get-HeroWeaponProfile {
    param($Hero)

    $weapon = Get-EquippedWeapon -Hero $Hero

    if ($weapon) {
        return [PSCustomObject]@{
            Name        = $weapon.Name
            AttackBonus = [int]$weapon.AttackBonus
            DamageMin   = [int]$weapon.DamageMin
            DamageMax   = [int]$weapon.DamageMax
        }
    }

    return [PSCustomObject]@{
        Name        = "Bare Hands"
        AttackBonus = 0
        DamageMin   = 1
        DamageMax   = 2
    }
}

function Set-EquippedItem {
    param(
        $Hero,
        $Item
    )

    if ($Item.Type -eq "Weapon") {
        foreach ($inventoryItem in $Hero.Inventory) {
            if ($inventoryItem.Type -eq "Weapon") {
                $inventoryItem.Equipped = $false
            }
        }

        $Item.Equipped = $true
        return
    }

    if ($Item.Type -eq "Armor") {
        $Item.Equipped = $true
    }
}

function Remove-InventoryItemAt {
    param(
        $Hero,
        [int]$Index
    )

    $newInventory = @()

    for ($i = 0; $i -lt $Hero.Inventory.Count; $i++) {
        if ($i -ne $Index) {
            $newInventory += $Hero.Inventory[$i]
        }
    }

    $Hero.Inventory = $newInventory
}

function Can-DropItem {
    param(
        $Hero,
        $Item
    )

    $capacityAfterDrop = Get-InventoryCapacity -Hero $Hero

    if ($Item.Type -eq "Utility" -and $null -ne $Item.SlotBonus) {
        $capacityAfterDrop -= [int]$Item.SlotBonus
    }

    $usedAfterDrop = (Get-InventoryUsedSlots -Hero $Hero) - (Get-ItemSlotCost -Item $Item)

    return $usedAfterDrop -le $capacityAfterDrop
}

function Get-Hero {
    return [PSCustomObject]@{
        Name               = "Borzig"
        Class              = "Barbarian"
        Level              = 1
        HP                 = 20
        STR                = 16
        BaseArmorClass     = 10
        BaseInventorySlots = 4
        Inventory          = @(
            (New-WeaponItem -Name "Great Axe" -Value 0 -AttackBonus -1 -DamageMin 4 -DamageMax 12 -SlotCost 2 -Equipped $true)
            (New-ArmorItem -Name "Helmet" -Value 0 -ArmorBonus 1 -SlotCost 1 -Equipped $true)
            (New-UtilityItem -Name "Backpack" -Value 0 -SlotBonus 4 -SlotCost 1 -Equipped $true)
            (New-ConsumableItem -Name "Healing Potion" -Value 0 -HealAmount 8 -SlotCost 1)
        )
    }
}
