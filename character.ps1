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

function Convert-CurrencyToCopper {
    param(
        [string]$Denomination,
        [int]$Amount
    )

    switch ($Denomination.ToUpper()) {
        "CP" { return $Amount }
        "SP" { return $Amount * 10 }
        "GP" { return $Amount * 100 }
        default { return 0 }
    }
}

function Get-HeroGoldPouchCapacityCopper {
    param($Hero)

    if ($null -ne $Hero.PSObject.Properties["GoldPouchCapacityGP"]) {
        return [int]$Hero.GoldPouchCapacityGP * 100
    }

    return 0
}

function Get-HeroCurrencyBreakdown {
    param($Hero)

    $totalCopper = 0

    if ($null -ne $Hero.PSObject.Properties["CurrencyCopper"]) {
        $totalCopper = [int]$Hero.CurrencyCopper
    }

    $gold = [Math]::Floor($totalCopper / 100)
    $remainder = $totalCopper % 100
    $silver = [Math]::Floor($remainder / 10)
    $copper = $remainder % 10

    return [PSCustomObject]@{
        Gold = $gold
        Silver = $silver
        Copper = $copper
        TotalCopper = $totalCopper
    }
}

function Get-HeroCurrencyText {
    param($Hero)

    $breakdown = Get-HeroCurrencyBreakdown -Hero $Hero
    return "$($breakdown.Gold) GP, $($breakdown.Silver) SP, $($breakdown.Copper) CP"
}

function Convert-CopperToCurrencyText {
    param([int]$Copper)

    $gold = [Math]::Floor($Copper / 100)
    $remainder = $Copper % 100
    $silver = [Math]::Floor($remainder / 10)
    $copperRemainder = $remainder % 10

    return "$gold GP, $silver SP, $copperRemainder CP"
}

function Convert-CopperToCurrencyItem {
    param([int]$Copper)

    if ($Copper -ge 100 -and ($Copper % 100) -eq 0) {
        return New-CurrencyItem -Name "Gold Coins" -Denomination "GP" -Amount ($Copper / 100)
    }

    if ($Copper -ge 10 -and ($Copper % 10) -eq 0) {
        return New-CurrencyItem -Name "Silver Coins" -Denomination "SP" -Amount ($Copper / 10)
    }

    return New-CurrencyItem -Name "Copper Coins" -Denomination "CP" -Amount $Copper
}

function Add-HeroCurrency {
    param(
        $Hero,
        [string]$Denomination,
        [int]$Amount
    )

    $addedCopper = Convert-CurrencyToCopper -Denomination $Denomination -Amount $Amount
    $capacityCopper = Get-HeroGoldPouchCapacityCopper -Hero $Hero
    $currentCopper = [int]$Hero.CurrencyCopper
    $spaceLeft = [Math]::Max(0, $capacityCopper - $currentCopper)
    $storedCopper = [Math]::Min($addedCopper, $spaceLeft)
    $leftoverCopper = $addedCopper - $storedCopper

    $Hero.CurrencyCopper += $storedCopper

    return [PSCustomObject]@{
        StoredCopper = $storedCopper
        LeftoverCopper = $leftoverCopper
        LeftoverItem = if ($leftoverCopper -gt 0) { Convert-CopperToCurrencyItem -Copper $leftoverCopper } else { $null }
    }
}

function Spend-HeroCurrency {
    param(
        $Hero,
        [int]$Copper
    )

    $currentCopper = [int]$Hero.CurrencyCopper

    if ($Copper -gt $currentCopper) {
        return [PSCustomObject]@{
            Success = $false
            SpentCopper = 0
            RemainingCopper = $currentCopper
        }
    }

    $Hero.CurrencyCopper -= $Copper

    return [PSCustomObject]@{
        Success = $true
        SpentCopper = $Copper
        RemainingCopper = [int]$Hero.CurrencyCopper
    }
}

function Apply-HeroBuff {
    param(
        $Hero,
        [string]$BuffType,
        [string]$BuffName
    )

    $Hero.ActiveBuff = [PSCustomObject]@{
        Type = $BuffType
        Name = $BuffName
    }
}

function Clear-HeroBuff {
    param($Hero)

    $Hero.ActiveBuff = $null
}

function Get-HeroHasInitiativeAdvantage {
    param($Hero)

    if ($null -eq $Hero.PSObject.Properties["ActiveBuff"]) {
        return $false
    }

    if ($null -eq $Hero.ActiveBuff) {
        return $false
    }

    return $Hero.ActiveBuff.Type -eq "Haste"
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

function Get-WeaponRequirementText {
    param($Weapon)

    $parts = @()

    if ($null -ne $Weapon.PSObject.Properties["Handedness"] -and -not [string]::IsNullOrWhiteSpace($Weapon.Handedness)) {
        $parts += $Weapon.Handedness
    }

    if ($null -ne $Weapon.PSObject.Properties["Light"] -and $Weapon.Light) {
        $parts += "Light"
    }

    if ($null -ne $Weapon.PSObject.Properties["RequiredSTR"] -and [int]$Weapon.RequiredSTR -gt 0) {
        $parts += "STR $($Weapon.RequiredSTR)"
    }

    if ($null -ne $Weapon.PSObject.Properties["RequiredDEX"] -and [int]$Weapon.RequiredDEX -gt 0) {
        $parts += "DEX $($Weapon.RequiredDEX)"
    }

    if ($parts.Count -eq 0) {
        return "No restrictions"
    }

    return ($parts -join ", ")
}

function Can-HeroUseWeapon {
    param(
        $Hero,
        $Weapon
    )

    if ($Weapon.Type -ne "Weapon") {
        return [PSCustomObject]@{
            CanUse = $false
            Message = "$($Weapon.Name) is not a weapon."
        }
    }

    $heroStrength = Get-HeroAbilityScore -Hero $Hero -Ability "STR"
    $heroDexterity = Get-HeroAbilityScore -Hero $Hero -Ability "DEX"

    if ($null -ne $Weapon.PSObject.Properties["RequiredSTR"] -and [int]$Weapon.RequiredSTR -gt 0 -and $heroStrength -lt [int]$Weapon.RequiredSTR) {
        return [PSCustomObject]@{
            CanUse = $false
            Message = "$($Hero.Name) lacks the strength to wield $($Weapon.Name)."
        }
    }

    if ($null -ne $Weapon.PSObject.Properties["RequiredDEX"] -and [int]$Weapon.RequiredDEX -gt 0 -and $heroDexterity -lt [int]$Weapon.RequiredDEX) {
        return [PSCustomObject]@{
            CanUse = $false
            Message = "$($Hero.Name) lacks the dexterity to wield $($Weapon.Name)."
        }
    }

    return [PSCustomObject]@{
        CanUse = $true
        Message = ""
    }
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
            BonusDamageDiceCount = [int]$weapon.BonusDamageDiceCount
            BonusDamageDiceSides = [int]$weapon.BonusDamageDiceSides
            BonusDamageType  = $weapon.BonusDamageType
            TotalDamageMin    = [Math]::Max(1, [int]$weapon.DamageMin + $strengthModifier)
            TotalDamageMax    = [Math]::Max(1, [int]$weapon.DamageMax + $strengthModifier + ([int]$weapon.BonusDamageDiceCount * [int]$weapon.BonusDamageDiceSides))
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
        BonusDamageDiceCount = 0
        BonusDamageDiceSides = 0
        BonusDamageType  = ""
        TotalDamageMin    = [Math]::Max(1, 1 + $strengthModifier)
        TotalDamageMax    = [Math]::Max(1, 2 + $strengthModifier)
    }
}

function Get-WeaponDamageRollText {
    param($WeaponProfile)

    $text = "$($WeaponProfile.DamageDiceCount)d$($WeaponProfile.DamageDiceSides)"

    if ($null -ne $WeaponProfile.PSObject.Properties["BonusDamageDiceCount"] -and [int]$WeaponProfile.BonusDamageDiceCount -gt 0) {
        $bonusText = "$($WeaponProfile.BonusDamageDiceCount)d$($WeaponProfile.BonusDamageDiceSides)"

        if (-not [string]::IsNullOrWhiteSpace($WeaponProfile.BonusDamageType)) {
            $bonusText = "$bonusText $($WeaponProfile.BonusDamageType.ToLower())"
        }

        $text = "$text + $bonusText"
    }

    return $text
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

function Roll-WeaponBonusDamage {
    param($WeaponProfile)

    if ($null -eq $WeaponProfile.PSObject.Properties["BonusDamageDiceCount"]) {
        return 0
    }

    $diceCount = [int]$WeaponProfile.BonusDamageDiceCount
    $diceSides = [int]$WeaponProfile.BonusDamageDiceSides

    if ($diceCount -le 0 -or $diceSides -le 0) {
        return 0
    }

    $total = 0

    for ($i = 0; $i -lt $diceCount; $i++) {
        $total += Roll-Dice -Sides $diceSides
    }

    return $total
}

function Set-EquippedItem {
    param(
        $Hero,
        $Item
    )

    if ($Item.Type -eq "Weapon") {
        $weaponCheck = Can-HeroUseWeapon -Hero $Hero -Weapon $Item

        if (-not $weaponCheck.CanUse) {
            return [PSCustomObject]@{
                Success = $false
                CanUse = $false
                Message = $weaponCheck.Message
            }
        }

        foreach ($inventoryItem in $Hero.Inventory) {
            if ($inventoryItem.Type -eq "Weapon") {
                $inventoryItem.Equipped = $false
            }
        }

        $Item.Equipped = $true
        return [PSCustomObject]@{
            Success = $true
            Message = ""
        }
    }

    if ($Item.Type -eq "Armor") {
        $Item.Equipped = $true
        return [PSCustomObject]@{
            Success = $true
            Message = ""
        }
    }

    return [PSCustomObject]@{
        Success = $false
        Message = "$($Item.Name) cannot be equipped."
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
        GoldPouchCapacityGP = 150
        CurrencyCopper     = 0
        ActiveBuff         = $null
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
            (New-WeaponItem -Name "Great Axe" -Value 0 -AttackBonus 0 -DamageDiceCount 1 -DamageDiceSides 12 -Handedness "Two-Handed" -RequiredSTR 13 -SlotCost 2 -Equipped $true)
            (New-ArmorItem -Name "Helmet" -Value 0 -ArmorBonus 1 -SlotCost 1 -Equipped $true)
            (New-UtilityItem -Name "Backpack" -Value 0 -SlotBonus 4 -SlotCost 1 -Equipped $true)
            (New-ConsumableItem -Name "Healing Potion" -Value 0 -HealAmount 8 -SlotCost 1)
        )
    }

    $hero | Add-Member -NotePropertyName HP -NotePropertyValue (Get-HeroMaxHP -Hero $hero)

    return $hero
}
