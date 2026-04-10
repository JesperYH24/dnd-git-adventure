function Get-MonsterList {
    @(
        @{
            name = "skeleton"
            article = "A"
            definite = "The Skeleton"
            hp = 8
            xp = 50
            armorClass = 11
            attackBonus = 0
            initiativeBonus = 0
            damageDiceCount = 1
            damageDiceSides = 4
            damageBonus = 0
            damageMin = 1
            damageMax = 4
            encounterChance = 40
            isBoss = $false
        },
        @{
            name = "goblin"
            article = "A"
            definite = "The Goblin"
            hp = 6
            xp = 50
            armorClass = 12
            attackBonus = 1
            initiativeBonus = 2
            damageDiceCount = 1
            damageDiceSides = 6
            damageBonus = 0
            damageMin = 1
            damageMax = 6
            encounterChance = 45
            isBoss = $false
        },
        @{
            name = "zombie"
            article = "A"
            definite = "The Zombie"
            hp = 10
            xp = 50
            armorClass = 9
            attackBonus = 0
            initiativeBonus = -1
            damageDiceCount = 1
            damageDiceSides = 4
            damageBonus = 1
            damageMin = 2
            damageMax = 5
            encounterChance = 35
            isBoss = $false
        },
        @{
            name = "giant rat"
            article = "A"
            definite = "The Giant Rat"
            hp = 5
            xp = 25
            armorClass = 10
            attackBonus = 1
            initiativeBonus = 2
            damageDiceCount = 1
            damageDiceSides = 4
            damageBonus = 0
            damageMin = 1
            damageMax = 4
            encounterChance = 50
            isBoss = $false
        },
        @{
            name = "ancient dragon"
            article = "An"
            definite = "The Ancient Dragon"
            hp = 50
            xp = 0
            armorClass = 16
            attackBonus = 4
            initiativeBonus = 0
            damageDiceCount = 2
            damageDiceSides = 6
            damageBonus = 4
            damageMin = 6
            damageMax = 16
            encounterChance = 100
            isBoss = $true
        }
    )
}

function Get-MonsterDamageProfile {
    param($Monster)

    $hasDiceCount = $null -ne $Monster.damageDiceCount
    $hasDiceSides = $null -ne $Monster.damageDiceSides

    if ($hasDiceCount -and $hasDiceSides) {
        $diceCount = [int]$Monster.damageDiceCount
        $diceSides = [int]$Monster.damageDiceSides
        $damageBonus = 0

        if ($null -ne $Monster.damageBonus) {
            $damageBonus = [int]$Monster.damageBonus
        }

        return [PSCustomObject]@{
            DiceCount = $diceCount
            DiceSides = $diceSides
            DamageBonus = $damageBonus
            DamageMin = [Math]::Max(1, $diceCount + $damageBonus)
            DamageMax = [Math]::Max(1, ($diceCount * $diceSides) + $damageBonus)
        }
    }

    return [PSCustomObject]@{
        DiceCount = 1
        DiceSides = [int]$Monster.damageMax
        DamageBonus = 0
        DamageMin = [int]$Monster.damageMin
        DamageMax = [int]$Monster.damageMax
    }
}

function Get-MonsterDamageRollText {
    param($Monster)

    $profile = Get-MonsterDamageProfile -Monster $Monster
    $text = "$($profile.DiceCount)d$($profile.DiceSides)"

    if ($profile.DamageBonus -gt 0) {
        return "$text + $($profile.DamageBonus)"
    }

    return $text
}

function Roll-MonsterDamage {
    param(
        $Monster,
        [int]$DiceCount = 0
    )

    $profile = Get-MonsterDamageProfile -Monster $Monster

    if ($DiceCount -le 0) {
        $DiceCount = $profile.DiceCount
    }

    $total = 0

    for ($i = 0; $i -lt $DiceCount; $i++) {
        $total += Roll-Dice -Sides $profile.DiceSides
    }

    return [Math]::Max(1, $total + $profile.DamageBonus)
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
                (New-CurrencyItem -Name "Bone Coins" -Denomination "CP" -Amount 2 -Value 2)
                (New-WeaponItem -Name "Rusty Sword" -Value 12 -AttackBonus 0 -DamageDiceCount 1 -DamageDiceSides 6 -Handedness "One-Handed" -RequiredSTR 10 -SlotCost 2)
            )
        }

        "goblin" {
            return @(
                (New-CurrencyItem -Name "Goblin Coins" -Denomination "SP" -Amount 1 -Value 10)
                (New-WeaponItem -Name "Dagger" -Value 18 -AttackBonus 2 -DamageDiceCount 1 -DamageDiceSides 4 -Handedness "One-Handed" -Light $true -RequiredDEX 11 -SlotCost 1)
                (New-ConsumableItem -Name "Small Healing Potion" -Value 16 -HealAmount 4 -SlotCost 1)
            )
        }

        "zombie" {
            return @(
                (New-ArmorItem -Name "Rotten Armor Scraps" -Value 12 -ArmorBonus 1 -SlotCost 2)
                (New-CurrencyItem -Name "Old Coin" -Denomination "CP" -Amount 2 -Value 2)
            )
        }

        "giant rat" {
            return @(
                [PSCustomObject]@{ Name = "Rat Tail"; Type = "Junk"; Value = 4; SlotCost = 1 }
            )
        }

        "ancient dragon" {
            return @(
                (New-CurrencyItem -Name "Dragon Gold" -Denomination "GP" -Amount 100 -Value 10000)
                (New-ArmorItem -Name "Ancient Scale Armor" -Value 75 -ArmorBonus 5 -SlotCost 3)
                (New-WeaponItem -Name "Flame Fang" -Value 60 -AttackBonus 1 -DamageDiceCount 1 -DamageDiceSides 10 -Handedness "One-Handed" -RequiredSTR 14 -RequiredDEX 12 -BonusDamageDiceCount 1 -BonusDamageDiceSides 6 -BonusDamageType "Fire" -SlotCost 2)
                (New-ConsumableItem -Name "Greater Healing Potion" -Value 25 -HealAmount 12 -SlotCost 1)
            )
        }

        default {
            return @()
        }
    }
}
