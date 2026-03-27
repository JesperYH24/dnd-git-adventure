function Get-MonsterList {
    @(
        @{
            name = "skeleton"
            article = "A"
            definite = "The Skeleton"
            hp = 10
            armorClass = 12
            attackBonus = 0
            damageMin = 1
            damageMax = 4
            encounterChance = 40
            isBoss = $false
        },
        @{
            name = "goblin"
            article = "A"
            definite = "The Goblin"
            hp = 8
            armorClass = 13
            attackBonus = 1
            damageMin = 1
            damageMax = 6
            encounterChance = 45
            isBoss = $false
        },
        @{
            name = "zombie"
            article = "A"
            definite = "The Zombie"
            hp = 12
            armorClass = 10
            attackBonus = 1
            damageMin = 1
            damageMax = 5
            encounterChance = 35
            isBoss = $false
        },
        @{
            name = "giant rat"
            article = "A"
            definite = "The Giant Rat"
            hp = 7
            armorClass = 11
            attackBonus = 2
            damageMin = 1
            damageMax = 3
            encounterChance = 50
            isBoss = $false
        },
        @{
            name = "ancient dragon"
            article = "An"
            definite = "The Ancient Dragon"
            hp = 50
            armorClass = 16
            attackBonus = 4
            damageMin = 8
            damageMax = 12
            encounterChance = 100
            isBoss = $true
        }
    )
}

function Get-RandomMonster {
    $monsters = Get-MonsterList | Where-Object { -not $_.isBoss }
    return ($monsters | Get-Random)
}

function Get-BossMonster {
    $monsters = Get-MonsterList
    return ($monsters | Where-Object { $_.isBoss } | Select-Object -First 1)
}

function Get-MonsterLoot {
    param($Monster)

    switch ($Monster.name) {
        "skeleton" {
            return @(
                [PSCustomObject]@{ Name = "Bone Coins"; Type = "Currency"; Value = 2; SlotCost = 1 }
                (New-WeaponItem -Name "Rusty Sword" -Value 5 -AttackBonus 0 -DamageMin 2 -DamageMax 5 -SlotCost 2)
            )
        }

        "goblin" {
            return @(
                [PSCustomObject]@{ Name = "Gold Pouch"; Type = "Currency"; Value = 10; SlotCost = 1 }
                (New-WeaponItem -Name "Dagger" -Value 6 -AttackBonus 2 -DamageMin 1 -DamageMax 4 -SlotCost 1)
                (New-ConsumableItem -Name "Small Healing Potion" -Value 10 -HealAmount 4 -SlotCost 1)
            )
        }

        "zombie" {
            return @(
                (New-ArmorItem -Name "Rotten Armor Scraps" -Value 3 -ArmorBonus 1 -SlotCost 2)
                [PSCustomObject]@{ Name = "Old Coin"; Type = "Currency"; Value = 2; SlotCost = 1 }
            )
        }

        "giant rat" {
            return @(
                [PSCustomObject]@{ Name = "Rat Tail"; Type = "Junk"; Value = 1; SlotCost = 1 }
            )
        }

        "ancient dragon" {
            return @(
                [PSCustomObject]@{ Name = "Dragon Gold"; Type = "Currency"; Value = 100; SlotCost = 2 }
                (New-ArmorItem -Name "Ancient Scale Armor" -Value 75 -ArmorBonus 5 -SlotCost 3)
                (New-WeaponItem -Name "Flame Fang" -Value 60 -AttackBonus 1 -DamageMin 5 -DamageMax 10 -SlotCost 2)
                (New-ConsumableItem -Name "Greater Healing Potion" -Value 25 -HealAmount 12 -SlotCost 1)
            )
        }

        default {
            return @()
        }
    }
}
