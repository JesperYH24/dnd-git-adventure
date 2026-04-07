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

function Show-Status {
    param(
        $Hero,
        $HeroHP,
        $Monster,
        $MonsterHP
    )

    $heroColor = Get-HeroHPColor -CurrentHP $HeroHP -MaxHP $Hero.HP
    $weapon = Get-HeroWeaponProfile -Hero $Hero
    $heroArmorClass = Get-HeroArmorClass -Hero $Hero
    $activeBuff = if ($null -ne $Hero.ActiveBuff) { $Hero.ActiveBuff.Name } else { "None" }
    $strengthModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "STR"
    $dexterityModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "DEX"
    $constitutionModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "CON"
    $intelligenceModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "INT"
    $wisdomModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "WIS"
    $charismaModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "CHA"
    $nextLevelXP = Get-HeroNextLevelXPThreshold -Hero $Hero
    $displayXP = [Math]::Min($Hero.XP, $nextLevelXP)
    $unarmedTrainingLevel = 0

    if ($null -ne $Hero.PSObject.Properties["UnarmedTrainingLevel"]) {
        $unarmedTrainingLevel = [int]$Hero.UnarmedTrainingLevel
    }

    if ($Monster.isBoss) {
        $monsterColor = "Magenta"
    }
    else {
        $monsterColor = Get-MonsterHPColor -CurrentHP $MonsterHP -MaxHP $Monster.hp
    }

    Write-ColorLine "Status:" "Cyan"
    Start-Sleep -Milliseconds 750

    if ($heroColor -eq "Red") {
        Write-BlinkingLine "$($Hero.Name): $HeroHP HP"
    }
    else {
        Write-ColorLine "$($Hero.Name): $HeroHP HP" $heroColor
    }

    Write-ColorLine "Level: $($Hero.Level) | AC: $heroArmorClass | Weapon: $($weapon.Name) | To Hit: +$($weapon.TotalAttackBonus) | Damage: $(Get-WeaponDamageRollText -WeaponProfile $weapon) + $($weapon.DamageBonus) ($($weapon.TotalDamageMin)-$($weapon.TotalDamageMax)) | Inventory: $(Get-InventoryUsedSlots -Hero $Hero)/$(Get-InventoryCapacity -Hero $Hero) slots" "White"
    Write-ColorLine "XP: $displayXP/$nextLevelXP" "White"
    Write-ColorLine "STR $($Hero.STR) $(Format-AbilityModifier -Modifier $strengthModifier) | DEX $($Hero.DEX) $(Format-AbilityModifier -Modifier $dexterityModifier) | CON $($Hero.CON) $(Format-AbilityModifier -Modifier $constitutionModifier)" "DarkGray"
    Write-ColorLine "INT $($Hero.INT) $(Format-AbilityModifier -Modifier $intelligenceModifier) | WIS $($Hero.WIS) $(Format-AbilityModifier -Modifier $wisdomModifier) | CHA $($Hero.CHA) $(Format-AbilityModifier -Modifier $charismaModifier)" "DarkGray"
    Write-ColorLine "Gold Pouch: $(Get-HeroCurrencyText -Hero $Hero) | Active Buff: $activeBuff" "DarkYellow"

    if ($unarmedTrainingLevel -gt 0) {
        Write-ColorLine "Unarmed Training: Tier $unarmedTrainingLevel (+$unarmedTrainingLevel to hit and damage)" "DarkYellow"
    }

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
