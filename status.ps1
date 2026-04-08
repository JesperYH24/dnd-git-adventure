function Get-HeroHPColor {
    param(
        [int]$CurrentHP,
        [int]$MaxHP
    )

    $hpPercent = ($CurrentHP / $MaxHP) * 100

    if ($hpPercent -le 20) {
        return "Red"
    }
    elseif ($hpPercent -le 60) {
        return "Yellow"
    }
    else {
        return "Green"
    }
}

function Get-MonsterHPColor {
    param(
        [int]$CurrentHP,
        [int]$MaxHP
    )

    $hpPercent = ($CurrentHP / $MaxHP) * 100

    if ($hpPercent -le 25) {
        return "Red"
    }
    elseif ($hpPercent -le 50) {
        return "Yellow"
    }
    else {
        return "DarkYellow"
    }
}

function Get-HeroStatusSnapshot {
    param(
        $Hero,
        [int]$HeroHP
    )

    $weapon = Get-HeroWeaponProfile -Hero $Hero
    $nextLevelXP = Get-HeroNextLevelXPThreshold -Hero $Hero
    $displayXP = [Math]::Min($Hero.XP, $nextLevelXP)
    $unarmedTrainingLevel = 0

    if ($null -ne $Hero.PSObject.Properties["UnarmedTrainingLevel"]) {
        $unarmedTrainingLevel = [int]$Hero.UnarmedTrainingLevel
    }

    return [PSCustomObject]@{
        HPColor = Get-HeroHPColor -CurrentHP $HeroHP -MaxHP $Hero.HP
        Weapon = $weapon
        ArmorClass = Get-HeroArmorClass -Hero $Hero
        ActiveBuff = if ($null -ne $Hero.ActiveBuff) { $Hero.ActiveBuff.Name } else { "None" }
        STRMod = Get-HeroAbilityModifier -Hero $Hero -Ability "STR"
        DEXMod = Get-HeroAbilityModifier -Hero $Hero -Ability "DEX"
        CONMod = Get-HeroAbilityModifier -Hero $Hero -Ability "CON"
        INTMod = Get-HeroAbilityModifier -Hero $Hero -Ability "INT"
        WISMod = Get-HeroAbilityModifier -Hero $Hero -Ability "WIS"
        CHAMod = Get-HeroAbilityModifier -Hero $Hero -Ability "CHA"
        DisplayXP = $displayXP
        NextLevelXP = $nextLevelXP
        UnarmedTrainingLevel = $unarmedTrainingLevel
    }
}

function Write-HeroStatusDetails {
    param(
        $Hero,
        [int]$HeroHP,
        $Snapshot
    )

    if ($Snapshot.HPColor -eq "Red") {
        Write-BlinkingLine "$($Hero.Name): $HeroHP/$($Hero.HP) HP"
    }
    else {
        Write-ColorLine "$($Hero.Name): $HeroHP/$($Hero.HP) HP" $Snapshot.HPColor
    }

    Write-ColorLine "Level: $($Hero.Level) | AC: $($Snapshot.ArmorClass) | Weapon: $($Snapshot.Weapon.Name) | To Hit: +$($Snapshot.Weapon.TotalAttackBonus) | Damage: $(Get-WeaponDamageRollText -WeaponProfile $Snapshot.Weapon) + $($Snapshot.Weapon.DamageBonus) ($($Snapshot.Weapon.TotalDamageMin)-$($Snapshot.Weapon.TotalDamageMax)) | Inventory: $(Get-InventoryUsedSlots -Hero $Hero)/$(Get-InventoryCapacity -Hero $Hero) slots" "White"
    Write-ColorLine "XP: $($Snapshot.DisplayXP)/$($Snapshot.NextLevelXP)" "White"
    Write-ColorLine "STR $($Hero.STR) $(Format-AbilityModifier -Modifier $Snapshot.STRMod) | DEX $($Hero.DEX) $(Format-AbilityModifier -Modifier $Snapshot.DEXMod) | CON $($Hero.CON) $(Format-AbilityModifier -Modifier $Snapshot.CONMod)" "DarkGray"
    Write-ColorLine "INT $($Hero.INT) $(Format-AbilityModifier -Modifier $Snapshot.INTMod) | WIS $($Hero.WIS) $(Format-AbilityModifier -Modifier $Snapshot.WISMod) | CHA $($Hero.CHA) $(Format-AbilityModifier -Modifier $Snapshot.CHAMod)" "DarkGray"
    Write-ColorLine "Gold Pouch: $(Get-HeroCurrencyText -Hero $Hero) | Active Buff: $($Snapshot.ActiveBuff)" "DarkYellow"

    if ($Snapshot.UnarmedTrainingLevel -gt 0) {
        Write-ColorLine "Unarmed Training: Tier $($Snapshot.UnarmedTrainingLevel) (+$($Snapshot.UnarmedTrainingLevel) to hit and damage)" "DarkYellow"
    }
}

function Show-Status {
    param(
        $Hero,
        $HeroHP,
        $Monster,
        $MonsterHP
    )

    $snapshot = Get-HeroStatusSnapshot -Hero $Hero -HeroHP $HeroHP

    if ($Monster.isBoss) {
        $monsterColor = "Magenta"
    }
    else {
        $monsterColor = Get-MonsterHPColor -CurrentHP $MonsterHP -MaxHP $Monster.hp
    }

    Write-ColorLine "Status:" "Cyan"
    Start-Sleep -Milliseconds 750

    Write-HeroStatusDetails -Hero $Hero -HeroHP $HeroHP -Snapshot $snapshot

    Start-Sleep -Milliseconds 750

    if ($monsterColor -eq "Red") {
        Write-BlinkingLine "$($Monster.definite): $MonsterHP HP"
    }
    else {
        Write-ColorLine "$($Monster.definite): $MonsterHP HP" $monsterColor
    }

    Write-ColorLine "Monster AC: $($Monster.armorClass) | Attack bonus: $($Monster.attackBonus) | Damage: $(Get-MonsterDamageRollText -Monster $Monster)" "White"
    Start-Sleep -Milliseconds 750
}
