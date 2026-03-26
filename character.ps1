function Get-Hero {

    $hero = @{
        Name = "Borzig"
        Class = "Barbarian"
        HP = 20

        Inventory = @(
            @{ Name = "Great Axe"; Type = "Weapon" }
            @{ Name = "Helmet"; Type = "Armor" }
            @{ Name = "Backpack"; Type = "Utility" }
            @{ Name = "Healing Potion"; Type = "Consumable" }
        )
    }

    return $hero
}