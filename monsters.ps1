function Get-MonsterList {
    @(
        @{ 
            name = "skeleton"
            article = "A"
            definite = "The Skeleton"
            hp = 10
            damageMin = 1
            damageMax = 4
            isBoss = $false
        },
        @{ 
            name = "goblin"
            article = "A"
            definite = "The Goblin"
            hp = 8
            damageMin = 1
            damageMax = 6
            isBoss = $false
        },
        @{ 
            name = "zombie"
            article = "A"
            definite = "The Zombie"
            hp = 12
            damageMin = 1
            damageMax = 5
            isBoss = $false
        },
        @{ 
            name = "giant rat"
            article = "A"
            definite = "The Giant Rat"
            hp = 7
            damageMin = 1
            damageMax = 3
            isBoss = $false
        },
        @{ 
            name = "ancient dragon"
            article = "An"
            definite = "The Ancient Dragon"
            hp = 50
            damageMin = 8
            damageMax = 12
            isBoss = $true
        }
    )
}

function Get-RandomMonster {
    $monsters = Get-MonsterList
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
                [PSCustomObject]@{ Name = "Bone Coins"; Type = "Currency"; Value = 2 }
                [PSCustomObject]@{ Name = "Rusty Sword"; Type = "Weapon"; Value = 5 }
            )
        }

        "goblin" {
            return @(
                [PSCustomObject]@{ Name = "Gold Pouch"; Type = "Currency"; Value = 10 }
                [PSCustomObject]@{ Name = "Dagger"; Type = "Weapon"; Value = 6 }
                [PSCustomObject]@{ Name = "Small Healing Potion"; Type = "Consumable"; Value = 10; HealAmount = 4 }
            )
        }

        "zombie" {
            return @(
                [PSCustomObject]@{ Name = "Rotten Armor Scraps"; Type = "Armor"; Value = 3 }
                [PSCustomObject]@{ Name = "Old Coin"; Type = "Currency"; Value = 2 }
            )
        }

        "giant rat" {
            return @(
                [PSCustomObject]@{ Name = "Rat Tail"; Type = "Junk"; Value = 1 }
            )
        }

        "ancient dragon" {
            return @(
                [PSCustomObject]@{ Name = "Dragon Gold"; Type = "Currency"; Value = 100 }
                [PSCustomObject]@{ Name = "Ancient Scale Armor"; Type = "Armor"; Value = 75 }
                [PSCustomObject]@{ Name = "Flame Fang"; Type = "Weapon"; Value = 60 }
                [PSCustomObject]@{ Name = "Greater Healing Potion"; Type = "Consumable"; Value = 25; HealAmount = 12 }
            )
        }

        default {
            return @()
        }
    }
}
