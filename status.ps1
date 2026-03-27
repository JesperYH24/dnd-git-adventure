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

    Write-ColorLine "AC: $heroArmorClass | Weapon: $($weapon.Name) | Inventory: $(Get-InventoryUsedSlots -Hero $Hero)/$(Get-InventoryCapacity -Hero $Hero) slots" "White"
    Start-Sleep -Milliseconds 750

    if ($monsterColor -eq "Red") {
        Write-BlinkingLine "$($Monster.definite): $MonsterHP HP"
    }
    else {
        Write-ColorLine "$($Monster.definite): $MonsterHP HP" $monsterColor
    }

    Write-ColorLine "Monster AC: $($Monster.armorClass) | Attack bonus: $($Monster.attackBonus)" "White"
    Start-Sleep -Milliseconds 750
}
