function Get-Hero {
    return [PSCustomObject]@{
        Name       = "Borzig"
        Class      = "Barbarian"
        HP         = 20
        STR        = 16
        DamageMin  = 1
        DamageMax  = 8
        Inventory  = @(
            [PSCustomObject]@{
                Name       = "Great Axe"
                Type       = "Weapon"
                Value      = 0
            }
            [PSCustomObject]@{
                Name       = "Helmet"
                Type       = "Armor"
                Value      = 0
            }
            [PSCustomObject]@{
                Name       = "Backpack"
                Type       = "Utility"
                Value      = 0
            }
            [PSCustomObject]@{
                Name       = "Healing Potion"
                Type       = "Consumable"
                Value      = 0
                HealAmount = 8
            }
        )
    }
}