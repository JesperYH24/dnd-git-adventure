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

function Get-ShadowSanctumGoldRewardGP {
    return 2
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

function Resolve-HeroShortRest {
    param(
        $Hero,
        [ref]$HeroHP
    )

    if ($HeroHP.Value -ge $Hero.HP) {
        Clear-HeroBuff -Hero $Hero
        $restoredBardicInspiration = 0

        if ($Hero.Class -eq "Bard") {
            $beforeDice = if ($null -ne $Hero.PSObject.Properties["CurrentBardicInspirationDice"]) { [int]$Hero.CurrentBardicInspirationDice } else { 0 }
            $prepared = Prepare-HeroBardicInspiration -Hero $Hero

            if ($prepared.Success) {
                $restoredBardicInspiration = [Math]::Max(0, [int]$Hero.CurrentBardicInspirationDice - $beforeDice)
            }
        }

        return [PSCustomObject]@{
            Healed = 0
            Roll = $null
            Modifier = Get-HeroAbilityModifier -Hero $Hero -Ability "CON"
            ClearedBuff = $true
            RestoredBardicInspiration = $restoredBardicInspiration
        }
    }

    $constitutionModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "CON"
    $roll = Roll-Dice -Sides 8
    $healing = [Math]::Max(1, $roll + $constitutionModifier)
    $oldHP = $HeroHP.Value
    $HeroHP.Value = [Math]::Min($Hero.HP, $HeroHP.Value + $healing)
    Clear-HeroBuff -Hero $Hero
    $restoredBardicInspiration = 0

    if ($Hero.Class -eq "Bard") {
        $beforeDice = if ($null -ne $Hero.PSObject.Properties["CurrentBardicInspirationDice"]) { [int]$Hero.CurrentBardicInspirationDice } else { 0 }
        $prepared = Prepare-HeroBardicInspiration -Hero $Hero

        if ($prepared.Success) {
            $restoredBardicInspiration = [Math]::Max(0, [int]$Hero.CurrentBardicInspirationDice - $beforeDice)
        }
    }

    return [PSCustomObject]@{
        Healed = ($HeroHP.Value - $oldHP)
        Roll = $roll
        Modifier = $constitutionModifier
        ClearedBuff = $true
        RestoredBardicInspiration = $restoredBardicInspiration
    }
}

function Get-EquippedArmor {
    param($Hero)

    return ($Hero.Inventory | Where-Object { $_.Type -eq "Armor" -and $_.Equipped } | Select-Object -First 1)
}

function Get-HeroBackpackItem {
    param($Hero)

    return ($Hero.Inventory | Where-Object { $_.Type -eq "Utility" -and $_.Name -eq "Backpack" } | Select-Object -First 1)
}

function Get-BackpackCapacity {
    param($Hero)

    if ($null -eq (Get-HeroBackpackItem -Hero $Hero)) {
        return 0
    }

    if ($null -ne $Hero.PSObject.Properties["BackpackCapacitySlots"]) {
        return [int]$Hero.BackpackCapacitySlots
    }

    return 0
}

function Get-BackpackUsedSlots {
    param($Hero)

    if ($null -eq $Hero.PSObject.Properties["BackpackInventory"] -or $null -eq $Hero.BackpackInventory) {
        return 0
    }

    $usedSlots = 0

    foreach ($item in $Hero.BackpackInventory) {
        $usedSlots += Get-ItemSlotCost -Item $item
    }

    return $usedSlots
}

function Get-InventoryCapacity {
    param($Hero)

    $utilityBonus = 0

    foreach ($item in $Hero.Inventory) {
        if ($item.Type -eq "Utility" -and $item.Name -ne "Backpack" -and $null -ne $item.SlotBonus) {
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

function Can-HeroStoreItemInBackpack {
    param(
        $Hero,
        $Item
    )

    if ($Item.Type -eq "Currency") {
        return $false
    }

    $capacity = Get-BackpackCapacity -Hero $Hero

    if ($capacity -le 0) {
        return $false
    }

    $usedSlots = Get-BackpackUsedSlots -Hero $Hero
    return ($usedSlots + (Get-ItemSlotCost -Item $Item)) -le $capacity
}

function Add-ItemToHeroStorage {
    param(
        $Hero,
        $Item
    )

    if (Can-HeroCarryItem -Hero $Hero -Item $Item) {
        $Hero.Inventory += $Item
        return [PSCustomObject]@{
            Success = $true
            Location = "Inventory"
        }
    }

    if (Can-HeroStoreItemInBackpack -Hero $Hero -Item $Item) {
        $Hero.BackpackInventory += $Item
        return [PSCustomObject]@{
            Success = $true
            Location = "Backpack"
        }
    }

    return [PSCustomObject]@{
        Success = $false
        Location = ""
    }
}

function Get-HeroArmorClass {
    param($Hero)

    $armorBonus = 0
    $dexterityModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "DEX"

    foreach ($item in $Hero.Inventory) {
        if ($item.Type -eq "Armor" -and $item.Equipped -and $null -ne $item.ArmorBonus) {
            $armorBonus += [int]$item.ArmorBonus

            if ($null -ne $item.PSObject.Properties["AddsDexModifier"] -and $item.AddsDexModifier) {
                $dexBonus = $dexterityModifier

                if ($null -ne $item.PSObject.Properties["DexBonusCap"] -and [int]$item.DexBonusCap -ge 0) {
                    $dexBonus = [Math]::Min($dexBonus, [int]$item.DexBonusCap)
                }

                $armorBonus += [Math]::Max(0, $dexBonus)
            }
        }
    }

    return $Hero.BaseArmorClass + $armorBonus
}

function Get-HeroBrawlAbility {
    param($Hero)

    if ($Hero.Class -eq "Barbarian") {
        return "STR"
    }

    $strengthModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "STR"
    $dexterityModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "DEX"

    if ($dexterityModifier -gt $strengthModifier) {
        return "DEX"
    }

    return "STR"
}

function Get-HeroWeaponAbility {
    param(
        $Hero,
        $Weapon
    )

    if ($null -eq $Weapon) {
        return "STR"
    }

    $strengthModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "STR"
    $dexterityModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "DEX"
    $canUseDexterity = $null -ne $Weapon.PSObject.Properties["RequiredDEX"] -and [int]$Weapon.RequiredDEX -gt 0

    if ($canUseDexterity -and $dexterityModifier -gt $strengthModifier) {
        return "DEX"
    }

    return "STR"
}

function Get-HeroAbilityCheckModifier {
    param(
        $Hero,
        [string]$Ability
    )

    $modifier = Get-HeroAbilityModifier -Hero $Hero -Ability $Ability
    $classBonus = 0

    if ($Hero.Class -eq "Bard" -and $Ability -eq "CHA") {
        $classBonus = 2
    }

    return [PSCustomObject]@{
        AbilityModifier = $modifier
        ClassBonus = $classBonus
        TotalModifier = $modifier + $classBonus
    }
}

function Get-HeroSpellSaveDC {
    param($Hero)

    if ($Hero.Class -eq "Bard") {
        return 8 + (Get-HeroProficiencyBonus -Hero $Hero) + (Get-HeroAbilityModifier -Hero $Hero -Ability "CHA")
    }

    return 8 + (Get-HeroProficiencyBonus -Hero $Hero)
}

function Get-HeroBardicInspirationMaxDice {
    param($Hero)

    if ($Hero.Class -ne "Bard") {
        return 0
    }

    return 1 + [Math]::Max(0, (Get-HeroAbilityModifier -Hero $Hero -Ability "CHA"))
}

function Get-HeroInstrument {
    param($Hero)

    $candidates = @()

    foreach ($item in $Hero.Inventory) {
        if ($item.Type -eq "Utility" -and $null -ne $item.PSObject.Properties["InspirationBonus"] -and [int]$item.InspirationBonus -gt 0) {
            $candidates += $item
        }
    }

    if ($candidates.Count -eq 0 -and $null -ne $Hero.PSObject.Properties["BackpackInventory"]) {
        foreach ($item in $Hero.BackpackInventory) {
            if ($item.Type -eq "Utility" -and $null -ne $item.PSObject.Properties["InspirationBonus"] -and [int]$item.InspirationBonus -gt 0) {
                $candidates += $item
            }
        }
    }

    if ($candidates.Count -eq 0) {
        return $null
    }

    return ($candidates | Sort-Object @{ Expression = { [int]$_.InspirationBonus }; Descending = $true }, Name | Select-Object -First 1)
}

function Get-HeroBardicInspirationStatus {
    param($Hero)

    if ($Hero.Class -ne "Bard") {
        return $null
    }

    $instrument = Get-HeroInstrument -Hero $Hero

    return [PSCustomObject]@{
        CurrentDice = if ($null -ne $Hero.PSObject.Properties["CurrentBardicInspirationDice"]) { [int]$Hero.CurrentBardicInspirationDice } else { 0 }
        MaxDice = Get-HeroBardicInspirationMaxDice -Hero $Hero
        DieSides = if ($null -ne $Hero.PSObject.Properties["BardicInspirationDieSides"]) { [int]$Hero.BardicInspirationDieSides } else { 6 }
        Instrument = $instrument
        InstrumentBonus = if ($null -ne $instrument) { [int]$instrument.InspirationBonus } else { 0 }
    }
}

function Prepare-HeroBardicInspiration {
    param($Hero)

    if ($Hero.Class -ne "Bard") {
        return [PSCustomObject]@{
            Success = $false
            Message = ""
            DicePrepared = 0
        }
    }

    $instrument = Get-HeroInstrument -Hero $Hero
    $maxDice = Get-HeroBardicInspirationMaxDice -Hero $Hero

    if ($null -eq $instrument) {
        return [PSCustomObject]@{
            Success = $false
            Message = "$($Hero.Name) needs a musical instrument on hand to prepare bardic inspiration."
            DicePrepared = 0
        }
    }

    if ($maxDice -le 0) {
        return [PSCustomObject]@{
            Success = $false
            Message = "$($Hero.Name) lacks the force of presence to build a battle-ready refrain."
            DicePrepared = 0
        }
    }

    $Hero.CurrentBardicInspirationDice = $maxDice

    return [PSCustomObject]@{
        Success = $true
        Message = "$($Hero.Name) plays the $($instrument.Name.ToLower()) and carries $maxDice bardic inspiration d$($Hero.BardicInspirationDieSides) into the next danger."
        DicePrepared = $maxDice
    }
}

function Use-HeroBardicInspirationDie {
    param($Hero)

    $status = Get-HeroBardicInspirationStatus -Hero $Hero

    if ($null -eq $status -or $status.CurrentDice -le 0) {
        return [PSCustomObject]@{
            Success = $false
            TotalBonus = 0
            Roll = 0
            InstrumentBonus = 0
            InstrumentName = ""
        }
    }

    $roll = Roll-Dice -Sides $status.DieSides
    $totalBonus = $roll + $status.InstrumentBonus
    $Hero.CurrentBardicInspirationDice = [Math]::Max(0, $status.CurrentDice - 1)

    return [PSCustomObject]@{
        Success = $true
        TotalBonus = $totalBonus
        Roll = $roll
        InstrumentBonus = $status.InstrumentBonus
        InstrumentName = if ($null -ne $status.Instrument) { $status.Instrument.Name } else { "" }
    }
}

function Get-HeroUnarmedProfile {
    param($Hero)

    $ability = Get-HeroBrawlAbility -Hero $Hero
    $abilityModifier = Get-HeroAbilityModifier -Hero $Hero -Ability $ability
    $proficiencyBonus = Get-HeroProficiencyBonus -Hero $Hero
    $trainingBonus = 0

    if ($null -ne $Hero.PSObject.Properties["UnarmedTrainingLevel"]) {
        $trainingBonus = [int]$Hero.UnarmedTrainingLevel
    }

    return [PSCustomObject]@{
        Name                 = "Bare Hands"
        Ability              = $ability
        AttackBonus          = 0
        TotalAttackBonus     = $proficiencyBonus + $abilityModifier + $trainingBonus
        DamageBonus          = $abilityModifier + $trainingBonus
        DamageDiceCount      = 1
        DamageDiceSides      = 4
        DamageMin            = 1
        DamageMax            = 4
        BonusDamageDiceCount = 0
        BonusDamageDiceSides = 0
        BonusDamageType      = ""
        TotalDamageMin       = [Math]::Max(1, 1 + $abilityModifier + $trainingBonus)
        TotalDamageMax       = [Math]::Max(1, 4 + $abilityModifier + $trainingBonus)
    }
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
    $proficiencyBonus = Get-HeroProficiencyBonus -Hero $Hero

    if ($weapon) {
        $attackAbility = Get-HeroWeaponAbility -Hero $Hero -Weapon $weapon
        $attackAbilityModifier = Get-HeroAbilityModifier -Hero $Hero -Ability $attackAbility

        return [PSCustomObject]@{
            Name              = $weapon.Name
            Ability           = $attackAbility
            AttackBonus       = [int]$weapon.AttackBonus
            TotalAttackBonus  = $proficiencyBonus + $attackAbilityModifier + [int]$weapon.AttackBonus
            DamageBonus       = $attackAbilityModifier
            DamageDiceCount   = [int]$weapon.DamageDiceCount
            DamageDiceSides   = [int]$weapon.DamageDiceSides
            DamageMin         = [int]$weapon.DamageMin
            DamageMax         = [int]$weapon.DamageMax
            BonusDamageDiceCount = [int]$weapon.BonusDamageDiceCount
            BonusDamageDiceSides = [int]$weapon.BonusDamageDiceSides
            BonusDamageType  = $weapon.BonusDamageType
            TotalDamageMin    = [Math]::Max(1, [int]$weapon.DamageMin + $attackAbilityModifier)
            TotalDamageMax    = [Math]::Max(1, [int]$weapon.DamageMax + $attackAbilityModifier + ([int]$weapon.BonusDamageDiceCount * [int]$weapon.BonusDamageDiceSides))
        }
    }

    return Get-HeroUnarmedProfile -Hero $Hero
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

    if ($Item.Type -eq "Utility" -and $Item.Name -eq "Backpack" -and (Get-BackpackUsedSlots -Hero $Hero) -gt 0) {
        return $false
    }

    $capacityAfterDrop = Get-InventoryCapacity -Hero $Hero

    if ($Item.Type -eq "Utility" -and $Item.Name -ne "Backpack" -and $null -ne $Item.SlotBonus) {
        $capacityAfterDrop -= [int]$Item.SlotBonus
    }

    $usedAfterDrop = (Get-InventoryUsedSlots -Hero $Hero) - (Get-ItemSlotCost -Item $Item)

    return $usedAfterDrop -le $capacityAfterDrop
}

function Get-Hero {
    param(
        [string]$Class = "Barbarian"
    )

    switch ($Class) {
        "Bard" {
            $hero = [PSCustomObject]@{
                Name               = "Gariand"
                Class              = "Bard"
                Level              = 1
                LevelCap           = 2
                XP                 = 0
                GoldPouchCapacityGP = 150
                CurrencyCopper     = 0
                ActiveBuff         = $null
                CurrentBardicInspirationDice = 0
                BardicInspirationDieSides = 6
                TutorialCampfireHintShown = $false
                TutorialCombatHintShown = $false
                UnarmedTrainingLevel = 0
                RingWinsTotal      = 0
                RingVisits         = 0
                RingRivalries      = @{}
                HitDie             = 8
                STR                = 8
                DEX                = 14
                CON                = 12
                INT                = 10
                WIS                = 10
                CHA                = 15
                BaseArmorClass     = 10
                BaseInventorySlots = 8
                BackpackCapacitySlots = 4
                BackpackInventory  = @()
                StashedInventory   = @()
                Inventory          = @(
                    (New-WeaponItem -Name "Rapier" -Value 0 -AttackBonus 0 -DamageDiceCount 1 -DamageDiceSides 8 -Handedness "One-Handed" -RequiredDEX 12 -SlotCost 1 -Equipped $true)
                    (New-ArmorItem -Name "Leather Armor" -Value 0 -ArmorBonus 1 -AddsDexModifier $true -SlotCost 1 -Equipped $true)
                    (New-UtilityItem -Name "Travel Lute" -Value 0 -InspirationBonus 1 -SlotCost 1 -Equipped $true)
                    (New-UtilityItem -Name "Backpack" -Value 0 -SlotBonus 0 -SlotCost 0 -Equipped $true)
                    (New-ConsumableItem -Name "Healing Potion" -Value 0 -HealAmount 8 -SlotCost 1)
                )
            }
        }
        default {
            $hero = [PSCustomObject]@{
                Name               = "Borzig"
                Class              = "Barbarian"
                Level              = 1
                LevelCap           = 2
                XP                 = 0
                GoldPouchCapacityGP = 150
                CurrencyCopper     = 0
                ActiveBuff         = $null
                CurrentBardicInspirationDice = 0
                BardicInspirationDieSides = 6
                TutorialCampfireHintShown = $false
                TutorialCombatHintShown = $false
                UnarmedTrainingLevel = 0
                RingWinsTotal      = 0
                RingVisits         = 0
                RingRivalries      = @{}
                HitDie             = 12
                STR                = 15
                DEX                = 14
                CON                = 15
                INT                = 8
                WIS                = 10
                CHA                = 8
                BaseArmorClass     = 10
                BaseInventorySlots = 8
                BackpackCapacitySlots = 4
                BackpackInventory  = @()
                StashedInventory   = @()
                Inventory          = @(
                    (New-WeaponItem -Name "Great Axe" -Value 0 -AttackBonus 0 -DamageDiceCount 1 -DamageDiceSides 12 -Handedness "Two-Handed" -RequiredSTR 13 -SlotCost 2 -Equipped $true)
                    (New-ArmorItem -Name "Helmet" -Value 0 -ArmorBonus 1 -SlotCost 1 -Equipped $true)
                    (New-UtilityItem -Name "Backpack" -Value 0 -SlotBonus 0 -SlotCost 0 -Equipped $true)
                    (New-ConsumableItem -Name "Healing Potion" -Value 0 -HealAmount 8 -SlotCost 1)
                )
            }
        }
    }

    $hero | Add-Member -NotePropertyName HP -NotePropertyValue (Get-HeroMaxHP -Hero $hero)

    return $hero
}
