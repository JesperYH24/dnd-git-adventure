function New-WeaponItem {
    param(
        [string]$Name,
        [int]$Value,
        [int]$AttackBonus,
        [int]$DamageDiceCount = 1,
        [int]$DamageDiceSides = 6,
        [int]$DamageMin = 0,
        [int]$DamageMax = 0,
        [int]$SlotCost = 1,
        [bool]$Equipped = $false
    )

    if ($DamageMin -gt 0 -and $DamageMax -gt 0) {
        $DamageDiceCount = 1
        $DamageDiceSides = $DamageMax
    }

    return [PSCustomObject]@{
        Name            = $Name
        Type            = "Weapon"
        Value           = $Value
        AttackBonus     = $AttackBonus
        DamageDiceCount = $DamageDiceCount
        DamageDiceSides = $DamageDiceSides
        DamageMin       = $DamageDiceCount
        DamageMax       = $DamageDiceCount * $DamageDiceSides
        SlotCost        = $SlotCost
        Equipped        = $Equipped
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
