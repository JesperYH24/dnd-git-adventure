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

if ($Monster.isBoss) {
    $monsterColor = "Magenta"
}
else {
    $monsterColor = Get-MonsterHPColor -CurrentHP $MonsterHP -MaxHP $Monster.hp
}

    Write-ColorLine "Status:" "Cyan"
    Start-Sleep -Milliseconds 1000

   # HERO HP
if ($heroColor -eq "Red") {
    Write-BlinkingLine "$($Hero.Name): $HeroHP HP"
}
else {
    Write-ColorLine "$($Hero.Name): $HeroHP HP" $heroColor
}

Start-Sleep -Milliseconds 1000

# MONSTER HP
if ($monsterColor -eq "Red") {
    Write-BlinkingLine "$($Monster.definite): $MonsterHP HP"
}
else {
    Write-ColorLine "$($Monster.definite): $MonsterHP HP" $monsterColor
}

Start-Sleep -Milliseconds 1000
}