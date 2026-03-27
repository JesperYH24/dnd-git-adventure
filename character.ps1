function Get-EquippedWeapon {
    param($Hero)

    return ($Hero.Inventory | Where-Object { $_.Type -eq "Weapon" -and $_.Equipped } | Select-Object -First 1)
}

function Get-AbilityModifier {
    param([int]$Score)

    return [Math]::Floor(($Score - 10) / 2)
}

function Get-HeroAbilityScore {
    param(
        $Hero,
        [string]$Ability
    )

    $property = $Hero.PSObject.Properties[$Ability]

    if ($null -eq $property) {
        return 10
    }

    return [int]$property.Value
}

function Get-HeroAbilityModifier {
    param(
        $Hero,
        [string]$Ability
    )

    $score = Get-HeroAbilityScore -Hero $Hero -Ability $Ability
    return Get-AbilityModifier -Score $score
}

function Format-AbilityModifier {
    param([int]$Modifier)

    if ($Modifier -ge 0) {
        return "(+$Modifier)"
    }

    return "($Modifier)"
}

function Get-HeroProficiencyBonus {
    param($Hero)

    $level = 1

    if ($null -ne $Hero.PSObject.Properties["Level"]) {
        $level = [int]$Hero.Level
    }

    return [Math]::Floor((($level - 1) / 4)) + 2
}

function Get-XPThresholdForLevel {
    param([int]$Level)

    switch ($Level) {
        1 { return 0 }
        2 { return 300 }
        3 { return 900 }
        4 { return 2700 }
        5 { return 6500 }
        default { return 6500 + (($Level - 5) * 3000) }
    }
}

function Get-HeroNextLevelXPThreshold {
    param($Hero)

    return Get-XPThresholdForLevel -Level ($Hero.Level + 1)
}

function Get-HeroAvailableLevelUps {
    param($Hero)

    $available = 0
    $currentLevel = [int]$Hero.Level
    $levelCap = $null

    if ($null -ne $Hero.PSObject.Properties["LevelCap"]) {
        $levelCap = [int]$Hero.LevelCap
    }

    while ($Hero.XP -ge (Get-XPThresholdForLevel -Level ($currentLevel + $available + 1))) {
        if ($null -ne $levelCap -and ($currentLevel + $available) -ge $levelCap) {
            break
        }

        $available += 1
    }

    return $available
}

function Get-HeroMaxHP {
    param($Hero)

    $hitDie = 12
    $level = 1

    if ($null -ne $Hero.PSObject.Properties["HitDie"]) {
        $hitDie = [int]$Hero.HitDie
    }

    if ($null -ne $Hero.PSObject.Properties["Level"]) {
        $level = [int]$Hero.Level
    }

    $constitutionModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "CON"
    $maxHP = $hitDie + $constitutionModifier

    if ($level -le 1) {
        return $maxHP
    }

    $levelUpGain = ([Math]::Floor($hitDie / 2) + 1) + $constitutionModifier

    return $maxHP + (($level - 1) * $levelUpGain)
}

function Get-HeroLevelUpFixedHPGain {
    param($Hero)

    $hitDie = [int]$Hero.HitDie
    $constitutionModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "CON"
    return ([Math]::Floor($hitDie / 2) + 1) + $constitutionModifier
}

function Resolve-HeroLevelUpHPGain {
    param(
        $Hero,
        [string]$Mode = ""
    )

    $hitDie = [int]$Hero.HitDie
    $constitutionModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "CON"
    $fixedGain = Get-HeroLevelUpFixedHPGain -Hero $Hero

    while ([string]::IsNullOrWhiteSpace($Mode)) {
        Write-SectionTitle -Text "Choose HP Increase" -Color "Yellow"
        Write-ColorLine "F. Fixed increase: $fixedGain HP" "White"
        Write-ColorLine "R. Roll $hitDie-sided hit die: 1d$hitDie + $constitutionModifier" "White"
        Write-ColorLine ""
        $Mode = (Read-Host "Choose HP gain (F/R)").ToUpper()

        if ($Mode -notin @("F", "R")) {
            Write-ColorLine "Choose F for fixed HP or R to roll." "DarkYellow"
            Write-ColorLine ""
            $Mode = ""
        }
    }

    if ($Mode -eq "R") {
        $roll = Roll-Dice -Sides $hitDie
        $gain = [Math]::Max(1, $roll + $constitutionModifier)

        return [PSCustomObject]@{
            Mode = "R"
            Roll = $roll
            Gain = $gain
        }
    }

    return [PSCustomObject]@{
        Mode = "F"
        Roll = $null
        Gain = $fixedGain
    }
}

function Grant-HeroXP {
    param(
        $Hero,
        [int]$XP
    )

    if ($null -eq $Hero.PSObject.Properties["XP"]) {
        $Hero | Add-Member -NotePropertyName XP -NotePropertyValue 0
    }

    $Hero.XP += $XP
}

function Resolve-HeroLongRestLevelUp {
    param(
        $Hero,
        [ref]$HeroHP,
        [string]$HPMode = ""
    )

    $availableLevelUps = Get-HeroAvailableLevelUps -Hero $Hero
    $levelUpResults = @()

    for ($i = 0; $i -lt $availableLevelUps; $i++) {
        $oldMaxHP = $Hero.HP
        $hpGainResult = Resolve-HeroLevelUpHPGain -Hero $Hero -Mode $HPMode
        $Hero.Level += 1
        $Hero.HP = $oldMaxHP + $hpGainResult.Gain
        $levelUpResults += [PSCustomObject]@{
            Level = $Hero.Level
            Gain = $hpGainResult.Gain
            Mode = $hpGainResult.Mode
            Roll = $hpGainResult.Roll
        }
    }

    if ($availableLevelUps -gt 0) {
        $HeroHP.Value = $Hero.HP
    }
    else {
        $HeroHP.Value = [Math]::Min($HeroHP.Value, $Hero.HP)
    }

    return [PSCustomObject]@{
        LeveledUp = ($availableLevelUps -gt 0)
        Results = $levelUpResults
    }
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
    $strengthModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "STR"
    $proficiencyBonus = Get-HeroProficiencyBonus -Hero $Hero

    if ($weapon) {
        return [PSCustomObject]@{
            Name              = $weapon.Name
            AttackBonus       = [int]$weapon.AttackBonus
            TotalAttackBonus  = $proficiencyBonus + $strengthModifier + [int]$weapon.AttackBonus
            DamageBonus       = $strengthModifier
            DamageDiceCount   = [int]$weapon.DamageDiceCount
            DamageDiceSides   = [int]$weapon.DamageDiceSides
            DamageMin         = [int]$weapon.DamageMin
            DamageMax         = [int]$weapon.DamageMax
            TotalDamageMin    = [Math]::Max(1, [int]$weapon.DamageMin + $strengthModifier)
            TotalDamageMax    = [Math]::Max(1, [int]$weapon.DamageMax + $strengthModifier)
        }
    }

    return [PSCustomObject]@{
        Name              = "Bare Hands"
        AttackBonus       = 0
        TotalAttackBonus  = $proficiencyBonus + $strengthModifier
        DamageBonus       = $strengthModifier
        DamageDiceCount   = 1
        DamageDiceSides   = 2
        DamageMin         = 1
        DamageMax         = 2
        TotalDamageMin    = [Math]::Max(1, 1 + $strengthModifier)
        TotalDamageMax    = [Math]::Max(1, 2 + $strengthModifier)
    }
}

function Get-WeaponDamageRollText {
    param($WeaponProfile)

    return "$($WeaponProfile.DamageDiceCount)d$($WeaponProfile.DamageDiceSides)"
}

function Roll-WeaponDamage {
    param(
        $WeaponProfile,
        [int]$DiceCount = 0
    )

    if ($DiceCount -le 0) {
        $DiceCount = [int]$WeaponProfile.DamageDiceCount
    }

    $total = 0

    for ($i = 0; $i -lt $DiceCount; $i++) {
        $total += Roll-Dice -Sides $WeaponProfile.DamageDiceSides
    }

    return $total
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
    $hero = [PSCustomObject]@{
        Name               = "Borzig"
        Class              = "Barbarian"
        Level              = 1
        LevelCap           = 2
        XP                 = 0
        HitDie             = 12
        STR                = 15
        DEX                = 14
        CON                = 15
        INT                = 8
        WIS                = 10
        CHA                = 8
        BaseArmorClass     = 10
        BaseInventorySlots = 4
        Inventory          = @(
            (New-WeaponItem -Name "Great Axe" -Value 0 -AttackBonus 0 -DamageDiceCount 1 -DamageDiceSides 12 -SlotCost 2 -Equipped $true)
            (New-ArmorItem -Name "Helmet" -Value 0 -ArmorBonus 1 -SlotCost 1 -Equipped $true)
            (New-UtilityItem -Name "Backpack" -Value 0 -SlotBonus 4 -SlotCost 1 -Equipped $true)
            (New-ConsumableItem -Name "Healing Potion" -Value 0 -HealAmount 8 -SlotCost 1)
        )
    }

    $hero | Add-Member -NotePropertyName HP -NotePropertyValue (Get-HeroMaxHP -Hero $hero)

    return $hero
}
