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

function Get-HeroAbilityNames {
    return @("STR", "DEX", "CON", "INT", "WIS", "CHA")
}

function Normalize-HeroAbilityName {
    param([string]$Ability)

    if ([string]::IsNullOrWhiteSpace($Ability)) {
        return ""
    }

    $normalized = $Ability.Trim().ToUpper()

    if ($normalized -in (Get-HeroAbilityNames)) {
        return $normalized
    }

    return ""
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

function Test-HeroFeatureUnlocked {
    param(
        $Hero,
        [string]$Feature
    )

    if ($null -eq $Hero -or [string]::IsNullOrWhiteSpace($Feature)) {
        return $false
    }

    $level = if ($null -ne $Hero.PSObject.Properties["Level"]) { [int]$Hero.Level } else { 1 }

    switch ($Hero.Class) {
        "Barbarian" {
            switch ($Feature) {
                "Rage" { return $level -ge 1 }
                "UnarmoredDefense" { return $level -ge 1 }
                "RecklessAttack" { return $level -ge 2 }
                "DangerSense" { return $level -ge 2 }
                "Frenzy" { return $level -ge 3 }
                "AbilityScoreIncrease" { return $level -ge 4 }
                default { return $false }
            }
        }
        "Fighter" {
            switch ($Feature) {
                "FightingStyleDefense" { return $level -ge 1 }
                "SecondWind" { return $level -ge 1 }
                "ActionSurge" { return $level -ge 2 }
                "ImprovedCritical" { return $level -ge 3 }
                "AbilityScoreIncrease" { return $level -ge 4 }
                default { return $false }
            }
        }
        "Bard" {
            switch ($Feature) {
                "BardicInspiration" { return $level -ge 1 }
                "Spellcasting" { return $level -ge 1 }
                "ViciousMockery" { return $level -ge 1 }
                "JackOfAllTrades" { return $level -ge 2 }
                "SongOfRest" { return $level -ge 2 }
                "CuttingWords" { return $level -ge 3 }
                "LoreBonusProficiencies" { return $level -ge 3 }
                "Expertise" { return $level -ge 3 }
                "AbilityScoreIncrease" { return $level -ge 4 }
                default { return $false }
            }
        }
        default {
            return $false
        }
    }
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
    param(
        [int]$Roll
    )

    if ($Roll -le 4) {
        return 1
    }
    elseif ($Roll -le 9) {
        return 2
    }
    elseif ($Roll -le 14) {
        return 3
    }
    elseif ($Roll -le 18) {
        return 4
    }
    elseif ($Roll -eq 19) {
        return 5
    }

    return 6
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

function Get-HeroPrimaryAbilityForASI {
    param($Hero)

    if ($Hero.Class -eq "Bard") {
        return "CHA"
    }

    if ($Hero.Class -eq "Fighter") {
        return "CON"
    }

    return "STR"
}

function Ensure-HeroAbilityScoreIncreaseState {
    param($Hero)

    if ($null -eq $Hero.PSObject.Properties["AbilityScoreIncreasesApplied"]) {
        $Hero | Add-Member -NotePropertyName AbilityScoreIncreasesApplied -NotePropertyValue @{}
    }

    if ($null -eq $Hero.AbilityScoreIncreasesApplied) {
        $Hero.AbilityScoreIncreasesApplied = @{}
    }
}

function Add-HeroAbilityScoreIncrease {
    param(
        $Hero,
        [string]$Ability,
        [int]$Amount
    )

    $normalizedAbility = Normalize-HeroAbilityName -Ability $Ability

    if ([string]::IsNullOrWhiteSpace($normalizedAbility) -or $Amount -le 0) {
        return 0
    }

    $currentScore = Get-HeroAbilityScore -Hero $Hero -Ability $normalizedAbility
    $newScore = [Math]::Min(20, $currentScore + $Amount)
    $Hero.$normalizedAbility = $newScore

    return ($newScore - $currentScore)
}

function New-HeroAbilityScoreIncreaseEntry {
    param(
        $Hero,
        [string]$Ability,
        [int]$Amount
    )

    $normalizedAbility = Normalize-HeroAbilityName -Ability $Ability
    $appliedAmount = Add-HeroAbilityScoreIncrease -Hero $Hero -Ability $normalizedAbility -Amount $Amount

    return [PSCustomObject]@{
        Ability = $normalizedAbility
        Amount = $appliedAmount
    }
}

function Resolve-HeroAbilityScoreIncreasePlan {
    param(
        [string]$Mode,
        [string]$PrimaryAbility
    )

    $modeText = if ([string]::IsNullOrWhiteSpace($Mode)) { "" } else { $Mode.Trim().ToUpper() }

    switch ($modeText) {
        { $_ -in @("1", "PRIMARY") } {
            return @([PSCustomObject]@{ Ability = $PrimaryAbility; Amount = 2 })
        }
        { $_ -in @("2", "TOUGH") } {
            return @([PSCustomObject]@{ Ability = "CON"; Amount = 2 })
        }
        { $_ -in @("3", "BALANCED") } {
            return @(
                [PSCustomObject]@{ Ability = $PrimaryAbility; Amount = 1 },
                [PSCustomObject]@{ Ability = "CON"; Amount = 1 }
            )
        }
    }

    $compactMode = $modeText -replace "\s", ""

    if ($compactMode -match "^(STR|DEX|CON|INT|WIS|CHA)(\+2)?$") {
        return @([PSCustomObject]@{ Ability = $matches[1]; Amount = 2 })
    }

    if ($compactMode -match "^\+2(STR|DEX|CON|INT|WIS|CHA)$") {
        return @([PSCustomObject]@{ Ability = $matches[1]; Amount = 2 })
    }

    $splitAbilities = @($compactMode -split "[+,/]" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })

    if ($splitAbilities.Count -eq 2) {
        $firstAbility = Normalize-HeroAbilityName -Ability $splitAbilities[0]
        $secondAbility = Normalize-HeroAbilityName -Ability $splitAbilities[1]

        if (-not [string]::IsNullOrWhiteSpace($firstAbility) -and
            -not [string]::IsNullOrWhiteSpace($secondAbility) -and
            $firstAbility -ne $secondAbility) {
            return @(
                [PSCustomObject]@{ Ability = $firstAbility; Amount = 1 },
                [PSCustomObject]@{ Ability = $secondAbility; Amount = 1 }
            )
        }
    }

    return $null
}

function Read-HeroAbilityScoreIncreasePlan {
    param([string]$PrimaryAbility)

    while ($true) {
        Write-SectionTitle -Text "Ability Score Increase" -Color "Green"
        Write-ColorLine "1. Sharpen class focus (+2 $PrimaryAbility)" "White"
        Write-ColorLine "2. Build endurance (+2 CON)" "White"
        Write-ColorLine "3. Balanced growth (+1 $PrimaryAbility, +1 CON)" "White"
        Write-ColorLine "4. Custom focus (+2 any ability)" "White"
        Write-ColorLine "5. Custom split (+1/+1 two abilities)" "White"
        Write-ColorLine ""
        $choice = (Read-Host "Choose ability increase").ToUpper()

        if ($choice -in @("1", "2", "3", "PRIMARY", "TOUGH", "BALANCED")) {
            return Resolve-HeroAbilityScoreIncreasePlan -Mode $choice -PrimaryAbility $PrimaryAbility
        }

        if ($choice -in @("4", "CUSTOM", "FOCUS")) {
            $ability = Normalize-HeroAbilityName -Ability (Read-Host "Choose ability for +2 (STR/DEX/CON/INT/WIS/CHA)")

            if (-not [string]::IsNullOrWhiteSpace($ability)) {
                return @([PSCustomObject]@{ Ability = $ability; Amount = 2 })
            }
        }

        if ($choice -in @("5", "SPLIT")) {
            $firstAbility = Normalize-HeroAbilityName -Ability (Read-Host "First +1 ability")
            $secondAbility = Normalize-HeroAbilityName -Ability (Read-Host "Second +1 ability")

            if (-not [string]::IsNullOrWhiteSpace($firstAbility) -and
                -not [string]::IsNullOrWhiteSpace($secondAbility) -and
                $firstAbility -ne $secondAbility) {
                return @(
                    [PSCustomObject]@{ Ability = $firstAbility; Amount = 1 },
                    [PSCustomObject]@{ Ability = $secondAbility; Amount = 1 }
                )
            }
        }

        Write-ColorLine "Choose a valid ASI option. Split increases must use two different abilities." "DarkYellow"
        Write-ColorLine ""
    }
}

function Resolve-HeroAbilityScoreIncrease {
    param(
        $Hero,
        [int]$Level,
        [string]$Mode = ""
    )

    if (($Level % 4) -ne 0) {
        return $null
    }

    Ensure-HeroAbilityScoreIncreaseState -Hero $Hero
    $levelKey = [string]$Level

    if ($Hero.AbilityScoreIncreasesApplied.ContainsKey($levelKey)) {
        return $null
    }

    $primaryAbility = Get-HeroPrimaryAbilityForASI -Hero $Hero
    $oldConstitutionModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "CON"

    if ([string]::IsNullOrWhiteSpace($Mode) -and (Get-Command Get-UiOutputSuppressed -ErrorAction SilentlyContinue) -and (Get-UiOutputSuppressed)) {
        $Mode = "1"
    }

    $increasePlan = Resolve-HeroAbilityScoreIncreasePlan -Mode $Mode -PrimaryAbility $primaryAbility

    if ($null -eq $increasePlan) {
        $increasePlan = Read-HeroAbilityScoreIncreasePlan -PrimaryAbility $primaryAbility
    }

    $increases = @()

    foreach ($increase in $increasePlan) {
        $increases += New-HeroAbilityScoreIncreaseEntry -Hero $Hero -Ability $increase.Ability -Amount $increase.Amount
    }

    $newConstitutionModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "CON"
    $maxHPDelta = ($newConstitutionModifier - $oldConstitutionModifier) * [Math]::Max(1, [int]$Hero.Level)
    $Hero.AbilityScoreIncreasesApplied[$levelKey] = $true

    return [PSCustomObject]@{
        Level = $Level
        Increases = $increases
        MaxHPDelta = $maxHPDelta
    }
}

function Sync-HeroMaxHPFromAbilityScores {
    param(
        $Hero,
        $HeroHP = $null,
        $MaxHPDelta = $null
    )

    $oldMaxHP = [int]$Hero.HP
    $delta = if ($null -ne $MaxHPDelta) { [int]$MaxHPDelta } else { (Get-HeroMaxHP -Hero $Hero) - $oldMaxHP }
    $newMaxHP = $oldMaxHP + $delta
    $Hero.HP = $newMaxHP

    if ($null -ne $HeroHP) {
        if ($delta -gt 0) {
            $HeroHP.Value += $delta
        }
        elseif ($HeroHP.Value -gt $newMaxHP) {
            $HeroHP.Value = $newMaxHP
        }
    }

    return [PSCustomObject]@{
        OldMaxHP = $oldMaxHP
        NewMaxHP = $newMaxHP
        Delta = $delta
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
        [string]$HPMode = "",
        [string]$ASIMode = ""
    )

    $availableLevelUps = Get-HeroAvailableLevelUps -Hero $Hero
    $levelUpResults = @()

    for ($i = 0; $i -lt $availableLevelUps; $i++) {
        $oldMaxHP = $Hero.HP
        $hpGainResult = Resolve-HeroLevelUpHPGain -Hero $Hero -Mode $HPMode
        $Hero.Level += 1
        $Hero.HP = $oldMaxHP + $hpGainResult.Gain
        $abilityScoreIncrease = Resolve-HeroAbilityScoreIncrease -Hero $Hero -Level $Hero.Level -Mode $ASIMode
        $hpSync = if ($null -ne $abilityScoreIncrease -and [int]$abilityScoreIncrease.MaxHPDelta -ne 0) {
            Sync-HeroMaxHPFromAbilityScores -Hero $Hero -MaxHPDelta $abilityScoreIncrease.MaxHPDelta
        }
        else {
            $null
        }
        $levelUpResults += [PSCustomObject]@{
            Level = $Hero.Level
            Gain = $hpGainResult.Gain
            Mode = $hpGainResult.Mode
            Roll = $hpGainResult.Roll
            AbilityScoreIncrease = $abilityScoreIncrease
            MaxHPSync = $hpSync
        }
    }

    if ($availableLevelUps -gt 0) {
        $HeroHP.Value = $Hero.HP
        Restore-HeroBardicInspiration -Hero $Hero | Out-Null
        Restore-HeroSpellSlots -Hero $Hero | Out-Null
        Restore-HeroRages -Hero $Hero
        Restore-HeroSecondWind -Hero $Hero | Out-Null
    }
    else {
        $HeroHP.Value = [Math]::Min($HeroHP.Value, $Hero.HP)
        Restore-HeroSpellSlots -Hero $Hero | Out-Null
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
        $restoredSecondWind = 0
        $songOfRestBonus = 0

        if ($Hero.Class -eq "Bard") {
            $beforeDice = if ($null -ne $Hero.PSObject.Properties["CurrentBardicInspirationDice"]) { [int]$Hero.CurrentBardicInspirationDice } else { 0 }
            $prepared = Prepare-HeroBardicInspiration -Hero $Hero

            if ($prepared.Success) {
                $restoredBardicInspiration = [Math]::Max(0, [int]$Hero.CurrentBardicInspirationDice - $beforeDice)
            }
        }

        if ($Hero.Class -eq "Fighter") {
            $beforeSecondWind = if ($null -ne $Hero.PSObject.Properties["CurrentSecondWind"]) { [int]$Hero.CurrentSecondWind } else { 0 }
            Restore-HeroSecondWind -Hero $Hero | Out-Null
            $restoredSecondWind = [Math]::Max(0, [int]$Hero.CurrentSecondWind - $beforeSecondWind)
        }

        return [PSCustomObject]@{
            Healed = 0
            Roll = $null
            Modifier = Get-HeroAbilityModifier -Hero $Hero -Ability "CON"
            ClearedBuff = $true
            RestoredBardicInspiration = $restoredBardicInspiration
            RestoredSecondWind = $restoredSecondWind
            SongOfRestBonus = $songOfRestBonus
        }
    }

    $constitutionModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "CON"
    $roll = Roll-Dice -Sides 8
    $songOfRestBonus = Get-HeroSongOfRestBonus -Hero $Hero
    $healing = [Math]::Max(1, $roll + $constitutionModifier + $songOfRestBonus)
    $oldHP = $HeroHP.Value
    $HeroHP.Value = [Math]::Min($Hero.HP, $HeroHP.Value + $healing)
    Clear-HeroBuff -Hero $Hero
    $restoredBardicInspiration = 0
    $restoredSecondWind = 0

    if ($Hero.Class -eq "Bard") {
        $beforeDice = if ($null -ne $Hero.PSObject.Properties["CurrentBardicInspirationDice"]) { [int]$Hero.CurrentBardicInspirationDice } else { 0 }
        $prepared = Prepare-HeroBardicInspiration -Hero $Hero

        if ($prepared.Success) {
            $restoredBardicInspiration = [Math]::Max(0, [int]$Hero.CurrentBardicInspirationDice - $beforeDice)
        }
    }

    if ($Hero.Class -eq "Fighter") {
        $beforeSecondWind = if ($null -ne $Hero.PSObject.Properties["CurrentSecondWind"]) { [int]$Hero.CurrentSecondWind } else { 0 }
        Restore-HeroSecondWind -Hero $Hero | Out-Null
        $restoredSecondWind = [Math]::Max(0, [int]$Hero.CurrentSecondWind - $beforeSecondWind)
    }

    return [PSCustomObject]@{
        Healed = ($HeroHP.Value - $oldHP)
        Roll = $roll
        Modifier = $constitutionModifier
        ClearedBuff = $true
        RestoredBardicInspiration = $restoredBardicInspiration
        RestoredSecondWind = $restoredSecondWind
        SongOfRestBonus = $songOfRestBonus
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
    $hasEquippedArmor = $false

    foreach ($item in $Hero.Inventory) {
        if ($item.Type -eq "Armor" -and $item.Equipped -and $null -ne $item.ArmorBonus) {
            $hasEquippedArmor = $true
            $armorBonus += [int]$item.ArmorBonus

            if ($null -ne $item.PSObject.Properties["AddsDexModifier"] -and $item.AddsDexModifier) {
                $dexBonus = $dexterityModifier

                if ($null -ne $item.PSObject.Properties["DexBonusCap"] -and [int]$item.DexBonusCap -ge 0) {
                    $dexBonus = [Math]::Min($dexBonus, [int]$item.DexBonusCap)
                }

                $armorBonus += $dexBonus
            }
        }
        elseif ($item.Type -eq "Shield" -and $item.Equipped -and $null -ne $item.ArmorBonus) {
            $armorBonus += [int]$item.ArmorBonus
        }
    }

    if (Test-HeroFightingStyleDefenseActive -Hero $Hero -HasEquippedArmor $hasEquippedArmor) {
        $armorBonus += 1
    }

    if ($Hero.Class -eq "Barbarian" -and -not $hasEquippedArmor) {
        $constitutionModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "CON"
        return $Hero.BaseArmorClass + $dexterityModifier + $constitutionModifier
    }

    return $Hero.BaseArmorClass + $armorBonus
}

function Get-HeroUnarmoredDefenseStatus {
    param($Hero)

    if ($null -eq $Hero -or $Hero.Class -ne "Barbarian") {
        return $null
    }

    $hasEquippedArmor = [bool]($Hero.Inventory | Where-Object { $_.Type -eq "Armor" -and $_.Equipped } | Select-Object -First 1)
    $dexterityModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "DEX"
    $constitutionModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "CON"
    $armorClass = $Hero.BaseArmorClass + $dexterityModifier + $constitutionModifier

    return [PSCustomObject]@{
        Active = (-not $hasEquippedArmor)
        ArmorClass = $armorClass
        DexterityModifier = $dexterityModifier
        ConstitutionModifier = $constitutionModifier
    }
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

function Get-HeroCheckProficiencies {
    param($Hero)

    $proficiencies = @()

    if ($null -ne $Hero.PSObject.Properties["CheckProficiencies"] -and $null -ne $Hero.CheckProficiencies) {
        $proficiencies = @($Hero.CheckProficiencies)
    }
    else {
        switch ($Hero.Class) {
            "Barbarian" { $proficiencies = @("STR", "CON") }
            "Bard" { $proficiencies = @("CHA", "Performance") }
            "Fighter" { $proficiencies = @("CON", "WIS") }
            default { $proficiencies = @() }
        }
    }

    if (Test-HeroFeatureUnlocked -Hero $Hero -Feature "LoreBonusProficiencies") {
        $proficiencies += @("Lore", "Investigation", "Insight")
    }

    return @($proficiencies | Select-Object -Unique)
}

function Get-HeroExpertiseTags {
    param($Hero)

    if (-not (Test-HeroFeatureUnlocked -Hero $Hero -Feature "Expertise")) {
        return @()
    }

    if ($Hero.Class -eq "Bard") {
        return @("Performance", "Perception")
    }

    return @()
}

function Get-HeroAbilityCheckModifier {
    param(
        $Hero,
        [string]$Ability,
        [string]$CheckTag = ""
    )

    $modifier = Get-HeroAbilityModifier -Hero $Hero -Ability $Ability
    $proficiencyBonus = Get-HeroProficiencyBonus -Hero $Hero
    $checkProficiencies = @(Get-HeroCheckProficiencies -Hero $Hero)
    $normalizedAbility = $Ability.ToUpper()
    $normalizedTag = if ([string]::IsNullOrWhiteSpace($CheckTag)) { "" } else { $CheckTag.Trim() }
    $isProficient = $false
    $isExpertise = $false

    foreach ($entry in $checkProficiencies) {
        if ([string]::Equals([string]$entry, $normalizedAbility, [System.StringComparison]::OrdinalIgnoreCase) -or
            (-not [string]::IsNullOrWhiteSpace($normalizedTag) -and [string]::Equals([string]$entry, $normalizedTag, [System.StringComparison]::OrdinalIgnoreCase))) {
            $isProficient = $true
            break
        }
    }

    foreach ($entry in (Get-HeroExpertiseTags -Hero $Hero)) {
        if (-not [string]::IsNullOrWhiteSpace($normalizedTag) -and [string]::Equals([string]$entry, $normalizedTag, [System.StringComparison]::OrdinalIgnoreCase)) {
            $isExpertise = $isProficient
            break
        }
    }

    $classBonus = 0

    if ($isExpertise) {
        $classBonus = $proficiencyBonus * 2
    }
    elseif ($isProficient) {
        $classBonus = $proficiencyBonus
    }
    elseif (Test-HeroFeatureUnlocked -Hero $Hero -Feature "JackOfAllTrades") {
        $classBonus = [Math]::Floor($proficiencyBonus / 2)
    }

    return [PSCustomObject]@{
        AbilityModifier = $modifier
        ClassBonus = $classBonus
        TotalModifier = $modifier + $classBonus
        CheckTag = $normalizedTag
        IsProficient = $isProficient
        IsExpertise = $isExpertise
        BonusSource = if ($isExpertise) { "Expertise" } elseif ($isProficient) { "Proficiency" } elseif ($classBonus -gt 0) { "JackOfAllTrades" } else { "" }
    }
}

function Format-HeroAbilityCheckBonusText {
    param($CheckProfile)

    if ($null -eq $CheckProfile -or [int]$CheckProfile.ClassBonus -le 0) {
        return ""
    }

    $source = if ($null -ne $CheckProfile.PSObject.Properties["BonusSource"]) { [string]$CheckProfile.BonusSource } else { "" }

    switch ($source) {
        "Expertise" { return " + $($CheckProfile.ClassBonus) Expertise" }
        "JackOfAllTrades" { return " + $($CheckProfile.ClassBonus) Jack of All Trades" }
        default {
            if ($null -ne $CheckProfile.PSObject.Properties["IsExpertise"] -and [bool]$CheckProfile.IsExpertise) {
                return " + $($CheckProfile.ClassBonus) Expertise"
            }

            return " + $($CheckProfile.ClassBonus) proficiency"
        }
    }
}

function Get-HeroSpellSaveDC {
    param($Hero)

    if ($Hero.Class -eq "Bard") {
        return 8 + (Get-HeroProficiencyBonus -Hero $Hero) + (Get-HeroAbilityModifier -Hero $Hero -Ability "CHA")
    }

    return 8 + (Get-HeroProficiencyBonus -Hero $Hero)
}

function Get-HeroSpellcastingProgression {
    param($Hero)

    if ($null -eq $Hero -or $Hero.Class -ne "Bard") {
        return [PSCustomObject]@{
            CantripsKnown = 0
            SpellsKnown = 0
            MaxSpellSlots = @{ Level1 = 0; Level2 = 0 }
        }
    }

    $level = if ($null -ne $Hero.PSObject.Properties["Level"]) { [int]$Hero.Level } else { 1 }

    if ($level -ge 4) {
        return [PSCustomObject]@{
            CantripsKnown = 3
            SpellsKnown = 7
            MaxSpellSlots = @{ Level1 = 4; Level2 = 3 }
        }
    }

    if ($level -ge 3) {
        return [PSCustomObject]@{
            CantripsKnown = 2
            SpellsKnown = 6
            MaxSpellSlots = @{ Level1 = 4; Level2 = 2 }
        }
    }

    if ($level -ge 2) {
        return [PSCustomObject]@{
            CantripsKnown = 2
            SpellsKnown = 5
            MaxSpellSlots = @{ Level1 = 3; Level2 = 0 }
        }
    }

    return [PSCustomObject]@{
        CantripsKnown = 2
        SpellsKnown = 4
        MaxSpellSlots = @{ Level1 = 2; Level2 = 0 }
    }
}

function New-HeroSpellSlotTable {
    param(
        [int]$Level1 = 0,
        [int]$Level2 = 0
    )

    return @{
        Level1 = [Math]::Max(0, $Level1)
        Level2 = [Math]::Max(0, $Level2)
    }
}

function Get-HeroKnownSpells {
    param($Hero)

    if ($null -eq $Hero -or $Hero.Class -ne "Bard") {
        return @()
    }

    $progression = Get-HeroSpellcastingProgression -Hero $Hero
    $cantripCount = [int]$progression.CantripsKnown
    $spellCount = [int]$progression.SpellsKnown

    $cantrips = @(
        [PSCustomObject]@{ Name = "Vicious Mockery"; Kind = "Cantrip"; SpellLevel = 0 },
        [PSCustomObject]@{ Name = "Minor Illusion"; Kind = "Cantrip"; SpellLevel = 0 },
        [PSCustomObject]@{ Name = "Friends"; Kind = "Cantrip"; SpellLevel = 0 }
    )

    $spells = @(
        [PSCustomObject]@{ Name = "Healing Word"; Kind = "Spell"; SpellLevel = 1 },
        [PSCustomObject]@{ Name = "Dissonant Whispers"; Kind = "Spell"; SpellLevel = 1 },
        [PSCustomObject]@{ Name = "Faerie Fire"; Kind = "Spell"; SpellLevel = 1 },
        [PSCustomObject]@{ Name = "Charm Person"; Kind = "Spell"; SpellLevel = 1 },
        [PSCustomObject]@{ Name = "Heroism"; Kind = "Spell"; SpellLevel = 1 },
        [PSCustomObject]@{ Name = "Suggestion"; Kind = "Spell"; SpellLevel = 2 },
        [PSCustomObject]@{ Name = "Invisibility"; Kind = "Spell"; SpellLevel = 2 }
    )

    return @($cantrips | Select-Object -First $cantripCount) + @($spells | Select-Object -First $spellCount)
}

function Initialize-HeroSpellcasting {
    param($Hero)

    if ($null -eq $Hero -or $Hero.Class -ne "Bard") {
        return $null
    }

    $progression = Get-HeroSpellcastingProgression -Hero $Hero

    if ($null -eq $Hero.PSObject.Properties["CantripsKnown"]) {
        $Hero | Add-Member -NotePropertyName CantripsKnown -NotePropertyValue ([int]$progression.CantripsKnown)
    }
    else {
        $Hero.CantripsKnown = [int]$progression.CantripsKnown
    }

    if ($null -eq $Hero.PSObject.Properties["SpellsKnown"]) {
        $Hero | Add-Member -NotePropertyName SpellsKnown -NotePropertyValue ([int]$progression.SpellsKnown)
    }
    else {
        $Hero.SpellsKnown = [int]$progression.SpellsKnown
    }

    if ($null -eq $Hero.PSObject.Properties["KnownSpells"]) {
        $Hero | Add-Member -NotePropertyName KnownSpells -NotePropertyValue @(Get-HeroKnownSpells -Hero $Hero)
    }
    else {
        $Hero.KnownSpells = @(Get-HeroKnownSpells -Hero $Hero)
    }

    $maxSlots = New-HeroSpellSlotTable -Level1 ([int]$progression.MaxSpellSlots.Level1) -Level2 ([int]$progression.MaxSpellSlots.Level2)

    if ($null -eq $Hero.PSObject.Properties["MaxSpellSlots"]) {
        $Hero | Add-Member -NotePropertyName MaxSpellSlots -NotePropertyValue $maxSlots
    }
    else {
        $Hero.MaxSpellSlots = $maxSlots
    }

    if ($null -eq $Hero.PSObject.Properties["CurrentSpellSlots"] -or $null -eq $Hero.CurrentSpellSlots) {
        $Hero | Add-Member -NotePropertyName CurrentSpellSlots -NotePropertyValue (New-HeroSpellSlotTable -Level1 $maxSlots.Level1 -Level2 $maxSlots.Level2) -Force
    }
    else {
        foreach ($key in @("Level1", "Level2")) {
            if (-not $Hero.CurrentSpellSlots.ContainsKey($key)) {
                $Hero.CurrentSpellSlots[$key] = [int]$maxSlots[$key]
            }

            $Hero.CurrentSpellSlots[$key] = [Math]::Min([int]$Hero.CurrentSpellSlots[$key], [int]$maxSlots[$key])
        }
    }

    return [PSCustomObject]@{
        CantripsKnown = [int]$Hero.CantripsKnown
        SpellsKnown = [int]$Hero.SpellsKnown
        KnownSpells = @($Hero.KnownSpells)
        CurrentSpellSlots = $Hero.CurrentSpellSlots
        MaxSpellSlots = $Hero.MaxSpellSlots
    }
}

function Restore-HeroSpellSlots {
    param($Hero)

    if ($null -eq $Hero -or $Hero.Class -ne "Bard") {
        return $null
    }

    Initialize-HeroSpellcasting -Hero $Hero | Out-Null
    $Hero.CurrentSpellSlots = New-HeroSpellSlotTable -Level1 ([int]$Hero.MaxSpellSlots.Level1) -Level2 ([int]$Hero.MaxSpellSlots.Level2)

    return [PSCustomObject]@{
        Success = $true
        CurrentSpellSlots = $Hero.CurrentSpellSlots
        MaxSpellSlots = $Hero.MaxSpellSlots
    }
}

function Get-HeroSpellcastingStatus {
    param($Hero)

    if ($null -eq $Hero -or $Hero.Class -ne "Bard") {
        return $null
    }

    Initialize-HeroSpellcasting -Hero $Hero | Out-Null

    return [PSCustomObject]@{
        CantripsKnown = [int]$Hero.CantripsKnown
        SpellsKnown = [int]$Hero.SpellsKnown
        KnownSpells = @($Hero.KnownSpells)
        CurrentSpellSlots = $Hero.CurrentSpellSlots
        MaxSpellSlots = $Hero.MaxSpellSlots
    }
}

function Get-HeroSpellDefinition {
    param(
        $Hero,
        [string]$SpellName
    )

    if ([string]::IsNullOrWhiteSpace($SpellName)) {
        return $null
    }

    Initialize-HeroSpellcasting -Hero $Hero | Out-Null
    $normalizedName = $SpellName.Trim()

    return (@($Hero.KnownSpells) | Where-Object { $_.Name -eq $normalizedName } | Select-Object -First 1)
}

function Test-HeroCanCastSpell {
    param(
        $Hero,
        [string]$SpellName
    )

    if ($null -eq $Hero -or $Hero.Class -ne "Bard") {
        return [PSCustomObject]@{
            CanCast = $false
            Spell = $null
            Message = "Only a bard can cast these spells."
        }
    }

    Initialize-HeroSpellcasting -Hero $Hero | Out-Null
    $spell = Get-HeroSpellDefinition -Hero $Hero -SpellName $SpellName

    if ($null -eq $spell) {
        return [PSCustomObject]@{
            CanCast = $false
            Spell = $null
            Message = "$($Hero.Name) does not know $SpellName."
        }
    }

    if ([int]$spell.SpellLevel -le 0) {
        return [PSCustomObject]@{
            CanCast = $true
            Spell = $spell
            Message = "$($spell.Name) is a cantrip and does not spend a spell slot."
        }
    }

    $slotKey = "Level$($spell.SpellLevel)"
    $slotsRemaining = if ($Hero.CurrentSpellSlots.ContainsKey($slotKey)) { [int]$Hero.CurrentSpellSlots[$slotKey] } else { 0 }

    if ($slotsRemaining -le 0) {
        return [PSCustomObject]@{
            CanCast = $false
            Spell = $spell
            Message = "$($Hero.Name) has no level $($spell.SpellLevel) spell slots remaining."
        }
    }

    return [PSCustomObject]@{
        CanCast = $true
        Spell = $spell
        Message = "$($Hero.Name) can cast $($spell.Name)."
    }
}

function Use-HeroSpellSlot {
    param(
        $Hero,
        [int]$SpellLevel
    )

    if ($null -eq $Hero -or $Hero.Class -ne "Bard") {
        return [PSCustomObject]@{
            Success = $false
            SpellLevel = $SpellLevel
            SlotsRemaining = 0
            Message = "Only a bard can spend bard spell slots."
        }
    }

    Initialize-HeroSpellcasting -Hero $Hero | Out-Null

    if ($SpellLevel -le 0) {
        return [PSCustomObject]@{
            Success = $true
            SpellLevel = $SpellLevel
            SlotsRemaining = 0
            Message = "Cantrips do not spend spell slots."
        }
    }

    $slotKey = "Level$SpellLevel"

    if (-not $Hero.CurrentSpellSlots.ContainsKey($slotKey) -or [int]$Hero.CurrentSpellSlots[$slotKey] -le 0) {
        return [PSCustomObject]@{
            Success = $false
            SpellLevel = $SpellLevel
            SlotsRemaining = 0
            Message = "$($Hero.Name) has no level $SpellLevel spell slots remaining."
        }
    }

    $Hero.CurrentSpellSlots[$slotKey] = [Math]::Max(0, [int]$Hero.CurrentSpellSlots[$slotKey] - 1)

    return [PSCustomObject]@{
        Success = $true
        SpellLevel = $SpellLevel
        SlotsRemaining = [int]$Hero.CurrentSpellSlots[$slotKey]
        Message = "$($Hero.Name) spends one level $SpellLevel spell slot."
    }
}

function Get-HeroBardicInspirationMaxDice {
    param($Hero)

    if (-not (Test-HeroFeatureUnlocked -Hero $Hero -Feature "BardicInspiration")) {
        return 0
    }

    return 1 + [Math]::Max(0, (Get-HeroAbilityModifier -Hero $Hero -Ability "CHA"))
}

function Get-HeroSongOfRestBonus {
    param($Hero)

    if (-not (Test-HeroFeatureUnlocked -Hero $Hero -Feature "SongOfRest")) {
        return 0
    }

    return (Roll-Dice -Sides 6)
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

function Restore-HeroBardicInspiration {
    param($Hero)

    if ($Hero.Class -ne "Bard") {
        return $null
    }

    return (Prepare-HeroBardicInspiration -Hero $Hero)
}

function Initialize-HeroBarbarianResources {
    param($Hero)

    if ($null -eq $Hero -or $Hero.Class -ne "Barbarian") {
        return
    }

    if ($null -eq $Hero.PSObject.Properties["MaxRages"]) {
        $Hero | Add-Member -NotePropertyName MaxRages -NotePropertyValue 2
    }

    if ($null -eq $Hero.PSObject.Properties["CurrentRages"]) {
        $Hero | Add-Member -NotePropertyName CurrentRages -NotePropertyValue ([int]$Hero.MaxRages)
    }

    if ($null -eq $Hero.PSObject.Properties["RageActive"]) {
        $Hero | Add-Member -NotePropertyName RageActive -NotePropertyValue $false
    }

    if ($null -eq $Hero.PSObject.Properties["RecklessAttackExposed"]) {
        $Hero | Add-Member -NotePropertyName RecklessAttackExposed -NotePropertyValue $false
    }

    if ($null -eq $Hero.PSObject.Properties["FrenzyUsedThisRage"]) {
        $Hero | Add-Member -NotePropertyName FrenzyUsedThisRage -NotePropertyValue $false
    }
}

function Get-HeroBarbarianResourceStatus {
    param($Hero)

    if ($null -eq $Hero -or $Hero.Class -ne "Barbarian") {
        return $null
    }

    Initialize-HeroBarbarianResources -Hero $Hero

    return [PSCustomObject]@{
        CurrentRages = [int]$Hero.CurrentRages
        MaxRages = [int]$Hero.MaxRages
        RageActive = [bool]$Hero.RageActive
        RecklessAttackExposed = [bool]$Hero.RecklessAttackExposed
        FrenzyUnlocked = Test-HeroFeatureUnlocked -Hero $Hero -Feature "Frenzy"
        FrenzyUsedThisRage = [bool]$Hero.FrenzyUsedThisRage
    }
}

function Start-HeroRage {
    param($Hero)

    if ($null -eq $Hero -or $Hero.Class -ne "Barbarian") {
        return [PSCustomObject]@{
            Success = $false
            Message = "Only a barbarian can rage."
        }
    }

    Initialize-HeroBarbarianResources -Hero $Hero

    if ([bool]$Hero.RageActive) {
        return [PSCustomObject]@{
            Success = $false
            Message = "$($Hero.Name) is already raging."
        }
    }

    if ([int]$Hero.CurrentRages -le 0) {
        return [PSCustomObject]@{
            Success = $false
            Message = "$($Hero.Name) has no rage left before a long rest."
        }
    }

    $Hero.CurrentRages = [Math]::Max(0, [int]$Hero.CurrentRages - 1)
    $Hero.RageActive = $true
    $Hero.FrenzyUsedThisRage = $false

    return [PSCustomObject]@{
        Success = $true
        Message = "$($Hero.Name) lets the red heat in, turning pain into momentum."
    }
}

function Stop-HeroRage {
    param($Hero)

    if ($null -eq $Hero -or $Hero.Class -ne "Barbarian") {
        return
    }

    Initialize-HeroBarbarianResources -Hero $Hero
    $Hero.RageActive = $false
    $Hero.RecklessAttackExposed = $false
    $Hero.FrenzyUsedThisRage = $false
}

function Restore-HeroRages {
    param($Hero)

    if ($null -eq $Hero -or $Hero.Class -ne "Barbarian") {
        return
    }

    Initialize-HeroBarbarianResources -Hero $Hero
    $Hero.CurrentRages = [int]$Hero.MaxRages
    $Hero.RageActive = $false
    $Hero.RecklessAttackExposed = $false
    $Hero.FrenzyUsedThisRage = $false
}

function Test-HeroCanUseFrenzy {
    param($Hero)

    if (-not (Test-HeroFeatureUnlocked -Hero $Hero -Feature "Frenzy")) {
        return $false
    }

    Initialize-HeroBarbarianResources -Hero $Hero
    return ([bool]$Hero.RageActive -and -not [bool]$Hero.FrenzyUsedThisRage)
}

function Use-HeroFrenzy {
    param($Hero)

    if (-not (Test-HeroCanUseFrenzy -Hero $Hero)) {
        return [PSCustomObject]@{
            Success = $false
            Message = "$($Hero.Name) needs an active rage and an unused frenzy opening."
        }
    }

    $Hero.FrenzyUsedThisRage = $true

    return [PSCustomObject]@{
        Success = $true
        Message = "$($Hero.Name)'s rage turns sharp and hungry enough for one extra attack."
    }
}

function Initialize-HeroFighterResources {
    param($Hero)

    if ($null -eq $Hero -or $Hero.Class -ne "Fighter") {
        return
    }

    if ($null -eq $Hero.PSObject.Properties["FightingStyle"]) {
        $Hero | Add-Member -NotePropertyName FightingStyle -NotePropertyValue "Defense"
    }

    if ($null -eq $Hero.PSObject.Properties["MaxSecondWind"]) {
        $Hero | Add-Member -NotePropertyName MaxSecondWind -NotePropertyValue 1
    }

    if ($null -eq $Hero.PSObject.Properties["CurrentSecondWind"]) {
        $Hero | Add-Member -NotePropertyName CurrentSecondWind -NotePropertyValue ([int]$Hero.MaxSecondWind)
    }

    if ($null -eq $Hero.PSObject.Properties["MaxActionSurges"]) {
        $Hero | Add-Member -NotePropertyName MaxActionSurges -NotePropertyValue 1
    }

    if ($null -eq $Hero.PSObject.Properties["CurrentActionSurges"]) {
        $currentActionSurges = if (Test-HeroFeatureUnlocked -Hero $Hero -Feature "ActionSurge") { [int]$Hero.MaxActionSurges } else { 0 }
        $Hero | Add-Member -NotePropertyName CurrentActionSurges -NotePropertyValue $currentActionSurges
    }
}

function Test-HeroFightingStyleDefenseActive {
    param(
        $Hero,
        $HasEquippedArmor = $null
    )

    if ($null -eq $Hero -or $Hero.Class -ne "Fighter") {
        return $false
    }

    Initialize-HeroFighterResources -Hero $Hero

    if ([string]$Hero.FightingStyle -ne "Defense") {
        return $false
    }

    if ($null -eq $HasEquippedArmor) {
        $HasEquippedArmor = [bool]($Hero.Inventory | Where-Object { $_.Type -eq "Armor" -and $_.Equipped } | Select-Object -First 1)
    }

    return [bool]$HasEquippedArmor
}

function Get-HeroFighterResourceStatus {
    param($Hero)

    if ($null -eq $Hero -or $Hero.Class -ne "Fighter") {
        return $null
    }

    Initialize-HeroFighterResources -Hero $Hero
    $maxActionSurges = if (Test-HeroFeatureUnlocked -Hero $Hero -Feature "ActionSurge") { [int]$Hero.MaxActionSurges } else { 0 }

    return [PSCustomObject]@{
        FightingStyle = [string]$Hero.FightingStyle
        DefenseActive = Test-HeroFightingStyleDefenseActive -Hero $Hero
        CurrentSecondWind = [int]$Hero.CurrentSecondWind
        MaxSecondWind = [int]$Hero.MaxSecondWind
        CurrentActionSurges = [Math]::Min([int]$Hero.CurrentActionSurges, $maxActionSurges)
        MaxActionSurges = $maxActionSurges
        ImprovedCritical = Test-HeroFeatureUnlocked -Hero $Hero -Feature "ImprovedCritical"
    }
}

function Restore-HeroSecondWind {
    param($Hero)

    if ($null -eq $Hero -or $Hero.Class -ne "Fighter") {
        return $null
    }

    Initialize-HeroFighterResources -Hero $Hero
    $Hero.CurrentSecondWind = [int]$Hero.MaxSecondWind
    if (Test-HeroFeatureUnlocked -Hero $Hero -Feature "ActionSurge") {
        $Hero.CurrentActionSurges = [int]$Hero.MaxActionSurges
    }
    else {
        $Hero.CurrentActionSurges = 0
    }

    return [PSCustomObject]@{
        Success = $true
        CurrentSecondWind = [int]$Hero.CurrentSecondWind
        MaxSecondWind = [int]$Hero.MaxSecondWind
        CurrentActionSurges = [int]$Hero.CurrentActionSurges
        MaxActionSurges = if (Test-HeroFeatureUnlocked -Hero $Hero -Feature "ActionSurge") { [int]$Hero.MaxActionSurges } else { 0 }
    }
}

function Use-HeroActionSurge {
    param($Hero)

    if ($null -eq $Hero -or $Hero.Class -ne "Fighter") {
        return [PSCustomObject]@{
            Success = $false
            Message = "Only a fighter can use Action Surge."
        }
    }

    if (-not (Test-HeroFeatureUnlocked -Hero $Hero -Feature "ActionSurge")) {
        return [PSCustomObject]@{
            Success = $false
            Message = "Action Surge unlocks for Fighters at level 2."
        }
    }

    Initialize-HeroFighterResources -Hero $Hero

    if ([int]$Hero.CurrentActionSurges -le 0) {
        return [PSCustomObject]@{
            Success = $false
            Message = "$($Hero.Name) has no Action Surge left before a rest."
        }
    }

    $Hero.CurrentActionSurges = [Math]::Max(0, [int]$Hero.CurrentActionSurges - 1)

    return [PSCustomObject]@{
        Success = $true
        Message = "$($Hero.Name) forces one more clean action out of the heartbeat."
    }
}

function Use-HeroSecondWind {
    param(
        $Hero,
        [ref]$HeroHP
    )

    if ($null -eq $Hero -or $Hero.Class -ne "Fighter") {
        return [PSCustomObject]@{
            Success = $false
            Message = "Only a fighter can use Second Wind."
            Roll = 0
            Healing = 0
            Healed = 0
        }
    }

    Initialize-HeroFighterResources -Hero $Hero

    if ([int]$Hero.CurrentSecondWind -le 0) {
        return [PSCustomObject]@{
            Success = $false
            Message = "$($Hero.Name) has no Second Wind left before a rest."
            Roll = 0
            Healing = 0
            Healed = 0
        }
    }

    if ($HeroHP.Value -ge $Hero.HP) {
        return [PSCustomObject]@{
            Success = $false
            Message = "$($Hero.Name) is already at full HP."
            Roll = 0
            Healing = 0
            Healed = 0
        }
    }

    $roll = Roll-Dice -Sides 10
    $healing = [Math]::Max(1, $roll + [int]$Hero.Level)
    $oldHP = $HeroHP.Value
    $HeroHP.Value = [Math]::Min($Hero.HP, $HeroHP.Value + $healing)
    $Hero.CurrentSecondWind = [Math]::Max(0, [int]$Hero.CurrentSecondWind - 1)
    $healed = $HeroHP.Value - $oldHP

    return [PSCustomObject]@{
        Success = $true
        Message = "$($Hero.Name) draws on Second Wind and recovers $healed HP. (d10 roll $roll + level $($Hero.Level))"
        Roll = $roll
        Healing = $healing
        Healed = $healed
    }
}

function Test-HeroRageActive {
    param($Hero)

    if ($null -eq $Hero -or $Hero.Class -ne "Barbarian") {
        return $false
    }

    Initialize-HeroBarbarianResources -Hero $Hero
    return [bool]$Hero.RageActive
}

function Use-HeroBardicInspirationDie {
    param(
        $Hero,
        [bool]$UseInstrumentBonus = $false
    )

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
    $appliedInstrumentBonus = if ($UseInstrumentBonus) { $status.InstrumentBonus } else { 0 }
    $totalBonus = $roll + $appliedInstrumentBonus
    $Hero.CurrentBardicInspirationDice = [Math]::Max(0, $status.CurrentDice - 1)

    return [PSCustomObject]@{
        Success = $true
        TotalBonus = $totalBonus
        Roll = $roll
        InstrumentBonus = $appliedInstrumentBonus
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
        foreach ($inventoryItem in $Hero.Inventory) {
            if ($inventoryItem.Type -eq "Armor") {
                $inventoryItem.Equipped = $false
            }
        }

        $Item.Equipped = $true
        return [PSCustomObject]@{
            Success = $true
            Message = ""
        }
    }

    if ($Item.Type -eq "Shield") {
        foreach ($inventoryItem in $Hero.Inventory) {
            if ($inventoryItem.Type -eq "Shield") {
                $inventoryItem.Equipped = $false
            }
        }

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
        "Fighter" {
            $hero = [PSCustomObject]@{
                Name               = "Lubert Stryer"
                Class              = "Fighter"
                Level              = 1
                LevelCap           = 2
                XP                 = 0
                GoldPouchCapacityGP = 150
                CurrencyCopper     = 0
                ActiveBuff         = $null
                CurrentBardicInspirationDice = 0
                BardicInspirationDieSides = 6
                CantripsKnown      = 2
                SpellsKnown        = 4
                KnownSpells        = @()
                MaxSpellSlots      = @{ Level1 = 2; Level2 = 0 }
                CurrentSpellSlots  = @{ Level1 = 2; Level2 = 0 }
                MaxRages           = 0
                CurrentRages       = 0
                RageActive         = $false
                RecklessAttackExposed = $false
                FightingStyle      = "Defense"
                MaxSecondWind      = 1
                CurrentSecondWind  = 1
                MaxActionSurges    = 1
                CurrentActionSurges = 0
                TutorialCampfireHintShown = $false
                TutorialCombatHintShown = $false
                UnarmedTrainingLevel = 0
                RingWinsTotal      = 0
                RingReputation     = 0
                RingChampionNightWon = $false
                RingStyleCounts    = @{ QuickFinish = 0; Technical = 0; Grappler = 0; Brawler = 0 }
                RingVisits         = 0
                RingRivalries      = @{}
                HitDie             = 10
                STR                = 14
                DEX                = 12
                CON                = 15
                INT                = 10
                WIS                = 10
                CHA                = 11
                CheckProficiencies = @("CON", "WIS", "Perception")
                BaseArmorClass     = 10
                BaseInventorySlots = 8
                BackpackCapacitySlots = 4
                BackpackInventory  = @()
                StashedInventory   = @()
                Inventory          = @(
                    (New-WeaponItem -Name "Shortsword" -Value 0 -AttackBonus 0 -DamageDiceCount 1 -DamageDiceSides 6 -Handedness "One-Handed" -RequiredSTR 10 -SlotCost 1 -Equipped $true)
                    (New-ShieldItem -Name "Simple Round Shield" -Value 0 -ArmorBonus 2 -SlotCost 1 -Equipped $true)
                    (New-ArmorItem -Name "Chain Mail" -Value 0 -ArmorBonus 6 -AddsDexModifier $false -SlotCost 4 -Equipped $true)
                    (New-UtilityItem -Name "Backpack" -Value 0 -SlotBonus 0 -SlotCost 0 -Equipped $true)
                    (New-ConsumableItem -Name "Healing Potion" -Value 0 -HealAmount 8 -SlotCost 1)
                )
            }
        }
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
                MaxRages           = 0
                CurrentRages       = 0
                RageActive         = $false
                RecklessAttackExposed = $false
                TutorialCampfireHintShown = $false
                TutorialCombatHintShown = $false
                UnarmedTrainingLevel = 0
                RingWinsTotal      = 0
                RingReputation     = 0
                RingChampionNightWon = $false
                RingStyleCounts    = @{ QuickFinish = 0; Technical = 0; Grappler = 0; Brawler = 0 }
                RingVisits         = 0
                RingRivalries      = @{}
                HitDie             = 8
                STR                = 8
                DEX                = 14
                CON                = 12
                INT                = 10
                WIS                = 10
                CHA                = 15
                CheckProficiencies = @("CHA", "Performance", "Perception")
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
                MaxRages           = 2
                CurrentRages       = 2
                RageActive         = $false
                RecklessAttackExposed = $false
                FrenzyUsedThisRage = $false
                TutorialCampfireHintShown = $false
                TutorialCombatHintShown = $false
                UnarmedTrainingLevel = 0
                RingWinsTotal      = 0
                RingReputation     = 0
                RingChampionNightWon = $false
                RingStyleCounts    = @{ QuickFinish = 0; Technical = 0; Grappler = 0; Brawler = 0 }
                RingVisits         = 0
                RingRivalries      = @{}
                HitDie             = 12
                STR                = 15
                DEX                = 14
                CON                = 15
                INT                = 8
                WIS                = 10
                CHA                = 8
                CheckProficiencies = @("STR", "CON", "Perception")
                BaseArmorClass     = 10
                BaseInventorySlots = 8
                BackpackCapacitySlots = 4
                BackpackInventory  = @()
                StashedInventory   = @()
                Inventory          = @(
                    (New-WeaponItem -Name "Great Axe" -Value 0 -AttackBonus 0 -DamageDiceCount 1 -DamageDiceSides 12 -Handedness "Two-Handed" -RequiredSTR 13 -SlotCost 2 -Equipped $true)
                    (New-UtilityItem -Name "Backpack" -Value 0 -SlotBonus 0 -SlotCost 0 -Equipped $true)
                    (New-ConsumableItem -Name "Healing Potion" -Value 0 -HealAmount 8 -SlotCost 1)
                )
            }
        }
    }

    $hero | Add-Member -NotePropertyName HP -NotePropertyValue (Get-HeroMaxHP -Hero $hero)
    Initialize-HeroSpellcasting -Hero $hero | Out-Null

    return $hero
}
