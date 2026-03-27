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
