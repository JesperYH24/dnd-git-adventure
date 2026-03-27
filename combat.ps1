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

    $attackRoll = Roll-Dice -Sides 20
    Write-Scene "$($Monster.definite) slår för attack: $attackRoll"

    if ($attackRoll -eq 20) {
        Write-Scene "CRITICAL HIT!"
        $extraDamage = Roll-Damage -Minimum $Monster.damageMin -Maximum $Monster.damageMax
        $monsterDamage = $Monster.damageMax + $extraDamage

        $HeroHP.Value -= $monsterDamage

        Write-Scene "$($Monster.definite) träffar extra hårt och gör $monsterDamage skada! ($($Monster.damageMax) + $extraDamage)"
    }
    elseif ($attackRoll -eq 1) {
        Write-Scene "CRITICAL FAIL!"
        Write-Scene "$($Monster.definite) snubblar till och tappar balansen!"
        $MonsterOffBalance.Value = $true
    }
    elseif ($attackRoll -ge 10) {
        $monsterDamage = Roll-Damage -Minimum $Monster.damageMin -Maximum $Monster.damageMax
        $HeroHP.Value -= $monsterDamage

        Write-Scene "$($Monster.definite) träffar och gör $monsterDamage skada!"
    }
    else {
        Write-Scene "$($Monster.definite) missar!"
    }

    if ($HeroHP.Value -lt 0) {
        $HeroHP.Value = 0
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

function Use-InventoryItem {
    param(
        $Hero,
        [ref]$HeroHP,
        $Item
    )

    if ($Item.Type -eq "Consumable" -and $null -ne $Item.HealAmount) {
        if ($HeroHP.Value -ge $Hero.HP) {
            Write-Scene "$($Hero.Name) har redan full HP och kan inte använda $($Item.Name)."
            return $false
        }

        $oldHP = $HeroHP.Value
        $HeroHP.Value = [Math]::Min($HeroHP.Value + $Item.HealAmount, $Hero.HP)
        $healed = $HeroHP.Value - $oldHP

        Write-Scene "$($Hero.Name) dricker $($Item.Name) och återfår $healed HP!"
        Write-Scene "$($Hero.Name) har nu $($HeroHP.Value)/$($Hero.HP) HP."

        return $true
    }

    Write-Scene "$($Item.Name) kan inte användas just nu."
    return $false
}

function Open-InventoryMenu {
    param(
        $Hero,
        [ref]$HeroHP
    )

    while ($true) {
        Write-ColorLine ""
        Write-ColorLine "===== INVENTORY =====" "Cyan"

        if (-not $Hero.Inventory -or $Hero.Inventory.Count -eq 0) {
            Write-ColorLine "Inventory är tomt." "DarkGray"
            Write-ColorLine ""
            Read-Host "Tryck Enter för att gå tillbaka"
            return $false
        }

        for ($i = 0; $i -lt $Hero.Inventory.Count; $i++) {
            $item = $Hero.Inventory[$i]

            if ($item.Type -eq "Consumable" -and $null -ne $item.HealAmount) {
                Write-ColorLine "$($i + 1). $($item.Name) [$($item.Type)] (+$($item.HealAmount) HP)" "White"
            }
            else {
                Write-ColorLine "$($i + 1). $($item.Name) [$($item.Type)]" "White"
            }
        }

        Write-ColorLine "0. Tillbaka" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Välj itemnummer"

        if ($choice -eq "0") {
            return $false
        }

        if ($choice -notmatch '^\d+$') {
            Write-ColorLine "Skriv ett giltigt nummer." "DarkYellow"
            continue
        }

        $index = [int]$choice - 1

        if ($index -lt 0 -or $index -ge $Hero.Inventory.Count) {
            Write-ColorLine "Det itemet finns inte." "DarkYellow"
            continue
        }

        $selectedItem = $Hero.Inventory[$index]
        $used = Use-InventoryItem -Hero $Hero -HeroHP $HeroHP -Item $selectedItem

        if ($used) {
            $newInventory = @()
            for ($i = 0; $i -lt $Hero.Inventory.Count; $i++) {
                if ($i -ne $index) {
                    $newInventory += $Hero.Inventory[$i]
                }
            }

            $Hero.Inventory = $newInventory
            return $true
        }
    }
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

        $choice = (Read-Host "Vad vill du göra? (A/I/R) - Attack, Inventory eller Run").ToUpper()

        if ($choice -eq "I") {
            Write-ColorLine ""
            $usedItem = Open-InventoryMenu -Hero $Hero -HeroHP $HeroHP

            if ($usedItem) {
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

            continue
        }
        elseif ($choice -eq "R") {
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
            Write-ColorLine "Skriv A, I eller R" "DarkYellow"
            Write-ColorLine ""
        }
    }
}
