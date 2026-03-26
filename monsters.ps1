function Get-MonsterList {
    @(
        @{ 
            name = "skelett"
            article = "Ett"
            definite = "Skelettet"
            hp = 10
            damageMin = 1
            damageMax = 4
            isBoss = $false
        },
        @{ 
            name = "goblin"
            article = "En"
            definite = "Goblinen"
            hp = 8
            damageMin = 1
            damageMax = 6
            isBoss = $false
        },
        @{ 
            name = "zombie"
            article = "En"
            definite = "Zombien"
            hp = 12
            damageMin = 1
            damageMax = 5
            isBoss = $false
        },
        @{ 
            name = "jätteråtta"
            article = "En"
            definite = "Jätteråttan"
            hp = 7
            damageMin = 1
            damageMax = 3
            isBoss = $false
        },
        @{ 
            name = "uråldrig drake"
            article = "En"
            definite = "Den uråldriga draken"
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
        "skelett" {
            return @(
                [PSCustomObject]@{ Name = "Bone Coins"; Type = "Currency"; Value = 2 }
                [PSCustomObject]@{ Name = "Rusty Sword"; Type = "Weapon"; Value = 5 }
            )
        }

        "goblin" {
            return @(
                [PSCustomObject]@{ Name = "Gold Pouch"; Type = "Currency"; Value = 10 }
                [PSCustomObject]@{ Name = "Dagger"; Type = "Weapon"; Value = 6 }
                [PSCustomObject]@{ Name = "Small Healing Potion"; Type = "Consumable"; Value = 10 }
            )
        }

        "zombie" {
            return @(
                [PSCustomObject]@{ Name = "Rotten Armor Scraps"; Type = "Armor"; Value = 3 }
                [PSCustomObject]@{ Name = "Old Coin"; Type = "Currency"; Value = 2 }
            )
        }

        "jätteråtta" {
            return @(
                [PSCustomObject]@{ Name = "Rat Tail"; Type = "Junk"; Value = 1 }
            )
        }

        "uråldrig drake" {
            return @(
                [PSCustomObject]@{ Name = "Dragon Gold"; Type = "Currency"; Value = 100 }
                [PSCustomObject]@{ Name = "Ancient Scale Armor"; Type = "Armor"; Value = 75 }
                [PSCustomObject]@{ Name = "Flame Fang"; Type = "Weapon"; Value = 60 }
                [PSCustomObject]@{ Name = "Greater Healing Potion"; Type = "Consumable"; Value = 25 }
            )
        }

        default {
            return @()
        }
    }
}