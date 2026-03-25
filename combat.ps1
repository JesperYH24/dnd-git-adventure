. "$PSScriptRoot\roll.ps1"
. "$PSScriptRoot\ui.ps1"

function Invoke-HeroAttack {
    param(
        $Hero,
        $Monster,
        [ref]$MonsterHP,
        [ref]$HeroDroppedWeapon
    )

    $heroRoll = Roll-Dice -Sides 20
    Write-Action "$($Hero.Name) slår för attack: $heroRoll" "Cyan"

    if ($heroRoll -eq 20) {
        $extraDamage = Roll-Damage -Minimum $Hero.DamageMin -Maximum $Hero.DamageMax
        $heroDamage = $Hero.DamageMax + $extraDamage
        $MonsterHP.Value -= $heroDamage
        Write-Action "CRITICAL HIT!" "Red"
        Write-Action "$($Hero.Name) träffar $($Monster.definite) extra hårt och gör $heroDamage skada! ($($Hero.DamageMax) + $extraDamage)" "Yellow"
    }
    elseif ($heroRoll -eq 1) {
        $HeroDroppedWeapon.Value = $true
        Write-Action "CRITICAL FAIL!" "Magenta"
        Write-Scene "$($Hero.Name) fumblar, tappar vapnet och måste plocka upp det nästa runda!"
    }
    elseif ($heroRoll -ge 10) {
        $heroDamage = Roll-Damage -Minimum $Hero.DamageMin -Maximum $Hero.DamageMax
        $MonsterHP.Value -= $heroDamage
        Write-Action "$($Hero.Name) träffar $($Monster.definite) och gör $heroDamage skada!" "Yellow"
    }
    else {
        Write-Action "$($Hero.Name) missar attacken!" "DarkGray"
    }

    Write-ColorLine ""
}

function Invoke-MonsterAttack {
    param(
        $Hero,
        $Monster,
        [ref]$HeroHP,
        [ref]$MonsterOffBalance
    )

    $monsterRoll = Roll-Dice -Sides 20
    $monsterColor = if ($Monster.isBoss) { "Magenta" } else { "DarkRed" }
    Write-Action "$($Monster.definite) slår för attack: $monsterRoll" $monsterColor

    if ($monsterRoll -eq 20) {
        $extraDamage = Roll-Damage -Minimum $Monster.damageMin -Maximum $Monster.damageMax
        $monsterDamage = $Monster.damageMax + $extraDamage
        $HeroHP.Value -= $monsterDamage
        Write-Action "CRITICAL HIT!" "Red"
        Write-Action "$($Monster.definite) träffar extra hårt och gör $monsterDamage skada! ($($Monster.damageMax) + $extraDamage)" "Yellow"
    }
    elseif ($monsterRoll -eq 1) {
        $MonsterOffBalance.Value = $true
        Write-Action "CRITICAL FAIL!" "Magenta"
        Write-Scene "$($Monster.definite) kastar sig fram alldeles för vilt, missar och måste samla sig nästa runda!"
    }
    elseif ($monsterRoll -ge 10) {
        $monsterDamage = Roll-Damage -Minimum $Monster.damageMin -Maximum $Monster.damageMax
        $HeroHP.Value -= $monsterDamage
        $damageColor = if ($Monster.isBoss) { "Red" } else { "Yellow" }
        Write-Action "$($Monster.definite) träffar och gör $monsterDamage skada!" $damageColor
    }
    else {
        Write-Action "$($Monster.definite) missar!" "DarkGray"
    }

    Write-ColorLine ""
}

function Start-CombatLoop {
    param(
        $Hero,
        $Monster,
        [ref]$HeroHP,
        [ref]$MonsterHP,
        [ref]$HeroDroppedWeapon,
        [ref]$MonsterOffBalance
    )

    while ($HeroHP.Value -gt 0 -and $MonsterHP.Value -gt 0) {
        Show-Status -Hero $Hero -HeroHP $HeroHP.Value -Monster $Monster -MonsterHP $MonsterHP.Value

        if ($HeroDroppedWeapon.Value) {
            Write-Scene "$($Hero.Name) plockar upp sitt vapen och förlorar rundan!"
            $HeroDroppedWeapon.Value = $false
            Write-ColorLine ""

            if (-not $MonsterOffBalance.Value) {
                Invoke-MonsterAttack -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance

                if ($HeroHP.Value -le 0) {
                    Write-Scene "$($Hero.Name) faller i striden..."
                    break
                }
            }
            else {
                Write-Scene "$($Monster.definite) försöker återfå balansen och kan inte attackera denna runda."
                $MonsterOffBalance.Value = $false
                Write-ColorLine ""
            }

            continue
        }

        $choice = (Read-Host "Vad vill du göra? (A/R) - Attack eller Run").ToUpper()

        if ($choice -eq "R") {
            Write-Scene "$($Hero.Name) flyr från $($Monster.definite)!"
            break
        }
        elseif ($choice -eq "A") {
            Write-ColorLine ""
            Invoke-HeroAttack -Hero $Hero -Monster $Monster -MonsterHP $MonsterHP -HeroDroppedWeapon $HeroDroppedWeapon

            if ($MonsterHP.Value -le 0) {
                Write-Scene "$($Monster.definite) faller till marken. Du vann!"
                break
            }

            if (-not $MonsterOffBalance.Value) {
                Invoke-MonsterAttack -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance

                if ($HeroHP.Value -le 0) {
                    Write-Scene "$($Hero.Name) faller i striden..."
                    break
                }
            }
            else {
                Write-Scene "$($Monster.definite) försöker återfå balansen och kan inte attackera denna runda."
                $MonsterOffBalance.Value = $false
                Write-ColorLine ""
            }
        }
        else {
            Write-ColorLine ""
            Write-ColorLine "Skriv A eller R" "DarkYellow"
            Write-ColorLine ""
        }
    }
}