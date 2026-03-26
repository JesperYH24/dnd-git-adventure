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

function Show-Inventory {
    param($Hero)

    Write-ColorLine ""
    Write-ColorLine "===== INVENTORY =====" "Cyan"

    if (-not $Hero.Inventory -or $Hero.Inventory.Count -eq 0) {
        Write-ColorLine "Inventory är tomt." "DarkGray"
        Write-ColorLine ""
        return
    }

    for ($i = 0; $i -lt $Hero.Inventory.Count; $i++) {
        $item = $Hero.Inventory[$i]
        Write-ColorLine "$($i + 1). $($item.Name) [$($item.Type)]" "White"
    }

    Write-ColorLine ""
}

function Resolve-LootDrop {
    param(
        $Hero,
        $Monster
    )

    $loot = Get-MonsterLoot -Monster $Monster

    if (-not $loot -or $loot.Count -eq 0) {
        Write-Scene "$($Monster.definite) hade ingen loot."
        return
    }

    Write-ColorLine ""
    Write-ColorLine "===== LOOT =====" "Yellow"

    foreach ($item in $loot) {
        Write-ColorLine "- $($item.Name) [$($item.Type)]" "White"
    }

    Write-ColorLine ""

    foreach ($item in $loot) {
        $choice = (Read-Host "Vill du plocka upp '$($item.Name)'? (Y/N)").ToUpper()

        if ($choice -eq "Y") {
            $Hero.Inventory += $item
            Write-Scene "$($Hero.Name) plockar upp $($item.Name)."
        }
        else {
            Write-Scene "$($Hero.Name) lämnar kvar $($item.Name)."
        }

        Write-ColorLine ""
    }

    Show-Inventory -Hero $Hero
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
    Resolve-LootDrop -Hero $Hero -Monster $Monster
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